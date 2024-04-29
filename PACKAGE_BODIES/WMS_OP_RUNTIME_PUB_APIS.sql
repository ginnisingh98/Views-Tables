--------------------------------------------------------
--  DDL for Package Body WMS_OP_RUNTIME_PUB_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_OP_RUNTIME_PUB_APIS" AS
/* $Header: WMSOPPBB.pls 120.5.12000000.2 2007/04/04 17:59:32 stdavid ship $*/

--
-- File        : WMSOPPBB.pls
-- Content     : WMS_OP_RUNTIME_PUB_APIS package Body
-- Description : WMS Operation Plan Run-time APIs
-- Notes       :
-- Modified    : 10/21/2002 lezhang created

--g_txn_type_so_stg_xfr NUMBER := inv_globals.g_type_transfer_order_stgxfr;
g_sourcetype_salesorder NUMBER := inv_globals.g_sourcetype_salesorder;
g_action_stgxfr NUMBER := inv_globals.g_action_stgxfr;
g_sourcetype_intorder NUMBER := inv_globals.g_sourcetype_intorder;
g_op_dest_sys_suggested NUMBER := wms_globals.g_op_dest_sys_suggested;
g_op_dest_api NUMBER := wms_globals.g_op_dest_api;
g_op_dest_pre_specified NUMBER := wms_globals.g_op_dest_pre_specified;
g_op_dest_rules_engine NUMBER := wms_globals.g_op_dest_rules_engine;
g_wms_task_type_pick NUMBER := wms_globals.g_wms_task_type_pick;
g_wms_task_type_stg_move NUMBER := wms_globals.g_wms_task_type_stg_move;
g_op_drop_lpn_no_lpn NUMBER := wms_globals.g_op_drop_lpn_no_lpn;
g_op_drop_lpn_optional NUMBER := wms_globals.g_op_drop_lpn_optional;

g_ret_sts_success VARCHAR2(1) := fnd_api.g_ret_sts_success;
g_ret_sts_unexp_error VARCHAR2(1) := fnd_api.g_ret_sts_unexp_error;
g_ret_sts_error  VARCHAR2(1) := fnd_api.g_ret_sts_error;

PROCEDURE print_debug(p_err_msg VARCHAR2,
		      p_level NUMBER)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   inv_mobile_helper_functions.tracelog
     (p_err_msg => p_err_msg,
      p_module => 'WMS_OP_RUNTIME_PUB_APIS',
      p_level => p_level);

   --dbms_output.put_line(p_err_msg);
END print_debug;



-- API name    :
-- Type        : Public
-- Function    :
-- Pre-reqs    :
--
--
-- Parameters  :
--   Output:
--
--   Input:
--
--
-- Version
--   Currently version is 1.0
--


PROCEDURE update_drop_locator_for_task
  (x_return_status          OUT nocopy VARCHAR2,
   x_message                OUT nocopy VARCHAR2,
   x_drop_lpn_option        OUT nocopy NUMBER,
   p_transfer_lpn_id    IN NUMBER
   )

  IS

     TYPE TransactionTempIDTable IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;
     TYPE PickRelDestZoneIDTable IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;
     TYPE PickRelDestSubCodeTable IS TABLE OF VARCHAR2(30)
       INDEX BY BINARY_INTEGER;
     TYPE PickRelDestLocIDTable IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;
     TYPE SugDestZoneIDTable IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;
     TYPE SugDestSubCodeTable IS TABLE OF VARCHAR2(30)
       INDEX BY BINARY_INTEGER;
     TYPE SugDestLocIDTable IS TABLE OF VARCHAR2(30)
       INDEX BY BINARY_INTEGER;
     TYPE SugLPNIDTable IS TABLE OF NUMBER -- xdock MDC
       INDEX BY BINARY_INTEGER;

     l_temp_id_table TransactionTempIDTable;
     l_pick_rel_zone_id_table PickRelDestZoneIDTable;
     l_pick_rel_sub_table PickRelDestSubCodeTable;
     l_pick_rel_loc_id_table PickRelDestLocIDTable;
     l_sug_dest_zone_id_table SugDestZoneIDTable;
     l_sug_dest_sub_table SugDestSubCodeTable;
     l_sug_dest_loc_id_table SugDestLocIDTable;
     l_sug_lpn_id_table SugLPNIDTable;


     CURSOR l_task_drop_loc_cur
       (v_operation_sequence_id NUMBER)IS
	SELECT mmtt.transaction_temp_id transaction_temp_id,
	  mmtt.transfer_subinventory pick_release_subinventory,
	  mmtt.transfer_to_location pick_release_locator_id,
	  mmtt.wms_task_type,
	  mmtt.parent_line_id parent_line_id,
	  mmtt.move_order_line_id move_order_line_id,
	  op.operation_plan_id operation_plan_id,
	  Nvl(op.loc_selection_criteria, g_op_dest_sys_suggested) dest_loc_sel_criteria,
	  op.loc_selection_api_id dest_loc_sel_api_id,
	  Nvl(op.drop_lpn_option, g_op_drop_lpn_optional) drop_lpn_option,
	  Nvl(op.consolidation_method_id, 2) consolidation_method_id -- xdock MDC default to within delivery
	  FROM mtl_material_transactions_temp mmtt,
	  (SELECT plan.operation_plan_id,
	   detail.loc_selection_criteria,
	   detail.loc_selection_api_id,
	   detail.drop_lpn_option,
	   detail.consolidation_method_id
	   FROM
	   wms_op_plans_b plan,
	   wms_op_plan_details detail
	   WHERE
	   plan.operation_plan_id = detail.operation_plan_id AND
	   detail.operation_sequence = v_operation_sequence_id
	   ) op
	  WHERE mmtt.transfer_lpn_id = p_transfer_lpn_id AND
	  (mmtt.parent_line_id IS NULL   -- xdock MDC non bulk line or child line for bulk task
	   OR mmtt.parent_line_id <> mmtt.transaction_temp_id) AND
	  ((mmtt.transaction_source_type_id = g_sourcetype_salesorder
	    AND mmtt.transaction_action_id = g_action_stgxfr)
	   OR
	   (mmtt.transaction_source_type_id = g_sourcetype_intorder
	    AND mmtt.transaction_action_id = g_action_stgxfr)
	   OR
	   mmtt.wms_task_type = g_wms_task_type_stg_move
	   )AND
	  mmtt.operation_plan_id = op.operation_plan_id (+)
	  ;

     l_task_drop_loc_rec l_task_drop_loc_cur%ROWTYPE;

     l_operation_sequence_id NUMBER := 2;
     l_delivery_id NUMBER;
     l_task_count NUMBER := 1;

     l_return_status VARCHAR2(1);
     l_message VARCHAR2(400);
     l_progress VARCHAR2(10);

     l_msg_count NUMBER;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   SAVEPOINT update_drop_loc_sp;



   IF (l_debug = 1) THEN
      print_debug('Enter update_drop_locator_for_task', 1);
   END IF;

   IF (l_debug = 1) THEN
      print_debug('p_transfer_lpn_id : '|| p_transfer_lpn_id, 4);
   END IF;


   l_progress := '10';

   x_return_status := g_ret_sts_success;

   fnd_message.clear;

   OPEN l_task_drop_loc_cur(l_operation_sequence_id);

   LOOP

      FETCH l_task_drop_loc_cur INTO l_task_drop_loc_rec;
      EXIT WHEN l_task_drop_loc_cur%notfound;

      l_progress := '20';

      IF (l_debug = 1) THEN
   	 print_debug('transaction_temp_id : '|| l_task_drop_loc_rec.transaction_temp_id, 4);
   	 print_debug('wms_task_type : '|| l_task_drop_loc_rec.wms_task_type, 4);
   	 print_debug('pick_release_subinventory : '|| l_task_drop_loc_rec.pick_release_subinventory, 4);
   	 print_debug('pick_release_locator_id : '|| l_task_drop_loc_rec.pick_release_locator_id, 4);
   	 print_debug('operation_plan_id : '|| l_task_drop_loc_rec.operation_plan_id, 4);
   	 print_debug('dest_loc_sel_criteria : '|| l_task_drop_loc_rec.dest_loc_sel_criteria, 4);
   	 print_debug('dest_loc_sel_api_id : '|| l_task_drop_loc_rec.dest_loc_sel_api_id, 4);
      END IF;


      l_temp_id_table(l_task_count) := l_task_drop_loc_rec.transaction_temp_id;
      l_pick_rel_sub_table(l_task_count) := l_task_drop_loc_rec.pick_release_subinventory;
      l_pick_rel_loc_id_table(l_task_count) := l_task_drop_loc_rec.pick_release_locator_id;

      l_progress := '25';

      l_sug_lpn_id_table(l_task_count) := NULL;

      IF l_task_drop_loc_rec.wms_task_type = g_wms_task_type_stg_move THEN

	 --{{
	 -- For staging move
	 -- Two cases to handle when consolidation accross delivery
	 -- 1. Bulk picking. In this case, should call MDC API for each delivery within the LPN
	 -- 2. Regular LPN. In this case, only need to call MDC API for the entire LPN
	 --    The indicator for a regular LPN is that any line within this LPN has NULL parent_line_id
	 -- In fact, bulk picking case might not occur for staging move. But since there is no
	 -- performance concern, leave the check here just in case.
	 --}}
	 IF l_task_drop_loc_rec.consolidation_method_id = 1 THEN

	    IF(l_task_drop_loc_rec.parent_line_id IS NULL) THEN
	       l_progress := '25.10';

	       IF(l_task_count = 1) THEN
		  l_progress := '25.20';

		  IF (l_debug = 1) THEN
		     print_debug('Before calling wms_mdc_pvt.suggest_to_lpn with following parameters:', 4);
		     print_debug('p_transfer_lpn_id : '||p_transfer_lpn_id , 4);
		  END IF;
		  wms_mdc_pvt.suggest_to_lpn
		    (p_lpn_id => p_transfer_lpn_id,
		     p_delivery_id => NULL,
		     x_to_lpn_id =>l_sug_lpn_id_table(l_task_count),
		     x_to_subinventory_code=>l_sug_dest_sub_table(l_task_count),
		     x_to_locator_id =>l_sug_dest_loc_id_table(l_task_count),
		     x_return_status =>l_return_status,
		     x_msg_count =>l_msg_count,
		     x_msg_data =>l_message);

		  IF (l_debug = 1) THEN
		     print_debug('After calling wms_mdc_pvt.suggest_to_lpn:', 4);
		     print_debug('l_return_status : '|| l_return_status, 4);
		     print_debug('x_to_lpn_id : '|| l_sug_lpn_id_table(l_task_count), 4);
		     print_debug('x_to_subinventory_code : '|| l_sug_dest_sub_table(l_task_count), 4);
		     print_debug('x_to_locator_id : '||l_sug_dest_loc_id_table(l_task_count) , 4);
		  END IF;

		  IF l_return_status <> g_ret_sts_success THEN
		     print_debug('Failed calling wms_mdc_pvt.suggest_to_lpn.', 4);
		     IF l_return_status = g_ret_sts_error THEN
			RAISE fnd_api.g_exc_error;
		     ELSE
			RAISE fnd_api.g_exc_unexpected_error;
		     END IF;
		  END IF;

		ELSE
		  --{{
		  -- In the case of regular LPN, the rest of the tasks within the same LPN
		  -- should have the same LPN/sub/loc suggested as the first line
		  --}}
		  print_debug('Default sub/loc/LPN from the first task in this LPN.', 4);

		  l_sug_lpn_id_table(l_task_count) := l_sug_lpn_id_table(1);
		  l_sug_dest_loc_id_table(l_task_count) := l_sug_dest_loc_id_table(1);
		  l_sug_lpn_id_table(l_task_count) := l_sug_lpn_id_table(1);
	       END IF;
	     ELSE
	       -- first derive delivery
	       l_progress := '25.30';

	       BEGIN

		  SELECT wda.delivery_id
		    INTO l_delivery_id
		    FROM wsh_delivery_assignments_v wda,
		    wsh_delivery_details wdd
		    WHERE wdd.delivery_detail_id = wda.delivery_detail_id
		    AND wdd.move_order_line_id = l_task_drop_loc_rec.move_order_line_id;

	       EXCEPTION
		  WHEN OTHERS THEN
		     NULL;
	       END;
	       --
	       IF l_delivery_id IS NOT NULL THEN
		  IF (l_debug = 1) THEN
		     print_debug('Before calling wms_mdc_pvt.suggest_to_lpn with following parameters:', 4);
		     print_debug('p_transfer_lpn_id : '||p_transfer_lpn_id , 4);
		     print_debug('p_delivery_id: '|| l_delivery_id, 4);

		  END IF;
		  wms_mdc_pvt.suggest_to_lpn
		    (p_lpn_id => p_transfer_lpn_id,
		     p_delivery_id => l_delivery_id,
		     x_to_lpn_id =>l_sug_lpn_id_table(l_task_count),
		     x_to_subinventory_code=>l_sug_dest_sub_table(l_task_count),
		     x_to_locator_id =>l_sug_dest_loc_id_table(l_task_count),
		     x_return_status =>l_return_status,
		     x_msg_count =>l_msg_count,
		     x_msg_data =>l_message);

		  IF (l_debug = 1) THEN
		     print_debug('After calling wms_mdc_pvt.suggest_to_lpn:', 4);
		     print_debug('l_return_status : '|| l_return_status, 4);
		     print_debug('x_to_lpn_id : '|| l_sug_lpn_id_table(l_task_count), 4);
		     print_debug('x_to_subinventory_code : '|| l_sug_dest_sub_table(l_task_count), 4);
		     print_debug('x_to_locator_id : '||l_sug_dest_loc_id_table(l_task_count) , 4);
		  END IF;

		  IF l_return_status <> g_ret_sts_success THEN
		     print_debug('Failed calling wms_mdc_pvt.suggest_to_lpn.', 4);
		     IF l_return_status = g_ret_sts_error THEN
			RAISE fnd_api.g_exc_error;
		     ELSE
			RAISE fnd_api.g_exc_unexpected_error;
		     END IF;
		  END IF;
	       END IF;


	    END IF;

	 END IF;

	 IF(l_task_drop_loc_rec.consolidation_method_id = 2 OR
	    l_sug_lpn_id_table(l_task_count) IS NULL) THEN

	    --{{
	    -- If consolidation within deliveyr or MDC API does not return anything
	    -- fall back to what we have in 11.5.9
	    -- The latter case could happen to drop to WIP. i.e. no delivery for this task
	    -- wms_op_dest_sys_apis.Get_Staging_Loc_For_Delivery should resort to original suggestion.
	    --}}
	    wms_op_dest_sys_apis.Get_Staging_Loc_For_Delivery
	      (x_return_status => l_return_status,
	       x_message => l_message,
	       x_locator_id => l_sug_dest_loc_id_table(l_task_count),
	       x_zone_id => l_sug_dest_zone_id_table(l_task_count),
	       x_subinventory_code => l_sug_dest_sub_table(l_task_count),
	       p_call_mode => 1,  -- locator selection
	       p_task_type => g_wms_task_type_pick,  -- picking
	       p_task_id => l_task_drop_loc_rec.transaction_temp_id,
	       p_locator_id => NULL);

	    IF l_return_status <> g_ret_sts_success THEN
	       IF l_return_status = 'W' THEN
		  x_return_status := l_return_status;
		  x_message := l_message;
		ELSE
		  RAISE fnd_api.g_exc_error;
	       END IF;

	    END IF;

	 END IF;


       ELSE


	 IF l_task_drop_loc_rec.dest_loc_sel_criteria = g_op_dest_sys_suggested THEN
	    l_progress := '30';
	    IF (l_debug = 1) THEN
   	       print_debug('Return locator as system suggested.', 4);
	    END IF;


	    l_sug_dest_sub_table(l_task_count) := l_task_drop_loc_rec.pick_release_subinventory;
	    l_sug_dest_loc_id_table(l_task_count) := l_task_drop_loc_rec.pick_release_locator_id;

	  ELSIF l_task_drop_loc_rec.dest_loc_sel_criteria = g_op_dest_api THEN -- suggested by API
	    IF (l_debug = 1) THEN
   	       print_debug('Return locator suggested by API.', 4);
	    END IF;

	    l_progress := '40';

	    IF l_task_drop_loc_rec.dest_loc_sel_api_id = 1 THEN
	       IF (l_debug = 1) THEN
   		  print_debug('Calling WMS_OP_DEST_SYS_APIS.Get_CONS_Loc_For_Delivery. Leaving update_drop_locator_for_task ... ', 4);
	       END IF;

	       l_progress := '50';

	       wms_op_dest_sys_apis.Get_CONS_Loc_For_Delivery
		 (x_return_status => l_return_status,
		  x_message => l_message,
		  x_locator_id => l_sug_dest_loc_id_table(l_task_count),
		  x_zone_id => l_sug_dest_zone_id_table(l_task_count),
		  x_subinventory_code => l_sug_dest_sub_table(l_task_count),
		  p_call_mode => 1,  -- locator selection
		  p_task_type => g_wms_task_type_pick,  -- picking
		  p_task_id => l_task_drop_loc_rec.transaction_temp_id,
		  p_locator_id => NULL);

	       IF (l_debug = 1) THEN
   		  print_debug('Back to update_drop_locator_for_task.', 4);
		  print_debug('x_return_status = '||l_return_status, 4);
   		  print_debug('x_message = '||l_message, 4);
   		  print_debug('x_locator_id = '||l_sug_dest_loc_id_table(l_task_count), 4);
   		  print_debug('x_subinventory_code = '||l_sug_dest_sub_table(l_task_count), 4);
   		  print_debug('x_zone_id = '||l_sug_dest_zone_id_table(l_task_count), 4);
	       END IF;

	       IF l_return_status <> g_ret_sts_success THEN
		  IF l_return_status = 'W' THEN
		     x_return_status := l_return_status;
		     x_message := l_message;
		   ELSE
		     RAISE fnd_api.g_exc_error;
		  END IF;
	       ELSIF l_task_drop_loc_rec.parent_line_id IS NOT NULL THEN
	          --
	          -- Bug 4884284: Bulk pick can have multiple deliveries
	          --              so update dest sub/loc immediately
	          --
		  UPDATE mtl_material_transactions_temp
	             SET transfer_subinventory
	                   = l_sug_dest_sub_table(l_task_count)
	               , transfer_to_location
	                   = l_sug_dest_loc_id_table(l_task_count)
	           WHERE transaction_temp_id
	                   = l_task_drop_loc_rec.transaction_temp_id;
	       END IF;

	       l_progress := '60';


	     ELSIF l_task_drop_loc_rec.dest_loc_sel_api_id = 2 THEN



	       --{{
	       -- For pick drop
	       -- Two cases to handle when consolidation accross delivery
	       -- 1. Bulk picking. In this case, should call MDC API for each delivery within the LPN
	       -- 2. Regular LPN. In this case, only need to call MDC API for the entire LPN
	       --    The indicator for a regular LPN is that any line within this LPN has NULL parent_line_id
	       --}}

	       IF l_task_drop_loc_rec.consolidation_method_id = 1 THEN -- across delivery

		  IF(l_task_drop_loc_rec.parent_line_id IS NULL) THEN -- regular LPN, i.e. non-bulk
		     l_progress := '60.10';

		     IF(l_task_count = 1) THEN
			l_progress := '60.20';

			IF (l_debug = 1) THEN
			   print_debug('Before calling wms_mdc_pvt.suggest_to_lpn with following parameters:', 4);
			   print_debug('p_transfer_lpn_id : '||p_transfer_lpn_id , 4);
			END IF;

			wms_mdc_pvt.suggest_to_lpn
			  (p_lpn_id => p_transfer_lpn_id,
			   p_delivery_id => NULL,
			   x_to_lpn_id =>l_sug_lpn_id_table(l_task_count),
			   x_to_subinventory_code=>l_sug_dest_sub_table(l_task_count),
			   x_to_locator_id =>l_sug_dest_loc_id_table(l_task_count),
			   x_return_status =>l_return_status,
			   x_msg_count =>l_msg_count,
			   x_msg_data =>l_message);

			IF (l_debug = 1) THEN
			   print_debug('After calling wms_mdc_pvt.suggest_to_lpn:', 4);
			   print_debug('l_return_status : '|| l_return_status, 4);
			   print_debug('x_to_lpn_id : '|| l_sug_lpn_id_table(l_task_count), 4);
			   print_debug('x_to_subinventory_code : '|| l_sug_dest_sub_table(l_task_count), 4);
			   print_debug('x_to_locator_id : '||l_sug_dest_loc_id_table(l_task_count) , 4);
			END IF;

			IF l_return_status <> g_ret_sts_success THEN
			   print_debug('Failed calling wms_mdc_pvt.suggest_to_lpn.', 4);
			   IF l_return_status = g_ret_sts_error THEN
			      RAISE fnd_api.g_exc_error;
			   ELSE
			      RAISE fnd_api.g_exc_unexpected_error;
			   END IF;
			END IF;

		      ELSE
			--{{
			-- In the case of regular LPN, the rest of the tasks within the same LPN
			-- should have the same LPN/sub/loc suggested as the first line
			--}}
			print_debug('Default sub/loc/LPN from the first task in this LPN.', 4);

			l_sug_lpn_id_table(l_task_count) := l_sug_lpn_id_table(1);
			l_sug_dest_loc_id_table(l_task_count) := l_sug_dest_loc_id_table(1);
			l_sug_lpn_id_table(l_task_count) := l_sug_lpn_id_table(1);
		     END IF;
		   ELSE -- now bulk picking
		     -- first derive delivery
		     l_progress := '60.30';

	             BEGIN

			SELECT wda.delivery_id
			  INTO l_delivery_id
			  FROM wsh_delivery_assignments_v wda,
			  wsh_delivery_details wdd
			  WHERE wdd.delivery_detail_id = wda.delivery_detail_id
			  AND wdd.move_order_line_id = l_task_drop_loc_rec.move_order_line_id;

		     EXCEPTION
			WHEN OTHERS THEN
			   NULL;
		     END;
		     --
		     IF l_delivery_id IS NOT NULL THEN
			IF (l_debug = 1) THEN
			   print_debug('Before calling wms_mdc_pvt.suggest_to_lpn with following parameters:', 4);
			   print_debug('p_transfer_lpn_id : '||p_transfer_lpn_id , 4);
			   print_debug('p_delivery_id: '|| l_delivery_id, 4);

			END IF;
			wms_mdc_pvt.suggest_to_lpn
			  (p_lpn_id => p_transfer_lpn_id,
			   p_delivery_id => l_delivery_id,
			   x_to_lpn_id =>l_sug_lpn_id_table(l_task_count),
			   x_to_subinventory_code=>l_sug_dest_sub_table(l_task_count),
			   x_to_locator_id =>l_sug_dest_loc_id_table(l_task_count),
			   x_return_status =>l_return_status,
			   x_msg_count =>l_msg_count,
			   x_msg_data =>l_message);

			IF (l_debug = 1) THEN
			   print_debug('After calling wms_mdc_pvt.suggest_to_lpn:', 4);
			   print_debug('l_return_status : '|| l_return_status, 4);
			   print_debug('x_to_lpn_id : '|| l_sug_lpn_id_table(l_task_count), 4);
			   print_debug('x_to_subinventory_code : '|| l_sug_dest_sub_table(l_task_count), 4);
			   print_debug('x_to_locator_id : '||l_sug_dest_loc_id_table(l_task_count) , 4);
			END IF;

			IF l_return_status <> g_ret_sts_success THEN
			   print_debug('Failed calling wms_mdc_pvt.suggest_to_lpn.', 4);
			   IF l_return_status = g_ret_sts_error THEN
			      RAISE fnd_api.g_exc_error;
			   ELSE
			      RAISE fnd_api.g_exc_unexpected_error;
			   END IF;
			END IF;
		     END IF; -- l_delivery_id IS NOT NULL

		  END IF; -- bulk picking if

	       END IF; -- l_task_drop_loc_rec.consolidation_method_id = 1

	       IF(l_task_drop_loc_rec.consolidation_method_id = 2 OR
		  l_sug_lpn_id_table(l_task_count) IS NULL) THEN

		  --{{
		  -- If consolidation within deliveyr or MDC API does not return anything
		  -- fall back to what we have in 11.5.9
		  -- The latter case could happen to drop to WIP. i.e. no delivery for this task
		  -- wms_op_dest_sys_apis.Get_Staging_Loc_For_Delivery should resort to original suggestion.
		  --}}
		  wms_op_dest_sys_apis.Get_Staging_Loc_For_Delivery
		    (x_return_status => l_return_status,
		     x_message => l_message,
		     x_locator_id => l_sug_dest_loc_id_table(l_task_count),
		     x_zone_id => l_sug_dest_zone_id_table(l_task_count),
		     x_subinventory_code => l_sug_dest_sub_table(l_task_count),
		     p_call_mode => 1,  -- locator selection
		     p_task_type => g_wms_task_type_pick,  -- picking
		     p_task_id => l_task_drop_loc_rec.transaction_temp_id,
		     p_locator_id => NULL);

		  IF l_return_status <> g_ret_sts_success THEN
		     IF l_return_status = 'W' THEN
			x_return_status := l_return_status;
			x_message := l_message;
		      ELSE
			RAISE fnd_api.g_exc_error;
		     END IF;

		  END IF;

	       END IF;

	       l_progress := '80';

	     ELSE

	       IF (l_debug = 1) THEN
   		  print_debug('Invalid loc_selection_api_id : '|| l_task_drop_loc_rec.dest_loc_sel_api_id ||'for operation_plan_id : '||l_operation_sequence_id||' and operation_sequence :'||l_operation_sequence_id, 4);
	       END IF;


	       l_sug_dest_sub_table(l_task_count) := l_task_drop_loc_rec.pick_release_subinventory;
	       l_sug_dest_loc_id_table(l_task_count) := l_task_drop_loc_rec.pick_release_locator_id;
	    END IF;


	  ELSIF l_task_drop_loc_rec.dest_loc_sel_criteria = g_op_dest_pre_specified THEN
	    IF (l_debug = 1) THEN
   	       print_debug('Return locator as pre-specified by user.', 4);
	    END IF;

	    l_sug_dest_sub_table(l_task_count) := l_task_drop_loc_rec.pick_release_subinventory;
	    l_sug_dest_loc_id_table(l_task_count) := l_task_drop_loc_rec.pick_release_locator_id;
	  ELSIF l_task_drop_loc_rec.dest_loc_sel_criteria = g_op_dest_rules_engine THEN
	    IF (l_debug = 1) THEN
   	       print_debug('Return locator as suggested by rules engine.', 4);
	    END IF;

	    l_sug_dest_sub_table(l_task_count) := l_task_drop_loc_rec.pick_release_subinventory;
	    l_sug_dest_loc_id_table(l_task_count) := l_task_drop_loc_rec.pick_release_locator_id;
	  ELSE
	    IF (l_debug = 1) THEN
   	       print_debug('Invalid loc_selection_criteria : '|| l_task_drop_loc_rec.dest_loc_sel_criteria ||'for operation_plan_id : '||l_operation_sequence_id||' and operation_sequence :'||l_operation_sequence_id, 4);
	    END IF;

	    l_sug_dest_sub_table(l_task_count) := l_task_drop_loc_rec.pick_release_subinventory;
	    l_sug_dest_loc_id_table(l_task_count) := l_task_drop_loc_rec.pick_release_locator_id;

	 END IF;

      END IF;


      l_task_count := l_task_count + 1;

   END LOOP;

   -- In release I, tasks in one LPN have the same operation_plan_ID,
   -- therefore use the drop_lpn_option of the last task for the LPN.

   x_drop_lpn_option := Nvl(l_task_drop_loc_rec.drop_lpn_option, g_op_drop_lpn_optional);
   IF (l_debug = 1) THEN
      print_debug('drop_lpn_option : ' || x_drop_lpn_option, 4);
   END IF;

   l_progress := '90';

   CLOSE l_task_drop_loc_cur;

   l_progress := '100';

   -- bulk update MMTT with new subinventory and locator
   forall i IN 1..l_temp_id_table.COUNT
     UPDATE mtl_material_transactions_temp
     SET transfer_subinventory = l_sug_dest_sub_table(i),
     transfer_to_location = l_sug_dest_loc_id_table(i)
     --cartonization_id = l_sug_lpn_id_table(i) -- xdock MDC
     -- mrana:bug5257431: the above update should not be committed
     -- before the task is confirmed. If the drop is cancelled, we would
     -- like to retain the original cartonization id
     WHERE transaction_temp_id = l_temp_id_table(i);

   l_progress := '105';

   -- bulk update WDT with original subinventory and locator
   -- Bug 4884372: moved WDT update to before the COMMIT
   forall i IN 1..l_temp_id_table.COUNT
     UPDATE wms_dispatched_tasks
     SET suggested_dest_subinventory = l_pick_rel_sub_table(i),
     suggested_dest_locator_id = l_pick_rel_loc_id_table(i)
     WHERE transaction_temp_id = l_temp_id_table(i)
     AND task_type IN (g_wms_task_type_pick, g_wms_task_type_stg_move);

   --- bug fix 4017457  GXIAO 11/17/2004
   --- need to commit after updating MMTT
   IF (WMS_UI_TASKS_APIS.g_wms_patch_level >= WMS_UI_TASKS_APIS.g_patchset_j) THEN
      COMMIT;
   END IF;

   l_progress := '110';

   -- mrana:bug5257431: Bulk update MMTT with suggested MDC LPN
   forall i IN 1..l_temp_id_table.COUNT
     UPDATE mtl_material_transactions_temp
     SET cartonization_id = l_sug_lpn_id_table(i) -- MDC
     WHERE transaction_temp_id = l_temp_id_table(i);

   l_progress := '120';

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_drop_loc_sp;

      x_return_status := g_ret_sts_error;
      IF l_task_drop_loc_cur%isopen THEN
	 CLOSE l_task_drop_loc_cur;
      END IF;


   WHEN OTHERS THEN
      ROLLBACK TO update_drop_loc_sp;

      IF (l_debug = 1) THEN
   	 print_debug('Other exception in update_drop_locator_for_task '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS')|| '  after where l_progress = ' || l_progress, 1);
      END IF;


      x_return_status := g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
	 IF (l_debug = 1) THEN
   	    print_debug(' With SQL error: ' || SQLERRM(SQLCODE), 1);
	 END IF;

      END IF;

      IF l_task_drop_loc_cur%isopen THEN
	 CLOSE l_task_drop_loc_cur;
      END IF;



END update_drop_locator_for_task;


PROCEDURE validate_pick_drop_Locator
  (
   X_Return_status          OUT nocopy VARCHAR2,
   X_Message                OUT nocopy VARCHAR2,
   P_Task_Type              IN  NUMBER,
   P_Task_ID                IN  NUMBER,
   P_Locator_Id             IN  NUMBER
   )
  IS
     CURSOR l_task_drop_loc_cur
       (v_operation_sequence_id NUMBER)IS
	  SELECT mmtt.transaction_temp_id transaction_temp_id,
	    mmtt.transfer_subinventory pick_release_subinventory,
	    mmtt.transfer_to_location pick_release_locator_id,
	    op.operation_plan_id operation_plan_id,
	    Nvl(op.loc_selection_criteria, g_op_dest_sys_suggested) dest_loc_sel_criteria,
	    op.loc_selection_api_id dest_loc_sel_api_id,
	    Nvl(op.drop_lpn_option, g_op_drop_lpn_optional) drop_lpn_option,
	    Nvl(consolidation_method_id, 2) consolidation_method_id
	    FROM mtl_material_transactions_temp mmtt,
	    (SELECT plan.operation_plan_id,
	     detail.loc_selection_criteria,
	     detail.loc_selection_api_id,
	     detail.drop_lpn_option,
	     detail.consolidation_method_id
	     FROM
	     wms_op_plans_b plan,
	     wms_op_plan_details detail
	     WHERE
	     plan.operation_plan_id = detail.operation_plan_id AND
	     detail.operation_sequence = v_operation_sequence_id
	     ) op
	    WHERE mmtt.transaction_temp_id = p_task_id AND
	    ((mmtt.transaction_source_type_id = g_sourcetype_salesorder
	      AND mmtt.transaction_action_id = g_action_stgxfr)
	     OR
	     (mmtt.transaction_source_type_id = g_sourcetype_intorder
	      AND mmtt.transaction_action_id = g_action_stgxfr)
	     OR
	     mmtt.wms_task_type = g_wms_task_type_stg_move
	     )AND
	    mmtt.operation_plan_id = op.operation_plan_id (+)
	    ;


     l_task_drop_loc_rec l_task_drop_loc_cur%ROWTYPE;

     l_operation_sequence_id NUMBER := 2;
     l_progress VARCHAR2(10);

     -- following three variables are dummy varaibles to hold output parameters
     -- for validation API
     l_subinventory_code VARCHAR2(30);
     l_zone_id NUMBER;
     l_locator_id NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('Enter validate_pick_drop_Locator', 1);
   END IF;

   IF (l_debug = 1) THEN
      print_debug('p_task_type : '|| p_task_type, 4);
      print_debug('p_task_id : '|| p_task_id, 4);
   END IF;


   l_progress := '10';

   x_return_status := g_ret_sts_success;

   fnd_message.clear;


   IF p_task_type NOT IN (g_wms_task_type_pick, g_wms_task_type_stg_move) THEN
      IF (l_debug = 1) THEN
   	 print_debug('validate_pick_drop_Locator: Task type not picking or staging move, do not need to validate locator.', 4);
      END IF;

      RETURN;
   END IF;

   l_progress := '20';

   OPEN l_task_drop_loc_cur(l_operation_sequence_id);

   l_progress := '23';

   FETCH l_task_drop_loc_cur INTO l_task_drop_loc_rec;

   IF l_task_drop_loc_cur%notfound THEN
      IF (l_debug = 1) THEN
   	 print_debug('validate_pick_drop_Locator: This is not a sales order staging transfer or a staging move, do not need to validate locator for consolidation.', 4);
      END IF;

      IF l_task_drop_loc_cur%isopen THEN
	 CLOSE l_task_drop_loc_cur;
      END IF;
      RETURN;
   END IF;

   IF l_task_drop_loc_rec.operation_plan_id IS NULL
     AND p_task_type <> g_wms_task_type_stg_move
     THEN
      IF (l_debug = 1) THEN
   	 print_debug('validate_pick_drop_Locator : This mmtt record does not have an operation_plan_id, do not need to validate locator for consolidation.', 4);
      END IF;

      IF l_task_drop_loc_cur%isopen THEN
	 CLOSE l_task_drop_loc_cur;
      END IF;
      RETURN;
   END IF;

   l_progress := '25';

   IF (l_debug = 1) THEN
      print_debug('validate_pick_drop_Locator : transaction_temp_id : '|| l_task_drop_loc_rec.transaction_temp_id, 4);
      print_debug('pick_release_subinventory : '|| l_task_drop_loc_rec.pick_release_subinventory, 4);
      print_debug('pick_release_locator_id : '|| l_task_drop_loc_rec.pick_release_locator_id, 4);
      print_debug('operation_plan_id : '|| l_task_drop_loc_rec.operation_plan_id, 4);
      print_debug('dest_loc_sel_criteria : '|| l_task_drop_loc_rec.dest_loc_sel_criteria, 4);
      print_debug('dest_loc_sel_api_id : '|| l_task_drop_loc_rec.dest_loc_sel_api_id, 4);
   END IF;

   IF p_task_type = g_wms_task_type_stg_move THEN

      --{{
      --  For staging move only do locator validation if consolidation within delivery
      --  validation will be at LPN level if consolidation across delivery.
      --}}

      IF(l_task_drop_loc_rec.consolidation_method_id = 2) THEN
	 IF (l_debug = 1) THEN
	    print_debug('validate_pick_drop_Locator : About to call wms_op_dest_sys_apis.Get_Staging_Loc_For_Delivery', 4);
	 END IF;

	 wms_op_dest_sys_apis.Get_Staging_Loc_For_Delivery
	   (x_return_status => x_return_status,
	    x_message => x_message,
	    x_locator_id => l_locator_id,
	    x_zone_id => l_zone_id,
	    x_subinventory_code => l_subinventory_code,
	    p_call_mode => 2,  -- locator validate
	    p_task_type => p_task_type,
	    p_task_id => p_task_id,
	    p_locator_id => p_locator_id);


	 IF (l_debug = 1) THEN
	    print_debug('Back to validate_pick_drop_Locator.', 4);
	    print_debug('x_return_status = '||x_return_status, 4);
	    print_debug('x_message = '||x_message, 4);
	 END IF;

      END IF;

    ELSE


      IF l_task_drop_loc_rec.dest_loc_sel_criteria = g_op_dest_sys_suggested THEN
	 l_progress := '30';
	 IF (l_debug = 1) THEN
   	    print_debug('Return locator as system suggested, do not need to validate locator.', 4);
	 END IF;


       ELSIF l_task_drop_loc_rec.dest_loc_sel_criteria = g_op_dest_api THEN
	 IF (l_debug = 1) THEN
   	    print_debug('Return locator suggested by API.', 4);
	 END IF;

	 l_progress := '40';

	 IF l_task_drop_loc_rec.dest_loc_sel_api_id = 1 THEN
	    IF (l_debug = 1) THEN
   	       print_debug('validate_pick_drop_Locator - Calling WMS_OP_DEST_SYS_APIS.Get_CONS_Loc_For_Delivery. Leaving validate_pick_drop_Locator ... ', 4);
	    END IF;

	    l_progress := '50';

	    wms_op_dest_sys_apis.Get_CONS_Loc_For_Delivery
	      (x_return_status => x_return_status,
	       x_message => x_message,
	       x_locator_id => l_locator_id,
	       x_zone_id => l_zone_id,
	       x_subinventory_code => l_subinventory_code,
	       p_call_mode => 2,  -- locator validate
	       p_task_type => p_task_type,
	       p_task_id => p_task_id,
	       p_locator_id => p_locator_id);

	    IF (l_debug = 1) THEN
   	       print_debug('Back to update_drop_locator_for_task.', 4);
	       print_debug('x_return_status = '||x_return_status, 4);
   	       print_debug('x_message = '||x_message, 4);
	    END IF;



	  ELSIF l_task_drop_loc_rec.dest_loc_sel_api_id = 2 THEN
	    --{{
	    --  For staging move only do locator validation if consolidation within delivery
	    --  validation will be at LPN level if consolidation across delivery.
	    --}}

	    IF(l_task_drop_loc_rec.consolidation_method_id = 2) THEN
	       IF (l_debug = 1) THEN
		  print_debug('Calling WMS_OP_DEST_SYS_APIS.Get_Staging_Loc_For_Delivery. Leaving validate_pick_drop_Locator ... ', 4);
	       END IF;

	       l_progress := '70';

	       wms_op_dest_sys_apis.Get_Staging_Loc_For_Delivery
		 (x_return_status => x_return_status,
		  x_message => x_message,
		  x_locator_id => l_locator_id,
		  x_zone_id => l_zone_id,
		  x_subinventory_code => l_subinventory_code,
		  p_call_mode => 2,  -- locator validate
		  p_task_type => p_task_type,  -- picking
		  p_task_id => p_task_id,
		  p_locator_id => p_locator_id);


	       IF (l_debug = 1) THEN
		  print_debug('Back to update_drop_locator_for_task.', 4);
		  print_debug('x_return_status = '||x_return_status, 4);
		  print_debug('x_message = '||x_message, 4);
	       END IF;

	    END IF;



	  ELSE
	    IF (l_debug = 1) THEN
   	       print_debug('Invalid loc_selection_api_id : '|| l_task_drop_loc_rec.dest_loc_sel_api_id ||'for operation_plan_id : '||l_operation_sequence_id||' and operation_sequence :'||l_operation_sequence_id, 4);
	    END IF;

	    x_return_status := g_ret_sts_unexp_error;
	    x_message :=  fnd_message.get_string('INV', 'INV_INT_LOCCODE');

	 END IF;


       ELSIF l_task_drop_loc_rec.dest_loc_sel_criteria = g_op_dest_pre_specified THEN
	 IF (l_debug = 1) THEN
   	    print_debug('Return locator as pre-specified by user.  do not need to validate locator.', 4);
	 END IF;


       ELSIF l_task_drop_loc_rec.dest_loc_sel_criteria = g_op_dest_rules_engine THEN
	 IF (l_debug = 1) THEN
   	    print_debug('Return locator as suggested by rules engine.  do not need to validate locator.', 4);
	 END IF;


       ELSE
	 IF (l_debug = 1) THEN
   	    print_debug('Invalid loc_selection_criteria : '|| l_task_drop_loc_rec.dest_loc_sel_criteria ||'for operation_plan_id : '||l_operation_sequence_id||' and operation_sequence :'||l_operation_sequence_id, 4);
	 END IF;

	 x_return_status := g_ret_sts_unexp_error;
	 x_message :=  fnd_message.get_string('INV', 'INV_INT_LOCCODE');

      END IF;

   END IF;

   IF l_task_drop_loc_cur%isopen THEN
      CLOSE l_task_drop_loc_cur;
   END IF;


EXCEPTION

   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
   	 print_debug('Other exception in validate_pick_drop_Locator '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS')|| '  after where l_progress = ' || l_progress, 1);
      END IF;

      x_return_status := g_ret_sts_unexp_error;
      x_message :=  fnd_message.get_string('INV', 'INV_INT_LOCCODE');

      IF SQLCODE IS NOT NULL THEN
	 IF (l_debug = 1) THEN
   	    print_debug(' With SQL error: ' || SQLERRM(SQLCODE), 1);
	 END IF;


      END IF;


      IF l_task_drop_loc_cur%isopen THEN
	 CLOSE l_task_drop_loc_cur;
      END IF;


END validate_pick_drop_Locator;


END WMS_OP_RUNTIME_PUB_APIS;


/
