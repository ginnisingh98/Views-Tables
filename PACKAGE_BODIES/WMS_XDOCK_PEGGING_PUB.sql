--------------------------------------------------------
--  DDL for Package Body WMS_XDOCK_PEGGING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_XDOCK_PEGGING_PUB" AS
/* $Header: WMSXDCKB.pls 120.23.12010000.4 2009/09/04 04:45:24 ssrikaku ship $ */


-- Global constants holding the package name and package version
g_pkg_name    CONSTANT VARCHAR2(30)  := 'WMS_XDOCK_PEGGING_PUB';
g_pkg_version CONSTANT VARCHAR2(100) := '$Header: WMSXDCKB.pls 120.23.12010000.4 2009/09/04 04:45:24 ssrikaku ship $';

-- This is the global cache table used to store the crossdock criteria records
-- encountered during crossdock pegging.  This is defined solely in the package body
-- so only the procedures and functions in this package can access it directly.
-- Set, Get, Delete, and Clear functions will be provided for outside callers.
TYPE crossdock_criteria_tb IS TABLE OF wms_crossdock_criteria%ROWTYPE
  INDEX BY BINARY_INTEGER;
g_crossdock_criteria_tb       crossdock_criteria_tb;

     -- For Wave Planning Crossdocking Simulation
       TYPE wp_crossdock_rec IS RECORD(
    delivery_detail_id number,
    crossdock_qty number);


  TYPE wp_crossdock_tbl IS TABLE OF wp_crossdock_rec INDEX BY BINARY_INTEGER;

  x_wp_crossdock_tbl wp_crossdock_tbl;

-- This is the global cache table used to store the default routing ID for supplies
-- based on the item, org, and vendor.  We do not want to include supply lines with a
-- routing ID of 3 = Direct.  The available routing ID's are as follows:
-- 1. Standard   2. Inspect  3. Direct
TYPE routing_id_tb IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_item_routing_id_tb          routing_id_tb;
g_org_routing_id_tb           routing_id_tb;
g_vendor_routing_id_tb        routing_id_tb;

-- The following types are used to cache the UOM conversions.  The three keys to this
-- are the inventory item, from UOM code, and to UOM code.  This will yield the conversion
-- rate by using a nested PLSQL table structure.
TYPE to_uom_code_tb IS TABLE OF NUMBER INDEX BY VARCHAR2(3);
TYPE from_uom_code_tb IS TABLE OF to_uom_code_tb INDEX BY VARCHAR2(3);
TYPE item_uom_conversion_tb IS TABLE OF from_uom_code_tb INDEX BY BINARY_INTEGER;
g_item_uom_conversion_tb      item_uom_conversion_tb;

-- The following are global constants used in this package.

-- Allocation method for the current pick release batch
G_INVENTORY_ONLY          CONSTANT VARCHAR2(1) := 'I';
G_CROSSDOCK_ONLY          CONSTANT VARCHAR2(1) := 'C';
G_PRIORITIZE_INVENTORY    CONSTANT VARCHAR2(1) := 'N';
G_PRIORITIZE_CROSSDOCK    CONSTANT VARCHAR2(1) := 'X';

-- Types of sources
G_SRC_TYPE_SUP            CONSTANT NUMBER := 1;  -- Source type Supply
G_SRC_TYPE_DEM            CONSTANT NUMBER := 2;  -- Source type Demand

-- Crossdock criterion types
G_CRT_TYPE_OPP            CONSTANT NUMBER := 1;  -- Criterion type Opportunistic
G_CRT_TYPE_PLAN           CONSTANT NUMBER := 2;  -- Criterion type Planned

-- Crossdock criterion rule types
G_CRT_RULE_TYPE_OPP       CONSTANT NUMBER := 10; -- Criterion Rule type Opportunistic
G_CRT_RULE_TYPE_PLAN      CONSTANT NUMBER := 11; -- Criterion Rule type Planned

-- Scheduling methods
G_APPT_START_TIME         CONSTANT NUMBER := 1;  -- Start of dock appointment
G_APPT_MEAN_TIME          CONSTANT NUMBER := 2;  -- Mean of dock appointment
G_APPT_END_TIME           CONSTANT NUMBER := 3;  -- End of dock appointment

-- Crossdocking goals
G_MINIMIZE_WAIT           CONSTANT NUMBER := 1;  -- Minimize time between receipt and shipment
G_MAXIMIZE_XDOCK          CONSTANT NUMBER := 2;  -- Maximize time between receipt and shipment
G_CUSTOM_GOAL             CONSTANT NUMBER := 3;  -- Order supply/demand lines using custom logic

-- Supply sources for Planned Crossdock
G_PLAN_SUP_PO_APPR        CONSTANT NUMBER := 10;  -- Approved PO
G_PLAN_SUP_ASN            CONSTANT NUMBER := 20;  -- ASN
G_PLAN_SUP_REQ            CONSTANT NUMBER := 30;  -- Internal Req
G_PLAN_SUP_INTR           CONSTANT NUMBER := 40;  -- Intransit Shipments
G_PLAN_SUP_WIP            CONSTANT NUMBER := 50;  -- WIP
G_PLAN_SUP_RCV            CONSTANT NUMBER := 60;  -- Material in Receiving

-- Demand sources for Opportunistic Crossdock
G_OPP_DEM_SO_SCHED        CONSTANT NUMBER := 10;  -- Sales Order (Scheduled)
G_OPP_DEM_SO_BKORD        CONSTANT NUMBER := 20;  -- Sales Order (Backordered)
G_OPP_DEM_IO_SCHED        CONSTANT NUMBER := 30;  -- Internal Order (Scheduled)
G_OPP_DEM_IO_BKORD        CONSTANT NUMBER := 40;  -- Internal Order (Backordered)
G_OPP_DEM_WIP_BKORD       CONSTANT NUMBER := 50;  -- WIP Component Demand (Backordered)
l_simulation_mode varchar2(1) := 'N';

-- Procedure to print debug messages.
-- We will rely on the caller to this procedure to determine if debug logging
-- should be done or not instead of querying for the profile value every time.
PROCEDURE print_debug(p_debug_msg IN VARCHAR2)
  IS
BEGIN
   inv_mobile_helper_functions.tracelog
     (p_err_msg => p_debug_msg,
      p_module  => 'WMS_XDock_Pegging_Pub',
      p_level   => 4);
END;


-- This function will store the crossdock criteria record inputted into the cache
-- {{******************** Crossdock Criteria Caching Functions ********************}}
FUNCTION set_crossdock_criteria
  (p_criterion_id IN NUMBER) RETURN BOOLEAN
  IS
BEGIN
   IF (p_criterion_id IS NULL) THEN
      RETURN FALSE;
   END IF;

   IF (g_crossdock_criteria_tb.EXISTS(p_criterion_id)) THEN
      -- {{
      -- Test setting the crossdock criteria record for a crossdock criterion that
      -- is already cached. }}
      RETURN TRUE;
    ELSE
      -- {{
      -- Test setting the crossdock criteria record for a crossdock criterion that
      -- has not yet been cached. }}
      SELECT *
	INTO g_crossdock_criteria_tb(p_criterion_id)
	FROM wms_crossdock_criteria
	WHERE criterion_id = p_criterion_id;
      RETURN TRUE;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;
END set_crossdock_criteria;


-- This function will retrieve the crossdock criteria record inputted from the cache
FUNCTION get_crossdock_criteria
  (p_criterion_id IN NUMBER) RETURN wms_crossdock_criteria%ROWTYPE
  IS
BEGIN
   IF (p_criterion_id IS NULL) THEN
      RETURN NULL;
   END IF;

   IF (NOT g_crossdock_criteria_tb.EXISTS(p_criterion_id)) THEN
      -- {{
      -- Test retrieving a crossdock criteria record for a crossdock criterion that
      -- has not yet been cached. }}
      SELECT *
	INTO g_crossdock_criteria_tb(p_criterion_id)
	FROM wms_crossdock_criteria
	WHERE criterion_id = p_criterion_id;
   END IF;
   -- {{
   -- Test retrieving a crossdock criteria record for a crossdock criterion that
   -- is already cached. }}
   RETURN g_crossdock_criteria_tb(p_criterion_id);
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_crossdock_criteria;


-- This function will delete the crossdock criteria record inputted from the cache
FUNCTION delete_crossdock_criteria
  (p_criterion_id IN NUMBER) RETURN BOOLEAN
  IS
BEGIN
   IF (p_criterion_id IS NULL) THEN
      RETURN FALSE;
   END IF;

   -- {{
   -- Test deleting an existing crossdock criteria record from the cache. }}
   -- {{
   -- Test deleting a non-existing crossdock criteria record from the cache. }}
   g_crossdock_criteria_tb.DELETE(p_criterion_id);
   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;
END delete_crossdock_criteria;


-- This function will clear all of the crossdock criteria records stored in the cache
FUNCTION clear_crossdock_cache RETURN BOOLEAN
  IS
BEGIN
   -- {{
   -- Test clearing the entire crossdock criteria cache. }}
   g_crossdock_criteria_tb.DELETE;
   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;
END clear_crossdock_cache;
-- {{ }}
-- {{******************** End Crossdock Criteria Caching Functions ********************}}
-- {{ }}


-- This is a function used to retrieve the default routing ID given an item, org,
-- and vendor as inputs.  This function will use the same logic as the get_defaul_routing_id
-- in the INV_RCV_COMMON_APIS package.  However we will cache all of the values retrieved
-- for performance.  The order to search for a default routing ID is: item, vendor, org.
-- The org and item should always be inputted and be non-null.
-- {{ }}
-- {{******************** Function get_default_routing_id ********************}}
FUNCTION get_default_routing_id
  (p_organization_id   IN  NUMBER,
   p_item_id           IN  NUMBER,
   p_vendor_id         IN  NUMBER
   ) RETURN NUMBER DETERMINISTIC
  IS
BEGIN
   -- Get the default routing ID based on the item.
   -- {{
   -- Get the routing ID from the item when the info has been cached. }}
   -- {{
   -- Get the routing ID from the item when the info has not been cached. }}
   IF (NOT g_item_routing_id_tb.EXISTS(p_item_id)) THEN
      BEGIN
	 SELECT receiving_routing_id
	   INTO g_item_routing_id_tb(p_item_id)
	   FROM mtl_system_items
	   WHERE inventory_item_id = p_item_id
	   AND organization_id = p_organization_id;
      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    NULL;
	 WHEN OTHERS THEN
	    RAISE fnd_api.g_exc_unexpected_error;
      END;
   END IF;

   -- Return the item default routing ID if a cached value exists
   -- and is not null.  A value might not exist in case of a
   -- NO_DATA_FOUND exception in the query.
   -- {{
   -- Test for item routing ID exists but is NULL.  Make sure we continue searching
   -- for a routing ID at the other levels, i.e. vendor and org. }}
   IF (g_item_routing_id_tb.EXISTS(p_item_id) AND
       g_item_routing_id_tb(p_item_id) IS NOT NULL) THEN
      RETURN g_item_routing_id_tb(p_item_id);
   END IF;

   -- Get the default routing ID based on the vendor
   -- if a value is passed
   -- {{
   -- Get the routing ID from the vendor when the info has been cached. }}
   -- {{
   -- Get the routing ID from the vendor when the info has not been cached. }}
   IF (p_vendor_id IS NOT NULL) THEN
      IF (NOT g_vendor_routing_id_tb.EXISTS(p_vendor_id)) THEN
         BEGIN
	    SELECT receiving_routing_id
	      INTO g_vendor_routing_id_tb(p_vendor_id)
	      FROM po_vendors
	      WHERE vendor_id = p_vendor_id;
	 EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	       NULL;
	    WHEN OTHERS THEN
	       RAISE fnd_api.g_exc_unexpected_error;
	 END;
      END IF;

      -- Return the vendor default routing ID if a cached value exists
      -- and is not null.  A value might not exist in case of a
      -- NO_DATA_FOUND exception in the query.
      -- {{
      -- Test for vendor routing ID exists but is NULL.  Make sure we continue searching
      -- for a routing ID at the other levels, i.e. org. }}
      IF (g_vendor_routing_id_tb.EXISTS(p_vendor_id) AND
	  g_vendor_routing_id_tb(p_vendor_id) IS NOT NULL) THEN
	 RETURN g_vendor_routing_id_tb(p_vendor_id);
      END IF;
   END IF;

   -- Get the default routing ID based on the org
   -- {{
   -- Get the routing ID from the org when the info has been cached. }}
   -- {{
   -- Get the routing ID from the org when the info has not been cached. }}
   IF (NOT g_org_routing_id_tb.EXISTS(p_organization_id)) THEN
      BEGIN
	 SELECT NVL(receiving_routing_id, 1)
	   INTO g_org_routing_id_tb(p_organization_id)
	   FROM rcv_parameters
	   WHERE organization_id = p_organization_id;
      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    NULL;
	 WHEN OTHERS THEN
	    RAISE fnd_api.g_exc_unexpected_error;
      END;
   END IF;

   -- Return the org default routing ID if a cached value exists
   -- and is not null.  A value might not exist in case of a
   -- NO_DATA_FOUND exception in the query.
   -- {{
   -- Test for org routing ID exists but is NULL.  Make sure we continue searching
   -- for a routing ID at the other levels.  (In this case, there are no places left
   -- to search for a routing ID). }}
   IF (g_org_routing_id_tb.EXISTS(p_organization_id) AND
       g_org_routing_id_tb(p_organization_id) IS NOT NULL) THEN
      RETURN g_org_routing_id_tb(p_organization_id);
   END IF;

   -- This case should not happen but return 1 in case nothing
   -- has been found so far.
   -- {{
   -- When no routing ID can be determined, a value of 1 should be returned. }}
   RETURN 1;

EXCEPTION
   WHEN OTHERS THEN
      -- If an exception occurs, just return a value of 1 to indicate
      -- Standard routing as the default.
      RETURN 1;
END get_default_routing_id;
-- {{ }}
-- {{******************** End get_default_routing_id ********************}}
-- {{ }}


-- This is a function used to retrieve the UOM conversion rate given an inventory item ID,
-- from UOM code and to UOM code.  The values retrieved will be cached in a global PLSQL table.
-- {{ }}
-- {{******************** Function get_conversion_rate ********************}}
FUNCTION get_conversion_rate
  (p_item_id           IN  NUMBER,
   p_from_uom_code     IN  VARCHAR2,
   p_to_uom_code       IN  VARCHAR2
   ) RETURN NUMBER
  IS
     l_conversion_rate          NUMBER;
BEGIN
   IF (p_from_uom_code = p_to_uom_code) THEN
      -- No conversion necessary
      l_conversion_rate := 1;
    ELSE
      -- Check if the conversion rate for the item/from UOM/to UOM combination is cached
      IF (g_item_uom_conversion_tb.EXISTS(p_item_id) AND
	  g_item_uom_conversion_tb(p_item_id).EXISTS(p_from_uom_code) AND
	  g_item_uom_conversion_tb(p_item_id)(p_from_uom_code).EXISTS(p_to_uom_code))
	THEN
	 -- Conversion rate is cached so just use the value
	 l_conversion_rate :=
	   g_item_uom_conversion_tb(p_item_id)(p_from_uom_code)(p_to_uom_code);
       ELSE
	 -- Conversion rate is not cached so query and store the value
	 inv_convert.inv_um_conversion(from_unit  => p_from_uom_code,
				       to_unit    => p_to_uom_code,
				       item_id    => p_item_id,
				       uom_rate   => l_conversion_rate);
	 IF (l_conversion_rate > 0) THEN
	    -- Store the conversion rate and also the reverse conversion.
	    -- Do this only if the conversion rate returned is valid, i.e. not negative.
	    -- {{
	    -- Test having an exception when retrieving the UOM conversion rate. }}
	    g_item_uom_conversion_tb(p_item_id)(p_from_uom_code)(p_to_uom_code)
	      := l_conversion_rate;
	    g_item_uom_conversion_tb(p_item_id)(p_to_uom_code)(p_from_uom_code)
	      := 1 / l_conversion_rate;
	 END IF;
      END IF;
   END IF;

   -- Return the conversion rate retrieved
   RETURN l_conversion_rate;

EXCEPTION
   WHEN OTHERS THEN
      -- If an exception occurs, return a negative value.
      -- The calling program should interpret this as an exception in retrieving
      -- the UOM conversion rate.
      RETURN -999;
END get_conversion_rate;
-- {{ }}
-- {{******************** End get_conversion_rate ********************}}
-- {{ }}


-- Function to see if the inputted WDD demand line is associated with an order line that
-- is tied to a WIP supply somehow. i.e. Either already crossdocked or through an existing
-- manual reservation with WIP as the supply for that demand.  This is needed in case we
-- do not want to have order lines partially crossdocked to WIP and other supply types.
-- {{ }}
-- {{******************** Function is_demand_tied_to_wip ********************}}
FUNCTION is_demand_tied_to_wip
  (p_organization_id    IN  NUMBER,
   p_inventory_item_id  IN  NUMBER,
   p_demand_type_id     IN  NUMBER,
   p_demand_header_id   IN  NUMBER,
   p_demand_line_id     IN  NUMBER
   ) RETURN VARCHAR2
  IS
     l_wip_exists       NUMBER;

BEGIN
   -- See if there is an existing reservation tying a WIP supply to this demand order line.
   -- {{
   -- Test for an OE demand input that is tied to a WIP supply and one that is not. }}
   BEGIN
      SELECT 1
	INTO l_wip_exists
	FROM dual
	WHERE EXISTS (SELECT reservation_id
		      FROM mtl_reservations
		      WHERE organization_id = p_organization_id
		      AND inventory_item_id = p_inventory_item_id
		      AND demand_source_type_id = p_demand_type_id
		      AND demand_source_header_id = p_demand_header_id
		      AND demand_source_line_id = p_demand_line_id
		      AND supply_source_type_id = inv_reservation_global.g_source_type_wip);
   EXCEPTION
      WHEN OTHERS THEN
	 -- This should be when no reservations are found
	 RETURN 'N';
   END;

   -- If a reservations exists tying a WIP supply to the demand, return 'Y'.
   IF (l_wip_exists IS NOT NULL) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
   END IF;

END is_demand_tied_to_wip;
-- {{ }}
-- {{******************** End is_demand_tied_to_wip ********************}}
-- {{ }}


-- Function to see if the inputted WDD demand line is associated with an order line that
-- is tied to a non-WIP and non-Inventory supply somehow. i.e. Either already crossdocked or
-- through an existing manual reservation with a non-WIP and non-Inventory supply for that
-- demand.  This is needed in case we do not want to have order lines partially crossdocked
-- to WIP and other supply types.
-- {{ }}
-- {{******************** Function is_demand_tied_to_non_wip ********************}}
FUNCTION is_demand_tied_to_non_wip
  (p_organization_id    IN  NUMBER,
   p_inventory_item_id  IN  NUMBER,
   p_demand_type_id     IN  NUMBER,
   p_demand_header_id   IN  NUMBER,
   p_demand_line_id     IN  NUMBER
   ) RETURN VARCHAR2
  IS
     l_non_wip_exists       NUMBER;

BEGIN
   -- See if there is an existing reservation tying a non-WIP and non-Inventory supply
   -- to this demand order line.
   -- {{
   -- Test for an OE demand input that is tied to a non-WIP and non-INV supply
   -- and one that is not. }}
   BEGIN
      SELECT 1
	INTO l_non_wip_exists
	FROM dual
	WHERE EXISTS (SELECT reservation_id
		      FROM mtl_reservations
		      WHERE organization_id = p_organization_id
		      AND inventory_item_id = p_inventory_item_id
		      AND demand_source_type_id = p_demand_type_id
		      AND demand_source_header_id = p_demand_header_id
		      AND demand_source_line_id = p_demand_line_id
		      AND supply_source_type_id <> inv_reservation_global.g_source_type_wip
		      AND supply_source_type_id <> inv_reservation_global.g_source_type_inv);
   EXCEPTION
      WHEN OTHERS THEN
	 -- This should be when no reservations are found
	 RETURN 'N';
   END;

   -- If a reservations exists tying a non-WIP and non-Inventory supply to the demand,
   -- return 'Y'.
   IF (l_non_wip_exists IS NOT NULL) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
   END IF;

END is_demand_tied_to_non_wip;
-- {{ }}
-- {{******************** End is_demand_tied_to_non_wip ********************}}
-- {{ }}


-- This is a private procedure used to crossdock/split a WDD record during pegging.
-- A common procedure is created since this exact piece of code is called in two places
-- for satisfying existing reservations and newly created crossdock reservations.
-- {{ }}
-- {{******************** Procedure Crossdock_WDD ********************}}
PROCEDURE Crossdock_WDD
  (p_log_prefix              IN      VARCHAR2,
   p_crossdock_type          IN      NUMBER,
   p_batch_id                IN      NUMBER,
   p_wsh_release_table       IN OUT  NOCOPY WSH_PR_CRITERIA.relRecTabTyp,
   p_trolin_delivery_ids     IN OUT  NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
   p_del_detail_id           IN OUT  NOCOPY WSH_PICK_LIST.DelDetTabTyp,
   l_wdd_index               IN OUT  NOCOPY NUMBER,
   l_debug                   IN OUT  NOCOPY NUMBER,
   l_inventory_item_id       IN OUT  NOCOPY NUMBER,
   l_wdd_txn_qty             IN OUT  NOCOPY NUMBER,
   l_atd_qty                 IN OUT  NOCOPY NUMBER,
   l_atd_wdd_qty             IN OUT  NOCOPY NUMBER,
   l_atd_wdd_qty2            IN OUT  NOCOPY NUMBER,
   l_supply_uom_code         IN OUT  NOCOPY VARCHAR2,
   l_demand_uom_code         IN OUT  NOCOPY VARCHAR2,
   l_demand_uom_code2        IN OUT  NOCOPY VARCHAR2,
   l_conversion_rate         IN OUT  NOCOPY NUMBER,
   l_conversion_precision    IN      NUMBER,
   l_demand_line_detail_id   IN OUT  NOCOPY NUMBER,
   l_index                   IN OUT  NOCOPY NUMBER,
   l_detail_id_tab           IN OUT  NOCOPY WSH_UTIL_CORE.id_tab_type,
   l_action_prms             IN OUT  NOCOPY WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type,
   l_action_out_rec          IN OUT  NOCOPY WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type,
   l_split_wdd_id            IN OUT  NOCOPY NUMBER,
   l_detail_info_tab         IN OUT  NOCOPY WSH_INTERFACE_EXT_GRP.Delivery_Details_Attr_Tbl_Type,
   l_in_rec                  IN OUT  NOCOPY WSH_INTERFACE_EXT_GRP.detailInRecType,
   l_out_rec                 IN OUT  NOCOPY WSH_INTERFACE_EXT_GRP.detailOutRecType,
   l_mol_line_id             IN OUT  NOCOPY NUMBER,
   l_split_wdd_index         IN OUT  NOCOPY NUMBER,
   l_split_delivery_index    IN OUT  NOCOPY NUMBER,
   l_split_wdd_rel_rec       IN OUT  NOCOPY WSH_PR_CRITERIA.relRecTyp,
   l_allocation_method       IN OUT  NOCOPY VARCHAR2,
   l_demand_qty              IN OUT  NOCOPY NUMBER,
   l_demand_qty2             IN OUT  NOCOPY NUMBER,
   l_demand_atr_qty          IN OUT  NOCOPY NUMBER,
   l_xdocked_wdd_index	     IN OUT  NOCOPY NUMBER,
   l_supply_type_id          IN OUT  NOCOPY NUMBER,
   x_return_status           IN OUT  NOCOPY VARCHAR2,
   x_msg_count               IN OUT  NOCOPY NUMBER,
   x_msg_data                IN OUT  NOCOPY VARCHAR2,
   x_error_code              OUT     NOCOPY VARCHAR2)
  IS
     l_progress                 VARCHAR2(10);

BEGIN
   -- Check if we need to split the WDD record or not based on the ATD qty
   IF (l_wdd_txn_qty > l_atd_qty) THEN

   	      l_split_flag := 'Y';   -- Make the Split Flag as Y

--We need not update the Delivery Detail in case of Simulation.

      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'WDD txn qty > ATD qty, so need to split the WDD record');
      END IF;
      -- Split the WDD record.
      -- {{
      -- Test for WDD record being split when crossdocking an existing reservation. }}

      -- First convert l_atd_qty to the UOM on the WDD line
      l_conversion_rate := get_conversion_rate(l_inventory_item_id,
					       l_supply_uom_code, l_demand_uom_code);
      IF (l_conversion_rate < 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug(p_log_prefix || 'Error while obtaining UOM conversion rate for WDD');
	 END IF;
	 -- Raise an exception.  The caller will do the rollback, cleanups,
	 -- and decide where to goto next.
	 x_error_code := 'UOM';
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- Round the converted quantity to the standard precision
      l_atd_wdd_qty := ROUND(l_conversion_rate * l_atd_qty, l_conversion_precision);
      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'ATD qty in WDD UOM: => ' || l_atd_wdd_qty || ' ' ||
		     l_demand_uom_code);
      END IF;
      l_progress := '10';

      -- Convert l_atd_qty to the secondary UOM on the WDD line if a value exists
      IF (l_demand_uom_code2 IS NOT NULL) THEN
	 l_conversion_rate := get_conversion_rate(l_inventory_item_id,
						  l_supply_uom_code, l_demand_uom_code2);
	 IF (l_conversion_rate < 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug(p_log_prefix || 'Error while obtaining secondary UOM conversion rate for WDD');
	    END IF;
	    -- Raise an exception.  The caller will do the rollback, cleanups,
	    -- and decide where to goto next.
	    x_error_code := 'UOM';
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
	 -- Round the converted quantity to the standard precision
	 l_atd_wdd_qty2 := ROUND(l_conversion_rate * l_atd_qty, l_conversion_precision);
       ELSE
	 -- Secondary WDD UOM code is NULL
	 l_atd_wdd_qty2 := NULL;
      END IF; -- End retrieving conversion rate
      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'ATD qty in WDD secondary UOM: => ' || l_atd_wdd_qty2 || ' ' ||
		     l_demand_uom_code2);
      END IF;
      l_progress := '20';

      -- Split the WDD line with the partial quantity allocated.  The original WDD
      -- line will retain the unallocated quantity.
      l_detail_id_tab(1) := l_demand_line_detail_id;
      l_action_prms.caller := 'WMS_XDOCK_PEGGING_PUB';
      l_action_prms.action_code := 'SPLIT-LINE';
      l_action_prms.split_quantity := l_atd_wdd_qty;
      l_action_prms.split_quantity2 := l_atd_wdd_qty2;

      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'Call the Delivery_Detail_Action API to split the WDD');
      END IF;

      if l_simulation_mode = 'N' then

      WSH_INTERFACE_GRP.Delivery_Detail_Action
	(p_api_version_number  => 1.0,
	 p_init_msg_list       => fnd_api.g_false,
	 p_commit              => fnd_api.g_false,
	 x_return_status       => x_return_status,
	 x_msg_count           => x_msg_count,
	 x_msg_data            => x_msg_data,
	 p_detail_id_tab       => l_detail_id_tab,
	 p_action_prms         => l_action_prms,
	 x_action_out_rec      => l_action_out_rec
	 );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 IF (l_debug = 1) THEN
	    print_debug(p_log_prefix || 'Error returned from Split Delivery_Detail_Action API: '
			|| x_return_status);
	 END IF;
	 -- Raise an exception.  The caller will do the rollback, cleanups,
	 -- and decide where to goto next.
	 x_error_code := 'DB';
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'Successfully split the WDD record');
      END IF;
      l_progress := '30';

      l_index := l_action_out_rec.result_id_tab.FIRST;
      l_split_wdd_id := l_action_out_rec.result_id_tab(l_index);

end if;

      -- Do the following logic only for Planned Crossdocking
      IF (p_crossdock_type = G_CRT_TYPE_PLAN) THEN
	 -- Insert the split WDD line into p_wsh_release_table.
	 -- The split WDD release record should be the same as the original one with
	 -- only the following fields modified: delivery_detail_id, released_status,
	 -- move_order_line_id (if supply used is receiving) and requested_quantity fields
	 l_split_wdd_rel_rec := p_wsh_release_table(l_wdd_index);
	 l_split_wdd_rel_rec.delivery_detail_id := l_split_wdd_id;
	 l_split_wdd_rel_rec.released_status := 'S';
	 l_split_wdd_rel_rec.move_order_line_id := l_mol_line_id;
	 l_split_wdd_rel_rec.requested_quantity := l_atd_wdd_qty;
	 l_split_wdd_rel_rec.requested_quantity2 := l_atd_wdd_qty2;

	 l_index := p_wsh_release_table.LAST + 1;
	 p_wsh_release_table(l_index) := l_split_wdd_rel_rec;
	 -- Store this newly inserted split WDD index value.  In case of rollback,
	 -- we need to remove this record from p_wsh_release_table.
	 l_split_wdd_index := l_index;

	 -- Update the original WDD line in p_wsh_release_table with the current
	 -- unallocated quantity while retaining the original released_status
	 -- (should be 'R' or 'B').  Do this in the UOM of the WDD line and also update
	 -- the secondary requested quantity field.
	 p_wsh_release_table(l_wdd_index).requested_quantity := l_demand_qty - l_atd_wdd_qty;
	 p_wsh_release_table(l_wdd_index).requested_quantity2 := l_demand_qty2 - l_atd_wdd_qty2;

	 IF (l_debug = 1) THEN
	    print_debug(p_log_prefix || 'Updated the WDD records in p_wsh_release_table');
	 END IF;
      END IF; -- End of: IF (p_crossdock_type = G_CRT_TYPE_PLAN) THEN

      -- Update the demand qty variable to indicate how much quantity on the original
      -- WDD demand line is left to be crossdocked if not crossdocked already.
      -- This is done here outside of the crossdock type loop so opportunistic crossdocking
      -- can have visibility to how much of the WDD demand line was used for crossdock.
      l_demand_qty := l_demand_qty - l_atd_wdd_qty;
      l_demand_qty2 := l_demand_qty2 - l_atd_wdd_qty2;
      -- Update the demand ATR qty variable if necessary.
      -- This is needed for Planned Crossdocking when looping through the available supply lines
      -- in case the WDD demand gets split.  The unallocated WDD that loops again needs to have
      -- the correct ATR qty otherwise the ATD qty calculated will be incorrect.
      IF (l_demand_atr_qty IS NOT NULL) THEN
	 l_demand_atr_qty := l_demand_atr_qty - l_atd_wdd_qty;
       ELSE
	 -- NULL value of demand ATR qty implies we are trying to satisfy an existing
	 -- reservation and there was no need to calculate the ATR qty on the demand line.
	 -- All of the qty on it should be reservable.  In that case, we do not need to
	 -- update this variable since it isn't used.  Doing it here for completeness.
	 l_demand_atr_qty := l_demand_qty;
      END IF;
      l_progress := '40';
    ELSE
      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'WDD txn qty = ATD qty, so no need to split the WDD record');
      END IF;
      -- {{
      -- Test for WDD qty = available to detail qty.  WDD record should be crossdocked
      -- properly. }}

      -- Do the following logic only for Planned Crossdocking
      IF (p_crossdock_type = G_CRT_TYPE_PLAN) THEN
	 -- Crossdock/Update the corresponding record in p_wsh_release_table
	 p_wsh_release_table(l_wdd_index).released_status := 'S';
	 p_wsh_release_table(l_wdd_index).move_order_line_id := l_mol_line_id;
      END IF;

      -- Set the split WDD ID.  Even though the WDD record did not get split,
      -- this variable is used later on to refer to the WDD ID that was crossdocked.
      l_split_wdd_id := l_demand_line_detail_id;

      -- Update the demand qty variable to indicate how much quantity on the original
      -- WDD demand line is left to be crossdocked if not crossdocked already.
      -- This is done here outside of the crossdock type loop so opportunistic crossdocking
      -- can have visibility to how much of the WDD demand line was used for crossdock.
      l_demand_qty := 0;
      l_demand_qty2 := 0;
      -- Update the demand ATR qty for completeness.  This should not be required since
      -- the WDD did not get split.
      l_demand_atr_qty := 0;
       l_split_flag := 'N';
      l_progress := '50';
   END IF; -- End splitting WDD record: Matches IF (l_wdd_txn_qty > l_atd_qty) THEN

   -- Crossdock the WDD record with the allocated quantity.
   -- Update the released_status to 'S' and update the move_order_line_id
   -- column if the supply type used is Receiving.
   IF (l_debug = 1) THEN
      print_debug(p_log_prefix || 'Update the crossdocked WDD record: ' || l_split_wdd_id);
   END IF;

   -- Store the crossdocked WDD record to update in l_detail_info_tab.
   -- The shipping API to update the table of WDD records will be done at the end
   -- once all lines have been considered for crossdocking.
   l_xdocked_wdd_index := l_detail_info_tab.COUNT + 1;
   l_detail_info_tab(l_xdocked_wdd_index).delivery_detail_id := l_split_wdd_id;
   l_detail_info_tab(l_xdocked_wdd_index).released_status := 'S';
   -- For WIP supplies being crossdocked to a WDD demand, do not update
   -- the move_order_line_id column.  This is to mimic 11.5.10 and prior behavior.
   IF (l_supply_type_id <> 5) THEN
      l_detail_info_tab(l_xdocked_wdd_index).move_order_line_id := l_mol_line_id;
   END IF;
   -- For Planned Crossdocking, we also want to update the batch_id column in WDD
   IF (p_crossdock_type = G_CRT_TYPE_PLAN) THEN
      l_detail_info_tab(l_xdocked_wdd_index).batch_id := p_batch_id;
   END IF;

   -- Do the following logic only for Planned Crossdocking
   IF (p_crossdock_type = G_CRT_TYPE_PLAN) THEN
      -- Insert a new record into p_trolin_delivery_ids and p_del_detail_id
      -- for the crossdocked WDD line if allocation method = N (Prioritize Inventory).
      -- This needs to be done whether the crossdocked WDD is a newly split one, or a pre-existing
      -- one in the release_table.  Shipping does not populate the delivery tables with any info
      -- so all crossdocked WDD records should have a record inserted there.
      -- {{
      -- Crossdocked WDD records should insert new records into the delivery tables for
      -- allocation method of Prioritize Inventory. }}
      IF (l_allocation_method = G_PRIORITIZE_INVENTORY) THEN
	 l_index := NVL(p_del_detail_id.LAST, 0) + 1;
	 p_del_detail_id(l_index) := l_split_wdd_id;
	 p_trolin_delivery_ids(l_index) := p_wsh_release_table(l_wdd_index).delivery_id;
	 -- Store this newly inserted delivery related index value.  In case of rollback,
	 -- we need to remove these records from p_del_detail_id and p_trolin_delivery_ids.
	 l_split_delivery_index := l_index;
	 IF (l_debug = 1) THEN
	    print_debug(p_log_prefix || 'Inserted record into delivery tables for crossdocked WDD');
	 END IF;
      END IF;
   END IF;
   l_progress := '60';

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug(p_log_prefix || 'Exiting Crossdock_WDD - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END Crossdock_WDD;
-- {{ }}
-- {{******************** End Crossdock_WDD ********************}}
-- {{ }}


-- This is a private procedure used to crossdock/split an RSV record during
-- both Planned and Opportunistic crossdock pegging for existing reservations.
-- {{ }}
-- {{******************** Procedure Crossdock_RSV ********************}}
PROCEDURE Crossdock_RSV
  (p_log_prefix              IN      VARCHAR2,
   p_crossdock_type          IN      NUMBER,
   l_debug                   IN OUT  NOCOPY NUMBER,
   l_inventory_item_id       IN OUT  NOCOPY NUMBER,
   l_rsv_txn_qty             IN OUT  NOCOPY NUMBER,
   l_atd_qty                 IN OUT  NOCOPY NUMBER,
   l_atd_rsv_qty             IN OUT  NOCOPY NUMBER,
   l_atd_rsv_qty2            IN OUT  NOCOPY NUMBER,
   l_atd_prim_qty            IN OUT  NOCOPY NUMBER,
   l_supply_uom_code         IN OUT  NOCOPY VARCHAR2,
   l_rsv_uom_code            IN OUT  NOCOPY VARCHAR2,
   l_rsv_uom_code2           IN OUT  NOCOPY VARCHAR2,
   l_primary_uom_code        IN OUT  NOCOPY VARCHAR2,
   l_conversion_rate         IN OUT  NOCOPY NUMBER,
   l_conversion_precision    IN      NUMBER,
   l_original_rsv_rec        IN OUT  NOCOPY inv_reservation_global.mtl_reservation_rec_type,
   l_rsv_id                  IN OUT  NOCOPY NUMBER,
   l_to_rsv_rec              IN OUT  NOCOPY inv_reservation_global.mtl_reservation_rec_type,
   l_split_wdd_id            IN OUT  NOCOPY NUMBER,
   l_crossdock_criteria_id   IN OUT  NOCOPY NUMBER,
   l_demand_expected_time    IN OUT  NOCOPY DATE,
   l_supply_expected_time    IN OUT  NOCOPY DATE,
   l_original_serial_number  IN OUT  NOCOPY inv_reservation_global.serial_number_tbl_type,
   l_split_rsv_id            IN OUT  NOCOPY NUMBER,
   l_rsv_qty                 IN OUT  NOCOPY NUMBER,
   l_rsv_qty2                IN OUT  NOCOPY NUMBER,
   l_to_serial_number	     IN OUT  NOCOPY inv_reservation_global.serial_number_tbl_type,
   l_supply_type_id          IN OUT  NOCOPY NUMBER,
   x_return_status           IN OUT  NOCOPY VARCHAR2,
   x_msg_count               IN OUT  NOCOPY NUMBER,
   x_msg_data                IN OUT  NOCOPY VARCHAR2,
   x_error_code              OUT     NOCOPY VARCHAR2)
  IS
     l_progress                 VARCHAR2(10);

BEGIN
   -- Check if we need to split the RSV record or not based on the ATD qty
   IF (l_rsv_txn_qty > l_atd_qty) THEN
      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'RSV txn qty > ATD qty, so need to split the RSV record');
      END IF;
      -- Split the RSV record.
      -- {{
      -- Test for RSV record being split when crossdocking an existing reservation. }}

      -- First convert l_atd_qty to the UOM on the RSV line
      l_conversion_rate := get_conversion_rate(l_inventory_item_id,
					       l_supply_uom_code, l_rsv_uom_code);
      IF (l_conversion_rate < 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug(p_log_prefix || 'Error while obtaining UOM conversion rate for RSV');
	 END IF;
	 -- Raise an exception.  The caller will do the rollback, cleanups,
	 -- and decide where to goto next.
	 x_error_code := 'UOM';
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- Round the converted quantity to the standard precision
      l_atd_rsv_qty := ROUND(l_conversion_rate * l_atd_qty, l_conversion_precision);
      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'ATD qty in RSV UOM: => ' || l_atd_rsv_qty || ' ' ||
		     l_rsv_uom_code);
      END IF;
      l_progress := '10';

      -- Convert l_atd_qty to the secondary UOM on the RSV line if a value exists
      IF (l_rsv_uom_code2 IS NOT NULL) THEN
	 l_conversion_rate := get_conversion_rate(l_inventory_item_id,
						  l_supply_uom_code, l_rsv_uom_code2);
	 IF (l_conversion_rate < 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug(p_log_prefix || 'Error while obtaining secondary UOM conversion rate for RSV');
	    END IF;
	    -- Raise an exception.  The caller will do the rollback, cleanups,
	    -- and decide where to goto next.
	    x_error_code := 'UOM';
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
	 -- Round the converted quantity to the standard precision
	 l_atd_rsv_qty2 := ROUND(l_conversion_rate * l_atd_qty, l_conversion_precision);
       ELSE
	 -- Secondary RSV UOM code is NULL
	 l_atd_rsv_qty2 := NULL;
      END IF; -- End retrieving conversion rate
      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'ATD qty in secondary RSV UOM: => ' || l_atd_rsv_qty2 || ' ' ||
		     l_rsv_uom_code2);
      END IF;
      l_progress := '20';

      -- Do not modify the reservation if the supply is of type WIP.
      -- We just want to update the l_rsv_qty and l_rsv_qty2 quantities.
      IF (l_supply_type_id = 5) THEN
	 IF (l_debug = 1) THEN
	    print_debug(p_log_prefix || 'Do not modify the WIP as supply reservation');
	 END IF;
       ELSE
	 -- Split the reservation with the quantity allocated.  The original RSV record
	 -- will be the non-crossdocked one.
	 l_original_rsv_rec.reservation_id  := l_rsv_id;

	 l_to_rsv_rec.demand_source_line_detail := l_split_wdd_id;
	 l_to_rsv_rec.reservation_quantity := l_atd_rsv_qty;
	 l_to_rsv_rec.reservation_uom_code := l_rsv_uom_code;
	 l_to_rsv_rec.secondary_reservation_quantity := l_atd_rsv_qty2;
	 l_to_rsv_rec.secondary_uom_code := l_rsv_uom_code2;
	 l_to_rsv_rec.primary_reservation_quantity := l_atd_prim_qty;
	 l_to_rsv_rec.primary_uom_code := l_primary_uom_code;
	 l_to_rsv_rec.crossdock_flag := 'Y';
	 l_to_rsv_rec.crossdock_criteria_id := l_crossdock_criteria_id;
	 l_to_rsv_rec.demand_ship_date := l_demand_expected_time;
	 l_to_rsv_rec.supply_receipt_date := l_supply_expected_time;

	 IF (l_debug = 1) THEN
	    print_debug(p_log_prefix || 'Call the transfer_reservation API to split the RSV record');
	 END IF;
	 INV_RESERVATION_PVT.transfer_reservation
	   (p_api_version_number      => 1.0,
	    p_init_msg_lst            => fnd_api.g_false,
	    x_return_status           => x_return_status,
	    x_msg_count               => x_msg_count,
	    x_msg_data                => x_msg_data,
	    p_original_rsv_rec        => l_original_rsv_rec,
	    p_to_rsv_rec	      => l_to_rsv_rec,
	    p_original_serial_number  => l_original_serial_number,
	    p_validation_flag         => fnd_api.g_true,
	    x_reservation_id          => l_split_rsv_id);

	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    IF (l_debug = 1) THEN
	       print_debug(p_log_prefix || 'Error returned from transfer_reservation API: '
			   || x_return_status);
	    END IF;
	    -- Raise an exception.  The caller will do the rollback, cleanups,
	    -- and decide where to goto next.
	    x_error_code := 'DB';
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
	 IF (l_debug = 1) THEN
	    print_debug(p_log_prefix || 'Successfully split the RSV record');
	 END IF;
      END IF;

      -- Decrement the reservation qty variable so we know how much qty is left on the
      -- original reservation to satisfy
      l_rsv_qty := l_rsv_qty - l_atd_rsv_qty;
      l_rsv_qty2 := l_rsv_qty2 - l_atd_rsv_qty2;
      l_progress := '30';
    ELSE
      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'RSV txn qty = ATD qty, so no need to split the RSV record');
      END IF;
      -- l_rsv_txn_qty = l_atd_qty so just crossdock the RSV record.
      -- Update the demand_source_line_detail column to the current WDD, set
      -- crossdock_flag = 'Y', update the expected ship and receipt dates, and update
      -- the crossdock criteria column.
      -- {{
      -- Test for RSV qty = available to detail qty.  Reservation should be crossdocked
      -- properly. }}

      -- Do not modify the reservation if the supply is of type WIP.
      -- We just want to update the l_rsv_qty and l_rsv_qty2 quantities.
      IF (l_supply_type_id = 5) THEN
	 IF (l_debug = 1) THEN
	    print_debug(p_log_prefix || 'Do not modify the WIP as supply reservation');
	 END IF;
       ELSE
	 l_original_rsv_rec.reservation_id  := l_rsv_id;

	 l_to_rsv_rec.demand_source_line_detail := l_split_wdd_id;
	 l_to_rsv_rec.crossdock_flag := 'Y';
	 l_to_rsv_rec.crossdock_criteria_id := l_crossdock_criteria_id;
	 l_to_rsv_rec.demand_ship_date := l_demand_expected_time;
	 l_to_rsv_rec.supply_receipt_date := l_supply_expected_time;

	 IF (l_debug = 1) THEN
	    print_debug(p_log_prefix || 'Call the update_reservation API to crossdock the RSV record');
	 END IF;
	 INV_RESERVATION_PVT.update_reservation
	   (p_api_version_number           => 1.0,
	    p_init_msg_lst                 => fnd_api.g_false,
	    x_return_status                => x_return_status,
	    x_msg_count                    => x_msg_count,
	    x_msg_data                     => x_msg_data,
	    p_original_rsv_rec             => l_original_rsv_rec,
	    p_to_rsv_rec                   => l_to_rsv_rec,
	    p_original_serial_number  	   => l_original_serial_number,
	    p_to_serial_number             => l_to_serial_number,
	    p_validation_flag              => fnd_api.g_true,
	    p_check_availability           => fnd_api.g_false);

	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    IF (l_debug = 1) THEN
	       print_debug(p_log_prefix || 'Error returned from update_reservation API: '
			   || x_return_status);
	    END IF;
	    -- Raise an exception.  The caller will do the rollback, cleanups,
	    -- and decide where to goto next.
	    x_error_code := 'DB';
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
	 IF (l_debug = 1) THEN
	    print_debug(p_log_prefix || 'Successfully updated and crossdocked the RSV record');
	 END IF;
      END IF;

      -- Set the reservation qty to 0 indicating the reservation was fully consumed
      l_rsv_qty := 0;
      l_rsv_qty2 := 0;
      l_progress := '40';
   END IF; -- End crossdocking RSV record: Matches 'IF (l_rsv_txn_qty > l_atd_qty) THEN'

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug(p_log_prefix || 'Exiting Crossdock_RSV - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END Crossdock_RSV;
-- {{ }}
-- {{******************** End Crossdock_RSV ********************}}
-- {{ }}


-- This is a private procedure used to crossdock/split a MOL record during pegging.
-- A common procedure is created since this exact piece of code is called in two places
-- for satisfying existing reservations and newly created crossdock reservations.
-- {{ }}
-- {{******************** Procedure Crossdock_MOL ********************}}
PROCEDURE Crossdock_MOL
  (p_log_prefix              IN      VARCHAR2,
   p_crossdock_type          IN      NUMBER,
   l_debug                   IN OUT  NOCOPY NUMBER,
   l_inventory_item_id       IN OUT  NOCOPY NUMBER,
   l_mol_qty                 IN OUT  NOCOPY NUMBER,
   l_mol_qty2                IN OUT  NOCOPY NUMBER,
   l_atd_qty                 IN OUT  NOCOPY NUMBER,
   l_atd_mol_qty2            IN OUT  NOCOPY NUMBER,
   l_supply_uom_code         IN OUT  NOCOPY VARCHAR2,
   l_mol_uom_code2           IN OUT  NOCOPY VARCHAR2,
   l_conversion_rate         IN OUT  NOCOPY NUMBER,
   l_conversion_precision    IN      NUMBER,
   l_mol_prim_qty            IN OUT  NOCOPY NUMBER,
   l_atd_prim_qty            IN OUT  NOCOPY NUMBER,
   l_split_wdd_id            IN OUT  NOCOPY NUMBER,
   l_mol_header_id           IN OUT  NOCOPY NUMBER,
   l_mol_line_id             IN OUT  NOCOPY NUMBER,
   l_supply_atr_qty          IN OUT  NOCOPY NUMBER,
   l_demand_type_id          IN OUT  NOCOPY NUMBER,
   l_wip_entity_id           IN OUT  NOCOPY NUMBER,
   l_operation_seq_num       IN OUT  NOCOPY NUMBER,
   l_repetitive_schedule_id  IN OUT  NOCOPY NUMBER,
   l_wip_supply_type         IN OUT  NOCOPY NUMBER,
   l_xdocked_wdd_index	     IN OUT  NOCOPY NUMBER,
   l_detail_info_tab         IN OUT  NOCOPY WSH_INTERFACE_EXT_GRP.Delivery_Details_Attr_Tbl_Type,
   l_wdd_index               IN OUT  NOCOPY NUMBER,
   l_split_wdd_index         IN OUT  NOCOPY NUMBER,
   p_wsh_release_table       IN OUT  NOCOPY WSH_PR_CRITERIA.relRecTabTyp,
   l_supply_type_id          IN OUT  NOCOPY NUMBER,
   x_return_status           IN OUT  NOCOPY VARCHAR2,
   x_msg_count               IN OUT  NOCOPY NUMBER,
   x_msg_data                IN OUT  NOCOPY VARCHAR2,
   x_error_code              OUT     NOCOPY VARCHAR2,
   l_criterion_type          IN             NUMBER DEFAULT NULL)
  IS
     l_progress                 VARCHAR2(10);
     l_backorder_detail_id      NUMBER;
     l_crossdock_type           NUMBER;
     l_split_mol_line_id        NUMBER;

BEGIN
   -- Set the value 'mtrl.backorder_delivery_detail_id' should be updated to
   -- based on OE or WIP demand.
   -- {{
   -- Test crossdocking a MOL to a demand of type WIP and OE for
   -- opportunistic crossdocking. }}
   IF (l_demand_type_id = 5) THEN
      -- WIP backordered component demand
      l_backorder_detail_id := l_wip_entity_id;
      l_crossdock_type := 2;
    ELSE
      -- OE demand
      l_backorder_detail_id := l_split_wdd_id;
      l_crossdock_type := 1;
   END IF;

   -- Check if we need to split the MOL record or not based on the ATD qty
   IF (l_mol_qty > l_atd_qty) THEN
      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'MOL qty > ATD qty, so need to split the MOL record');
      END IF;
      -- Split the MOL record.
      -- {{
      -- Test for splitting a MOL record for an existing reservation using
      -- In Receiving as the supply line source. }}

      -- Convert l_atd_qty to the secondary UOM on the MOL line if a value exists
      IF (l_mol_uom_code2 IS NOT NULL) THEN
	 l_conversion_rate := get_conversion_rate(l_inventory_item_id,
						  l_supply_uom_code, l_mol_uom_code2);
	 IF (l_conversion_rate < 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug(p_log_prefix || 'Error while obtaining UOM2 conversion rate for MOL');
	    END IF;
	    -- Raise an exception.  The caller will do the rollback, cleanups,
	    -- and decide where to goto next.
	    x_error_code := 'UOM';
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
	 -- Round the converted quantity to the standard precision
	 l_atd_mol_qty2 := ROUND(l_conversion_rate * l_atd_qty, l_conversion_precision);
       ELSE
	 -- Secondary RSV UOM code is NULL
	 l_atd_mol_qty2 := NULL;
      END IF; -- End retrieving conversion rate
      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'ATD qty in secondary MOL UOM: => ' || l_atd_mol_qty2 || ' ' ||
		     l_mol_uom_code2);
      END IF;
      l_progress := '10';

      -- Insert the new split MOL record which will be crossdocked with the
      -- the available to detail quantity.
      -- Note I would use a MERGE statement to do the INSERT and UPDATE in one SQL
      -- call.  However, this has a limitation where the INSERT clause does not work
      -- with a subquery which is how we are inserting the split MOL record.
      -- The alternative is to store each of the columns in a variable but that
      -- is not ideal.
      BEGIN
	 INSERT INTO mtl_txn_request_lines
	   (LINE_ID
	    ,HEADER_ID
	    ,LINE_NUMBER
	    ,ORGANIZATION_ID
	    ,INVENTORY_ITEM_ID
	    ,REVISION
	    ,FROM_SUBINVENTORY_CODE
	    ,FROM_LOCATOR_ID
	    ,TO_SUBINVENTORY_CODE
	    ,TO_LOCATOR_ID
	    ,TO_ACCOUNT_ID
	    ,LOT_NUMBER
	    ,SERIAL_NUMBER_START
	    ,SERIAL_NUMBER_END
	    ,UOM_CODE
	    ,QUANTITY
	    ,QUANTITY_DELIVERED
	    ,QUANTITY_DETAILED
	    ,DATE_REQUIRED
	    ,REASON_ID
	    ,REFERENCE
	    ,REFERENCE_TYPE_CODE
	    ,REFERENCE_ID
	    ,PROJECT_ID
	    ,TASK_ID
	    ,TRANSACTION_HEADER_ID
	    ,LINE_STATUS
	    ,STATUS_DATE
	    ,LAST_UPDATED_BY
	    ,LAST_UPDATE_LOGIN
	    ,LAST_UPDATE_DATE
	    ,CREATED_BY
	    ,CREATION_DATE
	    ,REQUEST_ID
	    ,PROGRAM_APPLICATION_ID
	    ,PROGRAM_ID
	    ,PROGRAM_UPDATE_DATE
	    ,ATTRIBUTE1
	    ,ATTRIBUTE2
	    ,ATTRIBUTE3
	    ,ATTRIBUTE4
	    ,ATTRIBUTE5
	    ,ATTRIBUTE6
	    ,ATTRIBUTE7
	    ,ATTRIBUTE8
	    ,ATTRIBUTE9
	    ,ATTRIBUTE10
	    ,ATTRIBUTE11
	    ,ATTRIBUTE12
	    ,ATTRIBUTE13
	    ,ATTRIBUTE14
	   ,ATTRIBUTE15
	   ,ATTRIBUTE_CATEGORY
	   ,TXN_SOURCE_ID
	   ,TXN_SOURCE_LINE_ID
	   ,TXN_SOURCE_LINE_DETAIL_ID
	   ,TRANSACTION_TYPE_ID
	   ,TRANSACTION_SOURCE_TYPE_ID
	   ,PRIMARY_QUANTITY
	   ,TO_ORGANIZATION_ID
	   ,PUT_AWAY_STRATEGY_ID
	   ,PICK_STRATEGY_ID
	   ,SHIP_TO_LOCATION_ID
	   ,UNIT_NUMBER
	   ,REFERENCE_DETAIL_ID
	   ,ASSIGNMENT_ID
	   ,FROM_COST_GROUP_ID
	   ,TO_COST_GROUP_ID
	   ,LPN_ID
	   ,TO_LPN_ID
	   ,PICK_SLIP_NUMBER
	   ,PICK_SLIP_DATE
	   ,INSPECTION_STATUS
	   ,PICK_METHODOLOGY_ID
	   ,CONTAINER_ITEM_ID
	   ,CARTON_GROUPING_ID
	   ,BACKORDER_DELIVERY_DETAIL_ID
	   ,WMS_PROCESS_FLAG
	   ,SHIP_SET_ID
	   ,SHIP_MODEL_ID
	   ,MODEL_QUANTITY
	   ,FROM_SUBINVENTORY_ID
	   ,TO_SUBINVENTORY_ID
	   ,CROSSDOCK_TYPE
	   ,REQUIRED_QUANTITY
	   ,GRADE_CODE
	   ,SECONDARY_QUANTITY
	   ,SECONDARY_QUANTITY_DELIVERED
	   ,SECONDARY_QUANTITY_DETAILED
	   ,SECONDARY_REQUIRED_QUANTITY
	   ,SECONDARY_UOM_CODE
	   ,WIP_ENTITY_ID
	   ,REPETITIVE_SCHEDULE_ID
	   ,OPERATION_SEQ_NUM
	   ,WIP_SUPPLY_TYPE
	   )
	   (SELECT
	    mtl_txn_request_lines_s.NEXTVAL -- LINE_ID
	    ,HEADER_ID
	    ,mtrl_max.line_num --LINE_NUMBER
	    ,ORGANIZATION_ID
	    ,INVENTORY_ITEM_ID
	    ,REVISION
	    ,FROM_SUBINVENTORY_CODE
	    ,FROM_LOCATOR_ID
	    ,TO_SUBINVENTORY_CODE
	    ,TO_LOCATOR_ID
	    ,TO_ACCOUNT_ID
	    ,LOT_NUMBER
	    ,SERIAL_NUMBER_START
	    ,SERIAL_NUMBER_END
	    ,UOM_CODE
	    ,l_atd_qty --QUANTITY
	    ,QUANTITY_DELIVERED
	    ,QUANTITY_DETAILED
	    ,DATE_REQUIRED
	    ,REASON_ID
	    ,REFERENCE
	    ,REFERENCE_TYPE_CODE
	    ,REFERENCE_ID
	    ,PROJECT_ID
	    ,TASK_ID
	    ,TRANSACTION_HEADER_ID
	    ,LINE_STATUS
	    ,STATUS_DATE
	    ,LAST_UPDATED_BY
	    ,LAST_UPDATE_LOGIN
	    ,SYSDATE --LAST_UPDATE_DATE
	    ,CREATED_BY
	    ,SYSDATE --CREATION_DATE
	    ,REQUEST_ID
	    ,PROGRAM_APPLICATION_ID
	    ,PROGRAM_ID
	    ,PROGRAM_UPDATE_DATE
	    ,ATTRIBUTE1
	    ,ATTRIBUTE2
	    ,ATTRIBUTE3
	    ,ATTRIBUTE4
	    ,ATTRIBUTE5
	    ,ATTRIBUTE6
	    ,ATTRIBUTE7
	    ,ATTRIBUTE8
	    ,ATTRIBUTE9
	   ,ATTRIBUTE10
	   ,ATTRIBUTE11
	   ,ATTRIBUTE12
	   ,ATTRIBUTE13
	   ,ATTRIBUTE14
	   ,ATTRIBUTE15
	   ,ATTRIBUTE_CATEGORY
	   ,TXN_SOURCE_ID
	   ,TXN_SOURCE_LINE_ID
	   ,TXN_SOURCE_LINE_DETAIL_ID
	   ,TRANSACTION_TYPE_ID
	   ,TRANSACTION_SOURCE_TYPE_ID
	   ,l_atd_prim_qty --PRIMARY_QUANTITY
	   ,TO_ORGANIZATION_ID
	   ,PUT_AWAY_STRATEGY_ID
	   ,PICK_STRATEGY_ID
	   ,SHIP_TO_LOCATION_ID
	   ,UNIT_NUMBER
	   -- Change made for Inbound. For Opportunistic cases inbound
	   -- can call crossdock API for a particular MOL. Then they need
	   -- to know the MOLs that have been split and created for this
	   -- line so that they can requery them somehow for creating suggestions.
	   ,Decode(l_criterion_type,g_crt_type_opp,l_mol_line_id,reference_detail_id)
	   ,ASSIGNMENT_ID
	   ,FROM_COST_GROUP_ID
	   ,TO_COST_GROUP_ID
	   ,LPN_ID
	   ,TO_LPN_ID
	   ,PICK_SLIP_NUMBER
	   ,PICK_SLIP_DATE
	   ,INSPECTION_STATUS
	   ,PICK_METHODOLOGY_ID
	   ,CONTAINER_ITEM_ID
	   ,CARTON_GROUPING_ID
	   ,l_backorder_detail_id --BACKORDER_DELIVERY_DETAIL_ID
	   ,WMS_PROCESS_FLAG
	   ,SHIP_SET_ID
	   ,SHIP_MODEL_ID
	   ,MODEL_QUANTITY
	   ,FROM_SUBINVENTORY_ID
	   ,TO_SUBINVENTORY_ID
	   ,l_crossdock_type --CROSSDOCK_TYPE
	   ,REQUIRED_QUANTITY
	   ,GRADE_CODE
	   ,l_atd_mol_qty2 --SECONDARY_QUANTITY
	   ,SECONDARY_QUANTITY_DELIVERED
	   ,SECONDARY_QUANTITY_DETAILED
	   ,SECONDARY_REQUIRED_QUANTITY
	   ,SECONDARY_UOM_CODE
	   ,l_wip_entity_id --WIP_ENTITY_ID
	   ,l_repetitive_schedule_id --REPETITIVE_SCHEDULE_ID
	   ,l_operation_seq_num --OPERATION_SEQ_NUM
	   ,l_wip_supply_type --WIP_SUPPLY_TYPE
	   FROM mtl_txn_request_lines mtrl, (SELECT MAX(line_number) + 1 AS line_num
					     FROM mtl_txn_request_lines
					     WHERE header_id = l_mol_header_id) mtrl_max
	     WHERE mtrl.line_id = l_mol_line_id);
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug(p_log_prefix || 'Error inserting split MOL record');
	    END IF;
	    -- Raise an exception.  The caller will do the rollback, cleanups,
	    -- and decide where to goto next.
	    x_error_code := 'DB';
	    RAISE FND_API.G_EXC_ERROR;
      END; -- End inserting split MOL record into MTL_TXN_REQUEST_LINES

      -- Retrieve the split MOL line ID we have just inserted above.
      -- We cannot use the RETURNING clause since a sub-query was used for the insert.
      -- As of 10g, this is not a supported feature.
      BEGIN
	 SELECT line_id
	   INTO l_split_mol_line_id
	   FROM mtl_txn_request_lines
	   WHERE header_id = l_mol_header_id
	   AND ROWNUM = 1
	   ORDER BY line_number DESC;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug(p_log_prefix || 'Error retrieving the split MOL line ID');
	    END IF;
	    -- Raise an exception.  The caller will do the rollback, cleanups,
	    -- and decide where to goto next.
	    x_error_code := 'DB';
	    RAISE FND_API.G_EXC_ERROR;
      END;
      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'Successfully inserted/split the MOL record: ' ||
		     l_split_mol_line_id);
      END IF;

      -- Update the quantity on the original MOL record.
      BEGIN
	 UPDATE mtl_txn_request_lines SET
	   quantity = l_mol_qty - l_atd_qty,
	   primary_quantity = l_mol_prim_qty - l_atd_prim_qty,
	   secondary_quantity = l_mol_qty2 - l_atd_mol_qty2
	   WHERE line_id = l_mol_line_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug(p_log_prefix || 'Error updating the original MOL record');
	    END IF;
	    -- Raise an exception.  The caller will do the rollback, cleanups,
	    -- and decide where to goto next.
	    x_error_code := 'DB';
	    RAISE FND_API.G_EXC_ERROR;
      END;

      -- Update the MOL qty values to indicate how much quantity from the original MOL
      -- is still available for crossdocking.
      l_mol_qty := l_mol_qty - l_atd_qty;
      l_mol_prim_qty := l_mol_prim_qty - l_atd_prim_qty;
      l_mol_qty2 := l_mol_qty2 - l_atd_mol_qty2;
      -- Do the following logic only for Opportunistic Crossdocking.
      -- This is needed so we can tell if the MOL supply line has been fully
      -- crossdocked yet.
      IF (p_crossdock_type = G_CRT_TYPE_OPP) THEN
	 l_supply_atr_qty := l_supply_atr_qty - l_atd_qty;
      END IF;

      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'Successfully updated and crossdocked the MOL record');
      END IF;
      l_progress := '20';
    ELSE
      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'MOL qty = ATD qty, so no need to split the MOL record');
      END IF;
      -- l_mol_qty = l_atd_qty so just crossdock the MOL record.
      -- Update the backorder_delivery_detail_id column and set the crossdock_type
      -- to 1 for crossdocking to Sales or Internal Order.
      -- {{
      -- Test for MOL qty = available to detail qty.  MOL record should be
      -- crossdocked properly. }}11
      BEGIN
	 UPDATE mtl_txn_request_lines SET
	   backorder_delivery_detail_id = l_backorder_detail_id,
	   crossdock_type = l_crossdock_type,
	   wip_entity_id = l_wip_entity_id,
	   repetitive_schedule_id = l_repetitive_schedule_id,
	   operation_seq_num = l_operation_seq_num,
	   wip_supply_type = l_wip_supply_type
	   WHERE line_id = l_mol_line_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug(p_log_prefix || 'Error updating the MOL record');
	    END IF;
	    -- Raise an exception.  The caller will do the rollback, cleanups,
	    -- and decide where to goto next.
	    x_error_code := 'DB';
	    RAISE FND_API.G_EXC_ERROR;
      END;

      -- Update the MOL qty field to indicate how much quantity from the original MOL
      -- is still available for crossdocking.
      l_mol_qty := 0;
      l_mol_prim_qty := 0;
      l_mol_qty2 := 0;
      -- Do the following logic only for Opportunistic Crossdocking.
      -- This is needed so we can tell if the MOL supply line has been fully
      -- crossdocked yet.
      IF (p_crossdock_type = G_CRT_TYPE_OPP) THEN
	 l_supply_atr_qty := 0;
      END IF;

      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'Successfully updated and crossdocked the MOL record');
      END IF;
      l_progress := '30';
   END IF; -- End crossdocking MOL record: Matches 'IF (l_mol_qty > l_atd_qty) THEN'

   -- If the MOL used to crossdock was split, then it is the split MOL that should be
   -- tied to the WDD lines.  We need to make sure crossdocked WDD lines are updated
   -- properly.  Additionally, for Planned Crossdocking, the records in p_wsh_release_table
   -- also need to reflect the correct MOL pegged to the WDD.  This needs to be done only
   -- for OE demand.  For WIP backordered component demand, nothing needs to be done since
   -- the WIP job is not tied to the move order line (currently).
   -- For Opportunistic Crossdocking with WIP as the supply being crossdocked to a WDD demand,
   -- we do not need to update the move_order_line_id column.  This is to mimic 11.5.10
   -- and prior behavior.
   IF (l_split_mol_line_id IS NOT NULL AND l_demand_type_id <> 5 AND l_supply_type_id <> 5) THEN
      -- Update the crossdocked WDD to point to the split MOL
      l_detail_info_tab(l_xdocked_wdd_index).move_order_line_id := l_split_mol_line_id;

      -- Update the WDD record in the release table for Planned Crossdocking
      IF (p_crossdock_type = G_CRT_TYPE_PLAN) THEN
	 IF (l_split_wdd_index IS NOT NULL) THEN
	    -- WDD record was also split so update the appropriate crossdocked WDD
	    p_wsh_release_table(l_split_wdd_index).move_order_line_id := l_split_mol_line_id;
	  ELSE
	    -- WDD record was not split so update the current WDD
	    p_wsh_release_table(l_wdd_index).move_order_line_id := l_split_mol_line_id;
	 END IF;
      END IF;
      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'Successfully updated the WDD records with the split MOL line');
      END IF;
      l_progress := '40';
   END IF; -- End of logic to update WDD records with split MOL line

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug(p_log_prefix || 'Exiting Crossdock_MOL - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END Crossdock_MOL;
-- {{ }}
-- {{******************** End Crossdock_MOL ********************}}
-- {{ }}


-- This is a private procedure used to create a crossdock reservation during pegging.
-- This will be used for both Planned and Opportunistic crossdocking.
-- {{ }}
-- {{******************** Procedure Create_RSV ********************}}
PROCEDURE Create_RSV
  (p_log_prefix              IN      VARCHAR2,
   p_crossdock_type          IN      NUMBER,
   l_debug                   IN OUT  NOCOPY NUMBER,
   l_organization_id         IN OUT  NOCOPY NUMBER,
   l_inventory_item_id       IN OUT  NOCOPY NUMBER,
   l_demand_type_id          IN OUT  NOCOPY NUMBER,
   l_demand_so_header_id     IN OUT  NOCOPY NUMBER,
   l_demand_line_id          IN OUT  NOCOPY NUMBER,
   l_split_wdd_id            IN OUT  NOCOPY NUMBER,
   l_primary_uom_code        IN OUT  NOCOPY VARCHAR2,
   l_demand_uom_code2        IN OUT  NOCOPY VARCHAR2,
   l_supply_uom_code         IN OUT  NOCOPY VARCHAR2,
   l_atd_qty                 IN OUT  NOCOPY NUMBER,
   l_atd_prim_qty            IN OUT  NOCOPY NUMBER,
   l_atd_wdd_qty2            IN OUT  NOCOPY NUMBER,
   l_supply_type_id          IN OUT  NOCOPY NUMBER,
   l_supply_header_id        IN OUT  NOCOPY NUMBER,
   l_supply_line_id          IN OUT  NOCOPY NUMBER,
   l_supply_line_detail_id   IN OUT  NOCOPY NUMBER,
   l_crossdock_criteria_id   IN OUT  NOCOPY NUMBER,
   l_supply_expected_time    IN OUT  NOCOPY DATE,
   l_demand_expected_time    IN OUT  NOCOPY DATE,
   l_demand_project_id       IN OUT  NOCOPY NUMBER,
   l_demand_task_id          IN OUT  NOCOPY NUMBER,
   l_original_rsv_rec        IN OUT  NOCOPY inv_reservation_global.mtl_reservation_rec_type,
   l_original_serial_number  IN OUT  NOCOPY inv_reservation_global.serial_number_tbl_type,
   l_to_serial_number        IN OUT  NOCOPY inv_reservation_global.serial_number_tbl_type,
   l_quantity_reserved       IN OUT  NOCOPY NUMBER,
   l_quantity_reserved2      IN OUT  NOCOPY NUMBER,
   l_rsv_id                  IN OUT  NOCOPY NUMBER,
   x_return_status           IN OUT  NOCOPY VARCHAR2,
   x_msg_count               IN OUT  NOCOPY NUMBER,
   x_msg_data                IN OUT  NOCOPY VARCHAR2)
  IS
     l_progress                 VARCHAR2(10);

BEGIN
   -- {{
   -- Test that a valid crossdocked reservation is created.  The quantities should
   -- match the relevant WDD and MOL records. }}
   --
   -- Set the values for the reservation record to be created
   IF (l_debug = 1) THEN
      print_debug(p_log_prefix || 'Requirement Date: ' || l_demand_expected_time);
   END IF;
   l_original_rsv_rec.reservation_id := NULL;
   l_original_rsv_rec.requirement_date := l_demand_expected_time;
   l_original_rsv_rec.organization_id := l_organization_id;
   l_original_rsv_rec.inventory_item_id := l_inventory_item_id;
   l_original_rsv_rec.demand_source_name := NULL;
   l_original_rsv_rec.demand_source_type_id := l_demand_type_id;
   l_original_rsv_rec.demand_source_header_id := l_demand_so_header_id;
   l_original_rsv_rec.demand_source_line_id := l_demand_line_id;
   l_original_rsv_rec.orig_demand_source_type_id := l_demand_type_id;
   l_original_rsv_rec.orig_demand_source_header_id := l_demand_so_header_id;
   l_original_rsv_rec.orig_demand_source_line_id := l_demand_line_id;
   -- For WIP as supply reservations, just create a regular non-crossdocked reservation.
   -- Do not stamp the WDD ID for the demand line detail.
   IF (l_supply_type_id = 5) THEN
      l_original_rsv_rec.demand_source_line_detail := NULL;
      l_original_rsv_rec.orig_demand_source_line_detail := NULL;
    ELSE
      l_original_rsv_rec.demand_source_line_detail := l_split_wdd_id;
      l_original_rsv_rec.orig_demand_source_line_detail := l_split_wdd_id;
   END IF;
   l_original_rsv_rec.demand_source_delivery := NULL;
   l_original_rsv_rec.primary_uom_code := l_primary_uom_code;
   l_original_rsv_rec.primary_uom_id := NULL;
   l_original_rsv_rec.secondary_uom_code := l_demand_uom_code2;
   l_original_rsv_rec.secondary_uom_id := NULL;
   l_original_rsv_rec.reservation_uom_code := l_supply_uom_code;
   l_original_rsv_rec.reservation_uom_id := NULL;
   l_original_rsv_rec.reservation_quantity := l_atd_qty;
   l_original_rsv_rec.primary_reservation_quantity := l_atd_prim_qty;
   l_original_rsv_rec.secondary_reservation_quantity := l_atd_wdd_qty2;
   l_original_rsv_rec.detailed_quantity := NULL;
   l_original_rsv_rec.secondary_detailed_quantity := NULL;
   l_original_rsv_rec.autodetail_group_id := NULL;
   l_original_rsv_rec.external_source_code := 'XDOCK';
   l_original_rsv_rec.external_source_line_id := NULL;
   l_original_rsv_rec.supply_source_type_id := l_supply_type_id;
   l_original_rsv_rec.orig_supply_source_type_id := l_supply_type_id;
   l_original_rsv_rec.supply_source_name := NULL;
   -- Since reservations with supply type of Receiving are not at the
   -- MO header and line level, these fields should be NULL.
   IF (l_supply_type_id = 27) THEN
      l_original_rsv_rec.supply_source_header_id := NULL;
      l_original_rsv_rec.supply_source_line_id := NULL;
      l_original_rsv_rec.supply_source_line_detail := NULL;
      l_original_rsv_rec.orig_supply_source_header_id := NULL;
      l_original_rsv_rec.orig_supply_source_line_id := NULL;
      l_original_rsv_rec.orig_supply_source_line_detail := NULL;
    ELSIF (l_supply_type_id = 7) THEN
      -- Reservations with supply type of Internal Req should have a NULL
      -- value for the supply source line detail.  Right now this field could
      -- potentially store the shipment line ID for an Internal Req that has quantity
      -- shipped.  Reservations currently are not created at this level of detail.
      l_original_rsv_rec.supply_source_header_id := l_supply_header_id;
      l_original_rsv_rec.supply_source_line_id := l_supply_line_id;
      l_original_rsv_rec.supply_source_line_detail := NULL;
      l_original_rsv_rec.orig_supply_source_header_id := l_supply_header_id;
      l_original_rsv_rec.orig_supply_source_line_id := l_supply_line_id;
      l_original_rsv_rec.orig_supply_source_line_detail := NULL;
    ELSIF (l_supply_type_id = 5) THEN
      -- Reservations with supply type of WIP should just have the WIP entity ID
      -- stored as the supply source header ID.  The other WIP fields such as
      -- operation seq num and repetitive schedule ID are not currently stored
      -- on the reservation.
      l_original_rsv_rec.supply_source_header_id := l_supply_header_id;
      l_original_rsv_rec.supply_source_line_id := NULL;
      l_original_rsv_rec.supply_source_line_detail := NULL;
      l_original_rsv_rec.orig_supply_source_header_id := l_supply_header_id;
      l_original_rsv_rec.orig_supply_source_line_id := NULL;
      l_original_rsv_rec.orig_supply_source_line_detail := NULL;
    ELSE
      l_original_rsv_rec.supply_source_header_id := l_supply_header_id;
      l_original_rsv_rec.supply_source_line_id := l_supply_line_id;
      l_original_rsv_rec.supply_source_line_detail := l_supply_line_detail_id;
      l_original_rsv_rec.orig_supply_source_header_id := l_supply_header_id;
      l_original_rsv_rec.orig_supply_source_line_id := l_supply_line_id;
      l_original_rsv_rec.orig_supply_source_line_detail := l_supply_line_detail_id;
   END IF;
   l_original_rsv_rec.revision := NULL;
   l_original_rsv_rec.subinventory_code := NULL;
   l_original_rsv_rec.subinventory_id := NULL;
   l_original_rsv_rec.locator_id := NULL;
   l_original_rsv_rec.lot_number := NULL;
   l_original_rsv_rec.lot_number_id := NULL;
   l_original_rsv_rec.pick_slip_number := NULL;
   l_original_rsv_rec.lpn_id := NULL;
   l_original_rsv_rec.attribute_category := NULL;
   l_original_rsv_rec.attribute1 := NULL;
   l_original_rsv_rec.attribute2 := NULL;
   l_original_rsv_rec.attribute3 := NULL;
   l_original_rsv_rec.attribute4 := NULL;
   l_original_rsv_rec.attribute5 := NULL;
   l_original_rsv_rec.attribute6 := NULL;
   l_original_rsv_rec.attribute7 := NULL;
   l_original_rsv_rec.attribute8 := NULL;
   l_original_rsv_rec.attribute9 := NULL;
   l_original_rsv_rec.attribute10 := NULL;
   l_original_rsv_rec.attribute11 := NULL;
   l_original_rsv_rec.attribute12 := NULL;
   l_original_rsv_rec.attribute13 := NULL;
   l_original_rsv_rec.attribute14 := NULL;
   l_original_rsv_rec.attribute15 := NULL;
   l_original_rsv_rec.ship_ready_flag := NULL;
   l_original_rsv_rec.staged_flag := NULL;
   -- For WIP as supply reservations, just create a regular non-crossdocked reservation.
   IF (l_supply_type_id = 5) THEN
      l_original_rsv_rec.crossdock_flag := NULL;
      l_original_rsv_rec.crossdock_criteria_id := NULL;
    ELSE
      l_original_rsv_rec.crossdock_flag := 'Y';
      l_original_rsv_rec.crossdock_criteria_id := l_crossdock_criteria_id;
   END IF;
   l_original_rsv_rec.serial_reservation_quantity := NULL;
   l_original_rsv_rec.supply_receipt_date := l_supply_expected_time;
   l_original_rsv_rec.demand_ship_date := l_demand_expected_time;
   l_original_rsv_rec.project_id := l_demand_project_id;
   l_original_rsv_rec.task_id := l_demand_task_id;
   l_original_rsv_rec.serial_number := NULL;
   l_progress := '10';

   IF (l_debug = 1) THEN
      print_debug(p_log_prefix || 'Call the create_reservation API to create the crossdock peg');
   END IF;
   INV_RESERVATION_PVT.create_reservation
     (p_api_version_number            => 1.0,
      p_init_msg_lst                  => fnd_api.g_false,
      x_return_status                 => x_return_status,
      x_msg_count                     => x_msg_count,
      x_msg_data                      => x_msg_data,
      p_rsv_rec			      => l_original_rsv_rec,
      p_serial_number		      => l_original_serial_number,
      x_serial_number		      => l_to_serial_number,
      p_partial_reservation_flag      => fnd_api.g_false,
      p_force_reservation_flag        => fnd_api.g_false,
      p_validation_flag               => fnd_api.g_true,
      x_quantity_reserved             => l_quantity_reserved,
      x_secondary_quantity_reserved   => l_quantity_reserved2,
      x_reservation_id                => l_rsv_id
      );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (l_debug = 1) THEN
	 print_debug(p_log_prefix || 'Error returned from create_reservation API: '
		     || x_return_status);
      END IF;
      -- Raise an exception.  The caller will do the rollback, cleanups,
      -- and decide where to goto next.
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   l_progress := '20';

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug(p_log_prefix || 'Exiting Create_RSV - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END Create_RSV;
-- {{ }}
-- {{******************** End Create_RSV ********************}}
-- {{ }}


-- {{ }}
-- {{******************** Procedure Planned_Cross_Dock ********************}}
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
      p_simulation_mode in varchar2 default 'N')
  IS
     l_api_name                 CONSTANT VARCHAR2(30) := 'Planned_Cross_Dock';
     l_api_version              CONSTANT NUMBER := 1.0;
     l_progress                 VARCHAR2(10);
     l_debug                    NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     -- This variable is used to indicate if the custom APIs were used.
     l_api_is_implemented       BOOLEAN;

     -- These variable will store the org, allocation method, crossdock criteria ID
     -- and the existing reservations only flag for the inputted picking batch.
     l_organization_id          NUMBER;
     l_allocation_method        VARCHAR2(1);
     l_wpb_xdock_criteria_id    NUMBER;
     l_existing_rsvs_only       VARCHAR2(1);

     -- This variable stores the PJM org parameter to allow cross project allocation
     -- when matching supply to demand lines for crossdocking.  Possible values are 'Y' or 'N'.
     l_allow_cross_proj_issues  VARCHAR2(1);

     -- This variable indicates if the org is PJM enabled or not.  1 = Yes, 2 = No
     l_project_ref_enabled      NUMBER;

     -- This boolean variable indicates if the org is a WMS org or not.
     l_wms_org_flag             BOOLEAN;

     -- This variable stores the current item being crossdocking from the release table
     l_inventory_item_id        NUMBER;
     l_primary_uom_code         VARCHAR2(3);

     -- Cursor to retrieve valid approved PO supply lines
     CURSOR po_approved_lines IS
	SELECT
	  poll.po_header_id AS header_id,
	  poll.line_location_id AS line_id,
	  NULL AS line_detail_id,
	  NULL AS quantity,
	  muom.uom_code AS uom_code,
	  NULL AS primary_quantity,
	  NULL AS secondary_quantity,
	  NULL AS secondary_uom_code,
	  MIN(pod.project_id) AS project_id,
	  MIN(pod.task_id) AS task_id,
	  NULL AS lpn_id
	FROM po_headers_all poh, po_lines_all pol, po_line_locations_all poll,
	     po_distributions_all pod, po_line_types plt, mtl_units_of_measure muom
	WHERE poh.type_lookup_code IN ('STANDARD','PLANNED','BLANKET','CONTRACT')
	  AND NVL(poh.cancel_flag, 'N') IN ('N', 'I')
	  AND NVL(poh.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	  AND pol.po_header_id = poh.po_header_id
	  AND poh.po_header_id = poll.po_header_id
	  AND pol.po_line_id = poll.po_line_id
	  AND pod.po_header_id = poh.po_header_id
	  AND pod.po_line_id = pol.po_line_id
	  AND pod.line_location_id = poll.line_location_id
	  AND pol.item_id = l_inventory_item_id
	  AND pol.line_type_id = plt.line_type_id
	  AND NVL(plt.outside_operation_flag, 'N') = 'N'
	  AND poll.unit_meas_lookup_code = muom.unit_of_measure
	  AND NVL(poll.approved_flag, 'N') = 'Y'
	  AND NVL(poll.cancel_flag, 'N') = 'N'
	  AND NVL(poll.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	  AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED')
	  AND poll.ship_to_organization_id = l_organization_id
	  AND poll.quantity > NVL(poll.quantity_received, 0)
	  AND NVL(poll.receiving_routing_id,
		  WMS_Xdock_Pegging_Pub.get_default_routing_id(l_organization_id,
							       l_inventory_item_id,
							       poh.vendor_id)) <> 3
	  AND NOT EXISTS (SELECT 'Invalid Destination'
			  FROM po_distributions_all pod2
			  WHERE pod2.po_header_id = poll.po_header_id
			  AND pod2.po_line_id = poll.po_line_id
			  AND pod2.line_location_id = poll.line_location_id
			  AND NVL(pod2.destination_type_code, pod2.destination_context) IN
			  ('EXPENSE','SHOP FLOOR'))
	  AND NOT EXISTS (SELECT 'Drop Ship'
			  FROM oe_drop_ship_sources odss
			  WHERE odss.po_header_id = poll.po_header_id
			  AND odss.po_line_id = poll.po_line_id
			  AND odss.line_location_id = poll.line_location_id)
	GROUP BY poll.po_header_id, poll.po_line_id, poll.line_location_id, muom.uom_code
	HAVING COUNT(DISTINCT NVL(pod.project_id, -999)) = 1
	   AND COUNT(DISTINCT NVL(pod.task_id, -999)) = 1;


     -- Cursor to retrieve valid ASN supply lines
     CURSOR po_asn_lines IS
	SELECT
	  rsl.po_header_id AS header_id,
	  rsl.po_line_location_id AS line_id,
	  rsl.shipment_line_id AS line_detail_id,
	  NULL AS quantity,
	  muom.uom_code AS uom_code,
	  NULL AS primary_quantity,
	  NULL AS secondary_quantity,
	  NULL AS secondary_uom_code,
	  MIN(pod.project_id) AS project_id,
	  MIN(pod.task_id) AS task_id,
	  NULL AS lpn_id
	FROM rcv_shipment_headers rsh, rcv_shipment_lines rsl, po_lines_all pol, po_line_types plt,
	     po_line_locations_all poll, po_distributions_all pod, mtl_units_of_measure muom
	WHERE rsh.shipment_num IS NOT NULL
	  AND rsh.receipt_source_code = 'VENDOR'
	  AND rsh.asn_type in ('ASN','ASBN')
	  AND rsh.shipment_header_id = rsl.shipment_header_id
	  AND rsl.to_organization_id = l_organization_id
	  AND rsl.shipment_line_status_code in ('EXPECTED','PARTIALLY RECEIVED')
	  AND rsl.item_id = l_inventory_item_id
	  AND rsl.quantity_shipped > NVL(rsl.quantity_received, 0)
	  AND rsl.po_line_id = pol.po_line_id
	  AND pol.line_type_id = plt.line_type_id
	  AND NVL(plt.outside_operation_flag, 'N') = 'N'
	  AND pol.po_line_id = poll.po_line_id
	  AND rsl.po_line_location_id = poll.line_location_id
	  AND pod.po_line_id = pol.po_line_id
	  AND pod.line_location_id = poll.line_location_id
	  AND rsl.unit_of_measure = muom.unit_of_measure
	  AND NVL(poll.receiving_routing_id,
		  WMS_Xdock_Pegging_Pub.get_default_routing_id(l_organization_id,
							       l_inventory_item_id,
							       rsh.vendor_id)) <> 3
	  AND NOT EXISTS (SELECT 'Invalid Destination'
			  FROM po_distributions_all pod2
			  WHERE pod2.po_header_id = poll.po_header_id
			  AND pod2.po_line_id = poll.po_line_id
			  AND pod2.line_location_id = poll.line_location_id
			  AND NVL(pod2.destination_type_code, pod2.destination_context) IN
			  ('EXPENSE','SHOP FLOOR'))
	  AND NOT EXISTS (SELECT 'Drop Ship'
			  FROM oe_drop_ship_sources odss
			  WHERE odss.po_header_id = poll.po_header_id
			  AND odss.po_line_id = poll.po_line_id
			AND odss.line_location_id = poll.line_location_id)
	GROUP BY rsl.po_header_id, rsl.po_line_location_id, rsl.shipment_line_id,
	         muom.uom_code
	HAVING COUNT(DISTINCT NVL(pod.project_id, -999)) = 1
	   AND COUNT(DISTINCT NVL(pod.task_id, -999)) = 1;


     -- Cursor to retrieve valid Internal Requisition supply lines
     CURSOR internal_req_lines IS
	-- Shipped In Transit Internal Reqs
	SELECT
	  prl.requisition_header_id AS header_id,
	  prl.requisition_line_id AS line_id,
	  rsl.shipment_line_id AS line_detail_id,
	  NULL AS quantity,
	  muom.uom_code AS uom_code,
	  NULL AS primary_quantity,
	  NULL AS secondary_quantity,
	  NULL AS secondary_uom_code,
	  MIN(prd.project_id) AS project_id,
	  MIN(prd.task_id) AS task_id,
	  NULL AS lpn_id
	FROM po_requisition_headers_all prh, po_requisition_lines_all prl,
	     rcv_shipment_lines rsl, rcv_shipment_headers rsh, po_req_distributions_all prd,
	     mtl_units_of_measure muom
	WHERE prh.requisition_header_id = prl.requisition_header_id
	  AND prd.requisition_line_id = prl.requisition_line_id
	  AND prh.authorization_status = 'APPROVED'
	  AND NVL(prl.cancel_flag,'N') = 'N'
	  AND prl.source_type_code = 'INVENTORY'
	  AND prl.destination_organization_id = l_organization_id
	  AND prl.item_id = l_inventory_item_id
	  AND rsl.requisition_line_id = prl.requisition_line_id
	  AND rsl.routing_header_id > 0
	  AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED')
	  AND rsl.to_organization_id = l_organization_id
	  AND rsl.item_id = l_inventory_item_id
	  AND rsl.quantity_shipped > NVL(rsl.quantity_received, 0)
	  AND rsh.shipment_header_id = rsl.shipment_header_id
	  AND rsl.unit_of_measure = muom.unit_of_measure
	  AND NVL(rsl.routing_header_id,
		  WMS_Xdock_Pegging_Pub.get_default_routing_id(l_organization_id,
							       l_inventory_item_id,
							       rsh.vendor_id)) <> 3
	  AND NVL(NVL(prl.destination_type_code, prl.destination_context), 'INVENTORY') NOT IN
	    ('EXPENSE', 'SHOP FLOOR')
	GROUP BY prl.requisition_header_id, prl.requisition_line_id, rsl.shipment_line_id,
	         muom.uom_code
	HAVING COUNT(DISTINCT NVL(prd.project_id, -999)) = 1
	   AND COUNT(DISTINCT NVL(prd.task_id, -999)) = 1

	UNION
	-- Approved but not shipped Internal Reqs
	SELECT
	  prl.requisition_header_id AS header_id,
	  prl.requisition_line_id AS line_id,
	  NULL AS line_detail_id,
	  NULL AS quantity,
	  muom.uom_code AS uom_code,
	  NULL AS primary_quantity,
	  NULL AS secondary_quantity,
	  NULL AS secondary_uom_code,
	  MIN(prd.project_id) AS project_id,
	  MIN(prd.task_id) AS task_id,
	  NULL AS lpn_id
	FROM po_requisition_headers_all prh, po_requisition_lines_all prl,
	     po_req_distributions_all prd, mtl_interorg_parameters mip, mtl_units_of_measure muom
	WHERE prh.requisition_header_id = prl.requisition_header_id
	  AND prd.requisition_line_id = prl.requisition_line_id
	  AND prh.authorization_status = 'APPROVED'
	  AND NVL(prl.cancel_flag,'N') = 'N'
	  AND prl.source_type_code = 'INVENTORY'
	  AND prl.destination_organization_id = l_organization_id
	  AND prl.item_id = l_inventory_item_id
	  AND NOT EXISTS (SELECT 'Ship Confirmed'
			  FROM rcv_shipment_lines rsl
			  WHERE rsl.requisition_line_id = prl.requisition_line_id
			  AND rsl.routing_header_id > 0
			  AND rsl.shipment_line_status_code <> 'CANCELLED'
			  AND rsl.to_organization_id = l_organization_id
			  AND rsl.item_id = l_inventory_item_id)
	  AND mip.from_organization_id = prl.source_organization_id
	  AND mip.to_organization_id = prl.destination_organization_id
	  AND prl.unit_meas_lookup_code = muom.unit_of_measure
	  AND NVL(mip.routing_header_id,
		  WMS_Xdock_Pegging_Pub.get_default_routing_id(l_organization_id,
							       l_inventory_item_id,
							       prl.vendor_id)) <> 3
	  AND NVL(NVL(prl.destination_type_code, prl.destination_context), 'INVENTORY') NOT IN
	    ('EXPENSE', 'SHOP FLOOR')
	GROUP BY prl.requisition_header_id, prl.requisition_line_id, muom.uom_code
	HAVING COUNT(DISTINCT NVL(prd.project_id, -999)) = 1
	   AND COUNT(DISTINCT NVL(prd.task_id, -999)) = 1;


     -- Cursor to retrieve valid In Transit Shipment supply lines
     CURSOR intship_lines IS
	SELECT
	  rsl.shipment_header_id AS header_id,
	  rsl.shipment_line_id AS line_id,
	  NULL AS line_detail_id,
	  NULL AS quantity,
	  muom.uom_code AS uom_code,
	  NULL AS primary_quantity,
	  NULL AS secondary_quantity,
	  NULL AS secondary_uom_code,
	  NULL AS project_id,
	  NULL AS task_id,
	  NULL AS lpn_id
	FROM rcv_shipment_headers rsh, rcv_shipment_lines rsl, mtl_units_of_measure muom
	WHERE rsh.shipment_num IS NOT NULL
	  AND rsh.shipment_header_id = rsl.shipment_header_id
	  AND rsh.receipt_source_code = 'INVENTORY'
	  AND EXISTS (SELECT 'Available Supply'
		      FROM mtl_supply ms
		      WHERE ms.to_organization_id = l_organization_id
		      AND ms.shipment_header_id = rsh.shipment_header_id)
	  AND rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED')
	  AND rsl.to_organization_id = l_organization_id
	  AND rsl.item_id = l_inventory_item_id
	  AND rsl.quantity_shipped > NVL(rsl.quantity_received, 0)
	  AND rsl.unit_of_measure = muom.unit_of_measure
	  AND NVL(rsl.routing_header_id,
		  WMS_Xdock_Pegging_Pub.get_default_routing_id(l_organization_id,
							       l_inventory_item_id,
							       rsh.vendor_id)) <> 3
	  AND NVL(NVL(rsl.destination_type_code, rsl.destination_context), 'INVENTORY') NOT IN
	    ('EXPENSE','SHOP FLOOR');
	--AND (l_project_ref_enabled = 2 OR l_allow_cross_proj_issues = 'Y');
	-- In Transit Shipments going to a destination org that is PJM enabled will
	-- always have a NULL project/task, i.e. part of common stock.  The assumption is
	-- that if such a supply exists, the user cannot receive it into a specific project/task.


     -- Cursor to retrieve valid In Receiving supply lines.
     CURSOR in_receiving_lines IS
	SELECT
	  mtrl.header_id AS header_id,
	  mtrl.line_id AS line_id,
	  NULL AS line_detail_id,
	  mtrl.quantity AS quantity,
	  mtrl.uom_code AS uom_code,
	  mtrl.primary_quantity AS primary_quantity,
	  mtrl.secondary_quantity AS secondary_quantity,
	  mtrl.secondary_uom_code AS secondary_uom_code,
	  mtrl.project_id AS project_id,
	  mtrl.task_id AS task_id,
	  mtrl.lpn_id AS lpn_id
	FROM mtl_txn_request_lines mtrl, mtl_txn_request_headers mtrh,
	     wms_license_plate_numbers wlpn
	WHERE mtrl.header_id = mtrh.header_id
	  AND mtrh.move_order_type = inv_globals.g_move_order_put_away
	  AND mtrl.organization_id = l_organization_id
	  AND mtrl.inventory_item_id = l_inventory_item_id
	  -- Modified the line below to use an IN instead of <> so the
	  -- index MTL_TXN_REQUEST_LINES_N10 on MTRL is more likely to be used.
	  -- AND mtrl.line_status <> inv_globals.g_to_status_closed
	  AND mtrl.line_status IN (inv_globals.g_to_status_preapproved,
				   inv_globals.g_to_status_approved)
	  AND mtrl.backorder_delivery_detail_id IS NULL
	  AND mtrl.lpn_id IS NOT NULL
	  AND mtrl.quantity > 0
	  AND NVL(mtrl.quantity_delivered, 0) = 0
	  AND NVL(mtrl.quantity_detailed, 0) = 0
	  AND NVL(mtrl.inspection_status, 2) = 2
	  AND NVL(mtrl.wms_process_flag, 1) = 1
	  AND NVL(mtrl.reference, 'non-RMA') <> 'ORDER_LINE_ID'
	  AND mtrl.lpn_id = wlpn.lpn_id
	  AND wlpn.lpn_context = 3
	  -- Added the following line so the index: WMS_LICENSE_PLATE_NUMBERS_N6
	  -- can be used in case the SQL optimizer uses WLPN as the driving table.
	  AND wlpn.organization_id = l_organization_id;


     -- Variables to retrieve the values from the supply lines cursors.
     -- We will bulk collect the records from the cursors into these PLSQL tables and
     -- use them to do a bulk insert into the xdock pegging global temp table.
     TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     TYPE uom_tab IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
     l_header_id_tb             num_tab;
     l_line_id_tb               num_tab;
     l_line_detail_id_tb        num_tab;
     l_uom_code_tb              uom_tab;
     l_project_id_tb            num_tab;
     l_task_id_tb               num_tab;

     -- Additional PLSQL tables used only by In Receiving supply source type.
     -- Since In Receiving supply lines consist of MOLs which can be split during
     -- crossdocking, we need this information in order to properly split the MOL records.
     -- Non-receiving supply types will just select NULL values for them currently.
     l_quantity_tb              num_tab;
     l_primary_quantity_tb      num_tab;
     l_secondary_quantity_tb    num_tab;
     l_secondary_uom_code_tb    uom_tab;
     l_lpn_id_tb                num_tab;

     -- Variables to store the expected time values for the supply line records retrieved.
     -- We will use the date tables to do a bulk insert into the xdock pegging global temp table.
     TYPE date_tab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
     l_dock_start_time_tb       date_tab;
     l_dock_mean_time_tb        date_tab;
     l_dock_end_time_tb         date_tab;
     l_expected_time_tb         date_tab;

     -- Type used to keep track of which supply source types for a given item
     -- have already been queried for so we do not do this again.
     -- This table will be indexed by the supply source code as used by the crossdock criteria
     -- tables.  If an entry exists for that index it will have a value of TRUE.  If the value
     -- does not exist, then the supply source type has not been queried for yet.
     TYPE bool_tab IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;

     -- Table indexed by inventory_item_id to keep track of which
     -- supply source types have already been retrieved and inserted into
     -- the wms_xdock_pegging_gtmp table.
     TYPE src_types_retrieved_tb IS TABLE OF bool_tab INDEX BY BINARY_INTEGER;
     l_src_types_retrieved_tb   src_types_retrieved_tb;

     -- Index used to loop through the release table
     l_wdd_index                NUMBER;

     -- Cursor to lock the WDD demand record
     CURSOR lock_wdd_record(p_delivery_detail_id NUMBER) IS
	SELECT delivery_detail_id
	  FROM wsh_delivery_details
	  WHERE delivery_detail_id = p_delivery_detail_id
	  FOR UPDATE NOWAIT;

     -- Variables used for the current WDD demand record
     l_demand_type_id           NUMBER;
     l_demand_header_id         NUMBER; -- OE order header ID
     l_demand_so_header_id      NUMBER; -- Sales order header ID
     l_demand_line_id           NUMBER;
     l_demand_line_detail_id    NUMBER;
     l_crossdock_criteria_id    NUMBER;
     l_dock_start_time          DATE;
     l_dock_mean_time           DATE;
     l_dock_end_time            DATE;
     l_demand_expected_time     DATE;
     l_demand_dock_exists       BOOLEAN;
     l_demand_qty               NUMBER;
     l_demand_uom_code          VARCHAR2(3);
     l_demand_qty2              NUMBER;
     l_demand_uom_code2         VARCHAR2(3);
     l_demand_project_id        NUMBER;
     l_demand_task_id           NUMBER;

     -- Type used to cache the item parameters needed
     TYPE item_params_rec IS RECORD
       (primary_uom_code       VARCHAR2(3),
	reservable_type        NUMBER,
	lot_control_code       NUMBER,
	lot_divisible_flag     VARCHAR2(1),
	item_type              VARCHAR2(30)
	);
     -- Table indexed by inventory_item_id to store item parameters
     TYPE item_params_tb IS TABLE OF item_params_rec
       INDEX BY BINARY_INTEGER;
     l_item_params_tb           item_params_tb;

     -- Variables used to call the rules engine to retrieve the crossdock criteria
     l_return_type              VARCHAR2(1);
     l_sequence_number          NUMBER;

     -- Type used to cache the UOM class info for a given UOM code
     TYPE uom_class_tb IS TABLE OF VARCHAR2(10) INDEX BY VARCHAR2(3);
     l_uom_class_tb             uom_class_tb;

     -- Cursor to retrieve the existing high level non-crossdocked non-inventory reservations
     -- for the current WDD record.  For these types of reservations, the detailed_quantity
     -- column should be NULL or 0.
     -- We will also lock the reservations records here.  Using the SKIP LOCKED keyword,
     -- we can select only row records which are lockable without erroring out the entire query.
     CURSOR existing_rsvs_cursor IS
	SELECT reservation_id, supply_source_type_id, supply_source_header_id,
	  supply_source_line_id, supply_source_line_detail,
	  reservation_quantity, reservation_uom_code,
	  secondary_reservation_quantity, secondary_uom_code,
	  primary_reservation_quantity, primary_uom_code
	  FROM mtl_reservations
	  WHERE organization_id = l_organization_id
	  AND inventory_item_id = l_inventory_item_id
	  AND demand_source_type_id = l_demand_type_id
	  AND demand_source_line_id = l_demand_line_id
	  AND supply_source_type_id <> inv_reservation_global.g_source_type_inv
	  AND NVL(crossdock_flag, 'N') = 'N'
     	  AND primary_reservation_quantity - NVL(detailed_quantity, 0) > 0
	  FOR UPDATE SKIP LOCKED; --Bug 6813492

     -- Table to store the results from the existing reservations cursor
     TYPE existing_rsvs_tb IS TABLE OF existing_rsvs_cursor%ROWTYPE INDEX BY BINARY_INTEGER;
     l_existing_rsvs_tb         existing_rsvs_tb;

     -- Index used to loop through the existing high level non-inventory reservations
     l_rsv_index                NUMBER;

     -- Variables for existing reservations and the related supply line on it
     l_rsv_id                   NUMBER;
     l_rsv_qty                  NUMBER;
     l_rsv_uom_code             VARCHAR2(3);
     l_rsv_qty2                 NUMBER;
     l_rsv_uom_code2            VARCHAR2(3);
     l_rsv_prim_qty             NUMBER;
     l_rsv_prim_uom_code        VARCHAR2(3);
     l_supply_uom_code          VARCHAR2(3);
     l_supply_type_id           NUMBER;
     l_supply_header_id         NUMBER;
     l_supply_line_id           NUMBER;
     l_supply_line_detail_id    NUMBER;
     l_supply_project_id        NUMBER;
     l_supply_task_id           NUMBER;

     -- Variable used to store the current supply source code (as used by crossdock criteria)
     -- The supply source codes are different for Reservations and Crossdock Criteria.
     l_supply_src_code          NUMBER;

     -- Variable for retrieving the expected receipt time for supply line
     -- from existing reservations.
     l_supply_expected_time     DATE;
     l_supply_dock_exists       BOOLEAN;

     -- Crossdock Criteria time interval values.
     -- The max precision for the DAY is 2 digits (i.e. 99 DAYs is the largest possible value)
     -- and will be enforced in the crossdock criteria definition form.
     l_xdock_window_interval    INTERVAL DAY(2) TO SECOND;
     l_buffer_interval          INTERVAL DAY(2) TO SECOND;
     l_processing_interval      INTERVAL DAY(2) TO SECOND;
     l_past_due_interval        INTERVAL DAY(2) TO SECOND;
     -- Store the past due time value too so we can tell in Get_Supply_Lines if this
     -- value is null or not.
     l_past_due_time            NUMBER;

     -- Crossdock time window start and end times.  Any valid supplies within this
     -- time interval are valid for crossdocking.
     l_xdock_start_time         DATE;
     l_xdock_end_time           DATE;

     -- The following are cursors used to satisfy existing reservations.  The supply line(s)
     -- on the reservation needs to be locked before we can crossdock it.
     -- A UOM code to match can be inputted if we are trying to crossdock an existing
     -- reservation for this supply type.  If the UOM Integrity flag is 'Y',
     -- we only want to pick up supply line(s) that have the same UOM as the reservation.
     -- We just need to lock the appropriate records (do not need to lock MUOM records).
     -- The project and task of the demand line is also passed in to match to the supply.
     -- If the org is PJM enabled and cross project allocation is not allowed, then the project
     -- and task values have to match.  The project and task values for the PO, ASN, and Int Req
     -- cursors are retrieved from a subquery.  This is because the FOR UPDATE OF clause does not
     -- work if there is a GROUP BY in the main clause.

     -- Cursor to lock the PO supply line record.
     CURSOR lock_po_record(p_uom_code VARCHAR2, p_project_id NUMBER, p_task_id NUMBER) IS
	SELECT muom.uom_code, pod.project_id, pod.task_id
	  FROM po_line_locations_all poll, mtl_units_of_measure muom,
	  (SELECT po_header_id, po_line_id, line_location_id,
	   MIN(project_id) AS project_id, MIN(task_id) AS task_id
	   FROM po_distributions_all
	   WHERE po_header_id = l_supply_header_id
	   AND line_location_id = l_supply_line_id
	   GROUP BY po_header_id, po_line_id, line_location_id
	   HAVING COUNT(DISTINCT NVL(project_id, -999)) = 1
	   AND COUNT(DISTINCT NVL(task_id, -999)) = 1
	   AND (l_project_ref_enabled = 2 OR
		l_allow_cross_proj_issues = 'Y' OR
		(NVL(MIN(project_id), -999) = NVL(p_project_id, -999) AND
		 NVL(MIN(task_id), -999) = NVL(p_task_id, -999)))) pod
	  WHERE poll.po_header_id = l_supply_header_id
	  AND poll.line_location_id = l_supply_line_id
	  AND poll.unit_meas_lookup_code = muom.unit_of_measure
	  AND (p_uom_code IS NULL OR muom.uom_code = p_uom_code)
	  AND pod.po_header_id = poll.po_header_id
	  AND pod.po_line_id = poll.po_line_id
	  AND pod.line_location_id = poll.line_location_id
	  FOR UPDATE OF poll.line_location_id NOWAIT;

     -- Cursor to lock the ASN supply line record.
     CURSOR lock_asn_record(p_uom_code VARCHAR2, p_project_id NUMBER, p_task_id NUMBER) IS
	SELECT muom.uom_code, pod.project_id, pod.task_id
	  FROM rcv_shipment_lines rsl, po_line_locations_all poll, mtl_units_of_measure muom,
	  (SELECT po_header_id, po_line_id, line_location_id,
	   MIN(project_id) AS project_id, MIN(task_id) AS task_id
	   FROM po_distributions_all
	   WHERE po_header_id = l_supply_header_id
	   AND line_location_id = l_supply_line_id
	   GROUP BY po_header_id, po_line_id, line_location_id
	   HAVING COUNT(DISTINCT NVL(project_id, -999)) = 1
	   AND COUNT(DISTINCT NVL(task_id, -999)) = 1
	   AND (l_project_ref_enabled = 2 OR
		l_allow_cross_proj_issues = 'Y' OR
		(NVL(MIN(project_id), -999) = NVL(p_project_id, -999) AND
		 NVL(MIN(task_id), -999) = NVL(p_task_id, -999)))) pod
	  WHERE rsl.po_header_id = l_supply_header_id
	  AND rsl.po_line_location_id = l_supply_line_id
	  AND rsl.shipment_line_id = l_supply_line_detail_id
	  AND rsl.po_line_location_id = poll.line_location_id
	  AND rsl.unit_of_measure = muom.unit_of_measure
	  AND (p_uom_code IS NULL OR muom.uom_code = p_uom_code)
	  AND pod.po_header_id = poll.po_header_id
	  AND pod.po_line_id = poll.po_line_id
	  AND pod.line_location_id = poll.line_location_id
	  FOR UPDATE OF rsl.shipment_line_id, poll.line_location_id NOWAIT;

     -- Cursor to lock the Internal Req supply line record.
     -- This can pull up multiple records if the given requisition line has several
     -- shipment lines tied to it.  Each shipment line can be in a different UOM.
     -- For UOM integrity, if we want to match the UOM from the supply to the reservation,
     -- just use the UOM at the requisition line level.
     CURSOR lock_intreq_record(p_uom_code VARCHAR2, p_project_id NUMBER, p_task_id NUMBER) IS
	SELECT muom_prl.uom_code, prd.project_id, prd.task_id
	  FROM po_requisition_lines_all prl, rcv_shipment_lines rsl, mtl_units_of_measure muom_prl,
	  (SELECT requisition_line_id, MIN(project_id) AS project_id, MIN(task_id) AS task_id
	   FROM po_req_distributions_all
	   WHERE requisition_line_id = l_supply_line_id
	   GROUP BY requisition_line_id
	   HAVING COUNT(DISTINCT NVL(project_id, -999)) = 1
	   AND COUNT(DISTINCT NVL(task_id, -999)) = 1
	   AND (l_project_ref_enabled = 2 OR
		l_allow_cross_proj_issues = 'Y' OR
		(NVL(MIN(project_id), -999) = NVL(p_project_id, -999) AND
		 NVL(MIN(task_id), -999) = NVL(p_task_id, -999)))) prd
	  WHERE prl.requisition_header_id = l_supply_header_id
	  AND prl.requisition_line_id = l_supply_line_id
	  AND prl.unit_meas_lookup_code = muom_prl.unit_of_measure
	  AND prl.requisition_line_id = rsl.requisition_line_id (+)
	  AND (p_uom_code IS NULL OR muom_prl.uom_code = p_uom_code)
	  AND prd.requisition_line_id = prl.requisition_line_id
	  FOR UPDATE OF prl.requisition_line_id, rsl.shipment_line_id NOWAIT;

     -- Cursor to lock the In Transit Shipment supply line record.
     CURSOR lock_intship_record(p_uom_code VARCHAR2, p_project_id NUMBER, p_task_id NUMBER) IS
	SELECT muom.uom_code, NULL AS project_id, NULL AS task_id
	  FROM rcv_shipment_lines rsl, mtl_units_of_measure muom
	  WHERE rsl.shipment_header_id = l_supply_header_id
	  AND rsl.shipment_line_id = l_supply_line_id
	  AND rsl.unit_of_measure = muom.unit_of_measure
	  AND (p_uom_code IS NULL OR muom.uom_code = p_uom_code)
	  AND (l_project_ref_enabled = 2 OR
	       l_allow_cross_proj_issues = 'Y' OR
	       (p_project_id IS NULL AND p_task_id IS NULL))
	  FOR UPDATE OF rsl.shipment_line_id NOWAIT;

     -- Cursor to lock and retrieve valid In Receiving supply move order lines.
     -- The MOLs will be ordered by ABS(mtrl.primary_quantity - p_rsv_prim_qty) ASC in order
     -- to minimize the amount of splitting that might need to be done for reservations and WDD
     -- demand lines.  This ordering will find MOLs that are closest to the reservation quantity.
     -- MOLs which have the same primary quantity.
     -- We also want to match the project/task on the demand line to the MOL supply lines if
     -- cross project allocation is not allowed.
     CURSOR lock_receiving_lines(p_uom_code      VARCHAR2,
				 p_rsv_prim_qty  NUMBER,
				 p_project_id    NUMBER,
				 p_task_id       NUMBER) IS
	SELECT
	  mtrl.header_id AS header_id,
	  mtrl.line_id AS line_id,
	  NULL AS line_detail_id,
	  mtrl.quantity AS quantity,
	  mtrl.uom_code AS uom_code,
	  mtrl.primary_quantity AS primary_quantity,
	  mtrl.secondary_quantity AS secondary_quantity,
	  mtrl.secondary_uom_code AS secondary_uom_code,
	  mtrl.project_id AS project_id,
	  mtrl.task_id AS task_id,
	  mtrl.lpn_id AS lpn_id
	FROM mtl_txn_request_lines mtrl, mtl_txn_request_headers mtrh,
	     wms_license_plate_numbers wlpn
	WHERE mtrl.header_id = mtrh.header_id
	  AND mtrh.move_order_type = inv_globals.g_move_order_put_away
	  AND mtrl.organization_id = l_organization_id
	  AND mtrl.inventory_item_id = l_inventory_item_id
	  -- Modified the line below to use an IN instead of <> so the
	  -- index MTL_TXN_REQUEST_LINES_N10 on MTRL is more likely to be used.
	  -- AND mtrl.line_status <> inv_globals.g_to_status_closed
	  AND mtrl.line_status IN (inv_globals.g_to_status_preapproved,
				   inv_globals.g_to_status_approved)
	  AND mtrl.backorder_delivery_detail_id IS NULL
	  AND mtrl.lpn_id IS NOT NULL
	  AND mtrl.quantity > 0
	  AND NVL(mtrl.quantity_delivered, 0) = 0
	  AND NVL(mtrl.quantity_detailed, 0) = 0
	  AND NVL(mtrl.inspection_status, 2) = 2
	  AND NVL(mtrl.wms_process_flag, 1) = 1
	  AND NVL(mtrl.reference, 'non-RMA') <> 'ORDER_LINE_ID'
	  AND (p_uom_code IS NULL OR mtrl.uom_code = p_uom_code)
	  AND (l_project_ref_enabled = 2 OR
	       l_allow_cross_proj_issues = 'Y' OR
	       (NVL(mtrl.project_id, -999) = NVL(p_project_id, -999) AND
		NVL(mtrl.task_id, -999) = NVL(p_task_id, -999)))
	  AND mtrl.lpn_id = wlpn.lpn_id
	  AND wlpn.lpn_context = 3
	  -- Added the following line so the index: WMS_LICENSE_PLATE_NUMBERS_N6
	  -- can be used in case the SQL optimizer uses WLPN as the driving table.
	  AND wlpn.organization_id = l_organization_id
	  ORDER BY ABS(mtrl.primary_quantity - p_rsv_prim_qty) ASC
	  FOR UPDATE OF mtrl.line_id NOWAIT;

     -- Table to store the results from the lock_receiving_lines cursor
     TYPE rcv_lines_tb IS TABLE OF lock_receiving_lines%ROWTYPE INDEX BY BINARY_INTEGER;
     l_rcv_lines_tb             rcv_lines_tb;

     -- Variables to store the converted quantity values and the available to detail
     -- values.  They will all be converted to the UOM on the supply line, l_supply_uom_code.
     -- We also need the ATD qty in the primary UOM of the item.
     -- l_wdd_atr_txn_qty is used when the full quantity on the WDD line may not be available
     -- for crossdocking.  This is not the case for existing reservations but is possible for
     -- normal crossdocking, i.e. other existing reservations tying up quantity on the WDD line.
     l_wdd_txn_qty              NUMBER;
     l_wdd_atr_txn_qty          NUMBER;
     l_rsv_txn_qty              NUMBER;
     l_atd_qty                  NUMBER;
     l_atd_prim_qty             NUMBER;

     -- These values will store the available to detail quantity converted to the UOM of
     -- the WDD and RSV record respectively.  They are used whenever those records need
     -- to be split.  The secondary quantities are needed too when splitting a WDD or RSV record.
     -- For MOL records, the ATD quantity is always in that UOM.  However, we still need to
     -- convert the ATD quantity to the secondary UOM on the MOL record if it exists.
     l_atd_wdd_qty              NUMBER;
     l_atd_wdd_qty2             NUMBER;
     l_atd_rsv_qty              NUMBER;
     l_atd_rsv_qty2             NUMBER;
     l_atd_mol_qty2             NUMBER;

     -- Variables to store supply line info for supply source type of Receiving
     l_mol_qty                  NUMBER;
     l_mol_header_id            NUMBER;
     l_mol_line_id              NUMBER;
     l_mol_prim_qty             NUMBER;
     l_mol_qty2                 NUMBER;
     l_mol_uom_code2            VARCHAR2(3);
     l_mol_lpn_id               NUMBER;

     -- Conversion rate when converting quantity values to different UOMs
     l_conversion_rate          NUMBER;
     -- The standard Inventory precision is to 5 decimal places.  Define this in a local constant
     -- in case this needs to be changed later on.  Variable is used to round off converted values
     -- to this precision level.
     l_conversion_precision     CONSTANT NUMBER := 5;

     -- Index used to loop through the supply lines for satisfying an existing reservation.
     -- For supplies of type non-Receiving, there is only one supply line used.  However, for
     -- Receiving supply type, there are multiple MOL's that are possible to loop through.
     l_supply_index             NUMBER;

     -- Variables used to call the Shipping API to split a WDD line if a partial quantity
     -- is crossdocked on the WDD line.
     l_detail_id_tab            WSH_UTIL_CORE.id_tab_type;
     l_action_prms              WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
     l_action_out_rec           WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;
     l_split_wdd_rel_rec        WSH_PR_CRITERIA.relRecTyp;
     l_split_wdd_id             NUMBER;
     l_index                    NUMBER;
     l_next_index               NUMBER;

     -- Variables used to call the Shipping API to update a WDD line when it is
     -- being crossdocked.
     l_detail_info_tab          WSH_INTERFACE_EXT_GRP.Delivery_Details_Attr_Tbl_Type;
     l_in_rec                   WSH_INTERFACE_EXT_GRP.detailInRecType;
     l_out_rec                  WSH_INTERFACE_EXT_GRP.detailOutRecType;

     -- Variables to split and update reservations records
     l_original_rsv_rec         inv_reservation_global.mtl_reservation_rec_type;
     l_to_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
     l_original_serial_number  	inv_reservation_global.serial_number_tbl_type;
     l_to_serial_number         inv_reservation_global.serial_number_tbl_type;
     l_split_rsv_id             NUMBER;

     -- Variables to call the pregenerate API when MOL records are crossdocked
     -- to existing reservations.
     l_partial_success          VARCHAR2(1);
     l_lpn_line_error_tbl       wms_putaway_suggestions.lpn_line_error_tbl;
     l_lpn_index                NUMBER;

     -- Variables to store the available to reserve quantity for a demand or supply line
     -- both in the primary and demand/supply line UOM.
     l_demand_atr_prim_qty      NUMBER;
     l_demand_atr_qty           NUMBER;
     l_demand_available_qty     NUMBER;
     l_supply_atr_prim_qty      NUMBER;
     l_supply_atr_qty           NUMBER;
     l_supply_available_qty     NUMBER;

     -- Cursor to retrieve eligible supply source types for a given crossdock criteria
     CURSOR supply_src_types_cursor IS
	SELECT source_code
	  FROM wms_xdock_source_assignments
	  WHERE criterion_id = l_crossdock_criteria_id
	  AND source_type = G_SRC_TYPE_SUP
	  ORDER BY priority;

     -- Table to store the eligible supply source types indexed by crossdock criteria ID
     TYPE supply_src_types_tb IS TABLE OF num_tab INDEX BY BINARY_INTEGER;
     l_supply_src_types_tb      supply_src_types_tb;

     -- Table to store the valid supply lines for crossdocking for the current WDD demand.
     -- The type is defined in the specs instead so the custom logic package can reference it.
     l_shopping_basket_tb       shopping_basket_tb;

     -- Cursor to retrieve valid supply lines that fall within the crossdock window
     -- of the current demand.
     CURSOR get_supply_lines(p_xdock_start_time   DATE,
			     p_xdock_end_time     DATE,
			     p_sup_resched_flag   NUMBER,
			     p_sup_sched_method   NUMBER,
			     p_crossdock_goal     NUMBER,
			     p_past_due_interval  INTERVAL DAY TO second,
			     p_past_due_time      NUMBER,
			     p_po_sup             NUMBER, p_po_priority       NUMBER,
			     p_asn_sup            NUMBER, p_asn_priority      NUMBER,
			     p_intreq_sup         NUMBER, p_intreq_priority   NUMBER,
			     p_intship_sup        NUMBER, p_intship_priority  NUMBER,
			     p_rcv_sup            NUMBER, p_rcv_priority      NUMBER,
			     p_demand_prim_qty    NUMBER,
			     p_project_id         NUMBER,
			     p_task_id            NUMBER) IS
	SELECT ROWID,
	  inventory_item_id,
	  xdock_source_code,
	  source_type_id,
	  source_header_id,
	  source_line_id,
	  source_line_detail_id,
	  dock_start_time,
	  dock_mean_time,
	  dock_end_time,
	  expected_time,
	  quantity,
	  reservable_quantity,
	  uom_code,
	  primary_quantity,
	  secondary_quantity,
	  secondary_uom_code,
	  project_id,
	  task_id,
	  lpn_id,
	  wip_supply_type
	  FROM wms_xdock_pegging_gtmp
	  WHERE inventory_item_id = l_inventory_item_id
	  AND xdock_source_code IN (p_po_sup, p_asn_sup, p_intreq_sup, p_intship_sup, p_rcv_sup)
	  AND ((expected_time IS NOT NULL AND (p_past_due_time IS NULL OR
					       expected_time > SYSDATE - p_past_due_interval)) OR
	       (dock_start_time IS NOT NULL AND (p_past_due_time IS NULL OR
						 dock_start_time > SYSDATE - p_past_due_interval)))
	  -- Only pick up supply lines that match the project/task if necessary
	  AND (l_project_ref_enabled = 2 OR
	       l_allow_cross_proj_issues = 'Y' OR
	       (NVL(project_id, -999) = NVL(p_project_id, -999) AND
		NVL(task_id, -999) = NVL(p_task_id, -999)))
	  AND (-- Dock Appointment Exists
	       (dock_start_time IS NOT NULL AND
		((p_sup_sched_method = G_APPT_START_TIME AND
		  dock_start_time BETWEEN p_xdock_start_time AND p_xdock_end_time) OR
		 (p_sup_sched_method = G_APPT_MEAN_TIME AND
		  dock_mean_time BETWEEN p_xdock_start_time AND p_xdock_end_time) OR
		 (p_sup_sched_method = G_APPT_END_TIME AND
		  dock_end_time BETWEEN p_xdock_start_time AND p_xdock_end_time))
		)
	       -- No Dock Appointment but supply can be rescheduled
	       OR (dock_start_time IS NULL AND p_sup_resched_flag = 1 AND
		   expected_time BETWEEN TRUNC(p_xdock_start_time) AND
		   TO_DATE(TO_CHAR(TRUNC(p_xdock_end_time), 'DD-MON-YYYY') ||
			   ' 23:59:59', 'DD-MON-YYYY HH24:MI:SS')
		   )
	       -- No Dock Appointment and supply cannot be rescheduled
	       OR (dock_start_time IS NULL AND p_sup_resched_flag = 2 AND
		   expected_time BETWEEN p_xdock_start_time AND p_xdock_end_time
		   )
	       )
	ORDER BY DECODE (xdock_source_code,
			 G_PLAN_SUP_PO_APPR, p_po_priority,
			 G_PLAN_SUP_ASN, p_asn_priority,
			 G_PLAN_SUP_REQ, p_intreq_priority,
			 G_PLAN_SUP_INTR, p_intship_priority,
			 G_PLAN_SUP_RCV, p_rcv_priority,
			 99),
		 -- For In Receiving supply lines, order by the quantity closest to the
		 -- ATR demand qty we are crossdocking for.  The expected times should all
		 -- be the same since the material has already been received.
		 -- Putting this order by first before the crossdocking goal since only
		 -- In Receiving supply lines will have a non-null value for primary_quantity.
		 -- For other supply types, this order by will do nothing.  Doing this since the
		 -- expected time for In Receiving lines just use SYSDATE.  We do not want the
		 -- order the MOL's are encountered and inserted into wms_xdock_pegging_gtmp to
		 -- affect the order we consume them for crossdocking.
		 ABS(NVL(primary_quantity, 0) - p_demand_prim_qty) ASC,
		 DECODE (p_crossdock_goal,
			 G_MINIMIZE_WAIT, SYSDATE - NVL(expected_time, dock_start_time),
			 G_MAXIMIZE_XDOCK, NVL(expected_time, dock_start_time) - SYSDATE,
			 G_CUSTOM_GOAL, NULL,
			 NULL);

     -- Variables for the get_supply_lines cursor to indicate which supply source
     -- types/codes to retrieve valid supply lines for.  If the supply type is not used,
     -- a value of -1 will be defaulted.  If it is used, the corresponding supply source code
     -- that crossdock criteria uses will be passed.
     l_po_sup                   NUMBER;
     l_asn_sup                  NUMBER;
     l_intreq_sup               NUMBER;
     l_intship_sup              NUMBER;
     l_rcv_sup                  NUMBER;

     -- Variables for the get_supply_lines cursor to indicate the relative priority of the supply
     -- source types to retrieve valid supply lines for.  If we don't need to prioritize documents,
     -- a default value of 99 will be used.  The cursor get_supply_lines will order by the priority
     -- value in ascending order so lower values have higher priority.
     l_po_priority              NUMBER;
     l_asn_priority             NUMBER;
     l_intreq_priority          NUMBER;
     l_intship_priority         NUMBER;
     l_rcv_priority             NUMBER;

     -- Variables to deal with rolling back the changes to the PLSQL data structures:
     -- p_wsh_release_table, p_trolin_delivery_ids and p_del_detail_id in case a rollback
     -- occurs.  The rollback will deal with the database changes to WDD, RSV, and MOL records.
     -- However, we are locally storing the changes to WDD records in the data structures
     -- mentioned above.  We should clean that up and rollback the similar changes made there.
     -- Also need to keep track of the WDD values inserted into WSH_PICK_LIST.G_XDOCK_DETAIL_TAB
     -- and WSH_PICK_LIST.G_XDOCK_MOL_TAB used for updating the crossdocked WDD records.
     l_split_wdd_index          NUMBER;
     l_split_delivery_index     NUMBER;
     l_xdocked_wdd_index        NUMBER;

     -- Type used to store the original WDD values that were modified when crossdocked
     TYPE orig_wdd_values_rec IS RECORD
       (requested_quantity      NUMBER,
	requested_quantity2     NUMBER,
	released_status         VARCHAR2(1),
	move_order_line_id      NUMBER);
     l_orig_wdd_values_rec      orig_wdd_values_rec;

     -- The following are types used to keep track of which set of MOLs have already been
     -- locked as valid supply lines for crossdocking.  The three keys to this are the
     -- inventory item, project ID, and task ID.  This will keep track of what project and task
     -- MOLs have already been locked for crossdocking using a nested PLSQL table structure.
     -- The project and task part are only stored if the org is PJM enabled AND cross project
     -- allocation is not allowed.  In that case, the set of MOLs locked will be for a specific
     -- project and task matched to ones on the current demand line.  Null values of project
     -- and task will use -999 as the ID.  If the org is not PJM enabled OR cross project allocation
     -- is allowed, we just need to insert a dummy project/task part for the given item.
     -- e.g. l_locked_mols_tb(l_inventory_item_id)(-999)(-999) := TRUE;  In that case, we just need
     -- to check that a value exists for the item, i.e. l_locked_mols_tb.EXISTS(l_inventory_item_id).
     -- There is no need to go to the project/task levels.
     TYPE task_id_tb IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
     TYPE project_id_tb IS TABLE OF task_id_tb INDEX BY BINARY_INTEGER;
     TYPE locked_mols_tb IS TABLE OF project_id_tb INDEX BY BINARY_INTEGER;
     l_locked_mols_tb           locked_mols_tb;
     l_dummy_project_id         NUMBER := -999;
     l_dummy_task_id            NUMBER := -999;

     -- The following are variables used to call the create_reservation API
     l_quantity_reserved        NUMBER;
     l_quantity_reserved2       NUMBER;

     -- The following is a table indexed by LPN ID to indicate which LPNs contained MOLs that
     -- were crossdocked.  This set of MOLs need to call the pre-generate API so the crossdock
     -- tasks can be generated.
     TYPE crossdocked_lpns_tb IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
     l_crossdocked_lpns_tb       crossdocked_lpns_tb;

     -- Table storing the delivery detail ID's for backordered lines.  These records
     -- should be removed from the input tables, p_trolin_delivery_ids and p_del_detail_id
     -- for allocation mode of N (Prioritize Inventory).
     -- This is so deliveries are not autocreated for them later on by Shipping.
     l_backordered_wdd_tbl       bool_tab;
     l_backordered_wdd_lines     PLS_INTEGER;

     -- Variable used to call the Shipping API to backorder WDD lines.
     -- This is used for allocation mode of N (Prioritize Inventory).
     l_shipping_attr             WSH_INTERFACE.ChangedAttributeTabType;

     -- Variables used to bulk update the reservable_quantity column in the global temp table,
     -- wms_xdock_pegging_gtmp.  We want to do a bulk update for this in case multiple
     -- supply lines are consumed when crossdocking a WDD record.
     l_supply_atr_index         NUMBER;
     TYPE rowid_tab IS TABLE OF urowid INDEX BY BINARY_INTEGER;
     l_supply_rowid_tb          rowid_tab;
     l_supply_atr_qty_tb        num_tab;

     -- Variables used when calling custom logic to sort the supply lines in the
     -- shopping basket table.
     l_sorted_order_tb          sorted_order_tb;
     l_shopping_basket_temp_tb  shopping_basket_tb;
     l_indices_used_tb          bool_tab;

     -- Error code variable used when calling the private Crossdock_WDD and Crossdock_MOL
     -- procedures.  This will indicate if an exception occurred during UOM conversion or
     -- during a database operation.
     -- Possible values are: UOM - UOM Conversion error
     --                      DB  - Database Update error
     l_error_code               VARCHAR2(3);

     -- Dummy variables used for calling Crossdock_MOL.  These values are used for
     -- WIP demand lines for Opportunistic Crossdock.
     l_wip_entity_id            NUMBER;
     l_repetitive_schedule_id   NUMBER;
     l_operation_seq_num        NUMBER;
     l_wip_supply_type          NUMBER;

     -- Variable for Allocation method of 'Crossdock Only' to indicate if any of the
     -- input demand release lines were unable to be crossdocked.  This is used so
     -- Shipping can display a status of 'Warning' to the user to indicate that some
     -- of the lines were unable to be allocated for whatever reason.
     l_unable_to_crossdock      BOOLEAN := FALSE;

l_wave_header_id number;


BEGIN
   -- Start the profiler for Unit Testing to ensure complete code coverage
   --dbms_profiler.start_profiler('Planned_Cross_Dock: ' || p_batch_id);

   IF (l_debug = 1) THEN
      print_debug('***Calling Planned_Cross_Dock with the following parameters***');
      print_debug('Package Version: => ' || g_pkg_version);
      print_debug('p_api_version: ===> ' || p_api_version);
      print_debug('p_init_msg_list: => ' || p_init_msg_list);
      print_debug('p_commit: ========> ' || p_commit);
      print_debug('p_batch_id: ======> ' || p_batch_id);
   END IF;

   -- Set the savepoint
   SAVEPOINT Planned_Cross_Dock_sp;
   l_progress := '10';

   l_simulation_mode := p_simulation_mode;

   -- Standard Call to check for call compatibility
   IF NOT fnd_api.Compatible_API_Call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      IF (l_debug = 1) THEN
	 print_debug('FND_API version not compatible!');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Initialize message list to clear any existing messages
   IF fnd_api.To_Boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;
   l_progress := '20';

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := '30';

   -- Return if there are no records to crossdock in p_wsh_release_table.
   -- {{
   -- If no records exist in the release table, API should still process without error. }}
   IF (p_wsh_release_table.COUNT = 0) THEN
      IF (l_debug = 1) THEN
	 print_debug('No records in p_wsh_release_table, exiting.');
      END IF;
      RETURN;
   END IF;

   -- Initialize the PLSQL tables used to retrieve the supply line cursor records
   l_header_id_tb.DELETE;
   l_line_id_tb.DELETE;
   l_line_detail_id_tb.DELETE;
   l_dock_start_time_tb.DELETE;
   l_dock_mean_time_tb.DELETE;
   l_dock_end_time_tb.DELETE;
   l_expected_time_tb.DELETE;
   l_quantity_tb.DELETE;
   l_uom_code_tb.DELETE;
   l_primary_quantity_tb.DELETE;
   l_secondary_quantity_tb.DELETE;
   l_secondary_uom_code_tb.DELETE;
   l_project_id_tb.DELETE;
   l_task_id_tb.DELETE;
   l_lpn_id_tb.DELETE;

   -- Initialize the source types retrieved table
   l_src_types_retrieved_tb.DELETE;

   -- Initialize the item parameters table
   l_item_params_tb.DELETE;

   -- Initialize the UOM class table
   l_uom_class_tb.DELETE;

   -- Initialize the global Item UOM conversion table
   g_item_uom_conversion_tb.DELETE;

   -- Initialize the eligible supply source types table
   l_supply_src_types_tb.DELETE;

   -- Initialize the locked MOL's table
   l_locked_mols_tb.DELETE;

   -- Initialize the crossdocked LPN's table
   l_crossdocked_lpns_tb.DELETE;

   -- Initialize the detail info table used for updating
   -- crossdocked WDD records
   l_detail_info_tab.DELETE;

   -- Initialize the crossdock criteria cache table
   g_crossdock_criteria_tb.DELETE;
   l_progress := '40';

   -- Query for and cache the picking batch record for the inputted batch ID
   -- {{
   -- Test for invalid batch ID entered.  API should error out. }}

   if p_simulation_mode = 'N' THEN

   IF (NOT INV_CACHE.set_wpb_rec
       (p_batch_id       => p_batch_id,
	p_request_number => NULL)) THEN
      IF (l_debug = 1) THEN
	 print_debug('Error caching the WSH picking batch record');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
 end if;
   l_progress := '50';


   if p_simulation_mode = 'Y' THEN


 print_debug('Getting the Crossdock Parameters based on Planning Criteria ID  --- > SImulation Mode');



  	select wwh.organization_id,allocation_method,crossdock_criteria_id,wave_header_id
  	into l_organization_id,l_allocation_method,l_wpb_xdock_criteria_id,l_wave_header_id
  	from wms_wp_planning_criteria_vl wwp,wms_wp_wave_headers_vl wwh
  	where wwp.planning_criteria_id = WMS_WAVE_PLANNING_PVT.g_planning_criteria_id
    AND wwh.planning_criteria_id=wwp.planning_criteria_id;


  else --- p_simulation_mode = 'N' --Existing Code
   -- Retrieve the necessary parameters from the picking batch
   -- {{
   -- Test for multiple orgs tied to the picking batch. }}
   -- If multiple orgs are tied to the picking batch, there should still be only one
   -- org for the sub-batch passed to the crossdock API.  Just retrieve the org from
   -- p_wsh_release_table instead.
   --l_organization_id := inv_cache.wpb_rec.organization_id;
   l_organization_id := p_wsh_release_table(p_wsh_release_table.FIRST).organization_id;
   l_allocation_method := NVL(inv_cache.wpb_rec.allocation_method, G_INVENTORY_ONLY);
   l_wpb_xdock_criteria_id := inv_cache.wpb_rec.crossdock_criteria_id;
   l_existing_rsvs_only := NVL(inv_cache.wpb_rec.existing_rsvs_only_flag, 'N');
   l_progress := '60';

   -- Query for and cache the org record.
   IF (NOT INV_CACHE.set_org_rec(l_organization_id)) THEN
      IF (l_debug = 1) THEN
	 print_debug('Error caching the org record');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

 end if; -- For SImulation Mode
   -- Set the PJM enabled flag.
   l_project_ref_enabled := INV_CACHE.org_rec.project_reference_enabled;
   l_progress := '70';

   -- Check if the organization is a WMS organization
   l_wms_org_flag := wms_install.check_install
     (x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_organization_id  => l_organization_id);
   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
	 print_debug('Call to wms_install.check_install failed: ' || x_msg_data);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   l_progress := '80';

   -- Retrieve the org parameter for allowing cross project allocation for crossdocking.
   -- For now, just hardcode this to 'N'.  The reason is even if we create a peg with
   -- differing project/task combinations, execution needs to be able to handle this.
   -- A project/task transfer needs to be done so until that code is present, we should not
   -- create cross project pegs.  The following is the SQL for retrieving this value.
   /*IF (l_project_ref_enabled = 1) THEN
      -- PJM org so see if cross project allocation is allowed
      BEGIN
	 SELECT NVL(allow_cross_proj_issues, 'N')
	   INTO l_allow_cross_proj_issues
	   FROM pjm_org_parameters
	   WHERE organization_id = l_organization_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    l_allow_cross_proj_issues := 'N';
      END;
    ELSE
      -- Non-PJM org so cross project allocation is allowed since there are no projects or tasks
      l_allow_cross_proj_issues := 'Y';
   END IF;*/
   l_allow_cross_proj_issues := 'N';
   l_progress := '90';

   -- Validate that the allocation method is not Inventory Only
   -- {{
   -- Make sure API errors out if the allocation method is Inventory Only. }}
   IF (l_allocation_method = G_INVENTORY_ONLY) THEN
      IF (l_debug = 1) THEN
	 print_debug('Allocation method of Inventory Only is invalid');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   l_progress := '100';

   -- Query for and cache the crossdock criteria record for the picking batch
   -- if a value exists.  This crossdock criterion will be used for all of the
   -- WDD records to be crossdocked.
   -- {{
   -- API should error out if invalid crossdock criteria is passed from the picking batch. }}
   IF (l_wpb_xdock_criteria_id IS NOT NULL) THEN
      IF (NOT set_crossdock_criteria(l_wpb_xdock_criteria_id)) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Error caching the crossdock criteria record: ' ||
			l_wpb_xdock_criteria_id);
	 END IF;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;
   l_progress := '110';
   -- End of validations and initializations


   -- Loop through the release table and try to crossdock records with
   -- a released status of 'R' or 'B'.
   l_wdd_index := p_wsh_release_table.FIRST;
   LOOP
      -- Crossdock the current WDD record only if it has a released status of R or B.
      -- Do not crossdock any of the WDD records if the org is not a WMS org.  We still need
      -- to do some post-crossdocking logic for certain cases if this API is called for a
      -- non WMS org, e.g. backordering the unallocated WDD lines for Prioritize Inventory.
      -- {{
      -- WDD records with a released status other than R or B should not be crossdocked.  }}
      -- {{
      -- Test for crossdock API called for a non WMS org.  Post crossdock logic should still
      -- be done, such as backordering the unallocated WDD lines for Prioritize Inventory.  }}
      IF (p_wsh_release_table(l_wdd_index).released_status NOT IN ('R','B') OR
	  NOT l_wms_org_flag) THEN
	 GOTO next_record;
      END IF;

      -- Section 1: Demand line validations and initializations
      -- For the current demand line, perform the following validations and
      -- initializations on it.
      -- 1.1 - Validate that the demand line is eligible for crossdocking.
      -- 1.2 - Lock the demand line record.
      -- 1.3 - Retrieve and store the crossdock criterion for the demand line.
      -- 1.4 - Determine the expected ship date for the demand line.
      --       Calculate the crossdock window given the expected ship date and crossdock
      --       criteria time parameters.

      -- Retrieve necessary parameters for the current demand line from p_wsh_release_table
      --l_organization_id := p_wsh_release_table(l_wdd_index).organization_id;
      l_inventory_item_id := p_wsh_release_table(l_wdd_index).inventory_item_id;
      l_demand_header_id := p_wsh_release_table(l_wdd_index).source_header_id;
      l_demand_so_header_id := inv_salesorder.get_salesorder_for_oeheader(l_demand_header_id);
      l_demand_line_id := p_wsh_release_table(l_wdd_index).source_line_id;
      l_demand_line_detail_id := p_wsh_release_table(l_wdd_index).delivery_detail_id;
      l_demand_qty := p_wsh_release_table(l_wdd_index).requested_quantity;
      l_demand_uom_code := p_wsh_release_table(l_wdd_index).requested_quantity_uom;
      l_demand_qty2 := p_wsh_release_table(l_wdd_index).requested_quantity2;
      l_demand_uom_code2 := p_wsh_release_table(l_wdd_index).requested_quantity_uom2;
      l_demand_project_id := p_wsh_release_table(l_wdd_index).project_id;
      l_demand_task_id := p_wsh_release_table(l_wdd_index).task_id;
      IF (NVL(p_wsh_release_table(l_wdd_index).source_doc_type, -999) <> 10) THEN
	 -- Sales Order
	 l_demand_type_id := 2;
       ELSE
	 -- Internal Order
	 l_demand_type_id := 8;
      END IF;
      IF (l_debug = 1) THEN
	 print_debug('1.0 - Current WDD to crossdock: ==> ' || l_demand_line_detail_id);
	 print_debug('1.0 - Current Item to crossdock: => ' || l_inventory_item_id);
      END IF;

      -- 1.1 - Validate that the demand line is eligible for crossdocking.
      IF (l_debug = 1) THEN
	 print_debug('1.1 - Validate that the demand line is eligible for crossdocking');
      END IF;

      -- Make sure current WDD is not associated with a ship set or ship model.
      -- {{
      -- WDD demand lines tied to ship sets or ship models should not be crossdocked. }}
      IF (l_debug = 1) THEN
	 print_debug('1.1 - Ship Set ID: ========> ' ||
		     p_wsh_release_table(l_wdd_index).ship_set_id);
	 print_debug('1.1 - Top Model Line ID: ==> ' ||
		     p_wsh_release_table(l_wdd_index).top_model_line_id);
      END IF;
      IF (p_wsh_release_table(l_wdd_index).ship_set_id IS NOT NULL OR
	  p_wsh_release_table(l_wdd_index).top_model_line_id IS NOT NULL) THEN
	 IF (l_debug = 1) THEN
	    print_debug('1.1 - Do not crossdock ship set or ship model WDD lines');
	 END IF;
	 GOTO next_record;
      END IF;

      -- Query for and cache the item parameters needed.
      -- {{
      -- If item parameter information cannot be retrieved, make sure we just go on to the
      -- next WDD record to crossdock. }}
      IF (NOT l_item_params_tb.EXISTS(l_inventory_item_id)) THEN
	 BEGIN
	    SELECT primary_uom_code, NVL(reservable_type, 1),
	      NVL(lot_control_code, 1), NVL(lot_divisible_flag, 'Y'), item_type
	      INTO l_item_params_tb(l_inventory_item_id)
	      FROM mtl_system_items
	      WHERE inventory_item_id = l_inventory_item_id
	      AND organization_id = l_organization_id;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('1.1 - Error caching the item parameters: ' ||
			      l_inventory_item_id);
	       END IF;
	       GOTO next_record;
	       --RAISE fnd_api.g_exc_unexpected_error;
	 END;
      END IF;
      -- Store the item's primary UOM code in a local variable
      l_primary_uom_code := l_item_params_tb(l_inventory_item_id).primary_uom_code;

      -- Make sure the item is reservable.
      -- {{
      -- Non-reservable items should not be crossdocked. }}
      IF (l_debug = 1) THEN
	 print_debug('1.1 - Reservable Type: ====> ' ||
		     l_item_params_tb(l_inventory_item_id).reservable_type);
      END IF;
      IF (l_item_params_tb(l_inventory_item_id).reservable_type = 2) THEN
	 IF (l_debug = 1) THEN
	    print_debug('1.1 - Do not crossdock non-reservable items');
	 END IF;
	 GOTO next_record;
      END IF;

      -- Make sure the item is lot divisible if it is lot controlled.
      -- {{
      -- Lot Indivisible items should not be crossdocked. }}
      IF (l_debug = 1) THEN
	 print_debug('1.1 - Lot Control Code: ===> ' ||
		     l_item_params_tb(l_inventory_item_id).lot_control_code);
	 print_debug('1.1 - Lot Divisible Flag: => ' ||
		     l_item_params_tb(l_inventory_item_id).lot_divisible_flag);
      END IF;
      IF (l_item_params_tb(l_inventory_item_id).lot_control_code = 2 AND
	  l_item_params_tb(l_inventory_item_id).lot_divisible_flag = 'N') THEN
	 IF (l_debug = 1) THEN
	    print_debug('1.1 - Do not crossdock lot indivisible items');
	 END IF;
	 GOTO next_record;
      END IF;
      l_progress := '120';

      -- If we do not allow partial WIP crossdocking, that is a mix of demand being tied to
      -- both WIP and other non-Inventory supply sources, validate that the current demand
      -- it not already tied to WIP supply.
      IF (WMS_XDOCK_CUSTOM_APIS_PUB.g_allow_partial_wip_xdock = 'N') THEN
	 IF (WMS_XDOCK_PEGGING_PUB.is_demand_tied_to_wip
	     (p_organization_id    => l_organization_id,
	      p_inventory_item_id  => l_inventory_item_id,
	      p_demand_type_id     => l_demand_type_id,
	      p_demand_header_id   => l_demand_so_header_id,
	      p_demand_line_id     => l_demand_line_id) = 'Y') THEN
	    IF (l_debug = 1) THEN
	       print_debug('1.1 - Do not crossdock demand already tied to WIP supply');
	    END IF;
	    GOTO next_record;
	 END IF;
      END IF;
      l_progress := '125';

      -- 1.2 - Lock the demand line record.
      -- {{
      -- If the WDD demand line cannot be locked, move on to the next record. }}
      IF (l_debug = 1) THEN
	 print_debug('1.2 - Lock the demand line record: ' || l_demand_line_detail_id);
      END IF;
      BEGIN
	 OPEN lock_wdd_record(l_demand_line_detail_id);
	 CLOSE lock_wdd_record;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('1.2 - Could not lock the current WDD record: ' ||
			   l_demand_line_detail_id);
	    END IF;
	    -- If unable to lock the current WDD record for some reason, do not error out.
	    -- Just skip it and try to crossdock the next WDD record.
	    GOTO next_record;
      END;
      l_progress := '130';

      -- 1.3 - Retrieve and store the crossdock criterion for the demand line.
      IF (l_debug = 1) THEN
	 print_debug('1.3 - Retrieve and store the crossdock criterion for the demand line');
      END IF;
      IF (l_wpb_xdock_criteria_id IS NOT NULL) THEN
	 -- Use the crossdock criteria inputted for the picking batch.
	 -- This record should already be queried for and cached.
	 l_crossdock_criteria_id := l_wpb_xdock_criteria_id;
       ELSE
	 -- Query for and cache the UOM class for the current UOM code.
	 -- {{
	 -- If the UOM class cannot be retrieved, just move on to the next WDD record. }}
	 IF (NOT l_uom_class_tb.EXISTS(l_demand_uom_code)) THEN
	    BEGIN
	       SELECT uom_class
		 INTO l_uom_class_tb(l_demand_uom_code)
		 FROM mtl_units_of_measure
		 WHERE uom_code = l_demand_uom_code;
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug('1.3 - Error caching the UOM class: ' || l_demand_uom_code);
		  END IF;
		  --GOTO next_record;
		  --RAISE fnd_api.g_exc_unexpected_error;
		  -- Instead of skipping to the next record, just store a NULL value
		  -- for the UOM class.  The crossdock criteria retrieved will thus not
		  -- make use of the UOM class as a filter.
		  l_uom_class_tb(l_demand_uom_code) := NULL;
	    END;
	 END IF;

	 -- Call the custom API to determine a valid crossdock criteria first.
	 -- If this API is not implemented, it will just be a stub and return a value of
	 -- FALSE for x_api_is_implemented.
	 -- {{
	 -- Test for an implemented custom API to get the crossdock criteria.  We should not
	 -- call the rules engine in this case. }}
	 WMS_XDOCK_CUSTOM_APIS_PUB.Get_Crossdock_Criteria
	   (p_wdd_release_record         => p_wsh_release_table(l_wdd_index),
	    x_return_status              => x_return_status,
	    x_msg_count                  => x_msg_count,
	    x_msg_data                   => x_msg_data,
	    x_api_is_implemented         => l_api_is_implemented,
	    x_crossdock_criteria_id      => l_crossdock_criteria_id);

	 IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('1.3 - Success returned from Get_Crossdock_Criteria API');
	    END IF;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('1.3 - Failure returned from Get_Crossdock_Criteria API');
	    END IF;
	    GOTO next_record;
	    --RAISE fnd_api.g_exc_error;
	 END IF;

	 -- If the custom API is not implemented, call the rules engine to determine the
	 -- crossdock criteria for the current WDD record.
	 IF (NOT l_api_is_implemented) THEN
	    -- Call the rules engine to retrieve the crossdock criteria
	    -- for the current WDD record
	    -- {{
	    -- If the rules errors out while determining a crossdock criteria, just go to the
	    -- next WDD record. }}
	    IF (l_debug = 1) THEN
	       print_debug('1.3 - Call the cross_dock_search Rules Workbench API');
	    END IF;
	    wms_rules_workbench_pvt.cross_dock_search
	      (	p_rule_type_code      => G_CRT_RULE_TYPE_PLAN,
		p_organization_id     => l_organization_id,
		p_customer_id	      => p_wsh_release_table(l_wdd_index).customer_id,
		p_inventory_item_id   => l_inventory_item_id,
		p_item_type	      => l_item_params_tb(l_inventory_item_id).item_type,
		p_vendor_id	      => NULL,
		p_location_id	      => p_wsh_release_table(l_wdd_index).ship_from_location_id,
		p_project_id	      => p_wsh_release_table(l_wdd_index).project_id,
		p_task_id	      => p_wsh_release_table(l_wdd_index).task_id,
		p_user_id	      => FND_GLOBAL.user_id,
		p_uom_code	      => l_demand_uom_code,
		p_uom_class	      => l_uom_class_tb(l_demand_uom_code),
		x_return_type	      => l_return_type,
		x_return_type_id      => l_crossdock_criteria_id,
		x_sequence_number     => l_sequence_number,
		x_return_status	      => x_return_status);

	    IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('1.3 - Success returned from cross_dock_search API');
	       END IF;
	     ELSE
	       IF (l_debug = 1) THEN
		  print_debug('1.3 - Failure returned from cross_dock_search API');
	       END IF;
	       GOTO next_record;
	       --RAISE fnd_api.g_exc_error;
	    END IF;
	 END IF;

	 -- Query for and cache the crossdock criteria retrieved from the rules engine
	 IF (l_crossdock_criteria_id IS NOT NULL) THEN
	    IF (NOT set_crossdock_criteria(l_crossdock_criteria_id)) THEN
	       IF (l_debug = 1) THEN
		  print_debug('1.3 - Error caching the crossdock criteria record: ' ||
			      l_crossdock_criteria_id);
	       END IF;
	       GOTO next_record;
	       --RAISE fnd_api.g_exc_unexpected_error;
	    END IF;
	 END IF;

      END IF; -- END IF matching 'IF (l_wpb_xdock_criteria_id IS NOT NULL) THEN'
      IF (l_debug = 1) THEN
	 print_debug('1.3 - Crossdock Criteria ID to use: ' || l_crossdock_criteria_id);
      END IF;
      -- Do not crossdock WDD record if a crossdock criteria is not retrieved.
      -- {{
      -- If a crossdock criteria is not returned by the rules engine, stop processing
      -- and move on to the next WDD record to crossdock. }}
      IF (l_crossdock_criteria_id IS NULL) THEN
	 GOTO next_record;
      END IF;
      l_progress := '140';

      -- 1.4 - Determine the expected ship date for the demand line.
      --       Calculate the crossdock window given the expected ship date and crossdock
      --       criteria time parameters.
      IF (l_debug = 1) THEN
	 print_debug('1.4 - Determine the expected ship date for the demand line');
      END IF;
      Get_Expected_Time
	(p_source_type_id           => l_demand_type_id,
	 p_source_header_id         => l_demand_so_header_id,
	 p_source_line_id           => l_demand_line_id,
	 p_source_line_detail_id    => l_demand_line_detail_id,
	 p_supply_or_demand         => G_SRC_TYPE_DEM,
	 p_crossdock_criterion_id   => l_crossdock_criteria_id,
	 x_return_status            => x_return_status,
	 x_msg_count                => x_msg_count,
	 x_msg_data                 => x_msg_data,
	 x_dock_start_time          => l_dock_start_time,
	 x_dock_mean_time           => l_dock_mean_time,
	 x_dock_end_time            => l_dock_end_time,
	 x_expected_time            => l_demand_expected_time);

      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('1.4 - Success returned from Get_Expected_Time API');
	 END IF;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('1.4 - Failure returned from Get_Expected_Time API');
	 END IF;
	 GOTO next_record;
	 --RAISE fnd_api.g_exc_error;
      END IF;
      -- Use this value to determine if a dock appointment for the demand line exists.
      -- There is a parameter on the crossdock criteria to decide if we should schedule
      -- demand anytime on the shipment date if no dock appointment exists.
      IF (l_dock_start_time IS NOT NULL) THEN
	 l_demand_dock_exists := TRUE;
       ELSE
	 l_demand_dock_exists := FALSE;
      END IF;
      -- Do not crossdock WDD record if an expected time cannot be determined.
      -- {{
      -- If the expected time for the WDD demand cannot be determined, stop processing
      -- and move on to the next record. }}
      IF (l_demand_expected_time IS NULL) THEN
	 IF (l_debug = 1) THEN
	    print_debug('1.4 - Unable to crossdock WDD record since demand expected time is NULL');
	 END IF;
	 GOTO next_record;
      END IF;
      IF (l_debug = 1) THEN
	 print_debug('1.4 - Demand expected time: => ' ||
		     TO_CHAR(l_demand_expected_time, 'DD-MON-YYYY HH24:MI:SS'));
      END IF;
      l_progress := '150';

      -- Get the time interval values for the crossdock criteria.
      -- Time intervals will be defined using the function NUMTODSINTERVAL
      -- Crossdock Window Time Interval
      l_xdock_window_interval := NUMTODSINTERVAL
	(g_crossdock_criteria_tb(l_crossdock_criteria_id).window_interval,
	 g_crossdock_criteria_tb(l_crossdock_criteria_id).window_uom);
      IF (l_debug = 1) THEN
	 print_debug('1.4 - Crossdock Window: ' ||
		     g_crossdock_criteria_tb(l_crossdock_criteria_id).window_interval || ' ' ||
		     g_crossdock_criteria_tb(l_crossdock_criteria_id).window_uom);
      END IF;
      -- Buffer Time Interval
      -- The buffer time interval and UOM should either both be NULL or not NULL.
      l_buffer_interval := NUMTODSINTERVAL
	(NVL(g_crossdock_criteria_tb(l_crossdock_criteria_id).buffer_interval, 0),
	 NVL(g_crossdock_criteria_tb(l_crossdock_criteria_id).buffer_uom, 'HOUR'));
      IF (l_debug = 1) THEN
	 print_debug('1.4 - Buffer Time: ' ||
		     g_crossdock_criteria_tb(l_crossdock_criteria_id).buffer_interval || ' ' ||
		     g_crossdock_criteria_tb(l_crossdock_criteria_id).buffer_uom);
      END IF;
      -- Order Processing Time Interval
      -- The order processing time interval and UOM should either both be NULL or not NULL.
      l_processing_interval := NUMTODSINTERVAL
	(NVL(g_crossdock_criteria_tb(l_crossdock_criteria_id).processing_interval, 0),
	 NVL(g_crossdock_criteria_tb(l_crossdock_criteria_id).processing_uom, 'HOUR'));
      IF (l_debug = 1) THEN
	 print_debug('1.4 - Order Processing Time: ' ||
		     g_crossdock_criteria_tb(l_crossdock_criteria_id).processing_interval || ' ' ||
		     g_crossdock_criteria_tb(l_crossdock_criteria_id).processing_uom);
      END IF;
      -- Past Due Time Interval
      -- The past due time interval and UOM should either both be NULL or not NULL.
      l_past_due_interval := NUMTODSINTERVAL
	(NVL(g_crossdock_criteria_tb(l_crossdock_criteria_id).past_due_interval, 0),
	 NVL(g_crossdock_criteria_tb(l_crossdock_criteria_id).past_due_uom, 'HOUR'));
      IF (l_debug = 1) THEN
	 print_debug('1.4 - Past Due Time: ' ||
		     g_crossdock_criteria_tb(l_crossdock_criteria_id).past_due_interval || ' ' ||
		     g_crossdock_criteria_tb(l_crossdock_criteria_id).past_due_uom);
      END IF;
      -- Set the variable to the past due time value.
      -- If this value is NULL, then that means we do not restrict past due supplies no matter
      -- how far in the past their expected time is.
      l_past_due_time := g_crossdock_criteria_tb(l_crossdock_criteria_id).past_due_interval;

      -- If a dock appointment for the demand does not exist and the crossdock criteria
      -- allows rescheduling of the demand for anytime on the expected ship date, set the
      -- appropriate crossdock time window interval.
      -- {{
      -- Test for a WDD demand where a dock appointment does not exist and demand rescheduling
      -- is allowed. }}
      IF (NOT l_demand_dock_exists AND
	  g_crossdock_criteria_tb(l_crossdock_criteria_id).allow_demand_reschedule_flag = 1 AND
	  l_demand_expected_time >= SYSDATE) THEN
	 -- Demand can be scheduled anytime on the expected ship date so use 12:00AM to calculate
	 -- the crossdock window start time and 11:59PM to calculate the crossdock window
	 -- end time.  Note this will yield a time interval of 24 hours plus the crossdock window
	 -- time interval.
	 l_xdock_start_time := TRUNC(l_demand_expected_time) -
	   (l_processing_interval + l_buffer_interval + l_xdock_window_interval);
	 l_xdock_end_time := TO_DATE(TO_CHAR(TRUNC(l_demand_expected_time), 'DD-MON-YYYY') ||
				     ' 23:59:59', 'DD-MON-YYYY HH24:MI:SS') -
	   (l_processing_interval + l_buffer_interval);
       ELSIF (l_demand_expected_time < SYSDATE) THEN
	 -- For demand that is expected to ship out in the past, consider it as ready to ship
	 -- out anytime on the current date.  Ideally someone should go back to modify the
	 -- scheduled ship date for these demand lines.
	 l_xdock_start_time := TRUNC(SYSDATE) -
	   (l_processing_interval + l_buffer_interval + l_xdock_window_interval);
	 l_xdock_end_time := TO_DATE(TO_CHAR(TRUNC(SYSDATE), 'DD-MON-YYYY') ||
				     ' 23:59:59', 'DD-MON-YYYY HH24:MI:SS') -
	   (l_processing_interval + l_buffer_interval);
       ELSE
	 -- Demand cannot be rescheduled so just use the expected ship date to calculate
	 -- the crossdock window start and end times for valid supplies to crossdock
	 l_xdock_start_time := l_demand_expected_time -
	   (l_processing_interval + l_buffer_interval + l_xdock_window_interval);
	 l_xdock_end_time := l_demand_expected_time -
	   (l_processing_interval + l_buffer_interval);
      END IF;
      IF (l_debug = 1) THEN
	 print_debug('1.4 - Crossdock start time: => ' ||
		     TO_CHAR(l_xdock_start_time, 'DD-MON-YYYY HH24:MI:SS'));
	 print_debug('1.4 - Crossdock end time: ===> ' ||
		     TO_CHAR(l_xdock_end_time, 'DD-MON-YYYY HH24:MI:SS'));
      END IF;
      l_progress := '160';

      -- Section 2: Crossdocking existing high level reservations
      -- For the current demand line, query to see if any existing high level reservations
      -- exist.  If they do, we should try to detail those first.
      -- 2.1 - Query for and lock existing high level reservations for the demand line.
      --     - If a reservation cannot be locked, do not pick up the record for crossdocking.
      -- 2.2 - Check if the supply line on reservation is valid for crossdocking.
      --     - Supply source type must be allowed on the crossdock criteria.
      --     - Supply expected receipt time must lie within the crossdock time window.
      -- 2.3 - Lock the supply line record(s).  Check that the UOM on the supply and
      --       reservation match if UOM integrity is Yes.  If cross project allocation is not
      --       allowed and the org is PJM enabled, make sure the project and task values
      --       on the supply line matches the demand.
      -- 2.4 - Crossdock detail the reservation and update the demand and supply line records.
      -- 2.5 - After processing through all existing reservations, check the prior reservations
      --       only flag on the picking batch.  If 'Y', we are done with the current demand line.
      -- 2.6 - If quantity still remains on the WDD to be crossdocked, see how much reservable
      --       quantity on the demand is actually available for crossdocking.

      -- 2.1 - Query for and lock existing high level reservations for the demand line.
      --     - If a reservation cannot be locked, do not pick up the record for crossdocking.
      -- {{
      -- Test for WDD demand lines with existing high level non-inventory reservations.
      -- The possible supply source types for these reservations are:
      --     Purchase Order
      --     Internal Requisition
      --     ASN
      --     In Transit Shipment
      --     In Receiving }}
      -- {{
      -- Test where an existing reservation is already locked.  This record should not be
      -- picked up for crossdocking. }}
      IF (l_debug = 1) THEN
	 print_debug('2.1 - Query for existing high level reservations for the demand line');
      END IF;
      -- Initialize the table we are fetching records into.
      l_existing_rsvs_tb.DELETE;
      BEGIN
	 OPEN existing_rsvs_cursor;
	 FETCH existing_rsvs_cursor BULK COLLECT INTO l_existing_rsvs_tb;
	 CLOSE existing_rsvs_cursor;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.1 - Exception retrieving the existing reservations');
	    END IF;
	    GOTO after_existing_rsvs;
	    --RAISE fnd_api.g_exc_unexpected_error;
      END;
      l_progress := '170';

      -- Loop through the existing reservations and try to crossdock them
      l_rsv_index := l_existing_rsvs_tb.FIRST;
      LOOP
	 -- If no existing reservations were found, exit out of loop.
	 IF (l_existing_rsvs_tb.COUNT = 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.1 - No existing reservations to crossdock');
	    END IF;
	    EXIT;
	 END IF;

	 -- Retrieve necessary parameters for the supply line from the current reservation
	 l_rsv_id := l_existing_rsvs_tb(l_rsv_index).reservation_id;
	 l_rsv_qty := l_existing_rsvs_tb(l_rsv_index).reservation_quantity;
	 l_rsv_uom_code := l_existing_rsvs_tb(l_rsv_index).reservation_uom_code;
	 l_rsv_qty2 := l_existing_rsvs_tb(l_rsv_index).secondary_reservation_quantity;
	 l_rsv_uom_code2 := l_existing_rsvs_tb(l_rsv_index).secondary_uom_code;
	 l_rsv_prim_qty := l_existing_rsvs_tb(l_rsv_index).primary_reservation_quantity;
	 l_rsv_prim_uom_code := l_existing_rsvs_tb(l_rsv_index).primary_uom_code;
	 l_supply_type_id := l_existing_rsvs_tb(l_rsv_index).supply_source_type_id;
	 l_supply_header_id := l_existing_rsvs_tb(l_rsv_index).supply_source_header_id;
	 l_supply_line_id := l_existing_rsvs_tb(l_rsv_index).supply_source_line_id;
	 l_supply_line_detail_id := l_existing_rsvs_tb(l_rsv_index).supply_source_line_detail;
	 IF (l_debug = 1) THEN
	    print_debug('2.1 - Reservation ID: ========> ' || l_rsv_id);
	    print_debug('2.1 - Reservation Quantity: ==> ' || l_rsv_qty || ' ' ||
			l_rsv_uom_code);
	    print_debug('2.1 - Reservation Quantity2: => ' || l_rsv_qty2 || ' ' ||
			l_rsv_uom_code2);
	    print_debug('2.1 - Reservation Prim Qty: ==> ' || l_rsv_prim_qty || ' ' ||
			l_rsv_prim_uom_code);
	    print_debug('2.1 - Supply source type ID: => ' || l_supply_type_id);
	    print_debug('2.1 - Supply header ID: ======> ' || l_supply_header_id);
	    print_debug('2.1 - Supply line ID: ========> ' || l_supply_line_id);
	    print_debug('2.1 - Supply line detail ID: => ' || l_supply_line_detail_id);
	 END IF;
	 l_progress := '180';

	 -- Make sure the primary UOM code on the reservation matches the one for the item.
	 -- This error condition should not come about but if it does, just skip this
	 -- reservation and go to the next one.
	 IF (l_primary_uom_code <> l_rsv_prim_uom_code) THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.1 - Item and reservation primary UOM codes do not match!');
	    END IF;
	    GOTO next_reservation;
	 END IF;
	 l_progress := '190';

	 -- 2.2 - Check if the supply line on reservation is valid for crossdocking.
	 --     - Supply source type must be allowed on the crossdock criteria.
	 --     - Supply expected receipt time must lie within the crossdock time window.
	 -- Valid supplies:
	 --    1  - Purchase Order
	 --    7  - Internal Requisition
	 --    25 - ASN
	 --    26 - In Transit Shipment
	 --    27 - In Receiving
	 IF (l_debug = 1) THEN
	    print_debug('2.2 - Check if the supply line on reservation is valid for crossdocking');
	 END IF;

	 -- Set the appropriate Crossdock Planned Supply source code.  This uses a different
	 -- set of lookup values compared to the reservations supply source codes.
	 IF (l_supply_type_id = 1) THEN
	    -- PO
	    l_supply_src_code := G_PLAN_SUP_PO_APPR;
	  ELSIF (l_supply_type_id = 7) THEN
	    -- Internal Requisition
	    l_supply_src_code := G_PLAN_SUP_REQ;
	  ELSIF (l_supply_type_id = 25) THEN
	    -- ASN
	    l_supply_src_code := G_PLAN_SUP_ASN;
	  ELSIF (l_supply_type_id = 26) THEN
	    -- In Transit Shipment
	    l_supply_src_code := G_PLAN_SUP_INTR;
	  ELSIF (l_supply_type_id = 27) THEN
	    -- In Receiving
	    l_supply_src_code := G_PLAN_SUP_RCV;
	  ELSE
	    -- Invalid supply for crossdocking.
	    -- {{
	    -- For prior existing reservations that are not supported for crossdocking (WIP),
	    -- make sure we do not try to crossdock them. }}
	    GOTO next_reservation;
	 END IF;
	 IF (l_debug = 1) THEN
	    print_debug('2.2 - Crossdock Supply Source Code: => ' || l_supply_src_code);
	 END IF;
	 l_progress := '200';

	 -- Supply source type must be allowed on the crossdock criteria.
	 -- Check if the supply line tied to the reservation is valid for crossdocking
	 -- based on the valid supply types allowed for the crossdock criteria.
	 -- {{
	 -- Test for existing reservations for valid supply types to crossdock which are
	 -- not allowed on the crossdock criteria.  Processing should stop and the next
	 -- existing reservation should be considered for crossdocking. }}
	 IF (NOT WMS_XDOCK_UTILS_PVT.Is_Eligible_Supply_Source
	     (p_criterion_id  => l_crossdock_criteria_id,
	      p_source_code   => l_supply_src_code)) THEN
	    -- Supply line on reservation is not valid source for crossdocking
	    IF (l_debug = 1) THEN
	       print_debug('2.2 - Supply line on reservation is not valid source for crossdocking');
	    END IF;
	    GOTO next_reservation;
	 END IF;
	 l_progress := '210';

	 -- Supply expected receipt time must lie within the crossdock time window.
	 -- Check if the supply line tied to the reservation is valid for crossdocking
	 -- based on the crossdock window for the crossdock criteria.
	 IF (l_debug = 1) THEN
	    print_debug('2.2 - Determine the expected receipt time for the supply line');
	 END IF;
	 IF (l_supply_type_id <> 27) THEN
	    -- For supply types that are not In Receiving, call the Get_Expected_Time
	    -- API to determine the expected receipt time
	    Get_Expected_Time
	      (p_source_type_id           => l_supply_type_id,
	       p_source_header_id         => l_supply_header_id,
	       p_source_line_id           => l_supply_line_id,
	       p_source_line_detail_id    => l_supply_line_detail_id,
	       p_supply_or_demand         => G_SRC_TYPE_SUP,
	       p_crossdock_criterion_id   => l_crossdock_criteria_id,
	       x_return_status            => x_return_status,
	       x_msg_count                => x_msg_count,
	       x_msg_data                 => x_msg_data,
	       x_dock_start_time          => l_dock_start_time,
	       x_dock_mean_time           => l_dock_mean_time,
	       x_dock_end_time            => l_dock_end_time,
	       x_expected_time            => l_supply_expected_time);

	    IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('2.2 - Success returned from Get_Expected_Time API');
	       END IF;
	     ELSE
	       IF (l_debug = 1) THEN
		  print_debug('2.2 - Failure returned from Get_Expected_Time API');
	       END IF;
	       GOTO next_reservation;
	       --RAISE fnd_api.g_exc_error;
	    END IF;
	    -- Use this value to determine if a dock appointment for the supply line exists.
	    -- There is a parameter on the crossdock criteria to decide if we should schedule
	    -- supply anytime on the expected receipt date if no dock appointment exists.
	    IF (l_dock_start_time IS NOT NULL) THEN
	       l_supply_dock_exists := TRUE;
	     ELSE
	       l_supply_dock_exists := FALSE;
	    END IF;
	  ELSE
	    -- In Receiving supply will just use SYSDATE as the expected receipt time
	    l_supply_expected_time := SYSDATE;
	    -- For In Receiving, dock appointments do not apply since the material is already
	    -- received.  However, set this variable to be TRUE so that the expected receipt time
	    -- for the supply is not rescheduled for anytime on the expected receipt date.
	    l_supply_dock_exists := TRUE;
	 END IF;
	 -- Do not crossdock the supply line on the reservation if an expected receipt
	 -- time cannot be determined.
	 -- {{
	 -- If an expected receipt time for the supply line on an existing reservation
	 -- cannot be determined, skip processing and move on to the next existing reservation. }}
	 IF (l_supply_expected_time IS NULL) THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.2 - Unable to crossdock reservation since supply expected time is NULL');
	    END IF;
	    GOTO next_reservation;
	 END IF;
	 IF (l_debug = 1) THEN
	    print_debug('2.2 - Supply expected time: => ' ||
			TO_CHAR(l_supply_expected_time, 'DD-MON-YYYY HH24:MI:SS'));
	 END IF;
	 l_progress := '220';

	 -- See if the supply lies within the crossdock time window.
	 -- If a dock appointment for the supply does not exist and the crossdock criteria
	 -- allows rescheduling of the supply for anytime on the expected receipt date, set the
	 -- appropriate logic to determine if the supply is valid.
	 -- {{
	 -- Test for a supply line on an existing reservation that does not have a dock appointment
	 -- and supply reschedule is allowed. }}
	 -- {{
	 -- Test for a supply line on an existing reservation lying within the crossdock window. }}
	 -- {{
	 -- Test for a supply line on an existing reservation not lying within the crossdock
	 -- window.  In this case, we cannot crossdock the existing reservation so just move
	 -- on to the next one. }}
	 IF ((NOT l_supply_dock_exists AND
	      g_crossdock_criteria_tb(l_crossdock_criteria_id).allow_supply_reschedule_flag = 1 AND
	      l_supply_expected_time BETWEEN TRUNC(l_xdock_start_time) AND
	      TO_DATE(TO_CHAR(TRUNC(l_xdock_end_time), 'DD-MON-YYYY') ||
		      ' 23:59:59', 'DD-MON-YYYY HH24:MI:SS'))
	     OR (l_supply_expected_time BETWEEN l_xdock_start_time AND l_xdock_end_time)) THEN
	    -- Supply is valid for crossdocking based on crossdock time window
	    IF (l_debug = 1) THEN
	       print_debug('2.2 - Supply line is within the crossdock window');
	    END IF;
	  ELSE
	    -- Supply is not valid for crossdocking so skip to the next existing
	    -- reservation to crossdock
	    IF (l_debug = 1) THEN
	       print_debug('2.2 - Supply line is not within the crossdock window');
	    END IF;
	    GOTO next_reservation;
	 END IF;
	 l_progress := '230';

	 -- 2.3 - Lock the supply line record(s).  Check that the UOM on the supply and
	 --       reservation match if UOM integrity is Yes.  If cross project allocation is not
	 --       allowed and the org is PJM enabled, make sure the project and task values
	 --       on the supply line matches the demand.

	 -- Based on the UOM integrity flag, decide if we should pick up the supply line record(s)
	 -- only if the UOM matches the one on the reservation.
	 IF (g_crossdock_criteria_tb(l_crossdock_criteria_id).uom_integrity_flag = 1) THEN
	    l_supply_uom_code := l_existing_rsvs_tb(l_rsv_index).reservation_uom_code;
	  ELSE
	    l_supply_uom_code := NULL;
	 END IF;
	 IF (l_debug = 1) THEN
	    print_debug('2.3 - UOM code the supply line should match to: ' || l_supply_uom_code);
	 END IF;

	 -- The cursors to lock the supply lines take a UOM code as input to deal with UOM integrity.
	 -- {{
	 -- Test a crossdock criteria where UOM integrity is 'Y'.  The UOM on the reservation
	 -- and supply line must match.  Test both cases where it does and does not match.  If it
	 -- doesn't match, then we should stop processing and move on to the next reservation. }}
	 -- {{
	 -- Test for a PJM org where cross project allocation is not allowed.  For an existing
	 -- reservation, if the demand and supply lines have different project and task values, the
	 -- reservation should not be crossdocked.  Test this for all types of supply lines.}}
	 -- {{
	 -- Test for a PJM org where cross project allocation is not allowed.  For an existing
	 -- reservation, if the supply line has multiple project/task values on the distribution
	 -- level (PO, ASN, Int Req), the reservation should not be crossdocked.}}
	 -- {{
	 -- Test for a PJM org where cross project allocation is not allowed.  For an existing
	 -- reservation with a supply of type Intransit Shipment, the reservation should be skipped
	 -- and not crossdocked.}}
	 IF (l_debug = 1) THEN
	    print_debug('2.3 - Lock and validate the supply line record(s): ' || l_supply_type_id);
	 END IF;
	 IF (l_supply_type_id = 1) THEN
	    -- PO
	    BEGIN
	       OPEN lock_po_record(l_supply_uom_code, l_demand_project_id, l_demand_task_id);
	       FETCH lock_po_record INTO l_supply_uom_code, l_supply_project_id, l_supply_task_id;
	       IF (lock_po_record%NOTFOUND) THEN
		  -- If a record is not found, do not error out.  This could mean that the
		  -- UOM on the supply did not match the reservation and UOM integrity is 'Y'.
		  -- This could also mean that the project and task on the supply line did not
		  -- match the demand and the org is PJM enabled and cross project allocation is
		  -- not allowed.  Skip this reservation and try to crossdock the next one.
		  IF (l_debug = 1) THEN
		     print_debug('2.3 - Supply record not found. UOM/project/task values do not match');
		  END IF;
		  CLOSE lock_po_record;
		  GOTO next_reservation;
	       END IF;
	       CLOSE lock_po_record;
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug('2.3 - Could not lock the PO supply line record');
		  END IF;
		  -- If we cannot lock the supply line, do not error out.  Just go to the
		  -- next existing reservation and try to crossdock that.
		  GOTO next_reservation;
	    END;
	  ELSIF (l_supply_type_id = 7) THEN
	    -- Internal Requisition
	    BEGIN
	       OPEN lock_intreq_record(l_supply_uom_code, l_demand_project_id, l_demand_task_id);
	       -- Multiple records could be returned from this cursor.  We only care about existence.
	       FETCH lock_intreq_record INTO l_supply_uom_code, l_supply_project_id, l_supply_task_id;
	       IF (lock_intreq_record%NOTFOUND) THEN
		  -- If a record is not found, do not error out.  This could mean that the
		  -- UOM on the supply did not match the reservation and UOM integrity is 'Y'.
		  -- This could also mean that the project and task on the supply line did not
		  -- match the demand and the org is PJM enabled and cross project allocation is
		  -- not allowed.  Skip this reservation and try to crossdock the next one.
		  IF (l_debug = 1) THEN
		     print_debug('2.3 - Supply record not found. UOM/project/task values do not match');
		  END IF;
		  CLOSE lock_intreq_record;
		  GOTO next_reservation;
	       END IF;
	       CLOSE lock_intreq_record;
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug('2.3 - Could not lock the Internal Req supply line record');
		  END IF;
		  -- If we cannot lock the supply line, do not error out.  Just go to the
		  -- next existing reservation and try to crossdock that.
		  GOTO next_reservation;
	    END;
	  ELSIF (l_supply_type_id = 25) THEN
	    -- ASN
	    BEGIN
	       OPEN lock_asn_record(l_supply_uom_code, l_demand_project_id, l_demand_task_id);
	       FETCH lock_asn_record INTO l_supply_uom_code, l_supply_project_id, l_supply_task_id;
	       IF (lock_asn_record%NOTFOUND) THEN
		  -- If a record is not found, do not error out.  This could mean that the
		  -- UOM on the supply did not match the reservation and UOM integrity is 'Y'.
		  -- This could also mean that the project and task on the supply line did not
		  -- match the demand and the org is PJM enabled and cross project allocation is
		  -- not allowed.  Skip this reservation and try to crossdock the next one.
		  IF (l_debug = 1) THEN
		     print_debug('2.3 - Supply record not found. UOM/project/task values do not match');
		  END IF;
		  CLOSE lock_asn_record;
		  GOTO next_reservation;
	       END IF;
	       CLOSE lock_asn_record;
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug('2.3 - Could not lock the ASN supply line record');
		  END IF;
		  -- If we cannot lock the supply line, do not error out.  Just go to the
		  -- next existing reservation and try to crossdock that.
		  GOTO next_reservation;
	    END;
	  ELSIF (l_supply_type_id = 26) THEN
	    -- In Transit Shipment
	    BEGIN
	       OPEN lock_intship_record(l_supply_uom_code, l_demand_project_id, l_demand_task_id);
	       FETCH lock_intship_record INTO l_supply_uom_code, l_supply_project_id, l_supply_task_id;
	       IF (lock_intship_record%NOTFOUND) THEN
		  -- If a record is not found, do not error out.  This could mean that the
		  -- UOM on the supply did not match the reservation and UOM integrity is 'Y'.
		  -- This could also mean that the org is PJM enabled, cross project allocation
		  -- is not allowed, and the demand project/task is not null.  In Transit Shipments
		  -- going to a PJM org will only be allowed for common stock (NULL) project/task.
		  -- Skip this reservation and try to crossdock the next one.
		  IF (l_debug = 1) THEN
		     print_debug('2.3 - Supply record not found. UOM/project/task values do not match');
		  END IF;
		  CLOSE lock_intship_record;
		  GOTO next_reservation;
	       END IF;
	       CLOSE lock_intship_record;
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug('2.3 - Could not lock the In Transit Shipment supply line record');
		  END IF;
		  -- If we cannot lock the supply line, do not error out.  Just go to the
		  -- next existing reservation and try to crossdock that.
		  GOTO next_reservation;
	    END;
	  ELSIF (l_supply_type_id = 27) THEN
	    -- In Receiving
	    -- Initialize the table we are fetching records into.
            l_rcv_lines_tb.DELETE;
	    BEGIN
	       OPEN lock_receiving_lines(l_supply_uom_code, l_rsv_prim_qty,
					 l_demand_project_id, l_demand_task_id);
	       FETCH lock_receiving_lines BULK COLLECT INTO l_rcv_lines_tb;
	       -- If no valid receiving lines are found, do not error out.  Skip this
	       -- reservation and try to crossdock the next one.  This means that there were no
	       -- valid MOLs found that matched either the UOM (if UOM integrity is 'Y') or the
	       -- project/task (if cross project allocation is not allowed for a PJM org).
	       IF (l_rcv_lines_tb.COUNT = 0) THEN
		  IF (l_debug = 1) THEN
		     print_debug('2.3 - No valid receiving supply lines found');
		  END IF;
		  CLOSE lock_receiving_lines;
		  GOTO next_reservation;
	       END IF;
	       CLOSE lock_receiving_lines;
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug('2.3 - Could not lock the Receiving supply line records');
		  END IF;
		  -- If we cannot lock the supply lines, do not error out.  Just go to the
		  -- next existing reservation and try to crossdock that.
		  GOTO next_reservation;
	    END;
	  ELSE
	    -- Invalid supply for crossdocking.
	    GOTO next_reservation;
	 END IF; -- End locking supply line(s) from different source types
	 IF (l_debug = 1) THEN
	    print_debug('2.3 - Successfully locked and validated the supply line record(s)');
	    print_debug('2.3 - Supply UOM Code: ===> ' || l_supply_uom_code);
	    print_debug('2.3 - Supply Project ID: => ' || l_supply_project_id);
	    print_debug('2.3 - Supply Task ID: ====> ' || l_supply_task_id);
	 END IF;
	 l_progress := '240';

	 -- 2.4 - Crossdock detail the reservation and update the demand and supply line records.
	 IF (l_debug = 1) THEN
	    print_debug('2.4 - Crossdock detail the relevant records: RSV, WDD, supply');
	 END IF;
	 l_supply_index := NVL(l_rcv_lines_tb.FIRST, 1);

	 -- Loop through the valid supply lines to fulfill the existing reservation.
	 -- For non-receiving supply types, there will only be one such supply line to use.
	 -- For Receiving supply type, there is at least one valid MOL to fulfill the reservation.
	 -- {{
	 -- For supply line(s) of In Receiving type, test that the MOL's are looped through
	 -- properly until they are all exhausted, reservation is fulfilled, or WDD quantity is
	 -- is completely fulfilled. }}
	 LOOP
	    -- Define a savepoint so if an exception occurs while updating database records such as
	    -- WDD, RSV, or MOL, we need to rollback the changes and goto the next WDD record
	    -- to crossdock.  Put this inside the supply lines loop so if one supply line
	    -- is crossdocked successfully but another one errors out, we can still crossdock
	    -- the first one.  Multiple supply lines are only possible for Receiving supply type.
	    SAVEPOINT Existing_Reservation_sp;

	    -- Initialize the variables to store the original WDD values in case
	    -- we need to rollback the changes to local PLSQL data structures
	    l_split_wdd_index := NULL;
	    l_split_delivery_index := NULL;
	    l_orig_wdd_values_rec := NULL;
	    l_xdocked_wdd_index := NULL;

	    -- Set the supply UOM code to the UOM of the current MOL for receiving supply type.
	    -- For non-receiving supply types, there is only one line and the supply UOM code
	    -- has already been retrieved when locking the supply line record.
	    IF (l_supply_type_id = 27) THEN
	       l_mol_header_id := l_rcv_lines_tb(l_supply_index).header_id;
	       l_mol_line_id := l_rcv_lines_tb(l_supply_index).line_id;
	       l_mol_qty := l_rcv_lines_tb(l_supply_index).quantity;
	       l_supply_uom_code := l_rcv_lines_tb(l_supply_index).uom_code;
	       l_mol_prim_qty := l_rcv_lines_tb(l_supply_index).primary_quantity;
	       l_mol_qty2 := l_rcv_lines_tb(l_supply_index).secondary_quantity;
	       l_mol_uom_code2 := l_rcv_lines_tb(l_supply_index).secondary_uom_code;
	       l_supply_project_id := l_rcv_lines_tb(l_supply_index).project_id;
	       l_supply_task_id := l_rcv_lines_tb(l_supply_index).task_id;
	       l_mol_lpn_id := l_rcv_lines_tb(l_supply_index).lpn_id;
	     ELSE
	       l_mol_line_id := NULL;
	    END IF;
	    l_progress := '250';

	    -- Convert the WDD qty to the UOM on the supply line.
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - Current supply UOM code to convert to: ' || l_supply_uom_code);
	    END IF;
	    -- Retrieve the conversion rate for the item/from UOM/to UOM combination.
	    -- {{
	    -- Test that the WDD quantity is converted properly to the UOM on the supply line. }}
	    l_conversion_rate := get_conversion_rate(l_inventory_item_id,
						     l_demand_uom_code, l_supply_uom_code);
	    IF (l_conversion_rate < 0) THEN
	       IF (l_debug = 1) THEN
		  print_debug('2.4 - Error while obtaining UOM conversion rate for WDD qty');
	       END IF;
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Existing_Reservation_sp;
	       -- Process the next existing reservation record.
	       GOTO next_reservation;
	    END IF;
	    -- Round the converted quantity to the standard precision
	    l_wdd_txn_qty := ROUND(l_conversion_rate * l_demand_qty, l_conversion_precision);
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - WDD qty: =====> ' || l_demand_qty || ' ' || l_demand_uom_code);
	       print_debug('2.4 - WDD txn qty: => ' || l_wdd_txn_qty || ' ' || l_supply_uom_code);
	    END IF;
	    l_progress := '260';

	    -- Convert the RSV qty to the UOM on the supply line.
	    -- Retrieve the conversion rate for the item/from UOM/to UOM combination.
	    -- {{
	    -- Test that the RSV quantity is converted properly to the UOM on the supply line. }}
	    l_conversion_rate := get_conversion_rate(l_inventory_item_id,
						     l_rsv_uom_code, l_supply_uom_code);
	    IF (l_conversion_rate < 0) THEN
	       IF (l_debug = 1) THEN
		  print_debug('2.4 - Error while obtaining UOM conversion rate for RSV qty');
	       END IF;
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Existing_Reservation_sp;
	       -- Process the next existing reservation record.
	       GOTO next_reservation;
	    END IF;
	    -- Round the converted quantity to the standard precision
	    l_rsv_txn_qty := ROUND(l_conversion_rate * l_rsv_qty, l_conversion_precision);
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - RSV qty: =====> ' || l_rsv_qty || ' ' || l_rsv_uom_code);
	       print_debug('2.4 - RSV txn qty: => ' || l_rsv_txn_qty || ' ' || l_supply_uom_code);
	    END IF;
	    l_progress := '270';

	    -- For receiving supply types, multiple MOL's comprise the supply line source.
	    IF (l_supply_type_id = 27) THEN
	       IF (l_debug = 1) THEN
		  print_debug('2.4 - MOL qty: =====> ' || l_mol_qty || ' ' || l_supply_uom_code);
	       END IF;
	     ELSE
	       -- For non-receiving supply types, just set this to be equal to the RSV txn qty.
	       -- We assume that there is more than enough quantity on the supply to fulfill
	       -- the reservation otherwise it should not have been created.  This variable is
	       -- set here for calculating the ATD qty.
	       l_mol_qty := l_rsv_txn_qty;
	    END IF;

	    -- Calculate the Available to Detail quantity.
	    -- {{
	    -- Test that the available to detail quantity is calculated properly,
	    -- i.e. is lower than WDD, RSV, and MOL qty, and is an integer value if
	    -- UOM integrity = 'Y'. }}
	    IF (g_crossdock_criteria_tb(l_crossdock_criteria_id).uom_integrity_flag = 1) THEN
	       -- UOM Integrity is 'Yes'
	       l_atd_qty := LEAST(FLOOR(l_wdd_txn_qty), FLOOR(l_rsv_txn_qty), FLOOR(l_mol_qty));
	     ELSE
	       -- UOM Integrity is 'No'
	       l_atd_qty := LEAST(l_wdd_txn_qty, l_rsv_txn_qty, l_mol_qty);
	    END IF;
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - Available to detail qty: ' || l_atd_qty || ' ' ||
			   l_supply_uom_code);
	    END IF;
	    -- If the ATD qty is 0, then goto the next reservation to crossdock.
	    -- This is possible if the UOM integrity flag is 'Y' and the resultant quantities
	    -- were floored to 0.
	    -- {{
	    -- Test for ATD qty = 0.  This can come about if UOM integrity is Yes and the
	    -- demand, reservation or supply line gets floored to 0. }}
	    IF (l_atd_qty = 0) THEN
	       IF (l_debug = 1) THEN
		  print_debug('2.4 - No available qty to detail for this reservation');
	       END IF;
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Existing_Reservation_sp;
	       -- Process the next existing reservation record.
	       GOTO next_reservation;
	    END IF;
	    l_progress := '280';

	    -- Convert l_atd_qty to the primary UOM
	    l_conversion_rate := get_conversion_rate(l_inventory_item_id,
						     l_supply_uom_code, l_primary_uom_code);
	    IF (l_conversion_rate < 0) THEN
	       IF (l_debug = 1) THEN
		  print_debug('2.4 - Error while obtaining primary UOM conversion rate for ATD qty');
	       END IF;
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Existing_Reservation_sp;
	       -- Process the next existing reservation record.
	       GOTO next_reservation;
	    END IF;
	    -- Round the converted quantity to the standard precision
	    l_atd_prim_qty := ROUND(l_conversion_rate * l_atd_qty, l_conversion_precision);
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - ATD qty in primary UOM: => ' || l_atd_prim_qty || ' ' ||
			   l_primary_uom_code);
	    END IF;
	    l_progress := '290';

	    -- Store the original WDD values in case of rollback where we need
	    -- to clean up the local PLSQL data structures
	    l_orig_wdd_values_rec.requested_quantity :=
	      p_wsh_release_table(l_wdd_index).requested_quantity;
	    l_orig_wdd_values_rec.requested_quantity2 :=
	      p_wsh_release_table(l_wdd_index).requested_quantity2;
	    l_orig_wdd_values_rec.released_status :=
	      p_wsh_release_table(l_wdd_index).released_status;
	    l_orig_wdd_values_rec.move_order_line_id :=
	      p_wsh_release_table(l_wdd_index).move_order_line_id;

	    -- Crossdock the WDD record, splitting it if necessary.
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - Call the Crossdock_WDD API to crossdock/split the WDD');
	    END IF;
	    Crossdock_WDD
	      (p_log_prefix              => '2.4 - ',
	       p_crossdock_type          => G_CRT_TYPE_PLAN,
	       p_batch_id                => p_batch_id,
	       p_wsh_release_table       => p_wsh_release_table,
	       p_trolin_delivery_ids     => p_trolin_delivery_ids,
	       p_del_detail_id           => p_del_detail_id,
	       l_wdd_index               => l_wdd_index,
	       l_debug                   => l_debug,
	       l_inventory_item_id       => l_inventory_item_id,
	       l_wdd_txn_qty             => l_wdd_txn_qty,
	       l_atd_qty                 => l_atd_qty,
	       l_atd_wdd_qty             => l_atd_wdd_qty,
	       l_atd_wdd_qty2            => l_atd_wdd_qty2,
	       l_supply_uom_code         => l_supply_uom_code,
	       l_demand_uom_code         => l_demand_uom_code,
	       l_demand_uom_code2        => l_demand_uom_code2,
	       l_conversion_rate         => l_conversion_rate,
	       l_conversion_precision    => l_conversion_precision,
	       l_demand_line_detail_id   => l_demand_line_detail_id,
	       l_index                   => l_index,
	       l_detail_id_tab           => l_detail_id_tab,
	       l_action_prms             => l_action_prms,
	       l_action_out_rec          => l_action_out_rec,
	       l_split_wdd_id            => l_split_wdd_id,
	       l_detail_info_tab         => l_detail_info_tab,
	       l_in_rec                  => l_in_rec,
	       l_out_rec                 => l_out_rec,
	       l_mol_line_id             => l_mol_line_id,
	       l_split_wdd_index         => l_split_wdd_index,
	       l_split_delivery_index    => l_split_delivery_index,
	       l_split_wdd_rel_rec       => l_split_wdd_rel_rec,
	       l_allocation_method       => l_allocation_method,
	       l_demand_qty              => l_demand_qty,
	       l_demand_qty2             => l_demand_qty2,
	       l_demand_atr_qty          => l_demand_atr_qty,
	       l_xdocked_wdd_index	 => l_xdocked_wdd_index,
	       l_supply_type_id          => l_supply_type_id,
	       x_return_status           => x_return_status,
	       x_msg_count               => x_msg_count,
	       x_msg_data                => x_msg_data,
	       x_error_code              => l_error_code
	      );

	    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	       IF (l_debug = 1) THEN
		  print_debug('2.4 - Error returned from Crossdock_WDD API: '
			      || x_return_status);
	       END IF;
	       --RAISE fnd_api.g_exc_error;
	       -- If an exception occurs while modifying a database record, rollback the changes
	       -- and just go to the next WDD record or reservation to crossdock.
	       ROLLBACK TO Existing_Reservation_sp;
	       -- We need to also rollback changes done to local PLSQL data structures
	       IF (l_split_wdd_index IS NOT NULL) THEN
		  p_wsh_release_table.DELETE(l_split_wdd_index);
	       END IF;
	       IF (l_split_delivery_index IS NOT NULL) THEN
		  p_del_detail_id.DELETE(l_split_delivery_index);
		  p_trolin_delivery_ids.DELETE(l_split_delivery_index);
	       END IF;
	       IF (l_xdocked_wdd_index IS NOT NULL) THEN
		  l_detail_info_tab.DELETE(l_xdocked_wdd_index);
	       END IF;
	       p_wsh_release_table(l_wdd_index).requested_quantity :=
		 l_orig_wdd_values_rec.requested_quantity;
	       p_wsh_release_table(l_wdd_index).requested_quantity2 :=
		 l_orig_wdd_values_rec.requested_quantity2;
	       p_wsh_release_table(l_wdd_index).released_status :=
		 l_orig_wdd_values_rec.released_status;
	       p_wsh_release_table(l_wdd_index).move_order_line_id :=
		 l_orig_wdd_values_rec.move_order_line_id;

	       -- Skip to the next WDD record or reservation to crossdock
	       IF (l_error_code = 'UOM') THEN
		  GOTO next_reservation;
		ELSE -- l_error_code = 'DB'
		  GOTO next_record;
	       END IF;
	     ELSE
	       IF (l_debug = 1) THEN
		  print_debug('2.4 - Successfully crossdocked/split the WDD record');
	       END IF;


	       if p_simulation_mode = 'Y' THEN

	x_wp_crossdock_tbl(l_wdd_index).delivery_detail_id := p_wsh_release_table(l_wdd_index).delivery_detail_id;

if l_split_flag = 'Y' then

x_wp_crossdock_tbl(l_wdd_index).crossdock_qty := 	l_atd_wdd_qty;

  print_debug('In Case of Splitting the crossdocked qty is  '||x_wp_crossdock_tbl(l_wdd_index).crossdock_qty);

ELSE

	x_wp_crossdock_tbl(l_wdd_index).crossdock_qty := 	l_wdd_txn_qty;

	  print_debug('Crossdock Quantity without SPlit '||x_wp_crossdock_tbl(l_wdd_index).crossdock_qty);

end if;
  END IF;

	    END IF;
	    l_progress := '300';

	    	    if p_simulation_mode ='Y' THEN -- Ajith

	    	    	null;

	    	    else
	    -- Crossdock the RSV record, splitting it if necessary
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - Call the Crossdock_RSV API to crossdock/split the RSV');
	    END IF;



	    Crossdock_RSV
	      (p_log_prefix              => '2.4 - ',
	       p_crossdock_type          => G_CRT_TYPE_PLAN,
	       l_debug                   => l_debug,
	       l_inventory_item_id       => l_inventory_item_id,
	       l_rsv_txn_qty             => l_rsv_txn_qty,
	       l_atd_qty                 => l_atd_qty,
	       l_atd_rsv_qty             => l_atd_rsv_qty,
	       l_atd_rsv_qty2            => l_atd_rsv_qty2,
	       l_atd_prim_qty            => l_atd_prim_qty,
	       l_supply_uom_code         => l_supply_uom_code,
	       l_rsv_uom_code            => l_rsv_uom_code,
	       l_rsv_uom_code2           => l_rsv_uom_code2,
	       l_primary_uom_code        => l_primary_uom_code,
	       l_conversion_rate         => l_conversion_rate,
	       l_conversion_precision    => l_conversion_precision,
	       l_original_rsv_rec        => l_original_rsv_rec,
	       l_rsv_id                  => l_rsv_id,
	       l_to_rsv_rec              => l_to_rsv_rec,
	       l_split_wdd_id            => l_split_wdd_id,
	       l_crossdock_criteria_id   => l_crossdock_criteria_id,
	       l_demand_expected_time    => l_demand_expected_time,
	       l_supply_expected_time    => l_supply_expected_time,
	       l_original_serial_number  => l_original_serial_number,
	       l_split_rsv_id            => l_split_rsv_id,
	       l_rsv_qty                 => l_rsv_qty,
	       l_rsv_qty2                => l_rsv_qty2,
	       l_to_serial_number	 => l_to_serial_number,
	       l_supply_type_id          => l_supply_type_id,
	       x_return_status           => x_return_status,
	       x_msg_count               => x_msg_count,
	       x_msg_data                => x_msg_data,
	       x_error_code              => l_error_code
	       );

	    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	       IF (l_debug = 1) THEN
		  print_debug('2.4 - Error returned from Crossdock_RSV API: '
			      || x_return_status);
	       END IF;
	       --RAISE fnd_api.g_exc_error;
	       -- If an exception occurs while modifying a database record, rollback the changes
	       -- and just go to the next WDD record or reservation to crossdock.
	       ROLLBACK TO Existing_Reservation_sp;
	       -- We need to also rollback changes done to local PLSQL data structures
	       IF (l_split_wdd_index IS NOT NULL) THEN
		  p_wsh_release_table.DELETE(l_split_wdd_index);
	       END IF;
	       IF (l_split_delivery_index IS NOT NULL) THEN
		  p_del_detail_id.DELETE(l_split_delivery_index);
		  p_trolin_delivery_ids.DELETE(l_split_delivery_index);
	       END IF;
	       IF (l_xdocked_wdd_index IS NOT NULL) THEN
		  l_detail_info_tab.DELETE(l_xdocked_wdd_index);
	       END IF;
	       p_wsh_release_table(l_wdd_index).requested_quantity :=
		 l_orig_wdd_values_rec.requested_quantity;
	       p_wsh_release_table(l_wdd_index).requested_quantity2 :=
		 l_orig_wdd_values_rec.requested_quantity2;
	       p_wsh_release_table(l_wdd_index).released_status :=
		 l_orig_wdd_values_rec.released_status;
	       p_wsh_release_table(l_wdd_index).move_order_line_id :=
		 l_orig_wdd_values_rec.move_order_line_id;

	       -- Skip to the next WDD record or reservation to crossdock
	       IF (l_error_code = 'UOM') THEN
		  GOTO next_reservation;
		ELSE -- l_error_code = 'DB'
		  GOTO next_record;
	       END IF;
	     ELSE
	       IF (l_debug = 1) THEN
		  print_debug('2.4 - Successfully crossdocked/split the RSV record');
	       END IF;
	    END IF;
	    l_progress := '310';


	    -- Crossdock and split the MOL supply line if necessary
	    IF (l_mol_line_id IS NOT NULL) THEN
	       IF (l_debug = 1) THEN
		  print_debug('2.4 - Call the Crossdock_MOL API to crossdock/split the MOL: '
			      || l_mol_line_id);
	       END IF;
	       Crossdock_MOL
		 (p_log_prefix              => '2.4 - ',
		  p_crossdock_type          => G_CRT_TYPE_PLAN,
		  l_debug                   => l_debug,
		  l_inventory_item_id       => l_inventory_item_id,
		  l_mol_qty                 => l_mol_qty,
		  l_mol_qty2                => l_mol_qty2,
		  l_atd_qty                 => l_atd_qty,
		  l_atd_mol_qty2            => l_atd_mol_qty2,
		  l_supply_uom_code         => l_supply_uom_code,
		  l_mol_uom_code2           => l_mol_uom_code2,
		  l_conversion_rate         => l_conversion_rate,
		  l_conversion_precision    => l_conversion_precision,
		  l_mol_prim_qty            => l_mol_prim_qty,
		  l_atd_prim_qty            => l_atd_prim_qty,
		  l_split_wdd_id            => l_split_wdd_id,
		  l_mol_header_id           => l_mol_header_id,
		  l_mol_line_id             => l_mol_line_id,
		  l_supply_atr_qty          => l_supply_atr_qty,
		  l_demand_type_id          => l_demand_type_id,
		  l_wip_entity_id           => l_wip_entity_id,
		  l_operation_seq_num       => l_operation_seq_num,
		  l_repetitive_schedule_id  => l_repetitive_schedule_id,
		  l_wip_supply_type         => l_wip_supply_type,
		  l_xdocked_wdd_index	    => l_xdocked_wdd_index,
		  l_detail_info_tab         => l_detail_info_tab,
		  l_wdd_index               => l_wdd_index,
		  l_split_wdd_index         => l_split_wdd_index,
		  p_wsh_release_table       => p_wsh_release_table,
		  l_supply_type_id          => l_supply_type_id,
		  x_return_status           => x_return_status,
		  x_msg_count               => x_msg_count,
		  x_msg_data                => x_msg_data,
		  x_error_code              => l_error_code
		  );

	       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		  IF (l_debug = 1) THEN
		     print_debug('2.4 - Error returned from Crossdock_MOL API: '
				 || x_return_status);
		  END IF;
		  --RAISE fnd_api.g_exc_error;
		  -- If an exception occurs while modifying a database record, rollback the changes
		  -- and just go to the next WDD record or reservation to crossdock.
		  ROLLBACK TO Existing_Reservation_sp;
		  -- We need to also rollback changes done to local PLSQL data structures
		  IF (l_split_wdd_index IS NOT NULL) THEN
		     p_wsh_release_table.DELETE(l_split_wdd_index);
		  END IF;
		  IF (l_split_delivery_index IS NOT NULL) THEN
		     p_del_detail_id.DELETE(l_split_delivery_index);
		     p_trolin_delivery_ids.DELETE(l_split_delivery_index);
		  END IF;
		  IF (l_xdocked_wdd_index IS NOT NULL) THEN
		     l_detail_info_tab.DELETE(l_xdocked_wdd_index);
		  END IF;
		  p_wsh_release_table(l_wdd_index).requested_quantity :=
		    l_orig_wdd_values_rec.requested_quantity;
		  p_wsh_release_table(l_wdd_index).requested_quantity2 :=
		    l_orig_wdd_values_rec.requested_quantity2;
		  p_wsh_release_table(l_wdd_index).released_status :=
		    l_orig_wdd_values_rec.released_status;
		  p_wsh_release_table(l_wdd_index).move_order_line_id :=
		    l_orig_wdd_values_rec.move_order_line_id;

		  -- Skip to the next WDD record or reservation to crossdock
		  IF (l_error_code = 'UOM') THEN
		     GOTO next_reservation;
		   ELSE -- l_error_code = 'DB'
		     GOTO next_record;
		  END IF;
		ELSE
		  IF (l_debug = 1) THEN
		     print_debug('2.4 - Successfully crossdocked/split the MOL record');
		  END IF;
	       END IF;

	       -- Store this LPN in the crossdocked LPNs table so we can call the pre_generate
	       -- API later on for the entire set of LPN's instead of once for each MOL that
	       -- is crossdocked.
	       IF (NOT l_crossdocked_lpns_tb.EXISTS(l_mol_lpn_id)) THEN
		  l_crossdocked_lpns_tb(l_mol_lpn_id) := TRUE;
		  IF (l_debug = 1) THEN
		     print_debug('2.4 - Successfully stored the crossdocked LPN: ' || l_mol_lpn_id);
		  END IF;
	       END IF;
	       l_progress := '320';

	    END IF; -- End of l_mol_line_id IS NOT NULL for receiving supply type


	    -- Exit out of loop if the WDD line has been fully crossdocked or the
	    -- reservation has been fully consumed
	    IF (p_wsh_release_table(l_wdd_index).released_status = 'S' OR l_rsv_qty = 0) THEN
	       EXIT;
	    END IF;
	    end if; --Ajith ---Check whether it is correct
	    -- Exit out of loop for non-receiving supply types.
	    IF (l_supply_type_id <> 27) THEN
	       EXIT;
	    END IF;

	    -- Exit when all supply lines (receiving MOL's for this case) have been considered
	    EXIT WHEN l_supply_index = l_rcv_lines_tb.LAST;
	    l_supply_index := l_rcv_lines_tb.NEXT(l_supply_index);
	 END LOOP; -- End looping through supply line(s)
	 IF (l_supply_type_id = 27 AND l_rcv_lines_tb.COUNT > 0) THEN
	    -- Clear the receiving lines table if the supply type is Receiving
	    l_rcv_lines_tb.DELETE;
	 END IF;
	 l_progress := '330';

	 -- Exit out of existing reservations loop if the WDD line has been fully crossdocked.
	 -- There is no need to consider anymore existing reservations.
	 IF (p_wsh_release_table(l_wdd_index).released_status = 'S') THEN
	    EXIT;
	 END IF;
	 -- {{
	 -- Test for existing reservation cases where RSV qty >, =, < WDD qty. }}

	 <<next_reservation>>
	 EXIT WHEN l_rsv_index = l_existing_rsvs_tb.LAST;
	 l_rsv_index := l_existing_rsvs_tb.NEXT(l_rsv_index);
      END LOOP; -- End looping through existing reservations
      l_progress := '340';

      -- 2.5 - After processing through all existing reservations, check the prior reservations
      --       only flag on the picking batch.  If 'Y', we are done with the current demand line.
      -- {{
      -- Test for picking batch where we only want to allocate against existing reservations.
      -- If that is the case, stop crossdocking after trying to crossdock existing reservations. }}
      <<after_existing_rsvs>>
      IF (l_debug = 1) THEN
	 print_debug('2.5 - Check the allocate against existing reservations only flag');
	 print_debug('2.5 - Existing RSVs Only Flag: ==> ' || l_existing_rsvs_only);
	 print_debug('2.5 - WDD line released status: => ' ||
		     p_wsh_release_table(l_wdd_index).released_status);
      END IF;
      IF (l_existing_rsvs_only = 'Y' OR
	  p_wsh_release_table(l_wdd_index).released_status = 'S') THEN
	 GOTO next_record;
      END IF;
      l_progress := '350';

      -- 2.6 - If quantity still remains on the WDD to be crossdocked, see how much reservable
      --       quantity on the demand is actually available for crossdocking.
      -- This API will return quantity in the primary UOM.
      IF (l_debug = 1) THEN
	 print_debug('2.6 - Calculate the ATR qty on the demand line for crossdocking');
      END IF;
      INV_RESERVATION_AVAIL_PVT.Available_demand_to_reserve
	(p_api_version_number     	  => 1.0,
	 p_init_msg_lst             	  => fnd_api.g_false,
	 x_return_status            	  => x_return_status,
	 x_msg_count                	  => x_msg_count,
	 x_msg_data                 	  => x_msg_data,
	 p_primary_uom_code               => l_primary_uom_code,
	 p_demand_source_type_id	  => l_demand_type_id,
	 p_demand_source_header_id	  => l_demand_so_header_id,
	 p_demand_source_line_id	  => l_demand_line_id,
	 p_demand_source_line_detail	  => l_demand_line_detail_id,
	 p_project_id			  => l_demand_project_id,
	 p_task_id			  => l_demand_task_id,
	 x_qty_available_to_reserve       => l_demand_atr_prim_qty,
	 x_qty_available                  => l_demand_available_qty);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 IF (l_debug = 1) THEN
	    print_debug('2.6 - Error returned from available_demand_to_reserve API: '
			|| x_return_status);
	 END IF;
	 GOTO next_record;
	 --RAISE fnd_api.g_exc_error;
      END IF;
      IF (l_debug = 1) THEN
	 print_debug('2.6 - Available qty to reserve (primary) for demand: ' ||
		     l_demand_atr_prim_qty || ' ' || l_primary_uom_code);
      END IF;
      l_progress := '360';

      -- Check how much quantity is available to be crossdocked.
      -- {{
      -- Test for case where the WDD line, after considering existing reservations, does not
      -- have any reservable quantity.  This line cannot be crossdocked and we should move
      -- on to the next record. }}
      IF (l_demand_atr_prim_qty <= 0) THEN
	 GOTO next_record;
       ELSE
	 -- Convert the ATR primary quantity to the UOM on the WDD demand line
	 l_conversion_rate := get_conversion_rate(l_inventory_item_id,
						  l_primary_uom_code, l_demand_uom_code);
	 IF (l_conversion_rate < 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.6 - Error while obtaining Primary UOM conversion rate for WDD');
	    END IF;
	    GOTO next_record;
	 END IF;
	 -- Round the converted quantity to the standard precision
	 l_demand_atr_qty := ROUND(l_conversion_rate * l_demand_atr_prim_qty, l_conversion_precision);
	 IF (l_debug = 1) THEN
	    print_debug('2.6 - Available qty to reserve for demand: ' || l_demand_atr_qty ||
			' ' || l_demand_uom_code);
	 END IF;
	 l_progress := '370';

	 -- Instead of splitting the WDD record here with the ATR quantity, just keep track
	 -- of that qty and use it later on when determining the available to detail qty.
	 -- In this way, we can minimize the amount of WDD splitting, doing it only when
	 -- absolutely necessary.
      END IF;

      -- Section 3: Build the set of available supply lines for the demand
      -- 3.1 - Query and cache the available supply source types for crossdocking based on the
      --       current crossdock criteria.
      -- 3.2 - For each supply source type, retrieve the available supply lines.
      -- 3.3 - For each supply line retrieved, determine the expected receipt time.
      -- 3.4 - Insert the available supply lines into the global temp table.
      -- 3.5 - Retrieve all of the supply lines that fall within the crossdock window and
      --       store it in the shopping basket table.  If prioritize documents, order this
      --       by the source type.
      -- 3.6 - Sort the supply lines in the shopping basket table based on the crossdocking
      --       goals.

      -- 3.1 - Query and cache the available supply source types for crossdocking based on the
      --       current crossdock criteria.
      IF (l_debug = 1) THEN
	 print_debug('3.1 - Query and cache the available supply source types for crossdocking');
      END IF;
      IF (NOT l_supply_src_types_tb.EXISTS(l_crossdock_criteria_id)) THEN
         BEGIN
	    OPEN supply_src_types_cursor;
	    FETCH supply_src_types_cursor BULK COLLECT INTO
	      l_supply_src_types_tb(l_crossdock_criteria_id);
	    CLOSE supply_src_types_cursor;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('3.1 - Exception retrieving the eligible supply source types');
	       END IF;
	       GOTO next_record;
	       --RAISE fnd_api.g_exc_unexpected_error;
	 END;
	 IF (l_debug = 1) THEN
	    print_debug('3.1 - Successfully retrieved the eligible supply source types for criteria: '
			|| l_crossdock_criteria_id);
	 END IF;
      END IF;
      l_progress := '380';

      -- 3.2 - For each supply source type, retrieve the available supply lines.
      IF (l_debug = 1) THEN
	 print_debug('3.2 - For each supply source type, retrieve the available supply lines');
      END IF;

      -- Set a savepoint in case an error occurs while inserting supply line records
      -- into the global temp table.
      SAVEPOINT Supply_Lines_sp;

      FOR i IN 1 .. l_supply_src_types_tb(l_crossdock_criteria_id).COUNT LOOP
	 -- Store the current supply source code
	 l_supply_src_code := l_supply_src_types_tb(l_crossdock_criteria_id)(i);

	 -- Retrieve the available supply lines for the current supply source type and item
	 -- combination if it has not been done already.  Here we do not care about project/task
	 -- and will retrieve all of the valid supply lines for the org/item regardless of the
	 -- project/task.  Each demand line could have a different project/task to match to.  That
	 -- logic should be done in the get_supply_lines cursor when building the shopping cart
	 -- table.
	 -- {{
	 -- Test to make sure that if a supply source type for a given item has already been
	 -- retrieved, do not requery the information again. }}
	 IF ((l_src_types_retrieved_tb.EXISTS(l_inventory_item_id) AND
	      NOT l_src_types_retrieved_tb(l_inventory_item_id).EXISTS(l_supply_src_code)) OR
	     NOT l_src_types_retrieved_tb.EXISTS(l_inventory_item_id)) THEN

	    IF (l_debug = 1) THEN
	       IF (l_supply_src_code = G_PLAN_SUP_PO_APPR) THEN
		  print_debug('3.2 - Supply source type to retrieve: Approved PO');
		ELSIF (l_supply_src_code = G_PLAN_SUP_ASN) THEN
		  print_debug('3.2 - Supply source type to retrieve: ASN');
		ELSIF (l_supply_src_code = G_PLAN_SUP_REQ) THEN
		  print_debug('3.2 - Supply source type to retrieve: Internal Requisition');
		ELSIF (l_supply_src_code = G_PLAN_SUP_INTR) THEN
		  print_debug('3.2 - Supply source type to retrieve: In Transit Shipment');
		ELSIF (l_supply_src_code = G_PLAN_SUP_RCV) THEN
		  print_debug('3.2 - Supply source type to retrieve: In Receiving');
		ELSE
		  print_debug('3.2 - Supply source type to retrieve: INVALID SUPPLY!');
	       END IF;
	    END IF;

	    -- Initialize the tables we are BULK fetching into
	    l_header_id_tb.DELETE;
	    l_line_id_tb.DELETE;
	    l_line_detail_id_tb.DELETE;
	    l_dock_start_time_tb.DELETE;
	    l_dock_mean_time_tb.DELETE;
	    l_dock_end_time_tb.DELETE;
	    l_expected_time_tb.DELETE;
	    l_quantity_tb.DELETE;
	    l_uom_code_tb.DELETE;
	    l_primary_quantity_tb.DELETE;
	    l_secondary_quantity_tb.DELETE;
	    l_secondary_uom_code_tb.DELETE;
	    l_project_id_tb.DELETE;
	    l_task_id_tb.DELETE;
	    l_lpn_id_tb.DELETE;

	    -- Bulk collect the supply line cursors into the PLSQL tables based on
	    -- the current crossdock supply source type.
	    IF (l_supply_src_code = G_PLAN_SUP_PO_APPR) THEN
	       -- PO
	       BEGIN
		  OPEN po_approved_lines;
		  FETCH po_approved_lines BULK COLLECT INTO l_header_id_tb, l_line_id_tb,
		    l_line_detail_id_tb, l_quantity_tb, l_uom_code_tb, l_primary_quantity_tb,
		    l_secondary_quantity_tb, l_secondary_uom_code_tb,
		    l_project_id_tb, l_task_id_tb, l_lpn_id_tb;
		  CLOSE po_approved_lines;
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			print_debug('3.2 - Could not retrieve the PO supply lines');
		     END IF;
		     -- If we cannot retrieve the available supply lines, do not error out.
		     -- Just go to the next record and try to crossdock that.
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Supply_Lines_sp;
		     GOTO next_record;
	       END;
	       l_supply_type_id := 1;
	     ELSIF (l_supply_src_code = G_PLAN_SUP_ASN) THEN
	       -- ASN
	       BEGIN
		  OPEN po_asn_lines;
		  FETCH po_asn_lines BULK COLLECT INTO l_header_id_tb, l_line_id_tb,
		    l_line_detail_id_tb, l_quantity_tb, l_uom_code_tb, l_primary_quantity_tb,
		    l_secondary_quantity_tb, l_secondary_uom_code_tb,
		    l_project_id_tb, l_task_id_tb, l_lpn_id_tb;
		  CLOSE po_asn_lines;
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			print_debug('3.2 - Could not retrieve the ASN supply lines');
		     END IF;
		     -- If we cannot retrieve the available supply lines, do not error out.
		     -- Just go to the next record and try to crossdock that.
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Supply_Lines_sp;
		     GOTO next_record;
	       END;
	       l_supply_type_id := 25;
	     ELSIF (l_supply_src_code = G_PLAN_SUP_REQ) THEN
	       -- Internal Requisition
	       BEGIN
		  OPEN internal_req_lines;
		  FETCH internal_req_lines BULK COLLECT INTO l_header_id_tb, l_line_id_tb,
		    l_line_detail_id_tb, l_quantity_tb, l_uom_code_tb, l_primary_quantity_tb,
		    l_secondary_quantity_tb, l_secondary_uom_code_tb,
		    l_project_id_tb, l_task_id_tb, l_lpn_id_tb;
		  CLOSE internal_req_lines;
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			print_debug('3.2 - Could not retrieve the Internal Req supply lines');
		     END IF;
		     -- If we cannot retrieve the available supply lines, do not error out.
		     -- Just go to the next record and try to crossdock that.
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Supply_Lines_sp;
		     GOTO next_record;
	       END;
	       l_supply_type_id := 7;
	     ELSIF (l_supply_src_code = G_PLAN_SUP_INTR) THEN
	       -- In Transit Shipment
	       BEGIN
		  OPEN intship_lines;
		  FETCH intship_lines BULK COLLECT INTO l_header_id_tb, l_line_id_tb,
		    l_line_detail_id_tb, l_quantity_tb, l_uom_code_tb, l_primary_quantity_tb,
		    l_secondary_quantity_tb, l_secondary_uom_code_tb,
		    l_project_id_tb, l_task_id_tb, l_lpn_id_tb;
		  CLOSE intship_lines;
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			print_debug('3.2 - Could not retrieve the In Transit Shipment supply lines');
		     END IF;
		     -- If we cannot retrieve the available supply lines, do not error out.
		     -- Just go to the next record and try to crossdock that.
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Supply_Lines_sp;
		     GOTO next_record;
	       END;
	       l_supply_type_id := 26;
	     ELSIF (l_supply_src_code = G_PLAN_SUP_RCV) THEN
	       -- In Receiving
	       BEGIN
		  OPEN in_receiving_lines;
		  FETCH in_receiving_lines BULK COLLECT INTO l_header_id_tb, l_line_id_tb,
		    l_line_detail_id_tb, l_quantity_tb, l_uom_code_tb, l_primary_quantity_tb,
		    l_secondary_quantity_tb, l_secondary_uom_code_tb,
		    l_project_id_tb, l_task_id_tb, l_lpn_id_tb;
		  CLOSE in_receiving_lines;
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			print_debug('3.2 - Could not retrieve the In Receiving supply lines');
		     END IF;
		     -- If we cannot retrieve the available supply lines, do not error out.
		     -- Just go to the next record and try to crossdock that.
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Supply_Lines_sp;
		     GOTO next_record;
	       END;
	       l_supply_type_id := 27;
	     ELSE
	       -- Invalid supply type for crossdocking
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Supply_Lines_sp;
	       GOTO next_record;
	    END IF; -- End retrieving supply lines for different supply source types
	    IF (l_debug = 1) THEN
	       IF (l_supply_src_code = G_PLAN_SUP_PO_APPR) THEN
		  print_debug('3.2 - Successfully retrieved ' || l_header_id_tb.COUNT ||
			      ' available line(s) for Approved PO');
		ELSIF (l_supply_src_code = G_PLAN_SUP_ASN) THEN
		  print_debug('3.2 - Successfully retrieved ' || l_header_id_tb.COUNT ||
			      ' available line(s) for ASN');
		ELSIF (l_supply_src_code = G_PLAN_SUP_REQ) THEN
		  print_debug('3.2 - Successfully retrieved ' || l_header_id_tb.COUNT ||
			      ' available line(s) for Internal Requisition');
		ELSIF (l_supply_src_code = G_PLAN_SUP_INTR) THEN
		  print_debug('3.2 - Successfully retrieved ' || l_header_id_tb.COUNT ||
			      ' available line(s) for In Transit Shipment');
		ELSIF (l_supply_src_code = G_PLAN_SUP_RCV) THEN
		  print_debug('3.2 - Successfully retrieved ' || l_header_id_tb.COUNT ||
			      ' available line(s) for In Receiving');
	       END IF;
	    END IF;
	  ELSE
	     -- Supply source type has already been retrieved
	     IF (l_debug = 1) THEN
		IF (l_supply_src_code = G_PLAN_SUP_PO_APPR) THEN
		   print_debug('3.2 - Supply source has already been retrieved: Approved PO');
		 ELSIF (l_supply_src_code = G_PLAN_SUP_ASN) THEN
		   print_debug('3.2 - Supply source has already been retrieved: ASN');
		 ELSIF (l_supply_src_code = G_PLAN_SUP_REQ) THEN
		   print_debug('3.2 - Supply source has already been retrieved: Internal Requisition');
		 ELSIF (l_supply_src_code = G_PLAN_SUP_INTR) THEN
		   print_debug('3.2 - Supply source has already been retrieved: In Transit Shipment');
		 ELSIF (l_supply_src_code = G_PLAN_SUP_RCV) THEN
		   print_debug('3.2 - Supply source has already been retrieved: In Receiving');
		END IF;
	     END IF;
	 END IF;
	 l_progress := '390';

	 -- 3.3 - For each supply line retrieved, determine the expected receipt time.
	 -- Do the logic in section 3.3 and 3.4 only if records are retrieved
	 -- for the current supply source type.
	 IF (l_header_id_tb.COUNT > 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug('3.3 - For each supply line retrieved, calculate the expected receipt time');
	    END IF;
	    FOR j IN 1 .. l_header_id_tb.COUNT LOOP
	       -- Call the Get_Expected_Time API if the supply type is not In Receiving
	       IF (l_supply_type_id <> 27) THEN
		  -- Do not pass the crossdock criteria ID since we want to be able to reuse
		  -- the supply lines for other demand lines which might have different
		  -- crossdock criteria values.  If a dock appointment time is found, it will
		  -- be passed in the output dock time variables.
		  Get_Expected_Time
		    (p_source_type_id           => l_supply_type_id,
		     p_source_header_id         => l_header_id_tb(j),
		     p_source_line_id           => l_line_id_tb(j),
		     p_source_line_detail_id    => l_line_detail_id_tb(j),
		     p_supply_or_demand         => G_SRC_TYPE_SUP,
		     p_crossdock_criterion_id   => NULL,
		     x_return_status            => x_return_status,
		     x_msg_count                => x_msg_count,
		     x_msg_data                 => x_msg_data,
		     x_dock_start_time          => l_dock_start_time_tb(j),
		     x_dock_mean_time           => l_dock_mean_time_tb(j),
		     x_dock_end_time            => l_dock_end_time_tb(j),
		     x_expected_time            => l_expected_time_tb(j));

		  IF (x_return_status = fnd_api.g_ret_sts_success) THEN
		     IF (l_debug = 1) THEN
			print_debug('3.3 - Success returned from Get_Expected_Time API');
		     END IF;
		   ELSE
		     IF (l_debug = 1) THEN
			print_debug('3.3 - Failure returned from Get_Expected_Time API');
		     END IF;
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Supply_Lines_sp;
		     GOTO next_record;
		     --RAISE fnd_api.g_exc_error;
		  END IF;
		ELSE
		  -- In Receiving supply types have an expected time of SYSDATE
		  -- since it has already been received.  Just set the dock expected times
		  -- since this is what the Get_Expected_Time API would do if the crossdock
		  -- criterion is not passed.  We want to go against the 'dock' time as the exact
		  -- time and not use the expected time (in case the 'Supply Reschedule Method' is used).
		  l_dock_start_time_tb(j) := SYSDATE;
		  l_dock_mean_time_tb(j) := SYSDATE;
		  l_dock_end_time_tb(j) := SYSDATE;
		  l_expected_time_tb(j) := NULL;
	       END IF;

	    END LOOP; -- End looping through supply lines retrieved
	    IF (l_debug = 1) THEN
	       print_debug('3.3 - Finished calculating expected time for all supply lines');
	    END IF;
	    l_progress := '400';

	    -- 3.4 - Insert the available supply lines into the global temp table.
	    -- {{
	    -- Make sure the valid supply lines are properly inserted into the
	    -- global temp table. }}
	    IF (l_debug = 1) THEN
	       print_debug('3.4 - Insert the available supply lines into the global temp table');
	    END IF;
	    BEGIN
	       FORALL k IN 1 .. l_header_id_tb.COUNT
		 INSERT INTO wms_xdock_pegging_gtmp
		 (inventory_item_id,
		  xdock_source_code,
		  source_type_id,
		  source_header_id,
		  source_line_id,
		  source_line_detail_id,
		  dock_start_time,
		  dock_mean_time,
		  dock_end_time,
		  expected_time,
		  quantity,
		  uom_code,
		  primary_quantity,
		  secondary_quantity,
		  secondary_uom_code,
		  project_id,
		  task_id,
		  lpn_id
		  )
		 VALUES
		 (l_inventory_item_id,
		  l_supply_src_code,
		  l_supply_type_id,
		  l_header_id_tb(k),
		  l_line_id_tb(k),
		  l_line_detail_id_tb(k),
		  l_dock_start_time_tb(k),
		  l_dock_mean_time_tb(k),
		  l_dock_end_time_tb(k),
		  l_expected_time_tb(k),
		  l_quantity_tb(k),
		  l_uom_code_tb(k),
		  l_primary_quantity_tb(k),
		  l_secondary_quantity_tb(k),
		  l_secondary_uom_code_tb(k),
		  l_project_id_tb(k),
		  l_task_id_tb(k),
		  l_lpn_id_tb(k)
		  );
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug('3.4 - Error inserting available supply lines into temp table');
		  END IF;
		  --RAISE fnd_api.g_exc_error;
		  -- If an exception occurs while inserting supply line records, just
		  -- rollback the changes and go to the next WDD record to crossdock.
		  ROLLBACK TO Supply_Lines_sp;
		  GOTO next_record;
	    END;
	    IF (l_debug = 1) THEN
	       print_debug('3.4 - Successfully inserted ' || l_header_id_tb.COUNT ||
			   ' available supply lines into temp table');
	    END IF;
	    l_progress := '410';

	    -- Clear the PLSQL tables used once the data is inserted into the global temp table
	    l_header_id_tb.DELETE;
	    l_line_id_tb.DELETE;
	    l_line_detail_id_tb.DELETE;
	    l_dock_start_time_tb.DELETE;
	    l_dock_mean_time_tb.DELETE;
	    l_dock_end_time_tb.DELETE;
	    l_expected_time_tb.DELETE;
	    l_quantity_tb.DELETE;
	    l_uom_code_tb.DELETE;
	    l_primary_quantity_tb.DELETE;
	    l_secondary_quantity_tb.DELETE;
	    l_secondary_uom_code_tb.DELETE;
	    l_project_id_tb.DELETE;
	    l_task_id_tb.DELETE;
	    l_lpn_id_tb.DELETE;
	 END IF; -- END IF matches: IF (l_header_id_tb.COUNT > 0) THEN

	 -- Set the marker indicating we have retrieved the supply lines for the
	 -- current source type and item.  This value could already exist if the supply source
	 -- type and item was retrieved previously.  However it is okay to set this again.
	 l_src_types_retrieved_tb(l_inventory_item_id)(l_supply_src_code) := TRUE;
	 l_progress := '420';

      END LOOP; -- End looping through eligible supply source types

      -- 3.5 - Retrieve all of the supply lines that fall within the crossdock window and
      --       store it in the shopping basket table.  If prioritize documents, order this
      --       by the source type.
      IF (l_debug = 1) THEN
	 print_debug('3.5 - Retrieve all of the supply lines that are valid for crossdocking');
      END IF;

      -- Iniitialize the shopping basket table which will store the valid supply lines
      -- for crossdocking to the current demand line.
      l_shopping_basket_tb.DELETE;

      -- Initialize the available supply source types to retrieve
      l_po_sup := -1;
      l_asn_sup := -1;
      l_intreq_sup := -1;
      l_intship_sup := -1;
      l_rcv_sup := -1;

      -- Initialize the supply document priority variables
      l_po_priority := 99;
      l_asn_priority := 99;
      l_intreq_priority := 99;
      l_intship_priority := 99;
      l_rcv_priority := 99;

      -- Get the valid supply source types to retrieve.
      -- The supply source types are cached in the order of the document priority already.
      -- Just use the same index value for the document priority variable.
      FOR i IN 1 .. l_supply_src_types_tb(l_crossdock_criteria_id).COUNT LOOP
	 IF (l_supply_src_types_tb(l_crossdock_criteria_id)(i) = G_PLAN_SUP_PO_APPR) THEN
	    l_po_sup := G_PLAN_SUP_PO_APPR;
	    l_po_priority := i;
	  ELSIF (l_supply_src_types_tb(l_crossdock_criteria_id)(i) = G_PLAN_SUP_ASN) THEN
	    l_asn_sup := G_PLAN_SUP_ASN;
	    l_asn_priority := i;
	  ELSIF (l_supply_src_types_tb(l_crossdock_criteria_id)(i) = G_PLAN_SUP_REQ) THEN
	    l_intreq_sup := G_PLAN_SUP_REQ;
	    l_intreq_priority := i;
	  ELSIF (l_supply_src_types_tb(l_crossdock_criteria_id)(i) = G_PLAN_SUP_INTR) THEN
	    l_intship_sup := G_PLAN_SUP_INTR;
	    l_intship_priority := i;
	  ELSIF (l_supply_src_types_tb(l_crossdock_criteria_id)(i) = G_PLAN_SUP_RCV) THEN
	    l_rcv_sup := G_PLAN_SUP_RCV;
	    l_rcv_priority := i;
	 END IF;
      END LOOP;

      -- If we do not need to prioritize documents, reset the supply document
      -- priority variables to the same default value
      IF (g_crossdock_criteria_tb(l_crossdock_criteria_id).prioritize_documents_flag = 2) THEN
	 l_po_priority := 99;
	 l_asn_priority := 99;
	 l_intreq_priority := 99;
	 l_intship_priority := 99;
	 l_rcv_priority := 99;
      END IF;

      -- Now get the valid supply lines for crossdocking and store it in the
      -- shopping basket table.  Only pick up supply lines that match the project/task
      -- on the demand (if necessary).
      -- {{
      -- Make sure the supply lines are retrieved properly into the shopping basket table.
      -- Do this both with and without enforcing document priority.  Also use various
      -- available supply types.  }}
      BEGIN
	 OPEN get_supply_lines
	   (p_xdock_start_time   => l_xdock_start_time,
	    p_xdock_end_time     => l_xdock_end_time,
	    p_sup_resched_flag   => g_crossdock_criteria_tb(l_crossdock_criteria_id).allow_supply_reschedule_flag,
	    p_sup_sched_method   => g_crossdock_criteria_tb(l_crossdock_criteria_id).supply_schedule_method,
	    p_crossdock_goal     => g_crossdock_criteria_tb(l_crossdock_criteria_id).crossdock_goal,
	    p_past_due_interval  => l_past_due_interval,
	    p_past_due_time      => l_past_due_time,
	    p_po_sup             => l_po_sup,
	    p_po_priority        => l_po_priority,
	    p_asn_sup            => l_asn_sup,
	    p_asn_priority       => l_asn_priority,
	    p_intreq_sup         => l_intreq_sup,
	    p_intreq_priority    => l_intreq_priority,
	    p_intship_sup        => l_intship_sup,
	    p_intship_priority   => l_intship_priority,
	    p_rcv_sup            => l_rcv_sup,
	    p_rcv_priority       => l_rcv_priority,
	    p_demand_prim_qty    => l_demand_atr_prim_qty,
	    p_project_id         => l_demand_project_id,
	    p_task_id            => l_demand_task_id);
	 FETCH get_supply_lines BULK COLLECT INTO l_shopping_basket_tb;
	 CLOSE get_supply_lines;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('3.5 - Could not retrieve the valid supply lines for available source types');
	    END IF;
	    -- If we cannot retrieve the valid supply lines, do not error out.
	    -- Just go to the next record and try to crossdock that.
	    GOTO next_record;
      END;
      IF (l_debug = 1) THEN
	 print_debug('3.5 - Successfully populated the shopping basket table with ' ||
		     l_shopping_basket_tb.COUNT || ' crossdockable supply lines');
      END IF;
      l_progress := '430';

      -- 3.6 - Sort the supply lines in the shopping basket table based on the crossdocking
      --       goals.
      -- For crossdock goals of Minimize Wait and Maximize Crossdock, the supply lines in the
      -- shopping basket have already been sorted.
      -- {{
      -- Test out the custom crossdock goal method of sorting the shopping basket lines.
      -- The not implemented stub version should just pass back the inputted shopping basket
      -- table without sorting them.  }}
      IF (g_crossdock_criteria_tb(l_crossdock_criteria_id).crossdock_goal = G_CUSTOM_GOAL) THEN
	 -- For each record in the shopping basket table, call the available to reserve API
	 -- to determine how much quantity from each supply line is available for crossdocking.
	 -- We need to do this since the custom logic might decide which supply lines to consume
	 -- based on the reservable quantity (e.g. Best Fit SPQ type of logic).
	 -- Do this only if the value is not available yet in the shopping basket supply record.
	 IF (l_debug = 1) THEN
	    print_debug('3.6 - Use custom logic to sort the supply lines');
	 END IF;

	 FOR i IN 1 .. l_shopping_basket_tb.COUNT LOOP

	    IF (l_shopping_basket_tb(i).reservable_quantity IS NULL) THEN
	       -- Reservable Quantity value has not been calculated yet for this supply.
	       -- This API will return available to reserve quantity in the primary UOM.
	       IF (l_debug = 1) THEN
		  print_debug('3.6 - Call the Available_supply_to_reserve API');
	       END IF;
	       INV_RESERVATION_AVAIL_PVT.Available_supply_to_reserve
		 (p_api_version_number     	=> 1.0,
		  p_init_msg_lst                => fnd_api.g_false,
		  x_return_status            	=> x_return_status,
		  x_msg_count                	=> x_msg_count,
		  x_msg_data                 	=> x_msg_data,
		  p_organization_id             => l_organization_id,
		  p_item_id                     => l_inventory_item_id,
		  p_supply_source_type_id	=> l_shopping_basket_tb(i).source_type_id,
		  p_supply_source_header_id	=> l_shopping_basket_tb(i).source_header_id,
		  p_supply_source_line_id	=> l_shopping_basket_tb(i).source_line_id,
		  p_supply_source_line_detail	=> l_shopping_basket_tb(i).source_line_detail_id,
		  p_project_id			=> l_shopping_basket_tb(i).project_id,
		  p_task_id			=> l_shopping_basket_tb(i).task_id,
		  x_qty_available_to_reserve    => l_supply_atr_prim_qty,
		  x_qty_available               => l_supply_available_qty);

	       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		  IF (l_debug = 1) THEN
		     print_debug('3.6 - Error returned from available_supply_to_reserve API: '
				 || x_return_status);
		  END IF;
		  -- Instead of erroring out and going to the next WDD record to crossdock,
		  -- just delete the supply line from the shopping basket table.  Shopping basket
		  -- table can therefore be a sparsely populated table after running custom logic.
		  l_shopping_basket_tb.DELETE(i);
		  GOTO next_custom_supply;
		  --GOTO next_record;
		  --RAISE fnd_api.g_exc_error;
	       END IF;

	       -- If the supply is 'In Receiving', the ATR qty returned is for all of receiving.
	       -- Since we're working on a specific MOL supply line, we need to use a LEAST
	       -- to get the min qty value.
	       IF (l_shopping_basket_tb(i).source_type_id = 27) THEN
		  l_supply_atr_prim_qty := LEAST(l_shopping_basket_tb(i).primary_quantity,
						 l_supply_atr_prim_qty);
	       END IF;

	       -- Convert the ATR primary quantity to the UOM on the supply line
	       l_supply_uom_code := l_shopping_basket_tb(i).uom_code;
	       l_conversion_rate := get_conversion_rate(l_inventory_item_id,
							l_primary_uom_code, l_supply_uom_code);
	       IF (l_conversion_rate < 0) THEN
		  IF (l_debug = 1) THEN
		     print_debug('3.6 - Error while obtaining Primary UOM conversion rate for supply line');
		  END IF;
		  -- Instead of erroring out and going to the next WDD record to crossdock,
		  -- just delete the supply line from the shopping basket table.  Shopping basket
		  -- table can therefore be a sparsely populated table after running custom logic.
		  l_shopping_basket_tb.DELETE(i);
		  GOTO next_custom_supply;
	       END IF;
	       -- Round the converted quantity to the standard precision
	       l_supply_atr_qty := ROUND(l_conversion_rate * l_supply_atr_prim_qty, l_conversion_precision);
	       IF (l_debug = 1) THEN
		  print_debug('3.6 - Supply line ATR qty: ' || l_supply_atr_qty || ' ' ||
			      l_supply_uom_code);
	       END IF;

	     ELSIF (l_shopping_basket_tb(i).reservable_quantity IS NOT NULL) THEN
	       -- Reservable Quantity value has alraedy been calculated for this supply.
	       l_supply_atr_qty := l_shopping_basket_tb(i).reservable_quantity;
	    END IF;

	    -- Set the quantity field to be equal to the ATR quanitty for the current supply line
	    -- record in the shopping basket.  We do not want to set this value in
	    -- the reservable_quantity column since this is also used to indicate if the supply line
	    -- record has been locked already.  Since we are not locking the supply line records yet
	    -- here when using custom logic, we will make use of the quantity field instead.
	    -- The custom API should make use of the quantity value instead when sorting the supply
	    -- lines.
	    l_shopping_basket_tb(i).quantity := l_supply_atr_qty;

	    <<next_custom_supply>>
	    NULL; -- Need an executable statment for the branching label above
	 END LOOP; -- End retrieving ATR quantity for all supply lines in shopping basket table
	 -- At this stage, the shopping basket table will have the ATR quantity stamped on all of
	 -- the records.  The table can be sparse so the custom logic to sort the shopping basket
	 -- must keep this in mind.  This will be documented in the custom logic API.
	 l_progress := '440';

	 -- Call the Custom logic to sort the shopping basket table.
	 -- If the API is not implemented, the lines will not be sorted at all.
	 -- {{
	 -- Test that invalid custom logic to sort demand lines is caught.  No sorting
	 -- should be done if this is the case. }}
	 IF (l_debug = 1) THEN
	    print_debug('3.6 - Call the Sort_Supply_Lines API');
	 END IF;
	 WMS_XDOCK_CUSTOM_APIS_PUB.Sort_Supply_Lines
	   (p_wdd_release_record    => p_wsh_release_table(l_wdd_index),
	    p_prioritize_documents  => g_crossdock_criteria_tb(l_crossdock_criteria_id).prioritize_documents_flag,
	    p_shopping_basket_tb    => l_shopping_basket_tb,
	    x_return_status         => x_return_status,
	    x_msg_count             => x_msg_count,
	    x_msg_data              => x_msg_data,
	    x_api_is_implemented    => l_api_is_implemented,
	    x_sorted_order_tb       => l_sorted_order_tb);

	 IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('3.6 - Success returned from Sort_Supply_Lines API');
	    END IF;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('3.6 - Failure returned from Sort_Supply_Lines API');
	    END IF;
	    -- In case of exception, do not error out.  Just use whatever order the
	    -- supply lines are in when the shopping basket table was created.
	    --RAISE fnd_api.g_exc_error;
	    l_sorted_order_tb.DELETE;
	 END IF;
	 l_progress := '450';

	 IF (NOT l_api_is_implemented) THEN
	    IF (l_debug = 1) THEN
	       print_debug('3.6 - Custom API is NOT implemented even though Custom Goal is selected!');
	    END IF;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('3.6 - Custom API is implemented so custom sorting logic is used');
	    END IF;
	 END IF;

	 -- Validate that the output l_sorted_order_tb is not larger in size than
	 -- the shopping basket table and that values exist in l_sorted_order_tb.
	 IF (l_debug = 1) THEN
	    print_debug('3.6 - Rebuild the shopping basket table based on the sorting order returned');
	 END IF;
	 IF (l_sorted_order_tb.COUNT > l_shopping_basket_tb.COUNT OR
	     l_sorted_order_tb.COUNT = 0) THEN
	    -- Invalid condition from the custom logic API.
	    -- Do not sort the shopping basket table and just use the current order
	    -- the lines are in.
	    IF (l_debug = 1) THEN
	       print_debug('3.6 - Invalid output from Sort_Supply_Lines API');
	       print_debug('3.6 - Do not sort the supply lines in the shopping basket');
	    END IF;
	  ELSE
	    -- Sort and rebuild the shopping basket table
	    l_index := l_sorted_order_tb.FIRST;
	    -- Initialize the indices used table and the temp shopping basket table
	    l_indices_used_tb.DELETE;
	    l_shopping_basket_temp_tb.DELETE;
	    LOOP
	       -- Make sure the current entry has not already been used.
	       -- Also make sure the index refered to in l_sorted_order_tb is a valid one
	       -- in the shopping basket table.
	       IF (l_indices_used_tb.EXISTS(l_sorted_order_tb(l_index)) OR
		   NOT l_shopping_basket_tb.EXISTS(l_sorted_order_tb(l_index))) THEN
		  IF (l_debug = 1) THEN
		     print_debug('3.6 - Sorted order table is invalid so do not sort the supply lines');
		  END IF;
		  -- Clear the temp shopping basket table
		  l_shopping_basket_temp_tb.DELETE;
		  -- Exit out of the loop.  No sorting will be done.
		  GOTO invalid_sorting;
	       END IF;

	       -- Mark the current pointer index to the shopping basket table as used
	       l_indices_used_tb(l_sorted_order_tb(l_index)) := TRUE;

	       -- Add this entry to the temp shopping basket table.
	       l_shopping_basket_temp_tb(l_shopping_basket_temp_tb.COUNT + 1) :=
		 l_shopping_basket_tb(l_sorted_order_tb(l_index));

	       EXIT WHEN l_index = l_sorted_order_tb.LAST;
	       l_index := l_sorted_order_tb.NEXT(l_index);
	    END LOOP;

	    -- Set the shopping basket table to point to the new sorted one
	    l_shopping_basket_tb := l_shopping_basket_temp_tb;
	    l_shopping_basket_temp_tb.DELETE;
	    IF (l_debug = 1) THEN
	       print_debug('3.6 - Finished sorting and rebuilding the shopping basket table');
	    END IF;

	    -- In case of an invalid sorted order table, jump to this label below and
	    -- do not sort the shopping basket at all.
	    <<invalid_sorting>>
	    NULL; -- Need an executable statement for the above label to work
	 END IF;
	 l_progress := '460';

      END IF; -- End of crossdocking goal = CUSTOM

      -- Section 4: Consume the valid supply lines for crossdocking to the demand line
      -- 4.1 - Lock the supply line record(s).
      -- 4.2 - Call the available to reserve API to see how much quantity from the supply
      --       is valid for crossdocking.
      -- 4.3 - Crossdock the demand and supply line records.
      -- 4.4 - Create a crossdocked reservation tying the demand to the supply line.
      -- 4.5 - Bulk update the reservable_quantity for all crossdocked supply lines in the
      --       global temp table, wms_xdock_pegging_gtmp.

      -- Check if there are valid supply lines found for crossdocking.
      -- If none exist, move on to the next WDD record to crossdock.
      IF (l_shopping_basket_tb.COUNT = 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('4.1 - No valid supply lines for crossdocking were found');
	 END IF;
	 GOTO next_record;
      END IF;

      -- Initialize the shopping basket supply lines index.  This should not be a NULL value.
      l_supply_index := NVL(l_shopping_basket_tb.FIRST, 1);

      -- Initialize the supply ATR tables used to do a bulk update for the supply lines
      -- crossdocked sucessfully for the reservable_quantity column.
      l_supply_rowid_tb.DELETE;
      l_supply_atr_qty_tb.DELETE;

      -- Define a savepoint so if an exception occurs when performing the bulk update
      -- of supply lines in wms_xdock_pegging_gtmp after the supply lines shopping basket loop,
      -- we want to rollback all crossdock changes done within the loop.
      SAVEPOINT Before_Supply_Loop_sp;

      -- Loop through the valid supply lines to crossdock the current WDD demand
      LOOP
	 -- Define a savepoint so if an exception occurs while updating database records such as
	 -- WDD, RSV, or MOL, we need to rollback the changes and goto the next WDD record
	 -- to crossdock.  Put this inside the supply lines loop so if one supply line
	 -- is crossdocked successfully but another one errors out, we can still crossdock
	 -- the first one.
	 SAVEPOINT Crossdock_Supply_sp;

	 -- Initialize the variables to store the original WDD values in case
	 -- we need to rollback the changes to local PLSQL data structures
	 l_split_wdd_index := NULL;
	 l_split_delivery_index := NULL;
	 l_xdocked_wdd_index := NULL;
	 l_orig_wdd_values_rec := NULL;

	 -- Initialize the supply ATR index variable which is used to update
	 -- the ATR qty for the supply lines used in this loop when crossdocked.
	 l_supply_atr_index := NULL;

	 -- Retrieve needed values from the current supply line
	 l_supply_type_id := l_shopping_basket_tb(l_supply_index).source_type_id;
	 l_supply_header_id := l_shopping_basket_tb(l_supply_index).source_header_id;
	 l_supply_line_id := l_shopping_basket_tb(l_supply_index).source_line_id;
	 l_supply_line_detail_id := l_shopping_basket_tb(l_supply_index).source_line_detail_id;
	 IF (l_debug = 1) THEN
	    print_debug('4.1 - Current supply line to consider for crossdocking');
	    print_debug('4.1 - Supply Source Type ID: => ' || l_supply_type_id);
	    print_debug('4.1 - Supply Header ID: ======> ' || l_supply_header_id);
	    print_debug('4.1 - Supply Line ID: ========> ' || l_supply_line_id);
	    print_debug('4.1 - Supply Line Detail ID: => ' || l_supply_line_detail_id);
	 END IF;

	 -- If the supply type is In Receiving, retrieve the necessary MOL values.
	 -- They will be used to update/split the MOL supply line used for crossdocking.
	 IF (l_supply_type_id = 27) THEN
	    l_mol_header_id := l_supply_header_id;
	    l_mol_line_id := l_supply_line_id;
	    l_mol_qty := l_shopping_basket_tb(l_supply_index).quantity;
	    l_mol_prim_qty := l_shopping_basket_tb(l_supply_index).primary_quantity;
	    l_mol_qty2 := l_shopping_basket_tb(l_supply_index).secondary_quantity;
	    l_mol_uom_code2 := l_shopping_basket_tb(l_supply_index).secondary_uom_code;
	    l_mol_lpn_id := l_shopping_basket_tb(l_supply_index).lpn_id;
	  ELSE
	    l_mol_line_id := NULL;
	 END IF;

	 -- For non-existing reservations, we do not need to match the UOM code on the supply line
	 l_supply_uom_code := NULL;

	 -- In case the supply is of type 'In Receiving' and the org is not PJM enabled OR
	 -- cross project allocation is allowed, set the supply project and task ID to the
	 -- dummy values.  This is used to see if the set of MOLs for the project/task have been
	 -- locked already or not.  For supply types other than In Receiving, this is not used.
	 IF (l_project_ref_enabled = 2 OR l_allow_cross_proj_issues = 'Y') THEN
	    l_supply_project_id := l_dummy_project_id;
	    l_supply_task_id := l_dummy_task_id;
	  ELSE
	    l_supply_project_id := l_shopping_basket_tb(l_supply_index).project_id;
	    l_supply_task_id := l_shopping_basket_tb(l_supply_index).task_id;
	 END IF;

	 -- 4.1 - Lock the supply line record(s).
	 -- Do this only if the supply line has not already been locked.
	 -- For non-Receiving supply types, we can just check if the reservable_quantity field is null.
	 -- For Receiving supply types, since we lock an entire set of MOLs at once, we do not want to
	 -- do this again if not necessary.  For example, say there are two valid MOLs for Item1, call
	 -- them MOL1 and MOL2.  Both records are pulled into the shopping basket table.  When we
	 -- first encounter MOL1, the MOLs associated with Item1 have not been locked yet.  The set
	 -- of MOLs we will lock also includes MOL2.  When we next use MOL2 as a supply line for
	 -- crossdocking, it is unnecessary to lock this record since it has already been done.
	 -- We might still have to calculate the ATR qty even though the record has been locked.
	 -- That is why for MOLs, we cannot rely on the reservable_quantity field.
	 IF ((l_supply_type_id <> 27 AND l_shopping_basket_tb(l_supply_index).reservable_quantity IS NULL)
	     OR
	     (l_supply_type_id = 27 AND l_shopping_basket_tb(l_supply_index).reservable_quantity IS NULL
	      AND NOT (l_locked_mols_tb.EXISTS(l_inventory_item_id) AND
		       l_locked_mols_tb(l_inventory_item_id).EXISTS(l_supply_project_id) AND
		       l_locked_mols_tb(l_inventory_item_id)(l_supply_project_id).EXISTS(l_supply_task_id))))
	       THEN
	    -- We do not need to use these cursors to retrieve the supply line UOM code, project
	    -- and task ID since that information is already stored in the shopping basket table.
	    -- We are doing that here so we can reuse the same locking cursors used for crossdocking
	    -- existing reservations.
	    IF (l_supply_type_id = 1) THEN
	       -- PO
	       BEGIN
		  OPEN lock_po_record(l_supply_uom_code, l_demand_project_id, l_demand_task_id);
		  FETCH lock_po_record INTO l_supply_uom_code, l_supply_project_id, l_supply_task_id;
		  IF (lock_po_record%NOTFOUND) THEN
		     -- If a record is not found, do not error out.  This error condition should not
		     -- occur since the supply lines retrieved should already satisfy the project
		     -- and task restrictions.  Skip this supply line and move on to the next one.
		     IF (l_debug = 1) THEN
			print_debug('4.1 - Supply record not found. UOM/project/task values do not match');
		     END IF;
		     CLOSE lock_po_record;
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Crossdock_Supply_sp;
		     GOTO next_supply;
		  END IF;
		  CLOSE lock_po_record;
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			print_debug('4.1 - Could not lock the PO supply line record');
		     END IF;
		     -- If we cannot lock the supply line, do not error out.  Just go to the
		     -- next available supply and try to crossdock that.
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Crossdock_Supply_sp;
		     GOTO next_supply;
	       END;
	     ELSIF (l_supply_type_id = 7) THEN
	       -- Internal Requisition
	       BEGIN
		  OPEN lock_intreq_record(l_supply_uom_code, l_demand_project_id, l_demand_task_id);
		  -- Multiple records could be returned from this cursor.  We only care about existence.
		  FETCH lock_intreq_record INTO l_supply_uom_code, l_supply_project_id, l_supply_task_id;
		  IF (lock_intreq_record%NOTFOUND) THEN
		     -- If a record is not found, do not error out.  This error condition should not
		     -- occur since the supply lines retrieved should already satisfy the project
		     -- and task restrictions.  Skip this supply line and move on to the next one.
		     IF (l_debug = 1) THEN
			print_debug('4.1 - Supply record not found. UOM/project/task values do not match');
		     END IF;
		     CLOSE lock_intreq_record;
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Crossdock_Supply_sp;
		     GOTO next_supply;
		  END IF;
		  CLOSE lock_intreq_record;
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			print_debug('4.1 - Could not lock the Internal Req supply line record');
		     END IF;
		     -- If we cannot lock the supply line, do not error out.  Just go to the
		     -- next available supply and try to crossdock that.
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Crossdock_Supply_sp;
		     GOTO next_supply;
	       END;
	     ELSIF (l_supply_type_id = 25) THEN
	       -- ASN
	       BEGIN
		  OPEN lock_asn_record(l_supply_uom_code, l_demand_project_id, l_demand_task_id);
		  FETCH lock_asn_record INTO l_supply_uom_code, l_supply_project_id, l_supply_task_id;
		  IF (lock_asn_record%NOTFOUND) THEN
		     -- If a record is not found, do not error out.  This error condition should not
		     -- occur since the supply lines retrieved should already satisfy the project
		     -- and task restrictions.  Skip this supply line and move on to the next one.
		     IF (l_debug = 1) THEN
			print_debug('4.1 - Supply record not found. UOM/project/task values do not match');
		     END IF;
		     CLOSE lock_asn_record;
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Crossdock_Supply_sp;
		     GOTO next_supply;
		  END IF;
		  CLOSE lock_asn_record;
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			print_debug('4.1 - Could not lock the ASN supply line record');
		     END IF;
		     -- If we cannot lock the supply line, do not error out.  Just go to the
		     -- next available supply and try to crossdock that.
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Crossdock_Supply_sp;
		     GOTO next_supply;
	       END;
	     ELSIF (l_supply_type_id = 26) THEN
	       -- In Transit Shipment
	       BEGIN
		  OPEN lock_intship_record(l_supply_uom_code, l_demand_project_id, l_demand_task_id);
		  FETCH lock_intship_record INTO l_supply_uom_code, l_supply_project_id, l_supply_task_id;
		  IF (lock_intship_record%NOTFOUND) THEN
		     -- If a record is not found, do not error out.  This error condition should not
		     -- occur since the supply lines retrieved should already satisfy the project
		     -- and task restrictions.  Skip this supply line and move on to the next one.
		     IF (l_debug = 1) THEN
			print_debug('4.1 - Supply record not found. UOM/project/task values do not match');
		     END IF;
		     CLOSE lock_intship_record;
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Crossdock_Supply_sp;
		     GOTO next_supply;
		  END IF;
		  CLOSE lock_intship_record;
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			print_debug('4.1 - Could not lock the In Transit Shipment supply line record');
		     END IF;
		     -- If we cannot lock the supply line, do not error out.  Just go to the
		     -- next available supply and try to crossdock that.
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Crossdock_Supply_sp;
		     GOTO next_supply;
	       END;
	     ELSIF (l_supply_type_id = 27) THEN
	       -- In Receiving
	       -- We need to lock the set of MOLs that match the given crossdocking criteria for:
               -- org, item, UOM, project and task.
	       -- Initialize the table we are fetching records into.  For this case, we do not need
	       -- to use the values stored there since we are going against the shopping basket
	       -- supply line records directly.
	       l_rcv_lines_tb.DELETE;
	       BEGIN
		  OPEN lock_receiving_lines(l_supply_uom_code, l_demand_atr_prim_qty,
					    l_demand_project_id, l_demand_task_id);
		  FETCH lock_receiving_lines BULK COLLECT INTO l_rcv_lines_tb;
		  -- If a record is not found, do not error out.  This error condition should not
		  -- occur since the supply lines retrieved should already satisfy the project
		  -- and task restrictions.  Skip this supply line and move on to the next one.
		  IF (l_rcv_lines_tb.COUNT = 0) THEN
		     IF (l_debug = 1) THEN
			print_debug('4.1 - No valid receiving supply lines found');
		     END IF;
		     CLOSE lock_receiving_lines;
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Crossdock_Supply_sp;
		     GOTO next_supply;
		  END IF;
		  CLOSE lock_receiving_lines;
	       EXCEPTION
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			print_debug('4.1 - Could not lock the Receiving supply line records');
		     END IF;
		     -- If we cannot lock the supply lines, do not error out.  Just go to the
		     -- next available supply and try to crossdock that.
		     -- Rollback any db changes that might have occurred (currently none).
		     ROLLBACK TO Crossdock_Supply_sp;
		     GOTO next_supply;
	       END;
	       -- Clear the table since we do not need to use it
	       l_rcv_lines_tb.DELETE;

	       -- Indicate that this set of MOLs for the given item has already been locked.
	       IF (l_project_ref_enabled = 2 OR l_allow_cross_proj_issues = 'Y') THEN
		  -- No need to store the project/task info so just use the
		  -- dummy project/task ID values.
		  l_locked_mols_tb(l_inventory_item_id)(l_dummy_project_id)(l_dummy_task_id) := TRUE;
		ELSE
		  -- We need to store the specific project/task info.
		  -- Since we have to match the project/task here, the supply line in the
		  -- shopping basket should have the same values as the demand.
		  l_locked_mols_tb(l_inventory_item_id)(NVL(l_demand_project_id, -999))(NVL(l_demand_task_id, -999)) := TRUE;
	       END IF;
	     ELSE
	       -- Invalid supply for crossdocking.  Should not reach this condition.
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Crossdock_Supply_sp;
	       GOTO next_supply;
	    END IF; -- End locking supply line(s) from different source types
	 END IF; -- End check if reservable_quantity IS NOT NULL

	 -- Reset these values to the ones stored in the shopping basket table.
	 -- The values could differ if the supply line is In Receiving since multiple
	 -- MOLs are locked/retrieved for the current supply line (MOL) in the shopping basket.
	 l_supply_uom_code := l_shopping_basket_tb(l_supply_index).uom_code;
	 l_supply_project_id := l_shopping_basket_tb(l_supply_index).project_id;
	 l_supply_task_id := l_shopping_basket_tb(l_supply_index).task_id;
	 IF (l_debug = 1) THEN
	    print_debug('4.1 - Successfully locked and validated the supply line record(s)');
	    print_debug('4.1 - Supply UOM Code: ===> ' || l_supply_uom_code);
	    print_debug('4.1 - Supply Project ID: => ' || l_supply_project_id);
	    print_debug('4.1 - Supply Task ID: ====> ' || l_supply_task_id);
	 END IF;
	 l_progress := '470';

	 -- 4.2 - Call the available to reserve API to see how much quantity from the supply
	 --       is valid for crossdocking.
	 -- Check if this value has already been queried and stored in the global temp table.
	 -- The shopping basket record for the supply line will have a non null value for the
	 -- reservable_quantity field.  This means the supply line was locked and used for
	 -- crossdocking previously.  In that case, we do not need to call the available to
	 -- reserve API's again.
	 IF (l_shopping_basket_tb(l_supply_index).reservable_quantity IS NULL) THEN
	    IF (l_debug = 1) THEN
	       print_debug('4.2 - Call the Available_supply_to_reserve API');
	    END IF;
	    INV_RESERVATION_AVAIL_PVT.Available_supply_to_reserve
	      (p_api_version_number     	=> 1.0,
	       p_init_msg_lst             	=> fnd_api.g_false,
	       x_return_status            	=> x_return_status,
	       x_msg_count                	=> x_msg_count,
	       x_msg_data                 	=> x_msg_data,
	       p_organization_id                => l_organization_id,
	       p_item_id                        => l_inventory_item_id,
	       p_supply_source_type_id	        => l_supply_type_id,
	       p_supply_source_header_id	=> l_supply_header_id,
	       p_supply_source_line_id	        => l_supply_line_id,
	       p_supply_source_line_detail	=> l_supply_line_detail_id,
	       p_project_id		        => l_supply_project_id,
	       p_task_id			=> l_supply_task_id,
	       x_qty_available_to_reserve       => l_supply_atr_prim_qty,
	       x_qty_available                  => l_supply_available_qty);

	    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	       IF (l_debug = 1) THEN
		  print_debug('4.2 - Error returned from available_supply_to_reserve API: '
			      || x_return_status);
	       END IF;
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Crossdock_Supply_sp;
	       GOTO next_supply;
	       --RAISE fnd_api.g_exc_error;
	    END IF;

	    -- If the supply is 'In Receiving', the ATR qty returned is for all of receiving.
	    -- Since we're working on a specific MOL supply line, we need to use a LEAST
	    -- to get the min qty value.
	    IF (l_supply_type_id = 27) THEN

	       l_supply_atr_prim_qty := LEAST(l_mol_prim_qty, l_supply_atr_prim_qty);

	    END IF;

	    -- Convert the ATR primary quantity to the UOM on the supply line
	    l_conversion_rate := get_conversion_rate(l_inventory_item_id,
						     l_primary_uom_code, l_supply_uom_code);
	    IF (l_conversion_rate < 0) THEN
	       IF (l_debug = 1) THEN
		  print_debug('4.2 - Error while obtaining Primary UOM conversion rate for supply line');
	       END IF;
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Crossdock_Supply_sp;
	       GOTO next_supply;
	    END IF;
	    -- Round the converted quantity to the standard precision
	    l_supply_atr_qty := ROUND(l_conversion_rate * l_supply_atr_prim_qty, l_conversion_precision);

	    -- Set the reservable quantity field for the current supply line
	    -- in the shopping basket table.
	    l_shopping_basket_tb(l_supply_index).reservable_quantity := l_supply_atr_qty;

	  ELSIF (l_shopping_basket_tb(l_supply_index).reservable_quantity IS NOT NULL) THEN
	    -- ATR quantity has already been calculated for this supply line
	    l_supply_atr_qty := l_shopping_basket_tb(l_supply_index).reservable_quantity;
	 END IF; -- End retrieving the ATR supply quantity
	 IF (l_debug = 1) THEN
	    print_debug('4.2 - Supply line ATR qty: ' || l_supply_atr_qty || ' ' ||
			l_supply_uom_code);
	 END IF;
	 -- If the current supply line has no reservable quantity,
	 -- skip it and go to the next available supply line.
	 IF (l_supply_atr_qty <= 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug('4.2 - Supply ATR qty <= 0 so skip to next available supply');
	    END IF;
	    -- Rollback any db changes that might have occurred (currently none).
	    ROLLBACK TO Crossdock_Supply_sp;
	    GOTO next_supply;
	 END IF;
	 l_progress := '480';

	 -- 4.3 - Crossdock the demand and supply line records.
	 IF (l_debug = 1) THEN
	    print_debug('4.3 - Crossdock the demand and supply line records');
	 END IF;

	 -- Convert the WDD ATR qty to the UOM on the supply line.  This value should not be zero if
	 -- we have reached this point.  If this was calculated as zero previously in section 2.6,
	 -- we would have skipped to the next WDD record to crossdock.
	 -- Also convert the WDD qty to the UOM on the supply line.  Since they use the same
	 -- conversion rate, we just need to retrieve that value once.
	 -- This is required so we know if the WDD line needs to be split or not.  That would depend
	 -- on the WDD qty, not the WDD ATR qty.
	 l_conversion_rate := get_conversion_rate(l_inventory_item_id,
						  l_demand_uom_code, l_supply_uom_code);
	 IF (l_conversion_rate < 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug('4.3 - Error while obtaining UOM conversion rate for WDD qty');
	    END IF;
	    -- Rollback any db changes that might have occurred (currently none).
	    ROLLBACK TO Crossdock_Supply_sp;
	    GOTO next_supply;
	 END IF;
	 -- Round the converted quantity to the standard precision
	 l_wdd_atr_txn_qty := ROUND(l_conversion_rate * l_demand_atr_qty, l_conversion_precision);
	 l_wdd_txn_qty := ROUND(l_conversion_rate * l_demand_qty, l_conversion_precision);
	 IF (l_debug = 1) THEN
	    print_debug('4.3 - WDD ATR txn qty: => ' || l_wdd_atr_txn_qty || ' ' || l_supply_uom_code);
	    print_debug('4.3 - WDD txn qty: =====> ' || l_wdd_txn_qty || ' ' || l_supply_uom_code);
	 END IF;
	 l_progress := '490';

	 -- Calculate the Available to Detail quantity.
	 -- {{
	 -- Test that the available to detail quantity is calculated properly,
	 -- i.e. is lower than WDD ATR qty and supply line qty, and is an integer value if
	 -- UOM integrity = 'Y'. }}
	 IF (g_crossdock_criteria_tb(l_crossdock_criteria_id).uom_integrity_flag = 1) THEN
	    -- UOM Integrity is 'Yes'
	    l_atd_qty := LEAST(FLOOR(l_wdd_atr_txn_qty), FLOOR(l_supply_atr_qty));
	  ELSE
	    -- UOM Integrity is 'No'
	    l_atd_qty := LEAST(l_wdd_atr_txn_qty, l_supply_atr_qty);
	 END IF;
	 IF (l_debug = 1) THEN
	    print_debug('4.3 - Available to detail qty: ' || l_atd_qty || ' ' ||
			l_supply_uom_code);
	 END IF;
	 -- If the ATD qty is 0, then goto the next supply line to crossdock.
	 -- This is possible if the UOM integrity flag is 'Y' and the resultant quantities
	 -- were floored to 0.
	 -- {{
	 -- Test for ATD qty = 0.  This can come about if UOM integrity is Yes and the
	 -- demand or supply line with available to reserve qty gets floored to 0. }}
	 IF (l_atd_qty = 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug('4.3 - ATD qty = 0 so skip to the next available supply');
	    END IF;
	    -- Rollback any db changes that might have occurred (currently none).
	    ROLLBACK TO Crossdock_Supply_sp;
	    GOTO next_supply;
	 END IF;
	 l_progress := '500';

	 -- Update the supply line record in the global temp table with the reservable_quantity
	 -- available after using up ATD qty from it for crossdocking.
	 -- Do not do this if the supply is of type In Receiving or Internal Requisition.
	 -- The reason is there can be multiple supply lines of these types in the shopping
	 -- basket table.  However, when we create reservations, they will not be at that
	 -- line level detail. e.g. Receiving supply reservations will only be at the org/item
	 -- level while Internal Reqs will be at the Req header/line level (and not the shipment
	 -- line level).  Availability to reserve needs to take the whole set of lines into account
	 -- so it should be recalculated each time.
	 IF (l_supply_type_id NOT IN (7, 27)) THEN
	    IF (l_debug = 1) THEN
	       print_debug('4.3 - Update the ATR qty for the crossdocked supply line');
	    END IF;
	    -- Instead of updating the supply line record here within the supply lines loop,
	    -- just store the values for the record that needs to be updated.  We will do a
	    -- bulk update outside the loop.  In case of exception for the current supply line
	    -- used for crossdocking, we should remove that record from these tables so the
	    -- global temp table won't be updated incorrectly.  This needs to be only done
	    -- when we are still staying within the supply lines loop.  For exceptions where
	    -- we go to the next_record, we do not need to remove the current supply line record.
	    -- The reason is because the bulk update logic after the supply lines loop is skipped.
	    l_supply_atr_index := l_supply_rowid_tb.COUNT + 1;
	    l_supply_rowid_tb(l_supply_atr_index) := l_shopping_basket_tb(l_supply_index).ROWID;

	    if l_simulation_mode = 'N' THEN
	    l_supply_atr_qty_tb(l_supply_atr_index) := l_supply_atr_qty - l_atd_qty;
	  ELSE



if l_split_flag = 'Y' then

l_supply_atr_qty_tb(l_supply_atr_index) := l_supply_atr_qty-l_atd_wdd_qty;
--   print_debug('Ajith l_atd_wdd_qty '||to_number(l_supply_atr_qty-l_atd_wdd_qty));


ELSE

	l_supply_atr_qty_tb(l_supply_atr_index) := l_supply_atr_qty-l_wdd_txn_qty;

	  -- print_debug('Ajith l_wdd_txn_qty '||to_number(l_supply_atr_qty-l_wdd_txn_qty));
end if;
  END IF;

	    -- Commented the below out since we will do a bulk update instead outside
	    -- the supply lines loop
	    /*BEGIN
	       UPDATE wms_xdock_pegging_gtmp
		 SET reservable_quantity = l_supply_atr_qty - l_atd_qty
		 WHERE ROWID = l_shopping_basket_tb(l_supply_index).ROWID;
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug('4.3 - Could not update the ATR quantity for the supply line');
		  END IF;
		  -- If we cannot udpate the qty on the supply line, do not error out.
		  -- Just go to the next available supply and try to crossdock that.
		  -- Null out the reservable qty value set in the shopping basket table.
		  l_shopping_basket_tb(l_supply_index).reservable_quantity := NULL;
		  -- Rollback any db changes that might have occurred
		  ROLLBACK TO Crossdock_Supply_sp;
		  GOTO next_supply;
	    END;*/
	 END IF;
	 l_progress := '510';

	 -- Convert l_atd_qty to the primary UOM
	 l_conversion_rate := get_conversion_rate(l_inventory_item_id,
						  l_supply_uom_code, l_primary_uom_code);
	 IF (l_conversion_rate < 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug('4.3 - Error while obtaining primary UOM conversion rate for ATD qty');
	    END IF;
	    -- Rollback any db changes that might have occurred (currently none).
	    ROLLBACK TO Crossdock_Supply_sp;
	    -- Remove the supply line from these tables so the ATR qty is not updated
	    IF (l_supply_atr_index IS NOT NULL) THEN
	       l_supply_rowid_tb.DELETE(l_supply_atr_index);
	       l_supply_atr_qty_tb.DELETE(l_supply_atr_index);
	    END IF;
	    GOTO next_supply;
	 END IF;
	 -- Convert l_atd_qty to the primary UOM
	 -- Bug 5608611: Use quantity from demand document where possible
	 IF (l_atd_qty = l_wdd_atr_txn_qty AND l_demand_uom_code = l_primary_uom_code) THEN
	    l_atd_prim_qty := l_demand_atr_qty;
	 ELSE
	    -- Round the converted quantity to the standard precision
	    l_atd_prim_qty := ROUND(l_conversion_rate * l_atd_qty, l_conversion_precision);
	 END IF;
	 IF (l_debug = 1) THEN
	    print_debug('4.3 - ATD qty in primary UOM: => ' || l_atd_prim_qty || ' ' ||
			l_primary_uom_code);
	 END IF;
	 l_progress := '520';

	 -- Store the original WDD values in case of rollback where we need
	 -- to clean up the local PLSQL data structures
	 l_orig_wdd_values_rec.requested_quantity :=
	   p_wsh_release_table(l_wdd_index).requested_quantity;
	 l_orig_wdd_values_rec.requested_quantity2 :=
	   p_wsh_release_table(l_wdd_index).requested_quantity2;
	 l_orig_wdd_values_rec.released_status :=
	   p_wsh_release_table(l_wdd_index).released_status;
	 l_orig_wdd_values_rec.move_order_line_id :=
	   p_wsh_release_table(l_wdd_index).move_order_line_id;

	 -- Crossdock the WDD record, splitting it if necessary.
	 IF (l_debug = 1) THEN
	    print_debug('4.3 - Call the Crossdock_WDD API to crossdock/split the WDD');
	 END IF;
	 Crossdock_WDD
	   (p_log_prefix              => '4.3 - ',
	    p_crossdock_type          => G_CRT_TYPE_PLAN,
	    p_batch_id                => p_batch_id,
	    p_wsh_release_table       => p_wsh_release_table,
	    p_trolin_delivery_ids     => p_trolin_delivery_ids,
	    p_del_detail_id           => p_del_detail_id,
	    l_wdd_index               => l_wdd_index,
	    l_debug                   => l_debug,
	    l_inventory_item_id       => l_inventory_item_id,
	    l_wdd_txn_qty             => l_wdd_txn_qty,
	    l_atd_qty                 => l_atd_qty,
	    l_atd_wdd_qty             => l_atd_wdd_qty,
	    l_atd_wdd_qty2            => l_atd_wdd_qty2,
	    l_supply_uom_code         => l_supply_uom_code,
	    l_demand_uom_code         => l_demand_uom_code,
	    l_demand_uom_code2        => l_demand_uom_code2,
	    l_conversion_rate         => l_conversion_rate,
	    l_conversion_precision    => l_conversion_precision,
	    l_demand_line_detail_id   => l_demand_line_detail_id,
	    l_index                   => l_index,
	    l_detail_id_tab           => l_detail_id_tab,
	    l_action_prms             => l_action_prms,
	    l_action_out_rec          => l_action_out_rec,
	    l_split_wdd_id            => l_split_wdd_id,
	    l_detail_info_tab         => l_detail_info_tab,
	    l_in_rec                  => l_in_rec,
	    l_out_rec                 => l_out_rec,
	    l_mol_line_id             => l_mol_line_id,
	    l_split_wdd_index         => l_split_wdd_index,
	    l_split_delivery_index    => l_split_delivery_index,
	    l_split_wdd_rel_rec       => l_split_wdd_rel_rec,
	    l_allocation_method       => l_allocation_method,
	    l_demand_qty              => l_demand_qty,
	    l_demand_qty2             => l_demand_qty2,
	    l_demand_atr_qty          => l_demand_atr_qty,
	    l_xdocked_wdd_index	      => l_xdocked_wdd_index,
	    l_supply_type_id          => l_supply_type_id,
	    x_return_status           => x_return_status,
	    x_msg_count               => x_msg_count,
	    x_msg_data                => x_msg_data,
	    x_error_code              => l_error_code
	   );

	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    IF (l_debug = 1) THEN
	       print_debug('4.3 - Error returned from Crossdock_WDD API: '
			   || x_return_status);
	    END IF;
	    --RAISE fnd_api.g_exc_error;
	    -- If an exception occurs while modifying a database record, rollback the changes
	    -- and just go to the next WDD record or supply to crossdock.
	    ROLLBACK TO Crossdock_Supply_sp;
	    -- We need to also rollback changes done to local PLSQL data structures
	    IF (l_split_wdd_index IS NOT NULL) THEN
	       p_wsh_release_table.DELETE(l_split_wdd_index);
	    END IF;
	    IF (l_split_delivery_index IS NOT NULL) THEN
	       p_del_detail_id.DELETE(l_split_delivery_index);
	       p_trolin_delivery_ids.DELETE(l_split_delivery_index);
	    END IF;
	    IF (l_xdocked_wdd_index IS NOT NULL) THEN
	       l_detail_info_tab.DELETE(l_xdocked_wdd_index);
	    END IF;
	    p_wsh_release_table(l_wdd_index).requested_quantity :=
	      l_orig_wdd_values_rec.requested_quantity;
	    p_wsh_release_table(l_wdd_index).requested_quantity2 :=
	      l_orig_wdd_values_rec.requested_quantity2;
	    p_wsh_release_table(l_wdd_index).released_status :=
	      l_orig_wdd_values_rec.released_status;
	    p_wsh_release_table(l_wdd_index).move_order_line_id :=
	      l_orig_wdd_values_rec.move_order_line_id;

	    -- Skip to the next WDD record or supply to crossdock
	    IF (l_error_code = 'UOM') THEN
	       GOTO next_supply;
	     ELSE -- l_error_code = 'DB'
	       GOTO next_record;
	    END IF;
	  ELSE
	  		       if p_simulation_mode = 'Y' THEN

	x_wp_crossdock_tbl(l_wdd_index).delivery_detail_id := p_wsh_release_table(l_wdd_index).delivery_detail_id;

if l_split_flag = 'Y' then

x_wp_crossdock_tbl(l_wdd_index).crossdock_qty := 	l_atd_wdd_qty;

  print_debug('In Case of Splitting the crossdocked qty is  '||x_wp_crossdock_tbl(l_wdd_index).crossdock_qty);

ELSE

	x_wp_crossdock_tbl(l_wdd_index).crossdock_qty := 	l_wdd_txn_qty;

	  print_debug('Crossdock Quantity without SPlit '||x_wp_crossdock_tbl(l_wdd_index).crossdock_qty);

end if;
  END IF;

	    IF (l_debug = 1) THEN
	       print_debug('4.3 - Successfully crossdocked/split the WDD record');
	    END IF;
	 END IF;
	 l_progress := '530';

	   if p_simulation_mode = 'Y' then

	   	null;

	  else
	 -- Crossdock and split the MOL supply line if necessary
	 IF (l_mol_line_id IS NOT NULL) THEN
	    IF (l_debug = 1) THEN
	       print_debug('4.3 - Call the Crossdock_MOL API to crossdock/split the MOL: '
			   || l_mol_line_id);
	    END IF;
	    Crossdock_MOL
	      (p_log_prefix              => '4.3 - ',
	       p_crossdock_type          => G_CRT_TYPE_PLAN,
	       l_debug                   => l_debug,
	       l_inventory_item_id       => l_inventory_item_id,
	       l_mol_qty                 => l_mol_qty,
	       l_mol_qty2                => l_mol_qty2,
	       l_atd_qty                 => l_atd_qty,
	       l_atd_mol_qty2            => l_atd_mol_qty2,
	       l_supply_uom_code         => l_supply_uom_code,
	       l_mol_uom_code2           => l_mol_uom_code2,
	       l_conversion_rate         => l_conversion_rate,
	       l_conversion_precision    => l_conversion_precision,
	       l_mol_prim_qty            => l_mol_prim_qty,
	       l_atd_prim_qty            => l_atd_prim_qty,
	       l_split_wdd_id            => l_split_wdd_id,
	       l_mol_header_id           => l_mol_header_id,
	       l_mol_line_id             => l_mol_line_id,
	       l_supply_atr_qty          => l_supply_atr_qty,
	       l_demand_type_id          => l_demand_type_id,
	       l_wip_entity_id           => l_wip_entity_id,
	       l_operation_seq_num       => l_operation_seq_num,
	       l_repetitive_schedule_id  => l_repetitive_schedule_id,
	       l_wip_supply_type         => l_wip_supply_type,
	       l_xdocked_wdd_index	 => l_xdocked_wdd_index,
	       l_detail_info_tab         => l_detail_info_tab,
	       l_wdd_index               => l_wdd_index,
	       l_split_wdd_index         => l_split_wdd_index,
	       p_wsh_release_table       => p_wsh_release_table,
	       l_supply_type_id          => l_supply_type_id,
	       x_return_status           => x_return_status,
	       x_msg_count               => x_msg_count,
	       x_msg_data                => x_msg_data,
	       x_error_code              => l_error_code
	      );

	    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	       IF (l_debug = 1) THEN
		  print_debug('4.3 - Error returned from Crossdock_MOL API: '
			      || x_return_status);
	       END IF;
	       --RAISE fnd_api.g_exc_error;
	       -- If an exception occurs while modifying a database record, rollback the changes
	       -- and just go to the next WDD record or supply to crossdock.
	       ROLLBACK TO Crossdock_Supply_sp;
	       -- We need to also rollback changes done to local PLSQL data structures
	       IF (l_split_wdd_index IS NOT NULL) THEN
		  p_wsh_release_table.DELETE(l_split_wdd_index);
	       END IF;
	       IF (l_split_delivery_index IS NOT NULL) THEN
		  p_del_detail_id.DELETE(l_split_delivery_index);
		  p_trolin_delivery_ids.DELETE(l_split_delivery_index);
	       END IF;
	       IF (l_xdocked_wdd_index IS NOT NULL) THEN
		  l_detail_info_tab.DELETE(l_xdocked_wdd_index);
	       END IF;
	       p_wsh_release_table(l_wdd_index).requested_quantity :=
		 l_orig_wdd_values_rec.requested_quantity;
	       p_wsh_release_table(l_wdd_index).requested_quantity2 :=
		 l_orig_wdd_values_rec.requested_quantity2;
	       p_wsh_release_table(l_wdd_index).released_status :=
		 l_orig_wdd_values_rec.released_status;
	       p_wsh_release_table(l_wdd_index).move_order_line_id :=
		 l_orig_wdd_values_rec.move_order_line_id;

	       -- Skip to the next WDD record or supply to crossdock
	       IF (l_error_code = 'UOM') THEN
		  GOTO next_supply;
		ELSE -- l_error_code = 'DB'
		  GOTO next_record;
	       END IF;
	     ELSE
	       IF (l_debug = 1) THEN
		  print_debug('4.3 - Successfully crossdocked/split the MOL record');
	       END IF;
	    END IF;

	    -- Store this LPN in the crossdocked LPNs table so we can call the pre_generate
	    -- API later on for the entire set of LPN's instead of once for each MOL that
	    -- is crossdocked.
	    IF (NOT l_crossdocked_lpns_tb.EXISTS(l_mol_lpn_id)) THEN
	       l_crossdocked_lpns_tb(l_mol_lpn_id) := TRUE;
	       IF (l_debug = 1) THEN
		  print_debug('4.3 - Successfully stored the crossdocked LPN: ' || l_mol_lpn_id);
	       END IF;
	    END IF;
	    l_progress := '540';

	     end if; --Simulation Mode
	 END IF; -- End of l_mol_line_id IS NOT NULL for receiving supply type


	 -- 4.4 - Create a crossdocked reservation tying the demand to the supply line.
	 -- Calculate the supply expected time
	 IF (l_debug = 1) THEN
	    print_debug('4.4 - Create a crossdock reservation peg to tie the demand to the supply');
	 END IF;
	 IF (l_shopping_basket_tb(l_supply_index).dock_start_time IS NOT NULL) THEN
	    -- Get the supply dock schedule method to decide which
	    -- dock appointment time to use as the supply expected time
	    IF (g_crossdock_criteria_tb(l_crossdock_criteria_id).supply_schedule_method IS NULL OR
		g_crossdock_criteria_tb(l_crossdock_criteria_id).supply_schedule_method = G_APPT_MEAN_TIME) THEN
	       l_supply_expected_time := l_shopping_basket_tb(l_supply_index).dock_mean_time;
	     ELSIF (g_crossdock_criteria_tb(l_crossdock_criteria_id).supply_schedule_method = G_APPT_START_TIME) THEN
	       l_supply_expected_time := l_shopping_basket_tb(l_supply_index).dock_start_time;
	     ELSIF (g_crossdock_criteria_tb(l_crossdock_criteria_id).supply_schedule_method = G_APPT_END_TIME) THEN
	       l_supply_expected_time := l_shopping_basket_tb(l_supply_index).dock_end_time;
	    END IF;
	  ELSE
	    l_supply_expected_time := l_shopping_basket_tb(l_supply_index).expected_time;
	 END IF;
	 IF (l_debug = 1) THEN
	    print_debug('4.4 - Supply line expected time: ' ||
			TO_CHAR(l_supply_expected_time, 'DD-MON-YYYY HH24:MI:SS'));
	 END IF;

if p_simulation_mode = 'Y' then

	null;

ELSE
	 -- Call the Create_RSV API to create a crossdock reservation
	 IF (l_debug = 1) THEN
	    print_debug('4.4 - Call the Create_RSV API to create a crossdock reservation');
	 END IF;
	 Create_RSV
	   (p_log_prefix              => '4.4 - ',
	    p_crossdock_type          => G_CRT_TYPE_PLAN,
	    l_debug                   => l_debug,
	    l_organization_id         => l_organization_id,
	    l_inventory_item_id       => l_inventory_item_id,
	    l_demand_type_id          => l_demand_type_id,
	    l_demand_so_header_id     => l_demand_so_header_id,
	    l_demand_line_id          => l_demand_line_id,
	    l_split_wdd_id            => l_split_wdd_id,
	    l_primary_uom_code        => l_primary_uom_code,
	    l_demand_uom_code2        => l_demand_uom_code2,
	    l_supply_uom_code         => l_supply_uom_code,
	    l_atd_qty                 => l_atd_qty,
	    l_atd_prim_qty            => l_atd_prim_qty,
	    l_atd_wdd_qty2            => l_atd_wdd_qty2,
	    l_supply_type_id          => l_supply_type_id,
	    l_supply_header_id        => l_supply_header_id,
	    l_supply_line_id          => l_supply_line_id,
	    l_supply_line_detail_id   => l_supply_line_detail_id,
	    l_crossdock_criteria_id   => l_crossdock_criteria_id,
	    l_supply_expected_time    => l_supply_expected_time,
	    l_demand_expected_time    => l_demand_expected_time,
	    l_demand_project_id       => l_demand_project_id,
	    l_demand_task_id          => l_demand_task_id,
	    l_original_rsv_rec        => l_original_rsv_rec,
	    l_original_serial_number  => l_original_serial_number,
	    l_to_serial_number        => l_to_serial_number,
	    l_quantity_reserved       => l_quantity_reserved,
	    l_quantity_reserved2      => l_quantity_reserved2,
	    l_rsv_id                  => l_rsv_id,
	    x_return_status           => x_return_status,
	    x_msg_count               => x_msg_count,
	    x_msg_data                => x_msg_data
	   );

	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    IF (l_debug = 1) THEN
	       print_debug('4.4 - Error returned from create_reservation API: '
			   || x_return_status);
	    END IF;
	    --RAISE fnd_api.g_exc_error;
	    -- If an exception occurs while modifying a database record, rollback the changes
	    -- and just go to the next WDD record to crossdock.
	    ROLLBACK TO Crossdock_Supply_sp;
	    -- We need to also rollback changes done to local PLSQL data structures
	    IF (l_split_wdd_index IS NOT NULL) THEN
	       p_wsh_release_table.DELETE(l_split_wdd_index);
	    END IF;
	    IF (l_split_delivery_index IS NOT NULL) THEN
	       p_del_detail_id.DELETE(l_split_delivery_index);
	       p_trolin_delivery_ids.DELETE(l_split_delivery_index);
	    END IF;
	    IF (l_xdocked_wdd_index IS NOT NULL) THEN
	       l_detail_info_tab.DELETE(l_xdocked_wdd_index);
	    END IF;
	    p_wsh_release_table(l_wdd_index).requested_quantity :=
	      l_orig_wdd_values_rec.requested_quantity;
	    p_wsh_release_table(l_wdd_index).requested_quantity2 :=
	      l_orig_wdd_values_rec.requested_quantity2;
	    p_wsh_release_table(l_wdd_index).released_status :=
	      l_orig_wdd_values_rec.released_status;
	    p_wsh_release_table(l_wdd_index).move_order_line_id :=
	      l_orig_wdd_values_rec.move_order_line_id;

	    -- Skip to the next WDD record to crossdock
	    GOTO next_record;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('4.4 - Successfully created a crossdock RSV record');
	    END IF;
	 END IF;
	 l_progress := '550';

end if; -- Simulation Mode

	 -- Exit out of valid supply lines loop if the WDD line has been fully crossdocked.
	 -- There is no need to consider anymore supply lines for crossdocking.
	 IF (p_wsh_release_table(l_wdd_index).released_status = 'S') THEN
	    EXIT;
	 END IF;

	 <<next_supply>>
	 -- Exit when all supply lines have been considered
	 EXIT WHEN l_supply_index = l_shopping_basket_tb.LAST;
	 l_supply_index := l_shopping_basket_tb.NEXT(l_supply_index);
      END LOOP; -- End looping through supply lines in shopping basket table
      l_progress := '560';

      -- 4.5 - Bulk update the reservable_quantity for all crossdocked supply lines in
      --       global temp table, wms_xdock_pegging_gtmp.
      -- {{
      -- Test that the supply lines used in wms_xdock_pegging_gtmp have the reservable
      -- quantities updated properly.  In this way, later demand lines to be crossdocked
      -- can just refer to this quantity instead of calling the availability APIs again. }}
      IF (l_supply_rowid_tb.COUNT > 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('4.5 - For all crossdocked supply lines, update the ATR qty in the temp table');
	 END IF;

	 BEGIN
	    FORALL i IN 1 .. l_supply_rowid_tb.COUNT
	      UPDATE wms_xdock_pegging_gtmp
	      SET reservable_quantity = l_supply_atr_qty_tb(i)
	      WHERE ROWID = l_supply_rowid_tb(i);
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('4.5 - Could not update the ATR qty for the crossdocked supply lines!');
	       END IF;
	       -- If an exception occurs while performing this bulk update, raise an exception.
	       -- This error should not occur but if it does, we should stop the crossdock pegging
	       -- process.
	       RAISE fnd_api.g_exc_error;
	 END;
	 IF (l_debug = 1) THEN
	    print_debug('4.5 - Successfully updated the ATR qty for ' || l_supply_rowid_tb.COUNT
			|| ' (non RCV or Int Req) supply lines ');
	 END IF;
      END IF;
      l_progress := '570';


      <<next_record>>
      EXIT WHEN l_wdd_index = p_wsh_release_table.LAST;
      l_wdd_index := p_wsh_release_table.NEXT(l_wdd_index);
   END LOOP; -- End looping through records in p_wsh_release_table
   l_progress := '580';

   -- Section 5: Post crossdocking logic
   -- 5.1 - For all crossdocked WDD lines, call the shipping API to update the
   --       released_status and move_order_line_id columns.
   -- 5.2 - For all of the MOL's and the corresponding LPN's that were crossdocked,
   --       call the pre_generate API to create the crossdock tasks.
   -- 5.3 - If allocation method is 'C', Crossdock Only or 'X', Prioritize Crossdock,
   --       insert all crossdocked WDD lines into the delivery IN OUT tables:
   --       p_trolin_delivery_ids and p_del_detail_id.
   -- 5.4 - If allocation method is 'N', Prioritize Inventory, backorder all of the
   --       WDD lines that could not be allocated.  Remove those entries from the
   --       delivery IN OUT tables: p_trolin_delivery_ids and p_del_detail_id.
   -- 5.5 - Bug 5194761: clear the temp table wms_xdock_pegging_gtmp

   -- 5.1 - For all crossdocked WDD lines, call the shipping API to update the
   --       released_status and move_order_line_id columns.
   -- {{
   -- Make sure the shipping API to update crossdocked WDD lines is only called if necessary
   -- and properly updates the WDD records. }}

    if p_simulation_mode = 'Y' THEN

    	--Do Bulk Update into the global temp table
    	 print_debug('Updating the wms_wp_rules_simulation table ');

       -- ssk autobuild
  /*  forall m3 in indices of x_wp_crossdock_tbl
    	update wms_wp_rules_simulation
    	set crossdocked_quantity = x_wp_crossdock_tbl(m3).crossdock_qty
    	 where delivery_detail_id=x_wp_crossdock_tbl(m3).delivery_detail_id
    	 and wave_header_id = l_wave_header_id;    */
       IF x_wp_crossdock_tbl.Count > 0 THEN
      FOR m3 IN x_wp_crossdock_tbl.first .. x_wp_crossdock_tbl.last LOOP
      update wms_wp_rules_simulation
    	set crossdocked_quantity = x_wp_crossdock_tbl(m3).crossdock_qty
    	 where delivery_detail_id=x_wp_crossdock_tbl(m3).delivery_detail_id
    	 and wave_header_id = l_wave_header_id;
       END LOOP;
       END IF;
       -- ssk autobuild


    ELSE
   IF (l_detail_info_tab.COUNT > 0) THEN
      IF (l_debug = 1) THEN
	 print_debug('5.1 - Call the Create_Update_Delivery_Detail API for ' ||
		     l_detail_info_tab.COUNT || ' crossdocked WDD records');
      END IF;

      l_in_rec.caller := 'WMS_XDOCK_PEGGING_PUB';
      l_in_rec.action_code := 'UPDATE';

      WSH_INTERFACE_EXT_GRP.Create_Update_Delivery_Detail
	(p_api_version_number      => 1.0,
	 p_init_msg_list           => fnd_api.g_false,
	 p_commit                  => fnd_api.g_false,
	 x_return_status           => x_return_status,
	 x_msg_count               => x_msg_count,
	 x_msg_data                => x_msg_data,
	 p_detail_info_tab         => l_detail_info_tab,
	 p_in_rec                  => l_in_rec,
	 x_out_rec                 => l_out_rec
	 );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 IF (l_debug = 1) THEN
	    print_debug('5.1 - Error returned from Create_Update_Delivery_Detail API: '
			|| x_return_status);
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('5.1 - Successfully updated the crossdocked WDD records');
	 END IF;
      END IF;
   END IF;

   -- 5.2 - For all of the MOL's and the corresponding LPN's that were crossdocked,
   --       call the pre_generate API to create the crossdock tasks.
   -- {{
   -- Test calling the pre_generate API for crossdocked MOL supply lines used.
   -- Make sure the staging lane is stamped properly onto the MOL, operation plans and
   -- tasks are generated properly.  }}
   l_lpn_index := l_crossdocked_lpns_tb.FIRST;

   IF (l_crossdocked_lpns_tb.COUNT > 0) THEN
      LOOP
	 -- Call the pre_generate API for the current crossdocked LPN
	 IF (l_debug = 1) THEN
	    print_debug('5.2 - Call the pre_generate API for LPN: ' || l_lpn_index);
	 END IF;
	 wms_putaway_suggestions.pre_generate
	   (x_return_status         => x_return_status,
	    x_msg_count             => x_msg_count,
	    x_msg_data              => x_msg_data,
	    x_partial_success       => l_partial_success,
	    x_lpn_line_error_tbl    => l_lpn_line_error_tbl,
	    p_from_conc_pgm         => 'N',
	    p_commit                => 'N',
	    p_organization_id       => l_organization_id,
	    p_lpn_id                => l_lpn_index);

	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    IF (l_debug = 1) THEN
	       print_debug('5.2 - Error returned from pre_generate API: ' || l_lpn_index
			   || ': ' || x_return_status);
	    END IF;
	    --RAISE fnd_api.g_exc_error;
	    -- No need to throw an exception if the pre_generate API errors out.
	 END IF;

	 EXIT WHEN l_lpn_index = l_crossdocked_lpns_tb.LAST;
	 l_lpn_index := l_crossdocked_lpns_tb.NEXT(l_lpn_index);
      END LOOP; -- End looping through crossdocked LPN's to call the pre_generate API
      IF (l_debug = 1) THEN
	 print_debug('5.2 - Finished calling pre_generate API for all crossdocked LPNs: ' ||
		     l_crossdocked_lpns_tb.COUNT);
      END IF;
      l_progress := '590';
   END IF;

   -- 5.3 - If allocation method is 'C', Crossdock Only or 'X', Prioritize Crossdock,
   --       insert all crossdocked WDD lines into the delivery IN OUT tables:
   --       p_trolin_delivery_ids and p_del_detail_id.
   -- {{
   -- Test for allocation method of Crossdock only or Prioritize Crossdock that crossdocked
   -- WDD lines are inserted into the delivery tables so shipping can pick them up and autocreate
   -- deliveries for them (if this option is set on the pick release form). }}
   IF (l_allocation_method = G_CROSSDOCK_ONLY OR
       l_allocation_method = G_PRIORITIZE_CROSSDOCK) THEN
      -- Initialize the necessary variables
      l_unable_to_crossdock := FALSE;
      l_wdd_index := p_wsh_release_table.FIRST;
      LOOP
	 IF (p_wsh_release_table.COUNT = 0) THEN
	    EXIT;
	 END IF;

	 -- Insert the crossdocked WDD lines into the delivery tables
	 IF (p_wsh_release_table(l_wdd_index).released_status = 'S') THEN
	    l_index := NVL(p_del_detail_id.LAST, 0) + 1;
	    p_del_detail_id(l_index) := p_wsh_release_table(l_wdd_index).delivery_detail_id;
	    p_trolin_delivery_ids(l_index) := p_wsh_release_table(l_wdd_index).delivery_id;
	  ELSIF (p_wsh_release_table(l_wdd_index).released_status IN ('R','B')) THEN
	    -- For Allocation method of 'Crossdock Only', if any line is not able
	    -- to be crossdocked, return a warning status to Shipping to alert the user.
	    IF (l_allocation_method = G_CROSSDOCK_ONLY) THEN
	       l_unable_to_crossdock := TRUE;
	    END IF;
	 END IF;

	 EXIT WHEN l_wdd_index = p_wsh_release_table.LAST;
	 l_wdd_index := p_wsh_release_table.NEXT(l_wdd_index);
      END LOOP;
      IF (l_debug = 1) THEN
	 print_debug('5.3 - Successfully inserted ' || p_del_detail_id.COUNT ||
		     ' crossdocked WDD lines into delivery tables');
      END IF;
   END IF;
   l_progress := '600';

   -- 5.4 - If allocation method is 'N' (Prioritize Inventory), backorder all of the
   --       WDD lines that could not be allocated.  Remove those entries from the
   --       delivery IN OUT tables: p_trolin_delivery_ids and p_del_detail_id.
   --       UPDATE: No need to remove the backordered lines from the delivery tables.
   --       This is because shipping does not pass anything in those tables.  They expect
   --       us to populate those tables with crossdocked WDD lines only.
   -- {{
   -- Test that for allocation method of Prioritize Inventory, if a line does not get
   -- allocated through inventory or crossdock, it should be backordered.  }}
   IF (l_allocation_method = G_PRIORITIZE_INVENTORY) THEN
      -- Initialize the variables
      l_wdd_index := p_wsh_release_table.FIRST;
      l_index := 1;
      l_shipping_attr.DELETE;
      l_backordered_wdd_lines := 0;
      LOOP
	 IF (p_wsh_release_table.COUNT = 0) THEN
	    EXIT;
	 END IF;

	 -- Backorder the WDD lines that could not be allocated
	 -- Bug 5220216
	 -- For non-reservable item, shipping still calls the pick
	 -- release API. As a result for prioritize Inventory case
	 -- this API gets called and if there was a non-reservable
	 -- item it will get back ordered. Excluding those WDDs.
	 IF (p_wsh_release_table(l_wdd_index).released_status IN ('R', 'B'))
	   AND (l_item_params_tb(p_wsh_release_table(l_wdd_index).inventory_item_id).reservable_type <> 2)
	  THEN
	    l_shipping_attr(l_index).source_header_id := p_wsh_release_table(l_wdd_index).source_header_id;
	    l_shipping_attr(l_index).source_line_id := p_wsh_release_table(l_wdd_index).source_line_id;
	    l_shipping_attr(l_index).ship_from_org_id := p_wsh_release_table(l_wdd_index).organization_id;
	    l_shipping_attr(l_index).released_status := p_wsh_release_table(l_wdd_index).released_status;
	    l_shipping_attr(l_index).delivery_detail_id := p_wsh_release_table(l_wdd_index).delivery_detail_id;
	    l_shipping_attr(l_index).action_flag := 'B';
	    l_shipping_attr(l_index).cycle_count_quantity := p_wsh_release_table(l_wdd_index).requested_quantity;
	    l_shipping_attr(l_index).cycle_count_quantity2 := p_wsh_release_table(l_wdd_index).requested_quantity2;
	    l_shipping_attr(l_index).subinventory := p_wsh_release_table(l_wdd_index).from_sub;
	    l_shipping_attr(l_index).locator_id := NULL;

	    -- Increment the index storing the backordered WDD records
	    l_index := l_index + 1;

	    -- Store the backordered WDD line in the table so it can
	    -- be removed from the delivery IN OUT tables.
	    -- No need to do this anymore since Shipping does not pass in any values in the
	    -- IN OUT delivery tables.  Instead just set the released status of the backordered
	    -- WDD line in the release table to 'B'.  Shipping can make use of this information
	    -- later on if they do not want to auto-create deliveries for backordered lines.
	    --l_backordered_wdd_tbl(p_wsh_release_table(l_wdd_index).delivery_detail_id) := TRUE;
	    l_backordered_wdd_lines := l_backordered_wdd_lines + 1;
	    p_wsh_release_table(l_wdd_index).released_status := 'B';
	 END IF;

	 EXIT WHEN l_wdd_index = p_wsh_release_table.LAST;
	 l_wdd_index := p_wsh_release_table.NEXT(l_wdd_index);
      END LOOP;

      -- Call the Shipping API to backorder the WDD lines
      IF (l_shipping_attr.COUNT > 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('5.4 - Call the Update_Shipping_Attributes API to backorder ' ||
			l_shipping_attr.COUNT || ' WDD records');
	 END IF;
	 WSH_INTERFACE.Update_Shipping_Attributes
	   (p_source_code               => 'INV',
	    p_changed_attributes        => l_shipping_attr,
	    x_return_status             => x_return_status
	    );
	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    IF (l_debug = 1) THEN
	       print_debug('5.4 - Error returned from Update_Shipping_Attributes API: '
			   || x_return_status);
	    END IF;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;

      -- Loop through table p_del_detail_id.  If that WDD is backordered (value exists in
      -- l_backordered_wdd_tbl), then delete that entry from p_del_detail_id and the corresponding
      -- one in p_trolin_delivery_ids.
      -- UPDATE: No need to do the following logic anymore since Shipping does not populate the
      -- delivery tables prior to calling the crossdock/inventory pick release APIs.
      -- {{
      -- Backordered WDD lines should have their records removed from the shipping delivery
      -- tables so the auto-create deliveries process does not pick them up. }}
      /*l_index := p_del_detail_id.FIRST;
      l_next_index := p_del_detail_id.FIRST;
      LOOP
	 l_index := l_next_index;
	 l_next_index := p_del_detail_id.NEXT(l_next_index);
	 -- Exit out of loop when l_index is null, meaning we have
	 -- reached the last entry in the table.
	 EXIT WHEN l_index IS NULL;

	 IF (l_backordered_wdd_tbl.EXISTS(p_del_detail_id(l_index))) THEN
	    p_del_detail_id.DELETE(l_index);
	    p_trolin_delivery_ids.DELETE(l_index);
	 END IF;
      END LOOP;*/
      IF (l_debug = 1) THEN
	 print_debug('5.4 - Finished backordering ' || l_backordered_wdd_lines || ' WDD lines');
      END IF;
   END IF; -- End of: IF (l_allocation_method = G_PRIORITIZE_INVENTORY) THEN
   l_progress := '610';

   -- 5.5 - Bug 5194761: delete records from wms_xdock_pegging_gtmp
   DELETE wms_xdock_pegging_gtmp;
   IF (l_debug = 1) AND SQL%FOUND THEN
      print_debug('5.5 - Cleared the temp table wms_xdock_pegging_gtmp');
   END IF;

   -- Standard call to commit
   IF fnd_api.To_Boolean(p_commit) THEN
      COMMIT;
   END IF;
   l_progress := '620';

   -- If we have reached this point, the return status should be set to success.
   -- This variable is reused each time we call another API but we try to continue with the
   -- flow and raise an exception only when absolutely necessary.  Since this is a planning
   -- and pegging API, if exceptions occur, we should just not peg anything instead of throwing
   -- errors.  Addendum to this is for allocation method of 'Crossdock Only', if any of the
   -- lines could not be crossdocked, return a 'Warning' status.  This is so Shipping can alert
   -- the user that some lines were not able to be allocated through crossdock.  The other
   -- allocation methods are taken care of when backordering unallocated WDD lines.
   IF (l_allocation_method = G_CROSSDOCK_ONLY AND l_unable_to_crossdock) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
      x_return_status := fnd_api.g_ret_sts_success;
   END IF;
   l_progress := '630';

 end if; -- Simulation Mode
   IF (l_debug = 1) THEN
      print_debug('***End of Planned_Cross_Dock***');
   END IF;

   -- Stop the profiler
   -- dbms_profiler.stop_profiler;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Planned_Cross_Dock_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Planned_Cross_Dock - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Planned_Cross_Dock_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Planned_Cross_Dock - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO Planned_Cross_Dock_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Planned_Cross_Dock - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END Planned_Cross_Dock;
-- {{ }}
-- {{******************** End Planned_Cross_Dock ********************}}
-- {{ }}


-- {{ }}
-- {{******************** Procedure Opportunistic_Cross_Dock ********************}}
PROCEDURE Opportunistic_Cross_Dock
  (p_organization_id            IN      NUMBER,
   p_move_order_line_id         IN      NUMBER,
   p_crossdock_criterion_id     IN      NUMBER,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2)
  IS
     l_api_name           CONSTANT VARCHAR2(30) := 'Opportunistic_Cross_Dock';
     l_progress           VARCHAR2(10);
     l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     -- This variable is used to indicate if the custom APIs were used.
     l_api_is_implemented       BOOLEAN;

     -- This variable stores the PJM org parameter to allow cross project allocation
     -- when matching supply to demand lines for crossdocking.  Possible values are 'Y' or 'N'.
     l_allow_cross_proj_issues  VARCHAR2(1);

     -- This variable indicates if the org is PJM enabled or not.  1 = Yes, 2 = No
     l_project_ref_enabled      NUMBER;

     -- This boolean variable indicates if the org is a WMS org or not.
     l_wms_org_flag             BOOLEAN;

     -- These variable will store necessary info for the item being crossdocked
     -- from the MOL inputted.
     l_inventory_item_id        NUMBER;
     l_primary_uom_code         VARCHAR2(3);
     l_reservable_type          NUMBER;
     l_lot_control_code         NUMBER;
     l_lot_divisible_flag       VARCHAR2(1);

     -- Local variables for the input org and crossdock criteria.
     -- Needed so code from Planned Crossdock case can be reused.
     l_organization_id          NUMBER;
     l_crossdock_criteria_id    NUMBER;

     -- Cursor to retrieve valid scheduled Sales Order demand lines
     CURSOR SO_scheduled_lines(p_project_id NUMBER, p_task_id NUMBER) IS
	SELECT
	  inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id) AS header_id,
	  wdd.source_line_id AS line_id,
	  wdd.delivery_detail_id AS line_detail_id,
	  wdd.requested_quantity AS quantity,
	  wdd.requested_quantity_uom AS uom_code,
	  wdd.requested_quantity2 AS secondary_quantity,
	  wdd.requested_quantity_uom2 AS secondary_uom_code,
	  wdd.project_id AS project_id,
	  wdd.task_id AS task_id,
	  NULL AS wip_supply_type
	FROM wsh_delivery_details wdd, oe_order_lines_all ool
	WHERE wdd.organization_id = l_organization_id
	  AND wdd.inventory_item_id = l_inventory_item_id
	  AND wdd.released_status = 'R'
	  AND wdd.source_code = 'OE'
	  AND wdd.requested_quantity > 0
	  AND wdd.source_line_id = ool.line_id
	  AND NVL(ool.source_document_type_id, -999) <> 10
	  AND ool.booked_flag = 'Y'
	  AND ool.open_flag = 'Y'
	  AND NOT EXISTS (SELECT 'Drop Ship'
			  FROM oe_drop_ship_sources odss
			  WHERE odss.header_id = ool.header_id
			  AND odss.line_id = ool.line_id)
	  -- Only pick up WDD lines that match the project/task of the MOL if necessary
	  AND (l_project_ref_enabled = 2 OR
	       l_allow_cross_proj_issues = 'Y' OR
	       (NVL(wdd.project_id, -999) = NVL(p_project_id, -999) AND
		NVL(wdd.task_id, -999) = NVL(p_task_id, -999)));


     -- Cursor to retrieve valid backordered Sales Order demand lines
     CURSOR SO_backordered_lines(p_project_id NUMBER, p_task_id NUMBER) IS
	SELECT
	  inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id) AS header_id,
	  wdd.source_line_id AS line_id,
	  wdd.delivery_detail_id AS line_detail_id,
	  wdd.requested_quantity AS quantity,
	  wdd.requested_quantity_uom AS uom_code,
	  wdd.requested_quantity2 AS secondary_quantity,
	  wdd.requested_quantity_uom2 AS secondary_uom_code,
	  wdd.project_id AS project_id,
	  wdd.task_id AS task_id,
	  NULL AS wip_supply_type
	FROM wsh_delivery_details wdd, oe_order_lines_all ool
	WHERE wdd.organization_id = l_organization_id
	  AND wdd.inventory_item_id = l_inventory_item_id
	  AND wdd.released_status = 'B'
	  AND wdd.source_code = 'OE'
	  AND wdd.requested_quantity > 0
	  AND wdd.source_line_id = ool.line_id
	  AND NVL(ool.source_document_type_id, -999) <> 10
	  AND ool.booked_flag = 'Y'
	  AND ool.open_flag = 'Y'
	  AND NOT EXISTS (SELECT 'Drop Ship'
			  FROM oe_drop_ship_sources odss
			  WHERE odss.header_id = ool.header_id
			  AND odss.line_id = ool.line_id)
	  -- Only pick up WDD lines that match the project/task of the MOL if necessary
	  AND (l_project_ref_enabled = 2 OR
	       l_allow_cross_proj_issues = 'Y' OR
	       (NVL(wdd.project_id, -999) = NVL(p_project_id, -999) AND
		NVL(wdd.task_id, -999) = NVL(p_task_id, -999)));


     -- Cursor to retrieve valid scheduled Internal Order demand lines
     CURSOR IO_scheduled_lines(p_project_id NUMBER, p_task_id NUMBER) IS
	SELECT
	  inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id) AS header_id,
	  wdd.source_line_id AS line_id,
	  wdd.delivery_detail_id AS line_detail_id,
	  wdd.requested_quantity AS quantity,
	  wdd.requested_quantity_uom AS uom_code,
	  wdd.requested_quantity2 AS secondary_quantity,
	  wdd.requested_quantity_uom2 AS secondary_uom_code,
	  wdd.project_id AS project_id,
	  wdd.task_id AS task_id,
	  NULL AS wip_supply_type
	FROM wsh_delivery_details wdd, oe_order_lines_all ool
	WHERE wdd.organization_id = l_organization_id
	  AND wdd.inventory_item_id = l_inventory_item_id
	  AND wdd.released_status = 'R'
	  AND wdd.source_code = 'OE'
	  AND wdd.requested_quantity > 0
	  AND wdd.source_line_id = ool.line_id
	  AND NVL(ool.source_document_type_id, -999) = 10
	  AND ool.booked_flag = 'Y'
	  AND ool.open_flag = 'Y'
	  AND NOT EXISTS (SELECT 'Drop Ship'
			  FROM oe_drop_ship_sources odss
			  WHERE odss.header_id = ool.header_id
			  AND odss.line_id = ool.line_id)
	  -- Only pick up WDD lines that match the project/task of the MOL if necessary
	  AND (l_project_ref_enabled = 2 OR
	       l_allow_cross_proj_issues = 'Y' OR
	       (NVL(wdd.project_id, -999) = NVL(p_project_id, -999) AND
		NVL(wdd.task_id, -999) = NVL(p_task_id, -999)));


     -- Cursor to retrieve valid backordered Internal Order demand lines
     CURSOR IO_backordered_lines(p_project_id NUMBER, p_task_id NUMBER) IS
	SELECT
	  inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id) AS header_id,
	  wdd.source_line_id AS line_id,
	  wdd.delivery_detail_id AS line_detail_id,
	  wdd.requested_quantity AS quantity,
	  wdd.requested_quantity_uom AS uom_code,
	  wdd.requested_quantity2 AS secondary_quantity,
	  wdd.requested_quantity_uom2 AS secondary_uom_code,
	  wdd.project_id AS project_id,
	  wdd.task_id AS task_id,
	  NULL AS wip_supply_type
	FROM wsh_delivery_details wdd, oe_order_lines_all ool
	WHERE wdd.organization_id = l_organization_id
	  AND wdd.inventory_item_id = l_inventory_item_id
	  AND wdd.released_status = 'B'
	  AND wdd.source_code = 'OE'
	  AND wdd.requested_quantity > 0
	  AND wdd.source_line_id = ool.line_id
	  AND NVL(ool.source_document_type_id, -999) = 10
	  AND ool.booked_flag = 'Y'
	  AND ool.open_flag = 'Y'
	  AND NOT EXISTS (SELECT 'Drop Ship'
			  FROM oe_drop_ship_sources odss
			  WHERE odss.header_id = ool.header_id
			  AND odss.line_id = ool.line_id)
	  -- Only pick up WDD lines that match the project/task of the MOL if necessary
	  AND (l_project_ref_enabled = 2 OR
	       l_allow_cross_proj_issues = 'Y' OR
	       (NVL(wdd.project_id, -999) = NVL(p_project_id, -999) AND
		NVL(wdd.task_id, -999) = NVL(p_task_id, -999)));


     -- Cursor to retrieve valid backordered WIP Component demand lines
     CURSOR wip_component_demand_lines(p_project_id        NUMBER,
				       p_task_id           NUMBER,
				       p_xdock_start_time  DATE,
				       p_xdock_end_time    DATE) IS
	SELECT
	  wmsv.wip_entity_id AS header_id,
	  wmsv.operation_seq_num AS line_id,
	  wmsv.repetitive_schedule_id AS line_detail_id,
	  wmsv.date_required AS expected_time,
	  wmsv.quantity_backordered AS quantity,
	  wmsv.primary_uom_code AS uom_code,
	  NULL AS secondary_quantity,
	  NULL AS secondary_uom_code,
	  wmsv.project_id AS project_id,
	  wmsv.task_id AS task_id,
	  wmsv.wip_supply_type AS wip_supply_type
	FROM wip_material_shortages_v wmsv
	WHERE wmsv.organization_id = l_organization_id
	  AND wmsv.inventory_item_id = l_inventory_item_id
	  AND wmsv.wip_entity_type in (1, 2, 5)
	  AND wmsv.date_required IS NOT NULL
	  -- Only pick up WIP demand lines that lie within the crossdock window
	  -- OR have a date_required value in the past.
	  AND (wmsv.date_required BETWEEN p_xdock_start_time AND p_xdock_end_time OR
	       wmsv.date_required < SYSDATE)
	  -- Only pick up WIP lines that match the project/task of the MOL if necessary
	  AND (l_project_ref_enabled = 2 OR
	       l_allow_cross_proj_issues = 'Y' OR
	       (NVL(wmsv.project_id, -999) = NVL(p_project_id, -999) AND
		NVL(wmsv.task_id, -999) = NVL(p_task_id, -999)));


     -- Variables to retrieve the values from the demand lines cursors.
     -- We will bulk collect the records from the cursors into these PLSQL tables and
     -- use them to do a bulk insert into the xdock pegging global temp table.
     TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
     TYPE uom_tab IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
     TYPE bool_tab IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
     l_header_id_tb             num_tab;
     l_line_id_tb               num_tab;
     l_line_detail_id_tb        num_tab;
     l_quantity_tb              num_tab;
     l_uom_code_tb              uom_tab;
     l_secondary_quantity_tb    num_tab;
     l_secondary_uom_code_tb    uom_tab;
     l_project_id_tb            num_tab;
     l_task_id_tb               num_tab;
     l_wip_supply_type_tb       num_tab;

     -- Variables to store the expected time values for the demand line records retrieved.
     -- We will use the date tables to do a bulk insert into the xdock pegging global temp table.
     TYPE date_tab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
     l_dock_start_time_tb       date_tab;
     l_dock_mean_time_tb        date_tab;
     l_dock_end_time_tb         date_tab;
     l_expected_time_tb         date_tab;

     -- Cursor to retrieve, lock and validate the MOL inputted
     CURSOR get_move_order_line IS
	SELECT mtrl.*,
	  msi.primary_uom_code AS primary_uom_code,
	  NVL(msi.reservable_type, 1) AS reservable_type,
	  NVL(msi.lot_control_code, 1) AS lot_control_code,
	  NVL(msi.lot_divisible_flag, 'Y') AS lot_divisible_flag,
	  wlpn.lpn_context AS lpn_context
	FROM mtl_txn_request_lines mtrl, mtl_system_items msi, wms_license_plate_numbers wlpn
	WHERE mtrl.line_id = p_move_order_line_id
	  AND mtrl.organization_id = l_organization_id
	  -- Modified the line below to use an IN instead of <>
	  -- AND mtrl.line_status <> inv_globals.g_to_status_closed
	  AND mtrl.line_status IN (inv_globals.g_to_status_preapproved,
				   inv_globals.g_to_status_approved)
	  AND mtrl.backorder_delivery_detail_id IS NULL
	  AND mtrl.lpn_id IS NOT NULL
	  AND mtrl.quantity > 0
	  AND NVL(mtrl.quantity_delivered, 0) = 0
	  AND NVL(mtrl.quantity_detailed, 0) = 0
	  AND NVL(mtrl.inspection_status, 2) = 2
	  AND NVL(mtrl.wms_process_flag, 1) = 1
	  AND NVL(mtrl.reference, 'non-RMA') <> 'ORDER_LINE_ID'
	  AND mtrl.inventory_item_id = msi.inventory_item_id
	  AND mtrl.organization_id = msi.organization_id
	  AND mtrl.lpn_id = wlpn.lpn_id
	  AND wlpn.lpn_context IN (2, 3) -- WIP or RCV
	  -- Added the following line so the index: WMS_LICENSE_PLATE_NUMBERS_N6
	  -- can be used in case the SQL optimizer uses WLPN as the driving table.
	  AND wlpn.organization_id = l_organization_id
	  FOR UPDATE OF mtrl.line_id NOWAIT;

     -- Variable to store info from the inputted MOL record
     l_mol_rec                  get_move_order_line%ROWTYPE;
     l_supply_type_id           NUMBER;
     l_supply_header_id         NUMBER;
     l_supply_line_id           NUMBER;
     l_supply_line_detail_id    NUMBER;
     l_supply_uom_code          VARCHAR2(3);
     l_supply_expected_time     DATE;
     l_mol_qty                  NUMBER;
     l_mol_header_id            NUMBER;
     l_mol_line_id              NUMBER;
     l_mol_prim_qty             NUMBER;
     l_mol_qty2                 NUMBER;
     l_mol_uom_code2            VARCHAR2(3);
     l_mol_lpn_id               NUMBER;

     -- Cursor to lock the set of MOL lines related to the input MOL (i.e. same org/item
     -- for RCV, same org/item/WIP job for WIP)
     CURSOR lock_mo_lines(p_lpn_context             NUMBER,
			  p_wip_entity_id           NUMBER,
			  p_operation_seq_num       NUMBER,
			  p_repetitive_schedule_id  NUMBER) IS
	SELECT mtrl.line_id
	FROM mtl_txn_request_lines mtrl, mtl_txn_request_headers mtrh,
	  wms_license_plate_numbers wlpn
	WHERE mtrl.header_id = mtrh.header_id
	  AND mtrh.move_order_type = inv_globals.g_move_order_put_away
	  AND mtrl.organization_id = l_organization_id
	  AND mtrl.inventory_item_id = l_inventory_item_id
	  -- Modified the line below to use an IN instead of <> so the
	  -- index MTL_TXN_REQUEST_LINES_N10 on MTRL is more likely to be used.
	  -- AND mtrl.line_status <> inv_globals.g_to_status_closed
	  AND mtrl.line_status IN (inv_globals.g_to_status_preapproved,
				   inv_globals.g_to_status_approved)
	  AND mtrl.backorder_delivery_detail_id IS NULL
	  AND mtrl.lpn_id IS NOT NULL
	  AND mtrl.quantity > 0
	  AND NVL(mtrl.quantity_delivered, 0) = 0
	  AND NVL(mtrl.quantity_detailed, 0) = 0
	  AND NVL(mtrl.inspection_status, 2) = 2
	  AND NVL(mtrl.wms_process_flag, 1) = 1
	  AND NVL(mtrl.reference, 'non-RMA') <> 'ORDER_LINE_ID'
	  AND mtrl.lpn_id = wlpn.lpn_id
	  AND wlpn.lpn_context = p_lpn_context
	  -- Added the following line so the index: WMS_LICENSE_PLATE_NUMBERS_N6
	  -- can be used in case the SQL optimizer uses WLPN as the driving table.
	  AND wlpn.organization_id = l_organization_id
	  AND (p_lpn_context = 3 OR -- RCV
	       (p_lpn_context = 2 AND -- WIP
		mtrl.txn_source_id = p_wip_entity_id)
		-- The two lines below are not required since WIP putaway MOLs do not store
		-- the operation sequence num or the repetitive schedule ID.
		-- NVL(mtrl.txn_source_line_id, -999) = NVL(p_operation_seq_num, -999) AND
		-- NVL(mtrl.reference_id, -999) = NVL(p_repetitive_schedule_id, -999))
	       )
	  FOR UPDATE OF mtrl.line_id NOWAIT;

     -- Table to store the results from the lock_mo_lines cursor
     TYPE locked_mo_lines_tb IS TABLE OF lock_mo_lines%ROWTYPE INDEX BY BINARY_INTEGER;
     l_locked_mo_lines_tb       locked_mo_lines_tb;

     -- Crossdock Criteria time interval values.
     -- The max precision for the DAY is 2 digits (i.e. 99 DAY is the largest possible value)
     -- and will be enforced in the crossdock criteria definition form.
     l_xdock_window_interval    INTERVAL DAY(2) TO SECOND;
     l_buffer_interval          INTERVAL DAY(2) TO SECOND;
     l_processing_interval      INTERVAL DAY(2) TO SECOND;

     -- Crossdock time window start and end times.  Any valid deamnds within this
     -- time interval are valid for crossdocking.
     l_xdock_start_time         DATE;
     l_xdock_end_time           DATE;

     -- Cursor to retrieve the existing high level non-crossdocked, non-WIP as demand reservations
     -- for the MO supply line.  For these types of reservations, the detailed_quantity
     -- column should be NULL or 0.
     -- We will also lock the reservations records here.  Using the SKIP LOCKED keyword,
     -- we can select only row records which are lockable without erroring out the entire query.
     CURSOR existing_rsvs_cursor(p_lpn_context    NUMBER,
				 p_wip_entity_id  NUMBER) IS
	SELECT reservation_id, demand_source_type_id, demand_source_header_id,
	  demand_source_line_id, reservation_quantity, reservation_uom_code,
	  secondary_reservation_quantity, secondary_uom_code,
	  primary_reservation_quantity, primary_uom_code
	  FROM mtl_reservations
	  WHERE organization_id = l_organization_id
	  AND inventory_item_id = l_inventory_item_id
	  AND ((p_lpn_context = 3 AND -- RCV supply
		supply_source_type_id = inv_reservation_global.g_source_type_rcv)
	       OR
	       (p_lpn_context = 2 AND -- WIP supply
		supply_source_type_id = inv_reservation_global.g_source_type_wip AND
		supply_source_header_id = p_wip_entity_id))
	  AND demand_source_type_id <> inv_reservation_global.g_source_type_wip
	  AND demand_source_line_detail IS NULL
	  AND NVL(crossdock_flag, 'N') = 'N'
     	  AND primary_reservation_quantity - NVL(detailed_quantity, 0) > 0
	  FOR UPDATE SKIP LOCKED;

     -- Table to store the results from the existing reservations cursor
     TYPE existing_rsvs_tb IS TABLE OF existing_rsvs_cursor%ROWTYPE INDEX BY BINARY_INTEGER;
     l_existing_rsvs_tb         existing_rsvs_tb;

     -- Index used to loop through the existing high level non-inventory reservations
     l_rsv_index                NUMBER;

     -- Variables for existing reservations and the related demand line on it
     l_rsv_id                   NUMBER;
     l_rsv_qty                  NUMBER;
     l_rsv_uom_code             VARCHAR2(3);
     l_rsv_qty2                 NUMBER;
     l_rsv_uom_code2            VARCHAR2(3);
     l_rsv_prim_qty             NUMBER;
     l_rsv_prim_uom_code        VARCHAR2(3);
     l_demand_type_id           NUMBER;
     l_demand_header_id         NUMBER; -- OE order header ID
     l_demand_so_header_id      NUMBER; -- Sales order header ID
     l_demand_line_id           NUMBER;

     -- Cursor to retrieve the valid WDD lines tied to an order line in an existing reservation.
     -- We will try to match for the project/task values on the supply line if necessary.
     CURSOR reserved_wdd_lines(p_project_id NUMBER, p_task_id NUMBER) IS
	SELECT wdd.delivery_detail_id, wdd.requested_quantity, wdd.requested_quantity_uom,
	  wdd.requested_quantity2, wdd.requested_quantity_uom2,
	  wdd.released_status, wdd.project_id, wdd.task_id
	  FROM wsh_delivery_details wdd, oe_order_lines_all ool
	  WHERE wdd.organization_id = l_organization_id
	  AND wdd.inventory_item_id = l_inventory_item_id
	  AND wdd.released_status IN ('R', 'B')
	  AND wdd.source_code = 'OE'
	  AND wdd.requested_quantity > 0
	  AND wdd.source_header_id = l_demand_header_id
	  AND wdd.source_line_id = l_demand_line_id
       	  AND wdd.source_line_id = ool.line_id
	  AND ool.booked_flag = 'Y'
	  AND ool.open_flag = 'Y'
	  AND NOT EXISTS (SELECT 'Drop Ship'
			  FROM oe_drop_ship_sources odss
			  WHERE odss.header_id = ool.header_id
			  AND odss.line_id = ool.line_id)
	  -- Only pick up WDD lines that match the project/task of the MOL if necessary
	  AND (l_project_ref_enabled = 2 OR
	       l_allow_cross_proj_issues = 'Y' OR
	       (NVL(wdd.project_id, -999) = NVL(p_project_id, -999) AND
		NVL(wdd.task_id, -999) = NVL(p_task_id, -999)))
     	  FOR UPDATE OF wdd.delivery_detail_id SKIP LOCKED;

     -- Table to store the results from the reserved_wdd_lines cursor
     TYPE reserved_wdd_lines_tb IS TABLE OF reserved_wdd_lines%ROWTYPE INDEX BY BINARY_INTEGER;
     l_reserved_wdd_lines_tb    reserved_wdd_lines_tb;

     -- Index used to loop through the reserved WDD lines table
     l_wdd_index                NUMBER;

     -- Variables for the current demand line
     l_demand_line_detail_id    NUMBER;
     l_demand_qty               NUMBER;
     l_demand_uom_code          VARCHAR2(3);
     l_demand_qty2              NUMBER;
     l_demand_uom_code2         VARCHAR2(3);
     l_demand_status            VARCHAR2(1);
     l_demand_project_id        NUMBER;
     l_demand_task_id           NUMBER;
     l_dock_start_time          DATE;
     l_dock_mean_time           DATE;
     l_dock_end_time            DATE;
     l_demand_expected_time     DATE;

     -- Variable used to store the current demand source code (as used by crossdock criteria)
     -- The supply source codes are different for Reservations and Crossdock Criteria.
     l_demand_src_code          NUMBER;

     -- Conversion rate when converting quantity values to different UOMs
     l_conversion_rate          NUMBER;
     -- The standard Inventory precision is to 5 decimal places.  Define this in a local constant
     -- in case this needs to be changed later on.  Variable is used to round off converted values
     -- to this precision level.
     l_conversion_precision     CONSTANT NUMBER := 5;

     -- Variables to store the converted quantity values and the available to detail
     -- values.  They will all be converted to the UOM on the MOL supply line, l_supply_uom_code.
     -- We also need the ATD qty in the primary UOM of the item.
     -- l_wdd_atr_txn_qty is used when the full quantity on the WDD line may not be available
     -- for crossdocking.  This is not the case for existing reservations but is possible for
     -- normal crossdocking, i.e. other existing reservations tying up quantity on the WDD line.
     l_wdd_txn_qty              NUMBER;
     l_wdd_atr_txn_qty          NUMBER;
     l_rsv_txn_qty              NUMBER;
     l_atd_qty                  NUMBER;
     l_atd_prim_qty             NUMBER;

     -- These values will store the available to detail quantity converted to the UOM of
     -- the WDD and RSV record respectively.  They are used whenever those records need
     -- to be split.  The secondary quantities are needed too when splitting a WDD or RSV record.
     -- For MOL records, the ATD quantity is always in that UOM.  However, we still need to
     -- convert the ATD quantity to the secondary UOM on the MOL record if it exists.
     l_atd_wdd_qty              NUMBER;
     l_atd_wdd_qty2             NUMBER;
     l_atd_rsv_qty              NUMBER;
     l_atd_rsv_qty2             NUMBER;
     l_atd_mol_qty2             NUMBER;

     -- Variables used to call the Shipping API to split a WDD line if a partial quantity
     -- is crossdocked on the WDD line.
     l_detail_id_tab            WSH_UTIL_CORE.id_tab_type;
     l_action_prms              WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
     l_action_out_rec           WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;
     l_split_wdd_rel_rec        WSH_PR_CRITERIA.relRecTyp;
     l_split_wdd_id             NUMBER;
     l_index                    NUMBER;

     -- Variables used to call the Shipping API to update a WDD line when it is
     -- being crossdocked.
     l_detail_info_tab          WSH_INTERFACE_EXT_GRP.Delivery_Details_Attr_Tbl_Type;
     l_in_rec                   WSH_INTERFACE_EXT_GRP.detailInRecType;
     l_out_rec                  WSH_INTERFACE_EXT_GRP.detailOutRecType;

     -- Variable used to update a crossdocked WDD record
     l_xdocked_wdd_index        NUMBER;

     -- Dummy variables used when calling the private Crossdock_WDD procedure.
     -- These are variables used in the Planned Crossdocking case but not needed here.
     l_batch_id                 NUMBER;
     l_wsh_release_table        WSH_PR_CRITERIA.relRecTabTyp;
     l_trolin_delivery_ids      WSH_UTIL_CORE.Id_Tab_Type;
     l_del_detail_id            WSH_PICK_LIST.DelDetTabTyp;
     l_dummy_wdd_index          NUMBER;
     l_allocation_method        VARCHAR2(1);
     l_split_wdd_index          NUMBER;
     l_split_delivery_index     NUMBER;
     TYPE orig_wdd_values_rec IS RECORD
       (requested_quantity      NUMBER,
	requested_quantity2     NUMBER,
	released_status         VARCHAR2(1),
	move_order_line_id      NUMBER);
     l_orig_wdd_values_rec      orig_wdd_values_rec;
     l_error_code               VARCHAR2(3);

     -- Variables to split and update reservations records
     l_original_rsv_rec         inv_reservation_global.mtl_reservation_rec_type;
     l_to_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
     l_original_serial_number  	inv_reservation_global.serial_number_tbl_type;
     l_to_serial_number         inv_reservation_global.serial_number_tbl_type;
     l_split_rsv_id             NUMBER;

     -- Variables to store the available to reserve quantity for a demand or supply line
     -- both in the primary and demand/supply line UOM.
     l_demand_atr_prim_qty      NUMBER;
     l_demand_atr_qty           NUMBER;
     l_demand_available_qty     NUMBER;
     l_supply_atr_prim_qty      NUMBER;
     l_supply_atr_qty           NUMBER;
     l_supply_available_qty     NUMBER;

     -- Cursor to retrieve eligible demand source types for a given crossdock criteria
     CURSOR demand_src_types_cursor IS
	SELECT source_code
	  FROM wms_xdock_source_assignments
	  WHERE criterion_id = l_crossdock_criteria_id
	  AND source_type = G_SRC_TYPE_DEM
	  ORDER BY priority;

     -- Table to retrieve the values from the demand_src_types_cursor
     l_demand_src_types_tb      num_tab;

     -- Table to store the valid demand lines for crossdocking for the MOL supply line.
     -- The type is defined in the specs instead so the custom logic package can reference it.
     l_shopping_basket_tb       shopping_basket_tb;

     -- Variables used when calling custom logic to sort the supply lines in the
     -- shopping basket table.
     l_sorted_order_tb          sorted_order_tb;
     l_shopping_basket_temp_tb  shopping_basket_tb;
     l_indices_used_tb          bool_tab;

     -- Variables for the get_demand_lines cursor to indicate the relative priority of the demand
     -- source types to retrieve valid demand lines for.  If we don't need to prioritize documents,
     -- a default value of 99 will be used.  The cursor get_demand_lines will order by the priority
     -- value in ascending order so lower values have higher priority.
     l_so_sched_priority        NUMBER;
     l_so_back_priority         NUMBER;
     l_io_sched_priority        NUMBER;
     l_io_back_priority         NUMBER;
     l_wip_priority             NUMBER;

     -- Cursor to retrieve valid demand lines for crossdocking.
     -- For opportunistic crossdock, only crossdockable demand lines are inserted into
     -- the global temp table.  Therefore we want to select every single record (full table scan)
     -- from wms_xdock_pegging_gtmp.
     CURSOR get_demand_lines(p_crossdock_goal     NUMBER,
			     p_so_sched_priority  NUMBER,
			     p_so_back_priority   NUMBER,
			     p_io_sched_priority  NUMBER,
			     p_io_back_priority   NUMBER,
			     p_wip_priority       NUMBER) IS
	SELECT ROWID,
	  inventory_item_id,
	  xdock_source_code,
	  source_type_id,
	  source_header_id,
	  source_line_id,
	  source_line_detail_id,
	  dock_start_time,
	  dock_mean_time,
	  dock_end_time,
	  expected_time,
	  quantity,
	  reservable_quantity,
	  uom_code,
	  primary_quantity,
	  secondary_quantity,
	  secondary_uom_code,
	  project_id,
	  task_id,
	  lpn_id,
	  wip_supply_type
	  FROM wms_xdock_pegging_gtmp
	  WHERE inventory_item_id = l_inventory_item_id
	  ORDER BY DECODE (xdock_source_code,
			   G_OPP_DEM_SO_SCHED, p_so_sched_priority,
			   G_OPP_DEM_SO_BKORD, p_so_back_priority,
			   G_OPP_DEM_IO_SCHED, p_io_sched_priority,
			   G_OPP_DEM_IO_BKORD, p_io_back_priority,
			   G_OPP_DEM_WIP_BKORD, p_wip_priority,
			   99),
		 DECODE (p_crossdock_goal,
			 G_MINIMIZE_WAIT, SYSDATE - expected_time,
			 G_MAXIMIZE_XDOCK, expected_time - SYSDATE,
			 G_CUSTOM_GOAL, NULL,
			 NULL);

     -- Index used to loop through the demand lines for crossdocking to the MOL supply line.
     l_demand_index             NUMBER;

     -- Cursor to lock the WDD demand record
     CURSOR lock_wdd_record(p_delivery_detail_id NUMBER) IS
	SELECT delivery_detail_id
	  FROM wsh_delivery_details
	  WHERE delivery_detail_id = p_delivery_detail_id
	  FOR UPDATE NOWAIT;

     -- Cursor to lock the WIP demand record.
     -- WIP backordered component demand MUST have a record in the table
     -- wip_requirement_operations.  Thus, operation_seq_num should not be null.
     -- We could also lock the wip_entities record but that is probably not necessary,
     -- especially if the demand is a WIP Repetitive job.  That might lock up the record
     -- unnecessarily for other repetitive jobs with the same wip_entity_id.
     CURSOR lock_wip_record(p_wip_entity_id           NUMBER,
			    p_operation_seq_num       NUMBER,
			    p_repetitive_schedule_id  NUMBER) IS
	SELECT wip_entity_id
	  FROM wip_requirement_operations
	  WHERE inventory_item_id = l_inventory_item_id
	  AND organization_id = l_organization_id
	  AND wip_entity_id = p_wip_entity_id
	  AND operation_seq_num = p_operation_seq_num
	  AND NVL(repetitive_schedule_id, -999) = NVL(p_repetitive_schedule_id, -999)
	  FOR UPDATE NOWAIT;

     -- The following are variables used to call the create_reservation API
     l_quantity_reserved        NUMBER;
     l_quantity_reserved2       NUMBER;

     -- Variables used for WIP backordered component demand lines
     l_wip_entity_id            NUMBER;
     l_operation_seq_num        NUMBER;
     l_repetitive_schedule_id   NUMBER;
     l_wip_supply_type          NUMBER;
     l_wip_qty_allocated        NUMBER;

     -- Cursor used when satisfying existing reservations with WIP as a supply.
     -- Part of the reservation could already be fulfilled by other MOLs from the same
     -- WIP job that have been crossdocked.  Since we do not split and update the WIP
     -- to SO/IO reservation when crossdocking, and if the crossdocked MOLs have not
     -- been delivered yet, the WIP reservation will not be updated.  We need to take
     -- these crossdocked WIP MOLs into account when calculating the quantity left to
     -- satisfy on the reservation.  Query for crossdocked WIP MOLs with the WIP job on
     -- the reservation as supply and Order Line on reservation as demand.
     CURSOR get_wip_xdock_qty(p_wip_entity_id            NUMBER,
			      p_operation_seq_num        NUMBER,
			      p_repetitive_schedule_id   NUMBER,
			      p_demand_source_header_id  NUMBER,
			      p_demand_source_line_id    NUMBER) IS
	SELECT NVL(SUM(mtrl.primary_quantity), 0)
	FROM mtl_txn_request_lines mtrl, wsh_delivery_details wdd,
	     wms_license_plate_numbers wlpn
	WHERE mtrl.organization_id = l_organization_id
	  AND mtrl.inventory_item_id = l_inventory_item_id
	  -- Modified the line below to use an IN instead of <> so the
	  -- index MTL_TXN_REQUEST_LINES_N10 on MTRL is more likely to be used.
	  -- AND mtrl.line_status <> inv_globals.g_to_status_closed
	  AND mtrl.line_status IN (inv_globals.g_to_status_preapproved,
				   inv_globals.g_to_status_approved)
	  AND NVL(mtrl.quantity_delivered, 0) = 0
	  AND mtrl.txn_source_id = p_wip_entity_id
	  -- The two lines below are not required since WIP putaway MOLs do not store
	  -- the operation sequence num or the repetitive schedule ID.
	  -- AND NVL(mtrl.txn_source_line_id, -999) = NVL(p_operation_seq_num, -999)
	  -- AND NVL(mtrl.reference_id, -999) = NVL(p_repetitive_schedule_id, -999)
	  AND mtrl.lpn_id = wlpn.lpn_id
	  AND wlpn.lpn_context = 2 -- WIP
	  -- Added the following line so the index: WMS_LICENSE_PLATE_NUMBERS_N6
	  -- can be used in case the SQL optimizer uses WLPN as the driving table.
	  AND wlpn.organization_id = l_organization_id
	  AND mtrl.crossdock_type = 1 -- Crossdocked to OE demand
	  AND mtrl.backorder_delivery_detail_id = wdd.delivery_detail_id
	  AND wdd.source_header_id = p_demand_source_header_id
	  AND wdd.source_line_id = p_demand_source_line_id;

     -- Variables to WIP crossdocked quantity values to adjust the reservation qty
     l_wip_xdock_prim_qty       NUMBER;
     l_wip_xdock_qty            NUMBER;
     l_wip_xdock_qty2           NUMBER;

     -- Variable for WIP MOL supply lines to indicate what type of WIP job
     -- it is from, i.e. Discrete or Flow.
     l_wip_entity_type          NUMBER;

     -- For WIP Discrete Job MOLs, check to see if multiple reservations exist
     -- for the same WIP job as supply.  If so, then do not crossdock the MOL.
     -- If one reservation exists, try to honor it if the demand is of type OE.
     -- Any quantity left can only be pegged to this same OE demand.  We do not want
     -- to create multiple reservations for the same WIP job going to different demands.
     -- Use a distinct in case we have multiple reservations for the same WIP supply and
     -- demand.  This could be possible if the reservations have a different requirement date
     -- so the reservations were not merged.
     CURSOR existing_wip_rsvs IS
	SELECT DISTINCT demand_source_type_id, demand_source_header_id, demand_source_line_id
	  FROM mtl_reservations
	  WHERE organization_id = l_organization_id
	  AND inventory_item_id = l_inventory_item_id
	  AND supply_source_type_id = inv_reservation_global.g_source_type_wip
	  AND supply_source_header_id = l_supply_header_id;

     -- Table to store the results from the existing WIP reservations cursor
     TYPE existing_wip_rsvs_tb IS TABLE OF existing_wip_rsvs%ROWTYPE INDEX BY BINARY_INTEGER;
     l_existing_wip_rsvs_tb     existing_wip_rsvs_tb;

     -- Variables to store the demand that a WIP MOL supply should be pegged against
     l_wip_demand_type_id       NUMBER;
     l_wip_demand_header_id     NUMBER; -- MTL Sales Order Header ID from Reservations
     l_wip_demand_line_id       NUMBER;

BEGIN
   -- Start the profiler for Unit Testing to ensure complete code coverage
   --dbms_profiler.start_profiler('Opportunistic_Cross_Dock: ' || p_move_order_line_id);

   IF (l_debug = 1) THEN
      print_debug('***Calling Opportunistic_Cross_Dock with the following parameters***');
      print_debug('Package Version: ==========> ' || g_pkg_version);
      print_debug('p_organization_id: ========> ' || p_organization_id);
      print_debug('p_move_order_line_id: =====> ' || p_move_order_line_id);
      print_debug('p_crossdock_criterion_id: => ' || p_crossdock_criterion_id);
   END IF;

   -- Set the savepoint
   SAVEPOINT Opportunistic_Cross_Dock_sp;
   l_progress := '10';

   -- Initialize message list to clear any existing messages
   fnd_msg_pub.initialize;
   l_progress := '20';

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := '30';

   -- Initialize local versions of the following input parameters
   l_organization_id := p_organization_id;
   l_crossdock_criteria_id := p_crossdock_criterion_id;

   -- Initialize the PLSQL tables used to retrieve the demand line cursor records
   l_header_id_tb.DELETE;
   l_line_id_tb.DELETE;
   l_line_detail_id_tb.DELETE;
   l_quantity_tb.DELETE;
   l_uom_code_tb.DELETE;
   l_secondary_quantity_tb.DELETE;
   l_secondary_uom_code_tb.DELETE;
   l_project_id_tb.DELETE;
   l_task_id_tb.DELETE;
   l_dock_start_time_tb.DELETE;
   l_dock_mean_time_tb.DELETE;
   l_dock_end_time_tb.DELETE;
   l_expected_time_tb.DELETE;
   l_wip_supply_type_tb.DELETE;

   -- Initialize the detail info table used for updating
   -- crossdocked WDD records
   l_detail_info_tab.DELETE;

   -- Initialize the global Item UOM conversion table.
   g_item_uom_conversion_tb.DELETE;
   l_progress := '40';

   -- Query for and cache the org record.
   IF (NOT INV_CACHE.set_org_rec(l_organization_id)) THEN
      IF (l_debug = 1) THEN
	 print_debug('Error caching the org record');
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   -- Set the PJM enabled flag.
   l_project_ref_enabled := INV_CACHE.org_rec.project_reference_enabled;
   l_progress := '50';

   -- Check if the organization is a WMS organization
   l_wms_org_flag := wms_install.check_install
     (x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_organization_id  => l_organization_id);
   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
	 print_debug('Call to wms_install.check_install failed: ' || x_msg_data);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   l_progress := '60';

   -- Retrieve the org parameter for allowing cross project allocation for crossdocking.
   -- For now, just hardcode this to 'N'.  The reason is even if we create a peg with
   -- differing project/task combinations, execution needs to be able to handle this.
   -- A project/task transfer needs to be done so until that code is present, we should not
   -- create cross project pegs.  The following is the SQL for retrieving this value.
   /*IF (l_project_ref_enabled = 1) THEN
      -- PJM org so see if cross project allocation is allowed
      BEGIN
	 SELECT NVL(allow_cross_proj_issues, 'N')
	   INTO l_allow_cross_proj_issues
	   FROM pjm_org_parameters
	   WHERE organization_id = l_organization_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    l_allow_cross_proj_issues := 'N';
      END;
    ELSE
      -- Non-PJM org so cross project allocation is allowed since there are no projects or tasks
      l_allow_cross_proj_issues := 'Y';
   END IF;*/
   l_allow_cross_proj_issues := 'N';
   l_progress := '70';

   -- Query for and cache the crossdock criteria record for the value entered.
   -- A value must exist.
   -- {{
   -- API should error out if invalid crossdock criteria is passed. }}
   IF (NOT set_crossdock_criteria(l_crossdock_criteria_id)) THEN
      IF (l_debug = 1) THEN
	 print_debug('Error caching the crossdock criteria record: ' ||
		     l_crossdock_criteria_id);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   -- Validate that the crossdock criterion is of type 'Opportunistic'
   IF (g_crossdock_criteria_tb(l_crossdock_criteria_id).criterion_type <> G_CRT_TYPE_OPP) THEN
      IF (l_debug = 1) THEN
	 print_debug('Invalid crossdock criterion type: ' ||
		     g_crossdock_criteria_tb(l_crossdock_criteria_id).criterion_type);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   l_progress := '80';
   -- End of validations and initializations


   -- Section 1: Supply line validations and initializations
   -- 1.1 - Validate that the supply line is eligible for crossdocking.
   -- 1.2 - Lock the set of MOLs related to the inputted supply line.
   -- 1.3 - Calculate the crossdock window given the crossdock criteria time parameters.

   -- 1.1 - Validate that the supply line is eligible for crossdocking.
   -- Retrieve, lock, and validate the MOL record.
   -- {{
   -- Invalid MOL supply lines should not be crossdocked.  Test for MOLs that are
   -- already crossdocked, have partial quantity detailed or delivered already, loose non-LPN
   -- material, part of an RMA return, requires inspection and not inspected yet,
   -- or MOL has already been locked by some other process. }}
   BEGIN
      OPEN get_move_order_line;
      FETCH get_move_order_line INTO l_mol_rec;
      -- If the MOL record is not found, do not error out.  Skip to the end
      -- and do not crossdock the MOL.
      IF (get_move_order_line%NOTFOUND) THEN
	 IF (l_debug = 1) THEN
	    print_debug('1.1 - MOL inputted is not valid for crossdocking');
	 END IF;
	 CLOSE get_move_order_line;
	 GOTO end_crossdock;
      END IF;
      CLOSE get_move_order_line;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('1.1 - Could not retrieve the MOL record');
	 END IF;
	 -- If an exception occurs, do not error out.
	 -- Skip to the end and do not crossdock the MOL.
	 GOTO end_crossdock;
   END;
   IF (l_debug = 1) THEN
      print_debug('1.1 - Successfully retrieved the MOL record');
      print_debug('1.1 - Item ID: ==> ' || l_mol_rec.inventory_item_id);
      print_debug('1.1 - Quantity: => ' || l_mol_rec.quantity || ' ' || l_mol_rec.uom_code);
   END IF;
   l_progress := '90';

   -- Store relevant values needed from the MOL record
   -- {{
   -- Crossdock WIP and RCV MOL supply lines. }}
   IF (l_mol_rec.lpn_context = 3) THEN
      -- RCV MOL
      l_supply_type_id := 27;
      l_supply_header_id := l_mol_rec.header_id;
      l_supply_line_id := l_mol_rec.line_id;
      l_supply_line_detail_id := NULL;
    ELSE
      -- WIP MOL
      l_supply_type_id := 5;
      l_supply_header_id := l_mol_rec.txn_source_id; -- WIP entity ID
      l_supply_line_id := l_mol_rec.txn_source_line_id; -- WIP oper seq num
      l_supply_line_detail_id := l_mol_rec.reference_id; -- WIP repetitive sched ID
      -- Actually the value above refers to the WIP LPN Completion header ID.
      -- For WIP job completions that are available for crossdocking (as a supply),
      -- only Discrete and Flow/WOL entity types will create a putaway MOL.
      -- I believe the only info about the WIP job that is populated on the MOL is
      -- the WIP entity ID, along with the LPN Completion header ID.
      -- For WIP MOLs, the supply line ID and supply line detail ID are not used currently
      -- in either the Availability check, or the create reservations call.
      -- It should be safe for now to leave these values as is.

      -- Get the WIP entity type for the WIP supply
      BEGIN
	 SELECT entity_type
	   INTO l_wip_entity_type
	   FROM wip_entities
	   WHERE wip_entity_id = l_supply_header_id
	   AND organization_id = l_organization_id;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('1.1 - Error retrieving WIP entity type for WIP entity: ' ||
			   l_supply_header_id);
	    END IF;
	    -- If an exception occurs, just skip to the end and do not crossdock
	    -- the MOL supply line.
	    GOTO end_crossdock;
      END;
   END IF;
   IF (l_debug = 1) THEN
      print_debug('1.1 - Supply type: ========> ' || l_supply_type_id);
      print_debug('1.1 - Supply header ID: ===> ' || l_supply_header_id);
      print_debug('1.1 - Supply line ID: =====> ' || l_supply_line_id);
      print_debug('1.1 - Supply line detail: => ' || l_supply_line_detail_id);
      print_debug('1.1 - WIP entity type: ====> ' || l_wip_entity_type);
   END IF;
   l_progress := '95';

   -- Check that for WIP MOL supply lines, the WIP entity type
   -- must be 1 (Discrete) or 4 (Flow).  Other WIP entity types are
   -- not supported for crossdocking in R12.
   IF (l_wip_entity_type IS NOT NULL AND l_wip_entity_type NOT IN (1, 4)) THEN
      IF (l_debug = 1) THEN
	 print_debug('1.1 - Invalid WIP entity type for crossdocking!');
      END IF;
      GOTO end_crossdock;
   END IF;
   l_progress := '97';

   -- Store necessary info from the MOL record
   l_supply_uom_code := l_mol_rec.uom_code;
   l_supply_expected_time := SYSDATE;
   l_mol_header_id := l_mol_rec.header_id;
   l_mol_line_id := l_mol_rec.line_id;
   l_mol_qty := l_mol_rec.quantity;
   l_mol_prim_qty := l_mol_rec.primary_quantity;
   l_mol_qty2 := l_mol_rec.secondary_quantity;
   l_mol_uom_code2 := l_mol_rec.secondary_uom_code;
   l_mol_lpn_id := l_mol_rec.lpn_id;
   l_inventory_item_id := l_mol_rec.inventory_item_id;
   l_primary_uom_code := l_mol_rec.primary_uom_code;
   l_reservable_type := l_mol_rec.reservable_type;
   l_lot_control_code := l_mol_rec.lot_control_code;
   l_lot_divisible_flag := l_mol_rec.lot_divisible_flag;
   l_progress := '100';

   -- For WIP supply MOL of type Flow or Work Order Less Completion,
   -- check to see if a specific OE demand has been associated to it.
   -- If so, we only want to attempt crossdocking to this demand.
   IF (l_wip_entity_type = 4) THEN
      -- Retrieve the OE demand info the WIP Flow job was completed for
      BEGIN
	 SELECT DECODE(ool.source_document_type_id, 10, 8, 2),
	   wlc.demand_source_header_id, wlc.demand_source_line
	   INTO l_wip_demand_type_id, l_wip_demand_header_id, l_wip_demand_line_id
	   FROM wip_lpn_completions wlc, oe_order_lines_all ool
	   WHERE wlc.header_id = l_mol_rec.reference_id
	   -- MOL reference_id is link to header_id in WIP LPN Flow Completions table
	   AND wlc.wip_entity_id = l_supply_header_id
	   AND wlc.lpn_id = l_mol_lpn_id
	   AND wlc.inventory_item_id = l_inventory_item_id
	   AND wlc.organization_id = l_organization_id
	   AND wlc.demand_source_line = ool.line_id (+);
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('1.1 - Exception retrieving demand that WIP job was completed for');
	    END IF;
	    GOTO end_crossdock;
      END;

      -- See if WIP flow job was completed for a specific OE demand
      IF (l_wip_demand_header_id IS NOT NULL) THEN
	 IF (l_debug = 1) THEN
	    print_debug('1.1 - OE demand WIP job was completed for:');
	    print_debug('1.1 - Demand Source Type: => ' || l_wip_demand_type_id);
	    print_debug('1.1 - Demand Header ID: ===> ' || l_wip_demand_header_id);
	    print_debug('1.1 - Demand Line ID: =====> ' || l_wip_demand_line_id);
	 END IF;
       ELSE
	 -- Null out the WIP demand type ID since it was defaulted to 2 in this case
	 l_wip_demand_type_id := NULL;
	 IF (l_debug = 1) THEN
	    print_debug('1.1 - WIP job was not completed for a specific OE demand');
	 END IF;
      END IF;
   END IF;
   l_progress := '105';

   -- For WIP supply MOL of type Discrete, check that multiple distinct reservations
   -- against this WIP job do not exist.  If so, do not crossdock this.
   -- Also if a single distinct reservation does exist, only crossdock peg against
   -- this specific demand if it is of type OE.
   IF (l_wip_entity_type = 1) THEN
      -- See how many reservations exist for the WIP Discrete job
      BEGIN
	 OPEN existing_wip_rsvs;
	 FETCH existing_wip_rsvs BULK COLLECT INTO l_existing_wip_rsvs_tb;
	 CLOSE existing_wip_rsvs;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('1.1 - Exception retrieving the existing WIP reservations');
	    END IF;
	    GOTO end_crossdock;
      END;
      IF (l_debug = 1) THEN
	 print_debug('1.1 - # of distinct existing reservations for WIP Discrete job: ' ||
		     l_existing_wip_rsvs_tb.COUNT);
      END IF;

      -- Do not crossdock if multiple reservations exist
      IF (l_existing_wip_rsvs_tb.COUNT > 1) THEN
	 IF (l_debug = 1) THEN
	    print_debug('1.1 - Multiple distinct reservations exist for WIP Discrete job');
	    print_debug('1.1 - Do not crossdock WIP supply line');
	 END IF;
	 GOTO end_crossdock;
      END IF;

      -- If a single distinct reservation exists for the WIP Discrete job as supply,
      -- retrieve the demand tied to it.
      IF (l_existing_wip_rsvs_tb.COUNT = 1) THEN
	 -- Retrieve the demand info on the reservation
	 l_rsv_index := l_existing_wip_rsvs_tb.FIRST;
	 l_wip_demand_type_id := l_existing_wip_rsvs_tb(l_rsv_index).demand_source_type_id;
	 l_wip_demand_header_id := l_existing_wip_rsvs_tb(l_rsv_index).demand_source_header_id;
	 l_wip_demand_line_id := l_existing_wip_rsvs_tb(l_rsv_index).demand_source_line_id;

	 -- If the demand that the WIP Discrete job is tied to is NOT of type OE,
	 -- skip all processing and do not crossdock.
	 IF (l_wip_demand_type_id NOT IN (2, 8)) THEN
	    IF (l_debug = 1) THEN
	       print_debug('1.1 - WIP Discrete job is reserved to a non-OE demand');
	       print_debug('1.1 - Do not crossdock WIP supply line');
	    END IF;
	    GOTO end_crossdock;
	 END IF;

	 IF (l_debug = 1) THEN
	    print_debug('1.1 - OE demand WIP job is reserved against:');
	    print_debug('1.1 - Demand Source Type: => ' || l_wip_demand_type_id);
	    print_debug('1.1 - Demand Header ID: ===> ' || l_wip_demand_header_id);
	    print_debug('1.1 - Demand Line ID: =====> ' || l_wip_demand_line_id);
	 END IF;
      END IF;

      -- No existing reservations tied to the WIP job
      IF (l_existing_wip_rsvs_tb.COUNT = 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('1.1 - No demand is reserved against the WIP job');
	 END IF;
      END IF;

   END IF; -- END IF matches: IF (l_wip_entity_type = 1) THEN
   l_progress := '107';

   -- Make sure the item is reservable.
   -- {{
   -- Non-reservable items should not be crossdocked. }}
   IF (l_reservable_type = 2) THEN
      IF (l_debug = 1) THEN
	 print_debug('1.1 - Do not crossdock non-reservable items');
      END IF;
      GOTO end_crossdock;
   END IF;
   l_progress := '110';

   -- Make sure the item is lot divisible if the item is lot controlled.
   -- {{
   -- Lot Indivisible items should not be crossdocked. }}
   IF (l_lot_control_code = 2 AND l_lot_divisible_flag = 'N') THEN
      IF (l_debug = 1) THEN
	 print_debug('1.1 - Do not crossdock lot indivisible items');
      END IF;
      GOTO end_crossdock;
   END IF;
   l_progress := '120';

   -- 1.2 - Lock the set of MOLs related to the inputted supply line.
   -- {{
   -- Test for errors while locking the set of supply MOLs related to the input MOL. }}
   BEGIN
      OPEN lock_mo_lines(p_lpn_context            => l_mol_rec.lpn_context,
			 p_wip_entity_id          => l_mol_rec.txn_source_id,
			 p_operation_seq_num      => l_mol_rec.txn_source_line_id,
			 p_repetitive_schedule_id => l_mol_rec.reference_id);
      FETCH lock_mo_lines BULK COLLECT INTO l_locked_mo_lines_tb;
      -- If no valid MO lines are found, do not error out.
      -- Skip to the end and do not crossdock the MOL.
      IF (l_locked_mo_lines_tb.COUNT = 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('1.2 - No valid Move Order supply lines found');
	 END IF;
	 CLOSE lock_mo_lines;
	 GOTO end_crossdock;
      END IF;
      CLOSE lock_mo_lines;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('1.2 - Could not lock the Move Order supply lines');
	 END IF;
	 -- If we cannot lock the Move Order lines, do not error out.
	 -- Skip to the end and do not crossdock the MOL.
	 GOTO end_crossdock;
   END;
   IF (l_debug = 1) THEN
      print_debug('1.2 - Successfully locked the set of Move Order lines');
   END IF;
   l_progress := '130';

   -- 1.3 - Calculate the crossdock window given the crossdock criteria time parameters.

   -- Get the time interval values for the crossdock criteria.
   -- Time intervals will be defined using the function NUMTODSINTERVAL
   -- Crossdock Window Time Interval
   l_xdock_window_interval := NUMTODSINTERVAL
     (g_crossdock_criteria_tb(l_crossdock_criteria_id).window_interval,
      g_crossdock_criteria_tb(l_crossdock_criteria_id).window_uom);
   IF (l_debug = 1) THEN
      print_debug('1.3 - Crossdock Window: ' ||
		  g_crossdock_criteria_tb(l_crossdock_criteria_id).window_interval || ' ' ||
		  g_crossdock_criteria_tb(l_crossdock_criteria_id).window_uom);
   END IF;
   -- Buffer Time Interval
   -- The buffer time interval and UOM should either both be NULL or not NULL.
   l_buffer_interval := NUMTODSINTERVAL
     (NVL(g_crossdock_criteria_tb(l_crossdock_criteria_id).buffer_interval, 0),
      NVL(g_crossdock_criteria_tb(l_crossdock_criteria_id).buffer_uom, 'HOUR'));
   IF (l_debug = 1) THEN
      print_debug('1.3 - Buffer Time: ' ||
		  g_crossdock_criteria_tb(l_crossdock_criteria_id).buffer_interval || ' ' ||
		  g_crossdock_criteria_tb(l_crossdock_criteria_id).buffer_uom);
   END IF;
   -- Order Processing Time Interval
   -- The order processing time interval and UOM should either both be NULL or not NULL.
   l_processing_interval := NUMTODSINTERVAL
     (NVL(g_crossdock_criteria_tb(l_crossdock_criteria_id).processing_interval, 0),
      NVL(g_crossdock_criteria_tb(l_crossdock_criteria_id).processing_uom, 'HOUR'));
   IF (l_debug = 1) THEN
      print_debug('1.3 - Order Processing Time: ' ||
		  g_crossdock_criteria_tb(l_crossdock_criteria_id).processing_interval || ' ' ||
		  g_crossdock_criteria_tb(l_crossdock_criteria_id).processing_uom);
   END IF;

   -- Calculate the crossdock window start and end times
   l_xdock_start_time := SYSDATE + l_processing_interval + l_buffer_interval;
   l_xdock_end_time := SYSDATE + l_processing_interval + l_buffer_interval +
     l_xdock_window_interval;
   IF (l_debug = 1) THEN
      print_debug('1.3 - Crossdock start time: => ' ||
		  TO_CHAR(l_xdock_start_time, 'DD-MON-YYYY HH24:MI:SS'));
      print_debug('1.3 - Crossdock end time: ===> ' ||
		  TO_CHAR(l_xdock_end_time, 'DD-MON-YYYY HH24:MI:SS'));
   END IF;
   l_progress := '140';

   -- Section 2: Crossdocking existing high level reservations
   -- For the inputted Move Order supply line, query to see if any existing high level
   -- reservations exist.  If they do, we should try to detail those first.
   -- 2.1 - Query for and lock existing high level reservations for the MO supply line.
   --     - If a reservation cannot be locked, do not pick up the record for crossdocking.
   --     - Check that the UOM on the MOL supply and reservation match if UOM integrity is Yes.
   --     - For WIP MOL supply with existing reservations, calculate the WIP crossdocked qty.
   --       Get the total quantity for crossdocked MOLs from the same WIP job to the same demand.
   -- 2.2 - Query for and lock the available WDD demand line(s) with a released status of
   --       'R' or 'B' tied to the order line on the reservation.
   --     - If cross project allocation is not allowed and the org is PJM enabled, make sure
   --       the project and task values on the MO supply line matches the demand.
   -- 2.3 - For each valid WDD demand, check that it is valid for crossdocking.
   --     - Demand source type must be allowed on the crossdock criteria.
   --     - Demand expected ship time must lie within the crossdock time window.
   -- 2.4 - Crossdock detail the reservation and update the demand and supply line records.
   -- 2.5 - If quantity still remains on the MOL to be crossdocked, see how much reservable
   --       quantity on the supply is actually available for crossdocking.

   -- 2.1 - Query for and lock existing high level reservations for the MO supply line.
   --     - If a reservation cannot be locked, do not pick up the record for crossdocking.
   --     - Check that the UOM on the MOL supply and reservation match if UOM integrity is Yes.
   -- {{
   -- Test for MO supply lines with existing high level reservations.
   -- The possible demand source types for these reservations are:
   --     Sales Order (scheduled)
   --     Sales Order (backordered)
   --     Internal Order (scheduled)
   --     Internal Order (backordered) }}
   -- {{
   -- Test where an existing reservation is already locked.  This record should not be
   -- picked up for crossdocking. }}
   -- {{
   -- Test for both OE and WIP MO supply lines with existing reservations. }}
   IF (l_debug = 1) THEN
      print_debug('2.1 - Query for existing high level reservations for the MO supply line');
   END IF;
   -- Initialize the table we are fetching records into.
   l_existing_rsvs_tb.DELETE;
   BEGIN
      OPEN existing_rsvs_cursor(p_lpn_context    => l_mol_rec.lpn_context,
				p_wip_entity_id  => l_mol_rec.txn_source_id);
      FETCH existing_rsvs_cursor BULK COLLECT INTO l_existing_rsvs_tb;
      CLOSE existing_rsvs_cursor;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('2.1 - Exception retrieving the existing reservations');
	 END IF;
	 GOTO after_existing_rsvs;
	 --RAISE fnd_api.g_exc_unexpected_error;
   END;
   l_progress := '150';

   -- Loop through the existing reservations and try to crossdock them
   l_rsv_index := l_existing_rsvs_tb.FIRST;
   LOOP
      -- If no existing reservations were found, exit out of loop.
      IF (l_existing_rsvs_tb.COUNT = 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('2.1 - No existing reservations to crossdock');
	 END IF;
	 EXIT;
      END IF;

      -- Retrieve necessary parameters for the demand order line from the current reservation
      l_rsv_id := l_existing_rsvs_tb(l_rsv_index).reservation_id;
      l_rsv_qty := l_existing_rsvs_tb(l_rsv_index).reservation_quantity;
      l_rsv_uom_code := l_existing_rsvs_tb(l_rsv_index).reservation_uom_code;
      l_rsv_qty2 := l_existing_rsvs_tb(l_rsv_index).secondary_reservation_quantity;
      l_rsv_uom_code2 := l_existing_rsvs_tb(l_rsv_index).secondary_uom_code;
      l_rsv_prim_qty := l_existing_rsvs_tb(l_rsv_index).primary_reservation_quantity;
      l_rsv_prim_uom_code := l_existing_rsvs_tb(l_rsv_index).primary_uom_code;
      l_demand_type_id := l_existing_rsvs_tb(l_rsv_index).demand_source_type_id;
      l_demand_so_header_id := l_existing_rsvs_tb(l_rsv_index).demand_source_header_id;
      l_demand_line_id := l_existing_rsvs_tb(l_rsv_index).demand_source_line_id;

      -- Get the demand OE header ID from the Sales Order header ID
      inv_salesorder.get_oeheader_for_salesorder
	(p_salesorder_id   => l_demand_so_header_id,
	 x_oe_header_id    => l_demand_header_id,
	 x_return_status   => x_return_status);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 IF (l_debug = 1) THEN
	    print_debug('2.1 - Error returned from get_oeheader_for_salesorder API: '
			|| x_return_status);
	 END IF;
	 GOTO next_reservation;
      END IF;

      IF (l_debug = 1) THEN
	 print_debug('2.1 - Reservation ID: ========> ' || l_rsv_id);
	 print_debug('2.1 - Reservation Quantity: ==> ' || l_rsv_qty || ' ' ||
		     l_rsv_uom_code);
	 print_debug('2.1 - Reservation Quantity2: => ' || l_rsv_qty2 || ' ' ||
		     l_rsv_uom_code2);
	 print_debug('2.1 - Reservation Prim Qty: ==> ' || l_rsv_prim_qty || ' ' ||
		     l_rsv_prim_uom_code);
	 print_debug('2.1 - Demand source type ID: => ' || l_demand_type_id);
	 print_debug('2.1 - Demand SO header ID: ===> ' || l_demand_so_header_id);
	 print_debug('2.1 - Demand header ID: ======> ' || l_demand_header_id);
	 print_debug('2.1 - Demand line ID: ========> ' || l_demand_line_id);
      END IF;
      l_progress := '160';

      -- Make sure the primary UOM code on the reservation matches the one for the item.
      -- This error condition should not come about but if it does, just skip this
      -- reservation and go to the next one.
      IF (l_primary_uom_code <> l_rsv_prim_uom_code) THEN
	 IF (l_debug = 1) THEN
	    print_debug('2.1 - Item and reservation primary UOM codes do not match!');
	 END IF;
	 GOTO next_reservation;
      END IF;

      -- Check that the UOM on the MOL supply and reservation match if UOM integrity is Yes.
      -- {{
      -- Test for a crossdock criteria where UOM Integrity is Yes and the existing reservation
      -- has a different UOM from the MOL supply lines. }}
      IF (g_crossdock_criteria_tb(l_crossdock_criteria_id).uom_integrity_flag = 1 AND
	  l_rsv_uom_code <> l_supply_uom_code) THEN
	 IF (l_debug = 1) THEN
	    print_debug('2.1 - RSV and MOL UOM codes do not match and UOM Integrity is Yes!');
	 END IF;
	 GOTO next_reservation;
      END IF;
      l_progress := '170';

      --     - For WIP MOL supply with existing reservations, calculate the WIP crossdocked qty.
      --       Get the total quantity for crossdocked MOLs from the same WIP job to the same demand.
      -- {{
      -- Test for WIP MOL supply line where another MOL from the same WIP job is already
      -- satisfying part of an existing reservation.  That quantity should be decremented
      -- from the reservation when deciding on how much quantity to detail. }}
      IF (l_supply_type_id = 5) THEN
	 -- Retrieve the Primary qty for other WIP MOLs for the same WIP job that have
	 -- already been pegged to this existing reservation.
	 IF (l_debug = 1) THEN
	    print_debug('2.1 - Retrieve the WIP crossdocked qty');
	 END IF;
         BEGIN
	    OPEN get_wip_xdock_qty(p_wip_entity_id            => l_mol_rec.txn_source_id,
				   p_operation_seq_num        => l_mol_rec.txn_source_line_id,
				   p_repetitive_schedule_id   => l_mol_rec.reference_id,
				   p_demand_source_header_id  => l_demand_header_id,
				   p_demand_source_line_id    => l_demand_line_id);
	    FETCH get_wip_xdock_qty INTO l_wip_xdock_prim_qty;
	    IF (get_wip_xdock_qty%NOTFOUND) THEN
	       l_wip_xdock_prim_qty := 0;
	    END IF;
	    CLOSE get_wip_xdock_qty;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('2.1 - Exception retrieving the WIP crossdocked qty');
	       END IF;
	       GOTO after_existing_rsvs;
	 END;
	 IF (l_debug = 1) THEN
	    print_debug('2.1 - WIP crossdocked qty: ' || l_wip_xdock_prim_qty || ' '
			|| l_primary_uom_code);
	 END IF;

	 -- Decrement the reservation quantity to be crossdocked if part of it
	 -- is already satisfied by existing crossdocked WIP MOLs.
	 IF (l_wip_xdock_prim_qty <> 0) THEN
	    -- Decrement the RSV qty
	    l_conversion_rate := get_conversion_rate(l_inventory_item_id,
						     l_primary_uom_code, l_rsv_uom_code);
	    IF (l_conversion_rate < 0) THEN
	       IF (l_debug = 1) THEN
		  print_debug('2.1 - Error while obtaining UOM conversion rate for RSV qty');
	       END IF;
	       GOTO next_reservation;
	    END IF;
	    -- Round the converted quantity to the standard precision
	    l_wip_xdock_qty := ROUND(l_conversion_rate * l_wip_xdock_prim_qty, l_conversion_precision);
	    l_rsv_qty := l_rsv_qty - l_wip_xdock_qty;
	    IF (l_debug = 1) THEN
	       print_debug('2.1 - Adjusted RSV Qty: ======> ' || l_rsv_qty || ' ' ||
			   l_rsv_uom_code);
	    END IF;

	    -- If the reservation has no quantity left on it to be satisfied,
	    -- skip to the next available reservation.
	    IF (l_rsv_qty = 0) THEN
	       GOTO next_reservation;
	    END IF;

	    -- Decrement the RSV qty2
	    IF (l_rsv_uom_code2 IS NOT NULL) THEN
	       l_conversion_rate := get_conversion_rate(l_inventory_item_id,
							l_primary_uom_code, l_rsv_uom_code2);
	       IF (l_conversion_rate < 0) THEN
		  IF (l_debug = 1) THEN
		     print_debug('2.1 - Error while obtaining UOM conversion rate for RSV qty2');
		  END IF;
		  GOTO next_reservation;
	       END IF;
	       -- Round the converted quantity to the standard precision
	       l_wip_xdock_qty2 := ROUND(l_conversion_rate * l_wip_xdock_prim_qty, l_conversion_precision);
	       l_rsv_qty2 := l_rsv_qty2 - l_wip_xdock_qty2;
	       IF (l_debug = 1) THEN
		  print_debug('2.1 - Adjusted RSV Qty2: =====> ' || l_rsv_qty2 || ' ' ||
			      l_rsv_uom_code2);
	       END IF;
	    END IF;

	    -- Decrement the RSV primary qty
	    l_rsv_prim_qty := l_rsv_prim_qty - l_wip_xdock_prim_qty;
	    IF (l_debug = 1) THEN
	       print_debug('2.1 - Adjusted RSV Prim Qty: => ' || l_rsv_prim_qty || ' ' ||
			   l_rsv_prim_uom_code);
	    END IF;
	 END IF; -- End IF matches: IF (l_wip_xdock_prim_qty <> 0) THEN
      END IF; -- End Calculating WIP crossdocked qty
      l_progress := '175';

      -- 2.2 - Query for and lock the available WDD demand line(s) with a released status of
      --       'R' or 'B' tied to the order line on the reservation.
      --     - If cross project allocation is not allowed and the org is PJM enabled, make sure
      --       the project and task values on the MO supply line matches the demand.

      -- Initialize the table we are fetching records into.
      l_reserved_wdd_lines_tb.DELETE;
      BEGIN
	 OPEN reserved_wdd_lines(l_mol_rec.project_id, l_mol_rec.task_id);
	 FETCH reserved_wdd_lines BULK COLLECT INTO l_reserved_wdd_lines_tb;
	 CLOSE reserved_wdd_lines;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.2 - Exception retrieving the reserved WDD demand lines');
	    END IF;
	    GOTO next_reservation;
	    --RAISE fnd_api.g_exc_unexpected_error;
      END;
      l_progress := '180';

      -- Loop through the available WDD lines and try to crossdock the valid ones
      l_wdd_index := l_reserved_wdd_lines_tb.FIRST;
      LOOP
	 -- Define a savepoint so if an exception occurs while updating database records such
	 -- as WDD, RSV, or MOL, we need to rollback the changes and goto the next reserved
	 -- WDD demand line to crossdock (if one exists).
	 SAVEPOINT Reserved_WDD_sp;

	 -- Initialize the variable below used for updating crossdocked WDD records,
	 -- in case we need to rollback the changes to local PLSQL data structures.
	 l_xdocked_wdd_index := NULL;

	 -- If no valid reserved WDD lines were found, exit out of loop.
	 -- This should not happen if the reservation was allowed to be created.
	 IF (l_reserved_wdd_lines_tb.COUNT = 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.2 - No valid reserved WDD lines to crossdock');
	    END IF;
	    EXIT;
	 END IF;

	 -- Retrieve necessary parameters for the demand order line from the current reservation
	 l_demand_line_detail_id := l_reserved_wdd_lines_tb(l_wdd_index).delivery_detail_id;
	 l_demand_qty := l_reserved_wdd_lines_tb(l_wdd_index).requested_quantity;
	 l_demand_uom_code := l_reserved_wdd_lines_tb(l_wdd_index).requested_quantity_uom;
	 l_demand_qty2 := l_reserved_wdd_lines_tb(l_wdd_index).requested_quantity2;
	 l_demand_uom_code2 := l_reserved_wdd_lines_tb(l_wdd_index).requested_quantity_uom2;
	 l_demand_status := l_reserved_wdd_lines_tb(l_wdd_index).released_status;
	 l_demand_project_id := l_reserved_wdd_lines_tb(l_wdd_index).project_id;
	 l_demand_task_id := l_reserved_wdd_lines_tb(l_wdd_index).task_id;
	 -- Set the WIP variables to NULL since the demand line is an OE WDD demand
	 l_wip_entity_id := NULL;
	 l_operation_seq_num := NULL;
	 l_repetitive_schedule_id := NULL;
	 l_wip_supply_type := NULL;

	 IF (l_debug = 1) THEN
	    print_debug('2.2 - Current reserved WDD line to check for crossdock:');
	    print_debug('2.2 - Demand line detail ID: ==> ' || l_demand_line_detail_id);
	    print_debug('2.2 - Demand line qty: ========> ' || l_demand_qty || ' ' ||
			l_demand_uom_code);
	    print_debug('2.2 - Demand line qty2: =======> ' || l_demand_qty2 || ' ' ||
			l_demand_uom_code2);
	    print_debug('2.2 - Demand Released Status: => ' || l_demand_status);
	    print_debug('2.2 - Demand Project ID: ======> ' || l_demand_project_id);
	    print_debug('2.2 - Demand Task ID: =========> ' || l_demand_task_id);
	 END IF;

	 -- 2.3 - For each valid WDD demand, check that it is valid for crossdocking.
	 --     - Demand source type must be allowed on the crossdock criteria.
	 --     - Demand expected ship time must lie within the crossdock time window.
	 IF (l_debug = 1) THEN
	    print_debug('2.3 - Check if the current reserved WDD line is valid for crossdocking');
	 END IF;

	 -- Set the appropriate Opportunistic Crossdock demand source code.  This uses a different
	 -- set of lookup values compared to the reservations demand source codes.
	 IF (l_demand_type_id = 2 AND l_demand_status = 'R') THEN
	    -- Sales Order (Scheduled)
	    l_demand_src_code := G_OPP_DEM_SO_SCHED;
	  ELSIF (l_demand_type_id = 2 AND l_demand_status = 'B') THEN
	    -- Sales Order (Backordered)
	    l_demand_src_code := G_OPP_DEM_SO_BKORD;
	  ELSIF (l_demand_type_id = 8 AND l_demand_status = 'R') THEN
	    -- Internal Order (Scheduled)
	    l_demand_src_code := G_OPP_DEM_IO_SCHED;
	  ELSIF (l_demand_type_id = 8 AND l_demand_status = 'B') THEN
	    -- Internal Order (Backordered)
	    l_demand_src_code := G_OPP_DEM_IO_BKORD;
	  ELSE
	    -- Invalid demand for crossdocking.
	    -- {{
	    -- For prior existing reservations that are not supported for crossdocking (WIP),
	    -- make sure we do not try to crossdock them. }}
	    GOTO next_reserved_wdd;
	 END IF;
	 IF (l_debug = 1) THEN
	    print_debug('2.3 - Crossdock Demand Source Code: => ' || l_demand_src_code);
	 END IF;
	 l_progress := '190';

	 -- Demand source type must be allowed on the crossdock criteria.
	 -- Check if the demand line tied to the reservation is valid for crossdocking
	 -- based on the valid demand types allowed for the crossdock criteria.
	 -- {{
	 -- Test for existing reservations for valid demand types to crossdock which are
	 -- not allowed on the crossdock criteria.  Processing should stop and the next
	 -- reserved WDD demand should be considered for crossdocking. }}
	 IF (NOT WMS_XDOCK_UTILS_PVT.Is_Eligible_Demand_Source
	     (p_criterion_id  => l_crossdock_criteria_id,
	      p_source_code   => l_demand_src_code)) THEN
	    -- Demand line on reservation is not valid source for crossdocking
	    IF (l_debug = 1) THEN
	       print_debug('2.3 - WDD Demand line on reservation is not a valid source');
	    END IF;
	    GOTO next_reserved_wdd;
	 END IF;
	 l_progress := '200';

	 -- Demand expected ship time must lie within the crossdock time window.
	 -- Check if the demand line tied to the reservation is valid for crossdocking
	 -- based on the crossdock window for the crossdock criteria.
	 IF (l_debug = 1) THEN
	    print_debug('2.3 - Determine the expected ship time for the demand line');
	 END IF;
	 Get_Expected_Time
	   (p_source_type_id           => l_demand_type_id,
	    p_source_header_id         => l_demand_so_header_id,
	    p_source_line_id           => l_demand_line_id,
	    p_source_line_detail_id    => l_demand_line_detail_id,
	    p_supply_or_demand         => G_SRC_TYPE_DEM,
	    p_crossdock_criterion_id   => l_crossdock_criteria_id,
	    x_return_status            => x_return_status,
	    x_msg_count                => x_msg_count,
	    x_msg_data                 => x_msg_data,
	    x_dock_start_time          => l_dock_start_time,
	    x_dock_mean_time           => l_dock_mean_time,
	    x_dock_end_time            => l_dock_end_time,
	    x_expected_time            => l_demand_expected_time);

	 IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.3 - Success returned from Get_Expected_Time API');
	    END IF;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('2.3 - Failure returned from Get_Expected_Time API');
	    END IF;
	    GOTO next_reserved_wdd;
	    --RAISE fnd_api.g_exc_error;
	 END IF;

	 -- Do not crossdock the demand line on the reservation if an expected ship
	 -- time cannot be determined.
	 -- {{
	 -- If an expected ship time for the demand line on an existing reservation
	 -- cannot be determined, skip processing and move on to the next reserved WDD
	 -- demand. }}
	 IF (l_demand_expected_time IS NULL) THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.3 - Unable to crossdock reservation since demand expected time is NULL');
	    END IF;
	    GOTO next_reserved_wdd;
	 END IF;
	 IF (l_debug = 1) THEN
	    print_debug('2.3 - Demand expected time: => ' ||
			TO_CHAR(l_demand_expected_time, 'DD-MON-YYYY HH24:MI:SS'));
	 END IF;
	 l_progress := '210';

	 -- See if the WDD demand line lies within the crossdock time window.
	 -- If a dock appointment for the demand does not exist and the crossdock criteria
	 -- allows rescheduling of the demand for anytime on the expected ship date, set the
	 -- appropriate logic to determine if the demand is valid.
	 -- Demands with an expected ship time in the past are considered as ready to ship out
	 -- immediately.  Thus they are all valid for Opportunistic Crossdocking.
	 -- {{
	 -- Test for a demand line on an existing reservation that does not have a dock appointment
	 -- and demand reschedule is allowed. }}
	 -- {{
	 -- Test for a demand line on an existing reservation lying within the crossdock window. }}
	 -- {{
	 -- Test for a demand line on an existing reservation not lying within the crossdock
	 -- window.  In this case, we cannot crossdock the existing reservation so just move
	 -- on to the next reserved WDD. }}
	 IF ((l_dock_start_time IS NULL AND
	      g_crossdock_criteria_tb(l_crossdock_criteria_id).allow_demand_reschedule_flag = 1 AND
	      l_demand_expected_time BETWEEN TRUNC(l_xdock_start_time) AND
	      TO_DATE(TO_CHAR(TRUNC(l_xdock_end_time), 'DD-MON-YYYY') ||
		      ' 23:59:59', 'DD-MON-YYYY HH24:MI:SS'))
	     OR (l_demand_expected_time < SYSDATE)
	     OR (l_demand_expected_time BETWEEN l_xdock_start_time AND l_xdock_end_time)) THEN
	    -- Demand is valid for crossdocking based on crossdock time window
	    IF (l_debug = 1) THEN
	       print_debug('2.3 - Demand line is within the crossdock window');
	    END IF;
	  ELSE
	    -- Demand is not valid for crossdocking so skip to the next
	    -- reserved WDD demand to crossdock
	    IF (l_debug = 1) THEN
	       print_debug('2.3 - Demand line is not within the crossdock window');
	    END IF;
	    GOTO next_reserved_wdd;
	 END IF;
	 l_progress := '220';

	 -- 2.4 - Crossdock detail the reservation and update the demand and supply line records.
	 IF (l_debug = 1) THEN
	    print_debug('2.4 - Crossdock detail the relevant records: RSV, WDD, MOL');
	 END IF;

	 -- Convert the WDD qty to the UOM on the supply line.
	 -- Retrieve the conversion rate for the item/from UOM/to UOM combination.
	 -- {{
	 -- Test that the WDD quantity is converted properly to the UOM on the supply line. }}
	 l_conversion_rate := get_conversion_rate(l_inventory_item_id,
						  l_demand_uom_code, l_supply_uom_code);
	 IF (l_conversion_rate < 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - Error while obtaining UOM conversion rate for WDD qty');
	    END IF;
	    -- Rollback any db changes that might have occurred (currently none).
	    ROLLBACK TO Reserved_WDD_sp;
	    -- Process the next existing reserved WDD.
	    GOTO next_reserved_wdd;
	 END IF;
	 -- Round the converted quantity to the standard precision
	 l_wdd_txn_qty := ROUND(l_conversion_rate * l_demand_qty, l_conversion_precision);
	 IF (l_debug = 1) THEN
	    print_debug('2.4 - WDD qty: =====> ' || l_demand_qty || ' ' || l_demand_uom_code);
	    print_debug('2.4 - WDD txn qty: => ' || l_wdd_txn_qty || ' ' || l_supply_uom_code);
	 END IF;
	 l_progress := '230';

	 -- Convert the RSV qty to the UOM on the supply line.
	 -- Retrieve the conversion rate for the item/from UOM/to UOM combination.
	 -- {{
	 -- Test that the RSV quantity is converted properly to the UOM on the supply line. }}
	 l_conversion_rate := get_conversion_rate(l_inventory_item_id,
						  l_rsv_uom_code, l_supply_uom_code);
	 IF (l_conversion_rate < 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - Error while obtaining UOM conversion rate for RSV qty');
	    END IF;
	    -- Rollback any db changes that might have occurred (currently none).
	    ROLLBACK TO Reserved_WDD_sp;
	    -- Process the next existing reserved WDD.
	    GOTO next_reserved_wdd;
	 END IF;
	 -- Round the converted quantity to the standard precision
	 l_rsv_txn_qty := ROUND(l_conversion_rate * l_rsv_qty, l_conversion_precision);
	 IF (l_debug = 1) THEN
	    print_debug('2.4 - RSV qty: =====> ' || l_rsv_qty || ' ' || l_rsv_uom_code);
	    print_debug('2.4 - RSV txn qty: => ' || l_rsv_txn_qty || ' ' || l_supply_uom_code);
	 END IF;
	 l_progress := '240';

	 -- Calculate the Available to Detail quantity.
	 -- {{
	 -- Test that the available to detail quantity is calculated properly,
	 -- i.e. is lower than WDD, RSV, and MOL qty, and is an integer value if
	 -- UOM integrity = 'Y'. }}
	 IF (g_crossdock_criteria_tb(l_crossdock_criteria_id).uom_integrity_flag = 1) THEN
	    -- UOM Integrity is 'Yes'
	    l_atd_qty := LEAST(FLOOR(l_wdd_txn_qty), FLOOR(l_rsv_txn_qty), FLOOR(l_mol_qty));
	  ELSE
	    -- UOM Integrity is 'No'
	    l_atd_qty := LEAST(l_wdd_txn_qty, l_rsv_txn_qty, l_mol_qty);
	 END IF;
	 IF (l_debug = 1) THEN
	    print_debug('2.4 - Available to detail qty: ' || l_atd_qty || ' ' ||
			l_supply_uom_code);
	 END IF;
	 -- If the ATD qty is 0, then goto the next reserved WDD to crossdock.
	 -- This is possible if the UOM integrity flag is 'Y' and the resultant quantities
	 -- were floored to 0.
	 -- {{
	 -- Test for ATD qty = 0.  This can come about if UOM integrity is Yes and the
	 -- demand, reservation or supply line gets floored to 0. }}
	 IF (l_atd_qty = 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - No available qty to detail for this WDD/RSV/MOL combination');
	    END IF;
	    -- Rollback any db changes that might have occurred (currently none).
	    ROLLBACK TO Reserved_WDD_sp;
	    -- Process the next existing reserved WDD.
	    GOTO next_reserved_wdd;
	 END IF;
	 l_progress := '250';

	 -- Convert l_atd_qty to the primary UOM
	 l_conversion_rate := get_conversion_rate(l_inventory_item_id,
						  l_supply_uom_code, l_primary_uom_code);
	 IF (l_conversion_rate < 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - Error while obtaining primary UOM conversion rate for ATD qty');
	    END IF;
	    -- Rollback any db changes that might have occurred (currently none).
	    ROLLBACK TO Reserved_WDD_sp;
	    -- Process the next existing reserved WDD.
	    GOTO next_reserved_wdd;
	 END IF;
	 -- Round the converted quantity to the standard precision
	 l_atd_prim_qty := ROUND(l_conversion_rate * l_atd_qty, l_conversion_precision);
	 IF (l_debug = 1) THEN
	    print_debug('2.4 - ATD qty in primary UOM: => ' || l_atd_prim_qty || ' ' ||
			l_primary_uom_code);
	 END IF;
	 l_progress := '260';

	 -- Crossdock the WDD record, splitting it if necessary.
	 IF (l_debug = 1) THEN
	    print_debug('2.4 - Call the Crossdock_WDD API to crossdock/split the WDD');
	 END IF;
	 Crossdock_WDD
	   (p_log_prefix              => '2.4 - ',
	    p_crossdock_type          => G_CRT_TYPE_OPP,
	    p_batch_id                => l_batch_id,
	    p_wsh_release_table       => l_wsh_release_table,
	    p_trolin_delivery_ids     => l_trolin_delivery_ids,
	    p_del_detail_id           => l_del_detail_id,
	    l_wdd_index               => l_dummy_wdd_index,
	    l_debug                   => l_debug,
	    l_inventory_item_id       => l_inventory_item_id,
	    l_wdd_txn_qty             => l_wdd_txn_qty,
	    l_atd_qty                 => l_atd_qty,
	    l_atd_wdd_qty             => l_atd_wdd_qty,
	    l_atd_wdd_qty2            => l_atd_wdd_qty2,
	    l_supply_uom_code         => l_supply_uom_code,
	    l_demand_uom_code         => l_demand_uom_code,
	    l_demand_uom_code2        => l_demand_uom_code2,
	    l_conversion_rate         => l_conversion_rate,
	    l_conversion_precision    => l_conversion_precision,
	    l_demand_line_detail_id   => l_demand_line_detail_id,
	    l_index                   => l_index,
	    l_detail_id_tab           => l_detail_id_tab,
	    l_action_prms             => l_action_prms,
	    l_action_out_rec          => l_action_out_rec,
	    l_split_wdd_id            => l_split_wdd_id,
	    l_detail_info_tab         => l_detail_info_tab,
	    l_in_rec                  => l_in_rec,
	    l_out_rec                 => l_out_rec,
	    l_mol_line_id             => l_mol_line_id,
	    l_split_wdd_index         => l_split_wdd_index,
	    l_split_delivery_index    => l_split_delivery_index,
	    l_split_wdd_rel_rec       => l_split_wdd_rel_rec,
	    l_allocation_method       => l_allocation_method,
	    l_demand_qty              => l_demand_qty,
	    l_demand_qty2             => l_demand_qty2,
	    l_demand_atr_qty          => l_demand_atr_qty,
	    l_xdocked_wdd_index	      => l_xdocked_wdd_index,
	    l_supply_type_id          => l_supply_type_id,
	    x_return_status           => x_return_status,
	    x_msg_count               => x_msg_count,
	    x_msg_data                => x_msg_data,
	    x_error_code              => l_error_code
	    );

	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - Error returned from Crossdock_WDD API: '
			   || x_return_status);
	    END IF;
	    --RAISE fnd_api.g_exc_error;
	    -- If an exception occurs while modifying a database record, rollback the changes
	    -- and just go to the next WDD record or reservation to crossdock.
	    ROLLBACK TO Reserved_WDD_sp;
	    -- We need to also rollback changes done to local PLSQL data structures
	    IF (l_xdocked_wdd_index IS NOT NULL) THEN
	       l_detail_info_tab.DELETE(l_xdocked_wdd_index);
	    END IF;
	    -- Process the next existing reserved WDD.
	    GOTO next_reserved_wdd;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - Successfully crossdocked/split the WDD record');
	    END IF;
	 END IF;
	 l_progress := '270';


	 -- Crossdock the RSV record, splitting it if necessary.
	 -- Do not modify the reservation if supply is of type WIP.
	 IF (l_debug = 1) THEN
	    print_debug('2.4 - Call the Crossdock_RSV API to crossdock/split the RSV');
	 END IF;
	 Crossdock_RSV
	   (p_log_prefix              => '2.4 - ',
	    p_crossdock_type          => G_CRT_TYPE_OPP,
	    l_debug                   => l_debug,
	    l_inventory_item_id       => l_inventory_item_id,
	    l_rsv_txn_qty             => l_rsv_txn_qty,
	    l_atd_qty                 => l_atd_qty,
	    l_atd_rsv_qty             => l_atd_rsv_qty,
	    l_atd_rsv_qty2            => l_atd_rsv_qty2,
	    l_atd_prim_qty            => l_atd_prim_qty,
	    l_supply_uom_code         => l_supply_uom_code,
	    l_rsv_uom_code            => l_rsv_uom_code,
	    l_rsv_uom_code2           => l_rsv_uom_code2,
	    l_primary_uom_code        => l_primary_uom_code,
	    l_conversion_rate         => l_conversion_rate,
	    l_conversion_precision    => l_conversion_precision,
	    l_original_rsv_rec        => l_original_rsv_rec,
	    l_rsv_id                  => l_rsv_id,
	    l_to_rsv_rec              => l_to_rsv_rec,
	    l_split_wdd_id            => l_split_wdd_id,
	    l_crossdock_criteria_id   => l_crossdock_criteria_id,
	    l_demand_expected_time    => l_demand_expected_time,
	    l_supply_expected_time    => l_supply_expected_time,
	    l_original_serial_number  => l_original_serial_number,
	    l_split_rsv_id            => l_split_rsv_id,
	    l_rsv_qty                 => l_rsv_qty,
	    l_rsv_qty2                => l_rsv_qty2,
	    l_to_serial_number	      => l_to_serial_number,
	    l_supply_type_id          => l_supply_type_id,
	    x_return_status           => x_return_status,
	    x_msg_count               => x_msg_count,
	    x_msg_data                => x_msg_data,
	    x_error_code              => l_error_code
	   );

	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - Error returned from Crossdock_RSV API: '
			   || x_return_status);
	    END IF;
	    --RAISE fnd_api.g_exc_error;
	    -- If an exception occurs while modifying a database record, rollback the changes
	    -- and just go to the next WDD record or reservation to crossdock.
	    ROLLBACK TO Reserved_WDD_sp;
	    -- We need to also rollback changes done to local PLSQL data structures
	    IF (l_xdocked_wdd_index IS NOT NULL) THEN
	       l_detail_info_tab.DELETE(l_xdocked_wdd_index);
	    END IF;
	    -- Process the next existing reserved WDD.
	    GOTO next_reserved_wdd;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - Successfully crossdocked/split the RSV record');
	    END IF;
	 END IF;
	 l_progress := '280';


	 -- Crossdock the MOL record, splitting it if necessary
	 IF (l_debug = 1) THEN
	    print_debug('2.4 - Call the Crossdock_MOL API to crossdock/split the MOL');
	 END IF;
	 Crossdock_MOL
	   (p_log_prefix              => '2.4 - ',
	    p_crossdock_type          => G_CRT_TYPE_OPP,
	    l_debug                   => l_debug,
	    l_inventory_item_id       => l_inventory_item_id,
	    l_mol_qty                 => l_mol_qty,
	    l_mol_qty2                => l_mol_qty2,
	    l_atd_qty                 => l_atd_qty,
	    l_atd_mol_qty2            => l_atd_mol_qty2,
	    l_supply_uom_code         => l_supply_uom_code,
	    l_mol_uom_code2           => l_mol_uom_code2,
	    l_conversion_rate         => l_conversion_rate,
	    l_conversion_precision    => l_conversion_precision,
	    l_mol_prim_qty            => l_mol_prim_qty,
	    l_atd_prim_qty            => l_atd_prim_qty,
	    l_split_wdd_id            => l_split_wdd_id,
	    l_mol_header_id           => l_mol_header_id,
	    l_mol_line_id             => l_mol_line_id,
	    l_supply_atr_qty          => l_supply_atr_qty,
	    l_demand_type_id          => l_demand_type_id,
	    l_wip_entity_id           => l_wip_entity_id,
	    l_operation_seq_num       => l_operation_seq_num,
	    l_repetitive_schedule_id  => l_repetitive_schedule_id,
	    l_wip_supply_type         => l_wip_supply_type,
	    l_xdocked_wdd_index	      => l_xdocked_wdd_index,
	    l_detail_info_tab         => l_detail_info_tab,
	    l_wdd_index               => l_dummy_wdd_index,
	    l_split_wdd_index         => l_split_wdd_index,
	    p_wsh_release_table       => l_wsh_release_table,
	    l_supply_type_id          => l_supply_type_id,
	    x_return_status           => x_return_status,
	    x_msg_count               => x_msg_count,
	    x_msg_data                => x_msg_data,
	   x_error_code              => l_error_code,
	   l_criterion_type          => G_CRT_TYPE_OPP
	   );

	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - Error returned from Crossdock_MOL API: '
			   || x_return_status);
	    END IF;
	    --RAISE fnd_api.g_exc_error;
	    -- If an exception occurs while modifying a database record, rollback the changes
	    -- and just go to the next WDD record or reservation to crossdock.
	    ROLLBACK TO Reserved_WDD_sp;
	    -- We need to also rollback changes done to local PLSQL data structures
	    IF (l_xdocked_wdd_index IS NOT NULL) THEN
	       l_detail_info_tab.DELETE(l_xdocked_wdd_index);
	    END IF;
	    -- Process the next existing reserved WDD.
	    GOTO next_reserved_wdd;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('2.4 - Successfully crossdocked/split the MOL record');
	    END IF;
	 END IF;
	 l_progress := '290';


	 -- Exit out of loop if the MOL supply has been fully crossdocked or the
	 -- reservation has been fully consumed.
	 IF (l_mol_qty = 0 OR l_rsv_qty = 0) THEN
	    EXIT;
	 END IF;

	 <<next_reserved_wdd>>
	 EXIT WHEN l_wdd_index = l_reserved_wdd_lines_tb.LAST;
	 l_wdd_index := l_reserved_wdd_lines_tb.NEXT(l_wdd_index);
      END LOOP; -- End looping through WDD lines in l_existing_rsvs_tb

      -- Exit out of existing reservations loop if the MOL supply has been fully crossdocked.
      -- There is no need to consider anymore existing reservations.
      IF (l_mol_qty = 0) THEN
	 EXIT;
      END IF;

      <<next_reservation>>
      EXIT WHEN l_rsv_index = l_existing_rsvs_tb.LAST;
      l_rsv_index := l_existing_rsvs_tb.NEXT(l_rsv_index);
   END LOOP; -- End looping through existing reservations
   l_progress := '300';

   <<after_existing_rsvs>>
   IF (l_debug = 1) THEN
      print_debug('2.5 - Finished processing existing reservations');
      print_debug('2.5 - Quantity left on MOL: ' || l_mol_qty || ' ' || l_supply_uom_code);
   END IF;

   -- 2.5 - If quantity still remains on the MOL to be crossdocked, see how much reservable
   --       quantity on the supply is actually available for crossdocking.
   -- {{
   -- Test for a supply MOL being fully crossdocked by existing reservations.
   -- Further crossdock processing should not occur. }}
   IF (l_mol_qty = 0) THEN
      GOTO end_crossdock;
   END IF;

   IF (l_debug = 1) THEN
      print_debug('2.5 - Calculate the ATR qty on the MOL supply line for crossdocking');
   END IF;
   -- {{
   -- Test getting the available to reserve quantity for the MOL supply for
   -- type RCV as well as WIP. }}
   IF (l_supply_type_id = 27) THEN
      -- RCV MOL
      INV_RESERVATION_AVAIL_PVT.Available_supply_to_reserve
	(p_api_version_number         => 1.0,
	 p_init_msg_lst               => fnd_api.g_false,
	 x_return_status              => x_return_status,
	 x_msg_count                  => x_msg_count,
	 x_msg_data                   => x_msg_data,
	 p_organization_id            => l_organization_id,
	 p_item_id                    => l_inventory_item_id,
	 p_supply_source_type_id      => l_supply_type_id,
	 p_supply_source_header_id    => l_supply_header_id,
	 p_supply_source_line_id      => l_supply_line_id,
	 p_supply_source_line_detail  => l_supply_line_detail_id,
	 p_project_id		      => l_mol_rec.project_id,
	 p_task_id		      => l_mol_rec.task_id,
	 x_qty_available_to_reserve   => l_supply_atr_prim_qty,
	 x_qty_available              => l_supply_available_qty);
    ELSIF (l_wip_entity_type = 1) THEN
      -- WIP Discrete Job MOL
      INV_RESERVATION_AVAIL_PVT.Available_supply_to_reserve
	(p_api_version_number         => 1.0,
	 p_init_msg_lst               => fnd_api.g_false,
	 x_return_status              => x_return_status,
	 x_msg_count                  => x_msg_count,
	 x_msg_data                   => x_msg_data,
	 p_organization_id            => l_organization_id,
	 p_item_id                    => l_inventory_item_id,
	 p_supply_source_type_id      => l_supply_type_id,
	 p_supply_source_header_id    => l_supply_header_id,
	 p_supply_source_line_id      => l_supply_line_id,
	 p_supply_source_line_detail  => l_supply_line_detail_id,
	 p_project_id		      => l_mol_rec.project_id,
	 p_task_id		      => l_mol_rec.task_id,
	 x_qty_available_to_reserve   => l_supply_atr_prim_qty,
	 x_qty_available              => l_supply_available_qty);
    ELSE -- l_wip_entity_type = 4
      -- WIP Flow Job MOL
      -- The full quantity on the MOL is available for crossdocking since
      -- you cannot create reservations against WIP Flow jobs as supply in R12.
      l_supply_atr_prim_qty := l_mol_prim_qty;
   END IF;

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (l_debug = 1) THEN
	 print_debug('2.5 - Error returned from available_supply_to_reserve API: '
		     || x_return_status);
      END IF;
      GOTO end_crossdock;
      --RAISE fnd_api.g_exc_error;
   END IF;

   -- The ATR qty returned is for all of receiving. Since we are working on a specific
   -- MOL supply line, we need to use a LEAST to get the min qty value.
   -- If the MOL is for WIP, the ATR qty is for all of the lines for the same WIP job.
   l_supply_atr_prim_qty := LEAST(l_mol_prim_qty, l_supply_atr_prim_qty);

   IF (l_debug = 1) THEN
      print_debug('2.5 - Available qty to reserve (primary) for supply: ' ||
		  l_supply_atr_prim_qty || ' ' || l_primary_uom_code);
   END IF;
   l_progress := '360';

   -- Check how much quantity is available to be crossdocked.
   -- {{
   -- Test for case where the MOL supply, after considering existing reservations, does not
   -- have any reservable quantity.  This line cannot be crossdocked and we should end
   -- crossdocking logic. }}
   IF (l_supply_atr_prim_qty <= 0) THEN
      GOTO end_crossdock;
    ELSE
      -- Convert the ATR primary quantity to the UOM on the MOL supply line
      l_conversion_rate := get_conversion_rate(l_inventory_item_id,
					       l_primary_uom_code, l_supply_uom_code);
      IF (l_conversion_rate < 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('2.5 - Error while obtaining Primary UOM conversion rate for WDD');
	 END IF;
	 GOTO end_crossdock;
      END IF;
      -- Round the converted quantity to the standard precision
      l_supply_atr_qty := ROUND(l_conversion_rate * l_supply_atr_prim_qty, l_conversion_precision);
      IF (l_debug = 1) THEN
	 print_debug('2.5 - Available qty to reserve for supply: ' || l_supply_atr_qty ||
		     ' ' || l_supply_uom_code);
      END IF;
      l_progress := '370';

      -- Instead of splitting the MOL record here with the ATR quantity, just keep track
      -- of that qty and use it later on when determining the available to detail qty.
      -- In this way, we can minimize the amount of MOL splitting, doing it only when
      -- absolutely necessary.
   END IF;

   -- Section 3: Build the set of available demand lines for the MOL supply
   -- 3.1 - For each available demand source type for the crossdock criteria,
   --       retrieve the available demand lines.
   -- 3.2 - For each demand line retrieved, determine the expected ship time.
   --       If the demand line does not lie within the crossdock window, remove it
   --       from the local PLSQL tables prior to insertion into the global temp table.
   -- 3.3 - Insert the available crossdockable demand lines into the global temp table.
   -- 3.4 - Retrieve all of the demand lines inserted into the global temp table and
   --       store it in the shopping basket table.  If prioritize documents, order this
   --       by the source type.
   -- 3.5 - Sort the demand lines in the shopping basket table based on the crossdocking
   --       goals.

   -- 3.1 - For each available demand source type for the crossdock criteria,
   --       retrieve the available demand lines.
   -- {{
   -- Test for different demand source types for opportunistic crossdocking.  Make sure
   -- only the valid ones are retrieved, i.e. SO, IO (both scheduled and backordered) and
   -- WIP backordered component demands. }}
   IF (l_debug = 1) THEN
      print_debug('3.1 - Query and cache the available demand source types for crossdocking');
   END IF;
   BEGIN
      OPEN demand_src_types_cursor;
      FETCH demand_src_types_cursor BULK COLLECT INTO l_demand_src_types_tb;
      CLOSE demand_src_types_cursor;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('3.1 - Exception retrieving the eligible demand source types');
	 END IF;
	 GOTO end_crossdock;
   END;
   IF (l_debug = 1) THEN
      print_debug('3.1 - Successfully retrieved ' || l_demand_src_types_tb.COUNT ||
		  ' eligible demand source types');
   END IF;

   -- Set a savepoint in case an error occurs while inserting demand line records
   -- into the global temp table.
   SAVEPOINT Demand_Lines_sp;

   FOR i IN 1 .. l_demand_src_types_tb.COUNT LOOP
      -- Store the current demand source code
      l_demand_src_code := l_demand_src_types_tb(i);

      -- Retrieve the available demand lines for the current demand source type,
      -- item,org, project and task.
      IF (l_debug = 1) THEN
	 IF (l_demand_src_code = G_OPP_DEM_SO_SCHED) THEN
	    print_debug('3.1 - Demand source type to retrieve: Scheduled Sales Order');
	  ELSIF (l_demand_src_code = G_OPP_DEM_SO_BKORD) THEN
	    print_debug('3.1 - Demand source type to retrieve: Backordered Sales Order');
	  ELSIF (l_demand_src_code = G_OPP_DEM_IO_SCHED) THEN
	    print_debug('3.1 - Demand source type to retrieve: Scheduled Internal Order');
	  ELSIF (l_demand_src_code = G_OPP_DEM_IO_BKORD) THEN
	    print_debug('3.1 - Demand source type to retrieve: Backordered Internal Order');
	  ELSIF (l_demand_src_code = G_OPP_DEM_WIP_BKORD) THEN
	    print_debug('3.1 - Demand source type to retrieve: Backordered WIP Component');
	  ELSE
	    print_debug('3.1 - Demand source type to retrieve: INVALID DEMAND!');
	 END IF;
      END IF;

      -- Initialize the tables we are BULK fetching into
      l_header_id_tb.DELETE;
      l_line_id_tb.DELETE;
      l_line_detail_id_tb.DELETE;
      l_dock_start_time_tb.DELETE;
      l_dock_mean_time_tb.DELETE;
      l_dock_end_time_tb.DELETE;
      l_expected_time_tb.DELETE;
      l_quantity_tb.DELETE;
      l_uom_code_tb.DELETE;
      l_secondary_quantity_tb.DELETE;
      l_secondary_uom_code_tb.DELETE;
      l_project_id_tb.DELETE;
      l_task_id_tb.DELETE;
      l_wip_supply_type_tb.DELETE;

      -- Bulk collect the demand line cursors into the PLSQL tables based on
      -- the current crossdock demand source type.
      -- {{
      -- Make sure that if cross project/task allocation is not allowed, only valid demand
      -- lines that match the project/task on the supply are retrieved. }}
      IF (l_demand_src_code = G_OPP_DEM_SO_SCHED) THEN
	 -- Sales Order (Scheduled)
	 BEGIN
	    OPEN SO_scheduled_lines(l_mol_rec.project_id, l_mol_rec.task_id);
	    FETCH SO_scheduled_lines BULK COLLECT INTO l_header_id_tb, l_line_id_tb,
	      l_line_detail_id_tb, l_quantity_tb, l_uom_code_tb,
	      l_secondary_quantity_tb, l_secondary_uom_code_tb, l_project_id_tb, l_task_id_tb,
	      l_wip_supply_type_tb;
	    CLOSE SO_scheduled_lines;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('3.1 - Could not retrieve the Scheduled SO demand lines');
	       END IF;
	       -- If we cannot retrieve the available demand lines, do not error out.
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Demand_Lines_sp;
	       GOTO end_crossdock;
	 END;
	 l_demand_type_id := 2;
       ELSIF (l_demand_src_code = G_OPP_DEM_SO_BKORD) THEN
	 -- Sales Order (Backordered)
	 BEGIN
	    OPEN SO_backordered_lines(l_mol_rec.project_id, l_mol_rec.task_id);
	    FETCH SO_backordered_lines BULK COLLECT INTO l_header_id_tb, l_line_id_tb,
	      l_line_detail_id_tb, l_quantity_tb, l_uom_code_tb,
	      l_secondary_quantity_tb, l_secondary_uom_code_tb, l_project_id_tb, l_task_id_tb,
	      l_wip_supply_type_tb;
	    CLOSE SO_backordered_lines;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('3.1 - Could not retrieve the Backordered SO demand lines');
	       END IF;
	       -- If we cannot retrieve the available demand lines, do not error out.
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Demand_Lines_sp;
	       GOTO end_crossdock;
	 END;
	 l_demand_type_id := 2;
       ELSIF (l_demand_src_code = G_OPP_DEM_IO_SCHED) THEN
	 -- Internal Order (Scheduled)
	 BEGIN
	    OPEN IO_scheduled_lines(l_mol_rec.project_id, l_mol_rec.task_id);
	    FETCH IO_scheduled_lines BULK COLLECT INTO l_header_id_tb, l_line_id_tb,
	      l_line_detail_id_tb, l_quantity_tb, l_uom_code_tb,
	      l_secondary_quantity_tb, l_secondary_uom_code_tb, l_project_id_tb, l_task_id_tb,
	      l_wip_supply_type_tb;
	    CLOSE IO_scheduled_lines;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('3.1 - Could not retrieve the Scheduled IO demand lines');
	       END IF;
	       -- If we cannot retrieve the available demand lines, do not error out.
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Demand_Lines_sp;
	       GOTO end_crossdock;
	 END;
	 l_demand_type_id := 8;
       ELSIF (l_demand_src_code = G_OPP_DEM_IO_BKORD) THEN
	 -- Internal Order (Backordered)
	 BEGIN
	    OPEN IO_backordered_lines(l_mol_rec.project_id, l_mol_rec.task_id);
	    FETCH IO_backordered_lines BULK COLLECT INTO l_header_id_tb, l_line_id_tb,
	      l_line_detail_id_tb, l_quantity_tb, l_uom_code_tb,
	      l_secondary_quantity_tb, l_secondary_uom_code_tb, l_project_id_tb, l_task_id_tb,
	      l_wip_supply_type_tb;
	    CLOSE IO_backordered_lines;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('3.1 - Could not retrieve the Backordered IO demand lines');
	       END IF;
	       -- If we cannot retrieve the available demand lines, do not error out.
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Demand_Lines_sp;
	       GOTO end_crossdock;
	 END;
	 l_demand_type_id := 8;
       ELSIF (l_demand_src_code = G_OPP_DEM_WIP_BKORD) THEN
	 -- WIP backordered component
	 BEGIN
	    OPEN wip_component_demand_lines(l_mol_rec.project_id, l_mol_rec.task_id,
					    l_xdock_start_time, l_xdock_end_time);
	    FETCH wip_component_demand_lines BULK COLLECT INTO l_header_id_tb, l_line_id_tb,
	      l_line_detail_id_tb, l_expected_time_tb, l_quantity_tb, l_uom_code_tb,
	      l_secondary_quantity_tb, l_secondary_uom_code_tb, l_project_id_tb, l_task_id_tb,
	      l_wip_supply_type_tb;
	    CLOSE wip_component_demand_lines;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('3.1 - Could not retrieve the WIP component demand lines');
	       END IF;
	       -- If we cannot retrieve the available demand lines, do not error out.
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Demand_Lines_sp;
	       GOTO end_crossdock;
	 END;
	 l_demand_type_id := 5;
       ELSE
	 -- Invalid demand type for crossdocking
	 -- Rollback any db changes that might have occurred (currently none).
	 ROLLBACK TO Demand_Lines_sp;
	 GOTO end_crossdock;
      END IF; -- End retrieving demand lines for different demand source types
      IF (l_debug = 1) THEN
	 IF (l_demand_src_code = G_OPP_DEM_SO_SCHED) THEN
	    print_debug('3.1 - Successfully retrieved ' || l_header_id_tb.COUNT ||
			' available line(s) for Scheduled Sales Order');
	  ELSIF (l_demand_src_code = G_OPP_DEM_SO_BKORD) THEN
	    print_debug('3.1 - Successfully retrieved ' || l_header_id_tb.COUNT ||
			' available line(s) for Backordered Sales Order');
	  ELSIF (l_demand_src_code = G_OPP_DEM_IO_SCHED) THEN
	    print_debug('3.1 - Successfully retrieved ' || l_header_id_tb.COUNT ||
			' available line(s) for Scheduled Internal Order');
	  ELSIF (l_demand_src_code = G_OPP_DEM_IO_BKORD) THEN
	    print_debug('3.1 - Successfully retrieved ' || l_header_id_tb.COUNT ||
			' available line(s) for Backordered Internal Order');
	  ELSIF (l_demand_src_code = G_OPP_DEM_WIP_BKORD) THEN
	    print_debug('3.1 - Successfully retrieved ' || l_header_id_tb.COUNT ||
			' available line(s) for Backordered WIP Component');
	 END IF;
      END IF;
      l_progress := '380';

      -- 3.2 - For each demand line retrieved, determine the expected ship time.
      --       If the demand line does not lie within the crossdock window, remove it
      --       from the local PLSQL tables prior to insertion into the global temp table.
      -- {{
      -- Make sure that demand lines with an expected time that lies outside of the crossdock
      -- window are removed from the PLSQL tables and not inserted into the global temp table. }}
      IF (l_debug = 1) THEN
 	 print_debug('3.2 - For each demand line retrieved, calculate the expected ship time');
      END IF;
      FOR j IN 1 .. l_header_id_tb.COUNT LOOP
	 -- Call the Get_Expected_Time API for OE demand.  WIP demand will already
	 -- have the date_required value retrieved.
	 IF (l_demand_type_id <> 5) THEN
	    Get_Expected_Time
	      (p_source_type_id           => l_demand_type_id,
	       p_source_header_id         => l_header_id_tb(j),
	       p_source_line_id           => l_line_id_tb(j),
	       p_source_line_detail_id    => l_line_detail_id_tb(j),
	       p_supply_or_demand         => G_SRC_TYPE_DEM,
	       p_crossdock_criterion_id   => l_crossdock_criteria_id,
	       x_return_status            => x_return_status,
	       x_msg_count                => x_msg_count,
	       x_msg_data                 => x_msg_data,
	       x_dock_start_time          => l_dock_start_time_tb(j),
	       x_dock_mean_time           => l_dock_mean_time_tb(j),
	       x_dock_end_time            => l_dock_end_time_tb(j),
	       x_expected_time            => l_expected_time_tb(j));

	    IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	       IF (l_debug = 1) THEN
		  print_debug('3.2 - Success returned from Get_Expected_Time API');
	       END IF;
	     ELSE
	       IF (l_debug = 1) THEN
		  print_debug('3.2 - Failure returned from Get_Expected_Time API');
	       END IF;
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Demand_Lines_sp;
	       GOTO end_crossdock;
	    END IF;
	  ELSE
	    -- WIP demand line.  Use the value retrieved in the l_expected_time_tb
	    -- and populate the same value for the dock appointment tables.
	    l_dock_start_time_tb(j) := l_expected_time_tb(j);
	    l_dock_mean_time_tb(j) := l_expected_time_tb(j);
	    l_dock_end_time_tb(j) := l_expected_time_tb(j);
	 END IF;

	 -- Check if the current demand line lies within the crossdock window.
	 -- Remove any demand lines that are not crossdockable from the PLSQL tables.
	 -- Do this only for non-WIP demand types.  WIP demand lines retrieved will already
	 -- be checked to lie within the crossdock window.  This logic is done within the
	 -- wip_component_demand_lines cursor.
	 -- Demand lines with an expected ship time in the past are always eligible for
	 -- opportunistic crossdocking.
	 IF (l_demand_type_id <> 5) THEN
	    IF (l_expected_time_tb(j) IS NOT NULL AND
		((l_dock_start_time_tb(j) IS NULL AND
		  g_crossdock_criteria_tb(l_crossdock_criteria_id).allow_demand_reschedule_flag = 1 AND
		  l_expected_time_tb(j) BETWEEN TRUNC(l_xdock_start_time) AND
		  TO_DATE(TO_CHAR(TRUNC(l_xdock_end_time), 'DD-MON-YYYY') ||
			  ' 23:59:59', 'DD-MON-YYYY HH24:MI:SS'))
		 OR (l_expected_time_tb(j) < SYSDATE)
		 OR (l_expected_time_tb(j) BETWEEN l_xdock_start_time AND l_xdock_end_time))) THEN
	       -- Demand is within the crossdock window
	       IF (l_debug = 1) THEN
		  print_debug('3.2 - Current demand line is valid for crossdocking');
	       END IF;
	     ELSE
	       -- Demand is not valid for crossdocking based on crossdock time window
	       -- so remove this line from the local tables prior to insertion.
	       IF (l_debug = 1) THEN
		  print_debug('3.2 - Current demand line is invalid for crossdocking so remove it');
	       END IF;
	       l_header_id_tb.DELETE(j);
	       l_line_id_tb.DELETE(j);
	       l_line_detail_id_tb.DELETE(j);
	       l_quantity_tb.DELETE(j);
	       l_uom_code_tb.DELETE(j);
	       l_secondary_quantity_tb.DELETE(j);
	       l_secondary_uom_code_tb.DELETE(j);
	       l_project_id_tb.DELETE(j);
	       l_task_id_tb.DELETE(j);
	       l_dock_start_time_tb.DELETE(j);
	       l_dock_mean_time_tb.DELETE(j);
	       l_dock_end_time_tb.DELETE(j);
	       l_expected_time_tb.DELETE(j);
	       l_wip_supply_type_tb.DELETE(j);
	    END IF;
	 END IF;

	 -- If we do not allow partial WIP crossdock, check if the demand is already tied
	 -- to a WIP supply.  If yes, then only WIP supply lines are valid for crossdocking.
	 -- Similarly, if the supply is a WIP supply, check that the demand is not already tied
	 -- to non-WIP and non-Inventory supplies.
	 -- Do this check only for non-WIP demand lines since those are the ones that will have
	 -- reservations created for the crossdock.  Only do this check if the demand line has not
	 -- already been removed above for not lying within the crossdock window.
	 IF (l_header_id_tb.EXISTS(j) AND l_demand_type_id <> 5) THEN
	    IF (WMS_XDOCK_CUSTOM_APIS_PUB.g_allow_partial_wip_xdock = 'N') THEN
	       IF ((l_supply_type_id <> 5 AND WMS_XDOCK_PEGGING_PUB.is_demand_tied_to_wip
		                             (p_organization_id    => l_organization_id,
					      p_inventory_item_id  => l_inventory_item_id,
					      p_demand_type_id     => l_demand_type_id,
					      p_demand_header_id   => l_header_id_tb(j),
					      p_demand_line_id     => l_line_id_tb(j)) = 'Y') OR
		   (l_supply_type_id = 5 AND WMS_XDOCK_PEGGING_PUB.is_demand_tied_to_non_wip
		                             (p_organization_id    => l_organization_id,
					      p_inventory_item_id  => l_inventory_item_id,
					      p_demand_type_id     => l_demand_type_id,
					      p_demand_header_id   => l_header_id_tb(j),
					      p_demand_line_id     => l_line_id_tb(j)) = 'Y')) THEN
		  IF (l_debug = 1) THEN
		     print_debug('3.2 - Demand cannot be crossdocked, partial WIP xdock is not allowed');
		  END IF;
		  l_header_id_tb.DELETE(j);
		  l_line_id_tb.DELETE(j);
		  l_line_detail_id_tb.DELETE(j);
		  l_quantity_tb.DELETE(j);
		  l_uom_code_tb.DELETE(j);
		  l_secondary_quantity_tb.DELETE(j);
		  l_secondary_uom_code_tb.DELETE(j);
		  l_project_id_tb.DELETE(j);
		  l_task_id_tb.DELETE(j);
		  l_dock_start_time_tb.DELETE(j);
		  l_dock_mean_time_tb.DELETE(j);
		  l_dock_end_time_tb.DELETE(j);
		  l_expected_time_tb.DELETE(j);
		  l_wip_supply_type_tb.DELETE(j);
	       END IF;
	    END IF;
	 END IF;

	 -- If the supply MOL is WIP, then there could be a specific OE demand that we
	 -- can ONLY crossdock to.  If that is the case, do not insert any other demand lines
	 -- into the xdock pegging temp table.  Only do this check if the demand line has not
	 -- already been removed above for not lying within the crossdock window or being part
	 -- of a partial WIP xdock.
	 IF (l_header_id_tb.EXISTS(j) AND
	     l_wip_entity_type IS NOT NULL AND l_wip_demand_header_id IS NOT NULL) THEN
	    IF (l_demand_type_id <> l_wip_demand_type_id OR
		l_header_id_tb(j) <> l_wip_demand_header_id OR
		l_line_id_tb(j) <> l_wip_demand_line_id) THEN
	       -- Demand is not valid for crossdocking due to WIP specified OE demand restriction.
	       -- So remove this line from the local tables prior to insertion.
	       IF (l_debug = 1) THEN
		  print_debug('3.2 - Current demand line does not match WIP OE demand so remove it');
	       END IF;
	       l_header_id_tb.DELETE(j);
	       l_line_id_tb.DELETE(j);
	       l_line_detail_id_tb.DELETE(j);
	       l_quantity_tb.DELETE(j);
	       l_uom_code_tb.DELETE(j);
	       l_secondary_quantity_tb.DELETE(j);
	       l_secondary_uom_code_tb.DELETE(j);
	       l_project_id_tb.DELETE(j);
	       l_task_id_tb.DELETE(j);
	       l_dock_start_time_tb.DELETE(j);
	       l_dock_mean_time_tb.DELETE(j);
	       l_dock_end_time_tb.DELETE(j);
	       l_expected_time_tb.DELETE(j);
	       l_wip_supply_type_tb.DELETE(j);
	    END IF;
	 END IF;

      END LOOP; -- End looping through demand lines retrieved
      IF (l_debug = 1) THEN
	 print_debug('3.2 - Finished calculating expected time for all demand lines');
      END IF;
      l_progress := '390';

      -- 3.3 - Insert the available crossdockable demand lines into the global temp table.
      -- {{
      -- Make sure the valid crossdockable demand lines are properly inserted into the
      -- global temp table. }}
      IF (l_debug = 1) THEN
	 print_debug('3.3 - Insert ' || l_header_id_tb.COUNT ||
		     ' crossdockable demand lines into the global temp table');
      END IF;
      BEGIN
	 FORALL k IN INDICES OF l_header_id_tb
	   INSERT INTO wms_xdock_pegging_gtmp
	   (inventory_item_id,
	    xdock_source_code,
	    source_type_id,
	    source_header_id,
	    source_line_id,
	    source_line_detail_id,
	    dock_start_time,
	    dock_mean_time,
	    dock_end_time,
	    expected_time,
	    quantity,
	    uom_code,
	    secondary_quantity,
	    secondary_uom_code,
	    project_id,
	    task_id,
	    wip_supply_type
	    )
	   VALUES
	   (l_inventory_item_id,
	    l_demand_src_code,
	    l_demand_type_id,
	    l_header_id_tb(k),
	    l_line_id_tb(k),
	    l_line_detail_id_tb(k),
	    l_dock_start_time_tb(k),
	    l_dock_mean_time_tb(k),
	    l_dock_end_time_tb(k),
	    l_expected_time_tb(k),
	    l_quantity_tb(k),
	    l_uom_code_tb(k),
	    l_secondary_quantity_tb(k),
	    l_secondary_uom_code_tb(k),
	    l_project_id_tb(k),
	    l_task_id_tb(k),
	    l_wip_supply_type_tb(k)
	    );
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('3.3 - Error inserting available demand lines into temp table');
	    END IF;
	    -- If an exception occurs while inserting demand line records,
	    -- rollback the changes and stop crossdock processing.
	    ROLLBACK TO Demand_Lines_sp;
	    GOTO end_crossdock;
      END;
      IF (l_debug = 1) THEN
	 print_debug('3.3 - Successfully inserted ' || l_header_id_tb.COUNT ||
		     ' crossdockable demand lines into temp table');
      END IF;
      l_progress := '400';

      -- Clear the PLSQL tables used once the data is inserted into the global temp table
      IF (l_header_id_tb.COUNT > 0) THEN
	 l_header_id_tb.DELETE;
	 l_line_id_tb.DELETE;
	 l_line_detail_id_tb.DELETE;
	 l_dock_start_time_tb.DELETE;
	 l_dock_mean_time_tb.DELETE;
	 l_dock_end_time_tb.DELETE;
	 l_expected_time_tb.DELETE;
	 l_quantity_tb.DELETE;
	 l_uom_code_tb.DELETE;
	 l_secondary_quantity_tb.DELETE;
	 l_secondary_uom_code_tb.DELETE;
	 l_project_id_tb.DELETE;
	 l_task_id_tb.DELETE;
	 l_wip_supply_type_tb.DELETE;
      END IF;
      l_progress := '410';

   END LOOP; -- End looping through eligible demand source types

   -- 3.4 - Retrieve all of the demand lines inserted into the global temp table and
   --       store it in the shopping basket table.  If prioritize documents, order this
   --       by the source type.
   -- {{
   -- Make sure the demand lines retrieved are sorted in order of document priority if
   -- necessary. }}
   IF (l_debug = 1) THEN
      print_debug('3.4 - Retrieve all of the demand lines that are valid for crossdocking');
   END IF;

   -- Iniitialize the shopping basket table which will store the valid supply lines
   -- for crossdocking to the current demand line.
   l_shopping_basket_tb.DELETE;

   -- Initialize the demand document priority variables
   l_so_sched_priority := 99;
   l_so_back_priority := 99;
   l_io_sched_priority := 99;
   l_io_back_priority := 99;
   l_wip_priority := 99;

   -- Get the valid demand source types to retrieve.
   -- The demand source types are cached in the order of the document priority already.
   -- Just use the same index value for the document priority variable.
   -- Do this only if we need to prioritize documents for the crossdock criteria
   IF (g_crossdock_criteria_tb(l_crossdock_criteria_id).prioritize_documents_flag = 1) THEN
      FOR i IN 1 .. l_demand_src_types_tb.COUNT LOOP
	 IF (l_demand_src_types_tb(i) = G_OPP_DEM_SO_SCHED) THEN
	    l_so_sched_priority := i;
	  ELSIF (l_demand_src_types_tb(i) = G_OPP_DEM_SO_BKORD) THEN
	    l_so_back_priority := i;
	  ELSIF (l_demand_src_types_tb(i) = G_OPP_DEM_IO_SCHED) THEN
	    l_io_sched_priority := i;
	  ELSIF (l_demand_src_types_tb(i) = G_OPP_DEM_IO_BKORD) THEN
	    l_io_back_priority := i;
	  ELSIF (l_demand_src_types_tb(i) = G_OPP_DEM_WIP_BKORD) THEN
	    l_wip_priority := i;
	 END IF;
      END LOOP;
   END IF;

   -- Now get the valid demand lines for crossdocking and store it in the
   -- shopping basket table.  All of the demand lines stored in the global temp table
   -- should already match the project/task of the supply (if necessary).  They should
   -- also lie within the crossdock window.  We are just sorting them basically here.
   -- {{
   -- Make sure the demand lines are retrieved properly into the shopping basket table.
   -- Do this both with and without enforcing document priority.  Also use various
   -- available demand types.  }}
   BEGIN
      OPEN get_demand_lines
	(p_crossdock_goal      => g_crossdock_criteria_tb(l_crossdock_criteria_id).crossdock_goal,
	 p_so_sched_priority   => l_so_sched_priority,
	 p_so_back_priority    => l_so_back_priority,
	 p_io_sched_priority   => l_io_sched_priority,
	 p_io_back_priority    => l_io_back_priority,
	 p_wip_priority        => l_wip_priority);
      FETCH get_demand_lines BULK COLLECT INTO l_shopping_basket_tb;
      CLOSE get_demand_lines;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    print_debug('3.4 - Could not retrieve the valid demand lines for available demand types');
	 END IF;
	 -- If we cannot retrieve the valid demand lines, do not error out.
	 -- Stop crossdock processing and exit out of the API.
	 GOTO end_crossdock;
   END;
   IF (l_debug = 1) THEN
      print_debug('3.4 - Successfully populated the shopping basket table with ' ||
		  l_shopping_basket_tb.COUNT || ' crossdockable demand lines');
   END IF;
   l_progress := '420';

   -- 3.5 - Sort the demand lines in the shopping basket table based on the crossdocking
   --       goals.
   -- For crossdock goals of Minimize Wait and Maximize Crossdock, the demand lines in the
   -- shopping basket have already been sorted.
   -- {{
   -- Test out the custom crossdock goal method of sorting the shopping basket lines.
   -- The not implemented stub version should just pass back the inputted shopping basket
   -- table without sorting them.  }}
   IF (g_crossdock_criteria_tb(l_crossdock_criteria_id).crossdock_goal = G_CUSTOM_GOAL) THEN
      -- For each record in the shopping basket table, call the available to reserve API
      -- to determine how much quantity from each demand line is available for crossdocking.
      -- We need to do this since the custom logic might decide which demand lines to consume
      -- based on the reservable quantity (e.g. Best Fit SPQ type of logic).
      IF (l_debug = 1) THEN
	 print_debug('3.5 - Use custom logic to sort the demand lines');
      END IF;

      FOR i IN 1 .. l_shopping_basket_tb.COUNT LOOP

	 -- Call the Available_demand_to_reserve API for OE demand.
	 -- The quantity_backordered on the WIP demand is the same as
	 -- the ATR qty so it is fully reserveable.
	 IF (l_shopping_basket_tb(i).source_type_id <> 5) THEN
	    IF (l_debug = 1) THEN
	       print_debug('3.5 - Call the Available_demand_to_reserve API');
	    END IF;
	    INV_RESERVATION_AVAIL_PVT.Available_demand_to_reserve
	      (p_api_version_number         => 1.0,
	       p_init_msg_lst               => fnd_api.g_false,
	       x_return_status              => x_return_status,
	       x_msg_count                  => x_msg_count,
	       x_msg_data                   => x_msg_data,
	       p_primary_uom_code           => l_primary_uom_code,
	       p_demand_source_type_id	    => l_shopping_basket_tb(i).source_type_id,
	       p_demand_source_header_id    => l_shopping_basket_tb(i).source_header_id,
	       p_demand_source_line_id	    => l_shopping_basket_tb(i).source_line_id,
	       p_demand_source_line_detail  => l_shopping_basket_tb(i).source_line_detail_id,
	       p_project_id	            => l_shopping_basket_tb(i).project_id,
	       p_task_id	            => l_shopping_basket_tb(i).task_id,
	       x_qty_available_to_reserve   => l_demand_atr_prim_qty,
	       x_qty_available              => l_demand_available_qty);

	    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	       IF (l_debug = 1) THEN
		  print_debug('3.5 - Error returned from available_demand_to_reserve API: '
			      || x_return_status);
	       END IF;
	       -- Instead of erroring out and stopping crossdock processing,
	       -- just delete the demand line from the shopping basket table.  Shopping basket
	       -- table can therefore be a sparsely populated table after running custom logic.
	       l_shopping_basket_tb.DELETE(i);
	       GOTO next_custom_demand;
	    END IF;
	  ELSE
	    -- WIP backordered component demand lines always store quantity in the primary UOM
	    l_demand_atr_prim_qty := l_shopping_basket_tb(i).quantity;
	 END IF;

	 -- Convert the ATR primary quantity to the UOM on the demand line
	 l_demand_uom_code := l_shopping_basket_tb(i).uom_code;
	 l_conversion_rate := get_conversion_rate(l_inventory_item_id,
						  l_primary_uom_code, l_demand_uom_code);
	 IF (l_conversion_rate < 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug('3.5 - Error while obtaining Primary UOM conversion rate for demand line');
	    END IF;
	    -- Instead of erroring out and stopping crossdock processing,
	    -- just delete the demand line from the shopping basket table.  Shopping basket
	    -- table can therefore be a sparsely populated table after running custom logic.
	    l_shopping_basket_tb.DELETE(i);
	    GOTO next_custom_demand;
	 END IF;
	 -- Round the converted quantity to the standard precision
	 l_demand_atr_qty := ROUND(l_conversion_rate * l_demand_atr_prim_qty, l_conversion_precision);
	 IF (l_debug = 1) THEN
	    print_debug('3.5 - Demand line ATR qty: ' || l_demand_atr_qty || ' ' ||
			l_demand_uom_code);
	 END IF;

	 -- Set the reservable_quantity field to be equal to the ATR quanitty for the
	 -- current demand line record in the shopping basket.
	 l_shopping_basket_tb(i).reservable_quantity := l_demand_atr_qty;

	 <<next_custom_demand>>
	 NULL; -- Need an executable statment for the branching label above
      END LOOP; -- End retrieving ATR quantity for all demand lines in shopping basket table
      -- At this stage, the shopping basket table will have the ATR quantity stamped on all of
      -- the records.  The table can be sparse so the custom logic to sort the shopping basket
      -- must keep this in mind.  This will be documented in the custom logic API.
      l_progress := '430';

      -- Call the Custom logic to sort the shopping basket table.
      -- If the API is not implemented, the lines will not be sorted at all.
      -- {{
      -- Test that invalid custom logic to sort demand lines is caught.  No sorting
      -- should be done if this is the case. }}
      IF (l_debug = 1) THEN
	 print_debug('3.5 - Call the Sort_Demand_Lines API');
      END IF;
      WMS_XDOCK_CUSTOM_APIS_PUB.Sort_Demand_Lines
	(p_move_order_line_id    => p_move_order_line_id,
	 p_prioritize_documents  => g_crossdock_criteria_tb(l_crossdock_criteria_id).prioritize_documents_flag,
	 p_shopping_basket_tb    => l_shopping_basket_tb,
	 x_return_status         => x_return_status,
	 x_msg_count             => x_msg_count,
	 x_msg_data              => x_msg_data,
	 x_api_is_implemented    => l_api_is_implemented,
	 x_sorted_order_tb       => l_sorted_order_tb);

      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('3.5 - Success returned from Sort_Demand_Lines API');
	 END IF;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('3.5 - Failure returned from Sort_Demand_Lines API');
	 END IF;
	 -- In case of exception, do not error out.  Just use whatever order the
	 -- demand lines are in when the shopping basket table was created.
	 l_sorted_order_tb.DELETE;
      END IF;
      l_progress := '440';

      IF (NOT l_api_is_implemented) THEN
	 IF (l_debug = 1) THEN
	    print_debug('3.5 - Custom API is NOT implemented even though Custom Goal is selected!');
	 END IF;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('3.5 - Custom API is implemented so custom sorting logic is used');
	 END IF;
      END IF;

      -- Validate that the output l_sorted_order_tb is not larger in size than
      -- the shopping basket table and that values exist in l_sorted_order_tb.
      IF (l_debug = 1) THEN
	 print_debug('3.5 - Rebuild the shopping basket table based on the sorting order returned');
      END IF;
      IF (l_sorted_order_tb.COUNT > l_shopping_basket_tb.COUNT OR
	  l_sorted_order_tb.COUNT = 0) THEN
	 -- Invalid condition from the custom logic API.
	 -- Do not sort the shopping basket table and just use the current order
	 -- the lines are in.
	 IF (l_debug = 1) THEN
	    print_debug('3.5 - Invalid output from Sort_Demand_Lines API');
	    print_debug('3.5 - Do not sort the demand lines in the shopping basket');
	 END IF;
       ELSE
	 -- Sort and rebuild the shopping basket table
	 l_index := l_sorted_order_tb.FIRST;
	 -- Initialize the indices used table and the temp shopping basket table
	 l_indices_used_tb.DELETE;
	 l_shopping_basket_temp_tb.DELETE;
	 LOOP
	    -- Make sure the current entry has not already been used.
	    -- Also make sure the index refered to in l_sorted_order_tb is a valid one
	    -- in the shopping basket table.
	    IF (l_indices_used_tb.EXISTS(l_sorted_order_tb(l_index)) OR
		NOT l_shopping_basket_tb.EXISTS(l_sorted_order_tb(l_index))) THEN
	       IF (l_debug = 1) THEN
		  print_debug('3.5 - Sorted order table is invalid so do not sort the demand lines');
	       END IF;
	       -- Clear the temp shopping basket table
	       l_shopping_basket_temp_tb.DELETE;
	       -- Exit out of the loop.  No sorting will be done.
	       GOTO invalid_sorting;
	    END IF;

	    -- Mark the current pointer index to the shopping basket table as used
	    l_indices_used_tb(l_sorted_order_tb(l_index)) := TRUE;

	    -- Add this entry to the temp shopping basket table.
	    l_shopping_basket_temp_tb(l_shopping_basket_temp_tb.COUNT + 1) :=
	      l_shopping_basket_tb(l_sorted_order_tb(l_index));

	    EXIT WHEN l_index = l_sorted_order_tb.LAST;
	    l_index := l_sorted_order_tb.NEXT(l_index);
	 END LOOP;

	 -- Set the shopping basket table to point to the new sorted one
	 l_shopping_basket_tb := l_shopping_basket_temp_tb;
	 l_shopping_basket_temp_tb.DELETE;
	 IF (l_debug = 1) THEN
	    print_debug('3.5 - Finished sorting and rebuilding the shopping basket table');
	 END IF;

	 -- In case of an invalid sorted order table, jump to this label below and
	 -- do not sort the shopping basket at all.
	 <<invalid_sorting>>
	   NULL; -- Need an executable statement for the above label to work
      END IF;
      l_progress := '450';

   END IF; -- End of crossdocking goal = CUSTOM

   -- Section 4: Consume the valid demand lines for crossdocking to the MOL supply
   -- 4.1 - Lock the demand line record.
   -- 4.2 - Call the available to reserve API to see how much quantity from the demand
   --       is valid for crossdocking.
   -- 4.3 - Crossdock the demand and supply line records.
   -- 4.4 - Create a crossdocked reservation tying the demand to the supply line.

   -- Check if there are valid demand lines found for crossdocking.
   IF (l_shopping_basket_tb.COUNT = 0) THEN
      IF (l_debug = 1) THEN
	 print_debug('4.1 - No valid demand lines for crossdocking were found');
      END IF;
      GOTO end_crossdock;
   END IF;

   -- Initialize the shopping basket demand lines index.  This should not be a NULL value.
   l_demand_index := NVL(l_shopping_basket_tb.FIRST, 1);

   -- Loop through the valid demand lines to crossdock the MOL supply
   LOOP
      -- Define a savepoint so if an exception occurs while updating database records such as
      -- WDD, RSV, or MOL, we need to rollback the changes and stop crossdock processing.
      -- Put this inside the demand lines loop so if one demand line is crossdocked successfully
      -- but another one errors out, we can still crossdock the first one.
      SAVEPOINT Crossdock_Demand_sp;

      -- Initialize the variable below used for updating crossdocked WDD records,
      -- in case we need to rollback the changes to local PLSQL data structures.
      l_xdocked_wdd_index := NULL;

      -- Retrieve needed values from the current demand line
      l_demand_type_id := l_shopping_basket_tb(l_demand_index).source_type_id;
      -- Since the demand type could be WIP or OE, use the same variable to store the
      -- header ID.  For OE demand lines, this will always refer to the MTL sales order
      -- header and not the OE header ID.  Currently there is no need to retrieve the
      -- OE header ID.
      l_demand_header_id := l_shopping_basket_tb(l_demand_index).source_header_id;
      l_demand_line_id := l_shopping_basket_tb(l_demand_index).source_line_id;
      l_demand_line_detail_id := l_shopping_basket_tb(l_demand_index).source_line_detail_id;
      l_demand_qty := l_shopping_basket_tb(l_demand_index).quantity;
      l_demand_uom_code := l_shopping_basket_tb(l_demand_index).uom_code;
      l_demand_qty2 := l_shopping_basket_tb(l_demand_index).secondary_quantity;
      l_demand_uom_code2 := l_shopping_basket_tb(l_demand_index).secondary_uom_code;
      l_demand_project_id := l_shopping_basket_tb(l_demand_index).project_id;
      l_demand_task_id := l_shopping_basket_tb(l_demand_index).task_id;
      l_demand_expected_time := l_shopping_basket_tb(l_demand_index).expected_time;
      -- Set the WIP related fields if the demand line is a WIP backordered component demand
      IF (l_demand_type_id = 5) THEN
	 l_wip_entity_id := l_demand_header_id;
	 l_operation_seq_num := l_demand_line_id;
	 l_repetitive_schedule_id := l_demand_line_detail_id;
	 l_wip_supply_type := l_shopping_basket_tb(l_demand_index).wip_supply_type;
       ELSE
	 l_wip_entity_id := NULL;
	 l_operation_seq_num := NULL;
	 l_repetitive_schedule_id := NULL;
	 l_wip_supply_type := NULL;
      END IF;

      IF (l_debug = 1) THEN
	 print_debug('4.1 - Current demand line to consider for crossdocking');
	 print_debug('4.1 - Demand Source Type ID: => ' || l_demand_type_id);
	 print_debug('4.1 - Demand Header ID: ======> ' || l_demand_header_id);
	 print_debug('4.1 - Demand Line ID: ========> ' || l_demand_line_id);
	 print_debug('4.1 - Demand Line Detail ID: => ' || l_demand_line_detail_id);
	 print_debug('4.1 - Demand Qty: ============> ' || l_demand_qty || ' ' || l_demand_uom_code);
	 print_debug('4.1 - Secondary Demand Qty: ==> ' || l_demand_qty2 || ' ' || l_demand_uom_code2);
	 print_debug('4.1 - Demand Project ID: =====> ' || l_demand_project_id);
	 print_debug('4.1 - Demand Task ID: ========> ' || l_demand_task_id);
	 print_debug('4.1 - Demand Expected Time: ==> ' ||
		     TO_CHAR(l_demand_expected_time, 'DD-MON-YYYY HH24:MI:SS'));
	 print_debug('4.1 - WIP Supply Type: =======> ' || l_wip_supply_type);
      END IF;

      -- For WIP Discrete Job MOLs, we only want to crossdock to the same
      -- OE demand at the Sales Order Line level (Not the WDD level).
      -- If the WIP Discrete job was completed for a specific Sales Order demand,
      -- then only the WDD records associated with that demand will be populated
      -- in the xdock temp table and the shopping basket table.  The condition below
      -- will thus always be met.

      -- If the Discrete job was NOT completed for a particular Sales Order,
      -- we will set the l_wip_demand variables to point the OE demand that the WIP
      -- MOL was first crossdocked to.  Thus afterwards, we will only crossdock to
      -- OE WDD demand lines that match the previously crossdocked OE demand.
      -- WIP demand will not need to do this check since we do not create reservations
      -- for those types of crossdock.
      IF (l_wip_entity_type = 1 AND l_wip_demand_header_id IS NOT NULL
	  AND l_demand_type_id <> 5) THEN
	 -- Make sure the current OE demand matches the one we are allowed to crossdock to.
	 IF (l_demand_type_id <> l_wip_demand_type_id OR
	     l_demand_header_id <> l_wip_demand_header_id OR
	     l_demand_line_id <> l_wip_demand_line_id) THEN
	    IF (l_debug = 1) THEN
	       print_debug('4.1 - Invalid OE demand to crossdock to for WIP Discrete supply');
	    END IF;
	    GOTO next_demand;
	 END IF;
      END IF;

      -- 4.1 - Lock the demand line record.
      -- {{
      -- If a demand line cannot be locked, make sure we skip it and do not error out.
      -- Just move on to the next available demand. }}
      IF (l_demand_type_id IN (2, 8)) THEN
	 -- OE WDD demand line
	 BEGIN
	    OPEN lock_wdd_record(l_demand_line_detail_id);
	    CLOSE lock_wdd_record;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('4.1 - Could not lock the WDD demand line record');
	       END IF;
	       -- If we cannot lock the supply line, do not error out.  Just go to the
	       -- next available demand and try to crossdock that.
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Crossdock_Demand_sp;
	       GOTO next_demand;
	 END;
       ELSIF (l_demand_type_id = 5) THEN
	 -- WIP Backordered Component Demand
	 BEGIN
	    OPEN lock_wip_record(l_demand_header_id, l_demand_line_id, l_demand_line_detail_id);
	    CLOSE lock_wip_record;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (l_debug = 1) THEN
		  print_debug('4.1 - Could not lock the WIP demand line record');
	       END IF;
	       -- If we cannot lock the demand line, do not error out.  Just go to the
	       -- next available demand and try to crossdock that.
	       -- Rollback any db changes that might have occurred (currently none).
	       ROLLBACK TO Crossdock_Demand_sp;
	       GOTO next_demand;
	 END;
       ELSE
	 -- Invalid demand for crossdocking.  Should not reach this condition.
	 -- Rollback any db changes that might have occurred (currently none).
	 ROLLBACK TO Crossdock_Demand_sp;
	 GOTO next_demand;
      END IF; -- End locking demand line from different source types

      IF (l_debug = 1) THEN
	 print_debug('4.1 - Successfully locked the demand line record');
      END IF;
      l_progress := '460';

      -- 4.2 - Call the available to reserve API to see how much quantity from the demand
      --       is valid for crossdocking.
      -- The quantity_backordered on the WIP demand is the same as
      -- the ATR qty so it is fully reserveable.
      IF (l_demand_type_id <> 5) THEN
	 IF (l_debug = 1) THEN
	    print_debug('4.2 - Call the Available_demand_to_reserve API');
	 END IF;
	 INV_RESERVATION_AVAIL_PVT.Available_demand_to_reserve
	   (p_api_version_number     	 => 1.0,
	    p_init_msg_lst             	 => fnd_api.g_false,
	    x_return_status            	 => x_return_status,
	    x_msg_count                	 => x_msg_count,
	    x_msg_data                 	 => x_msg_data,
	    p_primary_uom_code           => l_primary_uom_code,
	    p_demand_source_type_id	 => l_demand_type_id,
	    p_demand_source_header_id    => l_demand_header_id,
	    p_demand_source_line_id      => l_demand_line_id,
	    p_demand_source_line_detail  => l_demand_line_detail_id,
	    p_project_id	         => l_demand_project_id,
	    p_task_id		         => l_demand_task_id,
	    x_qty_available_to_reserve   => l_demand_atr_prim_qty,
	    x_qty_available              => l_demand_available_qty);

	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    IF (l_debug = 1) THEN
	       print_debug('4.2 - Error returned from available_demand_to_reserve API: '
			   || x_return_status);
	    END IF;
	    -- Rollback any db changes that might have occurred (currently none).
	    ROLLBACK TO Crossdock_Demand_sp;
	    GOTO next_demand;
	 END IF;
       ELSE
	 -- WIP backordered component demand lines always store quantity in the primary UOM
	 l_demand_atr_prim_qty := l_demand_qty;
      END IF;

      -- Convert the ATR primary quantity to the UOM on the demand line
      l_conversion_rate := get_conversion_rate(l_inventory_item_id,
					       l_primary_uom_code, l_demand_uom_code);
      IF (l_conversion_rate < 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('4.2 - Error while obtaining Primary UOM conversion rate for demand line');
	 END IF;
	 -- Rollback any db changes that might have occurred (currently none).
	 ROLLBACK TO Crossdock_Demand_sp;
	 GOTO next_demand;
      END IF;
      -- Round the converted quantity to the standard precision
      l_demand_atr_qty := ROUND(l_conversion_rate * l_demand_atr_prim_qty, l_conversion_precision);

      -- Set the reservable quantity field for the current demand line
      -- in the shopping basket table.
      l_shopping_basket_tb(l_demand_index).reservable_quantity := l_demand_atr_qty;

      IF (l_debug = 1) THEN
	 print_debug('4.2 - Demand line ATR qty: ' || l_demand_atr_qty || ' ' ||
		     l_demand_uom_code);
      END IF;
      -- If the current demand line has no reservable quantity,
      -- skip it and go to the next available demand line.
      -- {{
      -- Test for an available demand line for crossdocking that has no available quantity
      -- to reserve.  This line is already satisfied by another existing reservation. }}
      IF (l_demand_atr_qty <= 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('4.2 - Demand ATR qty <= 0 so skip to next available demand');
	 END IF;
	 -- Rollback any db changes that might have occurred (currently none).
	 ROLLBACK TO Crossdock_Demand_sp;
	 GOTO next_demand;
      END IF;
      l_progress := '470';

      -- 4.3 - Crossdock the demand and supply line records.
      IF (l_debug = 1) THEN
	 print_debug('4.3 - Crossdock the demand and supply line records');
      END IF;

      -- Convert the WDD ATR qty to the UOM on the MOL supply line.  This value should not be zero
      -- if we have reached this point.  Also convert the WDD qty to the UOM on the supply line.
      -- Since they use the same conversion rate, we just need to retrieve that value once.
      -- This is required so we know if the WDD line needs to be split or not.  That would depend
      -- on the WDD qty, not the WDD ATR qty.
      l_conversion_rate := get_conversion_rate(l_inventory_item_id,
					       l_demand_uom_code, l_supply_uom_code);
      IF (l_conversion_rate < 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('4.3 - Error while obtaining UOM conversion rate for WDD/WIP qty');
	 END IF;
	 -- Rollback any db changes that might have occurred (currently none).
	 ROLLBACK TO Crossdock_Demand_sp;
	 GOTO next_demand;
      END IF;
      -- Round the converted quantity to the standard precision
      l_wdd_atr_txn_qty := ROUND(l_conversion_rate * l_demand_atr_qty, l_conversion_precision);
      l_wdd_txn_qty := ROUND(l_conversion_rate * l_demand_qty, l_conversion_precision);
      IF (l_debug = 1) THEN
	 print_debug('4.3 - WDD/WIP ATR txn qty: => ' || l_wdd_atr_txn_qty || ' ' || l_supply_uom_code);
	 print_debug('4.3 - WDD/WIP txn qty: =====> ' || l_wdd_txn_qty || ' ' || l_supply_uom_code);
      END IF;
      l_progress := '480';

      -- Calculate the Available to Detail quantity.
      -- {{
      -- Test that the available to detail quantity is calculated properly,
      -- i.e. is lower than WDD/WIP ATR qty and supply line qty, and is an integer value if
      -- UOM integrity = 'Y'. }}
      IF (g_crossdock_criteria_tb(l_crossdock_criteria_id).uom_integrity_flag = 1) THEN
	 -- UOM Integrity is 'Yes'
	 l_atd_qty := LEAST(FLOOR(l_wdd_atr_txn_qty), FLOOR(l_supply_atr_qty));
       ELSE
	 -- UOM Integrity is 'No'
	 l_atd_qty := LEAST(l_wdd_atr_txn_qty, l_supply_atr_qty);
      END IF;
      IF (l_debug = 1) THEN
	 print_debug('4.3 - Available to detail qty: ' || l_atd_qty || ' ' ||
		     l_supply_uom_code);
      END IF;
      -- If the ATD qty is 0, then goto the next available demand line to crossdock.
      -- This is possible if the UOM integrity flag is 'Y' and the resultant quantities
      -- were floored to 0.
      -- {{
      -- Test for ATD qty = 0.  This can come about if UOM integrity is Yes and the
      -- demand line with available to reserve qty gets floored to 0. }}
      IF (l_atd_qty = 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('4.3 - ATD qty = 0 so skip to the next available demand');
	 END IF;
	 -- Rollback any db changes that might have occurred (currently none).
	 ROLLBACK TO Crossdock_Demand_sp;
	 GOTO next_demand;
      END IF;
      l_progress := '490';

      -- Convert l_atd_qty to the primary UOM
      l_conversion_rate := get_conversion_rate(l_inventory_item_id,
					       l_supply_uom_code, l_primary_uom_code);
      IF (l_conversion_rate < 0) THEN
	 IF (l_debug = 1) THEN
	    print_debug('4.3 - Error while obtaining primary UOM conversion rate for ATD qty');
	 END IF;
	 -- Rollback any db changes that might have occurred (currently none).
	 ROLLBACK TO Crossdock_Demand_sp;
	 GOTO next_demand;
      END IF;
      -- Convert l_atd_qty to the primary UOM
      -- Bug 5608611: Use quantity from demand document where possible
      IF (l_atd_qty = l_wdd_atr_txn_qty AND l_demand_uom_code = l_primary_uom_code) THEN
	 l_atd_prim_qty := l_demand_atr_qty;
      ELSE
	 -- Round the converted quantity to the standard precision
	 l_atd_prim_qty := ROUND(l_conversion_rate * l_atd_qty, l_conversion_precision);
      END IF;
      IF (l_debug = 1) THEN
	 print_debug('4.3 - ATD qty in primary UOM: => ' || l_atd_prim_qty || ' ' ||
		     l_primary_uom_code);
      END IF;
      l_progress := '500';

      -- Crossdock the WDD/WIP demand record
      IF (l_demand_type_id <> 5) THEN
	 -- Crossdock the WDD record, splitting it if necessary.
	 IF (l_debug = 1) THEN
	    print_debug('4.3 - Call the Crossdock_WDD API to crossdock/split the WDD');
	 END IF;
	 Crossdock_WDD
	   (p_log_prefix              => '4.3 - ',
	    p_crossdock_type          => G_CRT_TYPE_OPP,
	    p_batch_id                => l_batch_id,
	    p_wsh_release_table       => l_wsh_release_table,
	    p_trolin_delivery_ids     => l_trolin_delivery_ids,
	    p_del_detail_id           => l_del_detail_id,
	    l_wdd_index               => l_dummy_wdd_index,
	    l_debug                   => l_debug,
	    l_inventory_item_id       => l_inventory_item_id,
	    l_wdd_txn_qty             => l_wdd_txn_qty,
	    l_atd_qty                 => l_atd_qty,
	    l_atd_wdd_qty             => l_atd_wdd_qty,
	    l_atd_wdd_qty2            => l_atd_wdd_qty2,
	    l_supply_uom_code         => l_supply_uom_code,
	    l_demand_uom_code         => l_demand_uom_code,
	    l_demand_uom_code2        => l_demand_uom_code2,
	    l_conversion_rate         => l_conversion_rate,
	    l_conversion_precision    => l_conversion_precision,
	    l_demand_line_detail_id   => l_demand_line_detail_id,
	    l_index                   => l_index,
	    l_detail_id_tab           => l_detail_id_tab,
	    l_action_prms             => l_action_prms,
	    l_action_out_rec          => l_action_out_rec,
	    l_split_wdd_id            => l_split_wdd_id,
	    l_detail_info_tab         => l_detail_info_tab,
	    l_in_rec                  => l_in_rec,
	    l_out_rec                 => l_out_rec,
	    l_mol_line_id             => l_mol_line_id,
	    l_split_wdd_index         => l_split_wdd_index,
	    l_split_delivery_index    => l_split_delivery_index,
	    l_split_wdd_rel_rec       => l_split_wdd_rel_rec,
	    l_allocation_method       => l_allocation_method,
	    l_demand_qty              => l_demand_qty,
	    l_demand_qty2             => l_demand_qty2,
	    l_demand_atr_qty          => l_demand_atr_qty,
	    l_xdocked_wdd_index	      => l_xdocked_wdd_index,
	    l_supply_type_id          => l_supply_type_id,
	    x_return_status           => x_return_status,
	    x_msg_count               => x_msg_count,
	    x_msg_data                => x_msg_data,
	    x_error_code              => l_error_code
	   );

	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    IF (l_debug = 1) THEN
	       print_debug('4.3 - Error returned from Crossdock_WDD API: '
			   || x_return_status);
	    END IF;
	    --RAISE fnd_api.g_exc_error;
	    -- If an exception occurs while modifying a database record, rollback the changes
	    -- and just go to the next available demand to crossdock
	    ROLLBACK TO Crossdock_Demand_sp;
	    -- We need to also rollback changes done to local PLSQL data structures
	    IF (l_xdocked_wdd_index IS NOT NULL) THEN
	       l_detail_info_tab.DELETE(l_xdocked_wdd_index);
	    END IF;
	    GOTO next_demand;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('4.3 - Successfully crossdocked/split the WDD record');
	    END IF;
	 END IF;
	 l_progress := '510';

       ELSE
	 -- Crossdock the WIP demand record.
	 -- {{
	 -- Verify that the WIP API properly allocates the crossdocked material when
	 -- the demand is WIP. }}
	 IF (l_debug = 1) THEN
	    print_debug('4.3 - Call wip_picking_pub.allocate_material to crossdock the WIP demand');
	 END IF;
	 wip_picking_pub.allocate_material
	   (p_wip_entity_id              => l_wip_entity_id,
	    p_operation_seq_num          => l_operation_seq_num,
	    p_inventory_item_id          => l_inventory_item_id,
	    p_repetitive_schedule_id     => l_repetitive_schedule_id,
	    p_primary_quantity           => l_atd_prim_qty,
	    x_quantity_allocated         => l_wip_qty_allocated,
	    x_return_status              => x_return_status,
	    x_msg_data                   => x_msg_data
	    );

	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS OR l_wip_qty_allocated = 0) THEN
	    IF (l_debug = 1) THEN
	       print_debug('4.3 - Error returned from wip_picking_pub.allocate_material API: '
			   || x_return_status);
	    END IF;
	    --RAISE fnd_api.g_exc_error;
	    -- If an exception occurs while modifying a database record, rollback the changes
	    -- and just go to the next available demand to crossdock
	    ROLLBACK TO Crossdock_Demand_sp;
	    GOTO next_demand;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('4.3 - Successfully crossdocked the WIP demand');
	    END IF;
	 END IF;
	 l_progress := '515';
      END IF;


      -- Crossdock the MOL supply line, splitting it if necessary
      IF (l_debug = 1) THEN
	 print_debug('4.3 - Call the Crossdock_MOL API to crossdock/split the MOL');
      END IF;
      Crossdock_MOL
	(p_log_prefix              => '4.3 - ',
	 p_crossdock_type          => G_CRT_TYPE_OPP,
	 l_debug                   => l_debug,
	 l_inventory_item_id       => l_inventory_item_id,
	 l_mol_qty                 => l_mol_qty,
	 l_mol_qty2                => l_mol_qty2,
	 l_atd_qty                 => l_atd_qty,
	 l_atd_mol_qty2            => l_atd_mol_qty2,
	 l_supply_uom_code         => l_supply_uom_code,
	 l_mol_uom_code2           => l_mol_uom_code2,
	 l_conversion_rate         => l_conversion_rate,
	 l_conversion_precision    => l_conversion_precision,
	 l_mol_prim_qty            => l_mol_prim_qty,
	 l_atd_prim_qty            => l_atd_prim_qty,
	 l_split_wdd_id            => l_split_wdd_id,
	 l_mol_header_id           => l_mol_header_id,
	 l_mol_line_id             => l_mol_line_id,
	 l_supply_atr_qty          => l_supply_atr_qty,
	 l_demand_type_id          => l_demand_type_id,
	 l_wip_entity_id           => l_wip_entity_id,
	 l_operation_seq_num       => l_operation_seq_num,
	 l_repetitive_schedule_id  => l_repetitive_schedule_id,
	 l_wip_supply_type         => l_wip_supply_type,
	 l_xdocked_wdd_index	   => l_xdocked_wdd_index,
	 l_detail_info_tab         => l_detail_info_tab,
	 l_wdd_index               => l_dummy_wdd_index,
	 l_split_wdd_index         => l_split_wdd_index,
	 p_wsh_release_table       => l_wsh_release_table,
	 l_supply_type_id          => l_supply_type_id,
	 x_return_status           => x_return_status,
	 x_msg_count               => x_msg_count,
	 x_msg_data                => x_msg_data,
	 x_error_code              => l_error_code,
	 l_criterion_type          => G_CRT_TYPE_OPP
	 );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 IF (l_debug = 1) THEN
	    print_debug('4.3 - Error returned from Crossdock_MOL API: '
			|| x_return_status);
	 END IF;
	 --RAISE fnd_api.g_exc_error;
	 -- If an exception occurs while modifying a database record, rollback the changes
	 -- and just go to the next WDD record or supply to crossdock.
	 ROLLBACK TO Crossdock_Demand_sp;
	 -- We need to also rollback changes done to local PLSQL data structures
	 IF (l_xdocked_wdd_index IS NOT NULL) THEN
	    l_detail_info_tab.DELETE(l_xdocked_wdd_index);
	 END IF;
	 GOTO next_demand;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('4.3 - Successfully crossdocked/split the MOL record');
	 END IF;
      END IF;
      l_progress := '520';

      -- 4.4 - Create a crossdocked reservation tying the demand to the supply line.
      -- Calculate the supply expected time
      IF (l_debug = 1) THEN
	 print_debug('4.4 - Create a crossdock reservation peg to tie the demand to the supply');
      END IF;

      -- Call the Create_RSV API to create a crossdock reservation.
      -- Do this only for OE demand, not WIP.
      -- For WIP supply, create a reservation only if the WIP entity type is 'Discrete'.
      -- Flow WIP LPN completions should not create reservations here.  They are created
      -- immediately upon flow schedule completion against onhand Inventory.
      IF (l_demand_type_id <> 5 AND
	  (l_wip_entity_type IS NULL OR l_wip_entity_type = 1)) THEN
	 IF (l_debug = 1) THEN
	    print_debug('4.4 - Call the Create_RSV API to create a crossdock reservation');
	 END IF;
	 Create_RSV
	   (p_log_prefix              => '4.4 - ',
	    p_crossdock_type          => G_CRT_TYPE_OPP,
	    l_debug                   => l_debug,
	    l_organization_id         => l_organization_id,
	    l_inventory_item_id       => l_inventory_item_id,
	    l_demand_type_id          => l_demand_type_id,
	    l_demand_so_header_id     => l_demand_header_id, -- Use this value here for Opportunistic
	    l_demand_line_id          => l_demand_line_id,
	    l_split_wdd_id            => l_split_wdd_id,
	    l_primary_uom_code        => l_primary_uom_code,
	    l_demand_uom_code2        => l_demand_uom_code2,
	    l_supply_uom_code         => l_supply_uom_code,
	    l_atd_qty                 => l_atd_qty,
	    l_atd_prim_qty            => l_atd_prim_qty,
	    l_atd_wdd_qty2            => l_atd_wdd_qty2,
	    l_supply_type_id          => l_supply_type_id,
	    l_supply_header_id        => l_supply_header_id,
	    l_supply_line_id          => l_supply_line_id,
	    l_supply_line_detail_id   => l_supply_line_detail_id,
	    l_crossdock_criteria_id   => l_crossdock_criteria_id,
	    l_supply_expected_time    => l_supply_expected_time,
	    l_demand_expected_time    => l_demand_expected_time,
	    l_demand_project_id       => l_demand_project_id,
	    l_demand_task_id          => l_demand_task_id,
	    l_original_rsv_rec        => l_original_rsv_rec,
	    l_original_serial_number  => l_original_serial_number,
	    l_to_serial_number        => l_to_serial_number,
	    l_quantity_reserved       => l_quantity_reserved,
	    l_quantity_reserved2      => l_quantity_reserved2,
	    l_rsv_id                  => l_rsv_id,
	    x_return_status           => x_return_status,
	    x_msg_count               => x_msg_count,
	    x_msg_data                => x_msg_data
	   );

	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    IF (l_debug = 1) THEN
	       print_debug('4.4 - Error returned from create_reservation API: '
			   || x_return_status);
	    END IF;
	    --RAISE fnd_api.g_exc_error;
	    -- If an exception occurs while modifying a database record, rollback the changes
	    -- and just go to the next WDD record to crossdock.
	    ROLLBACK TO Crossdock_Demand_sp;
	    -- We need to also rollback changes done to local PLSQL data structures
	    IF (l_xdocked_wdd_index IS NOT NULL) THEN
	       l_detail_info_tab.DELETE(l_xdocked_wdd_index);
	    END IF;
	    GOTO next_demand;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('4.4 - Successfully created a crossdock RSV record');
	    END IF;
	 END IF;
      END IF;
      l_progress := '530';

      -- If the supply is a WIP discrete job, we only want to create reservation pegs
      -- tying the WIP job to the same OE Sales Order Line demand.  The user can manually
      -- create multiple ones for the same WIP job to different OE demand from
      -- the reservations form, but from the crossdock pegging logic, we want to restrict this.
      -- The reason is due to WIP not having the logic to know which reservation to consume
      -- when the WIP job LPN is being putaway.  If we have reached this point, a crossdock
      -- peg has already been created.  Set the l_wip_demand variables so we will only
      -- crossdock to that OE demand.  (You can have multiple WDD records for the same SO line).
      IF (l_wip_entity_type = 1 AND l_wip_demand_header_id IS NULL) THEN
	 IF (l_demand_type_id <> 5) THEN
	    -- OE demand that was just crossdocked for WIP Discrete supply.
	    -- We want to restrict future crossdock pegs to only go against this same demand.
	    l_wip_demand_type_id := l_demand_type_id;
	    l_wip_demand_header_id := l_demand_header_id;
	    l_wip_demand_line_id := l_demand_line_id;
	    IF (l_debug = 1) THEN
	       print_debug('4.4 - Supply is a WIP Discrete job and a crossdock has occurred');
	       print_debug('4.4 - Unique OE demand we are ONLY allowed to peg to');
	       print_debug('4.4 - Demand Type ID: ===> ' || l_wip_demand_type_id);
	       print_debug('4.4 - Demand Header ID: => ' || l_wip_demand_header_id);
	       print_debug('4.4 - Demand Line ID: ===> ' || l_wip_demand_line_id);
	    END IF;
	 END IF;
      END IF;


      -- Exit out of available demand lines loop if the MOL supply has been fully crossdocked.
      -- There is no need to consider anymore demand lines for crossdocking.
      IF (l_supply_atr_qty <= 0) THEN
	 EXIT;
      END IF;

      <<next_demand>>
      -- Exit when all demand lines have been considered
      EXIT WHEN l_demand_index = l_shopping_basket_tb.LAST;
      l_demand_index := l_shopping_basket_tb.NEXT(l_demand_index);
   END LOOP; -- End looping through demand lines in shopping basket table
   l_progress := '540';

   -- Done with crossdocking logic
   -- This label should come before the post crossdocking logic to update WDD records.
   -- If the MOL is completely used to fulfill an existing reservation, we will go to
   -- this label and the logic to update the WDD records needs to be done.
   <<end_crossdock>>

   -- Section 5: Post crossdocking logic
   -- 5.1 - For all crossdocked WDD lines, call the shipping API to update the
   --       released_status and move_order_line_id columns.
   -- 5.2 - Bug 5194761: clear the temp table wms_xdock_pegging_gtmp
   -- {{
   -- Make sure the shipping API to update crossdocked WDD lines is only called if necessary
   -- and properly updates the WDD records. }}
   IF (l_detail_info_tab.COUNT > 0) THEN
      IF (l_debug = 1) THEN
	 print_debug('5.1 - Call the Create_Update_Delivery_Detail API for ' ||
		     l_detail_info_tab.COUNT || ' crossdocked WDD records');
      END IF;

      l_in_rec.caller := 'WMS_XDOCK_PEGGING_PUB';
      l_in_rec.action_code := 'UPDATE';

      WSH_INTERFACE_EXT_GRP.Create_Update_Delivery_Detail
	(p_api_version_number      => 1.0,
	 p_init_msg_list           => fnd_api.g_false,
	 p_commit                  => fnd_api.g_false,
	 x_return_status           => x_return_status,
	 x_msg_count               => x_msg_count,
	 x_msg_data                => x_msg_data,
	 p_detail_info_tab         => l_detail_info_tab,
	 p_in_rec                  => l_in_rec,
	 x_out_rec                 => l_out_rec
	 );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 IF (l_debug = 1) THEN
	    print_debug('5.1 - Error returned from Create_Update_Delivery_Detail API: '
			|| x_return_status);
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('5.1 - Successfully updated the crossdocked WDD records');
	 END IF;
      END IF;
   END IF;
   l_progress := '550';

   -- Bug 5194761: delete records from wms_xdock_pegging_gtmp
   DELETE wms_xdock_pegging_gtmp;
   IF (l_debug = 1) AND SQL%FOUND THEN
      print_debug('5.2 - Cleared the temp table wms_xdock_pegging_gtmp');
   END IF;

   -- If we have reached this point, the return status should be set to success.
   -- This variable is reused each time we call another API but we try to continue with the
   -- flow and raise an exception only when absolutely necessary.  Since this is a planning
   -- and pegging API, if exceptions occur, we should just not peg anything instead of throwing
   -- errors.
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := '560';

   IF (l_debug = 1) THEN
      print_debug('***End of Opportunistic_Cross_Dock***');
   END IF;

   -- Stop the profiler
   -- dbms_profiler.stop_profiler;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Opportunistic_Cross_Dock_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Opportunistic_Cross_Dock - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Opportunistic_Cross_Dock_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Opportunistic_Cross_Dock - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO Opportunistic_Cross_Dock_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Opportunistic_Cross_Dock - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END Opportunistic_Cross_Dock;
-- {{ }}
-- {{******************** End Opportunistic_Cross_Dock ********************}}
-- {{ }}


-- p_source_type_id refers to new lookup_type in mfg_lookups called 'Reservation_Types'
-- Valid supplies:
--    1  - Purchase Order
--    7  - Internal Requisition
--    25 - ASN
--    26 - In Transit Shipment
-- Valid demands:
--    2  - Sales Order
--    8  - Internal Order
-- Supply of type Receiving is material already received so there is no need to get an expected
-- receipt time for that.  SYSDATE at the time the crossdock peg is created will be used and stamped
-- on the reservation.  Demand of type WIP (backordered component demand) will always use the
-- date_required field in the view wip_material_shortages_v as the expected ship time.  Other
-- source types will not currently be supported in this API.
-- {{ }}
-- {{******************** Procedure Get_Expected_Time ********************}}
PROCEDURE Get_Expected_Time
  (p_source_type_id             IN      NUMBER,
   p_source_header_id           IN      NUMBER,
   p_source_line_id             IN      NUMBER,
   p_source_line_detail_id      IN      NUMBER,
   p_supply_or_demand           IN      NUMBER,
   p_crossdock_criterion_id     IN      NUMBER,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2,
   x_dock_start_time            OUT     NOCOPY DATE,
   x_dock_mean_time             OUT     NOCOPY DATE,
   x_dock_end_time              OUT     NOCOPY DATE,
   x_expected_time              OUT     NOCOPY DATE)
  IS
     l_api_name           CONSTANT VARCHAR2(30) := 'Get_Expected_Time';
     l_progress           VARCHAR2(10);
     l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     -- This variable is used to indicate if the custom API was used to determine
     -- the expected time values.
     l_api_is_implemented BOOLEAN;

     -- Cursor to retrieve the trip stop id, carrier id, and expected ship time
     -- (without considering dock appointments) for a WDD demand line.
     -- The order to look for this information is documented in the Crossdock Pegging TDD.
     -- Make use of outer joins in a cascading manner since records might not exist in all
     -- of the tables.  WSH_DELIVERY_LEGS could have multiple trip stops for the same delivery.
     -- For our purposes, we want to pick the first one, hence choose the one with the minimum
     -- value for the sequence_number.  This is contingent upon a delivery being present for
     -- the WDD demand line.  For WDD demand lines, reservations will store the mtl sales order
     -- header ID, OE order line ID, and WDD delivery detail ID as the source header ID, line ID,
     -- and line detail ID respectively.
     CURSOR wdd_rec_cursor IS
	SELECT wdd.organization_id AS organization_id,
	  wts.stop_id AS trip_stop_id,
	  NVL(wt.carrier_id,
	      NVL(NVL(wnd.carrier_id, wcs_wnd.carrier_id),
	          NVL(NVL(wdd.carrier_id, wcs_wdd.carrier_id),
		      NVL(wc_ool.carrier_id, wcs_ool.carrier_id)))) AS carrier_id,
	  NVL(wts.planned_departure_date,
	      NVL(wdd.date_scheduled,
		  NVL(ool.schedule_ship_date, ool.promise_date))) AS expected_ship_date
	FROM wsh_delivery_details wdd, oe_order_lines_all ool,
	     wsh_delivery_assignments_v wda, wsh_new_deliveries wnd, wsh_delivery_legs wdl,
	     wsh_trip_stops wts, wsh_trips wt, wsh_carrier_services wcs_wnd,
	     wsh_carrier_services wcs_wdd, wsh_carrier_services wcs_ool, wsh_carriers wc_ool
	WHERE wdd.delivery_detail_id = p_source_line_detail_id
	  AND ool.line_id = p_source_line_id
	  AND wdd.source_line_id = ool.line_id
          AND inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id) = p_source_header_id
	  AND wdd.delivery_detail_id = wda.delivery_detail_id (+)
	  AND wda.delivery_id = wnd.delivery_id (+)
	  AND wnd.delivery_id = wdl.delivery_id (+)
	  AND (wdl.sequence_number IS NULL OR
	       wdl.sequence_number = (SELECT MIN(sequence_number)
				      FROM wsh_delivery_legs wdl_first_leg
				      WHERE wdl_first_leg.delivery_id = wdl.delivery_id))
	  AND wdl.pick_up_stop_id = wts.stop_id (+)
	  AND wts.trip_id         = wt.trip_id  (+)
	  AND wnd.ship_method_code = wcs_wnd.ship_method_code (+)
	  AND wdd.ship_method_code = wcs_wdd.ship_method_code (+)
	  AND ool.shipping_method_code = wcs_ool.ship_method_code (+)
	  AND ool.freight_carrier_code = wc_ool.freight_code (+);


     -- Cursor to retrieve the trip stop id, carrier id, and expected receipt time
     -- (without considering dock appointments) for a PO supply line.
     -- For PO supply lines, reservations will store the PO header ID, PO line location ID,
     -- and NULL as the source header ID, line ID, and line detail ID respectively.
     -- NOTE REGARDING INBOUND TRIPS:
     -- Currently, when an Inbound Trip is created, the trip has a planned arrival date
     -- set to be the last accept date for the inbound supply.  When a shipment is created,
     -- the planned arrival date of the trip does not get updated.  Thus the expected
     -- receipt date returned from this cursor is not the most accurate until the issue
     -- with trips is resolved.
     CURSOR po_rec_cursor IS
	SELECT poll.ship_to_organization_id AS organization_id,
	  wts.stop_id AS trip_stop_id,
	  NVL(wt.carrier_id,
	      NVL(NVL(wnd.carrier_id, wcs_wnd.carrier_id),
	          NVL(NVL(wdd.carrier_id, wcs_wdd.carrier_id),
		      wc_poll.carrier_id))) AS carrier_id,
	  NVL(wts.planned_arrival_date,
	      NVL(poll.promised_date, poll.need_by_date)) AS expected_receipt_date
	FROM po_line_locations_all poll, wsh_delivery_details wdd,
	     wsh_delivery_assignments_v wda, wsh_new_deliveries wnd, wsh_delivery_legs wdl,
	     wsh_trip_stops wts, wsh_trips wt, wsh_carrier_services wcs_wnd,
	     wsh_carrier_services wcs_wdd, wsh_carriers wc_poll
	WHERE poll.po_header_id = p_source_header_id
	  AND poll.line_location_id = p_source_line_id
	  AND poll.po_header_id = wdd.source_header_id (+)
	  AND poll.po_line_id = wdd.source_line_id (+)
	  AND poll.line_location_id = wdd.po_shipment_line_id (+)
	  AND 'PO' = wdd.source_code (+)
	  AND 'I' = wdd.line_direction (+)
	  AND 'L' <> wdd.released_status (+)
	  AND wdd.delivery_detail_id = wda.delivery_detail_id (+)
	  AND wda.delivery_id = wnd.delivery_id (+)
	  AND wnd.delivery_id = wdl.delivery_id (+)
	  AND (wdl.sequence_number IS NULL OR
	       wdl.sequence_number = (SELECT MIN(sequence_number)
				      FROM wsh_delivery_legs wdl_first_leg
				      WHERE wdl_first_leg.delivery_id = wdl.delivery_id))
	  AND wdl.drop_off_stop_id = wts.stop_id (+)
	  AND wts.trip_id          = wt.trip_id  (+)
	  AND wnd.ship_method_code = wcs_wnd.ship_method_code (+)
	  AND wdd.ship_method_code = wcs_wdd.ship_method_code (+)
	  AND poll.ship_via_lookup_code = wc_poll.freight_code (+)
	  ORDER BY expected_receipt_date ASC;


     -- Cursor to retrieve the trip stop id, carrier id, and expected receipt time
     -- (without considering dock appointments) for an ASN supply line.
     -- For ASN supply lines, reservations will store the PO header ID, PO line location ID,
     -- and RCV shipment line ID as the source header ID, line ID, and line detail ID respectively.
     -- NOTE REGARDING INBOUND TRIPS:
     -- Currently, when an Inbound Trip is created, the trip has a planned arrival date
     -- set to be the last accept date for the inbound supply.  When a shipment is created,
     -- the planned arrival date of the trip does not get updated.  Thus the expected
     -- receipt date returned from this cursor is not the most accurate until the issue
     -- with trips is resolved.
     CURSOR asn_rec_cursor IS
	SELECT rsl.to_organization_id AS organization_id,
	  wts.stop_id AS trip_stop_id,
	  NVL(wt.carrier_id,
	      NVL(NVL(wnd.carrier_id, wcs_wnd.carrier_id),
	          NVL(NVL(wdd.carrier_id, wcs_wdd.carrier_id),
		      NVL(wc_rsh.carrier_id,
		          wc_poll.carrier_id)))) AS carrier_id,
	  NVL(wts.planned_arrival_date,
	      NVL(NVL(rsh.expected_receipt_date, rsh.shipped_date),
		  NVL(poll.promised_date, poll.need_by_date))) AS expected_receipt_date
	 FROM po_line_locations_all poll, wsh_delivery_details wdd,
	      rcv_shipment_headers rsh, rcv_shipment_lines rsl,
	      wsh_delivery_assignments_v wda, wsh_new_deliveries wnd, wsh_delivery_legs wdl,
	      wsh_trip_stops wts, wsh_trips wt, wsh_carrier_services wcs_wnd,
	      wsh_carrier_services wcs_wdd, wsh_carriers wc_poll, wsh_carriers wc_rsh
	 WHERE rsl.po_header_id = p_source_header_id
	   AND rsl.po_line_location_id = p_source_line_id
	   AND rsl.shipment_line_id = p_source_line_detail_id
	   AND poll.po_header_id = rsl.po_header_id
	   AND poll.po_line_id = rsl.po_line_id
	   AND poll.line_location_id = rsl.po_line_location_id
           AND rsl.shipment_header_id = rsh.shipment_header_id
           AND rsh.shipment_num IS NOT NULL
           AND rsh.receipt_source_code = 'VENDOR'
           AND rsh.asn_type IN ('ASN', 'ASBN')
	   AND rsl.po_header_id = wdd.source_header_id (+)
	   AND rsl.po_line_id = wdd.source_line_id (+)
	   AND rsl.po_line_location_id = wdd.po_shipment_line_id (+)
	   AND rsl.shipment_line_id = wdd.rcv_shipment_line_id (+)
           AND 'PO' = wdd.source_code (+)
           AND 'I' = wdd.line_direction (+)
	   AND 'L' <> wdd.released_status (+)
           AND wdd.delivery_detail_id = wda.delivery_detail_id (+)
           AND wda.delivery_id = wnd.delivery_id (+)
           AND wnd.delivery_id = wdl.delivery_id (+)
           AND (wdl.sequence_number IS NULL OR
		wdl.sequence_number = (SELECT MIN(sequence_number)
				       FROM wsh_delivery_legs wdl_first_leg
				       WHERE wdl_first_leg.delivery_id = wdl.delivery_id))
	   AND wdl.drop_off_stop_id = wts.stop_id (+)
	   AND wts.trip_id          = wt.trip_id  (+)
	   AND wnd.ship_method_code = wcs_wnd.ship_method_code (+)
	   AND wdd.ship_method_code = wcs_wdd.ship_method_code (+)
	   AND poll.ship_via_lookup_code = wc_poll.freight_code (+)
	   AND rsh.freight_carrier_code = wc_rsh.freight_code (+);


     -- Cursor to retrieve the trip stop id, carrier id, and expected receipt time
     -- (without considering dock appointments) for an Internal Requisition supply line.
     -- For Internal Req supply lines, reservations will store the Req header ID, Req line ID,
     -- and NULL as the source header ID, line ID, and line detail ID respectively.
     -- For release R12, since reservations for Internal Requisitions will only be at the
     -- Req header and line level, there can be multiple shipments tied to a given reservation.
     -- Ideally reservations should also be at the shipment line level for Internal Reqs that
     -- have shipped.  Due to this limitation, when determining the expected receipt time,
     -- just use the earliest expected_receipt_date.  There can be multiple records returned
     -- from this cursor if multiple shipment lines for the Internal Req exist.
     -- NOTE REGARDING INBOUND TRIPS:
     -- Currently, when an Inbound Trip is created, the trip has a planned arrival date
     -- set to be the last accept date for the inbound supply.  When a shipment is created,
     -- the planned arrival date of the trip does not get updated.  Thus the expected
     -- receipt date returned from this cursor is not the most accurate until the issue
     -- with trips is resolved.
     CURSOR intreq_rec_cursor IS
	SELECT prl.destination_organization_id AS organization_id,
	  wts.stop_id AS trip_stop_id,
	  NVL(wt.carrier_id,
	      NVL(NVL(wnd.carrier_id, wcs_wnd.carrier_id),
	          NVL(NVL(wdd.carrier_id, wcs_wdd.carrier_id),
		      NVL(NVL(wc_ool.carrier_id, wcs_ool.carrier_id),
		          NVL(wc_rsh.carrier_id,
			      wcs_prl.carrier_id))))) AS carrier_id,
	  NVL(wts.planned_arrival_date,
	      NVL(NVL(rsh.expected_receipt_date, rsh.shipped_date),
		  prl.need_by_date)) AS expected_receipt_date
	  FROM po_requisition_lines_all prl, rcv_shipment_lines rsl, rcv_shipment_headers rsh,
	       oe_order_lines_all ool, wsh_delivery_details wdd,
	       wsh_delivery_assignments_v wda, wsh_new_deliveries wnd, wsh_delivery_legs wdl,
	       wsh_trip_stops wts, wsh_trips wt, wsh_carrier_services wcs_wnd,
	       wsh_carrier_services wcs_wdd, wsh_carrier_services wcs_ool,
	       wsh_carriers wc_ool, wsh_carriers wc_rsh, wsh_carrier_services wcs_prl
	  WHERE prl.requisition_header_id = p_source_header_id
	    AND prl.requisition_line_id = p_source_line_id
	    AND prl.source_type_code = 'INVENTORY'
            AND NVL(prl.cancel_flag, 'N') = 'N'
            AND prl.requisition_line_id = rsl.requisition_line_id (+)
            AND rsl.shipment_header_id = rsh.shipment_header_id (+)
            AND 10 = ool.order_source_id (+) -- Internal Order source type
            AND prl.requisition_header_id = ool.source_document_id (+)
            AND prl.requisition_line_id = ool.source_document_line_id (+)
            AND prl.item_id = ool.inventory_item_id (+)
            AND ool.header_id = wdd.source_header_id (+)
            AND ool.line_id = wdd.source_line_id (+)
            AND 'OE' = wdd.source_code (+)
            AND 'IO' = wdd.line_direction (+)
	    AND 'L' <> wdd.released_status (+)
            AND wdd.delivery_detail_id = wda.delivery_detail_id (+)
            AND wda.delivery_id = wnd.delivery_id (+)
            AND wnd.delivery_id = wdl.delivery_id (+)
            AND (wdl.sequence_number IS NULL OR
		 wdl.sequence_number = (SELECT MIN(sequence_number)
					FROM wsh_delivery_legs wdl_first_leg
					WHERE wdl_first_leg.delivery_id = wdl.delivery_id))
	    AND wdl.drop_off_stop_id = wts.stop_id (+)
	    AND wts.trip_id          = wt.trip_id  (+)
	    AND wnd.ship_method_code = wcs_wnd.ship_method_code (+)
	    AND wdd.ship_method_code = wcs_wdd.ship_method_code (+)
	    AND ool.shipping_method_code = wcs_ool.ship_method_code (+)
	    AND ool.freight_carrier_code = wc_ool.freight_code (+)
	    AND rsh.freight_carrier_code = wc_rsh.freight_code (+)
	    AND prl.ship_method = wcs_prl.ship_method_code (+)
	  ORDER BY expected_receipt_date ASC;


     -- Cursor to retrieve the trip stop id, carrier id, and expected receipt time
     -- (without considering dock appointments) for an In Transit Shipment supply line.
     -- For In Transit Shipment supply lines, reservations will store the RCV shipment header ID,
     -- RCV shipment line ID and NULL as the source header ID, line ID, and line detail ID
     -- respectively.
     CURSOR intship_rec_cursor IS
	SELECT rsl.to_organization_id AS organization_id,
	  NULL AS trip_stop_id,
	  wc_rsh.carrier_id as carrier_id,
	  NVL(rsh.expected_receipt_date,
	      NVL(rsh.shipped_date + NVL(mism.intransit_time, 0),
		  rsh.shipped_date)) AS expected_receipt_date
	FROM rcv_shipment_lines rsl, rcv_shipment_headers rsh,
	     wsh_carriers wc_rsh, mtl_interorg_ship_methods mism
	WHERE rsl.shipment_header_id = p_source_header_id
	  AND rsl.shipment_line_id = p_source_line_id
	  AND rsl.shipment_header_id = rsh.shipment_header_id
          AND rsh.shipment_num IS NOT NULL
	  AND rsh.receipt_source_code = 'INVENTORY'
	  AND rsh.freight_carrier_code = wc_rsh.freight_code (+)
	  AND rsl.from_organization_id = mism.from_organization_id (+)
	  AND rsl.to_organization_id = mism.to_organization_id (+)
	  AND 1 = mism.default_flag (+);

     -- Variables to retrieve the values from the source line cursors
     l_organization_id          NUMBER;
     l_trip_stop_id             NUMBER;
     l_carrier_id               NUMBER;
     l_expected_date            DATE;

     -- Variables for calling the dock appointment API
     l_dock_appt_list           WMS_DOCK_APPOINTMENTS_PUB.dock_appt_tb_tp;

     -- Variables to loop through all dock appointments returned to find the one
     -- closest to the expected receipt/ship time.
     l_dock_schedule_method     NUMBER;
     l_dock_start_time          DATE;
     l_dock_mean_time           DATE;
     l_dock_end_time            DATE;
     l_dock_appt_time           DATE;
     l_current_dock_appt_time   DATE;

BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling Get_Expected_Time with the following parameters***');
      print_debug('Package Version: ==========> ' || g_pkg_version);
      print_debug('p_source_type_id: =========> ' || p_source_type_id);
      print_debug('p_source_header_id: =======> ' || p_source_header_id);
      print_debug('p_source_line_id: =========> ' || p_source_line_id);
      print_debug('p_source_line_detail_id: ==> ' || p_source_line_detail_id);
      print_debug('p_supply_or_demand: =======> ' || p_supply_or_demand);
      print_debug('p_crossdock_criterion_id: => ' || p_crossdock_criterion_id);
   END IF;

   -- Set the savepoint
   SAVEPOINT Get_Expected_Time_sp;
   l_progress := '10';

   -- Initialize message list to clear any existing messages
   fnd_msg_pub.initialize;
   l_progress := '20';

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := '30';

   -- Validate p_supply_or_demand
   -- {{
   -- Make sure API errors out if input variable p_supply_or_demand is not valid. }}
   IF (p_supply_or_demand NOT IN (G_SRC_TYPE_SUP, G_SRC_TYPE_DEM)) THEN
      IF (l_debug = 1) THEN
	 print_debug('Invalid value for p_supply_or_demand: ' || p_supply_or_demand);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   l_progress := '40';

   -- Validate that source type matches supply or demand
   IF (p_supply_or_demand = G_SRC_TYPE_SUP) THEN
      -- Check that source type is a valid supply source
      -- {{
      -- Make sure API errors out if supply type passed in is not valid. }}
      IF (p_source_type_id NOT IN (1, 7, 25, 26)) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Invalid supply source type: ' || p_source_type_id);
	 END IF;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF (p_supply_or_demand = G_SRC_TYPE_DEM) THEN
      -- Check that source type is a valid demand source
      -- {{
      -- Make sure API errors out if demand type passed in is not valid. }}
      IF (p_source_type_id NOT IN (2, 8)) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Invalid demand source type: ' || p_source_type_id);
	 END IF;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;
   l_progress := '50';

   -- If the crossdock criterion is passed, query and cache the value
   IF (p_crossdock_criterion_id IS NOT NULL) THEN
      IF (NOT set_crossdock_criteria(p_crossdock_criterion_id)) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Unable to set the crossdock criterion: ' || p_crossdock_criterion_id);
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
      END IF;

      -- Get the dock schedule method from the crossdock criterion
      -- {{
      -- If crossdock criterion is passed, make sure a valid non-null value for
      -- the dock schedule method is retrieved. }}
      IF (p_supply_or_demand = G_SRC_TYPE_SUP) THEN
	 l_dock_schedule_method :=
	   g_crossdock_criteria_tb(p_crossdock_criterion_id).supply_schedule_method;
       ELSIF (p_supply_or_demand = G_SRC_TYPE_DEM) THEN
	 l_dock_schedule_method :=
	   g_crossdock_criteria_tb(p_crossdock_criterion_id).demand_schedule_method;
      END IF;
      IF (l_debug = 1) THEN
	 print_debug('Dock Schedule Method: ' || l_dock_schedule_method);
      END IF;
   END IF;
   l_progress := '60';
   -- End of validations and initializations


   -- Call the custom logic first to see if the API is implemented or not
   WMS_XDOCK_CUSTOM_APIS_PUB.Get_Expected_Time
     (p_source_type_id             => p_source_type_id,
      p_source_header_id           => p_source_header_id,
      p_source_line_id             => p_source_line_id,
      p_source_line_detail_id      => p_source_line_detail_id,
      p_supply_or_demand           => p_supply_or_demand,
      p_crossdock_criterion_id     => p_crossdock_criterion_id,
      p_dock_schedule_method       => l_dock_schedule_method,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data,
      x_api_is_implemented         => l_api_is_implemented,
      x_dock_start_time            => x_dock_start_time,
      x_dock_mean_time             => x_dock_mean_time,
      x_dock_end_time              => x_dock_end_time,
      x_expected_time              => x_expected_time);

   IF (x_return_status = fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
	 print_debug('Success returned from Custom Get_Expected_Time API');
      END IF;
    ELSE
      IF (l_debug = 1) THEN
	 print_debug('Failure returned from Custom Get_Expected_Time API');
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- If the custom API is implemented, just use the values retrieved from there.
   -- Skip all further processing and logic in this API.
   IF (l_api_is_implemented) THEN
      IF (l_debug = 1) THEN
	 print_debug('Custom API is implemented so using custom logic to get expected time');
      END IF;
      GOTO custom_logic_used;
    ELSE
      IF (l_debug = 1) THEN
	 print_debug('Custom API is not implemented so using default logic to get expected time');
      END IF;
   END IF;

   -- Check the source type to decide which cursor to open to retrieve the
   -- trip stop, carrier, and non-dock appointment derived expected receipt/ship time.
   IF (p_source_type_id IN (2, 8)) THEN
      -- Sales Order or Internal Order
      -- {{
      -- Get the expected time for a sales order and internal order demand. }}
      OPEN wdd_rec_cursor;
      FETCH wdd_rec_cursor INTO l_organization_id, l_trip_stop_id, l_carrier_id, l_expected_date;
      IF (wdd_rec_cursor%NOTFOUND) THEN
	 IF (l_debug = 1) THEN
	    print_debug('WDD cursor did not return any records!');
	 END IF;
	 CLOSE wdd_rec_cursor;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE wdd_rec_cursor;
    ELSIF (p_source_type_id = 1) THEN
      -- Purchase Order
      -- {{
      -- Get the expected time for a PO. }}
      OPEN po_rec_cursor;
      FETCH po_rec_cursor INTO l_organization_id, l_trip_stop_id, l_carrier_id, l_expected_date;
      IF (po_rec_cursor%NOTFOUND) THEN
	 IF (l_debug = 1) THEN
	    print_debug('PO cursor did not return any records!');
	 END IF;
	 CLOSE po_rec_cursor;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE po_rec_cursor;
    ELSIF (p_source_type_id = 25) THEN
      -- ASN
      -- {{
      -- Get the expected time for an ASN. }}
      OPEN asn_rec_cursor;
      FETCH asn_rec_cursor INTO l_organization_id, l_trip_stop_id, l_carrier_id, l_expected_date;
      IF (asn_rec_cursor%NOTFOUND) THEN
	 IF (l_debug = 1) THEN
	    print_debug('ASN cursor did not return any records!');
	 END IF;
	 CLOSE asn_rec_cursor;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE asn_rec_cursor;
    ELSIF (p_source_type_id = 7) THEN
      -- Internal Requisition
      -- {{
      -- Get the expected time for an Internal Req. }}
      OPEN intreq_rec_cursor;
      FETCH intreq_rec_cursor INTO l_organization_id, l_trip_stop_id, l_carrier_id, l_expected_date;
      IF (intreq_rec_cursor%NOTFOUND) THEN
	 IF (l_debug = 1) THEN
	    print_debug('INTREQ cursor did not return any records!');
	 END IF;
	 CLOSE intreq_rec_cursor;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE intreq_rec_cursor;
    ELSIF (p_source_type_id = 26) THEN
      -- In Transit Shipment
      -- {{
      -- Get the expected time for an In Transit Shipment. }}
      OPEN intship_rec_cursor;
      FETCH intship_rec_cursor INTO l_organization_id, l_trip_stop_id, l_carrier_id, l_expected_date;
      IF (intship_rec_cursor%NOTFOUND) THEN
	 IF (l_debug = 1) THEN
	    print_debug('INTSHIP cursor did not return any records!');
	 END IF;
	 CLOSE intship_rec_cursor;
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE intship_rec_cursor;
   END IF;
   l_progress := '70';

   IF (l_debug = 1) THEN
      print_debug('Successfully retrieved data from cursor');
      print_debug('Organization ID: => ' || l_organization_id);
      print_debug('Trip Stop ID: ====> ' || l_trip_stop_id);
      print_debug('Carrier ID: ======> ' || l_carrier_id);
      print_debug('Expected Date: ===> ' || TO_CHAR(l_expected_date, 'DD-MON-YYYY HH24:MI:SS'));
   END IF;
   l_progress := '80';

   -- If a trip stop is present, query for dock appointments associated with the trip stop.
   -- If a trip stop is passed to this API, the start and end date parameters are ignored
   -- and the first dock appointment associated with the trip stop is returned.  This will
   -- return at most one dock appointment in the output variable table x_dock_appt_list.
   -- CORRECTION TO THE ABOVE:
   -- The dock appointment API, even if a trip stop is passed does take the p_start_date into
   -- account.  Since dock appointment statuses do not exist yet, this API will only look for
   -- dock appointments tied to the trip stop that are >= p_start_date.  This is done so we do
   -- not pick up older dock appointments that have already passed.  (Though that should not be
   -- an issue for dock appointments tied to trip stops).  Thus use SYSDATE for p_start_date
   -- instead of l_expected_date.
   -- {{
   -- Test for cases both with and without a dock appointment tied to an existing trip stop. }}
   IF (l_trip_stop_id IS NOT NULL) THEN
      IF (l_debug = 1) THEN
	 print_debug('Call the get_dock_appointment_range API for a trip stop');
      END IF;
      l_progress := '90';

      wms_dock_appointments_pub.get_dock_appointment_range
	(p_api_version       => 1.0,
	 p_init_msg_list     => fnd_api.g_false,
	 x_return_status     => x_return_status,
	 x_msg_count         => x_msg_count,
	 x_msg_data          => x_msg_data,
	 x_dock_appt_list    => l_dock_appt_list,
	 p_organization_id   => l_organization_id,
	 p_start_date        => Trunc(Sysdate), --l_expected_date,
	 p_end_date          => l_expected_date,
	 p_appointment_type  => p_supply_or_demand,
	 p_supplier_id       => NULL,
	 p_supplier_site_id  => NULL,
	 p_customer_id       => NULL,
	 p_customer_site_id  => NULL,
	 p_carrier_code      => NULL,
	 p_carrier_id        => NULL,
	 p_trip_stop_id      => l_trip_stop_id,
	 p_waybill_number    => NULL,
	 p_bill_of_lading    => NULL,
	 p_master_bol        => NULL);

      IF (l_debug = 1) THEN
	 print_debug('Finished calling the get_dock_appointment_range API');
      END IF;
      l_progress := '100';

      -- Check to see if the get_dock_appointment_range API returned successfully
      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Success returned from get_dock_appointment_range API');
	 END IF;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('Failure returned from get_dock_appointment_range API');
	 END IF;
	x_return_status := fnd_api.g_ret_sts_success;
	 -- do not thrown an error but just go to the next way to calculate time
	 --FND_MESSAGE.SET_NAME('WMS', 'WMS_TD_MO_ERROR');
	 --FND_MSG_PUB.ADD;
	 --RAISE fnd_api.g_exc_error;
      END IF;
      l_progress := '110';
   END IF;

   -- If a dock appointment has not been found yet and a carrier ID is present,
   -- query for dock appointments associated with the carrier.  For the start and end dates,
   -- we will use the date on the variable l_expected_date (sans time information if present)
   -- along with the times of 12AM midnight and 11:59:59PM as the start and end date.
   -- This will return a list of valid dock appointments (multiple appointments are possible).
   -- {{
   -- Test for cases both with and without a dock appointment tied to an existing carrier. }}
   -- {{
   -- Test for cases where multiple dock appointments exist for a given carrier. }}
   IF (l_dock_appt_list.COUNT = 0 AND l_carrier_id IS NOT NULL) THEN
      IF (l_debug = 1) THEN
	 print_debug('Call the get_dock_appointment_range API for a carrier');
      END IF;
      l_progress := '120';

      wms_dock_appointments_pub.get_dock_appointment_range
	(p_api_version       => 1.0,
	 p_init_msg_list     => fnd_api.g_false,
	 x_return_status     => x_return_status,
	 x_msg_count         => x_msg_count,
	 x_msg_data          => x_msg_data,
	 x_dock_appt_list    => l_dock_appt_list,
	 p_organization_id   => l_organization_id,
	 p_start_date        => TRUNC(l_expected_date),
	 p_end_date          => TO_DATE(TO_CHAR(TRUNC(l_expected_date), 'DD-MON-YYYY') ||
					' 23:59:59', 'DD-MON-YYYY HH24:MI:SS'),
	 p_appointment_type  => p_supply_or_demand,
	 p_supplier_id       => NULL,
	 p_supplier_site_id  => NULL,
	 p_customer_id       => NULL,
	 p_customer_site_id  => NULL,
	 p_carrier_code      => NULL,
	 p_carrier_id        => l_carrier_id,
	 p_trip_stop_id      => NULL,
	 p_waybill_number    => NULL,
	 p_bill_of_lading    => NULL,
	 p_master_bol        => NULL);

      IF (l_debug = 1) THEN
	 print_debug('Finished calling the get_dock_appointment_range API');
      END IF;
      l_progress := '130';

      -- Check to see if the get_dock_appointment_range API returned successfully
      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Success returned from get_dock_appointment_range API');
	 END IF;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('Failure returned from get_dock_appointment_range API');
	 END IF;
	x_return_status := fnd_api.g_ret_sts_success;
	 -- do not thrown an error but just go to the next way to calculate time
	 --FND_MESSAGE.SET_NAME('WMS', 'WMS_TD_MO_ERROR');
	 --FND_MSG_PUB.ADD;
	 --RAISE fnd_api.g_exc_error;
      END IF;
      l_progress := '140';
   END IF;

   IF (l_debug = 1) THEN
      print_debug('Number of dock appointments found: ' || l_dock_appt_list.COUNT);
   END IF;
   l_progress := '150';

   -- See if any dock appointments were found.  If multiple dock appointments exist,
   -- get the one closest to the expected receipt/ship date
   IF (l_dock_appt_list.COUNT > 0) THEN
      -- Loop through all available dock appointments
      -- {{
      -- For multiple dock appointments, make sure the 'closest' one is correctly selected. }}
      FOR i IN l_dock_appt_list.FIRST .. l_dock_appt_list.LAST LOOP
	 IF (i = l_dock_appt_list.FIRST) THEN
	    -- First dock appointment found
	    l_dock_start_time := l_dock_appt_list(i).start_time;
	    l_dock_end_time := l_dock_appt_list(i).end_time;
	    l_dock_mean_time := (l_dock_end_time - l_dock_start_time)/2 + l_dock_start_time;

	    -- Based on the dock schedule method (if present) calculate a single
	    -- dock appointment time based on the start and end time.  If multiple dock
	    -- appointments exist, this value will be compared with the expected receipt/ship
	    -- date (non-dock appointment) and the closest dock appointment time will be used.
	    IF (l_dock_schedule_method IS NULL OR l_dock_schedule_method = G_APPT_MEAN_TIME) THEN
	       l_dock_appt_time := l_dock_mean_time;
	     ELSIF (l_dock_schedule_method = G_APPT_START_TIME) THEN
	       l_dock_appt_time := l_dock_start_time;
	     ELSIF (l_dock_schedule_method = G_APPT_END_TIME) THEN
	       l_dock_appt_time := l_dock_end_time;
	    END IF;
	    IF (l_debug = 1) THEN
	       print_debug('Current closest dock appt time: ' ||
			   TO_CHAR(l_dock_appt_time, 'DD-MON-YYYY HH24:MI:SS'));
	    END IF;
	    l_progress := '160';
	  ELSE
	    -- Calculate the current dock appointment time and compare it to the current
	    -- best time to see if this one is even closer to the expected receipt/ship date.
	    IF (l_dock_schedule_method IS NULL OR l_dock_schedule_method = G_APPT_MEAN_TIME) THEN
	       l_current_dock_appt_time := (l_dock_appt_list(i).end_time -
					    l_dock_appt_list(i).start_time)/2
		 + l_dock_appt_list(i).start_time;
	     ELSIF (l_dock_schedule_method = G_APPT_START_TIME) THEN
	       l_current_dock_appt_time := l_dock_appt_list(i).start_time;
	     ELSIF (l_dock_schedule_method = G_APPT_END_TIME) THEN
	       l_current_dock_appt_time := l_dock_appt_list(i).end_time;
	    END IF;

	    -- If the dock appointment time is closer to the expected receipt/ship date compared
	    -- to the current best time, update the best dock appointment variables to
	    -- point to the current dock appointment.
	    IF (abs(l_current_dock_appt_time - l_expected_date) <
		abs(l_dock_appt_time - l_expected_date)) THEN
	       l_dock_start_time := l_dock_appt_list(i).start_time;
	       l_dock_end_time := l_dock_appt_list(i).end_time;
	       l_dock_mean_time := (l_dock_end_time - l_dock_start_time)/2 + l_dock_start_time;
	       l_dock_appt_time := l_current_dock_appt_time;
	       IF (l_debug = 1) THEN
		  print_debug('Closer dock appt time found: ' ||
			      TO_CHAR(l_dock_appt_time, 'DD-MON-YYYY HH24:MI:SS'));
	       END IF;
	    END IF;
	    l_progress := '170';

	 END IF;
      END LOOP;

      IF (l_debug = 1) THEN
	 print_debug('Closest dock appt start time: => ' ||
		     TO_CHAR(l_dock_start_time, 'DD-MON-YYYY HH24:MI:SS'));
	 print_debug('Closest dock appt end time: ===> ' ||
		     TO_CHAR(l_dock_end_time, 'DD-MON-YYYY HH24:MI:SS'));
	 print_debug('Closest dock appt mean time: ==> ' ||
		     TO_CHAR(l_dock_mean_time, 'DD-MON-YYYY HH24:MI:SS'));
	 print_debug('Closest dock appt time: =======> ' ||
		     TO_CHAR(l_dock_appt_time, 'DD-MON-YYYY HH24:MI:SS'));
      END IF;
      l_progress := '180';

      -- We have now found the closest dock appointment time to the expected time
      x_dock_start_time := l_dock_start_time;
      x_dock_mean_time := l_dock_mean_time;
      x_dock_end_time := l_dock_end_time;
      IF (p_crossdock_criterion_id IS NOT NULL) THEN
	 x_expected_time := l_dock_appt_time;
       ELSE
	 -- If a crossdock criterion is not passed, let the caller decide how to determine
	 -- a single expected time based on the dock appointment start and end time.
	 x_expected_time := NULL;
      END IF;
      l_progress := '190';
   END IF; -- End of dock appointments found

   -- If a dock appointment was not found, just use the expected receipt/ship date
   -- retrieved from the cursors as the expected time.
   -- {{
   -- Ensure that the expected time calculated not based on dock appointments is returned
   -- in case no dock appointments exist for the inputted demand/supply line. }}
   IF (l_dock_appt_list.COUNT = 0) THEN
      x_dock_start_time := NULL;
      x_dock_mean_time := NULL;
      x_dock_end_time := NULL;
      x_expected_time := l_expected_date;
   END IF;
   l_progress := '200';

   IF (l_debug = 1) THEN
      print_debug('Dock start time: => ' || TO_CHAR(x_dock_start_time, 'DD-MON-YYYY HH24:MI:SS'));
      print_debug('Dock mean time: ==> ' || TO_CHAR(x_dock_mean_time, 'DD-MON-YYYY HH24:MI:SS'));
      print_debug('Dock end time: ===> ' || TO_CHAR(x_dock_end_time, 'DD-MON-YYYY HH24:MI:SS'));
      print_debug('Expected time: ===> ' || TO_CHAR(x_expected_time, 'DD-MON-YYYY HH24:MI:SS'));
   END IF;

   <<custom_logic_used>>
   IF (l_debug = 1) THEN
      print_debug('***End of Get_Expected_Time***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_Expected_Time_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_Expected_Time - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_Expected_Time_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_Expected_Time - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO Get_Expected_Time_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_Expected_Time - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END Get_Expected_Time;
-- {{ }}
-- {{******************** End Get_Expected_Time ********************}}
-- {{ }}


-- {{ }}
-- {{******************** Procedure Get_Expected_Delivery_Time ********************}}
PROCEDURE Get_Expected_Delivery_Time
  (p_delivery_id                IN      NUMBER,
   p_crossdock_criterion_id     IN      NUMBER,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2,
   x_dock_appointment_id        OUT     NOCOPY NUMBER,
   x_dock_start_time            OUT     NOCOPY DATE,
   x_dock_end_time              OUT     NOCOPY DATE,
   x_expected_time              OUT     NOCOPY DATE)
  IS
     l_api_name           CONSTANT VARCHAR2(30) := 'Get_Expected_Delivery_Time';
     l_progress           VARCHAR2(10);
     l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     -- This variable is used to indicate if the custom API was used to determine
     -- the expected time values.
     l_api_is_implemented BOOLEAN;

     -- Variable to store the dock schedule method for outbound demand lines
     -- from the crossdock criterion entered
     l_dock_schedule_method     NUMBER;

     -- Cursor to retrieve the trip stop id, carrier id, min expected ship date and max
     -- expected ship date (without considering dock appointments) for a given delivery.
     -- The carrier and expected ship dates come from the set of outbound WDD/OOL records
     -- already assigned to the delivery.
     CURSOR delivery_rec_cursor IS
	SELECT wnd.organization_id AS organization_id,
	  wts.stop_id AS trip_stop_id,
	  MIN(NVL(wt.carrier_id,
	          NVL(NVL(wnd.carrier_id, wcs_wnd.carrier_id),
		      NVL(NVL(wdd.carrier_id, wcs_wdd.carrier_id),
		          NVL(wc_ool.carrier_id, wcs_ool.carrier_id))))) AS carrier_id,
	  MIN(NVL(wts.planned_departure_date,
		  NVL(wdd.date_scheduled,
		      NVL(ool.schedule_ship_date, ool.promise_date)))) AS min_expected_ship_date,
	  MAX(NVL(wts.planned_departure_date,
		  NVL(wdd.date_scheduled,
		      NVL(ool.schedule_ship_date, ool.promise_date)))) AS max_expected_ship_date
	  FROM wsh_new_deliveries wnd, wsh_delivery_details wdd, wsh_delivery_assignments_v wda,
	       wsh_delivery_legs wdl, wsh_trip_stops wts, wsh_trips wt, oe_order_lines_all ool,
	       wsh_carrier_services wcs_wnd, wsh_carrier_services wcs_wdd,
	       wsh_carrier_services wcs_ool, wsh_carriers wc_ool
	  WHERE wnd.delivery_id = p_delivery_id
	  AND wnd.shipment_direction = 'O'
	  AND wnd.delivery_id = wda.delivery_id (+)
	  AND wda.delivery_detail_id = wdd.delivery_detail_id (+)
	  AND wdd.source_line_id = ool.line_id (+)
	  AND wnd.delivery_id = wdl.delivery_id (+)
	  AND (wdl.sequence_number IS NULL OR
	       wdl.sequence_number = (SELECT MIN(sequence_number)
				      FROM wsh_delivery_legs wdl_first_leg
				      WHERE wdl_first_leg.delivery_id = wdl.delivery_id))
	  AND wdl.pick_up_stop_id = wts.stop_id (+)
	  AND wts.trip_id         = wt.trip_id  (+)
	  AND wnd.ship_method_code = wcs_wnd.ship_method_code (+)
	  AND wdd.ship_method_code = wcs_wdd.ship_method_code (+)
	  AND ool.shipping_method_code = wcs_ool.ship_method_code (+)
	  AND ool.freight_carrier_code = wc_ool.freight_code (+)
	  GROUP BY wnd.organization_id, wnd.delivery_id, wts.stop_id;

     -- Variables to retrieve the values from the delivery record cursor
     l_organization_id          NUMBER;
     l_trip_stop_id             NUMBER;
     l_carrier_id               NUMBER;
     l_min_expected_date        DATE;
     l_max_expected_date        DATE;
     l_null_dates_retrieved     BOOLEAN;

     -- Variables for calling the dock appointment API
     l_dock_appt_list           WMS_DOCK_APPOINTMENTS_PUB.dock_appt_tb_tp;

     -- Variables to loop through all dock appointments returned to find the one
     -- closest to the expected receipt/ship time.
     l_dock_appointment_id      NUMBER;
     l_dock_start_time          DATE;
     l_dock_end_time            DATE;
     l_dock_appt_time           DATE;
     l_current_dock_appt_time   DATE;

BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling Get_Expected_Delivery_Time with the following parameters***');
      print_debug('Package Version: ==========> ' || g_pkg_version);
      print_debug('p_delivery_id: ============> ' || p_delivery_id);
      print_debug('p_crossdock_criterion_id: => ' || p_crossdock_criterion_id);
   END IF;

   -- Set the savepoint
   SAVEPOINT Get_Expected_Delivery_Time_sp;
   l_progress := '10';

   -- Initialize message list to clear any existing messages
   fnd_msg_pub.initialize;
   l_progress := '20';

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := '30';

   -- Query and cache the crossdock criterion record
   IF (NOT set_crossdock_criteria(p_crossdock_criterion_id)) THEN
      IF (l_debug = 1) THEN
	 print_debug('Unable to set the crossdock criterion: ' || p_crossdock_criterion_id);
	 RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;
   l_progress := '40';

   -- No need to do the following validation since this can also be called for MOL lines that
   -- were Planned Crossdocked so the crossdock criterion there is of 'Planned' type.
   -- Validate that the crossdock criteria is of 'Opportunistic' type.
   /*IF (g_crossdock_criteria_tb(p_crossdock_criterion_id).criterion_type <> G_CRT_TYPE_OPP) THEN
      IF (l_debug = 1) THEN
	 print_debug('Invalid crossdock criterion type: ' ||
		     g_crossdock_criteria_tb(p_crossdock_criterion_id).criterion_type);
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;*/
   l_progress := '50';

   -- Get the dock schedule method from the crossdock criterion
   -- {{
   -- make sure a valid dock schedule method is retrieved from the crossdock criterion.  }}
   l_dock_schedule_method :=
     g_crossdock_criteria_tb(p_crossdock_criterion_id).demand_schedule_method;
   IF (l_debug = 1) THEN
      print_debug('Dock Schedule Method: ' || l_dock_schedule_method);
   END IF;
   l_progress := '60';
   -- End of validations and initializations


   -- Call the custom logic first to see if the API is implemented or not
   WMS_XDOCK_CUSTOM_APIS_PUB.Get_Expected_Delivery_Time
     (p_delivery_id                => p_delivery_id,
      p_crossdock_criterion_id     => p_crossdock_criterion_id,
      p_dock_schedule_method       => l_dock_schedule_method,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data,
      x_api_is_implemented         => l_api_is_implemented,
      x_dock_appointment_id        => x_dock_appointment_id,
      x_dock_start_time            => x_dock_start_time,
      x_dock_end_time              => x_dock_end_time,
      x_expected_time              => x_expected_time);

   IF (x_return_status = fnd_api.g_ret_sts_success) THEN
      IF (l_debug = 1) THEN
	 print_debug('Success returned from Custom Get_Expected_Delivery_Time API');
      END IF;
    ELSE
      IF (l_debug = 1) THEN
	 print_debug('Failure returned from Custom Get_Expected_Delivery_Time API');
      END IF;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- If the custom API is implemented, just use the values retrieved from there.
   -- Skip all further processing and logic in this API.
   IF (l_api_is_implemented) THEN
      IF (l_debug = 1) THEN
	 print_debug('Custom API is implemented so using custom logic to get expected time');
      END IF;
      GOTO custom_logic_used;
    ELSE
      IF (l_debug = 1) THEN
	 print_debug('Custom API is not implemented so using default logic to get expected time');
      END IF;
   END IF;

   -- Open the delivery record cursor to retrieve the trip stop, carrier and
   -- non-dock appointment derived min and max expected ship times.
   -- {{
   -- Make sure API errors out properly if delivery entered is invalid. }}
   OPEN delivery_rec_cursor;
   FETCH delivery_rec_cursor INTO l_organization_id, l_trip_stop_id, l_carrier_id,
     l_min_expected_date, l_max_expected_date;
   IF (delivery_rec_cursor%NOTFOUND) THEN
      IF (l_debug = 1) THEN
	 print_debug('Delivery cursor did not return any records!');
      END IF;
      CLOSE delivery_rec_cursor;
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;
   CLOSE delivery_rec_cursor;
   l_progress := '70';

   IF (l_debug = 1) THEN
      print_debug('Successfully retrieved data from cursor');
      print_debug('Organization ID: ===> ' || l_organization_id);
      print_debug('Trip Stop ID: ======> ' || l_trip_stop_id);
      print_debug('Carrier ID: ========> ' || l_carrier_id);
      print_debug('Min Expected Date: => ' || TO_CHAR(l_min_expected_date, 'DD-MON-YYYY HH24:MI:SS'));
      print_debug('Max Expected Date: => ' || TO_CHAR(l_max_expected_date, 'DD-MON-YYYY HH24:MI:SS'));
   END IF;
   l_progress := '80';

   -- If values were not returned for the MIN/MAX expected ship dates, just use SYSDATE
   -- with a time of 12:00AM for the start time and 11:59PM for the end time.
   -- Either both or none of the expected ship dates should be NULL.  Set a BOOLEAN variable
   -- to indicate if NULL date values were retrieved from the cursor or not.  This can occur
   -- if no WDD records are assigned to the delivery.
   -- {{
   -- Test for deliveries that do not have any WDD records assigned to them yet. }}
   -- {{
   -- For deliveries with WDD records already assigned to them, make sure the min and max
   -- expected dates are calculated correctly. }}
   IF (l_min_expected_date IS NULL) THEN
      l_null_dates_retrieved := TRUE;
      l_min_expected_date := TRUNC(SYSDATE);
      l_max_expected_date := TO_DATE(TO_CHAR(TRUNC(SYSDATE), 'DD-MON-YYYY') ||
				     ' 23:59:59', 'DD-MON-YYYY HH24:MI:SS');
      IF (l_debug = 1) THEN
	 print_debug('Set the MIN/MAX expected dates to use SYSDATE due to NULL values');
      END IF;
    ELSE
      l_null_dates_retrieved := FALSE;
   END IF;
   l_progress := '85';

   -- If a trip stop is present, query for dock appointments associated with the trip stop.
   -- If a trip stop is passed to this API, the start and end date parameters are ignored
   -- and the first dock appointment associated with the trip stop is returned.  This will
   -- return at most one dock appointment in the output variable table x_dock_appt_list.
   -- CORRECTION TO THE ABOVE:
   -- The dock appointment API, even if a trip stop is passed does take the p_start_date into
   -- account.  Since dock appointment statuses do not exist yet, this API will only look for
   -- dock appointments tied to the trip stop that are >= p_start_date.  This is done so we do
   -- not pick up older dock appointments that have already passed.  (Though that should not be
   -- an issue for dock appointments tied to trip stops).  Thus use SYSDATE for p_start_date
   -- instead of l_min_expected_date.
   -- {{
   -- Get the expected time both with and without a trip stop tied to the delivery. }}
   IF (l_trip_stop_id IS NOT NULL) THEN
      IF (l_debug = 1) THEN
	 print_debug('Call the get_dock_appointment_range API for a trip stop');
      END IF;
      l_progress := '90';

      wms_dock_appointments_pub.get_dock_appointment_range
	(p_api_version       => 1.0,
	 p_init_msg_list     => fnd_api.g_false,
	 x_return_status     => x_return_status,
	 x_msg_count         => x_msg_count,
	 x_msg_data          => x_msg_data,
	 x_dock_appt_list    => l_dock_appt_list,
	 p_organization_id   => l_organization_id,
	 p_start_date        => Trunc(Sysdate), --l_min_expected_date,
	 p_end_date          => l_max_expected_date,
	 p_appointment_type  => G_SRC_TYPE_DEM, -- Outbound Demand type
	 p_supplier_id       => NULL,
	 p_supplier_site_id  => NULL,
	 p_customer_id       => NULL,
	 p_customer_site_id  => NULL,
	 p_carrier_code      => NULL,
	 p_carrier_id        => NULL,
	 p_trip_stop_id      => l_trip_stop_id,
	 p_waybill_number    => NULL,
	 p_bill_of_lading    => NULL,
	 p_master_bol        => NULL);

      IF (l_debug = 1) THEN
	 print_debug('Finished calling the get_dock_appointment_range API');
      END IF;
      l_progress := '100';

      -- Check to see if the get_dock_appointment_range API returned successfully
      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Success returned from get_dock_appointment_range API');
	 END IF;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('Failure returned from get_dock_appointment_range API');
	 END IF;
	x_return_status := fnd_api.g_ret_sts_success;
	 -- do not thrown an error but just go to the next way to calculate time
	 --FND_MESSAGE.SET_NAME('WMS', 'WMS_TD_MO_ERROR');
	 --FND_MSG_PUB.ADD;
	 --RAISE fnd_api.g_exc_error;
      END IF;
      l_progress := '110';
   END IF;

   -- If a dock appointment has not been found yet and a carrier ID is present,
   -- query for dock appointments associated with the carrier.  For the start and end dates,
   -- use the MIN and MAX expected ship dates retrieved from the delivery record cursor.
   -- This will return a list of valid dock appointments (multiple appointments are possible).
   -- {{
   -- Get the expected delivery time both with and without a carrier tied to the delivery. }}
   -- {{
   -- Test for cases where multiple dock appointments are tied to the carrier. }}
   IF (l_dock_appt_list.COUNT = 0 AND l_carrier_id IS NOT NULL) THEN
      IF (l_debug = 1) THEN
	 print_debug('Call the get_dock_appointment_range API for a carrier');
      END IF;
      l_progress := '120';

      wms_dock_appointments_pub.get_dock_appointment_range
	(p_api_version       => 1.0,
	 p_init_msg_list     => fnd_api.g_false,
	 x_return_status     => x_return_status,
	 x_msg_count         => x_msg_count,
	 x_msg_data          => x_msg_data,
	 x_dock_appt_list    => l_dock_appt_list,
	 p_organization_id   => l_organization_id,
	 p_start_date        => l_min_expected_date,
	 p_end_date          => l_max_expected_date,
	 p_appointment_type  => G_SRC_TYPE_DEM, -- Outbound Demand type
	 p_supplier_id       => NULL,
	 p_supplier_site_id  => NULL,
	 p_customer_id       => NULL,
	 p_customer_site_id  => NULL,
	 p_carrier_code      => NULL,
	 p_carrier_id        => l_carrier_id,
	 p_trip_stop_id      => NULL,
	 p_waybill_number    => NULL,
	 p_bill_of_lading    => NULL,
	 p_master_bol        => NULL);

      IF (l_debug = 1) THEN
	 print_debug('Finished calling the get_dock_appointment_range API');
      END IF;
      l_progress := '130';

      -- Check to see if the get_dock_appointment_range API returned successfully
      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	 IF (l_debug = 1) THEN
	    print_debug('Success returned from get_dock_appointment_range API');
	 END IF;
       ELSE
	 IF (l_debug = 1) THEN
	    print_debug('Failure returned from get_dock_appointment_range API');
	 END IF;
	x_return_status := fnd_api.g_ret_sts_success;
	 -- do not thrown an error but just go to the next way to calculate time
	 --FND_MESSAGE.SET_NAME('WMS', 'WMS_TD_MO_ERROR');
	 --FND_MSG_PUB.ADD;
	 --RAISE fnd_api.g_exc_error;
      END IF;
      l_progress := '140';
   END IF;

   IF (l_debug = 1) THEN
      print_debug('Number of dock appointments found: ' || l_dock_appt_list.COUNT);
   END IF;
   l_progress := '150';

   -- See if any dock appointments were found.  If multiple dock appointments exist,
   -- get the one closest to the MAX expected ship date.  Since multiple WDD records could be
   -- assigned to the delivery, the latest expected ship date from that set is the limiting
   -- factor in when the delivery can be shipped out.
   IF (l_dock_appt_list.COUNT > 0) THEN
      -- Loop through all available dock appointments
      -- {{
      -- For multiple dock appointments, make sure the 'closest' one is selected. }}
      FOR i IN l_dock_appt_list.FIRST .. l_dock_appt_list.LAST LOOP
	 IF (i = l_dock_appt_list.FIRST) THEN
	    -- First dock appointment found
	    l_dock_appointment_id := l_dock_appt_list(i).dock_appointment_id;
	    l_dock_start_time := l_dock_appt_list(i).start_time;
	    l_dock_end_time := l_dock_appt_list(i).end_time;

	    -- Based on the dock schedule method (if present) calculate a single
	    -- dock appointment time based on the start and end time.  If multiple dock
	    -- appointments exist, this value will be compared with the MAX expected ship
	    -- date (non-dock appointment) and the closest dock appointment time will be used.
	    IF (l_dock_schedule_method IS NULL OR l_dock_schedule_method = G_APPT_MEAN_TIME) THEN
	       l_dock_appt_time := (l_dock_end_time - l_dock_start_time)/2 + l_dock_start_time;
	     ELSIF (l_dock_schedule_method = G_APPT_START_TIME) THEN
	       l_dock_appt_time := l_dock_start_time;
	     ELSIF (l_dock_schedule_method = G_APPT_END_TIME) THEN
	       l_dock_appt_time := l_dock_end_time;
	    END IF;
	    IF (l_debug = 1) THEN
	       print_debug('Current closest dock appt time: ' ||
			   TO_CHAR(l_dock_appt_time, 'DD-MON-YYYY HH24:MI:SS'));
	    END IF;
	    l_progress := '160';
	  ELSE
	    -- Calculate the current dock appointment time and compare it to the current
	    -- best time to see if this one is even closer to the MAX expected ship date.
	    IF (l_dock_schedule_method IS NULL OR l_dock_schedule_method = G_APPT_MEAN_TIME) THEN
	       l_current_dock_appt_time := (l_dock_appt_list(i).end_time -
					    l_dock_appt_list(i).start_time)/2
		 + l_dock_appt_list(i).start_time;
	     ELSIF (l_dock_schedule_method = G_APPT_START_TIME) THEN
	       l_current_dock_appt_time := l_dock_appt_list(i).start_time;
	     ELSIF (l_dock_schedule_method = G_APPT_END_TIME) THEN
	       l_current_dock_appt_time := l_dock_appt_list(i).end_time;
	    END IF;

	    -- If the dock appointment time is closer to the MAX expected ship date compared
	    -- to the current best time, update the best dock appointment variables to
	    -- point to the current dock appointment.
	    IF (abs(l_current_dock_appt_time - l_max_expected_date) <
		abs(l_dock_appt_time - l_max_expected_date)) THEN
	       l_dock_appointment_id := l_dock_appt_list(i).dock_appointment_id;
	       l_dock_start_time := l_dock_appt_list(i).start_time;
	       l_dock_end_time := l_dock_appt_list(i).end_time;
	       l_dock_appt_time := l_current_dock_appt_time;
	    END IF;
	    IF (l_debug = 1) THEN
	       print_debug('Current closest dock appt time: ' ||
			   TO_CHAR(l_dock_appt_time, 'DD-MON-YYYY HH24:MI:SS'));
	    END IF;
	    l_progress := '170';
	 END IF;
      END LOOP;

      IF (l_debug = 1) THEN
	 print_debug('Closest dock appt ID: =========> ' || l_dock_appointment_id);
	 print_debug('Closest dock appt start time: => ' ||
		     TO_CHAR(l_dock_start_time, 'DD-MON-YYYY HH24:MI:SS'));
	 print_debug('Closest dock appt end time: ===> ' ||
		     TO_CHAR(l_dock_end_time, 'DD-MON-YYYY HH24:MI:SS'));
	 print_debug('Closest dock appt time: =======> ' ||
		     TO_CHAR(l_dock_appt_time, 'DD-MON-YYYY HH24:MI:SS'));
      END IF;
      l_progress := '180';

      -- We have now found the closest dock appointment time to the MAX expected ship time
      x_dock_appointment_id := l_dock_appointment_id;
      x_dock_start_time := l_dock_start_time;
      x_dock_end_time := l_dock_end_time;
      x_expected_time := l_dock_appt_time;
      l_progress := '190';

   END IF; -- End of dock appointments found

   -- If a dock appointment was not found, just use the MIN and MAX expected ship date
   -- retrieved from the cursors as the dock start and end times.  The expected time and
   -- dock appointment ID output variables will be NULL so the caller knows a dock appointment
   -- was not found.  If NULL date values were retrieved from the cursor, this means that no
   -- WDD records are assigned to the delivery.  In that case, return NULL values for the dock
   -- start and end time.
   -- {{
   -- For cases where no dock appointments exist, make sure the min and max expected dates
   -- from the WDD records assigned to the delivery are returned. }}
   -- {{
   -- For deliveries without dock appointments and no WDD records assigned to them, the
   -- expected times returned should all be null. }}
   IF (l_dock_appt_list.COUNT = 0) THEN
      x_dock_appointment_id := NULL;
      IF (l_null_dates_retrieved) THEN
	 x_dock_start_time := NULL;
	 x_dock_end_time := NULL;
       ELSE
	 x_dock_start_time := l_min_expected_date;
	 x_dock_end_time := l_max_expected_date;
      END IF;
      x_expected_time := NULL;
   END IF;
   l_progress := '200';

   IF (l_debug = 1) THEN
      print_debug('Dock Appointment ID: => ' || x_dock_appointment_id);
      print_debug('Dock start time: =====> ' || TO_CHAR(x_dock_start_time, 'DD-MON-YYYY HH24:MI:SS'));
      print_debug('Dock end time: =======> ' || TO_CHAR(x_dock_end_time, 'DD-MON-YYYY HH24:MI:SS'));
      print_debug('Expected time: =======> ' || TO_CHAR(x_expected_time, 'DD-MON-YYYY HH24:MI:SS'));
   END IF;

   <<custom_logic_used>>
   IF (l_debug = 1) THEN
      print_debug('***End of Get_Expected_Delivery_Time***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_Expected_Delivery_Time_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_Expected_Delivery_Time - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_Expected_Delivery_Time_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_Expected_Delivery_Time - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO Get_Expected_Delivery_Time_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_Expected_Delivery_Time - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END Get_Expected_Delivery_Time;
-- {{ }}
-- {{******************** End Get_Expected_Delivery_Time ********************}}
-- {{ }}


END WMS_XDOCK_PEGGING_PUB;


/
