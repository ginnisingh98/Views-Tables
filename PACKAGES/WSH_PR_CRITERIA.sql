--------------------------------------------------------
--  DDL for Package WSH_PR_CRITERIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PR_CRITERIA" AUTHID CURRENT_USER AS
/* $Header: WSHPRCRS.pls 120.5.12010000.3 2009/12/03 14:16:41 gbhargav ship $ */
--
-- Package
--	   WSH_PR_CRITERIA
--
-- Purpose
--   This package does the following:
--   - Initializes the picking criteria
--   - Initializes the grouping rule
--   - Open and fetch unreleased and/or backordered line details
--

   --
   -- PACKAGE TYPES
   --
	  TYPE relRecTyp IS RECORD (
		  source_line_id	   NUMBER,
		  source_header_id	   NUMBER,
		  organization_id	   NUMBER,
		  inventory_item_id	   NUMBER,
		  move_order_line_id	   NUMBER,
		  delivery_detail_id	   NUMBER,
		  ship_model_complete_flag VARCHAR2(1),
		  top_model_line_id	   NUMBER,
		  ship_from_location_id	   NUMBER,
		  ship_method_code	   VARCHAR2(30),
		  shipment_priority	   VARCHAR2(30),
		  date_scheduled	   DATE,
		  requested_quantity	   NUMBER,
		  requested_quantity_uom   VARCHAR2(3),
		  project_id		   NUMBER,
		  task_id		   NUMBER,
		  from_sub		   VARCHAR2(10),
		  to_sub		   VARCHAR2(10),
		  planned_departure_date   DATE,
		  delivery_id		   NUMBER,
		  unit_number		   VARCHAR2(30),
		  source_doc_type	   NUMBER,
		  -- hverddin 27-Jun-00 Start Of OPM Changes
                  -- HW OPMCONV grade is 150
		  preferred_grade	   VARCHAR2(150),
		  requested_quantity2	   NUMBER,
		  requested_quantity_uom2  VARCHAR2(3),
		  -- hverddin 27-Jun-00 End Of OPM Changes
		  demand_source_header_id  NUMBER,
		  released_status	   VARCHAR2(1),
		  ship_set_id		   NUMBER,
		  top_model_quantity	   NUMBER,
		  source_code		   VARCHAR2(30),
		  source_header_number	   VARCHAR2(150),
                  line_number              NUMBER,
                  customer_id              WSH_DELIVERY_DETAILS.CUSTOMER_ID%TYPE, -- X-dock, as requested by INV team
                  -- Standalone project Changes start
                  revision                 VARCHAR2(3),
                  from_locator             NUMBER,
                  lot_number               VARCHAR2(32),
                  -- Standalone project Changes end
                  non_reservable_flag      VARCHAR2(1),  -- ECO 5220234
                  client_id                NUMBER  -- LSP PROJECT:
	  );

	  TYPE relRecTabTyp IS TABLE OF relRecTyp INDEX BY BINARY_INTEGER;

   --
   -- PUBLIC CONSTANTS
   --
	  -- Indicates whether the process is online or conccuent
	  C_CONCUR			   CONSTANT  BINARY_INTEGER := 1;
	  C_ONLINE			   CONSTANT  BINARY_INTEGER := 2;

	  C_IMMEDIATE_PRINT_PS   CONSTANT  BINARY_INTEGER := 3;
	  C_DEFERRED_PRINT_PS	CONSTANT  BINARY_INTEGER := 4;

   --
   -- PUBLIC VARIABLES
   --
	  release_table				   relRecTabTyp;
	  g_application_id				NUMBER;
	  g_program_id					NUMBER;
	  g_request_id					NUMBER;
	  g_user_id					   NUMBER;
	  g_login_id					  NUMBER;
	  g_batch_name					VARCHAR2(30);
	  g_to_subinventory			   VARCHAR2(10);
	  g_to_locator					NUMBER;
	  g_from_subinventory			 VARCHAR2(10);
	  g_from_locator				  NUMBER;
	  g_trip_id					   NUMBER;
	  g_trip_stop_id				  NUMBER;
	  g_ship_from_loc_id			  NUMBER;
	  g_delivery_id				   NUMBER;
	  g_del_detail_id				 NUMBER;
          g_order_type_id                           NUMBER;  --Bugfix 3604021
	  g_order_header_id			   NUMBER;
	  g_organization_id			   NUMBER;
	  g_autodetail_flag			   VARCHAR2(1);
	  g_auto_pick_confirm_flag		VARCHAR2(1);
	  g_pick_seq_rule_id			  NUMBER;
	  g_pick_grouping_rule_id		 NUMBER;
	  g_autocreate_deliveries		 VARCHAR2(1);
	  g_autopack_flag				 VARCHAR2(1);
	  g_autopack_level				NUMBER;
	  g_auto_ship_confirm_rule_id	 NUMBER;
	  g_non_picking_flag			  VARCHAR2(1);
	  g_use_autocreate_del_orders	 VARCHAR2(1) := 'Y';
	  g_primary_psr				   VARCHAR2(30);
	  g_submission					NUMBER := C_CONCUR;
	  g_suppress_print				VARCHAR2(1) := FND_API.G_FALSE;
	  g_doc_set_id					NUMBER;
	  g_existing_rsvs_only_flag	   VARCHAR2(1);
	  -- To set flag that at least one Non-Reservable Item exists
	  g_nonreservable_item			VARCHAR2(1) := 'N';
	  g_task_planning_flag			VARCHAR2(1) := 'N';
	  --
	  -- rlanka : Pack J Pick Release enhancement
          --
	  g_CategoryID		NUMBER;
  	  g_CategorySetID	NUMBER;
          g_RelSubInventory	VARCHAR2(10);
	  g_RegionID		NUMBER;
 	  g_ZoneID		NUMBER;
	  g_acDelivCriteria	VARCHAR2(1);
	  g_from_request_date    DATE;
          g_to_request_date      DATE;
          g_from_sched_ship_date DATE;
          g_to_sched_ship_date   DATE;
	  -- deliveryMerge
	  g_append_flag                         VARCHAR2(1);

          -- Bug #3266659 : Shipset/SMC Criteria
	  g_ship_set_smc_flag                   VARCHAR2(1);

          -- To set if Delivery is part of Pick Slip Grouping rule
           g_use_delivery_ps    VARCHAR2(1) := 'N';

          -- X-dock
          g_allocation_method     VARCHAR2(1);
          g_crossdock_criteria_id NUMBER;

          g_actual_departure_date DATE;

          g_credit_check_option VARCHAR2(1) := NULL;

          g_sql_stmt 	VARCHAR2(32767);

          MAX_LINES       NUMBER := 52;

	     -- Bug 4775539
        g_honor_pick_from  VARCHAR2(1) :='Y';
        --bug# 6689448 (replenishment project)
        g_dynamic_replenishment_flag VARCHAR2(1);

   --
   -- PUBLIC FUNCTIONS/PROCEDURES
   --

-- Start of comments
-- API name : Init
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to initializes session and criteria for pick release. Api does
--            1. Initializes variables for the session
--            2. Retrieves criteria for the batch and sets up session variables.
--            3. Locks row for the batch
--            4. Update who columns for the batch
-- Parameters :
-- IN:
--      p_batch_id            IN  batch to be processed
--      p_worker_id            IN  batch to be processed
-- OUT:
--      x_api_status          OUT NOCOPY  Standard to output api status.
-- End of comments
Procedure Init (
	  p_batch_id	IN  NUMBER,
	  p_worker_id	IN  NUMBER,
	  x_api_status	OUT NOCOPY VARCHAR2
   );


-- Start of comments
-- API name : Init_Rules
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to retrieves  sequencing information based on sequence rule and
--            group information based on grouping rule.
-- Parameters :
-- IN:
--      p_pick_seq_rule_id            IN  pick sequence rule id.
--      p_pick_grouping_rule_id       IN  pick grouping rule id.
-- OUT:
--      x_api_status     OUT NOCOPY  Standard to output api status.
-- End of comments
PROCEDURE Init_Rules (
	  p_pick_seq_rule_id		   IN	  NUMBER,
	  p_pick_grouping_rule_id	   IN	  NUMBER,
	  x_api_status			   OUT NOCOPY	  VARCHAR2
   );

-- Start of comments
-- API name : Get_Worker_Records
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to get worker records for a specific batch_id and organization_id combination
--            based on the mode (PICK-SS / PICK)
-- Parameters :
-- IN:
--      p_mode                IN  Mode (Valid Values : PICK-SS and PICK)
--      p_batch_id            IN  batch to be processed
--      p_organization_id     IN  Organization to be processed
-- OUT:
--      x_api_status                 OUT NOCOPY  Standard to output api status.
-- End of comments
PROCEDURE Get_Worker_Records (
          p_mode             IN  VARCHAR2,
          p_batch_id         IN  NUMBER,
          p_organization_id  IN  NUMBER,
          x_api_status       OUT NOCOPY     VARCHAR2
   );


-- Start of comments
-- API name : Init_Cursor
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to creates a dynamic SQL statement for delivery lines based on release criteria .
--
-- Parameters :
-- IN:
--      p_organization_id               IN  Organization id.
--      p_mode                          IN  Mode, valid value SUMMARY/WORKER.
--      p_wms_org                       IN  Is Organization WMS enabled, valid value Y/N.
--      p_mo_header_id                  IN  Move Order Header id.
--      p_inv_item_id                   IN  Inventory Item id.
--      p_enforce_ship_set_and_smc      IN  Whether to enforce Ship Set and SMC validate value Y/N.
--      p_print_flag                    IN  If need to print the value in log file.
--      p_express_pick                  IN  If express pick, valid value Y/N.
--      p_batch_id                      IN  Batch to be processed.
-- OUT:
--      x_worker_count     OUT NOCOPY  Worker Records Count.
--      x_smc_worker_count OUT NOCOPY  SMC Worker Records Count.
--      x_dd_count         OUT NOCOPY  Delivery Details Records Count.
--      x_api_status       OUT NOCOPY  Standard to output api status.
-- End of comments

Procedure Init_Cursor (
          p_organization_id            IN         NUMBER,
          p_mode                       IN         VARCHAR2,
          p_wms_org                    IN         VARCHAR2,
          p_mo_header_id               IN         NUMBER,
          p_inv_item_id                IN         NUMBER,
          p_enforce_ship_set_and_smc   IN         VARCHAR2,
          p_print_flag                 IN         VARCHAR2,
          p_express_pick               IN         VARCHAR2,
          p_batch_id                   IN         NUMBER,
          x_worker_count               OUT NOCOPY NUMBER,
          x_smc_worker_count           OUT NOCOPY NUMBER,
          x_dd_count                   OUT NOCOPY NUMBER,
          x_api_status                 OUT NOCOPY VARCHAR2
   ) ;

-- Start of comments
-- API name : Get_Lines
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API This routine returns information about the lines that
--            are eligible for release.
--            1.Open the dynamic cursor for sql generated in api Init_Cursor for fetching.
--            2. It fetches rows from the cursor for unreleased and backordered lines, and inserts the each
--            row in the release_table based on the release sequence rule.
-- Parameters :
-- IN:
--      p_enforce_ship_set_and_smc      IN  Whether to enforce Ship Set and SMC validate value Y/N.
--      p_wms_flag                      IN  Org is WMS enabled or not. Valid values Y/N.
--      p_express_pick_flag             IN  Express Pick is enabled or not , Valid Values Y/N.
--      p_batch_id                      IN  Pick Release Batch ID.
-- OUT:
--      x_done_flag         OUT NOCOPY  whether all lines have been fetched
--      x_api_status        OUT NOCOPY  Standard to output api status.
-- End of comments
Procedure Get_Lines (
	  p_enforce_ship_set_and_smc 	IN  VARCHAR2,
	  p_wms_flag 	                IN  VARCHAR2,
	  p_express_pick_flag 	        IN  VARCHAR2,
	  p_batch_id 	                IN  NUMBER,
	  x_done_flag			OUT NOCOPY  VARCHAR2,
	  x_api_status		   	OUT NOCOPY  VARCHAR2
   );

END WSH_PR_CRITERIA;

/
