--------------------------------------------------------
--  DDL for Package Body WMS_OP_DEST_SYS_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_OP_DEST_SYS_APIS" AS
/* $Header: WMSOPDSB.pls 120.11.12010000.4 2010/01/20 06:00:44 avuppala ship $*/

--
-- File        : WMSOPDSB.pls
-- Content     : WMS_OP_DEST_SYS_APIS package body
-- Description : System seeded operation plan destination selection APIs.
-- Notes       :
-- Modified    : 10/01/2002 lezhang created


g_loc_type_packing_station NUMBER := inv_globals.g_loc_type_packing_station;
g_loc_type_storage_loc NUMBER := inv_globals.g_loc_type_storage_loc;
g_loc_type_consolidation NUMBER := inv_globals.g_loc_type_consolidation;
g_loc_type_staging_lane NUMBER := inv_globals.g_loc_type_staging_lane;
g_wms_task_type_pick NUMBER := wms_globals.g_wms_task_type_pick;
g_wms_task_type_stg_move NUMBER := wms_globals.g_wms_task_type_stg_move;

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
      p_module => 'WMS_OP_Dest_Sys_APIs',
      p_level => p_level);


--   dbms_output.put_line(p_err_msg);
END print_debug;


PROCEDURE create_pjm_locator(x_locator_id IN OUT nocopy NUMBER,
			     p_project_id IN NUMBER,
			     p_task_id IN NUMBER)
  IS
     PRAGMA AUTONOMOUS_TRANSACTION;

     l_locator_id NUMBER;
     l_locator_rec inv_validate.LOCATOR;
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     l_success NUMBER;
     l_organization_id     inv_validate.org;
     l_subinventory_code     inv_validate.sub;
BEGIN
   IF (l_debug = 1) THEN
      print_debug('Entering create_pjm_locator ', 1);
      print_debug('x_Locator_Id : '|| x_Locator_Id, 4);
      print_debug('p_project_id : '|| p_project_id, 4);
      print_debug('p_task_id : '|| p_task_id, 4);

   END IF;

   SELECT *
     INTO l_locator_rec
     FROM
     mtl_item_locations
     WHERE inventory_location_id = x_locator_id;

   IF l_locator_rec.project_id = p_project_id
     AND l_locator_rec.task_id = p_task_id THEN
      IF (l_debug = 1) THEN
	 print_debug('This locator itself is the logical locator for this project and task ', 4);
      END IF;

      RETURN;
   END IF;


   BEGIN
      SELECT inventory_location_id
	INTO l_locator_id
	FROM
	mtl_item_locations
	WHERE physical_location_id = x_locator_id
	AND project_id = p_project_id
	AND task_id = p_task_id
	AND ROWNUM < 2;
   EXCEPTION
      WHEN no_data_found THEN
	 l_locator_id := NULL;
   END;


   IF l_locator_id IS NOT NULL THEN
      IF (l_debug = 1) THEN
	 print_debug('Locator ID '|| l_locator_id ||  'is the logical locator for this project and task ', 4);
      END IF;

      x_locator_id := l_locator_id;

      RETURN;
   END IF;

   l_locator_rec.inventory_location_id  := NULL;
   l_locator_rec.physical_location_id   := x_locator_id;
   l_locator_rec.project_id             := p_project_id;
   l_locator_rec.task_id                := p_task_id;
   l_locator_rec.segment19              := p_project_id;
   l_locator_rec.segment20              := p_task_id;

   print_debug('Before calling inv_validate.validatelocator', 4);

   SELECT *
     INTO l_organization_id
     FROM mtl_parameters
     WHERE organization_id = l_locator_rec.organization_id;

   SELECT *
     INTO l_subinventory_code
     FROM mtl_secondary_inventories
     WHERE secondary_inventory_name = l_locator_rec.subinventory_code
     AND organization_id = l_locator_rec.organization_id;


   l_success := inv_validate.validatelocator
     (
      p_locator                    => l_locator_rec
      , p_org                        => l_organization_id
      , p_sub                        => l_subinventory_code
      , p_validation_mode            => inv_validate.exists_or_create
      , p_value_or_id                => 'I'
      );

   print_debug('After calling inv_validate.validatelocator', 4);

   COMMIT;

    IF (l_success = inv_validate.t
        AND fnd_flex_keyval.new_combination
	) THEN

       print_debug('Created new logical locator ' || l_locator_rec.inventory_location_id, 4);

       x_locator_id := l_locator_rec.inventory_location_id;

       RETURN;
    END IF;

EXCEPTION
   WHEN OTHERS THEN
      print_debug('Exception in create_pjm_locator.', 1);

END create_pjm_locator;


-- API name    : Get_CONS_Loc_For_Delivery
-- Type        : Public
-- Function    :
-- Pre-reqs    :
--
-- Parameters  :
--   Output:
--
--   X_Return_status  : API exeution status, differen meaning in different
--                      call mode
--              For locator selection:
--                     'S' : Locator successfully returned.
--                     'E' : Locator is not returned because of application
--                           error.
--                     'U' : Locator is not returned because of unexpected
--                           error.
--
--              For locator validation:
--                     'S' : Locator is valid according to API logic.
--                     'W' : Locator is not valid, and user will be prompt for a warning
--                     'E' : Locator is not valid, and user should not be allowed to continue.
--                     'U' : API execution encountered unexpected error.
--
--
--   X_Message        : Message corresponding to different statuses
--                      and different call mode
--              For locator selection:
--                     'S' : Message that needs to displayed before
--                           displaying the suggested locator.
--                     'E' : Reason why locator is not returned.
--                     'U' : Message for the unexpected error.
--
--              For locator validation:
--                     'S' : No message.
--                     'W' : Reason why locator is invalid.
--                     'E' : Reason why locator is invalid.
--                     'U' : Message for the unexpected error.
--
--
--   X_locator_ID     : Locator returned according to API loc,
--                      only apply to P_Call_Mode of locator selection.
--
--   X_Zone_ID        : Zone returned according to API loc,
--                      only apply to P_Call_Mode of locator selection.
--
--   X_Subinventory_Code : Subinventory code returned according to API loc
--                      only apply to P_Call_Mode of locator selection.
--
--
--   Input:
--
--   P_Call_Mode   : 1. Locator selection 2. Locator validation
--
--   P_Task_Type   : Refer to lookup type WMS_TASK_TYPES
--
--   P_Task_ID     : Primary key for the corresponding task type.
--                   e.g. transaction_temp_id in MMTT for picking task type.
--
--   P_Locator_Id  : The locator needs to be validated according to API logic,
--                   only apply to P_Call_Mode of locator validation,
--
--
-- Version
--   Currently version is 1.0
--



PROCEDURE Get_CONS_Loc_For_Delivery
  (
   X_Return_status          OUT nocopy VARCHAR2,
   X_Message                OUT nocopy VARCHAR2,
   X_locator_ID             OUT nocopy NUMBER,
   X_Zone_ID                OUT nocopy NUMBER,
   X_Subinventory_Code      OUT nocopy VARCHAR2,
   P_Call_Mode              IN  NUMBER DEFAULT NULL,
   P_Task_Type              IN  NUMBER DEFAULT NULL,
   P_Task_ID                IN  NUMBER DEFAULT NULL,
   P_Locator_Id             IN  NUMBER DEFAULT NULL
   )
  IS
     l_progress VARCHAR2(10);

     CURSOR l_current_task_curs
       IS
	  SELECT mol.carton_grouping_id,
	    wda.delivery_id,
	    mmtt.transaction_temp_id,
	    mmtt.operation_plan_id,
	    mil.project_id,
	    mil.task_id
	    FROM
	    mtl_material_transactions_temp mmtt,
	    mtl_txn_request_lines mol,
	    wsh_delivery_details wdd,
	    wsh_delivery_assignments_v wda,
	    mtl_item_locations mil
	    WHERE
	    mmtt.transaction_temp_id = p_task_id AND
	    mmtt.move_order_line_id = mol.line_id AND
	    mmtt.move_order_line_id = wdd.move_order_line_id AND
	    mmtt.transfer_to_location = mil.inventory_location_id AND
	    mmtt.transfer_organization = mil.organization_id AND
	    wdd.released_status = 'S' AND
	    wdd.delivery_detail_id = wda.delivery_detail_id (+) AND
            p_call_mode <> 3
	 UNION ALL
	  SELECT mol.carton_grouping_id,
	    wda.delivery_id,
	    mmtt.transaction_temp_id,
	    mmtt.operation_plan_id,
	    mil.project_id,
	    mil.task_id
	    FROM
	    mtl_material_transactions_temp mmtt,
	    mtl_material_transactions_temp pmmtt,
	    mtl_txn_request_lines mol,
	    wsh_delivery_details wdd,
	    wsh_delivery_assignments_v wda,
	    mtl_item_locations mil
	    WHERE
	    mmtt.transaction_temp_id = p_task_id AND
	    mmtt.move_order_line_id = mol.line_id AND
	    mmtt.move_order_line_id = wdd.move_order_line_id AND
	    pmmtt.locator_id = mil.inventory_location_id AND
	    pmmtt.organization_id = mil.organization_id AND
	    wdd.released_status = 'S' AND
	    wdd.delivery_detail_id = wda.delivery_detail_id (+) AND
	    pmmtt.transaction_temp_id = mmtt.parent_line_id AND
            p_call_mode = 3
	    ;

     CURSOR l_loc_with_same_del_curs
       (v_delivery_id NUMBER, v_operation_plan_id NUMBER)
       IS
	  SELECT wdd.subinventory del_subinventory,
	    wdd.locator_id del_locator_id,
	    nvl(mil.inventory_location_type, 3) del_locator_type,
	    wdth.creation_date
	    FROM wsh_delivery_details wdd,
	    wsh_delivery_assignments_v wda,
	    mtl_item_locations mil,
            mtl_secondary_inventories msi,
	    wms_dispatched_tasks_history wdth
	    WHERE wda.delivery_detail_id = wdd.delivery_detail_id AND
	    wdd.released_status = 'Y' AND
	    wdd.locator_id = mil.inventory_location_id AND
	    nvl(mil.inventory_location_type, 3) = G_LOC_TYPE_CONSOLIDATION AND
            nvl(mil.disable_date, trunc(sysdate+1)) > trunc(sysdate) AND
            msi.secondary_inventory_name = mil.subinventory_code AND
            msi.organization_id = mil.organization_id AND
            nvl(msi.disable_date, trunc(sysdate + 1)) > trunc(sysdate) AND
	    wdd.move_order_line_id = wdth.move_order_line_id AND
	    wdth.operation_plan_id = v_operation_plan_id AND
	    wda.delivery_id = v_delivery_id
	  UNION ALL -- bug 4017457
	  SELECT mmtt.transfer_subinventory del_subinventory,
	    mmtt.transfer_to_location del_locator_id,
	    Nvl(mil.inventory_location_type, 3) del_locator_type,
	    Sysdate creation_date
	    FROM mtl_material_transactions_temp mmtt,
	    wsh_delivery_details wdd,
	    wsh_delivery_assignments_v wda,
	    mtl_item_locations mil,
            mtl_secondary_inventories msi
	    WHERE mmtt.operation_plan_id = v_operation_plan_id AND
	    mmtt.move_order_line_id = wdd.move_order_line_id AND
	    wdd.delivery_detail_id = wda.delivery_detail_id AND
	    wdd.released_status = 'S' AND
	    wda.delivery_id = v_delivery_id AND
	    mmtt.transfer_to_location = mil.inventory_location_id AND
	    mmtt.transfer_organization = mil.organization_id AND
	    Nvl(mil.inventory_location_type, 3) = G_LOC_TYPE_CONSOLIDATION AND
            Nvl(mil.disable_date, trunc(sysdate+1)) > trunc(sysdate) AND
            msi.secondary_inventory_name = mil.subinventory_code AND
            msi.organization_id = mil.organization_id AND
            nvl(msi.disable_date, trunc(sysdate + 1)) > trunc(sysdate) AND
	    mmtt.transfer_to_location IS NOT NULL AND
	    mmtt.transfer_subinventory IS NOT NULL AND
	    p_call_mode <> 3
	  UNION ALL -- bug 4017457
	  SELECT pmmtt.subinventory_code del_subinventory,
	    pmmtt.locator_id del_locator_id,
	    Nvl(mil.inventory_location_type, 3) del_locator_type,
	    Sysdate creation_date
	    FROM mtl_material_transactions_temp mmtt,
	    mtl_material_transactions_temp pmmtt,
	    wsh_delivery_details wdd,
	    wsh_delivery_assignments_v wda,
	    mtl_item_locations mil,
            mtl_secondary_inventories msi
	    WHERE mmtt.operation_plan_id = v_operation_plan_id AND
	    mmtt.move_order_line_id = wdd.move_order_line_id AND
	    wdd.delivery_detail_id = wda.delivery_detail_id AND
	    wdd.released_status = 'S' AND
	    wda.delivery_id = v_delivery_id AND
	    pmmtt.locator_id = mil.inventory_location_id AND
	    pmmtt.organization_id = mil.organization_id AND
	    Nvl(mil.inventory_location_type, 3) = G_LOC_TYPE_CONSOLIDATION AND
            Nvl(mil.disable_date, trunc(sysdate+1)) > trunc(sysdate) AND
            msi.secondary_inventory_name = mil.subinventory_code AND
            msi.organization_id = mil.organization_id AND
            nvl(msi.disable_date, trunc(sysdate + 1)) > trunc(sysdate) AND
	    pmmtt.locator_id IS NOT NULL AND
	    pmmtt.subinventory_code IS NOT NULL AND
	    pmmtt.transaction_temp_id = mmtt.parent_line_id AND
	    p_call_mode = 3
	    ORDER BY 4 DESC
	    ;

     CURSOR l_loc_with_same_carton_group
       (v_carton_grouping_id NUMBER, v_operation_plan_id NUMBER)
       IS
	  SELECT wdd.subinventory mol_subinventory,
	    wdd.locator_id mol_locator_id,
	    nvl(mil.inventory_location_type, 3) mol_locator_type,
	    wdth.creation_date
	    FROM wsh_delivery_details wdd,
	    wsh_delivery_assignments_v wda,
	    mtl_txn_request_lines mol,
	    mtl_item_locations mil,
            mtl_secondary_inventories msi,
	    wms_dispatched_tasks_history wdth
	    WHERE
	    mol.line_id = wdd.move_order_line_id AND
	    wdd.released_status = 'Y' AND
	    wdd.locator_id = mil.inventory_location_id AND
	    wda.delivery_detail_id = wdd.delivery_detail_id AND
	    wda.delivery_id IS NULL AND  -- bug 2768678
	    nvl(mil.inventory_location_type, 3) = G_LOC_TYPE_CONSOLIDATION AND
            nvl(mil.disable_date, trunc(sysdate+1)) > trunc(sysdate) AND
            msi.secondary_inventory_name = mil.subinventory_code AND
            msi.organization_id = mil.organization_id AND
            nvl(msi.disable_date, trunc(sysdate + 1)) > trunc(sysdate) AND
	    wdd.move_order_line_id = wdth.move_order_line_id AND
	    wdth.operation_plan_id = v_operation_plan_id AND
	    mol.carton_grouping_id = v_carton_grouping_id
	  UNION ALL -- bug 4017457
	  SELECT mmtt.transfer_subinventory mol_subinventory,
	      mmtt.transfer_to_location mol_locator_id,
	      Nvl(mil.inventory_location_type, 3) mol_locator_type,
	      Sysdate creation_date
	    FROM mtl_material_transactions_temp mmtt,
	    mtl_txn_request_lines mol,
	    wsh_delivery_details wdd,
	    wsh_delivery_assignments_v wda,
	    mtl_item_locations mil,
            mtl_secondary_inventories msi
	    WHERE mmtt.operation_plan_id = v_operation_plan_id AND
	    mmtt.move_order_line_id = mol.line_id AND
	    mol.carton_grouping_id = v_carton_grouping_id AND
	    mmtt.move_order_line_id = wdd.move_order_line_id AND
	    wdd.delivery_detail_id = wda.delivery_detail_id AND
	    wda.delivery_id IS NULL AND
	    wdd.released_status = 'S' AND
	    mmtt.transfer_to_location = mil.inventory_location_id AND
	    mmtt.transfer_organization = mil.organization_id AND
	    Nvl(mil.inventory_location_type, 3) = G_LOC_TYPE_CONSOLIDATION AND
            Nvl(mil.disable_date, trunc(sysdate+1)) > trunc(sysdate) AND
            msi.secondary_inventory_name = mil.subinventory_code AND
            msi.organization_id = mil.organization_id AND
            Nvl(msi.disable_date, trunc(sysdate + 1)) > trunc(sysdate) AND
	    mmtt.transfer_to_location IS NOT NULL AND
	    mmtt.transfer_subinventory IS NOT NULL AND
            p_call_mode <> 3
	  UNION ALL -- bug 4017457
	  SELECT pmmtt.subinventory_code mol_subinventory,
	      pmmtt.locator_id mol_locator_id,
	      Nvl(mil.inventory_location_type, 3) mol_locator_type,
	      Sysdate creation_date
	    FROM mtl_material_transactions_temp mmtt,
	    mtl_material_transactions_temp pmmtt,
	    mtl_txn_request_lines mol,
	    wsh_delivery_details wdd,
	    wsh_delivery_assignments_v wda,
	    mtl_item_locations mil,
            mtl_secondary_inventories msi
	    WHERE mmtt.operation_plan_id = v_operation_plan_id AND
	    mmtt.move_order_line_id = mol.line_id AND
	    mol.carton_grouping_id = v_carton_grouping_id AND
	    mmtt.move_order_line_id = wdd.move_order_line_id AND
	    wdd.delivery_detail_id = wda.delivery_detail_id AND
	    wda.delivery_id IS NULL AND
	    wdd.released_status = 'S' AND
	    pmmtt.locator_id = mil.inventory_location_id AND
	    pmmtt.organization_id = mil.organization_id AND
	    Nvl(mil.inventory_location_type, 3) = G_LOC_TYPE_CONSOLIDATION AND
            Nvl(mil.disable_date, trunc(sysdate+1)) > trunc(sysdate) AND
            msi.secondary_inventory_name = mil.subinventory_code AND
            msi.organization_id = mil.organization_id AND
            Nvl(msi.disable_date, trunc(sysdate + 1)) > trunc(sysdate) AND
	    pmmtt.locator_id IS NOT NULL AND
	    pmmtt.subinventory_code IS NOT NULL AND
	    pmmtt.transaction_temp_id = mmtt.parent_line_id AND
            p_call_mode = 3
	    ORDER BY 4 DESC
	    ;


     l_current_task_rec l_current_task_curs%ROWTYPE;

     l_loc_del_rec l_loc_with_same_del_curs%ROWTYPE;

     l_loc_mol_rec l_loc_with_same_carton_group%ROWTYPE;


     CURSOR l_empty_CONS_loc IS
       SELECT mil.inventory_location_id locator_id,
	 mil.subinventory_code subinventory_code,
	 mil.dropping_order,
	 mil.picking_order
	 FROM mtl_item_locations mil,
         mtl_secondary_inventories msi,
	 mtl_material_transactions_temp mmtt,wsh_delivery_details wdd1
	 WHERE mmtt.transaction_temp_id = p_task_id
	 AND mil.subinventory_code = mmtt.transfer_subinventory
	 AND mil.organization_id = mmtt.organization_id
	 AND nvl(mil.inventory_location_type, 3)= G_LOC_TYPE_CONSOLIDATION -- consolidation locator
         AND nvl(mil.disable_date, trunc(sysdate+1)) > trunc(sysdate)
         AND Nvl(mil.empty_flag, 'Y') = 'Y'
         AND msi.secondary_inventory_name = mil.subinventory_code
         AND msi.organization_id = mil.organization_id
         AND nvl(msi.disable_date, trunc(sysdate + 1)) > trunc(sysdate)
	 AND (wdd1.project_id is NOT NULL or (wdd1.project_id IS NULL AND
	 (mil.inventory_location_id=mil.physical_location_id or  mil.physical_location_id is NULL))) --bug 8657987
	 -- bug 4017457
	 AND NOT exists (SELECT 1
			 FROM mtl_material_transactions_temp mmtt2,
			 wsh_delivery_details wdd
			 WHERE mmtt2.move_order_line_id = wdd.move_order_line_id AND
			 wdd.released_status = 'S' AND
			 mmtt2.transfer_organization = mil.organization_id  AND
			 mmtt2.transfer_subinventory = mil.subinventory_code AND
			 mmtt2.transfer_to_location = mil.inventory_location_id)
	 AND NOT exists (SELECT 1
			 FROM mtl_material_transactions_temp mmtt3,
			 mtl_material_transactions_temp pmmtt2,
			 wsh_delivery_details wdd
			 WHERE mmtt3.move_order_line_id = wdd.move_order_line_id AND
			 wdd.released_status = 'S' AND
			 pmmtt2.transaction_temp_id = mmtt3.parent_line_id AND
			 pmmtt2.organization_id = mil.organization_id  AND
			 pmmtt2.subinventory_code = mil.subinventory_code AND
			 pmmtt2.locator_id = mil.inventory_location_id)
	 AND p_call_mode <> 3
       UNION ALL
       SELECT mil.inventory_location_id locator_id,
	 mil.subinventory_code subinventory_code,
	 mil.dropping_order,
	 mil.picking_order
	 FROM mtl_item_locations mil,
         mtl_secondary_inventories msi,
	 mtl_material_transactions_temp mmtt,
	 mtl_material_transactions_temp pmmtt
	 WHERE mmtt.transaction_temp_id = p_task_id
	 AND mil.subinventory_code = pmmtt.subinventory_code
	 AND mil.organization_id = mmtt.organization_id
	 AND nvl(mil.inventory_location_type, 3)= G_LOC_TYPE_CONSOLIDATION -- consolidation locator
         AND nvl(mil.disable_date, trunc(sysdate+1)) > trunc(sysdate)
         AND Nvl(mil.empty_flag, 'Y') = 'Y'
         AND msi.secondary_inventory_name = mil.subinventory_code
         AND msi.organization_id = mil.organization_id
         AND nvl(msi.disable_date, trunc(sysdate + 1)) > trunc(sysdate)
	 AND pmmtt.transaction_temp_id = mmtt.parent_line_id
	 -- bug 4017457
	 AND NOT exists (SELECT 1
			 FROM mtl_material_transactions_temp mmtt2,
			 wsh_delivery_details wdd
			 WHERE mmtt2.move_order_line_id = wdd.move_order_line_id AND
			 wdd.released_status = 'S' AND
			 mmtt2.transfer_organization = mil.organization_id  AND
			 mmtt2.transfer_subinventory = mil.subinventory_code AND
			 mmtt2.transfer_to_location = mil.inventory_location_id)
	 AND NOT exists (SELECT 1
			 FROM mtl_material_transactions_temp mmtt3,
			 mtl_material_transactions_temp pmmtt2,
			 wsh_delivery_details wdd
			 WHERE mmtt3.move_order_line_id = wdd.move_order_line_id AND
			 wdd.released_status = 'S' AND
			 pmmtt2.transaction_temp_id = mmtt3.parent_line_id AND
			 pmmtt2.organization_id = mil.organization_id  AND
			 pmmtt2.subinventory_code = mil.subinventory_code AND
			 pmmtt2.locator_id = mil.inventory_location_id)
	 AND p_call_mode = 3
	 ORDER BY 3,4;

     l_empty_CONS_loc_rec l_empty_CONS_loc%ROWTYPE;
     l_empty_CONS_loc_count NUMBER := 0;

     l_cons_loc_exists_flag NUMBER;
     l_pick_release_subinventory VARCHAR2(30);
     l_pick_release_locator_id NUMBER;
     l_validate_loc_type NUMBER;
     l_validate_loc_subinventory VARCHAR2(30);
     l_validate_loc_empty_flag VARCHAR2(1);

     l_loc_disable_date DATE;
     l_sub_disable_date DATE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := G_RET_STS_SUCCESS;
   l_progress := '10';

   IF (l_debug = 1) THEN
      print_debug('Enter Get_CONS_Loc_For_Delivery '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
   END IF;


   IF (l_debug = 1) THEN
         print_debug('P_Call_Mode : '|| P_Call_Mode, 4);
         print_debug('P_Task_Type : '|| P_Task_Type, 4);
         print_debug('P_Task_ID : '|| P_Task_ID, 4);
         print_debug('P_Locator_Id : '|| P_Locator_Id, 4);
   END IF;



   -- Input parameter validation

   IF p_call_mode in (1,3) THEN -- locator selection
      IF p_task_type IS NULL OR p_task_id IS NULL THEN
	 x_return_status := g_ret_sts_unexp_error;
	 IF (l_debug = 1) THEN
   	    print_debug('Invalid input: For locator selection p_task_type and p_task_id cannot be NULL.', 4);
	 END IF;

	 RETURN;
      END IF;

    ELSIF p_call_mode = 2 THEN -- locator validation
      IF p_task_type IS NULL OR
	p_task_id IS NULL OR
	  p_locator_id IS NULL THEN
	 x_return_status := g_ret_sts_unexp_error;
	 IF (l_debug = 1) THEN
   	    print_debug('Invalid input: For locator selection p_locator_id, p_task_type and p_task_id cannot be NULL.', 4);
	 END IF;
	 RETURN;

      END IF;

    ELSE -- invalid p_call_mode

      x_return_status := g_ret_sts_unexp_error;
      IF (l_debug = 1) THEN
   	 print_debug('Invalid input: P_Call_Mode should be 1,2 or 3.', 4);
      END IF;

      RETURN;

   END IF;

     /*Bug#9167904 starts*/
     l_progress := '15';
     BEGIN
        SELECT 1
          INTO l_cons_loc_exists_flag
        FROM mtl_item_locations mil,
                mtl_material_transactions_temp mmtt
        WHERE mmtt.transaction_temp_id = p_task_id
          AND mil.organization_id = mmtt.organization_id
          AND nvl(mil.inventory_location_type, 3)= G_LOC_TYPE_CONSOLIDATION -- consolidation locator
          AND nvl(mil.disable_date, trunc(sysdate + 1)) > trunc(sysdate) ;
        l_progress := '16';
     EXCEPTION
        WHEN too_many_rows THEN
              l_cons_loc_exists_flag := 1;
        WHEN no_data_found THEN
              l_cons_loc_exists_flag := 0;
     END;
     IF (l_debug = 1) THEN
        print_debug('Is cons locator defined for org ? (1=yes) :'||l_cons_loc_exists_flag, 4);
     END IF;
     /*Bug#9167904 ends*/



   l_progress := '20';

   IF p_task_type IN (g_wms_task_type_pick, g_wms_task_type_stg_move) THEN  -- picking or staging move

     IF ( l_cons_loc_exists_flag > 0 ) THEN  --Do the following only if there exists atlest one conslocator (9167904)

      -- Get a consolidation locator where same delivery (or carton_grouping_ID) with the same operation plan ID has been dropped to
      OPEN l_current_task_curs;

      l_progress := '30';

      LOOP
	 -- this loop will only return one record, hense no performance concern
	 -- still used loop to conform to the standard way cursor is handled

	 FETCH l_current_task_curs INTO l_current_task_rec;
	 EXIT WHEN l_current_task_curs%notfound;

	 l_progress := '40';


	 IF (l_debug = 1) THEN
   	    print_debug('Searching consolidation locators for this tasks whose ', 4);
   	    print_debug('transaction_temp_id  : ' ||l_current_task_rec.transaction_temp_id, 4);
   	    print_debug('with operation_plan_id : '||l_current_task_rec.operation_plan_id, 4);
   	    print_debug('and delivery ID: ' || l_current_task_rec.delivery_id, 4);
   	    print_debug('or carton_grouping_ID: ' || l_current_task_rec.carton_grouping_ID, 4);
	 END IF;


	 IF l_current_task_rec.delivery_id IS NOT NULL THEN

	    IF (l_debug = 1) THEN
   	       print_debug('Look for locator with same delivery.', 4);
	    END IF;


	    OPEN l_loc_with_same_del_curs
	      (l_current_task_rec.delivery_id,
	       l_current_task_rec.operation_plan_id);

	    LOOP
	       FETCH l_loc_with_same_del_curs INTO l_loc_del_rec;
	       EXIT WHEN l_loc_with_same_del_curs%notfound;

	       l_progress := '50';

	       IF p_call_mode IN (1,3) THEN --suggestion
		  IF (l_debug = 1) THEN
   		     print_debug('Found one consolidation locator for the same delivery:', 4);
   		     print_debug('subinventory : ' || l_loc_del_rec.del_subinventory, 4);
   		     print_debug('locator ID : ' || l_loc_del_rec.del_locator_id, 4);
		  END IF;

		  x_zone_id := NULL;
		  x_subinventory_code := l_loc_del_rec.del_subinventory;
		  x_locator_id := l_loc_del_rec.del_locator_id;

		  IF l_current_task_rec.project_id IS NOT NULL THEN
		     create_pjm_locator(x_locator_id => x_locator_id,
					p_project_id => l_current_task_rec.project_id,
					p_task_id => l_current_task_rec.task_id);
		  END IF;

		  IF l_current_task_curs%isopen THEN
		     CLOSE l_current_task_curs;
		  END IF;

		  IF l_loc_with_same_del_curs%isopen THEN
		     CLOSE l_loc_with_same_del_curs;
		  END IF;

		  RETURN;

		ELSIF p_call_mode = 2 THEN -- validation
		  IF l_loc_del_rec.del_locator_id = p_locator_id THEN
		     IF (l_debug = 1) THEN
   			print_debug('This is a valid consolidation locator with the same delivery.', 4);
		     END IF;


		     IF l_current_task_curs%isopen THEN
			CLOSE l_current_task_curs;
		     END IF;

		     IF l_loc_with_same_del_curs%isopen THEN
			CLOSE l_loc_with_same_del_curs;
		     END IF;

		     RETURN;
		  END IF;

	       END IF;


	    END LOOP;  -- end l_loc_with_same_del_curs cursor loop


	    CLOSE l_loc_with_same_del_curs;

	  ELSIF l_current_task_rec.carton_grouping_id IS NOT NULL THEN

		  OPEN l_loc_with_same_carton_group
		    (l_current_task_rec.carton_grouping_ID,
		     l_current_task_rec.operation_plan_id);

		  LOOP
		     FETCH l_loc_with_same_carton_group INTO l_loc_mol_rec;
		     EXIT WHEN l_loc_with_same_carton_group%notfound;

		     l_progress := '60';

		     IF p_call_mode IN (1,3) THEN --suggestion

			IF (l_debug = 1) THEN
   			   print_debug('Found one consolidation locator for the same carton_grouping_ID:', 4);
   			   print_debug('subinventory : ' || l_loc_mol_rec.mol_subinventory, 4);
   			   print_debug('locator ID : ' || l_loc_mol_rec.mol_locator_id, 4);
			END IF;


			x_zone_id := NULL;
			x_subinventory_code := l_loc_mol_rec.mol_subinventory;
			x_locator_id := l_loc_mol_rec.mol_locator_id;

			IF l_current_task_rec.project_id IS NOT NULL THEN
			   create_pjm_locator(x_locator_id => x_locator_id,
					      p_project_id => l_current_task_rec.project_id,
					      p_task_id => l_current_task_rec.task_id);
			END IF;

			IF l_current_task_curs%isopen THEN
			   CLOSE l_current_task_curs;
			END IF;

			IF l_loc_with_same_carton_group%isopen THEN
			   CLOSE l_loc_with_same_carton_group;
			END IF;

			RETURN;

		      ELSIF p_call_mode = 2 THEN -- validation
			IF l_loc_mol_rec.mol_locator_id = p_locator_id THEN
			   IF (l_debug = 1) THEN
   			      print_debug('This is a valid consolidation locator with the carton_grouping_ID.', 4);
			   END IF;


			   IF l_current_task_curs%isopen THEN
			      CLOSE l_current_task_curs;
			   END IF;

			   IF l_loc_with_same_carton_group%isopen THEN
			      CLOSE l_loc_with_same_carton_group;
			   END IF;

			   RETURN;
			END IF;
		     END IF;

		  END LOOP;  -- end l_loc_with_same_carton_group cursor loop

		  CLOSE l_loc_with_same_carton_group;

	 END IF;


      END LOOP;   -- end l_current_task_curs cursor loop


      l_progress := '70';

      CLOSE l_current_task_curs;

      -- Get empty consolidation locator within the pick release subinventory

      IF (l_debug = 1) THEN
   	 print_debug('Searching for empty consolidation locator in staging subinventory for task ', 4);
   	 print_debug('with transaction_temp_id : ' || p_task_id, 4);
      END IF;


      OPEN l_empty_CONS_loc;

      l_progress := '80';

      LOOP
	 FETCH l_empty_CONS_loc INTO l_empty_CONS_loc_rec;
	 EXIT WHEN l_empty_CONS_loc%notfound;

	 l_progress := '90';

	 IF p_call_mode IN (1,3) THEN --suggestion

	    IF (l_debug = 1) THEN
   	       print_debug('Found one empty consolidation locator:', 4);
   	       print_debug('subinventory : ' || l_empty_CONS_loc_rec.subinventory_code, 4);
   	       print_debug('locator ID : ' || l_empty_CONS_loc_rec.locator_id, 4);
	    END IF;


	    x_zone_id := NULL;
	    x_subinventory_code := l_empty_CONS_loc_rec.subinventory_code;
	    x_locator_id := l_empty_CONS_loc_rec.locator_id;

	    IF l_current_task_rec.project_id IS NOT NULL THEN
	       create_pjm_locator(x_locator_id => x_locator_id,
				  p_project_id => l_current_task_rec.project_id,
				  p_task_id => l_current_task_rec.task_id);
	    END IF;

	    CLOSE l_empty_CONS_loc;
	    RETURN;

	  ELSIF p_call_mode = 2 THEN -- validation
	    IF l_empty_CONS_loc_rec.locator_id = p_locator_id THEN
	       IF (l_debug = 1) THEN
   		  print_debug('This is a valid empty consolidation locator within the pick release subinventory.', 4);
	       END IF;

	       CLOSE l_empty_CONS_loc;
	       RETURN;
	    END IF;

	    l_empty_cons_loc_count := l_empty_cons_loc_count + 1;
	 END IF;


      END LOOP;

      CLOSE l_empty_CONS_loc;

       END IF; --End of l_cons_loc_exists_flag -- Added for Bug 9167904

      l_progress := '100';


      -- Return pick release locator and display proper message (No consolidation or consolidation full)
      SELECT
	mmtt.transfer_subinventory,
	mmtt.transfer_to_location
	INTO
	l_pick_release_subinventory,
	l_pick_release_locator_id
	FROM
	mtl_material_transactions_temp mmtt
	WHERE mmtt.transaction_temp_id = p_task_id;

      l_progress := '110';

      BEGIN
	 IF (p_call_mode <> 3) THEN
	    SELECT 1
	      INTO l_cons_loc_exists_flag
	      FROM mtl_item_locations mil,
	      mtl_secondary_inventories msi,
	      mtl_material_transactions_temp mmtt
	      WHERE mmtt.transaction_temp_id = p_task_id
	      AND mil.subinventory_code = mmtt.transfer_subinventory
	      AND mil.organization_id = mmtt.organization_id
	      AND nvl(inventory_location_type, 3)= G_LOC_TYPE_CONSOLIDATION -- consolidation locator
	      AND nvl(mil.disable_date, trunc(sysdate+1)) > trunc(sysdate)
	      AND msi.secondary_inventory_name = mil.subinventory_code
	      AND msi.organization_id = mil.organization_id
	      AND nvl(msi.disable_date, trunc(sysdate + 1)) > trunc(sysdate)
	      ;
	  ELSE
	    SELECT 1
	      INTO l_cons_loc_exists_flag
	      FROM mtl_item_locations mil,
	      mtl_secondary_inventories msi,
	      mtl_material_transactions_temp mmtt,
	      mtl_material_transactions_temp pmmtt
	      WHERE mmtt.transaction_temp_id = p_task_id
	      AND pmmtt.transaction_temp_id = mmtt.parent_line_id
	      AND mil.subinventory_code = pmmtt.subinventory_code
	      AND mil.organization_id = mmtt.organization_id
	      AND nvl(inventory_location_type, 3)= G_LOC_TYPE_CONSOLIDATION -- consolidation locator
	      AND nvl(mil.disable_date, trunc(sysdate+1)) > trunc(sysdate)
	      AND msi.secondary_inventory_name = mil.subinventory_code
	      AND msi.organization_id = mil.organization_id
	      AND nvl(msi.disable_date, trunc(sysdate + 1)) > trunc(sysdate)
	      ;
	 END IF;
      EXCEPTION
	 WHEN too_many_rows THEN
	    l_cons_loc_exists_flag := 1;
	 WHEN no_data_found THEN
	    l_cons_loc_exists_flag := 0;
      END;

      l_progress := '120';


      IF p_call_mode IN (1,3) THEN -- suggestion

	 l_progress := '130';

	 x_zone_id := NULL;
	 x_subinventory_code := l_pick_release_subinventory;
	 x_locator_id := l_pick_release_locator_id;

	 IF l_current_task_rec.project_id IS NOT NULL THEN
	    create_pjm_locator(x_locator_id => x_locator_id,
			       p_project_id => l_current_task_rec.project_id,
			       p_task_id => l_current_task_rec.task_id);
	 END IF;

	 IF (l_debug = 1) THEN
   	    print_debug('Return pick release sub : '|| x_subinventory_code ||' and locator ID : '||x_locator_id, 4);
   	    print_debug('Exsiting flag for consolidation locators for the pick release staging sub : '||l_cons_loc_exists_flag, 4);
	 END IF;


	 IF l_cons_loc_exists_flag > 0 THEN
	    x_return_status := 'W';
	    x_message := fnd_message.get_string('WMS', 'WMS_CONS_LOC_FULL');
	    fnd_message.set_name('WMS', 'WMS_CONS_LOC_FULL');
	    FND_MSG_PUB.ADD;
	    IF (l_debug = 1) THEN
   	       print_debug('All consolidation locators are full.', 4);
	    END IF;

	  ELSE
	   /* 9167904- commented
	    x_return_status := 'W';
	    x_message := fnd_message.get_string('WMS', 'WMS_CONS_LOC_NOT_DEFINED');
	    fnd_message.set_name('WMS', 'WMS_CONS_LOC_NOT_DEFINED');
	    FND_MSG_PUB.ADD;*/
	    IF (l_debug = 1) THEN
   	       print_debug('Consolidation locators are not defined for staging sub.', 4);
	    END IF;

	 END IF;

	 RETURN;

      END IF;


      IF p_call_mode = 2 THEN

	 l_progress := '140';

	 SELECT Nvl(mil.inventory_location_type, 3),
	   mil.subinventory_code,
	   Nvl(mil.empty_flag, 'Y'),
           Nvl(mil.disable_date, trunc(sysdate+1)),
           Nvl(msi.disable_date, trunc(sysdate+1))
	   INTO l_validate_loc_type,
	   l_validate_loc_subinventory,
	   l_validate_loc_empty_flag,
           l_loc_disable_date,
           l_sub_disable_date
	   FROM mtl_item_locations mil,
	   mtl_secondary_inventories msi
	   WHERE mil.inventory_location_id = p_locator_id
           AND msi.secondary_inventory_name = mil.subinventory_code
           AND msi.organization_id = mil.organization_id
           ;

	 l_progress := '150';

	 IF l_validate_loc_empty_flag = 'Y' AND
	   l_validate_loc_subinventory <> l_pick_release_subinventory AND
           l_loc_disable_date > trunc(sysdate) AND
           l_sub_disable_date > trunc(sysdate) AND
	   l_validate_loc_type = 4 THEN

	    IF (l_debug = 1) THEN
   	       print_debug('This is a valid locator since it is an empty consolidation locator in a different subinventory.', 4);
	    END IF;

	    RETURN;

	 END IF;


	 -- Up to this point we know this locator is invalid
	 -- Need to perform invalid reason check

	 l_progress := '160';

	 IF l_validate_loc_type <> G_LOC_TYPE_CONSOLIDATION THEN 	 -- This is not a consolidation locator

	    IF (l_debug = 1) THEN
   	       print_debug('This locator is invalid since it is not a consolidation locator.', 4);
	    END IF;



	    x_message := fnd_message.get_string('WMS', 'WMS_NOT_A_CONS_LOC');
	    fnd_message.set_name('WMS', 'WMS_NOT_A_CONS_LOC');
	    FND_MSG_PUB.ADD;
	    x_return_status := 'W';

	    RETURN;

	  ELSIF l_validate_loc_empty_flag <> 'Y' THEN   -- locator is not empty

	    IF (l_debug = 1) THEN
   	       print_debug('This locator is invalid since it contains other delivery.', 4);
	    END IF;

	    IF l_empty_cons_loc_count > 0 THEN
	       IF (l_debug = 1) THEN
   		  print_debug(' And there are other empty consolidation locators.', 4);
	       END IF;

	       x_message := fnd_message.get_string('WMS', 'WMS_EMPTY_CONS_EXIST');
	       fnd_message.set_name('WMS', 'WMS_EMPTY_CONS_EXIST');
	       FND_MSG_PUB.ADD;
	       x_return_status := g_ret_sts_error;
	     ELSE
	       IF (l_debug = 1) THEN
   		  print_debug(' But there are NOT any other empty consolidation locators.', 4);
	       END IF;

	       fnd_message.set_name('WMS', 'WMS_LOC_CONTN_OTHER_DEL');
	       FND_MSG_PUB.ADD;
	       x_message := fnd_message.get_string('WMS', 'WMS_LOC_CONTN_OTHER_DEL');
	       x_return_status := 'W';
	    END IF;

	    RETURN;

	  ELSE
	    x_message := fnd_message.get_string('INV', 'INV_INT_LOCCODE');
	    fnd_message.set_name('INV', 'INV_INT_LOCCODE');
	    FND_MSG_PUB.ADD;
	    x_return_status := 'W';
	    RETURN;

	 END IF;


      END IF;

      l_progress := '170';

    ELSE -- invalid p_task_type
      x_return_status := g_ret_sts_unexp_error;
      IF (l_debug = 1) THEN
   	 print_debug('Invalid input: P_Task_Type of '||p_task_type||' is not supported. ', 4);
      END IF;


      RETURN;
   END IF;




EXCEPTION
   WHEN OTHERS THEN
      IF l_current_task_curs%isopen THEN
	 CLOSE l_current_task_curs;
      END IF;
      IF l_loc_with_same_del_curs%isopen THEN
	 CLOSE l_loc_with_same_del_curs;
      END IF;
      IF l_loc_with_same_carton_group%isopen THEN
	 CLOSE l_loc_with_same_carton_group;
      END IF;
      IF l_empty_CONS_loc%isopen THEN
	 CLOSE l_empty_CONS_loc;
      END IF;

      IF (l_debug = 1) THEN
   	 print_debug('Other exception in Get_CONS_Loc_For_Delivery '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS')|| '  after where l_progress = ' || l_progress, 1);
      END IF;


      x_return_status := g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
	 x_message := x_message || '  with SQL error: ' || SQLERRM(SQLCODE);
	 IF (l_debug = 1) THEN
   	    print_debug(' With SQL error: ' || SQLERRM(SQLCODE), 1);
	 END IF;


      END IF;
END Get_CONS_Loc_For_Delivery;




-- API name    : Get_Staging_Loc_For_Delivery
-- Type        : Public
-- Function    :
-- Pre-reqs    :
--
-- Parameters  :
--   Output:
--
--   X_Return_status  : API exeution status, differen meaning in different
--                      call mode
--              For locator selection:
--                     'S' : Locator successfully returned.
--                     'E' : Locator is not returned because of application
--                           error.
--                     'U' : Locator is not returned because of unexpected
--                           error.
--
--              For locator validation:
--                     'S' : Locator is valid according to API logic.
--                     'W' : Locator is not valid, and user will be prompt for a warning
--                     'E' : Locator is not valid, and user should not be allowed to continue.
--                     'U' : API execution encountered unexpected error.
--
--
--   X_Message        : Message corresponding to different statuses
--                      and different call mode
--              For locator selection:
--                     'S' : Message that needs to displayed before
--                           displaying the suggested locator.
--                     'E' : Reason why locator is not returned.
--                     'U' : Message for the unexpected error.
--
--              For locator validation:
--                     'S' : No message.
--                     'W' : Reason why locator is invalid.
--                     'E' : Reason why locator is invalid.
--                     'U' : Message for the unexpected error.
--
--
--   X_locator_ID     : Locator returned according to API loc,
--                      only apply to P_Call_Mode of locator selection.
--
--   X_Zone_ID        : Zone returned according to API loc,
--                      only apply to P_Call_Mode of locator selection.
--
--   X_Subinventory_Code : Subinventory code returned according to API loc
--                      only apply to P_Call_Mode of locator selection.
--
--
--   Input:
--
--   P_Call_Mode   : 1. Locator selection 2. Locator validation
--
--   P_Task_Type   : Refer to lookup type WMS_TASK_TYPES
--
--   P_Task_ID     : Primary key for the corresponding task type.
--                   e.g. transaction_temp_id in MMTT for picking task type.
--
--   P_Locator_Id  : The locator needs to be validated according to API logic,
--                   only apply to P_Call_Mode of locator validation,
--
--
-- Version
--   Currently version is 1.0
--

--{{
--  Need to throughly test Get_Staging_Loc_For_Delivery.
--  Delivery based consolidation at staging lane was never properly tested before.
--}}

PROCEDURE Get_Staging_Loc_For_Delivery
  (
   X_Return_status          OUT nocopy VARCHAR2,
   X_Message                OUT nocopy VARCHAR2,
   X_locator_ID             OUT nocopy NUMBER,
   X_Zone_ID                OUT nocopy NUMBER,
   X_Subinventory_Code      OUT nocopy VARCHAR2,
   P_Call_Mode              IN  NUMBER DEFAULT NULL,
   P_Task_Type              IN  NUMBER DEFAULT NULL,
   P_Task_ID                IN  NUMBER DEFAULT NULL,
   P_Locator_Id             IN  NUMBER DEFAULT NULL,
   p_mol_id                 IN  NUMBER DEFAULT NULL
   )
  IS
     l_progress VARCHAR2(10);

     CURSOR l_current_task_curs
       IS
	  SELECT mol.carton_grouping_id,
	    wda.delivery_id,
	    mmtt.transaction_temp_id,
--	    mmtt.operation_plan_id,
	    mil.project_id,
	    mil.task_id,
            mil.organization_id
	    FROM
	    mtl_material_transactions_temp mmtt,
	    mtl_txn_request_lines mol,
	    wsh_delivery_details wdd1,
	    wsh_delivery_details wdd2,
	    wsh_delivery_assignments_v wda,
	    mtl_item_locations mil
	    WHERE
	    mmtt.transaction_temp_id = p_task_id AND
	    wdd1.move_order_line_id = mol.line_id AND
	    mmtt.content_lpn_id = wdd2.lpn_id AND
	    mmtt.transfer_to_location = mil.inventory_location_id AND
	    mmtt.transfer_organization = mil.organization_id AND
	    wdd1.released_status = 'Y' AND
	    wdd1.delivery_detail_id = wda.delivery_detail_id AND
	    wdd2.delivery_detail_id = wda.parent_delivery_detail_id AND
	    p_call_mode <> 3 AND
	    ROWNUM < 2
	  UNION ALL
	  SELECT mol.carton_grouping_id,
	    wda.delivery_id,
	    mmtt.transaction_temp_id,
--	    mmtt.operation_plan_id,
	    mil.project_id,
	    mil.task_id,
            mil.organization_id
	    FROM
	    mtl_material_transactions_temp mmtt,
	    mtl_material_transactions_temp pmmtt,
	    mtl_txn_request_lines mol,
	    wsh_delivery_details wdd,
	    wsh_delivery_assignments_v wda,
	    mtl_item_locations mil
	    WHERE
	    mmtt.transaction_temp_id = p_task_id AND
	    mmtt.move_order_line_id = mol.line_id AND
	    mmtt.move_order_line_id = wdd.move_order_line_id AND
	    pmmtt.locator_id = mil.inventory_location_id AND
	    pmmtt.organization_id = mil.organization_id AND
	    wdd.released_status = 'S' AND
	    wdd.delivery_detail_id = wda.delivery_detail_id (+) AND
	    pmmtt.transaction_temp_id = mmtt.parent_line_id AND
            p_call_mode = 3 AND
	    ROWNUM < 2
	    ;


     CURSOR l_mol_curs
       IS
	  SELECT mol.carton_grouping_id,
	    wda.delivery_id,
	    NULL,
--	    mmtt.operation_plan_id,
	    mol.project_id,
	    mol.task_id,
            mol.organization_id
	    FROM
	    mtl_txn_request_lines mol,
	    wsh_delivery_details wdd,
	    wsh_delivery_assignments_v wda
	    WHERE
	    mol.line_id = p_mol_id AND
	    wdd.move_order_line_id = mol.line_id AND
	    wdd.released_status = 'S' AND
	    wdd.delivery_detail_id = wda.delivery_detail_id AND
	    ROWNUM < 2
	    ;

     CURSOR l_loc_with_same_del_curs
       (v_delivery_id NUMBER)
       IS
	  SELECT wdd.subinventory del_subinventory,
	    wdd.locator_id del_locator_id,
	    nvl(mil.inventory_location_type, 3) del_locator_type
	    FROM wsh_delivery_details wdd,
	    wsh_delivery_assignments_v wda,
	    mtl_item_locations mil,
            mtl_secondary_inventories msi
	    WHERE wda.delivery_detail_id = wdd.delivery_detail_id AND
	    wdd.released_status = 'Y' AND
	    wdd.locator_id = mil.inventory_location_id AND
	    (nvl(mil.inventory_location_type, g_loc_type_storage_loc) = G_LOC_TYPE_STAGING_LANE
	     OR(nvl(mil.inventory_location_type, g_loc_type_storage_loc) IN (g_loc_type_staging_lane, g_loc_type_consolidation, g_loc_type_packing_station) AND
		p_call_mode = 2)
	     ) AND
--	    wdd.move_order_line_id = wdth.move_order_line_id AND
--	    wdth.operation_plan_id = v_operation_plan_id AND
            nvl(mil.disable_date, trunc(sysdate+1)) > trunc(sysdate) AND
            msi.secondary_inventory_name = mil.subinventory_code AND
            msi.organization_id = mil.organization_id AND
            nvl(msi.disable_date, trunc(sysdate + 1)) > trunc(sysdate) AND
	    wda.delivery_id = v_delivery_id
	    ORDER BY wdd.last_update_date DESC
	    ;

     CURSOR l_loc_with_same_carton_group
       (v_carton_grouping_id NUMBER)
       IS
	  SELECT wdd.subinventory mol_subinventory,
	    wdd.locator_id mol_locator_id,
	    nvl(mil.inventory_location_type, 3) mol_locator_type
	    FROM wsh_delivery_details wdd,
	    wsh_delivery_assignments_v wda,
	    mtl_txn_request_lines mol,
	    mtl_item_locations mil,
            mtl_secondary_inventories msi
	    WHERE
	    mol.line_id = wdd.move_order_line_id AND
	    wdd.released_status = 'Y' AND
	    wdd.locator_id = mil.inventory_location_id AND
	    wda.delivery_detail_id = wdd.delivery_detail_id AND
	    wda.delivery_id IS NULL AND -- bug 2768678
	    (nvl(mil.inventory_location_type, g_loc_type_storage_loc) = G_LOC_TYPE_STAGING_LANE
	     OR(nvl(mil.inventory_location_type, g_loc_type_storage_loc) IN (g_loc_type_staging_lane, g_loc_type_consolidation, g_loc_type_packing_station) AND
		p_call_mode = 2)
	     ) AND
--	    wdd.move_order_line_id = wdth.move_order_line_id AND
--	    wdth.operation_plan_id = v_operation_plan_id AND
            nvl(mil.disable_date, trunc(sysdate+1)) > trunc(sysdate) AND
            msi.secondary_inventory_name = mil.subinventory_code AND
            msi.organization_id = mil.organization_id AND
            nvl(msi.disable_date, trunc(sysdate + 1)) > trunc(sysdate) AND
	    mol.carton_grouping_id = v_carton_grouping_id
	    ORDER BY wdd.last_update_date DESC
	    ;

     --Cursor to get the Trip stop id associated with a delivery
     CURSOR l_del_trip_stop
       (v_del_id IN NUMBER)
       IS
          SELECT wts.STOP_ID
            FROM wsh_trips wt, wsh_trip_stops wts, wsh_delivery_legs wdl
            WHERE wdl.delivery_id = v_del_id AND
            wts.stop_id = wdl.pick_up_stop_id AND
            wts.trip_id = wt.trip_id;



     l_current_task_rec l_current_task_curs%ROWTYPE;

     l_loc_del_rec l_loc_with_same_del_curs%ROWTYPE;

     l_loc_mol_rec l_loc_with_same_carton_group%ROWTYPE;

     l_pick_release_subinventory VARCHAR2(30);
     l_pick_release_locator_id NUMBER;
     l_pick_release_locator_type NUMBER;
     l_validate_loc_type NUMBER;
     l_validate_loc_subinventory VARCHAR2(30);
     l_validate_loc_empty_flag VARCHAR2(1);

     l_loc_disable_date DATE;
     l_sub_disable_date DATE;

     l_stop_id NUMBER;
     l_api_return_status VARCHAR2(1);
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(2000);


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   x_return_status := G_RET_STS_SUCCESS;
   l_progress := '10';

   IF (l_debug = 1) THEN
      print_debug('Enter Get_Staging_Loc_For_Delivery '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
   END IF;

   IF (l_debug = 1) THEN
      print_debug('P_Call_Mode : '|| P_Call_Mode, 4);
      print_debug('P_Task_Type : '|| P_Task_Type, 4);
      print_debug('P_Task_ID : '|| P_Task_ID, 4);
      print_debug('P_Locator_Id : '|| P_Locator_Id, 4);
   END IF;



   -- Input parameter validation

   IF p_call_mode IN (1,3) THEN -- locator selection
      IF p_task_type IS NULL OR (p_task_id IS NULL AND p_mol_id IS NULL) THEN
	 x_return_status := g_ret_sts_unexp_error;
	 IF (l_debug = 1) THEN
   	    print_debug('Invalid input: For locator selection p_task_type and p_task_id cannot be NULL.', 4);
	 END IF;

	 RETURN;

      END IF;

    ELSIF p_call_mode = 2 THEN -- locator validation
      IF p_task_type IS NULL OR
	p_task_id IS NULL OR
	  p_locator_id IS NULL THEN
	 x_return_status := g_ret_sts_unexp_error;
	 IF (l_debug = 1) THEN
   	    print_debug('Invalid input: For locator selection p_locator_id, p_task_type and p_task_id cannot be NULL.', 4);
	 END IF;
	 RETURN;

      END IF;

    ELSE -- invalid p_call_mode

      x_return_status := g_ret_sts_unexp_error;
      IF (l_debug = 1) THEN
   	 print_debug('Invalid input: P_Call_Mode should be 1,2 or 3.', 4);
      END IF;


      RETURN;

   END IF;


   l_progress := '20';

   IF p_task_type IN (g_wms_task_type_pick, g_wms_task_type_stg_move) THEN  -- picking

      -- Get a staging locator where same delivery (or carton_grouping_ID) with the same operation plan ID has been dropped to


      --
      -- {{
      --  Need to test following cases for delivery based staging lane suggestion when move order line ID is given:
      --  1. MOL is lined to a WDD and its delivery trough crossdock
      --  2. Project and task is enabled.
      -- }}
      --
      IF(p_mol_id IS NULL) THEN
	 OPEN l_current_task_curs;
      ELSE
	 OPEN l_mol_curs;
      END IF;

      l_progress := '30';

      LOOP
	 -- this loop will only return one record, hense no performance concern
	 -- still used loop to conform to the standard way cursor is handled

	 IF(p_mol_id IS NULL) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Open l_current_task_curs cursor.', 4);
 	    END IF;

	    FETCH l_current_task_curs INTO l_current_task_rec;
	    EXIT WHEN l_current_task_curs%notfound;
	  ELSE
	    IF (l_debug = 1) THEN
	       print_debug('Open l_mol_curs cursor.', 4);
 	    END IF;

	    FETCH l_mol_curs INTO l_current_task_rec;
	    EXIT WHEN l_mol_curs%notfound;
	 END IF;


	 l_progress := '40';


	 IF (l_debug = 1) THEN
   	    print_debug('Searching staging locators for this tasks whose ', 4);
   	    print_debug('transaction_temp_id  : ' ||l_current_task_rec.transaction_temp_id, 4);
--   	    print_debug('with operation_plan_id : '||l_current_task_rec.operation_plan_id, 4);
   	    print_debug('and delivery ID: ' || l_current_task_rec.delivery_id, 4);
   	    print_debug('or carton_grouping_ID: ' || l_current_task_rec.carton_grouping_ID, 4);
	 END IF;


	 IF l_current_task_rec.delivery_id IS NOT NULL THEN

	    IF (l_debug = 1) THEN
   	       print_debug('Look for locator with same delivery.', 4);
	    END IF;


	    OPEN l_loc_with_same_del_curs
	      (l_current_task_rec.delivery_id);

	    LOOP
	       FETCH l_loc_with_same_del_curs INTO l_loc_del_rec;
	       EXIT WHEN l_loc_with_same_del_curs%notfound;

	       l_progress := '50';

	       IF p_call_mode IN (1,3) THEN --suggestion
		  IF (l_debug = 1) THEN
   		     print_debug('Found one staging locator for the same delivery:', 4);
   		     print_debug('subinventory : ' || l_loc_del_rec.del_subinventory, 4);
   		     print_debug('locator ID : ' || l_loc_del_rec.del_locator_id, 4);
		  END IF;


		  x_zone_id := NULL;
		  x_subinventory_code := l_loc_del_rec.del_subinventory;
		  x_locator_id := l_loc_del_rec.del_locator_id;

		  IF l_current_task_rec.project_id IS NOT NULL THEN
		     create_pjm_locator(x_locator_id => x_locator_id,
					p_project_id => l_current_task_rec.project_id,
					p_task_id => l_current_task_rec.task_id);
		  END IF;

		  IF l_current_task_curs%isopen THEN
		     CLOSE l_current_task_curs;
		  END IF;

		  IF l_mol_curs%isopen THEN
		     CLOSE l_mol_curs;
		  END IF;

		  IF l_loc_with_same_del_curs%isopen THEN
		     CLOSE l_loc_with_same_del_curs;
		  END IF;

		  RETURN;

		ELSIF p_call_mode = 2 THEN -- validation
		  IF l_loc_del_rec.del_locator_id = p_locator_id THEN
		     IF (l_debug = 1) THEN
   			print_debug('This is a valid staging locator with the same delivery.', 4);
		     END IF;


		     IF l_current_task_curs%isopen THEN
			CLOSE l_current_task_curs;
		     END IF;

		     IF l_mol_curs%isopen THEN
			CLOSE l_mol_curs;
		     END IF;

		     IF l_loc_with_same_del_curs%isopen THEN
			CLOSE l_loc_with_same_del_curs;
		     END IF;

		     RETURN;
		  END IF;

	       END IF;


	    END LOOP;  -- end l_loc_with_same_del_curs cursor loop


	    CLOSE l_loc_with_same_del_curs;

            -- Bug 4759446: find staging lane for dock appointment if it exists
            IF p_call_mode IN (1,3) THEN --suggestion
            -- {
               IF (l_debug = 1) THEN
                  print_debug('Look for staging lane associated with a dock appt.', 4);
               END IF;

               OPEN l_del_trip_stop (l_current_task_rec.delivery_id);
               FETCH l_del_trip_stop INTO l_stop_id;
               CLOSE l_del_trip_stop;

               IF (l_debug = 1) THEN
                  print_debug('Trip stop ID: ' || l_stop_id, 4);
               END IF;

               IF l_stop_id IS NOT NULL THEN
               -- {
                  l_api_return_status := fnd_api.g_ret_sts_success;
                  WMS_TRIPSTOPS_STAGELANES_PUB.get_stgln_for_tripstop
                  ( p_org_id        => l_current_task_rec.organization_id
                  , p_trip_stop     => l_stop_id
                  , x_stg_ln_id     => x_locator_id
                  , x_sub_code      => x_subinventory_code
                  , x_return_status => l_api_return_status
                  , x_msg_count     => l_msg_count
                  , x_msg_data      => l_msg_data
                  );

                  IF l_api_return_status = fnd_api.g_ret_sts_success THEN
                     x_zone_id := NULL;
                     IF (l_debug = 1) THEN
                        print_debug('Found staging sub for dock appt: '
                                     || x_subinventory_code, 4);
                        print_debug('and staging lane: ' || x_locator_id, 4);
                     END IF;

                     IF l_current_task_rec.project_id IS NOT NULL THEN
                        create_pjm_locator
                        ( x_locator_id => x_locator_id
                        , p_project_id => l_current_task_rec.project_id
                        , p_task_id    => l_current_task_rec.task_id
                        );
                     END IF;
                     RETURN;
                  END IF;
               -- }
               END IF; -- end if stop ID defined
            -- }
            END IF; -- end if call mode 1 or 3 and delivery ID exists

	  ELSIF l_current_task_rec.carton_grouping_id IS NOT NULL THEN

		  OPEN l_loc_with_same_carton_group
		    (l_current_task_rec.carton_grouping_id);

		  LOOP
		     FETCH l_loc_with_same_carton_group INTO l_loc_mol_rec;
		     EXIT WHEN l_loc_with_same_carton_group%notfound;

		     l_progress := '60';

		     IF p_call_mode IN (1,3) THEN --suggestion

			IF (l_debug = 1) THEN
   			   print_debug('Found one staging locator for the same carton_grouping_ID:', 4);
   			   print_debug('subinventory : ' || l_loc_mol_rec.mol_subinventory, 4);
   			   print_debug('locator ID : ' || l_loc_mol_rec.mol_locator_id, 4);
			END IF;


			x_zone_id := NULL;
			x_subinventory_code := l_loc_mol_rec.mol_subinventory;
			x_locator_id := l_loc_mol_rec.mol_locator_id;

			IF l_current_task_rec.project_id IS NOT NULL THEN
			   create_pjm_locator(x_locator_id => x_locator_id,
					      p_project_id => l_current_task_rec.project_id,
					      p_task_id => l_current_task_rec.task_id);
			END IF;

			IF l_current_task_curs%isopen THEN
			   CLOSE l_current_task_curs;
			END IF;

			IF l_mol_curs%isopen THEN
			   CLOSE l_mol_curs;
			END IF;

			IF l_loc_with_same_carton_group%isopen THEN
			   CLOSE l_loc_with_same_carton_group;
			END IF;

			RETURN;

		      ELSIF p_call_mode = 2 THEN -- validation
			IF l_loc_mol_rec.mol_locator_id = p_locator_id THEN
			   IF (l_debug = 1) THEN
   			      print_debug('This is a valid staging locator with the carton_grouping_ID.', 4);
			   END IF;


			   IF l_current_task_curs%isopen THEN
			      CLOSE l_current_task_curs;
			   END IF;

			   IF l_mol_curs%isopen THEN
			      CLOSE l_mol_curs;
			   END IF;

			   IF l_loc_with_same_carton_group%isopen THEN
			      CLOSE l_loc_with_same_carton_group;
			   END IF;

			   RETURN;
			END IF;
		     END IF;

		  END LOOP;  -- end l_loc_with_same_carton_group cursor loop

		  CLOSE l_loc_with_same_carton_group;

	 END IF;


      END LOOP;   -- end l_current_task_curs cursor loop


      l_progress := '70';

      IF l_current_task_curs%isopen THEN
	 CLOSE l_current_task_curs;
      END IF;


      IF l_mol_curs%isopen THEN
	 CLOSE l_mol_curs;
      END IF;



      l_progress := '100';


      -- Return pick release locator

      IF(p_task_id IS NOT NULL) THEN

	 IF (l_debug = 1) THEN
	    print_debug('Get pick release sub/loc from task.', 4);
	 END IF;

	 BEGIN
	    IF (p_call_mode <> 3) THEN
	       SELECT
		 mmtt.transfer_subinventory,
		 mmtt.transfer_to_location,
		 nvl(mil.inventory_location_type, 3)
		 INTO
		 l_pick_release_subinventory,
		 l_pick_release_locator_id,
		 l_pick_release_locator_type
		 FROM
		 mtl_material_transactions_temp mmtt,
		 mtl_item_locations mil
		 WHERE mmtt.transaction_temp_id = p_task_id
		 AND mil.inventory_location_id = mmtt.transfer_to_location
		 AND mil.organization_id = mmtt.organization_id
		 ;
	     ELSE
	       SELECT
		 pmmtt.subinventory_code,
		 pmmtt.locator_id,
		 nvl(mil.inventory_location_type, 3)
		 INTO
		 l_pick_release_subinventory,
		 l_pick_release_locator_id,
		 l_pick_release_locator_type
		 FROM
		 mtl_material_transactions_temp mmtt,
		 mtl_material_transactions_temp pmmtt,
		 mtl_item_locations mil
		 WHERE mmtt.transaction_temp_id = p_task_id
		 AND mmtt.parent_line_id = pmmtt.transaction_temp_id
		 AND mil.inventory_location_id = pmmtt.locator_id
		 AND mil.organization_id = pmmtt.organization_id
		 ;
	    END IF;
	 EXCEPTION
	    WHEN no_data_found THEN
	       IF (l_debug = 1) THEN
		  print_debug('Unable to determine default pick release sub',4);
	       END IF;
	       l_pick_release_subinventory := NULL;
	       l_pick_release_locator_id := NULL;
	       l_pick_release_locator_type := NULL;
	 END;
      END IF;

      l_progress := '120';

      IF (l_debug = 1) THEN
	 print_debug('Got pick release sub : '|| l_pick_release_subinventory ||' and locator ID : '||l_pick_release_locator_id, 4);
      END IF;


      IF p_call_mode in (1,3) AND p_task_id IS NOT NULL THEN -- suggestion

	 IF l_pick_release_locator_type = g_loc_type_staging_lane THEN

	    l_progress := '130';

	    x_zone_id := NULL;
	    x_subinventory_code := l_pick_release_subinventory;
	    x_locator_id := l_pick_release_locator_id;

	    IF l_current_task_rec.project_id IS NOT NULL THEN
	       create_pjm_locator(x_locator_id => x_locator_id,
				  p_project_id => l_current_task_rec.project_id,
				  p_task_id => l_current_task_rec.task_id);
	    END IF;

	    IF (l_debug = 1) THEN
   	       print_debug('Return pick release sub : '|| x_subinventory_code ||' and locator ID : '||x_locator_id, 4);
	    END IF;



	    RETURN;

	  ELSE
	    l_progress := '130';
	    x_zone_id := NULL;
	    x_subinventory_code := l_pick_release_subinventory;
	    x_locator_id := l_pick_release_locator_id;

	    IF l_current_task_rec.project_id IS NOT NULL THEN
	       create_pjm_locator(x_locator_id => x_locator_id,
				  p_project_id => l_current_task_rec.project_id,
				  p_task_id => l_current_task_rec.task_id);
	    END IF;


	    IF p_task_type = g_wms_task_type_stg_move THEN

	       IF (l_debug = 1) THEN
		  print_debug('Cannot perform staging move to non-staging locator. Check pick release.', 4);
	       END IF;

	       x_return_status := g_ret_sts_error;
	       x_message := fnd_message.get_string('WMS', 'WMS_STG_MV_INVALID_LOC_TYPE');
	       fnd_message.set_name('WMS', 'WMS_STG_MV_INVALID_LOC_TYPE');
	       FND_MSG_PUB.ADD;

	    END IF;

	    RETURN;

	 END IF;

       ELSIF p_call_mode = 2 THEN

	 l_progress := '140';

	 SELECT Nvl(mil.inventory_location_type, 3),
	   mil.subinventory_code,
	   Nvl(mil.empty_flag, 'Y'),
           Nvl(mil.disable_date, trunc(sysdate+1)),
           Nvl(msi.disable_date, trunc(sysdate+1))
	   INTO l_validate_loc_type,
	   l_validate_loc_subinventory,
	   l_validate_loc_empty_flag,
           l_loc_disable_date,
           l_sub_disable_date
	   FROM mtl_item_locations mil,
           mtl_secondary_inventories msi
	   WHERE mil.inventory_location_id = p_locator_id
           AND msi.secondary_inventory_name = mil.subinventory_code
           AND msi.organization_id = mil.organization_id
           ;

	 l_progress := '150';



	 IF l_validate_loc_type NOT IN
	   (g_loc_type_staging_lane, g_loc_type_consolidation, g_loc_type_packing_station)
            OR l_loc_disable_date <= trunc(sysdate)
            OR l_sub_disable_date <= trunc(sysdate)
	   THEN
	    -- Not a valid locator
	    IF (l_debug = 1) THEN
   	       print_debug('This locator is invalid since it is not a staing, packing, or consolidation locator.', 4);
	    END IF;


	    x_message := fnd_message.get_string('WMS', 'WMS_NOT_A_STG_LOC');  -- Not a staging locator
	    fnd_message.set_name('WMS', 'WMS_NOT_A_STG_LOC');
	    FND_MSG_PUB.ADD;
	    x_return_status := g_ret_sts_error;

	    RETURN;

	 END IF;


      END IF;

      l_progress := '170';

    ELSE -- invalid p_task_type
      x_return_status := g_ret_sts_unexp_error;
      IF (l_debug = 1) THEN
   	 print_debug('Invalid input: P_Task_Type of '||p_task_type||' is not supported. ', 4);
      END IF;


      RETURN;
   END IF;




EXCEPTION
   WHEN OTHERS THEN
      IF l_current_task_curs%isopen THEN
	 CLOSE l_current_task_curs;
      END IF;
      IF l_mol_curs%isopen THEN
	 CLOSE l_mol_curs;
      END IF;
      IF l_loc_with_same_del_curs%isopen THEN
	 CLOSE l_loc_with_same_del_curs;
      END IF;
      IF l_loc_with_same_carton_group%isopen THEN
	 CLOSE l_loc_with_same_carton_group;
      END IF;

      IF (l_debug = 1) THEN
   	 print_debug('Other exception in Get_Staging_Loc_For_Delivery '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS')|| '  after where l_progress = ' || l_progress, 1);
      END IF;


      x_return_status := g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
	 IF (l_debug = 1) THEN
   	    print_debug(' With SQL error: ' || SQLERRM(SQLCODE), 1);
	 END IF;

      END IF;



END Get_Staging_Loc_For_Delivery;


PROCEDURE Get_LPN_For_Delivery
  (
   X_Return_status          OUT nocopy VARCHAR2,
   X_Message                OUT nocopy VARCHAR2,
   X_LPN_ID                 OUT nocopy NUMBER,
   P_Task_Type              IN  NUMBER DEFAULT NULL,
   P_Task_ID                IN  NUMBER DEFAULT NULL,
   p_sug_sub                IN  VARCHAR2 DEFAULT NULL,
   p_sug_loc                IN  NUMBER DEFAULT NULL
   )IS
      l_to_sub_code VARCHAR2(30);
      l_to_loc_id NUMBER;
      l_organization_id NUMBER;
      l_license_plan_number VARCHAR2(30);
      l_delivery_id NUMBER;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_progress VARCHAR2(10);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('Entered wms_op_dest_sys_apis.Get_LPN_For_Delivery ', 1);
      print_debug('P_Task_Type: ' ||P_Task_Type , 1);
      print_debug('P_Task_ID: ' || P_Task_ID, 1);
      print_debug('P_sug_sub: ' || p_sug_sub, 1);
      print_debug('p_sug_loc: ' || p_sug_loc, 1);
   END IF;

   l_progress := '10';

    SELECT Nvl(p_sug_sub,Nvl(mmtt.transfer_subinventory, mmtt.subinventory_code)),
     Nvl(p_sug_loc,Nvl(mmtt.transfer_to_location, mmtt.locator_id)),
     mmtt.organization_id,
     wda.delivery_id
     INTO l_to_sub_code,
     l_to_loc_id,
     l_organization_id,
     l_delivery_id
     FROM mtl_material_transactions_temp mmtt,
     wsh_delivery_details wdd,
     wsh_delivery_assignments_v wda
     WHERE mmtt.transaction_temp_id = p_task_id
     AND wdd.move_order_line_id = mmtt.move_order_line_id
     AND wdd.released_status = 'S'
     AND wdd.delivery_detail_id = wda.delivery_detail_id;


   IF (l_debug = 1) THEN
      print_debug('Before calling wms_pick_drop_pvt.get_default_drop_lpn ' , 1);
      print_debug('p_to_sub: ' ||l_to_sub_code , 1);
      print_debug('p_to_loc: ' || l_to_loc_id, 1);
      print_debug('p_delivery_id: ' || l_delivery_id, 1);
   END IF;

   l_progress := '20';

   wms_pick_drop_pvt.get_default_drop_lpn
     ( x_drop_lpn_num => l_license_plan_number
       , x_return_status  => x_return_status
       , p_organization_id => l_organization_id
       , p_delivery_id => l_delivery_id
       , p_to_sub => l_to_sub_code
       , p_to_loc => l_to_loc_id
       );

   print_debug('l_license_plate_number:'||l_license_plan_number,1);
   l_progress := '30';

   IF(l_license_plan_number IS NOT NULL) THEN
      SELECT lpn_id
	INTO x_lpn_id
	FROM wms_license_plate_numbers
	WHERE license_plate_number = l_license_plan_number;
   END IF;

   l_progress := '40';

   IF (l_debug = 1) THEN
      print_debug('Exit wms_op_dest_sys_apis.Get_LPN_For_Delivery ', 1);
      print_debug('x_lpn_id: ' || x_lpn_id, 1);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
   	 print_debug('Other exception in Get_LPN_For_Delivery '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS')|| '  after where l_progress = ' || l_progress, 1);
      END IF;


      x_return_status := g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
	 IF (l_debug = 1) THEN
   	    print_debug(' With SQL error: ' || SQLERRM(SQLCODE), 1);
	 END IF;

      END IF;


END Get_LPN_For_Delivery;



END wms_op_dest_sys_apis;


/
