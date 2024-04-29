--------------------------------------------------------
--  DDL for Package Body WMS_TASK_DISPATCH_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_TASK_DISPATCH_ENGINE" AS
  /* $Header: WMSTDENB.pls 120.13.12010000.16 2010/04/02 09:30:41 kjujjuru ship $*/


  --
  -- File        : WMSTDENB.pls
  -- Content     : WMS_task_schedule package body
  -- Description : WMS task dispatching API for mobile application
  -- Notes       :
  -- Modified    : 05/01/2000 lezhang created



  -- API name    : taskdsp
  -- Type        : Private
  -- Function    : Return a group of tasks that a sign-on employee is eligible
  --               to perform
  --               Or return a group of picking tasks with the same picking
  --               methodology and pick slip number. This group of tasks includes
  --               the most optimal task based on priority, locator picking
  --               sequence, coordinates approximation, etc.
  --               or reservation input parameters and creates recommendations
  -- Pre-reqs    : 1. For each record in MTL_MATERIAL_TRANSACTIONS_TEMP, user
  --               defined task type (standard_operation_id column ) has been
  --               assigned,
  --               2. System task type (wms_task_type column) has been assigned
  --               3. Pick slip
  --               number (pick_slip_number column) has been assigned
  --
  -- Parameters  :
  --   p_api_version          Standard Input Parameter
  --   p_init_msg_list        Standard Input Parameter
  --   p_commit               Standard Input Parameter
  --   p_validation_level     Standard Input Parameter
  --   p_sign_on_emp_id       NUMBER, sign on emplployee ID, mandatory
  --   p_sign_on_org_id       NUMBER, org ID, mandatory
  --   p_sign_on_zone         VARCHAR2, sign on sub ID, optional
  --   p_sign_on_equipment_id NUMBER, sign on equipment item ID, optional,
  --                          can be a specific number, NULL or -999,
  --                          -999 means none
  --   p_sign_on_equipment_srl   VARCHAR2, sign on equipment serial num, optional
  --                          can be a specific serial number, NULL or '@@@',
  --                          '@@@' means none
  --   p_task_type            VARCHAR2, system task type this API will return,
  --                          can be 'PICKING', 'ALL', 'DISPLAY'
  --
  --
  -- Output Parameters
  --   x_return_status        Standard Output Parameter
  --   x_msg_count            Standard Output Parameter
  --   x_msg_data             Standard Output Parameter
  --   x_task_cur             Reference Cursor to deliver the queried tasks
  --                          It includes following fields:
  --                          mmtt.transaction_temp_id    NUMBER
  --                          mmtt.subinventory_code      VARCHAR2
  --                          mmtt.locator_id             NUMBER
  --                          mmtt.revision               VARCHAR2
  --                          mmtt.transaction_uom        VARCHAR2
  --                          mmtt.transaction_quantity   NUMBER
  --                          mmtt.lot_number             NUMBER
  --
  --
  -- Version
  --   Currently version is 1.0
  --


  --  Global constant holding the package name
  g_pkg_name            CONSTANT VARCHAR2(30) := 'WMS_Task_Dispatch_Engine';
  g_move_order_mfg_pick CONSTANT NUMBER       := inv_globals.g_move_order_mfg_pick;
  g_move_order_pick_wave CONSTANT NUMBER       := inv_globals.g_move_order_pick_wave;
  g_exc_unexpected_error EXCEPTION ;
  g_current_release_level CONSTANT NUMBER  :=  WMS_CONTROL.G_CURRENT_RELEASE_LEVEL;
  g_j_release_level  CONSTANT NUMBER := INV_RELEASE.G_J_RELEASE_LEVEL;
  g_user_id          CONSTANT NUMBER := fnd_global.user_id;

  -- cached variables for each move order header
  g_move_order_header_id NUMBER;   -- used to decide if the g_delivery_flag need to be requeried or not
  g_delivery_flag VARCHAR2(1) := 'N';
  g_bulk_pick_control NUMBER;


  PROCEDURE print_debug(p_err_msg VARCHAR2, p_level NUMBER) IS
  BEGIN
      -- dbms_output.put_line(p_err_msg);
      inv_mobile_helper_functions.tracelog(p_err_msg => p_err_msg, p_module => 'WMS_Task_Dispatch_Engine', p_level => p_level);
  END print_debug;

  -- bug 4358107
  PROCEDURE store_locked_tasks
              (p_grp_doc_type IN VARCHAR2,
               p_grp_doc_num  IN NUMBER,
               p_grp_src_type_id IN NUMBER,
               x_return_status  OUT NOCOPY VARCHAR2)
  IS
  --{
      l_debug  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
      i        NUMBER ;
  --}
  BEGIN
  --{
      IF (l_debug = 1) THEN
        print_debug('Enter STORE_LOCKED_TASKS ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
        print_debug(' grouping document type : ' || p_grp_doc_type, 9);
        print_debug(' grouping document number : ' || p_grp_doc_num, 9);
        print_debug(' grouping source type : ' || p_grp_src_type_id, 9);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_success;

      savepoint store_locked_tasks;

      -- Inserting the data into temp table
      insert into WMS_DISPATCH_TASKS_GTMP
        (
          grouping_document_type,
          grouping_document_number,
          grouping_source_type_id
        )
      values
        (
          p_grp_doc_type,
          p_grp_doc_num,
          p_grp_src_type_id
        );

      IF (l_debug = 1) THEN
        print_debug('Exit STORE_LOCKED_TASKS ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
  --}
  EXCEPTION
  --{
      WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          print_debug('STORE_LOCKED_TASKS : Exception Occured ' || substrb(SQLERRM,1,200), 1);
        END IF;
        rollback to store_locked_tasks;
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
  --}
  END store_locked_tasks;

  PROCEDURE remove_stored_cartons(x_return_status  OUT NOCOPY VARCHAR2)
  IS
      l_debug  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
      i        NUMBER ;
  BEGIN
      x_return_status  := fnd_api.g_ret_sts_success;

      savepoint remove_stored_cartons;

      -- remove the data from temp table
      DELETE FROM WMS_DISPATCH_TASKS_GTMP
      WHERE GROUPING_DOCUMENT_NUMBER IN (SELECT * FROM TABLE(wms_picking_pkg.list_cartonization_id));

      IF (l_debug = 1) THEN
        print_debug('Exit REMOVE_STORED_CARTONS ' , 1);
      END IF;
  EXCEPTION
      WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          print_debug('REMOVE_STORED_CARTONS : Exception Occured ' || substrb(SQLERRM,1,200), 1);
        END IF;
        rollback to remove_stored_cartons;
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END remove_stored_cartons;

--Added for Case Picking Project start
PROCEDURE remove_stored_order_num(x_return_status  OUT NOCOPY VARCHAR2) IS
BEGIN
	x_return_status  := fnd_api.g_ret_sts_success;
	savepoint remove_stored_order_numbers;
	DELETE FROM WMS_DISPATCH_TASKS_GTMP WHERE
	GROUPING_DOCUMENT_NUMBER IN (
                              SELECT   MMTT.TRANSACTION_SOURCE_ID
                              FROM     MTL_SALES_ORDERS MSO    ,
                                      MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
                              WHERE  MMTT.TRANSACTION_SOURCE_ID = MSO.SALES_ORDER_ID
                                  AND MSO.SEGMENT1 IN ( SELECT *  FROM TABLE(WMS_PICKING_PKG.LIST_ORDER_NUMBERS))
                              );
EXCEPTION
	WHEN OTHERS THEN
	rollback to remove_stored_order_numbers;
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
END remove_stored_order_num;

PROCEDURE remove_stored_pick_slip_num(x_return_status  OUT NOCOPY VARCHAR2) IS
BEGIN
	x_return_status  := fnd_api.g_ret_sts_success;
	savepoint remove_store_pick_slip_numbers;
	DELETE FROM WMS_DISPATCH_TASKS_GTMP WHERE
	GROUPING_DOCUMENT_NUMBER IN
	(SELECT * FROM TABLE(wms_picking_pkg.list_pick_slip_numbers));
EXCEPTION
WHEN OTHERS THEN
	rollback to remove_stored_pick_slip_number;
	x_return_status  := fnd_api.g_ret_sts_unexp_error;
END remove_stored_pick_slip_num;
--Added for Case Picking Project end


  -- bug 4358107
  -- APL procedure: Used since 11.5.10
  PROCEDURE dispatch_task
    (p_api_version              IN            NUMBER,
     p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false,
     p_commit                   IN            VARCHAR2 := fnd_api.g_false,
     p_sign_on_emp_id           IN            NUMBER,
     p_sign_on_org_id           IN            NUMBER,
     p_sign_on_zone             IN            VARCHAR2 := NULL,
     p_sign_on_equipment_id     IN            NUMBER := NULL, -- specific equip idNULL or -999. -999 stands for none
     p_sign_on_equipment_srl    IN            VARCHAR2 := NULL, -- same as above
     p_task_filter              IN            VARCHAR2,
     p_task_method              IN            VARCHAR2,
     x_grouping_document_type   IN OUT nocopy VARCHAR2,
     x_grouping_document_number IN OUT nocopy NUMBER,
     x_grouping_source_type_id  IN OUT nocopy NUMBER,
     x_task_cur                 OUT NOCOPY    task_rec_cur_tp,
     x_return_status            OUT NOCOPY    VARCHAR2,
     x_msg_count                OUT NOCOPY    NUMBER,
     x_msg_data                 OUT NOCOPY    VARCHAR2)
    IS

    l_cur_x                       NUMBER;
    l_cur_y                       NUMBER;
    l_cur_z                       NUMBER;

    l_task_priority               NUMBER;
    l_sub_pick_order              NUMBER;
    l_loc_pick_order              NUMBER;
    l_x_coordinate                NUMBER;
    l_y_coordinate                NUMBER;
    l_z_coordinate                NUMBER;
    l_is_locked                   BOOLEAN      := FALSE;

    l_sign_on_equipment_id        NUMBER;
    l_sign_on_equipment_srl       VARCHAR2(30);


    l_last_loaded_time            DATE;
    l_last_loaded_task_id         NUMBER;
    l_last_loaded_task_type       NUMBER;
    l_last_dropoff_time           DATE;
    l_last_dropoff_task_id        NUMBER;
    l_last_dropoff_task_type      NUMBER;
    l_last_task_type              NUMBER;
    l_last_task_is_drop           BOOLEAN      := FALSE;
    l_last_task_id                NUMBER;
    l_lpn_id                      NUMBER; --Added for bug#  3853837
    l_wdt_count                   NUMBER; --Added for bug#  3853837
    l_ordered_tasks_count         NUMBER;
    l_first_task_pick_slip_number NUMBER;
    l_api_name           CONSTANT VARCHAR2(30) := 'dispatch_task';
    l_api_version        CONSTANT NUMBER       := 1.0;
    l_progress                    VARCHAR2(10);
    l_sequence_picks_across_waves NUMBER       := 2;

    l_so_allowed                  NUMBER  := 0;
    l_io_allowed                  NUMBER  := 0;
    l_wip_allowed                 NUMBER  := 0;
    l_mot_rep_allowed             NUMBER  := 0;
    l_mot_allowed                 NUMBER  := 0;
    l_rep_allowed                 NUMBER  := 0;
    l_mot_moi_allowed             NUMBER  := 0;
    l_moi_allowed                 NUMBER  := 0;
    l_cc_allowed                  NUMBER  := 0;
    l_non_cc_allowed              NUMBER  := 0;

    l_task_id                     NUMBER;
    l_subinventory_code           VARCHAR2(10);
    l_locator_id                  NUMBER;
    l_task_type_id                NUMBER;
    l_cartonization_id            NUMBER;
    l_batch_id                    NUMBER;
    l_pick_slip                   NUMBER := 0;
    l_distance                    NUMBER;
    l_task_status                 NUMBER;
    l_transaction_quantity        NUMBER;
    l_transaction_uom             VARCHAR2(3);
    l_transaction_action_id       NUMBER;
    l_transaction_type_id         NUMBER;
    l_transaction_source_type_id  NUMBER;
    l_transaction_source_id       NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number                  VARCHAR2(80);
    l_revision                    VARCHAR2(3);
    l_operation_plan_id           NUMBER;
    l_move_order_line_id          NUMBER;
    l_standard_operation_id       NUMBER;
    l_effective_start_date        DATE;
    l_effective_end_date          DATE;
    l_person_resource_id          NUMBER;
    l_machine_resource_id         NUMBER;
    -- bug 4358107
    l_return_status               VARCHAR2(1);
    -- bug 4358107
    l_q_sign_on_equipment_id        NUMBER; --bug 6017284
    l_ignore_equipment              NUMBER; --bug 6017284

    l_total_lpns                  NUMBER; --Bug 7254397
    l_locked_lpns                 NUMBER; --Bug 7254397

    /* Bug 3808770
      Added condition in all the cursors selecting cycle count tasks to select
      only those tasks whose cycle count have not been disabled by entering
      an Inactive Date.
      Added the table mtl_cycle_count_headers in the FROM clause and joined with
      mtl_cycle_count_entries and checked for disable_date value with sysdate.
    */

    -- Cursor #1 for selecting the most optimal task
    -- 1. Sub is passed         (1)
    -- 2. Non cycle count tasks (1)
    -- 3. Cycle count tasks     (1)
    CURSOR l_curs_opt_task_111 IS
       SELECT DISTINCT
    qt.task_id task_num,
    qt.pick_slip,
    wdt.task_type wms_task_type_id,
    nvl(wdt.priority, 0) task_priority,
    Decode(l_sequence_picks_across_waves, 2, mol.header_id, NULL) batch_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    wdt.status task_status,  --bug 4310093
    qt.transaction_type_id,
    qt.transaction_action_id,
    qt.transaction_source_id,
    qt.transaction_source_type_id
       FROM wms_dispatched_tasks wdt,
            (SELECT
          transaction_temp_id task_id,
          pick_slip_number pick_slip,
               cartonization_id,
          organization_id,
               subinventory_code,
          locator_id,
          move_order_line_id,
          transaction_type_id,
          transaction_action_id,
          transaction_source_id,
          transaction_source_type_id
        FROM mtl_material_transactions_temp mmtt
        WHERE wms_task_type IS NOT NULL
             AND transaction_temp_id = Decode(p_task_method, 'BULK',
                                              parent_line_id, transaction_temp_id)
        AND Decode(transaction_source_type_id,
         2, l_so_allowed,
	 4, Decode(transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)), /*Bug#5188179*/
         5, Decode(transaction_type_id, 35, l_wip_allowed),
         8, l_io_allowed,
         13, Decode(transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
	  --7169220: USERS LOCKED
 	         AND (mmtt.cartonization_id is null
 	                                 or not exists
 	                                         (select 1 from mtl_material_transactions_temp mmtt1 ,wms_dispatched_tasks wdt1
 	                                         where mmtt1.transaction_temp_id <> mmtt.transaction_temp_id
 	                                         and wdt1.transaction_temp_id = mmtt1.transaction_temp_id
 	                                         and wdt1.status = 9
 	                                         and mmtt1.cartonization_id = mmtt.cartonization_id)
 	                                 )
        UNION ALL
        SELECT
          MIN(mcce.cycle_count_entry_id) task_id,
          TO_NUMBER(NULL) pick_slip,
          To_number(NULL) cartonization_id,
          mcce.organization_id,
          mcce.subinventory subinventory_code,
          mcce.locator_id,
          To_number(NULL) move_order_line_id,
               4 transaction_type_id,
          4 transaction_action_id,
          mcce.cycle_count_header_id transaction_source_id,
          9 transaction_source_type_id
        FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
        WHERE mcce.entry_status_code IN(1, 3)
          AND NVL(mcce.export_flag, 2) = 2
          -- bug 3972076
          --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
          AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
          AND NVL(mcch.disable_date,sysdate+1)> sysdate
          GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) qt,
       mtl_txn_request_lines mol,
       mtl_secondary_inventories sub,
       mtl_item_locations loc,
       (SELECT
          bsor.standard_operation_id,
          bre.resource_id,
          bre.inventory_item_id equipment_id
        FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
        WHERE bsor.resource_id = bre.resource_id
        AND br.resource_type = 1
        AND bsor.resource_id = br.resource_id) e
       WHERE wdt.transaction_temp_id = qt.task_id
    AND wdt.status in ( 2,3) -- Queued and dispatched tasks only bug 4310093
    AND wdt.person_id = p_sign_on_emp_id
    AND wdt.organization_id = p_sign_on_org_id
    AND NVL(qt.cartonization_id, -999) = NVL(l_cartonization_id, NVL(qt.cartonization_id, -999))
    AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))
    AND wdt.user_task_type = e.standard_operation_id(+)
    AND qt.move_order_line_id = mol.line_id(+)
    AND qt.subinventory_code = p_sign_on_zone
    AND qt.organization_id = sub.organization_id
    AND qt.subinventory_code = sub.secondary_inventory_name
    AND qt.organization_id = loc.organization_id
    AND qt.locator_id = loc.inventory_location_id
       UNION ALL
       SELECT DISTINCT
    wdtv.task_id task_num,
    NVL(wdtv.pick_slip_number, -1) pick_slip,
    wdtv.wms_task_type_id,
    nvl(wdtv.task_priority, 0),
    Decode(l_sequence_picks_across_waves, 2, mol.header_id, NULL) batch_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    task_status,
         wdtv.transaction_type_id,
    wdtv.transaction_action_id,
    wdtv.transaction_source_id,
    wdtv.transaction_source_type_id
       FROM
    -- inlined wms_dispatchable_tasks_v, bug 2648133
    (SELECT
       transaction_temp_id task_id,
       standard_operation_id user_task_type_id,
       wms_task_type wms_task_type_id,
       organization_id,
       subinventory_code zone,
       locator_id,
       task_priority,
       revision,
       lot_number,
       transaction_uom,
       transaction_quantity,
       pick_rule_id,
       pick_slip_number,
       cartonization_id,
       inventory_item_id,
       move_order_line_id,
       1 task_status,
       transaction_type_id,
       transaction_action_id,
       transaction_source_id,
       transaction_source_type_id
     FROM mtl_material_transactions_temp mmtt
     WHERE wms_task_type IS NOT NULL
       AND transaction_status = 2
       AND(wms_task_status IS NULL OR wms_task_status = 1) --Added for task planning WB. bug#2651318
            AND transaction_temp_id = Decode(p_task_method, 'BULK',
                                             parent_line_id, transaction_temp_id)
            AND Decode(transaction_source_type_id,
             2, l_so_allowed,
             4, Decode(transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)), /*Bug#5188179*/
             5, Decode(transaction_type_id, 35, l_wip_allowed),
             8, l_io_allowed,
             13, Decode(transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
				    --7169220: USERS LOCKED
 	         AND (mmtt.cartonization_id is null
 	                                 or not exists
 	                                         (select 1 from mtl_material_transactions_temp mmtt1 ,wms_dispatched_tasks wdt1
 	                                         where mmtt1.transaction_temp_id <> mmtt.transaction_temp_id
 	                                         and wdt1.transaction_temp_id = mmtt1.transaction_temp_id
 	                                         and wdt1.status = 9
 	                                         and mmtt1.cartonization_id = mmtt.cartonization_id)
 	                                 )

     UNION ALL
     SELECT
       MIN(mcce.cycle_count_entry_id) task_id,
       MIN(mcce.standard_operation_id) user_task_type_id,
       3 wms_task_type_id,
       mcce.organization_id,
       mcce.subinventory zone,
       mcce.locator_id,
       MIN(mcce.task_priority) task_priority,
       mcce.revision revision,
       MIN(mcce.lot_number) lot_number,
       '' transaction_uom,
       TO_NUMBER(NULL) transaction_quantity,
       TO_NUMBER(NULL) pick_rule_id,
       TO_NUMBER(NULL) pick_slip_number,
       TO_NUMBER(NULL) cartonization_id,
       mcce.inventory_item_id,
       TO_NUMBER(NULL) move_order_line_id,
       1 task_status,
       4 transaction_type_id,
       4 transaction_action_id,
       mcce.cycle_count_header_id transaction_source_id,
       9 transaction_source_type_id
     FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
     WHERE mcce.entry_status_code IN(1, 3)
       AND NVL(mcce.export_flag, 2) = 2
       -- bug 3972076
       --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
       AND mcce.cycle_count_header_id = mcch.cycle_count_header_id

     -----bug6903708---
      AND mcce.organization_id = mcch.organization_id
      AND mcch.organization_id = p_sign_on_org_id
      ---------------------------

       AND NVL(mcch.disable_date,sysdate+1)> sysdate
     GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv,
    -- inlined wms_person_resource_utt_v, bug 2648133
    (SELECT
       utt_emp.standard_operation_id standard_operation_id,
       utt_emp.resource_id role,
       utt_eqp.resource_id equipment,
       utt_emp.person_id emp_id,
       utt_eqp.inventory_item_id eqp_id,
       NULL eqp_srl  /* removed for bug 2095237 */
     FROM
       (SELECT
          x_utt_res1.standard_operation_id standard_operation_id,
          x_utt_res1.resource_id resource_id,
          x_emp_r.person_id
        FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
        WHERE x_utt_res1.resource_id = r1.resource_id
          AND r1.resource_type = 2
          AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp,
       (SELECT
          x_utt_res2.standard_operation_id standard_operation_id,
          x_utt_res2.resource_id,
          x_eqp_r.inventory_item_id
        FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
        WHERE x_utt_res2.resource_id = r2.resource_id
        AND r2.resource_type = 1
        AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
      WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v,
    mtl_item_locations loc,
    mtl_secondary_inventories sub,
    mtl_txn_request_lines mol,
    mtl_txn_request_headers moh
       WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
    AND wdtv.organization_id = p_sign_on_org_id
    AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
    AND wdtv.zone = p_sign_on_zone --  removed NVL, bug 2648133
    AND NVL(wdtv.cartonization_id, -999) = NVL(l_cartonization_id, NVL(wdtv.cartonization_id, -999))
    AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
    AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
    AND wdtv.locator_id = loc.inventory_location_id(+)
    AND wdtv.zone = sub.secondary_inventory_name
    AND wdtv.organization_id = sub.organization_id
    AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
    AND moh.header_id(+) = mol.header_id
    AND Decode(Nvl(moh.move_order_type, -1),
          2, l_rep_allowed,
          1, l_mot_moi_allowed,
          -1, 1,
          1) = 1
    --AND Nvl(wdtv.pick_slip_number, -1) <> l_pick_slip -- bug 2832818
    -- bug 4358107
    AND NOT EXISTS
         ( SELECT 1
           FROM WMS_DISPATCH_TASKS_GTMP
           WHERE (p_task_method = 'DISCRETE'
                  and
                  grouping_document_number = wdtv.pick_slip_number
                 )
                 or
                 (
                  p_task_method = 'ORDERPICK'
                  and
                  grouping_document_number = wdtv.transaction_source_id
                  and
                  grouping_source_type_id = wdtv.transaction_source_type_id
                 )
                 or
                 (p_task_method = 'PICKBYLABEL'
                  and
                  grouping_document_number = wdtv.cartonization_id
                 )
		 or    --6598260   start
		 (    grouping_document_number = wdtv.cartonization_id
		      and
		      grouping_document_type = 'CARTON_TASK'
		 )     --6598260    end
         )
    -- bug 4358107
    AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
         (SELECT NULL
          FROM mtl_material_transactions_temp mmtt
          WHERE mmtt.transaction_temp_id = wdtv.task_id
          AND mmtt.parent_line_id IS NOT NULL
               AND mmtt.parent_line_id <> mmtt.transaction_temp_id
          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
    AND NOT EXISTS -- exclude tasks already dispatched and queued
         (SELECT NULL
          FROM wms_dispatched_tasks wdt1
          WHERE wdt1.transaction_temp_id = wdtv.task_id
          AND wdt1.task_type = wdtv.wms_task_type_id)
    -- excluded skipped tasks
    AND wdtv.task_id NOT IN
         (SELECT wdtv.task_id
          FROM wms_skip_task_exceptions wste, mtl_parameters mp
          WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
          AND wste.task_id = wdtv.task_id
          AND wste.organization_id = mp.organization_id)
         --J Addition
    AND wdtv.zone not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
                              )
       ORDER BY
    task_priority desc,
    batch_id,
    task_status DESC,
    sub_picking_order,
         loc_picking_order,
    distance,
    task_num;

    -- Cursor #2 for selecting the most optimal task
    -- 1. Sub is passed         (1)
    -- 2. Non cycle count tasks (1)
    -- 3. Cycle count tasks     (0)
    CURSOR l_curs_opt_task_110 IS
       SELECT DISTINCT
    qt.task_id task_num,
    qt.pick_slip,
    wdt.task_type wms_task_type_id,
    nvl(wdt.priority, 0) task_priority,
    Decode(l_sequence_picks_across_waves, 2, mol.header_id, NULL) batch_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    wdt.status task_status,  --bug 4310093
    qt.transaction_type_id,
    qt.transaction_action_id,
    qt.transaction_source_id,
    qt.transaction_source_type_id
       FROM wms_dispatched_tasks wdt,
            (SELECT
          transaction_temp_id task_id,
          pick_slip_number pick_slip,
               cartonization_id,
          organization_id,
               subinventory_code,
          locator_id,
          move_order_line_id,
          transaction_type_id,
          transaction_action_id,
          transaction_source_id,
          transaction_source_type_id
        FROM mtl_material_transactions_temp mmtt
        WHERE wms_task_type IS NOT NULL
             AND transaction_temp_id = Decode(p_task_method, 'BULK',
                                              parent_line_id, transaction_temp_id)
        AND Decode(transaction_source_type_id,
         2, l_so_allowed,
         4, Decode(transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)), /*Bug#5188179*/
         5, Decode(transaction_type_id, 35, l_wip_allowed),
         8, l_io_allowed,
         13, Decode(transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
				            --7169220: USERS LOCKED
 	         AND (mmtt.cartonization_id is null
 	                                 or not exists
 	                                         (select 1 from mtl_material_transactions_temp mmtt1 ,wms_dispatched_tasks wdt1
 	                                         where mmtt1.transaction_temp_id <> mmtt.transaction_temp_id
 	                                         and wdt1.transaction_temp_id = mmtt1.transaction_temp_id
 	                                         and wdt1.status = 9
 	                                         and mmtt1.cartonization_id = mmtt.cartonization_id)
 	                                 )
) qt,
       mtl_txn_request_lines mol,
       mtl_secondary_inventories sub,
       mtl_item_locations loc,
       (SELECT
          bsor.standard_operation_id,
          bre.resource_id,
          bre.inventory_item_id equipment_id
        FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
        WHERE bsor.resource_id = bre.resource_id
        AND br.resource_type = 1
        AND bsor.resource_id = br.resource_id) e
       WHERE wdt.transaction_temp_id = qt.task_id
    AND wdt.status = 2  --bug 6326482queued task only bug   -- Queued and dispatched tasks only bug 4310093
    AND wdt.person_id = p_sign_on_emp_id
    AND wdt.organization_id = p_sign_on_org_id
    AND NVL(qt.cartonization_id, -999) = NVL(l_cartonization_id, NVL(qt.cartonization_id, -999))
    AND NVL(e.equipment_id, -999) = NVL(l_q_sign_on_equipment_id, NVL(e.equipment_id, -999))--bug 6326482
    AND wdt.user_task_type = e.standard_operation_id(+)
    AND qt.move_order_line_id = mol.line_id(+)
    AND qt.subinventory_code = p_sign_on_zone
    AND qt.organization_id = sub.organization_id
    AND qt.subinventory_code = sub.secondary_inventory_name
    AND qt.organization_id = loc.organization_id
         AND qt.locator_id = loc.inventory_location_id
	    UNION ALL
      --bug 6326482 for dispatched tasks
       SELECT DISTINCT
    qt.task_id task_num,
    qt.pick_slip,
    wdt.task_type wms_task_type_id,
    nvl(wdt.priority, 0) task_priority,
    Decode(l_sequence_picks_across_waves, 2, mol.header_id, NULL) batch_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    wdt.status task_status,
    qt.transaction_type_id,
    qt.transaction_action_id,
    qt.transaction_source_id,
    qt.transaction_source_type_id
       FROM wms_dispatched_tasks wdt,
            (SELECT
          transaction_temp_id task_id,
	  wms_task_status task_status,--bug 6326482 added to know the previous state of dispatched tasks
          pick_slip_number pick_slip,
               cartonization_id,
          organization_id,
               subinventory_code,
          locator_id,
          move_order_line_id,
          transaction_type_id,
          transaction_action_id,
          transaction_source_id,
          transaction_source_type_id
        FROM mtl_material_transactions_temp mmtt
        WHERE wms_task_type IS NOT NULL
             AND transaction_temp_id = Decode(p_task_method, 'BULK',
                                              parent_line_id, transaction_temp_id)
        AND Decode(transaction_source_type_id,
         2, l_so_allowed,
         4, Decode(transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)), /*Bug#5094839*/
         5, Decode(transaction_type_id, 35, l_wip_allowed),
         8, l_io_allowed,
         13, Decode(transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
				    --7169220: USERS LOCKED
 	         AND (mmtt.cartonization_id is null
 	                                 or not exists
 	                                         (select 1 from mtl_material_transactions_temp mmtt1 ,wms_dispatched_tasks wdt1
 	                                         where mmtt1.transaction_temp_id <> mmtt.transaction_temp_id
 	                                         and wdt1.transaction_temp_id = mmtt1.transaction_temp_id
 	                                         and wdt1.status = 9
 	                                         and mmtt1.cartonization_id = mmtt.cartonization_id)
 	                                 )
) qt,
       mtl_txn_request_lines mol,
       mtl_secondary_inventories sub,
       mtl_item_locations loc,
       (SELECT
          bsor.standard_operation_id,
          bre.resource_id,
          bre.inventory_item_id equipment_id
        FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
        WHERE bsor.resource_id = bre.resource_id
        AND br.resource_type = 1
        AND bsor.resource_id = br.resource_id) e
       WHERE wdt.transaction_temp_id = qt.task_id
    AND wdt.status = 3  -- bug  6326482 dispatched tasks
    AND wdt.person_id = p_sign_on_emp_id
    AND wdt.organization_id = p_sign_on_org_id
    AND NVL(qt.cartonization_id, -999) = NVL(l_cartonization_id, NVL(qt.cartonization_id, -999))
    --bug 6326482
    AND ((qt.task_status is NULL
    AND NVL(e.equipment_id, -999) = NVL(l_q_sign_on_equipment_id, NVL(e.equipment_id, -999)))
    or
    (qt.task_status = 1
    AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))))--bug 6326482
    AND wdt.user_task_type = e.standard_operation_id(+)
    AND qt.move_order_line_id = mol.line_id(+)
    AND qt.subinventory_code = p_sign_on_zone
    AND qt.organization_id = sub.organization_id
    AND qt.subinventory_code = sub.secondary_inventory_name
    AND qt.organization_id = loc.organization_id
         AND qt.locator_id = loc.inventory_location_id
       UNION ALL
       SELECT DISTINCT
    wdtv.task_id task_num,
    NVL(wdtv.pick_slip_number, -1) pick_slip,
    wdtv.wms_task_type_id,
    nvl(wdtv.task_priority, 0),
    Decode(l_sequence_picks_across_waves, 2, mol.header_id, NULL) batch_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    task_status,
         wdtv.transaction_type_id,
    wdtv.transaction_action_id,
    wdtv.transaction_source_id,
    wdtv.transaction_source_type_id
       FROM
    -- inlined wms_dispatchable_tasks_v, bug 2648133
    (SELECT
       transaction_temp_id task_id,
       standard_operation_id user_task_type_id,
       wms_task_type wms_task_type_id,
       organization_id,
       subinventory_code zone,
       locator_id,
       task_priority,
       revision,
       lot_number,
       transaction_uom,
       transaction_quantity,
       pick_rule_id,
       pick_slip_number,
       cartonization_id,
       inventory_item_id,
       move_order_line_id,
       1 task_status,
       transaction_type_id,
       transaction_action_id,
       transaction_source_id,
       transaction_source_type_id
     FROM mtl_material_transactions_temp mmtt
     WHERE wms_task_type IS NOT NULL
       AND transaction_status = 2
       AND(wms_task_status IS NULL OR wms_task_status = 1) --Added for task planning WB. bug#2651318
            AND transaction_temp_id = Decode(p_task_method, 'BULK',
                                             parent_line_id, transaction_temp_id)
            AND Decode(transaction_source_type_id,
             2, l_so_allowed,
             4, Decode(transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)), /*Bug#5188179*/
             5, Decode(transaction_type_id, 35, l_wip_allowed),
             8, l_io_allowed,
             13, Decode(transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
    --7169220: USERS LOCKED
 	         AND (mmtt.cartonization_id is null
 	                                 or not exists
 	                                         (select 1 from mtl_material_transactions_temp mmtt1 ,wms_dispatched_tasks wdt1
 	                                         where mmtt1.transaction_temp_id <> mmtt.transaction_temp_id
 	                                         and wdt1.transaction_temp_id = mmtt1.transaction_temp_id
 	                                         and wdt1.status = 9
 	                                         and mmtt1.cartonization_id = mmtt.cartonization_id)
 	                                 )
) wdtv,
    -- inlined wms_person_resource_utt_v, bug 2648133
    (SELECT
       utt_emp.standard_operation_id standard_operation_id,
       utt_emp.resource_id role,
       utt_eqp.resource_id equipment,
       utt_emp.person_id emp_id,
       utt_eqp.inventory_item_id eqp_id,
       NULL eqp_srl  /* removed for bug 2095237 */
     FROM
       (SELECT
          x_utt_res1.standard_operation_id standard_operation_id,
          x_utt_res1.resource_id resource_id,
          x_emp_r.person_id
        FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
        WHERE x_utt_res1.resource_id = r1.resource_id
          AND r1.resource_type = 2
          AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp,
       (SELECT
          x_utt_res2.standard_operation_id standard_operation_id,
          x_utt_res2.resource_id,
          x_eqp_r.inventory_item_id
        FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
        WHERE x_utt_res2.resource_id = r2.resource_id
        AND r2.resource_type = 1
        AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
     WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v,
    mtl_item_locations loc,
    mtl_secondary_inventories sub,
    mtl_txn_request_lines mol,
    mtl_txn_request_headers moh
       WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
    AND wdtv.organization_id = p_sign_on_org_id
    AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
    AND wdtv.zone = p_sign_on_zone --  removed NVL, bug 2648133
    AND NVL(wdtv.cartonization_id, -999) = NVL(l_cartonization_id, NVL(wdtv.cartonization_id, -999))
    AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
    AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
    AND wdtv.locator_id = loc.inventory_location_id(+)
    AND wdtv.zone = sub.secondary_inventory_name
    AND wdtv.organization_id = sub.organization_id
    AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
    AND moh.header_id(+) = mol.header_id
    AND Decode(Nvl(moh.move_order_type, -1),
          2, l_rep_allowed,
          1, l_mot_moi_allowed,
          -1, 1,
          1) = 1
    --AND Nvl(wdtv.pick_slip_number, -1) <> l_pick_slip -- bug 2832818
    -- bug 4358107
    AND NOT EXISTS
         ( SELECT 1
           FROM WMS_DISPATCH_TASKS_GTMP
           WHERE (p_task_method = 'DISCRETE'
                  and
                  grouping_document_number = wdtv.pick_slip_number
                 )
                 or
                 (
                  p_task_method = 'ORDERPICK'
                  and
                  grouping_document_number = wdtv.transaction_source_id
                  and
                  grouping_source_type_id = wdtv.transaction_source_type_id
                 )
                 or
                 (p_task_method = 'PICKBYLABEL'
                  and
                  grouping_document_number = wdtv.cartonization_id
                 )
		 or    --6598260   start
		 (    grouping_document_number = wdtv.cartonization_id
		      and
		      grouping_document_type = 'CARTON_TASK'
		 )     --6598260    end
         )
    -- bug 4358107
    AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
         (SELECT NULL
          FROM mtl_material_transactions_temp mmtt
          WHERE mmtt.transaction_temp_id = wdtv.task_id
          AND mmtt.parent_line_id IS NOT NULL
               AND mmtt.parent_line_id <> mmtt.transaction_temp_id
          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
    AND NOT EXISTS -- exclude tasks already dispatched and queued
         (SELECT NULL
          FROM wms_dispatched_tasks wdt1
          WHERE wdt1.transaction_temp_id = wdtv.task_id
          AND wdt1.task_type = wdtv.wms_task_type_id)
    -- excluded skipped tasks
    AND wdtv.task_id NOT IN
         (SELECT wdtv.task_id
          FROM wms_skip_task_exceptions wste, mtl_parameters mp
          WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
          AND wste.task_id = wdtv.task_id
          AND wste.organization_id = mp.organization_id)
         --J Addition
    AND wdtv.zone not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
         )
       ORDER BY
    task_priority desc,
    batch_id,
    task_status DESC,
    sub_picking_order,
         loc_picking_order,
    distance,
    task_num;

    -- Cursor #3 for selecting the most optimal task
    -- 1. Sub is passed         (1)
    -- 2. Non cycle count tasks (0)
    -- 3. Cycle count tasks     (1)
    CURSOR l_curs_opt_task_101 IS
       SELECT DISTINCT
    qt.task_id task_num,
    qt.pick_slip,
    wdt.task_type wms_task_type_id,
    nvl(wdt.priority, 0) task_priority,
    To_number (NULL) batch_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    wdt.status task_status, --bug 4310093
    qt.transaction_type_id,
    qt.transaction_action_id,
    qt.transaction_source_id,
    qt.transaction_source_type_id
       FROM wms_dispatched_tasks wdt,
            (SELECT
          MIN(mcce.cycle_count_entry_id) task_id,
          TO_NUMBER(NULL) pick_slip,
          To_number(NULL) cartonization_id,
          mcce.organization_id,
          mcce.subinventory subinventory_code,
          mcce.locator_id,
          To_number(NULL) move_order_line_id,
               4 transaction_type_id,
          4 transaction_action_id,
          mcce.cycle_count_header_id transaction_source_id,
          9 transaction_source_type_id
        FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
        WHERE mcce.entry_status_code IN(1, 3)
          AND NVL(mcce.export_flag, 2) = 2
          -- bug 3972076
          --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
          AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
      -----bug6903708---

      AND mcce.organization_id = mcch.organization_id
      AND mcch.organization_id = p_sign_on_org_id

        ---------------------------

          AND NVL(mcch.disable_date,sysdate+1)> sysdate
          GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) qt,
       mtl_secondary_inventories sub,
       mtl_item_locations loc,
       (SELECT
          bsor.standard_operation_id,
          bre.resource_id,
          bre.inventory_item_id equipment_id
        FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
        WHERE bsor.resource_id = bre.resource_id
        AND br.resource_type = 1
        AND bsor.resource_id = br.resource_id) e
       WHERE wdt.transaction_temp_id = qt.task_id
    AND wdt.status in ( 2,3) -- Queued and dispatched tasks only bug 4310093
    AND wdt.person_id = p_sign_on_emp_id
    AND wdt.organization_id = p_sign_on_org_id
    AND NVL(qt.cartonization_id, -999) = NVL(l_cartonization_id, NVL(qt.cartonization_id, -999))
    AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))
    AND wdt.user_task_type = e.standard_operation_id(+)
    AND qt.organization_id = sub.organization_id
    AND qt.subinventory_code = p_sign_on_zone
    AND qt.subinventory_code = sub.secondary_inventory_name
    AND qt.organization_id = loc.organization_id
    AND qt.locator_id = loc.inventory_location_id
       UNION ALL
       SELECT DISTINCT
    wdtv.task_id task_num,
    NVL(wdtv.pick_slip_number, -1) pick_slip,
    wdtv.wms_task_type_id,
    nvl(wdtv.task_priority, 0),
    To_number(NULL) batch_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    task_status,
         wdtv.transaction_type_id,
    wdtv.transaction_action_id,
    wdtv.transaction_source_id,
    wdtv.transaction_source_type_id
       FROM
    -- inlined wms_dispatchable_tasks_v, bug 2648133
    (SELECT
       MIN(mcce.cycle_count_entry_id) task_id,
       MIN(mcce.standard_operation_id) user_task_type_id,
       3 wms_task_type_id,
       mcce.organization_id,
       mcce.subinventory zone,
       mcce.locator_id,
       MIN(mcce.task_priority) task_priority,
       mcce.revision revision,
       MIN(mcce.lot_number) lot_number,
       '' transaction_uom,
       TO_NUMBER(NULL) transaction_quantity,
       TO_NUMBER(NULL) pick_rule_id,
       TO_NUMBER(NULL) pick_slip_number,
       TO_NUMBER(NULL) cartonization_id,
       mcce.inventory_item_id,
       TO_NUMBER(NULL) move_order_line_id,
       1 task_status,
       4 transaction_type_id,
       4 transaction_action_id,
       mcce.cycle_count_header_id transaction_source_id,
       9 transaction_source_type_id
     FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
     WHERE mcce.entry_status_code IN(1, 3)
       AND NVL(mcce.export_flag, 2) = 2
       -- bug 3972076
       --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
       AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
      -----bug6903708---
      AND mcce.organization_id = mcch.organization_id
      AND mcch.organization_id = p_sign_on_org_id
        ---------------------------

       AND NVL(mcch.disable_date,sysdate+1)> sysdate
     GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv,
    -- inlined wms_person_resource_utt_v, bug 2648133
    (SELECT
       utt_emp.standard_operation_id standard_operation_id,
       utt_emp.resource_id role,
       utt_eqp.resource_id equipment,
       utt_emp.person_id emp_id,
       utt_eqp.inventory_item_id eqp_id,
       NULL eqp_srl  /* removed for bug 2095237 */
     FROM
       (SELECT
          x_utt_res1.standard_operation_id standard_operation_id,
          x_utt_res1.resource_id resource_id,
          x_emp_r.person_id
        FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
        WHERE x_utt_res1.resource_id = r1.resource_id
          AND r1.resource_type = 2
          AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp,
       (SELECT
          x_utt_res2.standard_operation_id standard_operation_id,
          x_utt_res2.resource_id,
          x_eqp_r.inventory_item_id
        FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
        WHERE x_utt_res2.resource_id = r2.resource_id
        AND r2.resource_type = 1
        AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
     WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v,
    mtl_item_locations loc,
    mtl_secondary_inventories sub
       WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
    AND wdtv.organization_id = p_sign_on_org_id
    AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
    AND wdtv.zone = p_sign_on_zone --  removed NVL, bug 2648133
    AND NVL(wdtv.cartonization_id, -999) = NVL(l_cartonization_id, NVL(wdtv.cartonization_id, -999))
    AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
    AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
    AND wdtv.locator_id = loc.inventory_location_id(+)
    AND wdtv.zone = sub.secondary_inventory_name
    AND wdtv.organization_id = sub.organization_id
    --AND Nvl(wdtv.pick_slip_number, -1) <> l_pick_slip -- bug 2832818
    -- bug 4358107
    AND NOT EXISTS
         ( SELECT 1
           FROM WMS_DISPATCH_TASKS_GTMP
           WHERE (p_task_method = 'DISCRETE'
                  and
                  grouping_document_number = wdtv.pick_slip_number
                 )
                 or
                 (
                  p_task_method = 'ORDERPICK'
                  and
                  grouping_document_number = wdtv.transaction_source_id
                  and
                  grouping_source_type_id = wdtv.transaction_source_type_id
                 )
                 or
                 (p_task_method = 'PICKBYLABEL'
                  and
                  grouping_document_number = wdtv.cartonization_id
                 )
         )
    -- bug 4358107
    AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
         (SELECT NULL
          FROM mtl_material_transactions_temp mmtt
          WHERE mmtt.transaction_temp_id = wdtv.task_id
          AND mmtt.parent_line_id IS NOT NULL
               AND mmtt.parent_line_id <> mmtt.transaction_temp_id
          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
    AND NOT EXISTS -- exclude tasks already dispatched and queued
         (SELECT NULL
          FROM wms_dispatched_tasks wdt1
          WHERE wdt1.transaction_temp_id = wdtv.task_id
          AND wdt1.task_type = wdtv.wms_task_type_id)
    -- excluded skipped tasks
    AND wdtv.task_id NOT IN
         (SELECT wdtv.task_id
          FROM wms_skip_task_exceptions wste, mtl_parameters mp
          WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
          AND wste.task_id = wdtv.task_id
          AND wste.organization_id = mp.organization_id)
         --J Addition
             AND wdtv.zone not in (
                     SELECT wd.subinventory_code
                     FROM  wms_devices_b wd
                         , wms_bus_event_devices wbed
                     WHERE 1 = 1
                         and wd.device_id = wbed.device_id
                        AND wbed.organization_id = wd.organization_id
                        AND wd.enabled_flag   = 'Y'
                        AND wbed.enabled_flag = 'Y'
                        AND wbed.business_event_id = 10
                        AND wd.subinventory_code IS NOT NULL
                        AND wd.force_sign_on_flag = 'Y'
                        AND wd.device_id NOT IN (SELECT device_id
                                    FROM wms_device_assignment_temp
                                   WHERE employee_id = p_sign_on_emp_id)
                  )
       ORDER BY
    task_priority desc,
    task_status DESC,
    sub_picking_order,
         loc_picking_order,
    distance,
    task_num;

    -- Cursor #4 for selecting the most optimal task
    -- 1. Sub is not passed     (0)
    -- 2. Non cycle count tasks (1)
    -- 3. Cycle count tasks     (1)
    CURSOR l_curs_opt_task_011 IS
       SELECT DISTINCT
    qt.task_id task_num,
    qt.pick_slip,
    wdt.task_type wms_task_type_id,
    nvl(wdt.priority, 0) task_priority,
    Decode(l_sequence_picks_across_waves, 2, mol.header_id, NULL) batch_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    wdt.status task_status,  --bug 4310093
    qt.transaction_type_id,
    qt.transaction_action_id,
    qt.transaction_source_id,
    qt.transaction_source_type_id
       FROM wms_dispatched_tasks wdt,
            (SELECT
          transaction_temp_id task_id,
          pick_slip_number pick_slip,
               cartonization_id,
          organization_id,
               subinventory_code,
          locator_id,
          move_order_line_id,
          transaction_type_id,
          transaction_action_id,
          transaction_source_id,
          transaction_source_type_id
        FROM mtl_material_transactions_temp mmtt
        WHERE wms_task_type IS NOT NULL
             AND transaction_temp_id = Decode(p_task_method, 'BULK',
                                              parent_line_id, transaction_temp_id)
        AND Decode(transaction_source_type_id,
         2, l_so_allowed,
	 4, Decode(transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)), /*Bug#5188179*/
         5, Decode(transaction_type_id, 35, l_wip_allowed),
         8, l_io_allowed,
         13, Decode(transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
				    --7169220: USERS LOCKED
 	         AND (mmtt.cartonization_id is null
 	                                 or not exists
 	                                         (select 1 from mtl_material_transactions_temp mmtt1 ,wms_dispatched_tasks wdt1
 	                                         where mmtt1.transaction_temp_id <> mmtt.transaction_temp_id
 	                                         and wdt1.transaction_temp_id = mmtt1.transaction_temp_id
 	                                         and wdt1.status = 9
 	                                         and mmtt1.cartonization_id = mmtt.cartonization_id)
 	                                 )

        UNION ALL
        SELECT
          MIN(mcce.cycle_count_entry_id) task_id,
          TO_NUMBER(NULL) pick_slip,
          To_number(NULL) cartonization_id,
          mcce.organization_id,
          mcce.subinventory subinventory_code,
          mcce.locator_id,
          To_number(NULL) move_order_line_id,
          4 transaction_type_id,
          4 transaction_action_id,
          mcce.cycle_count_header_id transaction_source_id,
          9 transaction_source_type_id
        FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
        WHERE mcce.entry_status_code IN(1, 3)
          AND NVL(mcce.export_flag, 2) = 2
          -- bug 3972076
          --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
          AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
           -----bug6903708---
          AND mcce.organization_id = mcch.organization_id
          AND mcch.organization_id = p_sign_on_org_id
          ---------------------------
          AND NVL(mcch.disable_date,sysdate+1)> sysdate
          GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) qt,
       mtl_txn_request_lines mol,
       mtl_secondary_inventories sub,
       mtl_item_locations loc,
       (SELECT
          bsor.standard_operation_id,
          bre.resource_id,
          bre.inventory_item_id equipment_id
        FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
        WHERE bsor.resource_id = bre.resource_id
        AND br.resource_type = 1
        AND bsor.resource_id = br.resource_id) e
       WHERE wdt.transaction_temp_id = qt.task_id
    AND wdt.status in ( 2,3) -- Queued and dispatched tasks only bug 4310093
    AND wdt.person_id = p_sign_on_emp_id
    AND wdt.organization_id = p_sign_on_org_id
    AND NVL(qt.cartonization_id, -999) = NVL(l_cartonization_id, NVL(qt.cartonization_id, -999))
    AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))
    AND wdt.user_task_type = e.standard_operation_id(+)
    AND qt.move_order_line_id = mol.line_id(+)
    AND qt.organization_id = sub.organization_id
    AND qt.subinventory_code = sub.secondary_inventory_name
    AND qt.organization_id = loc.organization_id
    AND qt.locator_id = loc.inventory_location_id
       UNION ALL
       SELECT DISTINCT
    wdtv.task_id task_num,
    NVL(wdtv.pick_slip_number, -1) pick_slip,
    wdtv.wms_task_type_id,
    nvl(wdtv.task_priority, 0),
    Decode(l_sequence_picks_across_waves, 2, mol.header_id, NULL) batch_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    task_status,
         wdtv.transaction_type_id,
    wdtv.transaction_action_id,
    wdtv.transaction_source_id,
    wdtv.transaction_source_type_id
       FROM
    -- inlined wms_dispatchable_tasks_v, bug 2648133
    (SELECT
       transaction_temp_id task_id,
       standard_operation_id user_task_type_id,
       wms_task_type wms_task_type_id,
       organization_id,
       subinventory_code zone,
       locator_id,
       task_priority,
       revision,
       lot_number,
       transaction_uom,
       transaction_quantity,
       pick_rule_id,
       pick_slip_number,
       cartonization_id,
       inventory_item_id,
       move_order_line_id,
       1 task_status,
       transaction_type_id,
       transaction_action_id,
       transaction_source_id,
       transaction_source_type_id
     FROM mtl_material_transactions_temp mmtt
     WHERE wms_task_type IS NOT NULL
       AND transaction_status = 2
       AND(wms_task_status IS NULL OR wms_task_status = 1) --Added for task planning WB. bug#2651318
            AND transaction_temp_id = Decode(p_task_method, 'BULK',
                                             parent_line_id, transaction_temp_id)
            AND Decode(transaction_source_type_id,
             2, l_so_allowed,
             4, Decode(transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)), /*Bug#5188179*/
             5, Decode(transaction_type_id, 35, l_wip_allowed),
             8, l_io_allowed,
             13, Decode(transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
	--7169220: USERS LOCKED
 	         AND (mmtt.cartonization_id is null
 	                                 or not exists
 	                                         (select 1 from mtl_material_transactions_temp mmtt1 ,wms_dispatched_tasks wdt1
 	                                         where mmtt1.transaction_temp_id <> mmtt.transaction_temp_id
 	                                         and wdt1.transaction_temp_id = mmtt1.transaction_temp_id
 	                                         and wdt1.status = 9
 	                                         and mmtt1.cartonization_id = mmtt.cartonization_id)
 	                                 )

     UNION ALL
     SELECT
       MIN(mcce.cycle_count_entry_id) task_id,
       MIN(mcce.standard_operation_id) user_task_type_id,
       3 wms_task_type_id,
       mcce.organization_id,
       mcce.subinventory zone,
       mcce.locator_id,
       MIN(mcce.task_priority) task_priority,
       mcce.revision revision,
       MIN(mcce.lot_number) lot_number,
       '' transaction_uom,
       TO_NUMBER(NULL) transaction_quantity,
       TO_NUMBER(NULL) pick_rule_id,
       TO_NUMBER(NULL) pick_slip_number,
       TO_NUMBER(NULL) cartonization_id,
       mcce.inventory_item_id,
       TO_NUMBER(NULL) move_order_line_id,
       1 task_status,
       4 transaction_type_id,
       4 transaction_action_id,
       mcce.cycle_count_header_id transaction_source_id,
       9 transaction_source_type_id
     FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
     WHERE mcce.entry_status_code IN(1, 3)
       AND NVL(mcce.export_flag, 2) = 2
       -- bug 3972076
       --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
       AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
       AND NVL(mcch.disable_date,sysdate+1)> sysdate

      -----bug6903708---
      AND mcce.organization_id = mcch.organization_id
      AND mcch.organization_id = p_sign_on_org_id
       ---------------------------

     GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv,
    -- inlined wms_person_resource_utt_v, bug 2648133
    (SELECT
       utt_emp.standard_operation_id standard_operation_id,
       utt_emp.resource_id role,
       utt_eqp.resource_id equipment,
       utt_emp.person_id emp_id,
       utt_eqp.inventory_item_id eqp_id,
       NULL eqp_srl  /* removed for bug 2095237 */
     FROM
       (SELECT
          x_utt_res1.standard_operation_id standard_operation_id,
          x_utt_res1.resource_id resource_id,
          x_emp_r.person_id
        FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
        WHERE x_utt_res1.resource_id = r1.resource_id
          AND r1.resource_type = 2
          AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp,
       (SELECT
          x_utt_res2.standard_operation_id standard_operation_id,
          x_utt_res2.resource_id,
          x_eqp_r.inventory_item_id
        FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
        WHERE x_utt_res2.resource_id = r2.resource_id
        AND r2.resource_type = 1
        AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
     WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v,
    mtl_item_locations loc,
    mtl_secondary_inventories sub,
    mtl_txn_request_lines mol,
    mtl_txn_request_headers moh
       WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
    AND wdtv.organization_id = p_sign_on_org_id
    AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
    AND NVL(wdtv.cartonization_id, -999) = NVL(l_cartonization_id, NVL(wdtv.cartonization_id, -999))
    AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
    AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
    AND wdtv.locator_id = loc.inventory_location_id(+)
    AND wdtv.zone = sub.secondary_inventory_name
    AND wdtv.organization_id = sub.organization_id
    AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
    AND moh.header_id(+) = mol.header_id
    AND Decode(Nvl(moh.move_order_type, -1),
          2, l_rep_allowed,
          1, l_mot_moi_allowed,
          -1, 1,
          1) = 1
    --AND Nvl(wdtv.pick_slip_number, -1) <> l_pick_slip -- bug 2832818
    -- bug 4358107
    AND NOT EXISTS
         ( SELECT 1
           FROM WMS_DISPATCH_TASKS_GTMP
           WHERE (p_task_method = 'DISCRETE'
                  and
                  grouping_document_number = wdtv.pick_slip_number
                 )
                 or
                 (
                  p_task_method = 'ORDERPICK'
                  and
                  grouping_document_number = wdtv.transaction_source_id
                  and
                  grouping_source_type_id = wdtv.transaction_source_type_id
                 )
                 or
                 (p_task_method = 'PICKBYLABEL'
                  and
                  grouping_document_number = wdtv.cartonization_id
                 )
		 or    --6598260   start
		 ( grouping_document_number = wdtv.cartonization_id
		   and
		   grouping_document_type = 'CARTON_TASK'
		 )    --6598260   end
         )
    -- bug 4358107
    AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
         (SELECT NULL
          FROM mtl_material_transactions_temp mmtt
          WHERE mmtt.transaction_temp_id = wdtv.task_id
          AND mmtt.parent_line_id IS NOT NULL
               AND mmtt.parent_line_id <> mmtt.transaction_temp_id
          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
    AND NOT EXISTS -- exclude tasks already dispatched and queued
         (SELECT NULL
          FROM wms_dispatched_tasks wdt1
          WHERE wdt1.transaction_temp_id = wdtv.task_id
          AND wdt1.task_type = wdtv.wms_task_type_id)
    -- excluded skipped tasks
    AND wdtv.task_id NOT IN
         (SELECT wdtv.task_id
          FROM wms_skip_task_exceptions wste, mtl_parameters mp
          WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
          AND wste.task_id = wdtv.task_id
          AND wste.organization_id = mp.organization_id)
         --J Addition
    AND wdtv.zone not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
    )

       ORDER BY
    task_priority desc,
    batch_id,
    task_status DESC,
    sub_picking_order,
         loc_picking_order,
    distance,
    task_num;

    -- Cursor #5 for selecting the most optimal task
    -- 1. Sub is not passed     (0)
    -- 2. Non cycle count tasks (1)
    -- 3. Cycle count tasks     (0)
    CURSOR l_curs_opt_task_010 IS
       SELECT DISTINCT
    qt.task_id task_num,
    qt.pick_slip,
    wdt.task_type wms_task_type_id,
    nvl(wdt.priority, 0) task_priority,
    Decode(l_sequence_picks_across_waves, 2, mol.header_id, NULL) batch_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    wdt.status task_status,  --bug 4310093
    qt.transaction_type_id,
    qt.transaction_action_id,
    qt.transaction_source_id,
    qt.transaction_source_type_id
       FROM wms_dispatched_tasks wdt,
            (SELECT
          transaction_temp_id task_id,
          pick_slip_number pick_slip,
               cartonization_id,
          organization_id,
               subinventory_code,
          locator_id,
          move_order_line_id,
          transaction_type_id,
          transaction_action_id,
          transaction_source_id,
          transaction_source_type_id
        FROM mtl_material_transactions_temp mmtt
        WHERE wms_task_type IS NOT NULL
             AND transaction_temp_id = Decode(p_task_method, 'BULK',
                                              parent_line_id, transaction_temp_id)
        AND Decode(transaction_source_type_id,
         2, l_so_allowed,
         4, Decode(transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)), /*Bug#5188179*/
         5, Decode(transaction_type_id, 35, l_wip_allowed),
         8, l_io_allowed,
         13, Decode(transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
 	         --7169220: USERS LOCKED
 	         AND (mmtt.cartonization_id is null
 	                                 or not exists
 	                                         (select 1 from mtl_material_transactions_temp mmtt1 ,wms_dispatched_tasks wdt1
 	                                         where mmtt1.transaction_temp_id <> mmtt.transaction_temp_id
 	                                         and wdt1.transaction_temp_id = mmtt1.transaction_temp_id
 	                                         and wdt1.status = 9
 	                                         and mmtt1.cartonization_id = mmtt.cartonization_id)
 	                                 )
) qt,
       mtl_txn_request_lines mol,
       mtl_secondary_inventories sub,
       mtl_item_locations loc,
       (SELECT
          bsor.standard_operation_id,
          bre.resource_id,
          bre.inventory_item_id equipment_id
        FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
        WHERE bsor.resource_id = bre.resource_id
        AND br.resource_type = 1
        AND bsor.resource_id = br.resource_id) e
       WHERE wdt.transaction_temp_id = qt.task_id
    AND wdt.status = 2 -- bug 6326482 queued tasks only-- Queued and dispatched tasks only bug 4310093
    AND wdt.person_id = p_sign_on_emp_id
    AND wdt.organization_id = p_sign_on_org_id
    AND NVL(qt.cartonization_id, -999) = NVL(l_cartonization_id, NVL(qt.cartonization_id, -999))
    AND NVL(e.equipment_id, -999) = NVL(l_q_sign_on_equipment_id, NVL(e.equipment_id, -999))
    AND wdt.user_task_type = e.standard_operation_id(+)
    AND qt.move_order_line_id = mol.line_id(+)
    AND qt.organization_id = sub.organization_id
    AND qt.subinventory_code = sub.secondary_inventory_name
    AND qt.organization_id = loc.organization_id
    AND qt.locator_id = loc.inventory_location_id
     UNION ALL
       --bug 6326482 for dispatched tasks
       SELECT DISTINCT
    qt.task_id task_num,
    qt.pick_slip,
    wdt.task_type wms_task_type_id,
    nvl(wdt.priority, 0) task_priority,
    Decode(l_sequence_picks_across_waves, 2, mol.header_id, NULL) batch_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    wdt.status task_status,
    qt.transaction_type_id,
    qt.transaction_action_id,
    qt.transaction_source_id,
    qt.transaction_source_type_id
       FROM wms_dispatched_tasks wdt,
            (SELECT
          transaction_temp_id task_id,
	  wms_task_status task_status, -- bug 6326482 added to get the previous state of dispatched tasks
          pick_slip_number pick_slip,
               cartonization_id,
          organization_id,
               subinventory_code,
          locator_id,
          move_order_line_id,
          transaction_type_id,
          transaction_action_id,
          transaction_source_id,
          transaction_source_type_id
        FROM mtl_material_transactions_temp mmtt
        WHERE wms_task_type IS NOT NULL
             AND transaction_temp_id = Decode(p_task_method, 'BULK',
                                              parent_line_id, transaction_temp_id)
        AND Decode(transaction_source_type_id,
         2, l_so_allowed,
         4, Decode(transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)), /*Bug#5094839*/
         5, Decode(transaction_type_id, 35, l_wip_allowed),
         8, l_io_allowed,
         13, Decode(transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
    --7169220: USERS LOCKED
 	         AND (mmtt.cartonization_id is null
 	                                 or not exists
 	                                         (select 1 from mtl_material_transactions_temp mmtt1 ,wms_dispatched_tasks wdt1
 	                                         where mmtt1.transaction_temp_id <> mmtt.transaction_temp_id
 	                                         and wdt1.transaction_temp_id = mmtt1.transaction_temp_id
 	                                         and wdt1.status = 9
 	                                         and mmtt1.cartonization_id = mmtt.cartonization_id)
 	                                 )
) qt,
       mtl_txn_request_lines mol,
       mtl_secondary_inventories sub,
       mtl_item_locations loc,
       (SELECT
          bsor.standard_operation_id,
          bre.resource_id,
          bre.inventory_item_id equipment_id
        FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
        WHERE bsor.resource_id = bre.resource_id
        AND br.resource_type = 1
        AND bsor.resource_id = br.resource_id) e
       WHERE wdt.transaction_temp_id = qt.task_id
    AND wdt.status =3 -- bug 6326482 dispatched  tasks only
     AND wdt.person_id = p_sign_on_emp_id
    AND wdt.organization_id = p_sign_on_org_id
    AND NVL(qt.cartonization_id, -999) = NVL(l_cartonization_id, NVL(qt.cartonization_id, -999))
    --bug 6326482
  AND ((qt.task_status is NULL
    AND NVL(e.equipment_id, -999) = NVL(l_q_sign_on_equipment_id, NVL(e.equipment_id, -999)))
    or
    (qt.task_status = 1
    AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))))--bug 6326482
    AND wdt.user_task_type = e.standard_operation_id(+)
    AND qt.move_order_line_id = mol.line_id(+)
    AND qt.organization_id = sub.organization_id
    AND qt.subinventory_code = sub.secondary_inventory_name
    AND qt.organization_id = loc.organization_id
    AND qt.locator_id = loc.inventory_location_id
       UNION ALL
       SELECT DISTINCT
    wdtv.task_id task_num,
    NVL(wdtv.pick_slip_number, -1) pick_slip,
    wdtv.wms_task_type_id,
    nvl(wdtv.task_priority, 0),
    Decode(l_sequence_picks_across_waves, 2, mol.header_id, NULL) batch_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    task_status,
         wdtv.transaction_type_id,
    wdtv.transaction_action_id,
    wdtv.transaction_source_id,
    wdtv.transaction_source_type_id
       FROM
    -- inlined wms_dispatchable_tasks_v, bug 2648133
    (SELECT
       transaction_temp_id task_id,
       standard_operation_id user_task_type_id,
       wms_task_type wms_task_type_id,
       organization_id,
       subinventory_code zone,
       locator_id,
       task_priority,
       revision,
       lot_number,
       transaction_uom,
       transaction_quantity,
       pick_rule_id,
       pick_slip_number,
       cartonization_id,
       inventory_item_id,
       move_order_line_id,
       1 task_status,
       transaction_type_id,
       transaction_action_id,
       transaction_source_id,
       transaction_source_type_id
     FROM mtl_material_transactions_temp mmtt
     WHERE wms_task_type IS NOT NULL
       AND transaction_status = 2
       AND(wms_task_status IS NULL OR wms_task_status = 1) --Added for task planning WB. bug#2651318
            AND transaction_temp_id = Decode(p_task_method, 'BULK',
                                             parent_line_id, transaction_temp_id)
            AND Decode(transaction_source_type_id,
             2, l_so_allowed,
             4, Decode(transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)), /*Bug#5188179*/
             5, Decode(transaction_type_id, 35, l_wip_allowed),
             8, l_io_allowed,
             13, Decode(transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
	--7169220: USERS LOCKED
 	         AND (mmtt.cartonization_id is null
 	                                 or not exists
 	                                         (select 1 from mtl_material_transactions_temp mmtt1 ,wms_dispatched_tasks wdt1
 	                                         where mmtt1.transaction_temp_id <> mmtt.transaction_temp_id
 	                                         and wdt1.transaction_temp_id = mmtt1.transaction_temp_id
 	                                         and wdt1.status = 9
 	                                         and mmtt1.cartonization_id = mmtt.cartonization_id)
 	                                 )
) wdtv,
    -- inlined wms_person_resource_utt_v, bug 2648133
    (SELECT
       utt_emp.standard_operation_id standard_operation_id,
       utt_emp.resource_id role,
       utt_eqp.resource_id equipment,
       utt_emp.person_id emp_id,
       utt_eqp.inventory_item_id eqp_id,
       NULL eqp_srl  /* removed for bug 2095237 */
     FROM
       (SELECT
          x_utt_res1.standard_operation_id standard_operation_id,
          x_utt_res1.resource_id resource_id,
          x_emp_r.person_id
        FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
        WHERE x_utt_res1.resource_id = r1.resource_id
          AND r1.resource_type = 2
          AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp,
       (SELECT
          x_utt_res2.standard_operation_id standard_operation_id,
          x_utt_res2.resource_id,
          x_eqp_r.inventory_item_id
        FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
        WHERE x_utt_res2.resource_id = r2.resource_id
        AND r2.resource_type = 1
        AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
     WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v,
    mtl_item_locations loc,
    mtl_secondary_inventories sub,
    mtl_txn_request_lines mol,
    mtl_txn_request_headers moh
       WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
    AND wdtv.organization_id = p_sign_on_org_id
    AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
    AND NVL(wdtv.cartonization_id, -999) = NVL(l_cartonization_id, NVL(wdtv.cartonization_id, -999))
    AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
    AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
    AND wdtv.locator_id = loc.inventory_location_id(+)
    AND wdtv.zone = sub.secondary_inventory_name
    AND wdtv.organization_id = sub.organization_id
    AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
    AND moh.header_id(+) = mol.header_id
    AND Decode(Nvl(moh.move_order_type, -1),
          2, l_rep_allowed,
          1, l_mot_moi_allowed,
          -1, 1,
          1) = 1
    --AND Nvl(wdtv.pick_slip_number, -1) <> l_pick_slip -- bug 2832818
    -- bug 4358107
    AND NOT EXISTS
         ( SELECT 1
           FROM WMS_DISPATCH_TASKS_GTMP
           WHERE (p_task_method = 'DISCRETE'
                  and
                  grouping_document_number = wdtv.pick_slip_number
                 )
                 or
                 (
                  p_task_method = 'ORDERPICK'
                  and
                  grouping_document_number = wdtv.transaction_source_id
                  and
                  grouping_source_type_id = wdtv.transaction_source_type_id
                 )
                 or
                 (p_task_method = 'PICKBYLABEL'
                  and
                  grouping_document_number = wdtv.cartonization_id
                 )
		  or    --6598260   start
	         ( grouping_document_number = wdtv.cartonization_id
	           and
	           grouping_document_type = 'CARTON_TASK'
	         )     --6598260    end
         )
    -- bug 4358107
    AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
         (SELECT NULL
          FROM mtl_material_transactions_temp mmtt
          WHERE mmtt.transaction_temp_id = wdtv.task_id
          AND mmtt.parent_line_id IS NOT NULL
               AND mmtt.parent_line_id <> mmtt.transaction_temp_id
          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
    AND NOT EXISTS -- exclude tasks already dispatched and queued
         (SELECT NULL
          FROM wms_dispatched_tasks wdt1
          WHERE wdt1.transaction_temp_id = wdtv.task_id
          AND wdt1.task_type = wdtv.wms_task_type_id)
    -- excluded skipped tasks
    AND wdtv.task_id NOT IN
         (SELECT wdtv.task_id
          FROM wms_skip_task_exceptions wste, mtl_parameters mp
          WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
          AND wste.task_id = wdtv.task_id
          AND wste.organization_id = mp.organization_id)
         --J Addition
                AND wdtv.zone not in (
                        SELECT wd.subinventory_code
                        FROM  wms_devices_b wd
                            , wms_bus_event_devices wbed
                        WHERE 1 = 1
                            and wd.device_id = wbed.device_id
                           AND wbed.organization_id = wd.organization_id
                           AND wd.enabled_flag   = 'Y'
                           AND wbed.enabled_flag = 'Y'
                           AND wbed.business_event_id = 10
                           AND wd.subinventory_code IS NOT NULL
                           AND wd.force_sign_on_flag = 'Y'
                           AND wd.device_id NOT IN (SELECT device_id
                                       FROM wms_device_assignment_temp
                                      WHERE employee_id = p_sign_on_emp_id)
                     )
       ORDER BY
    task_priority desc,
    batch_id,
    task_status DESC,
    sub_picking_order,
         loc_picking_order,
    distance,
    task_num;

    -- Cursor #6 for selecting the most optimal task
    -- 1. Sub is not passed     (0)
    -- 2. Non cycle count tasks (0)
    -- 3. Cycle count tasks     (1)
    CURSOR l_curs_opt_task_001 IS
       SELECT DISTINCT
    qt.task_id task_num,
    qt.pick_slip,
    wdt.task_type wms_task_type_id,
    nvl(wdt.priority, 0) task_priority,
    To_number (NULL) batch_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    wdt.status task_status, --bug 4310093
    qt.transaction_type_id,
    qt.transaction_action_id,
    qt.transaction_source_id,
    qt.transaction_source_type_id
       FROM wms_dispatched_tasks wdt,
            (SELECT
          MIN(mcce.cycle_count_entry_id) task_id,
          TO_NUMBER(NULL) pick_slip,
          To_number(NULL) cartonization_id,
          mcce.organization_id,
          mcce.subinventory subinventory_code,
          mcce.locator_id,
          To_number(NULL) move_order_line_id,
               4 transaction_type_id,
          4 transaction_action_id,
          mcce.cycle_count_header_id transaction_source_id,
          9 transaction_source_type_id
        FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
        WHERE mcce.entry_status_code IN(1, 3)
          AND NVL(mcce.export_flag, 2) = 2
          -- bug 3972076
          --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
          AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
          AND NVL(mcch.disable_date,sysdate+1)> sysdate
          GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) qt,
       mtl_secondary_inventories sub,
       mtl_item_locations loc,
       (SELECT
          bsor.standard_operation_id,
          bre.resource_id,
          bre.inventory_item_id equipment_id
        FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
        WHERE bsor.resource_id = bre.resource_id
        AND br.resource_type = 1
        AND bsor.resource_id = br.resource_id) e
       WHERE wdt.transaction_temp_id = qt.task_id
    AND wdt.status in (2,3) -- Queued and dispatched tasks only bug 4310093
    AND wdt.person_id = p_sign_on_emp_id
    AND wdt.organization_id = p_sign_on_org_id
    AND NVL(qt.cartonization_id, -999) = NVL(l_cartonization_id, NVL(qt.cartonization_id, -999))
    AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))
    AND wdt.user_task_type = e.standard_operation_id(+)
    AND qt.organization_id = sub.organization_id
    AND qt.subinventory_code = sub.secondary_inventory_name
    AND qt.organization_id = loc.organization_id
    AND qt.locator_id = loc.inventory_location_id
       UNION ALL
       SELECT DISTINCT
    wdtv.task_id task_num,
    NVL(wdtv.pick_slip_number, -1) pick_slip,
    wdtv.wms_task_type_id,
    nvl(wdtv.task_priority, 0),
    To_number(NULL) batch_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    task_status,
         wdtv.transaction_type_id,
    wdtv.transaction_action_id,
    wdtv.transaction_source_id,
    wdtv.transaction_source_type_id
       FROM
    -- inlined wms_dispatchable_tasks_v, bug 2648133
    (SELECT
       MIN(mcce.cycle_count_entry_id) task_id,
       MIN(mcce.standard_operation_id) user_task_type_id,
       3 wms_task_type_id,
       mcce.organization_id,
       mcce.subinventory zone,
       mcce.locator_id,
       MIN(mcce.task_priority) task_priority,
       mcce.revision revision,
       MIN(mcce.lot_number) lot_number,
       '' transaction_uom,
       TO_NUMBER(NULL) transaction_quantity,
       TO_NUMBER(NULL) pick_rule_id,
       TO_NUMBER(NULL) pick_slip_number,
       TO_NUMBER(NULL) cartonization_id,
       mcce.inventory_item_id,
       TO_NUMBER(NULL) move_order_line_id,
       1 task_status,
       4 transaction_type_id,
       4 transaction_action_id,
       mcce.cycle_count_header_id transaction_source_id,
       9 transaction_source_type_id
     FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
     WHERE mcce.entry_status_code IN(1, 3)
       AND NVL(mcce.export_flag, 2) = 2
       -- bug 3972076
       --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
       AND mcce.cycle_count_header_id = mcch.cycle_count_header_id

      -----bug6903708---
      AND mcce.organization_id = mcch.organization_id
      AND mcch.organization_id = p_sign_on_org_id
       ---------------------------

       AND NVL(mcch.disable_date,sysdate+1)> sysdate
     GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv,
    -- inlined wms_person_resource_utt_v, bug 2648133
    (SELECT
       utt_emp.standard_operation_id standard_operation_id,
       utt_emp.resource_id role,
       utt_eqp.resource_id equipment,
       utt_emp.person_id emp_id,
       utt_eqp.inventory_item_id eqp_id,
       NULL eqp_srl  /* removed for bug 2095237 */
     FROM
       (SELECT
          x_utt_res1.standard_operation_id standard_operation_id,
          x_utt_res1.resource_id resource_id,
          x_emp_r.person_id
        FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
        WHERE x_utt_res1.resource_id = r1.resource_id
          AND r1.resource_type = 2
          AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp,
       (SELECT
          x_utt_res2.standard_operation_id standard_operation_id,
          x_utt_res2.resource_id,
          x_eqp_r.inventory_item_id
        FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
        WHERE x_utt_res2.resource_id = r2.resource_id
        AND r2.resource_type = 1
        AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
     WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v,
    mtl_item_locations loc,
    mtl_secondary_inventories sub
       WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
    AND wdtv.organization_id = p_sign_on_org_id
    AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
    AND NVL(wdtv.cartonization_id, -999) = NVL(l_cartonization_id, NVL(wdtv.cartonization_id, -999))
    AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
    AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
    AND wdtv.locator_id = loc.inventory_location_id(+)
    AND wdtv.zone = sub.secondary_inventory_name
    AND wdtv.organization_id = sub.organization_id
    --AND Nvl(wdtv.pick_slip_number, -1) <> l_pick_slip -- bug 2832818
    -- bug 4358107
    AND NOT EXISTS
         ( SELECT 1
           FROM WMS_DISPATCH_TASKS_GTMP
           WHERE (p_task_method = 'DISCRETE'
                  and
                  grouping_document_number = wdtv.pick_slip_number
                 )
                 or
                 (
                  p_task_method = 'ORDERPICK'
                  and
                  grouping_document_number = wdtv.transaction_source_id
                  and
                  grouping_source_type_id = wdtv.transaction_source_type_id
                 )
                 or
                 (p_task_method = 'PICKBYLABEL'
                  and
                  grouping_document_number = wdtv.cartonization_id
                 )
         )
    -- bug 4358107
    AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
         (SELECT NULL
          FROM mtl_material_transactions_temp mmtt
          WHERE mmtt.transaction_temp_id = wdtv.task_id
          AND mmtt.parent_line_id IS NOT NULL
               AND mmtt.parent_line_id <> mmtt.transaction_temp_id
          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
    AND NOT EXISTS -- exclude tasks already dispatched and queued
         (SELECT NULL
          FROM wms_dispatched_tasks wdt1
          WHERE wdt1.transaction_temp_id = wdtv.task_id
          AND wdt1.task_type = wdtv.wms_task_type_id)
    -- excluded skipped tasks
    AND wdtv.task_id NOT IN
         (SELECT wdtv.task_id
          FROM wms_skip_task_exceptions wste, mtl_parameters mp
          WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
          AND wste.task_id = wdtv.task_id
          AND wste.organization_id = mp.organization_id)
         --J Addition
    AND wdtv.zone not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
    )
       ORDER BY
    task_priority desc,
    task_status DESC,
    sub_picking_order,
         loc_picking_order,
    distance,
    task_num;


    -- Cursor #1 for selecting the ordered tasks
    -- 1. Non cycle count tasks (1)
    -- 2. Cycle count tasks     (1)
    CURSOR l_curs_ordered_tasks_11(v_pick_slip_number NUMBER,
               v_task_id NUMBER,
               v_task_type NUMBER,
               v_transaction_source_id NUMBER) IS
       SELECT DISTINCT
    qt.task_id task_num,
    qt.subinventory_code,
    qt.locator_id,
    qt.pick_slip,
    qt.transaction_uom,
    qt.transaction_quantity,
    qt.lot_number,
    qt.operation_plan_id,
    qt.standard_operation_id,
    wdt.effective_start_date,
    wdt.effective_end_date,
    wdt.person_resource_id,
    wdt.machine_resource_id,
    wdt.task_type wms_task_type_id,
    nvl(wdt.priority, 0) task_priority,
    Decode(l_sequence_picks_across_waves, 2, mol.header_id, NULL) batch_id,
    mol.line_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    wdt.status task_status,  --bug 4310093
    qt.transaction_type_id,
    qt.transaction_action_id,
    qt.transaction_source_id,
    qt.transaction_source_type_id
       FROM wms_dispatched_tasks wdt,
            (SELECT
          transaction_temp_id task_id,
          pick_slip_number pick_slip,
               cartonization_id,
          organization_id,
               subinventory_code,
          locator_id,
          inventory_item_id,
          revision,
          transaction_uom,
          transaction_quantity,
          lot_number,
          operation_plan_id,
          standard_operation_id,
          move_order_line_id,
          transaction_type_id,
          transaction_action_id,
          transaction_source_id,
          transaction_source_type_id,
 	  parent_line_id  --Added for Case Picking Project (Bulk Task check)
        FROM mtl_material_transactions_temp mmtt
        WHERE wms_task_type IS NOT NULL
             AND transaction_temp_id = Decode(p_task_method, 'BULK',
                                              parent_line_id, transaction_temp_id)
        AND Decode(transaction_source_type_id,
         2, l_so_allowed,
         4, Decode(transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)), /*Bug#5188179*/
         5, Decode(transaction_type_id, 35, l_wip_allowed),
         8, l_io_allowed,
         13, Decode(transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
  --7169220: USERS LOCKED
 	         AND (mmtt.cartonization_id is null
 	                                 or not exists
 	                                         (select 1 from mtl_material_transactions_temp mmtt1 ,wms_dispatched_tasks wdt1
 	                                         where mmtt1.transaction_temp_id <> mmtt.transaction_temp_id
 	                                         and wdt1.transaction_temp_id = mmtt1.transaction_temp_id
 	                                         and wdt1.status = 9
 	                                         and mmtt1.cartonization_id = mmtt.cartonization_id)
 	                                 )


        UNION ALL
        SELECT
          MIN(mcce.cycle_count_entry_id) task_id,
          TO_NUMBER(NULL) pick_slip,
          To_number(NULL) cartonization_id,
          mcce.organization_id,
          mcce.subinventory subinventory_code,
          mcce.locator_id,
          mcce.inventory_item_id,
          mcce.revision,
          To_char(NULL) transaction_uom,
          To_number(NULL) transaction_quantity,
          MIN(mcce.lot_number) lot_number,
          To_number(NULL) operation_plan_id,
          MIN(mcce.standard_operation_id) standard_operation_id,
          To_number(NULL) move_order_line_id,
               4 transaction_type_id,
          4 transaction_action_id,
          mcce.cycle_count_header_id transaction_source_id,
          9 transaction_source_type_id,
	  TO_NUMBER(NULL) parent_line_id  --Added for Case Picking Project (Bulk Task check)
        FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
        WHERE mcce.entry_status_code IN(1, 3)
          AND NVL(mcce.export_flag, 2) = 2
          -- bug 3972076
          --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
          AND mcce.cycle_count_header_id = mcch.cycle_count_header_id

           -----bug6903708---
           AND mcce.organization_id = mcch.organization_id
           AND mcch.organization_id = p_sign_on_org_id
           ---------------------------

          AND NVL(mcch.disable_date,sysdate+1)> sysdate
          GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) qt,
       mtl_txn_request_lines mol,
       mtl_secondary_inventories sub,
       mtl_item_locations loc,
       (SELECT
          bsor.standard_operation_id,
          bre.resource_id,
          bre.inventory_item_id equipment_id
        FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
        WHERE bsor.resource_id = bre.resource_id
        AND br.resource_type = 1
        AND bsor.resource_id = br.resource_id) e
       WHERE wdt.transaction_temp_id = qt.task_id
    AND wdt.status in ( 2,3) -- Queued and dispatched tasks only bug 4310093
    AND wdt.person_id = p_sign_on_emp_id
         AND wdt.organization_id = p_sign_on_org_id
    AND ((qt.pick_slip = v_pick_slip_number AND p_task_method = 'DISCRETE')
         OR (p_task_method IN ('MANUAL', 'WAVE', 'BULK', 'DISCRETE')
                  AND qt.task_id = v_task_id AND wdt.task_type = v_task_type)
         OR (p_task_method = 'ORDERPICK'
                  AND Decode(qt.transaction_source_type_id,
                             2, qt.transaction_source_id,
                             5, Decode(qt.transaction_type_id, 35, qt.transaction_source_id),
                             8, qt.transaction_source_id,
                             13, Decode(qt.transaction_type_id, 51, qt.transaction_source_id),
                             -1) = nvl(v_transaction_source_id, -1))
        OR (p_task_method = 'PICKBYLABEL' AND qt.cartonization_id = l_cartonization_id)
        OR (p_task_method = 'CLUSTERPICKBYLABEL' AND
            qt.cartonization_id IN (SELECT * FROM TABLE(wms_picking_pkg.list_cartonization_id)))
        --Added for Case Picking Project start
        OR ( p_task_method = 'MANIFESTORDER' AND
	      qt.transaction_source_id IN (
                                        SELECT   MMTT.TRANSACTION_SOURCE_ID
                                        FROM     MTL_SALES_ORDERS MSO    ,
                                                MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
                                        WHERE  MMTT.TRANSACTION_SOURCE_ID = MSO.SALES_ORDER_ID
                                            AND MSO.SEGMENT1 IN ( SELECT *  FROM TABLE(WMS_PICKING_PKG.LIST_ORDER_NUMBERS))
                                           )
	       and qt.parent_line_id IS NULL  -- Added for bulk task
	      )
        OR (p_task_method = 'MANIFESTPICKSLIP'
	     AND qt.pick_slip IN (SELECT * FROM TABLE(wms_picking_pkg.list_pick_slip_numbers))
	     and qt.parent_line_id IS NULL  -- Added for bulk task
	   )
        --Added for Case Picking Project end
        )
    -- Bug: 7254397
    AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))
    AND wdt.user_task_type = e.standard_operation_id(+)
    AND qt.move_order_line_id = mol.line_id(+)
    AND NVL(qt.subinventory_code, '@@@') = NVL(p_sign_on_zone, NVL(qt.subinventory_code, '@@@'))
    AND qt.organization_id = sub.organization_id
    AND qt.subinventory_code = sub.secondary_inventory_name
    AND qt.organization_id = loc.organization_id
    AND qt.locator_id = loc.inventory_location_id
       UNION ALL
       SELECT DISTINCT
    wdtv.task_id task_num,
    wdtv.subinventory_code,
    wdtv.locator_id,
    NVL(wdtv.pick_slip_number, -1) pick_slip,
    wdtv.transaction_uom,
    wdtv.transaction_quantity,
    wdtv.lot_number,
    wdtv.operation_plan_id,
    wdtv.user_task_type_id standard_operation_id,
    v.effective_start_date,
    v.effective_end_date,
    v.role person_resource_id,
    v.equipment machine_resource_id,
    wdtv.wms_task_type_id,
    nvl(wdtv.task_priority, 0),
    Decode(l_sequence_picks_across_waves, 2, mol.header_id, NULL) batch_id,
         mol.line_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    task_status,
         wdtv.transaction_type_id,
    wdtv.transaction_action_id,
    wdtv.transaction_source_id,
    wdtv.transaction_source_type_id
       FROM
    -- inlined wms_dispatchable_tasks_v, bug 2648133
    (SELECT
       transaction_temp_id task_id,
       standard_operation_id user_task_type_id,
       wms_task_type wms_task_type_id,
       organization_id,
       subinventory_code,
       locator_id,
       task_priority,
       revision,
       lot_number,
       transaction_uom,
       transaction_quantity,
       pick_rule_id,
       pick_slip_number,
       cartonization_id,
       inventory_item_id,
       move_order_line_id,
       1 task_status,
       transaction_type_id,
       transaction_action_id,
       transaction_source_id,
       transaction_source_type_id,
       operation_plan_id,
       parent_line_id  --Added for Case Picking Project (Bulk Task check)
     FROM mtl_material_transactions_temp mmtt
     WHERE wms_task_type IS NOT NULL
       AND transaction_status = 2
       AND(wms_task_status IS NULL OR wms_task_status = 1) --Added for task planning WB. bug#2651318
            AND transaction_temp_id = Decode(p_task_method, 'BULK',
                                             parent_line_id, transaction_temp_id)
            AND Decode(transaction_source_type_id,
             2, l_so_allowed,
             4, Decode(transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)), /*Bug#5188179*/
             5, Decode(transaction_type_id, 35, l_wip_allowed),
             8, l_io_allowed,
             13, Decode(transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
				          --7169220: USERS LOCKED
 	         AND (mmtt.cartonization_id is null
 	                                 or not exists
 	                                         (select 1 from mtl_material_transactions_temp mmtt1 ,wms_dispatched_tasks wdt1
 	                                         where mmtt1.transaction_temp_id <> mmtt.transaction_temp_id
 	                                         and wdt1.transaction_temp_id = mmtt1.transaction_temp_id
 	                                         and wdt1.status = 9
 	                                         and mmtt1.cartonization_id = mmtt.cartonization_id)
 	                                 )

     UNION ALL
     SELECT
       MIN(mcce.cycle_count_entry_id) task_id,
       MIN(mcce.standard_operation_id) user_task_type_id,
       3 wms_task_type_id,
       mcce.organization_id,
       mcce.subinventory subinventory_code,
       mcce.locator_id,
       MIN(mcce.task_priority) task_priority,
       mcce.revision revision,
       MIN(mcce.lot_number) lot_number,
       '' transaction_uom,
       TO_NUMBER(NULL) transaction_quantity,
       TO_NUMBER(NULL) pick_rule_id,
       TO_NUMBER(NULL) pick_slip_number,
       TO_NUMBER(NULL) cartonization_id,
       mcce.inventory_item_id,
       TO_NUMBER(NULL) move_order_line_id,
       1 task_status,
       4 transaction_type_id,
       4 transaction_action_id,
       mcce.cycle_count_header_id transaction_source_id,
       9 transaction_source_type_id,
       To_number(NULL) operation_plan_id,
       TO_NUMBER(NULL) parent_line_id  --Added for Case Picking Project (Bulk Task check)
     FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
     WHERE mcce.entry_status_code IN(1, 3)
       AND NVL(mcce.export_flag, 2) = 2
       -- bug 3972076
       --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
       AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
        -----bug6903708---
       AND mcce.organization_id = mcch.organization_id
       AND mcch.organization_id = p_sign_on_org_id
        ---------------------------

       AND NVL(mcch.disable_date,sysdate+1)> sysdate
     GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv,
    -- inlined wms_person_resource_utt_v, bug 2648133
    (SELECT
       utt_emp.standard_operation_id standard_operation_id,
       min(utt_emp.resource_id) role,      --Modified for Case Picking Project  + Picking ER (FP 7709357)
       min(utt_eqp.resource_id) equipment, --Modified for Case Picking Project  + Picking ER (FP 7709357)
       utt_emp.person_id emp_id,
       utt_emp.effective_start_date,
       utt_emp.effective_end_date,
       --utt_eqp.inventory_item_id eqp_id, --Modified for Case Picking Project  + Picking ER (FP 7709357)
       NULL eqp_srl  /* removed for bug 2095237 */
     FROM
       (SELECT
          x_utt_res1.standard_operation_id standard_operation_id,
          x_utt_res1.resource_id resource_id,
          x_emp_r.person_id,
          x_emp_r.effective_start_date,
               x_emp_r.effective_end_date
        FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
        WHERE x_utt_res1.resource_id = r1.resource_id
          AND r1.resource_type = 2
          AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp,
       (SELECT
          x_utt_res2.standard_operation_id standard_operation_id,
          x_utt_res2.resource_id,
          x_eqp_r.inventory_item_id
        FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
        WHERE x_utt_res2.resource_id = r2.resource_id
        AND r2.resource_type = 1
        AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
     WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)
     AND NVL(utt_eqp.inventory_item_id, -999) = NVL(l_sign_on_equipment_id, NVL(utt_eqp.inventory_item_id, -999)) --Modified for Case Picking Project  + Picking ER (FP 7709357)
     GROUP BY utt_emp.standard_operation_id, utt_emp.person_id, utt_emp.effective_start_date, utt_emp.effective_end_date) v,
    mtl_item_locations loc,
    mtl_secondary_inventories sub,
    mtl_txn_request_lines mol,
    mtl_txn_request_headers moh
       WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
    AND ((wdtv.pick_slip_number = v_pick_slip_number AND p_task_method = 'DISCRETE')
         OR (p_task_method IN ('MANUAL', 'WAVE', 'BULK', 'DISCRETE')
                  AND wdtv.task_id = v_task_id AND wdtv.wms_task_type_id = v_task_type)
         OR (p_task_method = 'ORDERPICK'
                  AND Decode(wdtv.transaction_source_type_id,
                             2, wdtv.transaction_source_id,
                             5, Decode(wdtv.transaction_type_id, 35, wdtv.transaction_source_id),
                             8, wdtv.transaction_source_id,
                             13, Decode(wdtv.transaction_type_id, 51, wdtv.transaction_source_id),
                             -1) = nvl(v_transaction_source_id, -1))
        OR (p_task_method = 'PICKBYLABEL' AND wdtv.cartonization_id = l_cartonization_id)
        OR (p_task_method = 'CLUSTERPICKBYLABEL' AND
            wdtv.cartonization_id IN (SELECT * FROM TABLE(wms_picking_pkg.list_cartonization_id)))
	--Added for Case Picking Project start
        OR ( p_task_method = 'MANIFESTORDER' AND
	      wdtv.transaction_source_id IN (
                                        SELECT   MMTT.TRANSACTION_SOURCE_ID
                                        FROM     MTL_SALES_ORDERS MSO    ,
                                                MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
                                        WHERE  MMTT.TRANSACTION_SOURCE_ID = MSO.SALES_ORDER_ID
                                            AND MSO.SEGMENT1 IN ( SELECT *  FROM TABLE(WMS_PICKING_PKG.LIST_ORDER_NUMBERS))
                                    )
	       and wdtv.parent_line_id IS NULL  -- Added for bulk task
	    )
        OR (p_task_method = 'MANIFESTPICKSLIP'
	      AND wdtv.pick_slip_number IN (SELECT * FROM TABLE(wms_picking_pkg.list_pick_slip_numbers))
	      and wdtv.parent_line_id IS NULL  -- Added for bulk task
	    )
         --Added for Case Picking Project end
      )
    AND wdtv.organization_id = p_sign_on_org_id
    AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
    AND NVL(wdtv.subinventory_code, '@@@') = NVL(p_sign_on_zone, NVL(wdtv.subinventory_code, '@@@'))   AND NVL(wdtv.cartonization_id, -999) = NVL(l_cartonization_id, NVL(wdtv.cartonization_id, -999))
    --AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999)) --Modified above for Case Picking Project  + Picking ER (FP 7709357)
    AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
    AND wdtv.locator_id = loc.inventory_location_id(+)
    AND wdtv.subinventory_code = sub.secondary_inventory_name
    AND wdtv.organization_id = sub.organization_id
    AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
    AND moh.header_id(+) = mol.header_id
    AND Decode(Nvl(moh.move_order_type, -1),
          2, l_rep_allowed,
          1, l_mot_moi_allowed,
          -1, 1,
          1) = 1
    AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
         (SELECT NULL
          FROM mtl_material_transactions_temp mmtt
          WHERE mmtt.transaction_temp_id = wdtv.task_id
          AND mmtt.parent_line_id IS NOT NULL
               AND mmtt.parent_line_id <> mmtt.transaction_temp_id
          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
    AND NOT EXISTS -- exclude tasks already dispatched and queued
         (SELECT NULL
          FROM wms_dispatched_tasks wdt1
          WHERE wdt1.transaction_temp_id = wdtv.task_id
          AND wdt1.task_type = wdtv.wms_task_type_id)
    -- Bug 7254397: exclude tasks from locked cartons
    AND NOT EXISTS
        ( SELECT 1
           FROM WMS_DISPATCH_TASKS_GTMP
           WHERE p_task_method = 'CLUSTERPICKBYLABEL'
                AND
                  grouping_document_number = wdtv.cartonization_id)
    --Added for Case Picking Project start
    AND NOT EXISTS
        ( SELECT 1
           FROM WMS_DISPATCH_TASKS_GTMP
           WHERE p_task_method = 'MANIFESTPICKSLIP'
                AND grouping_document_number = wdtv.pick_slip_number)
    AND NOT EXISTS
        ( SELECT 1
           FROM WMS_DISPATCH_TASKS_GTMP
           WHERE p_task_method = 'MANIFESTORDER'
                 AND grouping_document_number = wdtv.transaction_source_id)
   --Added for Case Picking Project end
    -- excluded skipped tasks
    AND wdtv.task_id NOT IN
         (SELECT wdtv.task_id
          FROM wms_skip_task_exceptions wste, mtl_parameters mp
          WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
          AND wste.task_id = wdtv.task_id
          AND wste.organization_id = mp.organization_id)
         --J Addition
    AND wdtv.subinventory_code not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
    )
    ORDER BY
         sub_picking_order,
    loc_picking_order,
    distance,
    task_priority desc,
    batch_id,
    task_status DESC,
    task_num;


    -- Cursor #2 for selecting the ordered tasks
    -- 1. Non cycle count tasks (1)
    -- 2. Cycle count tasks     (0)
    CURSOR l_curs_ordered_tasks_10(v_pick_slip_number NUMBER,
               v_task_id NUMBER,
               v_task_type NUMBER,
               v_transaction_source_id NUMBER) IS
       SELECT DISTINCT
    qt.task_id task_num,
    qt.subinventory_code,
    qt.locator_id,
    qt.pick_slip,
    qt.transaction_uom,
    qt.transaction_quantity,
    qt.lot_number,
    qt.operation_plan_id,
    qt.standard_operation_id,
    wdt.effective_start_date,
    wdt.effective_end_date,
    wdt.person_resource_id,
    wdt.machine_resource_id,
    wdt.task_type wms_task_type_id,
    nvl(wdt.priority, 0) task_priority,
    Decode(l_sequence_picks_across_waves, 2, mol.header_id, NULL) batch_id,
    mol.line_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    wdt.status task_status,  --bug 4310093
    qt.transaction_type_id,
    qt.transaction_action_id,
    qt.transaction_source_id,
    qt.transaction_source_type_id
       FROM wms_dispatched_tasks wdt,
            (SELECT
          transaction_temp_id task_id,
          pick_slip_number pick_slip,
               cartonization_id,
          organization_id,
               subinventory_code,
          locator_id,
          inventory_item_id,
          revision,
          transaction_uom,
          transaction_quantity,
          lot_number,
          operation_plan_id,
          standard_operation_id,
          move_order_line_id,
          transaction_type_id,
          transaction_action_id,
          transaction_source_id,
          transaction_source_type_id,
	  parent_line_id  --Added for Case Picking Project (Bulk Task check)
        FROM mtl_material_transactions_temp mmtt
        WHERE wms_task_type IS NOT NULL
             AND transaction_temp_id = Decode(p_task_method, 'BULK',
                                              parent_line_id, transaction_temp_id)
        AND Decode(transaction_source_type_id,
         2, l_so_allowed,
	 4, Decode(transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)), /*Bug#5188179*/
         5, Decode(transaction_type_id, 35, l_wip_allowed),
         8, l_io_allowed,
         13, Decode(transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
                      --7169220: USERS LOCKED
 	         AND (mmtt.cartonization_id is null
 	                                 or not exists
 	                                         (select 1 from mtl_material_transactions_temp mmtt1 ,wms_dispatched_tasks wdt1
 	                                         where mmtt1.transaction_temp_id <> mmtt.transaction_temp_id
 	                                         and wdt1.transaction_temp_id = mmtt1.transaction_temp_id
 	                                         and wdt1.status = 9
 	                                         and mmtt1.cartonization_id = mmtt.cartonization_id)
 	                                 )
	       ) qt,
       mtl_txn_request_lines mol,
       mtl_secondary_inventories sub,
       mtl_item_locations loc,
       (SELECT
          bsor.standard_operation_id,
          bre.resource_id,
          bre.inventory_item_id equipment_id
        FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
        WHERE bsor.resource_id = bre.resource_id
        AND br.resource_type = 1
        AND bsor.resource_id = br.resource_id) e
       WHERE wdt.transaction_temp_id = qt.task_id
    AND wdt.status = 2 --bug 6326482 queued task only -- Queued and dispatched  tasks only bug 4310093
    AND wdt.person_id = p_sign_on_emp_id
    AND wdt.organization_id = p_sign_on_org_id
    AND ((qt.pick_slip = v_pick_slip_number AND p_task_method = 'DISCRETE')
         OR (p_task_method IN ('MANUAL', 'WAVE', 'BULK', 'DISCRETE')
                  AND qt.task_id = v_task_id AND wdt.task_type = v_task_type)
              OR (p_task_method = 'ORDERPICK'
                  AND Decode(qt.transaction_source_type_id,
                             2, qt.transaction_source_id,
                             5, Decode(qt.transaction_type_id, 35, qt.transaction_source_id),
                             8, qt.transaction_source_id,
                             13, Decode(qt.transaction_type_id, 51, qt.transaction_source_id),
                             -1) = nvl(v_transaction_source_id, -1))
              OR (p_task_method = 'PICKBYLABEL' AND qt.cartonization_id = l_cartonization_id)
              OR (p_task_method = 'CLUSTERPICKBYLABEL' AND
           	  qt.cartonization_id IN (SELECT * FROM TABLE(wms_picking_pkg.list_cartonization_id)))
	       --Added for Case Picking Project start
	      OR ( p_task_method = 'MANIFESTORDER' AND
	           qt.transaction_source_id IN (
					      SELECT   MMTT.TRANSACTION_SOURCE_ID
					      FROM     MTL_SALES_ORDERS MSO    ,
						      MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
					      WHERE  MMTT.TRANSACTION_SOURCE_ID = MSO.SALES_ORDER_ID
						  AND MSO.SEGMENT1 IN ( SELECT *  FROM TABLE(WMS_PICKING_PKG.LIST_ORDER_NUMBERS))
					  )
		    and qt.parent_line_id IS NULL  -- Added for bulk task
		  )
		OR (p_task_method = 'MANIFESTPICKSLIP'
		    AND qt.pick_slip IN (SELECT * FROM TABLE(wms_picking_pkg.list_pick_slip_numbers))
		    and qt.parent_line_id IS NULL -- Added for bulk task
		   )
		--Added for Case Picking Project end
	        )
    AND NVL(e.equipment_id, -999) = NVL(l_q_sign_on_equipment_id, NVL(e.equipment_id, -999))--bug 6326482
    AND wdt.user_task_type = e.standard_operation_id(+)
    AND qt.move_order_line_id = mol.line_id(+)
    AND NVL(qt.subinventory_code, '@@@') = NVL(p_sign_on_zone, NVL(qt.subinventory_code, '@@@'))
    AND qt.organization_id = sub.organization_id
    AND qt.subinventory_code = sub.secondary_inventory_name
    AND qt.organization_id = loc.organization_id
    AND qt.locator_id = loc.inventory_location_id
      UNION ALL
       --bug 6326482
      SELECT DISTINCT
    qt.task_id task_num,
    qt.subinventory_code,
    qt.locator_id,
    qt.pick_slip,
    qt.transaction_uom,
    qt.transaction_quantity,
    qt.lot_number,
    qt.operation_plan_id,
    qt.standard_operation_id,
    wdt.effective_start_date,
    wdt.effective_end_date,
    wdt.person_resource_id,
    wdt.machine_resource_id,
    wdt.task_type wms_task_type_id,
    nvl(wdt.priority, 0) task_priority,
    Decode(l_sequence_picks_across_waves, 2, mol.header_id, NULL) batch_id,
    mol.line_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    wdt.status task_status,
    qt.transaction_type_id,
    qt.transaction_action_id,
    qt.transaction_source_id,
    qt.transaction_source_type_id
       FROM wms_dispatched_tasks wdt,
            (SELECT
          transaction_temp_id task_id,
	  wms_task_status task_status, --bug 6326482 added to check for the previous state of dispatched tasks
          pick_slip_number pick_slip,
               cartonization_id,
          organization_id,
               subinventory_code,
          locator_id,
          inventory_item_id,
          revision,
          transaction_uom,
          transaction_quantity,
          lot_number,
          operation_plan_id,
          standard_operation_id,
          move_order_line_id,
          transaction_type_id,
          transaction_action_id,
          transaction_source_id,
          transaction_source_type_id,
	  parent_line_id  --Added for Case Picking Project (Bulk Task check)
        FROM mtl_material_transactions_temp mmtt
        WHERE wms_task_type IS NOT NULL
             AND transaction_temp_id = Decode(p_task_method, 'BULK',
                                              parent_line_id, transaction_temp_id)
        AND Decode(transaction_source_type_id,
         2, l_so_allowed,
         4, Decode(transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)), /*Bug#5094839*/
         5, Decode(transaction_type_id, 35, l_wip_allowed),
         8, l_io_allowed,
         13, Decode(transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
                    --7169220: USERS LOCKED
 	         AND (mmtt.cartonization_id is null
 	                                 or not exists
 	                                         (select 1 from mtl_material_transactions_temp mmtt1 ,wms_dispatched_tasks wdt1
 	                                         where mmtt1.transaction_temp_id <> mmtt.transaction_temp_id
 	                                         and wdt1.transaction_temp_id = mmtt1.transaction_temp_id
 	                                         and wdt1.status = 9
 	                                         and mmtt1.cartonization_id = mmtt.cartonization_id)
 	                                 )
	       ) qt,
       mtl_txn_request_lines mol,
       mtl_secondary_inventories sub,
       mtl_item_locations loc,
       (SELECT
          bsor.standard_operation_id,
          bre.resource_id,
          bre.inventory_item_id equipment_id
        FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
        WHERE bsor.resource_id = bre.resource_id
        AND br.resource_type = 1
        AND bsor.resource_id = br.resource_id) e
       WHERE wdt.transaction_temp_id = qt.task_id
    AND wdt.status = 3 -- bug 6326482 dispatched  tasks
    AND wdt.person_id = p_sign_on_emp_id
    AND wdt.organization_id = p_sign_on_org_id
    AND ((qt.pick_slip = v_pick_slip_number AND p_task_method = 'DISCRETE')
         OR (p_task_method IN ('MANUAL', 'WAVE', 'BULK', 'DISCRETE')
                  AND qt.task_id = v_task_id AND wdt.task_type = v_task_type)
              OR (p_task_method = 'ORDERPICK'
                  AND Decode(qt.transaction_source_type_id,
                             2, qt.transaction_source_id,
                             5, Decode(qt.transaction_type_id, 35, qt.transaction_source_id),
                             8, qt.transaction_source_id,
                             13, Decode(qt.transaction_type_id, 51, qt.transaction_source_id),
                             -1) = nvl(v_transaction_source_id, -1))
              OR (p_task_method = 'PICKBYLABEL' AND qt.cartonization_id = l_cartonization_id)
        OR (p_task_method = 'CLUSTERPICKBYLABEL' AND
            qt.cartonization_id IN (SELECT * FROM TABLE(wms_picking_pkg.list_cartonization_id)))
      	--Added for Case Picking Project start
        OR ( p_task_method = 'MANIFESTORDER' AND
	      qt.transaction_source_id IN (
                                        SELECT   MMTT.TRANSACTION_SOURCE_ID
                                        FROM     MTL_SALES_ORDERS MSO    ,
                                                MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
                                        WHERE  MMTT.TRANSACTION_SOURCE_ID = MSO.SALES_ORDER_ID
                                            AND MSO.SEGMENT1 IN ( SELECT *  FROM TABLE(WMS_PICKING_PKG.LIST_ORDER_NUMBERS))
                                    )
	      and qt.parent_line_id IS NULL -- Added for bulk task
	    )
        OR (p_task_method = 'MANIFESTPICKSLIP' AND
	     qt.pick_slip IN (SELECT * FROM TABLE(wms_picking_pkg.list_pick_slip_numbers))
	     and qt.parent_line_id IS NULL -- Added for bulk task
	   )
        --Added for Case Picking Project end
       )
	     -- -bug 6326482
 AND ((qt.task_status is NULL
    AND NVL(e.equipment_id, -999) = NVL(l_q_sign_on_equipment_id, NVL(e.equipment_id, -999)))
    or
    (qt.task_status = 1
    AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))))--bug 6326482
    AND wdt.user_task_type = e.standard_operation_id(+)
    AND qt.move_order_line_id = mol.line_id(+)
    AND NVL(qt.subinventory_code, '@@@') = NVL(p_sign_on_zone, NVL(qt.subinventory_code, '@@@'))
    AND qt.organization_id = sub.organization_id
    AND qt.subinventory_code = sub.secondary_inventory_name
    AND qt.organization_id = loc.organization_id
    AND qt.locator_id = loc.inventory_location_id
       UNION ALL
       SELECT DISTINCT
    wdtv.task_id task_num,
    wdtv.subinventory_code,
    wdtv.locator_id,
    NVL(wdtv.pick_slip_number, -1) pick_slip,
    wdtv.transaction_uom,
    wdtv.transaction_quantity,
    wdtv.lot_number,
    wdtv.operation_plan_id,
    wdtv.user_task_type_id standard_operation_id,
    v.effective_start_date,
    v.effective_end_date,
    v.role person_resource_id,
    v.equipment machine_resource_id,
    wdtv.wms_task_type_id,
    nvl(wdtv.task_priority, 0),
    Decode(l_sequence_picks_across_waves, 2, mol.header_id, NULL) batch_id,
         mol.line_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    task_status,
         wdtv.transaction_type_id,
    wdtv.transaction_action_id,
    wdtv.transaction_source_id,
    wdtv.transaction_source_type_id
       FROM
    -- inlined wms_dispatchable_tasks_v, bug 2648133
    (SELECT
       transaction_temp_id task_id,
       standard_operation_id user_task_type_id,
       wms_task_type wms_task_type_id,
       organization_id,
       subinventory_code,
       locator_id,
       task_priority,
       revision,
       lot_number,
       transaction_uom,
       transaction_quantity,
       pick_rule_id,
       pick_slip_number,
       cartonization_id,
       inventory_item_id,
       move_order_line_id,
       1 task_status,
       transaction_type_id,
       transaction_action_id,
       transaction_source_id,
       transaction_source_type_id,
       operation_plan_id,
       parent_line_id  --Added for Case Picking Project (Bulk Task check)
     FROM mtl_material_transactions_temp mmtt
     WHERE wms_task_type IS NOT NULL
       AND transaction_status = 2
       AND(wms_task_status IS NULL OR wms_task_status = 1) --Added for task planning WB. bug#2651318
            AND transaction_temp_id = Decode(p_task_method, 'BULK',
                                             parent_line_id, transaction_temp_id)
            AND Decode(transaction_source_type_id,
             2, l_so_allowed,
	     4, Decode(transaction_action_id, 1, l_moi_allowed, 2, decode(wms_task_type, 4, l_rep_allowed, l_mot_allowed)), /*Bug#5188179*/
             5, Decode(transaction_type_id, 35, l_wip_allowed),
             8, l_io_allowed,
             13, Decode(transaction_type_id,
                                   51, l_wip_allowed,
                                   Decode(transaction_action_id, 2, decode(wms_task_type, 4, l_rep_allowed)))) = 1
				    --7169220: USERS LOCKED
 	         AND (mmtt.cartonization_id is null
 	                                 or not exists
 	                                         (select 1 from mtl_material_transactions_temp mmtt1 ,wms_dispatched_tasks wdt1
 	                                         where mmtt1.transaction_temp_id <> mmtt.transaction_temp_id
 	                                         and wdt1.transaction_temp_id = mmtt1.transaction_temp_id
 	                                         and wdt1.status = 9
 	                                         and mmtt1.cartonization_id = mmtt.cartonization_id)
 	                                 )
	) wdtv,
    -- inlined wms_person_resource_utt_v, bug 2648133
    (SELECT
       utt_emp.standard_operation_id standard_operation_id,
       min(utt_emp.resource_id) role, --Modified for Case Picking Project  + Picking ER (FP 7709357)
       min(utt_eqp.resource_id) equipment, --Modified for Case Picking Project  + Picking ER (FP 7709357)
       utt_emp.person_id emp_id,
       utt_emp.effective_start_date,
       utt_emp.effective_end_date,
       -- utt_eqp.inventory_item_id eqp_id, --Modified for Case Picking Project  + Picking ER (FP 7709357)
       NULL eqp_srl  /* removed for bug 2095237 */
     FROM
       (SELECT
          x_utt_res1.standard_operation_id standard_operation_id,
          x_utt_res1.resource_id resource_id,
          x_emp_r.person_id,
          x_emp_r.effective_start_date,
               x_emp_r.effective_end_date
        FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
        WHERE x_utt_res1.resource_id = r1.resource_id
          AND r1.resource_type = 2
          AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp,
       (SELECT
          x_utt_res2.standard_operation_id standard_operation_id,
          x_utt_res2.resource_id,
          x_eqp_r.inventory_item_id
        FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
        WHERE x_utt_res2.resource_id = r2.resource_id
        AND r2.resource_type = 1
        AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
      WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)
          AND NVL(utt_eqp.inventory_item_id, -999) = NVL(l_sign_on_equipment_id, NVL(utt_eqp.inventory_item_id, -999)) --Modified for Case Picking Project  + Picking ER (FP 7709357)
          GROUP BY utt_emp.standard_operation_id, utt_emp.person_id, utt_emp.effective_start_date, utt_emp.effective_end_date) v,
    mtl_item_locations loc,
    mtl_secondary_inventories sub,
    mtl_txn_request_lines mol,
    mtl_txn_request_headers moh
       WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
    AND ((wdtv.pick_slip_number = v_pick_slip_number AND p_task_method = 'DISCRETE')
         OR (p_task_method IN ('MANUAL', 'WAVE', 'BULK', 'DISCRETE')
                  AND wdtv.task_id = v_task_id AND wdtv.wms_task_type_id = v_task_type)
              OR (p_task_method = 'ORDERPICK'
                  AND Decode(wdtv.transaction_source_type_id,
                             2, wdtv.transaction_source_id,
                             5, Decode(wdtv.transaction_type_id, 35, wdtv.transaction_source_id),
                             8, wdtv.transaction_source_id,
                             13, Decode(wdtv.transaction_type_id, 51, wdtv.transaction_source_id),
                             -1) = nvl(v_transaction_source_id, -1))
              OR (p_task_method = 'PICKBYLABEL' AND wdtv.cartonization_id = l_cartonization_id)
        OR (p_task_method = 'CLUSTERPICKBYLABEL' AND
            wdtv.cartonization_id IN (SELECT * FROM TABLE(wms_picking_pkg.list_cartonization_id)))
	      --Added for Case Picking Project start
        OR ( p_task_method = 'MANIFESTORDER' AND
	    	wdtv.transaction_source_id IN (
                                         SELECT   MMTT.TRANSACTION_SOURCE_ID
                                        FROM     MTL_SALES_ORDERS MSO    ,
                                                MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
                                        WHERE  MMTT.TRANSACTION_SOURCE_ID = MSO.SALES_ORDER_ID
                                            AND MSO.SEGMENT1 IN ( SELECT *  FROM TABLE(WMS_PICKING_PKG.LIST_ORDER_NUMBERS))
                                    )
		and wdtv.parent_line_id IS NULL  -- Added for bulk task
	   )
        OR (p_task_method = 'MANIFESTPICKSLIP'
	      AND wdtv.pick_slip_number IN (SELECT * FROM TABLE(wms_picking_pkg.list_pick_slip_numbers))
	      and wdtv.parent_line_id IS NULL  -- Added for bulk task
	   )
        --Added for Case Picking Project end
        )
    AND wdtv.organization_id = p_sign_on_org_id
    AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
    AND NVL(wdtv.subinventory_code, '@@@') = NVL(p_sign_on_zone, NVL(wdtv.subinventory_code, '@@@'))
    --AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999)) --Modified for Case Picking Project  + Picking ER (FP 7709357)
    AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
    AND wdtv.locator_id = loc.inventory_location_id(+)
    AND wdtv.subinventory_code = sub.secondary_inventory_name
    AND wdtv.organization_id = sub.organization_id
    AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
    AND moh.header_id(+) = mol.header_id
    AND Decode(Nvl(moh.move_order_type, -1),
          2, l_rep_allowed,
          1, l_mot_moi_allowed,
          -1, 1,
          1) = 1
    AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
         (SELECT NULL
          FROM mtl_material_transactions_temp mmtt
          WHERE mmtt.transaction_temp_id = wdtv.task_id
          AND mmtt.parent_line_id IS NOT NULL
               AND mmtt.parent_line_id <> mmtt.transaction_temp_id
          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
    AND NOT EXISTS -- exclude tasks already dispatched and queued
         (SELECT NULL
          FROM wms_dispatched_tasks wdt1
          WHERE wdt1.transaction_temp_id = wdtv.task_id
          AND wdt1.task_type = wdtv.wms_task_type_id)
    -- Bug 7254397: exclude tasks from locked cartons
    AND NOT EXISTS
        ( SELECT 1
           FROM WMS_DISPATCH_TASKS_GTMP
           WHERE p_task_method = 'CLUSTERPICKBYLABEL'
                AND
                  grouping_document_number = wdtv.cartonization_id)
    --Added for Case Picking Project start
    AND NOT EXISTS
        ( SELECT 1
           FROM WMS_DISPATCH_TASKS_GTMP
           WHERE p_task_method = 'MANIFESTPICKSLIP'
                AND grouping_document_number = wdtv.pick_slip_number)
    AND NOT EXISTS
        ( SELECT 1
           FROM WMS_DISPATCH_TASKS_GTMP
           WHERE p_task_method = 'MANIFESTORDER'
                 AND grouping_document_number = wdtv.transaction_source_id)
    --Added for Case Picking Project end
    -- excluded skipped taskS
    AND wdtv.task_id NOT IN
         (SELECT wdtv.task_id
          FROM wms_skip_task_exceptions wste, mtl_parameters mp
          WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
          AND wste.task_id = wdtv.task_id
          AND wste.organization_id = mp.organization_id)
         --J Addition
    AND wdtv.subinventory_code not in (
               SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
      )
       ORDER BY
    sub_picking_order,
    loc_picking_order,
    distance,
    task_priority desc,
    batch_id,
    task_status DESC,
    task_num;

    -- Cursor #3 for selecting the ordered tasks
    -- 1. Non cycle count tasks (0)
    -- 2. Cycle count tasks     (1)
    CURSOR l_curs_ordered_tasks_01(v_task_id NUMBER,
               v_task_type NUMBER) IS
       SELECT DISTINCT
    qt.task_id task_num,
    qt.subinventory_code,
    qt.locator_id,
    qt.pick_slip,
    qt.transaction_uom,
    qt.transaction_quantity,
    qt.lot_number,
    qt.operation_plan_id,
    qt.standard_operation_id,
    wdt.effective_start_date,
    wdt.effective_end_date,
    wdt.person_resource_id,
    wdt.machine_resource_id,
    wdt.task_type wms_task_type_id,
    nvl(wdt.priority, 0) task_priority,
    To_number(NULL) batch_id,
    To_number(NULL) line_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    wdt.status task_status,  --bug 4310093
    qt.transaction_type_id,
    qt.transaction_action_id,
    qt.transaction_source_id,
    qt.transaction_source_type_id
       FROM wms_dispatched_tasks wdt,
            (SELECT
          MIN(mcce.cycle_count_entry_id) task_id,
          TO_NUMBER(NULL) pick_slip,
          To_number(NULL) cartonization_id,
          mcce.organization_id,
          mcce.subinventory subinventory_code,
          mcce.locator_id,
          mcce.inventory_item_id,
          mcce.revision,
          To_char(NULL) transaction_uom,
          To_number(NULL) transaction_quantity,
          MIN(mcce.lot_number) lot_number,
          To_number(NULL) operation_plan_id,
          MIN(mcce.standard_operation_id) standard_operation_id,
          To_number(NULL) move_order_line_id,
               4 transaction_type_id,
          4 transaction_action_id,
          mcce.cycle_count_header_id transaction_source_id,
          9 transaction_source_type_id
        FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
        WHERE mcce.entry_status_code IN(1, 3)
          AND NVL(mcce.export_flag, 2) = 2
          -- bug 3972076
          --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
          AND mcce.cycle_count_header_id = mcch.cycle_count_header_id

           -----bug6903708---
           AND mcce.organization_id = mcch.organization_id
           AND mcch.organization_id = p_sign_on_org_id
            ---------------------------

          AND NVL(mcch.disable_date,sysdate+1)> sysdate
          GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) qt,
       mtl_secondary_inventories sub,
       mtl_item_locations loc,
       (SELECT
          bsor.standard_operation_id,
          bre.resource_id,
          bre.inventory_item_id equipment_id
        FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
        WHERE bsor.resource_id = bre.resource_id
        AND br.resource_type = 1
        AND bsor.resource_id = br.resource_id) e
       WHERE wdt.transaction_temp_id = qt.task_id
    AND wdt.status in ( 2,3) -- Queued and dispatched tasks only bug 4310093
    AND wdt.person_id = p_sign_on_emp_id
    AND wdt.organization_id = p_sign_on_org_id
    AND (qt.task_id = v_task_id AND wdt.task_type = v_task_type)
    AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))
    AND wdt.user_task_type = e.standard_operation_id(+)
    AND NVL(qt.subinventory_code, '@@@') = NVL(p_sign_on_zone, NVL(qt.subinventory_code, '@@@'))
    AND qt.organization_id = sub.organization_id
    AND qt.subinventory_code = sub.secondary_inventory_name
    AND qt.organization_id = loc.organization_id
    AND qt.locator_id = loc.inventory_location_id
       UNION ALL
       SELECT DISTINCT
    wdtv.task_id task_num,
    wdtv.subinventory_code,
    wdtv.locator_id,
    NVL(wdtv.pick_slip_number, -1) pick_slip,
    wdtv.transaction_uom,
    wdtv.transaction_quantity,
    wdtv.lot_number,
    wdtv.operation_plan_id,
    wdtv.user_task_type_id standard_operation_id,
    v.effective_start_date,
    v.effective_end_date,
    v.role person_resource_id,
    v.equipment machine_resource_id,
    wdtv.wms_task_type_id,
    nvl(wdtv.task_priority, 0),
    To_number(NULL) batch_id,
    To_number(NULL) line_id,
    sub.picking_order sub_picking_order,
    loc.picking_order loc_picking_order,
    ((nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x) +
     (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y) +
     (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)) distance,
    task_status,
         wdtv.transaction_type_id,
    wdtv.transaction_action_id,
    wdtv.transaction_source_id,
    wdtv.transaction_source_type_id
       FROM
    -- inlined wms_dispatchable_tasks_v, bug 2648133
    (SELECT
       MIN(mcce.cycle_count_entry_id) task_id,
       MIN(mcce.standard_operation_id) user_task_type_id,
       3 wms_task_type_id,
       mcce.organization_id,
       mcce.subinventory subinventory_code,
       mcce.locator_id,
       MIN(task_priority) task_priority,
       mcce.revision revision,
       MIN(mcce.lot_number) lot_number,
       '' transaction_uom,
       TO_NUMBER(NULL) transaction_quantity,
       TO_NUMBER(NULL) pick_rule_id,
       TO_NUMBER(NULL) pick_slip_number,
       TO_NUMBER(NULL) cartonization_id,
       mcce.inventory_item_id,
       TO_NUMBER(NULL) move_order_line_id,
       1 task_status,
       4 transaction_type_id,
       4 transaction_action_id,
       mcce.cycle_count_header_id transaction_source_id,
       9 transaction_source_type_id,
       To_number(NULL) operation_plan_id
     FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
     WHERE mcce.entry_status_code IN(1, 3)
       AND NVL(mcce.export_flag, 2) = 2
       -- bug 3972076
       --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
       AND mcce.cycle_count_header_id = mcch.cycle_count_header_id

        -----bug6903708---
        AND mcce.organization_id = mcch.organization_id
        AND mcch.organization_id = p_sign_on_org_id
        ---------------------------

       AND NVL(mcch.disable_date,sysdate+1)> sysdate
     GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv,
    -- inlined wms_person_resource_utt_v, bug 2648133
    (SELECT
       utt_emp.standard_operation_id standard_operation_id,
       min(utt_emp.resource_id) role,      --Modified for Case Picking Project  + Picking ER (FP 7709357)
       min(utt_eqp.resource_id) equipment, --Modified for Case Picking Project  + Picking ER (FP 7709357)
       utt_emp.person_id emp_id,
       utt_emp.effective_start_date,
       utt_emp.effective_end_date,
       --utt_eqp.inventory_item_id eqp_id, --Modified for Case Picking Project  + Picking ER (FP 7709357)
       NULL eqp_srl  /* removed for bug 2095237 */
     FROM
       (SELECT
          x_utt_res1.standard_operation_id standard_operation_id,
          x_utt_res1.resource_id resource_id,
          x_emp_r.person_id,
          x_emp_r.effective_start_date,
               x_emp_r.effective_end_date
        FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
        WHERE x_utt_res1.resource_id = r1.resource_id
          AND r1.resource_type = 2
          AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp,
       (SELECT
          x_utt_res2.standard_operation_id standard_operation_id,
          x_utt_res2.resource_id,
          x_eqp_r.inventory_item_id
        FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
        WHERE x_utt_res2.resource_id = r2.resource_id
        AND r2.resource_type = 1
        AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
        WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)
           AND NVL(utt_eqp.inventory_item_id, -999) = NVL(l_sign_on_equipment_id, NVL(utt_eqp.inventory_item_id, -999))  --Modified for Case Picking Project  + Picking ER (FP 7709357)
           GROUP BY utt_emp.standard_operation_id, utt_emp.person_id, utt_emp.effective_start_date, utt_emp.effective_end_date) v,
    mtl_item_locations loc,
    mtl_secondary_inventories sub
       WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
    AND (wdtv.task_id = v_task_id AND wdtv.wms_task_type_id = v_task_type)
    AND wdtv.organization_id = p_sign_on_org_id
    AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
    AND NVL(wdtv.subinventory_code, '@@@') = NVL(p_sign_on_zone, NVL(wdtv.subinventory_code, '@@@'))
    -- AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))  --Modified for Case Picking Project  + Picking ER (FP 7709357)
    AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
    AND wdtv.locator_id = loc.inventory_location_id(+)
    AND wdtv.subinventory_code = sub.secondary_inventory_name
    AND wdtv.organization_id = sub.organization_id
    AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
         (SELECT NULL
          FROM mtl_material_transactions_temp mmtt
          WHERE mmtt.transaction_temp_id = wdtv.task_id
          AND mmtt.parent_line_id IS NOT NULL
               AND mmtt.parent_line_id <> mmtt.transaction_temp_id
          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
    AND NOT EXISTS -- exclude tasks already dispatched and queued
         (SELECT NULL
          FROM wms_dispatched_tasks wdt1
          WHERE wdt1.transaction_temp_id = wdtv.task_id
          AND wdt1.task_type = wdtv.wms_task_type_id)
    -- excluded skipped tasks
    AND wdtv.task_id NOT IN
         (SELECT wdtv.task_id
          FROM wms_skip_task_exceptions wste, mtl_parameters mp
          WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
          AND wste.task_id = wdtv.task_id
          AND wste.organization_id = mp.organization_id)
         --J Addition
    AND wdtv.subinventory_code not in (
         SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
      )
       ORDER BY
         sub_picking_order,
    loc_picking_order,
    distance,
    task_priority desc,
    batch_id,
    task_status DESC,
    task_num;

   CURSOR c_task_lock_check(v_transaction_temp_id NUMBER) IS
      SELECT transaction_temp_id
   FROM mtl_material_transactions_temp
   WHERE transaction_temp_id = v_transaction_temp_id
   FOR UPDATE nowait;

   CURSOR c_pick_slip_lock_check(v_pick_slip_number NUMBER) IS
      SELECT transaction_temp_id
   FROM mtl_material_transactions_temp
   WHERE pick_slip_number = v_pick_slip_number
   AND NVL(subinventory_code, '@@@') = NVL(p_sign_on_zone, NVL(subinventory_code, '@@@'))
   FOR UPDATE nowait;

   CURSOR c_order_lock_check(v_order_header_id            NUMBER,
              v_transaction_source_type_id NUMBER,
              v_transaction_action_id      NUMBER,
              v_transaction_type_id        NUMBER) IS
      SELECT transaction_temp_id
   FROM mtl_material_transactions_temp
   WHERE transaction_source_id = v_order_header_id
   AND transaction_source_type_id = v_transaction_source_type_id
   AND transaction_action_id = v_transaction_action_id
   AND transaction_type_id = v_transaction_type_id
   AND NVL(subinventory_code, '@@@') = NVL(p_sign_on_zone, NVL(subinventory_code, '@@@'))
   FOR UPDATE nowait;

   CURSOR c_carton_lock_check(v_cartonization_id NUMBER) IS
      SELECT transaction_temp_id
   FROM mtl_material_transactions_temp
   WHERE cartonization_id = v_cartonization_id
   AND NVL(subinventory_code, '@@@') = NVL(p_sign_on_zone, NVL(subinventory_code, '@@@'))
   FOR UPDATE nowait;

   CURSOR c_cycle_count_lock_check(v_cycle_count_entry_id NUMBER) IS
      SELECT cycle_count_entry_id
   FROM mtl_cycle_count_entries
   WHERE cycle_count_entry_id = v_cycle_count_entry_id
   FOR UPDATE nowait;

   CURSOR c_task_filter(v_filter_name VARCHAR2) IS
      SELECT task_filter_source, task_filter_value
        FROM wms_task_filter_b wtf, wms_task_filter_dtl wtfd
        WHERE task_filter_name = v_filter_name
        AND wtf.task_filter_id = wtfd.task_filter_id;

  --Added for Case Picking Project start

  CURSOR c_pick_slip_numbers IS
      SELECT column_value pick_slip_number FROM TABLE(wms_picking_pkg.list_pick_slip_numbers);

  CURSOR c_order_numbers IS
      SELECT mso.sales_order_id FROM TABLE(wms_picking_pkg.list_order_numbers) lon , mtl_sales_orders mso
      WHERE mso.segment1 = lon.column_value;


   CURSOR c_manifest_order_lock_check(v_sales_order_id NUMBER) IS
      SELECT  transaction_temp_id FROM mtl_material_transactions_temp
      WHERE   transaction_source_id = v_sales_order_id
	      AND NVL(subinventory_code, '@@@') = NVL(p_sign_on_zone,NVL(subinventory_code, '@@@'))
	      FOR UPDATE nowait;

  --Added for Case Picking Project end


  CURSOR lpn_ids_cur IS
      SELECT column_value LPN_ID FROM TABLE(wms_picking_pkg.list_cartonization_id);

     l_debug NUMBER  := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  BEGIN
     IF (l_debug = 1) THEN
   print_debug('Enter dispatch_task ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
     END IF;
    IF (l_debug = 1) THEN
    -- Bug: 7254397
       for lpns_rec in lpn_ids_cur
       loop
           print_debug('LPNs: ' || To_char(lpns_rec.LPN_ID), 9);
       end loop;
      -- Bug: 7254397
    END IF;

     l_progress := '10';

     -- This API is query only, therefore does not create a save point

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF fnd_api.to_boolean(p_init_msg_list) THEN
   fnd_msg_pub.initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status  := fnd_api.g_ret_sts_success;

     -- API body
     -- preprocess input parameters

     fnd_profile.get('WMS_SEQUENCE_PICKS_ACROSS_WAVES', l_sequence_picks_across_waves);

     IF l_sequence_picks_across_waves IS NULL /*OR p_task_method = 'WAVE' */ THEN --Bug#8392581
   l_sequence_picks_across_waves  := 2;
     END IF;
  --bug 6326482
      l_ignore_equipment := NVL(fnd_profile.VALUE('WMS_IGNORE_EQUIPMENT'), 1);
     IF(l_ignore_equipment = 1) then
	l_q_sign_on_equipment_id   := NULL;
     Else
	 IF p_sign_on_equipment_srl = 'NONE' THEN
		l_q_sign_on_equipment_id   := -999;
	ELSE
		l_q_sign_on_equipment_id   := p_sign_on_equipment_id;
        END IF;
      END IF ;
      --bug 6326482

     IF p_sign_on_equipment_srl = 'NONE' THEN
   l_sign_on_equipment_srl  := NULL;
   l_sign_on_equipment_id   := -999;
      ELSE
   l_sign_on_equipment_srl  := p_sign_on_equipment_srl;
   l_sign_on_equipment_id   := p_sign_on_equipment_id;
     END IF;

     -- APL
     IF x_grouping_document_type = 'CARTON' THEN
   l_cartonization_id := x_grouping_document_number;
     END IF;

     -- Populate the task filter variables
     IF (l_debug = 1) THEN
   print_debug('Task Filter: ' || p_task_filter, 9);
     END IF;

     FOR task_filter_rec IN c_task_filter(p_task_filter) LOOP

        IF (l_debug = 1) THEN
           print_debug('Task Filter Source: ' || task_filter_rec.task_filter_source, 9);
           print_debug('Task Filter Value: ' || task_filter_rec.task_filter_value, 9);
        END IF;

        IF task_filter_rec.task_filter_value = 'Y' THEN
           IF task_filter_rec.task_filter_source = 1 THEN -- Internal Order
              l_io_allowed        := 1;
              l_non_cc_allowed    := 1;
            ELSIF task_filter_rec.task_filter_source = 2 THEN -- Move Order Issue
              l_moi_allowed       := 1;
              l_mot_moi_allowed   := 1;
              l_non_cc_allowed    := 1;
            ELSIF task_filter_rec.task_filter_source = 3 THEN -- Move Order Transfer
              l_mot_allowed       := 1;
              l_mot_rep_allowed   := 1;
              l_mot_moi_allowed   := 1;
              l_non_cc_allowed    := 1;
            ELSIF task_filter_rec.task_filter_source = 4 THEN -- Replenishment
              l_rep_allowed       := 1;
              l_mot_rep_allowed   := 1;
              l_non_cc_allowed    := 1;
            ELSIF task_filter_rec.task_filter_source = 5 THEN -- Sales Order
              l_so_allowed        := 1;
              l_non_cc_allowed    := 1;
            ELSIF task_filter_rec.task_filter_source = 6 THEN -- Work Order
              l_wip_allowed       := 1;
              l_non_cc_allowed    := 1;
            ELSIF task_filter_rec.task_filter_source = 7 THEN -- Cycle Counting
              l_cc_allowed        := 1;
           END IF;
        END IF;

     END LOOP;


     IF (l_debug = 1) THEN
        print_debug('l_so_allowed: ' || l_so_allowed, 9);
        print_debug('l_io_allowed: ' || l_io_allowed, 9);
        print_debug('l_wip_allowed: ' || l_wip_allowed, 9);
        print_debug('l_mot_rep_allowed: ' || l_mot_rep_allowed, 9);
        print_debug('l_mot_allowed: ' || l_mot_allowed, 9);
        print_debug('l_rep_allowed: ' || l_rep_allowed, 9);
        print_debug('l_mot_moi_allowed: ' || l_mot_moi_allowed, 9);
        print_debug('l_moi_allowed: ' || l_moi_allowed, 9);
        print_debug('l_cc_allowed: ' || l_cc_allowed, 9);
        print_debug('l_non_cc_allowed: ' || l_non_cc_allowed, 9);
     END IF;

     l_progress  := '20';


    -- select last task this operator was working on
    BEGIN
    SELECT transaction_temp_id, task_type, loaded_time
    INTO l_last_loaded_task_id, l_last_loaded_task_type, l_last_loaded_time
    FROM (SELECT transaction_temp_id, task_type, loaded_time
          FROM wms_dispatched_tasks wdt
          WHERE wdt.person_id = p_sign_on_emp_id
          AND wdt.loaded_time = (SELECT MAX(loaded_time)
                  FROM wms_dispatched_tasks
                  WHERE person_id = p_sign_on_emp_id))
    WHERE ROWNUM = 1; -- make sure only one task selected

       l_progress  := '31';
    EXCEPTION
       WHEN OTHERS THEN
     l_last_loaded_task_id  := -1;
    END;

    IF (l_debug = 1) THEN
       print_debug('dispatch_task - last loaded task : l_last_loaded_task_id => ' || l_last_loaded_task_id, 4);
       print_debug('dispatch_task  => l_last_loaded_task_type' || l_last_loaded_task_type, 4);
       print_debug('dispatch_task  => l_last_loaded_time' || l_last_loaded_time, 4);
    END IF;

    -- select last task this operator completed
    BEGIN
       l_progress  := '32';

       SELECT transaction_id, task_type, loaded_time
    INTO l_last_dropoff_task_id, l_last_dropoff_task_type, l_last_dropoff_time
    FROM (SELECT transaction_id, task_type, loaded_time
          FROM wms_dispatched_tasks_history wdth
          WHERE wdth.person_id = p_sign_on_emp_id
          AND wdth.drop_off_time = (SELECT MAX(drop_off_time)
                FROM wms_dispatched_tasks_history
                WHERE person_id = p_sign_on_emp_id))
    WHERE ROWNUM = 1; -- make sure only one task selected

       l_progress  := '33';
    EXCEPTION
       WHEN OTHERS THEN
     l_last_dropoff_task_id  := -1;
    END;

    IF (l_debug = 1) THEN
       print_debug('dispatch_task - last dropoff task : l_last_dropoff_task_id => ' || l_last_dropoff_task_id, 4);
       print_debug('dispatch_task  => l_last_dropoff_task_type' || l_last_dropoff_task_type, 4);
       print_debug('dispatch_task  => l_last_dropoff_time' || l_last_dropoff_time, 4);
    END IF;

    IF l_last_dropoff_task_id = -1 AND l_last_loaded_task_id = -1 THEN
       l_last_task_id  := -1;
     ELSIF l_last_dropoff_task_id = -1 THEN
       l_last_task_id       := l_last_loaded_task_id;
       l_last_task_type     := l_last_loaded_task_type;
       l_last_task_is_drop  := FALSE;
     ELSIF l_last_loaded_task_id = -1 THEN
       l_last_task_id       := l_last_dropoff_task_id;
       l_last_task_type     := l_last_dropoff_task_type;
       l_last_task_is_drop  := TRUE;
     ELSIF l_last_loaded_time < l_last_dropoff_time THEN
       l_last_task_id       := l_last_dropoff_task_id;
       l_last_task_type     := l_last_dropoff_task_type;
       l_last_task_is_drop  := TRUE;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('dispatch_task - previous task - l_last_task_id = ' || l_last_task_id, 4);
    END IF;

    -- select locator coordinates of the the last task
    IF l_last_task_id <> -1 THEN -- make sure there is a last task

       IF l_last_task_is_drop <> TRUE THEN -- task that has not been completed
     -- get the location from wms_dispatchable_tasks_v
          BEGIN
        l_progress  := '35';

        -- use Nvl to make sure if coordinates not defined, use 0
        SELECT NVL(loc.x_coordinate, 0), NVL(loc.y_coordinate, 0), NVL(loc.z_coordinate, 0)
          INTO l_cur_x, l_cur_y, l_cur_z
          FROM mtl_item_locations loc,
               (SELECT
           transaction_temp_id task_id,
           standard_operation_id user_task_type_id,
           wms_task_type wms_task_type_id,
           organization_id organization_id,
           subinventory_code zone,
           locator_id locator_id,
           task_priority task_priority,
           revision revision,
           lot_number lot_number,
           transaction_uom transaction_uom,
           transaction_quantity transaction_quantity,
           pick_rule_id pick_rule_id,
           pick_slip_number pick_slip_number,
           cartonization_id cartonization_id,
           inventory_item_id,
           move_order_line_id
           FROM mtl_material_transactions_temp
           WHERE wms_task_type IS NOT NULL
           AND transaction_status = 2
           UNION ALL
           SELECT
           MIN(cycle_count_entry_id) task_id,
           MIN(standard_operation_id) user_task_type_id,
           3 wms_task_type_id,
           organization_id organization_id,
           subinventory zone,
           locator_id locator_id,
           MIN(task_priority) task_priority,
           revision revision,
             MIN(lot_number) lot_number,
             '' transaction_uom,
             TO_NUMBER(NULL) transaction_quantity,
             TO_NUMBER(NULL) pick_rule_id,
             TO_NUMBER(NULL) pick_slip_number,
             TO_NUMBER(NULL) cartonization_id,
            inventory_item_id,
             TO_NUMBER(NULL) move_order_line_id
             FROM mtl_cycle_count_entries
            WHERE  entry_status_code IN(1, 3)
             AND  NVL(export_flag, 2) = 2
             -- bug 3972076
             --AND  NVL(TRUNC(count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
             GROUP BY  cycle_count_header_id, organization_id, subinventory, locator_id, inventory_item_id, revision) wdtv -- inlined wms_dispatchable_tasks_v, bug 2648133
          WHERE wdtv.locator_id = loc.inventory_location_id
       AND wdtv.organization_id = loc.organization_id
       AND wdtv.task_id = l_last_task_id
       AND wdtv.wms_task_type_id = l_last_task_type;

       -- Added the previous line since the task_id in the view
            -- might not be unique since it is the transaction_temp_id
            -- if it comes from MMTT but the cycle_count_entry_id if
            -- it comes from MTL_CYCLE_COUNT_ENTRIES for cycle counting tasks
            l_progress  := '36';
          EXCEPTION
        WHEN OTHERS THEN
      -- locator definition descripency
      l_cur_x  := 0;
      l_cur_y  := 0;
      l_cur_z  := 0;
     END;
        ELSE -- l_last_task_is_drop <> TRUE  (completed tasks)
          IF l_last_task_type <> 3 THEN                                -- not cycle count task
                                        -- get the location from mtl_material_transactions
            BEGIN
              l_progress  := '37';

              -- use Nvl to make sure if coordinates not defined, use 0
              SELECT NVL(loc.x_coordinate, 0)
                   , NVL(loc.y_coordinate, 0)
                   , NVL(loc.z_coordinate, 0)
                INTO l_cur_x
                   , l_cur_y
                   , l_cur_z
                FROM mtl_item_locations loc, mtl_material_transactions mmt
               WHERE mmt.locator_id = loc.inventory_location_id
                 AND mmt.organization_id = loc.organization_id
                 AND mmt.transaction_set_id = l_last_task_id
                 AND ROWNUM = 1;

              l_progress  := '38';
            EXCEPTION
              WHEN OTHERS THEN
                -- locator definition descripency
                l_cur_x  := 0;
                l_cur_y  := 0;
                l_cur_z  := 0;
            END;
          ELSE     -- l_last_task_type <> 3  (Cyclt Count task)
               -- get the location from mtl_cycle_count_entries
            BEGIN
              l_progress  := '39';

              -- use Nvl to make sure if coordinates not defined, use 0
              SELECT NVL(loc.x_coordinate, 0)
                   , NVL(loc.y_coordinate, 0)
                   , NVL(loc.z_coordinate, 0)
                INTO l_cur_x
                   , l_cur_y
                   , l_cur_z
                FROM mtl_item_locations loc, mtl_cycle_count_entries mcce
               WHERE mcce.locator_id = loc.inventory_location_id
                 AND mcce.organization_id = loc.organization_id
                 AND mcce.cycle_count_entry_id = l_last_task_id;

              l_progress  := '40';
            EXCEPTION
              WHEN OTHERS THEN                -- adf
                               -- locator definition descripency
                l_cur_x  := 0;
                l_cur_y  := 0;
                l_cur_z  := 0;
            END;
          END IF; -- l_last_task_type <> 3
        END IF; -- l_last_task_is_drop <> TRUE
      ELSE -- there is not a previous task at all
        l_cur_x  := 0;
        l_cur_y  := 0;
        l_cur_z  := 0;
    END IF; -- l_last_task_id <> -1

    l_progress                     := '45';

    -- Select the most optimal task
    -- first select eligible tasks according to employee sign on information
    -- order tasks by task priority, locator picking order and locator coordinates
    -- approximated to current locator

    IF (l_debug = 1) THEN
       print_debug('p_sign_on_emp_id => ' || p_sign_on_emp_id, 4);
       print_debug('p_sign_on_zone => ' || p_sign_on_zone, 4);
       print_debug('l_cartonization_id => ' || l_cartonization_id, 4);
       print_debug('l_sign_on_equipment_srl => ' || l_sign_on_equipment_srl, 4);
       print_debug('l_sign_on_equipment_id => ' || l_sign_on_equipment_id, 4);
       print_debug('l_cur_x => ' || l_cur_x, 4);
       print_debug('l_cur_y => ' || l_cur_y, 4);
       print_debug('l_cur_z => ' || l_cur_z, 4);
    END IF;
    --Bug 7254397, added loop for detecting and storing
    IF p_task_method = 'CLUSTERPICKBYLABEL' THEN
      BEGIN
        l_total_lpns := wms_picking_pkg.get_total_lpns;
        l_locked_lpns := 0;
        FOR lpn_id_rec IN lpn_ids_cur
        LOOP
                IF l_debug = 1 THEN
                  print_debug('Check carton ID '|| lpn_id_rec.LPN_ID || ' for locking.', 4);
                END IF;

                BEGIN
                  OPEN c_carton_lock_check(lpn_id_rec.LPN_ID);
                  CLOSE c_carton_lock_check;

                EXCEPTION
                  WHEN OTHERS  THEN
                   IF SQLCODE = -54 THEN  -- resource busy and acquire with NOWAIT specified
		      l_locked_lpns := l_locked_lpns + 1;
                      IF l_debug  = 1 THEN
                         print_debug('Carton ' || lpn_id_rec.LPN_ID ||' is locked by other user. ', 4);
                      END IF;
                      store_locked_tasks
                        (p_grp_doc_type => p_task_method,
                         p_grp_doc_num  => lpn_id_rec.LPN_ID,
                         p_grp_src_type_id => NULL,
                         x_return_status  => l_return_status);

                      IF l_debug  = 1 THEN
                        print_debug('Return Status after the call to store_locked_tasks ' || l_return_status ||' p_task_method ' || p_task_method, 4);
                      END IF;

                      IF l_return_status = fnd_api.g_ret_sts_error THEN
                        RAISE fnd_api.g_exc_error;
                      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                        RAISE fnd_api.g_exc_unexpected_error;
                      END IF;
		      IF l_locked_lpns = l_total_lpns THEN
       			fnd_message.set_name('WMS', 'WMS_TASK_NO_ELIGIBLE_TASKS');
       			fnd_msg_pub.ADD;

       			IF (l_debug = 1) THEN
         		 print_debug('dispatch_task - No eligible picking tasks ', 4);
       			END IF;
       			RAISE fnd_api.g_exc_error;
		      END IF;
                      l_return_status := fnd_api.g_ret_sts_success;
                   END IF;

                   IF c_carton_lock_check%isopen THEN
                      CLOSE c_carton_lock_check;
                   END IF;
                END;
        END LOOP;
      END;
    END IF;
    -- Bug 7254397
        --Added for Case Picking Project start
        IF p_task_method = 'MANIFESTORDER' THEN
              BEGIN
              FOR c_order_numbers_rec IN c_order_numbers
	      LOOP
	              BEGIN
                       OPEN c_manifest_order_lock_check(c_order_numbers_rec.sales_order_id);
	               CLOSE c_manifest_order_lock_check;
		       IF l_debug  = 1 THEN
			  print_debug('c_order_lock_check ORDER ID ' ||c_order_numbers_rec.sales_order_id, 4);
		       END IF;
                      EXCEPTION
                      WHEN OTHERS THEN
                          IF SQLCODE  = -54 THEN -- resource busy and acquire with NOWAIT specified
				      IF l_debug  = 1 THEN
				      print_debug('Sales order id ' || c_order_numbers_rec.sales_order_id||'is locked by other user. ', 4);
				      END IF;
				      store_locked_tasks(p_grp_doc_type => p_task_method,
							p_grp_doc_num  =>c_order_numbers_rec.sales_order_id  ,
							p_grp_src_type_id => NULL,
							x_return_status  => l_return_status);
                              IF l_return_status = fnd_api.g_ret_sts_error THEN
                                      RAISE fnd_api.g_exc_error;
                              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                                      RAISE fnd_api.g_exc_unexpected_error;
                              END IF;
                              l_return_status := fnd_api.g_ret_sts_success;
                          END IF;
                          IF c_manifest_order_lock_check%isopen THEN
                                  CLOSE c_manifest_order_lock_check;
                          END IF;
                      END;
              END LOOP;
              END;
        END IF;
        IF p_task_method = 'MANIFESTPICKSLIP' THEN
              BEGIN
              FOR c_pick_slip_numbers_rec IN c_pick_slip_numbers
	      LOOP
		      BEGIN
			OPEN c_pick_slip_lock_check(c_pick_slip_numbers_rec.pick_slip_number);
			CLOSE c_pick_slip_lock_check;
			IF l_debug  = 1 THEN
			  print_debug('c_pick_slip_lock_check Pick Slip ' ||c_pick_slip_numbers_rec.pick_slip_number, 4);
		        END IF;
                      EXCEPTION
                      WHEN OTHERS THEN
                          IF SQLCODE   = -54 THEN -- resource busy and acquire with NOWAIT specified
			    IF l_debug  = 1 THEN
				    print_debug('Pick Slip ' ||c_pick_slip_numbers_rec.pick_slip_number ||' is locked by other user. ', 4);
			    END IF;
			    store_locked_tasks(p_grp_doc_type => p_task_method,
						p_grp_doc_num  => c_pick_slip_numbers_rec.pick_slip_number,
						p_grp_src_type_id => NULL,
						x_return_status  => l_return_status);
                              IF l_return_status = fnd_api.g_ret_sts_error THEN
                                      RAISE fnd_api.g_exc_error;
                              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                                      RAISE fnd_api.g_exc_unexpected_error;
                              END IF;
                              l_return_status := fnd_api.g_ret_sts_success;
                          END IF;
                          IF c_pick_slip_lock_check%isopen THEN
                                  CLOSE c_pick_slip_lock_check;
                          END IF;
                      END;
              END LOOP;
              END;
        END IF;
     --Added for Case Picking Project end
    --Modified for Case Picking Project
    IF (p_task_method IN ('CLUSTERPICKBYLABEL','MANIFESTPICKSLIP','MANIFESTORDER')) THEN
       GOTO end_loop;
    END IF;
    -- open and fetch appropriate cursor
    -- start bug 2832818
    LOOP -- added loop for detecting lock for a pick slip
       l_is_locked := FALSE;
       -- bug 4358107
       l_pick_slip := 0;
       l_transaction_source_id := NULL;
       l_transaction_source_type_id := NULL;
       l_transaction_action_id := NULL;
       l_transaction_type_id := NULL;
       l_task_id := NULL;
       l_task_type_id := NULL;
       l_task_priority := NULL;
       l_batch_id := NULL;
       l_loc_pick_order := NULL;
       l_distance := NULL;
       l_task_status := NULL;
       -- bug 4358107
       -- end bug 2832818

       IF p_sign_on_zone IS NOT NULL THEN -- subinventory passed in

     IF l_cc_allowed = 1 AND l_non_cc_allowed = 1 THEN

        IF (l_debug = 1) THEN
      print_debug('Opt task cursor: subinventory passed, both cycle count and non cycle count', 4);
        END IF;

        OPEN l_curs_opt_task_111;

        FETCH l_curs_opt_task_111
          INTO l_task_id, l_pick_slip, l_task_type_id, l_task_priority, l_batch_id,
          l_sub_pick_order, l_loc_pick_order, l_distance,
          l_task_status, l_transaction_type_id,
          l_transaction_action_id, l_transaction_source_id, l_transaction_source_type_id;

      ELSIF l_cc_allowed = 0 AND l_non_cc_allowed = 1 THEN

        IF (l_debug = 1) THEN
      print_debug('Opt task cursor: subinventory passed, only non cycle count', 4);
      print_debug('Opt task cursor: l_curs_opt_task_110', 4);
        END IF;

        OPEN l_curs_opt_task_110;

        FETCH l_curs_opt_task_110
          INTO l_task_id, l_pick_slip, l_task_type_id, l_task_priority, l_batch_id,
          l_sub_pick_order, l_loc_pick_order, l_distance,
          l_task_status, l_transaction_type_id,
          l_transaction_action_id, l_transaction_source_id, l_transaction_source_type_id;

        ELSIF l_cc_allowed = 1 AND l_non_cc_allowed = 0 THEN

        IF (l_debug = 1) THEN
      print_debug('Opt task cursor: subinventory passed, only non cycle count', 4);
        END IF;

        OPEN l_curs_opt_task_101;

        FETCH l_curs_opt_task_101
          INTO l_task_id, l_pick_slip, l_task_type_id, l_task_priority, l_batch_id,
          l_sub_pick_order, l_loc_pick_order, l_distance,
          l_task_status, l_transaction_type_id,
          l_transaction_action_id, l_transaction_source_id, l_transaction_source_type_id;

     END IF;

   ELSE -- No subinventory passed in

     IF l_cc_allowed = 1 AND l_non_cc_allowed = 1 THEN

        IF (l_debug = 1) THEN
      print_debug('Opt task cursor: subinventory not passed, both cycle count and non cycle count', 4);
        END IF;

        OPEN l_curs_opt_task_011;

        FETCH l_curs_opt_task_011
          INTO l_task_id, l_pick_slip, l_task_type_id, l_task_priority, l_batch_id,
          l_sub_pick_order, l_loc_pick_order, l_distance,
          l_task_status, l_transaction_type_id,
          l_transaction_action_id, l_transaction_source_id, l_transaction_source_type_id;

      ELSIF l_cc_allowed = 0 AND l_non_cc_allowed = 1 THEN

        IF (l_debug = 1) THEN
      print_debug('Opt task cursor: subinventory not passed, only non cycle count', 4);
      print_debug('Opt task cursor: l_curs_opt_task_010', 4);
        END IF;

        OPEN l_curs_opt_task_010;

        FETCH l_curs_opt_task_010
          INTO l_task_id, l_pick_slip, l_task_type_id, l_task_priority, l_batch_id,
          l_sub_pick_order, l_loc_pick_order, l_distance,
          l_task_status, l_transaction_type_id,
          l_transaction_action_id, l_transaction_source_id, l_transaction_source_type_id;

      ELSIF l_cc_allowed = 1 AND l_non_cc_allowed = 0 THEN

        IF (l_debug = 1) THEN
      print_debug('Opt task cursor: subinventory not passed, only non cycle count', 4);
      print_debug('Opt task cursor: l_curs_opt_task_001', 4);
        END IF;

        OPEN l_curs_opt_task_001;

        FETCH l_curs_opt_task_001
          INTO l_task_id, l_pick_slip, l_task_type_id, l_task_priority, l_batch_id,
          l_sub_pick_order, l_loc_pick_order, l_distance,
          l_task_status, l_transaction_type_id,
          l_transaction_action_id, l_transaction_source_id, l_transaction_source_type_id;

     END IF;

       END IF;

       -- Wave, Discrete, Order, Cluster, Label, Manual, Bulk
       IF l_task_type_id <> 3 THEN -- Check the lock for non cycle count tasks
     IF p_task_method IN ('WAVE', 'BULK') THEN
        IF l_debug = 1 THEN
      print_debug('Check task '|| l_task_id || ' for locking.', 4);
        END IF;

             BEGIN
      OPEN c_task_lock_check(l_task_id);
      CLOSE c_task_lock_check;
        EXCEPTION
      WHEN OTHERS  THEN
         IF SQLCODE = -54 THEN  -- resource busy and acquire with NOWAIT specified
            l_is_locked := TRUE;

            IF l_debug  = 1 THEN
          print_debug('Task ' || l_task_id ||' is locked by other user. ', 4);
            END IF;

          ELSE
            l_is_locked := FALSE;
         END IF;

         IF c_task_lock_check%isopen THEN
            CLOSE c_task_lock_check;
         END IF;
        END;
      ELSIF p_task_method = 'DISCRETE' THEN
        IF l_debug = 1 THEN
      print_debug('Check pick_slip_number'|| l_pick_slip || ' for locking.', 4);
        END IF;

             BEGIN
      OPEN c_pick_slip_lock_check(l_pick_slip);
      CLOSE c_pick_slip_lock_check;

                l_is_locked := FALSE;
                x_grouping_document_type := 'PICK_SLIP';
                x_grouping_document_number := l_pick_slip;
                x_grouping_source_type_id := l_transaction_source_type_id;

        EXCEPTION
      WHEN OTHERS  THEN
         IF SQLCODE = -54 THEN  -- resource busy and acquire with NOWAIT specified
            l_is_locked := TRUE;

            IF l_debug  = 1 THEN
          print_debug('pick_slip_number ' || l_pick_slip ||' is locked by other user. ', 4);
            END IF;
            -- bug 4358107
            store_locked_tasks
              (p_grp_doc_type => p_task_method,
               p_grp_doc_num  => l_pick_slip,
               p_grp_src_type_id => NULL,
               x_return_status  => l_return_status);

            IF l_debug  = 1 THEN
              print_debug('Return Status after the call to store_locked_tasks ' || l_return_status ||' p_task_method ' || p_task_method, 4);
            END IF;

            IF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            l_return_status := fnd_api.g_ret_sts_success;
            -- bug 4358107

         END IF;

         IF c_pick_slip_lock_check%isopen THEN
            CLOSE c_pick_slip_lock_check;
         END IF;
        END;
      ELSIF p_task_method = 'ORDERPICK' THEN
        IF l_debug = 1 THEN
      print_debug('Check order '|| l_transaction_source_id || ' for locking.', 4);
        END IF;

             BEGIN
      OPEN c_order_lock_check(l_transaction_source_id,
               l_transaction_source_type_id,
               l_transaction_action_id,
               l_transaction_type_id);
      CLOSE c_order_lock_check;

                l_is_locked := FALSE;
                x_grouping_document_type := 'ORDER';
                x_grouping_document_number := l_transaction_source_id;
                x_grouping_source_type_id := l_transaction_source_type_id;

        EXCEPTION
      WHEN OTHERS  THEN
         IF SQLCODE = -54 THEN  -- resource busy and acquire with NOWAIT specified
            l_is_locked := TRUE;

            IF l_debug  = 1 THEN
          print_debug('Order ' || l_transaction_source_id ||' is locked by other user. ', 4);
            END IF;
            -- bug 4358107
            store_locked_tasks
              (p_grp_doc_type => p_task_method,
               p_grp_doc_num  => l_transaction_source_id,
               p_grp_src_type_id => l_transaction_source_type_id,
               x_return_status  => l_return_status);

            IF l_debug  = 1 THEN
              print_debug('Return Status after the call to store_locked_tasks ' || l_return_status ||' p_task_method ' || p_task_method, 4);
            END IF;

            IF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            l_return_status := fnd_api.g_ret_sts_success;
            -- bug 4358107

         END IF;

         IF c_order_lock_check%isopen THEN
            CLOSE c_order_lock_check;
         END IF;
        END;
      ELSIF p_task_method = 'PICKBYLABEL' THEN
        IF l_debug = 1 THEN
      print_debug('Check carton ID '|| l_cartonization_id || ' for locking.', 4);
        END IF;

             BEGIN
      OPEN c_carton_lock_check(l_cartonization_id);
      CLOSE c_carton_lock_check;

                l_is_locked := FALSE;
                x_grouping_document_type := 'CARTON';
                x_grouping_document_number := l_cartonization_id;
                x_grouping_source_type_id := l_transaction_source_type_id;

        EXCEPTION
      WHEN OTHERS  THEN
         IF SQLCODE = -54 THEN  -- resource busy and acquire with NOWAIT specified
            l_is_locked := TRUE;

            IF l_debug  = 1 THEN
          print_debug('Carton ' || l_cartonization_id ||' is locked by other user. ', 4);
            END IF;
            -- bug 4358107
            store_locked_tasks
              (p_grp_doc_type => p_task_method,
               p_grp_doc_num  => l_cartonization_id,
               p_grp_src_type_id => NULL,
               x_return_status  => l_return_status);

            IF l_debug  = 1 THEN
              print_debug('Return Status after the call to store_locked_tasks ' || l_return_status ||' p_task_method ' || p_task_method, 4);
            END IF;

            IF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            l_return_status := fnd_api.g_ret_sts_success;
            -- bug 4358107

         END IF;

         IF c_carton_lock_check%isopen THEN
            CLOSE c_carton_lock_check;
         END IF;
        END;
     END IF;
   ELSE -- Check the lock for cycle count tasks
     IF l_debug = 1 THEN
        print_debug('Check cycle count task '|| l_task_id || ' for locking.', 4);
     END IF;

          BEGIN
        OPEN c_cycle_count_lock_check(l_task_id);
        CLOSE c_cycle_count_lock_check;

             l_is_locked := FALSE;
             x_grouping_document_type := 'TASK';
             x_grouping_document_number := l_task_id;
             x_grouping_source_type_id := l_transaction_source_type_id;
     EXCEPTION
        WHEN OTHERS  THEN
      IF SQLCODE = -54 THEN  -- resource busy and acquire with NOWAIT specified
         l_is_locked := TRUE;

         IF l_debug  = 1 THEN
            print_debug('Cycle count task ' || l_task_id ||' is locked by other user. ', 4);
         END IF;

      END IF;

      IF c_cycle_count_lock_check%isopen THEN
         CLOSE c_cycle_count_lock_check;
      END IF;
     END;

       END IF;

       IF p_sign_on_zone IS NOT NULL THEN -- subinventory passed in
          IF l_cc_allowed = 1 AND l_non_cc_allowed = 1 THEN
             CLOSE l_curs_opt_task_111;
           ELSIF l_cc_allowed = 0 AND l_non_cc_allowed = 1 THEN
             CLOSE l_curs_opt_task_110;
           ELSIF l_cc_allowed = 1 AND l_non_cc_allowed = 0 THEN
             CLOSE l_curs_opt_task_101;
          END IF;
        ELSE -- No subinventory passed in
          IF l_cc_allowed = 1 AND l_non_cc_allowed = 1 THEN
             CLOSE l_curs_opt_task_011;
           ELSIF l_cc_allowed = 0 AND l_non_cc_allowed = 1 THEN
             CLOSE l_curs_opt_task_010;
           ELSIF l_cc_allowed = 1 AND l_non_cc_allowed = 0 THEN
             CLOSE l_curs_opt_task_001;
          END IF;
       END IF;

       IF l_is_locked = TRUE THEN
     IF l_debug = 1 THEN
        print_debug('Continue looking for most optimal task since there is a lock for this pick slip.', 4);
     END IF;
   ELSE
     IF l_debug = 1 THEN
        print_debug('There is no lock, got the most optimal task.', 4);
     END IF;
      /* Fix for the bug 3837944 Bug 3853837 .
          The below block is to check whether any task has been dispatched to some other user
            for the same carton. If yes, this user will not get the task.Should not allow cyclecount task    */
         --Bug 4078696
          IF (( l_task_id IS NOT NULL) AND (l_task_type_id <> 3)) THEN
             BEGIN
                 IF l_debug = 1 THEN
                    print_debug('The trx temp id :' || l_task_id , 4);
                 END IF;
              /*Take the LPN_ID from MMTT*/
                l_lpn_id := NULL;
                SELECT cartonization_id INTO l_lpn_id
                FROM   mtl_material_transactions_temp mmtt
                WHERE  mmtt.transaction_temp_id=  l_task_id;




                IF l_debug = 1 THEN
                    print_debug('The carton id :' || l_lpn_id || 'Current employee id :'||  p_sign_on_emp_id, 4);
                END IF;

                /*Check if any task has been dispatched to other users for the same LPN*/
                IF l_lpn_id IS NOT NULL THEN
                         l_wdt_count :=  0 ;
                         SELECT count(1) INTO l_wdt_count  FROM  wms_dispatched_tasks wdt, mtl_material_transactions_temp mmtt
                          WHERE mmtt.cartonization_id = l_lpn_id
                           AND wdt.transaction_temp_id = mmtt.transaction_temp_id
                           AND wdt.status in(3,9)   AND wdt.person_id <>  p_sign_on_emp_id ;

                         IF l_debug = 1 THEN
                             print_debug('The tasks dispatched to other user :'|| l_wdt_count,4);
                         END IF;

                        IF l_wdt_count > 0 then  --There tasks dispatched to other users for this LPN
                            l_task_id := NULL;
			    -- 6598260 start
			    IF l_debug = 1 THEN
                              print_debug('cartonized tasks  START',4);
			    END IF;

				      store_locked_tasks (p_grp_doc_type =>'CARTON_TASK',
							  p_grp_doc_num  => l_lpn_id,
							  p_grp_src_type_id => NULL,
							  x_return_status  => l_return_status);
				      IF l_debug  = 1 THEN
					print_debug('Return Status after the call to store_locked_tasks ' || l_return_status ||' l_lpn_id :- '|| l_lpn_id, 4);
				      END IF;

				      IF l_return_status = fnd_api.g_ret_sts_error THEN
					RAISE fnd_api.g_exc_error;
				      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
					RAISE fnd_api.g_exc_unexpected_error;
				      END IF;
				      l_return_status := fnd_api.g_ret_sts_success;

			    IF l_debug = 1 THEN
                              print_debug('cartonized tasks  end',4);
			    END IF;
			   -- 6598260 end
                           IF l_debug = 1 THEN
                                print_debug('There are tasks dispatched to other users for this carton ',4);
                           END IF;

                        ELSE    --No tasks dispatched to other users for this carton.
                           EXIT;
                        END IF;
                ELSE   --LPN id is NULL .This is not a cartonization task.
                   EXIT;
                END IF;
             EXCEPTION
               WHEN OTHERS  THEN
                  IF l_debug = 1 THEN
                       print_debug('Exception occured when checking for dispatched tasks to other users ',4);
                  END IF;
                  EXIT;--v1
             END;
          ELSE   --l_opt_task_id is NULL.
              EXIT;
          END IF;
        /* End of fix fir bug 3837944 Bug3853837 */
       END IF;--l_is_locked
    END LOOP;
    <<end_loop>> -- Bug 7254397
    -- End bug fix 2832818

    --Modified for Case Picking Project
    IF ( l_task_id IS NULL AND p_task_method NOT IN  ('CLUSTERPICKBYLABEL','MANIFESTORDER','MANIFESTPICKSLIP') ) THEN --Bug 7254397
       fnd_message.set_name('WMS', 'WMS_TASK_NO_ELIGIBLE_TASKS');
       fnd_msg_pub.ADD;

       IF (l_debug = 1) THEN
          print_debug('dispatch_task - No eligible picking tasks ', 4);
       END IF;

       RAISE fnd_api.g_exc_error;
    END IF;

    IF p_task_method <> 'ORDERPICK' THEN
       l_transaction_source_id := NULL;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('Pick Slip: ' || l_pick_slip, 4);
       print_debug('Task Type: ' || l_task_type_id, 4);
       print_debug('Task ID: ' || l_task_id, 4);
       print_debug('Transaction Source ID: ' || l_transaction_source_id, 4);
    END IF;

    IF l_non_cc_allowed = 1 AND l_cc_allowed = 1 THEN
       OPEN l_curs_ordered_tasks_11(l_pick_slip, l_task_id, l_task_type_id, l_transaction_source_id);
     ELSIF l_non_cc_allowed = 1 AND l_cc_allowed = 0 THEN
       OPEN l_curs_ordered_tasks_10(l_pick_slip, l_task_id, l_task_type_id, l_transaction_source_id);
     ELSIF l_non_cc_allowed = 0 AND l_cc_allowed = 1 THEN
       OPEN l_curs_ordered_tasks_01(l_task_id, l_task_type_id);
    END IF;

    l_progress                     := '50';
    l_first_task_pick_slip_number  := -1;
    l_ordered_tasks_count          := 0;

    LOOP

       IF (l_debug = 1) THEN
     print_debug('Start looping through ordered tasks: ', 4);
       END IF;

       l_task_id         := NULL;

       l_is_locked       := FALSE;
       l_progress        := '60';

       IF l_non_cc_allowed = 1 AND l_cc_allowed = 1 THEN
     IF (l_debug = 1) THEN
        print_debug('Both cycle count and non cycle count tasks allowed: ', 4);
     END IF;

     FETCH l_curs_ordered_tasks_11
       INTO
           l_task_id,
           l_subinventory_code,
           l_locator_id,
           l_pick_slip,
           l_transaction_uom,
           l_transaction_quantity,
           l_lot_number,
           l_operation_plan_id,
           l_standard_operation_id,
           l_effective_start_date,
           l_effective_end_date,
           l_person_resource_id,
           l_machine_resource_id,
           l_task_type_id,
           l_task_priority,
           l_batch_id,
           l_move_order_line_id,
           l_sub_pick_order,
           l_loc_pick_order,
           l_distance,
           l_task_status,
           l_transaction_type_id,
           l_transaction_action_id,
           l_transaction_source_id,
           l_transaction_source_type_id;

     EXIT WHEN l_curs_ordered_tasks_11%notfound;

   ELSIF l_non_cc_allowed = 1 AND l_cc_allowed = 0 THEN

     IF (l_debug = 1) THEN
        print_debug('Only non cycle count tasks allowed: ', 4);
     END IF;

      FETCH l_curs_ordered_tasks_10
         INTO
           l_task_id,
           l_subinventory_code,
           l_locator_id,
           l_pick_slip,
           l_transaction_uom,
           l_transaction_quantity,
           l_lot_number,
           l_operation_plan_id,
           l_standard_operation_id,
           l_effective_start_date,
           l_effective_end_date,
           l_person_resource_id,
           l_machine_resource_id,
           l_task_type_id,
           l_task_priority,
           l_batch_id,
           l_move_order_line_id,
           l_sub_pick_order,
           l_loc_pick_order,
           l_distance,
           l_task_status,
           l_transaction_type_id,
           l_transaction_action_id,
           l_transaction_source_id,
           l_transaction_source_type_id;

      EXIT WHEN l_curs_ordered_tasks_10%notfound;

   ELSIF l_non_cc_allowed = 0 AND l_cc_allowed = 1 THEN

      IF (l_debug = 1) THEN
         print_debug('Only cycle count tasks allowed: ', 4);
      END IF;

      FETCH l_curs_ordered_tasks_01
         INTO
           l_task_id,
           l_subinventory_code,
           l_locator_id,
           l_pick_slip,
           l_transaction_uom,
           l_transaction_quantity,
           l_lot_number,
           l_operation_plan_id,
           l_standard_operation_id,
           l_effective_start_date,
           l_effective_end_date,
           l_person_resource_id,
           l_machine_resource_id,
           l_task_type_id,
           l_task_priority,
           l_batch_id,
           l_move_order_line_id,
           l_sub_pick_order,
           l_loc_pick_order,
           l_distance,
           l_task_status,
           l_transaction_type_id,
           l_transaction_action_id,
           l_transaction_source_id,
           l_transaction_source_type_id;

      EXIT WHEN l_curs_ordered_tasks_01%notfound;

       END IF;

       l_progress            := '70';

       IF (l_debug = 1) THEN
     print_debug('Task ID =>      ' || l_task_id, 4);
     print_debug('Pick Slip =>    ' || l_pick_slip, 4);
     print_debug('Task Type =>    ' || l_task_type_id, 4);
     print_debug('Trx Src =>      ' || l_transaction_source_id, 4);
     print_debug('Trx Srx Type => ' || l_transaction_source_type_id, 4);
       END IF;

       l_ordered_tasks_count          := l_ordered_tasks_count + 1;

       IF (l_debug = 1) THEN
     print_debug('This is the first task in this group. l_ordered_tasks_count => ' || l_ordered_tasks_count, 4);
       END IF;

       l_progress                     := '72';

       INSERT INTO wms_ordered_tasks
    (task_id,
     wms_task_type,
     task_sequence_id,
     subinventory_code,
     locator_id,
     revision,
     transaction_uom,
     transaction_quantity,
     lot_number,
     priority,
     operation_plan_id,
     standard_operation_id,
     effective_start_date,
     effective_end_date,
     person_resource_id,
     machine_resource_id,
     move_order_line_id)
    VALUES
    (l_task_id,
     l_task_type_id,
     l_ordered_tasks_count,
     l_subinventory_code,
     l_locator_id,
     l_revision,
     l_transaction_uom,
     l_transaction_quantity,
     l_lot_number,
     l_task_priority,
     l_operation_plan_id,
     l_standard_operation_id,
     l_effective_start_date,
     l_effective_end_date,
     l_person_resource_id,
     l_machine_resource_id,
     l_move_order_line_id);

       l_progress                     := '73';

    END LOOP;

       --Bug 7254397: Clear ...GTMP table
    IF p_task_method = 'CLUSTERPICKBYLABEL' THEN
       remove_stored_cartons(x_return_status  => l_return_status);
       IF l_debug  = 1 THEN
            print_debug('Return Status after the call to remove_locked_tasks ' || l_return_status ||' p_task_method ' || p_task_method, 4);
       END IF;
       IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;
       l_return_status := fnd_api.g_ret_sts_success;
    END IF;--Bug 7254397: Clear ...GTMP table end

    --Added for Case Picking Project start
    IF p_task_method = 'MANIFESTORDER' THEN
 	      remove_stored_order_num(x_return_status => l_return_status);
	      print_debug('dispatch_task - remove_stored_order_numbers l_return_status'||l_return_status, 4);
    ELSIF p_task_method = 'MANIFESTPICKSLIP' THEN
	      remove_stored_pick_slip_num(x_return_status => l_return_status);
        print_debug('dispatch_task - remove_stored_pick_slip_numbers l_return_status'||l_return_status, 4);
    END IF;
    --Added for Case Picking Project end


    IF l_non_cc_allowed = 1 AND l_cc_allowed = 1 THEN
       CLOSE l_curs_ordered_tasks_11;
     ELSIF l_non_cc_allowed = 1 AND l_cc_allowed = 0 THEN
       CLOSE l_curs_ordered_tasks_10;
     ELSIF l_non_cc_allowed = 0 AND l_cc_allowed = 1 THEN
       CLOSE l_curs_ordered_tasks_01;
    END IF;

    IF (l_debug = 1) THEN
       print_debug('Total number of tasks dispatched: => ' || l_ordered_tasks_count, 4);
    END IF;

    IF l_ordered_tasks_count = 0 THEN
       fnd_message.set_name('WMS', 'WMS_TASK_NO_ELIGIBLE_TASKS');
       fnd_msg_pub.ADD;

       IF (l_debug = 1) THEN
     print_debug('dispatch_task - No eligible picking tasks ', 4);
       END IF;

       RAISE fnd_api.g_exc_error;
    END IF;

    l_progress                     := '90';

    -- open reference cursor for this statement

    IF (l_debug = 1) THEN
      print_debug('Before opening reference cursor ', 4);
    END IF;

    OPEN x_task_cur FOR
      SELECT
     task_id,
     subinventory_code,
     locator_id,
          revision,
          transaction_uom,
          transaction_quantity,
          lot_number,
          wms_task_type,
     priority,
     operation_plan_id,
     standard_operation_id,
     effective_start_date,
     effective_end_date,
     person_resource_id,
     machine_resource_id,
     move_order_line_id
      FROM wms_ordered_tasks
      ORDER BY task_sequence_id;

    l_progress       := '120';
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF l_curs_ordered_tasks_11%ISOPEN THEN
        CLOSE l_curs_ordered_tasks_11;
      END IF;

      IF l_curs_ordered_tasks_01%ISOPEN THEN
        CLOSE l_curs_ordered_tasks_01;
      END IF;

       IF l_curs_ordered_tasks_10%ISOPEN THEN
        CLOSE l_curs_ordered_tasks_10;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('dispatch_task:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_ordered_tasks_11%ISOPEN THEN
        CLOSE l_curs_ordered_tasks_11;
      END IF;

      IF l_curs_ordered_tasks_01%ISOPEN THEN
        CLOSE l_curs_ordered_tasks_01;
      END IF;

      IF l_curs_ordered_tasks_10%ISOPEN THEN
    CLOSE l_curs_ordered_tasks_10;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('dispatch_task: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_ordered_tasks_11%ISOPEN THEN
        CLOSE l_curs_ordered_tasks_11;
      END IF;

      IF l_curs_ordered_tasks_01%ISOPEN THEN
        CLOSE l_curs_ordered_tasks_01;
      END IF;

       IF l_curs_ordered_tasks_10%ISOPEN THEN
        CLOSE l_curs_ordered_tasks_10;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('WMS_Task_Dispatch_Engine.dispatch_task', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('dispatch_task: Other exception: ' || Sqlerrm || l_progress, 1);
      END IF;
  END dispatch_task;


  -- Old procedure: Not used from 11.5.10

  PROCEDURE dispatch_task(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 := fnd_api.g_false
  , p_commit                IN            VARCHAR2 := fnd_api.g_false
  , p_sign_on_emp_id        IN            NUMBER
  , p_sign_on_org_id        IN            NUMBER
  , p_sign_on_zone          IN            VARCHAR2 := NULL
  , p_sign_on_equipment_id  IN            NUMBER := NULL -- specific equip id, NULL or -999. -999 stands for none
  , p_sign_on_equipment_srl IN            VARCHAR2 := NULL -- same as above
  , p_task_type             IN            VARCHAR2 -- 'PICKING' or 'ALL'
  , p_cartonization_id      IN            NUMBER := NULL
  , x_task_cur              OUT NOCOPY    task_rec_cur_tp
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  ) IS
    l_cur_x                       NUMBER;
    l_cur_y                       NUMBER;
    l_cur_z                       NUMBER;
    l_opt_task_id                 NUMBER;
    l_opt_task_pick_slip          NUMBER:= 0;  -- bug 2832818 (init value to 0);
    l_opt_task_type               NUMBER;
    l_task_priority               NUMBER;
    l_mo_header_id                NUMBER;
    l_sub_pick_order              NUMBER;
    l_loc_pick_order              NUMBER;
    l_x_coordinate                NUMBER;
    l_y_coordinate                NUMBER;
    l_z_coordinate                NUMBER;
    l_is_locked                   BOOLEAN      := FALSE;
    l_sys_task_type               NUMBER;
    l_is_express_pick             NUMBER       := 0; -- 1 for express pick, 0 not
    l_sign_on_equipment_id        NUMBER;
    l_sign_on_equipment_srl       VARCHAR2(30);
    l_equipment_id_str            VARCHAR2(30);
    l_last_loaded_time            DATE;
    l_last_loaded_task_id         NUMBER;
    l_last_loaded_task_type       NUMBER;
    l_last_dropoff_time           DATE;
    l_last_dropoff_task_id        NUMBER;
    l_last_dropoff_task_type      NUMBER;
    l_last_task_type              NUMBER;
    l_last_task_is_drop           BOOLEAN      := FALSE;
    l_last_task_id                NUMBER;
    l_ordered_tasks_count         NUMBER;
    l_first_task_pick_slip_number NUMBER;
    l_api_name           CONSTANT VARCHAR2(30) := 'dispatch_task';
    l_api_version        CONSTANT NUMBER       := 1.0;
    l_progress                    VARCHAR2(10);
    l_sequence_picks_across_waves NUMBER       := 2;

    /* Bug 3856227
      Added condition in all the cursors selecting cycle count tasks to select
      only those tasks whose cycle count have not been disabled by entering
      an Inactive Date.
      Added the table mtl_cycle_count_headers in the FROM clause and joined with
      mtl_cycle_count_entries and checked for disable_date value with sysdate.
    */

    -- Cursor # 1 for selecting the most optimal task
    -- 1. sub is passed  (1)
    -- 2. order by across wave (1)
    -- 3. not express pick (0)

    CURSOR l_curs_opt_task_110 IS
      SELECT DISTINCT wdtv.task_id task_id
                    , NVL(wdtv.pick_slip_number, -1) pick_slip
                    , wdtv.wms_task_type_id
                    , nvl(wdtv.task_priority, 0)
                    , mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , nvl(loc.x_coordinate, 0)
                    , nvl(loc.y_coordinate, 0)
                    , nvl(loc.z_coordinate, 0)
                 FROM (SELECT transaction_temp_id task_id
                            , standard_operation_id user_task_type_id
                            , wms_task_type wms_task_type_id
                            , organization_id organization_id
                            , subinventory_code ZONE
                            , locator_id locator_id
                            , task_priority task_priority
                            , revision revision
                            , lot_number lot_number
                            , transaction_uom transaction_uom
                            , transaction_quantity transaction_quantity
                            , pick_rule_id pick_rule_id
                            , pick_slip_number pick_slip_number
                            , cartonization_id cartonization_id
                            , inventory_item_id
                            , move_order_line_id
                         FROM mtl_material_transactions_temp
                        WHERE wms_task_type IS NOT NULL
                          AND transaction_status = 2
                          AND(wms_task_status IS NULL
                              OR wms_task_status = 1) --Added for task planning WB. bug#2651318
                       UNION ALL
                       SELECT   MIN(mcce.cycle_count_entry_id) task_id
                              , MIN(mcce.standard_operation_id) user_task_type_id
                              , 3 wms_task_type_id
                              , mcce.organization_id organization_id
                              , mcce.subinventory ZONE
                              , mcce.locator_id locator_id
                              , MIN(mcce.task_priority) task_priority
                              , mcce.revision revision
                              , MIN(mcce.lot_number) lot_number
                              , '' transaction_uom
                              , TO_NUMBER(NULL) transaction_quantity
                              , TO_NUMBER(NULL) pick_rule_id
                              , TO_NUMBER(NULL) pick_slip_number
                              , TO_NUMBER(NULL) cartonization_id
                              , mcce.inventory_item_id
                              , TO_NUMBER(NULL) move_order_line_id
                           FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
                          WHERE mcce.entry_status_code IN(1, 3)
                            AND NVL(mcce.export_flag, 2) = 2
                            -- bug 3972076
                            --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
                            AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
                            AND NVL(mcch.disable_date,sysdate+1)> sysdate
                       GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv
                    , -- inlined wms_dispatchable_tasks_v, bug 2648133
                      (SELECT utt_emp.standard_operation_id standard_operation_id
                            , utt_emp.resource_id ROLE
                            , utt_eqp.resource_id equipment
                            , utt_emp.person_id emp_id
                            , utt_eqp.inventory_item_id eqp_id
                            , NULL eqp_srl  /* removed for bug 2095237 */
                         FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                    , x_utt_res1.resource_id resource_id
                                    , x_emp_r.person_id
                                 FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                WHERE x_utt_res1.resource_id = r1.resource_id
                                  AND r1.resource_type = 2
                                  AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                            , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                    , x_utt_res2.resource_id resource_id
                                    , x_eqp_r.inventory_item_id inventory_item_id
                                 FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                WHERE x_utt_res2.resource_id = r2.resource_id
                                  AND r2.resource_type = 1
                                  AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                        WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                    , -- inlined wms_person_resource_utt_v, bug 2648133
                      mtl_item_locations loc
                    , mtl_secondary_inventories sub
                    , mtl_txn_request_lines mol
                WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                  AND wdtv.organization_id = p_sign_on_org_id
                  AND wdtv.wms_task_type_id = NVL(l_sys_task_type, wdtv.wms_task_type_id) -- restrict to picking tasks or all tasks
                  AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
                  AND wdtv.ZONE = p_sign_on_zone --  removed NVL, bug 2648133
                  AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                  AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                  AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                  AND wdtv.locator_id = loc.inventory_location_id(+)
                  AND wdtv.ZONE = sub.secondary_inventory_name
                  AND wdtv.organization_id = sub.organization_id
                  AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
        AND Nvl(wdtv.pick_slip_number, -1) <> l_opt_task_pick_slip -- bug 2832818
        AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                 (
                       SELECT NULL
                         FROM mtl_material_transactions_temp mmtt
                        WHERE mmtt.transaction_temp_id = wdtv.task_id
                          AND mmtt.parent_line_id IS NOT NULL
                          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                  AND NOT EXISTS -- exclude tasks already dispatched
                                 (SELECT NULL
                                    FROM wms_dispatched_tasks wdt1
                                   WHERE wdt1.transaction_temp_id = wdtv.task_id
                                     AND wdt1.task_type = wdtv.wms_task_type_id)
                  --******************
                  AND wdtv.task_id NOT IN -- excluded skipped tasks
                                          (
                       SELECT wdtv.task_id
                         FROM wms_skip_task_exceptions wste, mtl_parameters mp
                        WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                          AND wste.task_id = wdtv.task_id
                          AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                          AND wste.organization_id = mp.organization_id)
             --*****************
             --J Addition
                   AND  wdtv.ZONE not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
         )
      ORDER BY        nvl(wdtv.task_priority, 0)
                    , -- removed order by segments for bug 2657909
                      mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , (
                         (loc.x_coordinate - l_cur_x) *(loc.x_coordinate - l_cur_x)
                       + (loc.y_coordinate - l_cur_y) *(loc.y_coordinate - l_cur_y)
                       + (loc.z_coordinate - l_cur_z) *(loc.z_coordinate - l_cur_z)
                      )
                    , wdtv.task_id;

    -- Cursor # 2 for selecting the most optimal task
    -- 1. sub is passed  (1)
    -- 2. order by across wave (1)
    -- 3. Express pick (1)

    CURSOR l_curs_opt_task_111 IS
      SELECT DISTINCT wdtv.task_id task_id
                    , -- added distinct for bug 2657909
                      NVL(wdtv.pick_slip_number, -1) pick_slip
                    , wdtv.wms_task_type_id
                    , nvl(wdtv.task_priority, 0)
                    , -- added following because of distinct for bug 2657909
                      mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , nvl(loc.x_coordinate, 0)
                    , nvl(loc.y_coordinate, 0)
                    , nvl(loc.z_coordinate, 0)
                 FROM (SELECT transaction_temp_id task_id
                            , standard_operation_id user_task_type_id
                            , wms_task_type wms_task_type_id
                            , organization_id organization_id
                            , subinventory_code ZONE
                            , locator_id locator_id
                            , task_priority task_priority
                            , revision revision
                            , lot_number lot_number
                            , transaction_uom transaction_uom
                            , transaction_quantity transaction_quantity
                            , pick_rule_id pick_rule_id
                            , pick_slip_number pick_slip_number
                            , cartonization_id cartonization_id
                            , inventory_item_id
                            , move_order_line_id
                         FROM mtl_material_transactions_temp
                        WHERE wms_task_type IS NOT NULL
                          AND transaction_status = 2
                          AND(wms_task_status IS NULL
                              OR wms_task_status = 1) --Added for task planning WB. bug#2651318
                       UNION ALL
                       SELECT   MIN(mcce.cycle_count_entry_id) task_id
                              , MIN(mcce.standard_operation_id) user_task_type_id
                              , 3 wms_task_type_id
                              , mcce.organization_id organization_id
                              , mcce.subinventory ZONE
                              , mcce.locator_id locator_id
                              , MIN(mcce.task_priority) task_priority
                              , mcce.revision revision
                              , MIN(mcce.lot_number) lot_number
                              , '' transaction_uom
                              , TO_NUMBER(NULL) transaction_quantity
                              , TO_NUMBER(NULL) pick_rule_id
                              , TO_NUMBER(NULL) pick_slip_number
                              , TO_NUMBER(NULL) cartonization_id
                              , mcce.inventory_item_id
                              , TO_NUMBER(NULL) move_order_line_id
                           FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
                          WHERE mcce.entry_status_code IN(1, 3)
                            AND NVL(mcce.export_flag, 2) = 2
                            -- bug 3972076
                            --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
                            AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
                            AND NVL(mcch.disable_date,sysdate+1)> sysdate
                       GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv
                    , -- inlined wms_dispatchable_tasks_v, bug 2648133
                      (SELECT utt_emp.standard_operation_id standard_operation_id
                            , utt_emp.resource_id ROLE
                            , utt_eqp.resource_id equipment
                            , utt_emp.person_id emp_id
                            , utt_eqp.inventory_item_id eqp_id
                            , NULL eqp_srl  /* removed for bug 2095237 */
                         FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                    , x_utt_res1.resource_id resource_id
                                    , x_emp_r.person_id
                                 FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                WHERE x_utt_res1.resource_id = r1.resource_id
                                  AND r1.resource_type = 2
                                  AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                            , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                    , x_utt_res2.resource_id resource_id
                                    , x_eqp_r.inventory_item_id inventory_item_id
                                 FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                WHERE x_utt_res2.resource_id = r2.resource_id
                                  AND r2.resource_type = 1
                                  AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                        WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                    , -- inlined wms_person_resource_utt_v, bug 2648133
                      mtl_item_locations loc
                    , mtl_secondary_inventories sub
                    , mtl_txn_request_lines mol
                --    mtl_system_items msi    -- bug 2648133
      WHERE           v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                  AND wdtv.organization_id = p_sign_on_org_id
                  AND wdtv.wms_task_type_id = NVL(l_sys_task_type, wdtv.wms_task_type_id) -- restrict to picking tasks or all tasks
                  AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
                  AND wdtv.ZONE = p_sign_on_zone --  removed NVL, bug 2648133
                  AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                  AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                  AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                  AND wdtv.locator_id = loc.inventory_location_id(+)
                  AND wdtv.ZONE = sub.secondary_inventory_name
                  AND wdtv.organization_id = sub.organization_id
                  AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
           AND Nvl(wdtv.pick_slip_number, -1) <> l_opt_task_pick_slip -- bug 2832818
            AND wms_express_pick_task.is_express_pick_task_eligible(wdtv.task_id) = 'S'
                  AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                 (
                       SELECT NULL
                         FROM mtl_material_transactions_temp mmtt
                        WHERE mmtt.transaction_temp_id = wdtv.task_id
                          AND mmtt.parent_line_id IS NOT NULL
                          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                  AND NOT EXISTS -- exclude tasks already dispatched
                                 (SELECT NULL
                                    FROM wms_dispatched_tasks wdt1
                                   WHERE wdt1.transaction_temp_id = wdtv.task_id
                                     AND wdt1.task_type = wdtv.wms_task_type_id)
                  --******************
                  AND wdtv.task_id NOT IN -- excluded skipped tasks
                                          (
                       SELECT wdtv.task_id
                         FROM wms_skip_task_exceptions wste, mtl_parameters mp
                        WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                          AND wste.task_id = wdtv.task_id
                          AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                          AND wste.organization_id = mp.organization_id)
             --*****************
             --J Addition
                   AND  wdtv.ZONE not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
            )
      ORDER BY        nvl(wdtv.task_priority, 0)
                    , -- removed order by segments for bug 2657909
                      mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , (
                         (loc.x_coordinate - l_cur_x) *(loc.x_coordinate - l_cur_x)
                       + (loc.y_coordinate - l_cur_y) *(loc.y_coordinate - l_cur_y)
                       + (loc.z_coordinate - l_cur_z) *(loc.z_coordinate - l_cur_z)
                      )
                    , wdtv.task_id;

    -- Cursor # 3 for selecting the most optimal task
    -- 1. sub is NOT passed  (0)
    -- 2. order by across wave (1)
    -- 3. not express pick (0)

    CURSOR l_curs_opt_task_010 IS
      SELECT DISTINCT wdtv.task_id task_id
                    , -- added distinct for bug 2657909
                      NVL(wdtv.pick_slip_number, -1) pick_slip
                    , wdtv.wms_task_type_id
                    , nvl(wdtv.task_priority, 0)
                    , -- added following because of distinct for bug 2657909
                      mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , nvl(loc.x_coordinate, 0)
                    , nvl(loc.y_coordinate, 0)
                    , nvl(loc.z_coordinate, 0)
                 FROM (SELECT transaction_temp_id task_id
                            , standard_operation_id user_task_type_id
                            , wms_task_type wms_task_type_id
                            , organization_id organization_id
                            , subinventory_code ZONE
                            , locator_id locator_id
                            , task_priority task_priority
                            , revision revision
                            , lot_number lot_number
                            , transaction_uom transaction_uom
                            , transaction_quantity transaction_quantity
                            , pick_rule_id pick_rule_id
                            , pick_slip_number pick_slip_number
                            , cartonization_id cartonization_id
                            , inventory_item_id
                            , move_order_line_id
                         FROM mtl_material_transactions_temp
                        WHERE wms_task_type IS NOT NULL
                          AND transaction_status = 2
                          AND(wms_task_status IS NULL
                              OR wms_task_status = 1) --Added for task planning WB. bug#2651318
                       UNION ALL
                       SELECT   MIN(mcce.cycle_count_entry_id) task_id
                              , MIN(mcce.standard_operation_id) user_task_type_id
                              , 3 wms_task_type_id
                              , mcce.organization_id organization_id
                              , mcce.subinventory ZONE
                              , mcce.locator_id locator_id
                              , MIN(mcce.task_priority) task_priority
                              , mcce.revision revision
                              , MIN(mcce.lot_number) lot_number
                              , '' transaction_uom
                              , TO_NUMBER(NULL) transaction_quantity
                              , TO_NUMBER(NULL) pick_rule_id
                              , TO_NUMBER(NULL) pick_slip_number
                              , TO_NUMBER(NULL) cartonization_id
                              , mcce.inventory_item_id
                              , TO_NUMBER(NULL) move_order_line_id
                           FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
                          WHERE mcce.entry_status_code IN(1, 3)
                            AND NVL(mcce.export_flag, 2) = 2
                            -- bug 3972076
                            --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
                            AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
                            AND NVL(mcch.disable_date,sysdate+1)> sysdate
                       GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv
                    , -- inlined wms_dispatchable_tasks_v, bug 2648133
                      (SELECT utt_emp.standard_operation_id standard_operation_id
                            , utt_emp.resource_id ROLE
                            , utt_eqp.resource_id equipment
                            , utt_emp.person_id emp_id
                            , utt_eqp.inventory_item_id eqp_id
                            , NULL eqp_srl  /* removed for bug 2095237 */
                         FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                    , x_utt_res1.resource_id resource_id
                                    , x_emp_r.person_id
                                 FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                WHERE x_utt_res1.resource_id = r1.resource_id
                                  AND r1.resource_type = 2
                                  AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                            , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                    , x_utt_res2.resource_id resource_id
                                    , x_eqp_r.inventory_item_id inventory_item_id
                                 FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                WHERE x_utt_res2.resource_id = r2.resource_id
                                  AND r2.resource_type = 1
                                  AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                        WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                    , -- inlined wms_person_resource_utt_v, bug 2648133
                      mtl_item_locations loc
                    , mtl_secondary_inventories sub
                    , mtl_txn_request_lines mol
                WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                  AND wdtv.organization_id = p_sign_on_org_id
                  AND wdtv.wms_task_type_id = NVL(l_sys_task_type, wdtv.wms_task_type_id) -- restrict to picking tasks or all tasks
                  AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
                  AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                  AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                  AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                  AND wdtv.locator_id = loc.inventory_location_id(+)
                  AND wdtv.ZONE = sub.secondary_inventory_name
                  AND wdtv.organization_id = sub.organization_id
                  AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
        AND Nvl(wdtv.pick_slip_number, -1) <> l_opt_task_pick_slip -- bug 2832818
              AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                 (
                       SELECT NULL
                         FROM mtl_material_transactions_temp mmtt
                        WHERE mmtt.transaction_temp_id = wdtv.task_id
                          AND mmtt.parent_line_id IS NOT NULL
                          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                  AND NOT EXISTS -- exclude tasks already dispatched
                                 (SELECT NULL
                                    FROM wms_dispatched_tasks wdt1
                                   WHERE wdt1.transaction_temp_id = wdtv.task_id
                                     AND wdt1.task_type = wdtv.wms_task_type_id)
                  --******************
                  AND wdtv.task_id NOT IN -- excluded skipped tasks
                                          (
                       SELECT wdtv.task_id
                         FROM wms_skip_task_exceptions wste, mtl_parameters mp
                        WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                          AND wste.task_id = wdtv.task_id
                          AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                          AND wste.organization_id = mp.organization_id)
             --*****************
            --J Addition
                   AND  wdtv.ZONE not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
         )
      ORDER BY        nvl(wdtv.task_priority, 0)
                    , -- removed order by segments for bug 2657909
                      mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , (
                         (loc.x_coordinate - l_cur_x) *(loc.x_coordinate - l_cur_x)
                       + (loc.y_coordinate - l_cur_y) *(loc.y_coordinate - l_cur_y)
                       + (loc.z_coordinate - l_cur_z) *(loc.z_coordinate - l_cur_z)
                      )
                    , wdtv.task_id;

    -- Cursor # 4 for selecting the most optimal task
    -- 1. sub is NOT passed  (0)
    -- 2. order by across wave (1)
    -- 3. express pick (1)

    CURSOR l_curs_opt_task_011 IS
      SELECT DISTINCT wdtv.task_id task_id
                    , -- added distinct for bug 2657909
                      NVL(wdtv.pick_slip_number, -1) pick_slip
                    , wdtv.wms_task_type_id
                    , nvl(wdtv.task_priority, 0)
                    , -- added following because of distinct for bug 2657909
                      mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , nvl(loc.x_coordinate, 0)
                    , nvl(loc.y_coordinate, 0)
                    , nvl(loc.z_coordinate, 0)
                 FROM (SELECT transaction_temp_id task_id
                            , standard_operation_id user_task_type_id
                            , wms_task_type wms_task_type_id
                            , organization_id organization_id
                            , subinventory_code ZONE
                            , locator_id locator_id
                            , task_priority task_priority
                            , revision revision
                            , lot_number lot_number
                            , transaction_uom transaction_uom
                            , transaction_quantity transaction_quantity
                            , pick_rule_id pick_rule_id
                            , pick_slip_number pick_slip_number
                            , cartonization_id cartonization_id
                            , inventory_item_id
                            , move_order_line_id
                         FROM mtl_material_transactions_temp
                        WHERE wms_task_type IS NOT NULL
                          AND transaction_status = 2
                          AND(wms_task_status IS NULL
                              OR wms_task_status = 1) --Added for task planning WB. bug#2651318
                       UNION ALL
                       SELECT   MIN(mcce.cycle_count_entry_id) task_id
                              , MIN(mcce.standard_operation_id) user_task_type_id
                              , 3 wms_task_type_id
                              , mcce.organization_id organization_id
                              , mcce.subinventory ZONE
                              , mcce.locator_id locator_id
                              , MIN(mcce.task_priority) task_priority
                              , mcce.revision revision
                              , MIN(mcce.lot_number) lot_number
                              , '' transaction_uom
                              , TO_NUMBER(NULL) transaction_quantity
                              , TO_NUMBER(NULL) pick_rule_id
                              , TO_NUMBER(NULL) pick_slip_number
                              , TO_NUMBER(NULL) cartonization_id
                              , mcce.inventory_item_id
                              , TO_NUMBER(NULL) move_order_line_id
                           FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
                          WHERE mcce.entry_status_code IN(1, 3)
                            AND NVL(mcce.export_flag, 2) = 2
                            -- bug 3972076
                            --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
                            AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
                            AND NVL(mcch.disable_date,sysdate+1)> sysdate
                       GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv
                    , -- inlined wms_dispatchable_tasks_v, bug 2648133
                      (SELECT utt_emp.standard_operation_id standard_operation_id
                            , utt_emp.resource_id ROLE
                            , utt_eqp.resource_id equipment
                            , utt_emp.person_id emp_id
                            , utt_eqp.inventory_item_id eqp_id
                            , NULL eqp_srl  /* removed for bug 2095237 */
                         FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                    , x_utt_res1.resource_id resource_id
                                    , x_emp_r.person_id
                                 FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                WHERE x_utt_res1.resource_id = r1.resource_id
                                  AND r1.resource_type = 2
                                  AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                            , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                    , x_utt_res2.resource_id resource_id
                                    , x_eqp_r.inventory_item_id inventory_item_id
                                 FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                WHERE x_utt_res2.resource_id = r2.resource_id
                                  AND r2.resource_type = 1
                                  AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                        WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                    , -- inlined wms_person_resource_utt_v, bug 2648133
                      mtl_item_locations loc
                    , mtl_secondary_inventories sub
                    , mtl_txn_request_lines mol
                WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                  AND wdtv.organization_id = p_sign_on_org_id
                  AND wdtv.wms_task_type_id = NVL(l_sys_task_type, wdtv.wms_task_type_id) -- restrict to picking tasks or all tasks
                  AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
                  AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                  AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                  AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                  AND wdtv.locator_id = loc.inventory_location_id(+)
                  AND wdtv.ZONE = sub.secondary_inventory_name
                  AND wdtv.organization_id = sub.organization_id
                  AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
                  AND wms_express_pick_task.is_express_pick_task_eligible(wdtv.task_id) = 'S'
        AND Nvl(wdtv.pick_slip_number, -1) <> l_opt_task_pick_slip -- bug 2832818
              AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                 (
                       SELECT NULL
                         FROM mtl_material_transactions_temp mmtt
                        WHERE mmtt.transaction_temp_id = wdtv.task_id
                          AND mmtt.parent_line_id IS NOT NULL
                          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                  AND NOT EXISTS -- exclude tasks already dispatched
                                 (SELECT NULL
                                    FROM wms_dispatched_tasks wdt1
                                   WHERE wdt1.transaction_temp_id = wdtv.task_id
                                     AND wdt1.task_type = wdtv.wms_task_type_id)
                  --******************
                  AND wdtv.task_id NOT IN -- excluded skipped tasks
                                          (
                       SELECT wdtv.task_id
                         FROM wms_skip_task_exceptions wste, mtl_parameters mp
                        WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                          AND wste.task_id = wdtv.task_id
                          AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                          AND wste.organization_id = mp.organization_id)
             --*****************
             --J Addition
                   AND  wdtv.ZONE not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
         )
      ORDER BY        nvl(wdtv.task_priority, 0)
                    , -- removed order by segments for bug 2657909
                      mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , (
                         (loc.x_coordinate - l_cur_x) *(loc.x_coordinate - l_cur_x)
                       + (loc.y_coordinate - l_cur_y) *(loc.y_coordinate - l_cur_y)
                       + (loc.z_coordinate - l_cur_z) *(loc.z_coordinate - l_cur_z)
                      )
                    , wdtv.task_id;

    -- Cursor # 5 for selecting the most optimal task
    -- 1. sub is passed  (1)
    -- 2. NOT order by across wave (0)
    -- 3. NOT express pick (0)

    CURSOR l_curs_opt_task_100 IS
      SELECT DISTINCT wdtv.task_id task_id
                    , -- added distinct for bug 2657909
                      NVL(wdtv.pick_slip_number, -1) pick_slip
                    , wdtv.wms_task_type_id
                    , nvl(wdtv.task_priority, 0)
                    , mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , nvl(loc.x_coordinate, 0)
                    , nvl(loc.y_coordinate, 0)
                    , nvl(loc.z_coordinate, 0)
                 FROM (SELECT transaction_temp_id task_id
                            , standard_operation_id user_task_type_id
                            , wms_task_type wms_task_type_id
                            , organization_id organization_id
                            , subinventory_code ZONE
                            , locator_id locator_id
                            , task_priority task_priority
                            , revision revision
                            , lot_number lot_number
                            , transaction_uom transaction_uom
                            , transaction_quantity transaction_quantity
                            , pick_rule_id pick_rule_id
                            , pick_slip_number pick_slip_number
                            , cartonization_id cartonization_id
                            , inventory_item_id
                            , move_order_line_id
                         FROM mtl_material_transactions_temp
                        WHERE wms_task_type IS NOT NULL
                          AND transaction_status = 2
                          AND(wms_task_status IS NULL
                              OR wms_task_status = 1) --Added for task planning WB. bug#2651318
                       UNION ALL
                       SELECT   MIN(mcce.cycle_count_entry_id) task_id
                              , MIN(mcce.standard_operation_id) user_task_type_id
                              , 3 wms_task_type_id
                              , mcce.organization_id organization_id
                              , mcce.subinventory ZONE
                              , mcce.locator_id locator_id
                              , MIN(mcce.task_priority) task_priority
                              , mcce.revision revision
                              , MIN(mcce.lot_number) lot_number
                              , '' transaction_uom
                              , TO_NUMBER(NULL) transaction_quantity
                              , TO_NUMBER(NULL) pick_rule_id
                              , TO_NUMBER(NULL) pick_slip_number
                              , TO_NUMBER(NULL) cartonization_id
                              , mcce.inventory_item_id
                              , TO_NUMBER(NULL) move_order_line_id
                           FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
                          WHERE mcce.entry_status_code IN(1, 3)
                            AND NVL(mcce.export_flag, 2) = 2
                            -- bug 3972076
                            --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
                            AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
                            AND NVL(mcch.disable_date,sysdate+1)> sysdate
                       GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv
                    , -- inlined wms_dispatchable_tasks_v, bug 2648133
                      (SELECT utt_emp.standard_operation_id standard_operation_id
                            , utt_emp.resource_id ROLE
                            , utt_eqp.resource_id equipment
                            , utt_emp.person_id emp_id
                            , utt_eqp.inventory_item_id eqp_id
                            , NULL eqp_srl  /* removed for bug 2095237 */
                         FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                    , x_utt_res1.resource_id resource_id
                                    , x_emp_r.person_id
                                 FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                WHERE x_utt_res1.resource_id = r1.resource_id
                                  AND r1.resource_type = 2
                                  AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                            , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                    , x_utt_res2.resource_id resource_id
                                    , x_eqp_r.inventory_item_id inventory_item_id
                                 FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                WHERE x_utt_res2.resource_id = r2.resource_id
                                  AND r2.resource_type = 1
                                  AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                        WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                    , -- inlined wms_person_resource_utt_v, bug 2648133
                      mtl_item_locations loc
                    , mtl_secondary_inventories sub
                    , mtl_txn_request_lines mol
                --   mtl_system_items msi      -- bug 2648133
      WHERE           v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                  AND wdtv.organization_id = p_sign_on_org_id
                  AND wdtv.wms_task_type_id = NVL(l_sys_task_type, wdtv.wms_task_type_id) -- restrict to picking tasks or all tasks
                  AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
                  AND wdtv.ZONE = p_sign_on_zone
                  AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                  --   AND Nvl(v.eqp_srl, '@@@') = Nvl(l_sign_on_equipment_srl, Nvl(v.eqp_srl, '@@@'))   removed for bug 2095237
                  AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                  AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                  AND wdtv.locator_id = loc.inventory_location_id(+)
                  AND wdtv.ZONE = sub.secondary_inventory_name
                  AND wdtv.organization_id = sub.organization_id
                  AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
        AND Nvl(wdtv.pick_slip_number, -1) <> l_opt_task_pick_slip -- bug 2832818
              AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                 (
                       SELECT NULL
                         FROM mtl_material_transactions_temp mmtt
                        WHERE mmtt.transaction_temp_id = wdtv.task_id
                          AND mmtt.parent_line_id IS NOT NULL
                          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                  AND NOT EXISTS -- exclude tasks already dispatched
                                 (SELECT NULL
                                    FROM wms_dispatched_tasks wdt1
                                   WHERE wdt1.transaction_temp_id = wdtv.task_id
                                     AND wdt1.task_type = wdtv.wms_task_type_id)
                  --******************
                  AND wdtv.task_id NOT IN -- excluded skipped tasks
                                          (
                       SELECT wdtv.task_id
                         FROM wms_skip_task_exceptions wste, mtl_parameters mp
                        WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                          AND wste.task_id = wdtv.task_id
                          AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                          AND wste.organization_id = mp.organization_id)
             --*****************
             --J Addition
                   AND  wdtv.ZONE not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
         )
      ORDER BY        nvl(wdtv.task_priority, 0)
                    , -- removed order by segments for bug 2657909
                      sub.picking_order
                    , loc.picking_order
                    , (
                         (loc.x_coordinate - l_cur_x) *(loc.x_coordinate - l_cur_x)
                       + (loc.y_coordinate - l_cur_y) *(loc.y_coordinate - l_cur_y)
                       + (loc.z_coordinate - l_cur_z) *(loc.z_coordinate - l_cur_z)
                      )
                    , wdtv.task_id;

    -- Cursor # 6 for selecting the most optimal task
    -- 1. sub is passed  (1)
    -- 2. NOT order by across wave (0)
    -- 3. express pick (1)

    CURSOR l_curs_opt_task_101 IS
      SELECT DISTINCT wdtv.task_id task_id
                    , -- added distinct for bug 2657909
                      NVL(wdtv.pick_slip_number, -1) pick_slip
                    , wdtv.wms_task_type_id
                    , nvl(wdtv.task_priority, 0)
                    , mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , nvl(loc.x_coordinate, 0)
                    , nvl(loc.y_coordinate, 0)
                    , nvl(loc.z_coordinate, 0)
                 FROM (SELECT transaction_temp_id task_id
                            , standard_operation_id user_task_type_id
                            , wms_task_type wms_task_type_id
                            , organization_id organization_id
                            , subinventory_code ZONE
                            , locator_id locator_id
                            , task_priority task_priority
                            , revision revision
                            , lot_number lot_number
                            , transaction_uom transaction_uom
                            , transaction_quantity transaction_quantity
                            , pick_rule_id pick_rule_id
                            , pick_slip_number pick_slip_number
                            , cartonization_id cartonization_id
                            , inventory_item_id
                            , move_order_line_id
                         FROM mtl_material_transactions_temp
                        WHERE wms_task_type IS NOT NULL
                          AND transaction_status = 2
                          AND(wms_task_status IS NULL
                              OR wms_task_status = 1) --Added for task planning WB. bug#2651318
                       UNION ALL
                       SELECT   MIN(mcce.cycle_count_entry_id) task_id
                              , MIN(mcce.standard_operation_id) user_task_type_id
                              , 3 wms_task_type_id
                              , mcce.organization_id organization_id
                              , mcce.subinventory ZONE
                              , mcce.locator_id locator_id
                              , MIN(mcce.task_priority) task_priority
                              , mcce.revision revision
                              , MIN(mcce.lot_number) lot_number
                              , '' transaction_uom
                              , TO_NUMBER(NULL) transaction_quantity
                              , TO_NUMBER(NULL) pick_rule_id
                              , TO_NUMBER(NULL) pick_slip_number
                              , TO_NUMBER(NULL) cartonization_id
                              , mcce.inventory_item_id
                              , TO_NUMBER(NULL) move_order_line_id
                           FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
                          WHERE mcce.entry_status_code IN(1, 3)
                            AND NVL(mcce.export_flag, 2) = 2
                            -- bug 3972076
                            -- AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
                            AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
                            AND NVL(mcch.disable_date,sysdate+1)> sysdate
                       GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv
                    , -- inlined wms_dispatchable_tasks_v, bug 2648133
                      (SELECT utt_emp.standard_operation_id standard_operation_id
                            , utt_emp.resource_id ROLE
                            , utt_eqp.resource_id equipment
                            , utt_emp.person_id emp_id
                            , utt_eqp.inventory_item_id eqp_id
                            , NULL eqp_srl  /* removed for bug 2095237 */
                         FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                    , x_utt_res1.resource_id resource_id
                                    , x_emp_r.person_id
                                 FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                WHERE x_utt_res1.resource_id = r1.resource_id
                                  AND r1.resource_type = 2
                                  AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                            , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                    , x_utt_res2.resource_id resource_id
                                    , x_eqp_r.inventory_item_id inventory_item_id
                                 FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                WHERE x_utt_res2.resource_id = r2.resource_id
                                  AND r2.resource_type = 1
                                  AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                        WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                    , -- inlined wms_person_resource_utt_v, bug 2648133
                      mtl_item_locations loc
                    , mtl_secondary_inventories sub
                    , mtl_txn_request_lines mol
                WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                  AND wdtv.organization_id = p_sign_on_org_id
                  AND wdtv.wms_task_type_id = NVL(l_sys_task_type, wdtv.wms_task_type_id) -- restrict to picking tasks or all tasks
                  AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
                  AND wdtv.ZONE = p_sign_on_zone
                  AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                  AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                  AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                  AND wdtv.locator_id = loc.inventory_location_id(+)
                  AND wdtv.ZONE = sub.secondary_inventory_name
                  AND wdtv.organization_id = sub.organization_id
                  AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
                  AND wms_express_pick_task.is_express_pick_task_eligible(wdtv.task_id) = 'S'
        AND Nvl(wdtv.pick_slip_number, -1) <> l_opt_task_pick_slip -- bug 2832818
               AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                 (
                       SELECT NULL
                         FROM mtl_material_transactions_temp mmtt
                        WHERE mmtt.transaction_temp_id = wdtv.task_id
                          AND mmtt.parent_line_id IS NOT NULL
                          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                  AND NOT EXISTS -- exclude tasks already dispatched
                                 (SELECT NULL
                                    FROM wms_dispatched_tasks wdt1
                                   WHERE wdt1.transaction_temp_id = wdtv.task_id
                                     AND wdt1.task_type = wdtv.wms_task_type_id)
                  --******************
                  AND wdtv.task_id NOT IN -- excluded skipped tasks
                                          (
                       SELECT wdtv.task_id
                         FROM wms_skip_task_exceptions wste, mtl_parameters mp
                        WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                          AND wste.task_id = wdtv.task_id
                          AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                          AND wste.organization_id = mp.organization_id)
             --*****************
            --J Addition
                   AND  wdtv.ZONE not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
            )
      ORDER BY        nvl(wdtv.task_priority, 0)
                    , -- removed order by segments for bug 2657909
                      sub.picking_order
                    , loc.picking_order
                    , (
                         (loc.x_coordinate - l_cur_x) *(loc.x_coordinate - l_cur_x)
                       + (loc.y_coordinate - l_cur_y) *(loc.y_coordinate - l_cur_y)
                       + (loc.z_coordinate - l_cur_z) *(loc.z_coordinate - l_cur_z)
                      )
                    , wdtv.task_id;

    -- Cursor # 7 for selecting the most optimal task
    -- 1. sub NOT passed  (0)
    -- 2. NOT order by across wave (0)
    -- 3. NOT express pick (0)

    CURSOR l_curs_opt_task_000 IS
      SELECT DISTINCT wdtv.task_id task_id
                    , -- added distinct for bug 2657909
                      NVL(wdtv.pick_slip_number, -1) pick_slip
                    , wdtv.wms_task_type_id
                    , nvl(wdtv.task_priority, 0)
                    , mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , nvl(loc.x_coordinate, 0)
                    , nvl(loc.y_coordinate, 0)
                    , nvl(loc.z_coordinate, 0)
                 FROM (SELECT transaction_temp_id task_id
                            , standard_operation_id user_task_type_id
                            , wms_task_type wms_task_type_id
                            , organization_id organization_id
                            , subinventory_code ZONE
                            , locator_id locator_id
                            , task_priority task_priority
                            , revision revision
                            , lot_number lot_number
                            , transaction_uom transaction_uom
                            , transaction_quantity transaction_quantity
                            , pick_rule_id pick_rule_id
                            , pick_slip_number pick_slip_number
                            , cartonization_id cartonization_id
                            , inventory_item_id
                            , move_order_line_id
                         FROM mtl_material_transactions_temp
                        WHERE wms_task_type IS NOT NULL
                          AND transaction_status = 2
                          AND(wms_task_status IS NULL
                              OR wms_task_status = 1) --Added for task planning WB. bug#2651318
                       UNION ALL
                       SELECT   MIN(mcce.cycle_count_entry_id) task_id
                              , MIN(mcce.standard_operation_id) user_task_type_id
                              , 3 wms_task_type_id
                              , mcce.organization_id organization_id
                              , mcce.subinventory ZONE
                              , mcce.locator_id locator_id
                              , MIN(mcce.task_priority) task_priority
                              , mcce.revision revision
                              , MIN(mcce.lot_number) lot_number
                              , '' transaction_uom
                              , TO_NUMBER(NULL) transaction_quantity
                              , TO_NUMBER(NULL) pick_rule_id
                              , TO_NUMBER(NULL) pick_slip_number
                              , TO_NUMBER(NULL) cartonization_id
                              , mcce.inventory_item_id
                              , TO_NUMBER(NULL) move_order_line_id
                           FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
                          WHERE mcce.entry_status_code IN(1, 3)
                            AND NVL(mcce.export_flag, 2) = 2
                            -- bug 3972076
                            -- AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
                            AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
                            AND NVL(mcch.disable_date,sysdate+1)> sysdate
                       GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv
                    , -- inlined wms_dispatchable_tasks_v, bug 2648133
                      (SELECT utt_emp.standard_operation_id standard_operation_id
                            , utt_emp.resource_id ROLE
                            , utt_eqp.resource_id equipment
                            , utt_emp.person_id emp_id
                            , utt_eqp.inventory_item_id eqp_id
                            , NULL eqp_srl  /* removed for bug 2095237 */
                         FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                    , x_utt_res1.resource_id resource_id
                                    , x_emp_r.person_id
                                 FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                WHERE x_utt_res1.resource_id = r1.resource_id
                                  AND r1.resource_type = 2
                                  AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                            , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                    , x_utt_res2.resource_id resource_id
                                    , x_eqp_r.inventory_item_id inventory_item_id
                                 FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                WHERE x_utt_res2.resource_id = r2.resource_id
                                  AND r2.resource_type = 1
                                  AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                        WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                    , -- inlined wms_person_resource_utt_v, bug 2648133
                      mtl_item_locations loc
                    , mtl_secondary_inventories sub
                    , mtl_txn_request_lines mol
                WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                  AND wdtv.organization_id = p_sign_on_org_id
                  AND wdtv.wms_task_type_id = NVL(l_sys_task_type, wdtv.wms_task_type_id) -- restrict to picking tasks or all tasks
                  AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
                  AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                  AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                  AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                  AND wdtv.locator_id = loc.inventory_location_id(+)
                  AND wdtv.ZONE = sub.secondary_inventory_name
                  AND wdtv.organization_id = sub.organization_id
                  AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
     AND Nvl(wdtv.pick_slip_number, -1) <> l_opt_task_pick_slip -- bug 2832818
                AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                 (
                       SELECT NULL
                         FROM mtl_material_transactions_temp mmtt
                        WHERE mmtt.transaction_temp_id = wdtv.task_id
                          AND mmtt.parent_line_id IS NOT NULL
                          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                  AND NOT EXISTS -- exclude tasks already dispatched
                                 (SELECT NULL
                                    FROM wms_dispatched_tasks wdt1
                                   WHERE wdt1.transaction_temp_id = wdtv.task_id
                                     AND wdt1.task_type = wdtv.wms_task_type_id)
                  --******************
                  AND wdtv.task_id NOT IN -- excluded skipped tasks
                                          (
                       SELECT wdtv.task_id
                         FROM wms_skip_task_exceptions wste, mtl_parameters mp
                        WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                          AND wste.task_id = wdtv.task_id
                          AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                          AND wste.organization_id = mp.organization_id)
             --*****************
            --J Addition
                   AND  wdtv.ZONE not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
      )
      ORDER BY        nvl(wdtv.task_priority, 0)
                    , -- removed order by segments for bug 2657909
                      sub.picking_order
                    , loc.picking_order
                    , (
                         (loc.x_coordinate - l_cur_x) *(loc.x_coordinate - l_cur_x)
                       + (loc.y_coordinate - l_cur_y) *(loc.y_coordinate - l_cur_y)
                       + (loc.z_coordinate - l_cur_z) *(loc.z_coordinate - l_cur_z)
                      )
                    , wdtv.task_id;

    -- Cursor # 8 for selecting the most optimal task
    -- 1. sub NOT passed  (0)
    -- 2. NOT order by across wave (0)
    -- 3. express pick (1)

    CURSOR l_curs_opt_task_001 IS
      SELECT DISTINCT wdtv.task_id task_id
                    , -- added distinct for bug 2657909
                      NVL(wdtv.pick_slip_number, -1) pick_slip
                    , wdtv.wms_task_type_id
                    , nvl(wdtv.task_priority, 0)
                    , mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , nvl(loc.x_coordinate, 0)
                    , nvl(loc.y_coordinate, 0)
                    , nvl(loc.z_coordinate, 0)
                 FROM (SELECT transaction_temp_id task_id
                            , standard_operation_id user_task_type_id
                            , wms_task_type wms_task_type_id
                            , organization_id organization_id
                            , subinventory_code ZONE
                            , locator_id locator_id
                            , task_priority task_priority
                            , revision revision
                            , lot_number lot_number
                            , transaction_uom transaction_uom
                            , transaction_quantity transaction_quantity
                            , pick_rule_id pick_rule_id
                            , pick_slip_number pick_slip_number
                            , cartonization_id cartonization_id
                            , inventory_item_id
                            , move_order_line_id
                         FROM mtl_material_transactions_temp
                        WHERE wms_task_type IS NOT NULL
                          AND transaction_status = 2
                          AND(wms_task_status IS NULL
                              OR wms_task_status = 1) --Added for task planning WB. bug#2651318
                       UNION ALL
                       SELECT   MIN(mcce.cycle_count_entry_id) task_id
                              , MIN(mcce.standard_operation_id) user_task_type_id
                              , 3 wms_task_type_id
                              , mcce.organization_id organization_id
                              , mcce.subinventory ZONE
                              , mcce.locator_id locator_id
                              , MIN(mcce.task_priority) task_priority
                              , mcce.revision revision
                              , MIN(mcce.lot_number) lot_number
                              , '' transaction_uom
                              , TO_NUMBER(NULL) transaction_quantity
                              , TO_NUMBER(NULL) pick_rule_id
                              , TO_NUMBER(NULL) pick_slip_number
                              , TO_NUMBER(NULL) cartonization_id
                              , mcce.inventory_item_id
                              , TO_NUMBER(NULL) move_order_line_id
                           FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
                          WHERE mcce.entry_status_code IN(1, 3)
                            AND NVL(mcce.export_flag, 2) = 2
                            -- bug 3972076
                            --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
                            AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
                            AND NVL(mcch.disable_date,sysdate+1)> sysdate
                       GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv
                    , -- inlined wms_dispatchable_tasks_v, bug 2648133
                      (SELECT utt_emp.standard_operation_id standard_operation_id
                            , utt_emp.resource_id ROLE
                            , utt_eqp.resource_id equipment
                            , utt_emp.person_id emp_id
                            , utt_eqp.inventory_item_id eqp_id
                            , NULL eqp_srl  /* removed for bug 2095237 */
                         FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                    , x_utt_res1.resource_id resource_id
                                    , x_emp_r.person_id
                                 FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                WHERE x_utt_res1.resource_id = r1.resource_id
                                  AND r1.resource_type = 2
                                  AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                            , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                    , x_utt_res2.resource_id resource_id
                                    , x_eqp_r.inventory_item_id inventory_item_id
                                 FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                WHERE x_utt_res2.resource_id = r2.resource_id
                                  AND r2.resource_type = 1
                                  AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                        WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                    , -- inlined wms_person_resource_utt_v, bug 2648133
                      mtl_item_locations loc
                    , mtl_secondary_inventories sub
                    , mtl_txn_request_lines mol
                WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                  AND wdtv.organization_id = p_sign_on_org_id
                  AND wdtv.wms_task_type_id = NVL(l_sys_task_type, wdtv.wms_task_type_id) -- restrict to picking tasks or all tasks
                  AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
                  AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                  AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                  AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                  AND wdtv.locator_id = loc.inventory_location_id(+)
                  AND wdtv.ZONE = sub.secondary_inventory_name
                  AND wdtv.organization_id = sub.organization_id
                  AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
                  AND wms_express_pick_task.is_express_pick_task_eligible(wdtv.task_id) = 'S'
        AND Nvl(wdtv.pick_slip_number, -1) <> l_opt_task_pick_slip -- bug 2832818
             AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                 (
                       SELECT NULL
                         FROM mtl_material_transactions_temp mmtt
                        WHERE mmtt.transaction_temp_id = wdtv.task_id
                          AND mmtt.parent_line_id IS NOT NULL
                          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                  AND NOT EXISTS -- exclude tasks already dispatched
                                 (SELECT NULL
                                    FROM wms_dispatched_tasks wdt1
                                   WHERE wdt1.transaction_temp_id = wdtv.task_id
                                     AND wdt1.task_type = wdtv.wms_task_type_id)
                  --******************
                  AND wdtv.task_id NOT IN -- excluded skipped tasks
                                          (
                       SELECT wdtv.task_id
                         FROM wms_skip_task_exceptions wste, mtl_parameters mp
                        WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                          AND wste.task_id = wdtv.task_id
                          AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                          AND wste.organization_id = mp.organization_id)
             --*****************
             --J Addition
                   AND  wdtv.ZONE not in  (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
         )
      ORDER BY        nvl(wdtv.task_priority, 0)
                    , -- removed order by segments for bug 2657909
                      sub.picking_order
                    , loc.picking_order
                    , (
                         (loc.x_coordinate - l_cur_x) *(loc.x_coordinate - l_cur_x)
                       + (loc.y_coordinate - l_cur_y) *(loc.y_coordinate - l_cur_y)
                       + (loc.z_coordinate - l_cur_z) *(loc.z_coordinate - l_cur_z)
                      )
                    , wdtv.task_id;

    CURSOR l_curs_ordered_tasks(v_pick_slip_number NUMBER, v_task_id NUMBER, v_task_type NUMBER) IS
      SELECT DISTINCT wdtv.task_id task_id
                    , -- added distinct for bug 2657909
                      NVL(wdtv.pick_slip_number, -1) pick_slip
                    , wdtv.wms_task_type_id
                    , nvl(wdtv.task_priority, 0)
                    , -- added following because of distinct for bug 2657909
                      mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , nvl(loc.x_coordinate, 0)
                    , nvl(loc.y_coordinate, 0)
                    , nvl(loc.z_coordinate, 0)
                 FROM (SELECT transaction_temp_id task_id
                            , standard_operation_id user_task_type_id
                            , wms_task_type wms_task_type_id
                            , organization_id organization_id
                            , subinventory_code ZONE
                            , locator_id locator_id
                            , task_priority task_priority
                            , revision revision
                            , lot_number lot_number
                            , transaction_uom transaction_uom
                            , transaction_quantity transaction_quantity
                            , pick_rule_id pick_rule_id
                            , pick_slip_number pick_slip_number
                            , cartonization_id cartonization_id
                            , inventory_item_id
                            , move_order_line_id
                         FROM mtl_material_transactions_temp
                        WHERE wms_task_type IS NOT NULL
                          AND transaction_status = 2
                          AND(wms_task_status IS NULL
                              OR wms_task_status = 1) --Added for task planning WB. bug#2651318
                       UNION ALL
                       SELECT   MIN(mcce.cycle_count_entry_id) task_id
                              , MIN(mcce.standard_operation_id) user_task_type_id
                              , 3 wms_task_type_id
                              , mcce.organization_id organization_id
                              , mcce.subinventory ZONE
                              , mcce.locator_id locator_id
                              , MIN(mcce.task_priority) task_priority
                              , mcce.revision revision
                              , MIN(mcce.lot_number) lot_number
                              , '' transaction_uom
                              , TO_NUMBER(NULL) transaction_quantity
                              , TO_NUMBER(NULL) pick_rule_id
                              , TO_NUMBER(NULL) pick_slip_number
                              , TO_NUMBER(NULL) cartonization_id
                              , mcce.inventory_item_id
                              , TO_NUMBER(NULL) move_order_line_id
                           FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
                          WHERE mcce.entry_status_code IN(1, 3)
                            AND NVL(mcce.export_flag, 2) = 2
                            -- bug 3972076
                            --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
                            AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
                            AND NVL(mcch.disable_date,sysdate+1)> sysdate
                       GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv
                    , -- inlined wms_dispatchable_tasks_v, bug 2648133
                      (SELECT utt_emp.standard_operation_id standard_operation_id
                            , utt_emp.resource_id ROLE
                            , utt_eqp.resource_id equipment
                            , utt_emp.person_id emp_id
                            , utt_eqp.inventory_item_id eqp_id
                            , NULL eqp_srl  /* removed for bug 2095237 */
                         FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                    , x_utt_res1.resource_id resource_id
                                    , x_emp_r.person_id
                                 FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                WHERE x_utt_res1.resource_id = r1.resource_id
                                  AND r1.resource_type = 2
                                  AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                            , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                    , x_utt_res2.resource_id resource_id
                                    , x_eqp_r.inventory_item_id inventory_item_id
                                 FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                WHERE x_utt_res2.resource_id = r2.resource_id
                                  AND r2.resource_type = 1
                                  AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                        WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                    , -- inlined wms_person_resource_utt_v, bug 2648133
                      mtl_item_locations loc
                    , mtl_secondary_inventories sub
                    , mtl_txn_request_lines mol
                WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                  AND(wdtv.pick_slip_number = v_pick_slip_number
                      OR(wdtv.task_id = v_task_id
                         AND wdtv.wms_task_type_id = v_task_type))
                  AND wdtv.organization_id = p_sign_on_org_id
                  AND wdtv.wms_task_type_id = NVL(l_sys_task_type, wdtv.wms_task_type_id) -- restrict to picking tasks or all tasks
                  AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
                  AND NVL(wdtv.ZONE, '@@@') = NVL(p_sign_on_zone, NVL(wdtv.ZONE, '@@@'))
                  AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                  AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                  AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                  AND wdtv.locator_id = loc.inventory_location_id(+)
                  AND wdtv.ZONE = sub.secondary_inventory_name
                  AND wdtv.organization_id = sub.organization_id
                  AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
                  AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                 (
                       SELECT NULL
                         FROM mtl_material_transactions_temp mmtt
                        WHERE mmtt.transaction_temp_id = wdtv.task_id
                          AND mmtt.parent_line_id IS NOT NULL
                          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                  AND NOT EXISTS -- exclude tasks already dispatched
                                 (SELECT NULL
                                    FROM wms_dispatched_tasks wdt1
                                   WHERE wdt1.transaction_temp_id = wdtv.task_id
                                     AND wdt1.task_type = wdtv.wms_task_type_id)
                  --******************
                  AND wdtv.task_id NOT IN -- excluded skipped tasks
                                          (
                       SELECT wdtv.task_id
                         FROM wms_skip_task_exceptions wste, mtl_parameters mp
                        WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                          AND wste.task_id = wdtv.task_id
                          AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                          AND wste.organization_id = mp.organization_id)
             --*****************
            --J Addition
                   AND  wdtv.ZONE not in  (
                        SELECT wd.subinventory_code
                        FROM  wms_devices_b wd
                            , wms_bus_event_devices wbed
                        WHERE 1 = 1
                            and wd.device_id = wbed.device_id
                           AND wbed.organization_id = wd.organization_id
                           AND wd.enabled_flag   = 'Y'
                           AND wbed.enabled_flag = 'Y'
                           AND wbed.business_event_id = 10
                           AND wd.subinventory_code IS NOT NULL
                           AND wd.force_sign_on_flag = 'Y'
                           AND wd.device_id NOT IN (SELECT device_id
                                       FROM wms_device_assignment_temp
                                      WHERE employee_id = p_sign_on_emp_id)
                     )
      ORDER BY        nvl(wdtv.task_priority, 0)
                    , -- removed order by segments for bug 2657909
                      mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , (
                         (loc.x_coordinate - l_cur_x) *(loc.x_coordinate - l_cur_x)
                       + (loc.y_coordinate - l_cur_y) *(loc.y_coordinate - l_cur_y)
                       + (loc.z_coordinate - l_cur_z) *(loc.z_coordinate - l_cur_z)
                      )
                    , wdtv.task_id;

    CURSOR l_curs_ordered_tasks_exp(v_pick_slip_number NUMBER, v_task_id NUMBER, v_task_type NUMBER) IS -- bug 2648133
      SELECT DISTINCT wdtv.task_id task_id
                    , -- added distinct for bug 2657909
                      NVL(wdtv.pick_slip_number, -1) pick_slip
                    , wdtv.wms_task_type_id
                    , nvl(wdtv.task_priority, 0)
                    , -- added following because of distinct for bug 2657909
                      mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , nvl(loc.x_coordinate, 0)
                    , nvl(loc.y_coordinate, 0)
                    , nvl(loc.z_coordinate, 0)
                 FROM (SELECT transaction_temp_id task_id
                            , standard_operation_id user_task_type_id
                            , wms_task_type wms_task_type_id
                            , organization_id organization_id
                            , subinventory_code ZONE
                            , locator_id locator_id
                            , task_priority task_priority
                            , revision revision
                            , lot_number lot_number
                            , transaction_uom transaction_uom
                            , transaction_quantity transaction_quantity
                            , pick_rule_id pick_rule_id
                            , pick_slip_number pick_slip_number
                            , cartonization_id cartonization_id
                            , inventory_item_id
                            , move_order_line_id
                         FROM mtl_material_transactions_temp
                        WHERE wms_task_type IS NOT NULL
                          AND transaction_status = 2
                          AND(wms_task_status IS NULL
                              OR wms_task_status = 1) --Added for task planning WB. bug#2651318
                       UNION ALL
                       SELECT   MIN(mcce.cycle_count_entry_id) task_id
                              , MIN(mcce.standard_operation_id) user_task_type_id
                              , 3 wms_task_type_id
                              , mcce.organization_id organization_id
                              , mcce.subinventory ZONE
                              , mcce.locator_id locator_id
                              , MIN(mcce.task_priority) task_priority
                              , mcce.revision revision
                              , MIN(mcce.lot_number) lot_number
                              , '' transaction_uom
                              , TO_NUMBER(NULL) transaction_quantity
                              , TO_NUMBER(NULL) pick_rule_id
                              , TO_NUMBER(NULL) pick_slip_number
                              , TO_NUMBER(NULL) cartonization_id
                              , mcce.inventory_item_id
                              , TO_NUMBER(NULL) move_order_line_id
                           FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
                          WHERE mcce.entry_status_code IN(1, 3)
                            AND NVL(mcce.export_flag, 2) = 2
                            -- bug 3972076
                            --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
                            AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
                            AND NVL(mcch.disable_date,sysdate+1)> sysdate
                       GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv
                    , -- inlined wms_dispatchable_tasks_v, bug 2648133
                      (SELECT utt_emp.standard_operation_id standard_operation_id
                            , utt_emp.resource_id ROLE
                            , utt_eqp.resource_id equipment
                            , utt_emp.person_id emp_id
                            , utt_eqp.inventory_item_id eqp_id
                            , NULL eqp_srl  /* removed for bug 2095237 */
                         FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                    , x_utt_res1.resource_id resource_id
                                    , x_emp_r.person_id
                                 FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                WHERE x_utt_res1.resource_id = r1.resource_id
                                  AND r1.resource_type = 2
                                  AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                            , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                    , x_utt_res2.resource_id resource_id
                                    , x_eqp_r.inventory_item_id inventory_item_id
                                 FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                WHERE x_utt_res2.resource_id = r2.resource_id
                                  AND r2.resource_type = 1
                                  AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                        WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                    , -- inlined wms_person_resource_utt_v, bug 2648133
                      mtl_item_locations loc
                    , mtl_secondary_inventories sub
                    , mtl_txn_request_lines mol
                --    mtl_system_items msi    -- bug 2648133
      WHERE           v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                  AND(wdtv.pick_slip_number = v_pick_slip_number
                      OR(wdtv.task_id = v_task_id
                         AND wdtv.wms_task_type_id = v_task_type))
                  AND wdtv.organization_id = p_sign_on_org_id
                  AND wdtv.wms_task_type_id = NVL(l_sys_task_type, wdtv.wms_task_type_id) -- restrict to picking tasks or all tasks
                  AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
                  AND NVL(wdtv.ZONE, '@@@') = NVL(p_sign_on_zone, NVL(wdtv.ZONE, '@@@'))
                  AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                  --    AND Nvl(v.eqp_srl, '@@@') = Nvl(l_sign_on_equipment_srl, Nvl(v.eqp_srl, '@@@'))   removed for bug 2095237
                  AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                  AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                  AND wdtv.locator_id = loc.inventory_location_id(+)
                  AND wdtv.ZONE = sub.secondary_inventory_name
                  AND wdtv.organization_id = sub.organization_id
                  AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
                  AND wms_express_pick_task.is_express_pick_task_eligible(wdtv.task_id) = 'S'
                  AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                 (
                       SELECT NULL
                         FROM mtl_material_transactions_temp mmtt
                        WHERE mmtt.transaction_temp_id = wdtv.task_id
                          AND mmtt.parent_line_id IS NOT NULL
                          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                  AND NOT EXISTS -- exclude tasks already dispatched
                                 (SELECT NULL
                                    FROM wms_dispatched_tasks wdt1
                                   WHERE wdt1.transaction_temp_id = wdtv.task_id
                                     AND wdt1.task_type = wdtv.wms_task_type_id)
                  --******************
                  AND wdtv.task_id NOT IN -- excluded skipped tasks
                                          (
                       SELECT wdtv.task_id
                         FROM wms_skip_task_exceptions wste, mtl_parameters mp
                        WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                          AND wste.task_id = wdtv.task_id
                          AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                          AND wste.organization_id = mp.organization_id)
             --*****************
            --J Addition
                               AND  wdtv.ZONE not in (
                                 SELECT wd.subinventory_code
                                 FROM  wms_devices_b wd
                                     , wms_bus_event_devices wbed
                                 WHERE 1 = 1
                                     and wd.device_id = wbed.device_id
                                    AND wbed.organization_id = wd.organization_id
                                    AND wd.enabled_flag   = 'Y'
                                    AND wbed.enabled_flag = 'Y'
                                    AND wbed.business_event_id = 10
                                    AND wd.subinventory_code IS NOT NULL
                                    AND wd.force_sign_on_flag = 'Y'
                                    AND wd.device_id NOT IN (SELECT device_id
                                                FROM wms_device_assignment_temp
                                               WHERE employee_id = p_sign_on_emp_id)
                              )
      ORDER BY        nvl(wdtv.task_priority, 0)
                    , -- removed order by segments for bug 2657909
                      mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , (
                         (loc.x_coordinate - l_cur_x) *(loc.x_coordinate - l_cur_x)
                       + (loc.y_coordinate - l_cur_y) *(loc.y_coordinate - l_cur_y)
                       + (loc.z_coordinate - l_cur_z) *(loc.z_coordinate - l_cur_z)
                      )
                    , wdtv.task_id;

    CURSOR l_curs_ordered_tasks_aw(v_pick_slip_number NUMBER, v_task_id NUMBER, v_task_type NUMBER) IS
      SELECT DISTINCT wdtv.task_id task_id
                    , -- added distinct for bug 2657909
                      NVL(wdtv.pick_slip_number, -1) pick_slip
                    , wdtv.wms_task_type_id
                    , nvl(wdtv.task_priority, 0)
                    , mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , nvl(loc.x_coordinate, 0)
                    , nvl(loc.y_coordinate, 0)
                    , nvl(loc.z_coordinate, 0)
                 FROM (SELECT transaction_temp_id task_id
                            , standard_operation_id user_task_type_id
                            , wms_task_type wms_task_type_id
                            , organization_id organization_id
                            , subinventory_code ZONE
                            , locator_id locator_id
                            , task_priority task_priority
                            , revision revision
                            , lot_number lot_number
                            , transaction_uom transaction_uom
                            , transaction_quantity transaction_quantity
                            , pick_rule_id pick_rule_id
                            , pick_slip_number pick_slip_number
                            , cartonization_id cartonization_id
                            , inventory_item_id
                            , move_order_line_id
                         FROM mtl_material_transactions_temp
                        WHERE wms_task_type IS NOT NULL
                          AND transaction_status = 2
                          AND(wms_task_status IS NULL
                              OR wms_task_status = 1) --Added for task planning WB. bug#2651318
                       UNION ALL
                       SELECT   MIN(mcce.cycle_count_entry_id) task_id
                              , MIN(mcce.standard_operation_id) user_task_type_id
                              , 3 wms_task_type_id
                              , mcce.organization_id organization_id
                              , mcce.subinventory ZONE
                              , mcce.locator_id locator_id
                              , MIN(mcce.task_priority) task_priority
                              , mcce.revision revision
                              , MIN(mcce.lot_number) lot_number
                              , '' transaction_uom
                              , TO_NUMBER(NULL) transaction_quantity
                              , TO_NUMBER(NULL) pick_rule_id
                              , TO_NUMBER(NULL) pick_slip_number
                              , TO_NUMBER(NULL) cartonization_id
                              , mcce.inventory_item_id
                              , TO_NUMBER(NULL) move_order_line_id
                           FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
                          WHERE mcce.entry_status_code IN(1, 3)
                            AND NVL(mcce.export_flag, 2) = 2
                            -- bug 3972076
                            --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
                       GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv
                    , -- inlined wms_dispatchable_tasks_v, bug 2648133
                      (SELECT utt_emp.standard_operation_id standard_operation_id
                            , utt_emp.resource_id ROLE
                            , utt_eqp.resource_id equipment
                            , utt_emp.person_id emp_id
                            , utt_eqp.inventory_item_id eqp_id
                            , NULL eqp_srl  /* removed for bug 2095237 */
                         FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                    , x_utt_res1.resource_id resource_id
                                    , x_emp_r.person_id
                                 FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                WHERE x_utt_res1.resource_id = r1.resource_id
                                  AND r1.resource_type = 2
                                  AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                            , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                    , x_utt_res2.resource_id resource_id
                                    , x_eqp_r.inventory_item_id inventory_item_id
                                 FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                WHERE x_utt_res2.resource_id = r2.resource_id
                                  AND r2.resource_type = 1
                                  AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                        WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                    , -- inlined wms_person_resource_utt_v, bug 2648133
                      mtl_item_locations loc
                    , mtl_secondary_inventories sub
                    , mtl_txn_request_lines mol
                WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                  AND(wdtv.pick_slip_number = v_pick_slip_number
                      OR(wdtv.task_id = v_task_id
                         AND wdtv.wms_task_type_id = v_task_type))
                  AND wdtv.organization_id = p_sign_on_org_id
                  AND wdtv.wms_task_type_id = NVL(l_sys_task_type, wdtv.wms_task_type_id) -- restrict to picking tasks or all tasks
                  AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
                  AND NVL(wdtv.ZONE, '@@@') = NVL(p_sign_on_zone, NVL(wdtv.ZONE, '@@@'))
                  AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                  AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                  AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                  AND wdtv.locator_id = loc.inventory_location_id(+)
                  AND wdtv.ZONE = sub.secondary_inventory_name
                  AND wdtv.organization_id = sub.organization_id
                  AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
                  AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                 (
                       SELECT NULL
                         FROM mtl_material_transactions_temp mmtt
                        WHERE mmtt.transaction_temp_id = wdtv.task_id
                          AND mmtt.parent_line_id IS NOT NULL
                          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                  AND NOT EXISTS -- exclude tasks already dispatched
                                 (SELECT NULL
                                    FROM wms_dispatched_tasks wdt1
                                   WHERE wdt1.transaction_temp_id = wdtv.task_id
                                     AND wdt1.task_type = wdtv.wms_task_type_id)
                  --******************
                  AND wdtv.task_id NOT IN -- excluded skipped tasks
                                          (
                       SELECT wdtv.task_id
                         FROM wms_skip_task_exceptions wste, mtl_parameters mp
                        WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                          AND wste.task_id = wdtv.task_id
                          AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                          AND wste.organization_id = mp.organization_id)
             --*****************
           --J Addition
                              AND  wdtv.ZONE not in (
                                 SELECT wd.subinventory_code
                                 FROM  wms_devices_b wd
                                     , wms_bus_event_devices wbed
                                 WHERE 1 = 1
                                     and wd.device_id = wbed.device_id
                                    AND wbed.organization_id = wd.organization_id
                                    AND wd.enabled_flag   = 'Y'
                                    AND wbed.enabled_flag = 'Y'
                                    AND wbed.business_event_id = 10
                                    AND wd.subinventory_code IS NOT NULL
                                    AND wd.force_sign_on_flag = 'Y'
                                    AND wd.device_id NOT IN (SELECT device_id
                                                FROM wms_device_assignment_temp
                                               WHERE employee_id = p_sign_on_emp_id)
                              )

      ORDER BY        nvl(wdtv.task_priority, 0)
                    , -- removed order by segments for bug 2657909
                      sub.picking_order
                    , loc.picking_order
                    , (
                         (loc.x_coordinate - l_cur_x) *(loc.x_coordinate - l_cur_x)
                       + (loc.y_coordinate - l_cur_y) *(loc.y_coordinate - l_cur_y)
                       + (loc.z_coordinate - l_cur_z) *(loc.z_coordinate - l_cur_z)
                      )
                    , wdtv.task_id;

    CURSOR l_curs_ordered_tasks_aw_exp(v_pick_slip_number NUMBER, v_task_id NUMBER, v_task_type NUMBER) IS
      SELECT DISTINCT wdtv.task_id task_id
                    , -- added distinct for bug 2657909
                      NVL(wdtv.pick_slip_number, -1) pick_slip
                    , wdtv.wms_task_type_id
                    , nvl(wdtv.task_priority, 0)
                    , mol.header_id
                    , sub.picking_order
                    , loc.picking_order
                    , nvl(loc.x_coordinate, 0)
                    , nvl(loc.y_coordinate, 0)
                    , nvl(loc.z_coordinate, 0)
                 FROM (SELECT transaction_temp_id task_id
                            , standard_operation_id user_task_type_id
                            , wms_task_type wms_task_type_id
                            , organization_id organization_id
                            , subinventory_code ZONE
                            , locator_id locator_id
                            , task_priority task_priority
                            , revision revision
                            , lot_number lot_number
                            , transaction_uom transaction_uom
                            , transaction_quantity transaction_quantity
                            , pick_rule_id pick_rule_id
                            , pick_slip_number pick_slip_number
                            , cartonization_id cartonization_id
                            , inventory_item_id
                            , move_order_line_id
                         FROM mtl_material_transactions_temp
                        WHERE wms_task_type IS NOT NULL
                          AND transaction_status = 2
                          AND(wms_task_status IS NULL
                              OR wms_task_status = 1) --Added for task planning WB. bug#2651318
                       UNION ALL
                       SELECT   MIN(mcce.cycle_count_entry_id) task_id
                              , MIN(mcce.standard_operation_id) user_task_type_id
                              , 3 wms_task_type_id
                              , mcce.organization_id organization_id
                              , mcce.subinventory ZONE
                              , mcce.locator_id locator_id
                              , MIN(mcce.task_priority) task_priority
                              , mcce.revision revision
                              , MIN(mcce.lot_number) lot_number
                              , '' transaction_uom
                              , TO_NUMBER(NULL) transaction_quantity
                              , TO_NUMBER(NULL) pick_rule_id
                              , TO_NUMBER(NULL) pick_slip_number
                              , TO_NUMBER(NULL) cartonization_id
                              , mcce.inventory_item_id
                              , TO_NUMBER(NULL) move_order_line_id
                           FROM mtl_cycle_count_entries mcce, mtl_cycle_count_headers mcch
                          WHERE mcce.entry_status_code IN(1, 3)
                            AND NVL(mcce.export_flag, 2) = 2
                            -- bug 3972076
                            --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
                            AND mcce.cycle_count_header_id = mcch.cycle_count_header_id
                            AND NVL(mcch.disable_date,sysdate+1)> sysdate
                       GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id, mcce.revision) wdtv
                    , -- inlined wms_dispatchable_tasks_v, bug 2648133
                      (SELECT utt_emp.standard_operation_id standard_operation_id
                            , utt_emp.resource_id ROLE
                            , utt_eqp.resource_id equipment
                            , utt_emp.person_id emp_id
                            , utt_eqp.inventory_item_id eqp_id
                            , NULL eqp_srl  /* removed for bug 2095237 */
                         FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                    , x_utt_res1.resource_id resource_id
                                    , x_emp_r.person_id
                                 FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                WHERE x_utt_res1.resource_id = r1.resource_id
                                  AND r1.resource_type = 2
                                  AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                            , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                    , x_utt_res2.resource_id resource_id
                                    , x_eqp_r.inventory_item_id inventory_item_id
                                 FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                WHERE x_utt_res2.resource_id = r2.resource_id
                                  AND r2.resource_type = 1
                                  AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                        WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                    , -- inlined wms_person_resource_utt_v, bug 2648133
                      mtl_item_locations loc
                    , mtl_secondary_inventories sub
                    , mtl_txn_request_lines mol
                WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                  AND(wdtv.pick_slip_number = v_pick_slip_number
                      OR(wdtv.task_id = v_task_id
                         AND wdtv.wms_task_type_id = v_task_type))
                  AND wdtv.organization_id = p_sign_on_org_id
                  AND wdtv.wms_task_type_id = NVL(l_sys_task_type, wdtv.wms_task_type_id) -- restrict to picking tasks or all tasks
                  AND wdtv.user_task_type_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
                  AND NVL(wdtv.ZONE, '@@@') = NVL(p_sign_on_zone, NVL(wdtv.ZONE, '@@@')) -- bug 2648133
                  AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                  AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                  AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                  AND wdtv.locator_id = loc.inventory_location_id(+)
                  AND wdtv.ZONE = sub.secondary_inventory_name
                  AND wdtv.organization_id = sub.organization_id
                  AND wdtv.move_order_line_id = mol.line_id(+) -- join task to MOL, outer join for tasks do not have MOL
                  AND wms_express_pick_task.is_express_pick_task_eligible(wdtv.task_id) = 'S'
                  AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                 (
                       SELECT NULL
                         FROM mtl_material_transactions_temp mmtt
                        WHERE mmtt.transaction_temp_id = wdtv.task_id
                          AND mmtt.parent_line_id IS NOT NULL
                          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                  AND NOT EXISTS -- exclude tasks already dispatched
                                 (SELECT NULL
                                    FROM wms_dispatched_tasks wdt1
                                   WHERE wdt1.transaction_temp_id = wdtv.task_id
                                     AND wdt1.task_type = wdtv.wms_task_type_id)
                  --******************
                  AND wdtv.task_id NOT IN -- excluded skipped tasks
                                          (
                       SELECT wdtv.task_id
                         FROM wms_skip_task_exceptions wste, mtl_parameters mp
                        WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                          AND wste.task_id = wdtv.task_id
                          AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                          AND wste.organization_id = mp.organization_id)
             --*****************
                        --J Addition
                            AND  wdtv.ZONE not in  (
                              SELECT wd.subinventory_code
                              FROM  wms_devices_b wd
                                  , wms_bus_event_devices wbed
                              WHERE 1 = 1
                                  and wd.device_id = wbed.device_id
                                 AND wbed.organization_id = wd.organization_id
                                 AND wd.enabled_flag   = 'Y'
                                 AND wbed.enabled_flag = 'Y'
                                 AND wbed.business_event_id = 10
                                 AND wd.subinventory_code IS NOT NULL
                                 AND wd.force_sign_on_flag = 'Y'
                                 AND wd.device_id NOT IN (SELECT device_id
                                             FROM wms_device_assignment_temp
                                            WHERE employee_id = p_sign_on_emp_id)
                           )
      ORDER BY        nvl(wdtv.task_priority, 0)
                    , -- removed order by segments for bug 2657909
                      sub.picking_order
                    , loc.picking_order
                    , (
                         (loc.x_coordinate - l_cur_x) *(loc.x_coordinate - l_cur_x)
                       + (loc.y_coordinate - l_cur_y) *(loc.y_coordinate - l_cur_y)
                       + (loc.z_coordinate - l_cur_z) *(loc.z_coordinate - l_cur_z)
                      )
          , wdtv.task_id;


   CURSOR c_lock_check(v_pick_slip_number NUMBER) IS

      SELECT transaction_temp_id
   FROM mtl_material_transactions_temp mmtt
   WHERE mmtt.pick_slip_number = v_pick_slip_number
   FOR UPDATE nowait;


    l_debug                       NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Enter dispatch_task ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress       := '10';

    -- This API is query only, therefore does not create a save point

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;
    -- API body
    -- preprocess input parameters

    fnd_profile.get('WMS_SEQUENCE_PICKS_ACROSS_WAVES', l_sequence_picks_across_waves);

    IF l_sequence_picks_across_waves IS NULL THEN
      l_sequence_picks_across_waves  := 2;
    END IF;

    IF p_sign_on_equipment_srl = 'NONE' THEN
      l_sign_on_equipment_srl  := NULL;
      l_sign_on_equipment_id   := -999;
    ELSE
      l_sign_on_equipment_srl  := p_sign_on_equipment_srl;
      l_sign_on_equipment_id   := p_sign_on_equipment_id;
    END IF;

    -- use l_equipment_id_str to concatenate sql statement
    IF l_sign_on_equipment_id IS NULL THEN
      l_equipment_id_str  := 'NULL';
    ELSE
      l_equipment_id_str  := TO_CHAR(l_sign_on_equipment_id);
    END IF;

    IF p_task_type = 'PICKING' THEN
      l_sys_task_type  := 1;
    ELSIF p_task_type = 'EXPPICK' THEN
      l_sys_task_type    := 1;
      l_is_express_pick  := 1;

      IF (l_debug = 1) THEN
        print_debug('Express Pick Task', 4);
      END IF;
    ELSE
      l_sys_task_type  := NULL;
    END IF;

    -- check if this call is for picking tasks or for all tasks
    IF p_task_type = 'DISPLAY' THEN
      IF (l_debug = 1) THEN
        print_debug('dispatch_task - DISPLAY ', 4);
      END IF;

      l_progress  := '20';
    /*
    l_sql_stmt :=
'SELECT wdtv.task_id, wdtv.zone, wdtv.locator_id,
wdtv.revision, wdtv.transaction_uom,
wdtv.transaction_quantity, wdtv.lot_number, wdtv.wms_task_type_id,wdtv.task_priority
FROM  wms_dispatchable_tasks_v wdtv
WHERE
wdtv.organization_id = ' || p_sign_on_org_id ||'
AND Nvl(wdtv.zone, ''@@@'') = Nvl('''|| p_sign_on_zone || ''', Nvl(wdtv.zone, ''@@@''))
AND wdtv.user_task_type_id IN
(
 SELECT standard_operation_id
 FROM wms_person_resource_utt_v v
 WHERE v.emp_id = ' || p_sign_on_emp_id  ||'
 AND Nvl(v.eqp_srl, ''@@@'') = Nvl(''' || l_sign_on_equipment_srl || ''', Nvl(v.eqp_srl, ''@@@''))
 AND Nvl(v.eqp_id, -999) = Nvl(' || l_equipment_id_str ||', Nvl(v.eqp_id, -999))
 )
--***********
AND wdtv.task_id NOT IN
(SELECT wdtv.task_id FROM wms_skip_task_exceptions wste, mtl_parameters mp
 WHERE ((SYSDATE - wste.creation_date)*24*60) < mp.skip_task_waiting_minutes
 AND wste.task_id = wdtv.task_id
 AND wste.organization_id = mp.organization_id )
--************
AND wdtv.task_id NOT IN
(SELECT wdt1.transaction_temp_id
 FROM wms_dispatched_tasks wdt1
 --   WHERE wdt1.status = 1
 UNION ALL
 SELECT wdt2.transaction_temp_id
 FROM wms_exceptions wms_except, wms_dispatched_tasks wdt2
 WHERE wms_except.person_id = ' || p_sign_on_emp_id || '
 AND wdt2.task_id = wms_except.task_id
 AND discrepancy_type = 1
 )
ORDER BY wdtv.pick_slip_number, wdtv.task_priority, wdtv.task_id';
    */
    ELSIF(p_task_type = 'ALL'
          OR p_task_type = 'EXPPICK') THEN -- the call is for ALL taks
      IF (l_debug = 1) THEN
        print_debug('dispatch_task -' || p_task_type, 4);
      END IF;

      l_progress                     := '30';

      -- select last task this operator was working on
      BEGIN
        SELECT transaction_temp_id
             , task_type
             , loaded_time
          INTO l_last_loaded_task_id
             , l_last_loaded_task_type
             , l_last_loaded_time
          FROM (SELECT transaction_temp_id
                     , task_type
                     , loaded_time
                  FROM wms_dispatched_tasks wdt
                 WHERE wdt.person_id = p_sign_on_emp_id
                   AND wdt.loaded_time = (SELECT MAX(loaded_time)
                                            FROM wms_dispatched_tasks
                                           WHERE person_id = p_sign_on_emp_id))
         WHERE ROWNUM = 1 -- make sure only one task selected
                          ;

        l_progress  := '31';
      EXCEPTION
        WHEN OTHERS THEN
          l_last_loaded_task_id  := -1;
      END;

      IF (l_debug = 1) THEN
        print_debug('dispatch_task - last loaded task : l_last_loaded_task_id => ' || l_last_loaded_task_id, 4);
        print_debug('dispatch_task  => l_last_loaded_task_type' || l_last_loaded_task_type, 4);
        print_debug('dispatch_task  => l_last_loaded_time' || l_last_loaded_time, 4);
      END IF;

      -- select last task this operator completed
      BEGIN
        l_progress  := '32';

        SELECT transaction_id
             , task_type
             , loaded_time
          INTO l_last_dropoff_task_id
             , l_last_dropoff_task_type
             , l_last_dropoff_time
          FROM (SELECT transaction_id
                     , task_type
                     , loaded_time
                  FROM wms_dispatched_tasks_history wdth
                 WHERE wdth.person_id = p_sign_on_emp_id
                   AND wdth.drop_off_time = (SELECT MAX(drop_off_time)
                                               FROM wms_dispatched_tasks_history
                                              WHERE person_id = p_sign_on_emp_id))
         WHERE ROWNUM = 1 -- make sure only one task selected
                          ;

        l_progress  := '33';
      EXCEPTION
        WHEN OTHERS THEN
          l_last_dropoff_task_id  := -1;
      END;

      IF (l_debug = 1) THEN
        print_debug('dispatch_task - last dropoff task : l_last_dropoff_task_id => ' || l_last_dropoff_task_id, 4);
        print_debug('dispatch_task  => l_last_dropoff_task_type' || l_last_dropoff_task_type, 4);
        print_debug('dispatch_task  => l_last_dropoff_time' || l_last_dropoff_time, 4);
      END IF;

      IF l_last_dropoff_task_id = -1
         AND l_last_loaded_task_id = -1 THEN
        l_last_task_id  := -1;
      ELSIF l_last_dropoff_task_id = -1 THEN
        l_last_task_id       := l_last_loaded_task_id;
        l_last_task_type     := l_last_loaded_task_type;
        l_last_task_is_drop  := FALSE;
      ELSIF l_last_loaded_task_id = -1 THEN
        l_last_task_id       := l_last_dropoff_task_id;
        l_last_task_type     := l_last_dropoff_task_type;
        l_last_task_is_drop  := TRUE;
      ELSIF l_last_loaded_time < l_last_dropoff_time THEN
        l_last_task_id       := l_last_dropoff_task_id;
        l_last_task_type     := l_last_dropoff_task_type;
        l_last_task_is_drop  := TRUE;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('dispatch_task - previous task - l_last_task_id = ' || l_last_task_id, 4);
      END IF;

      -- select locator coordinates of the the last task
      IF l_last_task_id <> -1 -- make sure there is a last task
                              THEN
        IF l_last_task_is_drop <> TRUE THEN                                   -- task that has not been completed
                                            -- get the location from wms_dispatchable_tasks_v
          BEGIN
            l_progress  := '35';

            -- use Nvl to make sure if coordinates not defined, use 0
            SELECT NVL(loc.x_coordinate, 0)
                 , NVL(loc.y_coordinate, 0)
                 , NVL(loc.z_coordinate, 0)
              INTO l_cur_x
                 , l_cur_y
                 , l_cur_z
              FROM mtl_item_locations loc
                 , (SELECT transaction_temp_id task_id
                         , standard_operation_id user_task_type_id
                         , wms_task_type wms_task_type_id
                         , organization_id organization_id
                         , subinventory_code ZONE
                         , locator_id locator_id
                         , task_priority task_priority
                         , revision revision
                         , lot_number lot_number
                         , transaction_uom transaction_uom
                         , transaction_quantity transaction_quantity
                         , pick_rule_id pick_rule_id
                         , pick_slip_number pick_slip_number
                         , cartonization_id cartonization_id
                         , inventory_item_id
                         , move_order_line_id
                      FROM mtl_material_transactions_temp
                     WHERE wms_task_type IS NOT NULL
                       AND transaction_status = 2
                    UNION ALL
                    SELECT   MIN(cycle_count_entry_id) task_id
                           , MIN(standard_operation_id) user_task_type_id
                           , 3 wms_task_type_id
                           , organization_id organization_id
                           , subinventory ZONE
                           , locator_id locator_id
                           , MIN(task_priority) task_priority
                           , revision revision
                           , MIN(lot_number) lot_number
                           , '' transaction_uom
                           , TO_NUMBER(NULL) transaction_quantity
                           , TO_NUMBER(NULL) pick_rule_id
                           , TO_NUMBER(NULL) pick_slip_number
                           , TO_NUMBER(NULL) cartonization_id
                           , inventory_item_id
                           , TO_NUMBER(NULL) move_order_line_id
                        FROM mtl_cycle_count_entries
                       WHERE  entry_status_code IN(1, 3)
                         AND  NVL(export_flag, 2) = 2
                         -- bug 3972076
                         --AND  NVL(TRUNC(count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
                    GROUP BY  cycle_count_header_id, organization_id, subinventory, locator_id, inventory_item_id, revision) wdtv -- inlined wms_dispatchable_tasks_v, bug 2648133
             WHERE wdtv.locator_id = loc.inventory_location_id
               AND wdtv.organization_id = loc.organization_id
               AND wdtv.task_id = l_last_task_id
               AND wdtv.wms_task_type_id = l_last_task_type;

            -- Added the previous line since the task_id in the view
            -- might not be unique since it is the transaction_temp_id
            -- if it comes from MMTT but the cycle_count_entry_id if
            -- it comes from MTL_CYCLE_COUNT_ENTRIES for cycle counting tasks
            l_progress  := '36';
          EXCEPTION
            WHEN OTHERS THEN
              -- locator definition descripency
              l_cur_x  := 0;
              l_cur_y  := 0;
              l_cur_z  := 0;
          END;
        ELSE -- l_last_task_is_drop <> TRUE  (completed tasks)
          IF l_last_task_type <> 3 THEN                                -- not cycle count task
                                        -- get the location from mtl_material_transactions
            BEGIN
              l_progress  := '37';

              -- use Nvl to make sure if coordinates not defined, use 0
              SELECT NVL(loc.x_coordinate, 0)
                   , NVL(loc.y_coordinate, 0)
                   , NVL(loc.z_coordinate, 0)
                INTO l_cur_x
                   , l_cur_y
                   , l_cur_z
                FROM mtl_item_locations loc, mtl_material_transactions mmt
               WHERE mmt.locator_id = loc.inventory_location_id
                 AND mmt.organization_id = loc.organization_id
                 AND mmt.transaction_set_id = l_last_task_id
                 AND ROWNUM = 1;

              l_progress  := '38';
            EXCEPTION
              WHEN OTHERS THEN
                -- locator definition descripency
                l_cur_x  := 0;
                l_cur_y  := 0;
                l_cur_z  := 0;
            END;
          ELSE     -- l_last_task_type <> 3  (Cyclt Count task)
               -- get the location from mtl_cycle_count_entries
            BEGIN
              l_progress  := '39';

              -- use Nvl to make sure if coordinates not defined, use 0
              SELECT NVL(loc.x_coordinate, 0)
                   , NVL(loc.y_coordinate, 0)
                   , NVL(loc.z_coordinate, 0)
                INTO l_cur_x
                   , l_cur_y
                   , l_cur_z
                FROM mtl_item_locations loc, mtl_cycle_count_entries mcce
               WHERE mcce.locator_id = loc.inventory_location_id
                 AND mcce.organization_id = loc.organization_id
                 AND mcce.cycle_count_entry_id = l_last_task_id;

              l_progress  := '40';
            EXCEPTION
              WHEN OTHERS THEN                -- adf
                               -- locator definition descripency
                l_cur_x  := 0;
                l_cur_y  := 0;
                l_cur_z  := 0;
            END;
          END IF; -- l_last_task_type <> 3
        END IF; -- l_last_task_is_drop <> TRUE
      ELSE -- there is not a previous task at all
        l_cur_x  := 0;
        l_cur_y  := 0;
        l_cur_z  := 0;
      END IF; -- l_last_task_id <> -1

      l_progress                     := '45';

      -- Select the most optimal task
      -- first select eligible tasks according to employee sign on information
      -- order tasks by task priority, locator picking order and locator coordinates
      -- approximated to current locator

      IF (l_debug = 1) THEN
        print_debug('p_sign_on_emp_id => ' || p_sign_on_emp_id, 4);
        print_debug('p_sign_on_zone => ' || p_sign_on_zone, 4);
        print_debug('p_cartonization_id => ' || p_cartonization_id, 4);
        print_debug('l_sign_on_equipment_srl => ' || l_sign_on_equipment_srl, 4);
        print_debug('l_sign_on_equipment_id => ' || l_sign_on_equipment_id, 4);
        print_debug('l_cur_x => ' || l_cur_x, 4);
        print_debug('l_cur_y => ' || l_cur_y, 4);
        print_debug('l_cur_z => ' || l_cur_z, 4);
      END IF;

      -- open and fetch appropriate cursor

      -- start bug 2832818
      LOOP -- added loop for detecting lock for a pick slip
    l_is_locked := FALSE;
    -- end bug 2832818

    IF l_sequence_picks_across_waves = 2 THEN -- order across wave
       IF p_sign_on_zone IS NOT NULL THEN -- zone passed in
          IF l_is_express_pick <> 1 THEN -- not express pick
        IF (l_debug = 1) THEN
           print_debug('Opt task cursor:  zone passed, order across wave, not express pick (110) ', 4);
        END IF;

        OPEN l_curs_opt_task_110;
        FETCH l_curs_opt_task_110 INTO l_opt_task_id
          , l_opt_task_pick_slip
          , l_opt_task_type
          , l_task_priority
          , l_mo_header_id
          , l_sub_pick_order
          , l_loc_pick_order
          , l_x_coordinate
          , l_y_coordinate
          , l_z_coordinate;
        CLOSE l_curs_opt_task_110;
      ELSE -- express pick
        IF (l_debug = 1) THEN
           print_debug('Opt task cursor:  zone passed, order across wave, express pick (111)', 4);
        END IF;

        OPEN l_curs_opt_task_111;
        FETCH l_curs_opt_task_111 INTO l_opt_task_id
          , l_opt_task_pick_slip
          , l_opt_task_type
          , l_task_priority
          , l_mo_header_id
          , l_sub_pick_order
          , l_loc_pick_order
          , l_x_coordinate
          , l_y_coordinate
          , l_z_coordinate;
        CLOSE l_curs_opt_task_111;
          END IF;
        ELSE -- zone NOT passed in
          IF l_is_express_pick <> 1 THEN -- not express pick
        IF (l_debug = 1) THEN
           print_debug('Opt task cursor: zone NOT passed, order across wave, NOT express pick (010) ', 4);
        END IF;

        OPEN l_curs_opt_task_010;
        FETCH l_curs_opt_task_010 INTO l_opt_task_id
          , l_opt_task_pick_slip
          , l_opt_task_type
          , l_task_priority
          , l_mo_header_id
          , l_sub_pick_order
          , l_loc_pick_order
          , l_x_coordinate
          , l_y_coordinate
          , l_z_coordinate;
        CLOSE l_curs_opt_task_010;
      ELSE -- express pick
        IF (l_debug = 1) THEN
           print_debug('Opt task cursor: zone NOT passed, order across wave, express pick (011) ', 4);
        END IF;

        OPEN l_curs_opt_task_011;
        FETCH l_curs_opt_task_011 INTO l_opt_task_id
          , l_opt_task_pick_slip
          , l_opt_task_type
          , l_task_priority
          , l_mo_header_id
          , l_sub_pick_order
          , l_loc_pick_order
          , l_x_coordinate
          , l_y_coordinate
          , l_z_coordinate;
        CLOSE l_curs_opt_task_011;
          END IF;
       END IF;
     ELSE -- NOT order across wave
       IF p_sign_on_zone IS NOT NULL THEN -- zone passed in
          IF l_is_express_pick <> 1 THEN -- not express pick
        IF (l_debug = 1) THEN
           print_debug('Opt task cursor: zone passed, NOT order across wave, NOT express pick (100) ', 4);
        END IF;

        OPEN l_curs_opt_task_100;
        FETCH l_curs_opt_task_100 INTO l_opt_task_id
          , l_opt_task_pick_slip
          , l_opt_task_type
          , l_task_priority
          , l_mo_header_id
          , l_sub_pick_order
          , l_loc_pick_order
          , l_x_coordinate
          , l_y_coordinate
          , l_z_coordinate;
        CLOSE l_curs_opt_task_100;
      ELSE -- express pick
        IF (l_debug = 1) THEN
           print_debug('Opt task cursor: zone passed, NOT order across wave, express pick (101) ', 4);
        END IF;

        OPEN l_curs_opt_task_101;
        FETCH l_curs_opt_task_101 INTO l_opt_task_id
          , l_opt_task_pick_slip
          , l_opt_task_type
          , l_task_priority
          , l_mo_header_id
          , l_sub_pick_order
          , l_loc_pick_order
          , l_x_coordinate
          , l_y_coordinate
          , l_z_coordinate;
        CLOSE l_curs_opt_task_101;
          END IF;
        ELSE -- zone NOT passed in
          IF l_is_express_pick <> 1 THEN -- not express pick
        IF (l_debug = 1) THEN
           print_debug('Opt task cursor: zone NOT passed, NOT order across wave, NOT express pick (000) ', 4);
        END IF;

        OPEN l_curs_opt_task_000;
        FETCH l_curs_opt_task_000 INTO l_opt_task_id
          , l_opt_task_pick_slip
          , l_opt_task_type
          , l_task_priority
          , l_mo_header_id
          , l_sub_pick_order
          , l_loc_pick_order
          , l_x_coordinate
          , l_y_coordinate
          , l_z_coordinate;
        CLOSE l_curs_opt_task_000;
      ELSE -- express pick
        IF (l_debug = 1) THEN
           print_debug('Opt task cursor: zone NOT passed, NOT order across wave, express pick (001) ', 4);
        END IF;

        OPEN l_curs_opt_task_001;
        FETCH l_curs_opt_task_001 INTO l_opt_task_id
          , l_opt_task_pick_slip
          , l_opt_task_type
          , l_task_priority
          , l_mo_header_id
          , l_sub_pick_order
          , l_loc_pick_order
          , l_x_coordinate
          , l_y_coordinate
          , l_z_coordinate;
        CLOSE l_curs_opt_task_001;
          END IF;
       END IF;
    END IF;

          -- start bug fix 2832818
    IF l_opt_task_pick_slip IS NOT NULL THEN

       IF l_debug = 1 THEN
          print_debug('Check pick_slip_number'|| l_opt_task_pick_slip || ' for locking.', 4);
       END IF;

            BEGIN
          OPEN c_lock_check(l_opt_task_pick_slip);
          CLOSE c_lock_check;
       EXCEPTION
          WHEN OTHERS  THEN
        IF SQLCODE = -54 THEN  -- resource busy and acquire with NOWAIT specified
           l_is_locked := TRUE;

           IF l_debug  = 1 THEN
         print_debug('pick_slip_number ' || l_opt_task_pick_slip ||' is locked by other user. ', 4);
           END IF;

         ELSE
           l_is_locked := FALSE;

        END IF;

        IF c_lock_check%isopen THEN
           CLOSE c_lock_check;
        END IF;
       END;
    END IF;

    IF l_is_locked = TRUE THEN
       print_debug('Continue looking for most optimal task since there is a lock for this pick slip.', 4);

     ELSE
       print_debug('There is no lock, got the most optimal task.', 4);

       EXIT;
    END IF;


      END LOOP;

       -- End bug fix 2832818

      IF l_opt_task_id IS NULL THEN
        fnd_message.set_name('WMS', 'WMS_TASK_NO_ELIGIBLE_TASKS');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('dispatch_task - No eligible picking tasks ', 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_sequence_picks_across_waves = 2 THEN
        IF l_is_express_pick <> 1 THEN
          OPEN l_curs_ordered_tasks(l_opt_task_pick_slip, l_opt_task_id, l_opt_task_type);
        ELSE
          OPEN l_curs_ordered_tasks_exp(l_opt_task_pick_slip, l_opt_task_id, l_opt_task_type);
        END IF;
      ELSE
        IF l_is_express_pick <> 1 THEN
          OPEN l_curs_ordered_tasks_aw(l_opt_task_pick_slip, l_opt_task_id, l_opt_task_type);
        ELSE
          OPEN l_curs_ordered_tasks_aw_exp(l_opt_task_pick_slip, l_opt_task_id, l_opt_task_type);
        END IF;
      END IF;

      l_progress                     := '50';
      l_first_task_pick_slip_number  := -1;
      l_ordered_tasks_count          := 0;

      LOOP
        IF (l_debug = 1) THEN
          print_debug('Start looping through ordered tasks: ', 4);
        END IF;

        l_opt_task_id         := NULL;
        l_opt_task_pick_slip  := NULL;
        --   l_opt_task_type := NULL;
        l_is_locked           := FALSE;
        l_progress            := '60';

        IF l_sequence_picks_across_waves = 2 THEN
          IF l_is_express_pick <> 1 THEN
            FETCH l_curs_ordered_tasks INTO l_opt_task_id
           , l_opt_task_pick_slip
           , l_opt_task_type
           , l_task_priority
           , l_mo_header_id
           , l_sub_pick_order
           , l_loc_pick_order
           , l_x_coordinate
           , l_y_coordinate
           , l_z_coordinate;
            EXIT WHEN l_curs_ordered_tasks%NOTFOUND;
          ELSE
            FETCH l_curs_ordered_tasks_exp INTO l_opt_task_id
           , l_opt_task_pick_slip
           , l_opt_task_type
           , l_task_priority
           , l_mo_header_id
           , l_sub_pick_order
           , l_loc_pick_order
           , l_x_coordinate
           , l_y_coordinate
           , l_z_coordinate;
            EXIT WHEN l_curs_ordered_tasks_exp%NOTFOUND;
          END IF;
        ELSE
          IF l_is_express_pick <> 1 THEN -- bug 2648133
            FETCH l_curs_ordered_tasks_aw INTO l_opt_task_id
           , l_opt_task_pick_slip
           , l_opt_task_type
           , l_task_priority
           , l_mo_header_id
           , l_sub_pick_order
           , l_loc_pick_order
           , l_x_coordinate
           , l_y_coordinate
           , l_z_coordinate;
            EXIT WHEN l_curs_ordered_tasks_aw%NOTFOUND;
          ELSE
            FETCH l_curs_ordered_tasks_aw_exp INTO l_opt_task_id
           , l_opt_task_pick_slip
           , l_opt_task_type
           , l_task_priority
           , l_mo_header_id
           , l_sub_pick_order
           , l_loc_pick_order
           , l_x_coordinate
           , l_y_coordinate
           , l_z_coordinate;
            EXIT WHEN l_curs_ordered_tasks_aw_exp%NOTFOUND;
          END IF;
        END IF;

        l_progress            := '70';

        IF (l_debug = 1) THEN
          print_debug('l_opt_task_id => ' || l_opt_task_id, 4);
          print_debug('l_opt_task_pick_slip => ' || l_opt_task_pick_slip, 4);
          print_debug('l_opt_task_type => ' || l_opt_task_type, 4);
        END IF;

        -- bug 2648133
        /*
        IF l_is_express_pick = 1 THEN

           IF wms_express_pick_task.is_express_pick_task_eligible(l_opt_task_id) <> 'S' THEN
              EXIT;
           END IF;

        END IF;
        */
        IF l_ordered_tasks_count = 0 THEN -- first task

                                          -- Test if this task is locked by any other user
          IF (l_opt_task_type <> 3) THEN
            -- Picking, Putaway, or Replenishment tasks
        IF l_opt_task_pick_slip IS NULL THEN  -- bug 2832818
                BEGIN
         SELECT     mmtt.transaction_temp_id
           INTO l_opt_task_id
           FROM mtl_material_transactions_temp mmtt
           WHERE mmtt.transaction_temp_id = l_opt_task_id
           FOR UPDATE NOWAIT;
      EXCEPTION
         WHEN OTHERS THEN
            IF (l_debug = 1) THEN
          print_debug('This task is locked by other user. ', 4);
            END IF;

            l_is_locked  := TRUE;
      END;

          END IF;  -- bug 2832818

          ELSE
            -- Cycle counting tasks
            BEGIN
              SELECT     mcce.cycle_count_entry_id
                    INTO l_opt_task_id
                    FROM mtl_cycle_count_entries mcce
                   WHERE mcce.cycle_count_entry_id = l_opt_task_id
              FOR UPDATE NOWAIT;
            EXCEPTION
              WHEN OTHERS THEN
                IF (l_debug = 1) THEN
                  print_debug('This task is locked by other user. ', 4);
                END IF;

                l_is_locked  := TRUE;
            END;
          END IF;

          IF l_is_locked <> TRUE THEN
            l_ordered_tasks_count          := l_ordered_tasks_count + 1;
            l_first_task_pick_slip_number  := l_opt_task_pick_slip;

            IF (l_debug = 1) THEN
              print_debug('This is the first task in this group. l_ordered_tasks_count => ' || l_ordered_tasks_count, 4);
            END IF;

            l_progress                     := '72';

            INSERT INTO wms_ordered_tasks
                        (
                         task_id
                       , wms_task_type
                       , task_sequence_id
                        )
                 VALUES (
                         l_opt_task_id
                       , l_opt_task_type
                       , l_ordered_tasks_count
                        );

            l_progress                     := '73';
          END IF;
        ELSIF l_first_task_pick_slip_number = l_opt_task_pick_slip
              AND l_first_task_pick_slip_number <> -1
              AND l_opt_task_pick_slip <> -1 THEN                                     -- task with the same pick slip number
                                                  -- Test if this task is locked by any other user
          IF (l_opt_task_type <> 3) THEN
            -- Picking, Putaway, or Replenishment tasks
        IF l_opt_task_pick_slip IS NULL THEN  -- bug 2832818
                BEGIN
         SELECT     mmtt.transaction_temp_id
           INTO l_opt_task_id
           FROM mtl_material_transactions_temp mmtt
           WHERE mmtt.transaction_temp_id = l_opt_task_id
           FOR UPDATE NOWAIT;
      EXCEPTION
         WHEN OTHERS THEN
            IF (l_debug = 1) THEN
          print_debug('This task is locked by other user. ', 4);
            END IF;

            l_is_locked  := TRUE;
      END;
        END IF; -- bug 2832818

      ELSE
            -- Cycle counting tasks
            BEGIN
              SELECT     mcce.cycle_count_entry_id
                    INTO l_opt_task_id
                    FROM mtl_cycle_count_entries mcce
                   WHERE mcce.cycle_count_entry_id = l_opt_task_id
              FOR UPDATE NOWAIT;
            EXCEPTION
              WHEN OTHERS THEN
                IF (l_debug = 1) THEN
                  print_debug('This task is locked by other user. ', 4);
                END IF;

                l_is_locked  := TRUE;
            END;
          END IF;

          IF l_is_locked <> TRUE THEN
            l_ordered_tasks_count  := l_ordered_tasks_count + 1;

            IF (l_debug = 1) THEN
              print_debug('This task has the same pick slip number. l_ordered_tasks_count => ' || l_ordered_tasks_count, 4);
            END IF;

            l_progress             := '74';

            INSERT INTO wms_ordered_tasks
                        (
                         task_id
                       , wms_task_type
                       , task_sequence_id
                        )
                 VALUES (
                         l_opt_task_id
                       , l_opt_task_type
                       , l_ordered_tasks_count
                        );

            l_progress             := '75';
          END IF;
        END IF;
      END LOOP;

      IF l_sequence_picks_across_waves = 2 THEN
        IF l_curs_ordered_tasks%ISOPEN THEN
          CLOSE l_curs_ordered_tasks;
        END IF;

        IF l_curs_ordered_tasks_exp%ISOPEN THEN -- bug 2648133
          CLOSE l_curs_ordered_tasks_exp;
        END IF;
      ELSE
        IF l_curs_ordered_tasks_aw%ISOPEN THEN
          CLOSE l_curs_ordered_tasks_aw;
        END IF;

        IF l_curs_ordered_tasks_aw_exp%ISOPEN THEN
          CLOSE l_curs_ordered_tasks_aw_exp;
        END IF;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('Total task dispatched: l_ordered_tasks_count => ' || l_ordered_tasks_count, 4);
      END IF;

      IF l_ordered_tasks_count = 0 THEN
        fnd_message.set_name('WMS', 'WMS_TASK_NO_ELIGIBLE_TASKS');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('dispatch_task - No eligible picking tasks ', 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      l_progress                     := '90';
      -- bug 2648133, inlined wms_dispatchable_tasks_v
      -- removed l_sql_stmt

      l_progress                     := '100';
    END IF; -- end task type check if


            -- open reference cursor for this statement

    IF (l_debug = 1) THEN
      print_debug('dispatch_task 120 - before opeing ref cursor ', 4);
    END IF;

    l_progress       := '110';

    -- bug 2648133, changed to static SQL and query against base tables

    IF l_opt_task_type <> 3 THEN -- non cycle counting tasks
      OPEN x_task_cur FOR
        SELECT   mmtt.transaction_temp_id task_id
               , mmtt.subinventory_code ZONE
               , mmtt.locator_id locator_id
               , mmtt.revision revision
               , mmtt.transaction_uom transaction_uom
               , mmtt.transaction_quantity transaction_quantity
               , '' lot_number
               , mmtt.wms_task_type wms_task_type_id
               , mmtt.task_priority task_priority
            FROM mtl_material_transactions_temp mmtt, wms_ordered_tasks wot
           WHERE mmtt.wms_task_type IS NOT NULL
             AND mmtt.transaction_status = 2
             AND mmtt.transaction_temp_id = wot.task_id
             AND mmtt.transaction_temp_id > 0
        ORDER BY wot.task_sequence_id;
    ELSE -- cycle counting tasks
      OPEN x_task_cur FOR
        SELECT   MIN(mcce.cycle_count_entry_id) task_id
               , mcce.subinventory ZONE
               , mcce.locator_id locator_id
               , mcce.revision revision
               , '' transaction_uom
               , TO_NUMBER(NULL) transaction_quantity
               , MIN(mcce.lot_number) lot_number
               , 3 wms_task_type_id
               , MIN(mcce.task_priority) task_priority
            FROM mtl_cycle_count_entries mcce, wms_ordered_tasks wot
           WHERE mcce.entry_status_code IN(1, 3)
             AND NVL(mcce.export_flag, 2) = 2
             -- bug 3972076
             --AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD')) >= TRUNC(SYSDATE, 'DD')
             AND mcce.cycle_count_entry_id = wot.task_id
        GROUP BY mcce.cycle_count_header_id, mcce.organization_id, mcce.subinventory, mcce.locator_id, mcce.inventory_item_id
               , mcce.revision
        ORDER BY MIN(wot.task_sequence_id);
    END IF;

    l_progress       := '120';
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF l_curs_ordered_tasks%ISOPEN THEN
        CLOSE l_curs_ordered_tasks;
      END IF;

      IF l_curs_ordered_tasks_aw%ISOPEN THEN
        CLOSE l_curs_ordered_tasks_aw;
      END IF;

      IF l_curs_ordered_tasks_exp%ISOPEN THEN -- bug 2648133
        CLOSE l_curs_ordered_tasks_exp;
      END IF;

      IF l_curs_ordered_tasks_aw_exp%ISOPEN THEN
        CLOSE l_curs_ordered_tasks_aw_exp;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('dispatch_task:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_ordered_tasks%ISOPEN THEN
        CLOSE l_curs_ordered_tasks;
      END IF;

      IF l_curs_ordered_tasks_aw%ISOPEN THEN
        CLOSE l_curs_ordered_tasks_aw;
      END IF;

      IF l_curs_ordered_tasks_exp%ISOPEN THEN -- bug 2648133
        CLOSE l_curs_ordered_tasks_exp;
      END IF;

      IF l_curs_ordered_tasks_aw_exp%ISOPEN THEN
        CLOSE l_curs_ordered_tasks_aw_exp;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('dispatch_task: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_ordered_tasks%ISOPEN THEN
        CLOSE l_curs_ordered_tasks;
      END IF;

      IF l_curs_ordered_tasks_aw%ISOPEN THEN
        CLOSE l_curs_ordered_tasks_aw;
      END IF;

      IF l_curs_ordered_tasks_exp%ISOPEN THEN -- bug 2648133
        CLOSE l_curs_ordered_tasks_exp;
      END IF;

      IF l_curs_ordered_tasks_aw_exp%ISOPEN THEN
        CLOSE l_curs_ordered_tasks_aw_exp;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('WMS_Task_Dispatch_Engine.dispatch_task', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('dispatch_task: Other exception ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
  END dispatch_task;

   -- CP Enhancements
  -- This Method has been over-ridden for implementing the cluster picking task dispatch logic.
  PROCEDURE dispatch_task(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 := fnd_api.g_false
  , p_commit                IN            VARCHAR2 := fnd_api.g_false
  , p_sign_on_emp_id        IN            NUMBER
  , p_sign_on_org_id        IN            NUMBER
  , p_sign_on_zone          IN            VARCHAR2 := NULL
  , p_sign_on_equipment_id  IN            NUMBER := NULL -- specific equip id, NULL or -999. -999 stands for none
  , p_sign_on_equipment_srl IN            VARCHAR2 := NULL -- same as above
  , p_task_type             IN            VARCHAR2 -- 'PICKING' or 'ALL'
  , p_task_filter           IN            VARCHAR2 := NULL
  , p_cartonization_id      IN            NUMBER := NULL
  , x_task_cur              OUT NOCOPY    task_rec_cur_tp
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , p_max_clusters          IN            NUMBER := 0
  , x_deliveries_list       OUT NOCOPY    VARCHAR2
  , x_cartons_list          OUT NOCOPY    VARCHAR2
  ) IS
    l_cur_x                  NUMBER;
    l_cur_y                  NUMBER;
    l_cur_z                  NUMBER;
    l_is_locked              BOOLEAN         := FALSE;
    l_sys_task_type          NUMBER;
    l_is_express_pick        NUMBER          := 0; -- 1 for express pick, 0 not
    l_sign_on_equipment_id   NUMBER;
    l_sign_on_equipment_srl  VARCHAR2(30);
    l_equipment_id_str       VARCHAR2(30);
    l_last_loaded_time       DATE;
    l_last_loaded_task_id    NUMBER;
    l_last_loaded_task_type  NUMBER;
    l_last_dropoff_time      DATE;
    l_last_dropoff_task_id   NUMBER;
    l_last_dropoff_task_type NUMBER;
    l_last_task_type         NUMBER;
    l_last_task_is_drop      BOOLEAN         := FALSE;
    l_last_task_id           NUMBER;
    l_ordered_tasks_count    NUMBER;
    --l_first_task_pick_slip_number NUMBER;

    l_api_name      CONSTANT VARCHAR2(30)    := 'dispatch_task';
    l_api_version   CONSTANT NUMBER          := 1.0;
    l_progress               VARCHAR2(10);
    l_cluster_count          NUMBER          := 0;

    -- the following is to used by task_filter
    l_so_allowed                  NUMBER  := 0;
    l_io_allowed                  NUMBER  := 0;
    l_wip_allowed                 NUMBER  := 0;


    TYPE cluster_rec IS RECORD(
      cluster_id   NUMBER
    , cluster_type VARCHAR2(1)
    );

    TYPE cluster_tab IS TABLE OF cluster_rec
      INDEX BY BINARY_INTEGER;

    cluster_table            cluster_tab;

    TYPE numtab IS TABLE OF NUMBER;

    TYPE chrtab IS TABLE OF VARCHAR2(1);

    TYPE loctab IS TABLE OF VARCHAR2(1000);

    TYPE subtab IS TABLE OF VARCHAR2(10);
    TYPE datetab IS TABLE OF DATE;

    idx                      NUMBER          := 0;
    -- This variable will give the bulk collect limit. currenlty it is hardcoded
    -- This can be changed in future to get from a profile.
    blk_limit                NUMBER          := 200;
    t_opt_task_id            numtab;
    t_carton_grouping_id     numtab;
    t_opt_task_type          numtab;
    l_cluster_exists         BOOLEAN         := FALSE;
    t_cluster_id             numtab;
    t_cluster_type           chrtab;
    t_task_priority          numtab;
    t_sub_code               subtab;
    t_sub_picking_order      numtab;
    t_loc_picking_order      numtab;
    t_xyz_distance           numtab;
    t_loc_concat_segs        loctab;
    t_task_status            numtab;
    t_batch_id               numtab;
    l_deliveries_list        VARCHAR2(32000) := NULL;
    l_cartons_list           VARCHAR2(32000) := NULL;

    l_sequence_picks_across_waves  number := 2;
    t_effective_start_date        datetab;
    t_effective_end_date          datetab;
    t_person_resource_id          numtab;
    t_machine_resource_id         numtab;




    CURSOR l_cp_curs_ordered_tasks IS
      SELECT DISTINCT wdtv.task_id task_id1
                    , mol.carton_grouping_id
                    , wdtv.wms_task_type_id
                    , NVL(wda.delivery_id, mol.carton_grouping_id) cluster_id
                    , DECODE(wda.delivery_id, NULL, 'C', 'D') cluster_type
                    , nvl(wdtv.task_priority, 0) wdtv_task_priority
                    , sub.secondary_inventory_name sub_secondary_inventory_name
                    , sub.picking_order sub_picking_order
                    , loc.picking_order loc_picking_order
                    , (
                         (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
                       + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
                       + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
                      ) xyz_distance
                    , loc.concatenated_segments loc_concat_segs
                 FROM --wms_dispatchable_tasks_v wdtv,
                      (SELECT transaction_temp_id task_id
                            , standard_operation_id user_task_type_id
                            , wms_task_type wms_task_type_id
                            , organization_id organization_id
                            , subinventory_code ZONE
                            , locator_id locator_id
                            , task_priority task_priority
                            , revision revision
                            , lot_number lot_number
                            , transaction_uom transaction_uom
                            , transaction_quantity transaction_quantity
                            , pick_rule_id pick_rule_id
                            , pick_slip_number pick_slip_number
                            , cartonization_id cartonization_id
                            , inventory_item_id
                            , move_order_line_id
                         FROM mtl_material_transactions_temp
                        WHERE wms_task_type IS NOT NULL
                          AND transaction_status = 2
                          AND(
                              wms_task_status IS NULL
                              OR wms_task_status = 1
                             )                                                      --Added for task planning WB. bug#2651318
                               -- Commented out the following lines because we won't consider cycle counting taks for cluster pick
                               /*UNION ALL
                               SELECT MIN(cycle_count_entry_id) task_id,
                               MIN(standard_operation_id) user_task_type_id,
                               3 wms_task_type_id,
                               organization_id organization_id,
                               subinventory zone,
                               locator_id locator_id,
                               MIN(task_priority) task_priority,
                               revision revision,
                               MIN(lot_number) lot_number,
                               '' transaction_uom,
                               To_number(NULL) transaction_quantity,
                               To_number(NULL) pick_rule_id,
                               To_number(NULL) pick_slip_number,
                               To_number(NULL) cartonization_id,
                               inventory_item_id,
                               To_number(NULL) move_order_line_id
                               FROM mtl_cycle_count_entries
                               WHERE entry_status_code IN (1,3)
                               AND  NVL(export_flag, 2) = 2
                               -- bug 3972076
                               --AND  NVL(Trunc(count_due_date, 'DD'), Trunc(Sysdate, 'DD')) >= Trunc(Sysdate, 'DD')
                               GROUP BY  cycle_count_header_id, organization_id, subinventory, locator_id, inventory_item_id, revision
                                */
                      ) wdtv
                    ,          -- inlined wms_dispatchable_tasks_v, bug 2648133
                      --wms_person_resource_utt_v v,
                      (SELECT utt_emp.standard_operation_id standard_operation_id
                            , utt_emp.resource_id ROLE
                            , utt_eqp.resource_id equipment
                            , utt_emp.person_id emp_id
                            , utt_eqp.inventory_item_id eqp_id
                            , NULL eqp_srl  /* removed for bug 2095237 */
                         FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                    , x_utt_res1.resource_id resource_id
                                    , x_emp_r.person_id
                                 FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                WHERE x_utt_res1.resource_id = r1.resource_id
                                  AND r1.resource_type = 2
                                  AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                            , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                    , x_utt_res2.resource_id resource_id
                                    , x_eqp_r.inventory_item_id inventory_item_id
                                 FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                WHERE x_utt_res2.resource_id = r2.resource_id
                                  AND r2.resource_type = 1
                                  AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                        WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                    , -- inlined wms_person_resource_utt_v, bug 2648133
                      mtl_item_locations_kfv loc
                    , --changed to kfv bug#2742611
                      mtl_secondary_inventories sub
                    , mtl_txn_request_lines mol
                    , mtl_txn_request_headers moh
                    , --    mtl_system_items msi    -- bug 2648133
                      wsh_delivery_details_ob_grp_v wdd
                    , -- added
                      wsh_delivery_assignments_v wda --added
                WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                  AND wdtv.organization_id = p_sign_on_org_id
                  AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
                  AND mol.header_id = moh.header_id
                  AND moh.move_order_type = 3 -- only pick wave move orders are considered
                  AND wdtv.user_task_type_id =
                                             v.standard_operation_id                                                        -- join task to resource view, check if user defined task type match
                                                                     --AND Nvl(wdtv.zone, '@@@') = Nvl(p_sign_on_zone, Nvl(wdtv.zone, '@@@'))
                  AND wdtv.ZONE = p_sign_on_zone --  removed NVL, bug 2648133
                  AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                  AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                  AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                  AND wdtv.locator_id = loc.inventory_location_id(+)
                  AND wdtv.ZONE = sub.secondary_inventory_name
                  AND wdtv.organization_id = sub.organization_id
                  AND wdtv.move_order_line_id = mol.line_id
                   -- AND wdtv.organization_id = msi.organization_id    -- bug 2648133
                  -- AND wdtv.inventory_item_id = msi.inventory_item_id -- bug 2648133
                  AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                 (
                       SELECT NULL
                         FROM mtl_material_transactions_temp mmtt
                        WHERE mmtt.transaction_temp_id = wdtv.task_id
                          AND mmtt.parent_line_id IS NOT NULL
                          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                  AND NOT EXISTS -- exclude tasks already dispatched
                                 (SELECT NULL
                                    FROM wms_dispatched_tasks wdt1
                                   WHERE wdt1.transaction_temp_id = wdtv.task_id
                                     AND wdt1.task_type = wdtv.wms_task_type_id)
                  -- Join with delivery details
                  AND(wdd.move_order_line_id = wdtv.move_order_line_id
                      AND wdd.delivery_detail_id = wda.delivery_detail_id)
                  --******************
                  AND wdtv.task_id NOT IN -- excluded skipped tasks
                                          (
                       SELECT wdtv.task_id
                         FROM wms_skip_task_exceptions wste, mtl_parameters mp
                        WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                          AND wste.task_id = wdtv.task_id
                          AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                          AND wste.organization_id = mp.organization_id)
                  --J Addition
                   AND  wdtv.ZONE not in (
                           SELECT wd.subinventory_code
                           FROM  wms_devices_b wd
                               , wms_bus_event_devices wbed
                           WHERE 1 = 1
                               and wd.device_id = wbed.device_id
                              AND wbed.organization_id = wd.organization_id
                              AND wd.enabled_flag   = 'Y'
                              AND wbed.enabled_flag = 'Y'
                              AND wbed.business_event_id = 10
                              AND wd.subinventory_code IS NOT NULL
                              AND wd.force_sign_on_flag = 'Y'
                              AND wd.device_id NOT IN (SELECT device_id
                                          FROM wms_device_assignment_temp
                                         WHERE employee_id = p_sign_on_emp_id)
                     )

      --*****************
      UNION ALL
      -- This will select the WIP Jobs alone
      SELECT   wdtv.task_id task_id1
             , mol.carton_grouping_id
             , wdtv.wms_task_type_id
             , mol.carton_grouping_id cluster_id
             , 'C' cluster_type
             , nvl(wdtv.task_priority, 0) wdtv_task_priority
             , sub.secondary_inventory_name sub_secondary_inventory_name
             , sub.picking_order sub_picking_order
             , loc.picking_order loc_picking_order
             , (
                  (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
                + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
                + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
               ) xyz_distance
             , loc.concatenated_segments loc_concat_segs
          FROM --wms_dispatchable_tasks_v wdtv,
               (SELECT transaction_temp_id task_id
                     , standard_operation_id user_task_type_id
                     , wms_task_type wms_task_type_id
                     , organization_id organization_id
                     , subinventory_code ZONE
                     , locator_id locator_id
                     , task_priority task_priority
                     , revision revision
                     , lot_number lot_number
                     , transaction_uom transaction_uom
                     , transaction_quantity transaction_quantity
                     , pick_rule_id pick_rule_id
                     , pick_slip_number pick_slip_number
                     , cartonization_id cartonization_id
                     , inventory_item_id
                     , move_order_line_id
                  FROM mtl_material_transactions_temp
                 WHERE wms_task_type IS NOT NULL
                   AND transaction_status = 2
                   AND(
                       wms_task_status IS NULL
                       OR wms_task_status = 1
                      )                                                      --Added for task planning WB. bug#2651318
                        -- Commented out the following lines because we won't consider cycle counting taks for cluster pick
                        /*UNION ALL
                        SELECT MIN(cycle_count_entry_id) task_id,
                        MIN(standard_operation_id) user_task_type_id,
                        3 wms_task_type_id,
                        organization_id organization_id,
                        subinventory zone,
                        locator_id locator_id,
                        MIN(task_priority) task_priority,
                        revision revision,
                        MIN(lot_number) lot_number,
                        '' transaction_uom,
                        To_number(NULL) transaction_quantity,
                        To_number(NULL) pick_rule_id,
                        To_number(NULL) pick_slip_number,
                        To_number(NULL) cartonization_id,
                        inventory_item_id,
                        To_number(NULL) move_order_line_id
                        FROM mtl_cycle_count_entries
                        WHERE entry_status_code IN (1,3)
                        AND  NVL(export_flag, 2) = 2
                        -- bug 3972076
                        --AND  NVL(Trunc(count_due_date, 'DD'), Trunc(Sysdate, 'DD')) >= Trunc(Sysdate, 'DD')
                        GROUP BY  cycle_count_header_id, organization_id, subinventory, locator_id, inventory_item_id, revision
                         */
               ) wdtv
             ,          -- inlined wms_dispatchable_tasks_v, bug 2648133
               --wms_person_resource_utt_v v,
               (SELECT utt_emp.standard_operation_id standard_operation_id
                     , utt_emp.resource_id ROLE
                     , utt_eqp.resource_id equipment
                     , utt_emp.person_id emp_id
                     , utt_eqp.inventory_item_id eqp_id
                     , NULL eqp_srl  /* removed for bug 2095237 */
                  FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                             , x_utt_res1.resource_id resource_id
                             , x_emp_r.person_id
                          FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                         WHERE x_utt_res1.resource_id = r1.resource_id
                           AND r1.resource_type = 2
                           AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                     , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                             , x_utt_res2.resource_id resource_id
                             , x_eqp_r.inventory_item_id inventory_item_id
                          FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                         WHERE x_utt_res2.resource_id = r2.resource_id
                           AND r2.resource_type = 1
                           AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                 WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
             , -- inlined wms_person_resource_utt_v, bug 2648133
               mtl_item_locations_kfv loc
             , --changed to kfv bug#2742611
               mtl_secondary_inventories sub
             , mtl_txn_request_lines mol
             , mtl_txn_request_headers moh
         --    mtl_system_items msi    -- bug 2648133
      WHERE    v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
           AND wdtv.organization_id = p_sign_on_org_id
           AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
           AND mol.header_id = moh.header_id
           AND moh.move_order_type = 5 -- only WIP jobs are considered : Bug 2666620 BackFlush Removed
           AND wdtv.user_task_type_id = v.standard_operation_id                                                        -- join task to resource view, check if user defined task type match
                                                                --AND Nvl(wdtv.zone, '@@@') = Nvl(p_sign_on_zone, Nvl(wdtv.zone, '@@@'))
           AND wdtv.ZONE = p_sign_on_zone --  removed NVL, bug 2648133
           AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
           AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
           AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
           AND wdtv.locator_id = loc.inventory_location_id(+)
           AND wdtv.ZONE = sub.secondary_inventory_name
           AND wdtv.organization_id = sub.organization_id
           AND wdtv.move_order_line_id = mol.line_id
           -- AND wdtv.organization_id = msi.organization_id    -- bug 2648133
           -- AND wdtv.inventory_item_id = msi.inventory_item_id -- bug 2648133
           AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                          (
                SELECT NULL
                  FROM mtl_material_transactions_temp mmtt
                 WHERE mmtt.transaction_temp_id = wdtv.task_id
                   AND mmtt.parent_line_id IS NOT NULL
                   AND mmtt.wms_task_type = wdtv.wms_task_type_id)
           AND NOT EXISTS -- exclude tasks already dispatched
                          (SELECT NULL
                             FROM wms_dispatched_tasks wdt1
                            WHERE wdt1.transaction_temp_id = wdtv.task_id
                              AND wdt1.task_type = wdtv.wms_task_type_id)
           --******************
           AND wdtv.task_id NOT IN -- excluded skipped tasks
                                   (
                SELECT wdtv.task_id
                  FROM wms_skip_task_exceptions wste, mtl_parameters mp
                 WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                   AND wste.task_id = wdtv.task_id
                   AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                   AND wste.organization_id = mp.organization_id)
      --*****************
      --J Addition
                   AND  wdtv.ZONE not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
      )
      ORDER BY wdtv_task_priority
             , sub_picking_order
             , sub_secondary_inventory_name
             , loc_picking_order
             , xyz_distance
             , loc_concat_segs
             , task_id1;

    CURSOR l_cp_curs_ordered_tasks_no_sub IS -- bug 2648133
      SELECT DISTINCT wdtv.task_id task_id1
                    , mol.carton_grouping_id
                    , wdtv.wms_task_type_id
                    , NVL(wda.delivery_id, mol.carton_grouping_id) cluster_id
                    , DECODE(wda.delivery_id, NULL, 'C', 'D') cluster_type
                    , nvl(wdtv.task_priority, 0) wdtv_task_priority
                    , sub.secondary_inventory_name sub_secondary_inventory_name
                    , sub.picking_order sub_picking_order
                    , loc.picking_order loc_picking_order
                    , (
                         (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
                       + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
                       + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
                      ) xyz_distance
                    , loc.concatenated_segments loc_concat_segs
                 FROM --wms_dispatchable_tasks_v wdtv,
                      (SELECT transaction_temp_id task_id
                            , standard_operation_id user_task_type_id
                            , wms_task_type wms_task_type_id
                            , organization_id organization_id
                            , subinventory_code ZONE
                            , locator_id locator_id
                            , task_priority task_priority
                            , revision revision
                            , lot_number lot_number
                            , transaction_uom transaction_uom
                            , transaction_quantity transaction_quantity
                            , pick_rule_id pick_rule_id
                            , pick_slip_number pick_slip_number
                            , cartonization_id cartonization_id
                            , inventory_item_id
                            , move_order_line_id
                         FROM mtl_material_transactions_temp
                        WHERE wms_task_type IS NOT NULL
                          AND transaction_status = 2
                          AND(
                              wms_task_status IS NULL
                              OR wms_task_status = 1
                             )                                                      --Added for task planning WB. bug#2651318
                               -- Commented out the following lines because we won't consider cycle counting taks for cluster pick
                               /*UNION ALL
                               SELECT MIN(cycle_count_entry_id) task_id,
                               MIN(standard_operation_id) user_task_type_id,
                               3 wms_task_type_id,
                               organization_id organization_id,
                               subinventory zone,
                               locator_id locator_id,
                               MIN(task_priority) task_priority,
                               revision revision,
                               MIN(lot_number) lot_number,
                               '' transaction_uom,
                               To_number(NULL) transaction_quantity,
                               To_number(NULL) pick_rule_id,
                               To_number(NULL) pick_slip_number,
                               To_number(NULL) cartonization_id,
                               inventory_item_id,
                               To_number(NULL) move_order_line_id
                               FROM mtl_cycle_count_entries
                               WHERE entry_status_code IN (1,3)
                               AND  NVL(export_flag, 2) = 2
                               -- bug 3972076
                               -- AND  NVL(Trunc(count_due_date, 'DD'), Trunc(Sysdate, 'DD')) >= Trunc(Sysdate, 'DD')
                               GROUP BY  cycle_count_header_id, organization_id, subinventory, locator_id, inventory_item_id, revision
                                */
                      ) wdtv
                    ,          -- inlined wms_dispatchable_tasks_v, bug 2648133
                      --wms_person_resource_utt_v v,
                      (SELECT utt_emp.standard_operation_id standard_operation_id
                            , utt_emp.resource_id ROLE
                            , utt_eqp.resource_id equipment
                            , utt_emp.person_id emp_id
                            , utt_eqp.inventory_item_id eqp_id
                            , NULL eqp_srl  /* removed for bug 2095237 */
                         FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                    , x_utt_res1.resource_id resource_id
                                    , x_emp_r.person_id
                                 FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                WHERE x_utt_res1.resource_id = r1.resource_id
                                  AND r1.resource_type = 2
                                  AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                            , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                    , x_utt_res2.resource_id resource_id
                                    , x_eqp_r.inventory_item_id inventory_item_id
                                 FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                WHERE x_utt_res2.resource_id = r2.resource_id
                                  AND r2.resource_type = 1
                                  AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                        WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                    , -- inlined wms_person_resource_utt_v, bug 2648133
                      mtl_item_locations_kfv loc
                    , --changed to kfv bug#2742611
                      mtl_secondary_inventories sub
                    , mtl_txn_request_lines mol
                    , mtl_txn_request_headers moh
                    , --    mtl_system_items msi    -- bug 2648133
                      wsh_delivery_details_ob_grp_v wdd
                    , -- added
                      wsh_delivery_assignments_v wda --added
                WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                  AND wdtv.organization_id = p_sign_on_org_id
                  AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
                  AND mol.header_id = moh.header_id
                  AND moh.move_order_type = 3 -- only pick wave move orders are considered
                  AND wdtv.user_task_type_id =
                                             v.standard_operation_id                                                        -- join task to resource view, check if user defined task type match
                                                                     --AND Nvl(wdtv.zone, '@@@') = Nvl(p_sign_on_zone, Nvl(wdtv.zone, '@@@'))
                  AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                  AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                  AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                  AND wdtv.locator_id = loc.inventory_location_id(+)
                  AND wdtv.ZONE = sub.secondary_inventory_name
                  AND wdtv.organization_id = sub.organization_id
                  AND wdtv.move_order_line_id = mol.line_id
                   -- AND wdtv.organization_id = msi.organization_id    -- bug 2648133
                  -- AND wdtv.inventory_item_id = msi.inventory_item_id -- bug 2648133
                  AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                 (
                       SELECT NULL
                         FROM mtl_material_transactions_temp mmtt
                        WHERE mmtt.transaction_temp_id = wdtv.task_id
                          AND mmtt.parent_line_id IS NOT NULL
                          AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                  AND NOT EXISTS -- exclude tasks already dispatched
                                 (SELECT NULL
                                    FROM wms_dispatched_tasks wdt1
                                   WHERE wdt1.transaction_temp_id = wdtv.task_id
                                     AND wdt1.task_type = wdtv.wms_task_type_id)
                  -- Join with delivery details
                  AND(wdd.move_order_line_id = wdtv.move_order_line_id
                      AND wdd.delivery_detail_id = wda.delivery_detail_id)
                  --******************
                  AND wdtv.task_id NOT IN -- excluded skipped tasks
                                          (
                       SELECT wdtv.task_id
                         FROM wms_skip_task_exceptions wste, mtl_parameters mp
                        WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                          AND wste.task_id = wdtv.task_id
                          AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                          AND wste.organization_id = mp.organization_id)
      --*****************
             --J Addition
                         AND  wdtv.ZONE not in (
                        SELECT wd.subinventory_code
                        FROM  wms_devices_b wd
                            , wms_bus_event_devices wbed
                        WHERE 1 = 1
                        and wd.device_id = wbed.device_id
                        AND wbed.organization_id = wd.organization_id
                        AND wd.enabled_flag   = 'Y'
                        AND wbed.enabled_flag = 'Y'
                        AND wbed.business_event_id = 10
                        AND wd.subinventory_code IS NOT NULL
                        AND wd.force_sign_on_flag = 'Y'
                        AND wd.device_id NOT IN (SELECT device_id
                                    FROM wms_device_assignment_temp
                                   WHERE employee_id = p_sign_on_emp_id)
               )

      UNION ALL
      -- This will select the WIP Jobs alone
      SELECT   wdtv.task_id task_id1
             , mol.carton_grouping_id
             , wdtv.wms_task_type_id
             , mol.carton_grouping_id cluster_id
             , 'C' cluster_type
             , nvl(wdtv.task_priority, 0) wdtv_task_priority
             , sub.secondary_inventory_name sub_secondary_inventory_name
             , sub.picking_order sub_picking_order
             , loc.picking_order loc_picking_order
             , (
                  (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
                + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
                + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
               ) xyz_distance
             , loc.concatenated_segments loc_concat_segs
          FROM --wms_dispatchable_tasks_v wdtv,
               (SELECT transaction_temp_id task_id
                     , standard_operation_id user_task_type_id
                     , wms_task_type wms_task_type_id
                     , organization_id organization_id
                     , subinventory_code ZONE
                     , locator_id locator_id
                     , task_priority task_priority
                     , revision revision
                     , lot_number lot_number
                     , transaction_uom transaction_uom
                     , transaction_quantity transaction_quantity
                     , pick_rule_id pick_rule_id
                     , pick_slip_number pick_slip_number
                     , cartonization_id cartonization_id
                     , inventory_item_id
                     , move_order_line_id
                  FROM mtl_material_transactions_temp
                 WHERE wms_task_type IS NOT NULL
                   AND transaction_status = 2
                   AND(
                       wms_task_status IS NULL
                       OR wms_task_status = 1
                      )                                                      --Added for task planning WB. bug#2651318
                        -- Commented out the following lines because we won't consider cycle counting taks for cluster pick
                        /*UNION ALL
                        SELECT MIN(cycle_count_entry_id) task_id,
                        MIN(standard_operation_id) user_task_type_id,
                        3 wms_task_type_id,
                        organization_id organization_id,
                        subinventory zone,
                        locator_id locator_id,
                        MIN(task_priority) task_priority,
                        revision revision,
                        MIN(lot_number) lot_number,
                        '' transaction_uom,
                        To_number(NULL) transaction_quantity,
                        To_number(NULL) pick_rule_id,
                        To_number(NULL) pick_slip_number,
                        To_number(NULL) cartonization_id,
                        inventory_item_id,
                        To_number(NULL) move_order_line_id
                        FROM mtl_cycle_count_entries
                        WHERE entry_status_code IN (1,3)
                        AND  NVL(export_flag, 2) = 2
                        -- bug 3972076
                        --AND  NVL(Trunc(count_due_date, 'DD'), Trunc(Sysdate, 'DD')) >= Trunc(Sysdate, 'DD')
                        GROUP BY  cycle_count_header_id, organization_id, subinventory, locator_id, inventory_item_id, revision
                         */
               ) wdtv
             ,          -- inlined wms_dispatchable_tasks_v, bug 2648133
               --wms_person_resource_utt_v v,
               (SELECT utt_emp.standard_operation_id standard_operation_id
                     , utt_emp.resource_id ROLE
                     , utt_eqp.resource_id equipment
                     , utt_emp.person_id emp_id
                     , utt_eqp.inventory_item_id eqp_id
                     , NULL eqp_srl  /* removed for bug 2095237 */
                  FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                             , x_utt_res1.resource_id resource_id
                             , x_emp_r.person_id
                          FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                         WHERE x_utt_res1.resource_id = r1.resource_id
                           AND r1.resource_type = 2
                           AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                     , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                             , x_utt_res2.resource_id resource_id
                             , x_eqp_r.inventory_item_id inventory_item_id
                          FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                         WHERE x_utt_res2.resource_id = r2.resource_id
                           AND r2.resource_type = 1
                           AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                 WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
             , -- inlined wms_person_resource_utt_v, bug 2648133
               mtl_item_locations_kfv loc
             , --changed to kfv bug#2742611
               mtl_secondary_inventories sub
             , mtl_txn_request_lines mol
             , mtl_txn_request_headers moh
         --    mtl_system_items msi    -- bug 2648133
      WHERE    v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
           AND wdtv.organization_id = p_sign_on_org_id
           AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
           AND mol.header_id = moh.header_id
           AND moh.move_order_type = 5 -- only WIP jobs are considered : Bug 2666620 BackFlush Removed
           AND wdtv.user_task_type_id = v.standard_operation_id                                                        -- join task to resource view, check if user defined task type match
                                                                --AND Nvl(wdtv.zone, '@@@') = Nvl(p_sign_on_zone, Nvl(wdtv.zone, '@@@'))
           AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
           AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
           AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
           AND wdtv.locator_id = loc.inventory_location_id(+)
           AND wdtv.ZONE = sub.secondary_inventory_name
           AND wdtv.organization_id = sub.organization_id
           AND wdtv.move_order_line_id = mol.line_id
           -- AND wdtv.organization_id = msi.organization_id    -- bug 2648133
           -- AND wdtv.inventory_item_id = msi.inventory_item_id -- bug 2648133
           AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                          (
                SELECT NULL
                  FROM mtl_material_transactions_temp mmtt
                 WHERE mmtt.transaction_temp_id = wdtv.task_id
                   AND mmtt.parent_line_id IS NOT NULL
                   AND mmtt.wms_task_type = wdtv.wms_task_type_id)
           AND NOT EXISTS -- exclude tasks already dispatched
                          (SELECT NULL
                             FROM wms_dispatched_tasks wdt1
                            WHERE wdt1.transaction_temp_id = wdtv.task_id
                              AND wdt1.task_type = wdtv.wms_task_type_id)
           --******************
           AND wdtv.task_id NOT IN -- excluded skipped tasks
                                   (
                SELECT wdtv.task_id
                  FROM wms_skip_task_exceptions wste, mtl_parameters mp
                 WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                   AND wste.task_id = wdtv.task_id
                   AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                   AND wste.organization_id = mp.organization_id)
      --*****************
      --J Addition
                   AND  wdtv.ZONE not in ( SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
            )
      ORDER BY wdtv_task_priority
             , sub_picking_order
             , sub_secondary_inventory_name
             , loc_picking_order
             , xyz_distance
             , loc_concat_segs
             , task_id1;

     ------------- the following cursors will be used for patchset J cluster picking from APL

      -- following cursor for SO and IO and sub entered  -----
      CURSOR l_cp_ordered_tasks_SI IS
      SELECT  DISTINCT
                qt.task_id task_id1
         , mol.carton_grouping_id
         , qt.wms_task_type_id
         , NVL(wda.delivery_id, mol.carton_grouping_id) cluster_id
         , DECODE(wda.delivery_id, NULL, 'C', 'D') cluster_type
         , nvl(qt.task_priority,0) wdtv_task_priority -- Bug 4599496
         , sub.secondary_inventory_name sub_secondary_inventory_name
         , sub.picking_order sub_picking_order
         , loc.picking_order loc_picking_order
         , (
         (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
       + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
       + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
      ) xyz_distance
         , loc.concatenated_segments loc_concat_segs
         ,wdt.status task_status --bug 4310093
         ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
              , wdt.effective_start_date
              , wdt.effective_end_date
              , wdt.person_resource_id
              , wdt.machine_resource_id
      FROM wms_dispatched_tasks wdt,
      (SELECT transaction_temp_id task_id
            , standard_operation_id user_task_type_id
            , wms_task_type wms_task_type_id
            , organization_id organization_id
            , subinventory_code ZONE
            , locator_id locator_id
            , task_priority task_priority
            , revision revision
            , lot_number lot_number
            , transaction_uom transaction_uom
            , transaction_quantity transaction_quantity
            , pick_rule_id pick_rule_id
            , pick_slip_number pick_slip_number
            , cartonization_id cartonization_id
            , inventory_item_id
            , move_order_line_id
         FROM mtl_material_transactions_temp
        WHERE wms_task_type IS NOT NULL
          AND transaction_status = 2
          AND Decode(transaction_source_type_id, 2, l_so_allowed,
         8, l_io_allowed) = 1   -- filter out the request so or io
          AND(
         wms_task_status IS NULL
         OR wms_task_status = 1
             )          --Added for task planning WB. bug#2651318
      ) qt
         , (SELECT
             bsor.standard_operation_id,
             bre.resource_id,
             bre.inventory_item_id equipment_id
           FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
           WHERE bsor.resource_id = bre.resource_id
           AND br.resource_type = 1
           AND bsor.resource_id = br.resource_id) e
         , mtl_item_locations_kfv loc
         , --changed to kfv bug#2742611
      mtl_secondary_inventories sub
         , mtl_txn_request_lines mol
         , mtl_txn_request_headers moh
         , --    mtl_system_items msi    -- bug 2648133
      wsh_delivery_details_ob_grp_v wdd
         , -- added
      wsh_delivery_assignments_v wda --added
     WHERE  wdt.transaction_temp_id = qt.task_id
            AND wdt.status in ( 2,3) -- Queued and dispatched tasks only bug 4310093
            AND wdt.person_id = p_sign_on_emp_id
       AND wdt.organization_id = p_sign_on_org_id
       AND qt.wms_task_type_id = 1 -- restrict to picking tasks
       AND mol.header_id = moh.header_id
       AND moh.move_order_type = 3 -- only pick wave move orders are considered
       AND qt.user_task_type_id =
                   e.standard_operation_id(+)                                                       -- join task to resource view, check if user defined task type match
                            --AND Nvl(wdtv.zone, '@@@') = Nvl(p_sign_on_zone, Nvl(wdtv.zone, '@@@'))
       AND qt.ZONE = p_sign_on_zone --  removed NVL, bug 2648133
       AND NVL(qt.cartonization_id, -999) = NVL(p_cartonization_id, NVL(qt.cartonization_id, -999))
       AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))
       AND qt.organization_id = loc.organization_id
       AND qt.locator_id = loc.inventory_location_id
       AND qt.ZONE = sub.secondary_inventory_name
       AND qt.organization_id = sub.organization_id
       AND qt.move_order_line_id = mol.line_id
       -- Join with delivery details
       AND(wdd.move_order_line_id = qt.move_order_line_id
      AND wdd.delivery_detail_id = wda.delivery_detail_id)
        UNION ALL
        SELECT DISTINCT wdtv.task_id task_id1
                      , mol.carton_grouping_id
                      , wdtv.wms_task_type_id
                      , NVL(wda.delivery_id, mol.carton_grouping_id) cluster_id
                      , DECODE(wda.delivery_id, NULL, 'C', 'D') cluster_type
                      , nvl(wdtv.task_priority, 0) wdtv_task_priority
                      , sub.secondary_inventory_name sub_secondary_inventory_name
                      , sub.picking_order sub_picking_order
                      , loc.picking_order loc_picking_order
                      , (
                           (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
                         + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
                         + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
                        ) xyz_distance
                      , loc.concatenated_segments loc_concat_segs
                      ,1 task_status
                      ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
                      ,v.effective_start_date
                      ,v.effective_end_date
                      ,v.role person_resource_id
                      ,v.equipment machine_resource_id
                   FROM --wms_dispatchable_tasks_v wdtv,
                        (SELECT transaction_temp_id task_id
                              , standard_operation_id user_task_type_id
                              , wms_task_type wms_task_type_id
                              , organization_id organization_id
                              , subinventory_code ZONE
                              , locator_id locator_id
                              , task_priority task_priority
                              , revision revision
                              , lot_number lot_number
                              , transaction_uom transaction_uom
                              , transaction_quantity transaction_quantity
                              , pick_rule_id pick_rule_id
                              , pick_slip_number pick_slip_number
                              , cartonization_id cartonization_id
                              , inventory_item_id
                              , move_order_line_id
                           FROM mtl_material_transactions_temp
                          WHERE wms_task_type IS NOT NULL
                            AND transaction_status = 2
                            AND Decode(transaction_source_type_id, 2, l_so_allowed,
                                8, l_io_allowed) = 1   -- filter out the request so or io
                            AND(
                                wms_task_status IS NULL
                                OR wms_task_status = 1
                               )          --Added for task planning WB. bug#2651318
                        ) wdtv
                      ,          -- inlined wms_dispatchable_tasks_v, bug 2648133
                        --wms_person_resource_utt_v v,
                        (SELECT utt_emp.standard_operation_id standard_operation_id
                              , utt_emp.resource_id ROLE
                              , utt_eqp.resource_id equipment
                              , utt_emp.person_id emp_id
                              , utt_eqp.inventory_item_id eqp_id
                              , NULL eqp_srl  /* removed for bug 2095237 */
                              , utt_emp.effective_start_date
                              , utt_emp.effective_end_date
                           FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                      , x_utt_res1.resource_id resource_id
                                      , x_emp_r.person_id
                                      , x_emp_r.effective_start_date
                                      , x_emp_r.effective_end_date
                                   FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                  WHERE x_utt_res1.resource_id = r1.resource_id
                                    AND r1.resource_type = 2
                                    AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                              , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                      , x_utt_res2.resource_id resource_id
                                      , x_eqp_r.inventory_item_id inventory_item_id
                                   FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                  WHERE x_utt_res2.resource_id = r2.resource_id
                                    AND r2.resource_type = 1
                                    AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                          WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                      , -- inlined wms_person_resource_utt_v, bug 2648133
                        mtl_item_locations_kfv loc
                      , --changed to kfv bug#2742611
                        mtl_secondary_inventories sub
                      , mtl_txn_request_lines mol
                      , mtl_txn_request_headers moh
                      , --    mtl_system_items msi    -- bug 2648133
                        wsh_delivery_details_ob_grp_v wdd
                      , -- added
                        wsh_delivery_assignments_v wda --added
                  WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                    AND wdtv.organization_id = p_sign_on_org_id
                    AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
                    AND mol.header_id = moh.header_id
                    AND moh.move_order_type = 3 -- only pick wave move orders are considered
                    AND wdtv.user_task_type_id =
                                               v.standard_operation_id                                                        -- join task to resource view, check if user defined task type match
                                                                       --AND Nvl(wdtv.zone, '@@@') = Nvl(p_sign_on_zone, Nvl(wdtv.zone, '@@@'))
                    AND wdtv.ZONE = p_sign_on_zone --  removed NVL, bug 2648133
                    AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                    AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                    AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                    AND wdtv.locator_id = loc.inventory_location_id(+)
                    AND wdtv.ZONE = sub.secondary_inventory_name
                    AND wdtv.organization_id = sub.organization_id
                    AND wdtv.move_order_line_id = mol.line_id
                     -- AND wdtv.organization_id = msi.organization_id    -- bug 2648133
                    -- AND wdtv.inventory_item_id = msi.inventory_item_id -- bug 2648133
                    AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                   (
                         SELECT NULL
                           FROM mtl_material_transactions_temp mmtt
                          WHERE mmtt.transaction_temp_id = wdtv.task_id
                            AND mmtt.parent_line_id IS NOT NULL
                            AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                    AND NOT EXISTS -- exclude tasks already dispatched
                                   (SELECT NULL
                                      FROM wms_dispatched_tasks wdt1
                                     WHERE wdt1.transaction_temp_id = wdtv.task_id
                                       AND wdt1.task_type = wdtv.wms_task_type_id)
                    -- Join with delivery details
                    AND(wdd.move_order_line_id = wdtv.move_order_line_id
                        AND wdd.delivery_detail_id = wda.delivery_detail_id)
                    --******************
                    AND wdtv.task_id NOT IN -- excluded skipped tasks
                                            (
                         SELECT wdtv.task_id
                           FROM wms_skip_task_exceptions wste, mtl_parameters mp
                          WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                            AND wste.task_id = wdtv.task_id
                            AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                            AND wste.organization_id = mp.organization_id)
                     --J Addition
                         AND  wdtv.ZONE not in (
                         SELECT wd.subinventory_code
                        FROM  wms_devices_b wd
                           , wms_bus_event_devices wbed
                        WHERE 1 = 1
                         and wd.device_id = wbed.device_id
                         AND wbed.organization_id = wd.organization_id
                         AND wd.enabled_flag   = 'Y'
                         AND wbed.enabled_flag = 'Y'
                         AND wbed.business_event_id = 10
                         AND wd.subinventory_code IS NOT NULL
                         AND wd.force_sign_on_flag = 'Y'
                         AND wd.device_id NOT IN (SELECT device_id
                              FROM wms_device_assignment_temp
                                WHERE employee_id = p_sign_on_emp_id)
            )

        ORDER BY wdtv_task_priority DESC
                 , batch_id
                 , task_status DESC
                 , sub_picking_order
                 , loc_picking_order
                 , xyz_distance
                 , task_id1;

        -------------------------
        -- following cursor for WIP and sub entered  -----
        CURSOR l_cp_ordered_tasks_W IS
        SELECT  DISTINCT
                 wdtv.task_id task_id1
               , mol.carton_grouping_id
               , wdtv.wms_task_type_id
               , mol.carton_grouping_id cluster_id
               , 'C' cluster_type
               , nvl(wdtv.task_priority, 0) wdtv_task_priority
               , sub.secondary_inventory_name sub_secondary_inventory_name
               , sub.picking_order sub_picking_order
               , loc.picking_order loc_picking_order
               , (
                    (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
                  + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
                  + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
                 ) xyz_distance
               , loc.concatenated_segments loc_concat_segs
               ,wdt.status task_status --bug  4310093
               ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
              , wdt.effective_start_date
              , wdt.effective_end_date
              , wdt.person_resource_id
              , wdt.machine_resource_id
            FROM wms_dispatched_tasks wdt,
                 (SELECT transaction_temp_id task_id
                       , standard_operation_id user_task_type_id
                       , wms_task_type wms_task_type_id
                       , organization_id organization_id
                       , subinventory_code ZONE
                       , locator_id locator_id
                       , task_priority task_priority
                       , revision revision
                       , lot_number lot_number
                       , transaction_uom transaction_uom
                       , transaction_quantity transaction_quantity
                       , pick_rule_id pick_rule_id
                       , pick_slip_number pick_slip_number
                       , cartonization_id cartonization_id
                       , inventory_item_id
                       , move_order_line_id
                    FROM mtl_material_transactions_temp
                   WHERE wms_task_type IS NOT NULL
                     AND transaction_status = 2
                     AND(
                         wms_task_status IS NULL
                         OR wms_task_status = 1
                        )                                                      --Added for task planning WB. bug#2651318
                 ) wdtv
               , (SELECT
                       bsor.standard_operation_id,
                       bre.resource_id,
                       bre.inventory_item_id equipment_id
                     FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
                     WHERE bsor.resource_id = bre.resource_id
                     AND br.resource_type = 1
                     AND bsor.resource_id = br.resource_id) e
               ,  mtl_item_locations_kfv loc
               , --changed to kfv bug#2742611
                 mtl_secondary_inventories sub
               , mtl_txn_request_lines mol
               , mtl_txn_request_headers moh
           --    mtl_system_items msi    -- bug 2648133
        WHERE  wdt.transaction_temp_id = wdtv.task_id
            AND wdt.status in ( 2,3) -- Queued and dispatched tasks only bug  4310093
            AND wdt.person_id = p_sign_on_emp_id
            AND wdt.organization_id = p_sign_on_org_id
             AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
             AND mol.header_id = moh.header_id
             AND moh.move_order_type = 5 -- only WIP jobs are considered : Bug 2666620 BackFlush Removed
             AND wdtv.user_task_type_id = e.standard_operation_id(+)                                                       -- join task to resource view, check if user defined task type match
             AND wdtv.ZONE = p_sign_on_zone --  removed NVL, bug 2648133
             AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
             AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))
             AND wdtv.organization_id = loc.organization_id
             AND wdtv.locator_id = loc.inventory_location_id
             AND wdtv.ZONE = sub.secondary_inventory_name
             AND wdtv.organization_id = sub.organization_id
             AND wdtv.move_order_line_id = mol.line_id
        UNION ALL
        SELECT   wdtv.task_id task_id1
               , mol.carton_grouping_id
               , wdtv.wms_task_type_id
               , mol.carton_grouping_id cluster_id
               , 'C' cluster_type
               , nvl(wdtv.task_priority, 0) wdtv_task_priority
               , sub.secondary_inventory_name sub_secondary_inventory_name
               , sub.picking_order sub_picking_order
               , loc.picking_order loc_picking_order
               , (
                    (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
                  + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
                  + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
                 ) xyz_distance
               , loc.concatenated_segments loc_concat_segs
               ,1 task_status
               ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
                      ,v.effective_start_date
                      ,v.effective_end_date
                      ,v.role person_resource_id
                      ,v.equipment machine_resource_id
            FROM --wms_dispatchable_tasks_v wdtv,
                 (SELECT transaction_temp_id task_id
                       , standard_operation_id user_task_type_id
                       , wms_task_type wms_task_type_id
                       , organization_id organization_id
                       , subinventory_code ZONE
                       , locator_id locator_id
                       , task_priority task_priority
                       , revision revision
                       , lot_number lot_number
                       , transaction_uom transaction_uom
                       , transaction_quantity transaction_quantity
                       , pick_rule_id pick_rule_id
                       , pick_slip_number pick_slip_number
                       , cartonization_id cartonization_id
                       , inventory_item_id
                       , move_order_line_id
                    FROM mtl_material_transactions_temp
                   WHERE wms_task_type IS NOT NULL
                     AND transaction_status = 2
                     AND(
                         wms_task_status IS NULL
                         OR wms_task_status = 1
                        )                                                      --Added for task planning WB. bug#2651318
                 ) wdtv
               ,          -- inlined wms_dispatchable_tasks_v, bug 2648133
                 --wms_person_resource_utt_v v,
                 (SELECT utt_emp.standard_operation_id standard_operation_id
                       , utt_emp.resource_id ROLE
                       , utt_eqp.resource_id equipment
                       , utt_emp.person_id emp_id
                       , utt_eqp.inventory_item_id eqp_id
                       , NULL eqp_srl  /* removed for bug 2095237 */
                              , utt_emp.effective_start_date
                              , utt_emp.effective_end_date
                    FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                               , x_utt_res1.resource_id resource_id
                               , x_emp_r.person_id
                                      , x_emp_r.effective_start_date
                                      , x_emp_r.effective_end_date
                            FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                           WHERE x_utt_res1.resource_id = r1.resource_id
                             AND r1.resource_type = 2
                             AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                       , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                               , x_utt_res2.resource_id resource_id
                               , x_eqp_r.inventory_item_id inventory_item_id
                            FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                           WHERE x_utt_res2.resource_id = r2.resource_id
                             AND r2.resource_type = 1
                             AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                   WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
               , -- inlined wms_person_resource_utt_v, bug 2648133
                 mtl_item_locations_kfv loc
               , --changed to kfv bug#2742611
                 mtl_secondary_inventories sub
               , mtl_txn_request_lines mol
               , mtl_txn_request_headers moh
           --    mtl_system_items msi    -- bug 2648133
        WHERE    v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
             AND wdtv.organization_id = p_sign_on_org_id
             AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
             AND mol.header_id = moh.header_id
             AND moh.move_order_type = 5 -- only WIP jobs are considered : Bug 2666620 BackFlush Removed
             AND wdtv.user_task_type_id = v.standard_operation_id                                                        -- join task to resource view, check if user defined task type match
                                                                  --AND Nvl(wdtv.zone, '@@@') = Nvl(p_sign_on_zone, Nvl(wdtv.zone, '@@@'))
             AND wdtv.ZONE = p_sign_on_zone --  removed NVL, bug 2648133
             AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
             AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
             AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
             AND wdtv.locator_id = loc.inventory_location_id(+)
             AND wdtv.ZONE = sub.secondary_inventory_name
             AND wdtv.organization_id = sub.organization_id
             AND wdtv.move_order_line_id = mol.line_id
             -- AND wdtv.organization_id = msi.organization_id    -- bug 2648133
             -- AND wdtv.inventory_item_id = msi.inventory_item_id -- bug 2648133
             AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                            (
                  SELECT NULL
                    FROM mtl_material_transactions_temp mmtt
                   WHERE mmtt.transaction_temp_id = wdtv.task_id
                     AND mmtt.parent_line_id IS NOT NULL
                     AND mmtt.wms_task_type = wdtv.wms_task_type_id)
             AND NOT EXISTS -- exclude tasks already dispatched
                            (SELECT NULL
                               FROM wms_dispatched_tasks wdt1
                              WHERE wdt1.transaction_temp_id = wdtv.task_id
                                AND wdt1.task_type = wdtv.wms_task_type_id)
             --******************
             AND wdtv.task_id NOT IN -- excluded skipped tasks
                                     (
                  SELECT wdtv.task_id
                    FROM wms_skip_task_exceptions wste, mtl_parameters mp
                   WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                     AND wste.task_id = wdtv.task_id
                     AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                     AND wste.organization_id = mp.organization_id)
        --*****************
        --J Addition
                    AND  wdtv.ZONE not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
         )
        ORDER BY wdtv_task_priority DESC
                 , batch_id
                 , task_status DESC
                 , sub_picking_order
                 , loc_picking_order
                 , xyz_distance
                 , task_id1;



      ----------------------------------
      -- following cursor for SO, IO and WIP and sub entered  -----

      CURSOR l_cp_ordered_tasks_SIW IS
      SELECT DISTINCT
                   qt.task_id task_id1
         , mol.carton_grouping_id
         , qt.wms_task_type_id
         , NVL(wda.delivery_id, mol.carton_grouping_id) cluster_id
         , DECODE(wda.delivery_id, NULL, 'C', 'D') cluster_type
         , NVL(qt.task_priority,0) wdtv_task_priority -- Bug 4599496
         , sub.secondary_inventory_name sub_secondary_inventory_name
         , sub.picking_order sub_picking_order
         , loc.picking_order loc_picking_order
         , (
         (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
       + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
       + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
      ) xyz_distance
         , loc.concatenated_segments loc_concat_segs
         ,wdt.status task_status --bug 4310093
         ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
              , wdt.effective_start_date
              , wdt.effective_end_date
              , wdt.person_resource_id
              , wdt.machine_resource_id
      FROM wms_dispatched_tasks wdt,
      (SELECT transaction_temp_id task_id
            , standard_operation_id user_task_type_id
            , wms_task_type wms_task_type_id
            , organization_id organization_id
            , subinventory_code ZONE
            , locator_id locator_id
            , task_priority task_priority
            , revision revision
            , lot_number lot_number
            , transaction_uom transaction_uom
            , transaction_quantity transaction_quantity
            , pick_rule_id pick_rule_id
            , pick_slip_number pick_slip_number
            , cartonization_id cartonization_id
            , inventory_item_id
            , move_order_line_id
         FROM mtl_material_transactions_temp
        WHERE wms_task_type IS NOT NULL
          AND transaction_status = 2
          AND Decode(transaction_source_type_id, 2, l_so_allowed,
         8, l_io_allowed) = 1   -- filter out the request so or io
          AND(
         wms_task_status IS NULL
         OR wms_task_status = 1
             )          --Added for task planning WB. bug#2651318
      ) qt
         , (SELECT
             bsor.standard_operation_id,
             bre.resource_id,
             bre.inventory_item_id equipment_id
           FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
           WHERE bsor.resource_id = bre.resource_id
           AND br.resource_type = 1
           AND bsor.resource_id = br.resource_id) e
         , mtl_item_locations_kfv loc
         , --changed to kfv bug#2742611
      mtl_secondary_inventories sub
         , mtl_txn_request_lines mol
         , mtl_txn_request_headers moh
         , --    mtl_system_items msi    -- bug 2648133
      wsh_delivery_details_ob_grp_v wdd
         , -- added
      wsh_delivery_assignments_v wda --added
     WHERE  wdt.transaction_temp_id = qt.task_id
            AND wdt.status in ( 2,3) -- Queued and dispatched tasks only bug 4310093
            AND wdt.person_id = p_sign_on_emp_id
       AND wdt.organization_id = p_sign_on_org_id
       AND qt.wms_task_type_id = 1 -- restrict to picking tasks
       AND mol.header_id = moh.header_id
       AND moh.move_order_type = 3 -- only pick wave move orders are considered
       AND qt.user_task_type_id =
                   e.standard_operation_id(+)                                                       -- join task to resource view, check if user defined task type match
                            --AND Nvl(wdtv.zone, '@@@') = Nvl(p_sign_on_zone, Nvl(wdtv.zone, '@@@'))
       AND qt.ZONE = p_sign_on_zone --  removed NVL, bug 2648133
       AND NVL(qt.cartonization_id, -999) = NVL(p_cartonization_id, NVL(qt.cartonization_id, -999))
       AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))
       AND qt.organization_id = loc.organization_id
       AND qt.locator_id = loc.inventory_location_id
       AND qt.ZONE = sub.secondary_inventory_name
       AND qt.organization_id = sub.organization_id
       AND qt.move_order_line_id = mol.line_id
       -- Join with delivery details
       AND(wdd.move_order_line_id = qt.move_order_line_id
      AND wdd.delivery_detail_id = wda.delivery_detail_id)
        UNION ALL
        SELECT DISTINCT wdtv.task_id task_id1
                      , mol.carton_grouping_id
                      , wdtv.wms_task_type_id
                      , NVL(wda.delivery_id, mol.carton_grouping_id) cluster_id
                      , DECODE(wda.delivery_id, NULL, 'C', 'D') cluster_type
                      , nvl(wdtv.task_priority, 0) wdtv_task_priority
                      , sub.secondary_inventory_name sub_secondary_inventory_name
                      , sub.picking_order sub_picking_order
                      , loc.picking_order loc_picking_order
                      , (
                           (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
                         + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
                         + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
                        ) xyz_distance
                      , loc.concatenated_segments loc_concat_segs
                      ,1 task_status
                      ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
                      ,v.effective_start_date
                      ,v.effective_end_date
                      ,v.role person_resource_id
                      ,v.equipment machine_resource_id
                   FROM --wms_dispatchable_tasks_v wdtv,
                        (SELECT transaction_temp_id task_id
                              , standard_operation_id user_task_type_id
                              , wms_task_type wms_task_type_id
                              , organization_id organization_id
                              , subinventory_code ZONE
                              , locator_id locator_id
                              , task_priority task_priority
                              , revision revision
                              , lot_number lot_number
                              , transaction_uom transaction_uom
                              , transaction_quantity transaction_quantity
                              , pick_rule_id pick_rule_id
                              , pick_slip_number pick_slip_number
                              , cartonization_id cartonization_id
                              , inventory_item_id
                              , move_order_line_id
                           FROM mtl_material_transactions_temp
                          WHERE wms_task_type IS NOT NULL
                            AND transaction_status = 2
                            AND Decode(transaction_source_type_id, 2, l_so_allowed,
                                8, l_io_allowed) = 1   -- filter out the request so or io
                            AND(
                                wms_task_status IS NULL
                                OR wms_task_status = 1
                               )          --Added for task planning WB. bug#2651318
                        ) wdtv
                      ,          -- inlined wms_dispatchable_tasks_v, bug 2648133
                        --wms_person_resource_utt_v v,
                        (SELECT utt_emp.standard_operation_id standard_operation_id
                              , utt_emp.resource_id ROLE
                              , utt_eqp.resource_id equipment
                              , utt_emp.person_id emp_id
                              , utt_eqp.inventory_item_id eqp_id
                              , NULL eqp_srl  /* removed for bug 2095237 */
                              , utt_emp.effective_start_date
                              , utt_emp.effective_end_date
                           FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                      , x_utt_res1.resource_id resource_id
                                      , x_emp_r.person_id
                                      , x_emp_r.effective_start_date
                                      , x_emp_r.effective_end_date
                                   FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                  WHERE x_utt_res1.resource_id = r1.resource_id
                                    AND r1.resource_type = 2
                                    AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                              , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                      , x_utt_res2.resource_id resource_id
                                      , x_eqp_r.inventory_item_id inventory_item_id
                                   FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                  WHERE x_utt_res2.resource_id = r2.resource_id
                                    AND r2.resource_type = 1
                                    AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                          WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                      , -- inlined wms_person_resource_utt_v, bug 2648133
                        mtl_item_locations_kfv loc
                      , --changed to kfv bug#2742611
                        mtl_secondary_inventories sub
                      , mtl_txn_request_lines mol
                      , mtl_txn_request_headers moh
                      , --    mtl_system_items msi    -- bug 2648133
                        wsh_delivery_details_ob_grp_v wdd
                      , -- added
                        wsh_delivery_assignments_v wda --added
                  WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                    AND wdtv.organization_id = p_sign_on_org_id
                    AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
                    AND mol.header_id = moh.header_id
                    AND moh.move_order_type = 3 -- only pick wave move orders are considered
                    AND wdtv.user_task_type_id =
                                               v.standard_operation_id                                                        -- join task to resource view, check if user defined task type match
                                                                       --AND Nvl(wdtv.zone, '@@@') = Nvl(p_sign_on_zone, Nvl(wdtv.zone, '@@@'))
                    AND wdtv.ZONE = p_sign_on_zone --  removed NVL, bug 2648133
                    AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                    AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                    AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                    AND wdtv.locator_id = loc.inventory_location_id(+)
                    AND wdtv.ZONE = sub.secondary_inventory_name
                    AND wdtv.organization_id = sub.organization_id
                    AND wdtv.move_order_line_id = mol.line_id
                     -- AND wdtv.organization_id = msi.organization_id    -- bug 2648133
                    -- AND wdtv.inventory_item_id = msi.inventory_item_id -- bug 2648133
                    AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                   (
                         SELECT NULL
                           FROM mtl_material_transactions_temp mmtt
                          WHERE mmtt.transaction_temp_id = wdtv.task_id
                            AND mmtt.parent_line_id IS NOT NULL
                            AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                    AND NOT EXISTS -- exclude tasks already dispatched
                                   (SELECT NULL
                                      FROM wms_dispatched_tasks wdt1
                                     WHERE wdt1.transaction_temp_id = wdtv.task_id
                                       AND wdt1.task_type = wdtv.wms_task_type_id)
                    -- Join with delivery details
                    AND(wdd.move_order_line_id = wdtv.move_order_line_id
                        AND wdd.delivery_detail_id = wda.delivery_detail_id)
                    --******************
                    AND wdtv.task_id NOT IN -- excluded skipped tasks
                                            (
                         SELECT wdtv.task_id
                           FROM wms_skip_task_exceptions wste, mtl_parameters mp
                          WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                            AND wste.task_id = wdtv.task_id
                            AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                            AND wste.organization_id = mp.organization_id)
        --*****************
                        --J Addition
                            AND  wdtv.ZONE not in (
                            SELECT wd.subinventory_code
                           FROM  wms_devices_b wd
                              , wms_bus_event_devices wbed
                           WHERE 1 = 1
                           and wd.device_id = wbed.device_id
                           AND wbed.organization_id = wd.organization_id
                           AND wd.enabled_flag   = 'Y'
                           AND wbed.enabled_flag = 'Y'
                           AND wbed.business_event_id = 10
                           AND wd.subinventory_code IS NOT NULL
                           AND wd.force_sign_on_flag = 'Y'
                           AND wd.device_id NOT IN (SELECT device_id
                                    FROM wms_device_assignment_temp
                                   WHERE employee_id = p_sign_on_emp_id)
                        )
        UNION ALL
        SELECT DISTINCT
                  wdtv.task_id task_id1
               , mol.carton_grouping_id
               , wdtv.wms_task_type_id
               , mol.carton_grouping_id cluster_id
               , 'C' cluster_type
               , nvl(wdtv.task_priority, 0) wdtv_task_priority
               , sub.secondary_inventory_name sub_secondary_inventory_name
               , sub.picking_order sub_picking_order
               , loc.picking_order loc_picking_order
               , (
                    (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
                  + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
                  + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
                 ) xyz_distance
               , loc.concatenated_segments loc_concat_segs
               ,1 task_status
               ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
              , wdt.effective_start_date
              , wdt.effective_end_date
              , wdt.person_resource_id
              , wdt.machine_resource_id
            FROM wms_dispatched_tasks wdt,
                 (SELECT transaction_temp_id task_id
                       , standard_operation_id user_task_type_id
                       , wms_task_type wms_task_type_id
                       , organization_id organization_id
                       , subinventory_code ZONE
                       , locator_id locator_id
                       , task_priority task_priority
                       , revision revision
                       , lot_number lot_number
                       , transaction_uom transaction_uom
                       , transaction_quantity transaction_quantity
                       , pick_rule_id pick_rule_id
                       , pick_slip_number pick_slip_number
                       , cartonization_id cartonization_id
                       , inventory_item_id
                       , move_order_line_id
                    FROM mtl_material_transactions_temp
                   WHERE wms_task_type IS NOT NULL
                     AND transaction_status = 2
                     AND(
                         wms_task_status IS NULL
                         OR wms_task_status = 1
                        )                                                      --Added for task planning WB. bug#2651318
                 ) wdtv
               , (SELECT
                       bsor.standard_operation_id,
                       bre.resource_id,
                       bre.inventory_item_id equipment_id
                     FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
                     WHERE bsor.resource_id = bre.resource_id
                     AND br.resource_type = 1
                     AND bsor.resource_id = br.resource_id) e
               ,  mtl_item_locations_kfv loc
               , --changed to kfv bug#2742611
                 mtl_secondary_inventories sub
               , mtl_txn_request_lines mol
               , mtl_txn_request_headers moh
           --    mtl_system_items msi    -- bug 2648133
        WHERE  wdt.transaction_temp_id = wdtv.task_id
            AND wdt.status = 2 -- Queued tasks only
            AND wdt.person_id = p_sign_on_emp_id
            AND wdt.organization_id = p_sign_on_org_id
             AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
             AND mol.header_id = moh.header_id
             AND moh.move_order_type = 5 -- only WIP jobs are considered : Bug 2666620 BackFlush Removed
             AND wdtv.user_task_type_id = e.standard_operation_id(+)                                                       -- join task to resource view, check if user defined task type match
             AND wdtv.ZONE = p_sign_on_zone --  removed NVL, bug 2648133
             AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
             AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))
             AND wdtv.organization_id = loc.organization_id
             AND wdtv.locator_id = loc.inventory_location_id
             AND wdtv.ZONE = sub.secondary_inventory_name
             AND wdtv.organization_id = sub.organization_id
             AND wdtv.move_order_line_id = mol.line_id
        UNION ALL
        -- This will select the WIP Jobs alone
        SELECT DISTINCT
                  wdtv.task_id task_id1
               , mol.carton_grouping_id
               , wdtv.wms_task_type_id
               , mol.carton_grouping_id cluster_id
               , 'C' cluster_type
               , nvl(wdtv.task_priority, 0) wdtv_task_priority
               , sub.secondary_inventory_name sub_secondary_inventory_name
               , sub.picking_order sub_picking_order
               , loc.picking_order loc_picking_order
               , (
                    (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
                  + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
                  + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
                 ) xyz_distance
               , loc.concatenated_segments loc_concat_segs
               ,1 task_status
               ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
                      ,v.effective_start_date
                      ,v.effective_end_date
                      ,v.role person_resource_id
                      ,v.equipment machine_resource_id
            FROM --wms_dispatchable_tasks_v wdtv,
                 (SELECT transaction_temp_id task_id
                       , standard_operation_id user_task_type_id
                       , wms_task_type wms_task_type_id
                       , organization_id organization_id
                       , subinventory_code ZONE
                       , locator_id locator_id
                       , task_priority task_priority
                       , revision revision
                       , lot_number lot_number
                       , transaction_uom transaction_uom
                       , transaction_quantity transaction_quantity
                       , pick_rule_id pick_rule_id
                       , pick_slip_number pick_slip_number
                       , cartonization_id cartonization_id
                       , inventory_item_id
                       , move_order_line_id
                    FROM mtl_material_transactions_temp
                   WHERE wms_task_type IS NOT NULL
                     AND transaction_status = 2
                     AND(
                         wms_task_status IS NULL
                         OR wms_task_status = 1
                        )                                                      --Added for task planning WB. bug#2651318
                 ) wdtv
               ,          -- inlined wms_dispatchable_tasks_v, bug 2648133
                 --wms_person_resource_utt_v v,
                 (SELECT utt_emp.standard_operation_id standard_operation_id
                       , utt_emp.resource_id ROLE
                       , utt_eqp.resource_id equipment
                       , utt_emp.person_id emp_id
                       , utt_eqp.inventory_item_id eqp_id
                       , NULL eqp_srl  /* removed for bug 2095237 */
                              , utt_emp.effective_start_date
                              , utt_emp.effective_end_date
                    FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                               , x_utt_res1.resource_id resource_id
                               , x_emp_r.person_id
                                      , x_emp_r.effective_start_date
                                      , x_emp_r.effective_end_date
                            FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                           WHERE x_utt_res1.resource_id = r1.resource_id
                             AND r1.resource_type = 2
                             AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                       , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                               , x_utt_res2.resource_id resource_id
                               , x_eqp_r.inventory_item_id inventory_item_id
                            FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                           WHERE x_utt_res2.resource_id = r2.resource_id
                             AND r2.resource_type = 1
                             AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                   WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
               , -- inlined wms_person_resource_utt_v, bug 2648133
                 mtl_item_locations_kfv loc
               , --changed to kfv bug#2742611
                 mtl_secondary_inventories sub
               , mtl_txn_request_lines mol
               , mtl_txn_request_headers moh
           --    mtl_system_items msi    -- bug 2648133
        WHERE    v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
             AND wdtv.organization_id = p_sign_on_org_id
             AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
             AND mol.header_id = moh.header_id
             AND moh.move_order_type = 5 -- only WIP jobs are considered : Bug 2666620 BackFlush Removed
             AND wdtv.user_task_type_id = v.standard_operation_id                                                        -- join task to resource view, check if user defined task type match
                                                                  --AND Nvl(wdtv.zone, '@@@') = Nvl(p_sign_on_zone, Nvl(wdtv.zone, '@@@'))
             AND wdtv.ZONE = p_sign_on_zone --  removed NVL, bug 2648133
             AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
             AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
             AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
             AND wdtv.locator_id = loc.inventory_location_id(+)
             AND wdtv.ZONE = sub.secondary_inventory_name
             AND wdtv.organization_id = sub.organization_id
             AND wdtv.move_order_line_id = mol.line_id
             -- AND wdtv.organization_id = msi.organization_id    -- bug 2648133
             -- AND wdtv.inventory_item_id = msi.inventory_item_id -- bug 2648133
             AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                            (
                  SELECT NULL
                    FROM mtl_material_transactions_temp mmtt
                   WHERE mmtt.transaction_temp_id = wdtv.task_id
                     AND mmtt.parent_line_id IS NOT NULL
                     AND mmtt.wms_task_type = wdtv.wms_task_type_id)
             AND NOT EXISTS -- exclude tasks already dispatched
                            (SELECT NULL
                               FROM wms_dispatched_tasks wdt1
                              WHERE wdt1.transaction_temp_id = wdtv.task_id
                                AND wdt1.task_type = wdtv.wms_task_type_id)
             --******************
             AND wdtv.task_id NOT IN -- excluded skipped tasks
                                     (
                  SELECT wdtv.task_id
                    FROM wms_skip_task_exceptions wste, mtl_parameters mp
                   WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                     AND wste.task_id = wdtv.task_id
                     AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                     AND wste.organization_id = mp.organization_id)
        --*****************
        --J Addition
                     AND  wdtv.ZONE not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                       WHERE employee_id = p_sign_on_emp_id)
                            )
     ORDER BY wdtv_task_priority DESC
            , batch_id
            , task_status DESC
            , sub_picking_order
            , loc_picking_order
            , xyz_distance
                      , task_id1;


      --- ***************************************
      -- THE FOLLOWING 3 cursors are for no sub ----------------
      ---------------------------------------------------------
      -- following cursor for SO, IO and sub NOT entered  -----
      CURSOR l_cp_ordered_tasks_no_sub_SI IS -- bug 2648133
      SELECT  DISTINCT
                  qt.task_id task_id1
               , mol.carton_grouping_id
               , qt.wms_task_type_id
               , NVL(wda.delivery_id, mol.carton_grouping_id) cluster_id
               , DECODE(wda.delivery_id, NULL, 'C', 'D') cluster_type
               , NVL(qt.task_priority,0) wdtv_task_priority -- Bug 4599496
               , sub.secondary_inventory_name sub_secondary_inventory_name
               , sub.picking_order sub_picking_order
               , loc.picking_order loc_picking_order
               , (
               (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
             + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
             + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
            ) xyz_distance
               , loc.concatenated_segments loc_concat_segs
               ,wdt.status task_status --bug 4310093
               ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
              , wdt.effective_start_date
              , wdt.effective_end_date
              , wdt.person_resource_id
              , wdt.machine_resource_id
            FROM wms_dispatched_tasks wdt,
            (SELECT transaction_temp_id task_id
                  , standard_operation_id user_task_type_id
                  , wms_task_type wms_task_type_id
                  , organization_id organization_id
                  , subinventory_code ZONE
                  , locator_id locator_id
                  , task_priority task_priority
                  , revision revision
                  , lot_number lot_number
                  , transaction_uom transaction_uom
                  , transaction_quantity transaction_quantity
                  , pick_rule_id pick_rule_id
                  , pick_slip_number pick_slip_number
                  , cartonization_id cartonization_id
                  , inventory_item_id
                  , move_order_line_id
               FROM mtl_material_transactions_temp
              WHERE wms_task_type IS NOT NULL
                AND transaction_status = 2
                AND Decode(transaction_source_type_id, 2, l_so_allowed,
               8, l_io_allowed) = 1   -- filter out the request so or io
                AND(
               wms_task_status IS NULL
               OR wms_task_status = 1
                   )          --Added for task planning WB. bug#2651318
            ) qt
               , (SELECT
                   bsor.standard_operation_id,
                   bre.resource_id,
                   bre.inventory_item_id equipment_id
                 FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
                 WHERE bsor.resource_id = bre.resource_id
                 AND br.resource_type = 1
                 AND bsor.resource_id = br.resource_id) e
               , mtl_item_locations_kfv loc
               , --changed to kfv bug#2742611
            mtl_secondary_inventories sub
               , mtl_txn_request_lines mol
               , mtl_txn_request_headers moh
               , --    mtl_system_items msi    -- bug 2648133
            wsh_delivery_details_ob_grp_v wdd
               , -- added
            wsh_delivery_assignments_v wda --added
           WHERE  wdt.transaction_temp_id = qt.task_id
                  AND wdt.status in( 2,3) -- Queued and dispatched tasks only bug 4310093
                  AND wdt.person_id = p_sign_on_emp_id
             AND wdt.organization_id = p_sign_on_org_id
             AND qt.wms_task_type_id = 1 -- restrict to picking tasks
             AND mol.header_id = moh.header_id
             AND moh.move_order_type = 3 -- only pick wave move orders are considered
             AND qt.user_task_type_id =
                         e.standard_operation_id(+)
             AND NVL(qt.cartonization_id, -999) = NVL(p_cartonization_id, NVL(qt.cartonization_id, -999))
             AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))
             AND qt.organization_id = loc.organization_id
             AND qt.locator_id = loc.inventory_location_id
             AND qt.ZONE = sub.secondary_inventory_name
             AND qt.organization_id = sub.organization_id
             AND qt.move_order_line_id = mol.line_id
             -- Join with delivery details
             AND(wdd.move_order_line_id = qt.move_order_line_id
      AND wdd.delivery_detail_id = wda.delivery_detail_id)
       UNION ALL
            SELECT DISTINCT wdtv.task_id task_id1
                            , mol.carton_grouping_id
                            , wdtv.wms_task_type_id
                            , NVL(wda.delivery_id, mol.carton_grouping_id) cluster_id
                            , DECODE(wda.delivery_id, NULL, 'C', 'D') cluster_type
                            , nvl(wdtv.task_priority, 0) wdtv_task_priority
                            , sub.secondary_inventory_name sub_secondary_inventory_name
                            , sub.picking_order sub_picking_order
                            , loc.picking_order loc_picking_order
                            , (
                                 (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
                               + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
                               + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
                              ) xyz_distance
                            , loc.concatenated_segments loc_concat_segs
                            ,1 task_status
                            ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
                      ,v.effective_start_date
                      ,v.effective_end_date
                      ,v.role person_resource_id
                      ,v.equipment machine_resource_id
                         FROM --wms_dispatchable_tasks_v wdtv,
                              (SELECT transaction_temp_id task_id
                                    , standard_operation_id user_task_type_id
                                    , wms_task_type wms_task_type_id
                                    , organization_id organization_id
                                    , subinventory_code ZONE
                                    , locator_id locator_id
                                    , task_priority task_priority
                                    , revision revision
                                    , lot_number lot_number
                                    , transaction_uom transaction_uom
                                    , transaction_quantity transaction_quantity
                                    , pick_rule_id pick_rule_id
                                    , pick_slip_number pick_slip_number
                                    , cartonization_id cartonization_id
                                    , inventory_item_id
                                    , move_order_line_id
                                 FROM mtl_material_transactions_temp
                                WHERE wms_task_type IS NOT NULL
                                  AND transaction_status = 2
                                  AND Decode(transaction_source_type_id, 2, l_so_allowed,
                                      8, l_io_allowed) = 1   -- filter out the request so or io
                                  AND(
                                      wms_task_status IS NULL
                                      OR wms_task_status = 1
                                     )                                                      --Added for task planning WB. bug#2651318
                              ) wdtv
                            ,          -- inlined wms_dispatchable_tasks_v, bug 2648133
                              --wms_person_resource_utt_v v,
                              (SELECT utt_emp.standard_operation_id standard_operation_id
                                    , utt_emp.resource_id ROLE
                                    , utt_eqp.resource_id equipment
                                    , utt_emp.person_id emp_id
                                    , utt_eqp.inventory_item_id eqp_id
                                    , NULL eqp_srl  /* removed for bug 2095237 */
                              , utt_emp.effective_start_date
                              , utt_emp.effective_end_date
                                 FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                            , x_utt_res1.resource_id resource_id
                                            , x_emp_r.person_id
                                      , x_emp_r.effective_start_date
                                      , x_emp_r.effective_end_date
                                         FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                        WHERE x_utt_res1.resource_id = r1.resource_id
                                          AND r1.resource_type = 2
                                          AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                                    , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                            , x_utt_res2.resource_id resource_id
                                            , x_eqp_r.inventory_item_id inventory_item_id
                                         FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                        WHERE x_utt_res2.resource_id = r2.resource_id
                                          AND r2.resource_type = 1
                                          AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                                WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                            , -- inlined wms_person_resource_utt_v, bug 2648133
                              mtl_item_locations_kfv loc
                            , --changed to kfv bug#2742611
                              mtl_secondary_inventories sub
                            , mtl_txn_request_lines mol
                            , mtl_txn_request_headers moh
                            , --    mtl_system_items msi    -- bug 2648133
                              wsh_delivery_details_ob_grp_v wdd
                            , -- added
                              wsh_delivery_assignments_v wda --added
                        WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                          AND wdtv.organization_id = p_sign_on_org_id
                          AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
                          AND mol.header_id = moh.header_id
                          AND moh.move_order_type = 3 -- only pick wave move orders are considered
                          AND wdtv.user_task_type_id =
                                                     v.standard_operation_id                                                        -- join task to resource view, check if user defined task type match
                          AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                          AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                          AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                          AND wdtv.locator_id = loc.inventory_location_id(+)
                          AND wdtv.ZONE = sub.secondary_inventory_name
                          AND wdtv.organization_id = sub.organization_id
                          AND wdtv.move_order_line_id = mol.line_id
                           -- AND wdtv.organization_id = msi.organization_id    -- bug 2648133
                          -- AND wdtv.inventory_item_id = msi.inventory_item_id -- bug 2648133
                          AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                         (
                               SELECT NULL
                                 FROM mtl_material_transactions_temp mmtt
                                WHERE mmtt.transaction_temp_id = wdtv.task_id
                                  AND mmtt.parent_line_id IS NOT NULL
                                  AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                          AND NOT EXISTS -- exclude tasks already dispatched
                                         (SELECT NULL
                                            FROM wms_dispatched_tasks wdt1
                                           WHERE wdt1.transaction_temp_id = wdtv.task_id
                                             AND wdt1.task_type = wdtv.wms_task_type_id)
                          -- Join with delivery details
                          AND(wdd.move_order_line_id = wdtv.move_order_line_id
                              AND wdd.delivery_detail_id = wda.delivery_detail_id)
                          --******************
                          AND wdtv.task_id NOT IN -- excluded skipped tasks
                                                  (
                               SELECT wdtv.task_id
                                 FROM wms_skip_task_exceptions wste, mtl_parameters mp
                                WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                                  AND wste.task_id = wdtv.task_id
                                  AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                                  AND wste.organization_id = mp.organization_id)

                                    --J Addition
                              AND  wdtv.ZONE not in (
                                 SELECT wd.subinventory_code
                                 FROM  wms_devices_b wd
                                     , wms_bus_event_devices wbed
                                 WHERE 1 = 1
                                     and wd.device_id = wbed.device_id
                                    AND wbed.organization_id = wd.organization_id
                                    AND wd.enabled_flag   = 'Y'
                                    AND wbed.enabled_flag = 'Y'
                                    AND wbed.business_event_id = 10
                                    AND wd.subinventory_code IS NOT NULL
                                    AND wd.force_sign_on_flag = 'Y'
                                    AND wd.device_id NOT IN (SELECT device_id
                                                FROM wms_device_assignment_temp
                                               WHERE employee_id = p_sign_on_emp_id)
                           )
         ORDER BY wdtv_task_priority DESC
                 , batch_id
                 , task_status DESC
                 , sub_picking_order
                 , loc_picking_order
                 , xyz_distance
                 , task_id1;


       -- following cursor for  WIP and sub NOT entered  -----
      CURSOR l_cp_ordered_tasks_no_sub_W IS
        SELECT   DISTINCT wdtv.task_id task_id1
               , mol.carton_grouping_id
               , wdtv.wms_task_type_id
               , mol.carton_grouping_id cluster_id
               , 'C' cluster_type
               , nvl(wdtv.task_priority, 0) wdtv_task_priority
               , sub.secondary_inventory_name sub_secondary_inventory_name
               , sub.picking_order sub_picking_order
               , loc.picking_order loc_picking_order
               , (
                    (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
                  + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
                  + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
                 ) xyz_distance
               , loc.concatenated_segments loc_concat_segs
               ,wdt.status task_status  --bug 4310093
               ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
              , wdt.effective_start_date
              , wdt.effective_end_date
              , wdt.person_resource_id
              , wdt.machine_resource_id
            FROM wms_dispatched_tasks wdt,
                 (SELECT transaction_temp_id task_id
                       , standard_operation_id user_task_type_id
                       , wms_task_type wms_task_type_id
                       , organization_id organization_id
                       , subinventory_code ZONE
                       , locator_id locator_id
                       , task_priority task_priority
                       , revision revision
                       , lot_number lot_number
                       , transaction_uom transaction_uom
                       , transaction_quantity transaction_quantity
                       , pick_rule_id pick_rule_id
                       , pick_slip_number pick_slip_number
                       , cartonization_id cartonization_id
                       , inventory_item_id
                       , move_order_line_id
                    FROM mtl_material_transactions_temp
                   WHERE wms_task_type IS NOT NULL
                     AND transaction_status = 2
                     AND(
                         wms_task_status IS NULL
                         OR wms_task_status = 1
                        )                                                      --Added for task planning WB. bug#2651318
                 ) wdtv
               , (SELECT
                       bsor.standard_operation_id,
                       bre.resource_id,
                       bre.inventory_item_id equipment_id
                     FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
                     WHERE bsor.resource_id = bre.resource_id
                     AND br.resource_type = 1
                     AND bsor.resource_id = br.resource_id) e
               ,  mtl_item_locations_kfv loc
               , --changed to kfv bug#2742611
                 mtl_secondary_inventories sub
               , mtl_txn_request_lines mol
               , mtl_txn_request_headers moh
           --    mtl_system_items msi    -- bug 2648133
        WHERE  wdt.transaction_temp_id = wdtv.task_id
            AND wdt.status in ( 2,3) -- Queued and dispatched tasks only bug 4310093
            AND wdt.person_id = p_sign_on_emp_id
            AND wdt.organization_id = p_sign_on_org_id
             AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
             AND mol.header_id = moh.header_id
             AND moh.move_order_type = 5 -- only WIP jobs are considered : Bug 2666620 BackFlush Removed
             AND wdtv.user_task_type_id = e.standard_operation_id(+)                                                       -- join task to resource view, check if user defined task type match
             AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
             AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))
             AND wdtv.organization_id = loc.organization_id
             AND wdtv.locator_id = loc.inventory_location_id
             AND wdtv.ZONE = sub.secondary_inventory_name
             AND wdtv.organization_id = sub.organization_id
             AND wdtv.move_order_line_id = mol.line_id
      UNION ALL
      -- This will select the WIP Jobs alone
      SELECT DISTINCT
                  wdtv.task_id task_id1
        , mol.carton_grouping_id
        , wdtv.wms_task_type_id
        , mol.carton_grouping_id cluster_id
        , 'C' cluster_type
        , nvl(wdtv.task_priority, 0) wdtv_task_priority
        , sub.secondary_inventory_name sub_secondary_inventory_name
        , sub.picking_order sub_picking_order
        , loc.picking_order loc_picking_order
        , (
        (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
      + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
      + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
          ) xyz_distance
        , loc.concatenated_segments loc_concat_segs
        ,1 task_status
        ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
                      ,v.effective_start_date
                      ,v.effective_end_date
                      ,v.role person_resource_id
                      ,v.equipment machine_resource_id
     FROM --wms_dispatchable_tasks_v wdtv,
          (SELECT transaction_temp_id task_id
           , standard_operation_id user_task_type_id
           , wms_task_type wms_task_type_id
           , organization_id organization_id
           , subinventory_code ZONE
           , locator_id locator_id
           , task_priority task_priority
           , revision revision
           , lot_number lot_number
           , transaction_uom transaction_uom
           , transaction_quantity transaction_quantity
           , pick_rule_id pick_rule_id
           , pick_slip_number pick_slip_number
           , cartonization_id cartonization_id
           , inventory_item_id
           , move_order_line_id
        FROM mtl_material_transactions_temp
       WHERE wms_task_type IS NOT NULL
         AND transaction_status = 2
         AND(
             wms_task_status IS NULL
             OR wms_task_status = 1
            )                                                      --Added for task planning WB. bug#2651318
          ) wdtv
        ,          -- inlined wms_dispatchable_tasks_v, bug 2648133
          --wms_person_resource_utt_v v,
          (SELECT utt_emp.standard_operation_id standard_operation_id
           , utt_emp.resource_id ROLE
           , utt_eqp.resource_id equipment
           , utt_emp.person_id emp_id
           , utt_eqp.inventory_item_id eqp_id
           , NULL eqp_srl  /* removed for bug 2095237 */
                              , utt_emp.effective_start_date
                              , utt_emp.effective_end_date
        FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
              , x_utt_res1.resource_id resource_id
              , x_emp_r.person_id
                                      , x_emp_r.effective_start_date
                                      , x_emp_r.effective_end_date
           FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
          WHERE x_utt_res1.resource_id = r1.resource_id
            AND r1.resource_type = 2
            AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
           , (SELECT x_utt_res2.standard_operation_id standard_operation_id
              , x_utt_res2.resource_id resource_id
              , x_eqp_r.inventory_item_id inventory_item_id
           FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
          WHERE x_utt_res2.resource_id = r2.resource_id
            AND r2.resource_type = 1
            AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
       WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
        , -- inlined wms_person_resource_utt_v, bug 2648133
          mtl_item_locations_kfv loc
        , --changed to kfv bug#2742611
          mtl_secondary_inventories sub
        , mtl_txn_request_lines mol
        , mtl_txn_request_headers moh
    --    mtl_system_items msi    -- bug 2648133
      WHERE    v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
      AND wdtv.organization_id = p_sign_on_org_id
      AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
      AND mol.header_id = moh.header_id
      AND moh.move_order_type = 5 -- only WIP jobs are considered : Bug 2666620 BackFlush Removed
      AND wdtv.user_task_type_id = v.standard_operation_id                                                        -- join task to resource view, check if user defined task type match
                        --AND Nvl(wdtv.zone, '@@@') = Nvl(p_sign_on_zone, Nvl(wdtv.zone, '@@@'))
      AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
      AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
      AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
      AND wdtv.locator_id = loc.inventory_location_id(+)
      AND wdtv.ZONE = sub.secondary_inventory_name
      AND wdtv.organization_id = sub.organization_id
      AND wdtv.move_order_line_id = mol.line_id
      -- AND wdtv.organization_id = msi.organization_id    -- bug 2648133
      -- AND wdtv.inventory_item_id = msi.inventory_item_id -- bug 2648133
      AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
           (
      SELECT NULL
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = wdtv.task_id
         AND mmtt.parent_line_id IS NOT NULL
         AND mmtt.wms_task_type = wdtv.wms_task_type_id)
      AND NOT EXISTS -- exclude tasks already dispatched
           (SELECT NULL
              FROM wms_dispatched_tasks wdt1
             WHERE wdt1.transaction_temp_id = wdtv.task_id
               AND wdt1.task_type = wdtv.wms_task_type_id)
      --******************
      AND wdtv.task_id NOT IN -- excluded skipped tasks
               (
      SELECT wdtv.task_id
        FROM wms_skip_task_exceptions wste, mtl_parameters mp
       WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
         AND wste.task_id = wdtv.task_id
         AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
         AND wste.organization_id = mp.organization_id)
      --*****************
      --J Addition
         AND  wdtv.ZONE not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
         )
      ORDER BY wdtv_task_priority DESC
          , batch_id
          , task_status DESC
          , sub_picking_order
          , loc_picking_order
          , xyz_distance
          , task_id1;


      -- following cursor for SO, IO, WIP and sub NOT entered  -----
      CURSOR l_cp_ordered_tasks_no_sub_SIW IS -- bug 2648133
          SELECT  DISTINCT
                  qt.task_id task_id1
         , mol.carton_grouping_id
         , qt.wms_task_type_id
         , NVL(wda.delivery_id, mol.carton_grouping_id) cluster_id
         , DECODE(wda.delivery_id, NULL, 'C', 'D') cluster_type
         , NVL(qt.task_priority, 0) wdtv_task_priority -- Bug 4599496
         , sub.secondary_inventory_name sub_secondary_inventory_name
         , sub.picking_order sub_picking_order
         , loc.picking_order loc_picking_order
         , (
         (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
       + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
       + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
      ) xyz_distance
         , loc.concatenated_segments loc_concat_segs
         ,wdt.status task_status  --bug 4310093
         ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
              , wdt.effective_start_date
              , wdt.effective_end_date
              , wdt.person_resource_id
              , wdt.machine_resource_id
      FROM wms_dispatched_tasks wdt,
      (SELECT transaction_temp_id task_id
            , standard_operation_id user_task_type_id
            , wms_task_type wms_task_type_id
            , organization_id organization_id
            , subinventory_code ZONE
            , locator_id locator_id
            , task_priority task_priority
            , revision revision
            , lot_number lot_number
            , transaction_uom transaction_uom
            , transaction_quantity transaction_quantity
            , pick_rule_id pick_rule_id
            , pick_slip_number pick_slip_number
            , cartonization_id cartonization_id
            , inventory_item_id
            , move_order_line_id
         FROM mtl_material_transactions_temp
        WHERE wms_task_type IS NOT NULL
          AND transaction_status = 2
          AND Decode(transaction_source_type_id, 2, l_so_allowed,
         8, l_io_allowed) = 1   -- filter out the request so or io
          AND(
         wms_task_status IS NULL
         OR wms_task_status = 1
             )          --Added for task planning WB. bug#2651318
      ) qt
         , (SELECT
             bsor.standard_operation_id,
             bre.resource_id,
             bre.inventory_item_id equipment_id
           FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
           WHERE bsor.resource_id = bre.resource_id
           AND br.resource_type = 1
           AND bsor.resource_id = br.resource_id) e
         , mtl_item_locations_kfv loc
         , --changed to kfv bug#2742611
      mtl_secondary_inventories sub
         , mtl_txn_request_lines mol
         , mtl_txn_request_headers moh
         , --    mtl_system_items msi    -- bug 2648133
      wsh_delivery_details_ob_grp_v wdd
         , -- added
      wsh_delivery_assignments_v wda --added
     WHERE  wdt.transaction_temp_id = qt.task_id
        AND wdt.status in ( 2,3) -- Queued and dispatched tasks only bug 4310093
        AND wdt.person_id = p_sign_on_emp_id
       AND wdt.organization_id = p_sign_on_org_id
       AND qt.wms_task_type_id = 1 -- restrict to picking tasks
       AND mol.header_id = moh.header_id
       AND moh.move_order_type = 3 -- only pick wave move orders are considered
       AND qt.user_task_type_id =
                   e.standard_operation_id(+)
       AND NVL(qt.cartonization_id, -999) = NVL(p_cartonization_id, NVL(qt.cartonization_id, -999))
       AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))
       AND qt.organization_id = loc.organization_id
       AND qt.locator_id = loc.inventory_location_id
       AND qt.ZONE = sub.secondary_inventory_name
       AND qt.organization_id = sub.organization_id
       AND qt.move_order_line_id = mol.line_id
       -- Join with delivery details
       AND(wdd.move_order_line_id = qt.move_order_line_id
      AND wdd.delivery_detail_id = wda.delivery_detail_id)
        UNION ALL
        SELECT DISTINCT wdtv.task_id task_id1
                      , mol.carton_grouping_id
                      , wdtv.wms_task_type_id
                      , NVL(wda.delivery_id, mol.carton_grouping_id) cluster_id
                      , DECODE(wda.delivery_id, NULL, 'C', 'D') cluster_type
                      , nvl(wdtv.task_priority, 0) wdtv_task_priority
                      , sub.secondary_inventory_name sub_secondary_inventory_name
                      , sub.picking_order sub_picking_order
                      , loc.picking_order loc_picking_order
                      , (
                           (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
                         + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
                         + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
                        ) xyz_distance
                      , loc.concatenated_segments loc_concat_segs
                      ,1 task_status
                      ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
                      ,v.effective_start_date
                      ,v.effective_end_date
                      ,v.role person_resource_id
                      ,v.equipment machine_resource_id
                   FROM --wms_dispatchable_tasks_v wdtv,
                        (SELECT transaction_temp_id task_id
                              , standard_operation_id user_task_type_id
                              , wms_task_type wms_task_type_id
                              , organization_id organization_id
                              , subinventory_code ZONE
                              , locator_id locator_id
                              , task_priority task_priority
                              , revision revision
                              , lot_number lot_number
                              , transaction_uom transaction_uom
                              , transaction_quantity transaction_quantity
                              , pick_rule_id pick_rule_id
                              , pick_slip_number pick_slip_number
                              , cartonization_id cartonization_id
                              , inventory_item_id
                              , move_order_line_id
                           FROM mtl_material_transactions_temp
                          WHERE wms_task_type IS NOT NULL
                            AND transaction_status = 2
                            AND Decode(transaction_source_type_id, 2, l_so_allowed,
                                8, l_io_allowed) = 1   -- filter out the request so or io
                            AND(
                                wms_task_status IS NULL
                                OR wms_task_status = 1
                               )                                                      --Added for task planning WB. bug#2651318
                        ) wdtv
                      ,          -- inlined wms_dispatchable_tasks_v, bug 2648133
                        --wms_person_resource_utt_v v,
                        (SELECT utt_emp.standard_operation_id standard_operation_id
                              , utt_emp.resource_id ROLE
                              , utt_eqp.resource_id equipment
                              , utt_emp.person_id emp_id
                              , utt_eqp.inventory_item_id eqp_id
                              , NULL eqp_srl  /* removed for bug 2095237 */
                              , utt_emp.effective_start_date
                              , utt_emp.effective_end_date
                           FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                                      , x_utt_res1.resource_id resource_id
                                      , x_emp_r.person_id
                                      , x_emp_r.effective_start_date
                                      , x_emp_r.effective_end_date
                                   FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                                  WHERE x_utt_res1.resource_id = r1.resource_id
                                    AND r1.resource_type = 2
                                    AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                              , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                                      , x_utt_res2.resource_id resource_id
                                      , x_eqp_r.inventory_item_id inventory_item_id
                                   FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                                  WHERE x_utt_res2.resource_id = r2.resource_id
                                    AND r2.resource_type = 1
                                    AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                          WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
                      , -- inlined wms_person_resource_utt_v, bug 2648133
                        mtl_item_locations_kfv loc
                      , --changed to kfv bug#2742611
                        mtl_secondary_inventories sub
                      , mtl_txn_request_lines mol
                      , mtl_txn_request_headers moh
                      , --    mtl_system_items msi    -- bug 2648133
                        wsh_delivery_details_ob_grp_v wdd
                      , -- added
                        wsh_delivery_assignments_v wda --added
                  WHERE v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
                    AND wdtv.organization_id = p_sign_on_org_id
                    AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
                    AND mol.header_id = moh.header_id
                    AND moh.move_order_type = 3 -- only pick wave move orders are considered
                    AND wdtv.user_task_type_id =
                                               v.standard_operation_id                                                        -- join task to resource view, check if user defined task type match
                                                                       --AND Nvl(wdtv.zone, '@@@') = Nvl(p_sign_on_zone, Nvl(wdtv.zone, '@@@'))
                    AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
                    AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
                    AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
                    AND wdtv.locator_id = loc.inventory_location_id(+)
                    AND wdtv.ZONE = sub.secondary_inventory_name
                    AND wdtv.organization_id = sub.organization_id
                    AND wdtv.move_order_line_id = mol.line_id
                     -- AND wdtv.organization_id = msi.organization_id    -- bug 2648133
                    -- AND wdtv.inventory_item_id = msi.inventory_item_id -- bug 2648133
                    AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                                   (
                         SELECT NULL
                           FROM mtl_material_transactions_temp mmtt
                          WHERE mmtt.transaction_temp_id = wdtv.task_id
                            AND mmtt.parent_line_id IS NOT NULL
                            AND mmtt.wms_task_type = wdtv.wms_task_type_id)
                    AND NOT EXISTS -- exclude tasks already dispatched
                                   (SELECT NULL
                                      FROM wms_dispatched_tasks wdt1
                                     WHERE wdt1.transaction_temp_id = wdtv.task_id
                                       AND wdt1.task_type = wdtv.wms_task_type_id)
                    -- Join with delivery details
                    AND(wdd.move_order_line_id = wdtv.move_order_line_id
                        AND wdd.delivery_detail_id = wda.delivery_detail_id)
                    --******************
                    AND wdtv.task_id NOT IN -- excluded skipped tasks
                                            (
                         SELECT wdtv.task_id
                           FROM wms_skip_task_exceptions wste, mtl_parameters mp
                          WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                            AND wste.task_id = wdtv.task_id
                            AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                            AND wste.organization_id = mp.organization_id)
        --*****************
                  --J Addition
                               AND  wdtv.ZONE not in (
                        SELECT wd.subinventory_code
                        FROM  wms_devices_b wd
                            , wms_bus_event_devices wbed
                        WHERE 1 = 1
                            and wd.device_id = wbed.device_id
                           AND wbed.organization_id = wd.organization_id
                           AND wd.enabled_flag   = 'Y'
                           AND wbed.enabled_flag = 'Y'
                           AND wbed.business_event_id = 10
                           AND wd.subinventory_code IS NOT NULL
                           AND wd.force_sign_on_flag = 'Y'
                           AND wd.device_id NOT IN (SELECT device_id
                                       FROM wms_device_assignment_temp
                                      WHERE employee_id = p_sign_on_emp_id)
                  )
        UNION ALL
   SELECT DISTINCT
                  wdtv.task_id task_id1
          , mol.carton_grouping_id
          , wdtv.wms_task_type_id
          , mol.carton_grouping_id cluster_id
          , 'C' cluster_type
          , nvl(wdtv.task_priority, 0) wdtv_task_priority
          , sub.secondary_inventory_name sub_secondary_inventory_name
          , sub.picking_order sub_picking_order
          , loc.picking_order loc_picking_order
          , (
          (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
        + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
        + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
       ) xyz_distance
          , loc.concatenated_segments loc_concat_segs
          ,1 task_status
          ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
              , wdt.effective_start_date
              , wdt.effective_end_date
              , wdt.person_resource_id
              , wdt.machine_resource_id
       FROM wms_dispatched_tasks wdt,
       (SELECT transaction_temp_id task_id
             , standard_operation_id user_task_type_id
             , wms_task_type wms_task_type_id
             , organization_id organization_id
             , subinventory_code ZONE
             , locator_id locator_id
             , task_priority task_priority
             , revision revision
             , lot_number lot_number
             , transaction_uom transaction_uom
             , transaction_quantity transaction_quantity
             , pick_rule_id pick_rule_id
             , pick_slip_number pick_slip_number
             , cartonization_id cartonization_id
             , inventory_item_id
             , move_order_line_id
          FROM mtl_material_transactions_temp
         WHERE wms_task_type IS NOT NULL
           AND transaction_status = 2
           AND(
          wms_task_status IS NULL
          OR wms_task_status = 1
         )                                                      --Added for task planning WB. bug#2651318
       ) wdtv
          , (SELECT
             bsor.standard_operation_id,
             bre.resource_id,
             bre.inventory_item_id equipment_id
           FROM bom_std_op_resources bsor, bom_resources br, bom_resource_equipments bre
           WHERE bsor.resource_id = bre.resource_id
           AND br.resource_type = 1
           AND bsor.resource_id = br.resource_id) e
          ,  mtl_item_locations_kfv loc
          , --changed to kfv bug#2742611
       mtl_secondary_inventories sub
          , mtl_txn_request_lines mol
          , mtl_txn_request_headers moh
      --    mtl_system_items msi    -- bug 2648133
   WHERE  wdt.transaction_temp_id = wdtv.task_id
       AND wdt.status = 2 -- Queued tasks only
       AND wdt.person_id = p_sign_on_emp_id
       AND wdt.organization_id = p_sign_on_org_id
        AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
        AND mol.header_id = moh.header_id
        AND moh.move_order_type = 5 -- only WIP jobs are considered : Bug 2666620 BackFlush Removed
        AND wdtv.user_task_type_id = e.standard_operation_id(+)                                                       -- join task to resource view, check if user defined task type match
        AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
        AND NVL(e.equipment_id, -999) = NVL(l_sign_on_equipment_id, NVL(e.equipment_id, -999))
        AND wdtv.organization_id = loc.organization_id
        AND wdtv.locator_id = loc.inventory_location_id
        AND wdtv.ZONE = sub.secondary_inventory_name
        AND wdtv.organization_id = sub.organization_id
        AND wdtv.move_order_line_id = mol.line_id
        UNION ALL
        -- This will select the WIP Jobs alone
        SELECT DISTINCT
                  wdtv.task_id task_id1
               , mol.carton_grouping_id
               , wdtv.wms_task_type_id
               , mol.carton_grouping_id cluster_id
               , 'C' cluster_type
               , nvl(wdtv.task_priority, 0) wdtv_task_priority
               , sub.secondary_inventory_name sub_secondary_inventory_name
               , sub.picking_order sub_picking_order
               , loc.picking_order loc_picking_order
               , (
                    (nvl(loc.x_coordinate, 0) - l_cur_x) *(nvl(loc.x_coordinate, 0) - l_cur_x)
                  + (nvl(loc.y_coordinate, 0) - l_cur_y) *(nvl(loc.y_coordinate, 0) - l_cur_y)
                  + (nvl(loc.z_coordinate, 0) - l_cur_z) *(nvl(loc.z_coordinate, 0) - l_cur_z)
                 ) xyz_distance
               , loc.concatenated_segments loc_concat_segs
               ,1 task_status
               ,DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL) batch_id
                      ,v.effective_start_date
                      ,v.effective_end_date
                      ,v.role person_resource_id
                      ,v.equipment machine_resource_id
            FROM --wms_dispatchable_tasks_v wdtv,
                 (SELECT transaction_temp_id task_id
                       , standard_operation_id user_task_type_id
                       , wms_task_type wms_task_type_id
                       , organization_id organization_id
                       , subinventory_code ZONE
                       , locator_id locator_id
                       , task_priority task_priority
                       , revision revision
                       , lot_number lot_number
                       , transaction_uom transaction_uom
                       , transaction_quantity transaction_quantity
                       , pick_rule_id pick_rule_id
                       , pick_slip_number pick_slip_number
                       , cartonization_id cartonization_id
                       , inventory_item_id
                       , move_order_line_id
                    FROM mtl_material_transactions_temp
                   WHERE wms_task_type IS NOT NULL
                     AND transaction_status = 2
                     AND(
                         wms_task_status IS NULL
                         OR wms_task_status = 1
                        )                                                      --Added for task planning WB. bug#2651318
                 ) wdtv
               ,          -- inlined wms_dispatchable_tasks_v, bug 2648133
                 --wms_person_resource_utt_v v,
                 (SELECT utt_emp.standard_operation_id standard_operation_id
                       , utt_emp.resource_id ROLE
                       , utt_eqp.resource_id equipment
                       , utt_emp.person_id emp_id
                       , utt_eqp.inventory_item_id eqp_id
                       , NULL eqp_srl  /* removed for bug 2095237 */
                              , utt_emp.effective_start_date
                              , utt_emp.effective_end_date
                    FROM (SELECT x_utt_res1.standard_operation_id standard_operation_id
                               , x_utt_res1.resource_id resource_id
                               , x_emp_r.person_id
                                      , x_emp_r.effective_start_date
                                      , x_emp_r.effective_end_date
                            FROM bom_std_op_resources x_utt_res1, bom_resources r1, bom_resource_employees x_emp_r
                           WHERE x_utt_res1.resource_id = r1.resource_id
                             AND r1.resource_type = 2
                             AND x_utt_res1.resource_id = x_emp_r.resource_id) utt_emp
                       , (SELECT x_utt_res2.standard_operation_id standard_operation_id
                               , x_utt_res2.resource_id resource_id
                               , x_eqp_r.inventory_item_id inventory_item_id
                            FROM bom_std_op_resources x_utt_res2, bom_resources r2, bom_resource_equipments x_eqp_r
                           WHERE x_utt_res2.resource_id = r2.resource_id
                             AND r2.resource_type = 1
                             AND x_utt_res2.resource_id = x_eqp_r.resource_id) utt_eqp
                   WHERE utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)) v
               , -- inlined wms_person_resource_utt_v, bug 2648133
                 mtl_item_locations_kfv loc
               , --changed to kfv bug#2742611
                 mtl_secondary_inventories sub
               , mtl_txn_request_lines mol
               , mtl_txn_request_headers moh
           --    mtl_system_items msi    -- bug 2648133
        WHERE    v.emp_id = p_sign_on_emp_id -- restrict to sign on employee
             AND wdtv.organization_id = p_sign_on_org_id
             AND wdtv.wms_task_type_id = 1 -- restrict to picking tasks
             AND mol.header_id = moh.header_id
             AND moh.move_order_type = 5 -- only WIP jobs are considered : Bug 2666620 BackFlush Removed
             AND wdtv.user_task_type_id = v.standard_operation_id                                                        -- join task to resource view, check if user defined task type match
                                                                  --AND Nvl(wdtv.zone, '@@@') = Nvl(p_sign_on_zone, Nvl(wdtv.zone, '@@@'))
             AND NVL(wdtv.cartonization_id, -999) = NVL(p_cartonization_id, NVL(wdtv.cartonization_id, -999))
             AND NVL(v.eqp_id, -999) = NVL(l_sign_on_equipment_id, NVL(v.eqp_id, -999))
             AND wdtv.organization_id = loc.organization_id(+) -- join task to loc, outer join for tasks do not have locator
             AND wdtv.locator_id = loc.inventory_location_id(+)
             AND wdtv.ZONE = sub.secondary_inventory_name
             AND wdtv.organization_id = sub.organization_id
             AND wdtv.move_order_line_id = mol.line_id
             -- AND wdtv.organization_id = msi.organization_id    -- bug 2648133
             -- AND wdtv.inventory_item_id = msi.inventory_item_id -- bug 2648133
             AND NOT EXISTS -- exclude child tasks for consolidated bulk tasks
                            (
                  SELECT NULL
                    FROM mtl_material_transactions_temp mmtt
                   WHERE mmtt.transaction_temp_id = wdtv.task_id
                     AND mmtt.parent_line_id IS NOT NULL
                     AND mmtt.wms_task_type = wdtv.wms_task_type_id)
             AND NOT EXISTS -- exclude tasks already dispatched
                            (SELECT NULL
                               FROM wms_dispatched_tasks wdt1
                              WHERE wdt1.transaction_temp_id = wdtv.task_id
                                AND wdt1.task_type = wdtv.wms_task_type_id)
             --******************
             AND wdtv.task_id NOT IN -- excluded skipped tasks
                                     (
                  SELECT wdtv.task_id
                    FROM wms_skip_task_exceptions wste, mtl_parameters mp
                   WHERE ((SYSDATE - wste.creation_date) * 24 * 60) < mp.skip_task_waiting_minutes
                     AND wste.task_id = wdtv.task_id
                     AND wste.wms_task_type = NVL(l_sys_task_type, wste.wms_task_type)
                     AND wste.organization_id = mp.organization_id)
        --*****************
        --J Addition
                     AND  wdtv.ZONE not in (
            SELECT wd.subinventory_code
            FROM  wms_devices_b wd
                , wms_bus_event_devices wbed
            WHERE 1 = 1
                and wd.device_id = wbed.device_id
               AND wbed.organization_id = wd.organization_id
               AND wd.enabled_flag   = 'Y'
               AND wbed.enabled_flag = 'Y'
               AND wbed.business_event_id = 10
               AND wd.subinventory_code IS NOT NULL
               AND wd.force_sign_on_flag = 'Y'
               AND wd.device_id NOT IN (SELECT device_id
                           FROM wms_device_assignment_temp
                          WHERE employee_id = p_sign_on_emp_id)
            )
        ORDER BY wdtv_task_priority DESC
       , batch_id -- DECODE (L_SEQUENCE_PICKS_ACROSS_WAVES, 2, MOL.HEADER_ID, NULL)
       , task_status DESC
       , sub_picking_order
       , loc_picking_order
       , xyz_distance
                 , task_id1;

   CURSOR c_task_filter(v_filter_name VARCHAR2) IS
      SELECT task_filter_source, task_filter_value
        FROM wms_task_filter_b wtf, wms_task_filter_dtl wtfd
        WHERE task_filter_name = v_filter_name
        AND wtf.task_filter_id = wtfd.task_filter_id;


    l_debug                  NUMBER          := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Enter dispatch_task ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress       := '10';

    -- This API is query only, therefore does not create a save point
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    -- API body
    -- preprocess input parameters

    IF p_sign_on_equipment_srl = 'NONE' THEN
      l_sign_on_equipment_srl  := NULL;
      l_sign_on_equipment_id   := -999;
    ELSE
      l_sign_on_equipment_srl  := p_sign_on_equipment_srl;
      l_sign_on_equipment_id   := p_sign_on_equipment_id;
    END IF;

    -- use l_equipment_id_str to concatenate sql statement
    IF l_sign_on_equipment_id IS NULL THEN
      l_equipment_id_str  := 'NULL';
    ELSE
      l_equipment_id_str  := TO_CHAR(l_sign_on_equipment_id);
    END IF;

    IF p_task_type = 'PICKING' THEN
      l_sys_task_type  := 1;
    ELSIF p_task_type = 'EXPPICK' THEN
      l_sys_task_type    := 1;
      l_is_express_pick  := 1;

      IF (l_debug = 1) THEN
        print_debug('Express Pick Task', 4);
      END IF;
    ELSE
      l_sys_task_type  := NULL;
    END IF;

    -- check if this call is for picking tasks or for all tasks
    IF p_task_type = 'DISPLAY' THEN
      IF (l_debug = 1) THEN
        print_debug('dispatch_task - DISPLAY ', 4);
      END IF;

      l_progress  := '20';
    /*
          l_sql_stmt :=
                  'SELECT  wdtv.task_id, wdtv.zone, wdtv.locator_id,
                          wdtv.revision, wdtv.transaction_uom,
                          wdtv.transaction_quantity, wdtv.lot_number, wdtv.wms_task_type_id,nvl(wdtv.task_priority, 0)
                   FROM    wms_dispatchable_tasks_v wdtv
                   WHERE   wdtv.organization_id = ' || p_sign_on_org_id ||'
                          AND Nvl(wdtv.zone, ''@@@'') = Nvl('''|| p_sign_on_zone || ''', Nvl(wdtv.zone, ''@@@''))
                          AND wdtv.user_task_type_id IN
                          (
                           SELECT standard_operation_id
                           FROM wms_person_resource_utt_v v
                           WHERE v.emp_id = ' || p_sign_on_emp_id  ||'
                           AND Nvl(v.eqp_srl, ''@@@'') = Nvl(''' || l_sign_on_equipment_srl || ''', Nvl(v.eqp_srl, ''@@@''))
                           AND Nvl(v.eqp_id, -999) = Nvl(' || l_equipment_id_str ||', Nvl(v.eqp_id, -999))
                           )
                          --***********
                          AND wdtv.task_id NOT IN
                          (SELECT wdtv.task_id FROM wms_skip_task_exceptions wste, mtl_parameters mp
                           WHERE ((SYSDATE - wste.creation_date)*24*60) < mp.skip_task_waiting_minutes
                           AND wste.task_id = wdtv.task_id
                           AND wste.organization_id = mp.organization_id )
                          --************
                          AND wdtv.task_id NOT IN
                          (SELECT wdt1.transaction_temp_id
                           FROM wms_dispatched_tasks wdt1
                           --   WHERE wdt1.status = 1
                           UNION ALL
                           SELECT wdt2.transaction_temp_id
                           FROM wms_exceptions wms_except, wms_dispatched_tasks wdt2
                           WHERE wms_except.person_id = ' || p_sign_on_emp_id || '
                           AND wdt2.task_id = wms_except.task_id
                           AND discrepancy_type = 1
                           )
                    ORDER BY wdtv.pick_slip_number, nvl(wdtv.task_priority, 0), wdtv.task_id';
    */
    ELSIF(p_task_type = 'ALL'
          OR p_task_type = 'EXPPICK'
          OR p_task_type = 'PICKING') THEN -- the call is for ALL taks
      IF (l_debug = 1) THEN
        print_debug('dispatch_task -' || p_task_type, 4);
      END IF;

      l_progress             := '30';

      -- select last task this operator was working on
      BEGIN
        SELECT transaction_temp_id
             , task_type
             , loaded_time
          INTO l_last_loaded_task_id
             , l_last_loaded_task_type
             , l_last_loaded_time
          FROM (SELECT transaction_temp_id
                     , task_type
                     , loaded_time
                  FROM wms_dispatched_tasks wdt
                 WHERE wdt.person_id = p_sign_on_emp_id
                   AND wdt.loaded_time = (SELECT MAX(loaded_time)
                                            FROM wms_dispatched_tasks
                                           WHERE person_id = p_sign_on_emp_id))
         WHERE ROWNUM = 1; -- make sure only one task selected

        l_progress  := '31';
      EXCEPTION
        WHEN OTHERS THEN
          l_last_loaded_task_id  := -1;
      END;

      IF (l_debug = 1) THEN
        print_debug('dispatch_task - last loaded task : l_last_loaded_task_id => ' || l_last_loaded_task_id, 4);
        print_debug('dispatch_task  => l_last_loaded_task_type' || l_last_loaded_task_type, 4);
        print_debug('dispatch_task  => l_last_loaded_time' || l_last_loaded_time, 4);
      END IF;

      -- select last task this operator completed
      BEGIN
        l_progress  := '32';

        SELECT transaction_id
             , task_type
             , loaded_time
          INTO l_last_dropoff_task_id
             , l_last_dropoff_task_type
             , l_last_dropoff_time
          FROM (SELECT transaction_id
                     , task_type
                     , loaded_time
                  FROM wms_dispatched_tasks_history wdth
                 WHERE wdth.person_id = p_sign_on_emp_id
                   AND wdth.drop_off_time = (SELECT MAX(drop_off_time)
                                               FROM wms_dispatched_tasks_history
                                              WHERE person_id = p_sign_on_emp_id))
         WHERE ROWNUM = 1; -- make sure only one task selected

        l_progress  := '33';
      EXCEPTION
        WHEN OTHERS THEN
          l_last_dropoff_task_id  := -1;
      END;

      IF (l_debug = 1) THEN
        print_debug('dispatch_task - last dropoff task : l_last_dropoff_task_id => ' || l_last_dropoff_task_id, 4);
        print_debug('dispatch_task  => l_last_dropoff_task_type' || l_last_dropoff_task_type, 4);
        print_debug('dispatch_task  => l_last_dropoff_time' || l_last_dropoff_time, 4);
      END IF;

      IF l_last_dropoff_task_id = -1
         AND l_last_loaded_task_id = -1 THEN
        l_last_task_id  := -1;
      ELSIF l_last_dropoff_task_id = -1 THEN
        l_last_task_id       := l_last_loaded_task_id;
        l_last_task_type     := l_last_loaded_task_type;
        l_last_task_is_drop  := FALSE;
      ELSIF l_last_loaded_task_id = -1 THEN
        l_last_task_id       := l_last_dropoff_task_id;
        l_last_task_type     := l_last_dropoff_task_type;
        l_last_task_is_drop  := TRUE;
      ELSIF l_last_loaded_time < l_last_dropoff_time THEN
        l_last_task_id       := l_last_dropoff_task_id;
        l_last_task_type     := l_last_dropoff_task_type;
        l_last_task_is_drop  := TRUE;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('dispatch_task - previous task - l_last_task_id = ' || l_last_task_id, 4);
      END IF;

      -- select locator coordinates of the the last task
      IF l_last_task_id <> -1 THEN -- make sure there is a last task
        IF l_last_task_is_drop <> TRUE THEN                                   -- task that has not been completed
                                            -- get the location from wms_dispatchable_tasks_v
          BEGIN
            l_progress  := '35';

            -- use Nvl to make sure if coordinates not defined, use 0
            SELECT NVL(loc.x_coordinate, 0)
                 , NVL(loc.y_coordinate, 0)
                 , NVL(loc.z_coordinate, 0)
              INTO l_cur_x
                 , l_cur_y
                 , l_cur_z
              FROM mtl_item_locations loc, wms_dispatchable_tasks_v wdtv
             WHERE wdtv.locator_id = loc.inventory_location_id
               AND wdtv.organization_id = loc.organization_id
               AND wdtv.task_id = l_last_task_id
               AND wdtv.wms_task_type_id = l_last_task_type;

            -- Added the previous line since the task_id in the view
            -- might not be unique since it is the transaction_temp_id
            -- if it comes from MMTT but the cycle_count_entry_id if
            -- it comes from MTL_CYCLE_COUNT_ENTRIES for cycle counting tasks
            l_progress  := '36';
          EXCEPTION
            WHEN OTHERS THEN
              -- locator definition descripency
              l_cur_x  := 0;
              l_cur_y  := 0;
              l_cur_z  := 0;
          END;
        ELSE -- l_last_task_is_drop <> TRUE  (completed tasks)
          IF l_last_task_type <> 3 THEN -- not cycle count task hence get the location from mtl_material_transactions
            BEGIN
              l_progress  := '37';

              -- use Nvl to make sure if coordinates not defined, use 0
              SELECT NVL(loc.x_coordinate, 0)
                   , NVL(loc.y_coordinate, 0)
                   , NVL(loc.z_coordinate, 0)
                INTO l_cur_x
                   , l_cur_y
                   , l_cur_z
                FROM mtl_item_locations loc, mtl_material_transactions mmt
               WHERE mmt.locator_id = loc.inventory_location_id
                 AND mmt.organization_id = loc.organization_id
                 AND mmt.transaction_set_id = l_last_task_id
                 AND ROWNUM = 1;

              l_progress  := '38';
            EXCEPTION
              WHEN OTHERS THEN
                -- locator definition descripency
                l_cur_x  := 0;
                l_cur_y  := 0;
                l_cur_z  := 0;
            END;
          ELSE -- l_last_task_type <> 3  (Cyclt Count task) hence get the location from mtl_cycle_count_entries
            BEGIN
              l_progress  := '39';

              -- use Nvl to make sure if coordinates not defined, use 0
              SELECT NVL(loc.x_coordinate, 0)
                   , NVL(loc.y_coordinate, 0)
                   , NVL(loc.z_coordinate, 0)
                INTO l_cur_x
                   , l_cur_y
                   , l_cur_z
                FROM mtl_item_locations loc, mtl_cycle_count_entries mcce
               WHERE mcce.locator_id = loc.inventory_location_id
                 AND mcce.organization_id = loc.organization_id
                 AND mcce.cycle_count_entry_id = l_last_task_id;

              l_progress  := '40';
            EXCEPTION
              WHEN OTHERS THEN              -- adf
                               -- locator definition descripency
                l_cur_x  := 0;
                l_cur_y  := 0;
                l_cur_z  := 0;
            END;
          END IF; -- l_last_task_type <> 3
        END IF; -- l_last_task_is_drop <> TRUE
      ELSE -- there is not a previous task at all
        l_cur_x  := 0;
        l_cur_y  := 0;
        l_cur_z  := 0;
      END IF; -- l_last_task_id <> -1

      l_progress             := '45';

      -- Select the most optimal task
      -- first select eligible tasks according to employee sign on information
      -- order tasks by task priority, locator picking order and locator coordinates
      -- approximated to current locator
      IF (l_debug = 1) THEN
        print_debug('p_sign_on_emp_id => ' || p_sign_on_emp_id, 4);
        print_debug('p_sign_on_zone => ' || p_sign_on_zone, 4);
        print_debug('p_cartonization_id => ' || p_cartonization_id, 4);
        print_debug('l_sign_on_equipment_srl => ' || l_sign_on_equipment_srl, 4);
        print_debug('l_sign_on_equipment_id => ' || l_sign_on_equipment_id, 4);
        print_debug('l_cur_x => ' || l_cur_x, 4);
        print_debug('l_cur_y => ' || l_cur_y, 4);
        print_debug('l_cur_z => ' || l_cur_z, 4);
      END IF;

      fnd_profile.get('WMS_SEQUENCE_PICKS_ACROSS_WAVES', l_sequence_picks_across_waves);

      IF l_sequence_picks_across_waves IS NULL THEN
          l_sequence_picks_across_waves  := 2;
      END IF;


      -----------------------------------
      IF G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL THEN
         IF (l_debug = 1) THEN print_debug('PATCHSET J APL START',4); END IF;
          -- Populate the task filter variables
          IF (l_debug = 1) THEN
         print_debug('Task Filter: ' || p_task_filter, 9);
           END IF;

           FOR task_filter_rec IN c_task_filter(p_task_filter) LOOP

           IF (l_debug = 1) THEN
               print_debug('Task Filter Source: ' || task_filter_rec.task_filter_source, 9);
               print_debug('Task Filter Value: ' || task_filter_rec.task_filter_value, 9);
           END IF;

           IF task_filter_rec.task_filter_value = 'Y' THEN
               IF task_filter_rec.task_filter_source = 1 THEN -- Internal Order
                  l_io_allowed        := 1;
               ELSIF task_filter_rec.task_filter_source = 5 THEN -- Sales Order
                  l_so_allowed        := 1;
               ELSIF task_filter_rec.task_filter_source = 6 THEN -- Work Order
                  l_wip_allowed       := 1;
               END IF;
           END IF;

           END LOOP;


           IF (l_debug = 1) THEN
               print_debug('l_so_allowed: ' || l_so_allowed, 9);
               print_debug('l_io_allowed: ' || l_io_allowed, 9);
               print_debug('l_wip_allowed: ' || l_wip_allowed, 9);
          END IF;

          IF l_wip_allowed = 1 THEN
       If l_so_allowed = 1 or l_io_allowed = 1 then -- any of the three types
          IF p_sign_on_zone IS NOT NULL THEN
          open l_cp_ordered_tasks_SIW;
          ELSE OPEN l_cp_ordered_tasks_no_sub_SIW;
          END IF;
       ELSE -- only WIP
          IF p_sign_on_zone IS NOT NULL THEN
          open l_cp_ordered_tasks_W;
          ELSE OPEN l_cp_ordered_tasks_no_sub_W;
          END IF;
       END IF;
          ELSE -- only SO or IO
              IF p_sign_on_zone IS NOT NULL THEN
              open l_cp_ordered_tasks_SI;
         ELSE OPEN l_cp_ordered_tasks_no_sub_SI;
         END IF;
          END IF;

          IF (l_debug = 1) THEN print_debug('PATCHSET J APL END',4); END IF;
      ELSE -- below patchset J
      ---------------------------------------
      --  END of patchset J APL

     IF p_sign_on_zone IS NOT NULL THEN -- bug 2648133
              OPEN l_cp_curs_ordered_tasks;
     ELSE
              OPEN l_cp_curs_ordered_tasks_no_sub;
     END IF;
      END IF;
      l_progress             := '50';
      --l_first_task_pick_slip_number := -1;
      l_ordered_tasks_count  := 0;

      LOOP -- Loop for looping through the pending eligible tasks
        IF (l_debug = 1) THEN
          print_debug('Start looping through ordered tasks: ', 4);
        END IF;

        t_opt_task_id    := NULL;
        --l_opt_task_pick_slip := NULL;
        t_opt_task_type  := NULL;
        l_is_locked      := FALSE;
        l_progress       := '55';

        IF G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL THEN
       IF (l_debug = 1) THEN print_debug('PATCHSET J APL START',4); END IF;
       IF l_wip_allowed = 1 THEN
      If l_so_allowed = 1 or l_io_allowed = 1 then -- any of the three types
          IF p_sign_on_zone IS NOT NULL THEN
              EXIT WHEN l_cp_ordered_tasks_SIW%NOTFOUND;
         FETCH l_cp_ordered_tasks_SIW BULK COLLECT INTO t_opt_task_id
                  , t_carton_grouping_id
                  , t_opt_task_type
                  , t_cluster_id
                  , t_cluster_type
                  , t_task_priority
                  , t_sub_code
                  , t_sub_picking_order
                  , t_loc_picking_order
                  , t_xyz_distance
                                 , t_loc_concat_segs
                                 , t_task_Status
                                 , t_batch_id
                                 , t_effective_start_date
                                 , t_effective_end_date
                                 , t_person_resource_id
                                 , t_machine_resource_id LIMIT blk_limit;

          ELSE
              EXIT WHEN l_cp_ordered_tasks_no_sub_SIW%NOTFOUND;
         FETCH l_cp_ordered_tasks_no_sub_SIW BULK COLLECT INTO t_opt_task_id
             , t_carton_grouping_id
             , t_opt_task_type
             , t_cluster_id
             , t_cluster_type
             , t_task_priority
             , t_sub_code
             , t_sub_picking_order
             , t_loc_picking_order
             , t_xyz_distance
                                 , t_loc_concat_segs
                                 , t_task_Status
                                 , t_batch_id
                                 , t_effective_start_date
                                 , t_effective_end_date
                                 , t_person_resource_id
                                 , t_machine_resource_id LIMIT blk_limit;

          END IF;
      ELSE -- only WIP
          IF p_sign_on_zone IS NOT NULL THEN
              EXIT WHEN l_cp_ordered_tasks_W%NOTFOUND;
         FETCH l_cp_ordered_tasks_W BULK COLLECT INTO t_opt_task_id
                  , t_carton_grouping_id
                  , t_opt_task_type
                  , t_cluster_id
                  , t_cluster_type
                  , t_task_priority
                  , t_sub_code
                  , t_sub_picking_order
                  , t_loc_picking_order
                  , t_xyz_distance
                                 , t_loc_concat_segs
                                 , t_task_Status
                                 , t_batch_id
                                 , t_effective_start_date
                                 , t_effective_end_date
                                 , t_person_resource_id
                                 , t_machine_resource_id LIMIT blk_limit;

          ELSE
              EXIT WHEN l_cp_ordered_tasks_no_sub_W%NOTFOUND;
         FETCH l_cp_ordered_tasks_no_sub_W BULK COLLECT INTO t_opt_task_id
             , t_carton_grouping_id
             , t_opt_task_type
             , t_cluster_id
             , t_cluster_type
             , t_task_priority
             , t_sub_code
             , t_sub_picking_order
             , t_loc_picking_order
             , t_xyz_distance
                                 , t_loc_concat_segs
                                 , t_task_Status
                                 , t_batch_id
                                 , t_effective_start_date
                                 , t_effective_end_date
                                 , t_person_resource_id
                                 , t_machine_resource_id LIMIT blk_limit;

          END IF;
      END IF;
       ELSE -- only SO or IO
           IF p_sign_on_zone IS NOT NULL THEN
              EXIT WHEN l_cp_ordered_tasks_SI%NOTFOUND;
         FETCH l_cp_ordered_tasks_SI BULK COLLECT INTO t_opt_task_id
                  , t_carton_grouping_id
                  , t_opt_task_type
                  , t_cluster_id
                  , t_cluster_type
                  , t_task_priority
                  , t_sub_code
                  , t_sub_picking_order
                  , t_loc_picking_order
                  , t_xyz_distance
                                 , t_loc_concat_segs
                                 , t_task_Status
                                 , t_batch_id
                                 , t_effective_start_date
                                 , t_effective_end_date
                                 , t_person_resource_id
                                 , t_machine_resource_id LIMIT blk_limit;

           ELSE
              EXIT WHEN l_cp_ordered_tasks_no_sub_SI%NOTFOUND;
         FETCH l_cp_ordered_tasks_no_sub_SI BULK COLLECT INTO t_opt_task_id
             , t_carton_grouping_id
             , t_opt_task_type
             , t_cluster_id
             , t_cluster_type
             , t_task_priority
             , t_sub_code
             , t_sub_picking_order
             , t_loc_picking_order
             , t_xyz_distance
                                 , t_loc_concat_segs
                                 , t_task_Status
                                 , t_batch_id
                                 , t_effective_start_date
                                 , t_effective_end_date
                                 , t_person_resource_id
                                 , t_machine_resource_id LIMIT blk_limit;
      END IF;
       END IF;

       IF (l_debug = 1) THEN print_debug('PATCHSET J APL END',4); END IF;
        ELSE -- below patchset J
        IF p_sign_on_zone IS NOT NULL THEN -- bug 2648133
          EXIT WHEN l_cp_curs_ordered_tasks%NOTFOUND;
          FETCH l_cp_curs_ordered_tasks BULK COLLECT INTO t_opt_task_id
         , t_carton_grouping_id
         , t_opt_task_type
         , t_cluster_id
         , t_cluster_type
         , t_task_priority
         , t_sub_code
         , t_sub_picking_order
         , t_loc_picking_order
         , t_xyz_distance
         , t_loc_concat_segs LIMIT blk_limit;
        ELSE --sign on zone is null
          EXIT WHEN l_cp_curs_ordered_tasks_no_sub%NOTFOUND;
          FETCH l_cp_curs_ordered_tasks_no_sub BULK COLLECT INTO t_opt_task_id
         , t_carton_grouping_id
         , t_opt_task_type
         , t_cluster_id
         , t_cluster_type
         , t_task_priority
         , t_sub_code
         , t_sub_picking_order
         , t_loc_picking_order
         , t_xyz_distance
         , t_loc_concat_segs LIMIT blk_limit;
        END IF;
        END IF; -- end the patchset J checking

        l_progress       := '60';

        FOR idx IN 1 .. t_opt_task_id.COUNT LOOP -- looping through the current batch of tasks
          IF (l_debug = 1) THEN
            print_debug('l_opt_task_id         => ' || t_opt_task_id(idx), 4);
            print_debug('l_carton_grouping_id  => ' || t_carton_grouping_id(idx), 4);
            print_debug('l_opt_task_type       => ' || t_opt_task_type(idx), 4);
            print_debug('l_cluster_id          => ' || t_cluster_id(idx), 4);
            print_debug('l_cluster_type        => ' || t_cluster_type(idx), 4);
          END IF;

          BEGIN
            l_cluster_exists  := FALSE;
            l_progress        := '61';

            FOR i IN 1 .. cluster_table.COUNT LOOP -- Check whether the cluster exists already in the cluster table
              IF (cluster_table(i).cluster_id = t_cluster_id(idx)
                  AND cluster_table(i).cluster_type = t_cluster_type(idx)) THEN
                -- This cluster had been already dispatched in this session
                l_cluster_exists  := TRUE;
                EXIT;
              END IF;
            END LOOP;

            l_progress        := '62';
          END;

          l_progress  := '63';

          IF t_cluster_id(idx) IS NOT NULL THEN -- dispatch tasks only if cluster exists
            IF l_cluster_exists THEN --  Cluster already exists so dispatch this task too.
              IF (l_debug = 1) THEN
                print_debug(' Cluster already exists so dispatching this task too', 4);
              END IF;

              -- Test if this task is locked by any other user
              BEGIN
                SELECT     mmtt.transaction_temp_id
                      INTO t_opt_task_id(idx)
                      FROM mtl_material_transactions_temp mmtt
                     WHERE mmtt.transaction_temp_id = t_opt_task_id(idx)
                FOR UPDATE NOWAIT;
              EXCEPTION
                WHEN OTHERS THEN
                  IF (l_debug = 1) THEN
                    print_debug('This task is locked by other user. ', 4);
                  END IF;

                  l_is_locked  := TRUE;
              END;

              IF l_is_locked <> TRUE THEN
                l_ordered_tasks_count  := l_ordered_tasks_count + 1;

                --l_first_task_pick_slip_number := l_opt_task_pick_slip;

                IF (l_debug = 1) THEN
                  print_debug(
                    'This task has the same cluster details of already dispatched task. l_ordered_tasks_count => ' || l_ordered_tasks_count
                  , 4
                  );
                END IF;

                l_progress             := '72';
                -- check if this is queued task or not
                IF G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL THEN
                    IF (l_debug = 1) THEN
                        print_debug('Insert task '||t_opt_task_id(idx)||' Effective start date'||t_effective_start_date(idx),4);
                    END IF;
                    INSERT INTO wms_ordered_tasks
                            (
                             task_id
                           , wms_task_type
                           , task_sequence_id
                           , effective_start_date
                           , effective_end_date
                           , person_resource_id
                           , machine_resource_id
                            )
                     VALUES (
                             t_opt_task_id(idx)
                           , t_opt_task_type(idx)
                           , l_ordered_tasks_count
                           , t_effective_start_date(idx)
                           , t_effective_end_date(idx)
                           , t_person_resource_id(idx)
                           , t_machine_resource_id(idx)
                            );
                ELSE -- before patchset J
                      INSERT INTO wms_ordered_tasks
                              (
                               task_id
                             , wms_task_type
                             , task_sequence_id
                              )
                       VALUES (
                               t_opt_task_id(idx)
                             , t_opt_task_type(idx)
                             , l_ordered_tasks_count
                              );
               END IF;

                l_progress             := '73';
              END IF;
            ELSE -- Cluster Doesn't Exist
              IF (l_debug = 1) THEN
                print_debug(' Cluster doesnot exists, so a new task', 4);
              END IF;

              IF l_cluster_count < p_max_clusters THEN -- Maximum clusters not reached and hence can dispatch the task from this cluster
                IF (l_debug = 1) THEN
                  print_debug(' Max Cluster not reached hence can dispatch this cluster  ', 4);
                END IF;

                -- Test if this task is locked by any other user
                BEGIN
                  SELECT     mmtt.transaction_temp_id
                        INTO t_opt_task_id(idx)
                        FROM mtl_material_transactions_temp mmtt
                       WHERE mmtt.transaction_temp_id = t_opt_task_id(idx)
                  FOR UPDATE NOWAIT;
                EXCEPTION
                  WHEN OTHERS THEN
                    IF (l_debug = 1) THEN
                      print_debug('This task is locked by other user. ', 4);
                    END IF;

                    l_is_locked  := TRUE;
                END;

                IF l_is_locked <> TRUE THEN
                  l_ordered_tasks_count                        := l_ordered_tasks_count + 1;

                  IF (l_debug = 1) THEN
                    print_debug('This task is from a new cluster. l_ordered_tasks_count => ' || l_ordered_tasks_count, 4);
                  END IF;

                  l_progress                                   := '74';

                  -- check if this is queued task or not
        IF G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL THEN
                    IF (l_debug = 1) THEN
                        print_debug('Insert task '||t_opt_task_id(idx)||' Effective start date'||
                                     t_effective_start_date(idx),4);
                    END IF;
                    INSERT INTO wms_ordered_tasks
                            (
                             task_id
                           , wms_task_type
                           , task_sequence_id
                           , effective_start_date
                           , effective_end_date
                           , person_resource_id
                           , machine_resource_id
                            )
                     VALUES (
                             t_opt_task_id(idx)
                           , t_opt_task_type(idx)
                           , l_ordered_tasks_count
                           , t_effective_start_date(idx)
                           , t_effective_end_date(idx)
                           , t_person_resource_id(idx)
                           , t_machine_resource_id(idx)
                            );
                  ELSE -- before patchset J
                      INSERT INTO wms_ordered_tasks
                              (
                               task_id
                             , wms_task_type
                             , task_sequence_id
                              )
                       VALUES (
                               t_opt_task_id(idx)
                             , t_opt_task_type(idx)
                             , l_ordered_tasks_count
                              );
                  END IF;

                  l_progress                                   := '75';

                  IF t_cluster_type(idx) = 'D' THEN
                    l_deliveries_list  := l_deliveries_list || ', ' || t_cluster_id(idx);

                    IF (l_debug = 1) THEN
                      print_debug(' building deliveries list ' || l_deliveries_list, 4);
                    END IF;

                    IF t_carton_grouping_id(idx) IS NOT NULL THEN
                      l_cartons_list  := l_cartons_list || ', ' || t_carton_grouping_id(idx);

                      IF (l_debug = 1) THEN
                        print_debug(' deliveries exists still building cartons list ' || l_cartons_list, 4);
                      END IF;
                    END IF;
                  ELSE
                    l_cartons_list  := l_cartons_list || ', ' || t_cluster_id(idx);

                    IF (l_debug = 1) THEN
                      print_debug(' building cartons list ' || l_cartons_list, 4);
                    END IF;
                  END IF;

                  --Increase the clusters dispatched count
                  l_cluster_count                              := l_cluster_count + 1;
                  --Store this cluster details in the cluster_table
                  cluster_table(l_cluster_count).cluster_id    := t_cluster_id(idx);
                  cluster_table(l_cluster_count).cluster_type  := t_cluster_type(idx);
                END IF;
              ELSE -- Maxmimum Clusters reached, hence can't dispatch this task so ignore it.
                IF (l_debug = 1) THEN
                  print_debug('Max Clusters reached and hence ignoring this task ', 4);
                END IF;

                NULL;
              END IF;
            END IF;
          END IF;
        END LOOP; -- bulk collect loop
      END LOOP; -- task dispatching loop

      IF l_deliveries_list IS NOT NULL THEN --append the starting and ending braces to deliveries list
        l_deliveries_list  := '( -999 ' || l_deliveries_list || ' ) ';

        IF (l_debug = 1) THEN
          print_debug(' final deliveries list ' || l_deliveries_list, 4);
        END IF;

        x_deliveries_list  := l_deliveries_list;
      END IF;

      IF l_cartons_list IS NOT NULL THEN --append the starting and ending braces to cartons list
        l_cartons_list  := '( -999 ' || l_cartons_list || ' ) ';

        IF (l_debug = 1) THEN
          print_debug(' final cartons list ' || l_cartons_list, 4);
        END IF;

        x_cartons_list  := l_cartons_list;
      END IF;

      IF G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL THEN
         IF (l_debug = 1) THEN print_debug('PATCHSET J APL START',4); END IF;
         IF l_wip_allowed = 1 THEN
             If l_so_allowed = 1 or l_io_allowed = 1 then -- any of the three types
                IF p_sign_on_zone IS NOT NULL THEN
                close l_cp_ordered_tasks_SIW;
                ELSE close l_cp_ordered_tasks_no_sub_SIW;
                END IF;
             ELSE -- only WIP
                IF p_sign_on_zone IS NOT NULL THEN
                close l_cp_ordered_tasks_W;
                ELSE close l_cp_ordered_tasks_no_sub_W;
                END IF;
             END IF;
         ELSE -- only SO or IO
              IF p_sign_on_zone IS NOT NULL THEN
                    close l_cp_ordered_tasks_SI;
               ELSE close l_cp_ordered_tasks_no_sub_SI;
               END IF;
         END IF;

         IF (l_debug = 1) THEN print_debug('PATCHSET J APL END',4); END IF;
      END IF;

      IF l_cp_curs_ordered_tasks%ISOPEN THEN
        CLOSE l_cp_curs_ordered_tasks;
      END IF;

      IF l_cp_curs_ordered_tasks_no_sub%ISOPEN THEN -- bug 2648133
        CLOSE l_cp_curs_ordered_tasks_no_sub;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('Total task dispatched: l_ordered_tasks_count => ' || l_ordered_tasks_count, 4);
      END IF;

      IF l_ordered_tasks_count = 0 THEN
        fnd_message.set_name('WMS', 'WMS_TASK_NO_ELIGIBLE_TASKS');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('dispatch_task - No eligible picking tasks ', 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      l_progress             := '90';
    END IF; -- end task type check if

            -- open reference cursor for this statement

    IF (l_debug = 1) THEN
      print_debug('dispatch_task 120 - before opeing ref cursor ', 4);
    END IF;

    l_progress       := '110';
    -- bug 2648133, changed to static SQL and query against base tables
    --OPEN x_task_cur FOR l_sql_stmt;
    OPEN x_task_cur FOR
      SELECT   mmtt.transaction_temp_id task_id
             , mmtt.subinventory_code ZONE
             , mmtt.locator_id locator_id
             , mmtt.revision revision
             , mmtt.transaction_uom transaction_uom
             , mmtt.transaction_quantity transaction_quantity
             , '' lot_number
             , mmtt.wms_task_type wms_task_type_id
             , mmtt.task_priority task_priority
             , mmtt.operation_plan_id,
          mmtt.standard_operation_id,
          wot.effective_start_date,
          wot.effective_end_date,
          wot.person_resource_id,
          wot.machine_resource_id,
          mmtt.move_order_line_id
          FROM mtl_material_transactions_temp mmtt, wms_ordered_tasks wot
         WHERE mmtt.wms_task_type IS NOT NULL
           AND mmtt.transaction_status = 2
           AND mmtt.transaction_temp_id = wot.task_id
           AND mmtt.transaction_temp_id > 0
      ORDER BY wot.task_sequence_id;
    l_progress       := '120';
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF l_cp_curs_ordered_tasks%ISOPEN THEN
        CLOSE l_cp_curs_ordered_tasks;
      END IF;

      IF l_cp_curs_ordered_tasks_no_sub%ISOPEN THEN -- bug 2648133
        CLOSE l_cp_curs_ordered_tasks_no_sub;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('dispatch_task:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF l_cp_curs_ordered_tasks%ISOPEN THEN
        CLOSE l_cp_curs_ordered_tasks;
      END IF;

      IF l_cp_curs_ordered_tasks_no_sub%ISOPEN THEN -- bug 2648133
        CLOSE l_cp_curs_ordered_tasks_no_sub;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('dispatch_task: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF l_cp_curs_ordered_tasks%ISOPEN THEN
        CLOSE l_cp_curs_ordered_tasks;
      END IF;

      IF l_cp_curs_ordered_tasks_no_sub%ISOPEN THEN -- bug 2648133
        CLOSE l_cp_curs_ordered_tasks_no_sub;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('WMS_Task_Dispatch_Engine.dispatch_task', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('dispatch_task: Other exception ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
  END dispatch_task; --overloaded dispatch_Task for cluster picking


  FUNCTION min_num(a NUMBER, b NUMBER)
    RETURN NUMBER IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (a <= b) THEN
      RETURN a;
    ELSE
      RETURN b;
    END IF;
  END min_num;

  PROCEDURE split_tasks(
    p_api_version                     NUMBER
  , p_move_order_header_id            NUMBER
  , p_commit                          VARCHAR2 := fnd_api.g_false
  , x_return_status        OUT NOCOPY VARCHAR2
  , x_msg_count            OUT NOCOPY NUMBER
  , x_msg_data             OUT NOCOPY VARCHAR2
  ) IS
    l_api_name            VARCHAR2(30)  := 'split_tasks';
    l_transaction_temp_id NUMBER;
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(400);
    l_progress            VARCHAR2(10);
    l_move_order_type     NUMBER;

    CURSOR task_list IS
      SELECT mmtt.transaction_temp_id
        FROM wms_cartonization_temp mmtt, mtl_txn_request_lines mol
       WHERE mmtt.move_order_line_id = mol.line_id
         AND mol.header_id = p_move_order_header_id;


    ---- Patchset J, bulk picking -------------
    CURSOR task_list_bulk IS
      SELECT mmtt.transaction_temp_id
        FROM wms_cartonization_temp mmtt
        WHERE
             mmtt.parent_line_id   is null     -- non bulked tasks
         OR mmtt.parent_line_id = mmtt.transaction_temp_id;   -- parent line only
   ---- End of Patchset J, bulk picking -------------


    l_debug               NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('Enter split_tasks 10 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    -- changed for patchset J bulk picking -----------
    IF p_move_order_header_id <> -1 THEN
    SELECT move_order_type
      INTO l_move_order_type
      FROM mtl_txn_request_headers
     WHERE header_id = p_move_order_header_id;

    if (l_debug = 1) then print_debug('Move order type:'||l_move_order_type,4);
    end if;
    ELSE
       -- IF (l_debug = 1) THEN print_debug('PATCHSET J-- BULK PICKING --START',4); END IF;
        l_move_order_type := G_MOVE_ORDER_PICK_WAVE;
        if (l_debug = 1) then print_debug('calling from the conconcurrent program for so ...',4);
                            --  print_debug('PATCHSET J-- BULK PICKING --END ',4);
                       end if;
    END IF;

    -- end of change for patchset J bulk picking ------------------

    l_progress       := '10';
    if G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
       l_move_order_type = G_MOVE_ORDER_PICK_WAVE THEN
        OPEN task_list_bulk;
    ELSE
        OPEN task_list;
    END IF;
    l_progress       := '20';

    LOOP
      l_progress  := '30';
      if G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL and
         l_move_order_type = G_MOVE_ORDER_PICK_WAVE THEN
         FETCH task_list_bulk INTO l_transaction_temp_id;
         EXIT WHEN task_list_bulk%NOTFOUND;
      else
          FETCH task_list INTO l_transaction_temp_id;
          EXIT WHEN task_list%NOTFOUND;
      end if;

      IF (l_debug = 1) THEN
        print_debug('split_tasks 20 split task with l_transaction_temp_id = ' || l_transaction_temp_id, 1);
      END IF;

      l_progress  := '40';
      split_task(
        p_api_version                => 1.0
      , p_task_id                    => l_transaction_temp_id
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF (l_debug = 1) THEN
          print_debug('split_tasks 30 - split_task RAISE FND_API.G_EXC_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        -- RAISE fnd_api.g_exc_error;
        -- in case of error for one task, should continue for another task
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF (l_debug = 1) THEN
          print_debug('split_tasks 40 - split_task RAISE FND_API.G_EXC_UNEXPECTED_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END LOOP;

    l_progress       := '50';
    if task_list_bulk%ISOPEN then
        CLOSE task_list_bulk;
    else
        CLOSE task_list;
    end if;
    l_progress       := '60';

    IF (l_debug = 1) THEN
      print_debug('split_tasks 50 complete' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('split_tasks:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('split_tasks: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('WMS_Task_Dispatch_Engine.split_tasks', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('split_tasks: Other exception ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
  END split_tasks;

  FUNCTION is_equipment_cap_exceeded(
    p_standard_operation_id IN NUMBER
  , p_item_id               IN NUMBER
  , p_organization_id       IN NUMBER
  , p_txn_qty               IN NUMBER
  , p_txn_uom_code          IN VARCHAR2
  )
    RETURN VARCHAR2 IS
    l_item_prim_uom_code VARCHAR2(3);
    l_txn_pri_uom_ratio  NUMBER;
    l_equip_vol          NUMBER;
    l_equip_weight       NUMBER;
    l_item_vol           NUMBER;
    l_item_weight        NUMBER;
    l_equip_v_uom        VARCHAR2(3);
    l_equip_w_uom        VARCHAR2(3);
    l_item_v_uom         VARCHAR2(3);
    l_item_w_uom         VARCHAR2(3);
    l_eq_it_v_uom_ratio  NUMBER;
    l_eq_it_w_uom_ratio  NUMBER;
    l_min_cap            NUMBER       := -1;
    l_min_cap_temp       NUMBER;
    l_progress           VARCHAR2(10);

    CURSOR l_capcity_cur IS
      SELECT equip.internal_volume equip_vol
           , -- equipment volume capacity
             equip.maximum_load_weight equip_weight
           , -- equipment weight capacity
             item.unit_volume item_vol
           , -- item unit volume
             item.unit_weight item_weight
           , -- item unit weight
             equip.volume_uom_code equip_v_uom
           , -- equipment volumn UOM code
             equip.weight_uom_code equip_w_uom
           , -- equipment weight UOM code
             item.volume_uom_code item_v_uom
           , -- item volume UOM code
             item.weight_uom_code item_w_uom -- item weight UOM code
        FROM mtl_system_items equip
           , mtl_system_items item
           , bom_resource_equipments res_equip
           , bom_resources res
           , bom_std_op_resources tt_x_res
       WHERE tt_x_res.standard_operation_id = p_standard_operation_id --join task with task_type-resource x-ref
         AND tt_x_res.resource_id = res.resource_id -- join with resource
         AND res.resource_type = 1 -- resource type for equipment
         AND res_equip.resource_id = tt_x_res.resource_id -- join with resource-equip x-ref
         AND equip.inventory_item_id = res_equip.inventory_item_id -- join with equipment (mtl_system_items)
         AND equip.organization_id = res_equip.organization_id
         AND item.inventory_item_id = p_item_id -- join with item for the item that is transfered
         AND item.organization_id = p_organization_id;

    l_debug              NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Enter is_equipment_cap_exceeded 10 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress  := '10';

    SELECT primary_uom_code
      INTO l_item_prim_uom_code
      FROM mtl_system_items
     WHERE inventory_item_id = p_item_id
       AND organization_id = p_organization_id;

    -- compute conversion rate between transaction UOM and item primary UOM
    inv_convert.inv_um_conversion(from_unit => p_txn_uom_code, to_unit => l_item_prim_uom_code, item_id => p_item_id
    , uom_rate                     => l_txn_pri_uom_ratio);

    IF l_txn_pri_uom_ratio = -99999 THEN -- uom conversion failure
      IF (l_debug = 1) THEN
        print_debug('is_equipment_cap_exceeded 20 - txn/item uom ratio calculation failed' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      RETURN 'N';
    END IF;

    IF (l_debug = 1) THEN
      print_debug('is_equipment_cap_exceeded 30 - UOM conversion data:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    IF (l_debug = 1) THEN
      print_debug('l_txn_pri_uom_ratio => ' || l_txn_pri_uom_ratio, 4);
    END IF;

    -- Query minimum equipment capacity in terms of transaction UOM
    -- The minimum of the volumn and weight capacity is used
    -- If no equipment capacity or item unit volumn or weight defined,
    -- do not split
    -- NEED FURTHER consideration for container item:
    -- should check unit volume and content weight ???

    l_progress  := '20';
    OPEN l_capcity_cur;
    l_progress  := '30';

    LOOP
      l_progress  := '40';
      FETCH l_capcity_cur INTO l_equip_vol, l_equip_weight, l_item_vol, l_item_weight, l_equip_v_uom, l_equip_w_uom, l_item_v_uom
     , l_item_w_uom;
      l_progress  := '50';
      EXIT WHEN l_capcity_cur%NOTFOUND;
      -- get the conversion ratio between equipment and item volume UOM
      inv_convert.inv_um_conversion(from_unit => l_equip_v_uom, to_unit => l_item_v_uom, item_id => 0, uom_rate => l_eq_it_v_uom_ratio);

      IF l_eq_it_v_uom_ratio = -99999 THEN -- uom conversion failure
        IF (l_debug = 1) THEN
          print_debug('is_equipment_cap_exceeded 40 - eqp/item volume uom ratio calculation failed'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4);
        END IF;
      END IF;

      -- get the conversion ratio between equipment and item weight UOM
      inv_convert.inv_um_conversion(from_unit => l_equip_w_uom, to_unit => l_item_w_uom, item_id => 0, uom_rate => l_eq_it_w_uom_ratio);

      IF l_eq_it_w_uom_ratio = -99999 THEN -- uom conversion failure
        IF (l_debug = 1) THEN
          print_debug('is_equipment_cap_exceeded 50 - eqp/item weight uom ratio calculation failed'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4);
        END IF;
      END IF;
      --Bug 8800509 Start of code addition
      --volume for both item and equipment are defined
      IF (l_equip_vol IS NOT NULL AND l_item_vol IS NOT NULL AND l_eq_it_v_uom_ratio <> -99999) THEN
	--weight for both item and equip are defined
	IF (l_equip_weight IS NOT NULL AND l_item_weight IS NOT NULL AND l_eq_it_w_uom_ratio <> -99999) THEN
		--both weight and voulme are defined for item and equip
		--calculate based on both

		IF (l_debug = 1) THEN
		    print_debug('split_task 70.1, both weight and voulme are defined for item and equip, calculate equipment capacity based on both weight and volume',4);
	        END IF;

		l_min_cap_temp  := TRUNC(min_num((l_equip_vol * l_eq_it_v_uom_ratio / l_item_vol),(l_equip_weight * l_eq_it_w_uom_ratio / l_item_weight))/ l_txn_pri_uom_ratio);
		--
	        -- Start FP Bug 4634596
                --
	        IF (l_min_cap_temp = 0) THEN
		   l_min_cap_temp :=  min_num((l_equip_vol * l_eq_it_v_uom_ratio /l_item_vol),(l_equip_weight * l_eq_it_w_uom_ratio / l_item_weight)) / l_txn_pri_uom_ratio;
	        END IF;
	ELSE
		--only volume is defined for item and equip
		--calculate equipment capacity based on volume only
		IF (l_debug = 1) THEN
		    print_debug('split_task 70.1, only voulme defined for item and equip, calculate equipment capacity based on volume',4);
	        END IF;
		l_min_cap_temp  := TRUNC((l_equip_vol * l_eq_it_v_uom_ratio / l_item_vol) / l_txn_pri_uom_ratio);
	        --
		-- Start FP Bug 4634596
		--
	        IF (l_min_cap_temp = 0) THEN
		   l_min_cap_temp  := (l_equip_vol * l_eq_it_v_uom_ratio / l_item_vol) / l_txn_pri_uom_ratio;
	        END IF;
		--
	        -- End FP Bug 4634596
		--
	END IF;
      --weight for both item and equipment are defined, but volume is not defined for one of them
      ELSIF (l_equip_weight IS NOT NULL AND l_item_weight IS NOT NULL AND l_eq_it_w_uom_ratio <> -99999) THEN
		--calculate based on weight only

		IF (l_debug = 1) THEN
		    print_debug('split_task 70.1, only weight defined for item and equip, calculate equipment capacity based on weight',4);
	        END IF;
		l_min_cap_temp  := TRUNC((l_equip_weight * l_eq_it_w_uom_ratio / l_item_weight) / l_txn_pri_uom_ratio);
	        --
		-- Start FP Bug 4634596
	        --
		IF (l_min_cap_temp = 0) THEN
	           l_min_cap_temp  := (l_equip_weight * l_eq_it_w_uom_ratio / l_item_weight) / l_txn_pri_uom_ratio;
		END IF;
	        --
		-- End FP Bug 4634596
	        --
      ELSE
	--throw error, as no capicity definition
	IF (l_debug = 1) THEN
          print_debug('split_task 80 - invalid capacity for a particulcar equipment' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;
      END IF;

      IF (l_debug = 1) THEN
            print_debug('split_task 1.6, l_min_cap'||l_min_cap,4);
            print_debug('split_task 1.6, l_min_cap_temp'|| l_min_cap_temp,4);
      END IF;

      IF (l_min_cap = -1)
           OR(l_min_cap > l_min_cap_temp) THEN
          l_min_cap  := l_min_cap_temp; -- get minimum capacity of all possible equipment
      END IF;
      --Bug 8800509 End of code addition

      --Bug 8800509 Start Commented out code
   /*   IF (l_equip_vol IS NOT NULL
          AND l_item_vol IS NOT NULL
          AND l_eq_it_v_uom_ratio <> -99999)
         OR(l_equip_weight IS NOT NULL
            AND l_item_weight IS NOT NULL
            AND l_eq_it_w_uom_ratio <> -99999) THEN
        IF l_eq_it_v_uom_ratio = -99999 THEN                                   -- invalid volume UOM conversion
                                             -- compute equipment capacity using weight
          l_min_cap_temp  := TRUNC((l_equip_weight * l_eq_it_w_uom_ratio / l_item_weight) / l_txn_pri_uom_ratio);
        ELSIF l_eq_it_w_uom_ratio = -9999 THEN                                       -- invalid weight conversion
                                               -- compute equipment capacity using volume
          l_min_cap_temp  := TRUNC((l_equip_vol * l_eq_it_v_uom_ratio / l_item_vol) / l_txn_pri_uom_ratio);
        ELSE     -- both weight and volume defined
             -- compute the minimum of volume capacity and weight capacity
             -- transfer the capacity to transaction UOM
          l_min_cap_temp  :=
            TRUNC(
                min_num((l_equip_vol * l_eq_it_v_uom_ratio / l_item_vol),(l_equip_weight * l_eq_it_w_uom_ratio / l_item_weight))
              / l_txn_pri_uom_ratio
            );
        END IF;

        IF (l_min_cap = -1)
           OR(l_min_cap > l_min_cap_temp) THEN
          l_min_cap  := l_min_cap_temp; -- get minimum capacity of all possible equipment
        END IF;
      ELSE -- neither of weight or volume capacity is properly defined
        IF (l_debug = 1) THEN
          print_debug('is_equipment_cap_exceeded 60 - invalid capacity for a particulcar equipment'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4);
        END IF;
      END IF;*/
      --Bug 8800509 Start Commented out code
    END LOOP;

    l_progress  := '60';
    CLOSE l_capcity_cur;
    l_progress  := '70';

    IF l_min_cap <= 0 THEN -- min capcity is not properly queried
      IF (l_debug = 1) THEN
        print_debug('is_equipment_cap_exceeded 70 - invalid capacity for a ALL equipment' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      RETURN 'N';
    ELSIF TRUNC(l_min_cap) < TRUNC(p_txn_qty) THEN
      IF (l_debug = 1) THEN
        print_debug('is_equipment_cap_exceeded 75 - equipment capacity exceeded' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      RETURN 'Y';
    ELSE
      IF (l_debug = 1) THEN
        print_debug('is_equipment_cap_exceeded 80 - equipment capacity not exceeded' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      RETURN 'N';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('WMS_Task_Dispatch_Engine.is_equipment_cap_exceeded', l_progress, SQLCODE);
      END IF;

      IF (l_debug = 1) THEN
        print_debug('is_equipment_cap_exceeded: Other exception ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RETURN 'N';
  END is_equipment_cap_exceeded;


  PROCEDURE consolidate_bulk_tasks(
    p_api_version          IN            NUMBER
  , p_commit               IN              VARCHAR2 := fnd_api.g_false
  , x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  , p_move_order_header_id IN            NUMBER
  ) IS
    l_new_txn_temp_id            NUMBER;
    l_last_update_date           DATE;
    l_last_updated_by            NUMBER;
    l_creation_date              DATE;
    l_created_by                 NUMBER;
    l_inventory_item_id          NUMBER;
    l_revision                   VARCHAR2(30);
    l_organization_id            NUMBER;
    l_subinventory_code          VARCHAR2(30);
    l_locator_id                 NUMBER;
    l_transaction_quantity       NUMBER;
    l_primary_quantity           NUMBER;
    l_sec_transaction_quantity NUMBER;
    l_transaction_uom            VARCHAR2(3);
    l_transaction_type_id        NUMBER;
    l_transaction_action_id      NUMBER;
    l_transaction_source_type_id NUMBER;
    l_transaction_date           DATE;
    l_acct_period_id             NUMBER;
    l_pick_slip_number           NUMBER;
    l_move_order_line_id         NUMBER;
    l_to_org_id                  NUMBER;
    l_to_sub                     VARCHAR2(30);
    l_to_loc_id                  NUMBER;
    l_wms_task_type              NUMBER;
    l_standard_operation_id      NUMBER;
    l_task_priority              NUMBER;
    l_cost_group_id              NUMBER;
    l_transaction_header_id      NUMBER;
    l_container_item_id          NUMBER;
    l_cartonization_id           NUMBER;
    l_operation_plan_id          NUMBER;
    l_carton_grouping_id         NUMBER;
    l_wms_task_status            NUMBER;

    l_parent_task_count          NUMBER       := 0;
    l_move_order_type            NUMBER;
    l_api_name                   VARCHAR2(30) := 'consolidate_bulk_tasks';
    l_primary_uom_code      VARCHAR2(3);
    l_sec_uom_code    VARCHAR2(3);
    l_lot_control_code      NUMBER;
    l_serial_control_code   NUMBER;
    l_serial_allocated_flag      VARCHAR2(1);

    CURSOR task_list IS
      SELECT   SYSDATE last_update_date
             , g_user_id last_updated_by
             , SYSDATE creation_date
             , g_user_id created_by
             , mmtt.inventory_item_id
             , mmtt.revision
             , mmtt.organization_id
             , mmtt.subinventory_code
             , mmtt.locator_id
             , SUM(mmtt.transaction_quantity)
             , SUM(mmtt.primary_quantity)
	     , SUM(mmtt.secondary_transaction_quantity)
	     , mmtt.transaction_uom
             , mmtt.transaction_type_id
             , mmtt.transaction_action_id
             , mmtt.transaction_source_type_id
             , MAX(mmtt.transaction_date)
             , MAX(mmtt.acct_period_id)
             , MIN(mmtt.pick_slip_number) -- the earliest created pick slip
             , MIN(mmtt.move_order_line_id) -- any line_id within this header
             , mmtt.transfer_organization
             , mmtt.transfer_subinventory
             , mmtt.transfer_to_location
             , mmtt.wms_task_type
             , mmtt.standard_operation_id
             , MAX(mmtt.task_priority)
             , mmtt.cost_group_id
             , MAX(mmtt.transaction_header_id)
             , mmtt.container_item_id
             , mmtt.cartonization_id
             , mmtt.operation_plan_id
        , mol.carton_grouping_id
        , mmtt.wms_task_status -- carry forward task status also for unreleased/pending statuses
             -- Bug 4584538
             , mmtt.item_primary_uom_code
	     , mmtt.secondary_uom_code
	     , mmtt.item_lot_control_code
             , mmtt.item_serial_control_code
             , mmtt.serial_allocated_flag
             -- Bug 4584538
          FROM wms_cartonization_temp mmtt, mtl_txn_request_lines mol
         WHERE mmtt.move_order_line_id = mol.line_id
           AND mol.header_id = p_move_order_header_id
           AND mmtt.wms_task_type NOT IN(5, 6)
           AND mmtt.allocated_lpn_id IS NULL -- if lpn allocated, no need to do consolidation
           AND( EXISTS(SELECT 1
                         FROM mtl_txn_request_headers moh, wsh_pick_grouping_rules spg
                        WHERE spg.pick_grouping_rule_id = moh.grouping_rule_id
                          AND spg.pick_method = '4'
                          AND moh.header_id = mol.header_id)
               OR EXISTS(SELECT 1
                           FROM mtl_system_items msi
                          WHERE msi.inventory_item_id = mmtt.inventory_item_id
			    AND msi.organization_id  = mmtt.organization_id  --8715667
                            AND msi.bulk_picked_flag = 'Y')
              )
           AND EXISTS ( SELECT 1 -- Only Consolidate Tasks for Plain item
                          FROM mtl_system_items msi2
                         WHERE msi2.inventory_item_id = mmtt.inventory_item_id
 			   AND msi2.organization_id  = mmtt.organization_id --8715667
                           AND msi2.lot_control_code = 1
                           AND(msi2.serial_number_control_code = 1
                               OR msi2.serial_number_control_code = 6))
      GROUP BY mmtt.inventory_item_id
             , mmtt.revision
             , mmtt.organization_id
             , mmtt.subinventory_code
             , mmtt.locator_id
             , mmtt.transaction_uom
             , mmtt.transaction_type_id
             , mmtt.transaction_action_id
             , mmtt.transaction_source_type_id
             , mmtt.transfer_organization
             , mmtt.transfer_subinventory
             , mmtt.transfer_to_location
             , mmtt.wms_task_type
             , mmtt.standard_operation_id
             , mmtt.cost_group_id
             , mmtt.container_item_id
             , mmtt.cartonization_id
             , mmtt.operation_plan_id
             , mol.carton_grouping_id -- only consolidate tasks with the same carton_grouping_id (hense delivery)
             , mmtt.wms_task_status
             -- Bug 4584538
             , mmtt.item_primary_uom_code
	     , mmtt.secondary_uom_code
	     , mmtt.item_lot_control_code
             , mmtt.item_serial_control_code
             , mmtt.serial_allocated_flag
             -- Bug 4584538
      HAVING SUM(mmtt.transaction_quantity) <> MIN(mmtt.transaction_quantity) -- make sure one line will not get consolidated
           AND 'Y' <> is_equipment_cap_exceeded(
                        mmtt.standard_operation_id
                      , mmtt.inventory_item_id
                      , mmtt.organization_id
                      , SUM(mmtt.transaction_quantity)
                      , mmtt.transaction_uom
                      ); -- make sure the consolidated quantity does not exceed minimum equipment capacity, this is to make sure a consolidated task will not be splitted later

    CURSOR task_list_wip IS
      SELECT   SYSDATE last_update_date
             , g_user_id last_updated_by
             , SYSDATE creation_date
             , g_user_id created_by
             , mmtt.inventory_item_id
             , mmtt.revision
             , mmtt.organization_id
             , mmtt.subinventory_code
             , mmtt.locator_id
             , SUM(mmtt.transaction_quantity)
             , SUM(mmtt.primary_quantity)
	     , SUM(mmtt.secondary_transaction_quantity)
	     , mmtt.transaction_uom
             , mmtt.transaction_type_id
             , mmtt.transaction_action_id
             , mmtt.transaction_source_type_id
             , MAX(mmtt.transaction_date)
             , MAX(mmtt.acct_period_id)
             , MIN(mmtt.pick_slip_number) -- the earliest created pick slip
             , MIN(mmtt.move_order_line_id) -- any line_id within this header
             , mmtt.transfer_organization
             , ''
             , NULL
             , mmtt.wms_task_type
             , mmtt.standard_operation_id
             , MAX(mmtt.task_priority)
             , mmtt.cost_group_id
             , MAX(mmtt.transaction_header_id)
             , mmtt.container_item_id
             , mmtt.cartonization_id
             , mmtt.operation_plan_id
        , NULL
        , mmtt.wms_task_status -- carry forward task status also for unreleased/pending statuses
             -- Bug 4584538
             , mmtt.item_primary_uom_code
	     , mmtt.secondary_uom_code
	     , mmtt.item_lot_control_code
             , mmtt.item_serial_control_code
             , mmtt.serial_allocated_flag
             -- Bug 4584538
          FROM wms_cartonization_temp mmtt, mtl_txn_request_lines mol
         WHERE mmtt.move_order_line_id = mol.line_id
           AND mol.header_id = p_move_order_header_id
           AND mmtt.wms_task_type NOT IN(5, 6)
           AND mmtt.allocated_lpn_id IS NULL -- if lpn allocated, no need to do consolidation
           AND( EXISTS(SELECT 1
                         FROM mtl_txn_request_headers moh, wsh_pick_grouping_rules spg
                        WHERE spg.pick_grouping_rule_id = moh.grouping_rule_id
                          AND spg.pick_method = '4'
                          AND moh.header_id = mol.header_id)
               OR EXISTS(SELECT 1
                           FROM mtl_system_items msi
                          WHERE msi.inventory_item_id = mmtt.inventory_item_id
		            AND msi.organization_id  = mmtt.organization_id --8715667
                            AND msi.bulk_picked_flag = 'Y')
              )
           AND EXISTS( SELECT 1 -- Only Consolidate Tasks for Plain item
                         FROM mtl_system_items msi2
                        WHERE msi2.inventory_item_id = mmtt.inventory_item_id
			  AND msi2.organization_id  = mmtt.organization_id --8715667
                          AND msi2.lot_control_code = 1
                          AND(msi2.serial_number_control_code = 1
                              OR msi2.serial_number_control_code = 6))
      GROUP BY mmtt.inventory_item_id
             , mmtt.revision
             , mmtt.organization_id
             , mmtt.subinventory_code
             , mmtt.locator_id
             , mmtt.transaction_uom
             , mmtt.transaction_type_id
             , mmtt.transaction_action_id
             , mmtt.transaction_source_type_id
             , mmtt.transfer_organization
             , mmtt.wms_task_type
             , mmtt.standard_operation_id
             , mmtt.cost_group_id
             , mmtt.container_item_id
             , mmtt.cartonization_id
             , mmtt.operation_plan_id
        , mmtt.wms_task_status
             -- Bug 4584538
             , mmtt.item_primary_uom_code
	     , mmtt.secondary_uom_code
	     , mmtt.item_lot_control_code
             , mmtt.item_serial_control_code
             , mmtt.serial_allocated_flag
             -- Bug 4584538
      HAVING   SUM(mmtt.transaction_quantity) <> MIN(mmtt.transaction_quantity) -- make sure one line will not get consolidated
             AND 'Y' <> is_equipment_cap_exceeded(
                        mmtt.standard_operation_id
                      , mmtt.inventory_item_id
                      , mmtt.organization_id
                      , SUM(mmtt.transaction_quantity)
                      , mmtt.transaction_uom
                      ); -- make sure the consolidated quantity does not exceed minimum equipment capacity, this is to make sure a consolidated task will not be splitted later

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Consolidating Tasks for MO Header ID = ' || p_move_order_header_id, 4);
    END IF;

    SAVEPOINT sp_consolidate_bulk_task;

    x_return_status  := fnd_api.g_ret_sts_success;

    SELECT move_order_type
      INTO l_move_order_type
      FROM mtl_txn_request_headers
     WHERE header_id = p_move_order_header_id;

    IF l_move_order_type = g_move_order_mfg_pick THEN
      OPEN task_list_wip;
    ELSE
      OPEN task_list;
    END IF;

    LOOP
      IF l_move_order_type = g_move_order_mfg_pick THEN
        FETCH task_list_wip INTO l_last_update_date
                               , l_last_updated_by
                               , l_creation_date
                               , l_created_by
                               , l_inventory_item_id
                               , l_revision
                               , l_organization_id
                               , l_subinventory_code
                               , l_locator_id
                               , l_transaction_quantity
                               , l_primary_quantity
	                       , l_sec_transaction_quantity
	                       , l_transaction_uom
                               , l_transaction_type_id
                               , l_transaction_action_id
                               , l_transaction_source_type_id
                               , l_transaction_date
                               , l_acct_period_id
                               , l_pick_slip_number
                               , l_move_order_line_id
                               , l_to_org_id
                               , l_to_sub
                               , l_to_loc_id
                               , l_wms_task_type
                               , l_standard_operation_id
                               , l_task_priority
                               , l_cost_group_id
                               , l_transaction_header_id
                               , l_container_item_id
                               , l_cartonization_id
                               , l_operation_plan_id
                               , l_carton_grouping_id
                               , l_wms_task_status
                               -- Bug 4584538
                               , l_primary_uom_code
	                       , l_sec_uom_code
	                       , l_lot_control_code
                               , l_serial_control_code
                               , l_serial_allocated_flag;
                               -- Bug 4584538
        EXIT WHEN task_list_wip%NOTFOUND;
      ELSE
        FETCH task_list INTO  l_last_update_date
                            , l_last_updated_by
                            , l_creation_date
                            , l_created_by
                            , l_inventory_item_id
                            , l_revision
                            , l_organization_id
                            , l_subinventory_code
                            , l_locator_id
                            , l_transaction_quantity
                            , l_primary_quantity
	                    , l_sec_transaction_quantity
	                    , l_transaction_uom
                            , l_transaction_type_id
                            , l_transaction_action_id
                            , l_transaction_source_type_id
                            , l_transaction_date
                            , l_acct_period_id
                            , l_pick_slip_number
                            , l_move_order_line_id
                            , l_to_org_id
                            , l_to_sub
                            , l_to_loc_id
                            , l_wms_task_type
                            , l_standard_operation_id
                            , l_task_priority
                            , l_cost_group_id
                            , l_transaction_header_id
                            , l_container_item_id
                            , l_cartonization_id
                            , l_operation_plan_id
                            , l_carton_grouping_id
                            , l_wms_task_status
                            -- Bug 4584538
                            , l_primary_uom_code
	                    , l_sec_uom_code
	                    , l_lot_control_code
                            , l_serial_control_code
                            , l_serial_allocated_flag;
                            -- Bug 4584538
        EXIT WHEN task_list%NOTFOUND;
      END IF;

      l_parent_task_count  := l_parent_task_count + 1;
      --SELECT mtl_material_transactions_s.NEXTVAL INTO l_new_txn_temp_id FROM DUAL;

      IF (l_debug = 1) THEN
        print_debug('Creating a Parent Line with the values...', 4);
        print_debug('  --> Txn Header ID      => ' || l_transaction_header_id, 4);
--   print_debug('  --> Txn Temp ID        => ' || l_new_txn_temp_id, 4);
        print_debug('  --> Inventory Item ID  => ' || l_inventory_item_id, 4);
        print_debug('  --> Revision           => ' || l_revision, 4);
        print_debug('  --> Organization ID    => ' || l_organization_id, 4);
        print_debug('  --> SubInventory Code  => ' || l_subinventory_code, 4);
        print_debug('  --> Locator ID         => ' || l_locator_id, 4);
        print_debug('  --> To Organization ID => ' || l_to_org_id, 4);
        print_debug('  --> To SubInventory    => ' || l_to_sub, 4);
        print_debug('  --> To Locator ID      => ' || l_to_loc_id, 4);
        print_debug('  --> Transaction Qty    => ' || l_transaction_quantity, 4);
        print_debug('  --> Primary Qty        => ' || l_primary_quantity, 4);
        print_debug('  --> Transaction UOM    => ' || l_transaction_uom, 4);
        print_debug('  --> Txn Type ID        => ' || l_transaction_type_id, 4);
        print_debug('  --> Txn Action ID      => ' || l_transaction_action_id, 4);
        print_debug('  --> Txn Source Type ID => ' || l_transaction_source_type_id, 4);
        print_debug('  --> Txn Date           => ' || l_transaction_date, 4);
        print_debug('  --> Account Period     => ' || l_acct_period_id, 4);
        print_debug('  --> Pick Slip Number   => ' || l_pick_slip_number, 4);
        print_debug('  --> Move Order Line ID => ' || l_move_order_line_id, 4);
        print_debug('  --> Cost Group ID      => ' || l_cost_group_id, 4);
        print_debug('  --> Container Item ID  => ' || l_container_item_id, 4);
        print_debug('  --> Cartonization ID   => ' || l_cartonization_id, 4);
        print_debug('  --> Operation Plan Id  => ' || l_operation_plan_id, 4);
        print_debug('  --> Carton Grouping ID => ' || l_carton_grouping_id, 4);
        print_debug('  --> Task Status        => ' || l_wms_task_status, 4);
        print_debug('  --> Primary UOM Code   => ' || l_primary_uom_code, 4);
        print_debug('  --> Lot Control Code   => ' || l_lot_control_code, 4);
        print_debug('  --> Serial Control Code => ' || l_serial_control_code, 4);
        print_debug('  --> Serial Allocated Flag => ' || l_serial_allocated_flag, 4);
      END IF;

      INSERT INTO wms_cartonization_temp
                  (
                    transaction_header_id
                  , transaction_temp_id
                  , posting_flag
                  , transaction_status
                  , last_update_date
                  , last_updated_by
                  , creation_date
                  , created_by
                  , transaction_type_id
                  , transaction_action_id
                  , transaction_source_type_id
                  , organization_id
                  , inventory_item_id
                  , revision
                  , subinventory_code
                  , locator_id
                  , transfer_organization
                  , transfer_subinventory
                  , transfer_to_location
                  , transaction_quantity
                  , primary_quantity
		  , secondary_transaction_quantity
		  , transaction_uom
                  , transaction_date
                  , acct_period_id
                  , cost_group_id
                  -- , move_order_line_id   keep same as patchset J
                  , pick_slip_number
                  , standard_operation_id
                  , wms_task_type
                  , task_priority
                  , container_item_id
                  , cartonization_id
                  , operation_plan_id
                  , wms_task_status
                  , parent_line_id
                  -- Bug 4584538
                  , item_primary_uom_code
	          , secondary_uom_code
	          , item_lot_control_code
                  , item_serial_control_code
                  , serial_allocated_flag
                  -- Bug 4584538
                  )
           VALUES (
                    l_transaction_header_id
                  --, l_new_txn_temp_id
		  , mtl_material_transactions_s.NEXTVAL --Bug 5535030
                  , 'N'
                  , 2
                  , l_last_update_date
                  , l_last_updated_by
                  , l_creation_date
                  , l_created_by
                  , l_transaction_type_id
                  , l_transaction_action_id
                  , l_transaction_source_type_id
                  , l_organization_id
                  , l_inventory_item_id
                  , l_revision
                  , l_subinventory_code
                  , l_locator_id
                  , l_to_org_id
                  , l_to_sub
                  , l_to_loc_id
                  , l_transaction_quantity
                  , l_primary_quantity
		  , l_sec_transaction_quantity
		  , l_transaction_uom
                  , l_transaction_date
                  , l_acct_period_id
                  , l_cost_group_id
                  -- , l_move_order_line_id  keep same as patchset J
                  , l_pick_slip_number
                  , l_standard_operation_id
                  , l_wms_task_type
                  , l_task_priority
                  , l_container_item_id
                  , l_cartonization_id
                  , l_operation_plan_id
                  , l_wms_task_status
   --               , l_new_txn_temp_id      -- have the same as patchset J
		  , mtl_material_transactions_s.CURRVAL
                  -- Bug 4584538
                  , l_primary_uom_code
	          , l_sec_uom_code
	          , l_lot_control_code
                  , l_serial_control_code
                  , l_serial_allocated_flag
                  -- Bug 4584538
             ) RETURNING transaction_temp_id INTO l_new_txn_temp_id ;

       print_debug('  --> Txn Temp ID        => ' || l_new_txn_temp_id, 4);
      IF (l_debug = 1) THEN
        print_debug('Updating the Parent Line ID of the Tasks Consolidated', 4);
      END IF;

      UPDATE wms_cartonization_temp
         SET parent_line_id = l_new_txn_temp_id
       WHERE transaction_temp_id <> l_new_txn_temp_id
         AND inventory_item_id = l_inventory_item_id
         AND NVL(revision, '#$%') = NVL(l_revision, NVL(revision, '#$%'))
         AND organization_id = l_organization_id
         AND subinventory_code = l_subinventory_code
         AND NVL(locator_id, -1) = NVL(l_locator_id, NVL(locator_id, -1))
         AND NVL(transfer_organization, -1) = NVL(l_to_org_id, NVL(transfer_organization, -1))
         AND NVL(transfer_to_location, -1) = NVL(l_to_loc_id, NVL(transfer_to_location, -1))
         AND NVL(transfer_subinventory, '#$%') = NVL(l_to_sub, NVL(transfer_subinventory, '#$%'))
         AND transaction_uom = l_transaction_uom
         AND NVL(transaction_type_id, -1) = NVL(l_transaction_type_id, NVL(transaction_type_id, -1))
         AND NVL(transaction_action_id, -1) = NVL(l_transaction_action_id, NVL(transaction_action_id, -1))
         AND NVL(transaction_source_type_id, -1) = NVL(l_transaction_source_type_id, NVL(transaction_source_type_id, -1))
         AND NVL(cost_group_id, -1) = NVL(l_cost_group_id, NVL(cost_group_id, -1))
         AND NVL(container_item_id, -1) = NVL(l_container_item_id, NVL(container_item_id, -1))
         AND NVL(cartonization_id, -1) = NVL(l_cartonization_id, NVL(cartonization_id, -1))
         AND EXISTS(SELECT 1
                      FROM mtl_txn_request_lines mol
                     WHERE mol.line_id = move_order_line_id
                       AND mol.header_id = p_move_order_header_id
                       AND NVL(mol.carton_grouping_id,-1) = NVL(l_carton_grouping_id,NVL(mol.carton_grouping_id,-1)));

      IF (l_debug = 1) THEN
        print_debug('Number of Tasks consolidated into 1 Parent Task = ' || SQL%ROWCOUNT, 4);
      END IF;
    END LOOP;

    IF task_list%ISOPEN THEN
      CLOSE task_list;
    END IF;

    IF task_list_wip%ISOPEN THEN
      CLOSE task_list_wip;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('Number of Parent Tasks = ' || l_parent_task_count, 4);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO sp_consolidate_bulk_task;
      IF l_debug = 1 THEN
         print_debug('Exception Occurred = ' || SQLERRM,4);
      END IF;

      IF task_list%ISOPEN THEN
        CLOSE task_list;
      END IF;
      IF task_list_wip%ISOPEN THEN
        CLOSE task_list_wip;
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END consolidate_bulk_tasks;



 PROCEDURE consolidate_bulk_tasks_for_so(
    p_api_version          IN            NUMBER
  , p_commit               IN              VARCHAR2 := fnd_api.g_false
  , x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  , p_move_order_header_id IN            NUMBER
  ) IS
    l_new_txn_temp_id            NUMBER;
    l_last_update_date           DATE;
    l_last_updated_by            NUMBER;
    l_creation_date              DATE;
    l_created_by                 NUMBER;
    l_inventory_item_id          NUMBER;
    l_revision                   VARCHAR2(30);
    l_organization_id            NUMBER;
    l_subinventory_code          VARCHAR2(30);
    l_locator_id                 NUMBER;
    l_transaction_quantity       NUMBER;
    l_primary_quantity           NUMBER;
    l_sec_transaction_quantity NUMBER;
    l_transaction_uom            VARCHAR2(3);
    l_transaction_type_id        NUMBER;
    l_transaction_action_id      NUMBER;
    l_transaction_source_type_id NUMBER;
    l_transaction_date           DATE;
    l_acct_period_id             NUMBER;
    l_pick_slip_number           NUMBER;
    l_move_order_line_id         NUMBER;
    l_to_org_id                  NUMBER;
    l_to_sub                     VARCHAR2(30);
    l_to_loc_id                  NUMBER;
    l_wms_task_type              NUMBER;
    l_standard_operation_id      NUMBER;
    l_task_priority              NUMBER;
    l_cost_group_id              NUMBER;
    l_transaction_header_id      NUMBER;
    l_container_item_id          NUMBER;
    l_cartonization_id           NUMBER;
    l_operation_plan_id          NUMBER;
    l_carton_grouping_id         NUMBER;
    l_wms_task_status            NUMBER;

    l_parent_task_count          NUMBER       := 0;
    l_move_order_type            NUMBER;
    l_api_name                   VARCHAR2(30) := 'consolidate_bulk_tasks_for_so';
    l_delivery_flag              VARCHAR2(1);
    l_bulk_pick_control          NUMBER;

    -- *****************************
    -- the following cursor will be used when calling from pick release process for all items (plain, lot and lot/serial,serial...)
    -- task_list is to bulk the children within the delivery and task_list_cross_delivery is to bulk_task cross deliveries
    -- for performance purpose, two cursors are being defined here.
    --******************************
    CURSOR task_list IS
      SELECT   SYSDATE last_update_date
             , g_user_id last_updated_by
             , SYSDATE creation_date
             , g_user_id created_by
             , mmtt.inventory_item_id
             , mmtt.revision
             , mmtt.organization_id
             , mmtt.subinventory_code
             , mmtt.locator_id
             , SUM(mmtt.transaction_quantity)
             , SUM(mmtt.primary_quantity)
	     , SUM(mmtt.secondary_transaction_quantity)
	     , mmtt.transaction_uom
             , mmtt.transaction_type_id
             , mmtt.transaction_action_id
             , mmtt.transaction_source_type_id
             , MAX(mmtt.transaction_date)
             , MAX(mmtt.acct_period_id)
             , mmtt.transfer_organization
             , mmtt.wms_task_type
             , MAX(mmtt.task_priority)
             , mmtt.cost_group_id
             , MAX(mmtt.transaction_header_id)
             , mmtt.container_item_id
             , mmtt.operation_plan_id
        , mmtt.wms_task_status -- carry forward task status also for unreleased/pending statuses
        , nvl(wda.delivery_id, mol.carton_grouping_id)
        , mmtt.item_primary_uom_code
	, mmtt.secondary_uom_code
	, mmtt.item_lot_control_code
        , mmtt.item_serial_control_code
        , mmtt.serial_allocated_flag
          FROM wms_cartonization_temp mmtt, mtl_txn_request_lines mol,wsh_delivery_details_ob_grp_v wdd,wsh_delivery_assignments_v wda
         WHERE mmtt.move_order_line_id = mol.line_id
           -- AND mol.header_id = p_move_order_header_id -- no need since wct only have the records in concerns
           AND mol.line_id = wdd.move_ordeR_line_id
           AND wdd.delivery_detail_id = wda.delivery_detail_id
           AND mmtt.wms_task_type NOT IN(5, 6)
           AND mmtt.allocated_lpn_id IS NULL -- if lpn allocated, no need to do consolidation
           AND mmtt.cartonization_id is null -- only bulk non_cartoned lines
           AND ( mmtt.serial_allocated_flag = 'N'  -- do not bulk serial allocated lines
                 or mmtt.serial_allocated_flag is null)
           AND(l_bulk_pick_control = WMS_GLOBALS.BULK_PICK_ENTIRE_WAVE
          -- if bulk picking is not disabled and not pick entire wave only the honor sub/item is left, so no need to check l_bulk_pick_control, only need to check the sub/item  flag
          OR EXISTS(SELECT 1   -- sub is bulk picking enabled
                    FROM mtl_secondary_inventories msi
                    WHERE msi.secondary_inventory_name = mmtt.subinventory_code
                      AND msi.organization_id = mmtt.organization_id
                      AND msi.enable_bulk_pick= 'Y')
          OR EXISTS(SELECT 1   -- item is bulk picking enabled
                    FROM mtl_system_items msi
                    WHERE msi.inventory_item_id = mmtt.inventory_item_id
		      AND msi.organization_id  = mmtt.organization_id  --8715667
                      AND msi.bulk_picked_flag = 'Y')
          )
      GROUP BY mmtt.inventory_item_id
             , mmtt.revision
             , mmtt.organization_id
             , mmtt.subinventory_code
             , mmtt.locator_id
             , mmtt.transaction_uom
             , mmtt.transaction_type_id
             , mmtt.transaction_action_id
             , mmtt.transaction_source_type_id
             , mmtt.transfer_organization
             , mmtt.wms_task_type
             , mmtt.cost_group_id
             , mmtt.container_item_id
             , mmtt.operation_plan_id
             , nvl(wda.delivery_id, mol.carton_grouping_id) -- only consolidate tasks with the same carton_grouping_id (hense delivery) if the delivery is checked in the rule
             , mmtt.wms_task_status
             , mmtt.item_primary_uom_code
	     , mmtt.secondary_uom_code
	     , mmtt.item_lot_control_code
             , mmtt.item_serial_control_code
             , mmtt.serial_allocated_flag
      HAVING SUM(mmtt.transaction_quantity) <> MIN(mmtt.transaction_quantity) -- make sure one line will not get consolidated
           ;

        CURSOR task_list_cross_delivery IS
          SELECT   SYSDATE last_update_date
                 , g_user_id last_updated_by
                 , SYSDATE creation_date
                 , g_user_id created_by
                 , mmtt.inventory_item_id
                 , mmtt.revision
                 , mmtt.organization_id
                 , mmtt.subinventory_code
                 , mmtt.locator_id
                 , SUM(mmtt.transaction_quantity)
                 , SUM(mmtt.primary_quantity)
	         , SUM(mmtt.secondary_transaction_quantity)
	         , mmtt.transaction_uom
                 , mmtt.transaction_type_id
                 , mmtt.transaction_action_id
                 , mmtt.transaction_source_type_id
                 , MAX(mmtt.transaction_date)
                 , MAX(mmtt.acct_period_id)
                 , mmtt.transfer_organization
                 , mmtt.wms_task_type
                 , MAX(mmtt.task_priority)
                 , mmtt.cost_group_id
                 , MAX(mmtt.transaction_header_id)
                 , mmtt.container_item_id
                 , mmtt.operation_plan_id
                 , mmtt.wms_task_status -- carry forward task status also for unreleased/pending statuses
                 , mmtt.item_primary_uom_code
	         , mmtt.secondary_uom_code
	         , mmtt.item_lot_control_code
                 , mmtt.item_serial_control_code
                 , mmtt.serial_allocated_flag
              FROM wms_cartonization_temp mmtt
             WHERE
                   mmtt.wms_task_type NOT IN(5, 6)
               AND mmtt.allocated_lpn_id IS NULL -- if lpn allocated, no need to do consolidation
               AND mmtt.cartonization_id is null -- only bulk non_cartoned lines
                AND ( mmtt.serial_allocated_flag = 'N'  -- do not bulk serial allocated lines
                 or mmtt.serial_allocated_flag is null)
               AND(l_bulk_pick_control = WMS_GLOBALS.BULK_PICK_ENTIRE_WAVE
             -- if bulk picking is not disabled and not pick entire wave only the honor sub/item is left, so no need to check l_bulk_pick_control, only need to check the sub/item  flag
             OR EXISTS(SELECT 1   -- sub is bulk picking enabled
                       FROM mtl_secondary_inventories msi
                       WHERE msi.secondary_inventory_name = mmtt.subinventory_code
                         AND msi.organization_id = mmtt.organization_id
                         AND msi.enable_bulk_pick= 'Y')
             OR EXISTS(SELECT 1   -- item is bulk picking enabled
                       FROM mtl_system_items msi
                       WHERE msi.inventory_item_id = mmtt.inventory_item_id
			 AND msi.organization_id  = mmtt.organization_id  --8715667
                         AND msi.bulk_picked_flag = 'Y')
             )
          GROUP BY mmtt.inventory_item_id
                 , mmtt.revision
                 , mmtt.organization_id
                 , mmtt.subinventory_code
                 , mmtt.locator_id
                 , mmtt.transaction_uom
                 , mmtt.transaction_type_id
                 , mmtt.transaction_action_id
                 , mmtt.transaction_source_type_id
                 , mmtt.transfer_organization
                 , mmtt.wms_task_type
                 , mmtt.cost_group_id
                 , mmtt.container_item_id
                 , mmtt.operation_plan_id
                 , mmtt.wms_task_status
                 , mmtt.item_primary_uom_code
		 , mmtt.secondary_uom_code
		 , mmtt.item_lot_control_code
                 , mmtt.item_serial_control_code
                 , mmtt.serial_allocated_flag
         HAVING SUM(mmtt.transaction_quantity) <> MIN(mmtt.transaction_quantity); -- make sure one line will not get consolidated


    -- *****************************
    -- the following cursor will be used when calling from concurrent program for bulking
    -- task_list_con to bulk within delivery and task_list_con_cd to cross deliveries
    --******************************
         CURSOR task_list_con IS
           SELECT   SYSDATE last_update_date
                  , g_user_id last_updated_by
                  , SYSDATE creation_date
                  , g_user_id created_by
                  , mmtt.inventory_item_id
                  , mmtt.revision
                  , mmtt.organization_id
                  , mmtt.subinventory_code
                  , mmtt.locator_id
                  , SUM(mmtt.transaction_quantity)
                  , SUM(mmtt.primary_quantity)
	          , SUM(mmtt.secondary_transaction_quantity)
	          , mmtt.transaction_uom
                  , mmtt.transaction_type_id
                  , mmtt.transaction_action_id
                  , mmtt.transaction_source_type_id
                  , MAX(mmtt.transaction_date)
                  , MAX(mmtt.acct_period_id)
                  , mmtt.transfer_organization
                  , mmtt.wms_task_type
                  , MAX(mmtt.task_priority)
                  , mmtt.cost_group_id
                  , MAX(mmtt.transaction_header_id)
                  , mmtt.container_item_id
                  , mmtt.operation_plan_id
                , mmtt.wms_task_status -- carry forward task status also for unreleased/pending statuses
                , nvl(wda.delivery_id, mol.carton_grouping_id)
             , mmtt.item_primary_uom_code
	     , mmtt.secondary_uom_code
	     , mmtt.item_lot_control_code
             , mmtt.item_serial_control_code
             , mmtt.serial_allocated_flag
               FROM wms_cartonization_temp mmtt, mtl_txn_request_lines mol,
                    wsh_delivery_details_ob_grp_v wdd,wsh_delivery_assignments_v wda
               WHERE mmtt.move_order_line_id = mol.line_id
                AND ( mmtt.serial_allocated_flag = 'N'  -- do not bulk serial allocated lines
                      or mmtt.serial_allocated_flag is null)
           AND mol.line_id = wdd.move_ordeR_line_id
           AND wdd.delivery_Detail_id = wda.delivery_detail_id
           GROUP BY mmtt.inventory_item_id
                  , mmtt.revision
                  , mmtt.organization_id
                  , mmtt.subinventory_code
                  , mmtt.locator_id
                  , mmtt.transaction_uom
                  , mmtt.transaction_type_id
                  , mmtt.transaction_action_id
                  , mmtt.transaction_source_type_id
                  , mmtt.transfer_organization
                  , mmtt.wms_task_type
                  , mmtt.cost_group_id
                  , mmtt.container_item_id
                  , mmtt.operation_plan_id
                  , nvl(wda.delivery_id, mol.carton_grouping_id) -- only consolidate tasks with the same carton_grouping_id (hense delivery) if the delivery is checked in the rule
                  , mmtt.wms_task_status
                  , mmtt.item_primary_uom_code
		  , mmtt.secondary_uom_code
	          , mmtt.item_lot_control_code
                  , mmtt.item_serial_control_code
                  , mmtt.serial_allocated_flag
         HAVING SUM(mmtt.transaction_quantity) <> MIN(mmtt.transaction_quantity); -- make sure one line will not get consolidated


     CURSOR task_list_con_cd IS
                SELECT   SYSDATE last_update_date
                       , g_user_id last_updated_by
                       , SYSDATE creation_date
                       , g_user_id created_by
                       , mmtt.inventory_item_id
                       , mmtt.revision
                       , mmtt.organization_id
                       , mmtt.subinventory_code
                       , mmtt.locator_id
                       , SUM(mmtt.transaction_quantity)
                       , SUM(mmtt.primary_quantity)
		       , SUM(mmtt.secondary_transaction_quantity)
		       , mmtt.transaction_uom
                       , mmtt.transaction_type_id
                       , mmtt.transaction_action_id
                       , mmtt.transaction_source_type_id
                       , MAX(mmtt.transaction_date)
                       , MAX(mmtt.acct_period_id)
                       , mmtt.transfer_organization
                       , mmtt.wms_task_type
                       , MAX(mmtt.task_priority)
                       , mmtt.cost_group_id
                       , MAX(mmtt.transaction_header_id)
                       , mmtt.container_item_id
                       , mmtt.operation_plan_id
                       , mmtt.wms_task_status -- carry forward task status also for unreleased/pending statuses
                       , mmtt.item_primary_uom_code
		       , mmtt.secondary_uom_code
		       , mmtt.item_lot_control_code
                       , mmtt.item_serial_control_code
                       , mmtt.serial_allocated_flag
                    FROM wms_cartonization_temp mmtt
                    WHERE  mmtt.serial_allocated_flag = 'N'  -- do not bulk serial allocated lines
                           or mmtt.serial_allocated_flag is null
                GROUP BY mmtt.inventory_item_id
                       , mmtt.revision
                       , mmtt.organization_id
                       , mmtt.subinventory_code
                       , mmtt.locator_id
                       , mmtt.transaction_uom
                       , mmtt.transaction_type_id
                       , mmtt.transaction_action_id
                       , mmtt.transaction_source_type_id
                       , mmtt.transfer_organization
                       , mmtt.wms_task_type
                       , mmtt.cost_group_id
                       , mmtt.container_item_id
                       , mmtt.operation_plan_id
                       , mmtt.wms_task_status
                       , mmtt.item_primary_uom_code
		       , mmtt.secondary_uom_code
		       , mmtt.item_lot_control_code
                       , mmtt.item_serial_control_code
                       , mmtt.serial_allocated_flag
               HAVING SUM(mmtt.transaction_quantity) <> MIN(mmtt.transaction_quantity); -- make sure one line will not get consolidated


    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_primary_uom_code      VARCHAR2(3);
    l_sec_uom_code    VARCHAR2(3);
    l_lot_control_code      NUMBER;
    l_serial_control_code   NUMBER;
    l_serial_allocated_flag      VARCHAR2(1);
    l_total_child_count          NUMBER := 0;

  BEGIN
    IF (l_debug = 1) THEN
      print_debug('START CREATING BULK TASKS....',4);
      print_debug('Consolidating Tasks for MO Header ID = ' || p_move_order_header_id, 4);
    END IF;

    SAVEPOINT sp_consolidate_bulk_task;


    x_return_status  := fnd_api.g_ret_sts_success;

    -- check if the delivery is checked in the bulk picking rule-------------
    IF p_move_order_header_id <> -1 THEN

      -- cache the move order header info first
      If NOT INV_CACHE.set_mtrh_rec(p_move_order_header_id) THEN
         Raise g_exc_unexpected_error;
      END IF;

      IF p_move_order_header_id = g_move_order_header_id THEN
        l_delivery_flag := g_delivery_flag;
        l_bulk_pick_control := g_bulk_pick_control;
      ELSE
        IF (l_debug = 1) THEN
            print_debug('checking the delivery flag.',4);
        END IF;

        Select DELIVERY_FLAG
        Into l_delivery_flag
        From WSH_PICK_GROUPING_RULES
        Where pick_method=WMS_GLOBALS.PICK_METHOD_BULK
          and user_defined_flag = 'N'  -- bulk picking default rule
          and rownum <2; -- in case of psudo translation, multiple records are inserted for the seeded rule

         -- check to see if the picking methodology is bulk picking disabled (including order picking)---
   SELECT spg.bulk_pick_control
   into l_bulk_pick_control
   FROM wsh_pick_grouping_rules spg
        WHERE spg.pick_grouping_rule_id = INV_CACHE.mtrh_rec.grouping_rule_id;

        g_move_order_header_id := p_move_order_header_id;
        g_delivery_flag := l_delivery_flag;
        g_bulk_pick_control := l_bulk_pick_control;

        IF l_bulk_pick_control is null THEN
            l_bulk_pick_control := WMS_GLOBALS.BULK_PICK_SUB_ITEM;
        ELSE
          IF (l_bulk_pick_control = WMS_GLOBALS.BULK_PICK_DISABLED  ) THEN
       IF (l_debug = 1) THEN
           print_debug('Consolidating Tasks are not bulk picking enabled',4);
       END IF;
       return;
          END IF;
        END IF;

        l_move_order_type := INV_CACHE.mtrh_rec.move_order_type;

        IF l_move_order_type <> g_move_order_pick_wave THEN
         IF (l_debug = 1) THEN
               print_debug('Consolidating Tasks are not pick wave mo',4);
         END IF;
         RAISE g_exc_unexpected_error;
        END IF;
      END IF;
    ELSE -- calling from the concurrent program, always query
        Select DELIVERY_FLAG
   Into l_delivery_flag
   From WSH_PICK_GROUPING_RULES
        Where pick_method=WMS_GLOBALS.PICK_METHOD_BULK
          and user_defined_flag = 'N'  -- default rule
          and rownum <2; -- in case of psudo translation, multiple records are inserted for the seeded rule
    END IF;

    IF (l_debug = 1) THEN
        print_debug('Delivery flag for bulk picking is '||l_delivery_flag,4);
        print_debug('Consolidating Tasks, bulk task control '||l_bulk_pick_control,4);
    END IF;

   -- open the non serial controlled items cursor -----------------------
    if p_move_order_header_id <> -1 then
        if l_delivery_flag = 'Y'then
            OPEN task_list;
        else OPEN task_list_cross_delivery;
        end if;
    else
        if l_delivery_flag = 'Y'then
        OPEN task_list_con;
        else OPEN task_list_con_cd;
        end if;
    end if;

    LOOP
      if p_move_order_header_id <> -1 then
        IF l_delivery_flag = 'Y'THEN
        FETCH task_list INTO  l_last_update_date
                            , l_last_updated_by
                            , l_creation_date
                            , l_created_by
                            , l_inventory_item_id
                            , l_revision
                            , l_organization_id
                            , l_subinventory_code
                            , l_locator_id
                            , l_transaction_quantity
                            , l_primary_quantity
	                    , l_sec_transaction_quantity
	                    , l_transaction_uom
                            , l_transaction_type_id
                            , l_transaction_action_id
                            , l_transaction_source_type_id
                            , l_transaction_date
                            , l_acct_period_id
                            , l_to_org_id
                            , l_wms_task_type
                            , l_task_priority
                            , l_cost_group_id
                            , l_transaction_header_id
                            , l_container_item_id
                            , l_operation_plan_id
                            , l_wms_task_status
                            , l_carton_grouping_id
                            , l_primary_uom_code
	                    , l_sec_uom_code
	                    , l_lot_control_code
                            , l_serial_control_code
                            , l_serial_allocated_flag;
        EXIT WHEN task_list%NOTFOUND;
        ELSE
        FETCH task_list_cross_delivery INTO  l_last_update_date
                               , l_last_updated_by
                               , l_creation_date
                               , l_created_by
                               , l_inventory_item_id
                               , l_revision
                               , l_organization_id
                               , l_subinventory_code
                               , l_locator_id
                               , l_transaction_quantity
                               , l_primary_quantity
                               , l_sec_transaction_quantity
	                       , l_transaction_uom
                               , l_transaction_type_id
                               , l_transaction_action_id
                               , l_transaction_source_type_id
                               , l_transaction_date
                               , l_acct_period_id
                               , l_to_org_id
                               , l_wms_task_type
                               , l_task_priority
                               , l_cost_group_id
                               , l_transaction_header_id
                               , l_container_item_id
                               , l_operation_plan_id
                               , l_wms_task_status
                               , l_primary_uom_code
	                       , l_sec_uom_code
	                       , l_lot_control_code
                               , l_serial_control_code
                               , l_serial_allocated_flag;
   EXIT WHEN task_list_cross_delivery%NOTFOUND;
        END IF;
      else
        IF l_delivery_flag = 'Y'THEN
        FETCH task_list_con INTO  l_last_update_date
                               , l_last_updated_by
                               , l_creation_date
                               , l_created_by
                               , l_inventory_item_id
                               , l_revision
                               , l_organization_id
                               , l_subinventory_code
                               , l_locator_id
                               , l_transaction_quantity
                               , l_primary_quantity
	                       , l_sec_transaction_quantity
	                       , l_transaction_uom
                               , l_transaction_type_id
                               , l_transaction_action_id
                               , l_transaction_source_type_id
                               , l_transaction_date
                               , l_acct_period_id
                               , l_to_org_id
                               , l_wms_task_type
                               , l_task_priority
                               , l_cost_group_id
                               , l_transaction_header_id
                               , l_container_item_id
                               , l_operation_plan_id
                               , l_wms_task_status
                               , l_carton_grouping_id
                               , l_primary_uom_code
	                       , l_sec_uom_code
	                       , l_lot_control_code
                               , l_serial_control_code
                               , l_serial_allocated_flag;
        EXIT WHEN task_list_con%NOTFOUND;
        ELSE
        FETCH task_list_con_cd INTO  l_last_update_date
                                  , l_last_updated_by
                                  , l_creation_date
                                  , l_created_by
                                  , l_inventory_item_id
                                  , l_revision
                                  , l_organization_id
                                  , l_subinventory_code
                                  , l_locator_id
                                  , l_transaction_quantity
                                  , l_primary_quantity
	                          , l_sec_transaction_quantity
	                          , l_transaction_uom
                                  , l_transaction_type_id
                                  , l_transaction_action_id
                                  , l_transaction_source_type_id
                                  , l_transaction_date
                                  , l_acct_period_id
                                  , l_to_org_id
                                  , l_wms_task_type
                                  , l_task_priority
                                  , l_cost_group_id
                                  , l_transaction_header_id
                                  , l_container_item_id
                                  , l_operation_plan_id
                                  , l_wms_task_status
                                  , l_primary_uom_code
	                          , l_sec_uom_code
	                          , l_lot_control_code
                                  , l_serial_control_code
                                  , l_serial_allocated_flag;
        EXIT WHEN task_list_con_cd%NOTFOUND;
        END IF;
      end if;

      l_parent_task_count  := l_parent_task_count + 1;
     -- SELECT mtl_material_transactions_s.NEXTVAL INTO l_new_txn_temp_id FROM DUAL;

      IF (l_debug = 1) THEN
        print_debug('Creating a Parent Line with the values...', 4);
        print_debug('  --> Txn Header ID      => ' || l_transaction_header_id, 4);
     --   print_debug('  --> Txn Temp ID        => ' || l_new_txn_temp_id, 4);
        print_debug('  --> Inventory Item ID  => ' || l_inventory_item_id, 4);
        print_debug('  --> Revision           => ' || l_revision, 4);
        print_debug('  --> Organization ID    => ' || l_organization_id, 4);
        print_debug('  --> SubInventory Code  => ' || l_subinventory_code, 4);
        print_debug('  --> Locator ID         => ' || l_locator_id, 4);
        print_debug('  --> To Organization ID => ' || l_to_org_id, 4);

        print_debug('  --> Transaction Qty    => ' || l_transaction_quantity, 4);
        print_debug('  --> Primary Qty        => ' || l_primary_quantity, 4);
        print_debug('  --> Transaction UOM    => ' || l_transaction_uom, 4);
        print_debug('  --> Txn Type ID        => ' || l_transaction_type_id, 4);
        print_debug('  --> Txn Action ID      => ' || l_transaction_action_id, 4);
        print_debug('  --> Txn Source Type ID => ' || l_transaction_source_type_id, 4);
        print_debug('  --> Txn Date           => ' || l_transaction_date, 4);
        print_debug('  --> Account Period     => ' || l_acct_period_id, 4);
        print_debug('  --> Cost Group ID      => ' || l_cost_group_id, 4);
        print_debug('  --> Container Item ID  => ' || l_container_item_id, 4);
        print_debug('  --> Operation Plan Id  => ' || l_operation_plan_id, 4);
        print_debug('  --> Task Status        => ' || l_wms_task_status, 4);
      END IF;

      INSERT INTO wms_cartonization_temp
                  (
                    transaction_header_id
                  , transaction_temp_id
                  , posting_flag
                  , transaction_status
                  , last_update_date
                  , last_updated_by
                  , creation_date
                  , created_by
                  , transaction_type_id
                  , transaction_action_id
                  , transaction_source_type_id
                  , organization_id
                  , inventory_item_id
                  , revision
                  , subinventory_code
                  , locator_id
                  , transfer_organization
                  , transaction_quantity
                  , primary_quantity
		  , secondary_transaction_quantity
		  , transaction_uom
                  , transaction_date
                  , acct_period_id
                  , cost_group_id
                  , wms_task_type
                  , task_priority
                  , container_item_id
                  , operation_plan_id
                  , wms_task_status
                  , parent_line_id
                  , item_primary_uom_code
	          , secondary_uom_code
	          , item_lot_control_code
                  , item_serial_control_code
                  , serial_allocated_flag
                  )
           VALUES (
                    l_transaction_header_id
                  --, l_new_txn_temp_id
		  , mtl_material_transactions_s.NEXTVAL --Bug 5535030
                  , 'N'
                  , 2
                  , l_last_update_date
                  , l_last_updated_by
                  , l_creation_date
                  , l_created_by
                  , l_transaction_type_id
                  , l_transaction_action_id
                  , l_transaction_source_type_id
                  , l_organization_id
                  , l_inventory_item_id
                  , l_revision
                  , l_subinventory_code
                  , l_locator_id
                  , l_to_org_id
                  , l_transaction_quantity
                  , l_primary_quantity
		  , l_sec_transaction_quantity
		  , l_transaction_uom
                  , l_transaction_date
                  , l_acct_period_id
                  , l_cost_group_id
                  , l_wms_task_type
                  , l_task_priority
                  , l_container_item_id
                  , l_operation_plan_id
                  , l_wms_task_status
                --, l_new_txn_temp_id
	          , mtl_material_transactions_s.CURRVAL
                  , l_primary_uom_code
	          , l_sec_uom_code
 	          , l_lot_control_code
                  , l_serial_control_code
                  , l_serial_allocated_flag
             )RETURNING transaction_temp_id INTO l_new_txn_temp_id ;

      print_debug('  --> Txn Temp ID        => ' || l_new_txn_temp_id, 4);
      IF (l_debug = 1) THEN
        print_debug('Updating the Parent Line ID of the Tasks Consolidated', 4);
      END IF;

      IF l_delivery_flag = 'Y' THEN
      UPDATE wms_cartonization_temp wct
         SET parent_line_id = l_new_txn_temp_id
       WHERE transaction_temp_id <> l_new_txn_temp_id
         AND inventory_item_id = l_inventory_item_id
         AND NVL(revision, '#$%') = NVL(l_revision, NVL(revision, '#$%'))
         AND organization_id = l_organization_id
         AND subinventory_code = l_subinventory_code
         AND NVL(locator_id, -1) = NVL(l_locator_id, NVL(locator_id, -1))
         AND NVL(transfer_organization, -1) = NVL(l_to_org_id, NVL(transfer_organization, -1))
         AND transaction_uom = l_transaction_uom
         AND NVL(transaction_type_id, -1) = NVL(l_transaction_type_id, NVL(transaction_type_id, -1))
         AND NVL(transaction_action_id, -1) = NVL(l_transaction_action_id, NVL(transaction_action_id, -1))
         AND NVL(transaction_source_type_id, -1) = NVL(l_transaction_source_type_id, NVL(transaction_source_type_id, -1))
         AND NVL(cost_group_id, -1) = NVL(l_cost_group_id, NVL(cost_group_id, -1))
         AND EXISTS(SELECT 1
                      FROM mtl_txn_request_lines mol,wsh_delivery_details_ob_grp_v wdd,wsh_delivery_assignments_v wda
                     WHERE mol.line_id = wct.move_order_line_id
                       AND mol.line_id = wdd.move_ordeR_line_id
                       AND wdd.delivery_detail_id = wda.delivery_detail_id
                       AND NVL(wda.delivery_id,mol.carton_grouping_id) = l_carton_grouping_id)
   	 AND wct.transaction_temp_id NOT IN (        -- added for bug 9309619 Vpedarla
                              SELECT transaction_temp_id
                                FROM mtl_material_transactions_temp mmtt
                              WHERE mmtt.transaction_temp_id = wct.transaction_temp_id
                                 AND mmtt.allocated_lpn_id IS NOT NULL)
	AND wct.cartonization_id is NULL;--added for bug 9446937
      ELSE
      UPDATE wms_cartonization_temp
               SET parent_line_id = l_new_txn_temp_id
             WHERE transaction_temp_id <> l_new_txn_temp_id
               AND inventory_item_id = l_inventory_item_id
               AND NVL(revision, '#$%') = NVL(l_revision, NVL(revision, '#$%'))
               AND organization_id = l_organization_id
               AND subinventory_code = l_subinventory_code
               AND NVL(locator_id, -1) = NVL(l_locator_id, NVL(locator_id, -1))
               AND NVL(transfer_organization, -1) = NVL(l_to_org_id, NVL(transfer_organization, -1))
               AND transaction_uom = l_transaction_uom
               AND NVL(transaction_type_id, -1) = NVL(l_transaction_type_id, NVL(transaction_type_id, -1))
               AND NVL(transaction_action_id, -1) = NVL(l_transaction_action_id, NVL(transaction_action_id, -1))
               AND NVL(transaction_source_type_id, -1) = NVL(l_transaction_source_type_id, NVL(transaction_source_type_id, -1))
               AND NVL(cost_group_id, -1) = NVL(l_cost_group_id, NVL(cost_group_id, -1))
	       AND transaction_temp_id NOT IN (        -- added for bug 9309619 Vpedarla
                              SELECT transaction_temp_id
                                FROM mtl_material_transactions_temp mmtt
                               WHERE mmtt.transaction_temp_id = transaction_temp_id
                                 AND mmtt.allocated_lpn_id IS NOT NULL)
	       AND cartonization_id is NULL;--added for bug 9446937

      END IF;


      IF (l_debug = 1) THEN
        print_debug('Number of Tasks consolidated into 1 Parent Task = ' || SQL%ROWCOUNT, 4);
      END IF;
      l_total_child_count := l_total_child_count + SQL%ROWCOUNT;
    END LOOP;

    if p_move_order_header_id <> -1 then
         IF l_delivery_flag = 'Y' THEN
         CLOSE task_list;
         ELSE
         CLOSE task_list_cross_delivery;
         END IF;
    else
         IF l_delivery_flag = 'Y' THEN
         CLOSE task_list_con;
         ELSE
         CLOSE task_list_con_cd;
         END IF;
    end if;

    IF (l_debug = 1) THEN
      print_debug('Number of Parent Tasks = ' || l_parent_task_count, 4);
      print_debug('Number of child lines processed = ' || l_total_child_count,4);
    END IF;
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO sp_consolidate_bulk_task;
      IF l_debug = 1 THEN
         print_debug('Exception Occurred = ' || SQLERRM,4);
      END IF;
      IF task_list%ISOPEN THEN
          CLOSE task_list;
      END IF;
      IF task_list_con%ISOPEN THEN
                CLOSE task_list_con;
      END IF;


      IF task_list_cross_delivery%ISOPEN THEN
   CLOSE task_list_cross_Delivery;
      END IF;
      IF task_list_con_cd%ISOPEN THEN
         CLOSE task_list_con_cd;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END consolidate_bulk_tasks_for_so;

  --------- patchset J bulk picking -----------------
  -- This procedure will be called inside the  split_task API. It will be called after stamping the parent_line_id
  -- for all the child lines.  ------

  Procedure Duplicate_lot_serial_in_parent(
                  p_parent_transaction_temp_id     NUMBER
        , x_return_status        OUT NOCOPY    VARCHAR2
                  , x_msg_count            OUT NOCOPY    NUMBER
                  , x_msg_data             OUT NOCOPY    VARCHAR2) IS

  l_serial_number_control_code NUMBER;
  l_lot_control_code NUMBER;
  l_mtlt_rec mtl_transaction_lots_temp%ROWTYPE;
  l_msnt_rec mtl_serial_numbers_temp%ROWTYPE;
  l_new_txn_temp_id NUMBER;



  l_debug                      NUMBER                              := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
      IF (l_debug = 1) THEN
        print_debug('Enter Duplicate_lot_serial_in_parent ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;


      -- Initialize API return status to success
      x_return_status  := fnd_api.g_ret_sts_success;

      -- to get the serial control code
      select serial_number_control_code,lot_control_code
      into   l_serial_number_control_code,l_lot_control_code
      from mtl_system_items_b msi,mtl_material_transactions_temp mmtt
      where mmtt.transaction_temp_id = p_parent_transaction_temp_id
        and mmtt.inventory_item_id = msi.inventory_item_id
        and mmtt.organization_id = msi.organization_id;

      IF (l_debug = 1) THEN
        print_debug('lot control code:'||l_lot_control_code,4);
        print_debug('serial control code:'||l_serial_number_control_code,4);
      END IF;

      IF (l_lot_control_code = 2) THEN
          -- insert the lot numbers for the parent line
          INSERT INTO mtl_transaction_lots_temp
          (transaction_temp_id
          , lot_number
          , transaction_quantity
          , primary_quantity
          , secondary_quantity        --   8310896
          , secondary_unit_of_measure -- 8310896
          , lot_expiration_date
          , last_update_date
          , last_updated_by
          , creation_date
          , created_by
          , serial_transaction_temp_id)   -- always set to null since we don't bulk lines with allocated serial numbers
          (SELECT p_parent_transaction_temp_id,   -- transaction_temp_id of parent line
                  mtlt.lot_number,
                  sum(mtlt.transaction_quantity) transaction_quantity,
                  sum(mtlt.primary_quantity) primary_quantity
                  ,Sum(mtlt.secondary_quantity) secondary_quantity  --8310896
                 ,mtlt.secondary_unit_of_measure   --8310896
                 ,mtlt.lot_expiration_date
                 ,SYSDATE
                 ,g_user_id
                 ,SYSDATE
                 ,g_user_id
                 ,null
                  FROM mtl_transaction_lots_temp mtlt,mtl_material_transactions_temp mmtt
                  WHERE
                       mtlt.transaction_temp_id = mmtt.transaction_temp_id
                   and mmtt.parent_line_id = p_parent_transaction_temp_id   -- child task
                   and mmtt.transaction_temp_id <> p_parent_transaction_temp_id -- not parent task
               group by mtlt.lot_number,mtlt.lot_expiration_date,mtlt.secondary_unit_of_measure);  --8310896


      END IF;


      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF l_debug = 1 THEN
         print_debug('Exception Occurred = ' || SQLERRM,4);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

  END Duplicate_lot_serial_in_parent;

  ----- end of patchset J bulk picking   ------------------------------------

  PROCEDURE split_task(
    p_api_version              NUMBER
  , p_task_id                  NUMBER
  , p_commit                   VARCHAR2 := fnd_api.g_false
  , x_return_status OUT NOCOPY VARCHAR2
  , x_msg_count     OUT NOCOPY NUMBER
  , x_msg_data      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name                   VARCHAR2(20)                        := 'split_task';
    l_item_id                    NUMBER; -- item ID
    l_lot_control_code           NUMBER;
    l_serial_number_control_code NUMBER;
    l_loc_uom_code               VARCHAR2(3); -- locator uom code
    l_txn_uom_code               VARCHAR2(3); -- transaction uom code
    l_item_prim_uom_code         VARCHAR2(3); -- primary uom code
    l_item_sec_uom_code          VARCHAR2(3); -- secondary uom code
    l_txn_pri_uom_ratio          NUMBER; -- conversion rate between transaction uom and item primary UOM
    l_txn_sec_uom_ratio          NUMBER; -- conversion rate between transaction uom and secondary uom
    l_ch_txn_sec_uom_ratio       NUMBER; -- conversion rate between transaction uom and secondary uom FOR child tasks
    l_loc_txn_uom_ratio          NUMBER; -- conversion rate between locator uom and transaction uom
    l_sec_trans_qty              NUMBER;
    l_equip_vol                  NUMBER; -- equipment volume capacity
    l_equip_weight               NUMBER; -- equipment weight capacity
    l_item_vol                   NUMBER; -- item unit volume
    l_item_weight                NUMBER; -- item unit weight
    l_equip_v_uom                VARCHAR2(3); -- equipment volume UOM
    l_equip_w_uom                VARCHAR2(3); -- equipment weight UOM
    l_item_v_uom                 VARCHAR2(3); -- item unit volume UOM
    l_item_w_uom                 VARCHAR2(3); -- item unit weight UOM
    l_eq_it_v_uom_ratio          NUMBER                              := 1; -- conversion rate between equipment volume capacity and item unit volume UOM
    l_eq_it_w_uom_ratio          NUMBER                              := 1; -- conversion rate between equipment weight capacity and item weight UOM
    l_task_rec_old_wct           wms_cartonization_temp%ROWTYPE;
    l_task_rec_new_wct           wms_cartonization_temp%ROWTYPE;
    l_task_rec_old_mmtt          mtl_material_transactions_temp%ROWTYPE;
    l_task_rec_new_mmtt          mtl_material_transactions_temp%ROWTYPE;
    l_child_rec_new              mtl_material_transactions_temp%ROWTYPE;
    l_lot_split_rec              inv_rcv_common_apis.trans_rec_tb_tp;
    l_min_cap                    NUMBER                              := -1; -- minimum equipment capacity for a task
    l_min_cap_temp               NUMBER;
    l_split_factor               NUMBER; -- split task to this size
    l_init_qty                   NUMBER;
    l_new_qty                    NUMBER;
    l_counter                    NUMBER                              := 0;
    l_new_temp_id                NUMBER;
    l_progress                   VARCHAR2(10);
    l_return_status              VARCHAR2(1)                         := fnd_api.g_ret_sts_success;
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(400);

    -- capacity cursur for all the equipments that is eligible for one task
    -- also the item weight and volumn for the task
    CURSOR l_capcity_cur IS
      SELECT equip.internal_volume equip_vol
           , -- equipment volume capacity
             equip.maximum_load_weight equip_weight
           , -- equipment weight capacity
             item.unit_volume item_vol
           , -- item unit volume
             item.unit_weight item_weight
           , -- item unit weight
             equip.volume_uom_code equip_v_uom
           , -- equipment volumn UOM code
             equip.weight_uom_code equip_w_uom
           , -- equipment weight UOM code
             item.volume_uom_code item_v_uom
           , -- item volume UOM code
             item.weight_uom_code item_w_uom -- item weight UOM code
        FROM mtl_system_items equip
           , mtl_system_items item
           , wms_cartonization_temp  mmtt
           , bom_resource_equipments res_equip
           , bom_resources res
           , bom_std_op_resources tt_x_res
       WHERE mmtt.transaction_temp_id = p_task_id -- the task in question
         AND mmtt.standard_operation_id = tt_x_res.standard_operation_id --join task with task_type-resource x-ref
         AND tt_x_res.resource_id = res.resource_id -- join with resource
         AND res.resource_type = 1 -- resource type for equipment
         AND res_equip.resource_id = tt_x_res.resource_id -- join with resource-equip x-ref
         AND equip.inventory_item_id = res_equip.inventory_item_id -- join with equipment (mtl_system_items)
         AND equip.organization_id = res_equip.organization_id
         AND item.inventory_item_id = mmtt.inventory_item_id -- join with item for the item that is transfered
         AND item.organization_id = mmtt.organization_id;


   ---------- patchset J bulk picking  -----------------------
    -- capacity cursur for all the equipments that is eligible for one task
    -- also the item weight and volumn for the task
    -- this cursor is used for the new flows introduced by bulk picking
    CURSOR l_capcity_cur_bulk IS
      SELECT equip.internal_volume equip_vol
           , -- equipment volume capacity
             equip.maximum_load_weight equip_weight
           , -- equipment weight capacity
             item.unit_volume item_vol
           , -- item unit volume
             item.unit_weight item_weight
           , -- item unit weight
             equip.volume_uom_code equip_v_uom
           , -- equipment volumn UOM code
             equip.weight_uom_code equip_w_uom
           , -- equipment weight UOM code
             item.volume_uom_code item_v_uom
           , -- item volume UOM code
             item.weight_uom_code item_w_uom -- item weight UOM code
        FROM mtl_system_items equip
           , mtl_system_items item
           , mtl_material_transactions_temp  mmtt
           , bom_resource_equipments res_equip
           , bom_resources res
           , bom_std_op_resources tt_x_res
       WHERE mmtt.transaction_temp_id = p_task_id -- the task in question
         AND mmtt.standard_operation_id = tt_x_res.standard_operation_id --join task with task_type-resource x-ref
         AND tt_x_res.resource_id = res.resource_id -- join with resource
         AND res.resource_type = 1 -- resource type for equipment
         AND res_equip.resource_id = tt_x_res.resource_id -- join with resource-equip x-ref
         AND equip.inventory_item_id = res_equip.inventory_item_id -- join with equipment (mtl_system_items)
         AND equip.organization_id = res_equip.organization_id
         AND item.inventory_item_id = mmtt.inventory_item_id -- join with item for the item that is transfered
         AND item.organization_id = mmtt.organization_id;

   --      A new cursor will be defined to find all the child tasks ordered by delivery
   Cursor c_child_tasks(p_parent_line_id NUMBER) is
        Select mmtt.transaction_temp_id,mmtt.transaction_quantity,mmtt.secondary_transaction_quantity,mmtt.primary_quantity
          From wms_cartonization_temp mmtt,mtl_txn_request_lines mol,wsh_delivery_details_ob_grp_v wdd,
               wsh_delivery_assignments_v wda
          WHERE mmtt.parent_line_id = p_parent_line_id
            And mol.line_id = mmtt.move_order_line_id
            and mol.line_id = wdd.move_order_line_id
            and wdd.delivery_detail_id = wda.delivery_detail_id
            and mmtt.transaction_temp_id <> p_parent_line_id
          Order by nvl(wda.delivery_id,mol.carton_grouping_id), mmtt.transaction_quantity DESC;

   l_child_remaining_qty NUMBER := 0;
   l_child_temp_id NUMBER := 0;
   l_child_rec c_child_tasks%ROWTYPE;
   l_child_total_qty NUMBER := 0;
   l_new_child_temp_id  NUMBER;
   l_new_child_qty NUMBER;
   l_move_order_type NUMBER;
   ---------- end of patchset J bulk picking  -----------------------

    l_debug                      NUMBER                              := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Enter split_task 10 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress       := '10';
    SAVEPOINT sp_task_split;
    l_progress       := '20';
    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;
    -- query locator picking UOM code, if NULL use subinventory picking UOM code
    -- query transaction UOM code, and primary UOM code
    -- query transacted item ID
    -- Also query the transaction quantity
    -- changed for patchset J bulk picking -----------
      SELECT *
      INTO l_task_rec_old_wct
      FROM wms_cartonization_temp
      WHERE transaction_temp_id = p_task_id;

      -- get the mmtt rec too, will be used later on, the reason why both wct and mmtt are here is for branching
      SELECT *
       INTO l_task_rec_old_mmtt
       FROM mtl_material_transactions_temp
       WHERE transaction_temp_id = p_task_id;

      IF (l_task_rec_old_wct.parent_line_id is null) THEN -- not bulk task
          -- cache the move order header info first
     If NOT INV_CACHE.set_mtrh_rec(l_task_rec_old_wct.move_order_header_id) THEN
         Raise g_exc_unexpected_error;
          END IF;
          l_move_order_type := INV_CACHE.mtrh_rec.move_order_type;
          if (l_debug = 1) then print_debug('Move order type:'||l_move_order_type,4); end if;
     ELSE
       --  IF (l_debug = 1) THEN print_debug('PATCHSET J-- BULK PICKING --START',4); END IF;
         l_move_order_type := G_MOVE_ORDER_PICK_WAVE;  -- calling for parent task, WIP doesn't call this for patchset J
         if (l_debug = 1) then print_debug('calling for bulk task (parent task line ....',4);
                       --        print_debug('PATCHSET J-- BULK PICKING --END', 4);
           end if;
     END IF;

   -- end of change for patchset J bulk picking ------------------




    -- Use subinventory locator pick_uom_code OR sub pick_uom_code
    l_progress       := '30';

    SELECT NVL(mil.pick_uom_code, msi.pick_uom_code)
         , mmtt.transaction_uom
         , mmtt.inventory_item_id
         , mmtt.transaction_quantity
         , mmtt.secondary_transaction_quantity
         , item.primary_uom_code
         , item.lot_control_code
         , item.serial_number_control_code
         , item.secondary_uom_code
      INTO l_loc_uom_code
         , l_txn_uom_code
         , l_item_id
         , l_init_qty
         , l_sec_trans_qty
         , l_item_prim_uom_code
         , l_lot_control_code
         , l_serial_number_control_code
         , l_item_sec_uom_code
      FROM wms_cartonization_temp mmtt, mtl_item_locations mil, mtl_secondary_inventories msi, mtl_system_items item
     WHERE mmtt.transaction_temp_id = p_task_id
       AND mmtt.locator_id = mil.inventory_location_id(+)
       AND mmtt.organization_id = mil.organization_id(+)
       AND mmtt.subinventory_code = msi.secondary_inventory_name
       AND mmtt.organization_id = msi.organization_id
       AND mmtt.inventory_item_id = item.inventory_item_id
       AND mmtt.organization_id = item.organization_id;

    l_progress       := '40';

    /* bug8197523. The ratio is calculated here and is used in calcualting secondary qty for parent tasks */
    IF (l_sec_trans_qty IS NOT NULL AND l_sec_trans_qty <> 0) THEN
        l_txn_sec_uom_ratio := (l_init_qty/l_sec_trans_qty);
     ELSE
       l_txn_sec_uom_ratio := 0;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('l_txn_sec_uom_ratio => ' || l_txn_sec_uom_ratio, 4);
    END IF;



    IF (l_debug = 1) THEN
      print_debug('split_task 20 - quried following information' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      print_debug('l_loc_uom_code => ' || l_loc_uom_code, 4);
      print_debug('l_txn_uom_code => ' || l_txn_uom_code, 4);
      print_debug('l_item_id => ' || l_item_id, 4);
      print_debug('l_init_qty => ' || l_init_qty, 4);
      print_debug('l_item_prim_uom_code => ' || l_item_prim_uom_code, 4);
      print_debug('l_lot_control_code => ' || l_lot_control_code, 4);
      print_debug('l_serial_number_control_code => ' || l_serial_number_control_code, 4);
    END IF;

    -- bug fix 2123018
    IF l_loc_uom_code IS NULL THEN
      IF (l_debug = 1) THEN
        print_debug('l_loc_uom_code is NULL, default it to l_txn_uom_code.', 4);
      END IF;

      l_loc_uom_code  := l_txn_uom_code;
    END IF;

    IF l_loc_uom_code IS NULL
       OR l_txn_uom_code IS NULL
       OR l_item_id IS NULL
       OR l_init_qty IS NULL
       OR l_item_prim_uom_code IS NULL THEN
      IF (l_debug = 1) THEN
        print_debug('split_task 30 - necessary UOM information missing' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- call UOM conversion API to compute the ratio between
    -- locator UOM and transcation UOM for given item
    inv_convert.inv_um_conversion(from_unit => l_loc_uom_code, to_unit => l_txn_uom_code, item_id => l_item_id
    , uom_rate                     => l_loc_txn_uom_ratio);

    IF l_loc_txn_uom_ratio = -99999 THEN -- uom conversion failure
      fnd_message.set_name('INV', 'INV_INT_UOMCONVCODE');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('split_task 40 - loc/item uom ratio calculation failed' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    -- compute conversion rate between transaction UOM and item primary UOM
    inv_convert.inv_um_conversion(from_unit => l_txn_uom_code, to_unit => l_item_prim_uom_code, item_id => l_item_id
    , uom_rate                     => l_txn_pri_uom_ratio);

    IF l_txn_pri_uom_ratio = -99999 THEN -- uom conversion failure
      fnd_message.set_name('INV', 'INV_INT_UOMCONVCODE');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('split_task 50 - txn/item uom ratio calculation failed' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('split_task 60 - UOM conversion data:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    IF (l_debug = 1) THEN
      print_debug('l_loc_txn_uom_ratio => ' || l_loc_txn_uom_ratio, 4);
      print_debug('l_txn_pri_uom_ratio => ' || l_txn_pri_uom_ratio, 4);
    END IF;

    -- Query minimum equipment capacity in terms of transaction UOM
    -- The minimum of the volumn and weight capacity is used
    -- If no equipment capacity or item unit volumn or weight defined,
    -- do not split
    -- NEED FURTHER consideration for container item:
    -- should check unit volume and content weight ???

    l_progress       := '50';
    if G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
       l_move_order_type = G_MOVE_ORDER_PICK_WAVE THEN
        IF (l_debug = 1) THEN print_debug('open l_capcity_cur_bulk',4);  END IF;
        OPEN l_capcity_cur_bulk;
    ELSE
        IF (l_debug = 1) THEN print_debug('open l_capcity_cur',4);  END IF;
        OPEN l_capcity_cur;
    END IF;
    l_progress       := '60';

    LOOP
      l_progress  := '70';
      if G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
       l_move_order_type = G_MOVE_ORDER_PICK_WAVE THEN
          FETCH l_capcity_cur_bulk INTO l_equip_vol, l_equip_weight, l_item_vol, l_item_weight, l_equip_v_uom, l_equip_w_uom, l_item_v_uom
                                 , l_item_w_uom;
          EXIT WHEN l_capcity_cur_bulk%NOTFOUND;
      else
          FETCH l_capcity_cur INTO l_equip_vol, l_equip_weight, l_item_vol, l_item_weight, l_equip_v_uom, l_equip_w_uom, l_item_v_uom
                                   , l_item_w_uom;
          EXIT WHEN l_capcity_cur%NOTFOUND;
      end if;
      l_progress  := '80';
      --bug 8800509 added following debug statements
      IF (l_debug = 1) THEN
          print_debug('split_task 70 - l_equip_vol ' || l_equip_vol, 4);
	  print_debug('split_task 70 - l_equip_weight ' || l_equip_weight, 4);
	  print_debug('split_task 70 - l_item_vol ' || l_item_vol, 4);
	  print_debug('split_task 70 - l_item_weight ' || l_item_weight, 4);
	  print_debug('split_task 70 - l_equip_v_uom ' || l_equip_v_uom, 4);
	  print_debug('split_task 70 - l_equip_w_uom ' || l_equip_w_uom, 4);
	  print_debug('split_task 70 - l_item_v_uom ' || l_item_v_uom, 4);
	  print_debug('split_task 70 - l_item_w_uom ' || l_item_w_uom, 4);
      END IF;
      -- get the conversion ratio between equipment and item volume UOM
      inv_convert.inv_um_conversion(from_unit => l_equip_v_uom, to_unit => l_item_v_uom, item_id => 0, uom_rate => l_eq_it_v_uom_ratio);
      IF l_eq_it_v_uom_ratio = -99999 THEN -- uom conversion failure
        fnd_message.set_name('INV', 'INV_INT_UOMCONVCODE');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('split_task 70 - eqp/item volume uom ratio calculation failed' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;
      END IF;
      -- get the conversion ratio between equipment and item weight UOM
      inv_convert.inv_um_conversion(from_unit => l_equip_w_uom, to_unit => l_item_w_uom, item_id => 0, uom_rate => l_eq_it_w_uom_ratio);
      IF l_eq_it_w_uom_ratio = -99999 THEN -- uom conversion failure
        fnd_message.set_name('INV', 'INV_INT_UOMCONVCODE');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('split_task 70 - eqp/item weight uom ratio calculation failed' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;
      END IF;

      --
      -- Debugging Statements for FP bug 4634597
      --
      IF (l_debug = 1) THEN
       print_debug('l_equip_vol = ' || l_equip_vol, 4);
       print_debug('l_item_vol = ' || l_item_vol, 4);
       print_debug('l_eq_it_v_uom_ratio = ' || l_eq_it_v_uom_ratio, 4);
       print_debug('l_equip_weight = ' || l_equip_weight, 4);
       print_debug('l_item_weight = ' || l_item_weight, 4);
       print_debug('l_eq_it_w_uom_ratio = ' || l_eq_it_w_uom_ratio, 4);
      END IF;
      --
      --Bug 8800509 Start of code addition
      --volume for both item and equipment are defined
      IF (l_equip_vol IS NOT NULL AND l_item_vol IS NOT NULL AND l_eq_it_v_uom_ratio <> -99999) THEN
	--weight for both item and equip are defined
	IF (l_equip_weight IS NOT NULL AND l_item_weight IS NOT NULL AND l_eq_it_w_uom_ratio <> -99999) THEN
		--both weight and voulme are defined for item and equip
		--calculate based on both

		IF (l_debug = 1) THEN
		    print_debug('split_task 70.1, both weight and voulme are defined for item and equip, calculate equipment capacity based on both weight and volume',4);
	        END IF;

		l_min_cap_temp  := TRUNC(min_num((l_equip_vol * l_eq_it_v_uom_ratio / l_item_vol),(l_equip_weight * l_eq_it_w_uom_ratio / l_item_weight))/ l_txn_pri_uom_ratio);
		--
	        -- Start FP Bug 4634596
                --
	        IF (l_min_cap_temp = 0) THEN
		   l_min_cap_temp :=  min_num((l_equip_vol * l_eq_it_v_uom_ratio /l_item_vol),(l_equip_weight * l_eq_it_w_uom_ratio / l_item_weight)) / l_txn_pri_uom_ratio;
	        END IF;
	ELSE
		--only volume is defined for item and equip
		--calculate equipment capacity based on volume only
		IF (l_debug = 1) THEN
		    print_debug('split_task 70.1, only voulme defined for item and equip, calculate equipment capacity based on volume',4);
	        END IF;
		l_min_cap_temp  := TRUNC((l_equip_vol * l_eq_it_v_uom_ratio / l_item_vol) / l_txn_pri_uom_ratio);
	        --
		-- Start FP Bug 4634596
		--
	        IF (l_min_cap_temp = 0) THEN
		   l_min_cap_temp  := (l_equip_vol * l_eq_it_v_uom_ratio / l_item_vol) / l_txn_pri_uom_ratio;
	        END IF;
		--
	        -- End FP Bug 4634596
		--
	END IF;
      --weight for both item and equipment are defined, but volume is not defined for one of them
      ELSIF (l_equip_weight IS NOT NULL AND l_item_weight IS NOT NULL AND l_eq_it_w_uom_ratio <> -99999) THEN
		--calculate based on weight only

		IF (l_debug = 1) THEN
		    print_debug('split_task 70.1, only weight defined for item and equip, calculate equipment capacity based on weight',4);
	        END IF;
		l_min_cap_temp  := TRUNC((l_equip_weight * l_eq_it_w_uom_ratio / l_item_weight) / l_txn_pri_uom_ratio);
	        --
		-- Start FP Bug 4634596
	        --
		IF (l_min_cap_temp = 0) THEN
	           l_min_cap_temp  := (l_equip_weight * l_eq_it_w_uom_ratio / l_item_weight) / l_txn_pri_uom_ratio;
		END IF;
	        --
		-- End FP Bug 4634596
	        --
      ELSE
	--throw error, as no capicity definition
	IF (l_debug = 1) THEN
          print_debug('split_task 80 - invalid capacity for a particulcar equipment' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;
      END IF;

      IF (l_debug = 1) THEN
            print_debug('split_task 1.6, l_min_cap'||l_min_cap,4);
            print_debug('split_task 1.6, l_min_cap_temp'|| l_min_cap_temp,4);
      END IF;

      IF (l_min_cap = -1)
           OR(l_min_cap > l_min_cap_temp) THEN
          l_min_cap  := l_min_cap_temp; -- get minimum capacity of all possible equipment
      END IF;
      --Bug 8800509 End of code addition

      --Bug 8800509 Start of commented out code

  /*    IF (l_equip_vol IS NOT NULL
          AND l_item_vol IS NOT NULL
          AND l_eq_it_v_uom_ratio <> -99999)
         OR(l_equip_weight IS NOT NULL
            AND l_item_weight IS NOT NULL
            AND l_eq_it_w_uom_ratio <> -99999) THEN
        IF l_eq_it_v_uom_ratio = -99999 THEN                                   -- invalid volume UOM conversion
                                             -- compute equipment capacity using weight
          l_min_cap_temp  := TRUNC((l_equip_weight * l_eq_it_w_uom_ratio / l_item_weight) / l_txn_pri_uom_ratio);
          --
          -- Start FP Bug 4634597
          --
          IF (l_min_cap_temp = 0) THEN
           l_min_cap_temp  := (l_equip_weight * l_eq_it_w_uom_ratio / l_item_weight) / l_txn_pri_uom_ratio;
          END IF;
          --
          -- End FP Bug 4634597
          --
        ELSIF l_eq_it_w_uom_ratio = -9999 THEN                                       -- invalid weight conversion
                                               -- compute equipment capacity using volume
          l_min_cap_temp  := TRUNC((l_equip_vol * l_eq_it_v_uom_ratio / l_item_vol) / l_txn_pri_uom_ratio);
          --
          -- Start FP Bug 4634597
          --
          IF (l_min_cap_temp = 0) THEN
           l_min_cap_temp  := (l_equip_vol * l_eq_it_v_uom_ratio / l_item_vol) / l_txn_pri_uom_ratio;
          END IF;
          --
          -- End FP Bug 4634597
          --
        ELSE     -- both weight and volume defined
             -- compute the minimum of volume capacity and weight capacity
             -- transfer the capacity to transaction UOM
          l_min_cap_temp  :=
            TRUNC(
                min_num((l_equip_vol * l_eq_it_v_uom_ratio / l_item_vol),(l_equip_weight * l_eq_it_w_uom_ratio / l_item_weight))
              / l_txn_pri_uom_ratio
            );
          --
          -- Start FP Bug 4634597
          --
          IF (l_min_cap_temp = 0) THEN
           l_min_cap_temp :=  min_num((l_equip_vol * l_eq_it_v_uom_ratio /
l_item_vol),(l_equip_weight * l_eq_it_w_uom_ratio / l_item_weight))
              / l_txn_pri_uom_ratio;
          END IF;
          --
          -- End FP Bug 4634597
          --
        END IF;
        IF (l_debug = 1) THEN
            print_debug('split_task 1.6, l_min_cap'||l_min_cap,4);
            print_debug('split_task 1.6, l_min_cap_temp'|| l_min_cap_temp,4);
        END IF;
        IF (l_min_cap = -1)
           OR(l_min_cap > l_min_cap_temp) THEN
          l_min_cap  := l_min_cap_temp; -- get minimum capacity of all possible equipment
        END IF;
      ELSE -- neither of weight or volume capacity is properly defined
        IF (l_debug = 1) THEN
          print_debug('split_task 80 - invalid capacity for a particulcar equipment' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;
      END IF;*/
      --Bug 8800509 End of commented out code
    END LOOP;

    l_progress       := '90';
    if G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
       l_move_order_type = G_MOVE_ORDER_PICK_WAVE THEN
        CLOSE l_capcity_cur_bulk;
    else
        CLOSE l_capcity_cur;
    end if;
    l_progress       := '100';

    IF l_min_cap = -1 THEN -- min capcity is not properly queried
      fnd_message.set_name('WMS', 'WMS_INVALID_CAP_DEF');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('split_task 90 - invalid capacity for a ALL equipment' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    -- compute splitting factor, round down equipment capacity to multiple of locator uom ratio
    IF l_min_cap >= l_loc_txn_uom_ratio THEN
      l_split_factor  := TRUNC(l_min_cap / l_loc_txn_uom_ratio) * l_loc_txn_uom_ratio;
    ELSE
      l_split_factor  := l_min_cap;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('split_task 100 - l_split_factor = ' || l_split_factor, 4);
    END IF;

    IF (l_split_factor <= 0 OR l_split_factor IS NULL) THEN -- min capcity is not properly queried bug# 9479006
      fnd_message.set_name('WMS', 'WMS_INVALID_CAP_DEF');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('split_task 95 - minimum capacity 0' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    -- query the inital task

    l_progress       := '110';

    --- patchset J bulk picking  ---
    if G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
       l_move_order_type = G_MOVE_ORDER_PICK_WAVE THEN
     --  IF (l_debug = 1) THEN print_debug('PATCHSET J-- BULK PICKING --START',4); END IF;
       if (l_task_rec_old_mmtt.transaction_temp_id = l_task_rec_old_mmtt.parent_line_id) then   -- bulk picking
          IF (l_init_qty > l_split_factor AND l_split_factor > 0) THEN   -- only open the child cursor when split is needed
               IF (l_debug = 1) THEN
                 print_debug('Patchset J bulk picking,open the child tasks...',4);
              END IF;
              open c_child_tasks(p_task_id);
          END IF;
       end if;
      -- IF (l_debug = 1) THEN print_debug('PATCHSET J-- BULK PICKING --END',4); END IF;
    end if;
    --- end of patchset J bulk picking  ---
    l_progress       := '120';

    -- split task based on splitting factor
    WHILE(l_init_qty > l_split_factor
          AND l_split_factor > 0) LOOP
      IF (l_debug = 1) THEN
        print_debug('split_task 110 - splitting task -  l_init_qty = ' || l_init_qty, 4);
      END IF;

      l_counter                            := l_counter + 1;
      l_init_qty                           := l_init_qty - l_split_factor;

      IF l_init_qty >= 0 THEN
        l_new_qty  := l_split_factor;
      ELSE
        l_new_qty  := l_init_qty + l_split_factor;
      END IF;

      -- generate new tasks
      if G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
       l_move_order_type = G_MOVE_ORDER_PICK_WAVE THEN
          l_task_rec_new_mmtt                       := l_task_rec_old_mmtt;
      else
          l_task_rec_new_wct                       := l_task_rec_old_wct;
      end if;
      l_progress                           := '130';

      -- generate new transaction_temp_id primary key
      SELECT mtl_material_transactions_s.NEXTVAL
        INTO l_new_temp_id
        FROM DUAL;

      l_progress                           := '140';
      /*  Is it necessary to change transaction UOM to locator UOM here ???*/
      IF G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
         l_move_order_type = G_MOVE_ORDER_PICK_WAVE THEN
          l_task_rec_new_mmtt.transaction_temp_id   := l_new_temp_id;
          l_task_rec_new_mmtt.transaction_quantity  := l_new_qty;
          l_task_rec_new_mmtt.primary_quantity      := l_new_qty * l_txn_pri_uom_ratio;
	  IF (l_txn_sec_uom_ratio<>0 AND l_txn_sec_uom_ratio IS NOT NULL) THEN
	     l_task_rec_new_mmtt.secondary_transaction_quantity  := Round((l_new_qty/l_txn_sec_uom_ratio),5);
	  END IF;
	  IF l_task_rec_old_mmtt.transaction_temp_id = l_task_rec_old_mmtt.parent_line_id THEN
              l_task_rec_new_mmtt.parent_line_id        := l_new_temp_id;
          END IF;
      ELSE
          l_task_rec_new_wct.transaction_temp_id   := l_new_temp_id;
          l_task_rec_new_wct.transaction_quantity  := l_new_qty;
          l_task_rec_new_wct.primary_quantity      := l_new_qty * l_txn_pri_uom_ratio;
      END IF;

      --      l_task_rec_new.transaction_uom := l_loc_uom_code;

      IF (l_debug = 1) THEN
        print_debug('split_task 120 - new task: ', 4);
        print_debug('l_new_temp_id  => ' || l_new_temp_id, 4);
        print_debug('l_new_qty  => ' || l_new_qty, 4);
        IF G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
         l_move_order_type = G_MOVE_ORDER_PICK_WAVE THEN
            print_debug('primary_quantity  => ' || l_task_rec_new_mmtt.primary_quantity, 4);
        ELSE
            print_debug('primary_quantity  => ' || l_task_rec_new_wct.primary_quantity, 4);
        END IF;
      END IF;

      -- insert reccord into mmtt
      l_progress                           := '150';
      if G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
         l_move_order_type = inv_globals.G_MOVE_ORDER_PICK_WAVE THEN
          insert_mmtt(l_task_rec_new_mmtt);
      else
          insert_wct(l_task_rec_new_wct);
      end if;

      -- Associate the child lines if it is bulk picking
      if G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
         l_move_order_type = G_MOVE_ORDER_PICK_WAVE AND
         l_task_rec_old_mmtt.transaction_temp_id = l_task_rec_old_mmtt.parent_line_id THEN

        -- IF (l_debug = 1) THEN
       --       print_debug('PATCHSET J BULK PICKING:starting to split',4);
        -- END IF;
         l_child_total_qty := 0;
         loop
             IF (l_debug = 1) THEN
                 print_debug('l_child_remaining_qty:'||l_child_remaining_qty,4);
             END IF;
             if (l_child_remaining_qty = 0) then
                 fetch c_child_tasks into l_child_rec;
                 EXIT WHEN c_child_tasks%NOTFOUND;

                 l_child_remaining_qty := l_child_rec.transaction_quantity;
                 l_child_temp_id := l_child_rec.transaction_temp_id;
                 l_child_total_qty := l_child_total_qty + l_child_rec.transaction_quantity;
             else
                 l_child_rec.transaction_quantity := l_child_remaining_qty;
                 l_child_total_qty := l_child_remaining_qty;
             end if;
             IF (l_debug = 1) THEN
                 print_debug('l_child_total_qty '||l_child_total_qty,4);
             END IF;
             if l_child_total_qty <= l_new_qty then
                -- update the child records with the new parent line id
                update mtl_material_transactions_temp
                set parent_line_id = l_new_temp_id
                where transaction_Temp_id = l_child_rec.transaction_temp_id;
                l_child_remaining_qty := 0;
                -- if = which means fully satisfied the new parent, can exit
                exit when l_child_total_qty = l_new_qty;
             else
                l_child_remaining_qty := l_child_total_qty - l_new_qty;
                -- find the qty to split
                l_new_child_qty := l_child_rec.transaction_quantity - l_child_remaining_qty;
                IF (l_debug = 1) THEN
                    print_debug('update transaction temp id '||l_child_rec.transaction_temp_id
                                || ' with the remaining qty '||l_child_remaining_qty,4);
                END IF;

		/* bug8197523. This ratio is for calculating the secondary qty for child tasks */
		IF (l_child_rec.secondary_transaction_quantity IS NOT NULL AND l_child_rec.secondary_transaction_quantity <> 0) THEN
		   l_ch_txn_sec_uom_ratio := (l_child_rec.transaction_quantity/l_child_rec.secondary_transaction_quantity);
		 ELSE
		   l_ch_txn_sec_uom_ratio := 0;
		END IF;


		IF (l_debug = 1) THEN
		   print_debug('81975 l_child_rec.transaction_temp_id => ' || l_child_rec.transaction_temp_id, 4);
		   print_debug('81975 l_child_rec.transaction_quantity => ' || l_child_rec.transaction_quantity, 4);
		   print_debug('81975 l_child_rec.primary_quantity => ' || l_child_rec.primary_quantity, 4);
		   print_debug('81975 l_child_rec.secondary_transaction_quantity => ' || l_child_rec.secondary_transaction_quantity, 4);
		   print_debug('81975  l_ch_txn_sec_uom_ratio=> ' || l_ch_txn_sec_uom_ratio, 4);
		END IF;


		-- update the child line with the remaining qty
                update mtl_material_transactions_temp
                set transaction_quantity =  l_child_remaining_qty
                    , primary_quantity = l_child_remaining_qty * l_txn_pri_uom_ratio
		    , secondary_transaction_quantity = DECODE(l_ch_txn_sec_uom_ratio, NULL, NULL,0,NULL,Round((l_child_remaining_qty/l_ch_txn_sec_uom_ratio),5))
		where transaction_temp_id =  l_child_rec.transaction_temp_id;

                -- split the child task
                -- generate new transaction_temp_id primary key
         SELECT mtl_material_transactions_s.NEXTVAL
         INTO l_new_child_temp_id
         FROM DUAL;

         l_progress                           := '140.1';
                   select *
                   into
                       l_child_rec_new
                   from mtl_material_transactions_temp
                   where transaction_temp_id =  l_child_rec.transaction_temp_id;

         /*  Is it necessary to change transaction UOM to locator UOM here ???*/
         l_child_rec_new.transaction_temp_id   := l_new_child_temp_id;
         l_child_rec_new.transaction_quantity  := l_new_child_qty;
         l_child_rec_new.primary_quantity      := l_new_child_qty * l_txn_pri_uom_ratio;
	 IF (l_ch_txn_sec_uom_ratio<>0 AND l_ch_txn_sec_uom_ratio IS NOT NULL) THEN
	 l_child_rec_new.secondary_transaction_quantity      := Round((l_new_child_qty/l_ch_txn_sec_uom_ratio),5);
	 END IF;
	 l_child_rec_new.parent_line_id       := l_new_temp_id;  -- update the new line with the correct parent



         IF (l_debug = 1) THEN
              print_debug('split_task for child line - new child task: ', 4);
              print_debug('l_new_temp_id  => ' || l_new_child_temp_id, 4);
              print_debug('l_new_qty  => ' || l_new_child_qty, 4);
              print_debug('primary_quantity  => ' || l_child_rec_new.primary_quantity, 4);
              print_debug('parent_line_id '||l_new_temp_id,4);
         END IF;

            -- insert reccord into mmtt
            l_progress                           := '150.1';
            insert_mmtt(l_child_rec_new);


                      -- split lot/serial temp table

                      l_lot_split_rec(1).transaction_id    := l_new_child_temp_id;
            l_lot_split_rec(1).primary_quantity  := l_child_rec_new.primary_quantity;
            IF (l_debug = 1) THEN
                          print_debug('calling BREAK to insert the lot and serial',4);
                      END IF;
            inv_rcv_common_apis.BREAK(
                    p_original_tid               => l_child_rec.transaction_temp_id
                  , p_new_transactions_tb        => l_lot_split_rec
                  , p_lot_control_code           => l_lot_control_code
                  , p_serial_control_code        => l_serial_number_control_code
                       );
                       IF (l_debug = 1) THEN print_debug('After insert the lot and serial for the split child',4);
                       END IF;
                       EXIT;
             end if;
         end loop;
         -- copy the lot and serial to the parents
         IF (l_debug = 1) THEN
                 print_debug('calling duplicate_lot_serial_in_parent....',4);
         END IF;
         Duplicate_lot_serial_in_parent(l_new_temp_id,x_return_status,x_msg_count,x_msg_data);

         if (x_return_status <> fnd_api.g_ret_sts_success) then
             IF (l_debug = 1) THEN
              print_debug('split_task 150.2 - error in duplicate_lot_serial_in_parent ', 4);
             END IF;
             raise fnd_api.g_exc_unexpected_error;
         end if;
        -- IF (l_debug = 1) THEN print_debug('PATCHSET J -- BULK PICKING --- END',4); END IF;
      END IF;

      ---   end of patchset J bulk picking            -----------------

      -- split lot/serial temp table
      IF l_task_rec_old_wct.parent_line_id is null THEN     -- bulk picking patchset J ---- this is only for non bulk task
          l_lot_split_rec(1).transaction_id    := l_new_temp_id;
          if G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
              l_move_order_type = G_MOVE_ORDER_PICK_WAVE THEN
              l_lot_split_rec(1).primary_quantity  := l_task_rec_new_mmtt.primary_quantity;
          else
              l_lot_split_rec(1).primary_quantity  := l_task_rec_new_wct.primary_quantity;
          end if;
          inv_rcv_common_apis.BREAK(
          p_original_tid               => p_task_id
         , p_new_transactions_tb        => l_lot_split_rec
         , p_lot_control_code           => l_lot_control_code
         , p_serial_control_code        => l_serial_number_control_code
         );
      END IF;
      l_progress                           := '160';
    END LOOP;

    IF (l_debug = 1) THEN
      print_debug('split_task 130 - remove original task: ', 4);
    END IF;

    IF ((l_init_qty <= l_split_factor)) THEN
      UPDATE wms_cartonization_temp
         SET transaction_quantity = l_init_qty
           , primary_quantity = l_init_qty * l_txn_pri_uom_ratio
	   , secondary_transaction_quantity = DECODE(l_txn_sec_uom_ratio, NULL, NULL,0,NULL,Round((l_init_qty/l_txn_sec_uom_ratio),5))
	WHERE transaction_temp_id = p_task_id;
       -- for patchset J bulk picking -----------
       -- the lot and serial info still need to be duplicated since consolidation didn't do it
       if G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
         l_move_order_type = G_MOVE_ORDER_PICK_WAVE THEN
        -- IF (l_debug = 1) THEN print_debug('PATCHSET J -- BULK PICKING --- START',4); END IF;
         UPDATE mtl_material_transactions_temp
       SET transaction_quantity = l_init_qty
         , primary_quantity = l_init_qty * l_txn_pri_uom_ratio
         , secondary_transaction_quantity = DECODE(l_txn_sec_uom_ratio, NULL, NULL,0,NULL,Round((l_init_qty/l_txn_sec_uom_ratio),5))

	   WHERE transaction_temp_id = p_task_id;
          IF l_task_rec_old_mmtt.transaction_temp_id = l_task_rec_old_mmtt.parent_line_id THEN
          -- copy the lot and serial to the parents
                  IF (l_debug = 1) THEN
             print_debug('calling duplicate_lot_serial_in_parent for the last ....',4);
                  END IF;
             Duplicate_lot_serial_in_parent(p_task_id,x_return_status,x_msg_count,x_msg_data);
             if (x_return_status <> fnd_api.g_ret_sts_success) then
                 IF (l_debug = 1) THEN
                 print_debug('split_task 150.2 - error in duplicate_lot_serial_in_parent ', 4);
                 END IF;
                 raise fnd_api.g_exc_unexpected_error;
                  end if;
          END IF;
        --  IF (l_debug = 1) THEN print_debug('PATCHSET J -- BULK PICKING --- END',4); END IF;
       end if; -- end of patchset J bulk picking ----------
    END IF;

    /*

      IF l_init_qty <= 0 THEN
         DELETE wms_cartonization_temp
     WHERE transaction_temp_id = p_task_id;
      END IF;
   */
    IF (l_debug = 1) THEN
      print_debug('split_task 140 - complete ', 4);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      ROLLBACK TO sp_task_split;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug(
             'split_task:  Raise expected exception. But the task generation process should continue processing, only that tasks are not split according to equipment capacity. '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1
        );
      END IF;
       -- for patchset J bulk picking -----------
       -- the lot and serial info still need to be duplicated since consolidation didn't do it
       if G_CURRENT_RELEASE_LEVEL >= G_J_RELEASE_LEVEL AND
         l_move_order_type = G_MOVE_ORDER_PICK_WAVE THEN
       --  IF (l_debug = 1) THEN print_debug('PATCHSET J -- BULK PICKING --- START',4); END IF;

          IF l_task_rec_old_mmtt.transaction_temp_id = l_task_rec_old_mmtt.parent_line_id THEN
          -- copy the lot and serial to the parents
                  IF (l_debug = 1) THEN
                  print_debug('calling duplicate_lot_serial_in_parent for the parent line ....',4);
                  END IF;
                  Duplicate_lot_serial_in_parent(p_task_id,x_return_status,x_msg_count,x_msg_data);
                  if (x_return_status <> fnd_api.g_ret_sts_success) then
                      IF (l_debug = 1) THEN
                           print_debug('split_task 1000- error in duplicate_lot_serial_in_parent ', 4);
                      END IF;
                      -- change to unexpected error
                      x_return_status  := fnd_api.g_ret_sts_unexp_error;
                  end if;
          END IF;
        --  IF (l_debug = 1) THEN print_debug('PATCHSET J -- BULK PICKING --- END',4); END IF;
       end if; -- end of patchset J bulk picking ----------

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO sp_task_split;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('split_task: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO sp_task_split;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('WMS_Task_Dispatch_Engine.split_task', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('split_task: Other exception ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
  END split_task;

  PROCEDURE insert_mmtt(l_mmtt_rec mtl_material_transactions_temp%ROWTYPE) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    INSERT INTO mtl_material_transactions_temp
                (
                 transaction_header_id
               , transaction_temp_id
               , source_code
               , source_line_id
               , transaction_mode
               , lock_flag
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , request_id
               , program_application_id
               , program_id
               , program_update_date
               , inventory_item_id
               , revision
               , organization_id
               , subinventory_code
               , locator_id
               , transaction_quantity
               , primary_quantity
               , transaction_uom
               , transaction_cost
               , transaction_type_id
               , transaction_action_id
               , transaction_source_type_id
               , transaction_source_id
               , transaction_source_name
               , transaction_date
               , acct_period_id
               , distribution_account_id
               , transaction_reference
               , requisition_line_id
               , requisition_distribution_id
               , reason_id
               , lot_number
               , lot_expiration_date
               , serial_number
               , receiving_document
               , demand_id
               , rcv_transaction_id
               , move_transaction_id
               , completion_transaction_id
               , wip_entity_type
               , schedule_id
               , repetitive_line_id
               , employee_code
               , primary_switch
               , schedule_update_code
               , setup_teardown_code
               , item_ordering
               , negative_req_flag
               , operation_seq_num
               , picking_line_id
               , trx_source_line_id
               , trx_source_delivery_id
               , physical_adjustment_id
               , cycle_count_id
               , rma_line_id
               , customer_ship_id
               , currency_code
               , currency_conversion_rate
               , currency_conversion_type
               , currency_conversion_date
               , ussgl_transaction_code
               , vendor_lot_number
               , encumbrance_account
               , encumbrance_amount
               , ship_to_location
               , shipment_number
               , transfer_cost
               , transportation_cost
               , transportation_account
               , freight_code
               , containers
               , waybill_airbill
               , expected_arrival_date
               , transfer_subinventory
               , transfer_organization
               , transfer_to_location
               , new_average_cost
               , value_change
               , percentage_change
               , material_allocation_temp_id
               , demand_source_header_id
               , demand_source_line
               , demand_source_delivery
               , item_segments
               , item_description
               , item_trx_enabled_flag
               , item_location_control_code
               , item_restrict_subinv_code
               , item_restrict_locators_code
               , item_revision_qty_control_code
               , item_primary_uom_code
               , item_uom_class
               , item_shelf_life_code
               , item_shelf_life_days
               , item_lot_control_code
               , item_serial_control_code
               , item_inventory_asset_flag
               , allowed_units_lookup_code
               , department_id
               , department_code
               , wip_supply_type
               , supply_subinventory
               , supply_locator_id
               , valid_subinventory_flag
               , valid_locator_flag
               , locator_segments
               , current_locator_control_code
               , number_of_lots_entered
               , wip_commit_flag
               , next_lot_number
               , lot_alpha_prefix
               , next_serial_number
               , serial_alpha_prefix
               , shippable_flag
               , posting_flag
               , required_flag
               , process_flag
               , ERROR_CODE
               , error_explanation
               , attribute_category
               , attribute1
               , attribute2
               , attribute3
               , attribute4
               , attribute5
               , attribute6
               , attribute7
               , attribute8
               , attribute9
               , attribute10
               , attribute11
               , attribute12
               , attribute13
               , attribute14
               , attribute15
               , movement_id
               , reservation_quantity
               , shipped_quantity
               , transaction_line_number
               , task_id
               , to_task_id
               , source_task_id
               , project_id
               , source_project_id
               , pa_expenditure_org_id
               , to_project_id
               , expenditure_type
               , final_completion_flag
               , transfer_percentage
               , transaction_sequence_id
               , material_account
               , material_overhead_account
               , resource_account
               , outside_processing_account
               , overhead_account
               , flow_schedule
               , cost_group_id
               , transfer_cost_group_id
               , demand_class
               , qa_collection_id
               , kanban_card_id
               , overcompletion_transaction_qty
               , overcompletion_primary_qty
               , overcompletion_transaction_id
               , end_item_unit_number
               , scheduled_payback_date
               , line_type_code
               , parent_transaction_temp_id
               , put_away_strategy_id
               , put_away_rule_id
               , pick_strategy_id
               , pick_rule_id
               , move_order_line_id
               , task_group_id
               , pick_slip_number
               , reservation_id
               , common_bom_seq_id
               , common_routing_seq_id
               , org_cost_group_id
               , cost_type_id
               , transaction_status
               , standard_operation_id
               , task_priority
               , wms_task_type
               , parent_line_id
               , lpn_id
               , transfer_lpn_id
               , wms_task_status
               , content_lpn_id
               , container_item_id
               , cartonization_id
               , pick_slip_date
               , rebuild_item_id
               , rebuild_serial_number
               , rebuild_activity_id
               , rebuild_job_name
               , organization_type
               , transfer_organization_type
               , owning_organization_id
               , owning_tp_type
               , xfr_owning_organization_id
               , transfer_owning_tp_type
               , planning_organization_id
               , planning_tp_type
               , xfr_planning_organization_id
               , transfer_planning_tp_type
               , secondary_uom_code
               , secondary_transaction_quantity
               , transaction_batch_id
               , transaction_batch_seq
               , allocated_lpn_id
               , schedule_number
               , scheduled_flag
               , class_code
               , schedule_group
               , build_sequence
               , bom_revision
               , routing_revision
               , bom_revision_date
               , routing_revision_date
               , alternate_bom_designator
               , alternate_routing_designator
               , operation_plan_id
               , serial_allocated_flag
               , move_order_header_id
                )
         VALUES (
                 l_mmtt_rec.transaction_header_id
               , l_mmtt_rec.transaction_temp_id
               , l_mmtt_rec.source_code
               , l_mmtt_rec.source_line_id
               , l_mmtt_rec.transaction_mode
               , l_mmtt_rec.lock_flag
               , l_mmtt_rec.last_update_date
               , l_mmtt_rec.last_updated_by
               , l_mmtt_rec.creation_date
               , l_mmtt_rec.created_by
               , l_mmtt_rec.last_update_login
               , l_mmtt_rec.request_id
               , l_mmtt_rec.program_application_id
               , l_mmtt_rec.program_id
               , l_mmtt_rec.program_update_date
               , l_mmtt_rec.inventory_item_id
               , l_mmtt_rec.revision
               , l_mmtt_rec.organization_id
               , l_mmtt_rec.subinventory_code
               , l_mmtt_rec.locator_id
               , l_mmtt_rec.transaction_quantity
               , l_mmtt_rec.primary_quantity
               , l_mmtt_rec.transaction_uom
               , l_mmtt_rec.transaction_cost
               , l_mmtt_rec.transaction_type_id
               , l_mmtt_rec.transaction_action_id
               , l_mmtt_rec.transaction_source_type_id
               , l_mmtt_rec.transaction_source_id
               , l_mmtt_rec.transaction_source_name
               , l_mmtt_rec.transaction_date
               , l_mmtt_rec.acct_period_id
               , l_mmtt_rec.distribution_account_id
               , l_mmtt_rec.transaction_reference
               , l_mmtt_rec.requisition_line_id
               , l_mmtt_rec.requisition_distribution_id
               , l_mmtt_rec.reason_id
               , l_mmtt_rec.lot_number
               , l_mmtt_rec.lot_expiration_date
               , l_mmtt_rec.serial_number
               , l_mmtt_rec.receiving_document
               , l_mmtt_rec.demand_id
               , l_mmtt_rec.rcv_transaction_id
               , l_mmtt_rec.move_transaction_id
               , l_mmtt_rec.completion_transaction_id
               , l_mmtt_rec.wip_entity_type
               , l_mmtt_rec.schedule_id
               , l_mmtt_rec.repetitive_line_id
               , l_mmtt_rec.employee_code
               , l_mmtt_rec.primary_switch
               , l_mmtt_rec.schedule_update_code
               , l_mmtt_rec.setup_teardown_code
               , l_mmtt_rec.item_ordering
               , l_mmtt_rec.negative_req_flag
               , l_mmtt_rec.operation_seq_num
               , l_mmtt_rec.picking_line_id
               , l_mmtt_rec.trx_source_line_id
               , l_mmtt_rec.trx_source_delivery_id
               , l_mmtt_rec.physical_adjustment_id
               , l_mmtt_rec.cycle_count_id
               , l_mmtt_rec.rma_line_id
               , l_mmtt_rec.customer_ship_id
               , l_mmtt_rec.currency_code
               , l_mmtt_rec.currency_conversion_rate
               , l_mmtt_rec.currency_conversion_type
               , l_mmtt_rec.currency_conversion_date
               , l_mmtt_rec.ussgl_transaction_code
               , l_mmtt_rec.vendor_lot_number
               , l_mmtt_rec.encumbrance_account
               , l_mmtt_rec.encumbrance_amount
               , l_mmtt_rec.ship_to_location
               , l_mmtt_rec.shipment_number
               , l_mmtt_rec.transfer_cost
               , l_mmtt_rec.transportation_cost
               , l_mmtt_rec.transportation_account
               , l_mmtt_rec.freight_code
               , l_mmtt_rec.containers
               , l_mmtt_rec.waybill_airbill
               , l_mmtt_rec.expected_arrival_date
               , l_mmtt_rec.transfer_subinventory
               , l_mmtt_rec.transfer_organization
               , l_mmtt_rec.transfer_to_location
               , l_mmtt_rec.new_average_cost
               , l_mmtt_rec.value_change
               , l_mmtt_rec.percentage_change
               , l_mmtt_rec.material_allocation_temp_id
               , l_mmtt_rec.demand_source_header_id
               , l_mmtt_rec.demand_source_line
               , l_mmtt_rec.demand_source_delivery
               , l_mmtt_rec.item_segments
               , l_mmtt_rec.item_description
               , l_mmtt_rec.item_trx_enabled_flag
               , l_mmtt_rec.item_location_control_code
               , l_mmtt_rec.item_restrict_subinv_code
               , l_mmtt_rec.item_restrict_locators_code
               , l_mmtt_rec.item_revision_qty_control_code
               , l_mmtt_rec.item_primary_uom_code
               , l_mmtt_rec.item_uom_class
               , l_mmtt_rec.item_shelf_life_code
               , l_mmtt_rec.item_shelf_life_days
               , l_mmtt_rec.item_lot_control_code
               , l_mmtt_rec.item_serial_control_code
               , l_mmtt_rec.item_inventory_asset_flag
               , l_mmtt_rec.allowed_units_lookup_code
               , l_mmtt_rec.department_id
               , l_mmtt_rec.department_code
               , l_mmtt_rec.wip_supply_type
               , l_mmtt_rec.supply_subinventory
               , l_mmtt_rec.supply_locator_id
               , l_mmtt_rec.valid_subinventory_flag
               , l_mmtt_rec.valid_locator_flag
               , l_mmtt_rec.locator_segments
               , l_mmtt_rec.current_locator_control_code
               , l_mmtt_rec.number_of_lots_entered
               , l_mmtt_rec.wip_commit_flag
               , l_mmtt_rec.next_lot_number
               , l_mmtt_rec.lot_alpha_prefix
               , l_mmtt_rec.next_serial_number
               , l_mmtt_rec.serial_alpha_prefix
               , l_mmtt_rec.shippable_flag
               , l_mmtt_rec.posting_flag
               , l_mmtt_rec.required_flag
               , l_mmtt_rec.process_flag
               , l_mmtt_rec.ERROR_CODE
               , l_mmtt_rec.error_explanation
               , l_mmtt_rec.attribute_category
               , l_mmtt_rec.attribute1
               , l_mmtt_rec.attribute2
               , l_mmtt_rec.attribute3
               , l_mmtt_rec.attribute4
               , l_mmtt_rec.attribute5
               , l_mmtt_rec.attribute6
               , l_mmtt_rec.attribute7
               , l_mmtt_rec.attribute8
               , l_mmtt_rec.attribute9
               , l_mmtt_rec.attribute10
               , l_mmtt_rec.attribute11
               , l_mmtt_rec.attribute12
               , l_mmtt_rec.attribute13
               , l_mmtt_rec.attribute14
               , l_mmtt_rec.attribute15
               , l_mmtt_rec.movement_id
               , l_mmtt_rec.reservation_quantity
               , l_mmtt_rec.shipped_quantity
               , l_mmtt_rec.transaction_line_number
               , l_mmtt_rec.task_id
               , l_mmtt_rec.to_task_id
               , l_mmtt_rec.source_task_id
               , l_mmtt_rec.project_id
               , l_mmtt_rec.source_project_id
               , l_mmtt_rec.pa_expenditure_org_id
               , l_mmtt_rec.to_project_id
               , l_mmtt_rec.expenditure_type
               , l_mmtt_rec.final_completion_flag
               , l_mmtt_rec.transfer_percentage
               , l_mmtt_rec.transaction_sequence_id
               , l_mmtt_rec.material_account
               , l_mmtt_rec.material_overhead_account
               , l_mmtt_rec.resource_account
               , l_mmtt_rec.outside_processing_account
               , l_mmtt_rec.overhead_account
               , l_mmtt_rec.flow_schedule
               , l_mmtt_rec.cost_group_id
               , l_mmtt_rec.transfer_cost_group_id
               , l_mmtt_rec.demand_class
               , l_mmtt_rec.qa_collection_id
               , l_mmtt_rec.kanban_card_id
               , l_mmtt_rec.overcompletion_transaction_qty
               , l_mmtt_rec.overcompletion_primary_qty
               , l_mmtt_rec.overcompletion_transaction_id
               , l_mmtt_rec.end_item_unit_number
               , l_mmtt_rec.scheduled_payback_date
               , l_mmtt_rec.line_type_code
               , l_mmtt_rec.parent_transaction_temp_id
               , l_mmtt_rec.put_away_strategy_id
               , l_mmtt_rec.put_away_rule_id
               , l_mmtt_rec.pick_strategy_id
               , l_mmtt_rec.pick_rule_id
               , l_mmtt_rec.move_order_line_id
               , l_mmtt_rec.task_group_id
               , l_mmtt_rec.pick_slip_number
               , l_mmtt_rec.reservation_id
               , l_mmtt_rec.common_bom_seq_id
               , l_mmtt_rec.common_routing_seq_id
               , l_mmtt_rec.org_cost_group_id
               , l_mmtt_rec.cost_type_id
               , l_mmtt_rec.transaction_status
               , l_mmtt_rec.standard_operation_id
               , l_mmtt_rec.task_priority
               , l_mmtt_rec.wms_task_type
               , l_mmtt_rec.parent_line_id
               , l_mmtt_rec.lpn_id
               , l_mmtt_rec.transfer_lpn_id
               , l_mmtt_rec.wms_task_status
               , l_mmtt_rec.content_lpn_id
               , l_mmtt_rec.container_item_id
               , l_mmtt_rec.cartonization_id
               , l_mmtt_rec.pick_slip_date
               , l_mmtt_rec.rebuild_item_id
               , l_mmtt_rec.rebuild_serial_number
               , l_mmtt_rec.rebuild_activity_id
               , l_mmtt_rec.rebuild_job_name
               , l_mmtt_rec.organization_type
               , l_mmtt_rec.transfer_organization_type
               , l_mmtt_rec.owning_organization_id
               , l_mmtt_rec.owning_tp_type
               , l_mmtt_rec.xfr_owning_organization_id
               , l_mmtt_rec.transfer_owning_tp_type
               , l_mmtt_rec.planning_organization_id
               , l_mmtt_rec.planning_tp_type
               , l_mmtt_rec.xfr_planning_organization_id
               , l_mmtt_rec.transfer_planning_tp_type
               , l_mmtt_rec.secondary_uom_code
               , l_mmtt_rec.secondary_transaction_quantity
               , l_mmtt_rec.transaction_batch_id
               , l_mmtt_rec.transaction_batch_seq
               , l_mmtt_rec.allocated_lpn_id
               , l_mmtt_rec.schedule_number
               , l_mmtt_rec.scheduled_flag
               , l_mmtt_rec.class_code
               , l_mmtt_rec.schedule_group
               , l_mmtt_rec.build_sequence
               , l_mmtt_rec.bom_revision
               , l_mmtt_rec.routing_revision
               , l_mmtt_rec.bom_revision_date
               , l_mmtt_rec.routing_revision_date
               , l_mmtt_rec.alternate_bom_designator
               , l_mmtt_rec.alternate_routing_designator
               , l_mmtt_rec.operation_plan_id
               , l_mmtt_rec.serial_allocated_flag
               , l_mmtt_rec.move_order_header_id
                );
  END insert_mmtt;

  PROCEDURE insert_wct(l_wct_rec wms_cartonization_temp%ROWTYPE) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    INSERT INTO wms_cartonization_temp
                (
                 transaction_header_id
               , transaction_temp_id
               , source_code
               , source_line_id
               , transaction_mode
               , lock_flag
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , request_id
               , program_application_id
               , program_id
               , program_update_date
               , inventory_item_id
               , revision
               , organization_id
               , subinventory_code
               , locator_id
               , transaction_quantity
               , primary_quantity
               , transaction_uom
               , transaction_cost
               , transaction_type_id
               , transaction_action_id
               , transaction_source_type_id
               , transaction_source_id
               , transaction_source_name
               , transaction_date
               , acct_period_id
               , distribution_account_id
               , transaction_reference
               , requisition_line_id
               , requisition_distribution_id
               , reason_id
               , lot_number
               , lot_expiration_date
               , serial_number
               , receiving_document
               , demand_id
               , rcv_transaction_id
               , move_transaction_id
               , completion_transaction_id
               , wip_entity_type
               , schedule_id
               , repetitive_line_id
               , employee_code
               , primary_switch
               , schedule_update_code
               , setup_teardown_code
               , item_ordering
               , negative_req_flag
               , operation_seq_num
               , picking_line_id
               , trx_source_line_id
               , trx_source_delivery_id
               , physical_adjustment_id
               , cycle_count_id
               , rma_line_id
               , customer_ship_id
               , currency_code
               , currency_conversion_rate
               , currency_conversion_type
               , currency_conversion_date
               , ussgl_transaction_code
               , vendor_lot_number
               , encumbrance_account
               , encumbrance_amount
               , ship_to_location
               , shipment_number
               , transfer_cost
               , transportation_cost
               , transportation_account
               , freight_code
               , containers
               , waybill_airbill
               , expected_arrival_date
               , transfer_subinventory
               , transfer_organization
               , transfer_to_location
               , new_average_cost
               , value_change
               , percentage_change
               , material_allocation_temp_id
               , demand_source_header_id
               , demand_source_line
               , demand_source_delivery
               , item_segments
               , item_description
               , item_trx_enabled_flag
               , item_location_control_code
               , item_restrict_subinv_code
               , item_restrict_locators_code
               , item_revision_qty_control_code
               , item_primary_uom_code
               , item_uom_class
               , item_shelf_life_code
               , item_shelf_life_days
               , item_lot_control_code
               , item_serial_control_code
               , item_inventory_asset_flag
               , allowed_units_lookup_code
               , department_id
               , department_code
               , wip_supply_type
               , supply_subinventory
               , supply_locator_id
               , valid_subinventory_flag
               , valid_locator_flag
               , locator_segments
               , current_locator_control_code
               , number_of_lots_entered
               , wip_commit_flag
               , next_lot_number
               , lot_alpha_prefix
               , next_serial_number
               , serial_alpha_prefix
               , shippable_flag
               , posting_flag
               , required_flag
               , process_flag
               , ERROR_CODE
               , error_explanation
               , attribute_category
               , attribute1
               , attribute2
               , attribute3
               , attribute4
               , attribute5
               , attribute6
               , attribute7
               , attribute8
               , attribute9
               , attribute10
               , attribute11
               , attribute12
               , attribute13
               , attribute14
               , attribute15
               , movement_id
               , reservation_quantity
               , shipped_quantity
               , transaction_line_number
               , task_id
               , to_task_id
               , source_task_id
               , project_id
               , source_project_id
               , pa_expenditure_org_id
               , to_project_id
               , expenditure_type
               , final_completion_flag
               , transfer_percentage
               , transaction_sequence_id
               , material_account
               , material_overhead_account
               , resource_account
               , outside_processing_account
               , overhead_account
               , flow_schedule
               , cost_group_id
               , transfer_cost_group_id
               , demand_class
               , qa_collection_id
               , kanban_card_id
               , overcompletion_transaction_qty
               , overcompletion_primary_qty
               , overcompletion_transaction_id
               , end_item_unit_number
               , scheduled_payback_date
               , line_type_code
               , parent_transaction_temp_id
               , put_away_strategy_id
               , put_away_rule_id
               , pick_strategy_id
               , pick_rule_id
               , move_order_line_id
               , task_group_id
               , pick_slip_number
               , reservation_id
               , common_bom_seq_id
               , common_routing_seq_id
               , org_cost_group_id
               , cost_type_id
               , transaction_status
               , standard_operation_id
               , task_priority
               , wms_task_type
               , parent_line_id
               , lpn_id
               , transfer_lpn_id
               , wms_task_status
               , content_lpn_id
               , container_item_id
               , cartonization_id
               , pick_slip_date
               , rebuild_item_id
               , rebuild_serial_number
               , rebuild_activity_id
               , rebuild_job_name
               , organization_type
               , transfer_organization_type
               , owning_organization_id
               , owning_tp_type
               , xfr_owning_organization_id
               , transfer_owning_tp_type
               , planning_organization_id
               , planning_tp_type
               , xfr_planning_organization_id
               , transfer_planning_tp_type
               , secondary_uom_code
               , secondary_transaction_quantity
               , transaction_batch_id
               , transaction_batch_seq
               , allocated_lpn_id
               , schedule_number
               , scheduled_flag
               , class_code
               , schedule_group
               , build_sequence
               , bom_revision
               , routing_revision
               , bom_revision_date
               , routing_revision_date
               , alternate_bom_designator
               , alternate_routing_designator
               , operation_plan_id
               , serial_allocated_flag
               , move_order_header_id
                )
         VALUES (
                 l_wct_rec.transaction_header_id
               , l_wct_rec.transaction_temp_id
               , l_wct_rec.source_code
               , l_wct_rec.source_line_id
               , l_wct_rec.transaction_mode
               , l_wct_rec.lock_flag
               , l_wct_rec.last_update_date
               , l_wct_rec.last_updated_by
               , l_wct_rec.creation_date
               , l_wct_rec.created_by
               , l_wct_rec.last_update_login
               , l_wct_rec.request_id
               , l_wct_rec.program_application_id
               , l_wct_rec.program_id
               , l_wct_rec.program_update_date
               , l_wct_rec.inventory_item_id
               , l_wct_rec.revision
               , l_wct_rec.organization_id
               , l_wct_rec.subinventory_code
               , l_wct_rec.locator_id
               , l_wct_rec.transaction_quantity
               , l_wct_rec.primary_quantity
               , l_wct_rec.transaction_uom
               , l_wct_rec.transaction_cost
               , l_wct_rec.transaction_type_id
               , l_wct_rec.transaction_action_id
               , l_wct_rec.transaction_source_type_id
               , l_wct_rec.transaction_source_id
               , l_wct_rec.transaction_source_name
               , l_wct_rec.transaction_date
               , l_wct_rec.acct_period_id
               , l_wct_rec.distribution_account_id
               , l_wct_rec.transaction_reference
               , l_wct_rec.requisition_line_id
               , l_wct_rec.requisition_distribution_id
               , l_wct_rec.reason_id
               , l_wct_rec.lot_number
               , l_wct_rec.lot_expiration_date
               , l_wct_rec.serial_number
               , l_wct_rec.receiving_document
               , l_wct_rec.demand_id
               , l_wct_rec.rcv_transaction_id
               , l_wct_rec.move_transaction_id
               , l_wct_rec.completion_transaction_id
               , l_wct_rec.wip_entity_type
               , l_wct_rec.schedule_id
               , l_wct_rec.repetitive_line_id
               , l_wct_rec.employee_code
               , l_wct_rec.primary_switch
               , l_wct_rec.schedule_update_code
               , l_wct_rec.setup_teardown_code
               , l_wct_rec.item_ordering
               , l_wct_rec.negative_req_flag
               , l_wct_rec.operation_seq_num
               , l_wct_rec.picking_line_id
               , l_wct_rec.trx_source_line_id
               , l_wct_rec.trx_source_delivery_id
               , l_wct_rec.physical_adjustment_id
               , l_wct_rec.cycle_count_id
               , l_wct_rec.rma_line_id
               , l_wct_rec.customer_ship_id
               , l_wct_rec.currency_code
               , l_wct_rec.currency_conversion_rate
               , l_wct_rec.currency_conversion_type
               , l_wct_rec.currency_conversion_date
               , l_wct_rec.ussgl_transaction_code
               , l_wct_rec.vendor_lot_number
               , l_wct_rec.encumbrance_account
               , l_wct_rec.encumbrance_amount
               , l_wct_rec.ship_to_location
               , l_wct_rec.shipment_number
               , l_wct_rec.transfer_cost
               , l_wct_rec.transportation_cost
               , l_wct_rec.transportation_account
               , l_wct_rec.freight_code
               , l_wct_rec.containers
               , l_wct_rec.waybill_airbill
               , l_wct_rec.expected_arrival_date
               , l_wct_rec.transfer_subinventory
               , l_wct_rec.transfer_organization
               , l_wct_rec.transfer_to_location
               , l_wct_rec.new_average_cost
               , l_wct_rec.value_change
               , l_wct_rec.percentage_change
               , l_wct_rec.material_allocation_temp_id
               , l_wct_rec.demand_source_header_id
               , l_wct_rec.demand_source_line
               , l_wct_rec.demand_source_delivery
               , l_wct_rec.item_segments
               , l_wct_rec.item_description
               , l_wct_rec.item_trx_enabled_flag
               , l_wct_rec.item_location_control_code
               , l_wct_rec.item_restrict_subinv_code
               , l_wct_rec.item_restrict_locators_code
               , l_wct_rec.item_revision_qty_control_code
               , l_wct_rec.item_primary_uom_code
               , l_wct_rec.item_uom_class
               , l_wct_rec.item_shelf_life_code
               , l_wct_rec.item_shelf_life_days
               , l_wct_rec.item_lot_control_code
               , l_wct_rec.item_serial_control_code
               , l_wct_rec.item_inventory_asset_flag
               , l_wct_rec.allowed_units_lookup_code
               , l_wct_rec.department_id
               , l_wct_rec.department_code
               , l_wct_rec.wip_supply_type
               , l_wct_rec.supply_subinventory
               , l_wct_rec.supply_locator_id
               , l_wct_rec.valid_subinventory_flag
               , l_wct_rec.valid_locator_flag
               , l_wct_rec.locator_segments
               , l_wct_rec.current_locator_control_code
               , l_wct_rec.number_of_lots_entered
               , l_wct_rec.wip_commit_flag
               , l_wct_rec.next_lot_number
               , l_wct_rec.lot_alpha_prefix
               , l_wct_rec.next_serial_number
               , l_wct_rec.serial_alpha_prefix
               , l_wct_rec.shippable_flag
               , l_wct_rec.posting_flag
               , l_wct_rec.required_flag
               , l_wct_rec.process_flag
               , l_wct_rec.ERROR_CODE
               , l_wct_rec.error_explanation
               , l_wct_rec.attribute_category
               , l_wct_rec.attribute1
               , l_wct_rec.attribute2
               , l_wct_rec.attribute3
               , l_wct_rec.attribute4
               , l_wct_rec.attribute5
               , l_wct_rec.attribute6
               , l_wct_rec.attribute7
               , l_wct_rec.attribute8
               , l_wct_rec.attribute9
               , l_wct_rec.attribute10
               , l_wct_rec.attribute11
               , l_wct_rec.attribute12
               , l_wct_rec.attribute13
               , l_wct_rec.attribute14
               , l_wct_rec.attribute15
               , l_wct_rec.movement_id
               , l_wct_rec.reservation_quantity
               , l_wct_rec.shipped_quantity
               , l_wct_rec.transaction_line_number
               , l_wct_rec.task_id
               , l_wct_rec.to_task_id
               , l_wct_rec.source_task_id
               , l_wct_rec.project_id
               , l_wct_rec.source_project_id
               , l_wct_rec.pa_expenditure_org_id
               , l_wct_rec.to_project_id
               , l_wct_rec.expenditure_type
               , l_wct_rec.final_completion_flag
               , l_wct_rec.transfer_percentage
               , l_wct_rec.transaction_sequence_id
               , l_wct_rec.material_account
               , l_wct_rec.material_overhead_account
               , l_wct_rec.resource_account
               , l_wct_rec.outside_processing_account
               , l_wct_rec.overhead_account
               , l_wct_rec.flow_schedule
               , l_wct_rec.cost_group_id
               , l_wct_rec.transfer_cost_group_id
               , l_wct_rec.demand_class
               , l_wct_rec.qa_collection_id
               , l_wct_rec.kanban_card_id
               , l_wct_rec.overcompletion_transaction_qty
               , l_wct_rec.overcompletion_primary_qty
               , l_wct_rec.overcompletion_transaction_id
               , l_wct_rec.end_item_unit_number
               , l_wct_rec.scheduled_payback_date
               , l_wct_rec.line_type_code
               , l_wct_rec.parent_transaction_temp_id
               , l_wct_rec.put_away_strategy_id
               , l_wct_rec.put_away_rule_id
               , l_wct_rec.pick_strategy_id
               , l_wct_rec.pick_rule_id
               , l_wct_rec.move_order_line_id
               , l_wct_rec.task_group_id
               , l_wct_rec.pick_slip_number
               , l_wct_rec.reservation_id
               , l_wct_rec.common_bom_seq_id
               , l_wct_rec.common_routing_seq_id
               , l_wct_rec.org_cost_group_id
               , l_wct_rec.cost_type_id
               , l_wct_rec.transaction_status
               , l_wct_rec.standard_operation_id
               , l_wct_rec.task_priority
               , l_wct_rec.wms_task_type
               , l_wct_rec.parent_line_id
               , l_wct_rec.lpn_id
               , l_wct_rec.transfer_lpn_id
               , l_wct_rec.wms_task_status
               , l_wct_rec.content_lpn_id
               , l_wct_rec.container_item_id
               , l_wct_rec.cartonization_id
               , l_wct_rec.pick_slip_date
               , l_wct_rec.rebuild_item_id
               , l_wct_rec.rebuild_serial_number
               , l_wct_rec.rebuild_activity_id
               , l_wct_rec.rebuild_job_name
               , l_wct_rec.organization_type
               , l_wct_rec.transfer_organization_type
               , l_wct_rec.owning_organization_id
               , l_wct_rec.owning_tp_type
               , l_wct_rec.xfr_owning_organization_id
               , l_wct_rec.transfer_owning_tp_type
               , l_wct_rec.planning_organization_id
               , l_wct_rec.planning_tp_type
               , l_wct_rec.xfr_planning_organization_id
               , l_wct_rec.transfer_planning_tp_type
               , l_wct_rec.secondary_uom_code
               , l_wct_rec.secondary_transaction_quantity
               , l_wct_rec.transaction_batch_id
               , l_wct_rec.transaction_batch_seq
               , l_wct_rec.allocated_lpn_id
               , l_wct_rec.schedule_number
               , l_wct_rec.scheduled_flag
               , l_wct_rec.class_code
               , l_wct_rec.schedule_group
               , l_wct_rec.build_sequence
               , l_wct_rec.bom_revision
               , l_wct_rec.routing_revision
               , l_wct_rec.bom_revision_date
               , l_wct_rec.routing_revision_date
               , l_wct_rec.alternate_bom_designator
               , l_wct_rec.alternate_routing_designator
               , l_wct_rec.operation_plan_id
               , l_wct_rec.serial_allocated_flag
               , l_wct_rec.move_order_header_id
                );
  END insert_wct;

  PROCEDURE insert_mtlt --Bug 9473783 added procedure
  (p_transaction_temp_id            NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2)
   IS

   CURSOR mmtt IS
   SELECT * FROM mtl_material_transactions_temp
   WHERE transaction_temp_id = p_transaction_temp_id ;

  l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  l_mmtt_rec mtl_material_transactions_temp%ROWTYPE;
  BEGIN
   x_return_status  := fnd_api.g_ret_sts_success;

  OPEN mmtt;
  FETCH mmtt INTO l_mmtt_rec;

  CLOSE mmtt;

  INSERT INTO mtl_transaction_lots_temp
                  (
                   transaction_temp_id
                 , last_update_date
                 , last_updated_by
                 , creation_date
                 , created_by
                 , last_update_login
                 , request_id
                 , program_application_id
                 , program_id
                 , program_update_date
                 , transaction_quantity
                 , primary_quantity
                 , secondary_quantity         --INVCONV Mercy Thomas 09/24/2004
                 , secondary_unit_of_measure  --INVCONV Mercy Thomas 09/24/2004
                 , lot_number
                 , lot_expiration_date
                 , group_header_id
                 , reason_id
                  )
        VALUES ( l_mmtt_rec.transaction_temp_id
              , l_mmtt_rec.last_update_date
              , l_mmtt_rec.last_updated_by
              , l_mmtt_rec.creation_date
              , l_mmtt_rec.created_by
              , l_mmtt_rec.last_update_login
              , l_mmtt_rec.request_id
              , l_mmtt_rec.program_application_id
              , l_mmtt_rec.program_id
              , l_mmtt_rec.program_update_date
              , l_mmtt_rec.transaction_quantity
              , l_mmtt_rec.primary_quantity
              , l_mmtt_rec.secondary_transaction_quantity
              , l_mmtt_rec.secondary_uom_code
              , l_mmtt_rec.lot_number
              , l_mmtt_rec.lot_expiration_date
              , l_mmtt_rec.transaction_header_id
              , l_mmtt_rec.reason_id  );


     EXCEPTION
    WHEN OTHERS THEN
    IF (l_debug = 1) THEN
          print_debug('INSERT_MTLT : Exception Occured ' || substrb(SQLERRM,1,200), 1);
        END IF;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

  END insert_mtlt;

END wms_task_dispatch_engine;

/
