--------------------------------------------------------
--  DDL for Package Body WSH_PR_CRITERIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PR_CRITERIA" AS
/* $Header: WSHPRCRB.pls 120.17.12010000.10 2010/02/16 07:09:50 mvudugul ship $ */
   --
   -- PACKAGE TYPES
   --
   --Record type to store attributes of order.
   TYPE psrTyp IS RECORD (
		 attribute		 NUMBER,
		 attribute_name	 VARCHAR2(30),
		 priority		  NUMBER,
		 sort_order		 VARCHAR2(4));

   TYPE psrTabTyp IS TABLE OF psrTyp INDEX BY BINARY_INTEGER;

   -- dramamoo 09-Mar-01 Start of Table to store Detailed List IDs instead of using Concatenated String
   TYPE psrDetLst IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;


   CURSOR c_work_cursorID(l_batch_id NUMBER, l_organization_id NUMBER, l_mode VARCHAR2) IS
          SELECT organization_id, inventory_item_id, mo_start_line_number, mo_line_count,ROWID -- Bug # 9369504 : added rowid
          FROM   wsh_pr_workers
          WHERE  batch_id = l_batch_id
          AND    organization_id = l_organization_id
          AND    type = 'PICK'
          AND    processed = 'N'
          AND    l_mode = 'PICK'
          UNION
          SELECT organization_id, inventory_item_id, mo_start_line_number, mo_line_count,ROWID -- Bug # 9369504 : added rowid
          FROM   wsh_pr_workers
          WHERE  batch_id = l_batch_id
          AND    organization_id = l_organization_id
          AND    type = 'PICK'
          AND    processed = 'N'
          AND    inventory_item_id IS NULL
          AND    l_mode = 'PICK-SS'
          ORDER BY 1, 2 DESC;

   --
   -- PACKAGE CONSTANTS

   -- Indicate what attributes are used in Pick Sequence Rules
   C_INVOICE_VALUE	 CONSTANT  BINARY_INTEGER := 1;
   C_ORDER_NUMBER	  CONSTANT  BINARY_INTEGER := 2;
   C_SCHEDULE_DATE	 CONSTANT  BINARY_INTEGER := 3;
   C_TRIP_STOP_DATE	CONSTANT  BINARY_INTEGER := 4;
   C_SHIPMENT_PRIORITY CONSTANT  BINARY_INTEGER := 5;

   --
   -- PACKAGE VARIABLES
   --
	  g_use_trip_stop_date			BOOLEAN := FALSE;
	  g_initialized	               BOOLEAN := FALSE;
	  g_ordered_psr	               psrTabTyp;
	  g_use_order_ps	              VARCHAR2(1) := 'Y';
	  g_invoice_value_flag			VARCHAR2(1) := 'N';
	  g_total_pick_criteria		   NUMBER;
       -- g_order_type_id				 NUMBER; -- Bugfix 3604021
	  g_order_line_id				 NUMBER;
	  g_backorders_flag               VARCHAR2(1);
	  g_include_planned_lines		 VARCHAR2(1);
	  g_details_list	              VARCHAR2(100);
	  g_customer_id	               NUMBER;
	  g_inventory_item_id			 NUMBER;
	  g_shipment_priority			 VARCHAR2(30);
	  g_ship_method_code              VARCHAR2(30);
	  g_ship_set_number               NUMBER;
	  g_ship_to_loc_id				NUMBER;
	  g_project_id					NUMBER;
	  g_task_id		               NUMBER;
	  g_Unreleased_SQL				VARCHAR(3000) := NULL;
	  g_Backordered_SQL               VARCHAR(3000) := NULL;
	  g_Cond_SQL		              VARCHAR(2000) := NULL;
	  g_orderby_SQL	               VARCHAR2(500) := NULL;

	  g_lock_or_hold_failed			 BOOLEAN := FALSE;
	  g_failed_ship_set_id              NUMBER  := NULL;
	  g_failed_top_model_line_id		NUMBER  := NULL;
	  g_last_ship_set_id				NUMBER  := NULL;
 	  g_last_top_model_line_id		  NUMBER  := NULL;
	  g_last_model_quantity			 NUMBER  := NULL;
	  g_last_header_id	              NUMBER  := NULL;
	  g_last_source_code				VARCHAR2(30) := NULL;
          --
          -- LSP PROJECT : begin
          g_client_id	                  NUMBER;
          v_client_id                    NUMBER;
          -- LSP PROJECT : end

	  -- dramamoo 09-Mar-01 Start of Table to store Detailed List IDs instead of using Concatenated String
	  g_det_lst	              psrDetLst;

	  --Bug 4775539
	  g_cache_header_id                               NUMBER;
          g_cache_demand_header_id                        NUMBER;

	  -- selected from cursors
	  v_count               NUMBER;
	  v_line_id               NUMBER;
	  v_header_id               NUMBER;
	  v_org_id               NUMBER;
	  v_inventory_item_id		   NUMBER;
	  v_move_order_line_id	           NUMBER;
	  v_delivery_detail_id	           NUMBER;
	  v_ship_model_complete_flag       VARCHAR2(1);
	  v_top_model_line_id		   NUMBER;
	  v_ship_from_location_id	   NUMBER;
	  v_ship_method_code		   VARCHAR2(30);
	  v_shipment_priority		   VARCHAR2(30);
	  v_date_scheduled		   DATE;
	  v_requested_quantity	           NUMBER;
	  v_requested_quantity_uom         VARCHAR2(3);
	  v_project_id               NUMBER;
	  v_task_id               NUMBER;
	  v_from_sub               VARCHAR2(10);
	  v_to_sub               VARCHAR2(10);
	  v_released_status		   VARCHAR2(1);
	  v_ship_set_id               NUMBER;
	  v_model_quantity		   NUMBER;
	  v_source_code               VARCHAR2(30);
	  v_source_header_number	   VARCHAR2(150);
	  v_planned_departure_date         DATE;
	  v_delivery_id               NUMBER;
	  v_unit_number               VARCHAR2(30);
	  v_source_doc_type		   NUMBER;
	  v_demand_source_header_id        NUMBER;
	  v_invoice_value		   INTEGER;
	  v_cursorID               INTEGER;
          v_pr_org_id                      NUMBER;
          v_pr_inv_item_id                 NUMBER;
          v_pr_mo_header_id                NUMBER;
          v_pr_mo_line_number              NUMBER;
          v_pr_mo_line_count               NUMBER;
          v_total_rec_fetched              NUMBER := 0;
          v_prev_item_id                   NUMBER;
	  v_ignore               INTEGER;
	  v_reservable_type		   VARCHAR2(1);
          v_last_update_date               DATE; --Bug# 3248578

          v_customer_id                    NUMBER;-- anxsharm, X-dock
          -- Standalone project Changes Start
          v_revision                       VARCHAR2(3);
          v_from_locator                   NUMBER;
          v_lot_number                     VARCHAR2(32);
          -- Standalone project Changes end

	  -- hverddin 27-JUN-00 Start Of OPM Changes
-- HW OPMCONV. Need to expand length of grade to 150
	  v_preferred_grade		   VARCHAR2(150);
	  v_requested_quantity2	           NUMBER;
	  v_requested_quantity_uom2        VARCHAR2(3);
	  -- hverddin 27-JUN-00 End Of OPM Changes
      v_rowid                          VARCHAR(200); -- Bug # 9369504
      -- Track local PL/SQL table information
	  g_del_current_line		  NUMBER := 1;
	  g_rel_current_line		  NUMBER := 1;
	  first_line              relRecTyp;

	  -- Return status of procedures
	  g_return_status		 VARCHAR2(1);
	  --

   -- FORWARD DECLARATIONS
   --

   G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_PR_CRITERIA';

   PROCEDURE Insert_RL_Row(
		p_enforce_ship_set_and_smc IN  VARCHAR2,
                x_skip_detail              OUT NOCOPY VARCHAR2, --Bug# 3248578
                x_api_status               OUT NOCOPY  VARCHAR2
	  );

   PROCEDURE Process_Buffer(
		 p_print_flag		IN   VARCHAR2,
		 p_buffer_name	   IN   VARCHAR2,
		 p_buffer_text	   IN   VARCHAR2,
	         p_bind_value	   IN   VARCHAR2 default NULL
	  );


-- Start of comments
-- API name : Validate_SS_SMC
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to validate Ship Set Competitions. Api does
--            1. Checks if any lines in the ship set are not yet imported.
--            2. If number of Ship Set lines in Server Side is not equal to Release table lines, then reset the release table.
-- Parameters :
-- IN:
--      p_ship_set_id         IN      Ship set id.
--      p_top_model_line_id   IN      Top model line id, used when ship_set_id is null.
--      p_order_header_id     IN      Order header id.
-- OUT:
--      x_api_status	 OUT NOCOPY      Standard to output api status.
-- End of comments
PROCEDURE validate_ss_smc(
			p_ship_set_id	   IN  NUMBER,
			p_top_model_line_id IN  NUMBER,
			p_order_header_id   IN  NUMBER,
			p_source_code	   IN  VARCHAR2,
			x_api_status		OUT NOCOPY  VARCHAR2)
   IS
   --
   l_start_index NUMBER := 0;
   l_end_index   NUMBER := 0;
   l_ss_count	NUMBER := 0;
   l_smc_count   NUMBER := 0;
   l_db_count	NUMBER := 0;
   l_status	  BOOLEAN;
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_SS_SMC';
   --
BEGIN
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
		l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
		WSH_DEBUG_SV.log(l_module_name,'P_SHIP_SET_ID',P_SHIP_SET_ID);
		WSH_DEBUG_SV.log(l_module_name,'P_TOP_MODEL_LINE_ID',P_TOP_MODEL_LINE_ID);
		WSH_DEBUG_SV.log(l_module_name,'P_ORDER_HEADER_ID',P_ORDER_HEADER_ID);
		WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
	END IF;
	--
	x_api_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--

	IF l_debug_on THEN
	   WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
	   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit OE_Shipping_Integration_PUB.Check_Import_Pending_Lines',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	-- Checks if any lines in the ship set are not yet imported
        -- Bug :3832310. The call to "WSH_DELIVERY_VALIDATIONS.Check_SS_Imp_Pending"
        -- is changed to "OE_Shipping_Integration_PUB.Check_Import_Pending_Lines".
        -- Since this call is applicable to both ship sets and SMC's make this
        -- call before the IF condition branching the logic for these two kinds of
        -- groupings.

	l_status := OE_Shipping_Integration_PUB.Check_Import_Pending_Lines(
                                              p_header_id          =>  P_ORDER_HEADER_ID,
                                              p_ship_set_id        =>  p_ship_set_id,
                                              p_top_model_line_id  =>  P_TOP_MODEL_LINE_ID,
                                              p_transactable_flag  => 'Y',
                                              x_return_status      =>  x_api_status );

	IF (x_api_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	   IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,  'UNEXPECTED ERROR FROM WSH_DELIVERY_VALIDATIONS.CHECK_SS_IMP_PENDING');
	     WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
	   RETURN;
	END IF;

	IF (p_ship_set_id IS NOT NULL) THEN
	--{

          IF (l_status = FALSE) THEN
            --All lines in SS are imported

	    SELECT count(*)
	    INTO   l_ss_count
	    FROM   wsh_delivery_details
	    WHERE  ship_set_id	  = p_ship_set_id
	    AND	source_header_id = p_order_header_id
	    AND	source_code	  = p_source_code
	    AND	released_status  IN ('R','N','B')
	    AND	pickable_flag	= 'Y';
	    --
	    IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,  'FOUND '||L_SS_COUNT||' RECORDS IN DB'  );
	    END IF;
	    --
	  ELSE

            -- Some of the lines in SS are not imported
	    IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,  'THERE EXISTS A LINE IN THIS SHIP SET WHICH IS NOT YET IMPORTED'  );
	    END IF;
	    --
	    l_ss_count := -1;
	    --
	  END IF;


	  l_start_index := g_rel_current_line - 1;
	  WHILE ((l_start_index > 0) AND
	         (release_table(l_start_index).ship_set_id = p_ship_set_id)) LOOP

	   l_start_index := l_start_index -1;
	  END LOOP;

	  l_end_index := l_start_index;
	  l_start_index := g_rel_current_line - 1;
	  l_db_count := l_start_index - l_end_index;
	  --
	  IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,  'FOUND '||L_DB_COUNT||' RECORDS IN RELEASE_TABLE');
	  END IF;
	  --


	  IF (l_db_count <> l_ss_count) THEN
	    -- release_table SS doesn't match with Database SS
	    IF (l_ss_count <> -1) THEN
	     IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,  'THE DB COUNT FOR SS '||P_SHIP_SET_ID || ' DOES NOT MATCH WITH THE SELECTED RECORD COUNT');
	     END IF;
	    END IF;


	    IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'REMOVING THE SHIP SET FROM RELEASE TABLE');
	    END IF;

            --Removing Ship Set lines from release table as SS doesn't match with Database SS
	    FOR i in l_end_index+1..l_start_index LOOP
	      release_table.delete(i);
	    END LOOP;

	    -- reset the g_rel_current_line after deletion
	    g_rel_current_line := l_end_index + 1;
	    --
	    IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'G_REL_CURRENT_LINE',G_REL_CURRENT_LINE);
	    END IF;
	    --
	  END IF;
	--}
        ELSE --p_ship_set_id is NULL
	--{

	  IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_module_name,  'CHECKING FOR SMC WITH TOP_MODEL_LINE_ID '||P_TOP_MODEL_LINE_ID ||' FOR ORDER HEADER '||P_ORDER_HEADER_ID||' SOURCE CODE '||P_SOURCE_CODE  );
	  END IF;
	  --

          IF (l_status = FALSE) THEN
            --Check for SMC with top_model_line_id
	    SELECT count(*)
	    INTO   l_smc_count
	    FROM   wsh_delivery_details
	    WHERE  top_model_line_id = p_top_model_line_id
	    AND	source_header_id  = p_order_header_id
  	    AND	ship_model_complete_flag = 'Y'
	    AND	source_code	   = p_source_code
	    AND	released_status IN ('R','N','B')
	    AND	pickable_flag	 = 'Y';

	    IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,  'FOUND '||L_SMC_COUNT||' RECORDS IN DB'  );
	    END IF;

          ELSE
            -- Some of the lines in SMC are not imported
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,  'THERE EXISTS A LINE IN THIS SMC SET WHICH IS NOT YET IMPORTED'  );
            END IF;
            --
            l_smc_count := -1;
            --
          END IF;


	  l_start_index := g_rel_current_line - 1;
	  WHILE ((l_start_index > 0) AND
		 (release_table(l_start_index).top_model_line_id = p_top_model_line_id))
	  LOOP
	    l_start_index := l_start_index -1;
	  END LOOP;

	  l_end_index := l_start_index;
	  l_start_index := g_rel_current_line - 1;
	  l_db_count := l_start_index - l_end_index;


	  IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_module_name,'FOUND '||L_DB_COUNT||' RECORDS IN RELEASE_TABLE');
	  END IF;
	  --
	  IF (l_db_count <> l_smc_count) THEN
	   -- release_table SMC count doesn't match with Database SMC count
	   --
	   IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,  'THE DB COUNT FOR SMC '||P_TOP_MODEL_LINE_ID || ' DOES NOT MATCH WITH THE SELECTED RECORD COUNT');
	     WSH_DEBUG_SV.logmsg(l_module_name,  'REMOVING THE SMC FROM RELEASE TABLE'  );
	   END IF;


	   --Removing the SMC lines from Release Table.
	   FOR i in l_end_index+1..l_start_index LOOP
	    release_table.delete(i);
	   END LOOP;


	   -- reset the g_rel_current_line after deletion
	   g_rel_current_line := l_end_index + 1;
	   --
	   IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,  'G_REL_CURRENT_LINE SET BACK TO '||G_REL_CURRENT_LINE  );
	   END IF;
	   --
	  END IF;
	--}
        END IF;


	--
	IF l_debug_on THEN
	  WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
EXCEPTION
         --
	 WHEN OTHERS THEN
	   wsh_util_core.default_handler('WSH_PR_CRITERIA.validate_ss_smc');
	   x_api_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	   --
	   IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
				SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	   END IF;
	   --
END validate_ss_smc;


-- Start of comments
-- API name : Set_Globals
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to set the global variables related to Ship Sets and models.
-- Parameters :
-- IN:
--      p_enforce_ship_set_and_smc	IN  Whether to enforce Ship Set and SMC validate value Y/N.
--      p_ship_set_id         		IN  Ship set id.
--      p_top_model_line_id   		IN  Top model line id.
-- OUT:
--      None
-- End of comments
PROCEDURE Set_Globals(
	  p_enforce_ship_set_and_smc IN VARCHAR2,
	  p_ship_set_id		IN   NUMBER,
	  p_top_model_line_id  IN   NUMBER)
   IS
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SET_GLOBALS';
   --
BEGIN
	 --
	 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	 --
	 IF l_debug_on IS NULL
	 THEN
		 l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	 END IF;
	 --
	 IF l_debug_on THEN
	   WSH_DEBUG_SV.push(l_module_name);
	   WSH_DEBUG_SV.log(l_module_name,'P_ENFORCE_SHIP_SET_AND_SMC',P_ENFORCE_SHIP_SET_AND_SMC);
	   WSH_DEBUG_SV.log(l_module_name,'P_SHIP_SET_ID',P_SHIP_SET_ID);
	   WSH_DEBUG_SV.log(l_module_name,'P_TOP_MODEL_LINE_ID',P_TOP_MODEL_LINE_ID);
	 END IF;
	 --

         --IF only enforce ship set and SMC
	 IF (p_enforce_ship_set_and_smc = 'Y') THEN
		g_lock_or_hold_failed := TRUE;
		g_failed_ship_set_id	   := p_ship_set_id;
		g_failed_top_model_line_id := p_top_model_line_id;
		g_last_ship_set_id	   := p_ship_set_id;
		g_last_top_model_line_id := p_top_model_line_id;
	 END IF;
	 --
	 IF l_debug_on THEN
		 WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
END Set_Globals;


-- Start of comments
-- API name : Get_Detail_Lock
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to lock the delivery detail line for pick release. If locking is successful,then it check
--            for current date with previous retrive last update date, if not same then it re-query the detail lines.
-- Parameters :
-- IN:
--      p_delivery_detail_id      	IN  Delivery detail id.
--      p_ship_set_id                   IN  Ship set id.
--      p_top_model_line_id             IN  Top model line id.
--      p_enforce_ship_set_and_smc      IN  Whether to enforce Ship Set and SMC validate value Y/N.
-- OUT:
--      x_skip_detail       OUT NOCOPY  Ignoring delivery detail since no longer satisfies the pick release criteria,validate value Y/N.
--      x_return_status     OUT NOCOPY  Standard to output api status.
 -- Bug 4775539 added 4 new out variables
-- End of comments

PROCEDURE Get_Detail_Lock(
	  p_delivery_detail_id	   	IN  NUMBER,
	  p_ship_set_id			IN  NUMBER,
	  p_top_model_line_id		IN  NUMBER,
	  p_enforce_ship_set_and_smc 	IN  VARCHAR2,
	  -- Bug 4775539 added 4 new out variables
          x_requested_qty_uom           OUT NOCOPY VARCHAR2,
          x_src_requested_qty_uom       OUT NOCOPY VARCHAR2,
          x_src_requested_qty           OUT NOCOPY NUMBER,
          x_inv_item_id                 OUT NOCOPY NUMBER,
          x_skip_detail              OUT NOCOPY VARCHAR2, -- Bug# 3248578
	  x_return_status		OUT NOCOPY  VARCHAR2)
   IS
   --
   record_locked  EXCEPTION;
   PRAGMA EXCEPTION_INIT(record_locked, -54);
   --

   --Cursor to lock the delivery detail line.
   CURSOR lock_for_update(v_del_detail_id IN NUMBER) IS
   SELECT ROWID, LAST_UPDATE_DATE, --Bug# 3248578
   -- Bug 4775539
          REQUESTED_QUANTITY_UOM,
          SRC_REQUESTED_QUANTITY_UOM,
          SRC_REQUESTED_QUANTITY,
          INVENTORY_ITEM_ID
   FROM   WSH_DELIVERY_DETAILS
   WHERE  DELIVERY_DETAIL_ID = v_del_detail_id
   AND	RELEASED_STATUS IN ('R','B','X')
   AND	MOVE_ORDER_LINE_ID IS NULL
   FOR	UPDATE NOWAIT;
   --
   -- Start Bug# 3248578

     --Cursor to get the delivery detail info.
     CURSOR new_detail_info(v_del_detail_id IN NUMBER) IS
     SELECT wdd.SOURCE_LINE_ID, -- Start New Col Addition
            wdd.SOURCE_HEADER_ID,
	    wdd.INVENTORY_ITEM_ID,
	    WDD.SHIPMENT_PRIORITY_CODE,
	    WDD.SOURCE_CODE SOURCE_CODE,
	    WDD.SOURCE_HEADER_NUMBER SOURCE_HEADER_NUMBER, -- End New Col Addition
            wdd.organization_id,
            wdd.move_order_line_id,
            wdd.ship_from_location_id,
            wdd.ship_method_code,
            wdd.shipment_priority_code,
            wdd.date_scheduled,
            wdd.requested_quantity,
            wdd.requested_quantity_uom,
            wdd.preferred_grade,
            wdd.requested_quantity2,
            wdd.requested_quantity_uom2,
            wdd.project_id,
            wdd.task_id,
            wdd.subinventory,
            wdd.subinventory,
            wdd.released_status,
            wdd.ship_model_complete_flag,
            wdd.top_model_line_id,
            wdd.ship_set_id,
            -- Standalone project Changes start
            wdd.locator_id,
            wdd.revision,
            wdd.lot_number,
            -- Standalone project Changes end
            wda.delivery_id,
            wdd.last_update_date,
            wdd.client_id  -- LSP PROJECT:
     FROM  wsh_delivery_details wdd,
           wsh_delivery_assignments_v wda
     WHERE wdd.delivery_detail_id = v_del_detail_id
     AND   wda.delivery_detail_id = wdd.delivery_detail_id
     AND   wdd.date_scheduled IS NOT NULL
     AND   wdd.date_requested >= nvl(g_from_request_date, wdd.date_requested)
     AND   wdd.date_requested <= nvl(g_to_request_date, wdd.date_requested)
     AND   wdd.date_scheduled >= nvl(g_from_sched_ship_date, wdd.date_scheduled)
     AND   wdd.date_scheduled <= nvl(g_to_sched_ship_date, wdd.date_scheduled)
     AND   nvl(wdd.requested_quantity,0) > 0
     AND   wdd.released_status IN ('R','B','X')
     -- bug 5166340: wdd subinventory needs to be compared
     --              with g_RelSubInventory(subinventory field value)
     --              not with g_from_subinventory(pick from subinventory field value)
     -- AND   nvl(wdd.subinventory, -99) = decode(g_from_subinventory, NULL,
     --                                           nvl(wdd.subinventory, -99), g_from_subinventory)
     AND   nvl(wdd.subinventory, -99) = decode(g_RelSubInventory, NULL,
                                               nvl(wdd.subinventory, -99), g_RelSubInventory)
     AND   nvl(wdd.project_id,0)  = decode(g_project_id, 0, nvl(wdd.project_id,0), g_project_id)
     AND   nvl(wdd.task_id,0)     = decode(g_task_id, 0, nvl(wdd.task_id,0), g_task_id)
     AND   nvl(wdd.ship_set_id,0) = decode(g_ship_set_number, 0, nvl(wdd.ship_set_id,0), g_ship_set_number)
     AND   nvl(wdd.shipment_priority_code,-99) = decode(g_shipment_priority, NULL,
                                                        nvl(wdd.shipment_priority_code,-99), g_shipment_priority)
     AND   wdd.organization_id = nvl(g_organization_id, wdd.organization_id)
     AND   wdd.ship_from_location_id = decode(g_ship_from_loc_id, -1, wdd.ship_from_location_id,
                                              g_ship_from_loc_id)
     AND   (( wda.delivery_id IS NOT NULL AND ( g_include_planned_lines <> 'N'  OR
                                                wda.delivery_id = g_delivery_id OR
                                                g_trip_id <> 0
                                              )
             ) OR
             ( wda.delivery_id IS NULL AND g_delivery_id = 0 AND g_trip_id = 0 )
           );

   -- End Bug# 3248578

   l_rowid VARCHAR2(30);

   l_last_update_date DATE; --Bug# 3248578

   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DETAIL_LOCK';
   --
BEGIN
     --
     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL THEN
	l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
	WSH_DEBUG_SV.push(l_module_name);
	WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_SHIP_SET_ID',P_SHIP_SET_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_TOP_MODEL_LINE_ID',P_TOP_MODEL_LINE_ID);
	WSH_DEBUG_SV.log(l_module_name,'P_ENFORCE_SHIP_SET_AND_SMC',P_ENFORCE_SHIP_SET_AND_SMC);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     x_skip_detail := 'N'; --Bug# 3248578
     --

     --Cursor to lock the delivery detail line.
     OPEN lock_for_update(p_delivery_detail_id);
     FETCH lock_for_update INTO l_rowid, l_last_update_date,
     -- Bug 4775539
           x_requested_qty_uom,x_src_requested_qty_uom,x_src_requested_qty,x_inv_item_id;
     --
     IF lock_for_update%NOTFOUND THEN
	CLOSE lock_for_update;
	RAISE no_data_found;
     END IF;

     -- Start Bug# 3248578
     IF l_debug_on THEN
	WSH_DEBUG_SV.log(l_module_name,'l_last_update_date',l_last_update_date);
	WSH_DEBUG_SV.log(l_module_name,'v_last_update_date',v_last_update_date);
     END IF;


     IF l_last_update_date <> v_last_update_date THEN
        -- Record has been changed during the Pick Release process
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Record has been changed during the Pick Release process');
        END IF;

        --Cursor to get the detail info.
        OPEN new_detail_info(p_delivery_detail_id);
        FETCH new_detail_info INTO
              v_line_id, -- Start New Col Addition
              v_header_id,
              v_inventory_item_id,
              v_shipment_priority,
              v_source_code,
              v_source_header_number, -- End New Col Addition
	      v_org_id,
              v_move_order_line_id,
              v_ship_from_location_id,
              v_ship_method_code,
              v_shipment_priority,
              v_date_scheduled,
              v_requested_quantity,
              v_requested_quantity_uom,
              v_preferred_grade,
              v_requested_quantity2,
              v_requested_quantity_uom2,
              v_project_id,
              v_task_id,
              v_from_sub,
              v_to_sub,
              v_released_status,
              v_ship_model_complete_flag,
              v_top_model_line_id,
              v_ship_set_id,
              -- Standalone project Changes start
              v_from_locator,
              v_revision,
              v_lot_number,
              -- Standalone project Changes end
              v_delivery_id,
              v_last_update_date,
              v_client_id; -- LSP PROJECT :
        IF new_detail_info%NOTFOUND THEN
--jckwok wrap debug stmts around if.. end if
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Ignoring delivery detail : '||p_delivery_detail_id ||' since no longer satisfies the pick release criteria' );
           END IF;
           x_skip_detail := 'Y';
           IF lock_for_update%ISOPEN THEN
              CLOSE lock_for_update;
           END IF;
        END IF;
        CLOSE new_detail_info;

     END IF;
     -- End Bug# 3248578
     --

     --Successfully lock the detail lines.
     IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,  'SUCCESSFULLY LOCKED DELIVERY DETAIL '||P_DELIVERY_DETAIL_ID);
	WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
EXCEPTION
     --
     WHEN record_locked THEN
       --
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
        -- Bug Bug 4775539
       x_requested_qty_uom     := null;
       x_src_requested_qty_uom := null;
       x_src_requested_qty     := null;
       x_inv_item_id           := null;

       Set_Globals(p_enforce_ship_set_and_smc, p_ship_set_id, p_top_model_line_id);
       --
       IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,  'CANNOT LOCK DELIVERY DETAIL FOR UPDATE: '|| P_DELIVERY_DETAIL_ID);
	WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
       END IF;
       --
     WHEN no_data_found THEN
       --
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       Set_Globals(p_enforce_ship_set_and_smc, p_ship_set_id, p_top_model_line_id);
       --
       IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,  'DELIVERY DETAIL LINE NOT FOUND: '|| P_DELIVERY_DETAIL_ID);
	WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
       END IF;
       --
END Get_Detail_Lock;



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
--      p_worker_id           IN  worker id
-- OUT:
--      x_api_status          OUT NOCOPY  Standard to output api status.
-- End of comments

PROCEDURE Init(
	  p_batch_id	IN	   NUMBER,
	  p_worker_id	IN	   NUMBER,
	  x_api_status	OUT NOCOPY VARCHAR2
   ) IS
	  -- cursor to get batch parameter information
	  CURSOR  get_batch(v_batch_id IN NUMBER) IS
	  SELECT  NAME,
           BACKORDERS_ONLY_FLAG,
                            NVL(AUTODETAIL_PR_FLAG, NULL),
              NVL(AUTO_PICK_CONFIRM_FLAG, NULL),
              NVL(PICK_SEQUENCE_RULE_ID, ''),
              NVL(PICK_GROUPING_RULE_ID, ''),
              NVL(INCLUDE_PLANNED_LINES, 'N'),
              NVL(ORGANIZATION_ID, ''),
              NVL(CUSTOMER_ID, 0),
              NVL(FROM_REQUESTED_DATE, NULL),
              NVL(TO_REQUESTED_DATE, NULL),
              NVL(EXISTING_RSVS_ONLY_FLAG, 'N'),
              NVL(ORDER_HEADER_ID, 0),
              NVL(INVENTORY_ITEM_ID, 0),
              NVL(TRIP_ID, 0),
              NVL(TRIP_STOP_ID, 0),
              NVL(DELIVERY_ID, 0),
              NVL(ORDER_TYPE_ID, 0),
              NVL(FROM_SCHEDULED_SHIP_DATE, NULL),
              NVL(TO_SCHEDULED_SHIP_DATE, NULL),
              NVL(SHIPMENT_PRIORITY_CODE, ''),
              NVL(SHIP_METHOD_CODE, ''),
              NVL(SHIP_SET_NUMBER, 0),
              NVL(DELIVERY_DETAIL_ID, 0),
              NVL(SHIP_TO_LOCATION_ID, 0),
              NVL(DEFAULT_STAGE_SUBINVENTORY, ''),
              NVL(DEFAULT_STAGE_LOCATOR_ID,''),
              NVL(PICK_FROM_SUBINVENTORY,''),
              NVL(PICK_FROM_LOCATOR_ID,''),
              NVL(TASK_ID,0),
              NVL(PROJECT_ID,0),
              NVL(SHIP_FROM_LOCATION_ID, -1),
              NVL(AUTOCREATE_DELIVERY_FLAG, NULL),
              SHIP_CONFIRM_RULE_ID,
              NVL(AUTOPACK_FLAG, 'N'),
              AUTOPACK_LEVEL,
              NON_PICKING_FLAG,
              NVL(ORDER_LINE_ID, 0),
              NVL(DOCUMENT_SET_ID, '-1'),
              TASK_PLANNING_FLAG,
              --
              -- rlanka : Pack J Enhancement
              NVL(category_set_id, 0),
              NVL(category_id, 0),
              NVL(region_id, 0),
              NVL(zone_id, 0),
              NVL(ac_delivery_criteria, NULL),
              NVL(rel_subinventory, NULL),
              --
              -- deliveryMerge
              NVL(append_flag, NULL),
              -- Bug #3266659 : Shipset/SMC Criteria
              NVL(SHIP_SET_SMC_FLAG,'A'),
              ACTUAL_DEPARTURE_DATE,
              NVL(ALLOCATION_METHOD,'I'), --anxsharm, X-dock
              CROSSDOCK_CRITERIA_ID ,      --anxsharm, X-dock
              DYNAMIC_REPLENISHMENT_FLAG,  --bug# 6689448 (replenishment project)
              NVL(CLIENT_ID, 0) --LSP PROJECT
	  FROM	WSH_PICKING_BATCHES
	  WHERE   BATCH_ID = v_batch_id;

	  -- cursor to get batch parameter information
	  CURSOR  get_lock_batch(v_batch_id IN NUMBER) IS
	  SELECT  NAME,
              BACKORDERS_ONLY_FLAG,
              NVL(AUTODETAIL_PR_FLAG, NULL),
              NVL(AUTO_PICK_CONFIRM_FLAG, NULL),
              NVL(PICK_SEQUENCE_RULE_ID, ''),
              NVL(PICK_GROUPING_RULE_ID, ''),
              NVL(INCLUDE_PLANNED_LINES, 'N'),
              NVL(ORGANIZATION_ID, ''),
              NVL(CUSTOMER_ID, 0),
              NVL(FROM_REQUESTED_DATE, NULL),
              NVL(TO_REQUESTED_DATE, NULL),
              NVL(EXISTING_RSVS_ONLY_FLAG, 'N'),
              NVL(ORDER_HEADER_ID, 0),
              NVL(INVENTORY_ITEM_ID, 0),
              NVL(TRIP_ID, 0),
              NVL(TRIP_STOP_ID, 0),
              NVL(DELIVERY_ID, 0),
              NVL(ORDER_TYPE_ID, 0),
              NVL(FROM_SCHEDULED_SHIP_DATE, NULL),
              NVL(TO_SCHEDULED_SHIP_DATE, NULL),
              NVL(SHIPMENT_PRIORITY_CODE, ''),
              NVL(SHIP_METHOD_CODE, ''),
              NVL(SHIP_SET_NUMBER, 0),
              NVL(DELIVERY_DETAIL_ID, 0),
              NVL(SHIP_TO_LOCATION_ID, 0),
              NVL(DEFAULT_STAGE_SUBINVENTORY, ''),
              NVL(DEFAULT_STAGE_LOCATOR_ID,''),
              NVL(PICK_FROM_SUBINVENTORY,''),
              NVL(PICK_FROM_LOCATOR_ID,''),
              NVL(TASK_ID,0),
              NVL(PROJECT_ID,0),
              NVL(SHIP_FROM_LOCATION_ID, -1),
              NVL(AUTOCREATE_DELIVERY_FLAG, NULL),
              SHIP_CONFIRM_RULE_ID,
              NVL(AUTOPACK_FLAG, 'N'),
              AUTOPACK_LEVEL,
              NON_PICKING_FLAG,
              NVL(ORDER_LINE_ID, 0),
              NVL(DOCUMENT_SET_ID, '-1'),
              TASK_PLANNING_FLAG,
              --
              -- rlanka : Pack J Enhancement
              NVL(category_set_id, 0),
              NVL(category_id, 0),
              NVL(region_id, 0),
              NVL(zone_id, 0),
              NVL(ac_delivery_criteria, NULL),
              NVL(rel_subinventory, NULL),
              --
              -- deliveryMerge
              NVL(append_flag, NULL),
              -- Bug #3266659 : Shipset/SMC Criteria
              NVL(SHIP_SET_SMC_FLAG,'A'),
              ACTUAL_DEPARTURE_DATE,
              NVL(ALLOCATION_METHOD,'I'), --anxsharm, X-dock
              CROSSDOCK_CRITERIA_ID,       --anxsharm, X-dock
              DYNAMIC_REPLENISHMENT_FLAG,   --bug# 6689448 (replenishment project)
              NVL(CLIENT_ID, 0)
	  FROM	WSH_PICKING_BATCHES
	  WHERE   BATCH_ID = v_batch_id
          FOR UPDATE OF BATCH_ID NOWAIT;

	  -- cursor to get line information
	  CURSOR get_line_info(v_line_id In NUMBER) IS
	  SELECT HEADER_ID
	  FROM   OE_ORDER_LINES_ALL
	  WHERE  LINE_ID = v_line_id;

	  -- cursor to get lines within a container
	  CURSOR get_inner_items (v_del_detail_id NUMBER) IS
	  SELECT WDD.DELIVERY_DETAIL_ID
	  FROM   wsh_delivery_assignments_v WDA,
		 WSH_DELIVERY_DETAILS WDD
	  WHERE  WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID
	  AND	WDD.CONTAINER_FLAG = 'N'
	  AND	WDA.DELIVERY_ASSIGNMENT_ID IN
			 (SELECT WDA1.DELIVERY_ASSIGNMENT_ID
              FROM   wsh_delivery_assignments_v WDA1
              START WITH WDA1.PARENT_DELIVERY_DETAIL_ID = v_del_detail_id
              CONNECT BY PRIOR WDA1.DELIVERY_DETAIL_ID = WDA1.PARENT_DELIVERY_DETAIL_ID);

	  -- Cursor to get lines within a batch.
          -- Changes: added checks on LINE_DIRECTION for J Inbound Logistics. jckwok

	  -- Bug 3433645 :
          --  Added condition AND CONTAINER_FLAG = 'Y' to fetch  containers only.

	  CURSOR get_batch_details (v_batch_id NUMBER, v_del_det NUMBER) IS
	  SELECT DELIVERY_DETAIL_ID               -- If Launch PR from STF for del details, we stamp batch id
	  FROM WSH_DELIVERY_DETAILS               -- on details. wsh_picking_batches has the detail as -1,
	  WHERE BATCH_ID = v_batch_id             -- batch can have several delivery details
          AND nvl(LINE_DIRECTION , 'O') IN ('O', 'IO')
	  AND CONTAINER_FLAG='Y'
	  UNION
          SELECT DELIVERY_DETAIL_ID               -- If use PR form then we do not stamp batch id in wdd,
          FROM WSH_DELIVERY_DETAILS               -- wsh_picking_batches has the delivery detail stamped
          WHERE DELIVERY_DETAIL_ID = v_del_det    -- we can specify only one detail per batch
          AND nvl(LINE_DIRECTION , 'O') IN ('O', 'IO')
          AND BATCH_ID IS NULL
	  AND CONTAINER_FLAG='Y';

	  record_locked					EXCEPTION;
	  PRAGMA EXCEPTION_INIT(record_locked, -54);
	  l_order_header_id				NUMBER;
	  l_temp_line					NUMBER := -1;  -- bug # 8915460 : initializing to -1.

	  --
	  l_debug_on BOOLEAN;
          l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INIT';
	  --

          -- Variables for INV_Validate APIs
          l_validate_org          INV_Validate.Org;
          l_validate_sub          INV_Validate.Sub;
          l_validate_from_sub     INV_Validate.Sub;
          l_validate_locator      INV_Validate.Locator;
          l_validate_item         INV_Validate.Item;


BEGIN
	  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	  IF l_debug_on IS NULL
	  THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	  END IF;

	  IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
	    WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_WORKER_ID',P_WORKER_ID);
	  END IF;
	  --
	  -- initialize the WHO session variables
	  g_request_id     := FND_GLOBAL.CONC_REQUEST_ID;
	  g_application_id := FND_GLOBAL.PROG_APPL_ID;
	  g_program_id     := FND_GLOBAL.CONC_PROGRAM_ID;
	  g_user_id        := FND_GLOBAL.USER_ID;
	  g_login_id       := FND_GLOBAL.CONC_LOGIN_ID;

	  IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,  'REQUEST_ID', TO_CHAR(G_REQUEST_ID));
	    WSH_DEBUG_SV.log(l_module_name,  'APPLICATION_ID',TO_CHAR(G_APPLICATION_ID));
	    WSH_DEBUG_SV.log(l_module_name,  'PROGRAM_ID', TO_CHAR(G_PROGRAM_ID));
	    WSH_DEBUG_SV.log(l_module_name,  'USER_ID', TO_CHAR(G_USER_ID));
	    WSH_DEBUG_SV.log(l_module_name,  'LOGIN_ID', TO_CHAR(G_LOGIN_ID));
	  END IF;

          IF p_worker_id IS NULL THEN --{
	     -- fetch release criteria for the batch and lock row
	     OPEN  get_lock_batch(p_batch_id);
	     FETCH get_lock_batch
	     INTO  g_batch_name,
		   g_backorders_flag,
		   g_autodetail_flag,
		   g_auto_pick_confirm_flag,
		   g_pick_seq_rule_id,
		   g_pick_grouping_rule_id,
		   g_include_planned_lines,
		   g_organization_id,
		   g_customer_id,
		   g_from_request_date,
		   g_to_request_date,
		   g_existing_rsvs_only_flag,
		   g_order_header_id,
		   g_inventory_item_id,
		   g_trip_id,
		   g_trip_stop_id,
		   g_delivery_id,
		   g_order_type_id,
		   g_from_sched_ship_date,
		   g_to_sched_ship_date,
		   g_shipment_priority,
		   g_ship_method_code,
		   g_ship_set_number,
		   g_del_detail_id,
		   g_ship_to_loc_id,
		   g_to_subinventory,
		   g_to_locator,
		   g_from_subinventory,
		   g_from_locator,
		   g_task_id,
		   g_project_id,
		   g_ship_from_loc_id,
		   g_autocreate_deliveries,
		   g_auto_ship_confirm_rule_id,
		   g_autopack_flag,
		   g_autopack_level,
		   g_non_picking_flag,
		   g_order_line_id,
		   g_doc_set_id,
		   g_task_planning_flag,
		   g_CategorySetID,
		   g_CategoryID,
		   g_RegionID,
		   g_ZoneID,
		   g_acDelivCriteria,
		   g_RelSubInventory,
		   g_append_flag,
		   g_ship_set_smc_flag,
                   g_actual_departure_date,
                   g_allocation_method,  -- anxsharm, X-dock
                   g_crossdock_criteria_id, -- anxsharm, X-dock
                   g_dynamic_replenishment_flag, --bug# 6689448 (replenishment project)
                   g_client_id; --LSP PROJECT

             -- Handle batch does not exist condition
	     IF get_lock_batch%NOTFOUND THEN
	        x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	        IF l_debug_on THEN
	           WSH_DEBUG_SV.logmsg(l_module_name, 'BATCH ID ' || TO_CHAR(P_BATCH_ID) || ' DOES NOT EXIST.');
	           WSH_DEBUG_SV.pop(l_module_name);
  	        END IF;
	        IF get_lock_batch%ISOPEN THEN
		   CLOSE get_lock_batch;
   	        END IF;
      	        RETURN;
   	     END IF;
	     IF get_lock_batch%ISOPEN THEN
		CLOSE get_lock_batch;
   	     END IF;
          --}
          ELSE --{
	     -- fetch release criteria for the batch
	     OPEN  get_batch(p_batch_id);
	     FETCH get_batch
	     INTO  g_batch_name,
		   g_backorders_flag,
		   g_autodetail_flag,
		   g_auto_pick_confirm_flag,
		   g_pick_seq_rule_id,
		   g_pick_grouping_rule_id,
		   g_include_planned_lines,
		   g_organization_id,
		   g_customer_id,
		   g_from_request_date,
		   g_to_request_date,
		   g_existing_rsvs_only_flag,
		   g_order_header_id,
		   g_inventory_item_id,
		   g_trip_id,
		   g_trip_stop_id,
		   g_delivery_id,
		   g_order_type_id,
		   g_from_sched_ship_date,
		   g_to_sched_ship_date,
		   g_shipment_priority,
		   g_ship_method_code,
		   g_ship_set_number,
		   g_del_detail_id,
		   g_ship_to_loc_id,
		   g_to_subinventory,
		   g_to_locator,
		   g_from_subinventory,
		   g_from_locator,
		   g_task_id,
		   g_project_id,
		   g_ship_from_loc_id,
		   g_autocreate_deliveries,
		   g_auto_ship_confirm_rule_id,
		   g_autopack_flag,
		   g_autopack_level,
		   g_non_picking_flag,
		   g_order_line_id,
		   g_doc_set_id,
		   g_task_planning_flag,
		   g_CategorySetID,
		   g_CategoryID,
		   g_RegionID,
		   g_ZoneID,
		   g_acDelivCriteria,
		   g_RelSubInventory,
		   g_append_flag,
		   g_ship_set_smc_flag,
                   g_actual_departure_date,
                   g_allocation_method,  -- anxsharm, X-dock
                   g_crossdock_criteria_id, -- anxsharm, X-dock
                   g_dynamic_replenishment_flag, --bug# 6689448 (replenishment project)
                   g_client_id; -- LSP PROJECT

             -- Handle batch does not exist condition
	     IF get_batch%NOTFOUND THEN
	        x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	        IF l_debug_on THEN
	           WSH_DEBUG_SV.logmsg(l_module_name, 'BATCH ID ' || TO_CHAR(P_BATCH_ID) || ' DOES NOT EXIST.');
	           WSH_DEBUG_SV.pop(l_module_name);
  	        END IF;
	        IF get_batch%ISOPEN THEN
		   CLOSE get_batch;
   	        END IF;
      	        RETURN;
   	     END IF;
	     IF get_batch%ISOPEN THEN
		CLOSE get_batch;
   	     END IF;
          --
          -- bug # 8915460 : When g_del_detail_id is > 0, for child requests change
          --                g_del_detail_id to -2 because when g_del_detail_id is > 0
          --                parent process is updating WDD with batch_id value
          --                and changing g_del_detail_id to -2.
          IF (g_del_detail_id > 0) THEN
            g_del_detail_id := -2;
          END IF;
          -- bug # 8915460 : End

          END IF; --}

	  -- Write to log the variables that have been initialized
	  IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,'PICK RELEASE PARAMETERS ARE...'  );
		  WSH_DEBUG_SV.log(l_module_name,  'BATCH_NAME', G_BATCH_NAME);
		  WSH_DEBUG_SV.log(l_module_name,  'BACKORDERS_FLAG', G_BACKORDERS_FLAG);
		  WSH_DEBUG_SV.log(l_module_name,  'AUTODETAIL_PR_FLAG', G_AUTODETAIL_FLAG);
		  WSH_DEBUG_SV.log(l_module_name,  'AUTO_PICK_CONFIRM_FLAG', G_AUTO_PICK_CONFIRM_FLAG);
		  WSH_DEBUG_SV.log(l_module_name,  'ORDER_HEADER_ID', G_ORDER_HEADER_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'ORDER_TYPE_ID', G_ORDER_TYPE_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'SHIP_FROM_LOC_ID', G_SHIP_FROM_LOC_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'ORGANIZATION_ID', G_ORGANIZATION_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'CUSTOMER_ID', G_CUSTOMER_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'SHIP_TO_LOC_ID', G_SHIP_TO_LOC_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'SHIPMENT_PRIORITY', G_SHIPMENT_PRIORITY);
		  WSH_DEBUG_SV.log(l_module_name,  'SHIP_METHOD_CODE', G_SHIP_METHOD_CODE);
		  WSH_DEBUG_SV.log(l_module_name,  'SHIP_SET_NUMBER', G_SHIP_SET_NUMBER);
		  WSH_DEBUG_SV.log(l_module_name,  'LINE/CONTAINER ID', G_DEL_DETAIL_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'FROM_REQUEST_DATE',
			TO_CHAR(G_FROM_REQUEST_DATE , 'DD-MON-YYYY HH24:MI:SS'));
		  WSH_DEBUG_SV.log(l_module_name,  'TO_REQUEST_DATE',
			TO_CHAR(G_TO_REQUEST_DATE , 'DD-MON-YYYY HH24:MI:SS'));
		  WSH_DEBUG_SV.log(l_module_name,  'FROM_SCHED_SHIP_DATE',
			TO_CHAR(G_FROM_SCHED_SHIP_DATE , 'DD-MON-YYYY HH24:MI:SS'));
		  WSH_DEBUG_SV.log(l_module_name,  'TO_SCHED_SHIP_DATE',
			TO_CHAR(G_TO_SCHED_SHIP_DATE , 'DD-MON-YYYY HH24:MI:SS'));
		  WSH_DEBUG_SV.log(l_module_name,  'EXISTING_RSVS_ONLY_FLAG', G_EXISTING_RSVS_ONLY_FLAG);
		  WSH_DEBUG_SV.log(l_module_name,  'TO_SUBINVENTORY', G_TO_SUBINVENTORY);
		  WSH_DEBUG_SV.log(l_module_name,  'TO_LOCATOR', G_TO_LOCATOR);
		  WSH_DEBUG_SV.log(l_module_name,  'FROM_SUBINVENTORY', G_FROM_SUBINVENTORY);
		  WSH_DEBUG_SV.log(l_module_name,  'FROM_LOCATOR', G_FROM_LOCATOR);
		  WSH_DEBUG_SV.log(l_module_name,  'INVENTORY_ITEM_ID', G_INVENTORY_ITEM_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'TRIP_ID', G_TRIP_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'TRIP_STOP_ID', G_TRIP_STOP_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'DELIVERY_ID', G_DELIVERY_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'PICK_GROUPING_RULE_ID', G_PICK_GROUPING_RULE_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'PICK_SEQ_RULE_ID', G_PICK_SEQ_RULE_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'DOC_SET_ID', G_DOC_SET_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'INCLUDE_PLANNED_LINES', G_INCLUDE_PLANNED_LINES);
		  WSH_DEBUG_SV.log(l_module_name,  'AUTOCREATE_DELIVERY_FLAG', G_AUTOCREATE_DELIVERIES);
		  WSH_DEBUG_SV.log(l_module_name,  'ORDER_LINE_ID', G_ORDER_LINE_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'PROJECT_ID', G_PROJECT_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'TASK_ID', G_TASK_ID);
		  WSH_DEBUG_SV.log(l_module_name,  'TASK_PLANNING_FLAG', G_TASK_PLANNING_FLAG);
		  -- rlanka : Pack J Enhancement
                  WSH_DEBUG_SV.log(l_module_name, 'Region ID', g_RegionID);
  		  WSH_DEBUG_SV.log(l_module_name, 'Zone ID', g_ZoneID);
   		  WSH_DEBUG_SV.log(l_module_name, 'Category Set ID',g_CategorySetID);
   		  WSH_DEBUG_SV.log(l_module_name, 'Category ID', g_CategoryID);
     		  WSH_DEBUG_SV.log(l_module_name, 'AC Deliv Criteria',g_acDelivCriteria);
      		  WSH_DEBUG_SV.log(l_module_name, 'Rel Subinventory', g_RelSubInventory);
      		  -- deliveryMerge
      		  WSH_DEBUG_SV.log(l_module_name, 'Append Flag', g_append_flag);
		  WSH_DEBUG_SV.log(l_module_name,  'SHIP_SET_SMC_FLAG', G_SHIP_SET_SMC_FLAG  );
                  -- anxsharm, X-dock
		  WSH_DEBUG_SV.log(l_module_name,  'ALLOCATION METHOD', G_ALLOCATION_METHOD  );
		  WSH_DEBUG_SV.log(l_module_name,  'CROSSDOCK CRITERIA ID', G_CROSSDOCK_CRITERIA_ID );
                  --bug# 6689448 (replenishment project)
                  WSH_DEBUG_SV.log(l_module_name,  'DYNAMIC REPLENISHMENT FLAG', G_DYNAMIC_REPLENISHMENT_FLAG);
                  WSH_DEBUG_SV.log(l_module_name,  'CLIENT ID', G_CLIENT_ID);  -- LSP PROJECT
	  END IF;

          -- Validate only if Parent Worker Process
          IF p_worker_id IS NULL THEN --{

	     -- Validating order_line_id
	     IF g_order_line_id <> 0 THEN

	   	 OPEN  get_line_info(g_order_line_id);
		 FETCH get_line_info
		 INTO  l_order_header_id;

		 IF get_line_info%NOTFOUND THEN

		  x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		  --
		  IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,  'ORDER LINE ID ' || TO_CHAR (G_ORDER_LINE_ID)
					|| 'DOES NOT EXIST'  );
		    WSH_DEBUG_SV.pop(l_module_name);
		  END IF;
		  --
		  RETURN;

		 END IF;

		 IF l_order_header_id <> g_order_header_id THEN

		  x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		  --
		  IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,  'ORDER LINE ID ' || TO_CHAR (G_ORDER_LINE_ID)
					|| 'DOES NOT BELONG TO');
		   WSH_DEBUG_SV.logmsg(l_module_name,  'ORDER HEADER ID ' || TO_CHAR ( G_ORDER_HEADER_ID ));
		   WSH_DEBUG_SV.pop(l_module_name);
		  END IF;
		  --
		  RETURN;
		 END IF;

		 IF get_line_info%ISOPEN THEN
		   CLOSE get_line_info;
		 END IF;
	     END IF;

	     --
	     --Bug 3433645 : OMFST:J: AUTOMATED SHIPPING FAILING FOR ORDER WITH HUGE DELIVERY LINES
	     --		     BULK UPDATE ALL THE LINES WITH THE SAME BATCH ID.

             --1) Get all the container item in the batch.
	     --2) For every container get the inner non container items
	     --   Stamp the non container items with same batch id
	     --3) If atleast one update then set g_del_detail_id = -1
	     --   g_del_detail_id used for building the dynamic SQL

	     IF g_del_detail_id <> 0 THEN
         --{
           --Cursor to get all the containers within the batch
		   OPEN get_batch_details(p_batch_id, g_del_detail_id);
		   LOOP
		     FETCH get_batch_details into l_temp_line;
		     EXIT WHEN get_batch_details%NOTFOUND;
	         -- Get lines within a container
		     OPEN get_inner_items(l_temp_line);
		     FETCH get_inner_items BULK COLLECT INTO g_det_lst;
	   	     CLOSE get_inner_items;
		     IF (g_det_lst.COUNT > 0) THEN
			   FORALL i IN g_det_lst.FIRST..g_det_lst.LAST
                 UPDATE WSH_DELIVERY_DETAILS
                 SET    BATCH_ID = p_batch_id
                 WHERE  DELIVERY_DETAIL_ID = g_det_lst(i);
			   IF (SQL%ROWCOUNT > 0) THEN
               --{
                 IF (g_del_detail_id > 0) THEN -- bug # 8915460 : When pick release is submitted from release SO form/Public APIs
                   g_del_detail_id := -2;
                 ELSE
                   g_del_detail_id := -1; -- bug # 8915460 : When pick release is submitted from STF
                 END IF;
	           --}
	    	   END IF;
		     END IF;
		   END LOOP;
	 	   IF get_batch_details%ISOPEN THEN
		     CLOSE get_batch_details;
		   END IF;
           -- bug # 8915460 : if l_temp_line is not modified means
           --                 provided dd is not a container dd then
           --                 update wdd for that dd_ID and change g_del_detail_id to -2.
           --                 (Pick release is submitted from Release SO form/Public API)
           IF ( l_temp_line = -1 AND g_del_detail_id > 0 ) THEN
             UPDATE WSH_DELIVERY_DETAILS
             SET    BATCH_ID = p_batch_id
             WHERE  DELIVERY_DETAIL_ID = g_del_detail_id;
             IF (SQL%ROWCOUNT > 0) THEN
               g_del_detail_id := -2;
             END IF;
           END IF;
           -- bug # 8915460 : end
	     --}
         END IF;

	     -- Validating From_Subinventory and From_Locator
             IF (g_from_subinventory IS NOT NULL) THEN --{

		 IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_Validate.From_Subinventory',WSH_DEBUG_SV.C_PROC_LEVEL);
		 END IF;
                 l_validate_org := NULL;
                 l_validate_sub := NULL;
                 l_validate_locator := NULL;
                 l_validate_item := NULL;
                 l_validate_sub.secondary_inventory_name := g_from_subinventory;
                 l_validate_org.organization_id          := g_organization_id;

                 IF (INV_Validate.From_Subinventory( p_sub  => l_validate_sub,
                                                     p_org  => l_validate_org,
                                                     p_item => l_validate_item,
                                                     p_acct_txn => 1
                                                   )  = 0 ) THEN

                    x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    --
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name, g_from_subinventory||' is not a Valid Subinventory for Org ID :'|| g_organization_id);
                       WSH_DEBUG_SV.pop(l_module_name);
                    END IF;
                    --
                    RETURN;
                    --
                 END IF;

                 IF (g_from_locator IS NOT NULL) THEN
                     IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_Validate.From_Locator',WSH_DEBUG_SV.C_PROC_LEVEL);
                     END IF;
                     l_validate_locator.inventory_location_id := g_from_locator;
                     IF (INV_Validate.From_Locator( p_locator  => l_validate_locator,
                                                    p_org      => l_validate_org,
                                                    p_item     => l_validate_item,
                                                    p_from_sub => l_validate_sub,
                                                    p_project_id => g_project_id,
                                                    p_task_id  => g_task_id,
                                                    p_txn_action_id => 0)  = 0 ) THEN
                        --
                        x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                        --
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name, g_from_locator||' is not a Valid Locator for Subinventory :'|| g_from_subinventory);
                           WSH_DEBUG_SV.pop(l_module_name);
                        END IF;
                        --
                        RETURN;
                        --
                     END IF;
                 END IF;
             END IF;
             --}

	     -- Validating To_Subinventory and To_Locator
             IF (g_to_subinventory IS NOT NULL) THEN --{

		 IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_Validate.To_Subinventory',WSH_DEBUG_SV.C_PROC_LEVEL);
		 END IF;
                 l_validate_org := NULL;
                 l_validate_sub := NULL;
                 l_validate_from_sub := NULL;
                 l_validate_locator := NULL;
                 l_validate_item := NULL;
                 l_validate_sub.secondary_inventory_name := g_to_subinventory;
                 l_validate_org.organization_id          := g_organization_id;
                 l_validate_from_sub.secondary_inventory_name := g_from_subinventory;

                 IF (INV_Validate.To_Subinventory( p_sub      => l_validate_sub,
                                                   p_org      => l_validate_org,
                                                   p_item     => l_validate_item,
                                                   p_from_sub => l_validate_from_sub,
                                                   p_acct_txn => 1
                                                 )  = 0 ) THEN

                    x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    --
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name, g_to_subinventory||' is not a Valid Subinventory for Org ID :'|| g_organization_id);
                       WSH_DEBUG_SV.pop(l_module_name);
                    END IF;
                    --
                    RETURN;
                    --
                 END IF;

                 IF (g_to_locator IS NOT NULL) THEN
                     IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_Validate.To_Locator',WSH_DEBUG_SV.C_PROC_LEVEL);
                     END IF;
                     l_validate_locator.inventory_location_id := g_to_locator;
                     IF (INV_Validate.To_Locator( p_locator    => l_validate_locator,
                                                  p_org        => l_validate_org,
                                                  p_item       => l_validate_item,
                                                  p_to_sub     => l_validate_sub,
                                                  p_project_id => g_project_id,
                                                  p_task_id    => g_task_id,
                                                  p_txn_action_id => 0)  = 0 ) THEN

                        x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                        --
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name, g_to_locator||' is not a Valid Locator for Subinventory :'|| g_to_subinventory);
                           WSH_DEBUG_SV.pop(l_module_name);
                        END IF;
                        --
                        RETURN;

                     END IF;
                 END IF;
             END IF; --}

             -- Validating RelSubinventory
             IF (g_relsubinventory IS NOT NULL) THEN --{
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_Validate.From_Subinventory',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 l_validate_org := NULL;
                 l_validate_sub := NULL;
                 l_validate_locator := NULL;
                 l_validate_item := NULL;
                 l_validate_sub.secondary_inventory_name := g_relsubinventory;
                 l_validate_org.organization_id          := g_organization_id;

                 IF (INV_Validate.From_Subinventory( p_sub => l_validate_sub,
                                                     p_org => l_validate_org,
                                                     p_item => l_validate_item,
                                                     p_acct_txn => 1
                                                   )  = 0 ) THEN

                    x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    --
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name, g_relsubinventory||' is not a Valid Subinventory for Org ID :'|| g_organization_id);
                       WSH_DEBUG_SV.pop(l_module_name);
                    END IF;
                    --
                    RETURN;

                 END IF;
             END IF; --}

	     IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,  'UPDATING REQUEST ID FOR BATCH'  );
	     END IF;

	     -- Update picking batch setting request id and other who parameters
	     UPDATE WSH_PICKING_BATCHES
	     SET REQUEST_ID = g_request_id,
		  PROGRAM_APPLICATION_ID = g_application_id,
		  PROGRAM_ID = g_program_id,
		  PROGRAM_UPDATE_DATE = SYSDATE,
		  LAST_UPDATED_BY = g_user_id,
		  LAST_UPDATE_DATE = SYSDATE,
		  LAST_UPDATE_LOGIN = g_login_id
	     WHERE BATCH_ID = p_batch_id
	     AND (REQUEST_ID IS NULL OR REQUEST_ID = g_request_id);

	     IF SQL%NOTFOUND THEN
	       IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,  'PICKING BATCH ' || TO_CHAR(P_BATCH_ID) || ' NOT EXIST');
	         WSH_DEBUG_SV.logmsg(l_module_name,  'OR ANOTHER REQUEST HAS ALREADY RELEASED THIS BATCH');
	       END IF;
	     END IF;

	  END IF; --}

	  g_initialized := TRUE;
	  x_api_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	  IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	  END IF;

EXCEPTION
	  WHEN OTHERS THEN

	   x_api_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

	   IF get_lock_batch%ISOPEN THEN
		CLOSE get_lock_batch;
	   END IF;
	   IF get_batch%ISOPEN THEN
		CLOSE get_batch;
	   END IF;
	   IF get_line_info%ISOPEN THEN
		CLOSE get_line_info;
	   END IF;
	   IF get_batch_details%ISOPEN THEN
		CLOSE get_batch_details;
	   END IF;
	   IF get_inner_items%ISOPEN THEN
		CLOSE get_inner_items;
	   END IF;

	   IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,  'UNEXPECTED ERROR IN WSH_PR_CRITERIA.INIT');
	     WSH_DEBUG_SV.logmsg(l_module_name,'Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	   END IF;

END Init;


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
	  p_pick_grouping_rule_id	  IN	  NUMBER,
	  x_api_status				 OUT NOCOPY	  VARCHAR2
   ) IS
	  -- cursor to fetch pick sequence rule info
	  CURSOR  pick_seq_rule(v_psr_id IN NUMBER) IS
	  SELECT  NAME,
              NVL(ORDER_ID_PRIORITY, -1),
              DECODE(ORDER_ID_SORT, 'A', 'ASC', 'D', 'DESC', ''),
              NVL(INVOICE_VALUE_PRIORITY, -1),
              DECODE(INVOICE_VALUE_SORT, 'A', 'ASC', 'D', 'DESC', ''),
              NVL(SCHEDULE_DATE_PRIORITY, -1),
              DECODE(SCHEDULE_DATE_SORT, 'A', 'ASC', 'D', 'DESC', ''),
              NVL(SHIPMENT_PRI_PRIORITY, -1),
              DECODE(SHIPMENT_PRI_SORT, 'A', 'ASC', 'D', 'DESC', ''),
              NVL(TRIP_STOP_DATE_PRIORITY, -1),
              DECODE(TRIP_STOP_DATE_SORT, 'A', 'ASC', 'D', 'DESC', '')
	  FROM	WSH_PICK_SEQUENCE_RULES
	  WHERE   PICK_SEQUENCE_RULE_ID = v_psr_id
	  AND	 SYSDATE BETWEEN TRUNC(NVL(START_DATE_ACTIVE, SYSDATE)) AND
	                          NVL(END_DATE_ACTIVE, TRUNC(SYSDATE)+1);

	  -- cursor to determine if pick slip rule contains order number and delivery
	  CURSOR  order_ps_group(v_pgr_id IN NUMBER) IS
	  SELECT  NVL(ORDER_NUMBER_FLAG,'N'), NVL(DELIVERY_FLAG,'N')
	  FROM	WSH_PICK_GROUPING_RULES
	  WHERE   PICK_GROUPING_RULE_ID = v_pgr_id
	  AND	 SYSDATE BETWEEN TRUNC(NVL(START_DATE_ACTIVE, SYSDATE)) AND
		              NVL(END_DATE_ACTIVE, TRUNC(SYSDATE)+1);

	  l_pick_seq_rule_name		              VARCHAR2(30);
	  l_invoice_value_priority	              NUMBER;
	  l_order_number_priority	               NUMBER;
	  l_schedule_date_priority	              NUMBER;
	  l_trip_stop_date_priority				 NUMBER;
	  l_shipment_pri_priority	               NUMBER;
	  l_invoice_value_sort		              VARCHAR2(4);
	  l_order_number_sort		               VARCHAR2(4);
	  l_schedule_date_sort		              VARCHAR2(4);
	  l_trip_stop_date_sort					 VARCHAR2(4);
	  l_shipment_pri_sort		               VARCHAR2(4);
	  i	                          NUMBER;
	  j	                          NUMBER;
	  l_temp_psr                            	  psrTyp;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INIT_RULES';
--
BEGIN
	  --
	  -- Debug Statements
	  --
	  --
	  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	  --
	  IF l_debug_on IS NULL
	  THEN
		  l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	  END IF;
	  --
	  IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    WSH_DEBUG_SV.log(l_module_name,'P_PICK_SEQ_RULE_ID',P_PICK_SEQ_RULE_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_PICK_GROUPING_RULE_ID',P_PICK_GROUPING_RULE_ID);
	    WSH_DEBUG_SV.logmsg(l_module_name,  'FETCHING PICK SEQUENCE RULE INFORMATION FOR THE BATCH');
	  END IF;
	  --
	  -- fetch pick sequence rule parameters
	  OPEN	pick_seq_rule(p_pick_seq_rule_id);
	  FETCH   pick_seq_rule
	  INTO	l_pick_seq_rule_name,
              l_order_number_priority,
              l_order_number_sort,
              l_invoice_value_priority,
              l_invoice_value_sort,
              l_schedule_date_priority,
              l_schedule_date_sort,
              l_shipment_pri_priority,
              l_shipment_pri_sort,
              l_trip_stop_date_priority,
              l_trip_stop_date_sort;

	  -- handle pick sequence rule does not exist
	  IF pick_seq_rule%NOTFOUND THEN
		 --
		 x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 --
		 IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,  'PICK SEQUENCE RULE ID ' || TO_CHAR ( G_PICK_SEQ_RULE_ID ) || ' DOES NOT EXIST.');
		   WSH_DEBUG_SV.pop(l_module_name);
		 END IF;
		 --
		 RETURN;
	  END IF;
	  IF pick_seq_rule%ISOPEN THEN
		 CLOSE pick_seq_rule;
	  END IF;

	  -- initialize the pick sequence rule parameters
	  i := 1;
	  g_use_trip_stop_date := FALSE;
	  IF (l_invoice_value_priority <> -1) THEN
	     g_ordered_psr(i).attribute := C_INVOICE_VALUE;
	     g_ordered_psr(i).attribute_name := 'INVOICE_VALUE';

	     -- initialize the invoice_value_flag to be used as part
	     -- of building the select statement
	     g_invoice_value_flag := 'Y';
	     g_ordered_psr(i).priority := l_invoice_value_priority;
	     g_ordered_psr(i).sort_order := l_invoice_value_sort;
	     i := i + 1;
	  END IF;

	  IF (l_order_number_priority <> -1) THEN
		 g_ordered_psr(i).attribute := C_ORDER_NUMBER;
		 g_ordered_psr(i).attribute_name := 'ORDER_NUMBER';
		 g_ordered_psr(i).priority := l_order_number_priority;
		 g_ordered_psr(i).sort_order := l_order_number_sort;
	         i := i + 1;
	  END IF;
	  IF (l_schedule_date_priority <> -1) THEN
		 g_ordered_psr(i).attribute := C_SCHEDULE_DATE;
		 g_ordered_psr(i).attribute_name := 'SCHEDULE_DATE';
		 g_ordered_psr(i).priority := l_schedule_date_priority;
		 g_ordered_psr(i).sort_order := l_schedule_date_sort;
		 i := i + 1;
	  END IF;

	  IF (l_trip_stop_date_priority <> -1) THEN
		 g_use_trip_stop_date := TRUE;
	         g_ordered_psr(i).attribute := C_TRIP_STOP_DATE;
	         g_ordered_psr(i).attribute_name := 'TRIP_STOP_DATE';
	         g_ordered_psr(i).priority := l_trip_stop_date_priority;
	         g_ordered_psr(i).sort_order := l_trip_stop_date_sort;
	         i := i + 1;
	  END IF;

	  IF (l_shipment_pri_priority <> -1) THEN
		 g_ordered_psr(i).attribute := C_SHIPMENT_PRIORITY;
		 g_ordered_psr(i).attribute_name := 'SHIPMENT_PRIORITY';
		 g_ordered_psr(i).priority := l_shipment_pri_priority;
		 g_ordered_psr(i).sort_order := l_shipment_pri_sort;
		 i := i + 1;
	  END IF;
	  g_total_pick_criteria := i - 1;

	  -- sort the table for pick sequence rule according to priority
	  FOR i IN 1..g_total_pick_criteria LOOP
		 FOR j IN i+1..g_total_pick_criteria LOOP
			IF (g_ordered_psr(j).priority < g_ordered_psr(i).priority) THEN
			l_temp_psr := g_ordered_psr(j);
			g_ordered_psr(j) := g_ordered_psr(i);
			g_ordered_psr(i) := l_temp_psr;
		END IF;
	 END LOOP;
	  END LOOP;

	  -- determine the most significant pick sequence rule attribute
	  g_primary_psr := g_ordered_psr(1).attribute_name;

	  IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,  'PRIMARY PICK RULE IS ' || G_PRIMARY_PSR  );
	  END IF;
	  --

	  -- print pick sequence rule information for debugging purposes
	  FOR i IN 1..g_total_pick_criteria LOOP
	   --
	   IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,  'ATTRIBUTE = ' || G_ORDERED_PSR ( I ) .ATTRIBUTE_NAME || ' ' || 'PRIORITY = ' || TO_CHAR ( G_ORDERED_PSR ( I ) .PRIORITY ) || ' ' || 'SORT = ' || G_ORDERED_PSR ( I ) .SORT_ORDER  );
	   END IF;
	   --
	  END LOOP;
	  --
	  IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,  'DETERMINING IF ORDER NUMBER IS IN GROUPING RULE...');
	  END IF;

          --Determine if order number is in grouping rule.
	  OPEN  order_ps_group(p_pick_grouping_rule_id);
	  FETCH order_ps_group INTO  g_use_order_ps, g_use_delivery_ps;
	  IF order_ps_group%NOTFOUND THEN
		 g_use_order_ps    := 'N';
		 g_use_delivery_ps := 'N';
	  END IF;
	  IF order_ps_group%ISOPEN THEN
		 CLOSE order_ps_group;
	  END IF;

	  x_api_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	  --
	  IF l_debug_on THEN
	     WSH_DEBUG_SV.log(l_module_name,  'g_use_order_ps ' , g_use_order_ps  );
	     WSH_DEBUG_SV.log(l_module_name,  'g_use_delivery_ps ' , g_use_delivery_ps  );
	     WSH_DEBUG_SV.pop(l_module_name);
	  END IF;
	  --
EXCEPTION
     --
     WHEN OTHERS THEN
       --
       x_api_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       --
       IF pick_seq_rule%ISOPEN THEN
	 CLOSE pick_seq_rule;
       END IF;
       IF order_ps_group%ISOPEN THEN
	 CLOSE order_ps_group;
       END IF;
       --
       IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
				SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --
END Init_Rules;


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
   ) IS

   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_WORKER_RECORDS';
   --
   l_query VARCHAR2(4000);

BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_MODE',P_MODE);
      WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
   END IF;

   x_api_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF c_work_cursorID%ISOPEN THEN
      CLOSE c_work_cursorID;
   END IF;

   OPEN c_work_cursorID(p_batch_id, p_organization_id, p_mode);

   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Status '||x_api_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
   --
   WHEN OTHERS THEN
   --
   x_api_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
   --
   IF c_work_cursorID%ISOPEN THEN
      CLOSE c_work_cursorID;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
   --
END Get_Worker_Records;


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
--	p_batch_id			IN  Batch to be processed.
-- OUT:
--      x_worker_count     OUT NOCOPY  Worker Records Count.
--      x_smc_worker_count OUT NOCOPY  SMC Worker Records Count.
--      x_dd_count         OUT NOCOPY  Delivery Details Records Count.
--      x_api_status       OUT NOCOPY  Standard to output api status.
-- End of comments

Procedure Init_Cursor (
	  p_organization_id	       IN	  NUMBER,
	  p_mode	               IN	  VARCHAR2,
	  p_wms_org	               IN	  VARCHAR2,
	  p_mo_header_id	       IN	  NUMBER,
	  p_inv_item_id	               IN	  NUMBER,
	  p_enforce_ship_set_and_smc   IN	  VARCHAR2,
	  p_print_flag		       IN	  VARCHAR2,
          p_express_pick               IN         VARCHAR2,
	  p_batch_id		       IN	  NUMBER,
	  x_worker_count	       OUT NOCOPY NUMBER,
          x_smc_worker_count           OUT NOCOPY NUMBER,
	  x_dd_count		       OUT NOCOPY NUMBER,
	  x_api_status		       OUT NOCOPY VARCHAR2
   ) IS
   --
   i               NUMBER;
   l_ont_source_code VARCHAR2(240);

   l_count    NUMBER;
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INIT_CURSOR';
   --
BEGIN
	  --
	  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	  --
	  IF l_debug_on IS NULL THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	  END IF;
	  --
	  IF l_debug_on THEN
	   --
	   WSH_DEBUG_SV.push(l_module_name);
	   WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
	   WSH_DEBUG_SV.log(l_module_name,'P_MODE',P_MODE);
	   WSH_DEBUG_SV.log(l_module_name,'P_WMS_ORG',P_WMS_ORG);
	   WSH_DEBUG_SV.log(l_module_name,'P_MO_HEADER_ID',P_MO_HEADER_ID);
	   WSH_DEBUG_SV.log(l_module_name,'P_INV_ITEM_ID',P_INV_ITEM_ID);
	   WSH_DEBUG_SV.log(l_module_name,'P_ENFORCE_SHIP_SET_AND_SMC',P_ENFORCE_SHIP_SET_AND_SMC);
	   WSH_DEBUG_SV.log(l_module_name,'P_PRINT_FLAG',P_PRINT_FLAG);
	   WSH_DEBUG_SV.log(l_module_name,'P_EXPRESS_PICK',P_EXPRESS_PICK);
	   WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
	   --
	  END IF;
	  --
	  --bug# 6719369(replenishment project) : need to consider the replenishment status value.
	  IF g_backorders_flag NOT IN ('E','I','O','M') THEN
           --
	   x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   --
	   IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name, 'INVALID BACKORDER MODE.');
	     WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
	   --
	   RETURN;
	   --
	  END IF;

	  --
	  -- Make sure the first_line record has header_id set to -1
	  -- This is used to determine whether the Get_Lines
	  -- is called for the first time or not. The first_line is set
	  -- as a dummy line
	  first_line.source_header_id := -1;
	  g_del_current_line := 1;

	  -- Selection for unreleased lines, build the dynamic sql based on release batch parameters.
	  g_Unreleased_SQL := '';

          -- Bug 8314220: Add hint if organization id and inventory item id is not null
          IF ( p_organization_id IS NOT NULL and
               ( ( p_mode = 'WORKER' and p_inv_item_id is not null ) or
                 ( nvl(p_mode, 'SUMMARY') = 'SUMMARY' and g_inventory_item_id <> 0 ) ) )
          THEN
             Process_Buffer(p_print_flag,
                         'u', 'SELECT /*+ index(wdd WSH_DELIVERY_DETAILS_N9) */ ');
          ELSE
             Process_Buffer(p_print_flag,
		  				   'u', 'SELECT ');
          END IF;
          -- End bug 8314220

          -- 10. Based on P_MODE parameter, the query columns are selected.
          --{
          IF p_mode = 'SUMMARY' THEN
            IF p_enforce_ship_set_and_smc = 'N' THEN
               Process_Buffer(p_print_flag, 'u', ' WDD.ORGANIZATION_ID, WDD.INVENTORY_ITEM_ID, COUNT(*) ');
            ELSE
               Process_Buffer(p_print_flag, 'u', ' WDD.ORGANIZATION_ID,
                DECODE(WDD.SHIP_SET_ID,NULL,DECODE(WDD.SHIP_MODEL_COMPLETE_FLAG,''Y'',NULL,WDD.INVENTORY_ITEM_ID),NULL)
                ITEM1, COUNT(*) ');
            END IF;

          ELSE --{

	    Process_Buffer(p_print_flag,
	  				   'u', ' DISTINCT WDD.SOURCE_LINE_ID,');

	    Process_Buffer(p_print_flag,
	  	               'u', '	   WDD.SOURCE_HEADER_ID,');
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.ORGANIZATION_ID,');
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.INVENTORY_ITEM_ID,');
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.MOVE_ORDER_LINE_ID,');
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.DELIVERY_DETAIL_ID,' );
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.SHIP_MODEL_COMPLETE_FLAG,');
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.TOP_MODEL_LINE_ID,');
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.SHIP_FROM_LOCATION_ID,');
	    Process_Buffer(p_print_flag,
		               'u', '	   NULL SHIP_METHOD_CODE,');
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.SHIPMENT_PRIORITY_CODE,');
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.DATE_SCHEDULED DATE_SCHEDULED,');
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.REQUESTED_QUANTITY,');
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.REQUESTED_QUANTITY_UOM,');
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.PREFERRED_GRADE,' );
	    Process_Buffer(p_print_flag,
		              'u', '	   WDD.REQUESTED_QUANTITY2,' );
	    Process_Buffer(p_print_flag,
		              'u', '	   WDD.REQUESTED_QUANTITY_UOM2,' );
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.PROJECT_ID,' );
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.TASK_ID,' );
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.SUBINVENTORY FROM_SUBINVENTORY_CODE,' );
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.SUBINVENTORY TO_SUBINVENTORY_CODE,' );
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.RELEASED_STATUS RELEASED_STATUS,' );
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.SHIP_SET_ID SHIP_SET_ID,' );
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.SOURCE_CODE SOURCE_CODE,' );
	    Process_Buffer(p_print_flag,
		               'u', '	   WDD.SOURCE_HEADER_NUMBER SOURCE_HEADER_NUMBER,' );

            -- Bug 2040002: Need PLANNED_DEPARTURE_DATE only if released by trip or
	    --              is part of release sequence rule
	    IF ((g_use_trip_stop_date) OR (WSH_PR_CRITERIA.g_trip_id > 0)) THEN
	  	  Process_Buffer(p_print_flag,
		                 'u', '	   WTS.PLANNED_DEPARTURE_DATE,');
	    ELSE
		  Process_Buffer(p_print_flag,
		                 'u', '	   NULL PLANNED_DEPARTURE_DATE,');
	    END IF;

	    Process_Buffer(p_print_flag,
		               'u', '	   WDA.DELIVERY_ID,');
	    Process_Buffer(p_print_flag,
		               'u', '	   OL.END_ITEM_UNIT_NUMBER,');
	    Process_Buffer(p_print_flag,
		               'u', '	   OL.SOURCE_DOCUMENT_TYPE_ID,');
	    Process_Buffer(p_print_flag,
		               'u', '	   MSI.RESERVABLE_TYPE,');

            Process_Buffer(p_print_flag,   'u', '          WDD.LAST_UPDATE_DATE,'); --Bug# 3248578

            --HVOP
  	    IF (g_existing_rsvs_only_flag = 'Y')  THEN
                  Process_Buffer(p_print_flag,
		               'u', '       MR.DEMAND_SOURCE_HEADER_ID,');
            ELSE
                  Process_Buffer(p_print_flag,
		               'u', '       -1 DEMAND_SOURCE_HEADER_ID,');
	    END IF;

	    IF g_invoice_value_flag = 'Y' THEN
		  Process_Buffer(p_print_flag,
		              'u', '	WSH_PICK_CUSTOM.OUTSTANDING_ORDER_VALUE(WDD.SOURCE_HEADER_ID) OUTSTANDING_ORDER_VALUE,');
	    ELSE
		  Process_Buffer(p_print_flag,
		              'u', '	-1 OUTSTANDING_ORDER_VALUE,');
	    END IF;

            -- anxsharm, X-dock, add customer_id

            Process_Buffer(p_print_flag,   'u', '          WDD.CUSTOMER_ID,');
            -- anxsharm, end of code for X-dock
            -- Standalone project Changes start
            Process_Buffer(p_print_flag,   'u', '          WDD.REVISION,');
            Process_Buffer(p_print_flag,   'u', '          WDD.LOCATOR_ID,');
            Process_Buffer(p_print_flag,   'u', '          WDD.LOT_NUMBER,');
            -- Standalone project Changes end
            --
            Process_Buffer(p_print_flag,   'u', '          WDD.CLIENT_ID');  -- LSP PROJECT :
            --}
          END IF;
          --}

          -- 20. Common Tables to be selected irrespective of P_MODE parameter
          --{
	  Process_Buffer(p_print_flag,
					 'u', ' FROM  WSH_DELIVERY_DETAILS WDD,');
	  Process_Buffer(p_print_flag,
					 'u', '	   wsh_delivery_assignments_v WDA,');

	  -- Bug 2040002: Need WSH_NEW_DELIVERIES under following conditions only
	  IF ((g_ship_method_code IS NOT NULL) OR
		  (g_trip_id > 0) OR
		  (g_use_trip_stop_date) OR
		  (g_delivery_id > 0)) THEN
		Process_Buffer(p_print_flag,
		               'u', '	   WSH_NEW_DELIVERIES WDE,');
	  END IF;

	  -- Bug 2040002: Need Trip/Stop info only if released by trip/stop or if
	  --              Departure Date is part of release sequence rule
	  IF ((g_use_trip_stop_date) OR (WSH_PR_CRITERIA.g_trip_id > 0)) THEN
		Process_Buffer(p_print_flag,
		               'u', '	   WSH_DELIVERY_LEGS WLG,');
		Process_Buffer(p_print_flag,
		               'u', '	   WSH_TRIP_STOPS WTS,');
	  END IF;

	  IF (g_existing_rsvs_only_flag = 'Y') THEN
	       /* NC Prior Reservations for OPM Bug#2768102 */
               /* Added if condition */
              -- HW OPMCONV - Removed checking for process flag
                  Process_Buffer(p_print_flag,
                                     'u', '       MTL_SALES_ORDERS MSORD1, ');
                  Process_Buffer(p_print_flag,
                                     'u', '       MTL_RESERVATIONS MR, ');
                  Process_Buffer(p_print_flag,
                                   'u', '       OE_TRANSACTION_TYPES_TL OTTT, '); --bug 6082122: Added table OE_TRANSACTION_TYPES_TL
	  END IF;

	  Process_Buffer(p_print_flag,
					 'u', '	   OE_ORDER_LINES_ALL OL, ');
	  Process_Buffer(p_print_flag,
					 'u', '	   MTL_SYSTEM_ITEMS MSI ');
          /* rlanka : Pack J Enhancement
           * Need mtl_category_sets and mtl_category_set_valid_cats only *
           * if pick releasing by category                               *
          */
	  IF g_CategorySetID <> 0 AND g_CategoryID <> 0 THEN
            Process_Buffer(p_print_flag, 'u', ' , MTL_CATEGORY_SETS MCS, MTL_ITEM_CATEGORIES MIC ');
          END IF;
          --
	  Process_Buffer(p_print_flag,
					 'u', ' WHERE   WDD.DATE_SCHEDULED IS NOT NULL');

	  -- Bug 2040002: Can do hard join only when released by trip
	  --              Do outer join when Departure Date is part of release sequence rule
	  --              Otherwise we don't need to access these tables
	  IF (WSH_PR_CRITERIA.g_trip_id > 0) THEN
		Process_Buffer(p_print_flag,
		               'u', ' AND   WTS.STOP_ID = WLG.PICK_UP_STOP_ID ');
		Process_Buffer(p_print_flag,
		               'u', ' AND   WLG.DELIVERY_ID = WDE.DELIVERY_ID ');
	  ELSIF (g_use_trip_stop_date) THEN
		Process_Buffer(p_print_flag,
		               'u', ' AND   WTS.STOP_ID(+) = WLG.PICK_UP_STOP_ID ');
		Process_Buffer(p_print_flag,
		               'u', ' AND   WLG.DELIVERY_ID(+) = WDE.DELIVERY_ID ');
	  END IF;

	  -- Bug 2040002:
	  IF ((g_delivery_id > 0) OR (g_trip_id > 0)) THEN
		Process_Buffer(p_print_flag,
		               'u', ' AND   WDE.DELIVERY_ID = WDA.DELIVERY_ID ');
	  ELSIF ((g_ship_method_code IS NOT NULL) OR (g_use_trip_stop_date)) THEN
		Process_Buffer(p_print_flag,
		               'u', ' AND   WDE.DELIVERY_ID(+) = WDA.DELIVERY_ID ');
	  END IF;
	  Process_Buffer(p_print_flag,
					 'u', ' AND   WDA.DELIVERY_DETAIL_ID = WDD.DELIVERY_DETAIL_ID');
	  Process_Buffer(p_print_flag,
					 'u', ' AND   NVL(WDD.REQUESTED_QUANTITY,0) > 0');
	  Process_Buffer(p_print_flag,
					 'u', ' AND   WDD.SOURCE_LINE_ID = OL.LINE_ID');
	  Process_Buffer(p_print_flag,
					 'u', ' AND   WDD.SOURCE_CODE  = ''OE'' ');
	  Process_Buffer(p_print_flag,
					 'u', ' AND   WDD.INVENTORY_ITEM_ID  = MSI.INVENTORY_ITEM_ID ');
	  Process_Buffer(p_print_flag,
					 'u', ' AND   WDD.ORGANIZATION_ID  = MSI.ORGANIZATION_ID ');

	  -- Both unreleased and backordered SQL share common conditions
	  IF p_print_flag = 'Y' THEN
	   --
	   IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,  ' <COMMON CONDITIONS>');
	   END IF;
	   --
	  END IF;

          --Construct the where clause
	  g_cond_SQL := '';

          --bug# 6689448 (replenishment project) :(begin) need to consider the replenishment status value.
	  IF ( g_backorders_flag = 'I' ) THEN
              Process_Buffer(p_print_flag,'c', ' AND WDD.RELEASED_STATUS IN ( ''R'',''B'',''X'') AND NVL(WDD.REPLENISHMENT_STATUS,''C'') = ''C'' ');
	  ELSIF ( g_backorders_flag = 'E' ) THEN
              Process_Buffer(p_print_flag,'c', ' AND WDD.RELEASED_STATUS IN ( ''R'',''X'') AND WDD.REPLENISHMENT_STATUS IS NULL');
	  ELSIF ( g_backorders_flag = 'O' ) THEN
              Process_Buffer(p_print_flag,'c', ' AND WDD.RELEASED_STATUS IN ( ''B'',''X'') AND WDD.REPLENISHMENT_STATUS IS NULL');
          ELSIF ( g_backorders_flag = 'M' ) THEN
              Process_Buffer(p_print_flag,'c', '  AND WDD.RELEASED_STATUS IN ( ''R'',''B'') AND WDD.REPLENISHMENT_STATUS = ''C'' ');
	  END IF;
          --bug# 6689448 (replenishment project) : (end)

	  --Bug 3433645 : OMFST:J: AUTOMATED SHIPPING FAILING FOR ORDER WITH HUGE DELIVERY LINES
	  --g_del_detail_id is set to -1 if batch id for an item in a container is chagned.
	  -- bug # 8915460 :g_del_detail_id is set to -2 when pick release is submitted from
      --               release so form or public APIs with Container/Line is specified.
	  IF (g_del_detail_id = -1 OR g_del_detail_id = -2 ) THEN

		 Process_Buffer(p_print_flag,'c',' AND WDA.DELIVERY_DETAIL_ID IN '
                          ||'( SELECT DELIVERY_DETAIL_ID FROM '
                          ||' WSH_DELIVERY_DETAILS WHERE BATCH_ID = :X_batch_id '
                          ||' AND CONTAINER_FLAG = ''N'')'); -- ,p_batch_id);

          ELSIF (g_del_detail_id <> 0) THEN
		 Process_Buffer(p_print_flag,'c', ' AND WDA.DELIVERY_DETAIL_ID = :X_del_detail_id'); -- ,g_del_detail_id);
	  END IF;
	  --End of Fix for Bug 3433645

	  IF (g_order_header_id <> 0 AND g_order_line_id = 0) THEN
		  Process_Buffer(p_print_flag,'c', ' AND WDD.SOURCE_HEADER_ID = :X_header_id '); -- ,g_order_header_id);
	  ELSIF (g_order_header_id <> 0 AND g_order_line_id <> 0) THEN
		  Process_Buffer(p_print_flag,'c',' AND WDD.SOURCE_HEADER_ID + 0 = :X_header_id'); -- ,g_order_header_id);
	  END IF;

	  IF (g_order_line_id <> 0) THEN
		 Process_Buffer(p_print_flag,'c', ' AND WDD.SOURCE_LINE_ID = :X_order_line_id'); -- ,g_order_line_id);
	  END IF;

	  IF (g_customer_id <> 0) THEN
		 Process_Buffer(p_print_flag,'c', ' AND WDD.CUSTOMER_ID = :X_customer_id'); -- ,g_customer_id);
	  END IF;
          --
          -- LSP PROJECT
          IF (g_client_id <> 0) THEN
		 Process_Buffer(p_print_flag,'c', ' AND WDD.CLIENT_ID = :X_client_id'); -- ,g_CLIENT_id);
	  END IF;
          -- LSP PROJECT: end

	  IF (g_ship_from_loc_id <> -1) THEN
		 Process_Buffer(p_print_flag,'c', ' AND WDD.SHIP_FROM_LOCATION_ID = :X_ship_from_loc_id'); -- ,g_ship_from_loc_id);
	  END IF;

	  IF (g_ship_to_loc_id <> 0) THEN
		 Process_Buffer(p_print_flag,'c', ' AND WDD.SHIP_TO_LOCATION_ID = :X_ship_to_loc_id'); -- ,g_ship_to_loc_id);
	  END IF;

	  IF (g_order_type_id <> 0) THEN
		 Process_Buffer(p_print_flag,'c', ' AND WDD.SOURCE_HEADER_TYPE_ID = :X_order_type_id'); -- ,g_order_type_id);
	  END IF;

	  IF (g_ship_set_number <> 0) THEN
		 Process_Buffer(p_print_flag,'c', ' AND WDD.SHIP_SET_ID = :X_ship_set_id'); -- ,g_ship_set_number);
	  END IF;

	  IF (g_task_id <> 0) THEN
		 Process_Buffer(p_print_flag,'c', ' AND WDD.TASK_ID = :X_task_id'); -- ,g_task_id);
	  END IF;

	  IF (g_project_id <> 0) THEN
		 Process_Buffer(p_print_flag,'c', ' AND WDD.PROJECT_ID = :X_project_id'); -- ,g_project_id);
	  END IF;

	  IF (p_organization_id IS NOT NULL) THEN
		 Process_Buffer(p_print_flag,'c', ' AND WDD.ORGANIZATION_ID = :X_org_id',p_organization_id);
	  END IF;

	  -- Bug 2040002: Flipped WDE and WDD. Not related to this bug
	  IF (g_ship_method_code IS NOT NULL) THEN
		 Process_Buffer(p_print_flag,'c', ' AND NVL(WDE.SHIP_METHOD_CODE,WDD.SHIP_METHOD_CODE) =  :X_ship_method_code '); -- ,g_ship_method_code);
	  END IF;

	  IF (g_shipment_priority IS NOT NULL) THEN
		 Process_Buffer(p_print_flag,'c', ' AND WDD.SHIPMENT_PRIORITY_CODE = :X_shipment_priority '); -- ,g_shipment_priority);
	  END IF;

	  IF (g_from_request_date IS NOT NULL) THEN
		 Process_Buffer(p_print_flag,'c',
		 ' AND TO_CHAR(WDD.DATE_REQUESTED, ''RRRR/MM/DD HH24:MI:SS'') >= :X_from_request_date');
	  END IF;

	  IF (g_to_request_date IS NOT NULL) THEN
		 Process_Buffer(p_print_flag,'c',
		 ' AND TO_CHAR(WDD.DATE_REQUESTED, ''RRRR/MM/DD HH24:MI:SS'') <= :X_to_request_date');
	  END IF;

	  IF (g_from_sched_ship_date IS NOT NULL) THEN
		 Process_Buffer(p_print_flag,'c',
		' AND TO_CHAR(WDD.DATE_SCHEDULED, ''RRRR/MM/DD HH24:MI:SS'') >= :X_from_sched_ship_date');
	  END IF;

	  IF (g_to_sched_ship_date IS NOT NULL) THEN
		 Process_Buffer(p_print_flag,'c',
		 ' AND TO_CHAR(WDD.DATE_SCHEDULED, ''RRRR/MM/DD HH24:MI:SS'') <= :X_to_sched_ship_date');
	  END IF;
          --}

          -- 30. For P_MODE as WORKER, the input parameter p_inv_item_id is considered as a query criteria
          --{
          IF p_mode = 'WORKER' THEN
             IF p_inv_item_id IS NOT NULL THEN
		 Process_Buffer(p_print_flag,'c', ' AND WDD.INVENTORY_ITEM_ID  = :X_inventory_item_id '); -- ,g_inventory_item_id);
	     END IF;
	  ELSE
             IF (g_inventory_item_id <> 0) THEN
		 Process_Buffer(p_print_flag,'c', ' AND WDD.INVENTORY_ITEM_ID  = :X_inventory_item_id '); -- ,g_inventory_item_id);
             END IF;
	  END IF;
          --}

          -- 40. Common Query Criteria
          --{
	  Process_Buffer(p_print_flag,'c', ' AND (WDA.DELIVERY_ID IS NULL');

	  IF (g_include_planned_lines <> 'N') THEN
		 Process_Buffer(p_print_flag,'c', '	  OR :X_include_planned_lines <> ''N'' '); -- ,g_include_planned_lines);
	  END IF;

	  IF (g_trip_id <> 0) THEN
		 Process_Buffer(p_print_flag,'c', '	  OR :X_trip_id <> 0'); -- ,g_trip_id );
	  END IF;

	  IF (g_delivery_id <> 0) THEN
		 Process_Buffer(p_print_flag,'c', '	  OR :X_delivery_id <> 0'); -- ,g_delivery_id );
	  END IF;

	  Process_Buffer(p_print_flag,'c', '	 )');

	  Process_Buffer(p_print_flag,
					 'c', ' AND (NVL(WDD.DEP_PLAN_REQUIRED_FLAG,''N'') = ''N''');
	  Process_Buffer(p_print_flag,
					 'c', '	  OR (NVL(WDD.DEP_PLAN_REQUIRED_FLAG,''N'') = ''Y''');
	  IF ((g_ship_method_code IS NOT NULL) OR
		  (g_trip_id > 0) OR
		  (g_use_trip_stop_date) OR
		  (g_delivery_id > 0)) THEN
		  Process_Buffer(p_print_flag,
					 'c', ' AND NVL(WDE.PLANNED_FLAG,''N'') IN (''Y'',''F'')))');
	  ELSE
		  Process_Buffer(p_print_flag,
					 'c', ' AND EXISTS ( SELECT 1 FROM WSH_NEW_DELIVERIES WDE1
	                             WHERE WDE1.DELIVERY_ID = WDA.DELIVERY_ID
                                     AND  ( NVL(WDE1.PLANNED_FLAG,''N'') IN (''Y'',''F'' ) )) ))');
	  END IF;

	  -- Handling trips and deliveries
	  IF ( g_delivery_id <> 0) THEN
		 Process_Buffer(p_print_flag,'c', ' AND WDE.DELIVERY_ID = :X_delivery_id'); -- ,g_delivery_id);
	  END IF;

	  IF (g_trip_id <> 0) THEN
		 Process_Buffer(p_print_flag,'c', ' AND WTS.TRIP_ID = :X_trip_id '); -- ,g_trip_id);
		IF (g_trip_stop_id <> 0) THEN
			Process_Buffer(p_print_flag,'c', ' AND WTS.STOP_ID = :X_trip_stop_id'); -- ,g_trip_stop_id);
		END IF;
	  END IF;

          IF (p_express_pick = 'Y' AND p_enforce_ship_set_and_smc = 'Y') THEN
              Process_Buffer(p_print_flag,'c', ' AND NOT(WDD.SHIP_SET_ID is null AND WDD.SHIP_MODEL_COMPLETE_FLAG = ''Y'' AND WDD.TOP_MODEL_LINE_ID is not null)');

          END IF;

          --If only prior reservation exists
	  IF (g_existing_rsvs_only_flag = 'Y') THEN

		l_ont_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,  'OM: SOURCE CODE IS '|| L_ONT_SOURCE_CODE  );
		END IF;
		--
		Process_Buffer(p_print_flag,'c', ' AND MSORD1.SEGMENT1               = WDD.SOURCE_HEADER_NUMBER');
                --bug 6082122: Comparing MSORD1.SEGMENT2 with the order type name for the base language
                Process_Buffer(p_print_flag,'c', ' AND MSORD1.SEGMENT2           = OTTT.NAME');
                Process_Buffer(p_print_flag,'c', ' AND OTTT.TRANSACTION_TYPE_ID  = WDD.SOURCE_HEADER_TYPE_ID');
                Process_Buffer(p_print_flag,'c', ' AND OTTT.LANGUAGE  = (SELECT language_code FROM fnd_languages WHERE installed_flag = ''B'') ');
		IF (l_ont_source_code is NOT NULL) THEN
		  Process_Buffer(p_print_flag,'c', ' AND MSORD1.SEGMENT3               = '''|| l_ont_source_code ||'''');
		END IF;
		Process_Buffer(p_print_flag,'c', ' AND MR.DEMAND_SOURCE_HEADER_ID = MSORD1.SALES_ORDER_ID');
		Process_Buffer(p_print_flag,'c', ' AND MR.DEMAND_SOURCE_LINE_ID   = WDD.SOURCE_LINE_ID');
		Process_Buffer(p_print_flag,'c', ' AND NVL(MR.SHIP_READY_FLAG, 2) = 2');
                Process_Buffer(p_print_flag,'c', ' AND MR.PRIMARY_RESERVATION_QUANTITY - NVL(MR.DETAILED_QUANTITY,0) > 0');

                -- Bug 3157902
                -- rlanka : Process_Buffer accepts only 1 bind variable
		--
                IF (g_from_subinventory IS NOT NULL) THEN
                  Process_Buffer(p_print_flag,'c',
                        ' AND ((MR.SUBINVENTORY_CODE IS NOT NULL ' ||
                        ' AND MR.SUBINVENTORY_CODE = :X_subinventory_code)' ||
                        ' OR MR.SUBINVENTORY_CODE IS NULL)'); -- ,
                        -- g_from_subinventory);
                END IF;
                --
                IF (g_from_locator IS NOT NULL) THEN
                  Process_Buffer(p_print_flag,'c',
                        ' AND ((MR.LOCATOR_ID IS NOT NULL ' ||
                        ' AND MR.LOCATOR_ID = :X_locator_id)' ||
                        ' OR MR.LOCATOR_ID IS NULL)'); -- ,
                        -- g_from_locator);
                END IF;
                --
          END IF;

	 /* rlanka : Pack J Enhancement
           * Need mtl_category_sets and mtl_category_set_valid_cats only *
           * if pick releasing by category                               *
           * Need wsh_region_locations only if releasing by region/zone  *
          */
          IF (g_CategorySetID <> 0) THEN
            Process_Buffer(p_print_flag, 'c', ' AND MCS.category_set_id = MIC.category_set_id '
               || ' AND MCS.category_set_id = :x_CategorySetID '); -- ,g_CategorySetID);

            IF (g_CategoryID <> 0) THEN
               Process_Buffer(p_print_flag, 'c', ' AND MIC.category_id = :x_CategoryID '
               || ' AND MIC.organization_id = WDD.organization_id '
               || ' AND MIC.inventory_item_id = WDD.inventory_item_id '); -- ,g_CategoryID);
            END IF;
          END IF;

          --
          IF g_RegionID <> 0 THEN
            Process_Buffer(p_print_flag, 'c',
			' AND WDD.ship_to_location_id IN (select location_id '
		     || ' FROM wsh_region_locations WHERE region_id =  :x_RegionID)'); -- ,g_RegionID);
          END IF;
          --
          IF g_ZoneID <> 0 THEN
            Process_Buffer(p_print_flag, 'c',
               ' AND WDD.ship_to_location_id IN (select location_id '
			|| ' FROM wsh_region_locations WHERE region_id IN '
		        || ' (SELECT region_id FROM wsh_zone_regions WHERE '
		        || ' parent_region_id = :x_ZoneID))'); -- ,g_ZoneID);
          END IF;
	  --
          IF (g_RelSubInventory IS NOT NULL) THEN
            Process_Buffer(p_print_flag, 'c',
		' AND NVL(WDD.subinventory, ''-99'') = NVL(:x_RelSubInv, ''-99'')'); -- ,g_RelSubInventory);
          END IF;
          --}

          -- 50. For Ship Sets/SMCs, P_MODE and P_INV_ITEM_ID is also considered.
          --{
	  /* Bug#: 3266659 : Ignore the line when  pick release criteria SHIP_SET_SMC_FLAG is E (Exclude)
	  and  line is part of the SHIP SET or  line is part of the Model with SHIP MODEL COMPLETE is set YES.
          Ignore the line when  pick release criteria SHIP_SET_SMC_FLAG is I (Include)
          and  line is not part of the SHIP SET  AND  line is part of the Model with SHIP MODEL COMPLETE is set NO.
          This action is applicable only when the shipping parameter "Enforce Ship Set and SMC" is set 'YES' */
	  IF ( p_enforce_ship_set_and_smc = 'Y' ) THEN
              IF ( g_ship_set_smc_flag = 'E') OR ( p_mode = 'WORKER' AND p_inv_item_id IS NOT NULL )THEN
                  Process_Buffer(p_print_flag, 'c', ' AND WDD.SHIP_SET_ID IS NULL '
                                       || ' AND ( NVL(WDD.SHIP_MODEL_COMPLETE_FLAG,''N'') = ''N'')');
              ELSIF( g_ship_set_smc_flag = 'I') OR ( p_mode = 'WORKER' AND p_inv_item_id IS NULL ) THEN
                  Process_Buffer(p_print_flag, 'c', ' AND (WDD.SHIP_SET_ID IS NOT NULL '
                                       || ' OR ( NVL(WDD.SHIP_MODEL_COMPLETE_FLAG,''N'') = ''Y'' '
                                       || ' AND WDD.TOP_MODEL_LINE_ID IS NOT NULL ))');
             END IF;
          END IF;
          --}

          -- 60. Build Order By Clause and Group By Clause (for P_MODE = SUMMARY)
          --
	  -- Determine the order by clause
	  --
	  IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_module_name, 'ORDER BY CLAUSE FOR ORGANIZATION ' || TO_CHAR(P_ORGANIZATION_ID));
	  END IF;
	  --
	  g_orderby_SQL := '';

          IF p_mode = 'SUMMARY' THEN
          --{
             IF p_enforce_ship_set_and_smc = 'N' THEN
                Process_Buffer('Y','o', ' GROUP BY WDD.ORGANIZATION_ID, WDD.INVENTORY_ITEM_ID ');
             ELSE
                Process_Buffer('Y','o', ' GROUP BY WDD.ORGANIZATION_ID,
                                DECODE(WDD.SHIP_SET_ID,NULL,DECODE(WDD.SHIP_MODEL_COMPLETE_FLAG,''Y'',NULL,WDD.INVENTORY_ITEM_ID),NULL) ');
             END IF;
          --}

          ELSE
          --{
	     Process_Buffer('Y','o', ' ORDER BY ');

	     --Bug #2898157 : Replaced SOURCE_HEADER_ID with SOURCE_HEADER_NUMBER
	     --Bug #3266659 : do not consider the shipsets/SMC  when g_ship_set_smc_flag is E (Exclude shipsets/SMCs)
	     --               and p_enforce_ship_set_and_smc = 'Y'
	     IF (p_enforce_ship_set_and_smc = 'Y' AND g_ship_set_smc_flag <> 'E') THEN
             --{
	   	FOR i IN 1..g_total_pick_criteria LOOP
		    IF (g_ordered_psr(i).attribute = C_INVOICE_VALUE) THEN
                Process_Buffer('Y','o', ' OUTSTANDING_ORDER_VALUE ' || g_ordered_psr(i).sort_order || ', ');
                Process_Buffer('Y','o', ' SOURCE_HEADER_ID ASC ,');
		    ELSIF (g_ordered_psr(i).attribute = C_ORDER_NUMBER) THEN
                Process_Buffer('Y','o', ' to_number(SOURCE_HEADER_NUMBER) ' || g_ordered_psr(i).sort_order || ', ');
		    ELSIF (g_ordered_psr(i).attribute = C_SCHEDULE_DATE) THEN
                Process_Buffer('Y','o', ' DATE_SCHEDULED ' || g_ordered_psr(i).sort_order || ', ');
		    ELSIF (g_ordered_psr(i).attribute = C_SHIPMENT_PRIORITY) THEN
                Process_Buffer('Y','o', ' SHIPMENT_PRIORITY_CODE ' || g_ordered_psr(i).sort_order || ', ');
		    END IF;
		END LOOP;

	        Process_Buffer('Y','o', ' NVL(WDD.SHIP_SET_ID,999999999), ');

	        -- Consider SMC only if SS is not specified
	        Process_Buffer('Y','o', ' DECODE(NVL(WDD.SHIP_SET_ID,-999999999), -999999999, WDD.SHIP_MODEL_COMPLETE_FLAG,NULL) DESC, ');

	        -- This is necessary to push the non-transactable lines ahead in SS/SMC
		Process_Buffer('Y','o', ' RELEASED_STATUS DESC, ');

	        -- Consider SMC only if SS is not specified
		Process_Buffer('Y','o', ' DECODE(NVL(WDD.SHIP_SET_ID,-999999999), -999999999,WDD.TOP_MODEL_LINE_ID,NULL), ');
		Process_Buffer('Y','o', ' WDD.INVENTORY_ITEM_ID, ');

	        -- Inventory needs this for grouping all lines by line_id for SMCs
		Process_Buffer('Y','o', ' WDD.SOURCE_LINE_ID, ');

		FOR i IN 1..g_total_pick_criteria LOOP
		    IF (g_ordered_psr(i).attribute = C_TRIP_STOP_DATE) THEN
			Process_Buffer('Y','o', ' PLANNED_DEPARTURE_DATE ' || g_ordered_psr(i).sort_order || ', ');
		    END IF;
		END LOOP;
             --}

	     ELSE
             --{
		-- Not SS/SMC enforced

		Process_Buffer('Y','o', ' WDD.INVENTORY_ITEM_ID, ');
--Bug #2898157 : Replaced SOURCE_HEADER_ID with SOURCE_HEADER_NUMBER

		FOR i IN 1..g_total_pick_criteria LOOP
		    IF (g_ordered_psr(i).attribute = C_INVOICE_VALUE) THEN
			Process_Buffer('Y','o', ' OUTSTANDING_ORDER_VALUE ' || g_ordered_psr(i).sort_order || ', ');
			Process_Buffer('Y','o', ' SOURCE_HEADER_ID ASC ,');
		    ELSIF (g_ordered_psr(i).attribute = C_ORDER_NUMBER) THEN
		        Process_Buffer('Y','o', ' to_number(SOURCE_HEADER_NUMBER) ' || g_ordered_psr(i).sort_order || ', ');
		    ELSIF (g_ordered_psr(i).attribute = C_SCHEDULE_DATE) THEN
		        Process_Buffer('Y','o', ' DATE_SCHEDULED ' || g_ordered_psr(i).sort_order || ', ');
		    ELSIF (g_ordered_psr(i).attribute = C_TRIP_STOP_DATE) THEN
		        Process_Buffer('Y','o', ' PLANNED_DEPARTURE_DATE ' || g_ordered_psr(i).sort_order || ', ');
	            ELSIF (g_ordered_psr(i).attribute = C_SHIPMENT_PRIORITY) THEN
		        Process_Buffer('Y','o', ' SHIPMENT_PRIORITY_CODE ' || g_ordered_psr(i).sort_order || ', ');
		    END IF;
		END LOOP;
             --}
	     END IF;

	     Process_Buffer('Y','o', ' SHIP_FROM_LOCATION_ID');

          --}
	  END IF;

          --HVOP
	  g_sql_stmt := '( ' || g_Unreleased_SQL || g_Cond_SQL||' ) '|| g_orderby_SQL;

	  --HVOP

	  IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Dynamic SQL-'||g_Unreleased_SQL||g_cond_SQL||g_orderby_SQL);
	  END IF;

          -- 70. Parse  Cursor
          v_CursorID := DBMS_SQL.Open_Cursor;
          --
          IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,  'PARSE CURSOR'  );
          END IF;
          --
          DBMS_SQL.Parse(v_CursorID, g_Unreleased_SQL || g_Cond_SQL|| g_orderby_SQL, DBMS_SQL.v7 );
          --
          IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,  'COLUMN DEFINITION FOR CURSOR'  );
          END IF;
          --
          --{
          IF p_mode = 'SUMMARY' THEN
             DBMS_SQL.Define_Column(v_CursorID, 1, v_org_id);
             DBMS_SQL.Define_Column(v_CursorID, 2, v_inventory_item_id);
             DBMS_SQL.Define_Column(v_CursorID, 3, v_count);
          ELSE --{
             DBMS_SQL.Define_Column(v_CursorID, 1,  v_line_id);
             DBMS_SQL.Define_Column(v_CursorID, 2,  v_header_id);
             DBMS_SQL.Define_Column(v_CursorID, 3,  v_org_id);
             DBMS_SQL.Define_Column(v_CursorID, 4,  v_inventory_item_id);
             DBMS_SQL.Define_Column(v_CursorID, 5,  v_move_order_line_id);
             DBMS_SQL.Define_Column(v_CursorID, 6,  v_delivery_detail_id);
             DBMS_SQL.Define_Column(v_CursorID, 7,  v_ship_model_complete_flag,1);
             DBMS_SQL.Define_Column(v_CursorID, 8,  v_top_model_line_id);
             DBMS_SQL.Define_Column(v_CursorID, 9,  v_ship_from_location_id);
             DBMS_SQL.Define_Column(v_CursorID, 10,  v_ship_method_code,30);
             DBMS_SQL.Define_Column(v_CursorID, 11, v_shipment_priority,30);
             DBMS_SQL.Define_Column(v_CursorID, 12, v_date_scheduled);
             DBMS_SQL.Define_Column(v_CursorID, 13, v_requested_quantity);
             DBMS_SQL.Define_Column(v_CursorID, 14, v_requested_quantity_uom,3);
             DBMS_SQL.Define_Column(v_CursorID, 15, v_preferred_grade, 150); -- HW OPMCONV.
             DBMS_SQL.Define_Column(v_CursorID, 16, v_requested_quantity2);
             DBMS_SQL.Define_Column(v_CursorID, 17, v_requested_quantity_uom2, 3);
             DBMS_SQL.Define_Column(v_CursorID, 18, v_project_id);
             DBMS_SQL.Define_Column(v_CursorID, 19, v_task_id);
             DBMS_SQL.Define_Column(v_CursorID, 20, v_from_sub,10);
             DBMS_SQL.Define_Column(v_CursorID, 21, v_to_sub,10);
             DBMS_SQL.Define_Column(v_CursorID, 22, v_released_status,1);
             DBMS_SQL.Define_Column(v_CursorID, 23, v_ship_set_id);
             DBMS_SQL.Define_Column(v_CursorID, 24, v_source_code,30);
             DBMS_SQL.Define_Column(v_CursorID, 25, v_source_header_number,150);
             DBMS_SQL.Define_Column(v_CursorID, 26, v_planned_departure_date);
             DBMS_SQL.Define_Column(v_CursorID, 27, v_delivery_id);
             DBMS_SQL.Define_Column(v_CursorID, 28, v_unit_number, 30);
             DBMS_SQL.Define_Column(v_CursorID, 29, v_source_doc_type);
             DBMS_SQL.Define_Column(v_CursorID, 30, v_reservable_type,1);
             DBMS_SQL.Define_Column(v_CursorID, 31, v_last_update_date);
             DBMS_SQL.Define_Column(v_CursorID, 32, v_demand_source_header_id);
             DBMS_SQL.Define_Column(v_CursorID, 33, v_invoice_value);
             -- anxsharm, X-dock, customer_id
             DBMS_SQL.Define_Column(v_CursorID, 34, v_customer_id);
             -- Standalone project Changes start
             DBMS_SQL.Define_Column(v_CursorID, 35, v_revision, 3);
             DBMS_SQL.Define_Column(v_CursorID, 36, v_from_locator);
             DBMS_SQL.Define_Column(v_CursorID, 37, v_lot_number, 32);
             -- Standalone project Changes end
             DBMS_SQL.Define_Column(v_CursorID, 38, v_client_id); -- LSP PROJECT
             --}
          END IF;
          --}

          --  80. Bind release criteria values
          --
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'BIND CURSOR'  );
          END IF;
          --
          --{
          -- bug # 8915460 : Added g_del_detail_id = - 2 condition.
          IF (g_del_detail_id = -1 OR g_del_detail_id = -2) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_batch_id',p_batch_id);
          ELSIF (g_del_detail_id <> 0) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_del_detail_id',g_del_detail_id);
          END IF;
          IF (g_order_header_id <> 0) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_header_id',g_order_header_id);
          END IF;
          IF (g_order_line_id <> 0) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_order_line_id',g_order_line_id);
          END IF;
          IF (g_customer_id <> 0) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_customer_id',g_customer_id);
          END IF;
          -- LSP PROJECT
          IF (g_CLIENT_id <> 0) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_client_id',g_client_id);
          END IF;
          -- LSP PROJECT
          IF (g_ship_from_loc_id <> -1) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_ship_from_loc_id',g_ship_from_loc_id);
          END IF;
          IF (g_ship_to_loc_id <> 0) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_ship_to_loc_id',g_ship_to_loc_id);
          END IF;
          IF (g_order_type_id <> 0) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_order_type_id',g_order_type_id);
          END IF;
          IF (g_ship_set_number <> 0) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_ship_set_id',g_ship_set_number);
          END IF;
          IF (g_task_id <> 0) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_task_id',g_task_id);
          END IF;
          IF (g_project_id <> 0) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_project_id',g_project_id);
          END IF;
          IF (p_organization_id IS NOT NULL) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_org_id',p_organization_id);
          END IF;
          IF (g_ship_method_code IS NOT NULL) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_ship_method_code',g_ship_method_code);
          END IF;
          IF (g_shipment_priority IS NOT NULL) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_shipment_priority',g_shipment_priority);
          END IF;
          IF (g_from_request_date IS NOT NULL) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_from_request_date',TO_CHAR(g_from_request_date,'RRRR/MM/DD HH24:MI:SS'));
          END IF;
          IF (g_to_request_date IS NOT NULL) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_to_request_date',TO_CHAR(g_to_request_date,'RRRR/MM/DD HH24:MI:SS'));
          END IF;
          IF (g_from_sched_ship_date IS NOT NULL) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_from_sched_ship_date',TO_CHAR(g_from_sched_ship_date,'RRRR/MM/DD HH24:MI:SS'));
          END IF;
          IF (g_to_sched_ship_date IS NOT NULL) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_to_sched_ship_date',TO_CHAR(g_to_sched_ship_date,'RRRR/MM/DD HH24:MI:SS'));
          END IF;
          --}

          --{
          IF p_mode = 'WORKER' THEN
             IF (p_inv_item_id IS NOT NULL) THEN
                 DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_inventory_item_id',p_inv_item_id);
             END IF;
          ELSE
             IF (g_inventory_item_id <> 0) THEN
                 DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_inventory_item_id',g_inventory_item_id);
             END IF;
          END IF;
          --}

          --{
          IF (g_include_planned_lines <> 'N') THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_include_planned_lines',g_include_planned_lines);
          END IF;
          IF (g_trip_id <> 0) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_trip_id',g_trip_id);
              IF (g_trip_stop_id <> 0) THEN
                  DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_trip_stop_id', g_trip_stop_id);
              END IF;
          END IF;
          IF (g_delivery_id <> 0) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_delivery_id',g_delivery_id);
          END IF;
          IF (g_existing_rsvs_only_flag = 'Y') THEN
              IF (g_from_subinventory IS NOT NULL) THEN
                  DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_subinventory_code',g_from_subinventory);
              END IF;
              IF (g_from_locator IS NOT NULL) THEN
                  DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_locator_id',g_from_locator);
              END IF;
          END IF;
          IF (g_categorysetid <> 0) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_categorysetid',g_categorysetid);
              IF (g_categoryid <> 0) THEN
                  DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_categoryid',g_categoryid);
              END IF;
          END IF;
          IF (g_regionid <> 0) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_regionid',g_regionid);
          END IF;
          IF (g_zoneid <> 0) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_zoneid',g_zoneid);
          END IF;
          IF (g_RelSubInventory IS NOT NULL) THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID,':x_relsubinv',g_relsubinventory);
          END IF;
          --}

          --  90. Execute the cursor
          --
          IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,  'EXECUTING CURSOR'  );
          END IF;
          --
          v_ignore := DBMS_SQL.Execute(v_CursorID);


          --  100. Fetching records for SUMMARY mode and inserting worker records
          --{
          IF p_mode = 'SUMMARY' THEN
             l_count := 0;
             LOOP
               IF DBMS_SQL.Fetch_Rows(v_cursorID) = 0 THEN
                  DBMS_SQL.Close_Cursor(v_cursorID);
                  v_cursorID := NULL;
                  EXIT;
               ELSE
                  DBMS_SQL.Column_Value(v_CursorID, 1, v_org_id);
                  DBMS_SQL.Column_Value(v_CursorID, 2, v_inventory_item_id);
                  DBMS_SQL.Column_Value(v_CursorID, 3, v_count);

                  INSERT INTO WSH_PR_WORKERS (
                                               batch_id,
                                               type,
                                               mo_header_id,
                                               organization_id,
                                               inventory_item_id,
                                               mo_start_line_number,
                                               mo_line_count,
                                               processed
                                              )
                                     VALUES  (
                                               WSH_PICK_LIST.G_BATCH_ID,
                                               'PICK',
                                               p_mo_header_id,
                                               v_org_id,
                                               v_inventory_item_id,
                                               l_count + 1,
                                               v_count,
                                               'N'
                                              );

                  x_worker_count := nvl(x_worker_count,0) + 1;
                  IF v_inventory_item_id IS NULL THEN
                     x_smc_worker_count := nvl(x_smc_worker_count,0) + 1;
                  END IF;
                  l_count := l_count + v_count;
               END IF;
             END LOOP;

             x_dd_count := nvl(x_dd_count,0) + l_count;

  	     IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'x_dd_count ',x_dd_count);
                WSH_DEBUG_SV.log(l_module_name,'x_worker_count ',x_worker_count);
                WSH_DEBUG_SV.log(l_module_name,'x_smc_worker_count ',x_smc_worker_count);
   	     END IF;
          END IF;
          --}

	  x_api_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	  IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	  END IF;

EXCEPTION
     --
     WHEN OTHERS THEN
       IF DBMS_SQL.IS_Open(v_cursorID) THEN
          DBMS_SQL.Close_Cursor(v_cursorID);
       END IF;
       --
       x_api_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       --
       IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,  'UNEXPECTED ERROR IN CREATING SELECT STATEMENT');
	WSH_DEBUG_SV.logmsg(l_module_name,  'SQL ERROR: ' || SQLERRM ( SQLCODE ));
	WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --
END Init_Cursor;


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
          p_enforce_ship_set_and_smc    IN  VARCHAR2,
          p_wms_flag                    IN  VARCHAR2,
          p_express_pick_flag           IN  VARCHAR2,
          p_batch_id                    IN  NUMBER,
          x_done_flag                   OUT NOCOPY  VARCHAR2,
          x_api_status                  OUT NOCOPY  VARCHAR2
   ) IS
   --
   l_get_lock_status VARCHAR2(1);
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_LINES';
   l_ship_set_id     NUMBER;
   l_model_line_id   NUMBER;
   --
   l_skip_detail     VARCHAR2(1); -- Bug# 3248578

    -- Bug 4775539
   l_requested_qty_uom     VARCHAR2(3);
   l_src_requested_qty_uom VARCHAR2(3);
   l_src_requested_qty     NUMBER;
   l_inv_item_id           NUMBER;

   -- LPN CONV. rvishnuv
   l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
   l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(32767);
   e_return_excp EXCEPTION;
   -- LPN CONV. rvishnuv

   l_mode          VARCHAR2(10); -- for setting mode value
   l_temp          VARCHAR2(1);
   l_dummy         NUMBER;
   l_dummy1        NUMBER;
   l_dummy2        NUMBER;

BEGIN
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
	WSH_DEBUG_SV.push(l_module_name);
	WSH_DEBUG_SV.log(l_module_name,'P_ENFORCE_SHIP_SET_AND_SMC',P_ENFORCE_SHIP_SET_AND_SMC);
	WSH_DEBUG_SV.log(l_module_name,'P_WMS_FLAG',P_WMS_FLAG);
	WSH_DEBUG_SV.log(l_module_name,'P_EXPRESS_PICK_FLAG',P_EXPRESS_PICK_FLAG);
	WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
    END IF;
    --
    x_api_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    -- handle uninitialized package errors here
    IF g_initialized = FALSE THEN
     --{
     x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     --
     IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,  'THE PACKAGE MUST BE INITIALIZED BEFORE USE'  );
	WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --
     RETURN;
     --}
   END IF;
   --
   g_rel_current_line := 1;
   -- Clear the table
   release_table.delete;

   -- Set flag to indicate that fetching is not completed for an organization
   x_done_flag := FND_API.G_FALSE;

   -- Set the mode for Init_Cursor
   -- If Single process, mode is Null, otherwise Worker
   IF WSH_PICK_LIST.G_PICK_REL_PARALLEL THEN
      l_mode := 'WORKER';
   ELSE
      l_mode := NULL;
   END IF;

   -- If called after the first time, place the last row fetched in previous
   -- call as the first row, since it was not returned in the previous call
   IF first_line.source_header_id <> -1 THEN
    --{
	-- Bug 1878992: Need to lock this again because the last lock would have got released
	-- by commit before detailing for the previous batch
        --
	Get_Detail_Lock(
                p_delivery_detail_id       => first_line.delivery_detail_id,
                p_ship_set_id              => first_line.ship_set_id,
                p_top_model_line_id        => first_line.top_model_line_id,
                p_enforce_ship_set_and_smc => p_enforce_ship_set_and_smc,
                -- Bug 4775539
                x_requested_qty_uom        => l_requested_qty_uom,
                x_src_requested_qty_uom    => l_src_requested_qty_uom,
                x_src_requested_qty        => l_src_requested_qty,
                x_inv_item_id              => l_inv_item_id,
                x_skip_detail              => l_skip_detail, -- Bug# 3248578
                x_return_status            => l_get_lock_status);
	IF (l_get_lock_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         --{
	 IF l_skip_detail = 'N' THEN
	 IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_module_name, 'GOT LOCK ON DELIVERY DETAIL '||
					FIRST_LINE.DELIVERY_DETAIL_ID||' AGAIN');
	 END IF;
	 --
	 release_table(g_rel_current_line) := first_line;
         g_last_ship_set_id := release_table(g_rel_current_line).ship_set_id;
	 g_last_top_model_line_id := release_table(g_rel_current_line).top_model_line_id;
	 g_last_model_quantity := release_table(g_rel_current_line).top_model_quantity;
	 g_last_header_id := release_table(g_rel_current_line).source_header_id;
	 g_last_source_code := release_table(g_rel_current_line).source_code;
	 g_rel_current_line := g_rel_current_line + 1;
         --}
         ELSE
	    IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'No longer eligible to pick release. Ignoring Delivery Detail '||first_line.delivery_detail_id);
	    END IF;
         END IF;

	ELSE
         --{
	 IF l_debug_on THEN
	   WSH_DEBUG_SV.logmsg(l_module_name,  'UNABLE TO LOCK. IGNORING DELIVERY DETAIL '
					||FIRST_LINE.DELIVERY_DETAIL_ID  );
	 END IF;
	 --}
	END IF;
     --}
     ELSE
      --{
        g_lock_or_hold_failed	   := FALSE;
	g_failed_ship_set_id	   := NULL;
	g_failed_top_model_line_id := NULL;
	g_last_ship_set_id	   := NULL;
	g_last_top_model_line_id   := NULL;
	g_last_model_quantity	   := NULL;
	g_last_header_id	   := NULL;
	g_last_source_code	   := NULL;
      --}
    END IF; /* if first_line */

    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'g_rel_current_line', g_rel_current_line);
    END IF;

    LOOP
    --{
        IF v_cursorID IS NOT NULL THEN
           l_dummy := DBMS_SQL.Fetch_Rows(v_cursorID);
        END IF;
        IF ( v_cursorID IS NULL ) OR ( l_dummy = 0 ) THEN
        -- Either all lines are fetched for a worker record or a New Organization
        --{
	    IF l_debug_on THEN
	       WSH_DEBUG_SV.log(l_module_name, 'v_cursorID',v_cursorID);
            END IF;

            --{
            -- Fetch and lock worker record to get Organization - Item combination
            v_prev_item_id := v_pr_inv_item_id;
            LOOP
              FETCH c_work_cursorID INTO v_pr_org_id, v_pr_inv_item_id, v_pr_mo_line_number, v_pr_mo_line_count,v_rowid;  -- Bug # 9369504 : added rowid
              IF c_work_cursorID%NOTFOUND THEN --{
	         IF l_debug_on THEN
	  	    WSH_DEBUG_SV.logmsg(l_module_name,  'FETCHED ALL LINES FOR ORGANIZATION');
	         END IF;
                 IF c_work_cursorID%ISOPEN THEN
                    CLOSE c_work_cursorID;
                 END IF;
                 IF v_CursorID IS NOT NULL THEN
                    DBMS_SQL.Close_Cursor(v_CursorID);
                    v_CursorID := NULL;
                 END IF;
                 x_done_flag := FND_API.G_TRUE;
                 EXIT;
              ELSE
              --{
		 IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Getting lock for worker record Batch '||p_batch_id
                                                    ||' Org '||v_pr_org_id|| ' Item '||v_pr_inv_item_id);
		 END IF;
                 DECLARE
                    worker_row_locked exception;
                    PRAGMA EXCEPTION_INIT(worker_row_locked, -54);
                 BEGIN
                   -- Bug # 9369504 : Added rowid in where clause.
                   SELECT 'Y'
                   INTO   l_temp
                   FROM   wsh_pr_workers
                   WHERE  ROWID = v_rowid
                   AND    processed = 'N'
                   FOR UPDATE NOWAIT;
                   EXIT; -- successfully locked
                 EXCEPTION
                   WHEN worker_row_locked THEN
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'Unable to lock as worker record as it is already locked');
                        END IF;
                        l_temp := 'N';
                   WHEN no_data_found THEN
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'Record already processed by one of the other workers');
                        END IF;
                        l_temp := 'N';
                   WHEN OTHERS THEN
                        IF l_debug_on THEN
                           WSH_DEBUG_SV.logmsg(l_module_name,'Unable to lock as worker record due to error');
                           WSH_DEBUG_SV.logmsg(l_module_name,SQLERRM);
                        END IF;
                        l_temp := 'N';
                 END;
              --}
              END IF;
            END LOOP;
            --}

            -- No more lines to process, then Exit ; otherwise check if worker record
            -- was locked and update worker record
            IF x_done_flag = FND_API.G_TRUE THEN
	       -- Reinitialize the first line marker since we have
   	       -- fetched all rows
	       first_line.source_header_id := -1;

	       -- If the last line is in SS/SMC we need to validate it
	       IF ((g_rel_current_line > 1) AND
	   	   ((release_table(g_rel_current_line - 1).ship_set_id > 0) OR
		   (release_table(g_rel_current_line - 1).top_model_line_id > 0))) THEN
	       --{
	   	   validate_ss_smc(
		     	   release_table(g_rel_current_line - 1).ship_set_id,
		  	   release_table(g_rel_current_line - 1).top_model_line_id,
		  	   release_table(g_rel_current_line - 1).source_header_id,
		  	   release_table(g_rel_current_line - 1).source_code,
		  	   g_return_status);
		   IF (g_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
		        x_api_status := g_return_status;
	                IF l_debug_on THEN
		           WSH_DEBUG_SV.logmsg(l_module_name,  'ERROR OCCURRED IN VALIDATE_SS_SMC/0'  );
		        END IF;
                        raise e_return_excp; -- LPN CONV. rv
   		   END IF;
               --}
	       END IF;
               EXIT;
            ELSIF l_temp = 'Y' THEN --{
               -- Update Worker Record as processed
               BEGIN
                  -- Bug # 9369504 : Added rowid in where clause.
                  UPDATE wsh_pr_workers
                  SET    processed = 'Y'
                  WHERE  ROWID= v_rowid;
               EXCEPTION WHEN OTHERS THEN
                  x_api_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred in updating worker records as processed');
                     WSH_DEBUG_SV.pop(l_module_name);
                  END IF;
                  IF DBMS_SQL.Is_Open(v_CursorID) THEN
                     DBMS_SQL.Close_Cursor(v_CursorID);
                  END IF;
                  IF c_work_cursorID%ISOPEN THEN
                     CLOSE c_work_cursorID;
                  END IF;
                  ROLLBACK;
                  RETURN;
               END;
	    END IF; --}

            --{
            -- Open Cursor for Organization - Item combination, only if called for new Organization OR
            -- if the previous call was for SMC and now for regular item as Item Bind Variable changes
            IF ( v_cursorID IS NULL ) OR ( v_prev_item_id IS NULL ) THEN
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PR_CRITERIA.Init_Cursor', WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               Init_Cursor (
                             p_organization_id          => v_pr_org_id,
                             p_mode                     => l_mode,
                             p_wms_org                  => p_wms_flag,
                             p_mo_header_id             => NULL, -- this is not required for WORKER mode
                             p_inv_item_id              => v_pr_inv_item_id,
                             p_enforce_ship_set_and_smc => p_enforce_ship_set_and_smc,
                             p_print_flag               => 'Y',  -- this should be printed only once for each Organization
                                                                 -- use global variable to print only once for all Orgs
                             p_express_pick             => p_express_pick_flag,
                             p_batch_id                 => p_batch_id,
                             x_worker_count             => l_dummy,
                             x_smc_worker_count         => l_dummy2,
                             x_dd_count                 => l_dummy1,
                             x_api_status               => x_api_status);
               IF (x_api_status = WSH_UTIL_CORE.G_RET_STS_ERROR) OR (x_api_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred in Init_Cursor');
                      WSH_DEBUG_SV.pop(l_module_name);
                   END IF;
                   IF DBMS_SQL.Is_Open(v_CursorID) THEN
                      DBMS_SQL.Close_Cursor(v_CursorID);
                   END IF;
                   IF c_work_cursorID%ISOPEN THEN
                      CLOSE c_work_cursorID;
                   END IF;
                   ROLLBACK;
                   RETURN;
               END IF;
               v_total_rec_fetched := 0;
            ELSE
               -- Bind the new Item and execute the cursor again
               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,  'Binding new Item '||v_pr_inv_item_id||' and Executing Cursor'  );
               END IF;
               DBMS_SQL.BIND_VARIABLE(v_CursorID,':X_inventory_item_id',v_pr_inv_item_id);
               l_dummy :=  DBMS_SQL.Execute(v_CursorID);
               v_total_rec_fetched := 0;
            END IF;
            --}

        --}
	ELSE
        --{
            IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,  'MAP OUTPUT COLUMNS'  );
            END IF;

            DBMS_SQL.Column_Value(v_CursorID, 1,  v_line_id);
            DBMS_SQL.Column_Value(v_CursorID, 2,  v_header_id);
            DBMS_SQL.Column_Value(v_CursorID, 3,  v_org_id);
            DBMS_SQL.Column_Value(v_CursorID, 4,  v_inventory_item_id);
            DBMS_SQL.Column_Value(v_CursorID, 5,  v_move_order_line_id);
            DBMS_SQL.Column_Value(v_CursorID, 6,  v_delivery_detail_id);
            DBMS_SQL.Column_Value(v_CursorID, 7,  v_ship_model_complete_flag);
            DBMS_SQL.Column_Value(v_CursorID, 8,  v_top_model_line_id);
            DBMS_SQL.Column_Value(v_CursorID, 9,  v_ship_from_location_id);
            DBMS_SQL.Column_Value(v_CursorID, 10,  v_ship_method_code);
            DBMS_SQL.Column_Value(v_CursorID, 11, v_shipment_priority);
            DBMS_SQL.Column_Value(v_CursorID, 12, v_date_scheduled);
            DBMS_SQL.Column_Value(v_CursorID, 13, v_requested_quantity);
            DBMS_SQL.Column_Value(v_CursorID, 14, v_requested_quantity_uom);
            DBMS_SQL.Column_Value(v_CursorID, 15, v_preferred_grade);
            DBMS_SQL.Column_Value(v_CursorID, 16, v_requested_quantity2);
            DBMS_SQL.Column_Value(v_CursorID, 17, v_requested_quantity_uom2);
            DBMS_SQL.Column_Value(v_CursorID, 18, v_project_id);
            DBMS_SQL.Column_Value(v_CursorID, 19, v_task_id);
            DBMS_SQL.Column_Value(v_CursorID, 20, v_from_sub);
            DBMS_SQL.Column_Value(v_CursorID, 21, v_to_sub);
            DBMS_SQL.Column_Value(v_CursorID, 22, v_released_status);
            DBMS_SQL.Column_Value(v_CursorID, 23, v_ship_set_id);
            DBMS_SQL.Column_Value(v_CursorID, 24, v_source_code);
            DBMS_SQL.Column_Value(v_CursorID, 25, v_source_header_number);
            DBMS_SQL.Column_Value(v_CursorID, 26, v_planned_departure_date);
            DBMS_SQL.Column_Value(v_CursorID, 27, v_delivery_id);
            DBMS_SQL.Column_Value(v_CursorID, 28, v_unit_number);
            DBMS_SQL.Column_Value(v_CursorID, 29, v_source_doc_type);
            DBMS_SQL.Column_Value(v_CursorID, 30, v_reservable_type);
            DBMS_SQL.Column_Value(v_CursorID, 31, v_last_update_date);
            DBMS_SQL.Column_Value(v_CursorID, 32, v_demand_source_header_id);
            DBMS_SQL.Column_Value(v_CursorID, 33, v_invoice_value);
            -- anxsharm, X-dock, customer_id
            DBMS_SQL.Column_Value(v_CursorID, 34, v_customer_id);
            -- Standalone project Changes start
            DBMS_SQL.Column_Value(v_CursorID, 35, v_revision);
            DBMS_SQL.Column_Value(v_CursorID, 36, v_from_locator);
            DBMS_SQL.Column_Value(v_CursorID, 37, v_lot_number);
            -- Standalone project Changes end
            DBMS_SQL.Column_Value(v_CursorID, 38, v_client_id); -- LSP PROJECT
	    IF l_debug_on THEN
	       WSH_DEBUG_SV.log(l_module_name, 'CURRENT LINE IS', TO_CHAR(G_REL_CURRENT_LINE));
	       WSH_DEBUG_SV.log(l_module_name, 'Delivery detail ID', v_delivery_detail_id);
	    END IF;

            -- Save fetched record into release table
	    Insert_RL_Row(p_enforce_ship_set_and_smc, l_skip_detail, g_return_status);

            IF (g_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) OR (g_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
		x_api_status := g_return_status;
		IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,  'ERROR OCCURRED IN INSERT_RL_ROW');
		  --WSH_DEBUG_SV.pop(l_module_name);
		END IF;
                IF DBMS_SQL.Is_Open(v_CursorID) THEN
                   DBMS_SQL.Close_Cursor(v_CursorID);
                END IF;
                IF c_work_cursorID%ISOPEN THEN
                   CLOSE c_work_cursorID;
                END IF;
		--RETURN;
                raise e_return_excp; -- LPN CONV. rv
	    ELSIF (g_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
		IF l_debug_on THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,  'WARNING: SKIPPING THE ORDER LINE');
		END IF;
		x_api_status := g_return_status;
	    ELSE
               IF l_skip_detail = 'N' THEN
                  g_rel_current_line := g_rel_current_line + 1;
                  v_total_rec_fetched := v_total_rec_fetched + 1;
               ELSE
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Skipping the Order Line');
                  END IF;
                  x_api_status := g_return_status;
               END IF;
	    END IF;
        --}
	END IF;

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'v_pr_mo_line_count : '||v_pr_mo_line_count||
                                             ' , v_total_rec_fetched : '||v_total_rec_fetched);
        END IF;

        IF (v_pr_mo_line_count is not null AND v_total_rec_fetched > v_pr_mo_line_count) THEN
        --{
            IF (release_table(g_rel_current_line - 1).ship_set_id > 0 OR
                release_table(g_rel_current_line - 1).top_model_line_id > 0) THEN
                  l_ship_set_id   := release_table(g_rel_current_line - 1).ship_set_id;
                  l_model_line_id := release_table(g_rel_current_line - 1).top_model_line_id;
                  LOOP
                    IF (release_table(g_rel_current_line - 1).ship_set_id = l_ship_set_id OR
                        release_table(g_rel_current_line - 1).top_model_line_id = l_model_line_id) THEN
                          release_table.delete(g_rel_current_line - 1);
                          g_rel_current_line := g_rel_current_line -1;
                    END IF;
                  END LOOP;
            ELSE
            -- Bug 7595246 : Need to delete the DD's which got inserted after parent
            --               process inserted the records into worker table.
                release_table.delete(g_rel_current_line - 1);
                g_rel_current_line := g_rel_current_line -1;
            END IF;
        --}
        END IF;

	IF (g_rel_current_line > MAX_LINES) THEN
        --{
	  IF (((release_table(g_rel_current_line - 1).ship_set_id > 0) AND
		(release_table(g_rel_current_line - 1).ship_set_id =
		  release_table(g_rel_current_line - 2).ship_set_id)) OR
		((release_table(g_rel_current_line - 1).top_model_line_id > 0) AND
		 (release_table(g_rel_current_line - 1).top_model_line_id =
		  release_table(g_rel_current_line - 2).top_model_line_id))) THEN
             IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'LARGE MODEL OR SS, IN MODEL FETCH MODE');
             END IF;
	  ELSE
	     first_line := release_table(g_rel_current_line - 1);
	     release_table.delete(g_rel_current_line - 1);
             g_rel_current_line := g_rel_current_line - 1;
	     x_done_flag := FND_API.G_FALSE;
             --If exceed MAX_LINES and not broken ship set or model
	     EXIT;
          END IF;
        --}
	END IF;
    --}
    END LOOP;

   -- LPN CONV. rvishnuv
   IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
   THEN
   --{

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;


       WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
         (
           p_in_rec             => l_lpn_in_sync_comm_rec,
           x_return_status      => g_return_status,
           x_out_rec            => l_lpn_out_sync_comm_rec
         );
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'Return Status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS API is ', g_return_status);
         WSH_DEBUG_SV.log(l_module_name, 'current value of x_api_status is ', x_api_status);
       END IF;
       --
       IF g_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
       THEN
       --{
           x_api_status := g_return_status;
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'UNEXPECTED ERROR OCCURRED IN WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS');
           END IF;
       --}
       ELSIF (g_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
       AND   nvl(x_api_status, WSH_UTIL_CORE.G_RET_STS_SUCCESS) NOT IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR))
       THEN
       --{
           x_api_status := g_return_status;
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'ERROR OCCURRED IN WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS');
           END IF;
       --}
       ELSIF (g_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
       AND    nvl(x_api_status, WSH_UTIL_CORE.G_RET_STS_SUCCESS) NOT IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR))
       THEN
       --{
           x_api_status := g_return_status;
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS API returned warning');
           END IF;
       --}
       END IF;
   --}
   END IF;
   -- LPN CONV. rvishnuv

    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'release_table.COUNT', release_table.COUNT);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
EXCEPTION
    --
    -- LPN CONV. rv
    WHEN e_return_excp THEN
      --
      IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
      THEN
      --{
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
            (
              p_in_rec             => l_lpn_in_sync_comm_rec,
              x_return_status      => g_return_status,
              x_out_rec            => l_lpn_out_sync_comm_rec
            );
          --
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,  'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS', g_return_status);
          END IF;
          IF (g_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) AND x_api_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            x_api_status := g_return_status;
          END IF;
      --}
      END IF;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:E_RETURN_EXCP');
      END IF;
      -- LPN CONV. rv
      --


    WHEN OTHERS THEN
      --
      IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      END IF;
      --
      IF DBMS_SQL.Is_Open(v_CursorID) THEN
         DBMS_SQL.Close_Cursor(v_CursorID);
      END IF;
      IF c_work_cursorID%ISOPEN THEN
         CLOSE c_work_cursorID;
      END IF;
      --
      x_done_flag := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_api_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => g_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',g_return_status);
              END IF;
              --
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
      --
      IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Get_Lines;


-- Start of comments
-- API name : Insert_RL_Row
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to store the pick release eligible line to pick release pl/sql table. Api does
--            1. Determine eligibility for ship set and models.
--            2. For order management source line check for  Credit hold.
--            3. Calculate reservation and backordered the difference, if requested quantity grater than the reserved  quantity.
--            4. Store the line information in pl/sql release table.
-- Parameters :
-- IN:
--      p_enforce_ship_set_and_smc      IN  Whether to enforce Ship Set and SMC validate value Y/N.
-- OUT:
--      x_done_flag         OUT NOCOPY  whether all lines have been fetched
--      x_skip_detail       OUT NOCOPY  Ignoring delivery detail since no longer satisfies the pick release criteria,
--                                      validate value Y/N.
--      x_api_status        OUT NOCOPY  Standard to output api status.
-- End of comments
PROCEDURE Insert_RL_Row(
	 p_enforce_ship_set_and_smc IN  VARCHAR2,
	  x_skip_detail              OUT NOCOPY VARCHAR2, --Bug# 3248578
	  x_api_status               OUT NOCOPY  VARCHAR2
   ) IS

   CURSOR c_order_line(v_line_id IN NUMBER) IS
   SELECT ORDERED_QUANTITY,
		ORDER_QUANTITY_UOM
   FROM   OE_ORDER_LINES_ALL
   WHERE  LINE_ID = v_line_id;

   l_return_status		  VARCHAR2(100);
   l_ordered_quantity	   NUMBER;
   l_order_quantity_uom	 VARCHAR2(3);
   l_requested_quantity	 NUMBER;
   l_new_delivery_detail_id NUMBER;
   l_split_status		   VARCHAR2(30);
   l_result				 NUMBER;

-- HW BUG#:1941429 cross_docking for OPM
   l_result2				 NUMBER;
   l_requested_quantity2	 NUMBER;
   l_msg_count						 NUMBER;
   l_msg_data                          VARCHAR2(3000);

   l_exception_return_status  VARCHAR2(30);
   l_exception_msg_count      NUMBER;
   l_exception_msg_data       VARCHAR2(4000) := NULL;
   l_dummy_exception_id       NUMBER;
   l_message                  VARCHAR2(2000);
   l_request_id               NUMBER;

   l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
   l_dbi_rs        VARCHAR2(1);             -- DBI Project

   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_RL_ROW';

      -- Bug 4775539
   l_requested_qty_uom     varchar2(3);
   l_src_requested_qty_uom varchar2(3);
   l_src_requested_qty     number;
   l_inv_item_id           number;
   l_exception_name        varchar2(2000);

BEGIN
	  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	  --
	  IF l_debug_on IS NULL
	  THEN
		  l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	  END IF;
	  --
	  IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    WSH_DEBUG_SV.log(l_module_name,'P_ENFORCE_SHIP_SET_AND_SMC',P_ENFORCE_SHIP_SET_AND_SMC);
	    WSH_DEBUG_SV.log(l_module_name, 'Delivery ID', v_delivery_id);
	    WSH_DEBUG_SV.log(l_module_name, 'Released Status', v_released_status);
	    WSH_DEBUG_SV.log(l_module_name, 'Quantity', v_requested_quantity);
	    WSH_DEBUG_SV.log(l_module_name, 'Quantity UOM', v_requested_quantity_uom);
	    WSH_DEBUG_SV.log(l_module_name, 'v_ship_model_complete_flag',v_ship_model_complete_flag);
            WSH_DEBUG_SV.log(l_module_name, 'Quantity2', v_requested_quantity2);
 	    WSH_DEBUG_SV.log(l_module_name, 'Quantity UOM2', v_requested_quantity_uom2);
	  END IF;

	  x_skip_detail := 'N'; --Bug# 3248578

	  IF (p_enforce_ship_set_and_smc = 'Y') THEN
          --{
		IF (v_released_status IN ('X')) THEN
                  --None pick release eligible  line, ignore
		  IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,  'THIS IS NON-TRANSACTABLE LINE. IGNORING SS/SMC'  );
		  END IF;
		  v_ship_set_id := NULL;
		  v_top_model_line_id := NULL;
		  v_ship_model_complete_flag := NULL;
		END IF;

		IF (v_ship_set_id IS NOT NULL) THEN
		  -- Ignore SMC if SS is Specified
		  IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,  'IGNORING SMC AS SHIP SET IS SPECIFIED'  );
		  END IF;
		  v_ship_model_complete_flag := NULL;
		  v_top_model_line_id := NULL;
		ELSE
		  IF (NVL(v_ship_model_complete_flag,'N') = 'N') THEN
			-- Ignore top_model_line_id if SMC is not set to Y
			v_top_model_line_id := NULL;
		  END IF;
		END IF;

		IF ((g_last_ship_set_id IS NULL) AND (g_last_top_model_line_id IS NULL)) THEN
		  g_lock_or_hold_failed	  := FALSE;
		  g_failed_ship_set_id	   := NULL;
		  g_failed_top_model_line_id := NULL;
		  g_last_model_quantity	  := NULL;
		  g_last_header_id		   := NULL;
		  g_last_source_code		 := NULL;
		END IF;

		IF l_debug_on THEN
		  WSH_DEBUG_SV.log(l_module_name,'g_last_ship_set_id',g_last_ship_set_id);
		  WSH_DEBUG_SV.log(l_module_name,'v_ship_set_id',v_ship_set_id);
		  WSH_DEBUG_SV.log(l_module_name,'g_last_top_model_line_id',g_last_top_model_line_id);
		  WSH_DEBUG_SV.log(l_module_name,'v_top_model_line_id',v_top_model_line_id);
		END IF;

		IF (((g_last_ship_set_id IS NOT NULL) AND (g_last_ship_set_id <> NVL(v_ship_set_id,-99))) OR
			((g_last_top_model_line_id IS NOT NULL) AND (g_last_top_model_line_id <> NVL(v_top_model_line_id,-99)))) THEN
		  -- SHIP SET OR SMC IS CHANGED. WE NEED TO VALIDATE SS/SMC
		  validate_ss_smc(
			g_last_ship_set_id,
			g_last_top_model_line_id,
			g_last_header_id,
			g_last_source_code,
			l_return_status);
		  IF (g_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,  'ERROR OCCURRED IN VALIDATE_SS_SMC/5'  );
			END IF;
			x_api_status := l_return_status;
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		  END IF;

		  g_lock_or_hold_failed	  := FALSE;
		  g_failed_ship_set_id	   := NULL;
		  g_failed_top_model_line_id := NULL;
		  g_last_ship_set_id		 := NULL;
		  g_last_top_model_line_id   := NULL;
		  g_last_model_quantity	  := NULL;
		  g_last_header_id		   := NULL;
		  g_last_source_code		 := NULL;
		END IF;
          --}
	  ELSE
          --{
		v_ship_set_id	   := NULL;
		v_top_model_line_id := NULL;
		v_ship_model_complete_flag := 'N';
          --}
	  END IF; -- p_enforce_ship_set_and_smc


	  IF (v_source_code = 'OE') THEN --{
		  -- Bug 1287776: Check for Credit Check and Holds
		  IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,
	              'PROCESSING HEADER '
	              ||TO_CHAR ( V_HEADER_ID )
	              ||' LINE '
	              ||TO_CHAR ( V_LINE_ID )
	              || ' DETAIL '
	              ||TO_CHAR ( V_DELIVERY_DETAIL_ID )
	              ||' SS '
	              ||TO_CHAR ( V_SHIP_SET_ID )
	              || ' MODEL '
	              ||TO_CHAR ( V_TOP_MODEL_LINE_ID )
	              || ' ITEM '
	              ||TO_CHAR ( V_INVENTORY_ITEM_ID )  );
		  END IF;

		IF ((p_enforce_ship_set_and_smc = 'Y') AND
			(g_lock_or_hold_failed) AND
			((g_failed_ship_set_id IS NOT NULL) OR (g_failed_top_model_line_id IS NOT NULL))) THEN
                --{
		  IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,  'IGNORING THIS LINE SINCE ONE OF THE PREVIOUS LINES IN SHIP SET/SMC FAILED'  );
		  END IF;
		  -- Ignore this line as previous line in ship set or model is faild.
		  x_api_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		  IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
		  END IF;
		  RETURN;
                --}
		END IF;

                -- Check if Credit Check needs to be called
                IF (WSH_PR_CRITERIA.g_credit_check_option = 'A') OR
                   (WSH_PR_CRITERIA.g_credit_check_option = 'R' AND v_released_status = 'R') OR
                   (WSH_PR_CRITERIA.g_credit_check_option = 'B' AND v_released_status = 'B') THEN --{
  		   IF l_debug_on THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,  'CHECKING FOR CREDIT CHECK/HOLDS'  );
		      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.CHECK_CREDIT_HOLDS',WSH_DEBUG_SV.C_PROC_LEVEL);
   		   END IF;
		   WSH_DETAILS_VALIDATIONS.check_credit_holds(
		     p_detail_id        => v_delivery_detail_id,
		     p_activity_type	=> 'PICK',
		     p_source_line_id   => v_line_id,
		     p_source_header_id => v_header_id,
		     p_source_code	=> v_source_code,
		     p_init_flag	=> 'N',
		     x_return_status	=> l_return_status);

		   IF  (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
		     /* Don't error out. Raise Warning only */
		     x_api_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		     Set_Globals(p_enforce_ship_set_and_smc, v_ship_set_id, v_top_model_line_id);
		     IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		     END IF;
		     RETURN;
		   END IF;
		END IF; --}
	  END IF; --}


	  Get_Detail_Lock(
                p_delivery_detail_id       => v_delivery_detail_id,
                p_ship_set_id              => v_ship_set_id,
                p_top_model_line_id        => v_top_model_line_id,
                p_enforce_ship_set_and_smc => p_enforce_ship_set_and_smc,
                -- Bug 4775539
                x_requested_qty_uom        => l_requested_qty_uom,
                x_src_requested_qty_uom    => l_src_requested_qty_uom,
                x_src_requested_qty        => l_src_requested_qty,
                x_inv_item_id              => l_inv_item_id,
                x_skip_detail              => x_skip_detail, -- Bug# 3248578
                x_return_status            => x_api_status);

	  IF (x_api_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		 IF l_debug_on THEN
			 WSH_DEBUG_SV.logmsg(l_module_name,  'GET_DETAIL_LOCK RETURNED WITH WARNING'  );
			 WSH_DEBUG_SV.pop(l_module_name);
		 END IF;
		 --
		 RETURN;
          -- Bug# 3248578 start of change
	  ELSIF (x_api_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) AND (x_skip_detail = 'Y') THEN
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'No longer eligible to Pick Release, ignoring the line');
                 END IF;
                 RETURN;
	  END IF;

          -- Bug# 3248578 end of change

-- HW BUG#:1941429 for cross_docking. We need to branch */
/* HW OPMCONV - Removed code forking

	  /* Moved Prior Reservation validation from WSHPGSLB.pls to here for SS/SMC	 */
	  l_result := v_requested_quantity;
	  l_requested_quantity := v_requested_quantity;
-- HW BUG#:1941429 cross_docking OPM
	  l_result2 := v_requested_quantity2;
	  l_requested_quantity2 := nvl(v_requested_quantity2,0);

--Bug8683087 now fetching demand_source_header_id for all the cases.
                IF v_header_id <> NVL(g_cache_header_id, -99) THEN
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name, 'Call API to get demand sales order number for '||v_header_id);
                   END IF;
                   IF NVL(v_demand_source_header_id,-1) = -1 THEN
                      v_demand_source_header_id := INV_SALESORDER.GET_SALESORDER_FOR_OEHEADER(v_header_id);
                   END IF;
                   g_cache_header_id := v_header_id;
            	     g_cache_demand_header_id := v_demand_source_header_id;
                ELSE
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name, 'use cached value '||g_cache_demand_header_id);
                   END IF;
                   v_demand_source_header_id := g_cache_demand_header_id;
                END IF;
--8683087
	   --Check for reservation status for prior reservation line.
	   -- Bug 4775539 Added g_honor_pick_from default is 'Y'
           IF ((g_existing_rsvs_only_flag = 'Y' or (g_honor_pick_from = 'Y' and g_from_subinventory is not null)) and (v_released_status <> 'X')) THEN
           --{
                -- Bug 4775539
                IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,  'CHECKING FOR RESERVATIONS'  );
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PICK_LIST.CALCULATE_RESERVATIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --Calculate Reservations
-- HW OPMCONV - Pass and return qty2
		WSH_PICK_LIST.Calculate_Reservations(
                  p_demand_source_header_id    => v_demand_source_header_id,
                  p_demand_source_line_id      => v_line_id,
                  p_requested_quantity         => v_requested_quantity,
                  -- Bug 4775539
                  p_requested_quantity_uom     => l_requested_qty_uom,
                  p_src_requested_quantity_uom => l_src_requested_qty_uom,
                  p_src_requested_quantity     => l_src_requested_qty,
                  p_inv_item_id                => l_inv_item_id,
  		  p_requested_quantity2        => v_requested_quantity2, /* Bug 7291415 Uncommented this line */
		  x_result                     => l_result,
		  x_result2                    => l_result2);

		IF (l_result = 0) THEN -- No Fulfillment
		  IF l_debug_on THEN
               -- Bug 4775539
                     IF g_existing_rsvs_only_flag = 'Y' THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,  'PRIOR RESERVATIONS IS SPECIFIED AND RESERVED QUANTITY IS 0'  );
                     ELSE
                          WSH_DEBUG_SV.logmsg(l_module_name,  'PICK FROM SUB IS HONORED AND AVAILABLE QUANTITY IS 0'  );
                     END IF;
              WSH_DEBUG_SV.logmsg(l_module_name,  'IGNORING THE LINE'  );
		  END IF;
		  --
		  Set_Globals(p_enforce_ship_set_and_smc, v_ship_set_id, v_top_model_line_id);

		  x_api_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                  -- bug 2164110 - log exception
                  l_message := null;
		  -- Bug 4775539
                  IF g_existing_rsvs_only_flag = 'Y' THEN
                    l_exception_name := 'WSH_PICK_PRIOR_RSV';
                  ELSE
                    l_exception_name := 'WSH_HONOR_PICK_FROM';
                  END IF;
                  FND_MESSAGE.SET_NAME('WSH',l_exception_name);
                  -- end Bug 4775539
                  FND_MESSAGE.SET_NAME('WSH','WSH_PICK_PRIOR_RSV');
                  l_message := FND_MESSAGE.GET;
                  l_request_id := fnd_global.conc_request_id;
                  IF ( l_request_id <> -1 OR WSH_PICK_LIST.G_BATCH_ID IS NOT NULL ) THEN
                     wsh_xc_util.log_exception(
                              p_api_version             => 1.0,
                              p_logging_entity          => 'SHIPPER',
                              p_logging_entity_id       => FND_GLOBAL.USER_ID,
                              -- Bug 4775539
                              p_exception_name          => l_exception_name,
                              p_message                 => l_message,
                              p_logged_at_location_id   => v_ship_from_location_id,
                              p_exception_location_id   => v_ship_from_location_id,
                              p_delivery_detail_id      => v_delivery_detail_id,
                              p_request_id              => l_request_id,
                              p_batch_id                => WSH_PICK_LIST.G_BATCH_ID,
                              x_return_status           => l_exception_return_status,
                              x_msg_count               => l_exception_msg_count,
                              x_msg_data                => l_exception_msg_data,
                              x_exception_id            => l_dummy_exception_id);
                     wsh_util_core.PrintMsg('Please view Shipping Exception Report for detail of the logged exception');
                  END IF;
                  -- end bug 2164110

		  IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
		  END IF;
		  RETURN;
		ELSIF (l_result = l_requested_quantity) THEN  -- Complete Fulfillment
		  NULL;
		ELSE -- (l_result < l_requested_quantity) Partial Fulfillment
		  IF ((v_ship_set_id > 0) OR (v_top_model_line_id > 0)) THEN
			IF l_debug_on THEN
				 IF l_debug_on THEN
                           IF g_existing_rsvs_only_flag = 'Y' THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,  'PRIOR RESERVATIONS IS SPECIFIED AND SS/SMC LINE IS PARTIALLY RESERVED'  );
                           ELSE
                                WSH_DEBUG_SV.logmsg(l_module_name,  'PICK FROM HONOR IS SPECIFIED AND SS/SMC LINE IS PARTIALLY RESERVED'  );
                           END IF;
                        END IF;
				WSH_DEBUG_SV.logmsg(l_module_name,  'IGNORING THE LINE'  );
			END IF;

			Set_Globals(p_enforce_ship_set_and_smc, v_ship_set_id, v_top_model_line_id);
			x_api_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                        -- bug 2164110 - log exception
                        l_message := null;
			-- Bug 4775539
                        IF g_existing_rsvs_only_flag = 'Y' THEN
                          l_exception_name := 'WSH_PICK_PRIOR_RSV';
                        ELSE
                          l_exception_name := 'WSH_HONOR_PICK_FROM';
                        END IF;
                        FND_MESSAGE.SET_NAME('WSH',l_exception_name);
                        -- end Bug 4775539
                        FND_MESSAGE.SET_NAME('WSH','WSH_PICK_PRIOR_RSV');
                        l_message := FND_MESSAGE.GET;
                        l_request_id := fnd_global.conc_request_id;
                        IF ( l_request_id <> -1 OR WSH_PICK_LIST.G_BATCH_ID IS NOT NULL ) THEN
                           wsh_xc_util.log_exception(
                              p_api_version             => 1.0,
                              p_logging_entity          => 'SHIPPER',
                              p_logging_entity_id       => FND_GLOBAL.USER_ID,
                              -- Bug 4775539
                              p_exception_name          => l_exception_name,
                              p_message                 => l_message,
                              p_logged_at_location_id   => v_ship_from_location_id,
                              p_exception_location_id   => v_ship_from_location_id,
                              p_delivery_detail_id      => v_delivery_detail_id,
                              p_request_id              => l_request_id,
                              p_batch_id                => WSH_PICK_LIST.G_BATCH_ID,
                              x_return_status           => l_exception_return_status,
                              x_msg_count               => l_exception_msg_count,
                              x_msg_data                => l_exception_msg_data,
                              x_exception_id            => l_dummy_exception_id);
                           wsh_util_core.PrintMsg('Please view Shipping Exception Report for detail of the logged exception');
                        END IF;
                        -- end bug 2164110

			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		  ELSE
			l_requested_quantity := l_requested_quantity - l_result;
-- HW OPMCONV - Added qty2
			l_requested_quantity2 := l_requested_quantity2 - l_result2;

			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.SPLIT_DELIVERY_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

-- HW OPMCONV - Added l_requested_quantity2 and re-arranged parameters

              WSH_DELIVERY_DETAILS_ACTIONS.Split_Delivery_Details(
              p_from_detail_id  => v_delivery_detail_id,
              p_req_quantity    => l_requested_quantity,
              x_new_detail_id   => l_new_delivery_detail_id,
              p_req_quantity2   => l_requested_quantity2,
              x_return_status   => l_split_status,
              p_unassign_flag   => 'N'
              );

			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,  'CREATED NEW DELIVERY DETAIL '||L_NEW_DELIVERY_DETAIL_ID  );
			END IF;
		  END IF;
		END IF;
                --}
	   END IF;

           --}
	  -- To check if there is a Non-Reservable Item present and set the
	  -- global flag to 'Y'. If the flag is already set, no need to reset
	  -- it again.
	  IF G_NONRESERVABLE_ITEM = 'N' AND v_reservable_type = 2 THEN
		 G_NONRESERVABLE_ITEM := 'Y';
	  END IF;

	  IF l_debug_on THEN
		  WSH_DEBUG_SV.logmsg(l_module_name,  'INSERT INTO TABLE'  );
	  END IF;

          --Store the detail line values to release table
	  release_table(g_rel_current_line).source_line_id := v_line_id;
	  release_table(g_rel_current_line).source_header_id := v_header_id;
	  release_table(g_rel_current_line).organization_id := v_org_id;
	  release_table(g_rel_current_line).inventory_item_id := v_inventory_item_id;
	  release_table(g_rel_current_line).move_order_line_id := v_move_order_line_id;
	  release_table(g_rel_current_line).delivery_detail_id := v_delivery_detail_id;

          release_table(g_rel_current_line).line_number := v_pr_mo_line_number;
          v_pr_mo_line_number := v_pr_mo_line_number + 1;

	  release_table(g_rel_current_line).ship_from_location_id := v_ship_from_location_id;
	  release_table(g_rel_current_line).ship_method_code := v_ship_method_code;
	  release_table(g_rel_current_line).shipment_priority := v_shipment_priority;
	  release_table(g_rel_current_line).date_scheduled := v_date_scheduled;
	  release_table(g_rel_current_line).requested_quantity := l_result;
	  release_table(g_rel_current_line).requested_quantity_uom := v_requested_quantity_uom;
	  release_table(g_rel_current_line).preferred_grade := v_preferred_grade;

          -- HW BUG#:1941429 OPM cross_docking
          -- Changed v_requested_quantiy2 to be l_result2
	  release_table(g_rel_current_line).requested_quantity2 := nvl(l_result2,0);
	  release_table(g_rel_current_line).requested_quantity_uom2 := v_requested_quantity_uom2;
	  release_table(g_rel_current_line).project_id := v_project_id;
	  release_table(g_rel_current_line).task_id := v_task_id;
	  release_table(g_rel_current_line).from_sub := v_from_sub;
	  release_table(g_rel_current_line).to_sub := v_to_sub;
	  release_table(g_rel_current_line).released_status := v_released_status;
	  release_table(g_rel_current_line).ship_set_id := v_ship_set_id;
	  release_table(g_rel_current_line).source_header_number := v_source_header_number;
          -- LSP PROJECT : Copy clientId information.
          release_table(g_rel_current_line).client_id := v_client_id;
	  -- Inventory wants only ship_set_id if SMC and SHIP SET are specified for a MODEL
	  IF ((release_table(g_rel_current_line).ship_set_id is NULL) AND
		  (v_top_model_line_id is NOT NULL)) THEN
		release_table(g_rel_current_line).top_model_line_id := v_top_model_line_id;

		IF (v_top_model_line_id <> NVL(g_last_top_model_line_id,-99)) THEN
		  OPEN  c_order_line(v_top_model_line_id);
		  FETCH c_order_line INTO l_ordered_quantity, l_order_quantity_uom;
		  CLOSE c_order_line;

		  IF l_debug_on THEN
		   WSH_DEBUG_SV.log(l_module_name,  'l_ordered_quantity',l_ordered_quantity);
		   WSH_DEBUG_SV.log(l_module_name,  'l_order_quantity_uom',l_order_quantity_uom);
		  END IF;

		  release_table(g_rel_current_line).top_model_quantity := l_ordered_quantity;
		  g_last_model_quantity := l_ordered_quantity;
		ELSE
		 release_table(g_rel_current_line).top_model_quantity := g_last_model_quantity;
		END IF;
	  ELSE
		release_table(g_rel_current_line).top_model_line_id  := NULL;
		release_table(g_rel_current_line).top_model_quantity := NULL;
	  END IF;
	  release_table(g_rel_current_line).source_code := v_source_code;
	  release_table(g_rel_current_line).planned_departure_date := v_planned_departure_date;
	  release_table(g_rel_current_line).delivery_id := v_delivery_id;
	  release_table(g_rel_current_line).unit_number := v_unit_number;
	  release_table(g_rel_current_line).source_doc_type := v_source_doc_type;
	  --Bug8683087 now passing demand_source_header_id in all the cases.
    release_table(g_rel_current_line).demand_source_header_id := v_demand_source_header_id;


          -- anxsharm, X-dock
	  release_table(g_rel_current_line).customer_id := v_customer_id;
          -- anxsharm, end of X-dock
          -- Standalone project Changes start
	  release_table(g_rel_current_line).revision   := v_revision;
	  release_table(g_rel_current_line).from_locator := v_from_locator;
	  release_table(g_rel_current_line).lot_number := v_lot_number;
      -- Standalone project Changes end
          IF v_reservable_type = 2 THEN  -- ECO 5220234
            release_table(g_rel_current_line).non_reservable_flag := 'Y';
          END IF;

	  IF (p_enforce_ship_set_and_smc = 'Y') THEN
		g_last_ship_set_id	   := v_ship_set_id;
		g_last_top_model_line_id := v_top_model_line_id;
		g_last_header_id		 := v_header_id;
		g_last_source_code	   := v_source_code;
	  END IF;

	  x_api_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
	  WHEN OTHERS THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,  'UNEXPECTED ERROR IN INSERT_RL_ROW'  );
		END IF;
		x_api_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		END IF;

END Insert_RL_Row;


-- Start of comments
-- API name : Process_Buffer
-- Type     : Private
-- Pre-reqs : None.
-- Procedure: API to processes a line of text, by first writing to the
--            log file and then concatenating it to the required SQL buffer.
-- Parameters :
-- IN:
--      p_print_flag      IN  Indicates whether to print to log.
--      p_buffer_name     IN  Identifies which buffer to append to.
--                            'u' -> Unreleased_SQL
--                            'b' -> Backordered_SQL
--                            'c' -> cond_SQL
--      p_buffer_text     IN  Identifies the text to process.
--      p_bind_value      IN  Identifies the value for the bind variable refere in p_buffer_text.
-- OUT:
--      None
-- End of comments
PROCEDURE Process_Buffer(
	  p_print_flag		IN   VARCHAR2,
	  p_buffer_name	   IN   VARCHAR2,
	  p_buffer_text	   IN   VARCHAR2,
	  p_bind_value	   IN   VARCHAR2 default NULL
   ) IS
   --
   l_debug_on BOOLEAN;
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_BUFFER';
   --
BEGIN
	  --
	  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	  --
	  IF l_debug_on IS NULL THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	  END IF;
	  --
	  IF p_buffer_name = 'u' THEN
		 g_Unreleased_SQL := g_Unreleased_SQL || p_buffer_text;
	  ELSIF p_buffer_name = 'b' THEN
		 g_Backordered_SQL := g_Backordered_SQL || p_buffer_text;
	  ELSIF p_buffer_name = 'c' THEN
		 g_cond_SQL := g_cond_SQL || p_buffer_text;
	  ELSIF p_buffer_name = 'o' THEN
		 g_orderby_SQL := g_orderby_SQL || p_buffer_text;
	  ELSE
		RETURN;
	  END IF;

END Process_Buffer;

END WSH_PR_CRITERIA;

/
