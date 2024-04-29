--------------------------------------------------------
--  DDL for Package WSH_PICK_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PICK_LIST" AUTHID CURRENT_USER AS
/* $Header: WSHPGSLS.pls 120.8.12010000.3 2008/09/15 12:55:57 gbhargav ship $ */

--
-- Package
--        WSH_PICK_LIST
--
-- Purpose
--   This package does the following:
--   - Generate selection list
--   - Call Move Order APIs to create reservations and to print Pick Slips
--

--
-- DECLARE CONSTANTS FOR X-DOCK
--
   C_INVENTORY_ONLY       CONSTANT VARCHAR2(1) := 'I';
   C_CROSSDOCK_ONLY       CONSTANT VARCHAR2(1) := 'C';
   C_PRIORITIZE_CROSSDOCK CONSTANT VARCHAR2(1) := 'X';
   C_PRIORITIZE_INVENTORY CONSTANT VARCHAR2(1) := 'N';
--

--  1729516 G_BATCH_ID is now initialized to NULL
   G_BATCH_ID            NUMBER  := NULL;
   G_BACKORDERED         BOOLEAN := FALSE;
   G_SEED_DOC_SET        NUMBER  := NULL;
   G_AUTO_PICK_CONFIRM   VARCHAR2(1) := NULL;
   G_PICK_REL_PARALLEL   BOOLEAN := FALSE;
   G_NUM_WORKERS         NUMBER;
   G_ASSIGNED_DEL_TBL    WSH_UTIL_CORE.Id_Tab_Type;

   TYPE unassign_delivery_id_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   G_UNASSIGNED_DELIVERY_IDS      WSH_PICK_LIST.unassign_delivery_id_type;

   --Bug 7171766
   TYPE  group_match_seq_rec_type IS RECORD (
	delivery_detail_id NUMBER,
        match_group_id NUMBER,
        delivery_group_id NUMBER
        );

   TYPE group_match_seq_tab_type IS TABLE OF group_match_seq_rec_type
   INDEX BY BINARY_INTEGER;

   --bug 7171766 till here


   TYPE Org_Params_Rec IS RECORD (
        WMS_ORG                       VARCHAR2(1),
        EXPRESS_PICK_FLAG             VARCHAR2(1),
        AUTO_PICK_CONFIRM             VARCHAR2(1),
        AUTODETAIL_FLAG               WSH_SHIPPING_PARAMETERS.AUTODETAIL_PR_FLAG%TYPE,
        AUTOCREATE_DELIVERIES         WSH_SHIPPING_PARAMETERS.AUTOCREATE_DEL_ORDERS_PR_FLAG%TYPE,
        PICK_SEQ_RULE_ID              WSH_SHIPPING_PARAMETERS.PICK_SEQUENCE_RULE_ID%TYPE,
        PICK_GROUPING_RULE_ID         WSH_SHIPPING_PARAMETERS.PICK_GROUPING_RULE_ID%TYPE,
        AUTOPACK_LEVEL                WSH_SHIPPING_PARAMETERS.AUTOPACK_LEVEL%TYPE,
        USE_HEADER_FLAG               WSH_SHIPPING_PARAMETERS.AUTOCREATE_DEL_ORDERS_PR_FLAG%TYPE,
        AUTO_APPLY_ROUTING_RULES      WSH_SHIPPING_PARAMETERS.AUTO_APPLY_ROUTING_RULES%TYPE,
        AUTO_CALC_FGT_RATE_CR_DEL     WSH_SHIPPING_PARAMETERS.AUTO_CALC_FGT_RATE_CR_DEL%TYPE,
        TASK_PLANNING_FLAG            WSH_SHIPPING_PARAMETERS.TASK_PLANNING_FLAG%TYPE,
        PRINT_PICK_SLIP_MODE          WSH_SHIPPING_PARAMETERS.PRINT_PICK_SLIP_MODE%TYPE,
        APPEND_FLAG                   WSH_SHIPPING_PARAMETERS.APPENDING_LIMIT%TYPE,
        DOC_SET_ID                    WSH_SHIPPING_PARAMETERS.PICK_RELEASE_REPORT_SET_ID%TYPE,
        TO_SUBINVENTORY               WSH_SHIPPING_PARAMETERS.DEFAULT_STAGE_SUBINVENTORY%TYPE,
        TO_LOCATOR                    WSH_SHIPPING_PARAMETERS.DEFAULT_STAGE_LOCATOR_ID%TYPE,
        ENFORCE_SHIP_SET_AND_SMC      WSH_SHIPPING_PARAMETERS.ENFORCE_SHIP_SET_AND_SMC%TYPE,
        DYNAMIC_REPLENISHMENT_FLAG    WSH_SHIPPING_PARAMETERS.DYNAMIC_REPLENISHMENT_FLAG%TYPE  --bug# 6689448 (replenishment project)
        );

   TYPE Org_Params_Rec_Tbl IS TABLE OF Org_Params_Rec INDEX BY BINARY_INTEGER;

   -- X-dock, moved out of body to spec
   TYPE DelDetTabTyp IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- PUBLIC FUNCTIONS/PROCEDURES

-- Start of comments
-- API name : Release_Batch_Sub
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: This is core api to pick release a batch, api does
--            1. Gets initializes batch criteria.
--            2. Select details lines based on release criteria.
--            3. Calls Inventory Move Order api for allocation and pick confirmation.
--            4. Create/Appened deliveries, pack or ship confirmed based on release criteria.
--            5. Print document sets.
-- Parameters :
-- IN:
--      p_batch_id            IN  Batch Id.
--      p_worker_id           IN  Worker Id.
--      p_mode                IN  Mode.
--      p_log_level           IN  Set the debug log level.
-- OUT:
--      errbuf       OUT NOCOPY  Error message.
--      retcode      OUT NOCOPY  Error Code 1:Successs, 2:Warning and 3:Error.
-- End of comments
PROCEDURE Release_Batch_Sub(
      errbuf                            OUT NOCOPY      VARCHAR2,
      retcode                           OUT NOCOPY      VARCHAR2,
      p_batch_id                        IN      NUMBER,
      p_worker_id                       IN      NUMBER,
      p_mode                            IN      VARCHAR2,
      p_log_level                       IN      NUMBER  DEFAULT 0
   );


-- Start of comments
-- API name : Release_Batch
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: This is core api to pick release a batch, api does
--            1. Gets initializes batch criteria.
--            2. Select details lines based on release criteria.
--            3. Calls Inventory Move Order api for allocation and pick confirmation.
--            4. Create/Appened deliveries, pack or ship confirmed based on release criteria.
--            5. Print document sets.
-- Parameters :
-- IN:
--      p_batch_id            IN  Batch Id.
--      p_log_level           IN  Set the debug log level.
--      p_num_workers         IN  Number of workers
-- OUT:
--      errbuf       OUT NOCOPY  Error message.
--      retcode      OUT NOCOPY  Error Code 1:Successs, 2:Warning and 3:Error.
-- End of comments
PROCEDURE Release_Batch(
      errbuf			        OUT NOCOPY   	VARCHAR2,
      retcode 			        OUT NOCOPY  	VARCHAR2,
      p_batch_id                        IN      NUMBER,
      p_log_level                       IN      NUMBER  DEFAULT 0,
      p_num_workers                     IN      NUMBER
   );
 -- Bug # 2231365 : Defaulted the parameter p_log_level to 0


-- Start of comments
-- API name : Release_Batch_SRS
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: This procedure gets the defaults from Shipping Parameters and
--            generate the batch id.  It saves to the picking batch table and
--            call Release_Batch. It is called from Pick Release SRS.
-- Parameters :
-- IN:
--      p_batch_prefix        IN  Batch Id.
--      p_rule_id             IN  Rule Id.
--      p_log_level           IN  Set the debug log level.
--      p_num_workers         IN  Number of workers
-- OUT:
--      errbuf       OUT NOCOPY  Error message.
--      retcode      OUT NOCOPY  Error Code 1:Successs, 2:Warning and 3:Error.
-- End of comments
PROCEDURE Release_Batch_SRS (
      errbuf                            OUT NOCOPY   VARCHAR2,
      retcode                           OUT NOCOPY   VARCHAR2,
      p_rule_id                         IN  NUMBER,
      p_batch_prefix                    IN  VARCHAR2,
      p_log_level                       IN  NUMBER, -- log level fix
      p_ship_confirm_rule_id            IN  NUMBER DEFAULT NULL,
      p_actual_departure_date           IN  VARCHAR2 DEFAULT NULL,
      p_num_workers                     IN  NUMBER
   );


-- Start of comments
-- API name : Online_Release
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: This procedure calls Release_Batch based on batch id passed,
--            this is call from Release Sales Order from in online mode.
-- Parameters :
-- IN:
--      p_batch_id            IN  Batch Id.
-- OUT:
--      p_pick_result     OUT NOCOPY  Pick Release Phase, Valid value 'START','MOVE ORDER LINE','SUCCESS'.
--      p_pick_phase      OUT NOCOPY  Pick Release Result,Valid value Success,Warning,Error
--      p_pick_skip       OUT NOCOPY  If Pick Release has been skip, valid value Y/N.
-- End of comments
PROCEDURE Online_Release (
      p_batch_id                        IN      NUMBER ,
      p_pick_result                     OUT NOCOPY      VARCHAR2,
      p_pick_phase                      OUT NOCOPY      VARCHAR2,
      p_pick_skip                       OUT NOCOPY      VARCHAR2);


-- Start of comments
-- API name : Launch_Pick_Release
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to launch pick Release process based on input entity passed. Api dose
--            1. Get the Entity name for the passed entity
--            2. Get the entity status.
--            3. Create picking batch by calling WSH_PICKING_BATCHES_PKG.Insert_Row.
--            4. Update the detail lines with batch id.
--            5. Submit request to release batch created by calling WSH_PICKING_BATCHES_PKG.Submit_Release_Request
-- Parameters :
-- IN:
--      p_trip_ids            IN  Trip id.
--      p_stop_ids            IN  Stop Id.
--      p_delivery_ids        IN  Delivery id.
--      p_detail_ids          IN  Delivery detail Id.
--      p_auto_pack_ship      IN  SC - Auto Ship Confirm after Pick Release
--                                PS - Auto Pack and Ship Confirm after Pick Release.
-- OUT:
--      x_return_status     OUT NOCOPY  Standard to output api status.
--      x_request_ids       OUT NOCOPY  Request ID of concurrent program.
-- End of comments
-- bug# 6719369 (replenishment project): For dynamic replenishment case, WMS passes the delivery detail ids as well as
-- the picking batch id value. In this case it shoud create a new batch by taking the attribute values from the old batch
-- information.
PROCEDURE Launch_Pick_Release(
     p_trip_ids      	IN  WSH_UTIL_CORE.Id_Tab_Type,
     p_stop_ids      	IN  WSH_UTIL_CORE.Id_Tab_Type,
     p_delivery_ids  	IN  WSH_UTIL_CORE.Id_Tab_Type,
     p_detail_ids    	IN  WSH_UTIL_CORE.Id_Tab_Type,
     x_request_ids   	OUT NOCOPY  WSH_UTIL_CORE.Id_Tab_Type,
     p_auto_pack_ship  IN VARCHAR2 DEFAULT NULL,
     p_batch_id        IN NUMBER   DEFAULT NULL, -- bug# 6719369 (replenishment project)
     x_return_status   OUT NOCOPY  VARCHAR2
  );


-- Start of comments
-- API name : Calculate_Reservations
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: API to calculate the Reservations quantity, api does
--            1. Scan through global demand table and find out if reservation exists for input header and line.
--            2. If not fetch the reservation from inventory reservation table.
--            3. Calculate the reservation quantity.
-- Parameters :
-- IN:
--      p_demand_source_header_id        IN  Demand hedaer id.
--      p_demand_source_line_id          IN  Demand line id.
--      p_requested_quantity             IN  Requested Quantity.
-- OUT:
--      x_result       OUT NOCOPY Reservations quantity.
-- End of comments
 -- HW OPMCONV - Added parameters: 1) p_requested_quantity2
 --                                2) x_result2
 --Bug 4775539 Added 4 new in parameters
PROCEDURE Calculate_Reservations(
     p_demand_source_header_id IN NUMBER,
     p_demand_source_line_id   IN NUMBER,
     p_requested_quantity      IN NUMBER,
     --Bug 4775539
     p_requested_quantity_uom     IN VARCHAR2,
     p_src_requested_quantity_uom IN VARCHAR2,
     p_src_requested_quantity     IN NUMBER,
     p_inv_item_id                IN NUMBER,
     p_requested_quantity2     IN NUMBER default NULL,
     x_result                  OUT NOCOPY  NUMBER,
     x_result2                 OUT NOCOPY  NUMBER);


/* rlanka : Pack J Enhancement */
-- Start of comments
-- API name : CalcWorkingDay
-- Type     : Public
-- Pre-reqs : None.
-- Procedure: This procedure uses the shipping calendar to determine
--            the next (or) prior working day.  Used if the picking rule has dynamic date components.
-- Parameters :
-- IN:
--      p_orgID            IN  Organization Id.
--      p_days             IN  Days in Number 1-31.
--      p_Time             IN  Time.
--      p_CalCode          IN  Shipping Calender Code.
-- OUT:
--      x_date       OUT NOCOPY Working days date.
-- End of comments
PROCEDURE CalcWorkingDay(p_orgID 	IN NUMBER,
                           p_PickRule   IN VARCHAR2, --Added bug 7316707
			   p_days 	IN NUMBER,
			   p_Time 	IN NUMBER,
                           p_CalCode 	IN VARCHAR2,
		           x_date 	IN OUT NOCOPY DATE);
END WSH_PICK_LIST;

/
