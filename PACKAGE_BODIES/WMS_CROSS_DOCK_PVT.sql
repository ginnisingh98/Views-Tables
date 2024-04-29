--------------------------------------------------------
--  DDL for Package Body WMS_CROSS_DOCK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CROSS_DOCK_PVT" AS
/* $Header: WMSCRDKB.pls 120.19.12010000.7 2009/09/05 00:52:12 bvanjaku ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WMS_Cross_Dock_Pvt';


PROCEDURE mydebug(msg in varchar2)
  IS
     l_msg VARCHAR2(5100);
     l_ts VARCHAR2(30);
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   select to_char(sysdate,'MM/DD/YYYY HH:MM:SS') INTO l_ts from dual;
   l_msg:=l_ts||'  '||msg;


   inv_mobile_helper_functions.tracelog
     (p_err_msg => l_msg,
      p_module => 'wms_cross_dock_pvt',
      p_level => 4);
--   dbms_output.put_line(msg);
   --INSERT INTO amintemp1 VALUES (msg);
   null;
END mydebug ;


--
-- Checkcrossdock logic will first cal rules engine to derive crossdock criteria,
-- and stamp the crossdock criteria to move order line. It wil call pegging API to
-- peg the move order to a set of demands. For outbound shipment demand without a
-- delivery, the demand will be merged into existing delivery or a new delivery
-- will be created. For shipment demand, destination sub/loc will be determined based
-- on delivery based consolidation. Destination sub/loc will be stamped on to move
-- order line so that rules engine will honor that for generating putaway tasks.
--
-- This API will handle both opportunistic crossdock and planned crossdock
-- gxiao 4/18/05
-- {{********************** check_crossdock ************************************}}
--

-- original procedure name is 'crossdock'. add new procedure 'check_crossdock'
-- TODO: how to handle the dual maintainance: break it or add version

   PROCEDURE crossdock
   (p_org_id          IN   NUMBER               ,
    p_lpn             IN   NUMBER               ,
    x_ret             OUT  NOCOPY NUMBER        ,
    x_return_status   OUT  NOCOPY VARCHAR2      ,
    x_msg_count       OUT  NOCOPY NUMBER        ,
    x_msg_data        OUT  NOCOPY VARCHAR2      ,
    p_move_order_line_id IN NUMBER DEFAULT NULL
    ) IS

       l_api_name           CONSTANT VARCHAR2(30) := 'check_crossdock';
       l_progress           VARCHAR2(10);
       l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

       l_org_id NUMBER;
       l_lpn_id NUMBER;
       l_line_id NUMBER;
       l_backorder_delivery_detail_id NUMBER;
       l_wip_supply_type NUMBER;
       l_wip_entity_id   NUMBER;
       l_operation_sequence_number NUMBER;
       l_repetitive_schedule_id    NUMBER;

       l_reference VARCHAR2(240);
       l_reference_id NUMBER;
       l_location_id NUMBER;
       l_ship_to_location_id NUMBER;

       l_xdock_flag NUMBER;
       l_default_xdock_criteria_id NUMBER;
       l_default_xdock_sub VARCHAR2(10);
       l_default_xdock_loc_id NUMBER;
       l_default_ship_staging_sub VARCHAR2(10);
       l_default_ship_staging_loc_id NUMBER;



       l_to_sub_code VARCHAR2(10);
       l_to_loc_id NUMBER;
       l_to_zone_id NUMBER;

       l_xdock_type NUMBER;

       l_inventory_item_id NUMBER;
       l_project_id NUMBER;
       l_task_id  NUMBER;
       l_uom_code VARCHAR2(3);
       l_item_type VARCHAR2(30);
       l_uom_class VARCHAR2(10);
       l_user_id NUMBER;
       l_vendor_id NUMBER;

       l_xdock_criterion_id NUMBER;
       l_xdock_criteria    wms_crossdock_criteria%ROWTYPE;
       l_dock_appointment_id NUMBER;
       l_dock_start_time DATE;
       l_dock_end_time DATE;
       l_expected_delivery_time DATE;
       l_dummy1 DATE;
       l_dummy2 DATE;
       l_dummy3 DATE;
       l_source_type_id NUMBER;
       l_source_header_id NUMBER;
       l_source_line_id NUMBER;

       l_matched_delivery_id           NUMBER;
       l_matched_dock_appointment_id   NUMBER;
       l_matched_dock_start_time       DATE;
       l_matched_dock_end_time         DATE;
       l_matched_expected_del_time    DATE;


       -- Crossdock Criteria time interval values
       -- INTERVAL DAY TO SECOND type stores the number of days and seconds
       l_xdock_window_interval    INTERVAL DAY TO SECOND;
       l_buffer_interval          INTERVAL DAY TO SECOND;
       l_processing_interval      INTERVAL DAY TO SECOND;

       l_return_type VARCHAR2(10);
       l_sequence_number NUMBER;

       --l_sequence_number 	wms_selection_criteria_txn.sequence_number%type;
       --l_return_type_code	wms_selection_criteria_txn.return_type_code%type;
       --l_return_type_id		wms_selection_criteria_txn.return_type_id%type;
       l_index NUMBER;
       l_cache BOOLEAN;

       l_attr_tab               wsh_integration.grp_attr_tab_type;
       l_action_rec             wsh_integration.action_rec_type;
       l_target_rec             wsh_integration.grp_attr_rec_type;
       l_matched_entities       wsh_util_core.id_tab_type;
       l_out_rec                wsh_integration.out_rec_type;
       l_group_info             wsh_integration.grp_attr_tab_type;

       l_action_prms            wsh_glbl_var_strct_grp.dd_action_parameters_rec_type;
       l_action_out_rec         wsh_glbl_var_strct_grp.dd_action_out_rec_type;
       l_defaults_rec           wsh_glbl_var_strct_grp.dd_default_parameters_rec_type;
--       l_detail_id_tab          wsh_util_core.id_tab_type;
       l_rec_attr_tab           WSH_GLBL_VAR_STRCT_GRP.delivery_details_attr_tbl_type;

       l_delivery_id            NUMBER;

       TYPE num_tb IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
       l_mol_criteria_tb num_tb;
       l_txn_src_type_id NUMBER;

       l_return_status  VARCHAR2(1);
       l_msg_count      NUMBER;
       l_msg_data       VARCHAR2(240);
       l_message        VARCHAR2(240);
       --e_return_excp EXCEPTION;

       -- create cursor matching the condition:
       -- 1. the MTRL is within the LPN
       -- 2. the MTRL has not been pegged to demand by planned crossdocking
       -- 3. there has not been any MMTT generated for this MTRL
       -- 4. this MTRL does not require inspection or has been accepted }}
       CURSOR c_mol_opportunistic IS
	  SELECT mtrl.line_id,
	    mtrl.inventory_item_id,
	    msi.item_type,
	    mtrl.project_id,
	    mtrl.task_id,
	    mtrl.uom_code,
	    muom.uom_class,
	    mtrl.last_update_login,
	    mtrl.reference,
	    mtrl.reference_id,
	    mtrl.transaction_source_type_id
	    FROM mtl_txn_request_lines mtrl,
	    mtl_system_items msi,
	    mtl_units_of_measure muom
	    WHERE mtrl.lpn_id  = l_lpn_id   -- the MTRL is within the LPN
	    AND (mtrl.line_id = p_move_order_line_id OR p_move_order_line_id IS NULL)
	      AND mtrl.backorder_delivery_detail_id IS NULL  -- this LPN has not crossdocked yet
		AND (mtrl.quantity_detailed = 0 OR mtrl.quantity_detailed IS NULL) -- no MMTT is created for this LPN
		  AND (inspection_status = 2 OR inspection_status IS NULL)
		    AND wms_process_flag = 1
		    AND msi.inventory_item_id = mtrl.inventory_item_id
		    AND msi.organization_id = mtrl.organization_id
		    AND mtrl.uom_code = muom.uom_code;

      -- MRTL which has been pegged to demand by either planned or opportunistic crossdocking
      CURSOR c_mol_opp_and_planned IS
	 SELECT line_id,
	   inventory_item_id,
	   backorder_delivery_detail_id,
	   crossdock_type,
	   to_subinventory_code,
	   to_locator_id,
	   wip_supply_type,
	   wip_entity_id,
	   operation_seq_num,
	   repetitive_schedule_id,
	   transaction_source_type_id
	   FROM
	   mtl_txn_request_lines mtrl
	   WHERE mtrl.lpn_id  = l_lpn_id   -- the MTRL is within the LPN
	   AND mtrl.line_id = NVL(p_move_order_line_id, mtrl.line_id)
	   AND mtrl.backorder_delivery_detail_id IS NOT NULL  -- also including lines planned crossdocked
	     AND (mtrl.quantity_detailed = 0 OR mtrl.quantity_detailed IS NULL) -- no MMTT is created for this LPN
	       AND NVL(inspection_status, 2) = 2
	       AND wms_process_flag = 1

         --BUG 5194761: If case of Item Load, p_move_order_line will be passed
         --and we need to pick up the MOL that may be split by the crossdock API.
         --So make use of the mtrl.reference_detail_id
         UNION
	 SELECT line_id,
	   inventory_item_id,
	   backorder_delivery_detail_id,
	   crossdock_type,
	   to_subinventory_code,
	   to_locator_id,
	   wip_supply_type,
	   wip_entity_id,
	   operation_seq_num,
	   repetitive_schedule_id,
	   transaction_source_type_id
	   FROM
	   mtl_txn_request_lines mtrl
	   WHERE mtrl.lpn_id  = l_lpn_id   -- the MTRL is within the LPN
	   AND p_move_order_line_id IS NOT NULL
           AND mtrl.reference_detail_id = p_move_order_line_id
	   AND mtrl.backorder_delivery_detail_id IS NOT NULL  -- also including lines planned crossdocked
	     AND (mtrl.quantity_detailed = 0 OR mtrl.quantity_detailed IS NULL) -- no MMTT is created for this LPN
	       AND NVL(inspection_status, 2) = 2
	       AND wms_process_flag = 1;



BEGIN

   IF (l_debug = 1) THEN
      mydebug('***Calling check_crossdock API with the following parameters***');
      mydebug('p_org_id: ==================> ' || p_org_id);
      mydebug('p_lpn: =====================> ' || p_lpn);
      mydebug('p_move_order_line_id: ======> ' || p_move_order_line_id);
   END IF;

   -- Set the savepoint
   SAVEPOINT check_crossdock_sp;
   l_progress := '10';

   -- Initialize message list to clear any existing messages
   --   fnd_msg_pub.initialize;
   l_progress := '20';

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   x_ret := 1;
   l_progress := '30';

   l_lpn_id := p_lpn;
   l_org_id := p_org_id;

   -- get org level crossdock related info
   -- 1. opportunistic crossdock enabled flag
   -- 2. default crossdock criteria
   -- 3. default mfg staging sub/loc
   BEGIN
      SELECT Nvl(mp.crossdock_flag, 2),
	mp.default_crossdock_criteria_id,
	mp.default_crossdock_subinventory, -- default wip crossdocking sub
	mp.default_crossdock_locator_id, -- default wip crossdocking loc
	wsp.default_stage_subinventory,
	wsp.default_stage_locator_id
	INTO l_xdock_flag,
	l_default_xdock_criteria_id,
	l_default_xdock_sub, -- default wip crossdocking sub
	l_default_xdock_loc_id,-- default wip crossdocking loc
	l_default_ship_staging_sub,
	l_default_ship_staging_loc_id
	FROM mtl_parameters mp, wsh_shipping_parameters wsp
	WHERE mp.organization_id = wsp.organization_id (+)
	AND mp.organization_id = l_org_id;
   EXCEPTION
      WHEN OTHERS THEN
	 IF (l_debug = 1) THEN
	    mydebug('Exit from check_crossdock, failed to get org level data. ' );
	 END IF;

	 RETURN;
   END;

   IF (l_debug = 1) THEN
      mydebug('l_xdock_flag = '||l_xdock_flag );
      mydebug('l_default_xdock_criteria_id = '||l_default_xdock_criteria_id );
      mydebug('l_default_xdock_sub = '||l_default_xdock_sub );
      mydebug('l_default_xdock_loc_id	 = '||l_default_xdock_loc_id );
      mydebug('l_default_ship_staging_sub	 = '||l_default_ship_staging_sub );

      mydebug('l_default_ship_staging_loc_id	 = '||l_default_ship_staging_loc_id );

   END IF;

   l_progress := '50';

   -- If opportunistic crossdock enabled, then
   -- loop through MTRL records that match the following condition:
   -- 1. the MTRL is within the LPN
   -- 2. the MTRL has not been pegged to demand by planned crossdocking
   -- 3. there has not been any MMTT generated for this MTRL
   -- 4. this MTRL does not require inspection or has been accepted

   IF l_xdock_flag = 1 THEN

      --{{
      -- When org level opportunistics crossdock is enabled should crossdock the received
      -- move order line to demand.
      --
      -- When org level opportunistics crossdock is NOT enabled don't do crossdock,
      -- however for lines that have been pegged, should merge/create delivery
      -- and suggest staging lane based on delivery.
      --}}

      IF (l_debug = 1) THEN
	 mydebug('Opportunistics crossdock enabled. ' );
      END IF;

      BEGIN
	 SELECT location_id
	   INTO l_location_id
	   FROM rcv_supply
	   WHERE lpn_id = p_lpn
	   AND ROWNUM<2;
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       mydebug('Failed to get location_id from rcv_supply. ' );
	    END IF;

      END;

      IF (l_debug = 1) THEN
	 mydebug('l_location_id = '|| l_location_id);
      END IF;

      OPEN c_mol_opportunistic;
      --  enter MTRL loop including only opportunistic
      LOOP
	 FETCH c_mol_opportunistic INTO
	   l_line_id,
	   l_inventory_item_id,
	   l_item_type,
	   l_project_id,
	   l_task_id,
	   l_uom_code,
	   l_uom_class,
	   l_user_id,
	   l_reference,
	   l_reference_id,
	   l_txn_src_type_id;


	 EXIT WHEN c_mol_opportunistic%notfound;

	 IF (l_debug = 1) THEN
	    mydebug('l_line_id = '||l_line_id );
	    mydebug('l_inventory_item_id = '|| l_inventory_item_id);
	    mydebug('l_item_type = '|| l_item_type);
	    mydebug('l_project_id = '|| l_project_id);
	    mydebug('l_task_id = '|| l_task_id);
	    mydebug('l_uom_code = '|| l_uom_code);
	    mydebug('l_uom_class = '|| l_uom_class);
	    mydebug('l_user_id = '|| l_user_id);
	    mydebug('l_reference = '|| l_reference);
	    mydebug('l_reference_id = '|| l_reference_id);
	    mydebug('l_txn_src_type_id = '|| l_txn_src_type_id);
	 END IF;

	 l_progress := '60';


	 -- {{ call wms_rules_workbench_pvt.get_unit_of_measure }}
	 -- {{ call wms_rules_workbench_pvt.get_vendor_id }}
	 IF (l_debug = 1) THEN
	    mydebug('***Calling wms_rules_workbench_pvt.get_vendor_id***');
	 END IF;

	 l_vendor_id := wms_rules_workbench_pvt.get_vendor_id(l_reference, l_reference_id);

	 l_progress := '100';



	 -- TODO: check with ANIL on the parameters
	 -- {{ call wms_rules_workbench_pvt.cross_dock_search to get crossdock_criteria_id }}
	 IF (l_debug = 1) THEN
	    mydebug('***Calling wms_rules_workbench_pvt.cross_dock_search with the following parameters***');
	    mydebug('p_rule_type_code: ==========>  10');
	    mydebug('p_organization_id: =========> ' || p_org_id);
	    mydebug('p_customer_id: =============> ' || NULL);
	    mydebug('p_inventory_item_id: =======> ' || l_inventory_item_id);
	    mydebug('p_item_type: ===============> ' || l_item_type);
	    mydebug('p_vendor_id: ===============> ' || l_vendor_id);
	    mydebug('p_location_id: =============> ' || l_location_id);
	    mydebug('p_project_id: ==============> ' || l_project_id);
	    mydebug('p_task_id: =================> ' || l_task_id);
	    mydebug('p_user_id: =================> ' || l_user_id);
	    mydebug('p_uom_code: ================> ' || l_uom_code);
	    mydebug('p_uom_class: ===============> ' || l_uom_class);
	    mydebug('p_date_type: ===============> ' || NULL);
	    mydebug('p_from_date: ===============> ' || NULL);
	    mydebug('p_to_date: =================> ' || NULL);
	    mydebug('p_criterion_type: ==========> 1');
	 END IF;

	 wms_rules_workbench_pvt.cross_dock_search(
	   p_rule_type_code      => 10,                   -- supply_initiated_crossdock
	   p_organization_id	 => l_org_id,
	   p_customer_id	 => NULL,                 -- opportunistic crossdock
	   p_inventory_item_id	 => l_inventory_item_id,
--	   p_category_id	 => l_category_id,
	   p_item_type		 => l_item_type,
	   p_vendor_id		 => l_vendor_id,
	   p_location_id	 => l_location_id,
	   p_project_id		 => l_project_id,
	   p_task_id		 => l_task_id,
	   p_user_id		 => l_user_id,
	   p_uom_code		 => l_uom_code,
	   p_uom_class		 => l_uom_class,
--	   p_date_type		 => NULL,
--	   p_from_date		 => NULL,
--	   p_to_date		 => NULL,
--	   p_criterion_type	 => 1,                    --Opportunistic (1) or Planned (2)
	   x_return_type	 => l_return_type,
	   x_return_type_id	 => l_xdock_criterion_id,     --criterion_id
	   x_sequence_number	 => l_sequence_number,
	   x_return_status       => l_return_status
	   );

	 -- Bug 4576491
	 IF l_xdock_criterion_id IS NULL THEN
	    l_xdock_criterion_id := l_default_xdock_criteria_id;
	 END IF;

	 IF (l_debug = 1) THEN
	    mydebug('***After calling wms_rules_workbench_pvt.cross_dock_search ***');
	    mydebug('l_return_type = '||l_return_type);
	    mydebug('l_xdock_criterion_id = '||l_xdock_criterion_id);
	    mydebug('l_sequence_number = '||l_sequence_number);
	    mydebug('l_return_status = '||l_return_status);
	 END IF;

	 IF (l_txn_src_type_id = 5) THEN --WIP
	    l_mol_criteria_tb(l_line_id) := l_xdock_criterion_id;
	 END IF;

	 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    FND_MESSAGE.SET_NAME('WMS','WMS_XDOK_SEARCH_ERROR' );
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.g_exc_unexpected_error;

	  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    FND_MESSAGE.SET_NAME('WMS','WMS_XDOK_SEARCH_ERROR');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.g_exc_error;
	 END IF;

	 l_progress := '110';

	 -- {{ call wms_xdock_pegging_pub.opportunistic_cross_dock API, performing opportunistic
	 -- crossdock pegging to fulfill a move order line supply that has been received.
	 -- this API will find a set of demands that thas MTRL record can satisfy according to
	 -- crossdock criteria. The splitting of WDD lines, creation and splitting of reservations,
	 -- splitting and updating of MOL will all be done in the API. }}

	 IF (l_debug = 1) THEN
	    mydebug('***Calling wms_xdock_pegging_pub.opportunistic_cross_dock with the following parameters***');
	    mydebug('p_organization_id: =========> ' || l_org_id);
	    mydebug('p_move_order_line_id:=======> ' || l_line_id);
	    mydebug('p_crossdock_criterion_id: ==> ' || l_xdock_criterion_id);
	 END IF;

	 -- Bug 4576491
	 IF l_xdock_criterion_id IS NOT NULL THEN
	    -- Bug# 4662186
	    -- Cache crossdock criteria data first before calling the pegging API
	    IF (l_debug = 1) THEN
	       mydebug('***Calling wms_xdock_pegging_pub.set_crossdock_criteria***');
	    END IF;
	    l_cache := wms_xdock_pegging_pub.set_crossdock_criteria(l_xdock_criterion_id);

	    wms_xdock_pegging_pub.Opportunistic_Cross_Dock
	      (p_organization_id            => l_org_id,
	       p_move_order_line_id         => l_line_id,
	       p_crossdock_criterion_id     => l_xdock_criterion_id,
	       x_return_status              => l_return_status,
	       x_msg_count                  => l_msg_count,
	       x_msg_data                   => l_msg_data);

	    IF (l_debug = 1) THEN
	       mydebug('***After calling wms_xdock_pegging_pub.Opportunistic_Cross_Dock ***');
	       mydebug('l_return_status = '||l_return_status);
	       mydebug('l_msg_count = '||l_msg_count);
	       mydebug('l_msg_data = '||l_msg_data);
	    END IF;

	    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       FND_MESSAGE.SET_NAME('WMS','WMS_OPP_XDOK_ERROR' );
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.g_exc_unexpected_error;

	     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	       FND_MESSAGE.SET_NAME('WMS','WMS_OPP_XDOK_ERROR');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.g_exc_error;
	    END IF;

	    l_progress := '120';

	 END IF; -- l_xdock_criterion_id is not null

	 -- {{ end MTRL loop }}
      END LOOP;

      CLOSE c_mol_opportunistic;

      -- Bug# 4662186
      -- Clear the crossdock criteria cache when pegging has completed
      IF (l_debug = 1) THEN
	 mydebug('***Calling wms_xdock_pegging_pub.clear_crossdock_cache***');
      END IF;
      l_cache := wms_xdock_pegging_pub.clear_crossdock_cache;

      l_progress := '130';
   END IF;

   -- Now start creating and merging delivery, and determine staging lane.
   -- Open another MTRL cursor loop for those lines that get crossdocked (including
   -- new MTRL created by the split). This new cursor takes into consideration of planned
   -- crossdock.

   OPEN c_mol_opp_and_planned;

   --  enter MTRL loop including both opportunistic and planned crossdock
   LOOP
	 FETCH c_mol_opp_and_planned INTO
	   l_line_id,
	   l_inventory_item_id,
	   l_backorder_delivery_detail_id,
	   l_xdock_type,
	   l_to_sub_code,
	   l_to_loc_id,
	   l_wip_supply_type,
	   l_wip_entity_id,
	   l_operation_sequence_number,
	   l_repetitive_schedule_id,
	   l_txn_src_type_id;

	 EXIT WHEN c_mol_opp_and_planned%NOTFOUND;

	 -- at least one line is crossdocked for this LPN
	 x_ret := 0;

	 -- {{ merge/create delivery only applicable for sales order or internal
	 -- order demand. }}

	 IF (l_xdock_type = 2) THEN
	    --{{
	    -- When crossdock to WIP work order, get staging locator based on following logic
	    -- 1. First try to get staging sub/loc from the job
	    -- 2. If can't find from job for a pull job, get from wip parameter
	    --}}
	    BEGIN
	       -- first get the sub and loc from wip_requirement_operations_v

	       SELECT nvl(nvl(supply_subinventory, mp.default_crossdock_subinventory), wp.default_pull_supply_subinv),
		 nvl(nvl(supply_locator_id, mp.default_crossdock_locator_id), wp.default_pull_supply_locator_id)
		 INTO l_to_sub_code,
		 l_to_loc_id
		 FROM wip_requirement_operations wro,
		 mtl_txn_request_lines mtrl,
		 mtl_parameters mp,
		 wip_parameters wp
		 WHERE wro.organization_id = l_org_id
		 AND mp.organization_id = l_org_id
		 AND wp.organization_id = l_org_id
		 AND mtrl.line_id = l_line_id
		 AND wro.inventory_item_id = mtrl.inventory_item_id
		 AND wro.wip_entity_id  = mtrl.wip_entity_id
		 AND nvl(wro.operation_seq_num, -1)  = Nvl(mtrl.operation_seq_num, nvl(wro.operation_seq_num, -1))
		 AND nvl(wro.repetitive_schedule_id, -1)  = Nvl(mtrl.repetitive_schedule_id, nvl(wro.repetitive_schedule_id, -1));

	    EXCEPTION
	       WHEN NO_DATA_FOUND THEN
		  NULL;
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     mydebug('Unexpected error, skip this move order line.');
		  END IF;

		  GOTO loop_end;
	    END;

	    -- if for pull job and if sub and loc is NULL, use wip_parameters
	    -- 9/30/05: Also do this for WIP push
	    IF (l_to_sub_code IS NULL OR l_to_loc_id IS NULL) THEN

	       BEGIN
		  SELECT default_pull_supply_subinv,
		    default_pull_supply_locator_id
		    INTO l_to_sub_code,
		    l_to_loc_id
		    FROM wip_parameters
		    WHERE organization_id = l_org_id;

	       EXCEPTION
		  WHEN NO_DATA_FOUND THEN
		     NULL;
		  WHEN OTHERS THEN
		     IF (l_debug = 1) THEN
			mydebug('Unexpected error, skip this move order line.');
		     END IF;

		     GOTO loop_end;
	       END;

	    END IF;


	  ELSE
             BEGIN
		SELECT delivery_id
		  INTO l_delivery_id
		  FROM wsh_delivery_assignments_v
		  WHERE delivery_detail_id = l_backorder_delivery_detail_id;
	     EXCEPTION
		WHEN OTHERS THEN
		   NULL;
	     END;

	     IF (l_debug = 1) THEN
		mydebug('l_delivery_id = '|| l_delivery_id);
	     END IF;

	     IF(l_delivery_id IS NULL) THEN

		  -- sales order crossdock
		IF (l_debug = 1) THEN
		   mydebug('Delivery detail is not yet assigned to delivery.');
		END IF;

		l_progress := '140';
		IF (l_txn_src_type_id = 5) THEN
		   l_xdock_criterion_id := l_mol_criteria_tb(l_line_id);
		   IF (l_debug = 1) THEN
		      mydebug('WIP MOL.  Xdock_criterial_id stored is: '||l_xdock_criterion_id);
		   END IF;

		   IF (l_xdock_criterion_id IS NOT NULL) THEN
		      IF (l_debug = 1) THEN
			 mydebug('Retrieving the l_expected_delivery_time');
		      END IF;

		      BEGIN
			 SELECT 2
			   , inv_salesorder.get_salesorder_for_oeheader(wdd.source_header_id)
			   , wdd.source_line_id
			   INTO l_source_type_id, l_source_header_id, l_source_line_id
			   FROM wsh_delivery_details wdd
			   WHERE wdd.delivery_detail_id = l_backorder_delivery_detail_id;
		      EXCEPTION
			 WHEN OTHERS THEN
			    IF (l_debug = 1) THEN
			       mydebug('Error retrieving SO info! Skip this mol!');
			       GOTO loop_end;
			    END IF;
		      END;

		      IF (l_debug = 1) THEN
			 mydebug('Calling wms_xdock_pegging_pub.get_expected_time');
			 mydebug(' p_source_type_id     => '|| l_source_type_id);
			 mydebug(' p_source_header_id   => '||l_source_header_id);
			 mydebug(' p_source_line_id     => '||l_source_line_id);
			 mydebug(' p_source_line_detail_=> '||l_backorder_delivery_detail_id);
			 mydebug(' p_supply_or_demand   => '||2);
			 mydebug(' p_crossdock_criterion=> '||l_xdock_criterion_id);
		      END IF;

		      wms_xdock_pegging_pub.get_expected_time
			( p_source_type_id          => l_source_type_id
			  ,p_source_header_id       => l_source_header_id
			  ,p_source_line_id         => l_source_line_id
			  ,p_source_line_detail_id  => l_backorder_delivery_detail_id
			  ,p_supply_or_demand       => 2
			  ,p_crossdock_criterion_id => l_xdock_criterion_id
			  ,x_return_status          => l_return_status
			  ,x_msg_count              => l_msg_count
			  ,x_msg_data               => l_msg_data
			  ,x_dock_start_time        => l_dummy1
			  ,x_dock_mean_time         => l_dummy2
			  ,x_dock_end_time          => l_dummy3
			  ,x_expected_time          => l_expected_delivery_time);

		      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			 IF (l_debug = 1) THEN
			    mydebug('Unexpected error, skip this move order line.');
			 END IF;

			 GOTO loop_end;
		       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			 IF (l_debug = 1) THEN
			    mydebug('Expected error, skip this move order line.');
			 END IF;

			 GOTO loop_end;
		      END IF;

		      IF (l_debug = 1) THEN
			 mydebug('After calling get_expected_time. l_expected_delivery_time = '||l_expected_delivery_time);
		      END IF;
		   END IF;--IF (l_xdock_criterion_id IS NOT NULL) THEN

		 ELSE
		  -- query crossdock criteria BT, OPT and crossdocking wondow
		  BEGIN
		     SELECT crossdock_criteria_id,
		       demand_ship_date
		       INTO l_xdock_criterion_id,
		       l_expected_delivery_time
		       FROM mtl_reservations
		       WHERE demand_source_line_detail = l_backorder_delivery_detail_id
		       AND supply_source_type_id  = inv_reservation_global.g_source_type_rcv
		       AND organization_id = l_org_id
		       AND inventory_item_id = l_inventory_item_id;
		  EXCEPTION
		     WHEN OTHERS THEN
			IF (l_debug = 1) THEN
			   mydebug('Unexpected error, skip this move order line.');
			END IF;

			GOTO loop_end;
		  END;
		END IF;

		l_progress := '150';
		  IF (l_debug = 1) THEN
		     mydebug(' l_xdock_criterion_id = '||l_xdock_criterion_id);
		  END IF;

		--For WIP, this maybe NULL. In this case, skip all logic
		--AND simply create the delivery
		IF (l_xdock_criterion_id IS NOT NULL) THEN

		  -- {{ get BT, OPT, and crossdocking_window from cached values }}
		  l_xdock_criteria := wms_xdock_pegging_pub.get_crossdock_criteria(l_xdock_criterion_id);

		  IF (l_debug = 1) THEN
		     mydebug('Crossdock Window: ' ||
			     l_xdock_criteria.window_interval || ' ' ||
			     l_xdock_criteria.window_uom);
		     mydebug('Buffer Time: ' ||
			     l_xdock_criteria.buffer_interval || ' ' ||
			     l_xdock_criteria.buffer_uom);
		     mydebug('Order Processing Time: ' ||
			     l_xdock_criteria.processing_interval || ' ' ||
			     l_xdock_criteria.processing_uom);
		  END IF;

		  l_progress := '160';

		  -- crossdock window intertal
		  l_xdock_window_interval := NUMTODSINTERVAL
		    (l_xdock_criteria.window_interval,
		     l_xdock_criteria.window_uom);

		  -- Buffer Time Interval
		  -- The buffer time interval and UOM should either both be NULL or not NULL.
		  l_buffer_interval := NUMTODSINTERVAL
		    (NVL(l_xdock_criteria.buffer_interval, 0),
		     NVL(l_xdock_criteria.buffer_uom, 'HOUR'));

		  -- Order Processing Time Interval
		  -- The order processing time interval and UOM should either both be NULL or not NULL.
		  l_processing_interval := NUMTODSINTERVAL
		    (NVL(l_xdock_criteria.processing_interval, 0),
		     NVL(l_xdock_criteria.processing_uom, 'HOUR'));

		  IF (l_debug = 1) THEN
		     mydebug('Crossdock Window interval: ' || l_xdock_window_interval);
		     mydebug('Buffer Time interval: ' || l_buffer_interval);
		     mydebug('Order Processing Time interval: ' || l_processing_interval);
		  END IF;


		  -- {{ Merge/create delivery if there is no delivery for the WDD --
		  -- only available for sales order or internal order demand }}

		  l_progress := '170';

		  -- {{ get possible matching deliveries }}

		  l_attr_tab(1).entity_id := l_backorder_delivery_detail_id;
		  l_attr_tab(1).entity_type := 'DELIVERY_DETAIL';
		  l_target_rec.entity_type := 'DELIVERY';
		  l_action_rec.action := 'MATCH_GROUPS';
		  l_action_rec.caller := 'WMS_CHECK_CROSSDOCK';
		  l_action_rec.output_format_type := 'ID_TAB';

		  l_progress := '190';

		  -- {{ call wsh_delivery_autocreate.find_matching_groups}}

		  IF (l_debug = 1) THEN
		     mydebug('***Calling wsh_integration.find_matching_groups***');
		     mydebug('l_attr_tab(1).entity_id = ' ||l_backorder_delivery_detail_id);
		     mydebug('l_attr_tab(1).entity_type = ' ||l_attr_tab(1).entity_type);
		     mydebug('l_target_rec.entity_type = ' ||l_target_rec.entity_type);
		     mydebug('l_action_rec.action = ' ||l_action_rec.action);
		     mydebug('l_action_rec.caller = ' ||l_action_rec.caller);
		     mydebug('l_action_rec.output_format_type = ' ||l_action_rec.output_format_type);
		  END IF;

		  wsh_integration.find_matching_groups
		    (p_attr_tab               => l_attr_tab,
		     p_action_rec             => l_action_rec,
		     p_target_rec             => l_target_rec,
		     p_group_tab              => l_group_info,
		     x_matched_entities       => l_matched_entities,
		     x_out_rec                => l_out_rec,
		     x_return_status          => l_return_status);

		  IF (l_debug = 1) THEN
		     mydebug('***After calling wsh_delivery_autocreate.find_matching_groups***');
		     mydebug('x_return_status = '||l_return_status);
		     mydebug('l_matched_entities.count = '||l_matched_entities.count);
		  END IF;


		  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		     IF (l_debug = 1) THEN
			mydebug('Unexpected error, skip this move order line.');
		     END IF;

		     GOTO loop_end;
		   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		     IF (l_debug = 1) THEN
			mydebug('Expected error, skip this move order line.');
		     END IF;

		     GOTO loop_end;
		  END IF;

		  l_progress := '200';

		  -- {{ loop those deliveries returned by WSH API
		  -- check whether the delivery satisfies the crossdocking window and related
		  -- time constraints) based on crossdock criteria;
		  FOR l_index IN 1..l_matched_entities.COUNT LOOP
		     -- {{ call wms_xdock_pegging_pub.get_expected_delivery_time}}

		     IF (l_debug = 1) THEN
			mydebug('***Calling wms_xdock_pegging_pub.get_expected_delivery_time***');
			mydebug('p_delivery_id = '||l_matched_entities(l_index));
			mydebug('p_crossdock_criterion_id = '||l_xdock_criterion_id);
		     END IF;

		     wms_xdock_pegging_pub.get_expected_delivery_time
		       (p_delivery_id                => l_matched_entities(l_index),
			p_crossdock_criterion_id     => l_xdock_criterion_id,
			x_return_status              => l_return_status,
			x_msg_count                  => l_msg_count,
			x_msg_data                   => l_msg_data,
			x_dock_appointment_id        => l_matched_dock_appointment_id,
			x_dock_start_time            => l_matched_dock_start_time,
			x_dock_end_time              => l_matched_dock_end_time,
			x_expected_time              => l_matched_expected_del_time);

		     IF (l_debug = 1) THEN
			mydebug('***After calling wms_xdock_pegging_pub.get_expected_delivery_time***');
			mydebug('x_dock_appointment_id = '||l_matched_dock_appointment_id);
			mydebug('x_dock_start_time = '||l_matched_dock_start_time);
			mydebug('x_dock_end_time = '||l_matched_dock_end_time);
			mydebug('x_expected_time = '||l_matched_expected_del_time);
		     END IF;

		     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			IF (l_debug = 1) THEN
			   mydebug('Unexpected error, skip this Delivery.');
			END IF;

			GOTO delivery_loop_end;
		      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			IF (l_debug = 1) THEN
			   mydebug('Expected error, skip this Delivery.');
			END IF;

			GOTO delivery_loop_end;
		     END IF;

		     l_progress := '210';

		     -- {{ check whether this delivery found satisfies the crossdocking window based on
		     -- crossdock criteria;

		     --the delivery will be eligible for merging if expected shipment
		     -- date derived from delivery level fall into the crossdocking window.
		     IF l_matched_expected_del_time IS NOT NULL THEN

			IF ( l_matched_expected_del_time - l_buffer_interval- l_processing_interval
			     < SYSDATE + l_xdock_window_interval AND
			     l_matched_expected_del_time - l_buffer_interval- l_processing_interval > SYSDATE)
			  THEN

			   IF (l_debug = 1) THEN
			      mydebug('Found matching delivery '|| l_matched_entities(l_index) || ' with expected ship time : '||l_matched_expected_del_time);
			   END IF;

			   l_matched_delivery_id := l_matched_entities(l_index);
			   EXIT;
			END IF;

		      ELSE
			-- {{ if expected shipment date cannot be derived from delivery, the delivery will
			-- be eligible for merging if the current WDD's expected shipment date falls between
			-- the range of expected shipment dates of all WDDsfor this delivery. }}

			IF (l_expected_delivery_time < l_matched_dock_end_time)
			  AND
			  (l_expected_delivery_time > l_matched_dock_start_time)
			  THEN
			   IF (l_debug = 1) THEN
			      mydebug('Found matching delivery '||l_matched_entities(l_index) || ' with dock appointment: '||l_matched_dock_start_time||' '||l_matched_dock_end_time);
			   END IF;
			   l_matched_delivery_id := l_matched_entities(l_index);
			   EXIT;
			END IF;

		     END IF;
		    <<delivery_loop_end>>
		    NULL;

		  END LOOP;
		 ELSE --(l_xdock_criterion_id IS NULL) THEN
		   l_matched_delivery_id := NULL;
		END IF;--IF (l_xdock_criterion_id IS NOT NULL) THEN

		l_progress := '220';

		  l_action_prms.caller := 'WMS_CHECK_CROSSDOCK';
		  l_rec_attr_tab(1).delivery_detail_id := l_backorder_delivery_detail_id;

		  -- {{ if there is a matching delivery, merge WDD to this matching delivery }}
		  IF (l_matched_delivery_id IS NOT NULL) THEN
		     l_action_prms.action_code := 'ASSIGN';
--		     l_detail_id_tab(1) := l_backorder_delivery_detail_id;
		     l_action_prms.delivery_id := l_matched_delivery_id;
		   ELSE
		     -- {{ if there is no matching delivery call, create a new record in wsh_new_deliveries }}
		     l_action_prms.action_code := 'AUTOCREATE-DEL';
		  END IF;
		  l_progress := '230';


		  -- {{ call wsh_delivery_autocreate.delivery_detail_action }}

		  IF (l_debug = 1) THEN
		     mydebug('***Calling wsh_delivery_details_grp.delivery_detail_action***');
		     mydebug('l_rec_attr_tab(1).delivery_detail_id  = '||l_rec_attr_tab(1).delivery_detail_id );
		     mydebug('l_action_prms.action_code = '||l_action_prms.action_code);
		     mydebug('l_action_prms.delivery_id = '||l_action_prms.delivery_id);
		  END IF;

		  wsh_delivery_details_grp.delivery_detail_action
		    (
		     -- Standard Parameters
		     p_api_version_number        => 1.0,
		     p_init_msg_list             => fnd_api.g_false,
		     p_commit                    => fnd_api.g_false,
		     x_return_status             => l_return_status,
		     x_msg_count                 => l_msg_count,
		     x_msg_data                  => l_msg_data,
		     -- Procedure specific Parameters
		     p_rec_attr_tab              => l_rec_attr_tab,
		     p_action_prms               => l_action_prms,
		     x_defaults                  => l_defaults_rec,
		     x_action_out_rec            => l_action_out_rec
		     );

		  IF (l_debug = 1) THEN
		     mydebug('***After calling wsh_delivery_details_grp.delivery_detail_action***');
		     mydebug('x_return_status  = '||l_return_status);
		     mydebug('x_msg_count  = '||l_msg_count);
		     mydebug('x_msg_data  = '||l_msg_data);
		  END IF;



		  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		     IF (l_debug = 1) THEN
			mydebug('Unexpected error, skip this move order line.');
		     END IF;

		     GOTO loop_end;
		   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		     IF (l_debug = 1) THEN
			mydebug('Expected error, skip this move order line.');
		     END IF;

		     GOTO loop_end;
		  END IF;

		  l_progress := '240';

	     END IF; -- end l_delivery_id is null

	     -- {{ determine staging lane and stamp MTRL }}

	     -- {{ call wms_op_dest_sys_apis.get_staging_loc_for_delivery }}
	     IF (l_debug = 1) THEN
		mydebug('***Calling wms_op_dest_sys_apis.get_staging_loc_for_delivery with the following parameters***');
		mydebug('p_call_mode: ===============> ' || 1);
		mydebug('p_task_type: ===============> ' || 1);
		mydebug('p_task_id: =================> ' || NULL);
		mydebug('p_locator_id: ==============> ' || NULL);
		mydebug('p_mol_id: ==================> ' || l_line_id);
	     END IF;

	     wms_op_dest_sys_apis.get_staging_loc_for_delivery
	       (
		x_return_status          => l_return_status,
		x_message                => l_message,
		x_locator_id             => l_to_loc_id,
		x_zone_id                => l_to_zone_id,
		x_subinventory_code      => l_to_sub_code,
		p_call_mode              => 1,
		p_task_type              => 1,
		p_task_id                => NULL,
		p_locator_id             => NULL,
		p_mol_id                 => l_line_id
		);

	     IF (l_debug = 1) THEN
		mydebug('***After calling wms_op_dest_sys_apis.get_staging_loc_for_delivery with the following parameters***');
		mydebug('x_return_status = ' || l_return_status);
		mydebug('x_message = ' || l_message);
		mydebug('x_locator_id = ' || l_to_loc_id);
		mydebug('x_zone_id = ' || l_to_zone_id);
		mydebug('x_subinventory_code = ' || l_to_sub_code);
	     END IF;

	     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		IF (l_debug = 1) THEN
		   mydebug('Unexpected error, skip this move order line.');
		END IF;

		GOTO loop_end;
	      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		IF (l_debug = 1) THEN
		   mydebug('Expected error, skip this move order line.');
		END IF;

		GOTO loop_end;
	     END IF;


	     l_progress := '250';

	 END IF; -- end sales order or WIP crossdock IF

	 IF (l_xdock_type = 2) THEN

	    UPDATE mtl_txn_request_lines
	      SET to_subinventory_code = l_to_sub_code,
	      to_locator_id = l_to_loc_id
	      WHERE line_id = l_line_id;

	  ELSE

	    UPDATE mtl_txn_request_lines
	      SET to_subinventory_code = Nvl(l_to_sub_code, l_default_ship_staging_sub),
	      to_locator_id = Nvl(l_to_loc_id, l_default_ship_staging_loc_id)
	      WHERE line_id = l_line_id;


	 END IF;

	 l_progress := '260';

	 -- {{ end MTRL loop }}

	 <<loop_end>>
	   NULL; -- this is necessary for the goto label
   END LOOP;

   CLOSE c_mol_opp_and_planned;

   l_progress := '270';

   IF (l_debug = 1) THEN
      mydebug('***End of check_crossdock***');
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      IF (c_mol_opportunistic%ISOPEN) THEN
	 CLOSE c_mol_opportunistic;
      END IF;

      IF (c_mol_opp_and_planned%ISOPEN) THEN
	 CLOSE c_mol_opp_and_planned;
      END IF;

      ROLLBACK TO check_crossdock_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 mydebug('Exiting check_crossdock - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

      IF SQLCODE IS NOT NULL THEN
	 IF (l_debug = 1) THEN
   	    mydebug(' With SQL error: ' || SQLERRM(SQLCODE));
	 END IF;

      END IF;

      -- TODO: check cursor close
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF (c_mol_opportunistic%ISOPEN) THEN
	 CLOSE c_mol_opportunistic;
      END IF;

      IF (c_mol_opp_and_planned%ISOPEN) THEN
	 CLOSE c_mol_opp_and_planned;
      END IF;

      ROLLBACK TO check_crossdock_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 mydebug('Exiting Opportunistic_Cross_Dock - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

      IF SQLCODE IS NOT NULL THEN
	 IF (l_debug = 1) THEN
   	    mydebug(' With SQL error: ' || SQLERRM(SQLCODE));
	 END IF;

      END IF;

   WHEN OTHERS THEN
      IF (c_mol_opportunistic%ISOPEN) THEN
	 CLOSE c_mol_opportunistic;
      END IF;

      IF (c_mol_opp_and_planned%ISOPEN) THEN
	 CLOSE c_mol_opp_and_planned;
      END IF;

      ROLLBACK TO check_crossdock_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 mydebug('Exiting Opportunistic_Cross_Dock - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

      IF SQLCODE IS NOT NULL THEN
	 IF (l_debug = 1) THEN
   	    mydebug(' With SQL error: ' || SQLERRM(SQLCODE));
	 END IF;

      END IF;

END crossdock;


PROCEDURE complete_crossdock
  (    p_org_id               IN    NUMBER
       ,p_temp_id             IN    NUMBER
       ,  x_return_status     OUT   NOCOPY VARCHAR2
       ,  x_msg_count         OUT   NOCOPY NUMBER
       ,  x_msg_data          OUT   NOCOPY VARCHAR2
       )

  IS

     /*
       ,p_del_id NUMBER
       ,p_mo_line_id NUMBER
       , p_item_id NUMBER
	 ,x_return_status     OUT VARCHAR2
	 */
     l_cnt_lpn_id NUMBER;
     l_msg_cnt NUMBER;
    -- l_msg_data VARCHAR2(240);
     l_org_id NUMBER;
     l_item_id NUMBER;
     l_ret NUMBER;
     l_temp_id NUMBER;
     l_del_id NUMBER;
     l_mo_line_id NUMBER;
     l_demand_source_type		NUMBER;
     l_mso_header_id			NUMBER;	-- The MTL_SALES_ORDERS
     --header ID, which should be derived from the OE header ID
     -- and used for reservation queries.

     l_shipping_attr              WSH_INTERFACE.ChangedAttributeTabType;

     l_update_rsv_rec			INV_Reservation_GLOBAL.MTL_RESERVATION_REC_TYPE;
     l_demand_info			wsh_inv_delivery_details_v%ROWTYPE;
     l_prim_qty NUMBER;
     l_primary_temp_qty NUMBER;
     l_prim_uom VARCHAR2(3);
     l_sub VARCHAR2(10);
     l_loc NUMBER;
     l_return_status VARCHAR2(1);
     l_api_return_status		VARCHAR2(1);
     l_org_wide_res_id			NUMBER ;
     l_qty_succ_reserved NUMBER;
     l_msg_data VARCHAR2(2400);
     l_msg_count NUMBER;

     l_dummy_sn			INV_Reservation_Global.Serial_Number_Tbl_Type;

     l_source_header_id           NUMBER;
     l_source_line_id             NUMBER;
     l_rev varchar2(3);
     l_lot VARCHAR2(30);
     l_lot_count NUMBER;
     l_lot_control_code NUMBER;
     l_serial_control_code NUMBER;
     l_serial_trx_id NUMBER;
     l_transaction_type_id NUMBER;
     l_action_flag VARCHAR2(1);
     l_serial_temp_id NUMBER;
     l_transfer_lpn_id NUMBER;
     l_serial_number VARCHAR2(30);
     l_transaction_source_type_id NUMBER;
     l_txn_supply_source_id NUMBER;
     l_query_rsv_rec   	INV_Reservation_GLOBAL.MTL_RESERVATION_REC_TYPE;
     l_reservation_tbl  inv_reservation_global.mtl_reservation_tbl_type;
     l_rsv_tbl_count NUMBER;
     l_error_code NUMBER;

     l_order_source_id NUMBER;

     l_label_status VARCHAR2(2000);

     l_lpn_del_detail_id NUMBER;
     l_crossdock_type NUMBER;

     -- Release 12 (K): LPN Synchronization/Convergence
     -- Types needed for WSH_WMS_LPN_GRP.Delivery_Detail_Action
     l_curr_lpn_id        NUMBER;
     l_lpn_rec            WMS_Data_Type_Definitions_PUB.LPNRecordType;
     l_wsh_lpn_id_tbl     WSH_Util_Core.id_tab_type;
     l_wsh_del_det_id_tbl WSH_Util_Core.id_tab_type;
     l_wsh_action_prms    WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
     l_wsh_defaults       WSH_GLBL_VAR_STRCT_GRP.dd_default_parameters_rec_type;
     l_wsh_action_out_rec WSH_GLBL_VAR_STRCT_GRP.dd_action_out_rec_type;

     -- Patchset J change
     CURSOR msn_serial_csr (l_lpn_id NUMBER) IS
	SELECT serial_number
	  FROM mtl_serial_numbers
	  WHERE lpn_id = l_lpn_id;

     cursor serial_csr IS
	SELECT fm_serial_number
	  FROM  mtl_serial_numbers_temp
	  WHERE transaction_temp_id=l_serial_temp_id ;

  CURSOR parent_lpn_cur ( p_innermost_lpn_id NUMBER ) IS
    SELECT lpn_id, license_plate_number, parent_lpn_id, organization_id, subinventory_code, locator_id,
           tare_weight, tare_weight_uom_code, gross_weight, gross_weight_uom_code,
           container_volume, container_volume_uom, content_volume, content_volume_uom_code
    FROM   wms_license_plate_numbers
    START WITH lpn_id = p_innermost_lpn_id
    CONNECT BY lpn_id = PRIOR parent_lpn_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   l_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- patchset J change to set the local variable with the patch level

   IF (l_debug = 1) THEN
      mydebug('in Complete cdock');
   END IF;
   l_org_id:=p_org_id;
   l_temp_id:=p_temp_id;
   l_ret:=0;
  -- l_del_id:=p_del_id;
  -- l_mo_line_id:=p_mo_line_id;
   --l_item_id:=p_item_id;

   l_return_status:=fnd_api.g_ret_sts_success;
   IF (l_debug = 1) THEN
      mydebug('Check if crossdock is necessary..');
   END IF;

   BEGIN
      SELECT
	l.line_id, l.backorder_delivery_detail_id,l.inventory_item_id,Nvl(crossdock_type,1)
	,l.transaction_source_type_id,l.txn_source_id
	INTO l_mo_line_id,l_del_id,l_item_id,l_crossdock_type,l_transaction_source_type_id,l_txn_supply_source_id
	FROM mtl_txn_request_lines l, mtl_material_transactions_temp t, wsh_delivery_details_ob_grp_v wdd
	WHERE t.transaction_temp_id=l_temp_id
	AND  l.backorder_delivery_detail_id = wdd.delivery_detail_id
	AND t.move_order_line_id=l.line_id
	AND exists (
		    select 1 from oe_order_lines_all oel
		    where oel.line_id = wdd.source_line_id
		    and nvl(oel.project_id,-9999) = nvl(l.project_id,-9999)
		    and nvl(oel.task_id,-9999) = nvl(l.task_id,-9999)
		    );

   EXCEPTION
      WHEN no_data_found THEN

	    SELECT
	      l.line_id, l.backorder_delivery_detail_id,l.inventory_item_id,Nvl(crossdock_type,1)
	      ,l.transaction_source_type_id,l.txn_source_id
	      INTO l_mo_line_id,l_del_id,l_item_id,l_crossdock_type,l_transaction_source_type_id,l_txn_supply_source_id
	      FROM mtl_txn_request_lines l, mtl_material_transactions_temp t
	      WHERE t.transaction_temp_id=l_temp_id
	      AND t.move_order_line_id=l.line_id;

   END;

   IF (l_debug = 1) THEN
      mydebug('Transaction source type id is : '||l_transaction_source_type_id);
   END IF;

    IF l_del_id IS NULL THEN
       IF (l_debug = 1) THEN
          mydebug('No Crossdocking necessary');
       END IF;
       x_return_status:=l_return_status;
       x_msg_data:='No Crossdocking necessary';

     ELSE
       IF (l_debug = 1) THEN
          mydebug('Cross Docked!');
       END IF;
       IF l_crossdock_type=2 THEN
	  IF (l_debug = 1) THEN
   	  mydebug('Cross Docked FOR WIP2!');
	  END IF;
	  wms_wip_xdock_pvt.wip_complete_crossdock
	    (    p_org_id   =>l_org_id
		 ,  p_temp_id =>l_temp_id
		 , p_wip_id=>l_del_id
		 , p_inventory_item_id=>l_item_id
		 ,  x_return_status=>l_return_status
		 ,  x_msg_count =>l_msg_cnt
		 ,  x_msg_data =>l_msg_data
		 );
	  IF (l_debug = 1) THEN
   	  mydebug('After WIP Complete crossdock API');
	  END IF;
	  x_return_status:=l_return_status;
	  x_msg_data :=l_msg_data;
	  RETURN;
       END if;
       IF (l_debug = 1) THEN
          mydebug('Cross Docked FOR SO!');
          mydebug('Get relevant info');
       END IF;

       --Get info from MMTT
       SELECT  t.primary_quantity,t.inventory_item_id,t.subinventory_code,
	 t.locator_id,t.revision,t.transaction_type_id,t.transfer_lpn_id,
	 t.content_lpn_id,i.primary_uom_code,i.lot_control_code,
	 i.serial_number_control_code
	 INTO  l_prim_qty ,l_item_id,l_sub,
	 l_loc,l_rev,l_transaction_type_id,
	 l_transfer_lpn_id,l_cnt_lpn_id,l_prim_uom
	 ,l_lot_control_code, l_serial_control_code
	 FROM mtl_material_transactions_temp t,
	 mtl_system_items i
	 WHERE t.transaction_temp_id=l_temp_id
	 AND t.organization_id=l_org_id
	 AND t.organization_id =i.organization_id
	 AND t.inventory_item_id=i.inventory_item_id;
--	 AND wlpn.lpn_id = t.lpn_id;  BUG 4666710

       IF l_transfer_lpn_id IS NULL THEN
	  l_transfer_lpn_id:=l_cnt_lpn_id;
       END IF;
       IF (l_debug = 1) THEN
          mydebug ('lpn id'||l_transfer_lpn_id);
       END IF;
       IF l_lot_control_code>1 THEN

	  -- Get lot info. Will always be only one lot
	  SELECT lot_number,serial_transaction_temp_id INTO l_lot,
	    l_serial_temp_id
	    FROM  mtl_transaction_lots_temp
	    WHERE transaction_temp_id in (select TRANSACTION_TEMP_ID from mtl_material_transactions_temp where PARENT_LINE_ID=l_temp_id)
	    and rownum=1;  -- Modified for Bug#8489892

         mydebug('l_serial_temp_id is '||l_serial_temp_id);
	ELSE
	  l_lot:=NULL;

       END IF;

        IF (l_debug = 1) THEN
 	           mydebug ('l_lot_control_code = '||l_lot_control_code);
 	           mydebug ('l_lot = '||l_lot);
 	END IF;


       -- {{
       --  Remove reservation related calls from complete_crossdock if source is receiving
       --  but creation/transfer of reservation should still happen correctly.
       -- }}

       --IF(l_lpn_context <> 3 )THEN
       IF (l_transaction_source_type_id = inv_reservation_global.g_source_type_wip) THEN
	 IF (l_debug = 1) THEN
	    mydebug('Create Rsv');
	 END IF;

	 -- Create Reservation
	 SELECT * INTO l_demand_info
	   from wsh_inv_delivery_details_v
	   WHERE delivery_detail_id=l_del_id;


	 -- Compute the MTL_SALES_ORDERS header ID to use when dealing with reservations.
	 l_mso_header_id :=  INV_SALESORDER.GET_SALESORDER_FOR_OEHEADER(l_demand_info.oe_header_id);

	 IF (l_debug = 1) THEN
	    mydebug('HdrID:'||l_mso_header_id);
	 END IF;
	 IF l_mso_header_id IS NULL THEN
	    FND_MESSAGE.SET_NAME('INV','INV_COULD_NOT_GET_MSO_HEADER');
	    FND_MSG_PUB.Add;
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
	 IF (l_debug = 1) THEN
	    mydebug('Get Dem src');
	 END IF;
	 -- get damand source type
	 select Nvl(order_source_id,1)
	   into   l_order_source_id
	   from oe_order_lines_all
	   where line_id = l_demand_info.oe_line_id;

	 IF (l_debug = 1) THEN
	    mydebug('dem src'||l_demand_source_type);
	    mydebug('Qty'||l_prim_qty);
	    mydebug('UOM'||l_prim_uom);
	 END IF;

	  IF (l_debug = 1) THEN
 	     mydebug ('lot control code '||l_lot_control_code);
 	     mydebug ('l_lot '||l_lot);
 	   END IF;

	 -- See if reservation already exists. If a reservation already exists
	 -- for a given supply source id then transfer reservation else create
	 -- reservation
	 l_query_rsv_rec.organization_id	:= l_org_id;
	 l_query_rsv_rec.inventory_item_id := l_item_id;
	 IF (l_transaction_source_type_id = inv_reservation_global.g_source_type_wip) THEN
	    -- LPN coming from WIP
	    l_query_rsv_rec.supply_source_header_id := l_txn_supply_source_id;
	    l_query_rsv_rec.supply_source_type_id := inv_reservation_global.g_source_type_wip;
	  ELSE -- LPN coming from Receiving

	    -- Bug# 3281512 - Performance Fixes
	    -- Take the decode out of the query and just use an IF condition
	    -- to decide if we should go against transaction_id or interface_transaction_id
	    -- in the rcv_transactions_table depending on if we are on
	    -- patchset J or higher.

	    BEGIN
	       SELECT Nvl(po_header_id, -1)
		 INTO l_query_rsv_rec.supply_source_header_id
		 FROM rcv_transactions
		 -- patchset j changes
		 WHERE transaction_id = l_txn_supply_source_id;
	    EXCEPTION
	       WHEN OTHERS THEN
		  l_query_rsv_rec.supply_source_header_id := -1;
	    END;

	    l_query_rsv_rec.supply_source_type_id := inv_reservation_global.g_source_type_po;
	 END IF;
	 l_query_rsv_rec.demand_source_header_id := l_mso_header_id;
	 l_query_rsv_rec.demand_source_line_id := l_demand_info.oe_line_id;

	 -- Call query reservation
	 inv_reservation_pub.query_reservation
	   (p_api_version_number    => 1.0,
	    p_init_msg_lst          => fnd_api.g_false,
	    x_return_status         => l_return_status,
	    x_msg_count             => l_msg_count,
	    x_msg_data              => l_msg_data,
	    p_query_input           => l_query_rsv_rec,
	    p_lock_records          => fnd_api.g_true,
	    p_sort_by_req_date      => inv_reservation_global.g_query_req_date_asc,
	    x_mtl_reservation_tbl   => l_reservation_tbl,
	    x_mtl_reservation_tbl_count => l_rsv_tbl_count,
	    x_error_code            => l_error_code);

	 IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    x_msg_count := l_msg_count;
	    x_msg_data := l_msg_data;
	    x_return_status := l_return_status;
	    IF (l_debug = 1) THEN
	       mydebug('Error in Query Reservation');
	    END IF;
	    FND_MESSAGE.SET_NAME('INV','INV_QRY_RSV_FAILED');
	    FND_MSG_PUB.Add;
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;


	 IF (l_rsv_tbl_count > 0) THEN
	    l_primary_temp_qty := l_prim_qty;

	    FOR i IN 1 .. l_rsv_tbl_count LOOP
	       l_update_rsv_rec := l_reservation_tbl(i);
	       l_update_rsv_rec.demand_source_delivery	:= NULL;
	       l_update_rsv_rec.primary_uom_code             := l_prim_uom;
	       l_update_rsv_rec.primary_uom_id               := NULL;
	       l_update_rsv_rec.reservation_uom_code         := NULL;
	       l_update_rsv_rec.reservation_uom_id           := NULL;
	       l_update_rsv_rec.reservation_quantity         := NULL;

	       IF (l_primary_temp_qty >
		   l_reservation_tbl(i).primary_reservation_quantity) THEN
		  l_update_rsv_rec.primary_reservation_quantity :=
		    l_reservation_tbl(i).primary_reservation_quantity;
		  l_primary_temp_qty := l_primary_temp_qty -
		    l_reservation_tbl(i).primary_reservation_quantity;
		ELSE
		  l_update_rsv_rec.primary_reservation_quantity :=
		    l_primary_temp_qty;
		l_primary_temp_qty := 0;
	       END IF;

	       l_update_rsv_rec.supply_source_type_id := INV_Reservation_GLOBAL.g_source_type_inv;
	       l_update_rsv_rec.supply_source_header_id      := NULL;
	       l_update_rsv_rec.supply_source_line_id        := NULL;
	       l_update_rsv_rec.supply_source_name           := NULL;
	       l_update_rsv_rec.supply_source_line_detail    := NULL;

	       l_update_rsv_rec.subinventory_code            := l_sub;
	       l_update_rsv_rec.subinventory_id              := NULL;
	       l_update_rsv_rec.locator_id                   := l_loc;

	     IF l_lot_control_code>1 THEN
 	       l_update_rsv_rec.lot_number := l_lot; -- Bug 7712653
 	     END IF;
	       -- Bug# 2771182
	       -- Pass the LPN ID into the reservation record when transferring reservation
	       l_update_rsv_rec.lpn_id                       := l_transfer_lpn_id;

	       inv_reservation_pub.transfer_reservation
		 (p_api_version_number     => 1.0,
		  p_init_msg_lst           => fnd_api.g_false,
		  x_return_status          => l_return_status,
		  x_msg_count              => l_msg_count,
		  x_msg_data               => l_msg_data,
		  p_is_transfer_supply     => fnd_api.g_true,
		  p_original_rsv_rec       => l_reservation_tbl(i),
		  p_to_rsv_rec             => l_update_rsv_rec,
		  p_original_serial_number => l_dummy_sn,
		  p_to_serial_number       => l_dummy_sn,
		  p_validation_flag        => fnd_api.g_true,
		  x_to_reservation_id      => l_org_wide_res_id);

	       -- Return an error if the transfer reservation call failed
	       IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
		  IF (l_debug = 1) THEN
		     mydebug('error in transfer reservation');
		  END IF;
		  FND_MESSAGE.SET_NAME('INV','INV_TRANSFER_RSV_FAILED');
		  FND_MSG_PUB.Add;
		RAISE fnd_api.g_exc_unexpected_error;
	       END IF;

	       IF (l_primary_temp_qty <= 0) THEN
		  exit;
	       END IF;
	    END LOOP;

	  ELSE
	  --	l_demand_source_type:=2;
	    l_update_rsv_rec.reservation_id 		:= NULL; -- cannot know
	    l_update_rsv_rec.requirement_date 		:= Sysdate;
	    l_update_rsv_rec.organization_id 		:= l_org_id;
	    l_update_rsv_rec.inventory_item_id 		:= l_item_id;

	    If l_order_source_id = 10 then
	       l_update_rsv_rec.demand_source_type_id     :=
		 INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_INTERNAL_ORD; -- Internal Order
	     ELSE
	       l_update_rsv_rec.demand_source_type_id   :=
		 INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_OE; -- Order Entry
	    end if;
	    -- bug 2808892
	    --l_update_rsv_rec.demand_source_type_id 	:= inv_globals.G_SourceType_SalesOrder;
	    --INV_Reservation_Global.g_source_type_oe; -- order entry
	    l_update_rsv_rec.demand_source_name 		:= NULL;
	    l_update_rsv_rec.demand_source_header_id 	:= l_mso_header_id;
	    l_update_rsv_rec.demand_source_line_id 	:= l_demand_info.oe_line_id;
	    l_update_rsv_rec.demand_source_delivery	:= NULL;
	    l_update_rsv_rec.primary_uom_code             := l_prim_uom;
	    l_update_rsv_rec.primary_uom_id               := NULL;
	    l_update_rsv_rec.reservation_uom_code         := NULL;
	    l_update_rsv_rec.reservation_uom_id           := NULL;
	    l_update_rsv_rec.reservation_quantity         := NULL;
	    l_update_rsv_rec.primary_reservation_quantity := l_prim_qty;
	    l_update_rsv_rec.autodetail_group_id          := NULL;
	    l_update_rsv_rec.external_source_code         := NULL;
	    l_update_rsv_rec.external_source_line_id      := NULL;
	    l_update_rsv_rec.supply_source_type_id 	:=
	      INV_Reservation_GLOBAL.g_source_type_inv;
	    l_update_rsv_rec.supply_source_header_id      := NULL;
	    l_update_rsv_rec.supply_source_line_id        := NULL;
	    l_update_rsv_rec.supply_source_name           := NULL;
	    l_update_rsv_rec.supply_source_line_detail    := NULL;

	    l_update_rsv_rec.revision                     := l_rev;
	    l_update_rsv_rec.subinventory_code            := l_sub;
	    l_update_rsv_rec.subinventory_id              := NULL;
	    l_update_rsv_rec.locator_id                   := l_loc;
	    l_update_rsv_rec.lot_number                   := l_lot;
	    l_update_rsv_rec.lot_number_id                := NULL;
	    l_update_rsv_rec.pick_slip_number             := NULL;
	    -- Bug# 2771182
	    -- Pass the LPN ID into the reservation record when creating reservation
	    l_update_rsv_rec.lpn_id                       := l_transfer_lpn_id;
	    l_update_rsv_rec.attribute_category           := NULL;
	    l_update_rsv_rec.attribute1                   := NULL;
	    l_update_rsv_rec.attribute2                   := NULL;
	    l_update_rsv_rec.attribute3                   := NULL;
	    l_update_rsv_rec.attribute4                   := NULL;
	    l_update_rsv_rec.attribute5                   := NULL;
	    l_update_rsv_rec.attribute6                   := NULL;
	    l_update_rsv_rec.attribute7                   := NULL;
	    l_update_rsv_rec.attribute8                   := NULL;
	    l_update_rsv_rec.attribute9                   := NULL;
	    l_update_rsv_rec.attribute10                  := NULL;
	    l_update_rsv_rec.attribute11                  := NULL;
	    l_update_rsv_rec.attribute12                  := NULL;
	    l_update_rsv_rec.attribute13                  := NULL;
	    l_update_rsv_rec.attribute14                  := NULL;
	    l_update_rsv_rec.attribute15                  := NULL;
	    l_update_rsv_rec.ship_ready_flag 		:= NULL;
	    l_update_rsv_rec.detailed_quantity 		:= 0;

	    IF (l_debug = 1) THEN
	       mydebug('create new reservation');
	    END IF;
	    inv_quantity_tree_pvt.clear_quantity_cache ;
	    INV_Reservation_PUB.Create_Reservation
	      (
	       p_api_version_number        => 1.0
	       , p_init_msg_lst              => fnd_api.g_false
	       , x_return_status             => l_api_return_status
	       , x_msg_count                 => l_msg_cnt
	       , x_msg_data                  => l_msg_data
	       , p_rsv_rec                   => l_update_rsv_rec
	       , p_serial_number             => l_dummy_sn
	       , x_serial_number             => l_dummy_sn
	       , p_partial_reservation_flag  => fnd_api.g_true
	       , p_force_reservation_flag    => fnd_api.g_false
	       , p_validation_flag           => fnd_api.g_true
	       , x_quantity_reserved         => l_qty_succ_reserved
	       , x_reservation_id            => l_org_wide_res_id
	       );



	    fnd_msg_pub.count_and_get
	      (  p_count  => l_msg_cnt
		 , p_data   => l_msg_data
		 );

	    IF (l_msg_cnt = 0) THEN
	       IF (l_debug = 1) THEN
		  mydebug('Successful');
	       END IF;
	     ELSIF (l_msg_cnt = 1) THEN
	       IF (l_debug = 1) THEN
		  mydebug('Not Successful');
		mydebug(replace(l_msg_data,chr(0),' '));
	       END IF;
	     ELSE
	       IF (l_debug = 1) THEN
		  mydebug('Not Successful2');
	       END IF;
	       For I in 1..l_msg_cnt LOOP
		  l_msg_data := fnd_msg_pub.get(I,'F');
		  IF (l_debug = 1) THEN
		     mydebug(replace(l_msg_data,chr(0),' '));
		  END IF;
	       END LOOP;
	    END IF;


	    -- Return an error if the create reservation call failed
	    IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
	       IF (l_debug = 1) THEN
		  mydebug('error in create reservation');
	       END IF;
	       --  ROLLBACK TO Process_Line_PVT;
	       FND_MESSAGE.SET_NAME('WMS','WMS_TD_CR_RSV_ERROR');
	       FND_MSG_PUB.Add;
	       RAISE fnd_api.g_exc_unexpected_error;
	    END IF;
	 END IF;


	 -- Fix for Bug 2344419
	 -- Changes made to the shipping process as part of the change
	 -- management project require that the reservation be marked as
	 -- staged. Am calling an API to update the reservation thusly..

	 IF (l_debug = 1) THEN
	    mydebug('Upd Reservation as having been staged');
	    mydebug('Rsv Id:'||l_org_wide_res_id);
	    mydebug('Calling API to update rsv as staged...');
	 END IF;
	 inv_staged_reservation_util.update_staged_flag
	   ( x_return_status  =>l_return_status,
	     x_msg_count =>l_msg_cnt,
	     x_msg_data  =>l_msg_data,
	     p_reservation_id  =>l_org_wide_res_id,
	     p_staged_flag =>'Y');

       END IF; -- l_lpn_context


       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  FND_MESSAGE.SET_NAME('WMS','WMS_TD_UPD_RSV_ERROR' );
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.g_exc_unexpected_error;

	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  FND_MESSAGE.SET_NAME('WMS','WMS_TD_UPD_RSV_ERROR');
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (l_debug = 1) THEN
          mydebug('After calling API to update rsv as staged');
       END IF;

       IF (l_debug = 1) THEN
          mydebug('Upd shipping');
       END IF;

       -- UPDATE SHIPPING
       -- TEST should modify to get from demand info
       select  oe_header_id, oe_line_id
	 into  l_source_header_id, l_source_line_id
	 from wsh_inv_delivery_details_v
	 WHERE delivery_detail_id=l_del_id;

       IF ((l_serial_control_code>1 AND l_serial_control_code<>6)
	   OR l_lot_control_code > 1) THEN
	  l_action_flag:='M';
	ELSE
	  l_action_flag:='U';
       END IF;
       -- Call update shipping
       l_shipping_attr(1).source_header_id := l_source_header_id;
       l_shipping_attr(1).source_line_id := l_source_line_id;
       l_shipping_attr(1).ship_from_org_id := l_org_id;
       l_shipping_attr(1).subinventory := l_sub;
       l_shipping_attr(1).revision := l_rev;
       l_shipping_attr(1).locator_id := l_loc;
       l_shipping_attr(1).released_status := 'Y';
       l_shipping_attr(1).delivery_detail_id := l_del_id;
       l_shipping_attr(1).transfer_lpn_id := l_transfer_lpn_id;
       l_shipping_attr(1).action_flag := l_action_flag;
       l_shipping_attr(1).lot_number := l_lot;
       l_shipping_attr(1).order_quantity_uom:=l_prim_uom;

       if( l_lot_control_code > 1 and l_serial_control_code not in ( 1, 6) ) then

	  -- get serial info for lot and ser controlled item
	  IF (l_debug = 1) THEN
   	  mydebug('Lot and Serial Controlled');
	  END IF;

	  IF l_transfer_lpn_id = l_cnt_lpn_id THEN
	     IF (l_debug = 1) THEN
   	     mydebug('Entire LPN being crossdocked. MSNT will not be present. hence go against msn');
	     END IF;

	     OPEN msn_serial_csr (l_transfer_lpn_id);
	     LOOP
		FETCH msn_serial_csr INTO l_serial_number;
		EXIT WHEN msn_serial_csr%notfound;
		l_shipping_attr(1).serial_number := l_serial_number;
		l_shipping_attr(1).lot_number := l_lot;
		l_shipping_attr(1).ordered_quantity := 1;
		l_shipping_attr(1).picked_quantity := 1; -- added for bug 3872182
		l_return_status := '';

		WSH_INTERFACE.Update_Shipping_Attributes
		  (p_source_code               => 'INV',
		   p_changed_attributes        => l_shipping_attr,
		   x_return_status             => l_return_status
		   );

		IF (l_debug = 1) THEN
   		mydebug('after update shipping attributes');
		END IF;


		--BUG 3738630: Need to populate group_mark_id here
		--because shipping relies on the fact the MSN.GROUP_MARK_ID
		--is not null, and inventory TM would have null it out
		--at this point
		BEGIN
		   UPDATE mtl_serial_numbers
		     SET  group_mark_id = mtl_material_transactions_s.NEXTVAL
		     WHERE serial_number = l_serial_number
		     AND   inventory_item_id = l_item_id
		     AND   current_organization_id = l_org_id;
		EXCEPTION
		   WHEN OTHERS THEN
		      IF (l_debug = 1) THEN
			 mydebug('Error updating group_mark_id of serial_number: ' || l_serial_number);
		      END IF;
		END;

		IF (l_debug = 1) THEN
		   mydebug('Number of serial number updated: ' || SQL%rowcount);
		END IF;

		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		   FND_MESSAGE.SET_NAME('WMS','WMS_TD_UPD_SHP_ERROR' );
		   FND_MSG_PUB.ADD;
		   RAISE FND_API.g_exc_unexpected_error;

		 ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		   FND_MESSAGE.SET_NAME('WMS','WMS_TD_UPD_SHP_ERROR');
		   FND_MSG_PUB.ADD;
		   RAISE FND_API.G_EXC_ERROR;
		END IF;


	     END LOOP;
	     CLOSE msn_serial_csr;

	   ELSE

	     IF (l_debug = 1) THEN
   	     mydebug('Entire LPN not being crossdocked');
	     END IF;
	     OPEN serial_csr;
	     LOOP
		fetch serial_csr into l_serial_number;
		exit when serial_csr%NOTFOUND;
		l_shipping_attr(1).serial_number := l_serial_number;
		l_shipping_attr(1).lot_number := l_lot;
		l_shipping_attr(1).ordered_quantity := 1;
		l_shipping_attr(1).picked_quantity := 1; -- added for bug 3872182
		l_return_status := '';

		WSH_INTERFACE.Update_Shipping_Attributes
		  (p_source_code               => 'INV',
		   p_changed_attributes        => l_shipping_attr,
		   x_return_status             => l_return_status
		   );


		IF (l_debug = 1) THEN
   		mydebug('after update shipping attributes');
		END IF;

		--BUG 3738630: Need to populate group_mark_id here
		--because shipping relies on the fact the MSN.GROUP_MARK_ID
		--is not null, and inventory TM would have null it out
		--at this point
		BEGIN
		   UPDATE mtl_serial_numbers
		     SET  group_mark_id = mtl_material_transactions_s.NEXTVAL
		     WHERE serial_number = l_serial_number
		     AND   inventory_item_id = l_item_id
		     AND   current_organization_id = l_org_id;
		EXCEPTION
		   WHEN OTHERS THEN
		      IF (l_debug = 1) THEN
			 mydebug('Error updating group_mark_id of serial_number: ' || l_serial_number);
		      END IF;
		END;

		IF (l_debug = 1) THEN
		   mydebug('Number of serial number updated: ' || SQL%rowcount);
		END IF;

		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		   FND_MESSAGE.SET_NAME('WMS','WMS_TD_UPD_SHP_ERROR' );
		   FND_MSG_PUB.ADD;
		   RAISE FND_API.g_exc_unexpected_error;

		 ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		   FND_MESSAGE.SET_NAME('WMS','WMS_TD_UPD_SHP_ERROR');
		   FND_MSG_PUB.ADD;
		   RAISE FND_API.G_EXC_ERROR;
		END IF;


	     END LOOP;
	     close serial_csr;

	  END IF;

	ELSIF ( l_lot_control_code = 1 and l_serial_control_code not in (1, 6)
		) THEN
		-- get serial info for ser controlled item
		IF (l_debug = 1) THEN
   		mydebug('Serial Controlled only');
		END IF;
		l_serial_temp_id:=l_temp_id;

		IF l_transfer_lpn_id = l_cnt_lpn_id THEN
		   IF (l_debug = 1) THEN
   		   mydebug('Entire LPN being crossdocked. MSNT will not be present. hence go against msn');
		   END IF;

		   OPEN msn_serial_csr (l_transfer_lpn_id);
		   LOOP
		      FETCH msn_serial_csr INTO l_serial_number;
		      EXIT WHEN msn_serial_csr%notfound;

		      l_shipping_attr(1).serial_number := l_serial_number;
		      -- l_shipping_attr(1).lot_number := l_lot;
		      l_shipping_attr(1).ordered_quantity := 1;
		      l_shipping_attr(1).picked_quantity := 1; -- added for bug 3872182
		      l_return_status := '';

		      WSH_INTERFACE.Update_Shipping_Attributes
			(p_source_code               => 'INV',
			 p_changed_attributes        => l_shipping_attr,
			 x_return_status             => l_return_status
			 );

		      --BUG 3738630: Need to populate group_mark_id here
		      --because shipping relies on the fact the MSN.GROUP_MARK_ID
		      --is not null, and inventory TM would have null it out
		      --at this point
		      BEGIN
			 UPDATE mtl_serial_numbers
			   SET  group_mark_id = mtl_material_transactions_s.NEXTVAL
			   WHERE serial_number = l_serial_number
			   AND   inventory_item_id = l_item_id
			   AND   current_organization_id = l_org_id;
		      EXCEPTION
			 WHEN OTHERS THEN
			    IF (l_debug = 1) THEN
			       mydebug('Error updating group_mark_id of serial_number: ' || l_serial_number);
			    END IF;
		      END;

		      IF (l_debug = 1) THEN
			 mydebug('Number of serial number updated: ' || SQL%rowcount);
		      END IF;

		      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			 FND_MESSAGE.SET_NAME('WMS','WMS_TD_UPD_SHP_ERROR' );
			 FND_MSG_PUB.ADD;
			 RAISE FND_API.g_exc_unexpected_error;

		       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			 FND_MESSAGE.SET_NAME('WMS','WMS_TD_UPD_SHP_ERROR');
			 FND_MSG_PUB.ADD;
			 RAISE FND_API.G_EXC_ERROR;
		      END IF;


		      IF (l_debug = 1) THEN
   		      mydebug('after update shipping attributes');
		      END IF;

		   END LOOP;
		   CLOSE msn_serial_csr;

		 ELSE
		   IF (l_debug = 1) THEN
   		   mydebug('Entire LPN not being crossdocked');
		   END IF;
		   OPEN serial_csr;
		   LOOP
		      fetch serial_csr into l_serial_number;
		      exit when serial_csr%NOTFOUND;
		      l_shipping_attr(1).serial_number := l_serial_number;
		      -- l_shipping_attr(1).lot_number := l_lot;
		      l_shipping_attr(1).ordered_quantity := 1;
		      l_shipping_attr(1).picked_quantity := 1; -- added for bug 3872182
		      l_return_status := '';

		      WSH_INTERFACE.Update_Shipping_Attributes
			(p_source_code               => 'INV',
			 p_changed_attributes        => l_shipping_attr,
			 x_return_status             => l_return_status
			 );

		      --BUG 3738630: Need to populate group_mark_id here
		      --because shipping relies on the fact the MSN.GROUP_MARK_ID
		      --is not null, and inventory TM would have null it out
		      --at this point
		      BEGIN
			 UPDATE mtl_serial_numbers
			   SET  group_mark_id = mtl_material_transactions_s.NEXTVAL
			   WHERE serial_number = l_serial_number
			   AND   inventory_item_id = l_item_id
			   AND   current_organization_id = l_org_id;
		      EXCEPTION
			 WHEN OTHERS THEN
			    IF (l_debug = 1) THEN
			       mydebug('Error updating group_mark_id of serial_number: ' || l_serial_number);
			    END IF;
		      END;

		      IF (l_debug = 1) THEN
			    mydebug('Number of serial number updated: ' || SQL%rowcount);
		      END IF;

		      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			 FND_MESSAGE.SET_NAME('WMS','WMS_TD_UPD_SHP_ERROR' );
			 FND_MSG_PUB.ADD;
			 RAISE FND_API.g_exc_unexpected_error;

		       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			 FND_MESSAGE.SET_NAME('WMS','WMS_TD_UPD_SHP_ERROR');
			 FND_MSG_PUB.ADD;
			 RAISE FND_API.G_EXC_ERROR;
		      END IF;


		      IF (l_debug = 1) THEN
   		      mydebug('after update shipping attributes');
		      END IF;

		   END LOOP;
		   close serial_csr;

		END IF;

	ELSE
		      IF (l_debug = 1) THEN
   		      mydebug('No Ser cnt');
		      END IF;
		      -- no serial control
		      IF (l_debug = 1) THEN
   		      mydebug('no serial control');
		      END IF;
		      l_shipping_attr(1).ordered_quantity := l_prim_qty;
		      l_shipping_attr(1).picked_quantity := l_prim_qty; -- added for bug 3872182

		      IF (l_debug = 1) THEN
   		      mydebug('release status = ' || l_shipping_attr(1).released_status);
   		      mydebug('delivery_detail_id ' || l_shipping_attr(1).delivery_detail_id);
   		      mydebug('action flag is ' || l_shipping_attr(1).action_flag);
   		      mydebug('about to call update shipping attributes');
		      END IF;





		      WSH_INTERFACE.Update_Shipping_Attributes
			(p_source_code               => 'INV',
			 p_changed_attributes        => l_shipping_attr,
			 x_return_status             => l_return_status
			 );


		      fnd_msg_pub.count_and_get
			(  p_count  => l_msg_cnt
			   , p_data   => l_msg_data
			   );

		      IF (l_msg_cnt = 0) THEN
			 IF (l_debug = 1) THEN
   			 mydebug('Successful');
			 END IF;
		       ELSIF (l_msg_cnt = 1) THEN
			 IF (l_debug = 1) THEN
   			 mydebug('Not Successful');
   			 mydebug(replace(l_msg_data,chr(0),' '));
			 END IF;
		       ELSE
			 IF (l_debug = 1) THEN
   			 mydebug('Not Successful2');
			 END IF;
			 For I in 1..l_msg_cnt LOOP
			    l_msg_data := fnd_msg_pub.get(I,'F');
			    IF (l_debug = 1) THEN
   			    mydebug(replace(l_msg_data,chr(0),' '));
			    END IF;
			 END LOOP;
		      END IF;

		      IF (l_debug = 1) THEN
   		      mydebug('return status'|| l_return_status);
		      END IF;

		      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			 FND_MESSAGE.SET_NAME('WMS','WMS_TD_UPD_SHP_ERROR' );
			 FND_MSG_PUB.ADD;
			 RAISE FND_API.g_exc_unexpected_error;

		       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			 FND_MESSAGE.SET_NAME('WMS','WMS_TD_UPD_SHP_ERROR');
			 FND_MSG_PUB.ADD;
			 RAISE FND_API.G_EXC_ERROR;
		      END IF;

		      IF (l_debug = 1) THEN
   		      mydebug('after update shipping attributes');
		      END IF;

       END IF;


       -- Have to get delivery detail id
	 IF (l_debug = 1) THEN
   	 mydebug('Getting del detail id...');
	 END IF;
         begin
	    SELECT delivery_detail_id INTO l_lpn_del_detail_id
	      FROM wsh_delivery_details_ob_grp_v
	      WHERE lpn_id=l_transfer_lpn_id
	      AND ROWNUM=1;
	 EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	       FND_MESSAGE.SET_NAME('WMS', 'WMS_TD_DEL_LPN_ERROR');
	       FND_MSG_PUB.ADD;
	       RAISE FND_API.G_EXC_ERROR;
	 END;

	 IF (l_debug = 1) THEN
   	 mydebug('Update LPN context to picked');
	 END IF;

	 -- LPN Sync Project, after creating the inner LPN need
	 -- to create the outer LPNs an well
         l_wsh_action_prms.caller      := 'WMS';
         l_wsh_action_prms.action_code := 'PACK';
         l_curr_lpn_id                 := l_transfer_lpn_id;
         l_ret                         := 0;

	 FOR parent_lpn_rec IN parent_lpn_cur( l_transfer_lpn_id ) LOOP
           IF ( l_debug = 1 ) THEN
            mydebug('Got parent LPN record lpnid='||parent_lpn_rec.lpn_id||' plpnid='||parent_lpn_rec.parent_lpn_id||' curlpn='||l_curr_lpn_id||' lret='||l_ret);
           END IF;

           IF ( parent_lpn_rec.lpn_id  = l_transfer_lpn_id ) THEN
	 	 	 -- If this is the innermost LPN create the LPN, if there is a parent
	 	 	 -- LPN it will be created in the next cursor pass through the packing
            WMS_Container_PVT.Modify_LPN_Wrapper (
	       p_api_version   => '1.0'
	     , x_return_status => l_return_status
	     , x_msg_count     => l_msg_cnt
	     , x_msg_data      => l_msg_data
	     , p_caller        => 'WMS_COMPLETE_CROSSDOCK'
	     , p_lpn_id        => l_transfer_lpn_id
	     , p_lpn_context   => wms_globals.lpn_context_picked );

            -- store current LPNs for use in next pass. This will be used to set l_curr_lpn_id
            l_lpn_rec.lpn_id                  := parent_lpn_rec.lpn_id;

	   ELSE
	   	 -- Check to see if the LPN already exist in WDD will be used to determine if
	 	   -- we need to continue creating heirarchy in the next loop
	 	   -- should only be checked if there is another loop (lpn has a parent)
	 	   IF ( parent_lpn_rec.parent_lpn_id IS NOT NULL ) THEN
	 	     BEGIN
	 	       SELECT 1 INTO l_ret
	 	       FROM   wsh_delivery_details
	 	       WHERE  lpn_id = parent_lpn_rec.lpn_id;
	 	     EXCEPTION
	 	       WHEN NO_DATA_FOUND THEN
	 	       	 IF (l_debug = 1) THEN
                          mydebug('LPN not in WDD');
                         END IF;
	 	         l_ret := 0;
	 	      END;
                   END IF;

	   	 -- Not the innermost LPN.  Get the previous passes parent LPN's attibutes to
	   	 -- give to shipping
                 l_lpn_rec.lpn_id                  := parent_lpn_rec.lpn_id;
                 l_lpn_rec.license_plate_number    := parent_lpn_rec.license_plate_number;
                 l_lpn_rec.organization_id         := parent_lpn_rec.organization_id;
	 	 l_lpn_rec.subinventory_code       := parent_lpn_rec.subinventory_code;
	 	 l_lpn_rec.locator_id              := parent_lpn_rec.locator_id;
                 l_lpn_rec.tare_weight             := parent_lpn_rec.tare_weight;
                 l_lpn_rec.tare_weight_uom_code    := parent_lpn_rec.tare_weight_uom_code;
                 l_lpn_rec.gross_weight            := parent_lpn_rec.gross_weight;
                 l_lpn_rec.gross_weight_uom_code   := parent_lpn_rec.gross_weight_uom_code;
                 l_lpn_rec.container_volume        := parent_lpn_rec.container_volume;
                 l_lpn_rec.container_volume_uom    := parent_lpn_rec.container_volume_uom;
                 l_lpn_rec.content_volume          := parent_lpn_rec.content_volume;
                 l_lpn_rec.content_volume_uom_code := parent_lpn_rec.content_volume_uom_code;

	         -- Translate LPN attribues to wsh data type
                 l_wsh_action_prms.lpn_rec := WMS_Container_PVT.To_DeliveryDetailsRecType(l_lpn_rec);

                -- Pack previous cursor passes LPN into it's parent in WDD
                -- Parent LPN will be created in WDD if it does not already exist
                l_wsh_lpn_id_tbl(1) := l_curr_lpn_id;

                IF (l_debug = 1) THEN
                  mydebug('Call to WSH Delivery_Detail_Action to pack LPN heirarchy');
                END IF;
                WSH_WMS_LPN_GRP.Delivery_Detail_Action (
                  p_api_version_number => 1.0
                , p_init_msg_list      => fnd_api.g_false
                , p_commit             => fnd_api.g_false
                , x_return_status      => x_return_status
                , x_msg_count          => x_msg_count
                , x_msg_data           => x_msg_data
                , p_lpn_id_tbl         => l_wsh_lpn_id_tbl
                , p_del_det_id_tbl     => l_wsh_del_det_id_tbl
                , p_action_prms        => l_wsh_action_prms
                , x_defaults           => l_wsh_defaults
                , x_action_out_rec     => l_wsh_action_out_rec );

                IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
                  IF (l_debug = 1) THEN
                    mydebug('Delivery_Detail_Action failed');
                  END IF;
                  RAISE fnd_api.g_exc_error;
                ELSIF (l_debug = 1) THEN
                  mydebug('Done with call to WSH Create_Update_Containers');
                END IF;
            END IF;

            -- LPN already exists in WDD, thus so should it's parent LPNs, exit
           IF ( l_ret = 1 ) THEN
              EXIT;
           ELSE -- Store current parent LPN's lpn_id as current lpn for next pass
             l_curr_lpn_id := l_lpn_rec.lpn_id;
           END IF;
	 END LOOP;


       IF (l_debug = 1) THEN
          mydebug('Calling Print Label with del detail id:'||l_lpn_del_detail_id);
       END IF;
       -- Calling the print label function

       inv_label.PRINT_LABEL_WRAP
	 (
	  x_return_status=>l_return_status
	  ,	x_msg_count=>l_msg_cnt
	  ,	x_msg_data=>l_msg_data
	  ,	x_label_status=>l_label_status
	  ,	p_business_flow_code=>6
	  ,	p_transaction_id=>l_lpn_del_detail_id
	  ) ;


       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  FND_MESSAGE.SET_NAME('INV','INV_RCV_CRT_PRINT_LAB_FAIL');
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.g_exc_unexpected_error;

	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  FND_MESSAGE.SET_NAME('INV','INV_RCV_CRT_PRINT_LAB_FAIL');
	  FND_MSG_PUB.ADD;
	  l_return_status :=FND_API.g_ret_sts_success;
       END IF;

       x_return_status:=l_return_status;


       -- End of crossdock loop
    END IF;

    -- Bug 2465491 The API completes successfully so returns success
    x_return_status:= FND_API.g_ret_sts_success;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MESSAGE.SET_NAME('WMS','WMS_TD_CCDOCK_ERROR' );
	FND_MSG_PUB.ADD;
	FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);


END complete_crossdock;


PROCEDURE mark_delivery
  (p_del_id IN NUMBER
   ,  x_ret OUT NOCOPY VARCHAR2
   ,  x_return_status     OUT   NOCOPY VARCHAR2
   ,  x_msg_count         OUT   NOCOPY NUMBER
   ,  x_msg_data          OUT   NOCOPY VARCHAR2)
  IS
     l_ret VARCHAR2(1);
     l_del_id NUMBER;
     l_shipping_attr              WSH_INTERFACE.ChangedAttributeTabType;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(240);
     l_return_status VARCHAR2(1);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      mydebug('in mark delivery as submitted');
   END IF;
   l_del_id:=p_del_id;

   l_shipping_attr(1).released_status := 'S';
   l_shipping_attr(1).delivery_detail_id := l_del_id;
   l_shipping_attr(1).action_flag := 'U';

   IF (l_debug = 1) THEN
      mydebug('Before calling update shipping');
   END IF;

   WSH_INTERFACE.Update_Shipping_Attributes
     (p_source_code               => 'INV',
      p_changed_attributes        => l_shipping_attr,
      x_return_status             => l_return_status
      );
   IF (l_debug = 1) THEN
      mydebug('return status'||l_ret);
   END IF;

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      FND_MESSAGE.SET_NAME('WMS','WMS_TD_UPD_SHP_ERROR' );
      FND_MSG_PUB.ADD;
      RAISE FND_API.g_exc_unexpected_error;

    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      FND_MESSAGE.SET_NAME('WMS','WMS_TD_UPD_SHP_ERROR');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;



   x_ret:=l_ret;
   x_return_status:=l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       x_ret := FND_API.G_RET_STS_ERROR;
       x_return_status:=l_return_status;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get( p_count => l_msg_count, p_data => l_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_ret := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_return_status:=l_return_status;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get( p_count => l_msg_count, p_data => l_msg_data);

    WHEN OTHERS THEN
       x_ret := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_return_status:=l_return_status;
       FND_MESSAGE.SET_NAME('WMS','WMS_TD_MD_ERROR');
       FND_MSG_PUB.ADD;
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );



END mark_delivery;

--New private api to cancel wip crossdock tasks.
PROCEDURE cancel_wip_crossdock_task(p_transaction_temp_id IN NUMBER
				    ,p_move_order_line_id IN NUMBER
				    ,x_return_status OUT nocopy VARCHAR2
				    ,x_msg_data OUT nocopy VARCHAR2
				    ,x_msg_count OUT nocopy NUMBER
				    )
  IS
          l_wdt_status NUMBER := 0;
BEGIN
   mydebug('CANCEL_WIP_CROSSDOCK_TASK: Entering...');
   mydebug('CANCEL_WIP_CROSSDOCK_TASK: MMTT ID: '||p_transaction_temp_id);
   mydebug('CANCEL_WIP_CROSSDOCK_TASK: MOL ID: '||p_move_order_line_id);

   x_return_status := fnd_api.g_ret_sts_success;

   --Check to see if the task is loaded. If task is loaded and return an
   --error!!!

   BEGIN
      SELECT status
	INTO l_wdt_status
	FROM wms_dispatched_tasks
	WHERE transaction_temp_id = p_transaction_temp_id
	AND   task_type = wms_globals.g_wms_task_type_putaway;
   EXCEPTION
      WHEN no_data_found THEN
	 l_wdt_status := 0;
   END;

   IF l_wdt_status = 4 THEN
      x_return_status := fnd_api.g_ret_sts_error;
      mydebug('Task is loaded... Cannot be canceled ...');
      RETURN;
   END IF;

   --Update MOL
   UPDATE mtl_txn_request_lines
     SET backorder_delivery_detail_id = NULL
     , crossdock_type = 1
     , quantity_detailed = (quantity - Nvl(quantity_delivered,0))
     WHERE line_id = p_move_order_line_id;

   --Delete MMTT
   INV_TRX_UTIL_PUB.Delete_transaction
     (x_return_status       => x_return_status,
      x_msg_data            => x_msg_data,
      x_msg_count           => x_msg_count,
      p_transaction_temp_id => p_transaction_temp_id,
      p_update_parent       => FALSE);

   mydebug('CANCEL_WIP_CROSSDOCK_TASK: Exiting...: '||x_return_status);
EXCEPTION
   WHEN OTHERS THEN
      mydebug('CANCEL_WIP_CROSSDOCK_TASK:ERROR! Unexpected Error:'||SQLCODE);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count  => x_msg_count
				, p_data => x_msg_data);

END cancel_wip_crossdock_task;


--New api to be called from WMS Control Board.
PROCEDURE cancel_crossdock_task(p_transaction_temp_id IN NUMBER
				, x_return_status     OUT nocopy VARCHAR2
				, x_msg_data          OUT nocopy VARCHAR2
				, x_msg_count         OUT nocopy NUMBER
				)

  IS
     l_txn_src_type_id NUMBER;
     l_error_code NUMBER;
     l_move_order_line_id NUMBER;
     l_backorder_delivery_detail_id NUMBER;

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   mydebug('CANCEL_CROSSDOCK_TASK: Enter...');
   mydebug('CANCEL_CROSSDOCK_TASK: MMTT ID: '||p_transaction_temp_id);

   --Query the MMTT using the p_transaction_temp_id

   SELECT mmtt.transaction_source_type_id
     , mmtt.move_order_line_id
     , mtrl.backorder_delivery_detail_id
     INTO l_txn_src_type_id
     , l_move_order_line_id
     , l_backorder_delivery_detail_id
     FROM mtl_material_transactions_temp mmtt
     , mtl_txn_request_lines mtrl
     , mtl_txn_request_headers mtrh
     WHERE mmtt.transaction_temp_id = p_transaction_temp_id
     AND mmtt.move_order_line_id = mtrl.line_id
     AND mtrh.header_id = mtrl.header_id
     AND mtrh.move_order_type = 6
     AND mtrl.line_status = 7;

   mydebug('CANCEL_CROSSDOCK_TASK: TxnSourceID: '||l_txn_src_type_id);
   mydebug('CANCEL_CROSSDOCK_TASK: MOLID: '||l_move_order_line_id);
   mydebug('CANCEL_CROSSDOCK_TASK: BODDID: '||l_backorder_delivery_detail_id);

   IF l_backorder_delivery_detail_id IS NULL THEN
      mydebug('CANCEL_CROSSDOCK_TASK: ERROR! Not a Crossdock Task');
      RAISE fnd_api.g_exc_error;
   END IF;

   --Check the transaction source type.
   --If the transaction type is WIP then write a new api to take care of
   --task cancellation ELSE call cancel_operation_plan api.

   mydebug('CANCEL_CROSSDOCK_TASK: Call the appropriate API...');

   IF l_txn_src_type_id = inv_reservation_global.g_source_type_wip THEN
      mydebug('CANCEL_CROSSDOCK_TASK: Cancelling Crossdock task for a WIP LPN');
      cancel_wip_crossdock_task(p_transaction_temp_id => p_transaction_temp_id
				,p_move_order_line_id => l_move_order_line_id
				,x_return_status => x_return_status
				,x_msg_data => x_msg_data
				,x_msg_count => x_msg_count);
    ELSE
      mydebug('CANCEL_CROSSDOCK_TASK: Cancelling Crossdock task for a RCV LPN');
      wms_atf_runtime_pub_apis.cancel_operation_plan(x_return_status => x_return_status
						     ,x_msg_data => x_msg_data
						     ,x_msg_count => x_msg_count
						     ,x_error_code => l_error_code
						     ,p_source_task_id => p_transaction_temp_id
						     ,p_activity_type_id=> 1
						     --,p_mmtt_error_code => p_mmtt_error_code
						     --,p_mmtt_error_explanation => p_mmtt_error_explanation
						     );
   END IF;

   mydebug('CANCEL_CROSSDOCK_TASK: x_return_status: '||x_return_status);
   mydebug('CANCEL_CROSSDOCK_TASK: Exiting...');

EXCEPTION
   WHEN no_data_found THEN
      mydebug('CANCEL_CROSSDOCK_TASK: ERROR! Invalid Transaction Temp ID: '||p_transaction_temp_id);
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count  => x_msg_count
				, p_data => x_msg_data);
   WHEN fnd_api.g_exc_error THEN
      mydebug('CANCEL_CROSSDOCK_TASK: ERROR! Error raised by the API: '||SQLCODE);
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count  => x_msg_count
				, p_data => x_msg_data);
   WHEN OTHERS THEN
      mydebug('CANCEL_CROSSDOCK_TASK: ERROR! Unexpected Error: '||SQLCODE);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count  => x_msg_count
				, p_data => x_msg_data);

END cancel_crossdock_task;


END WMS_Cross_Dock_Pvt;


/
