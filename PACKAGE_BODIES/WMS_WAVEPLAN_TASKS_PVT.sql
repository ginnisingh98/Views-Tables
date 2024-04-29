--------------------------------------------------------
--  DDL for Package Body WMS_WAVEPLAN_TASKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_WAVEPLAN_TASKS_PVT" AS
/* $Header: WMSVTKPB.pls 120.45.12010000.14 2010/04/12 23:21:15 sfulzele ship $ */
--
   g_record_count                   NUMBER;
-- Messages
   g_task_updated                   wms_waveplan_tasks_temp.error%TYPE;
   g_task_saved                     wms_waveplan_tasks_temp.error%TYPE;
   g_cannot_update_putaway          wms_waveplan_tasks_temp.error%TYPE;
   g_cannot_update_staging_move     wms_waveplan_tasks_temp.error%TYPE;
   g_cannot_unrelease_cc            wms_waveplan_tasks_temp.error%TYPE;
   g_summarized_time                wms_waveplan_tasks_temp.error%TYPE;
   g_cannot_summarize_time          wms_waveplan_tasks_temp.error%TYPE;
   g_time_uom_error                 wms_waveplan_tasks_temp.error%TYPE;
   g_summarized_volume              wms_waveplan_tasks_temp.error%TYPE;
   g_cannot_summarize_vol           wms_waveplan_tasks_temp.error%TYPE;
   g_vol_uom_error                  wms_waveplan_tasks_temp.error%TYPE;
   g_no_item_vol                    wms_waveplan_tasks_temp.error%TYPE;
   g_summarized_weight              wms_waveplan_tasks_temp.error%TYPE;
   g_cannot_summarize_wt            wms_waveplan_tasks_temp.error%TYPE;
   g_wt_uom_error                   wms_waveplan_tasks_temp.error%TYPE;
   g_no_item_wt                     wms_waveplan_tasks_temp.error%TYPE;
   g_plan_cancelled                 wms_waveplan_tasks_temp.error%TYPE;
-- Global variables to determine if a column is visible or not
   g_allocated_lpn_visible          jtf_custom_grid_cols.visible_flag%TYPE;
   g_assembly_visible               jtf_custom_grid_cols.visible_flag%TYPE;
   g_carrier_visible                jtf_custom_grid_cols.visible_flag%TYPE;
   g_cartonization_lpn_visible      jtf_custom_grid_cols.visible_flag%TYPE;
   g_container_item_visible         jtf_custom_grid_cols.visible_flag%TYPE;
   g_content_lpn_visible            jtf_custom_grid_cols.visible_flag%TYPE;
   g_customer_visible               jtf_custom_grid_cols.visible_flag%TYPE;
   g_delivery_visible               jtf_custom_grid_cols.visible_flag%TYPE;
   g_department_visible             jtf_custom_grid_cols.visible_flag%TYPE;
   g_line_visible                   jtf_custom_grid_cols.visible_flag%TYPE;
   g_line_number_visible            jtf_custom_grid_cols.visible_flag%TYPE;
   g_machine_resource_visible       jtf_custom_grid_cols.visible_flag%TYPE;
   g_person_visible                 jtf_custom_grid_cols.visible_flag%TYPE;
   g_person_resource_visible        jtf_custom_grid_cols.visible_flag%TYPE;
   g_ship_method_visible            jtf_custom_grid_cols.visible_flag%TYPE;
   g_ship_to_country_visible        jtf_custom_grid_cols.visible_flag%TYPE;
   g_ship_to_postal_code_visible    jtf_custom_grid_cols.visible_flag%TYPE;
   g_ship_to_state_visible          jtf_custom_grid_cols.visible_flag%TYPE;
   g_source_header_visible          jtf_custom_grid_cols.visible_flag%TYPE;
   g_status_visible                 jtf_custom_grid_cols.visible_flag%TYPE;
   g_task_type_visible              jtf_custom_grid_cols.visible_flag%TYPE;
   g_to_locator_visible             jtf_custom_grid_cols.visible_flag%TYPE;
   g_to_lpn_visible                 jtf_custom_grid_cols.visible_flag%TYPE;
   g_to_organization_code_visible   jtf_custom_grid_cols.visible_flag%TYPE;
   g_transaction_action_visible     jtf_custom_grid_cols.visible_flag%TYPE;
   g_txn_source_type_visible        jtf_custom_grid_cols.visible_flag%TYPE;
   g_operation_plan_visible         jtf_custom_grid_cols.visible_flag%TYPE;
   g_user_task_type_visible         jtf_custom_grid_cols.visible_flag%TYPE;
   g_num_of_child_tasks_visible     jtf_custom_grid_cols.visible_flag%TYPE;
     --bug: 4510849
   g_picked_lpn_visible             jtf_custom_grid_cols.visible_flag%TYPE;
   g_loaded_lpn_visible             jtf_custom_grid_cols.visible_flag%TYPE;
   g_drop_lpn_visible               jtf_custom_grid_cols.visible_flag%TYPE;
--Changed
   g_op_plan_instance_id_visible    jtf_custom_grid_cols.visible_flag%TYPE;
   g_operation_sequence_visible     jtf_custom_grid_cols.visible_flag%TYPE;
   --end of change
   g_from_lpn_visible               jtf_custom_grid_cols.visible_flag%TYPE;

   g_project_enabled_organization   VARCHAR2 (1);
   g_rows_marked                    BOOLEAN                          := FALSE;
   g_final_query                    VARCHAR2 (10000);
   i NUMBER  := 1;

   PROCEDURE DEBUG (
      p_message   VARCHAR2,
      p_module    VARCHAR2 DEFAULT 'Task Planning'
   )
   IS
      l_counter   NUMBER := 1;

   --PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      WHILE l_counter < LENGTH (p_message)
      LOOP
         inv_log_util.TRACE (SUBSTR (p_message, l_counter, 80), p_module);
         l_counter := l_counter + 80;
      END LOOP;

   /*INSERT INTO my_temp_table VALUES (p_message,i);
    i := i+1;
    COMMIT;*/

    RETURN;
   END;

   PROCEDURE wwtt_dump
   IS
      l_debug   NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
      CURSOR cur_wwtt
      IS
         SELECT transaction_temp_id, task_id, is_modified, status_id,
                status_id_original, person_id, person_id_original, priority,
                priority_original
           FROM wms_waveplan_tasks_temp
          WHERE is_modified = 'Y';
   BEGIN
     IF l_debug = 1 then
       FOR rec_wwtt IN cur_wwtt
       LOOP
	   DEBUG ('TRANSACTION_TEMP_ID: ' || rec_wwtt.transaction_temp_id);
           DEBUG ('TASK_ID: ' || rec_wwtt.task_id);
           DEBUG ('IS_MODIFIED: ' || rec_wwtt.is_modified);
           DEBUG ('STATUS_ID: ' || rec_wwtt.status_id);
           DEBUG ('STATUS_ID_ORIGINAL: ' || rec_wwtt.status_id_original);
           DEBUG ('PERSON_ID: ' || rec_wwtt.person_id);
           DEBUG ('PERSON_ID_ORIGINAL: ' || rec_wwtt.person_id_original);
           DEBUG ('PRIORITY: ' || rec_wwtt.priority);
           DEBUG ('PRIORITY_ORIGINAL: ' || rec_wwtt.priority_original);
       END LOOP;
     END IF;
   END;

--Procedures for labor estimations
   PROCEDURE mark_rows (
      p_transaction_temp_id   IN              wms_waveplan_tasks_pvt.transaction_temp_table_type,
      p_task_type_id          IN              wms_waveplan_tasks_pvt.task_type_id_table_type,
      x_return_status         OUT NOCOPY      VARCHAR2
   )
   IS
   BEGIN
      x_return_status := 'S';
      FORALL i IN p_transaction_temp_id.FIRST .. p_transaction_temp_id.LAST
         UPDATE wms_waveplan_tasks_temp
            SET RESULT = DECODE (RESULT, NULL, 'X', 'S', 'Y', 'E', 'Z')
          WHERE transaction_temp_id = p_transaction_temp_id (i)
            AND task_type_id = p_task_type_id (i);
      g_rows_marked := TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (SQLERRM, 'Task_planning.mark_rows');
         x_return_status := 'U';
   END mark_rows;

   PROCEDURE unmark_rows
   IS
   BEGIN
      IF g_rows_marked
      THEN
         UPDATE wms_waveplan_tasks_temp
            SET RESULT =
                        DECODE (RESULT,
                                'Y', 'S',
                                'Z', 'E',
                                'X', NULL,
                                RESULT
                               )
          WHERE RESULT IN ('X', 'Y', 'Z');

         g_rows_marked := FALSE;
      END IF;
   END;

-- This procedure populates the global variables that store information if a column
-- is visible or not.
-- We will use these globals to determine if certain columns that are not
-- populated by the base query need to be populated by subsequent queries
   PROCEDURE find_visible_columns
   IS
      TYPE visible_columns_type IS TABLE OF jtf_custom_grid_cols.visible_flag%TYPE;

      visible_columns   visible_columns_type;
      l_user_id         NUMBER;
   BEGIN
      fnd_profile.get ('USER_ID', l_user_id);

      SELECT   NVL (jcgc.visible_flag, jgc.visible_flag)
      BULK COLLECT INTO visible_columns
          FROM jtf_grid_cols_b jgc, jtf_custom_grid_cols jcgc
         WHERE jgc.grid_datasource_name = jcgc.grid_datasource_name(+)
           AND jgc.grid_col_alias = jcgc.grid_col_alias(+)
           AND jgc.grid_datasource_name = 'WMS_WAVEPLAN_TASKS'
           AND jcgc.created_by(+) = l_user_id
           AND jgc.grid_col_alias IN
                  ('ALLOCATED_LPN',
                   'ASSEMBLY',
                   'CARRIER',
                   'CARTONIZATION_LPN',
                   'CONTAINER_ITEM',
                   'CONTENT_LPN',
                   'CUSTOMER',
                   'DELIVERY',
                   'DEPARTMENT',
		   'DROP_LPN', --bug 4510849
                   'FROM_LPN',
                   'LINE',
                   'LINE_NUMBER',
		   'LOADED_LPN', --bug 4510849
                   'MACHINE_RESOURCE_CODE',
                   'NUM_OF_CHILD_TASKS',
                   'OPERATION_PLAN',
                   'OPERATION_SEQUENCE',
                   'OP_PLAN_INSTANCE_ID',
                   'PERSON',
                   'PERSON_RESOURCE_CODE',
		   'PICKED_LPN', --bug 4510849
                   'SHIP_METHOD',
                   'SHIP_TO_COUNTRY',
                   'SHIP_TO_POSTAL_CODE',
                   'SHIP_TO_STATE',
                   'SOURCE_HEADER',
                   'STATUS',
                   'TASK_TYPE',
                   'TO_LOCATOR',
                   'TO_LPN',
                   'TO_ORGANIZATION_CODE',
                   'TRANSACTION_SOURCE_TYPE',
                   'USER_TASK_TYPE'
                  )
      ORDER BY NVL (jcgc.grid_col_alias, jgc.grid_col_alias);

      g_allocated_lpn_visible := visible_columns (1);
      g_assembly_visible := visible_columns (2);
      g_carrier_visible := visible_columns (3);
      g_cartonization_lpn_visible := visible_columns (4);
      g_container_item_visible := visible_columns (5);
      g_content_lpn_visible := visible_columns (6);
      g_customer_visible := visible_columns (7);
      g_delivery_visible := visible_columns (8);
      g_department_visible := visible_columns (9);
      g_drop_lpn_visible := visible_columns(10);	  --bug 4510849
      g_from_lpn_visible := visible_columns(11);
      g_line_visible := visible_columns(12);
      g_line_number_visible := visible_columns (13);
      g_loaded_lpn_visible := visible_columns(14); --bug 4510849
      g_machine_resource_visible := visible_columns (15);
      g_num_of_child_tasks_visible := visible_columns (16);
      g_operation_plan_visible := visible_columns (17);
      g_operation_sequence_visible := visible_columns (18);
      g_op_plan_instance_id_visible := visible_columns (19);
      g_person_visible := visible_columns (20);
      g_person_resource_visible := visible_columns (21);
      g_picked_lpn_visible := visible_columns(22);   --bug 4510849
      g_ship_method_visible := visible_columns (23);
      g_ship_to_country_visible := visible_columns (24);
      g_ship_to_postal_code_visible := visible_columns (25);
      g_ship_to_state_visible := visible_columns (26);
      g_source_header_visible := visible_columns (27);
      g_status_visible := visible_columns (28);
      g_task_type_visible := visible_columns (29);
      g_to_locator_visible := visible_columns (30);
      g_to_lpn_visible := visible_columns (31);
      g_to_organization_code_visible := visible_columns (32);
      g_txn_source_type_visible := visible_columns (33);
      g_user_task_type_visible := visible_columns (34);

      wms_plan_tasks_pvt.g_allocated_lpn_visible := g_allocated_lpn_visible;
      wms_plan_tasks_pvt.g_assembly_visible := g_assembly_visible;
      wms_plan_tasks_pvt.g_carrier_visible := g_carrier_visible;
      wms_plan_tasks_pvt.g_cartonization_lpn_visible :=
                                                   g_cartonization_lpn_visible;
         wms_plan_tasks_pvt.g_container_item_visible := g_container_item_visible;
      wms_plan_tasks_pvt.g_content_lpn_visible := g_content_lpn_visible;
      wms_plan_tasks_pvt.g_customer_visible := g_customer_visible;
      wms_plan_tasks_pvt.g_delivery_visible := g_delivery_visible;
      wms_plan_tasks_pvt.g_department_visible := g_department_visible;
      wms_plan_tasks_pvt.g_from_lpn_visible := g_from_lpn_visible;
      wms_plan_tasks_pvt.g_line_visible := g_line_visible;
      wms_plan_tasks_pvt.g_line_number_visible := g_line_number_visible;
      wms_plan_tasks_pvt.g_machine_resource_visible :=
                                                    g_machine_resource_visible;
      wms_plan_tasks_pvt.g_num_of_child_tasks_visible :=
                                                  g_num_of_child_tasks_visible;
      wms_plan_tasks_pvt.g_operation_plan_visible := g_operation_plan_visible;
      wms_plan_tasks_pvt.g_operation_sequence_visible := g_operation_sequence_visible;
      wms_plan_tasks_pvt.g_op_plan_instance_id_visible :=
                                                 g_op_plan_instance_id_visible;
      wms_plan_tasks_pvt.g_person_visible := g_person_visible;
      wms_plan_tasks_pvt.g_person_resource_visible :=
                                                     g_person_resource_visible;
      wms_plan_tasks_pvt.g_ship_method_visible := g_ship_method_visible;
      wms_plan_tasks_pvt.g_ship_to_country_visible :=
                                                     g_ship_to_country_visible;
      wms_plan_tasks_pvt.g_ship_to_postal_code_visible :=
                                                 g_ship_to_postal_code_visible;
      wms_plan_tasks_pvt.g_ship_to_state_visible := g_ship_to_state_visible;
      wms_plan_tasks_pvt.g_source_header_visible := g_source_header_visible;
      wms_plan_tasks_pvt.g_status_visible := g_status_visible;
      wms_plan_tasks_pvt.g_task_type_visible := g_task_type_visible;
      wms_plan_tasks_pvt.g_to_locator_visible := g_to_locator_visible;
      wms_plan_tasks_pvt.g_to_lpn_visible := g_to_lpn_visible;
      wms_plan_tasks_pvt.g_to_organization_code_visible :=
                                                g_to_organization_code_visible;
      wms_plan_tasks_pvt.g_txn_source_type_visible :=
                                                     g_txn_source_type_visible;
      wms_plan_tasks_pvt.g_user_task_type_visible := g_user_task_type_visible;
   END;

   PROCEDURE set_status_codes
   IS
   BEGIN
      SELECT   REPLACE (meaning, '''', ''''''), meaning
      BULK COLLECT INTO g_status_codes, g_status_codes_orig
          FROM mfg_lookups
         WHERE lookup_type = 'WMS_TASK_STATUS'
      ORDER BY lookup_code;
   END;

   PROCEDURE set_task_type
   IS
   BEGIN
      SELECT   REPLACE (meaning, '''', ''''''), meaning
      BULK COLLECT INTO g_task_types, g_task_types_orig
          FROM mfg_lookups
         WHERE lookup_type = 'WMS_TASK_TYPES'
      ORDER BY lookup_code;
   END;

--Change
   PROCEDURE set_plan_task_types
   IS
   BEGIN
      SELECT   REPLACE (meaning, '''', '''''')
      BULK COLLECT INTO g_plan_task_types
          FROM mfg_lookups
         WHERE lookup_type = 'WMS_PLAN_TASK_TYPES'
      ORDER BY lookup_code;
   END set_plan_task_types;

   PROCEDURE set_plan_status_codes
   IS
   BEGIN
      SELECT   REPLACE (meaning, '''', '''''')
      BULK COLLECT INTO g_plan_status_codes
          FROM mfg_lookups
         WHERE lookup_type = 'WMS_OP_PLAN_INSTANCE_STATUS'
      ORDER BY lookup_code;
   END;

   --End of Change
   PROCEDURE set_project_locators (p_organization_id NUMBER)
   IS
   BEGIN
      IF g_project_enabled_organization IS NULL
      THEN
         SELECT DECODE (project_reference_enabled, 1, 'Y', 'N')
           INTO g_project_enabled_organization
           FROM mtl_parameters
          WHERE organization_id = p_organization_id;
      END IF;

      IF g_project_enabled_organization = 'Y'
      THEN
         UPDATE wms_waveplan_tasks_temp wwtt
            SET LOCATOR =
                   inv_project.get_locator (wwtt.locator_id,
                                            wwtt.organization_id
                                           )
          WHERE LOCATOR IS NULL;

         IF g_to_locator_visible = 'T'
         THEN
            UPDATE wms_waveplan_tasks_temp wwtt
               SET to_locator =
                      inv_project.get_locator (wwtt.to_locator_id,
                                               wwtt.organization_id
                                              )
             WHERE to_locator IS NULL;
         END IF;
      END IF;
   END;

   PROCEDURE set_inbound_source_header_line
   IS
      TYPE source_header_type IS TABLE OF wms_waveplan_tasks_temp.source_header%TYPE;

      TYPE line_number_type IS TABLE OF wms_waveplan_tasks_temp.line_number%TYPE;

      TYPE temp_id_type IS TABLE OF wms_waveplan_tasks_temp.transaction_temp_id%TYPE;

      TYPE task_type_id_type IS TABLE OF wms_waveplan_tasks_temp.task_type_id%TYPE;

      l_source_header   source_header_type;
      l_line_number     line_number_type;
      l_temp_id         temp_id_type;
      l_task_type_id    task_type_id_type;
   BEGIN
      SELECT ph.segment1, pl.line_num, wwtt.transaction_temp_id,
             wwtt.task_type_id
      BULK COLLECT INTO l_source_header, l_line_number, l_temp_id,
             l_task_type_id
        FROM po_line_locations_trx_v pll,--CLM Changes, using CLM views instead of base tables
             po_headers_trx_v ph,
             po_lines_trx_v pl,
             wms_waveplan_tasks_temp wwtt
       WHERE pll.line_location_id = wwtt.reference_id
         AND pll.po_line_id = pl.po_line_id
         AND ph.po_header_id = pl.po_header_id
         AND wwtt.REFERENCE = 'PO_LINE_LOCATION_ID'
         AND wwtt.source_header IS NULL
         AND wwtt.reference_id IS NOT NULL;

      IF l_temp_id.COUNT > 0
      THEN
         FORALL i IN l_temp_id.FIRST .. l_temp_id.LAST
            UPDATE wms_waveplan_tasks_temp wwtt
               SET source_header = l_source_header (i),
                   line_number = l_line_number (i)
             WHERE wwtt.transaction_temp_id = l_temp_id (i)
               AND wwtt.task_type_id = l_task_type_id (i);
      END IF;

      SELECT ooh.order_number, ool.line_number, wwtt.transaction_temp_id,
             wwtt.task_type_id
      BULK COLLECT INTO l_source_header, l_line_number, l_temp_id,
             l_task_type_id
        FROM oe_order_lines_all ool,
             oe_order_headers_all ooh,
             wms_waveplan_tasks_temp wwtt
       WHERE ool.line_id = wwtt.reference_id
         AND ooh.header_id = ool.header_id
         AND wwtt.REFERENCE = 'ORDER_LINE_ID'
         AND wwtt.source_header IS NULL
         AND wwtt.reference_id IS NOT NULL;

      IF l_temp_id.COUNT > 0
      THEN
         FORALL i IN l_temp_id.FIRST .. l_temp_id.LAST
            UPDATE wms_waveplan_tasks_temp wwtt
               SET source_header = l_source_header (i),
                   line_number = l_line_number (i)
             WHERE wwtt.transaction_temp_id = l_temp_id (i)
               AND wwtt.task_type_id = l_task_type_id (i);
      END IF;

      SELECT DECODE (rsl.requisition_line_id,
                     NULL, rsh.shipment_num,
                     prh.segment1
                    ),
             DECODE (rsl.requisition_line_id,
                     NULL, rsl.line_num,
                     prl.line_num
                    ),
             wwtt.transaction_temp_id, wwtt.task_type_id
      BULK COLLECT INTO l_source_header,
             l_line_number,
             l_temp_id, l_task_type_id
             -- MOAC po_requisition_headers and
             -- po_requisition_lines switched to use _ALL tables
        FROM po_requisition_headers_all prh,
             po_requisition_lines_all prl,
             rcv_shipment_lines rsl,
             rcv_shipment_headers rsh,
             wms_waveplan_tasks_temp wwtt
       WHERE rsl.shipment_line_id = wwtt.reference_id
         AND prh.requisition_header_id(+) = prl.requisition_header_id
         AND rsl.requisition_line_id = prl.requisition_line_id(+)
         AND rsl.shipment_header_id = rsh.shipment_header_id
         AND wwtt.REFERENCE = 'SHIPMENT_LINE_ID'
         AND wwtt.source_header IS NULL
         AND wwtt.reference_id IS NOT NULL;

      IF l_temp_id.COUNT > 0
      THEN
         FORALL i IN l_temp_id.FIRST .. l_temp_id.LAST
            UPDATE wms_waveplan_tasks_temp wwtt
               SET source_header = l_source_header (i),
                   line_number = l_line_number (i)
             WHERE wwtt.transaction_temp_id = l_temp_id (i)
               AND wwtt.task_type_id = l_task_type_id (i);
      END IF;
   END;

--Patchset J Bulk Picking Enhancement
--This procedure calcuate the number of children task
--associated with parent tasks
   PROCEDURE set_num_of_child_tasks
   IS
      l_debug                    NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
      l_progress                 NUMBER;

      TYPE num_of_child_tasks_type IS TABLE OF wms_waveplan_tasks_temp.num_of_child_tasks%TYPE;

      l_num_of_child_tasks_tbl   num_of_child_tasks_type;
      l_parent_temp_ids_tbl      wms_waveplan_tasks_pvt.transaction_temp_table_type;
   BEGIN
      IF l_debug = 1
      THEN
         DEBUG (   'set_num_of_child_tasks entered '
                || TO_CHAR (SYSDATE, 'YYYY-MM-DD HH:DD:SS'),
                'WMS_WAVEPLAN_TASKS_PVT'
               );
      END IF;

      l_progress := 10;

      --MMTT used to get children task.
      --wwtt used to get the parent task.
      SELECT   COUNT (1), wwtt.transaction_temp_id
      BULK COLLECT INTO l_num_of_child_tasks_tbl, l_parent_temp_ids_tbl
          FROM wms_waveplan_tasks_temp wwtt,
               mtl_material_transactions_temp mmtt
         WHERE wwtt.transaction_temp_id = mmtt.parent_line_id
           AND wwtt.transaction_temp_id <> mmtt.transaction_temp_id
      GROUP BY wwtt.transaction_temp_id;

      l_progress := 20;

      IF l_num_of_child_tasks_tbl.COUNT > 0
      THEN
         l_progress := 30;
         FORALL i IN l_num_of_child_tasks_tbl.FIRST .. l_num_of_child_tasks_tbl.LAST
            UPDATE wms_waveplan_tasks_temp wwtt
               SET wwtt.num_of_child_tasks = l_num_of_child_tasks_tbl (i)
             WHERE wwtt.transaction_temp_id = l_parent_temp_ids_tbl (i);
         l_progress := 40;
      END IF;

      l_progress := 50;

      IF l_debug = 1
      THEN
         DEBUG (   'set_num_of_child_tasks exited '
                || TO_CHAR (SYSDATE, 'YYYY-MM-DD HH:DD:SS'),
                'WMS_WAVEPLAN_TASKS_PVT'
               );
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN                                               --no parent bulk task
         IF l_debug = 1
         THEN
            DEBUG
                (   'set_num_of_child_tasks no_data_found after l_progress '
                 || l_progress,
                 'WMS_WAVEPLAN_TASKS_PVT'
                );

            IF l_progress = 10
            THEN
               DEBUG
                  (   'set_num_of_child_tasks exited normally with no parent '
                   || 'task found '
                   || TO_CHAR (SYSDATE, 'YYYY-MM-DD HH:DD:SS'),
                   'WMS_WAVEPLAN_TASKS_PVT'
                  );
            END IF;
         END IF;
      WHEN OTHERS
      THEN
         IF l_debug = 1
         THEN
            DEBUG
               (   'set_num_of_child_tasks OTHERS exception after l_progress '
                || l_progress,
                'WMS_WAVEPLAN_TASKS_PVT'
               );
         END IF;
   END set_num_of_child_tasks;

    /*Added procedure set_picking_lpns for bug 4510849*/

  PROCEDURE set_picking_lpns(p_is_loaded    BOOLEAN,
                              p_is_completed BOOLEAN) IS
   BEGIN

      IF p_is_completed THEN
         -- Completed Tasks
         IF g_picked_lpn_visible = 'T' OR g_loaded_lpn_visible = 'T' OR g_drop_lpn_visible = 'T' THEN
            UPDATE wms_waveplan_tasks_temp
              -- transfer_lpn_id would be null if it is loaded into the same lpn as that of picked.
              SET picked_lpn_id = NVL(from_lpn_id, content_lpn_id),
                  loaded_lpn_id = Nvl(to_lpn_id,  Nvl(from_lpn_id, content_lpn_id))
              WHERE task_type_id IN (1, 4, 5, 6)
              AND status_id = 6;
         END IF;

         IF g_picked_lpn_visible = 'T' THEN
           UPDATE wms_waveplan_tasks_temp
             SET picked_lpn = (SELECT license_plate_number FROM wms_license_plate_numbers WHERE lpn_id = picked_lpn_id)
             WHERE picked_lpn_id IS NOT NULL
             AND task_type_id IN (1, 4, 5, 6)
             AND status_id = 6;
         END IF;

         IF g_loaded_lpn_visible = 'T' THEN
            UPDATE wms_waveplan_tasks_temp
              SET loaded_lpn = (SELECT license_plate_number FROM wms_license_plate_numbers WHERE lpn_id = loaded_lpn_id)
              WHERE loaded_lpn_id IS NOT NULL
              AND task_type_id IN (1, 4, 5, 6)
              AND status_id = 6;
         END IF;

         IF g_drop_lpn_visible = 'T' THEN
            UPDATE wms_waveplan_tasks_temp wstt
              SET drop_lpn = Nvl((select license_plate_number
                                  FROM wms_license_plate_numbers wlpn, mtl_material_transactions mmt
                                  WHERE wlpn.lpn_id = mmt.transfer_lpn_id
                                  AND mmt.transaction_action_id = 50
                                  AND mmt.transaction_set_id = wstt.transaction_set_id
                                  AND mmt.transaction_quantity > 0),
                                 loaded_lpn)
              WHERE task_type_id IN (1, 4, 5, 6)
              AND status_id = 6;
         END IF;
      END IF;

      IF p_is_loaded THEN
         -- Loaded Tasks
         IF g_picked_lpn_visible = 'T' OR g_loaded_lpn_visible = 'T' THEN
            UPDATE wms_waveplan_tasks_temp
              -- transfer_lpn_id would be null if it is loaded into the same lpn as that of picked.
              SET picked_lpn_id = Nvl(from_lpn_id, content_lpn_id),
                  loaded_lpn_id = to_lpn_id
              WHERE task_type_id IN (1, 4, 5, 6)
              AND status_id = 4;
         END IF;

         IF g_picked_lpn_visible = 'T' THEN
            UPDATE wms_waveplan_tasks_temp
              SET picked_lpn = (SELECT license_plate_number FROM wms_license_plate_numbers WHERE lpn_id = picked_lpn_id)
              WHERE picked_lpn_id IS NOT NULL
              AND task_type_id IN (1, 4, 5, 6)
              AND status_id = 4;
         END IF;

         IF g_loaded_lpn_visible = 'T' THEN
            UPDATE wms_waveplan_tasks_temp
              SET loaded_lpn = (SELECT license_plate_number FROM wms_license_plate_numbers WHERE lpn_id = loaded_lpn_id)
              WHERE loaded_lpn_id IS NOT NULL
              AND task_type_id IN (1, 4, 5, 6)
              AND status_id = 4;
         END IF;
      END IF;
   END set_picking_lpns;

   FUNCTION get_generic_insert (
      p_is_unreleased   BOOLEAN DEFAULT FALSE,
      p_is_pending      BOOLEAN DEFAULT FALSE,
      p_is_queued       BOOLEAN DEFAULT FALSE,
      p_is_dispatched   BOOLEAN DEFAULT FALSE,
      p_is_active       BOOLEAN DEFAULT FALSE,
      p_is_loaded       BOOLEAN DEFAULT FALSE,
      p_is_completed    BOOLEAN DEFAULT FALSE
   )
      RETURN VARCHAR2
   IS
      l_insert_generic   VARCHAR2 (2000);
      l_join_wdt         BOOLEAN;
   BEGIN
      IF     (p_is_unreleased OR p_is_pending)
         AND NOT (p_is_queued OR p_is_dispatched OR p_is_loaded OR p_is_active
                 )
      THEN
         -- Query records present only in MMTT
         l_join_wdt := FALSE;
      ELSIF     (p_is_unreleased OR p_is_pending)
            AND (p_is_queued OR p_is_dispatched OR p_is_loaded OR p_is_active
                )
      THEN
         -- Query records present only in MMTT as well as those in both MMTT and WDT
         l_join_wdt := TRUE;
      ELSIF     NOT (p_is_unreleased OR p_is_pending)
            AND (   p_is_queued
                 OR p_is_dispatched
                 OR p_is_loaded
                 OR p_is_active
                 OR p_is_completed
                )
      THEN
         -- Query records present both in MMTT and WDT
         l_join_wdt := TRUE;
      END IF;

      l_insert_generic := 'INSERT INTO wms_waveplan_tasks_temp( ';
      /* Patchset J - ATF - we have to insert expansion_code, plans_tasks also
        * into the temp table
        */
      l_insert_generic := l_insert_generic || 'expansion_code';
      l_insert_generic := l_insert_generic || ', plans_tasks';
      l_insert_generic := l_insert_generic || ', transaction_temp_id ';
      --Patchset J Bulk Picking Enhancement.  Always include parent_line_id in wwtt,
      --not just when querying for non-completed tasks.  Because now
      --we are showing completed parent tasks, which we weren't showing before.
      --Thus, we need a link between completed parents and children
      l_insert_generic := l_insert_generic || ', parent_line_id ';
      l_insert_generic := l_insert_generic || ', inventory_item_id ';
      l_insert_generic := l_insert_generic || ', item ';
      l_insert_generic := l_insert_generic || ', item_description ';
      l_insert_generic := l_insert_generic || ', unit_weight ';
      l_insert_generic := l_insert_generic || ', weight_uom_code ';
      l_insert_generic := l_insert_generic || ', unit_volume ';
      l_insert_generic := l_insert_generic || ', volume_uom_code ';
      l_insert_generic := l_insert_generic || ', organization_id ';
      l_insert_generic := l_insert_generic || ', revision ';
      l_insert_generic := l_insert_generic || ', subinventory ';
      l_insert_generic := l_insert_generic || ', locator_id ';
      l_insert_generic := l_insert_generic || ', locator ';
      l_insert_generic := l_insert_generic || ', status_id ';
      l_insert_generic := l_insert_generic || ', status_id_original ';
      l_insert_generic := l_insert_generic || ', status ';
      l_insert_generic := l_insert_generic || ', transaction_type_id ';
      l_insert_generic := l_insert_generic || ', transaction_action_id ';
      l_insert_generic := l_insert_generic || ', transaction_source_type_id ';

      IF g_txn_source_type_visible = 'T'
      THEN
         l_insert_generic := l_insert_generic || ', transaction_source_type ';
      END IF;

      l_insert_generic := l_insert_generic || ', transaction_source_id ';
      l_insert_generic := l_insert_generic || ', transaction_source_line_id ';
      l_insert_generic := l_insert_generic || ', to_organization_id ';

      IF g_to_organization_code_visible = 'T'
      THEN
         l_insert_generic := l_insert_generic || ', to_organization_code ';
      END IF;

      l_insert_generic := l_insert_generic || ', to_subinventory ';
      l_insert_generic := l_insert_generic || ', to_locator_id ';

      IF g_to_locator_visible = 'T'
      THEN
         l_insert_generic := l_insert_generic || ', to_locator ';
      END IF;

      l_insert_generic := l_insert_generic || ', transaction_uom ';
      l_insert_generic := l_insert_generic || ', transaction_quantity ';
      l_insert_generic := l_insert_generic || ', user_task_type_id ';

      IF g_user_task_type_visible = 'T'
      THEN
         l_insert_generic := l_insert_generic || ', user_task_type ';
      END IF;

      l_insert_generic := l_insert_generic || ', move_order_line_id ';
      l_insert_generic := l_insert_generic || ', pick_slip_number ';
      l_insert_generic := l_insert_generic || ', cartonization_id ';

      IF g_cartonization_lpn_visible = 'T'
      THEN                                       --AND NOT p_is_completed THEN
         l_insert_generic := l_insert_generic || ', cartonization_lpn ';
      END IF;

      l_insert_generic := l_insert_generic || ', allocated_lpn_id ';

      IF g_allocated_lpn_visible = 'T' /*AND NOT p_is_completed*/
      THEN
         l_insert_generic := l_insert_generic || ', allocated_lpn ';
      END IF;

      l_insert_generic := l_insert_generic || ', container_item_id ';

      IF g_container_item_visible = 'T' /*AND NOT p_is_completed*/
      THEN
         l_insert_generic := l_insert_generic || ', container_item ';
      END IF;

      l_insert_generic := l_insert_generic || ', from_lpn_id ';

      IF g_from_lpn_visible = 'T'
      THEN
         l_insert_generic := l_insert_generic || ', from_lpn ';
      END IF;

      l_insert_generic := l_insert_generic || ', content_lpn_id ';

      IF g_content_lpn_visible = 'T'
      THEN
         l_insert_generic := l_insert_generic || ', content_lpn ';
      END IF;

      l_insert_generic := l_insert_generic || ', to_lpn_id ';

      IF g_to_lpn_visible = 'T'
      THEN
         l_insert_generic := l_insert_generic || ', to_lpn ';
      END IF;

      l_insert_generic := l_insert_generic || ', mmtt_last_update_date ';
      l_insert_generic := l_insert_generic || ', mmtt_last_updated_by ';
      l_insert_generic := l_insert_generic || ', priority ';
      l_insert_generic := l_insert_generic || ', priority_original ';
      l_insert_generic := l_insert_generic || ', task_type_id ';
      l_insert_generic := l_insert_generic || ', task_type ';
      l_insert_generic := l_insert_generic || ', creation_time ';
      l_insert_generic := l_insert_generic || ', operation_plan_id ';

      IF g_operation_plan_visible = 'T'
      THEN
         l_insert_generic := l_insert_generic || ', operation_plan ';
      END IF;

       IF g_operation_sequence_visible = 'T' THEN
        l_insert_generic := l_insert_generic || ', operation_sequence ';
      END IF;

      l_insert_generic := l_insert_generic || ', op_plan_instance_id ';

      IF l_join_wdt
      THEN
         l_insert_generic := l_insert_generic || ', task_id ';
         l_insert_generic := l_insert_generic || ', person_id ';
         l_insert_generic := l_insert_generic || ', person_id_original ';

         IF g_person_visible = 'T'
         THEN
            l_insert_generic := l_insert_generic || ', person ';
         END IF;

         l_insert_generic := l_insert_generic || ', effective_start_date ';
         l_insert_generic := l_insert_generic || ', effective_end_date ';
         l_insert_generic := l_insert_generic || ', person_resource_id ';

         IF g_person_resource_visible = 'T'
         THEN
            l_insert_generic := l_insert_generic || ', person_resource_code ';
         END IF;

         l_insert_generic := l_insert_generic || ', machine_resource_id ';

         IF g_machine_resource_visible = 'T'
         THEN
            l_insert_generic :=
                               l_insert_generic || ', machine_resource_code ';
         END IF;

         l_insert_generic := l_insert_generic || ', equipment_instance ';
         l_insert_generic := l_insert_generic || ', dispatched_time ';
         l_insert_generic := l_insert_generic || ', loaded_time ';
         l_insert_generic := l_insert_generic || ', drop_off_time ';
         l_insert_generic := l_insert_generic || ', wdt_last_update_date ';
         l_insert_generic := l_insert_generic || ', wdt_last_updated_by ';
      END IF;

      l_insert_generic := l_insert_generic || ', is_modified ';
      -- Bug #4141928
      l_insert_generic := l_insert_generic || ', secondary_transaction_uom ';
      l_insert_generic := l_insert_generic || ', secondary_transaction_quantity ';

      IF p_is_completed THEN      --bug 4510849
        IF NOT (wms_plan_tasks_pvt.g_include_inbound OR wms_plan_tasks_pvt.g_include_crossdock) THEN /* Bug 4047985 */
          l_insert_generic := l_insert_generic || ', transaction_set_id ';
	END IF; /* End of Bug 4047985 */
      END IF;

      RETURN l_insert_generic;
   END;

   FUNCTION get_generic_select (
      p_is_unreleased           BOOLEAN DEFAULT FALSE,
      p_is_pending              BOOLEAN DEFAULT FALSE,
      p_is_queued               BOOLEAN DEFAULT FALSE,
      p_is_dispatched           BOOLEAN DEFAULT FALSE,
      p_is_active               BOOLEAN DEFAULT FALSE,
      p_is_loaded               BOOLEAN DEFAULT FALSE,
      p_is_completed            BOOLEAN DEFAULT FALSE,
      p_populate_merged_tasks   BOOLEAN DEFAULT FALSE
   )
      RETURN VARCHAR2
   IS
      l_select_generic   VARCHAR2 (4000);
      l_join_wdt         BOOLEAN;
   BEGIN
      IF NOT p_is_completed
      THEN

         IF     (p_is_unreleased OR p_is_pending)
            AND NOT (p_is_queued OR p_is_dispatched OR p_is_loaded
                     OR p_is_active
                    )
         THEN
            -- Query records present only in MMTT
            l_join_wdt := FALSE;
         ELSIF     (p_is_unreleased OR p_is_pending)
               AND (p_is_queued OR p_is_dispatched OR p_is_loaded
                    OR p_is_active
                   )
         THEN
            -- Query records present only in MMTT as well as those in both MMTT and WDT
            l_join_wdt := TRUE;
         ELSIF     NOT (p_is_unreleased OR p_is_pending)
               AND (p_is_queued OR p_is_dispatched OR p_is_loaded
                    OR p_is_active
                   )
         THEN
            -- Query records present both in MMTT and WDT
            l_join_wdt := TRUE;
         END IF;

         -- Build the generic select section of the query
         l_select_generic := 'SELECT ';
         l_select_generic := l_select_generic || 'null, ';   -- expansion_code
         l_select_generic :=
               l_select_generic
            || 'decode(mmtt.parent_line_id,'
            || ' null,decode(mmtt.operation_plan_id,null,'''
            || g_plan_task_types (1)
       || ''','
       || ' decode(mmtt.transaction_action_id,28,'''
       || g_plan_task_types(1)
       || ''','
       || ' decode(mmtt.transaction_source_type_id, 5, '''
       || g_plan_task_types(1)
       || ''','
       || ' 13, decode(mmtt.transaction_type_id,51,'''
       || g_plan_task_types(1)
       || ''','''
       || g_plan_task_types(3)
            || ''' )))), '
            || ' mmtt.transaction_temp_id, '''
            || g_plan_task_types (4)
            || ''','''
            || g_plan_task_types (2)
            || '''),';

    --planned task only since won't show non-completed bulk children
         l_select_generic := l_select_generic || 'mmtt.transaction_temp_id, ';
                                                         --transaction_temp_id
         l_select_generic := l_select_generic || 'mmtt.parent_line_id, ';
                                                              --parent_line_id
         l_select_generic := l_select_generic || 'mmtt.inventory_item_id, ';
                                                           --inventory_item_id
         l_select_generic :=
                            l_select_generic || 'msiv.concatenated_segments, ';
                                                                        --item
         l_select_generic := l_select_generic || 'msiv.description, ';
                                                            --item description
         l_select_generic := l_select_generic || 'msiv.unit_weight, ';
                                                                 --unit_weight
         l_select_generic := l_select_generic || 'msiv.weight_uom_code, ';
                                                             --weight_uom_code
         l_select_generic := l_select_generic || 'msiv.unit_volume, ';
                                                                 --unit_volume
         l_select_generic := l_select_generic || 'msiv.volume_uom_code, ';
                                                             --volume_uom_code
         l_select_generic := l_select_generic || 'mmtt.organization_id, ';
                                                             --organization_id
         l_select_generic := l_select_generic || 'mmtt.revision, '; --revision
         l_select_generic := l_select_generic || 'mmtt.subinventory_code, ';
                                                                --subinventory
         l_select_generic := l_select_generic || 'mmtt.locator_id, ';
                                                                  --locator_id
         --locator
         l_select_generic :=
               l_select_generic
            || 'decode(milv.segment19, null, milv.concatenated_segments, null), ';

         IF l_join_wdt
         THEN
            --status_id
            l_select_generic :=
                  l_select_generic
               || 'decode(wdt.status, null, nvl(mmtt.wms_task_status, 1), wdt.status), ';
            --status_id_original
            l_select_generic :=
                  l_select_generic
               || 'decode(wdt.status, null, nvl(mmtt.wms_task_status, 1), wdt.status), ';
            --status
            l_select_generic :=
                  l_select_generic
               || 'decode(decode(wdt.status, null, nvl(mmtt.wms_task_status, 1), wdt.status),'
               || '1, '''
               || g_status_codes (1)
               || ''', 2, '''
               || g_status_codes (2)
               || ''', 3, '''
               || g_status_codes (3)
               || ''', 4, '''
               || g_status_codes (4)
               || ''', 5, '''
               || g_status_codes (5)
               || ''', 6, '''
               || g_status_codes (6)
               || ''', 7, '''
               || g_status_codes (7)
               || ''', 8, '''
               || g_status_codes (8)
               || ''', '
               || '9, '''
               || g_status_codes (9)
               || '''), ';
         ELSE
            --status_id
            l_select_generic :=
                         l_select_generic || 'nvl(mmtt.wms_task_status, 1), ';
            --status_id_original
            l_select_generic :=
                         l_select_generic || 'nvl(mmtt.wms_task_status, 1), ';
            --status
            l_select_generic :=
                  l_select_generic
               || 'decode(nvl(mmtt.wms_task_status, 1),'
               || '1, '''
               || g_status_codes (1)
               || ''', 8, '''
               || g_status_codes (8)
               || '''), ';
         END IF;

         l_select_generic := l_select_generic || 'mmtt.transaction_type_id, ';
                                                         --transaction_type_id
         l_select_generic :=
                            l_select_generic || 'mmtt.transaction_action_id, ';
                                                       --transaction_action_id
         l_select_generic :=
                       l_select_generic || 'mmtt.transaction_source_type_id, ';
                                                  --transaction_source_type_id

         IF g_txn_source_type_visible = 'T'
         THEN
            l_select_generic :=
                    l_select_generic || 'mtst.transaction_source_type_name, ';
                                                    --transaction_source_type
         END IF;

         l_select_generic :=
                            l_select_generic || 'mmtt.transaction_source_id, ';
                                                       --transaction_source_id
         l_select_generic := l_select_generic || 'mmtt.trx_source_line_id, ';
                                                  --transaction_source_line_id
         l_select_generic :=
                            l_select_generic || 'mmtt.transfer_organization, ';
                                                          --to_organization_id

         IF g_to_organization_code_visible = 'T'
         THEN
            l_select_generic := l_select_generic || 'mp1.organization_code, ';
                                                         --to_organization_id
         END IF;

         l_select_generic :=
                            l_select_generic || 'mmtt.transfer_subinventory, ';
                                                             --to_subinventory
         l_select_generic := l_select_generic || 'mmtt.transfer_to_location, ';
                                                               --to_locator_id

         IF g_to_locator_visible = 'T'
         THEN
            --to_locator_id
            l_select_generic :=
                  l_select_generic
               || 'decode(milv1.segment19, null, milv1.concatenated_segments, null), ';
         END IF;

         l_select_generic := l_select_generic || 'mmtt.transaction_uom, ';
                                                             --transaction_uom
         l_select_generic := l_select_generic || 'mmtt.transaction_quantity, ';
                                                        --transaction_quantity
         l_select_generic :=
                            l_select_generic || 'mmtt.standard_operation_id, ';
                                                           --user_task_type_id

         IF g_user_task_type_visible = 'T'
         THEN
            l_select_generic := l_select_generic || 'bso.operation_code, ';
                                                             --user_task_type
         END IF;

         IF NOT p_populate_merged_tasks
         THEN
            l_select_generic :=
                              l_select_generic || 'mmtt.move_order_line_id, ';
                                                         --move_order_line_id
            --Change
            l_select_generic := l_select_generic || 'mmtt.pick_slip_number, ';
                                                           --pick_slip_number
         -- End of Change
         ELSE
            l_select_generic := l_select_generic || 'to_number(null), ';
                                                         --move_order_line_id
            --Change
            l_select_generic := l_select_generic || 'to_number(null), ';
                                                           --pick_slip_number
         -- End of Change
         END IF;

           --Change
           /*IF NOT p_populate_merged_tasks THEN
         l_select_generic := l_select_generic || 'mmtt.pick_slip_number, ';          --pick_slip_number
            ELSE
         l_select_generic := l_select_generic || 'to_number(null), ';                --pick_slip_number
           END IF;*/
           --End of change
         l_select_generic := l_select_generic || 'mmtt.cartonization_id, ';
                                                            --cartonization_id

         IF g_cartonization_lpn_visible = 'T'
         THEN
            l_select_generic :=
                           l_select_generic || 'wlpn2.license_plate_number, ';
                                                          --cartonization_lpn
         END IF;

         l_select_generic := l_select_generic || 'mmtt.allocated_lpn_id, ';
                                                            --allocated_lpn_id

         IF g_allocated_lpn_visible = 'T'
         THEN
            l_select_generic :=
                           l_select_generic || 'wlpn1.license_plate_number, ';
                                                              --allocated_lpn
         END IF;

         l_select_generic := l_select_generic || 'mmtt.container_item_id, ';
                                                           --container_item_id

         IF g_container_item_visible = 'T'
         THEN
            l_select_generic :=
                          l_select_generic || 'msiv1.concatenated_segments, ';
                                                             --container_item
         END IF;

         l_select_generic := l_select_generic || 'mmtt.lpn_id, ';
                                                              --from_lpn_id

         IF g_from_lpn_visible = 'T'
         THEN
            l_select_generic :=
                           l_select_generic || 'wlpn5.license_plate_number, ';
                                                                --from_lpn
         END IF;

         l_select_generic := l_select_generic || 'mmtt.content_lpn_id, ';
                                                              --content_lpn_id

         IF g_content_lpn_visible = 'T'
         THEN
            l_select_generic :=
                           l_select_generic || 'wlpn3.license_plate_number, ';
                                                                --content_lpn
         END IF;

         l_select_generic := l_select_generic || 'mmtt.transfer_lpn_id, ';
                                                                   --to_lpn_id

         IF g_to_lpn_visible = 'T'
         THEN
            l_select_generic :=
                           l_select_generic || 'wlpn4.license_plate_number, ';
                                                                     --to_lpn
         END IF;

         l_select_generic := l_select_generic || 'mmtt.last_update_date, ';
                                                       --mmtt_last_update_date
         l_select_generic := l_select_generic || 'mmtt.last_updated_by, ';
                                                        --mmtt_last_updated_by
         l_select_generic := l_select_generic || 'mmtt.task_priority, ';
                                                                    --priority
         l_select_generic := l_select_generic || 'mmtt.task_priority, ';
                                                           --priority_original
         l_select_generic := l_select_generic || 'mmtt.wms_task_type, ';
                                                                --task_type_id
         --task_type
         l_select_generic :=
               l_select_generic
            || 'decode(mmtt.wms_task_type,'
            || '1, '''
            || g_task_types (1)
            || ''', 2, '''
            || g_task_types (2)
            || ''', 3, '''
            || g_task_types (3)
            || ''', 4, '''
            || g_task_types (4)
            || ''', 5, '''
            || g_task_types (5)
            || ''', 6, '''
            || g_task_types (6)
            || ''', 7, '''
            || g_task_types (7)
            || ''', 8, '''
            || g_task_types (8)
            || '''), ';
         l_select_generic := l_select_generic || 'mmtt.creation_date, ';
                                                               --creation_time
         l_select_generic := l_select_generic || 'mmtt.operation_plan_id, ';
                                                           --operation_plan_id

         IF g_operation_plan_visible = 'T'
         THEN
            l_select_generic :=
                              l_select_generic || 'wop.operation_plan_name, ';
                                                             --operation_plan
         END IF;

         --IF g_op_plan_instance_id_visible = 'T' THEN
         IF wms_plan_tasks_pvt.g_query_planned_tasks = TRUE
         THEN
            IF g_operation_sequence_visible = 'T' THEN
              l_select_generic := l_select_generic || 'wooi.operation_sequence,  '; --operation_sequence
            END IF;

            l_select_generic :=
                            l_select_generic || 'wooi.op_plan_instance_id,  ';
                                                        --op_plan_instance_id
         ELSE
            IF g_operation_sequence_visible = 'T' THEN
            l_select_generic := l_select_generic || 'to_number(null), '; --operation_sequence
            END IF;

            l_select_generic := l_select_generic || 'to_number(null), ';
                                                        --op_plan_instance_id
         END IF;

         -- END IF;
         IF l_join_wdt
         THEN
            l_select_generic := l_select_generic || 'wdt.task_id, ';
                                                                    --task_id
            l_select_generic := l_select_generic || 'wdt.person_id, ';
                                                                  --person_id
            l_select_generic := l_select_generic || 'wdt.person_id, ';
                                                         --person_id_original

            IF g_person_visible = 'T'
            THEN
               l_select_generic := l_select_generic || 'pap.full_name, ';
                                                                  --person_id
            END IF;

            l_select_generic :=
                              l_select_generic || 'wdt.effective_start_date, ';
                                                        --effective_start_date
            l_select_generic := l_select_generic || 'wdt.effective_end_date, ';
                                                          --effective_end_date
            l_select_generic := l_select_generic || 'wdt.person_resource_id, ';
                                                          --person_resource_id

            IF g_person_resource_visible = 'T'
            THEN
               l_select_generic := l_select_generic || 'br1.resource_code, ';
                                                       --person_resource_code
            END IF;

            l_select_generic :=
                               l_select_generic || 'wdt.machine_resource_id, ';
                                                         --machine_resource_id

            IF g_machine_resource_visible = 'T'
            THEN
               l_select_generic := l_select_generic || 'br2.resource_code, ';
                                                      --machine_resource_code
            END IF;

            l_select_generic := l_select_generic || 'wdt.equipment_instance, ';
                                                          --equipment_instance
            l_select_generic := l_select_generic || 'wdt.dispatched_time, ';
                                                             --dispatched_time
            l_select_generic := l_select_generic || 'wdt.loaded_time, ';
                                                                 --loaded_time
            l_select_generic := l_select_generic || 'wdt.drop_off_time, ';
                                                               --drop_off_time
            l_select_generic := l_select_generic || 'wdt.last_update_date, ';
                                                        --wdt_last_update_date
            l_select_generic := l_select_generic || 'wdt.last_updated_by, ';
                                                         --wdt_last_updated_by
         -- Bug #3754781 -1 line, +1 line
         --ELSIF wms_plan_tasks_pvt.g_include_inbound
         ELSIF wms_plan_tasks_pvt.g_inbound_cycle
         THEN
            l_select_generic :=
                  l_select_generic
               || 'to_number(null), '                              /*task_id*/
               || 'to_number(null), '                            /*person_id*/
               || 'to_number(null), ';                    --person_id_original

            IF g_person_visible = 'T'
            THEN
               l_select_generic := l_select_generic || 'NULL, ';
            --person_id
            END IF;

            l_select_generic :=
                  l_select_generic
               || 'TO_DATE(NULL), '                   /*effective_start_date*/
               || 'TO_DATE(NULL), '                     /*effective_end_date*/
               || 'TO_NUMBER(NULL), ';                    --person_resource_id

            IF g_person_resource_visible = 'T'
            THEN
               l_select_generic := l_select_generic || 'NULL, ';
                                                       --person_resource_code
            END IF;

            l_select_generic := l_select_generic || 'TO_NUMBER(NULL), ';
                                                         --machine_resource_id

            IF g_machine_resource_visible = 'T'
            THEN
               l_select_generic := l_select_generic || 'NULL, ';
                                                      --machine_resource_code
            END IF;

            l_select_generic := l_select_generic || 'NULL, ';
            --equipment_instance
            l_select_generic := l_select_generic || 'TO_DATE(NULL), ';
            --dispatched_time
            l_select_generic := l_select_generic || 'TO_DATE(NULL), ';
            --loaded_time
            l_select_generic := l_select_generic || 'TO_DATE(NULL), ';
            --drop_off_time
            l_select_generic := l_select_generic || 'TO_DATE(NULL), ';
            --wdt_last_update_date
            l_select_generic := l_select_generic || 'TO_NUMBER(NULL), ';
         --wdt_last_updated_by
         END IF;

         l_select_generic := l_select_generic || '''N'', ';       --is_modified
         -- Bug #4141928
         l_select_generic := l_select_generic || 'mmtt.secondary_uom_code, ';
                                                             --sec_transaction_uom
         l_select_generic :=
                         l_select_generic || 'mmtt.secondary_transaction_quantity ';
                                                        --sec_transaction_quantity

         RETURN l_select_generic;
      ELSIF (p_is_completed AND NOT p_populate_merged_tasks)
      THEN
         -- Build the generic select section of the query
         l_select_generic := 'SELECT ';
         l_select_generic := l_select_generic || 'null, ';  -- expansion_code
    l_select_generic :=
      l_select_generic
      || 'decode(wdth.is_parent,'
      || '''Y'', decode(wdth.transaction_action_id,28,'''
      || g_plan_task_types (4)
      || ''','
      || 'decode(wdth.transaction_source_type_id,'
      || '5,decode(wdth.transaction_type_id,35,'''
      || g_plan_task_types (4)
      || ''','''
      || g_plan_task_types (3)
      || '''),'
      || '13, decode(wdth.transaction_type_id,51,'''
      || g_plan_task_types (4)
      || ''','''
      || g_plan_task_types (3)
      || '''),'''
      || g_plan_task_types (3)
      || ''')),'
      || 'decode(wdth.parent_transaction_id,null,''' --'N' or null
      || g_plan_task_types(1)
      || ''','
      || 'decode(wdth.transaction_action_id,28,'''
      || g_plan_task_types(5)
      || ''','
      || 'decode(wdth.transaction_source_type_id,'
      || '5,decode(wdth.transaction_type_id,35,'''
      || g_plan_task_types (5)
      || ''','''
      || g_plan_task_types (2)
      || '''),'
      || '13, decode(wdth.transaction_type_id,51,'''
      || g_plan_task_types (5)
      || ''','''
      || g_plan_task_types (2)
      || '''),'''
      || g_plan_task_types (2)
      || ''')))),';   --plan task
         l_select_generic := l_select_generic || 'mmt.transaction_id, ';
                                                         --transaction_temp_id
         l_select_generic := l_select_generic || 'wdth.parent_transaction_id,';
                                                              --parent_line_id
         l_select_generic := l_select_generic || 'mmt.inventory_item_id, ';
                                                           --inventory_item_id
         l_select_generic :=
                            l_select_generic || 'msiv.concatenated_segments, ';
                                                                        --item
         l_select_generic := l_select_generic || 'msiv.description, ';
                                                            --item description
         l_select_generic := l_select_generic || 'msiv.unit_weight, ';
                                                                 --unit_weight
         l_select_generic := l_select_generic || 'msiv.weight_uom_code, ';
                                                             --weight_uom_code
         l_select_generic := l_select_generic || 'msiv.unit_volume, ';
                                                                 --unit_volume
         l_select_generic := l_select_generic || 'msiv.volume_uom_code, ';
                                                             --volume_uom_code
         l_select_generic := l_select_generic || 'mmt.organization_id, ';
                                                             --organization_id
         l_select_generic := l_select_generic || 'mmt.revision, ';  --revision
         l_select_generic := l_select_generic || 'mmt.subinventory_code, ';
                                                                --subinventory
         l_select_generic := l_select_generic || 'mmt.locator_id, ';
                                                                  --locator_id
         --locator
         l_select_generic :=
               l_select_generic
            || 'decode(milv.segment19, null, milv.concatenated_segments, null), ';
         l_select_generic := l_select_generic || '6, ';            --status_id
         l_select_generic := l_select_generic || '6, ';   --status_id_original
         l_select_generic :=
                       l_select_generic || '''' || g_status_codes (6)
                       || ''', ';                                     --status
         l_select_generic := l_select_generic || 'mmt.transaction_type_id, ';
                                                         --transaction_type_id
         l_select_generic := l_select_generic || 'mmt.transaction_action_id, ';
                                                       --transaction_action_id
         l_select_generic :=
                        l_select_generic || 'mmt.transaction_source_type_id, ';
                                                  --transaction_source_type_id

         IF g_txn_source_type_visible = 'T'
         THEN
            l_select_generic :=
                    l_select_generic || 'mtst.transaction_source_type_name, ';
                                                    --transaction_source_type
         END IF;

         l_select_generic := l_select_generic || 'mmt.transaction_source_id, ';
                                                       --transaction_source_id
         l_select_generic := l_select_generic || 'mmt.trx_source_line_id, ';
                                                  --transaction_source_line_id
         l_select_generic :=
                          l_select_generic || 'mmt.transfer_organization_id, ';
                                                          --to_organization_id

         IF g_to_organization_code_visible = 'T'
         THEN
            l_select_generic := l_select_generic || 'mp1.organization_code, ';
                                                         --to_organization_id
         END IF;

         l_select_generic := l_select_generic || 'mmt.transfer_subinventory, ';
                                                             --to_subinventory
         l_select_generic := l_select_generic || 'mmt.transfer_locator_id,  ';
                                                               --to_locator_id

         IF g_to_locator_visible = 'T'
         THEN
            --to locator
            l_select_generic :=
                  l_select_generic
               || 'decode(milv1.segment19, null, milv1.concatenated_segments, null), ';
         END IF;

         l_select_generic := l_select_generic || 'mmt.transaction_uom, ';
                                                             --transaction_uom
         l_select_generic :=
                         l_select_generic || 'abs(mmt.transaction_quantity), ';
                                                        --transaction_quantity
         l_select_generic := l_select_generic || 'wdth.user_task_type, ';
                                                           --user_task_type_id

         IF g_user_task_type_visible = 'T'
         THEN
            l_select_generic := l_select_generic || 'bso.operation_code, ';
                                                             --user_task_type
         END IF;

         l_select_generic := l_select_generic || 'mmt.move_order_line_id, ';
                                                          --move_order_line_id
         l_select_generic := l_select_generic || 'mmt.pick_slip_number, ';
                                                            --pick_slip_number
         l_select_generic := l_select_generic || 'to_number(null), ';
                                                            --cartonization_id
         IF g_cartonization_lpn_visible = 'T' THEN
         l_select_generic := l_select_generic || 'null, '; --cartonization_lpn
         END IF;
         l_select_generic := l_select_generic || 'to_number(null), ';
                                                            --allocated_lpn_id
         IF g_allocated_lpn_visible = 'T' THEN
            l_select_generic := l_select_generic || 'null, ';
                                                            --allocated_lpn
         END IF;
         l_select_generic := l_select_generic || 'to_number(null), ';
         --container_item_id
         IF g_container_item_visible = 'T' THEN
            l_select_generic := l_select_generic || 'null, '; /*container item */
        end if;

         l_select_generic := l_select_generic || 'mmt.lpn_id, ';
                                                              --from_lpn_id

         IF g_from_lpn_visible = 'T'
         THEN
            l_select_generic :=
                           l_select_generic || 'wlpn5.license_plate_number, ';
                                                                --from_lpn
         END IF;

         l_select_generic := l_select_generic || 'mmt.content_lpn_id, ';
                                                              --content_lpn_id

         IF g_content_lpn_visible = 'T'
         THEN
            l_select_generic :=
                           l_select_generic || 'wlpn3.license_plate_number, ';
                                                                --content_lpn
         END IF;

         l_select_generic := l_select_generic || 'mmt.transfer_lpn_id, ';
                                                                   --to_lpn_id

         IF g_to_lpn_visible = 'T'
         THEN
            l_select_generic :=
                           l_select_generic || 'wlpn4.license_plate_number, ';
                                                                     --to_lpn
         END IF;

         l_select_generic := l_select_generic || 'to_date(null), ';
                                                        --mmt_last_update_date
         l_select_generic := l_select_generic || 'to_number(null), ';
                                                         --mmt_last_updated_by
         l_select_generic := l_select_generic || 'wdth.priority, '; --priority
         l_select_generic := l_select_generic || 'wdth.priority, ';
                                                           --priority_original
         l_select_generic := l_select_generic || 'wdth.task_type, ';
                                                                --task_type_id
         --task_type
         l_select_generic :=
               l_select_generic
            || 'decode(wdth.task_type,'
            || '1, '''
            || g_task_types (1)
            || ''', 2, '''
            || g_task_types (2)
            || ''', 3, '''
            || g_task_types (3)
            || ''', 4, '''
            || g_task_types (4)
            || ''', 5, '''
            || g_task_types (5)
            || ''', 6, '''
            || g_task_types (6)
            || ''', 7, '''
            || g_task_types (7)
            || '''), ';
         l_select_generic := l_select_generic || 'to_date(null), ';
                                                               --creation_time
         l_select_generic := l_select_generic || 'wdth.operation_plan_id, ';
                                                           --operation_plan_id

         IF g_operation_plan_visible = 'T'
         THEN
            l_select_generic :=
                              l_select_generic || 'wop.operation_plan_name, ';
                                                             --operation_plan
         END IF;

         IF g_operation_sequence_visible = 'T' THEN
            IF wms_plan_tasks_pvt.g_query_planned_tasks = TRUE THEN
            l_select_generic := l_select_generic || 'to_number(null), ';--operation_sequence
            ELSE
               l_select_generic := l_select_generic || 'to_number(null), ';--operation_sequence
            END IF;
         END IF;

         -- IF g_op_plan_instance_id_visible = 'T' THEN
         l_select_generic := l_select_generic || 'wdth.op_plan_instance_id,  ';
                                                         --op_plan_instance_id

         --END IF;
         l_select_generic := l_select_generic || 'wdth.task_id, ';   --task_id
         l_select_generic := l_select_generic || 'wdth.person_id, ';
                                                                   --person_id
         l_select_generic := l_select_generic || 'wdth.person_id, ';
                                                          --person_id_original

         IF g_person_visible = 'T'
         THEN
            l_select_generic := l_select_generic || 'pap.full_name, ';
                                                                  --person_id
         END IF;

         l_select_generic := l_select_generic || 'wdth.effective_start_date, ';
                                                        --effective_start_date
         l_select_generic := l_select_generic || 'wdth.effective_end_date, ';
                                                          --effective_end_date
         l_select_generic := l_select_generic || 'wdth.person_resource_id, ';
                                                          --person_resource_id

         IF g_person_resource_visible = 'T'
         THEN
            l_select_generic := l_select_generic || 'br1.resource_code, ';
                                                       --person_resource_code
         END IF;

         l_select_generic := l_select_generic || 'wdth.machine_resource_id, ';
                                                         --machine_resource_id

         IF g_machine_resource_visible = 'T'
         THEN
            l_select_generic := l_select_generic || 'br2.resource_code, ';
                                                      --machine_resource_code
         END IF;

         l_select_generic := l_select_generic || 'wdth.equipment_instance, ';
                                                          --equipment_instance
         l_select_generic := l_select_generic || 'wdth.dispatched_time, ';
                                                             --dispatched_time
         l_select_generic := l_select_generic || 'wdth.loaded_time, ';
                                                                 --loaded_time
         l_select_generic := l_select_generic || 'wdth.drop_off_time, ';
                                                               --drop_off_time
         l_select_generic := l_select_generic || 'to_date(null), ';
                                                        --wdt_last_update_date
         l_select_generic := l_select_generic || 'to_number(null), ';
                                                         --wdt_last_updated_by
         l_select_generic := l_select_generic || '''N'', ';       --is_modified

          -- bug #5163661
         IF NOT (wms_plan_tasks_pvt.g_include_inbound OR wms_plan_tasks_pvt.g_include_crossdock) THEN
             -- Bug #4141928
             l_select_generic := l_select_generic || 'mmt.secondary_uom_code, ';
                                                                 --sec_transaction_uom
             l_select_generic :=
                             l_select_generic || 'abs(mmt.secondary_transaction_quantity), ';
                                                            --sec_transaction_quantity

              l_select_generic := l_select_generic || 'mmt.transaction_set_id ';
   							-- bug 4510849
         ELSE
            -- Bug #4141928
            l_select_generic := l_select_generic || 'mmt.secondary_uom_code, ';
                                                                --sec_transaction_uom
            l_select_generic :=
                            l_select_generic || 'abs(mmt.secondary_transaction_quantity) ';
                                                           --sec_transaction_quantity
	      END IF;

         RETURN l_select_generic;
      ELSE                        --p_is_completed and p_populate_merged_tasks
         --Patchset J Bulk Picking Enhancement
         --We are now showing completed parent tasks since completed parent
         --tasks will now be stored in wdth.  However, since it still will
         --not be in mmt, we can only query from wdth when querying for
         --completed parent tasks.

         -- Build the generic select section of the query
         l_select_generic := 'SELECT ';
         l_select_generic := l_select_generic || 'null, ';  -- expansion_code
         l_select_generic :=
               l_select_generic
            || 'decode(wdth.is_parent,'
            || '''N'', decode(wdth.operation_plan_id,null, decode(wdth.parent_transaction_id,null,'''
            || g_plan_task_types (1)
            || ''','''
            || g_plan_task_types (5)
            || '''),'''
            || g_plan_task_types (2)
            || '''), '
            || 'decode(wdth.transaction_action_id,28,'''
            || g_plan_task_types (4)
            || ''','
            || 'decode(wdth.transaction_source_type_id,'
            || '5,decode(wdth.transaction_type_id,35,'''
            || g_plan_task_types (4)
            || ''','''
            || g_plan_task_types (3)
            || '''),'
            || '13, decode(wdth.transaction_type_id,51,'''
           || g_plan_task_types (4)
            || ''','''
            || g_plan_task_types (3)
            || '''),'''
            || g_plan_task_types (3)
            || '''))),';                                  --plan_task
         l_select_generic := l_select_generic || 'wdth.transaction_id, ';
                                                         --transaction_temp_id
         l_select_generic := l_select_generic || 'wdth.parent_transaction_id,';
                                                              --parent_line_id
         l_select_generic := l_select_generic || 'wdth.inventory_item_id, ';
                                                           --inventory_item_id
         l_select_generic :=
                            l_select_generic || 'msiv.concatenated_segments, ';
                                                                        --item
         l_select_generic := l_select_generic || 'msiv.description, ';
                                                            --item description
         l_select_generic := l_select_generic || 'msiv.unit_weight, ';
                                                                 --unit_weight
         l_select_generic := l_select_generic || 'msiv.weight_uom_code, ';
                                                             --weight_uom_code
         l_select_generic := l_select_generic || 'msiv.unit_volume, ';
                                                                 --unit_volume
         l_select_generic := l_select_generic || 'msiv.volume_uom_code, ';
                                                             --volume_uom_code
         l_select_generic := l_select_generic || 'wdth.organization_id, ';
                                                             --organization_id
         l_select_generic := l_select_generic || 'wdth.revision, '; --revision
         l_select_generic :=
                         l_select_generic || 'wdth.source_subinventory_code, ';
                                                                --subinventory
         l_select_generic := l_select_generic || 'wdth.source_locator_id, ';
                                                                  --locator_id
         --locator
         l_select_generic :=
               l_select_generic
            || 'decode(milv.segment19, null, milv.concatenated_segments, null), ';
         l_select_generic := l_select_generic || '6, ';            --status_id
         l_select_generic := l_select_generic || '6, ';   --status_id_original
         l_select_generic :=
                       l_select_generic || '''' || g_status_codes (6)
                       || ''', ';                                     --status
         l_select_generic := l_select_generic || 'wdth.transaction_type_id, ';
                                                         --transaction_type_id
         l_select_generic :=
                            l_select_generic || 'wdth.transaction_action_id, ';
                                                       --transaction_action_id
         l_select_generic :=
                       l_select_generic || 'wdth.transaction_source_type_id, ';
                                                  --transaction_source_type_id

         IF g_txn_source_type_visible = 'T'
         THEN
            l_select_generic :=
                    l_select_generic || 'mtst.transaction_source_type_name, ';
                                                    --transaction_source_type
         END IF;

         l_select_generic := l_select_generic || 'to_number(null), ';
                                                       --transaction_source_id
         l_select_generic := l_select_generic || 'to_number(null), ';
                                                  --transaction_source_line_id
         l_select_generic :=
                         l_select_generic || 'wdth.transfer_organization_id, ';
                                                          --to_organization_id

         IF g_to_organization_code_visible = 'T'
         THEN
            l_select_generic := l_select_generic || 'mp1.organization_code, ';
                                                         --to_organization_id
         END IF;

         l_select_generic := l_select_generic || 'null, ';   --to_subinventory
         l_select_generic := l_select_generic || 'to_number(null),  ';
                                                               --to_locator_id

         IF g_to_locator_visible = 'T'
         THEN
            --to locator
            l_select_generic := l_select_generic || 'null, ';
         END IF;

         l_select_generic := l_select_generic || 'wdth.transaction_uom_code, ';
                                                             --transaction_uom
         l_select_generic := l_select_generic || 'to_number(null), ';
                                                        --transaction_quantity
         l_select_generic := l_select_generic || 'wdth.user_task_type, ';
                                                           --user_task_type_id

         IF g_user_task_type_visible = 'T'
         THEN
            l_select_generic := l_select_generic || 'bso.operation_code, ';
                                                             --user_task_type
         END IF;

         l_select_generic := l_select_generic || 'to_number(null), ';
                                                          --move_order_line_id
         l_select_generic := l_select_generic || 'to_number(null), ';
                                                            --pick_slip_number
         l_select_generic := l_select_generic || 'to_number(null), ';
                                                            --cartonization_id
         IF g_cartonization_lpn_visible = 'T' THEN
         l_select_generic := l_select_generic || 'null, '; --cartonization_lpn
         END IF;
         l_select_generic := l_select_generic || 'to_number(null), ';
                                                            --allocated_lpn_id
         IF g_allocated_lpn_visible = 'T' THEN
            l_select_generic := l_select_generic || 'null, ';
         END IF;

         l_select_generic := l_select_generic || 'to_number(null), ';
                                                           --container_item_id
         IF g_container_item_visible = 'T' THEN
            l_select_generic := l_select_generic || 'null, ';
         END IF;


         l_select_generic := l_select_generic || 'wdth.lpn_id, ';
                                                              --from_lpn_id

         IF g_from_lpn_visible = 'T'
         THEN
            l_select_generic :=
                           l_select_generic || 'wlpn5.license_plate_number, ';
                                                                --from_lpn
         END IF;

         l_select_generic := l_select_generic || 'wdth.content_lpn_id, ';
                                                              --content_lpn_id

         IF g_content_lpn_visible = 'T'
         THEN
            l_select_generic :=
                           l_select_generic || 'wlpn3.license_plate_number, ';
                                                                --content_lpn
         END IF;

         l_select_generic := l_select_generic || 'wdth.transfer_lpn_id, ';
                                                                   --to_lpn_id

         IF g_to_lpn_visible = 'T'
         THEN
            l_select_generic :=
                           l_select_generic || 'wlpn4.license_plate_number, ';
                                                                     --to_lpn
         END IF;

         l_select_generic := l_select_generic || 'to_date(null), ';
                                                        --mmt_last_update_date
         l_select_generic := l_select_generic || 'to_number(null), ';
                                                         --mmt_last_updated_by
         l_select_generic := l_select_generic || 'wdth.priority, '; --priority
         l_select_generic := l_select_generic || 'wdth.priority, ';
                                                           --priority_original
         l_select_generic := l_select_generic || 'wdth.task_type, ';
                                                                --task_type_id
         --task_type
         l_select_generic :=
               l_select_generic
            || 'decode(wdth.task_type,'
            || '1, '''
            || g_task_types (1)
            || ''', 2, '''
            || g_task_types (2)
            || ''', 3, '''
            || g_task_types (3)
            || ''', 4, '''
            || g_task_types (4)
            || ''', 5, '''
            || g_task_types (5)
            || ''', 6, '''
            || g_task_types (6)
            || ''', 7, '''
            || g_task_types (7)
            || ''', 8, '''
            || g_task_types (8)
            || '''), ';
         l_select_generic := l_select_generic || 'to_date(null), ';
                                                               --creation_time
         l_select_generic := l_select_generic || 'wdth.operation_plan_id, ';
                                                           --operation_plan_id

         IF g_operation_plan_visible = 'T'
         THEN
            l_select_generic :=
                              l_select_generic || 'wop.operation_plan_name, ';
                                                             --operation_plan
         END IF;

         IF g_operation_sequence_visible = 'T' THEN
             l_select_generic := l_select_generic || 'to_number(null),  '; --operation_sequence
         END IF;

         -- IF g_op_plan_instance_id_visible = 'T' THEN
         l_select_generic := l_select_generic || 'wdth.op_plan_instance_id,  ';
                                                         --op_plan_instance_id

         --END IF;
         l_select_generic := l_select_generic || 'wdth.task_id, ';   --task_id
         l_select_generic := l_select_generic || 'wdth.person_id, ';
                                                                   --person_id
         l_select_generic := l_select_generic || 'wdth.person_id, ';
                                                          --person_id_original

         IF g_person_visible = 'T'
         THEN
            l_select_generic := l_select_generic || 'pap.full_name, ';
                                                                  --person_id
         END IF;

         l_select_generic := l_select_generic || 'wdth.effective_start_date, ';
                                                        --effective_start_date
         l_select_generic := l_select_generic || 'wdth.effective_end_date, ';
                                                          --effective_end_date
         l_select_generic := l_select_generic || 'wdth.person_resource_id, ';
                                                          --person_resource_id

         IF g_person_resource_visible = 'T'
         THEN
            l_select_generic := l_select_generic || 'br1.resource_code, ';
                                                       --person_resource_code
         END IF;

         l_select_generic := l_select_generic || 'wdth.machine_resource_id, ';
                                                         --machine_resource_id

         IF g_machine_resource_visible = 'T'
         THEN
            l_select_generic := l_select_generic || 'br2.resource_code, ';
                                                      --machine_resource_code
         END IF;

         l_select_generic := l_select_generic || 'wdth.equipment_instance, ';
                                                          --equipment_instance
         l_select_generic := l_select_generic || 'wdth.dispatched_time, ';
                                                             --dispatched_time
         l_select_generic := l_select_generic || 'wdth.loaded_time, ';
                                                                 --loaded_time
         l_select_generic := l_select_generic || 'wdth.drop_off_time, ';
                                                               --drop_off_time
         l_select_generic := l_select_generic || 'to_date(null), ';
                                                        --wdt_last_update_date
         l_select_generic := l_select_generic || 'to_number(null), ';
                                                         --wdt_last_updated_by
         l_select_generic := l_select_generic || '''N'', ';       --is_modified

         -- bug #5163661
         IF NOT (wms_plan_tasks_pvt.g_include_inbound OR wms_plan_tasks_pvt.g_include_crossdock) THEN
            -- Bug #4141928
            l_select_generic := l_select_generic || 'wdth.secondary_transaction_uom_code, ';
                                                                --sec_transaction_uom
            l_select_generic := l_select_generic || 'to_number(null), ';
                                                           --sec_transaction_quantity
            l_select_generic := l_select_generic || 'mmt.transaction_set_id ';
   							-- bug 4510849
         ELSE
            -- Bug #4141928
            l_select_generic := l_select_generic || 'wdth.secondary_transaction_uom_code, ';
                                                                --sec_transaction_uom
            l_select_generic := l_select_generic || 'to_number(null) ';
                                                           --sec_transaction_quantity
	      END IF;
       RETURN l_select_generic;
       END IF;
   END get_generic_select;

   FUNCTION get_generic_from (
      p_is_queued               BOOLEAN DEFAULT FALSE,
      p_is_dispatched           BOOLEAN DEFAULT FALSE,
      p_is_active               BOOLEAN DEFAULT FALSE,
      p_is_loaded               BOOLEAN DEFAULT FALSE,
      p_is_completed            BOOLEAN DEFAULT FALSE,
      p_item_category_id        NUMBER DEFAULT NULL,
      p_category_set_id         NUMBER DEFAULT NULL,
      p_populate_merged_tasks   BOOLEAN DEFAULT FALSE
   )
      RETURN VARCHAR2
   IS
      l_from_generic   VARCHAR2 (2000);
   BEGIN
      -- Build the generic from section of the query
      l_from_generic := ' FROM ';

      IF NOT p_is_completed
      THEN
         l_from_generic :=
                     l_from_generic || 'mtl_material_transactions_temp mmtt ';

         --IF g_op_plan_instance_id_visible = 'T' AND
         IF wms_plan_tasks_pvt.g_query_planned_tasks = TRUE
         THEN
            l_from_generic :=
                        l_from_generic || ', wms_op_operation_instances wooi';
         END IF;

         IF p_is_queued OR p_is_dispatched OR p_is_loaded OR p_is_active
         THEN
            l_from_generic := l_from_generic || ', wms_dispatched_tasks wdt ';
         END IF;
      ELSE                                           -- if p_is_completed then
         --Patchset J Bulk Picking Enhancement
         --Only include mmt if not querying for completed parent tasks
         --because completed parent tasks are not in mmt
         IF NOT p_populate_merged_tasks
         THEN
            l_from_generic :=
                          l_from_generic || 'mtl_material_transactions mmt, ';
         END IF;

         l_from_generic :=
                         l_from_generic || 'wms_dispatched_tasks_history wdth';
         /*IF g_operation_sequence_visible = 'T' AND wms_plan_tasks_pvt.g_query_planned_tasks = TRUE THEN
            l_from_generic :=
                         l_from_generic || 'wms_op_opertn_instances_hist wooih';
         END IF; */


      END IF;

      IF p_populate_merged_tasks
      THEN
         l_from_generic :=
               l_from_generic
            || ', (select distinct parent_line_id from wms_waveplan_tasks_temp where task_type_id <> 3) wwtt';
      END IF;

      l_from_generic := l_from_generic || ', mtl_system_items_kfv msiv ';
      l_from_generic := l_from_generic || ', mtl_item_locations_kfv milv ';

      IF p_item_category_id IS NOT NULL OR p_category_set_id IS NOT NULL
      THEN
         l_from_generic := l_from_generic || ', mtl_item_categories mic ';
      END IF;

      IF g_allocated_lpn_visible = 'T' AND NOT p_is_completed
      THEN
         l_from_generic :=
                       l_from_generic || ', wms_license_plate_numbers wlpn1 ';
      END IF;

      IF g_cartonization_lpn_visible = 'T' AND NOT p_is_completed
      THEN
         l_from_generic :=
                       l_from_generic || ', wms_license_plate_numbers wlpn2 ';
      END IF;

      IF g_container_item_visible = 'T' AND NOT p_is_completed
      THEN
         l_from_generic := l_from_generic || ', mtl_system_items_kfv msiv1 ';
      END IF;

      IF g_from_lpn_visible = 'T'
      THEN
         l_from_generic :=
                       l_from_generic || ', wms_license_plate_numbers wlpn5 ';
      END IF;

      IF g_content_lpn_visible = 'T'
      THEN
         l_from_generic :=
                       l_from_generic || ', wms_license_plate_numbers wlpn3 ';
      END IF;

      IF g_to_lpn_visible = 'T'
      THEN
         l_from_generic :=
                       l_from_generic || ', wms_license_plate_numbers wlpn4 ';
      END IF;

      IF g_user_task_type_visible = 'T'
      THEN
         l_from_generic := l_from_generic || ', bom_standard_operations bso ';
      END IF;

      IF g_to_organization_code_visible = 'T'
      THEN
         l_from_generic := l_from_generic || ', mtl_parameters mp1 ';
      END IF;

      IF     g_to_locator_visible = 'T'
         AND NOT (p_populate_merged_tasks AND p_is_completed)
      THEN
         --Change
         --AND NOT p_populate_merged_tasks THEN
         --End of change
         l_from_generic :=
                          l_from_generic || ', mtl_item_locations_kfv milv1 ';
      END IF;

      IF g_txn_source_type_visible = 'T'
      THEN
         l_from_generic := l_from_generic || ', mtl_txn_source_types mtst ';
      END IF;

      IF g_operation_plan_visible = 'T'
      THEN
         l_from_generic := l_from_generic || ', wms_op_plans_vl wop ';
      END IF;

      IF (   p_is_queued
          OR p_is_dispatched
          OR p_is_loaded
          OR p_is_active
          OR p_is_completed
         )
      THEN
         IF g_person_resource_visible = 'T'
         THEN
            l_from_generic := l_from_generic || ', bom_resources br1 ';
         END IF;

         IF g_machine_resource_visible = 'T'
         THEN
            l_from_generic := l_from_generic || ', bom_resources br2 ';
         END IF;

         IF g_person_visible = 'T'
         THEN
            l_from_generic := l_from_generic || ', per_all_people_f pap ';
         END IF;
      END IF;

      RETURN l_from_generic;
   END get_generic_from;

   FUNCTION get_generic_where (
      p_add                     BOOLEAN DEFAULT FALSE,
      p_organization_id         NUMBER DEFAULT NULL,
      p_subinventory_code       VARCHAR2 DEFAULT NULL,
      p_locator_id              NUMBER DEFAULT NULL,
      p_to_subinventory_code    VARCHAR2 DEFAULT NULL,
      p_to_locator_id           NUMBER DEFAULT NULL,
      p_inventory_item_id       NUMBER DEFAULT NULL,
      p_category_set_id         NUMBER DEFAULT NULL,
      p_item_category_id        NUMBER DEFAULT NULL,
      p_person_id               NUMBER DEFAULT NULL,
      p_person_resource_id      NUMBER DEFAULT NULL,
      p_equipment_type_id       NUMBER DEFAULT NULL,
      p_machine_resource_id     NUMBER DEFAULT NULL,
      p_machine_instance        VARCHAR2 DEFAULT NULL,
      p_user_task_type_id       NUMBER DEFAULT NULL,
      p_from_task_quantity      NUMBER DEFAULT NULL,
      p_to_task_quantity        NUMBER DEFAULT NULL,
      p_from_task_priority      NUMBER DEFAULT NULL,
      p_to_task_priority        NUMBER DEFAULT NULL,
      p_from_creation_date      DATE DEFAULT NULL,
      p_to_creation_date        DATE DEFAULT NULL,
      p_include_cycle_count     BOOLEAN DEFAULT FALSE,
      p_is_unreleased           BOOLEAN DEFAULT FALSE,
      p_is_pending              BOOLEAN DEFAULT FALSE,
      p_is_queued               BOOLEAN DEFAULT FALSE,
      p_is_dispatched           BOOLEAN DEFAULT FALSE,
      p_is_active               BOOLEAN DEFAULT FALSE,
      p_is_loaded               BOOLEAN DEFAULT FALSE,
      p_is_completed            BOOLEAN DEFAULT FALSE,
      p_populate_merged_tasks   BOOLEAN DEFAULT FALSE,
      p_outbound_tasks_cycle    BOOLEAN DEFAULT FALSE,      -- bug #4661615
      -- R12 : Additional Query Criteria
      p_item_type_code                            VARCHAR2 DEFAULT NULL,
   	p_age_uom_code                              VARCHAR2 DEFAULT NULL,
   	p_age_min                                   NUMBER DEFAULT NULL,
   	p_age_max                                   NUMBER DEFAULT NULL
      -- R12 : Additional Query Criteria
   )
      RETURN VARCHAR2
   IS
      l_where_generic   VARCHAR2 (4000);
      l_debug   NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
      --R12: Additional Query criteria
      --Age UOM conversion factor
      n                 VARCHAR2 (10);
   BEGIN
      IF l_debug = 1 then
        IF p_outbound_tasks_cycle THEN
          debug('p_outbound_tasks_cycle : true');
        ELSE
          debug('p_outbound_tasks_cycle : false');
        END IF;
      END IF;

      IF NOT p_is_completed
      THEN
         -- Build the generic where section of the query
         IF p_add
         THEN
            l_where_generic :=
                   'WHERE NOT exists (SELECT 1 FROM wms_waveplan_tasks_temp ';
            l_where_generic :=
                  l_where_generic
               || 'WHERE transaction_temp_id = mmtt.transaction_temp_id ';
            l_where_generic := l_where_generic || 'AND task_type_id <> 3) ';
         ELSE
            l_where_generic := 'WHERE 1=1 ';
         END IF;

         --IF g_op_plan_instance_id_visible = 'T' AND
         IF wms_plan_tasks_pvt.g_query_planned_tasks
         THEN
            l_where_generic :=
                  l_where_generic
               || ' AND mmtt.transaction_temp_id = wooi.source_task_id (+) ';
         END IF;

         IF     (p_is_unreleased OR p_is_pending)
            AND NOT (p_is_queued OR p_is_dispatched OR p_is_loaded
                     OR p_is_active
                    )
         THEN

	    -- bug #4459382
            -- retrive no pending/unreleased tasks if employee criterion is given
            IF  p_person_id IS NOT NULL OR
               p_person_resource_id IS NOT NULL OR
               p_equipment_type_id IS NOT NULL OR
               p_machine_resource_id IS NOT NULL OR
               p_machine_instance IS NOT NULL
            THEN
               l_where_generic := l_where_generic || 'AND 1 = 2 ';
            END IF;

            -- Query records present only in MMTT
            IF p_is_unreleased AND NOT p_is_pending
            THEN
               l_where_generic :=
                   l_where_generic || 'AND nvl(mmtt.wms_task_status, 1) = 8 ';
            ELSIF NOT p_is_unreleased AND p_is_pending
            THEN
               l_where_generic :=
                   l_where_generic || 'AND nvl(mmtt.wms_task_status, 1) = 1 ';
            END IF;

            IF p_is_pending
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND NOT EXISTS (SELECT 1 FROM wms_dispatched_tasks ';
               l_where_generic :=
                     l_where_generic
                  || '                WHERE transaction_temp_id = mmtt.transaction_temp_id) ';
            END IF;
         ELSIF     (p_is_unreleased OR p_is_pending)
               AND (p_is_queued OR p_is_dispatched OR p_is_loaded
                    OR p_is_active
                   )
         THEN
            -- Query records present only in MMTT as well as those in both MMTT and WDT
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.transaction_temp_id = wdt.transaction_temp_id(+) ';
            l_where_generic :=
                  l_where_generic
               || 'AND decode(wdt.status, null, nvl(mmtt.wms_task_status, 1), wdt.status) in ( ';

            IF p_is_unreleased
            THEN
               l_where_generic := l_where_generic || '8';
            END IF;

            IF p_is_pending
            THEN
               IF p_is_unreleased
               THEN
                  l_where_generic := l_where_generic || ', 1';
               ELSE
                  l_where_generic := l_where_generic || '1';
               END IF;
            END IF;

            IF p_is_queued
            THEN
               IF p_is_unreleased OR p_is_pending
               THEN
                  l_where_generic := l_where_generic || ', 2';
               ELSE
                  l_where_generic := l_where_generic || '2';
               END IF;
            END IF;

            IF p_is_dispatched
            THEN
               IF p_is_unreleased OR p_is_pending OR p_is_queued
               THEN
                  l_where_generic := l_where_generic || ', 3';
               ELSE
                  l_where_generic := l_where_generic || '3';
               END IF;
            END IF;

            IF p_is_loaded
            THEN
               IF    p_is_unreleased
                  OR p_is_pending
                  OR p_is_queued
                  OR p_is_dispatched
               THEN
                  l_where_generic := l_where_generic || ', 4';
               ELSE
                  l_where_generic := l_where_generic || '4';
               END IF;
            END IF;

            IF p_is_active
            THEN
               IF    p_is_unreleased
                  OR p_is_pending
                  OR p_is_queued
                  OR p_is_dispatched
                  OR p_is_loaded
               THEN
                  l_where_generic := l_where_generic || ', 9';
               ELSE
                  l_where_generic := l_where_generic || '9';
               END IF;
            END IF;

            l_where_generic := l_where_generic || ') ';

            IF g_person_resource_visible = 'T'
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND wdt.person_resource_id = br1.resource_id(+) ';
            END IF;

            IF g_machine_resource_visible = 'T'
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND wdt.machine_resource_id = br2.resource_id(+) ';
            END IF;

            IF g_person_visible = 'T'
            THEN
               l_where_generic :=
                   l_where_generic || 'AND wdt.person_id = pap.person_id(+) ';
               l_where_generic :=
                     l_where_generic
                  || 'AND wdt.effective_start_date >= pap.effective_start_date(+) ';
               l_where_generic :=
                     l_where_generic
                  || 'AND wdt.effective_end_date <= pap.effective_end_date(+) ';
            END IF;

	    -- Bug #4459382
            -- Add the employee criteria to the where clause

            IF p_person_id IS NOT NULL
            THEN
               l_where_generic :=
                            l_where_generic || 'AND (wdt.person_id IS NULL OR wdt.person_id = :person_id) '; /* Bug 5446146  */ -- Bug 7589766
            END IF;

            IF p_person_resource_id IS NOT NULL
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND (wdt.person_resource_id IS NULL OR wdt.person_resource_id = :person_resource_id) ';  -- Bug 7589766
            END IF;

            IF p_equipment_type_id IS NOT NULL
            THEN
               l_where_generic :=
                  l_where_generic
                  || 'AND (wdt.equipment_id IS NULL OR wdt.equipment_id = :equipment_type_id) ';  -- Bug 7589766
            END IF;

            IF p_machine_resource_id IS NOT NULL
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND (wdt.machine_resource_id IS NULL OR wdt.machine_resource_id = :machine_resource_id) ';  -- Bug 7589766
            END IF;

            IF p_machine_instance IS NOT NULL
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND (wdt.equipment_instance IS NULL OR wdt.equipment_instance = :machine_instance) ';  -- Bug 7589766
            END IF;

         ELSIF     NOT (p_is_unreleased OR p_is_pending)
               AND (p_is_queued OR p_is_dispatched OR p_is_loaded
                    OR p_is_active
                   )
         THEN
            -- Query records present both in MMTT and WDT
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.transaction_temp_id = wdt.transaction_temp_id ';
            l_where_generic := l_where_generic || 'AND wdt.status in ( ';

            IF p_is_queued
            THEN
               l_where_generic := l_where_generic || '2';
            END IF;

            IF p_is_dispatched
            THEN
               IF p_is_queued
               THEN
                  l_where_generic := l_where_generic || ', 3';
               ELSE
                  l_where_generic := l_where_generic || '3';
               END IF;
            END IF;

            IF p_is_loaded
            THEN
               IF p_is_queued OR p_is_dispatched
               THEN
                  l_where_generic := l_where_generic || ', 4';
               ELSE
                  l_where_generic := l_where_generic || '4';
               END IF;
            END IF;

            IF p_is_active
            THEN
               IF p_is_queued OR p_is_dispatched OR p_is_loaded
               THEN
                  l_where_generic := l_where_generic || ', 9';
               ELSE
                  l_where_generic := l_where_generic || '9';
               END IF;
            END IF;

            l_where_generic := l_where_generic || ') ';

            IF g_person_resource_visible = 'T'
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND wdt.person_resource_id = br1.resource_id(+) ';
            END IF;

            IF g_machine_resource_visible = 'T'
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND wdt.machine_resource_id = br2.resource_id(+) ';
            END IF;

            IF g_person_visible = 'T'
            THEN
               l_where_generic :=
                   l_where_generic || 'AND wdt.person_id = pap.person_id(+) ';
               l_where_generic :=
                     l_where_generic
                  || 'AND wdt.effective_start_date >= pap.effective_start_date(+) ';
               l_where_generic :=
                     l_where_generic
                  || 'AND wdt.effective_end_date <= pap.effective_end_date(+) ';
            END IF;

	    -- Bug #4459382
            -- Add the employee criteria to the where clause

            IF p_person_id IS NOT NULL
            THEN
               l_where_generic :=
                            l_where_generic || 'AND (wdt.person_id IS NULL OR wdt.person_id = :person_id) ';  -- Bug 7589766
            END IF;

            IF p_person_resource_id IS NOT NULL
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND (wdt.person_resource_id IS NULL OR wdt.person_resource_id = :person_resource_id) ';  -- Bug 7589766
            END IF;

            IF p_equipment_type_id IS NOT NULL
            THEN
               l_where_generic :=
                  l_where_generic
                  || 'AND (wdt.equipment_id IS NULL OR wdt.equipment_id = :equipment_type_id) ';  -- Bug 7589766
            END IF;

            IF p_machine_resource_id IS NOT NULL
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND (wdt.machine_resource_id IS NULL OR wdt.machine_resource_id = :machine_resource_id) ';  -- Bug 7589766
            END IF;

            IF p_machine_instance IS NOT NULL
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND (wdt.equipment_instance IS NULL OR wdt.equipment_instance = :machine_instance) ';  -- Bug 7589766
            END IF;

         END IF;

         IF p_populate_merged_tasks
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.transaction_temp_id = wwtt.parent_line_id ';
         END IF;

         l_where_generic :=
               l_where_generic
            || 'AND mmtt.organization_id = msiv.organization_id ';
         l_where_generic :=
               l_where_generic
            || 'AND mmtt.inventory_item_id = msiv.inventory_item_id ';
         l_where_generic :=
               l_where_generic
            || 'AND mmtt.organization_id = milv.organization_id(+) ';
         l_where_generic :=
               l_where_generic
            || 'AND mmtt.locator_id = milv.inventory_location_id(+) ';

         IF g_to_organization_code_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.transfer_organization = mp1.organization_id(+) ';
         END IF;

         IF g_to_locator_visible = 'T'
         THEN
            --Bug 2838178
            l_where_generic :=
                  l_where_generic
               || 'AND milv1.organization_id(+) = nvl(mmtt.transfer_organization,mmtt.organization_id) ';
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.transfer_subinventory = milv1.subinventory_code(+) ';
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.transfer_to_location = milv1.inventory_location_id(+) ';
         END IF;

         IF g_txn_source_type_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.transaction_source_type_id = mtst.transaction_source_type_id ';
         END IF;

         IF g_allocated_lpn_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.allocated_lpn_id = wlpn1.lpn_id(+) ';
         END IF;

         IF g_cartonization_lpn_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.cartonization_id = wlpn2.lpn_id(+) ';
         END IF;

         IF g_container_item_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.container_item_id = msiv1.inventory_item_id(+) ';
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.organization_id = msiv1.organization_id(+) ';
         END IF;

         IF g_from_lpn_visible = 'T'
         THEN
            l_where_generic :=
               l_where_generic
               || 'AND mmtt.lpn_id = wlpn5.lpn_id(+) ';
         END IF;

         IF g_content_lpn_visible = 'T'
         THEN
            l_where_generic :=
               l_where_generic
               || 'AND mmtt.content_lpn_id = wlpn3.lpn_id(+) ';
         END IF;

         IF g_to_lpn_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.transfer_lpn_id = wlpn4.lpn_id(+) ';
         END IF;

         IF g_user_task_type_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.standard_operation_id = bso.standard_operation_id(+) ';
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.organization_id = bso.organization_id(+) ';
         END IF;

         IF g_operation_plan_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.operation_plan_id = wop.operation_plan_id(+) ';
         END IF;

         IF p_organization_id IS NOT NULL
         THEN
            l_where_generic :=
                     l_where_generic || 'AND mmtt.organization_id = :org_id ';
         END IF;

         IF p_subinventory_code IS NOT NULL
         THEN
            l_where_generic :=
                 l_where_generic || 'AND mmtt.subinventory_code = :sub_code ';
         END IF;

         IF p_locator_id IS NOT NULL
         THEN
            l_where_generic :=
                          l_where_generic || 'AND mmtt.locator_id = :loc_id ';
         END IF;

         IF p_to_subinventory_code IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.transfer_subinventory = :to_sub_code ';
         END IF;

         IF p_to_locator_id IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.transfer_to_location = :to_loc_id ';
         END IF;

         IF p_inventory_item_id IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic || 'AND mmtt.inventory_item_id = :item_id ';
         END IF;
         -- R12 : Additional Query Criteria using item type
         IF p_item_type_code IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic || 'AND msiv.item_type = :item_type_code ';
         END IF;


         IF p_category_set_id IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mic.category_set_id = :category_set_id ';
         END IF;

         IF p_item_category_id IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.inventory_item_id = mic.inventory_item_id ';
            l_where_generic :=
                 l_where_generic || 'AND mic.category_id = :item_category_id ';
            l_where_generic :=
                  l_where_generic
               || 'AND mic.organization_id = mmtt.organization_id ';
         END IF;

         IF p_user_task_type_id IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND nvl(mmtt.standard_operation_id,:user_task_type_id) = :user_task_type_id '; /* Bug 5446146 */
         END IF;

         IF p_from_task_quantity IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.transaction_quantity >= :from_task_quantity ';
         END IF;

         IF p_to_task_quantity IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.transaction_quantity <= :to_task_quantity ';
         END IF;

         IF p_from_task_priority IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.task_priority >= :from_task_priority ';
         END IF;

         IF p_to_task_priority IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.task_priority <= :to_task_priority ';
         END IF;

         IF p_from_creation_date IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
              -- || 'AND mmtt.creation_date >= :from_creation_date '; --commented in 6868286
               || 'AND TRUNC(mmtt.creation_date) >= TRUNC(:from_creation_date) '; --added in 6868286
         END IF;

         IF p_to_creation_date IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
             --  || 'AND mmtt.creation_date <= :to_creation_date '; --commented in 6868286
               || 'AND TRUNC(mmtt.creation_date) <= TRUNC(:to_creation_date) '; --added in 6868286
         END IF;

         -- R12: Additional Query criteria using age of the task
         IF p_age_uom_code IS NOT NULL
         THEN

            IF    p_age_uom_code = 2 THEN  -- Minutes
               n := '*(24 * 60)';
            ELSIF p_age_uom_code = 3 THEN  -- Hours
               n := '*(24)';
            ELSIF p_age_uom_code = 4 THEN  -- Days
               n := '*(1)';
            ELSIF p_age_uom_code = 5 THEN  -- Weeks
               n := '/(7)';
            ELSIF p_age_uom_code = 6 THEN  -- Months
               n := '/(7 * 31)';
            END IF;

            IF p_age_min IS NOT NULL
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND (sysdate - mmtt.creation_date)'||n||' >= :age_min ';
            END IF;

            IF p_age_max IS NOT NULL
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND (sysdate - mmtt.creation_date)'||n||' <= :age_max ';
            END IF;
         END IF;

	 --Bug#8546026
	 IF p_is_unreleased THEN
         l_where_generic :=
                  l_where_generic
               || ' AND nvl(mmtt.lock_flag,''$'') <> ''Y'' ';
         END IF;

      ELSIF (p_is_completed AND NOT p_populate_merged_tasks)
      THEN
         IF p_add
         THEN
            l_where_generic :=
                   'WHERE NOT exists (SELECT 1 FROM wms_waveplan_tasks_temp ';
            l_where_generic :=
                  l_where_generic
               || 'WHERE transaction_temp_id = mmt.transaction_id) ';
         ELSE
            l_where_generic := 'WHERE 1=1 ';
         END IF;

         IF NOT p_include_cycle_count
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND decode(mmt.transfer_transaction_id, null, 0, mmt.transaction_quantity) <= 0 ';
         END IF;

        /**With ATF changes the source_document_id of WDTH maps to transaction_set_id of MMT.
         * Hence changing the join here. Since we support pre-Patchset J records, we use NVL
         * to retain the earlier join. Also in Patchset J, this is only done for Inbound
         * specific transactions. With ATF changes for Outbound and Warehousing we would
         * just need to remove the If condition.Hence leaving it in generic_where
         */

         IF wms_plan_tasks_pvt.g_from_inbound THEN

           l_where_generic := l_where_generic ||
              ' AND mmt.transaction_set_id = nvl(wdth.source_document_id,wdth.transaction_id) ';
           wms_plan_tasks_pvt.g_from_inbound := FALSE;
         ELSE
         l_where_generic :=
               l_where_generic
            || 'AND mmt.transaction_set_id = wdth.transaction_id ';


         END IF;
         l_where_generic :=
               l_where_generic
            || 'AND nvl(mmt.transaction_batch_id, -1) = decode(wdth.task_type, ';
         l_where_generic :=
             l_where_generic || '      2, nvl(mmt.transaction_batch_id, -1), ';
         l_where_generic :=
             l_where_generic || '      3, nvl(mmt.transaction_batch_id, -1), ';
         l_where_generic :=
                 l_where_generic || '      decode(wdth.transaction_batch_id, ';
         l_where_generic :=
               l_where_generic
            || '      -999,nvl(mmt.transaction_batch_id,-1), nvl(wdth.transaction_batch_id, nvl(mmt.transaction_batch_id,-1) ))) '; /* Bug 5553303 */
         l_where_generic :=
               l_where_generic
            || 'AND nvl(mmt.transaction_batch_seq, -1) = decode(wdth.task_type, ';
         l_where_generic :=
            l_where_generic || '      2, nvl(mmt.transaction_batch_seq, -1), ';
         l_where_generic :=
            l_where_generic || '      3, nvl(mmt.transaction_batch_seq, -1), ';
         l_where_generic :=
               l_where_generic
            || 'decode(wdth.transaction_batch_seq, -999,nvl(mmt.transaction_batch_seq,-1),nvl(wdth.transaction_batch_seq, nvl(mmt.transaction_batch_seq,-1) ))) '; /* Bug 5553303 */
         l_where_generic :=
               l_where_generic
            || 'AND mmt.organization_id = msiv.organization_id ';
         l_where_generic :=
               l_where_generic
            || 'AND mmt.inventory_item_id = msiv.inventory_item_id ';


         IF p_outbound_tasks_cycle THEN  -- bug #4661615
            if l_debug = 1 then
	      debug(' get_gen_where : p_outbound_tasks_cycle = true' );
	    end if;
            l_where_generic :=
                  l_where_generic
               || 'AND mmt.organization_id = milv.organization_id ';
            l_where_generic :=
                  l_where_generic
               || 'AND mmt.locator_id = milv.inventory_location_id ';
         ELSE
            if l_debug = 1 then
	      debug(' get_gen_where : p_outbound_tasks_cycle = false' );
	    end if;
            l_where_generic :=
                  l_where_generic
               || 'AND mmt.organization_id = milv.organization_id(+) ';
            l_where_generic :=
                  l_where_generic
               || 'AND mmt.locator_id = milv.inventory_location_id(+) ';
         END IF;


         IF g_to_organization_code_visible = 'T'
         THEN
            IF p_outbound_tasks_cycle THEN  -- bug #4661615
               l_where_generic :=
                     l_where_generic
                  || 'AND mmt.transfer_organization_id = mp1.organization_id ';
            ELSE
               l_where_generic :=
                     l_where_generic
                  || 'AND mmt.transfer_organization_id = mp1.organization_id(+) ';
            END IF;
         END IF;

         IF g_to_locator_visible = 'T'  -- bug #4661615
         THEN
            IF p_outbound_tasks_cycle THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND mmt.transfer_organization_id = milv1.organization_id ';
               l_where_generic :=
                     l_where_generic
                  || 'AND mmt.transfer_locator_id = milv1.inventory_location_id ';
            ELSE
               l_where_generic :=
                     l_where_generic
                  || 'AND mmt.transfer_organization_id = milv1.organization_id(+) ';
               l_where_generic :=
                     l_where_generic
                  || 'AND mmt.transfer_locator_id = milv1.inventory_location_id(+) ';
            END IF;
         END IF;

         IF g_txn_source_type_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmt.transaction_source_type_id = mtst.transaction_source_type_id ';
         END IF;

         IF g_person_resource_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.person_resource_id = br1.resource_id(+) ';
         END IF;

         IF g_machine_resource_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.machine_resource_id = br2.resource_id(+) ';
         END IF;

         IF g_person_visible = 'T'
         THEN
            l_where_generic :=
                     l_where_generic || 'AND wdth.person_id = pap.person_id ';
            l_where_generic :=
                  l_where_generic
               || 'AND trunc(wdth.effective_start_date) >= trunc(pap.effective_start_date) '; /* Bug 5697014 */
            l_where_generic :=
                  l_where_generic
               || 'AND trunc(wdth.effective_end_date) <= trunc(pap.effective_end_date) ';    /* Bug 5697014 */
         END IF;

         IF g_from_lpn_visible = 'T'
           THEN
            l_where_generic :=
              l_where_generic || 'AND mmt.lpn_id = wlpn5.lpn_id(+) ';
         END IF;

         IF g_content_lpn_visible = 'T'
         THEN
            l_where_generic :=
               l_where_generic || 'AND mmt.content_lpn_id = wlpn3.lpn_id(+) ';
         END IF;

         IF g_to_lpn_visible = 'T'
         THEN
            l_where_generic :=
               l_where_generic
               || 'AND mmt.transfer_lpn_id = wlpn4.lpn_id(+) ';
         END IF;

         IF g_user_task_type_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.user_task_type = bso.standard_operation_id(+) ';
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.organization_id = bso.organization_id(+) ';
         END IF;

         IF g_operation_plan_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.operation_plan_id = wop.operation_plan_id(+) ';
         END IF;

         IF p_organization_id IS NOT NULL
         THEN
            l_where_generic :=
                      l_where_generic || 'AND mmt.organization_id = :org_id ';
         END IF;

         IF p_subinventory_code IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic || 'AND mmt.subinventory_code = :sub_code ';
         END IF;

         IF p_locator_id IS NOT NULL
         THEN
            l_where_generic :=
                           l_where_generic || 'AND mmt.locator_id = :loc_id ';
         END IF;

         IF p_to_subinventory_code IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmt.transfer_subinventory = :to_sub_code ';
         END IF;

         IF p_to_locator_id IS NOT NULL
         THEN
            l_where_generic :=
               l_where_generic || 'AND mmt.transfer_locator_id = :to_loc_id ';
         END IF;

         IF p_inventory_item_id IS NOT NULL
         THEN
            l_where_generic :=
                   l_where_generic || 'AND mmt.inventory_item_id = :item_id ';
         END IF;

         -- R12 : Additional Query Criteria using item type
         IF p_item_type_code IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic || 'AND msiv.item_type = :item_type_code ';
         END IF;

         IF p_category_set_id IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mic.category_set_id = :category_set_id ';
         END IF;

         IF p_item_category_id IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmt.inventory_item_id = mic.inventory_item_id ';
            l_where_generic :=
                 l_where_generic || 'AND mic.category_id = :item_category_id ';
            l_where_generic :=
                  l_where_generic
               || 'AND mic.organization_id = mmt.organization_id ';
         END IF;

         IF p_person_id IS NOT NULL
         THEN
            l_where_generic :=
                        l_where_generic || 'AND wdth.person_id = :person_id ';
         END IF;

         IF p_person_resource_id IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.person_resource_id = :person_resource_id ';
         END IF;

         IF p_machine_resource_id IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.machine_resource_id = :machine_resource_id ';
         END IF;

         IF p_equipment_type_id IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.equipment_id = :equipment_type_id ';
         END IF;

         IF p_machine_instance IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.equipment_instance = :machine_instance ';
         END IF;

         IF p_user_task_type_id IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.user_task_type = :user_task_type_id ';
         END IF;

         IF p_from_task_priority IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.task_priority >= :from_task_priority ';
         END IF;

         IF p_to_task_priority IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmtt.task_priority <= :to_task_priority ';
         END IF;

         IF p_from_task_quantity IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmt.transaction_quantity >= :from_task_quantity ';
         END IF;

         IF p_to_task_quantity IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mmt.transaction_quantity <= :to_task_quantity ';
         END IF;

         IF p_from_task_priority IS NOT NULL
         THEN
            l_where_generic :=
               l_where_generic || 'AND wdth.priority >= :from_task_priority ';
         END IF;

         IF p_to_task_priority IS NOT NULL
         THEN
            l_where_generic :=
                 l_where_generic || 'AND wdth.priority <= :to_task_priority ';
         END IF;

         IF p_from_creation_date IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND TRUNC(mmt.transaction_date) >= TRUNC(:from_creation_date)';--Added TRUNC in bug 6854145
         END IF;

         IF p_to_creation_date IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND TRUNC(mmt.transaction_date) <= TRUNC(:to_creation_date) ';--Added TRUNC in bug 6854145
         END IF;

         -- R12: Additional Query criteria using age of the task
         IF p_age_uom_code IS NOT NULL
         THEN

            IF    p_age_uom_code = 2 THEN  -- Minutes
               n := '*(24 * 60)';
            ELSIF p_age_uom_code = 3 THEN  -- Hours
               n := '*(24)';
            ELSIF p_age_uom_code = 4 THEN  -- Days
               n := '*(1)';
            ELSIF p_age_uom_code = 5 THEN  -- Weeks
               n := '/(7)';
            ELSIF p_age_uom_code = 6 THEN  -- Months
               n := '/(7 * 31)';
            END IF;

            IF p_age_min IS NOT NULL
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND (sysdate - mmtt.creation_date)'||n||' >= :age_min ';
            END IF;

            IF p_age_max IS NOT NULL
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND (sysdate - mmtt.creation_date)'||n||' <= :age_max ';
            END IF;
         END IF;
      ELSIF (p_is_completed AND p_populate_merged_tasks)
      THEN
         --Patchset J Bulk Pick Enhancement
         --Querying for completed parent tasks.  Thus only use wdth and not mmt
         --Completed parent only comes up if query criteria match one of its
         --completed children.
         IF p_add
         THEN
            l_where_generic :=
                   'WHERE NOT exists (SELECT 1 FROM wms_waveplan_tasks_temp ';
            l_where_generic :=
                  l_where_generic
               || 'WHERE transaction_temp_id = wdth.transaction_id) ';
         ELSE
            l_where_generic := 'WHERE 1=1 ';
         END IF;

         --Assumption with this join:
         --wwtt contain completed children that have been queried up and need
         --to find the parent.  Thus we use the children to find the wdth
         --parent record.
         l_where_generic :=
            l_where_generic
            || 'AND wdth.transaction_id = wwtt.parent_line_id ';
         l_where_generic :=
               l_where_generic
            || 'AND wdth.organization_id = msiv.organization_id ';
         l_where_generic :=
               l_where_generic
            || 'AND wdth.inventory_item_id = msiv.inventory_item_id ';
         l_where_generic :=
               l_where_generic
            || 'AND wdth.organization_id = milv.organization_id(+) ';
         l_where_generic :=
               l_where_generic
            || 'AND wdth.source_locator_id = milv.inventory_location_id(+) ';

         IF g_to_organization_code_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.transfer_organization_id = mp1.organization_id(+) ';
         END IF;

         IF g_txn_source_type_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.transaction_source_type_id = mtst.transaction_source_type_id ';
         END IF;

         IF g_person_resource_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.person_resource_id = br1.resource_id(+) ';
         END IF;

         IF g_machine_resource_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.machine_resource_id = br2.resource_id(+) ';
         END IF;

         IF g_person_visible = 'T'
         THEN
            l_where_generic :=
                     l_where_generic || 'AND wdth.person_id = pap.person_id ';
            l_where_generic :=
                  l_where_generic
               || 'AND trunc(wdth.effective_start_date) >= trunc(pap.effective_start_date) '; /* Bug 5697014 */
            l_where_generic :=
                  l_where_generic
               || 'AND trunc(wdth.effective_end_date) <= trunc(pap.effective_end_date) ';     /* Bug 5697014 */
         END IF;

         IF g_from_lpn_visible = 'T'
         THEN
            l_where_generic :=
               l_where_generic || 'AND wdth.lpn_id = wlpn5.lpn_id(+) ';
         END IF;

         IF g_content_lpn_visible = 'T'
         THEN
            l_where_generic :=
               l_where_generic
               || 'AND wdth.content_lpn_id = wlpn3.lpn_id(+) ';
         END IF;

         IF g_to_lpn_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.transfer_lpn_id = wlpn4.lpn_id(+) ';
         END IF;

         IF g_user_task_type_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.user_task_type = bso.standard_operation_id(+) ';
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.organization_id = bso.organization_id(+) ';
         END IF;

         IF g_operation_plan_visible = 'T'
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.operation_plan_id = wop.operation_plan_id(+) ';
         END IF;

         IF p_organization_id IS NOT NULL
         THEN
            l_where_generic :=
                     l_where_generic || 'AND wdth.organization_id = :org_id ';
         END IF;

         IF p_category_set_id IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND mic.category_set_id = :category_set_id ';
         END IF;

         IF p_item_category_id IS NOT NULL
         THEN
            l_where_generic :=
                  l_where_generic
               || 'AND wdth.inventory_item_id = mic.inventory_item_id ';
            l_where_generic :=
                 l_where_generic || 'AND mic.category_id = :item_category_id ';
            l_where_generic :=
                  l_where_generic
               || 'AND mic.organization_id = wdth.organization_id ';
         END IF;
      END IF;
      if l_debug = 1 then
        debug (l_where_generic);
      end if;
      RETURN l_where_generic;
   END get_generic_where;

--The procedure deals with parent and children tasks.
--It was already existing when this file was first created.
--Enhancements done for Bulk Picking in patchset J:
--1.  We needed to show completed children for Active parents (partially
--    completed).  Before patchset J, children are not shown anytime parent
--    is shown.  This is done by deleting only non-completed children
--2.  Added condition transaction_action_id = 28 and check for WIP task everywhere since we now
--    support ATF which also uses parent_line_id column. This condition
--    will select or delete only bulk pick related tasks
--3.  Added a new out parameter to return the number of non-completed
--    parent tasks that was inserted.  Use to determine if need to
--    calculate number of children
   PROCEDURE populate_merged_tasks (
      p_is_unreleased                      BOOLEAN DEFAULT FALSE,
      p_is_pending                         BOOLEAN DEFAULT FALSE,
      p_is_queued                          BOOLEAN DEFAULT FALSE,
      p_is_dispatched                      BOOLEAN DEFAULT FALSE,
      p_is_active                          BOOLEAN DEFAULT FALSE,
      p_is_loaded                          BOOLEAN DEFAULT FALSE,
      p_is_completed                       BOOLEAN DEFAULT FALSE,
      p_from_task_quantity                 NUMBER  DEFAULT NULL,
      p_to_task_quantity                   NUMBER  DEFAULT NULL,
      p_person_id			   NUMBER  DEFAULT NULL,  /* Bug 5446146 */
      p_person_resource_id		   NUMBER  DEFAULT NULL,
      p_equipment_type_id		   NUMBER  DEFAULT NULL,
      p_machine_resource_id		   NUMBER  DEFAULT NULL,
      p_machine_instance		   VARCHAR2 DEFAULT NULL,
      p_user_task_type_id		   NUMBER  DEFAULT NULL, /* End of Bug 5446146 */
      x_non_complete_parent   OUT NOCOPY   NUMBER
   )
   IS
      l_insert_query     VARCHAR2 (2000);
      l_select_generic   VARCHAR2 (3000);
      l_from_generic     VARCHAR2 (2000);
      l_where_generic    VARCHAR2 (5000);
      l_query            VARCHAR2 (10000);
      l_query_handle     NUMBER;                -- Handle for the dynamic sql
      l_query_count      NUMBER;
   BEGIN
      -- If no tasks have been queried up, there is no need to populate merged tasks
      IF g_record_count = 0
      THEN
         RETURN;
      END IF;

      -- Delete all the parent records that have been queries up
      DELETE FROM wms_waveplan_tasks_temp
            WHERE task_type_id <> 3
              AND transaction_temp_id IN (
                     SELECT parent_line_id
                       FROM wms_waveplan_tasks_temp
                      WHERE parent_line_id IS NOT NULL
                        AND task_type_id <> 3
                        --Change
                        --Check for outbound and wip tasks below
                        AND (   transaction_action_id = 28
                             OR (    transaction_source_type_id = 5
                                 AND transaction_type_id = 35
                                )
                             OR (    transaction_source_type_id = 13
                                 AND transaction_type_id = 51
                                )
                            ));

      --End of change
      l_query_count := SQL%ROWCOUNT;
      g_record_count := g_record_count - l_query_count;
      l_query_count := 0;

      --get the number of children tasks queried up
      BEGIN
         SELECT 1
           INTO l_query_count
           FROM DUAL
          WHERE EXISTS (
                   SELECT parent_line_id
                     FROM wms_waveplan_tasks_temp
                    WHERE parent_line_id IS NOT NULL
                      AND task_type_id <> 3
                      --Change
                      --check for outbound and wip tasks below
                      AND (   transaction_action_id = 28
                           OR (    transaction_source_type_id = 5
                               AND transaction_type_id = 35
                              )
                           OR (    transaction_source_type_id = 13
                               AND transaction_type_id = 51
                              )
                          ));
      --End of change
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      IF     (l_query_count > 0)
         AND (   p_is_unreleased
              OR p_is_pending
              OR p_is_queued
              OR p_is_dispatched
              OR p_is_active
              OR p_is_loaded
             )
      THEN
         -- Insert merged tasks into the temp table
         l_insert_query :=
            get_generic_insert (p_is_unreleased      => p_is_unreleased,
                                p_is_pending         => p_is_pending,
                                p_is_queued          => p_is_queued,
                                p_is_dispatched      => p_is_dispatched,
                                p_is_active          => p_is_active,
                                p_is_loaded          => p_is_loaded,
                                p_is_completed       => FALSE
                               );
         l_insert_query := l_insert_query || ') ';
         l_select_generic :=
            get_generic_select (p_is_unreleased              => p_is_unreleased,
                                p_is_pending                 => p_is_pending,
                                p_is_queued                  => p_is_queued,
                                p_is_dispatched              => p_is_dispatched,
                                p_is_active                  => p_is_active,
                                p_is_loaded                  => p_is_loaded,
                                p_is_completed               => FALSE,
                                p_populate_merged_tasks      => TRUE
                               );
         l_from_generic :=
            get_generic_from (p_is_queued                  => p_is_queued,
                              p_is_dispatched              => p_is_dispatched,
                              p_is_active                  => p_is_active,
                              p_is_loaded                  => p_is_loaded,
                              p_is_completed               => FALSE,
                              p_populate_merged_tasks      => TRUE
                             );
         l_where_generic :=
            get_generic_where (p_from_task_quantity         => p_from_task_quantity,
                               p_to_task_quantity           => p_to_task_quantity,
                               p_is_unreleased              => p_is_unreleased,
                               p_is_pending                 => p_is_pending,
                               p_is_queued                  => p_is_queued,
                               p_is_dispatched              => p_is_dispatched,
                               p_is_active                  => p_is_active,
                               p_is_loaded                  => p_is_loaded,
                               p_is_completed               => FALSE,
                               p_populate_merged_tasks      => TRUE
                              );

         /* Bug 5446146 Filter the bulk tasks based on the employee, Role, etc */
	 IF p_person_id IS NOT NULL THEN
	   l_where_generic := l_where_generic || ' AND wdt.person_id = :person_id ';
	 END IF;

	 IF p_person_resource_id IS NOT NULL THEN
	   l_where_generic := l_where_generic || 'AND wdt.person_resource_id = :person_resource_id ';
	 END IF;

	 IF p_equipment_type_id IS NOT NULL THEN
	   l_where_generic := l_where_generic || 'AND wdt.equipment_id = :equipment_type_id ';
	 END IF;

	 IF p_machine_resource_id IS NOT NULL THEN
	   l_where_generic := l_where_generic || 'AND wdt.machine_resource_id = :machine_resource_id ';
	 END IF;

	 IF p_machine_instance IS NOT NULL THEN
	   l_where_generic := l_where_generic || 'AND wdt.equipment_instance = :machine_instance ';
	 END IF;

	 IF p_user_task_type_id IS NOT NULL THEN
	     l_where_generic := l_where_generic || 'AND mmtt.standard_operation_id = :user_task_type_id ';
	 END IF;
	 /* End of Bug 5446146 */

         -- Concatenate the different sections of the query
         l_query :=
               l_insert_query
            || l_select_generic
            || l_from_generic
            || l_where_generic;
         -- Parse, Bind and Execute the dynamic query
         l_query_handle := DBMS_SQL.open_cursor;
         DBMS_SQL.parse (l_query_handle, l_query, DBMS_SQL.native);

         IF p_from_task_quantity IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_task_quantity',
                                    p_from_task_quantity
                                   );
         END IF;

         IF p_to_task_quantity IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_task_quantity',
                                    p_to_task_quantity
                                   );
         END IF;

	 /* Bug 5446146 */
	 IF p_person_id IS NOT NULL THEN
	   DBMS_SQL.bind_variable (l_query_handle,
				   'person_id',
				   p_person_id);
	 END IF;

	 IF p_person_resource_id IS NOT NULL THEN
	   DBMS_SQL.bind_variable (l_query_handle,
				   'person_resource_id',
				   p_person_resource_id);
	 END IF;

	 IF p_equipment_type_id IS NOT NULL THEN
	   DBMS_SQL.bind_variable (l_query_handle,
				       'equipment_type_id',
				       p_equipment_type_id
				      );
	 END IF;

	 IF p_machine_resource_id IS NOT NULL THEN
	   DBMS_SQL.bind_variable (l_query_handle,
				       'machine_resource_id',
				       p_machine_resource_id
				      );
	 END IF;

	 IF p_machine_instance IS NOT NULL THEN
	   DBMS_SQL.bind_variable (l_query_handle,
				       'machine_instance',
				       p_machine_instance
				      );
	 END IF;

	 IF p_user_task_type_id IS NOT NULL
	 THEN
	    DBMS_SQL.bind_variable (l_query_handle,
				    'user_task_type_id',
				    p_user_task_type_id
				   );
	 END IF;
	 /* End of Bug 5446146 */

         l_query_count := DBMS_SQL.EXECUTE (l_query_handle);
         g_record_count := g_record_count + l_query_count;
         x_non_complete_parent := l_query_count;
    DBMS_SQL.close_cursor(l_query_handle);

         -- Delete the child tasks from the temp table
         --Bulk Picking Enhancement:
         --Added the condition status_id <> 6 because we want to show
         --completed children associated with a partially completed(Active) parent
         DELETE FROM wms_waveplan_tasks_temp
               WHERE parent_line_id IS NOT NULL
                 AND status_id <> 6
                 --Change
                 --check for outbound and wip tasks below
                 AND (   transaction_action_id = 28
                      OR (    transaction_source_type_id = 5
                          AND transaction_type_id = 35
                         )
                      OR (    transaction_source_type_id = 13
                          AND transaction_type_id = 51
                         )
                     )
                 AND parent_line_id <> transaction_temp_id;
                                                   -- exclude the parent lines

                                                            -- this is only useful for patchset J, jali changed.
         --End of change
         l_query_count := SQL%ROWCOUNT;
         g_record_count := g_record_count - l_query_count;
      END IF;

      --get the number of completed children tasks queried up
      l_query_count := 0;

      BEGIN
         SELECT 1
           INTO l_query_count
           FROM DUAL
          WHERE EXISTS (
                   SELECT parent_line_id
                     FROM wms_waveplan_tasks_temp
                    WHERE parent_line_id IS NOT NULL
                      AND task_type_id <> 3
                      --Change
                      --check for outbound and wip tasks below
                      AND (   transaction_action_id = 28
                           OR (    transaction_source_type_id = 5
                               AND transaction_type_id = 35
                              )
                           OR (    transaction_source_type_id = 13
                               AND transaction_type_id = 51
                              )
                          )
                      --End of change
                      AND status_id = 6);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            --no completed children.  no need to find parents
            RETURN;
      END;

      --Changes
      --Changed all p_ params to FALSE in the following block of code

      --Find completed parent of completed children
      IF l_query_count > 0
      THEN
         l_insert_query :=
            get_generic_insert (p_is_unreleased      => FALSE
                                                            --p_is_unreleased,
                                                             ,
                                p_is_pending         => FALSE  --p_is_pending,
                                                             ,
                                p_is_queued          => FALSE   --p_is_queued,
                                                             ,
                                p_is_dispatched      => FALSE
                                                            --p_is_dispatched,
                                                             ,
                                p_is_active          => FALSE   --p_is_active,
                                                             ,
                                p_is_loaded          => FALSE   --p_is_loaded,
                                                             ,
                                p_is_completed       => TRUE
                               );
         l_insert_query := l_insert_query || ') ';
         l_select_generic :=
            get_generic_select (p_is_unreleased              => FALSE
                                                            --p_is_unreleased,
                                                                     ,
                                p_is_pending                 => FALSE
                                                               --p_is_pending,
                                                                     ,
                                p_is_queued                  => FALSE
                                                                --p_is_queued,
                                                                     ,
                                p_is_dispatched              => FALSE
                                                            --p_is_dispatched,
                                                                     ,
                                p_is_active                  => FALSE
                                                                --p_is_active,
                                                                     ,
                                p_is_loaded                  => FALSE
                                                                --p_is_loaded,
                                                                     ,
                                p_is_completed               => TRUE,
                                p_populate_merged_tasks      => TRUE
                               );
         l_from_generic :=
            get_generic_from (p_is_queued                  => FALSE
                                                                --p_is_queued,
                                                                   ,
                              p_is_dispatched              => FALSE
                                                            --p_is_dispatched,
                                                                   ,
                              p_is_active                  => FALSE
                                                                --p_is_active,
                                                                   ,
                              p_is_loaded                  => FALSE
                                                                --p_is_loaded,
                                                                   ,
                              p_is_completed               => TRUE,
                              p_populate_merged_tasks      => TRUE
                             );
         l_where_generic :=
            get_generic_where (p_is_unreleased              => FALSE
                                                            --p_is_unreleased,
                                                                    ,
                               p_is_pending                 => FALSE
                                                               --p_is_pending,
                                                                    ,
                               p_is_queued                  => FALSE
                                                                --p_is_queued,
                                                                    ,
                               p_is_dispatched              => FALSE
                                                            --p_is_dispatched,
                                                                    ,
                               p_is_active                  => FALSE
                                                                --p_is_active,
                                                                    ,
                               p_is_loaded                  => FALSE
                                                                --p_is_loaded,
                                                                    ,
                               p_is_completed               => TRUE,
                               p_populate_merged_tasks      => TRUE
                              );
         --End of Changes

         --Changes
         --Assumption with this join:
         --wwtt contain completed children that have been queried up and need
         --to find the parent.  Thus we use the children to find the wdth
         --parent record.
         l_where_generic :=
               l_where_generic
            || ' AND wdth.transaction_id = wwtt.parent_line_id ';
         --End of Changes

         -- Concatenate the different sections of the query
         l_query :=
               l_insert_query
            || l_select_generic
            || l_from_generic
            || l_where_generic;
         -- Parse, Bind and Execute the dynamic query
         l_query_handle := DBMS_SQL.open_cursor;
         DBMS_SQL.parse (l_query_handle, l_query, DBMS_SQL.native);
         l_query_count := DBMS_SQL.EXECUTE (l_query_handle);
         g_record_count := g_record_count + l_query_count;
    DBMS_SQL.close_cursor(l_query_handle);
      END IF;
   EXCEPTION
	WHEN OTHERS THEN -- Bug 4150145
	   IF dbms_sql.is_open(l_query_handle) THEN
	     DBMS_SQL.close_cursor(l_query_handle);
	   END IF;
	   debug(Sqlerrm, 'Task_planning.populate_merged_tasks');
   END populate_merged_tasks;

   PROCEDURE query_outbound_tasks (
      p_add                          BOOLEAN DEFAULT FALSE,
      p_organization_id              NUMBER DEFAULT NULL,
      p_subinventory_code            VARCHAR2 DEFAULT NULL,
      p_locator_id                   NUMBER DEFAULT NULL,
      p_to_subinventory_code         VARCHAR2 DEFAULT NULL,
      p_to_locator_id                NUMBER DEFAULT NULL,
      p_inventory_item_id            NUMBER DEFAULT NULL,
      p_category_set_id              NUMBER DEFAULT NULL,
      p_item_category_id             NUMBER DEFAULT NULL,
      p_person_id                    NUMBER DEFAULT NULL,
      p_person_resource_id           NUMBER DEFAULT NULL,
      p_equipment_type_id            NUMBER DEFAULT NULL,
      p_machine_resource_id          NUMBER DEFAULT NULL,
      p_machine_instance             VARCHAR2 DEFAULT NULL,
      p_user_task_type_id            NUMBER DEFAULT NULL,
      p_from_task_quantity           NUMBER DEFAULT NULL,
      p_to_task_quantity             NUMBER DEFAULT NULL,
      p_from_task_priority           NUMBER DEFAULT NULL,
      p_to_task_priority             NUMBER DEFAULT NULL,
      p_from_creation_date           DATE DEFAULT NULL,
      p_to_creation_date             DATE DEFAULT NULL,
      p_is_unreleased                BOOLEAN DEFAULT FALSE,
      p_is_pending                   BOOLEAN DEFAULT FALSE,
      p_is_queued                    BOOLEAN DEFAULT FALSE,
      p_is_dispatched                BOOLEAN DEFAULT FALSE,
      p_is_active                    BOOLEAN DEFAULT FALSE,
      p_is_loaded                    BOOLEAN DEFAULT FALSE,
      p_is_completed                 BOOLEAN DEFAULT FALSE,
      p_include_sales_orders         BOOLEAN DEFAULT TRUE,
      p_include_internal_orders      BOOLEAN DEFAULT TRUE,
      p_from_sales_order_id          NUMBER DEFAULT NULL,
      p_to_sales_order_id            NUMBER DEFAULT NULL,
      p_from_pick_slip_number        NUMBER DEFAULT NULL,
      p_to_pick_slip_number          NUMBER DEFAULT NULL,
      p_customer_id                  NUMBER DEFAULT NULL,
      p_customer_category            VARCHAR2 DEFAULT NULL,
      p_delivery_id                  NUMBER DEFAULT NULL,
      p_carrier_id                   NUMBER DEFAULT NULL,
      p_ship_method                  VARCHAR2 DEFAULT NULL,
      p_shipment_priority            VARCHAR2 DEFAULT NULL,
      p_trip_id                      NUMBER DEFAULT NULL,
      p_from_shipment_date           DATE DEFAULT NULL,
      p_to_shipment_date             DATE DEFAULT NULL,
      p_ship_to_state                VARCHAR2 DEFAULT NULL,
      p_ship_to_country              VARCHAR2 DEFAULT NULL,
      p_ship_to_postal_code          VARCHAR2 DEFAULT NULL,
      p_from_number_of_order_lines   NUMBER DEFAULT NULL,
      p_to_number_of_order_lines     NUMBER DEFAULT NULL,
      -- R12 : Additional Query Criteria
      p_item_type_code                            VARCHAR2 DEFAULT NULL,
   	p_age_uom_code                              VARCHAR2 DEFAULT NULL,
   	p_age_min                                   NUMBER DEFAULT NULL,
   	p_age_max                                   NUMBER DEFAULT NULL,
      p_order_type_id                             NUMBER DEFAULT NULL,
   	p_time_till_shipment_uom_code               VARCHAR2 DEFAULT NULL,
   	p_time_till_shipment                        NUMBER DEFAULT NULL,
   	p_time_till_appt_uom_code                   VARCHAR2 DEFAULT NULL,
   	p_time_till_appt                            NUMBER DEFAULT NULL,
	   p_summary_mode		NUMBER DEFAULT 0
      -- R12 : Additional Query Criteria
      ,p_wave_header_id		NUMBER DEFAULT NULL
   )
   IS
      l_insert_query      VARCHAR2 (3000);
      l_select_generic    VARCHAR2 (4000);
      l_select_outbound   VARCHAR2 (4000);
      l_from_generic      VARCHAR2 (2000);
      l_where_generic     VARCHAR2 (5000);
      l_from_outbound     VARCHAR2 (2000);
      l_where_outbound    VARCHAR2 (4000);
      l_query             VARCHAR2 (10000);
      l_query_handle      NUMBER;               -- Handle for the dynamic sql
      l_query_count       NUMBER;
      l_loop_start        NUMBER;
      l_loop_end          NUMBER;
      l_is_unreleased     BOOLEAN;
      l_is_pending        BOOLEAN;
      l_is_queued         BOOLEAN;
      l_is_dispatched     BOOLEAN;
      l_is_active         BOOLEAN;
      l_is_loaded         BOOLEAN;
      l_is_completed      BOOLEAN;
      l_outbound_tasks_cycle BOOLEAN;           -- bug #4661615
      l_wms_task_type	NUMBER; -- for bug 5129375
      l_task_count	NUMBER;

      l_is_range_so BOOLEAN;/*added for 3455109*/
      l_from_tonum_mso_seg1 varchar2(40);--3455109
      l_to_tonum_mso_seg1 varchar2(40); -- 3455109
      l_from_mso_seg2 VARCHAR2(150);--need tocheck the corrrect size from mso 3455109
      l_to_mso_seg2 VARCHAR2(150);--3455109
      l_from_mso_seg1 varchar2(40);--3455109 used for non range query no need to do lpad/to_number
      --R12: Additional Query criteria
      --Age UOM conversion factor
      n                 VARCHAR2 (10);

      l_debug                    NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

   BEGIN

      if (p_from_sales_order_id = p_to_sales_order_id) then
        l_is_range_so := FALSE;
      else/*range so is TRUE if from or to is null or form<> to*/
         l_is_range_so := TRUE;
      end if;
      if  P_from_sales_order_id is not null then
         select lpad(segment1,40), segment2,segment1
           INTO l_from_tonum_mso_seg1,l_from_mso_seg2,l_from_mso_seg1
           from mtl_sales_orders
          WHERE sales_order_id = p_from_sales_order_id;
      end if;
      IF(l_is_range_so) THEN
         /* Its a range...Query for details of to sales order */
         if  P_to_sales_order_id is not null then
            select lpad(segment1,40), segment2
              INTO l_to_tonum_mso_seg1,l_to_mso_seg2
              from mtl_sales_orders
             WHERE sales_order_id = p_to_sales_order_id;
          end if;/*added the above code to get the values since we are not going to join with mso 3455109*/
      ELSE
          l_to_tonum_mso_seg1 :=  l_from_tonum_mso_seg1;
          l_to_mso_seg2 :=  l_from_mso_seg2;
      END IF;

     /* DEBUG('l_from_tonum_mso_seg1 '|| l_from_tonum_mso_seg1);
      DEBUG('l_from_mso_seg2 '|| l_from_mso_seg2);
      DEBUG('l_from_mso_seg1 '|| l_from_mso_seg1);
      DEBUG('l_to_tonum_mso_seg1 '|| l_to_tonum_mso_seg1);
      DEBUG('l_to_mso_seg2 '|| l_to_mso_seg2);*/


      IF p_is_completed
      THEN

         l_loop_end := 2;
      ELSE

         l_loop_end := 1;
      END IF;

      IF    p_is_unreleased
         OR p_is_pending
         OR p_is_queued
         OR p_is_dispatched
         OR p_is_active
         OR p_is_loaded
      THEN

         l_loop_start := 1;
      ELSE

         l_loop_start := 2;
      END IF;

      if l_debug =  1 then
        IF p_is_unreleased THEN
	  debug('unreleased');
        END IF;

	IF p_is_pending THEN
          debug('pending');
        END IF;

	IF p_is_queued THEN
	  debug('queued');
        END IF;

	IF p_is_dispatched THEN
	  debug('dispatched');
        END IF;

        IF p_is_active THEN
	  debug('active');
        END IF;

        IF p_is_loaded THEN
	  debug('loaded');
        END IF;

	DEBUG('p_is_pending : ' || l_loop_start);
	DEBUG('p_is_pending : ' || l_loop_end);
      end if;

      FOR i IN l_loop_start .. l_loop_end
      LOOP
         --debug(' i ' || i);
         l_insert_query := NULL;
         l_select_generic := NULL;
         l_select_outbound := NULL;
         l_from_generic := NULL;
         l_from_outbound := NULL;
         l_where_generic := NULL;
         l_where_outbound := NULL;

         IF i = 1
         THEN                                -- Non completed tasks iteration
            if l_debug = 1 then
	      DEBUG('non completed tasks iteration');
	    end if;
            l_is_unreleased := p_is_unreleased;
            l_is_pending := p_is_pending;
            l_is_queued := p_is_queued;
            l_is_dispatched := p_is_dispatched;
            l_is_active := p_is_active;
            l_is_loaded := p_is_loaded;
            l_is_completed := FALSE;
            l_outbound_tasks_cycle := TRUE;                -- bug #4661615
         ELSE                                               -- Completed tasks
            if l_debug = 1 then
   	      DEBUG('completed tasks iteration');
	    end if;
            l_is_unreleased := FALSE;
            l_is_pending := FALSE;
            l_is_queued := FALSE;
            l_is_dispatched := FALSE;
            l_is_active := FALSE;
            l_is_loaded := FALSE;
            l_is_completed := p_is_completed;
            l_outbound_tasks_cycle := TRUE;                -- bug #4661615
         END IF;

         -- Insert section
	 IF  p_summary_mode = 1 THEN -- only for query mode
		IF i = 1 THEN
			l_select_generic := ' SELECT mmtt.wms_task_type, count(*) ';
		ELSE
			l_select_generic := ' SELECT wdth.task_type, count(*) ';
		END IF;
	 ELSE
         l_insert_query :=
            get_generic_insert (p_is_unreleased      => l_is_unreleased,
                                p_is_pending         => l_is_pending,
                                p_is_queued          => l_is_queued,
                                p_is_dispatched      => l_is_dispatched,
                                p_is_active          => l_is_active,
                                p_is_loaded          => l_is_loaded,
                                p_is_completed       => l_is_completed
                               );
         l_insert_query := l_insert_query || ', customer_id ';

         IF g_customer_visible = 'T'
         THEN
            l_insert_query := l_insert_query || ', customer ';
         END IF;

         l_insert_query := l_insert_query || ', ship_to_location_id ';

         IF    g_ship_to_country_visible = 'T'
            OR g_ship_to_state_visible = 'T'
            OR g_ship_to_postal_code_visible = 'T'
         THEN
            l_insert_query := l_insert_query || ', ship_to_country ';
            l_insert_query := l_insert_query || ', ship_to_state ';
            l_insert_query := l_insert_query || ', ship_to_postal_code ';
         END IF;

         IF g_delivery_visible = 'T'
         THEN
            l_insert_query := l_insert_query || ', delivery ';
         END IF;

         IF g_ship_method_visible = 'T'
         THEN
            l_insert_query := l_insert_query || ', ship_method ';
         END IF;

         l_insert_query := l_insert_query || ', carrier_id ';

         IF g_carrier_visible = 'T'
         THEN
            l_insert_query := l_insert_query || ', carrier ';
         END IF;

         l_insert_query := l_insert_query || ', wave_header_id ';
	 l_insert_query := l_insert_query || ', shipment_date ';
         l_insert_query := l_insert_query || ', shipment_priority ';
         l_insert_query := l_insert_query || ', source_header ';
         l_insert_query := l_insert_query || ', line_number ';
	 if WMS_CONTROL.G_CURRENT_RELEASE_LEVEL >= 120001 then
		-- For R12.1 OTM integration project
	 	l_insert_query := l_insert_query || ', load_seq_number ';
	 end if;
         l_insert_query := l_insert_query || ') ';
         l_select_generic :=
            get_generic_select (p_is_unreleased      => l_is_unreleased,
                                p_is_pending         => l_is_pending,
                                p_is_queued          => l_is_queued,
                                p_is_dispatched      => l_is_dispatched,
                                p_is_active          => l_is_active,
                                p_is_loaded          => l_is_loaded,
                                p_is_completed       => l_is_completed
                               );
         l_select_outbound := ', wdd.customer_id ';              --customer_id

         IF g_customer_visible = 'T'
         THEN
            l_select_outbound := l_select_outbound || ', substr( hp.party_name,  1,  50 ) ';
                                                               --customer
         END IF;

         l_select_outbound :=
                             l_select_outbound || ', wdd.ship_to_location_id ';
                                                         --ship_to_location_id

         IF    g_ship_to_country_visible = 'T'
            OR g_ship_to_state_visible = 'T'
            OR g_ship_to_postal_code_visible = 'T'
         THEN
            l_select_outbound := l_select_outbound || ', hl.country ';
                                                            --ship_to_country
            l_select_outbound := l_select_outbound || ', hl.state ';
                                                              --ship_to_state
            l_select_outbound := l_select_outbound || ', hl.postal_code ';
                                                        --ship_to_postal_code
         END IF;

         IF g_delivery_visible = 'T'
         THEN
            l_select_outbound := l_select_outbound || ', wnd.name ';
                                                                   --delivery
         END IF;

         IF g_ship_method_visible = 'T' and g_delivery_visible = 'T'  THEN
-- 4629955  l_select_outbound := l_select_outbound || ', flv.meaning ';
                                                              -- ship_method
            l_select_outbound :=l_select_outbound || ', INV_SHIPPING_TRANSACTION_PUB.GET_SHIPMETHOD_MEANING(decode(wda.delivery_id,NULL,wdd.ship_method_code,decode(wnd.ship_method_code,NULL,wdd.ship_method_code,wnd.ship_method_code)))'; -- 4629955
            --Bug#6954042
         ELSIF g_ship_method_visible = 'T' and g_delivery_visible = 'F' THEN
            l_select_outbound :=l_select_outbound || ', INV_SHIPPING_TRANSACTION_PUB.GET_SHIPMETHOD_MEANING(wdd.ship_method_code)';
         ELSIF g_ship_method_visible = 'F' and g_delivery_visible = 'T' THEN
            NULL;
         ELSIF g_ship_method_visible = 'F' and g_delivery_visible = 'F' THEN
            NULL;
           --Bug#6954042
         END IF;

-- 4629955  l_select_outbound := l_select_outbound || ', wdd.carrier_id ';
                                                                  --carrier_id
            --Bug#6954042
            --l_select_outbound := l_select_outbound || ', Decode(wda.delivery_id, NULL, wdd.carrier_id, Decode(wnd.carrier_id,NULL, wdd.carrier_id, wnd.carrier_id))';
            IF g_delivery_visible = 'T'
            THEN
             l_select_outbound := l_select_outbound || ', Decode(wda.delivery_id, NULL, wdd.carrier_id, Decode(wnd.carrier_id,NULL, wdd.carrier_id, wnd.carrier_id))';
            ELSE
             l_select_outbound := l_select_outbound || ', wdd.carrier_id ';
            END IF;
            --Bug#6954042

         IF g_carrier_visible = 'T' and g_delivery_visible = 'T'
         THEN
--4629955    l_select_outbound := l_select_outbound || ', wc.freight_code ';
                                                                    --carrier
             l_select_outbound := l_select_outbound || ',INV_SHIPPING_TRANSACTION_PUB.GET_FREIGHT_CODE(Decode(wda.delivery_id,NULL,wdd.carrier_id,Decode(wnd.carrier_id,NULL,wdd.carrier_id,wnd.carrier_id)))';
             --Bug#6954042
         ELSIF g_carrier_visible = 'T' and g_delivery_visible = 'F' THEN
             l_select_outbound := l_select_outbound || ', INV_SHIPPING_TRANSACTION_PUB.GET_FREIGHT_CODE(wdd.carrier_id)';
         ELSIF g_carrier_visible = 'F' and g_delivery_visible = 'T' THEN
             NULL;
         ELSIF g_carrier_visible = 'F' and g_delivery_visible = 'F' THEN
             NULL;
            --Bug#6954042
	  END IF;

         l_select_outbound := l_select_outbound || ', wwl.wave_header_id ';
	 l_select_outbound := l_select_outbound || ', wdd.date_scheduled ';
                                                               --shipment_date
         l_select_outbound :=
                          l_select_outbound || ', wdd.shipment_priority_code ';
                                                           --shipment_priority
         l_select_outbound :=
                            l_select_outbound || ', wdd.source_header_number ';
                                                               --source_header
         l_select_outbound := l_select_outbound || ', wdd.source_line_number ';
                                                                 --line_number
	 if WMS_CONTROL.G_CURRENT_RELEASE_LEVEL >= 120001 then
		-- For R12.1 OTM integration project
		l_select_outbound := l_select_outbound || ', wdd.load_seq_number ';
								-- load_seq_number
	 end if;
	END IF;

         l_from_generic :=
            get_generic_from (p_is_queued             => l_is_queued,
                              p_is_dispatched         => l_is_dispatched,
                              p_is_active             => l_is_active,
                              p_is_loaded             => l_is_loaded,
                              p_is_completed          => l_is_completed,
                              p_item_category_id      => p_item_category_id,
                              p_category_set_id       => p_category_set_id
                             );
         l_where_generic :=
            get_generic_where
                            (p_add                       => p_add,
                             p_organization_id           => p_organization_id,
                             p_subinventory_code         => p_subinventory_code,
                             p_locator_id                => p_locator_id,
                             p_to_subinventory_code      => p_to_subinventory_code,
                             p_to_locator_id             => p_to_locator_id,
                             p_inventory_item_id         => p_inventory_item_id,
                             p_category_set_id           => p_category_set_id,
                             p_item_category_id          => p_item_category_id,
                             p_person_id                 => p_person_id,
                             p_person_resource_id        => p_person_resource_id,
                             p_equipment_type_id         => p_equipment_type_id,
                             p_machine_resource_id       => p_machine_resource_id,
                             p_machine_instance          => p_machine_instance,
                             p_user_task_type_id         => p_user_task_type_id,
                             p_from_task_quantity        => p_from_task_quantity,
                             p_to_task_quantity          => p_to_task_quantity,
                             p_from_task_priority        => p_from_task_priority,
                             p_to_task_priority          => p_to_task_priority,
                             p_from_creation_date        => p_from_creation_date,
                             p_to_creation_date          => p_to_creation_date,
                             p_is_unreleased             => l_is_unreleased,
                             p_is_pending                => l_is_pending,
                             p_is_queued                 => l_is_queued,
                             p_is_dispatched             => l_is_dispatched,
                             p_is_active                 => l_is_active,
                             p_is_loaded                 => l_is_loaded,
                             p_is_completed              => l_is_completed,
                             p_outbound_tasks_cycle      => l_outbound_tasks_cycle,         -- bug #4661615
                              -- R12: Additional query criteria
                              p_item_type_code             =>  p_item_type_code,
                              p_age_uom_code               =>  p_age_uom_code,
                              p_age_min                    =>  p_age_min,
                              p_age_max                    =>  p_age_max
                            );
         -- Build the outbound from section of the query
         --Change
         --l_from_outbound := ', wsh_delivery_details wdd ';
         l_from_outbound := ', wsh_delivery_details_ob_grp_v wdd ';

         -- End of change

         if (i =1) then/*3455109 we will no longer use mso for completed tasks*/
            IF p_from_sales_order_id IS NOT NULL
            THEN
               l_from_outbound := l_from_outbound || ', mtl_sales_orders mso1 ';
            END IF;

            IF p_to_sales_order_id IS NOT NULL
            THEN
               l_from_outbound := l_from_outbound || ', mtl_sales_orders mso2 ';
            END IF;
         END IF;

         IF g_customer_visible = 'T' OR p_customer_category IS NOT NULL
         THEN
            l_from_outbound := l_from_outbound || ', hz_parties hp ';
            l_from_outbound := l_from_outbound || ', hz_cust_accounts hca ';
         END IF;

--Start of fix for 4629955
/*	 IF g_carrier_visible = 'T'
         THEN
            l_from_outbound := l_from_outbound || ', wsh_carriers wc ';
         END IF;

         IF g_ship_method_visible = 'T'
         THEN
            l_from_outbound :=
                             l_from_outbound || ', fnd_lookup_values_vl flv ';
         END IF;
*/
--End of fix for 4629955

         IF p_trip_id IS NOT NULL
         THEN
                 --Change
            /*l_from_outbound := l_from_outbound || ', wsh_trips wt, wsh_trip_stops wts ';
            l_from_outbound := l_from_outbound || ', wsh_delivery_legs wdl, wsh_new_deliveries wnd ';
            l_from_outbound := l_from_outbound || ', wsh_delivery_assignments wda ';   */
            l_from_outbound :=
                  l_from_outbound
               || ', wsh_trips_ob_grp_v wt, wsh_trip_stops_ob_grp_v wts ';
            l_from_outbound :=
                  l_from_outbound
               || ', wsh_delivery_legs_ob_grp_v wdl, wsh_new_deliveries_ob_grp_v wnd ';
            l_from_outbound :=
                          l_from_outbound || ', wsh_delivery_assignments wda ';
         --End of change
         ELSIF p_delivery_id IS NOT NULL
         THEN
            l_from_outbound :=
                         l_from_outbound || ', wsh_delivery_assignments wda ';
         END IF;

         IF g_delivery_visible = 'T' AND p_trip_id IS NULL
         THEN
                 --Change
            --l_from_outbound := l_from_outbound || ', wsh_new_deliveries wnd ';
            l_from_outbound :=
                      l_from_outbound || ', wsh_new_deliveries_ob_grp_v wnd ';

            -- End of change
            IF p_delivery_id IS NULL
            THEN
               l_from_outbound :=
                         l_from_outbound || ', wsh_delivery_assignments wda ';
            END IF;
         END IF;

         IF    p_ship_to_state IS NOT NULL
            OR p_ship_to_country IS NOT NULL
            OR p_ship_to_postal_code IS NOT NULL
            OR g_ship_to_country_visible = 'T'
            OR g_ship_to_state_visible = 'T'
            OR g_ship_to_postal_code_visible = 'T'
         THEN
            l_from_outbound := l_from_outbound || ', hz_locations hl ';
         END IF;

         l_from_outbound := l_from_outbound || ', WMS_WP_WAVE_LINES WWL ';

	 IF    p_from_number_of_order_lines IS NOT NULL
            OR p_to_number_of_order_lines IS NOT NULL
         THEN
            l_from_outbound :=
                  l_from_outbound
               || ', (SELECT COUNT(line_id) line_sum, header_id FROM oe_order_lines_all ';

            IF p_customer_id IS NOT NULL
            THEN
               l_from_outbound :=
                   l_from_outbound || ' WHERE sold_to_org_id = :customer_id ';
            END IF;

            l_from_outbound :=
                              l_from_outbound || ' GROUP BY header_id) oolac ';
         END IF;

         IF i = 1
         THEN                                           -- Non Completed tasks
            -- Build the outbound where section of the query
            l_where_outbound := 'AND mmtt.transaction_action_id = 28 ';

            IF    (p_include_internal_orders AND NOT p_include_sales_orders
                  )
               OR (NOT p_include_internal_orders AND p_include_sales_orders)
            THEN
               l_where_outbound :=
                     l_where_outbound
                  || 'AND mmtt.transaction_source_type_id = :source_type_id ';
            END IF;

            IF p_from_sales_order_id IS NOT NULL
            THEN
               l_where_outbound :=
                     l_where_outbound
                  || 'AND mso1.sales_order_id = :from_sales_order_id ';
               l_where_outbound :=
                     l_where_outbound
                  || 'AND to_number(wdd.source_header_number) >= to_number(mso1.segment1) ';
               l_where_outbound :=
                     l_where_outbound
                  || 'AND wdd.source_header_type_name >= mso1.segment2 ';
            END IF;

            IF p_to_sales_order_id IS NOT NULL
            THEN
               l_where_outbound :=
                     l_where_outbound
                  || 'AND mso2.sales_order_id = :to_sales_order_id ';
               l_where_outbound :=
                     l_where_outbound
                  || 'AND to_number(wdd.source_header_number) <= to_number(mso2.segment1) ';
               l_where_outbound :=
                     l_where_outbound
                  || 'AND wdd.source_header_type_name <= mso2.segment2 ';
            END IF;

            IF p_from_pick_slip_number IS NOT NULL
            THEN
               l_where_outbound :=
                     l_where_outbound
                  || 'AND mmtt.pick_slip_number >= :from_pick_slip_number ';
            END IF;

            IF p_to_pick_slip_number IS NOT NULL
            THEN
               l_where_outbound :=
                     l_where_outbound
                  || 'AND mmtt.pick_slip_number <= :to_pick_slip_number ';
            END IF;

            l_where_outbound := l_where_outbound || 'AND mmtt.move_order_line_id = wdd.move_order_line_id ';
            l_where_outbound := l_where_outbound || 'AND wdd.delivery_detail_id = (select delivery_detail_id from wsh_delivery_details_ob_grp_v ';
            l_where_outbound := l_where_outbound || ' where mmtt.trx_source_line_id = source_line_id ';
            l_where_outbound := l_where_outbound || ' and mmtt.move_order_line_id = move_order_line_id ';
            l_where_outbound := l_where_outbound || ' and rownum < 2) ';

	    IF p_wave_header_id IS NULL THEN
                l_where_outbound := l_where_outbound || ' AND WWL.source_line_id(+) = MMTT.trx_source_line_id ';
	    ELSE
                l_where_outbound := l_where_outbound || ' AND WWL.source_line_id = MMTT.trx_source_line_id ';
                l_where_outbound := l_where_outbound || ' AND WWL.WAVE_HEADER_ID = :wave_header_id ';
            END IF;
            l_where_outbound := l_where_outbound || ' AND Nvl(wwl.REMOVE_FROM_WAVE_FLAG, ''N'') <> ''Y'' ';

         ELSE                                               -- Completed tasks
            -- Build the outbound where section of the query
            l_where_outbound := 'AND mmt.transaction_action_id + 0 = 28 '; -- Code added for bug#7446999


            IF    (p_include_internal_orders AND NOT p_include_sales_orders
                  )
               OR (NOT p_include_internal_orders AND p_include_sales_orders)
            THEN
               l_where_outbound :=
                     l_where_outbound
                  || 'AND mmt.transaction_source_type_id = :source_type_id ';
            END IF;

            /*Logic if L_is_range_so then we need to add the greater than or  less
              than but change it to bind rather than from mso 3455109 else use equals*/
            IF(l_is_range_so)  then
               IF p_from_sales_order_id IS NOT NULL
               THEN
                  -- 3455109 l_where_outbound := l_where_outbound || 'AND mso1.sales_order_id = :from_sales_order_id ';
                  l_where_outbound := l_where_outbound || ' AND lpad(wdd.source_header_number,40) >= :l_from_tonum_mso_seg1 ';
                  l_where_outbound := l_where_outbound || ' AND wdd.source_header_type_name >= :l_from_mso_seg2 ';
               END IF;

               IF p_to_sales_order_id IS NOT NULL
               THEN
                  -- 3455109 l_where_outbound := l_where_outbound || 'AND mso2.sales_order_id = :to_sales_order_id ';
                  l_where_outbound := l_where_outbound || 'AND lpad(wdd.source_header_number,40) <= :l_to_tonum_mso_seg1 ';
                  l_where_outbound := l_where_outbound || 'AND wdd.source_header_type_name <= :l_to_mso_seg2 ';
               END IF;
            ELSE
               l_where_outbound := l_where_outbound || 'AND (wdd.source_header_number) = :l_from_mso_seg1 ';
               l_where_outbound := l_where_outbound || 'AND wdd.source_header_type_name = :l_from_mso_seg2 ';
            END IF;/*end of range or not range so 3455109*/



            IF p_from_pick_slip_number IS NOT NULL
            THEN
               l_where_outbound := l_where_outbound || 'AND mmt.pick_slip_number >= :from_pick_slip_number ';
            END IF;

            IF p_to_pick_slip_number IS NOT NULL
            THEN
               l_where_outbound := l_where_outbound || 'AND mmt.pick_slip_number <= :to_pick_slip_number ';
            END IF;

            -- bug #4661615
	    /* Bug 5601349 Commented the below lines, hence reverted the changes done in 4661615 */
	    /*
            l_where_outbound := l_where_outbound || 'AND wdd.released_status IN (''Y'', ''C'') ';
            l_where_outbound := l_where_outbound || 'AND wdd.container_flag = ''N'' ';
            l_where_outbound := l_where_outbound || 'AND wdd.move_order_line_id = mmt.move_order_line_id ';

            -- Following two lines are added for Bugfix #4891668
            l_where_outbound := l_where_outbound || 'AND wdd.transaction_id = mmt.transaction_id ';
            l_where_outbound := l_where_outbound || 'AND wdd.source_line_id = mmt.trx_source_line_id '; */
	    /* End of Bug 5601349 */

            -- This code does not add any restrictions since the join
            -- between move order line and source line id are already done
            -- outside this subquery. This is redundant code.
/*            l_where_outbound := l_where_outbound || 'AND EXISTS ( SELECT 1 ';
            l_where_outbound := l_where_outbound || '         FROM wsh_delivery_details wdd2 ';
            l_where_outbound := l_where_outbound || '         WHERE mmt.trx_source_line_id = wdd2.source_line_id ';
            l_where_outbound := l_where_outbound || '           AND wdd2.delivery_detail_id = wdd.delivery_detail_id ) ';
*/
            -- End of Code Bugfix #4891668

	    l_where_outbound := l_where_outbound || ' and mmt.transaction_id = wdd.transaction_id ';  -- for bug 5933053

	    /* Bug 5601349 */
	    /* These lines were commented out in bug fix of 4661615 */
            l_where_outbound := l_where_outbound || 'AND wdd.delivery_detail_id = (select delivery_detail_id from wsh_delivery_details ';
            l_where_outbound := l_where_outbound || ' where mmt.trx_source_line_id = source_line_id ';
	    l_where_outbound := l_where_outbound || ' and mmt.transaction_id = transaction_id '; /* Added in Bug Fix 5601349 */
            -- bug 3781535
            l_where_outbound := l_where_outbound || ' and released_status in (''Y'', ''C'') ';
            -- bug 3888926, 3896871
            l_where_outbound := l_where_outbound || ' and container_flag = ''N'' ';
            l_where_outbound := l_where_outbound || ' and move_order_line_id = mmt.move_order_line_id ';
            l_where_outbound := l_where_outbound || ' and rownum < 2) ';
	    /* End of Bug 5601349 */

	    IF p_wave_header_id IS NULL THEN
                l_where_outbound := l_where_outbound || ' AND WWL.source_line_id(+) = MMT.trx_source_line_id ';
            ELSE
                l_where_outbound := l_where_outbound || ' AND WWL.source_line_id = MMT.trx_source_line_id ';
                l_where_outbound := l_where_outbound || ' AND WWL.WAVE_HEADER_ID = :wave_header_id ';
            END IF;
            l_where_outbound := l_where_outbound || ' AND Nvl(wwl.REMOVE_FROM_WAVE_FLAG, ''N'') <> ''Y'' ';

         END IF;

         IF p_customer_id IS NOT NULL
         THEN
            l_where_outbound :=
                    l_where_outbound || 'AND wdd.customer_id = :customer_id ';
         END IF;

         IF g_customer_visible = 'T' OR p_customer_category IS NOT NULL
         THEN
            l_where_outbound :=
                  l_where_outbound || 'AND hca.party_id = hp.party_id ';

            l_where_outbound :=
                  l_where_outbound || 'AND wdd.customer_id = hca.cust_account_id ';
            /* Bug 6069381:wdd.customer_id is not always same as hp.party_id.
               It is same as hca.cust_account_id and that is take care in the
               above statement.*/
            /*l_where_outbound :=
                  l_where_outbound || 'AND wdd.customer_id = hp.party_id  ';*/

            IF p_customer_category IS NOT NULL
            THEN
               l_where_outbound :=
                     l_where_outbound
                  || 'AND hca.customer_class_code = :customer_category ';
            END IF;
         END IF;

--Start of fix for 4629955
/*       IF g_carrier_visible = 'T'
         THEN
            l_where_outbound :=
                 l_where_outbound || 'AND wdd.carrier_id = wc.carrier_id(+) ';
         END IF;

         IF g_ship_method_visible = 'T'
         THEN
            l_where_outbound :=
                  l_where_outbound
               || 'AND flv.lookup_code(+) = wdd.ship_method_code ';
            l_where_outbound :=
               l_where_outbound || 'AND flv.lookup_type(+) = ''SHIP_METHOD'' ';
            l_where_outbound :=
                  l_where_outbound
               || 'AND nvl(flv.start_date_active(+), sysdate) <= sysdate ';
            l_where_outbound :=
                  l_where_outbound
               || 'AND nvl(flv.end_date_active(+), sysdate) >= sysdate ';
            l_where_outbound :=
                     l_where_outbound || 'AND flv.view_application_id(+) = 3 ';
         END IF;
*/
-- End of fix for 4629955

         IF p_carrier_id IS NOT NULL --bugfix 4629955
         THEN
            l_where_outbound :=
                      l_where_outbound || 'AND nvl(wnd.carrier_id,wdd.carrier_id) = :carrier_id ';
         END IF;

         IF p_ship_method IS NOT NULL --bugfix 4629955
         THEN
            l_where_outbound :=
               l_where_outbound || 'AND nvl(wnd.ship_method_code,wdd.ship_method_code) = :ship_method ';
         END IF;

         IF p_order_type_id IS NOT NULL
         THEN
            l_where_outbound :=
               l_where_outbound || 'AND wdd.source_header_type_id = :p_order_type_id ';
         END IF;

         IF p_shipment_priority IS NOT NULL
         THEN
            l_where_outbound :=
                  l_where_outbound
               || 'AND wdd.shipment_priority_code = :shipment_priority ';
         END IF;

         IF p_from_shipment_date IS NOT NULL
         THEN
            l_where_outbound :=
                  l_where_outbound
               || 'AND wdd.date_scheduled >= :from_shipment_date ';
         END IF;

         IF p_to_shipment_date IS NOT NULL
         THEN
            l_where_outbound :=
                  l_where_outbound
               || 'AND wdd.date_scheduled <= :to_shipment_date ';
         END IF;

         -- R12: Additional Query criteria using age of the task
         IF p_time_till_shipment_uom_code IS NOT NULL
         THEN

            IF    p_time_till_shipment_uom_code = 2 THEN  -- Minutes
               n := '*(24 * 60)';
            ELSIF p_time_till_shipment_uom_code = 3 THEN  -- Hours
               n := '*(24)';
            ELSIF p_time_till_shipment_uom_code = 4 THEN  -- Days
               n := '*(1)';
            ELSIF p_time_till_shipment_uom_code = 5 THEN  -- Weeks
               n := '/(7)';
            ELSIF p_time_till_shipment_uom_code = 6 THEN  -- Months
               n := '/(7 * 31)';
            END IF;

            IF p_time_till_shipment IS NOT NULL
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND (wdd.date_scheduled - sysdate)'||n||' BETWEEN 0 AND :p_time_till_shipment ';
            END IF;
         END IF;

         IF p_trip_id IS NOT NULL OR p_delivery_id IS NOT NULL
         THEN
            IF p_trip_id IS NOT NULL
            THEN
               l_where_outbound :=
                             l_where_outbound || 'AND wt.trip_id = :trip_id ';
               l_where_outbound :=
                          l_where_outbound || 'AND wt.trip_id = wts.trip_id ';
               l_where_outbound :=
                  l_where_outbound
                  || 'AND wdl.pick_up_stop_id = wts.stop_id ';
               l_where_outbound :=
                  l_where_outbound
                  || 'AND wnd.delivery_id = wdl.delivery_id ';
               l_where_outbound :=
                  l_where_outbound
                  || 'AND wnd.delivery_id = wda.delivery_id ';
            END IF;

            l_where_outbound :=
                  l_where_outbound
               || 'AND wdd.delivery_detail_id = wda.delivery_detail_id ';

            IF p_delivery_id IS NOT NULL
            THEN
               l_where_outbound :=
                    l_where_outbound || 'AND wda.delivery_id = :delivery_id ';
            END IF;
         END IF;

         IF g_delivery_visible = 'T' AND p_trip_id IS NULL
         THEN
            IF p_delivery_id IS NULL
            THEN
               l_where_outbound :=
                     l_where_outbound
                  || 'AND wdd.delivery_detail_id = wda.delivery_detail_id(+) ';
            END IF;

            l_where_outbound :=
               l_where_outbound || 'AND wnd.delivery_id(+) = wda.delivery_id ';
         END IF;

         IF    p_ship_to_state IS NOT NULL
            OR p_ship_to_country IS NOT NULL
            OR p_ship_to_postal_code IS NOT NULL
            OR g_ship_to_country_visible = 'T'
            OR g_ship_to_state_visible = 'T'
            OR g_ship_to_postal_code_visible = 'T'
         THEN
            l_where_outbound :=
                  l_where_outbound
               || 'AND wdd.ship_to_location_id = hl.location_id ';

            IF p_ship_to_state IS NOT NULL
            THEN
               l_where_outbound :=
                         l_where_outbound || 'AND hl.state = :ship_to_state ';
            END IF;

            IF p_ship_to_country IS NOT NULL
            THEN
               l_where_outbound :=
                     l_where_outbound || 'AND hl.country = :ship_to_country ';
            END IF;

            IF p_ship_to_postal_code IS NOT NULL
            THEN
               l_where_outbound :=
                     l_where_outbound
                  || 'AND hl.postal_code = :ship_to_postal_code ';
            END IF;
         END IF;

         IF    p_from_number_of_order_lines IS NOT NULL
            OR p_to_number_of_order_lines IS NOT NULL
         THEN
            IF p_from_number_of_order_lines IS NOT NULL
            THEN
               l_where_outbound :=
                     l_where_outbound
                  || 'AND oolac.line_sum >= :from_number_of_order_lines ';
            END IF;

            IF p_to_number_of_order_lines IS NOT NULL
            THEN
               l_where_outbound :=
                     l_where_outbound
                  || 'AND oolac.line_sum <= :to_number_of_order_lines ';
            END IF;

            l_where_outbound :=
                  l_where_outbound
               || 'AND oolac.header_id = wdd.source_header_id ';
         END IF;

         -- R12: Additional Query criteria using time till dock door appointment
         IF p_time_till_appt_uom_code IS NOT NULL
         THEN

            IF    p_time_till_appt_uom_code = 2 THEN  -- Minutes
               n := '*(24 * 60)';
            ELSIF p_time_till_appt_uom_code = 3 THEN  -- Hours
               n := '*(24)';
            ELSIF p_time_till_appt_uom_code = 4 THEN  -- Days
               n := '*(1)';
            ELSIF p_time_till_appt_uom_code = 5 THEN  -- Weeks
               n := '/(7)';
            ELSIF p_time_till_appt_uom_code = 6 THEN  -- Months
               n := '/(7 * 31)';
            END IF;

            IF p_time_till_appt IS NOT NULL
            THEN
               l_where_generic :=
                     l_where_generic
                  || 'AND EXISTS (SELECT 1 FROM '||
                                  'WMS_DOCK_APPOINTMENTS_B WDAB, '||
                                  'WSH_DELIVERY_LEGS WDL '||
                                  'WHERE '||
                                  'WDAB.TRIP_STOP = WDL.PICK_UP_STOP_ID AND '||
                                  'WDL.DELIVERY_ID = WDA.DELIVERY_ID AND '||
                                  'WDAB.APPOINTMENT_TYPE = 2 AND '|| -- OUTBOUND appt
                                  '(WDAB.START_TIME - sysdate)'||n||' BETWEEN 0 AND :p_time_till_appt) ';

            END IF;
         END IF;

	 IF p_summary_mode = 1 THEN
		IF i = 1 THEN
			l_where_outbound := l_where_outbound || ' GROUP BY mmtt.wms_task_type ';
		ELSE
			l_where_outbound := l_where_outbound || ' GROUP BY wdth.task_type ';
		END IF;
	 END IF;
         -- Execute the Outbound query

         -- Concatenate the different sections of the query
         l_query :=
               l_insert_query
            || l_select_generic
            || l_select_outbound
            || l_from_generic
            || l_from_outbound
            || l_where_generic
            || l_where_outbound;
         -- Parse, Bind and Execute the dynamic query

    IF l_debug = 1 then
       debug('l_query ' || l_query,'query_outbound_tasks');
    END IF;

         l_query_handle := DBMS_SQL.open_cursor;
         DBMS_SQL.parse (l_query_handle, l_query, DBMS_SQL.native);

         IF p_organization_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'org_id',
                                    p_organization_id
                                   );
         END IF;

         IF p_subinventory_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'sub_code',
                                    p_subinventory_code
                                   );
         END IF;

         IF p_locator_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'loc_id', p_locator_id);
         END IF;

         IF p_to_subinventory_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_sub_code',
                                    p_to_subinventory_code
                                   );
         END IF;

         IF p_to_locator_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_loc_id',
                                    p_to_locator_id
                                   );
         END IF;

         IF p_inventory_item_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_id',
                                    p_inventory_item_id
                                   );
         END IF;

         -- R12 : Additional Query Criteria using item type
         IF p_item_type_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_type_code',
                                    p_item_type_code
                                   );
         END IF;

         IF p_category_set_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'category_set_id',
                                    p_category_set_id
                                   );
         END IF;

         IF p_item_category_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_category_id',
                                    p_item_category_id
                                   );
         END IF;

	 -- Bug  #4459382
         -- Bind the employee criterion only if its not pending/unreleased tasks case
         IF   (i=1 AND (p_is_queued OR p_is_dispatched OR p_is_loaded OR p_is_active))
               OR
              (i=2 AND (p_is_completed OR p_is_queued OR p_is_dispatched OR p_is_loaded OR p_is_active))
         THEN

           IF p_person_id IS NOT NULL
           THEN
              DBMS_SQL.bind_variable (l_query_handle, 'person_id', p_person_id);
           END IF;

           IF p_person_resource_id IS NOT NULL
           THEN
              DBMS_SQL.bind_variable (l_query_handle,
                                    'person_resource_id',
                                    p_person_resource_id
                                   );
           END IF;

           IF p_equipment_type_id IS NOT NULL
           THEN
              DBMS_SQL.bind_variable (l_query_handle,
                                    'equipment_type_id',
                                    p_equipment_type_id
                                   );
           END IF;

           IF p_machine_resource_id IS NOT NULL
           THEN
              DBMS_SQL.bind_variable (l_query_handle,
                                    'machine_resource_id',
                                    p_machine_resource_id
                                   );
           END IF;

           IF p_machine_instance IS NOT NULL
           THEN
              DBMS_SQL.bind_variable (l_query_handle,
                                    'machine_instance',
                                    p_machine_instance
                                   );
           END IF;
         END IF;--4459382

         IF p_user_task_type_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'user_task_type_id',
                                    p_user_task_type_id
                                   );
         END IF;

         IF p_from_task_quantity IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_task_quantity',
                                    p_from_task_quantity
                                   );
         END IF;

         IF p_to_task_quantity IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_task_quantity',
                                    p_to_task_quantity
                                   );
         END IF;

         IF p_from_task_priority IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_task_priority',
                                    p_from_task_priority
                                   );
         END IF;

         IF p_to_task_priority IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_task_priority',
                                    p_to_task_priority
                                   );
         END IF;

         IF p_from_creation_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_creation_date',
                                   -- p_from_creation_date    --commented in 6868286
				   TRUNC(p_from_creation_date) --added in 6868286
                                   );
         END IF;

         IF p_to_creation_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_creation_date',
                                    --p_to_creation_date      --commented in 6868286
                                    TRUNC(p_to_creation_date) --added in 6868286
                                   );
         END IF;

         -- R12: Additional Query criteria using age of the task
         IF p_age_uom_code IS NOT NULL
         THEN

            IF p_age_min IS NOT NULL
            THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'age_min',
                                    p_age_min
                                   );
            END IF;

            IF p_age_max IS NOT NULL
            THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'age_max',
                                    p_age_max
                                   );

            END IF;
         END IF;

         IF p_include_internal_orders AND NOT p_include_sales_orders
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'source_type_id', 8);
         ELSIF NOT p_include_internal_orders AND p_include_sales_orders
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'source_type_id', 2);
         END IF;

         /*added if else for 3455109 since we are changing the query also need to change binds if its for completed task*/
         IF (i=1) /*old code*/ then

            IF p_from_sales_order_id IS NOT NULL
            THEN
               DBMS_SQL.bind_variable (l_query_handle,
                                       'from_sales_order_id',
                                       p_from_sales_order_id
                                      );
            END IF;

            IF p_to_sales_order_id IS NOT NULL
            THEN
               DBMS_SQL.bind_variable (l_query_handle,
                                       'to_sales_order_id',
                                       p_to_sales_order_id
                                      );
            END IF;
         ELSE --completed tasks
            IF(l_is_range_so)  then
                 IF p_from_sales_order_id IS NOT NULL THEN
               --3240261 dbms_sql.bind_variable(l_query_handle, 'from_sales_order_id', p_from_sales_order_id);
               dbms_sql.bind_variable(l_query_handle,'l_from_tonum_mso_seg1',l_from_tonum_mso_seg1);--added for 3455109
               dbms_sql.bind_variable(l_query_handle,'l_from_mso_seg2',l_from_mso_seg2);--3455109
                 END IF;

                   IF p_to_sales_order_id IS NOT NULL THEN
               --3420261 dbms_sql.bind_variable(l_query_handle, 'to_sales_order_id', p_to_sales_order_id);
               dbms_sql.bind_variable(l_query_handle,'l_to_tonum_mso_seg1',l_to_tonum_mso_seg1);
               dbms_sql.bind_variable(l_query_handle,'l_to_mso_seg2',l_to_mso_seg2);
                 END IF;
             ELSE
                    dbms_sql.bind_variable(l_query_handle,'l_from_mso_seg1',l_from_mso_seg1);
               dbms_sql.bind_variable(l_query_handle,'l_from_mso_seg2',l_from_mso_seg2);
             END IF;--end of range or not range so
         END IF;--end of copleted or not completed task 3455109

         IF p_from_pick_slip_number IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_pick_slip_number',
                                    p_from_pick_slip_number
                                   );
         END IF;

         IF p_to_pick_slip_number IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_pick_slip_number',
                                    p_to_pick_slip_number
                                   );
         END IF;

         IF p_wave_header_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'wave_header_id',
                                    p_wave_header_id
                                   );
         END IF;

	 IF p_customer_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'customer_id',
                                    p_customer_id
                                   );
         END IF;

         IF p_customer_category IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'customer_category',
                                    p_customer_category
                                   );
         END IF;

         IF p_trip_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'trip_id', p_trip_id);
         END IF;

         IF p_delivery_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'delivery_id',
                                    p_delivery_id
                                   );
         END IF;

         IF p_carrier_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'carrier_id',
                                    p_carrier_id
                                   );
         END IF;

         IF p_ship_method IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'ship_method',
                                    p_ship_method
                                   );
         END IF;

         IF p_order_type_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'p_order_type_id',
                                    p_order_type_id
                                   );
         END IF;

         IF p_shipment_priority IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'shipment_priority',
                                    p_shipment_priority
                                   );
         END IF;

         IF p_from_shipment_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_shipment_date',
                                    p_from_shipment_date
                                   );
         END IF;

         IF p_to_shipment_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_shipment_date',
                                    p_to_shipment_date
                                   );
         END IF;

         IF p_time_till_shipment IS NOT NULL AND p_time_till_shipment_uom_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'p_time_till_shipment',
                                    p_time_till_shipment
                                   );
         END IF;

         IF p_time_till_appt IS NOT NULL AND p_time_till_appt_uom_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'p_time_till_appt',
                                    p_time_till_appt
                                   );
         END IF;


         IF p_ship_to_state IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'ship_to_state',
                                    p_ship_to_state
                                   );
         END IF;

         IF p_ship_to_country IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'ship_to_country',
                                    p_ship_to_country
                                   );
         END IF;

         IF p_ship_to_postal_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'ship_to_postal_code',
                                    p_ship_to_postal_code
                                   );
         END IF;

         IF p_from_number_of_order_lines IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_number_of_order_lines',
                                    p_from_number_of_order_lines
                                   );
         END IF;

         IF p_to_number_of_order_lines IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_number_of_order_lines',
                                    p_to_number_of_order_lines
                                   );
         END IF;

	 IF p_summary_mode = 1 THEN
		DBMS_SQL.DEFINE_COLUMN(l_query_handle, 1, l_wms_task_type);
		DBMS_SQL.DEFINE_COLUMN(l_query_handle, 2, l_task_count);
	 END IF;

         l_query_count := DBMS_SQL.EXECUTE (l_query_handle);
         g_record_count := g_record_count + l_query_count;

	 IF p_summary_mode = 1 THEN -- fetch the rows and put them into the global tables
		LOOP
		       IF DBMS_SQL.FETCH_ROWS(l_query_handle)>0 THEN
			  DBMS_SQL.COLUMN_VALUE(l_query_handle, 1, l_wms_task_type);
			  DBMS_SQL.COLUMN_VALUE(l_query_handle, 2, l_task_count);
			  g_wms_task_summary_tbl(l_wms_task_type).wms_task_type := l_wms_task_type;
			  g_wms_task_summary_tbl(l_wms_task_type).task_count := g_wms_task_summary_tbl(l_wms_task_type).task_count + l_task_count;
			  IF l_debug = 1 then
			  	debug('Task Type :' || g_wms_task_summary_tbl(l_wms_task_type).wms_task_type, 'query_outbound_tasks');
			     	debug('TaskCount :' || g_wms_task_summary_tbl(l_wms_task_type).task_count, 'query_outbound_tasks');
			  END IF;
		       ELSE
			  EXIT; -- no more rows returned from dynamic SQL
		       END IF;
		END LOOP;
	 END IF;
    DBMS_SQL.close_cursor(l_query_handle);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN -- Bug 4150145
	IF dbms_sql.is_open(l_query_handle) THEN
	   DBMS_SQL.close_cursor(l_query_handle);
	END IF;
         DEBUG (SQLERRM, 'Task_planning.query_outbound_tasks');
   END query_outbound_tasks;

   PROCEDURE query_inbound_tasks (
      p_add                          BOOLEAN DEFAULT FALSE,
      p_organization_id              NUMBER DEFAULT NULL,
      p_subinventory_code            VARCHAR2 DEFAULT NULL,
      p_locator_id                   NUMBER DEFAULT NULL,
      p_to_subinventory_code         VARCHAR2 DEFAULT NULL,
      p_to_locator_id                NUMBER DEFAULT NULL,
      p_inventory_item_id            NUMBER DEFAULT NULL,
      p_category_set_id              NUMBER DEFAULT NULL,
      p_item_category_id             NUMBER DEFAULT NULL,
      p_person_id                    NUMBER DEFAULT NULL,
      p_person_resource_id           NUMBER DEFAULT NULL,
      p_equipment_type_id            NUMBER DEFAULT NULL,
      p_machine_resource_id          NUMBER DEFAULT NULL,
      p_machine_instance             VARCHAR2 DEFAULT NULL,
      p_user_task_type_id            NUMBER DEFAULT NULL,
      p_from_task_quantity           NUMBER DEFAULT NULL,
      p_to_task_quantity             NUMBER DEFAULT NULL,
      p_from_task_priority           NUMBER DEFAULT NULL,
      p_to_task_priority             NUMBER DEFAULT NULL,
      p_from_creation_date           DATE DEFAULT NULL,
      p_to_creation_date             DATE DEFAULT NULL,
      p_is_pending                   BOOLEAN DEFAULT FALSE,
      p_is_loaded                    BOOLEAN DEFAULT FALSE,
      p_is_completed                 BOOLEAN DEFAULT FALSE,
      p_from_po_header_id            NUMBER DEFAULT NULL,
      p_to_po_header_id              NUMBER DEFAULT NULL,
      p_from_rma_header_id           NUMBER DEFAULT NULL,
      p_to_rma_header_id             NUMBER DEFAULT NULL,
      p_from_requisition_header_id   NUMBER DEFAULT NULL,
      p_to_requisition_header_id     NUMBER DEFAULT NULL,
      p_from_shipment_number         VARCHAR2 DEFAULT NULL,
      p_to_shipment_number           VARCHAR2 DEFAULT NULL,
      -- R12 : Additional Query Criteria
      p_item_type_code                            VARCHAR2 DEFAULT NULL,
   	p_age_uom_code                              VARCHAR2 DEFAULT NULL,
   	p_age_min                                   NUMBER DEFAULT NULL,
   	p_age_max                                   NUMBER DEFAULT NULL,
	p_summary_mode			NUMBER DEFAULT 0
      -- R12 : Additional Query Criteria
   )
   IS
      l_insert_query     VARCHAR2 (4000);
      l_select_generic   VARCHAR2 (4000);
      l_from_generic     VARCHAR2 (2000);
      l_where_generic    VARCHAR2 (5000);
      l_from_inbound     VARCHAR2 (2000);
      l_where_inbound    VARCHAR2 (4000);
      l_query            VARCHAR2 (10000);
      l_query_handle     NUMBER;                -- Handle for the dynamic sql
      l_query_count      NUMBER;
      l_loop_start       NUMBER;
      l_loop_end         NUMBER;
      l_is_pending       BOOLEAN;
      l_is_loaded        BOOLEAN;
      l_is_completed     BOOLEAN;
      l_wms_task_type	 NUMBER;
      l_task_count	 NUMBER;
   BEGIN
      -- Inbound tasks currently cannot have priorities or user task types. If user wants to
      -- query up tasks with certain priorities or user task types, we should not query inbound tasks.
      IF    p_from_task_priority IS NOT NULL
         OR p_to_task_priority IS NOT NULL
         OR p_user_task_type_id IS NOT NULL
      THEN
         RETURN;
      END IF;

      IF p_is_completed
      THEN
         l_loop_end := 2;
      ELSE
         l_loop_end := 1;
      END IF;

      IF p_is_pending OR p_is_loaded
      THEN
         l_loop_start := 1;
      ELSE
         l_loop_start := 2;
      END IF;

      FOR i IN l_loop_start .. l_loop_end
      LOOP
         l_insert_query := NULL;
         l_select_generic := NULL;
         l_from_generic := NULL;
         l_from_inbound := NULL;
         l_where_generic := NULL;
         l_where_inbound := NULL;

         IF i = 1
         THEN                                -- Non completed tasks iteration
            l_is_pending := p_is_pending;
            l_is_loaded := p_is_loaded;
            l_is_completed := FALSE;
         ELSE                                               -- Completed tasks
            l_is_pending := FALSE;
            l_is_loaded := FALSE;
            l_is_completed := p_is_completed;
         END IF;

         -- Insert section
	 IF p_summary_mode = 1 THEN
		IF i=1 THEN
			l_select_generic := ' SELECT mmtt.wms_task_type, count(*) ';
		ELSE
			l_select_generic := ' SELECT wdth.task_type, count(*) ';
		END IF;
	 ELSE
         l_insert_query :=
            get_generic_insert (p_is_pending        => l_is_pending,
                                p_is_loaded         => l_is_loaded,
                                p_is_completed      => l_is_completed
                               );
         -- Inbound specific inserts
         l_insert_query := l_insert_query || ', reference_id ';
         l_insert_query := l_insert_query || ', reference ';

         IF    p_from_po_header_id IS NOT NULL
            OR p_to_po_header_id IS NOT NULL
            OR p_from_rma_header_id IS NOT NULL
            OR p_to_rma_header_id IS NOT NULL
            OR p_from_requisition_header_id IS NOT NULL
            OR p_to_requisition_header_id IS NOT NULL
         THEN
            l_insert_query := l_insert_query || ', source_header ';
            l_insert_query := l_insert_query || ', line_number ';
         END IF;

         l_insert_query := l_insert_query || ') ';
         l_select_generic :=
            get_generic_select (p_is_pending        => l_is_pending,
                                p_is_loaded         => l_is_loaded,
                                p_is_completed      => l_is_completed
                               );

         IF i = 1
         THEN
            l_select_generic := l_select_generic || ', mtrl.reference_id ';
                                                              -- reference_id
            l_select_generic := l_select_generic || ', mtrl.reference ';
                                                                 -- reference
         ELSE
            -- reference
            l_select_generic :=
                     l_select_generic || ', decode(rt.source_document_code, ';
            l_select_generic :=
                   l_select_generic || '''INVENTORY'', rt.shipment_line_id, ';
            l_select_generic :=
                       l_select_generic || '''PO'', rt.po_line_location_id, ';
            l_select_generic :=
                         l_select_generic || '''REQ'', rt.shipment_line_id, ';
            l_select_generic :=
                         l_select_generic || '''RMA'', rt.oe_order_line_id) ';
            -- reference_id
            l_select_generic :=
                     l_select_generic || ', decode(rt.source_document_code, ';
            l_select_generic :=
                  l_select_generic || '''INVENTORY'', ''SHIPMENT_LINE_ID'', ';
            l_select_generic :=
                      l_select_generic || '''PO'', ''PO_LINE_LOCATION_ID'', ';
            l_select_generic :=
                        l_select_generic || '''REQ'', ''SHIPMENT_LINE_ID'', ';
            l_select_generic :=
                           l_select_generic || '''RMA'', ''ORDER_LINE_ID'') ';
         END IF;

         IF p_from_po_header_id IS NOT NULL OR p_to_po_header_id IS NOT NULL
         THEN
            l_select_generic := l_select_generic || ', ph.segment1 ';
                                                             -- source_header
            l_select_generic := l_select_generic || ', pl.line_num ';
                                                               -- line_number
         ELSIF    p_from_rma_header_id IS NOT NULL
               OR p_to_rma_header_id IS NOT NULL
         THEN
            l_select_generic := l_select_generic || ', ooh.order_number ';
                                                             -- source_header
            l_select_generic := l_select_generic || ', ool.line_number ';
                                                               -- line_number
         ELSIF    p_from_requisition_header_id IS NOT NULL
               OR p_to_requisition_header_id IS NOT NULL
         THEN
            l_select_generic := l_select_generic || ', prh.segment1 ';
                                                             -- source_header
            l_select_generic := l_select_generic || ', prl.line_num ';
                                                               -- line_number
         END IF;
	 END IF; -- p_summary_code check

         -- Inbound secific selects, should map to the columns additionally selected above
         l_from_generic :=
            get_generic_from (p_is_loaded             => l_is_loaded,
                              p_is_completed          => l_is_completed,
                              p_item_category_id      => p_item_category_id,
                              p_category_set_id       => p_category_set_id
                             );

         IF p_from_po_header_id IS NOT NULL OR p_to_po_header_id IS NOT NULL
         THEN
            IF i = 1
            THEN
               l_from_generic :=
                              l_from_generic || ', po_line_locations_trx_v pll';
            END IF;

            l_from_generic := l_from_generic || ', po_headers_trx_v ph';--CLM Changes, using CLM views instead of base tables
            l_from_generic := l_from_generic || ', po_lines_trx_v pl';
         ELSIF    p_from_rma_header_id IS NOT NULL
               OR p_to_rma_header_id IS NOT NULL
         THEN
            l_from_generic := l_from_generic || ', oe_order_headers_all ooh';
            l_from_generic := l_from_generic || ', oe_order_lines_all ool';
         ELSIF    p_from_requisition_header_id IS NOT NULL
               OR p_to_requisition_header_id IS NOT NULL
         THEN
            l_from_generic := l_from_generic || ', rcv_shipment_headers rsh';
            l_from_generic := l_from_generic || ', rcv_shipment_lines rsl';
            l_from_generic :=
                             l_from_generic || ', po_requisition_headers_all prh';
            l_from_generic := l_from_generic || ', po_requisition_lines_all prl';
         ELSIF    p_from_shipment_number IS NOT NULL
               OR p_to_shipment_number IS NOT NULL
         THEN
            l_from_generic := l_from_generic || ', rcv_shipment_headers rsh';
            l_from_generic := l_from_generic || ', rcv_shipment_lines rsl';
         END IF;

         IF i = 1
         THEN
            l_from_generic :=
                          l_from_generic || ', mtl_txn_request_headers mtrh ';
            l_from_generic :=
                            l_from_generic || ', mtl_txn_request_lines mtrl ';
         ELSE
            l_from_generic := l_from_generic || ', rcv_transactions rt ';
         END IF;

         l_where_generic :=
            get_generic_where
                            (p_add                       => p_add,
                             p_organization_id           => p_organization_id,
                             p_subinventory_code         => p_subinventory_code,
                             p_locator_id                => p_locator_id,
                             p_to_subinventory_code      => p_to_subinventory_code,
                             p_to_locator_id             => p_to_locator_id,
                             p_inventory_item_id         => p_inventory_item_id,
                             p_category_set_id           => p_category_set_id,
                             p_item_category_id          => p_item_category_id,
                             p_person_id                 => p_person_id,
                             p_person_resource_id        => p_person_resource_id,
                             p_equipment_type_id         => p_equipment_type_id,
                             p_machine_resource_id       => p_machine_resource_id,
                             p_machine_instance          => p_machine_instance,
                             p_from_task_quantity        => p_from_task_quantity,
                             p_to_task_quantity          => p_to_task_quantity,
                             p_from_creation_date        => p_from_creation_date,
                             p_to_creation_date          => p_to_creation_date,
                             p_is_pending                => l_is_pending,
                             p_is_loaded                 => l_is_loaded,
                             p_is_completed              => l_is_completed,
                              -- R12: Additional query criteria
                              p_item_type_code             =>  p_item_type_code,
                              p_age_uom_code               =>  p_age_uom_code,
                              p_age_min                    =>  p_age_min,
                              p_age_max                    =>  p_age_max
                            );

         IF i = 1
         THEN
            l_where_generic :=
                   l_where_generic || ' AND mtrh.header_id = mtrl.header_id ';
            l_where_generic :=
                          l_where_generic || ' AND mtrh.move_order_type = 6 ';
            l_where_generic :=
                  l_where_generic
               || ' AND mmtt.move_order_line_id = mtrl.line_id ';

            IF NOT (   p_from_po_header_id IS NOT NULL
                    OR p_to_po_header_id IS NOT NULL
                    OR p_from_rma_header_id IS NOT NULL
                    OR p_to_rma_header_id IS NOT NULL
                    OR p_from_requisition_header_id IS NOT NULL
                    OR p_to_requisition_header_id IS NOT NULL
                   )
            THEN
               l_where_generic :=
                     l_where_generic
                  || ' AND mtrl.reference in (''PO_LINE_LOCATION_ID'', ''ORDER_LINE_ID'', ''SHIPMENT_LINE_ID'') ';
            END IF;
         ELSE
            l_where_generic :=
                  l_where_generic
               || ' AND mmt.rcv_transaction_id = rt.transaction_id ';
         END IF;

         -- Build the inbound section(FROM and WHERE) of the query
         IF p_from_po_header_id IS NOT NULL OR p_to_po_header_id IS NOT NULL
         THEN
            l_where_inbound :=
                 l_where_inbound || ' AND pl.po_header_id = ph.po_header_id ';

            IF i = 1
            THEN
               l_where_inbound :=
                    l_where_inbound || ' AND pll.po_line_id = pl.po_line_id ';
               l_where_inbound :=
                     l_where_inbound
                  || ' AND pll.line_location_id = mtrl.reference_id ';
               l_where_inbound :=
                     l_where_inbound
                  || ' AND mtrl.reference = ''PO_LINE_LOCATION_ID'' ';

               IF p_from_po_header_id IS NOT NULL
               THEN
                  l_where_inbound :=
                        l_where_inbound
                     || 'AND pll.po_header_id >= :from_po_header_id ';
               END IF;

               IF p_to_po_header_id IS NOT NULL
               THEN
                  l_where_inbound :=
                        l_where_inbound
                     || 'AND pll.po_header_id <= :to_po_header_id ';
               END IF;
            ELSE
               l_where_inbound :=
                     l_where_inbound || ' AND rt.po_line_id = pl.po_line_id ';

               IF p_from_po_header_id IS NOT NULL
               THEN
                  l_where_inbound :=
                        l_where_inbound
                     || 'AND rt.po_header_id >= :from_po_header_id ';
               END IF;

               IF p_to_po_header_id IS NOT NULL
               THEN
                  l_where_inbound :=
                        l_where_inbound
                     || 'AND rt.po_header_id <= :to_po_header_id ';
               END IF;
            END IF;
         ELSIF    p_from_rma_header_id IS NOT NULL
               OR p_to_rma_header_id IS NOT NULL
         THEN
            l_where_generic :=
                     l_where_generic || ' AND ooh.header_id = ool.header_id ';

            IF i = 1
            THEN
               l_where_generic :=
                   l_where_generic || ' AND mtrl.reference_id = ool.line_id ';
               l_where_inbound :=
                     l_where_inbound
                  || ' AND mtrl.reference = ''ORDER_LINE_ID'' ';

               IF p_from_rma_header_id IS NOT NULL
               THEN
                  l_where_inbound :=
                        l_where_inbound
                     || 'AND ooh.header_id >= :from_rma_header_id ';
               END IF;

               IF p_to_rma_header_id IS NOT NULL
               THEN
                  l_where_inbound :=
                        l_where_inbound
                     || 'AND ooh.header_id <= :to_rma_header_id ';
               END IF;
            ELSE
               l_where_generic :=
                  l_where_generic
                  || ' AND rt.oe_order_line_id = ool.line_id ';

               IF p_from_rma_header_id IS NOT NULL
               THEN
                  l_where_inbound :=
                        l_where_inbound
                     || 'AND rt.oe_order_header_id >= :from_rma_header_id ';
               END IF;

               IF p_to_rma_header_id IS NOT NULL
               THEN
                  l_where_inbound :=
                        l_where_inbound
                     || 'AND rt.oe_order_header_id <= :to_rma_header_id ';
               END IF;
            END IF;
         ELSIF    p_from_requisition_header_id IS NOT NULL
               OR p_to_requisition_header_id IS NOT NULL
         THEN
            l_where_inbound :=
                  l_where_inbound
               || ' AND rsl.requisition_line_id = prl.requisition_line_id ';
            l_where_generic :=
                  l_where_generic
               || ' AND rsh.shipment_header_id = rsl.shipment_header_id ';
            l_where_generic :=
                  l_where_generic
               || ' AND prh.requisition_header_id = prl.requisition_header_id ';

            IF i = 1
            THEN
               l_where_inbound :=
                     l_where_inbound
                  || ' AND mtrl.reference_id = rsl.shipment_line_id ';
               l_where_inbound :=
                     l_where_inbound
                  || ' AND mtrl.reference = ''SHIPMENT_LINE_ID'' ';

               IF p_from_requisition_header_id IS NOT NULL
               THEN
                  l_where_inbound :=
                        l_where_inbound
                     || 'AND prh.requisition_header_id >= :from_requisition_header_id ';
               END IF;

               IF p_to_requisition_header_id IS NOT NULL
               THEN
                  l_where_inbound :=
                        l_where_inbound
                     || 'AND prh.requisition_header_id <= :to_requisition_header_id ';
               END IF;
            ELSE
               l_where_inbound :=
                     l_where_inbound
                  || ' AND rt.shipment_line_id = rsl.shipment_line_id ';

               IF p_from_requisition_header_id IS NOT NULL
               THEN
                  l_where_inbound :=
                        l_where_inbound
                     || 'AND prh.requisition_header_id >= :from_requisition_header_id ';
               END IF;

               IF p_to_requisition_header_id IS NOT NULL
               THEN
                  l_where_inbound :=
                        l_where_inbound
                     || 'AND prh.requisition_header_id <= :to_requisition_header_id ';
               END IF;
            END IF;
         ELSIF    p_from_shipment_number IS NOT NULL
               OR p_to_shipment_number IS NOT NULL
         THEN
            l_where_inbound :=
                  l_where_inbound
               || ' AND rsh.shipment_header_id = rsl.shipment_header_id ';
            l_where_inbound :=
                    l_where_inbound || ' AND rsl.requisition_line_id IS NULL ';

            IF i = 1
            THEN
               l_where_inbound :=
                     l_where_inbound
                  || ' AND mtrl.reference_id = rsl.shipment_line_id ';
               l_where_inbound :=
                     l_where_inbound
                  || ' AND mtrl.reference = ''SHIPMENT_LINE_ID'' ';
            ELSE
               l_where_inbound :=
                     l_where_inbound
                  || ' AND rsh.shipment_header_id = rt.shipment_header_id ';
               l_where_inbound :=
                     l_where_inbound
                  || ' AND rsl.shipment_line_id = rt.shipment_line_id ';
               l_where_inbound :=
                              l_where_inbound || ' AND rt.po_line_id IS NULL ';
               l_where_inbound :=
                      l_where_inbound || ' AND  rt.oe_order_header_id IS NULL ';
            END IF;

            IF p_from_shipment_number IS NOT NULL
            THEN
               l_where_inbound :=
                     l_where_inbound
                  || ' AND rsh.shipment_num >= :from_shipment_number ';
            END IF;

            IF p_to_shipment_number IS NOT NULL
            THEN
               l_where_inbound :=
                     l_where_inbound
                  || ' AND rsh.shipment_num <= :to_shipment_number ';
            END IF;
         END IF;

	 IF p_summary_mode = 1 THEN
		IF i = 1 THEN
			l_where_inbound := l_where_inbound || ' GROUP BY mmtt.wms_task_type ';
		ELSE
			l_where_inbound := l_where_inbound || ' GROUP BY wdth.task_type ';
		END IF;
	 END IF;

         -- Execute the Inbound query

         -- Concatenate the different sections of the query
         l_query :=
               l_insert_query
            || l_select_generic
            || l_from_generic
            || l_from_inbound
            || l_where_generic
            || l_where_inbound;
         -- Parse, Bind and Execute the dynamic query
         l_query_handle := DBMS_SQL.open_cursor;
         DBMS_SQL.parse (l_query_handle, l_query, DBMS_SQL.native);

         --generic bind variables
         IF p_organization_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'org_id',
                                    p_organization_id
                                   );
         END IF;

         IF p_subinventory_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'sub_code',
                                    p_subinventory_code
                                   );
         END IF;

         IF p_locator_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'loc_id', p_locator_id);
         END IF;

         IF p_to_subinventory_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_sub_code',
                                    p_to_subinventory_code
                                   );
         END IF;

         IF p_to_locator_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_loc_id',
                                    p_to_locator_id
                                   );
         END IF;

         IF p_inventory_item_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_id',
                                    p_inventory_item_id
                                   );
         END IF;

         -- R12 : Additional Query Criteria using item type
         IF p_item_type_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_type_code',
                                    p_item_type_code
                                   );
         END IF;


         IF p_category_set_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'category_set_id',
                                    p_category_set_id
                                   );
         END IF;

         IF p_item_category_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_category_id',
                                    p_item_category_id
                                   );
         END IF;

         IF p_person_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'person_id', p_person_id);
         END IF;

         IF p_person_resource_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'person_resource_id',
                                    p_person_resource_id
                                   );
         END IF;

         IF p_equipment_type_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'equipment_type_id',
                                    p_equipment_type_id
                                   );
         END IF;

         IF p_machine_resource_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'machine_resource_id',
                                    p_machine_resource_id
                                   );
         END IF;

         IF p_machine_instance IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'machine_instance',
                                    p_machine_instance
                                   );
         END IF;

         IF p_from_task_quantity IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_task_quantity',
                                    p_from_task_quantity
                                   );
         END IF;

         IF p_to_task_quantity IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_task_quantity',
                                    p_to_task_quantity
                                   );
         END IF;

         IF p_from_creation_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_creation_date',
                                    p_from_creation_date
                                   );
         END IF;

         IF p_to_creation_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_creation_date',
                                    p_to_creation_date
                                   );
         END IF;

         -- R12: Additional Query criteria using age of the task
         IF p_age_uom_code IS NOT NULL
         THEN

            IF p_age_min IS NOT NULL
            THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'age_min',
                                    p_age_min
                                   );
            END IF;

            IF p_age_max IS NOT NULL
            THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'age_max',
                                    p_age_max
                                   );

            END IF;
         END IF;

         --Inbound specifc bind variables
         IF p_from_po_header_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_po_header_id',
                                    p_from_po_header_id
                                   );
         END IF;

         IF p_to_po_header_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_po_header_id',
                                    p_to_po_header_id
                                   );
         END IF;

         IF p_from_rma_header_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_rma_header_id',
                                    p_from_rma_header_id
                                   );
         END IF;

         IF p_to_rma_header_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_rma_header_id',
                                    p_to_rma_header_id
                                   );
         END IF;

         IF p_from_requisition_header_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_requisition_header_id',
                                    p_from_requisition_header_id
                                   );
         END IF;

         IF p_to_requisition_header_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_requisition_header_id',
                                    p_to_requisition_header_id
                                   );
         END IF;

         IF p_from_shipment_number IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_shipment_number',
                                    p_from_shipment_number
                                   );
         END IF;

         IF p_to_shipment_number IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_shipment_number',
                                    p_to_shipment_number
                                   );
         END IF;

	 IF p_summary_mode = 1 THEN
		DBMS_SQL.DEFINE_COLUMN(l_query_handle, 1, l_wms_task_type);
		DBMS_SQL.DEFINE_COLUMN(l_query_handle, 2, l_task_count);
	 END IF;

         --execute the query
         l_query_count := DBMS_SQL.EXECUTE (l_query_handle);
         g_record_count := g_record_count + l_query_count;

	 IF p_summary_mode = 1 THEN -- fetch the rows and put them into the global tables
		LOOP
		       IF DBMS_SQL.FETCH_ROWS(l_query_handle)>0 THEN
			  DBMS_SQL.COLUMN_VALUE(l_query_handle, 1, l_wms_task_type);
			  DBMS_SQL.COLUMN_VALUE(l_query_handle, 2, l_task_count);
			  g_wms_task_summary_tbl(l_wms_task_type).wms_task_type := l_wms_task_type;
			  g_wms_task_summary_tbl(l_wms_task_type).task_count := g_wms_task_summary_tbl(l_wms_task_type).task_count + l_task_count;
		       ELSE
			  EXIT; -- no more rows returned from dynamic SQL
		       END IF;
		END LOOP;
	 END IF;

    DBMS_SQL.close_cursor(l_query_handle);
      END LOOP;

      IF     (g_source_header_visible = 'T' OR g_line_number_visible = 'T')
         AND p_from_po_header_id IS NULL
         AND p_to_po_header_id IS NULL
         AND p_from_rma_header_id IS NULL
         AND p_to_rma_header_id IS NULL
         AND p_from_requisition_header_id IS NULL
         AND p_to_requisition_header_id IS NULL
      THEN
         set_inbound_source_header_line;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN -- Bug 4150145
	IF dbms_sql.is_open(l_query_handle) THEN
           dbms_sql.close_cursor(l_query_handle);
        END IF;
        DEBUG (SQLERRM, 'Task_planning.query_inbound_tasks');
   END query_inbound_tasks;

   PROCEDURE query_manufacturing_tasks (
      p_add                    BOOLEAN DEFAULT FALSE,
      p_organization_id        NUMBER DEFAULT NULL,
      p_subinventory_code      VARCHAR2 DEFAULT NULL,
      p_locator_id             NUMBER DEFAULT NULL,
      p_to_subinventory_code   VARCHAR2 DEFAULT NULL,
      p_to_locator_id          NUMBER DEFAULT NULL,
      p_inventory_item_id      NUMBER DEFAULT NULL,
      p_category_set_id        NUMBER DEFAULT NULL,
      p_item_category_id       NUMBER DEFAULT NULL,
      p_person_id              NUMBER DEFAULT NULL,
      p_person_resource_id     NUMBER DEFAULT NULL,
      p_equipment_type_id      NUMBER DEFAULT NULL,
      p_machine_resource_id    NUMBER DEFAULT NULL,
      p_machine_instance       VARCHAR2 DEFAULT NULL,
      p_user_task_type_id      NUMBER DEFAULT NULL,
      p_from_task_quantity     NUMBER DEFAULT NULL,
      p_to_task_quantity       NUMBER DEFAULT NULL,
      p_from_task_priority     NUMBER DEFAULT NULL,
      p_to_task_priority       NUMBER DEFAULT NULL,
      p_from_creation_date     DATE DEFAULT NULL,
      p_to_creation_date       DATE DEFAULT NULL,
      p_is_unreleased          BOOLEAN DEFAULT FALSE,
      p_is_pending             BOOLEAN DEFAULT FALSE,
      p_is_queued              BOOLEAN DEFAULT FALSE,
      p_is_dispatched          BOOLEAN DEFAULT FALSE,
      p_is_active              BOOLEAN DEFAULT FALSE,
      p_is_loaded              BOOLEAN DEFAULT FALSE,
      p_is_completed           BOOLEAN DEFAULT FALSE,
      p_manufacturing_type     VARCHAR2 DEFAULT NULL,
      p_from_job               VARCHAR2 DEFAULT NULL,
      p_to_job                 VARCHAR2 DEFAULT NULL,
      p_assembly_id            NUMBER DEFAULT NULL,
      p_from_start_date        DATE DEFAULT NULL,
      p_to_start_date          DATE DEFAULT NULL,
      p_from_line              VARCHAR2 DEFAULT NULL,
      p_to_line                VARCHAR2 DEFAULT NULL,
      p_department_id          NUMBER DEFAULT NULL,
      -- R12 : Additional Query Criteria
      p_item_type_code                            VARCHAR2 DEFAULT NULL,
   	p_age_uom_code                              VARCHAR2 DEFAULT NULL,
   	p_age_min                                   NUMBER DEFAULT NULL,
   	p_age_max                                   NUMBER DEFAULT NULL,
	p_summary_mode		NUMBER DEFAULT 0
      -- R12 : Additional Query Criteria
   )
   IS
      l_query                  VARCHAR2 (10000);
      l_insert_query           VARCHAR2 (3000);
      l_select_manufacturing   VARCHAR2 (3000);
      l_from_manufacturing     VARCHAR2 (3000);
      l_where_manufacturing    VARCHAR2 (4000);
      l_select_generic         VARCHAR2 (3000);
      l_from_generic           VARCHAR2 (3000);
      l_where_generic          VARCHAR2 (5000);
      l_query_handle           NUMBER;          -- Handle for the dynamic sql
      l_query_count            NUMBER;
      l_loop_start             NUMBER;
      l_loop_end               NUMBER;
      l_is_unreleased          BOOLEAN;
      l_is_pending             BOOLEAN;
      l_is_queued              BOOLEAN;
      l_is_dispatched          BOOLEAN;
      l_is_active              BOOLEAN;
      l_is_loaded              BOOLEAN;
      l_is_completed           BOOLEAN;
      l_wms_task_type	NUMBER; -- for bug 5129375
      l_task_count	NUMBER;
      l_debug                    NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
   BEGIN
      IF p_is_completed  THEN

         /*Bug 3627575:Setting the variable to true for Inbound queries*/
        wms_plan_tasks_pvt.g_from_inbound :=TRUE;

         l_loop_end := 2;
      ELSE
         l_loop_end := 1;
      END IF;

      IF    p_is_unreleased
         OR p_is_pending
         OR p_is_queued
         OR p_is_dispatched
         OR p_is_active
         OR p_is_loaded
      THEN
         l_loop_start := 1;
      ELSE
         l_loop_start := 2;
      END IF;

      FOR i IN l_loop_start .. l_loop_end
      LOOP
         l_insert_query := NULL;
         l_select_generic := NULL;
         l_select_manufacturing := NULL;
         l_from_generic := NULL;
         l_from_manufacturing := NULL;
         l_where_generic := NULL;
         l_where_manufacturing := NULL;

         IF i = 1
         THEN                                -- Non completed tasks iteration
            l_is_unreleased := p_is_unreleased;
            l_is_pending := p_is_pending;
            l_is_queued := p_is_queued;
            l_is_dispatched := p_is_dispatched;
            l_is_active := p_is_active;
            l_is_loaded := p_is_loaded;
            l_is_completed := FALSE;
         ELSE                                               -- Completed tasks
            l_is_unreleased := FALSE;
            l_is_pending := FALSE;
            l_is_queued := FALSE;
            l_is_dispatched := FALSE;
            l_is_active := FALSE;
            l_is_loaded := FALSE;
            l_is_completed := p_is_completed;
         END IF;

         -- Insert section
	 IF  p_summary_mode = 1 THEN -- only for query mode
		IF i = 1 THEN
			l_select_generic := ' SELECT mmtt.wms_task_type, count(*) ';
		ELSE
			l_select_generic := ' SELECT wdth.task_type, count(*) ';
		END IF;
	 ELSE
         l_insert_query :=
            get_generic_insert (p_is_unreleased      => l_is_unreleased,
                                p_is_pending         => l_is_pending,
                                p_is_queued          => l_is_queued,
                                p_is_dispatched      => l_is_dispatched,
                                p_is_active          => l_is_active,
                                p_is_loaded          => l_is_loaded,
                                p_is_completed       => l_is_completed
                               );

         -- Manufacturing specific insert
         IF g_assembly_visible = 'T' OR p_assembly_id IS NOT NULL
         THEN
            l_insert_query := l_insert_query || ', assembly_id ';

            IF g_assembly_visible = 'T'
            THEN
               l_insert_query := l_insert_query || ', assembly ';
            END IF;
         END IF;

         IF    g_line_visible = 'T'
            OR p_from_line IS NOT NULL
            OR p_to_line IS NOT NULL
         THEN
            l_insert_query := l_insert_query || ', line_id ';
            l_insert_query := l_insert_query || ', line ';
         END IF;

         IF g_department_visible = 'T' OR p_department_id IS NOT NULL
         THEN
            l_insert_query := l_insert_query || ', department_id ';

            IF g_department_visible = 'T'
            THEN
               l_insert_query := l_insert_query || ', department ';
            END IF;
         END IF;

         IF    g_source_header_visible = 'T'
            OR p_from_job IS NOT NULL
            OR p_to_job IS NOT NULL
         THEN
            l_insert_query := l_insert_query || ', source_header ';
         END IF;

         l_insert_query := l_insert_query || ', wip_entity_type ';
         l_insert_query := l_insert_query || ', wip_entity_id ';
	 /* Navin INV_Convergence_Gme_Wms_TD REPLACED: l_insert_query := l_insert_query || ') '; */
         IF p_manufacturing_type = '10' /* Batch*/ THEN
             l_insert_query := l_insert_query || ', primary_product ';
             l_insert_query := l_insert_query || ') ';
         ELSE
             l_insert_query := l_insert_query || ') ';
         END IF;
         -- Generic select
         l_select_generic :=
            get_generic_select (p_is_unreleased      => l_is_unreleased,
                                p_is_pending         => l_is_pending,
                                p_is_queued          => l_is_queued,
                                p_is_dispatched      => l_is_dispatched,
                                p_is_active          => l_is_active,
                                p_is_loaded          => l_is_loaded,
                                p_is_completed       => l_is_completed
                               );
	END IF;
         -- Generic from
         l_from_generic :=
            get_generic_from (p_is_queued             => l_is_queued,
                              p_is_dispatched         => l_is_dispatched,
                              p_is_active             => l_is_active,
                              p_is_loaded             => l_is_loaded,
                              p_is_completed          => l_is_completed,
                              p_item_category_id      => p_item_category_id,
                              p_category_set_id       => p_category_set_id
                             );
         --Generic Where
         l_where_generic :=
            get_generic_where
                            (p_add                       => p_add,
                             p_organization_id           => p_organization_id,
                             p_subinventory_code         => p_subinventory_code,
                             p_locator_id                => p_locator_id,
                             p_to_subinventory_code      => p_to_subinventory_code,
                             p_to_locator_id             => p_to_locator_id,
                             p_inventory_item_id         => p_inventory_item_id,
                             p_category_set_id           => p_category_set_id,
                             p_item_category_id          => p_item_category_id,
                             p_person_id                 => p_person_id,
                             p_person_resource_id        => p_person_resource_id,
                             p_equipment_type_id         => p_equipment_type_id,
                             p_machine_resource_id       => p_machine_resource_id,
                             p_machine_instance          => p_machine_instance,
                             p_user_task_type_id         => p_user_task_type_id,
                             p_from_task_quantity        => p_from_task_quantity,
                             p_to_task_quantity          => p_to_task_quantity,
                             p_from_task_priority        => p_from_task_priority,
                             p_to_task_priority          => p_to_task_priority,
                             p_from_creation_date        => p_from_creation_date,
                             p_to_creation_date          => p_to_creation_date,
                             p_is_unreleased             => l_is_unreleased,
                             p_is_pending                => l_is_pending,
                             p_is_queued                 => l_is_queued,
                             p_is_dispatched             => l_is_dispatched,
                             p_is_active                 => l_is_active,
                             p_is_loaded                 => l_is_loaded,
                             p_is_completed              => l_is_completed,
                              -- R12: Additional query criteria
                              p_item_type_code             =>  p_item_type_code,
                              p_age_uom_code               =>  p_age_uom_code,
                              p_age_min                    =>  p_age_min,
                              p_age_max                    =>  p_age_max
                            );

         -- Build the manufacturing section(FROM and WHERE) of the query
         IF p_manufacturing_type IS NOT NULL
         THEN
            l_from_manufacturing := ', mtl_txn_request_lines mtrl ';

            IF i = 1
            THEN
               l_where_manufacturing :=
                               ' and mmtt.move_order_line_id = mtrl.line_id ';
            ELSE
               l_where_manufacturing :=
                                ' and mmt.move_order_line_id = mtrl.line_id ';
            END IF;

            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and mtrl.transaction_source_type_id in (5,13) ';
            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and mtrl.transaction_type_id in (35,51) ';
         END IF;

         IF p_manufacturing_type = '1'
         THEN                                                            --job
            IF g_assembly_visible = 'T' OR p_assembly_id IS NOT NULL
            THEN
               l_select_manufacturing := ', wdj.primary_item_id ';
                                                               -- assembly_id

               IF g_assembly_visible = 'T'
               THEN
                  l_select_manufacturing :=
                        l_select_manufacturing
                     || ', msiv2.concatenated_segments ';          -- assembly
               END IF;
            END IF;

            IF    g_line_visible = 'T'
               OR p_from_line IS NOT NULL
               OR p_to_line IS NOT NULL
            THEN
               l_select_manufacturing :=
                                    l_select_manufacturing || ', wl.line_id ';
                                                                   -- line_id
               l_select_manufacturing :=
                                  l_select_manufacturing || ', wl.line_code ';
                                                                      -- line
            END IF;

            IF g_department_visible = 'T' OR p_department_id IS NOT NULL
            THEN
               l_select_manufacturing :=
                             l_select_manufacturing || ', wro.department_id ';
                                                             -- department_id

               IF g_department_visible = 'T'
               THEN
                  l_select_manufacturing :=
                            l_select_manufacturing || ', bd.department_code ';
                                                                -- department
               END IF;
            END IF;

            IF    g_source_header_visible = 'T'
               OR p_from_job IS NOT NULL
               OR p_to_job IS NOT NULL
            THEN
               l_select_manufacturing :=
                            l_select_manufacturing || ', we.wip_entity_name ';
                                                             -- source header
            END IF;

            l_select_manufacturing :=
                                   l_select_manufacturing || ', to_number(1) ';
                                                         -- manufacturing_type
            l_select_manufacturing :=
                              l_select_manufacturing || ', wdj.wip_entity_id ';
                                                              -- wip_entity_id
            l_from_manufacturing :=
                            l_from_manufacturing || ', wip_discrete_jobs wdj ';

            IF g_assembly_visible = 'T'
            THEN
               l_from_manufacturing :=
                      l_from_manufacturing || ', mtl_system_items_kfv msiv2 ';
            END IF;

            IF g_department_visible = 'T'
            THEN
               l_from_manufacturing :=
                              l_from_manufacturing || ', bom_departments bd ';
            END IF;

            l_where_manufacturing :=
                  l_where_manufacturing
               || '  and mtrl.txn_source_id = wdj.wip_entity_id ';

            IF g_assembly_visible = 'T'
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || '  and wdj.primary_item_id = msiv2.inventory_item_id(+) ';
               l_where_manufacturing :=
                     l_where_manufacturing
                  || '  and wdj.organization_id = msiv2.organization_id(+) ';
            END IF;

            IF    g_source_header_visible = 'T'
               OR p_from_job IS NOT NULL
               OR p_to_job IS NOT NULL
            THEN
               l_from_manufacturing :=
                                 l_from_manufacturing || ', wip_entities we ';
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wdj.wip_entity_id = we.wip_entity_id ';
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wdj.organization_id = we.organization_id ';

               IF p_from_job IS NOT NULL
               THEN
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and we.wip_entity_name >= :from_job ';
               END IF;

               IF p_to_job IS NOT NULL
               THEN
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and we.wip_entity_name <= :to_job ';
               END IF;
            END IF;

            IF p_assembly_id IS NOT NULL
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wdj.primary_item_id = :assembly_id ';
            END IF;

            IF p_from_start_date IS NOT NULL
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wdj.scheduled_start_date >= :from_start_date ';
            END IF;

            IF p_to_start_date IS NOT NULL
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wdj.scheduled_start_date <= :to_start_date ';
            END IF;

            IF    g_line_visible = 'T'
               OR p_from_line IS NOT NULL
               OR p_to_line IS NOT NULL
            THEN
               l_from_manufacturing :=
                                   l_from_manufacturing || ' , wip_lines wl ';
               l_where_manufacturing :=
                  l_where_manufacturing
                  || ' and wdj.line_id = wl.line_id(+) ';
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wdj.organization_id = wl.organization_id(+) ';

               IF p_from_line IS NOT NULL
               THEN
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and wl.line_code >= :from_line ';
               END IF;

               IF p_to_line IS NOT NULL
               THEN
                  l_where_manufacturing :=
                     l_where_manufacturing
                     || ' and wl.line_code <= :to_line ';
               END IF;
            END IF;

            IF g_department_visible = 'T' OR p_department_id IS NOT NULL
            THEN
               l_from_manufacturing :=
                  l_from_manufacturing
                  || ' , wip_requirement_operations wro ';
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and mtrl.txn_source_line_id = wro.operation_seq_num ';
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and mtrl.inventory_item_id = wro.inventory_item_id ';
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wdj.wip_entity_id   = wro.wip_entity_id ';
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wdj.organization_id = wro.organization_id ';

               IF p_department_id IS NOT NULL
               THEN
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and wro.department_id = :dept_id ';
               END IF;

               IF g_department_visible = 'T'
               THEN
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and wro.department_id = bd.department_id(+) ';
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and wro.organization_id = bd.organization_id(+) ';
               END IF;
            END IF;
         ELSIF p_manufacturing_type = '2'
         THEN                                                  --Flow schedule
            IF g_assembly_visible = 'T' OR p_assembly_id IS NOT NULL
            THEN
               l_select_manufacturing := ', wfs.primary_item_id ';
                                                               -- assembly_id

               IF g_assembly_visible = 'T'
               THEN
                  l_select_manufacturing :=
                        l_select_manufacturing
                     || ', msiv2.concatenated_segments ';          -- assembly
               END IF;
            END IF;

            IF    g_line_visible = 'T'
               OR p_from_line IS NOT NULL
               OR p_to_line IS NOT NULL
            THEN
               l_select_manufacturing :=
                                    l_select_manufacturing || ', wl.line_id ';
                                                                   -- line_id
               l_select_manufacturing :=
                                  l_select_manufacturing || ', wl.line_code ';
                                                                      -- line
            END IF;

            IF g_department_visible = 'T' OR p_department_id IS NOT NULL
            THEN
               l_select_manufacturing :=
                             l_select_manufacturing || ', bos.department_id ';
                                                             -- department_id

               IF g_department_visible = 'T'
               THEN
                  l_select_manufacturing :=
                            l_select_manufacturing || ', bd.department_code ';
                                                                -- department
               END IF;
            END IF;

            IF    g_source_header_visible = 'T'
               OR p_from_job IS NOT NULL
               OR p_to_job IS NOT NULL
            THEN
               l_select_manufacturing :=
                           l_select_manufacturing || ', wfs.schedule_number ';
                                                             -- source header
            END IF;

            l_select_manufacturing :=
                                    l_select_manufacturing || ',to_number(2) ';
                                                         -- manufacturing_type
            l_select_manufacturing :=
                              l_select_manufacturing || ', wfs.wip_entity_id ';
                                                              -- wip_entity_id
            l_from_manufacturing :=
                          l_from_manufacturing || ' , wip_flow_schedules wfs ';
            l_from_manufacturing :=
                    l_from_manufacturing || ' , bom_operational_routings bor ';
            l_from_manufacturing :=
                     l_from_manufacturing || ' , bom_operation_sequences bos ';

            IF g_assembly_visible = 'T'
            THEN
               l_from_manufacturing :=
                      l_from_manufacturing || ', mtl_system_items_kfv msiv2 ';
            END IF;

            IF g_department_visible = 'T'
            THEN
               l_from_manufacturing :=
                              l_from_manufacturing || ', bom_departments bd ';
            END IF;

            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and mtrl.txn_source_id = wfs.wip_entity_id ';
            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and mtrl.organization_id = wfs.organization_id ';
            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and ( (mtrl.txn_source_line_id = bos.operation_seq_num) or (mtrl.txn_source_line_id = 1) ) ';
            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and (wfs.alternate_routing_designator = bor.alternate_routing_designator ';
            l_where_manufacturing :=
                  l_where_manufacturing
               || ' OR (wfs.alternate_routing_designator is null AND bor.alternate_routing_designator is null)) ';
            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and wfs.organization_id = bor.organization_id ';
            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and wfs.primary_item_id = bor.assembly_item_id ';
            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and bor.routing_sequence_id = bos.routing_sequence_id ';
            l_where_manufacturing :=
                       l_where_manufacturing || ' and bos.operation_type = 1 ';

            IF g_assembly_visible = 'T'
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wfs.primary_item_id = msiv2.inventory_item_id ';
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and mtrl.organization_id = msiv2.organization_id ';
            END IF;

            IF p_from_job IS NOT NULL OR p_to_job IS NOT NULL
            THEN
               IF p_from_job IS NOT NULL
               THEN
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and wfs.schedule_number >= :from_job ';
               END IF;

               IF p_to_job IS NOT NULL
               THEN
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and wfs.schedule_number <= :to_job ';
               END IF;
            END IF;

            IF p_assembly_id IS NOT NULL
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wfs.primary_item_id = :assembly_id ';
            END IF;

            IF p_from_start_date IS NOT NULL
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wfs.scheduled_start_date >= :from_start_date ';
            END IF;

            IF p_to_start_date IS NOT NULL
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wfs.scheduled_start_date <= :to_start_date ';
            END IF;

            IF    g_line_visible = 'T'
               OR p_from_line IS NOT NULL
               OR p_to_line IS NOT NULL
            THEN
               l_from_manufacturing :=
                                   l_from_manufacturing || ' , wip_lines wl ';
               l_where_manufacturing :=
                    l_where_manufacturing || ' and wfs.line_id = wl.line_id ';
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wfs.organization_id = wl.organization_id ';

               IF p_from_line IS NOT NULL
               THEN
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and wl.line_code >= :from_line ';
               END IF;

               IF p_to_line IS NOT NULL
               THEN
                  l_where_manufacturing :=
                     l_where_manufacturing
                     || ' and wl.line_code <= :to_line ';
               END IF;
            END IF;

            IF g_department_visible = 'T' OR p_department_id IS NOT NULL
            THEN
               IF p_department_id IS NOT NULL
               THEN
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and bos.department_id = :dept_id ';
               END IF;

               IF g_department_visible = 'T'
               THEN
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and bos.department_id = bd.department_id ';
               END IF;
            END IF;
         ELSIF p_manufacturing_type = '3'
         THEN                                            --repetitive schedule
            IF g_assembly_visible = 'T' OR p_assembly_id IS NOT NULL
            THEN
               l_select_manufacturing := ', wri.primary_item_id ';
                                                               -- assembly_id

               IF g_assembly_visible = 'T'
               THEN
                  l_select_manufacturing :=
                        l_select_manufacturing
                     || ', msiv2.concatenated_segments ';          -- assembly
               END IF;
            END IF;

            IF    g_line_visible = 'T'
               OR p_from_line IS NOT NULL
               OR p_to_line IS NOT NULL
            THEN
               l_select_manufacturing :=
                                    l_select_manufacturing || ', wl.line_id ';
                                                                   -- line_id
               l_select_manufacturing :=
                                  l_select_manufacturing || ', wl.line_code ';
                                                                      -- line
            END IF;

            IF g_department_visible = 'T' OR p_department_id IS NOT NULL
            THEN
               l_select_manufacturing :=
                             l_select_manufacturing || ', wro.department_id ';
                                                             -- department_id

               IF g_department_visible = 'T'
               THEN
                  l_select_manufacturing :=
                            l_select_manufacturing || ', bd.department_code ';
                                                                -- department
               END IF;
            END IF;

            IF g_source_header_visible = 'T'
            THEN
               l_select_manufacturing :=
                            l_select_manufacturing || ', we.wip_entity_name ';
                                                             -- source header
            END IF;

            l_select_manufacturing :=
                                   l_select_manufacturing || ', to_number(3) ';
                                                         -- manufacturing_type
            l_select_manufacturing :=
                              l_select_manufacturing || ', wrs.wip_entity_id ';
                                                              -- wip_entity_id
            l_from_manufacturing :=
                    l_from_manufacturing || ', wip_repetitive_schedules  wrs ';
            l_from_manufacturing :=
                  l_from_manufacturing || ', wip_requirement_operations  wro ';

            IF g_assembly_visible = 'T'
            THEN
               l_from_manufacturing :=
                      l_from_manufacturing || ', mtl_system_items_kfv msiv2 ';
            END IF;

            IF g_department_visible = 'T'
            THEN
               l_from_manufacturing :=
                              l_from_manufacturing || ', bom_departments bd ';
            END IF;

            IF g_source_header_visible = 'T'
            THEN
               l_from_manufacturing :=
                                 l_from_manufacturing || ', wip_entities we ';
            END IF;

            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and wro.wip_entity_id   = wrs.wip_entity_id ';
            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and wro.organization_id = wrs.organization_id ';
            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and wro.repetitive_schedule_id = wrs.repetitive_schedule_id ';
            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and mtrl.TXN_SOURCE_LINE_ID = wro.OPERATION_SEQ_NUM ';
            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and mtrl.inventory_item_id = wro.inventory_item_id ';
            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and mtrl.txn_source_id  = wrs.wip_entity_id ';
            l_where_manufacturing :=
                  l_where_manufacturing
               || ' and mtrl.reference_id   = wrs.repetitive_schedule_id ';

            IF g_assembly_visible = 'T'
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || '  and wri.primary_item_id = msiv2.inventory_item_id ';
               l_where_manufacturing :=
                     l_where_manufacturing
                  || '  and mtrl.organization_id = msiv2.organization_id ';
            END IF;

            IF g_source_header_visible = 'T'
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wro.wip_entity_id   = we.wip_entity_id ';
            END IF;

            -- for repetitive schedule we can't give job
            IF g_assembly_visible = 'T' OR p_assembly_id IS NOT NULL
            THEN
               l_from_manufacturing :=
                       l_from_manufacturing || ' , wip_repetitive_items wri ';
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wrs.wip_entity_id = wri.wip_entity_id ';
               l_where_manufacturing :=
                    l_where_manufacturing || ' and wrs.line_id = wri.line_id ';
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wrs.organization_id = wri.organization_id ';

               IF p_assembly_id IS NOT NULL
               THEN
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and wri.primary_item_id = :assembly_id ';
               END IF;
            END IF;

            IF p_from_start_date IS NOT NULL
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wrs.first_unit_start_date >= :from_start_date ';
            END IF;

            IF p_to_start_date IS NOT NULL
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wrs.first_unit_start_date <= :to_start_date ';
            END IF;

            IF    g_line_visible = 'T'
               OR p_from_line IS NOT NULL
               OR p_to_line IS NOT NULL
            THEN
               l_from_manufacturing :=
                                   l_from_manufacturing || ' , wip_lines wl ';
               l_where_manufacturing :=
                    l_where_manufacturing || ' and wrs.line_id = wl.line_id ';
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and wrs.organization_id = wl.organization_id ';

               IF p_from_line IS NOT NULL
               THEN
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and wl.line_code >= :from_line ';
               END IF;

               IF p_to_line IS NOT NULL
               THEN
                  l_where_manufacturing :=
                     l_where_manufacturing
                     || ' and wl.line_code <= :to_line ';
               END IF;
            END IF;

            IF g_department_visible = 'T' OR p_department_id IS NOT NULL
            THEN
               IF p_department_id IS NOT NULL
               THEN
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and wro.department_id = :dept_id ';
               END IF;

               IF g_department_visible = 'T'
               THEN
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and wro.department_id = bd.department_id(+) ';
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and wro.organization_id = bd.organization_id(+) ';
               END IF;
            END IF;
	 /* Navin INV_Convergence_Gme_Wms_TD Added condition for OPM Batch. */
         ELSIF p_manufacturing_type = '10'    /* OPM Batch */
         THEN
            IF g_assembly_visible = 'T' OR p_assembly_id IS NOT NULL
            THEN
               l_select_manufacturing := ', TO_NUMBER (NULL) '; -- Inventory item Identifier
                                                                -- for the assembly the job creates
                                                               	-- assembly_id
               IF g_assembly_visible = 'T'
               THEN
                  l_select_manufacturing :=
                        l_select_manufacturing
                     || ', NULL ';          -- assembly
               END IF;
            END IF;

            IF    g_line_visible = 'T'
               OR p_from_line IS NOT NULL
               OR p_to_line IS NOT NULL
            THEN
               l_select_manufacturing :=
                                    l_select_manufacturing || ', TO_NUMBER (NULL) ';
                                                                   -- line_id
               l_select_manufacturing :=
                                  l_select_manufacturing || ', NULL ';
                                                                      -- line
            END IF;

            IF g_department_visible = 'T' OR p_department_id IS NOT NULL
            THEN
               l_select_manufacturing :=
                             l_select_manufacturing || ', TO_NUMBER (NULL) ';
                                                             -- department_id

               IF g_department_visible = 'T'
               THEN
                  l_select_manufacturing :=
                            l_select_manufacturing || ', NULL ';
                                                                -- department
               END IF;
            END IF;

            IF    g_source_header_visible = 'T'
               OR p_from_job IS NOT NULL
               OR p_to_job IS NOT NULL
            THEN
               l_select_manufacturing :=
                            l_select_manufacturing || ', h.batch_no ';
                                                             -- source header
            END IF;

            l_select_manufacturing :=
                                   l_select_manufacturing || ', to_number(10) ';
                                                         -- manufacturing_type
            l_select_manufacturing :=
                              l_select_manufacturing || ', h.batch_id ';
                                                              -- wip_entity_id

            IF g_assembly_visible = 'T'
            THEN
                 l_select_manufacturing :=
                              l_select_manufacturing || ', msiv2.concatenated_segments ';
                                                              -- product
            END IF;

	    l_from_manufacturing :=
                            l_from_manufacturing || ', gme_batch_header h ';

            IF g_assembly_visible = 'T'
            THEN
               l_from_manufacturing :=
                      l_from_manufacturing || ', mtl_system_items_kfv msiv2 ';
               l_from_manufacturing :=
                      l_from_manufacturing || ', gmd_recipe_validity_rules val ';
            END IF;

            l_where_manufacturing :=
                  l_where_manufacturing
               || '  and mtrl.txn_source_id = h.batch_id ';


            IF g_assembly_visible = 'T'
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || '  and h.recipe_validity_rule_id = val.recipe_validity_rule_id ';
	       /* Bug#5020669 svgonugu added val.organization_id IS NULL condition to consider validity rules
	          which are for all orgs */
               l_where_manufacturing :=
                     l_where_manufacturing
                  || '  and (val.organization_id IS NULL OR h.organization_id = val.organization_id) ';
               l_where_manufacturing :=
                     l_where_manufacturing
                  || '  and val.inventory_item_id = msiv2.inventory_item_id ';
	       /* Bug#5020669 svgonugu added val.organization_id IS NULL condition to consider validity rules
	          which are for all orgs */
               l_where_manufacturing :=
                     l_where_manufacturing
                  || '  and (val.organization_id IS NULL OR val.organization_id = msiv2.organization_id) ';
	       /* Bug#5300219 nsinghi. Added this where condition. */
               l_where_manufacturing :=
                     l_where_manufacturing
                  || '  and h.organization_id = msiv2.organization_id ';
            END IF;

            IF    g_source_header_visible = 'T'
               OR p_from_job IS NOT NULL
               OR p_to_job IS NOT NULL
            THEN

	       IF p_from_job IS NOT NULL
               THEN
	          --Siva added lpad to fetch the batches with the given range
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and lpad(h.batch_no,32,''0'') >= lpad(:from_job,32,''0'') ';
               END IF;

               IF p_to_job IS NOT NULL
               THEN
	          --Siva added lpad to fetch the batches with the given range
                  l_where_manufacturing :=
                        l_where_manufacturing
                     || ' and lpad(h.batch_no,32,''0'') <= lpad(:to_job,32,''0'') ';
               END IF;
            END IF;

            -- Navin Added for Primary Product filter:
            IF p_assembly_id IS NOT NULL
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and val.inventory_item_id = :assembly_id ';	-- p_manufacturing_type = '10'  Batch
	    END IF;

	    IF p_from_start_date IS NOT NULL
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and h.actual_start_date >= :from_start_date ';
            END IF;

            IF p_to_start_date IS NOT NULL
            THEN
               l_where_manufacturing :=
                     l_where_manufacturing
                  || ' and h.actual_start_date <= :to_start_date ';
            END IF;
         ELSIF p_manufacturing_type IS NULL
         THEN                                                   --type is null
            RETURN;
         END IF;                                          --manufacturing_type

         -- Execute the Manufacturing query
	 IF p_summary_mode = 1 THEN
		l_select_manufacturing := NULL; -- for summary mode we wont need the manufacturing related data
		IF i = 1 THEN
			l_where_manufacturing := l_where_manufacturing || ' GROUP BY mmtt.wms_task_type ';
		ELSE
			l_where_manufacturing := l_where_manufacturing || ' GROUP BY wdt_task_type ';
		END IF;
	 END IF;
         -- Concatenate the different sections of the query
         l_query :=
               l_insert_query
            || l_select_generic
            || l_select_manufacturing
            || l_from_generic
            || l_from_manufacturing
            || l_where_generic
            || l_where_manufacturing;
         -- Parse, Bind and Execute the dynamic query
         debug('l_query: ' || l_query,'query_manufacturing_tasks');
         l_query_handle := DBMS_SQL.open_cursor;
         DBMS_SQL.parse (l_query_handle, l_query, DBMS_SQL.native);

         --generic bind variables
         IF p_organization_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'org_id',
                                    p_organization_id
                                   );
         END IF;

         IF p_subinventory_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'sub_code',
                                    p_subinventory_code
                                   );
         END IF;

         IF p_locator_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'loc_id', p_locator_id);
         END IF;

         IF p_to_subinventory_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_sub_code',
                                    p_to_subinventory_code
                                   );
         END IF;

         IF p_to_locator_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_loc_id',
                                    p_to_locator_id
                                   );
         END IF;

         IF p_inventory_item_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_id',
                                    p_inventory_item_id
                                   );
         END IF;

         -- R12 : Additional Query Criteria using item type
         IF p_item_type_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_type_code',
                                    p_item_type_code
                                   );
         END IF;


         IF p_category_set_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'category_set_id',
                                    p_category_set_id
                                   );
         END IF;

         IF p_item_category_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_category_id',
                                    p_item_category_id
                                   );
         END IF;

         IF p_person_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'person_id', p_person_id);
         END IF;

         IF p_person_resource_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'person_resource_id',
                                    p_person_resource_id
                                   );
         END IF;

         IF p_equipment_type_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'equipment_type_id',
                                    p_equipment_type_id
                                   );
         END IF;

         IF p_machine_resource_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'machine_resource_id',
                                    p_machine_resource_id
                                   );
         END IF;

         IF p_machine_instance IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'machine_instance',
                                    p_machine_instance
                                   );
         END IF;

         IF p_user_task_type_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'user_task_type_id',
                                    p_user_task_type_id
                                   );
         END IF;

         IF p_from_task_quantity IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_task_quantity',
                                    p_from_task_quantity
                                   );
         END IF;

         IF p_to_task_quantity IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_task_quantity',
                                    p_to_task_quantity
                                   );
         END IF;

         IF p_from_task_priority IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_task_priority',
                                    p_from_task_priority
                                   );
         END IF;

         IF p_to_task_priority IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_task_priority',
                                    p_to_task_priority
                                   );
         END IF;

         IF p_from_creation_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_creation_date',
                                    p_from_creation_date
                                   );
         END IF;

         IF p_to_creation_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_creation_date',
                                    p_to_creation_date
                                   );
         END IF;

         -- R12: Additional Query criteria using age of the task
         IF p_age_uom_code IS NOT NULL
         THEN

            IF p_age_min IS NOT NULL
            THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'age_min',
                                    p_age_min
                                   );
            END IF;

            IF p_age_max IS NOT NULL
            THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'age_max',
                                    p_age_max
                                   );

            END IF;
         END IF;

         -- Manufacturing query specific bind variables
         IF p_from_job IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'from_job', p_from_job);
         END IF;

         IF p_to_job IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'to_job', p_to_job);
         END IF;

         IF p_assembly_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'assembly_id',
                                    p_assembly_id
                                   );
         END IF;

         IF p_from_start_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_start_date',
                                    p_from_start_date
                                   );
         END IF;

         IF p_to_start_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_start_date',
                                    p_to_start_date
                                   );
         END IF;

         IF p_from_line IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'from_line', p_from_line);
         END IF;

         IF p_to_line IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'to_line', p_to_line);
         END IF;

         IF p_department_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'dept_id',
                                    p_department_id
                                   );
         END IF;

	 IF p_summary_mode = 1 THEN
		DBMS_SQL.DEFINE_COLUMN(l_query_handle, 1, l_wms_task_type);
		DBMS_SQL.DEFINE_COLUMN(l_query_handle, 2, l_task_count);
	 END IF;

         --mfg_query
         l_query_count := DBMS_SQL.EXECUTE (l_query_handle);

	 IF p_summary_mode = 1 THEN -- fetch the rows and put them into the global tables
		LOOP
		       IF DBMS_SQL.FETCH_ROWS(l_query_handle)>0 THEN
			  DBMS_SQL.COLUMN_VALUE(l_query_handle, 1, l_wms_task_type);
			  DBMS_SQL.COLUMN_VALUE(l_query_handle, 2, l_task_count);
			  g_wms_task_summary_tbl(l_wms_task_type).wms_task_type := l_wms_task_type;
			  g_wms_task_summary_tbl(l_wms_task_type).task_count := g_wms_task_summary_tbl(l_wms_task_type).task_count + l_task_count;
			  IF l_debug = 1 then
			       debug('Task Type :' || g_wms_task_summary_tbl(l_wms_task_type).wms_task_type, 'query_manufacturing_tasks');
			       debug('TaskCount :' || g_wms_task_summary_tbl(l_wms_task_type).task_count, 'query_manufacturing_tasks');
			  END IF;
		       ELSE
			  EXIT; -- no more rows returned from dynamic SQL
		       END IF;
		END LOOP;
	 END IF;
         g_record_count := g_record_count + l_query_count;
    DBMS_SQL.close_cursor(l_query_handle);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN -- Bug 4150145
	IF dbms_sql.is_open(l_query_handle) THEN
	   dbms_sql.close_cursor(l_query_handle);
	END IF;
        DEBUG (SQLERRM, 'Task_planning.query_manufacturing_tasks');
   END query_manufacturing_tasks;

   PROCEDURE query_cycle_count_tasks (
      p_add                    BOOLEAN DEFAULT FALSE,
      p_organization_id        NUMBER DEFAULT NULL,
      p_subinventory_code      VARCHAR2 DEFAULT NULL,
      p_locator_id             NUMBER DEFAULT NULL,
      p_to_subinventory_code   VARCHAR2 DEFAULT NULL,
      p_to_locator_id          NUMBER DEFAULT NULL,
      p_inventory_item_id      NUMBER DEFAULT NULL,
      p_category_set_id        NUMBER DEFAULT NULL,
      p_item_category_id       NUMBER DEFAULT NULL,
      p_person_id              NUMBER DEFAULT NULL,
      p_person_resource_id     NUMBER DEFAULT NULL,
      p_equipment_type_id      NUMBER DEFAULT NULL,
      p_machine_resource_id    NUMBER DEFAULT NULL,
      p_machine_instance       VARCHAR2 DEFAULT NULL,
      p_user_task_type_id      NUMBER DEFAULT NULL,
      p_from_task_quantity     NUMBER DEFAULT NULL,
      p_to_task_quantity       NUMBER DEFAULT NULL,
      p_from_task_priority     NUMBER DEFAULT NULL,
      p_to_task_priority       NUMBER DEFAULT NULL,
      p_from_creation_date     DATE DEFAULT NULL,
      p_to_creation_date       DATE DEFAULT NULL,
      p_cycle_count_name       VARCHAR2 DEFAULT NULL,
      p_is_pending             BOOLEAN DEFAULT FALSE,
      p_is_queued              BOOLEAN DEFAULT FALSE,
      p_is_dispatched          BOOLEAN DEFAULT FALSE,
      p_is_active              BOOLEAN DEFAULT FALSE,
      p_is_completed           BOOLEAN DEFAULT FALSE,
      -- R12 : Additional Query Criteria
      p_item_type_code                            VARCHAR2 DEFAULT NULL,
   	p_age_uom_code                              VARCHAR2 DEFAULT NULL,
   	p_age_min                                   NUMBER DEFAULT NULL,
   	p_age_max                                   NUMBER DEFAULT NULL,
	p_summary_mode		NUMBER DEFAULT 0
      -- R12 : Additional Query Criteria
   )
   IS
      l_join_wdt       BOOLEAN;
      l_select_cc      VARCHAR2 (4000);
      l_insert_cc      VARCHAR2 (4000);
      l_from_cc        VARCHAR2 (2000);
      l_where_cc       VARCHAR2 (4000);
      l_query          VARCHAR2 (10000);
      l_query_handle   NUMBER;                  -- Handle for the dynamic sql
      l_query_count    NUMBER;
      l_loop_start     NUMBER;
      l_loop_end       NUMBER;
      l_wms_task_type	NUMBER; -- for bug 5129375
      l_task_count	NUMBER;
      --R12: Additional Query criteria
      --Age UOM conversion factor
      n                 VARCHAR2 (10);
      l_debug                    NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
   BEGIN
      -- Cycle tasks currently cannot have priorities, quantities or dest sub/loc. If user wants to
      -- query up tasks with certain priorities, quantities or dest sub/loc, we should not
      -- query cycle count tasks.
      IF    p_from_task_priority IS NOT NULL
         OR p_to_task_priority IS NOT NULL
         OR p_from_task_quantity IS NOT NULL
         OR p_to_task_quantity IS NOT NULL
         OR p_to_subinventory_code IS NOT NULL
         OR p_to_locator_id IS NOT NULL
      THEN
         RETURN;
      END IF;

      IF p_is_pending OR p_is_queued OR p_is_dispatched OR p_is_active
      THEN
         l_loop_start := 1;
      ELSE
         l_loop_start := 2;
      END IF;

      IF p_is_completed
      THEN
         l_loop_end := 2;
      ELSE
         l_loop_end := 1;
      END IF;

      FOR i IN l_loop_start .. l_loop_end
      LOOP
         l_insert_cc := NULL;
         l_select_cc := NULL;
         l_from_cc := NULL;
         l_where_cc := NULL;

         IF i = 1
         THEN
            IF     (p_is_pending)
               AND NOT (p_is_queued OR p_is_dispatched OR p_is_active)
            THEN
               -- Query records present only in MMTT
               l_join_wdt := FALSE;
            ELSIF     p_is_pending
                  AND (p_is_queued OR p_is_dispatched OR p_is_active)
            THEN
               -- Query records present only in MMTT as well as those in both MMTT and WDT
               l_join_wdt := TRUE;
            ELSIF     NOT p_is_pending
                  AND (p_is_queued OR p_is_dispatched OR p_is_active)
            THEN
               -- Query records present both in MMTT and WDT
               l_join_wdt := TRUE;
            END IF;
         ELSIF i = 2
         THEN                                               -- Completed tasks
            l_join_wdt := TRUE;
         END IF;

         l_insert_cc := 'INSERT INTO wms_waveplan_tasks_temp( ';
         l_insert_cc := l_insert_cc || 'transaction_temp_id ';
         l_insert_cc := l_insert_cc || ', inventory_item_id ';
         l_insert_cc := l_insert_cc || ', item ';
	 l_insert_cc := l_insert_cc || ', item_description ';--Added for Bug 8540985
         l_insert_cc := l_insert_cc || ', organization_id ';
         l_insert_cc := l_insert_cc || ', revision ';
         l_insert_cc := l_insert_cc || ', subinventory ';
         l_insert_cc := l_insert_cc || ', locator_id ';
         l_insert_cc := l_insert_cc || ', locator ';
         l_insert_cc := l_insert_cc || ', status_id ';
         l_insert_cc := l_insert_cc || ', status_id_original ';
         l_insert_cc := l_insert_cc || ', status ';
         l_insert_cc := l_insert_cc || ', transaction_action_id ';
         l_insert_cc := l_insert_cc || ', transaction_source_type_id ';

         IF g_txn_source_type_visible = 'T'
         THEN
            l_insert_cc := l_insert_cc || ', transaction_source_type ';
         END IF;

         l_insert_cc := l_insert_cc || ', user_task_type_id ';

         IF g_user_task_type_visible = 'T'
         THEN
            l_insert_cc := l_insert_cc || ', user_task_type ';
         END IF;

         l_insert_cc := l_insert_cc || ', mmtt_last_update_date ';
         l_insert_cc := l_insert_cc || ', mmtt_last_updated_by ';
         l_insert_cc := l_insert_cc || ', priority ';
         l_insert_cc := l_insert_cc || ', priority_original ';
         l_insert_cc := l_insert_cc || ', task_type_id ';
         l_insert_cc := l_insert_cc || ', task_type ';
         l_insert_cc := l_insert_cc || ', creation_time ';

         IF l_join_wdt
         THEN
            l_insert_cc := l_insert_cc || ', task_id ';
            l_insert_cc := l_insert_cc || ', person_id ';
            l_insert_cc := l_insert_cc || ', person_id_original ';

            IF g_person_visible = 'T'
            THEN
               l_insert_cc := l_insert_cc || ', person ';
            END IF;

            l_insert_cc := l_insert_cc || ', effective_start_date ';
            l_insert_cc := l_insert_cc || ', effective_end_date ';
            l_insert_cc := l_insert_cc || ', person_resource_id ';

            IF g_person_resource_visible = 'T'
            THEN
               l_insert_cc := l_insert_cc || ', person_resource_code ';
            END IF;

            l_insert_cc := l_insert_cc || ', machine_resource_id ';

            IF g_machine_resource_visible = 'T'
            THEN
               l_insert_cc := l_insert_cc || ', machine_resource_code ';
            END IF;

            l_insert_cc := l_insert_cc || ', equipment_instance ';
            l_insert_cc := l_insert_cc || ', dispatched_time ';
            l_insert_cc := l_insert_cc || ', loaded_time ';
            l_insert_cc := l_insert_cc || ', drop_off_time ';
            l_insert_cc := l_insert_cc || ', wdt_last_update_date ';
            l_insert_cc := l_insert_cc || ', wdt_last_updated_by ';
         END IF;

         l_insert_cc := l_insert_cc || ', is_modified ';

         IF g_source_header_visible = 'T' OR p_cycle_count_name IS NOT NULL
         THEN
            l_insert_cc := l_insert_cc || ', source_header ';
         END IF;

         l_insert_cc := l_insert_cc || ') ';
         -- Build the generic select section of the query
         l_select_cc := 'SELECT ';


         l_select_cc := l_select_cc || 'mcce.cycle_count_entry_id, ';
                                                         --transaction_temp_id
         l_select_cc := l_select_cc || 'mcce.inventory_item_id, ';
                                                              --inventory_item_id
         l_select_cc := l_select_cc || 'msiv.concatenated_segments, ';  --item

	 l_select_cc := l_select_cc || 'msiv.description, '; -- Added for Bug 8540985

         l_select_cc := l_select_cc || 'mcce.organization_id, ';
                                                             --organization_id
         l_select_cc := l_select_cc || 'mcce.revision, ';           --revision

         l_select_cc := l_select_cc || 'mcce.subinventory, ';   --subinventory

         l_select_cc := l_select_cc || 'mcce.locator_id, ';       --locator_id

         --locator
         l_select_cc :=
               l_select_cc
            || 'decode(milv.segment19, null, milv.concatenated_segments, null), ';

         IF i = 1
         THEN
            IF l_join_wdt
            THEN
               --status_id
           l_select_cc := l_select_cc || 'decode(wdt.status, null, 1, wdt.status), ';

               --status_id_original
           l_select_cc := l_select_cc || 'decode(wdt.status, null, 1, wdt.status), ';

               --status
               l_select_cc :=
                     l_select_cc
                  || 'decode(decode(wdt.status, null, 1, wdt.status),'
                  || '1, '''
                  || g_status_codes (1)
                  || ''', 2, '''
                  || g_status_codes (2)
                  || ''', 3, '''
                  || g_status_codes (3)
                  || ''', 4, '''
                  || g_status_codes (4)
                  || ''', 5, '''
                  || g_status_codes (5)
                  || ''', 6, '''
                  || g_status_codes (6)
                  || ''', 7, '''
                  || g_status_codes (7)
                  || ''', 8, '''
                  || g_status_codes (8)
                  || ''', '
                  || '9, '''
                  || g_status_codes (9)
        || '''), ';
            ELSE
               --status_id
               l_select_cc := l_select_cc || '1, ';
               --status_id_original
               l_select_cc := l_select_cc || '1, ';
               --status
               l_select_cc :=
                           l_select_cc || '''' || g_status_codes (1)
                           || ''', ';
            END IF;
         ELSIF i = 2
         THEN
            l_select_cc := l_select_cc || '6, ';                  --status_id
            l_select_cc := l_select_cc || '6, ';         --status_id_original
            l_select_cc := l_select_cc || '''' || g_status_codes (6)
                           || ''', ';                                --status
         END IF;

         l_select_cc := l_select_cc || '4, ';          --transaction_action_id
         l_select_cc := l_select_cc || '9, ';     --transaction_source_type_id

         IF g_txn_source_type_visible = 'T'
         THEN
            l_select_cc :=
         l_select_cc || 'mtst.transaction_source_type_name, ';

         END IF;

         l_select_cc := l_select_cc || 'mcce.standard_operation_id, ';
                                                           --user_task_type_id

         IF g_user_task_type_visible = 'T'
         THEN
            l_select_cc := l_select_cc || 'bso.operation_code, ';
                                                             --user_task_type
         END IF;

         l_select_cc := l_select_cc || 'mcce.last_update_date, ';
                                                       --mmtt_last_update_date
         l_select_cc := l_select_cc || 'mcce.last_updated_by, ';
                                                        --mmtt_last_updated_by
         l_select_cc := l_select_cc || 'mcce.task_priority, ';      --priority

         l_select_cc := l_select_cc || 'mcce.task_priority, ';
                                                           --priority_original
         l_select_cc := l_select_cc || '3, ';                   --task_type_id

         l_select_cc := l_select_cc || '''' || g_task_types (3) || ''', ';
                                                                   --task_type
         l_select_cc := l_select_cc || 'mcce.creation_date, '; --creation_time


         IF l_join_wdt
         THEN
            l_select_cc := l_select_cc || 'wdt.task_id, ';          --task_id

            l_select_cc := l_select_cc || 'wdt.person_id, ';      --person_id

            l_select_cc := l_select_cc || 'wdt.person_id, ';
                                                     --person_id_original

            IF g_person_visible = 'T'
            THEN
               l_select_cc := l_select_cc || 'pap.full_name, ';   --person_id

            END IF;

        l_select_cc := l_select_cc || 'wdt.effective_start_date, ';
                                                        --effective_start_date

        l_select_cc := l_select_cc || 'wdt.effective_end_date, ';
                                                          --effective_end_date

        l_select_cc := l_select_cc || 'wdt.person_resource_id, ';
                                                          --person_resource_id

            IF g_person_resource_visible = 'T'
            THEN
               l_select_cc := l_select_cc || 'br1.resource_code, ';
          --person_resource_code
            END IF;

            l_select_cc := l_select_cc || 'wdt.machine_resource_id, ';
                                                         --machine_resource_id

            IF g_machine_resource_visible = 'T'
            THEN
               l_select_cc := l_select_cc || 'br2.resource_code, ';
                                                      --machine_resource_code
            END IF;

            l_select_cc := l_select_cc || 'wdt.equipment_instance, ';
                                                          --equipment_instance
            l_select_cc := l_select_cc || 'wdt.dispatched_time, ';
                                                             --dispatched_time
            l_select_cc := l_select_cc || 'wdt.loaded_time, ';   --loaded_time

	    l_select_cc := l_select_cc || 'wdt.drop_off_time, ';
                                                               --drop_off_time
            l_select_cc := l_select_cc || 'wdt.last_update_date, ';
                                                        --wdt_last_update_date
            l_select_cc := l_select_cc || 'wdt.last_updated_by, ';
                                                         --wdt_last_updated_by
    END IF;

         l_select_cc := l_select_cc || '''N'' ';                -- is_modified

         IF g_source_header_visible = 'T' OR p_cycle_count_name IS NOT NULL
         THEN
            l_select_cc := l_select_cc || ', mcch.cycle_count_header_name ';
                                                              --source header
    END IF;

         -- Build the generic from section of the query
         l_from_cc := ' FROM ';
         l_from_cc := l_from_cc || ' mtl_system_items_kfv msiv ';
         l_from_cc := l_from_cc || ', mtl_item_locations_kfv milv ';
         l_from_cc := l_from_cc || ', mtl_cycle_count_entries mcce ';

         /*Bug 3856227 -Added the table mtl_cycle_count_headers in the from clause
                         if the task is of status pending, queued, dispatched, active
                         or if the cycle count name is not null.*/
          IF i=1 THEN
           l_from_cc := l_from_cc || ', mtl_cycle_count_headers mcch ' ;
          ELSIF i=2 THEN
           IF g_source_header_visible = 'T' OR p_cycle_count_name IS NOT NULL THEN
              l_from_cc := l_from_cc || ', mtl_cycle_count_headers mcch ' ;
           END IF;
          END IF;
          -- End of fix for Bug 3856227

         IF l_join_wdt
         THEN
            IF i = 1
            THEN
               l_from_cc := l_from_cc || ', wms_dispatched_tasks wdt ';
            ELSIF i = 2
            THEN
               l_from_cc :=
                           l_from_cc || ', wms_dispatched_tasks_history wdt ';
            END IF;
         END IF;

         IF p_item_category_id IS NOT NULL OR p_category_set_id IS NOT NULL
         THEN
            l_from_cc := l_from_cc || ', mtl_item_categories mic ';
         END IF;

         IF g_user_task_type_visible = 'T'
         THEN
            l_from_cc := l_from_cc || ', bom_standard_operations bso ';
         END IF;

         IF g_txn_source_type_visible = 'T'
         THEN
            l_from_cc := l_from_cc || ', mtl_txn_source_types mtst ';
         END IF;

         IF    (i = 1 AND (p_is_queued OR p_is_dispatched OR p_is_active))
            OR (i = 2 AND p_is_completed)
         THEN
            IF g_person_resource_visible = 'T'
            THEN
               l_from_cc := l_from_cc || ', bom_resources br1 ';
            END IF;

            IF g_machine_resource_visible = 'T'
            THEN
               l_from_cc := l_from_cc || ', bom_resources br2 ';
            END IF;

            IF g_person_visible = 'T'
            THEN
               l_from_cc := l_from_cc || ', per_all_people_f pap ';
            END IF;
         END IF;

         -- Build the generic where section of the query
         IF p_add
         THEN
            l_where_cc :=
                   'WHERE NOT exists (SELECT 1 FROM wms_waveplan_tasks_temp ';
            l_where_cc :=
                  l_where_cc
               || 'WHERE transaction_temp_id = mcce.cycle_count_entry_id ';
            l_where_cc := l_where_cc || 'AND task_type_id = 3) ';
         ELSE
            l_where_cc := 'WHERE 1=1 ';
	     /* 8522232 added the code to use a subquery approach
             so that when selecting min(mcce.cycle_count_entry_id)all the columns need not be
             in gruop by clause of outer query which is causing many issues.*/
            l_where_cc := l_where_cc || ' and mcce.cycle_count_entry_id IN
            (SELECT MIN(mcce.cycle_count_entry_id) from mtl_cycle_count_entries mcce  , mtl_cycle_count_headers mcch
              WHERE mcce.organization_id                    = :org_id
              and  mcce.cycle_count_header_id              = mcch.cycle_count_header_id ' ;
              IF i = 1 THEN
           -- Bug #3732568. Added Rejected status counts (4)  in the NOT IN list.
            l_where_cc := l_where_cc || 'AND mcce.entry_status_code not in (2,4, 5) '; -- 3620782

          -- Bug 3856227-Added the following for pending, queued, active, dispatched tasks considering the disable date of the cycle count .
            l_where_cc := l_where_cc || 'AND nvl(mcch.disable_date,sysdate+1)> sysdate ' ;
            -- End of fix for Bug 3856227.
             ELSIF i = 2 THEN
            -- Bug #3732568. Added Rejected status counts (4) in the NOT IN list.
            l_where_cc := l_where_cc || 'AND mcce.entry_status_code in (2,4, 5) ';
             END IF;

           l_where_cc := l_where_cc || 'GROUP BY  mcce.organization_id ,
           mcce.subinventory,
           mcce.locator_id,
           mcce.inventory_item_id,
           mcce.revision,
	   mcce.cycle_count_header_id';
	      IF i = 2 THEN  --Added this to show all completed tasks instead of min(mcce.cycle_count_entry_id)
	        l_where_cc := l_where_cc || ',mcce.cycle_count_entry_id';
	      END IF;
	      l_where_cc := l_where_cc ||' )' ;

         END IF;

         IF i = 1
         THEN
            IF     p_is_pending
               AND NOT (p_is_queued OR p_is_dispatched OR p_is_active)
            THEN
               -- Query records present only in MCCE
               IF p_is_pending
               THEN
                  l_where_cc :=
                        l_where_cc
                     || 'AND NOT EXISTS (SELECT 1 FROM wms_dispatched_tasks ';
                  l_where_cc :=
                        l_where_cc
                     || '                WHERE transaction_temp_id = mcce.cycle_count_entry_id) ';
               END IF;
            ELSIF     p_is_pending
                  AND (p_is_queued OR p_is_dispatched OR p_is_active)
            THEN
               -- Query records present only in MCCE as well as those in both MCCE and WDT
               l_where_cc :=
                     l_where_cc
                  || 'AND mcce.cycle_count_entry_id = wdt.transaction_temp_id(+) ';
               l_where_cc :=
                     l_where_cc
                  || 'AND decode(wdt.status, null, 1, wdt.status) in ( ';

               IF p_is_pending
               THEN
                  l_where_cc := l_where_cc || '1';
               END IF;

               IF p_is_queued
               THEN
                  IF p_is_pending
                  THEN
                     l_where_cc := l_where_cc || ', 2';
                  ELSE
                     l_where_cc := l_where_cc || '2';
                  END IF;
               END IF;

               IF p_is_dispatched
               THEN
                  IF p_is_pending OR p_is_queued
                  THEN
                     l_where_cc := l_where_cc || ', 3';
                  ELSE
                     l_where_cc := l_where_cc || '3';
                  END IF;
               END IF;

               IF p_is_active
               THEN
                  IF p_is_pending OR p_is_queued OR p_is_dispatched
                  THEN
                     l_where_cc := l_where_cc || ', 9';
                  ELSE
                     l_where_cc := l_where_cc || '9';
                  END IF;
               END IF;

               l_where_cc := l_where_cc || ') ';

               IF g_person_resource_visible = 'T'
               THEN
                  l_where_cc :=
                        l_where_cc
                     || 'AND wdt.person_resource_id = br1.resource_id(+) ';
               END IF;

               IF g_machine_resource_visible = 'T'
               THEN
                  l_where_cc :=
                        l_where_cc
                     || 'AND wdt.machine_resource_id = br2.resource_id(+) ';
               END IF;

               IF g_person_visible = 'T'
               THEN
                  l_where_cc :=
                        l_where_cc || 'AND wdt.person_id = pap.person_id(+) ';
                  l_where_cc :=
                        l_where_cc
                     || 'AND wdt.effective_start_date >= pap.effective_start_date(+) ';
                  l_where_cc :=
                        l_where_cc
                     || 'AND wdt.effective_end_date <= pap.effective_end_date(+) ';
               END IF;
            ELSIF     NOT p_is_pending
                  AND (p_is_queued OR p_is_dispatched OR p_is_active)
            THEN
               -- Query records present both in MMTT and WDT
               l_where_cc :=
                     l_where_cc
                  || 'AND mcce.cycle_count_entry_id = wdt.transaction_temp_id ';
               l_where_cc := l_where_cc || 'AND wdt.task_type = 3 ';
                                                           -- cycle count task
               l_where_cc := l_where_cc || 'AND wdt.status in ( ';

               IF p_is_queued
               THEN
                  l_where_cc := l_where_cc || '2';
               END IF;

               IF p_is_dispatched
               THEN
                  IF p_is_queued
                  THEN
                     l_where_cc := l_where_cc || ', 3';
                  ELSE
                     l_where_cc := l_where_cc || '3';
                  END IF;
               END IF;

               IF p_is_active
               THEN
                  IF p_is_queued OR p_is_dispatched
                  THEN
                     l_where_cc := l_where_cc || ', 9';
                  ELSE
                     l_where_cc := l_where_cc || '9';
                  END IF;
               END IF;

               l_where_cc := l_where_cc || ') ';

               IF g_person_resource_visible = 'T'
               THEN
                  l_where_cc :=
                        l_where_cc
                     || 'AND wdt.person_resource_id = br1.resource_id ';
               END IF;

               IF g_machine_resource_visible = 'T'
               THEN
                  l_where_cc :=
                        l_where_cc
                     || 'AND wdt.machine_resource_id = br2.resource_id(+) ';
               END IF;

               IF g_person_visible = 'T'
               THEN
                  l_where_cc :=
                           l_where_cc || 'AND wdt.person_id = pap.person_id ';
                  l_where_cc :=
                        l_where_cc
                     || 'AND wdt.effective_start_date >= pap.effective_start_date ';
                  l_where_cc :=
                        l_where_cc
                     || 'AND wdt.effective_end_date <= pap.effective_end_date ';
               END IF;
            END IF;
         ELSIF i = 2
         THEN
            l_where_cc :=
                  l_where_cc
               || 'AND mcce.cycle_count_entry_id = wdt.transaction_id ';
            l_where_cc :=
                  l_where_cc
               || 'AND wdt.task_type = 3 ';

            IF g_person_resource_visible = 'T'
            THEN
               l_where_cc :=
                     l_where_cc
                  || 'AND wdt.person_resource_id = br1.resource_id ';
            END IF;

            IF g_machine_resource_visible = 'T'
            THEN
               l_where_cc :=
                     l_where_cc
                  || 'AND wdt.machine_resource_id = br2.resource_id(+) ';
            END IF;

            IF g_person_visible = 'T'
            THEN
               l_where_cc :=
                           l_where_cc || 'AND wdt.person_id = pap.person_id ';
               l_where_cc :=
                     l_where_cc
                  || 'AND wdt.effective_start_date >= pap.effective_start_date ';
               l_where_cc :=
                     l_where_cc
                  || 'AND wdt.effective_end_date <= pap.effective_end_date ';
            END IF;
         END IF;

        l_where_cc :=
             l_where_cc || 'AND mcce.cycle_count_header_id = mcch.cycle_count_header_id ';


         l_where_cc :=
              l_where_cc || 'AND mcce.organization_id = msiv.organization_id ';
         l_where_cc :=
               l_where_cc
            || 'AND mcce.inventory_item_id = msiv.inventory_item_id ';
         l_where_cc :=
            l_where_cc
            || 'AND mcce.organization_id = milv.organization_id(+) ';
         l_where_cc :=
               l_where_cc
            || 'AND mcce.locator_id = milv.inventory_location_id(+) ';

         IF g_txn_source_type_visible = 'T'
         THEN
            l_where_cc :=
                     l_where_cc || 'AND mtst.transaction_source_type_id = 9 ';
         END IF;

         IF g_user_task_type_visible = 'T'
         THEN
            l_where_cc :=
                  l_where_cc
               || 'AND mcce.standard_operation_id = bso.standard_operation_id(+) ';
         END IF;

         IF p_organization_id IS NOT NULL
         THEN
            l_where_cc := l_where_cc || 'AND mcce.organization_id = :org_id ';
         END IF;

         IF p_subinventory_code IS NOT NULL
         THEN
            l_where_cc :=
                     --l_where_cc || 'AND mcce.subinventory_code = :sub_code ';
		     --Bug 6688574 :Column in mcce is subinventory.
 		       l_where_cc || 'AND mcce.subinventory = :sub_code ';
         END IF;

         IF p_locator_id IS NOT NULL
         THEN
            l_where_cc := l_where_cc || 'AND mcce.locator_id = :loc_id ';
         END IF;

         IF p_inventory_item_id IS NOT NULL
         THEN
            l_where_cc :=
                       l_where_cc || 'AND mcce.inventory_item_id = :item_id ';
         END IF;

         -- R12 : Additional Query Criteria using item type
         IF p_item_type_code IS NOT NULL
         THEN
            l_where_cc :=
                  l_where_cc || 'AND msiv.item_type = :item_type_code ';
         END IF;

         IF p_category_set_id IS NOT NULL
         THEN
            l_where_cc :=
                  l_where_cc || 'AND mic.category_set_id = :category_set_id ';
         END IF;

         IF p_item_category_id IS NOT NULL
         THEN
            l_where_cc :=
               l_where_cc
               || 'AND mcce.organization_id = mic.organization_id ';
            l_where_cc :=
                  l_where_cc
               || 'AND mcce.inventory_item_id = mic.inventory_item_id ';
            l_where_cc :=
                      l_where_cc || 'AND mic.category_id = :item_category_id ';
         END IF;

         IF p_person_id IS NOT NULL
         THEN
            l_where_cc := l_where_cc || 'AND wdt.person_id = :person_id ';
         END IF;

         IF p_person_resource_id IS NOT NULL
         THEN
            l_where_cc :=
                  l_where_cc
               || 'AND wdt.person_resource_id = :person_resource_id ';
         END IF;

         IF p_equipment_type_id IS NOT NULL
         THEN
            l_where_cc :=
                   l_where_cc || 'AND wdt.equipment_id = :equipment_type_id ';
         END IF;

         IF p_machine_resource_id IS NOT NULL
         THEN
            l_where_cc :=
                  l_where_cc
               || 'AND wdt.machine_resource_id = :machine_resource_id ';
         END IF;

         IF p_machine_instance IS NOT NULL
         THEN
            l_where_cc :=
               l_where_cc
               || 'AND wdt.equipment_instance = :machine_instance ';
         END IF;

         IF p_user_task_type_id IS NOT NULL
         THEN
            l_where_cc :=
                  l_where_cc
               || 'AND mcce.standard_operation_id = :user_task_type_id ';
         END IF;

         IF p_from_task_priority IS NOT NULL
         THEN
            l_where_cc :=
               l_where_cc || 'AND mcce.task_priority >= :from_task_priority ';
         END IF;

         IF p_to_task_priority IS NOT NULL
         THEN
            l_where_cc :=
                 l_where_cc || 'AND mcce.task_priority <= :to_task_priority ';
         END IF;

         IF p_from_creation_date IS NOT NULL
         THEN
            l_where_cc :=
               l_where_cc || 'AND mcce.creation_date >= :from_creation_date ';
         END IF;

         IF p_to_creation_date IS NOT NULL
         THEN
            l_where_cc :=
                 l_where_cc || 'AND mcce.creation_date <= :to_creation_date ';
         END IF;

         -- R12: Additional Query criteria using age of the task
         IF p_age_uom_code IS NOT NULL
         THEN

            IF    p_age_uom_code = 2 THEN  -- Minutes
               n := '*(24 * 60)';
            ELSIF p_age_uom_code = 3 THEN  -- Hours
               n := '*(24)';
            ELSIF p_age_uom_code = 4 THEN  -- Days
               n := '*(1)';
            ELSIF p_age_uom_code = 5 THEN  -- Weeks
               n := '/(7)';
            ELSIF p_age_uom_code = 6 THEN  -- Months
               n := '/(7 * 31)';
            END IF;

            IF p_age_min IS NOT NULL
            THEN
               l_where_cc :=
                     l_where_cc
                  || 'AND (sysdate - mcce.creation_date)'||n||' >= :age_min ';
            END IF;

            IF p_age_max IS NOT NULL
            THEN
               l_where_cc :=
                     l_where_cc
                  || 'AND (sysdate - mcce.creation_date)'||n||' <= :age_max ';
            END IF;
         END IF;


         IF g_source_header_visible = 'T' OR p_cycle_count_name IS NOT NULL
         THEN
            /* Bug 3856227 - Commented the from and where clause.
               Already Handled in the from and where condition in the fix for the bug.

            l_from_cc := l_from_cc || ',mtl_cycle_count_headers mcch ';
            l_where_cc :=
                  l_where_cc
               || ' and mcce.cycle_count_header_id = mcch.cycle_count_header_id '; */
            -- End of fix for Bug 3856227

            IF p_cycle_count_name IS NOT NULL
            THEN
               l_where_cc :=
                     l_where_cc
                  || ' and mcch.cycle_count_header_name = :cc_header_name ';
            END IF;
         END IF;

         -- Execute the Cycle Count query

         -- Concatenate the different sections of the query
	 IF p_summary_mode = 0 THEN
		l_query := l_insert_cc || l_select_cc || l_from_cc || l_where_cc ;
	 ELSE
		l_query := l_select_cc || l_from_cc || l_where_cc ;
	 END IF;

         -- Parse, Bind and Execute the dynamic query
         l_query_handle := DBMS_SQL.open_cursor;
         DBMS_SQL.parse (l_query_handle, l_query, DBMS_SQL.native);

         --generic bind variables
         IF p_organization_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'org_id',
                                    p_organization_id
                                   );
         END IF;

         IF p_subinventory_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'sub_code',
                                    p_subinventory_code
                                   );
         END IF;

         IF p_locator_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'loc_id', p_locator_id);
         END IF;

         IF p_inventory_item_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_id',
                                    p_inventory_item_id
                                   );
         END IF;

         -- R12 : Additional Query Criteria using item type
         IF p_item_type_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_type_code',
                                    p_item_type_code
                                   );
         END IF;


         IF p_category_set_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'category_set_id',
                                    p_category_set_id
                                   );
         END IF;

         IF p_item_category_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_category_id',
                                    p_item_category_id
                                   );
         END IF;

         IF p_person_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'person_id', p_person_id);
         END IF;

         IF p_person_resource_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'person_resource_id',
                                    p_person_resource_id
                                   );
         END IF;

         IF p_equipment_type_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'equipment_type_id',
                                    p_equipment_type_id
                                   );
         END IF;

         IF p_machine_resource_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'machine_resource_id',
                                    p_machine_resource_id
                                   );
         END IF;

         IF p_machine_instance IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'machine_instance',
                                    p_machine_instance
                                   );
         END IF;

         IF p_user_task_type_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'user_task_type_id',
                                    p_user_task_type_id
                                   );
         END IF;

         IF p_from_task_priority IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_task_priority',
                                    p_from_task_priority
                                   );
         END IF;

         IF p_to_task_priority IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_task_priority',
                                    p_to_task_priority
                                   );
         END IF;

         IF p_from_creation_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_creation_date',
                                    p_from_creation_date
                                   );
         END IF;

         IF p_to_creation_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_creation_date',
                                    p_to_creation_date
                                   );
         END IF;

         -- R12: Additional Query criteria using age of the task
         IF p_age_uom_code IS NOT NULL
         THEN

            IF p_age_min IS NOT NULL
            THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'age_min',
                                    p_age_min
                                   );
            END IF;

            IF p_age_max IS NOT NULL
            THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'age_max',
                                    p_age_max
                                   );

            END IF;
         END IF;

         --Cycle count specifc bind variables
         IF p_cycle_count_name IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'cc_header_name',
                                    p_cycle_count_name
                                   );
         END IF;


         --execute the query
         l_query_count := DBMS_SQL.EXECUTE (l_query_handle);
         g_record_count := g_record_count + l_query_count;

	 IF p_summary_mode = 1 THEN
		 LOOP
			IF DBMS_SQL.FETCH_ROWS(l_query_handle) = 0 THEN
				EXIT;
			END IF;
		 END LOOP;
		 g_wms_task_summary_tbl(wms_waveplan_tasks_pvt.g_task_type_cycle_count).wms_task_type := wms_waveplan_tasks_pvt.g_task_type_cycle_count;
		 g_wms_task_summary_tbl(wms_waveplan_tasks_pvt.g_task_type_cycle_count).task_count := g_wms_task_summary_tbl(wms_waveplan_tasks_pvt.g_task_type_cycle_count).task_count + dbms_sql.last_row_count;
		 IF l_debug = 1 THEN
			 debug(' Query :' || l_query , 'query_cc_tasks');
			 debug('Task Type :' || g_wms_task_summary_tbl(wms_waveplan_tasks_pvt.g_task_type_cycle_count).wms_task_type, 'query_cycle_count_tasks');
			 debug('TaskCount :' || g_wms_task_summary_tbl(wms_waveplan_tasks_pvt.g_task_type_cycle_count).task_count, 'query_cycle_count_tasks');
		 END IF;
	 END IF;

    DBMS_SQL.close_cursor(l_query_handle);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN -- Bug 4150145
	IF dbms_sql.is_open(l_query_handle) THEN
           dbms_sql.close_cursor(l_query_handle);
        END IF;
        DEBUG (SQLERRM, 'Task_planning.query_cycle_count_tasks');
   END query_cycle_count_tasks;

   PROCEDURE query_mo_tasks (
      p_add                      BOOLEAN DEFAULT FALSE,
      p_organization_id          NUMBER DEFAULT NULL,
      p_subinventory_code        VARCHAR2 DEFAULT NULL,
      p_locator_id               NUMBER DEFAULT NULL,
      p_to_subinventory_code     VARCHAR2 DEFAULT NULL,
      p_to_locator_id            NUMBER DEFAULT NULL,
      p_inventory_item_id        NUMBER DEFAULT NULL,
      p_category_set_id          NUMBER DEFAULT NULL,
      p_item_category_id         NUMBER DEFAULT NULL,
      p_person_id                NUMBER DEFAULT NULL,
      p_person_resource_id       NUMBER DEFAULT NULL,
      p_equipment_type_id        NUMBER DEFAULT NULL,
      p_machine_resource_id      NUMBER DEFAULT NULL,
      p_machine_instance         VARCHAR2 DEFAULT NULL,
      p_user_task_type_id        NUMBER DEFAULT NULL,
      p_from_task_quantity       NUMBER DEFAULT NULL,
      p_to_task_quantity         NUMBER DEFAULT NULL,
      p_from_task_priority       NUMBER DEFAULT NULL,
      p_to_task_priority         NUMBER DEFAULT NULL,
      p_from_creation_date       DATE DEFAULT NULL,
      p_to_creation_date         DATE DEFAULT NULL,
      p_is_unreleased            BOOLEAN DEFAULT FALSE,
      p_is_pending               BOOLEAN DEFAULT FALSE,
      p_is_queued                BOOLEAN DEFAULT FALSE,
      p_is_dispatched            BOOLEAN DEFAULT FALSE,
      p_is_active                BOOLEAN DEFAULT FALSE,
      p_is_loaded                BOOLEAN DEFAULT FALSE,
      p_is_completed             BOOLEAN DEFAULT FALSE,
      p_include_replenishment    BOOLEAN DEFAULT FALSE,
      p_from_replenishment_mo    VARCHAR2 DEFAULT NULL,
      p_to_replenishment_mo      VARCHAR2 DEFAULT NULL,
      p_include_mo_issue         BOOLEAN DEFAULT FALSE,
      p_include_mo_transfer      BOOLEAN DEFAULT FALSE,
      p_from_transfer_issue_mo   VARCHAR2 DEFAULT NULL,
      p_to_transfer_issue_mo     VARCHAR2 DEFAULT NULL,
      p_include_lpn_putaway      BOOLEAN DEFAULT FALSE,
      -- R12 : Additional Query Criteria
      p_item_type_code                            VARCHAR2 DEFAULT NULL,
   	p_age_uom_code                              VARCHAR2 DEFAULT NULL,
   	p_age_min                                   NUMBER DEFAULT NULL,
   	p_age_max                                   NUMBER DEFAULT NULL,
	p_summary_mode		NUMBER DEFAULT 0
      -- R12 : Additional Query Criteria

   )
   IS
      l_insert_query     VARCHAR2 (4000);
      l_select_generic   VARCHAR2 (4000);
      l_select_repl      VARCHAR2 (4000);
      l_from_generic     VARCHAR2 (2000);
      l_where_generic    VARCHAR2 (5000);
      l_from_repl        VARCHAR2 (2000);
      l_where_repl       VARCHAR2 (4000);
      l_query            VARCHAR2 (10000);
      l_query_handle     NUMBER;                -- Handle for the dynamic sql
      l_query_count      NUMBER;
      l_loop_start       NUMBER;
      l_loop_end         NUMBER;
      l_is_unreleased    BOOLEAN;
      l_is_pending       BOOLEAN;
      l_is_queued        BOOLEAN;
      l_is_dispatched    BOOLEAN;
      l_is_active        BOOLEAN;
      l_is_loaded        BOOLEAN;
      l_is_completed     BOOLEAN;
      l_wms_task_type	NUMBER; -- for bug 5129375
      l_task_count	NUMBER;
      l_debug                    NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
   BEGIN
      IF p_is_completed    THEN

         /*Bug 3627575:Setting the variable to true for Inbound queries*/
       wms_plan_tasks_pvt.g_from_inbound :=TRUE;
       l_loop_end := 2;
      ELSE
         l_loop_end := 1;
      END IF;

      IF    p_is_unreleased
         OR p_is_pending
         OR p_is_queued
         OR p_is_dispatched
         OR p_is_active
         OR p_is_loaded
      THEN
         l_loop_start := 1;
      ELSE
         l_loop_start := 2;
      END IF;

      FOR i IN l_loop_start .. l_loop_end
      LOOP
         l_insert_query := NULL;
         l_select_generic := NULL;
         l_select_repl := NULL;
         l_from_generic := NULL;
         l_from_repl := NULL;
         l_where_generic := NULL;
         l_where_repl := NULL;

         IF i = 1
         THEN                                -- Non completed tasks iteration
            l_is_unreleased := p_is_unreleased;
            l_is_pending := p_is_pending;
            l_is_queued := p_is_queued;
            l_is_dispatched := p_is_dispatched;
            l_is_active := p_is_active;
            l_is_loaded := p_is_loaded;
            l_is_completed := FALSE;
         ELSE                                               -- Completed tasks
            l_is_unreleased := FALSE;
            l_is_pending := FALSE;
            l_is_queued := FALSE;
            l_is_dispatched := FALSE;
            l_is_active := FALSE;
            l_is_loaded := FALSE;
            l_is_completed := p_is_completed;
         END IF;

         -- Insert section
	 IF  p_summary_mode = 1 THEN -- only for query mode
		IF i = 1 THEN
			l_select_generic := ' SELECT mmtt.wms_task_type, count(*) ';
		ELSE
			l_select_generic := ' SELECT wdth.task_type, count(*) ';
		END IF;
	 ELSE
         l_insert_query :=
            get_generic_insert (p_is_unreleased      => l_is_unreleased,
                                p_is_pending         => l_is_pending,
                                p_is_queued          => l_is_queued,
                                p_is_dispatched      => l_is_dispatched,
                                p_is_active          => l_is_active,
                                p_is_loaded          => l_is_loaded,
                                p_is_completed       => l_is_completed
                               );
         -- Replenishment specific inserts
         l_insert_query := l_insert_query || ', source_header ';
                                                               --source_header
         l_insert_query := l_insert_query || ', line_number ';   --line_number
         l_insert_query := l_insert_query || ') ';
         l_select_generic :=
            get_generic_select (p_is_unreleased      => l_is_unreleased,
                                p_is_pending         => l_is_pending,
                                p_is_queued          => l_is_queued,
                                p_is_dispatched      => l_is_dispatched,
                                p_is_active          => l_is_active,
                                p_is_loaded          => l_is_loaded,
                                p_is_completed       => l_is_completed
                               );
         -- Replenishment secific selects, should map to the columns additionally selecteda above
         l_select_repl := ', mtrh.request_number ';            --source_header
         l_select_repl := l_select_repl || ', mtrl.line_number ';
                                                                 --line_number
	 END IF;
         -- Generic from
         l_from_generic :=
            get_generic_from (p_is_queued             => l_is_queued,
                              p_is_dispatched         => l_is_dispatched,
                              p_is_active             => l_is_active,
                              p_is_loaded             => l_is_loaded,
                              p_is_completed          => l_is_completed,
                              p_item_category_id      => p_item_category_id,
                              p_category_set_id       => p_category_set_id
                             );
         --Generic Where
         l_where_generic :=
            get_generic_where
                            (p_add                       => p_add,
                             p_organization_id           => p_organization_id,
                             p_subinventory_code         => p_subinventory_code,
                             p_locator_id                => p_locator_id,
                             p_to_subinventory_code      => p_to_subinventory_code,
                             p_to_locator_id             => p_to_locator_id,
                             p_inventory_item_id         => p_inventory_item_id,
                             p_category_set_id           => p_category_set_id,
                             p_item_category_id          => p_item_category_id,
                             p_person_id                 => p_person_id,
                             p_person_resource_id        => p_person_resource_id,
                             p_equipment_type_id         => p_equipment_type_id,
                             p_machine_resource_id       => p_machine_resource_id,
                             p_machine_instance          => p_machine_instance,
                             p_user_task_type_id         => p_user_task_type_id,
                             p_from_task_quantity        => p_from_task_quantity,
                             p_to_task_quantity          => p_to_task_quantity,
                             p_from_task_priority        => p_from_task_priority,
                             p_to_task_priority          => p_to_task_priority,
                             p_from_creation_date        => p_from_creation_date,
                             p_to_creation_date          => p_to_creation_date,
                             p_is_unreleased             => l_is_unreleased,
                             p_is_pending                => l_is_pending,
                             p_is_queued                 => l_is_queued,
                             p_is_dispatched             => l_is_dispatched,
                             p_is_active                 => l_is_active,
                             p_is_loaded                 => l_is_loaded,
                             p_is_completed              => l_is_completed,
                              -- R12: Additional query criteria
                              p_item_type_code             =>  p_item_type_code,
                              p_age_uom_code               =>  p_age_uom_code,
                              p_age_min                    =>  p_age_min,
                              p_age_max                    =>  p_age_max
                            );
         l_from_repl := ' , mtl_txn_request_headers mtrh';
         l_from_repl := l_from_repl || ' , mtl_txn_request_lines mtrl ';
         l_where_repl :=
                       l_where_repl || ' and mtrl.header_id = mtrh.header_id ';

         IF i = 1
         THEN
            l_where_repl :=
               l_where_repl || ' and mtrl.line_id = mmtt.trx_source_line_id ';
            l_where_repl :=
                  l_where_repl || ' and mmtt.transaction_source_type_id = 4 ';
         ELSE
            l_where_repl :=
                l_where_repl || ' and mtrl.line_id = mmt.trx_source_line_id ';
            l_where_repl :=
                   l_where_repl || ' and mmt.transaction_source_type_id = 4 ';
            /* Bug 5688998 */
	    l_where_repl :=
                   l_where_repl || ' and mtrl.line_id = wdth.move_order_line_id(+) ';
	    /* End of Big 5688998 */
         END IF;

         IF    p_include_replenishment
            OR p_include_mo_issue
            OR p_include_mo_transfer
            OR p_include_lpn_putaway
         THEN
            IF p_include_replenishment
            THEN
               l_where_repl :=
                             l_where_repl || ' and (mtrh.move_order_type = 2';

               IF p_from_replenishment_mo IS NOT NULL
               THEN
                  l_where_repl :=
                        l_where_repl
                     || ' and mtrh.request_number >= :from_replenishment_mo ';
               END IF;

               IF p_to_replenishment_mo IS NOT NULL
               THEN
                  l_where_repl :=
                        l_where_repl
                     || ' and mtrh.request_number <= :to_replenishment_mo ';
               END IF;
            END IF;

            IF p_include_mo_issue OR p_include_mo_transfer
            THEN
               IF p_include_replenishment
               THEN
                  l_where_repl := l_where_repl || ' OR ';
               ELSE
                  l_where_repl := l_where_repl || ' AND (';
               END IF;

               l_where_repl := l_where_repl || ' mtrh.move_order_type = 1 ';

               IF p_from_transfer_issue_mo IS NOT NULL
               THEN
                  l_where_repl :=
                        l_where_repl
                     || ' and mtrh.request_number >= :from_transfer_issue_mo ';
               END IF;

               IF p_to_transfer_issue_mo IS NOT NULL
               THEN
                  l_where_repl :=
                        l_where_repl
                     || ' and mtrh.request_number <= :to_transfer_issue_mo ';
               END IF;
            END IF;

            IF p_include_lpn_putaway
            THEN
               IF    p_include_replenishment
                  OR p_include_mo_transfer
                  OR p_include_mo_issue
               THEN
                  l_where_repl := l_where_repl || ' OR ';
               ELSE
                  l_where_repl := l_where_repl || ' AND (';
               END IF;

               l_where_repl := l_where_repl || ' (mtrh.move_order_type = 6 ';
               l_where_repl := l_where_repl || ' AND mtrl.reference is NULL) ';
            END IF;

            l_where_repl := l_where_repl || ' ) ';

            IF p_include_replenishment OR p_include_mo_transfer
            THEN
               IF i = 1
               THEN
                  l_where_repl :=
                      l_where_repl || ' and (mmtt.transaction_action_id = 2 ';
               ELSE
                  l_where_repl :=
                       l_where_repl || ' and (mmt.transaction_action_id = 2 ';
               END IF;
            END IF;

            IF p_include_mo_issue
            THEN
               IF p_include_replenishment OR p_include_mo_transfer
               THEN
                  IF i = 1
                  THEN
                     l_where_repl :=
                        l_where_repl
                        || ' OR mmtt.transaction_action_id = 1) ';
                  ELSE
                     l_where_repl :=
                        l_where_repl || ' OR mmt.transaction_action_id = 1) ';
                  END IF;
               ELSE
                  IF i = 1
                  THEN
                     l_where_repl :=
                           l_where_repl
                        || ' AND (mmtt.transaction_action_id = 1)';
                  ELSE
                     l_where_repl :=
                        l_where_repl
                        || ' AND (mmt.transaction_action_id = 1)';
                  END IF;
               END IF;
            ELSE
               IF p_include_replenishment OR p_include_mo_transfer
               THEN
                  l_where_repl := l_where_repl || ')';
               END IF;
            END IF;
         END IF;

	 IF p_summary_mode = 1 THEN
		IF i = 1 THEN
			l_where_repl := l_where_repl || ' GROUP BY mmtt.wms_task_type ';
		ELSE
			l_where_repl := l_where_repl || ' GROUP BY wdth.task_type ';
		END IF;
	 END IF;

         -- Execute the query

         -- Concatenate the different sections of the query
         l_query :=
               l_insert_query
            || l_select_generic
            || l_select_repl
            || l_from_generic
            || l_from_repl
            || l_where_generic
            || l_where_repl;
         -- Parse, Bind and Execute the dynamic query
         if l_debug = 1 then
	   debug('MO Tasks Query ' || l_query,'query_mo_tasks');
	 end if;
         l_query_handle := DBMS_SQL.open_cursor;
         DBMS_SQL.parse (l_query_handle, l_query, DBMS_SQL.native);

         --generic bind variables
         IF p_organization_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'org_id',
                                    p_organization_id
                                   );
         END IF;

         IF p_subinventory_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'sub_code',
                                    p_subinventory_code
                                   );
         END IF;

         IF p_locator_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'loc_id', p_locator_id);
         END IF;

         IF p_to_subinventory_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_sub_code',
                                    p_to_subinventory_code
                                   );
         END IF;

         IF p_to_locator_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_loc_id',
                                    p_to_locator_id
                                   );
         END IF;

         IF p_category_set_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'category_set_id',
                                    p_category_set_id
                                   );
         END IF;

         IF p_inventory_item_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_id',
                                    p_inventory_item_id
                                   );
         END IF;

         -- R12 : Additional Query Criteria using item type
         IF p_item_type_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_type_code',
                                    p_item_type_code
                                   );
         END IF;


         IF p_item_category_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_category_id',
                                    p_item_category_id
                                   );
         END IF;

         IF p_person_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'person_id', p_person_id);
         END IF;

         IF p_person_resource_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'person_resource_id',
                                    p_person_resource_id
                                   );
         END IF;

         IF p_equipment_type_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'equipment_type_id',
                                    p_equipment_type_id
                                   );
         END IF;

         IF p_machine_resource_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'machine_resource_id',
                                    p_machine_resource_id
                                   );
         END IF;

         IF p_machine_instance IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'machine_instance',
                                    p_machine_instance
                                   );
         END IF;

         IF p_user_task_type_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'user_task_type_id',
                                    p_user_task_type_id
                                   );
         END IF;

         IF p_from_task_quantity IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_task_quantity',
                                    p_from_task_quantity
                                   );
         END IF;

         IF p_to_task_quantity IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_task_quantity',
                                    p_to_task_quantity
                                   );
         END IF;

         IF p_from_task_priority IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_task_priority',
                                    p_from_task_priority
                                   );
         END IF;

         IF p_to_task_priority IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_task_priority',
                                    p_to_task_priority
                                   );
         END IF;

         IF p_from_creation_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_creation_date',
                                    p_from_creation_date
                                   );
         END IF;

         IF p_to_creation_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_creation_date',
                                    p_to_creation_date
                                   );
         END IF;

         -- R12: Additional Query criteria using age of the task
         IF p_age_uom_code IS NOT NULL
         THEN

            IF p_age_min IS NOT NULL
            THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'age_min',
                                    p_age_min
                                   );
            END IF;

            IF p_age_max IS NOT NULL
            THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'age_max',
                                    p_age_max
                                   );

            END IF;
         END IF;

         IF p_from_replenishment_mo IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_replenishment_mo',
                                    p_from_replenishment_mo
                                   );
         END IF;

         IF p_to_replenishment_mo IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_replenishment_mo',
                                    p_to_replenishment_mo
                                   );
         END IF;

         IF p_from_transfer_issue_mo IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_transfer_issue_mo',
                                    p_from_transfer_issue_mo
                                   );
         END IF;

         IF p_to_transfer_issue_mo IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_transfer_issue_mo',
                                    p_to_transfer_issue_mo
                                   );
         END IF;

	 IF p_summary_mode = 1 THEN
		DBMS_SQL.DEFINE_COLUMN(l_query_handle, 1, l_wms_task_type);
		DBMS_SQL.DEFINE_COLUMN(l_query_handle, 2, l_task_count);
	 END IF;

         --execute the replenishment query
         l_query_count := DBMS_SQL.EXECUTE (l_query_handle);
         g_record_count := g_record_count + l_query_count;

	 IF p_summary_mode = 1 THEN -- fetch the rows and put them into the global tables
		LOOP
		       IF DBMS_SQL.FETCH_ROWS(l_query_handle)>0 THEN
			  DBMS_SQL.COLUMN_VALUE(l_query_handle, 1, l_wms_task_type);
			  DBMS_SQL.COLUMN_VALUE(l_query_handle, 2, l_task_count);
			  g_wms_task_summary_tbl(l_wms_task_type).wms_task_type := l_wms_task_type;
			  g_wms_task_summary_tbl(l_wms_task_type).task_count := g_wms_task_summary_tbl(l_wms_task_type).task_count + l_task_count;
			  IF l_debug = 1 THEN
				  debug('Task Type :' || g_wms_task_summary_tbl(l_wms_task_type).wms_task_type, 'query_mo_tasks');
				  debug('TaskCount :' || g_wms_task_summary_tbl(l_wms_task_type).task_count, 'query_mo_tasks');
			  END IF;
		       ELSE
			  EXIT; -- no more rows returned from dynamic SQL
		       END IF;
		END LOOP;
	 END IF;
    DBMS_SQL.close_cursor(l_query_handle);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN -- Bug 4150145
	IF dbms_sql.is_open(l_query_handle) THEN
           dbms_sql.close_cursor(l_query_handle);
        END IF;
        DEBUG (SQLERRM, 'Task_planning.query_mo_tasks');
   END query_mo_tasks;

   PROCEDURE query_move_tasks (
      p_add                      BOOLEAN DEFAULT FALSE,
      p_organization_id          NUMBER DEFAULT NULL,
      p_subinventory_code        VARCHAR2 DEFAULT NULL,
      p_locator_id               NUMBER DEFAULT NULL,
      p_to_subinventory_code     VARCHAR2 DEFAULT NULL,
      p_to_locator_id            NUMBER DEFAULT NULL,
      p_inventory_item_id        NUMBER DEFAULT NULL,
      p_category_set_id          NUMBER DEFAULT NULL,
      p_item_category_id         NUMBER DEFAULT NULL,
      p_person_id                NUMBER DEFAULT NULL,
      p_person_resource_id       NUMBER DEFAULT NULL,
      p_equipment_type_id        NUMBER DEFAULT NULL,
      p_machine_resource_id      NUMBER DEFAULT NULL,
      p_machine_instance         VARCHAR2 DEFAULT NULL,
      p_user_task_type_id        NUMBER DEFAULT NULL,
      p_from_task_quantity       NUMBER DEFAULT NULL,
      p_to_task_quantity         NUMBER DEFAULT NULL,
      p_from_task_priority       NUMBER DEFAULT NULL,
      p_to_task_priority         NUMBER DEFAULT NULL,
      p_from_creation_date       DATE DEFAULT NULL,
      p_to_creation_date         DATE DEFAULT NULL,
      p_include_staging_move     BOOLEAN DEFAULT FALSE,
      p_include_inventory_move   BOOLEAN DEFAULT FALSE,
      p_is_unreleased            BOOLEAN DEFAULT FALSE,
      p_is_pending               BOOLEAN DEFAULT FALSE,
      p_is_queued                BOOLEAN DEFAULT FALSE,
      p_is_dispatched            BOOLEAN DEFAULT FALSE,
      p_is_active                BOOLEAN DEFAULT FALSE,
      p_is_loaded                BOOLEAN DEFAULT FALSE,
      p_is_completed             BOOLEAN DEFAULT FALSE,
      -- R12 : Additional Query Criteria
      p_item_type_code                            VARCHAR2 DEFAULT NULL,
   	p_age_uom_code                              VARCHAR2 DEFAULT NULL,
   	p_age_min                                   NUMBER DEFAULT NULL,
   	p_age_max                                   NUMBER DEFAULT NULL
      -- R12 : Additional Query Criteria
   )
   IS
      l_insert_query     VARCHAR2 (4000);
      l_select_generic   VARCHAR2 (4000);
      l_select_repl      VARCHAR2 (4000);
      l_from_generic     VARCHAR2 (2000);
      l_where_generic    VARCHAR2 (5000);
      l_query            VARCHAR2 (10000);
      l_query_handle     NUMBER;                -- Handle for the dynamic sql
      l_query_count      NUMBER;
      l_loop_start       NUMBER;
      l_loop_end         NUMBER;

      l_is_unreleased    BOOLEAN;
      l_is_pending       BOOLEAN;
      l_is_queued        BOOLEAN;
      l_is_dispatched    BOOLEAN;
      l_is_active        BOOLEAN;
      l_is_loaded        BOOLEAN;
      l_is_completed     BOOLEAN;
      l_debug   NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

   BEGIN
      IF p_is_completed
      THEN
         l_loop_end := 2;
      ELSE
         l_loop_end := 1;
      END IF;

      IF p_is_pending OR p_is_loaded
      THEN
         l_loop_start := 1;
      ELSE
         l_loop_start := 2;
      END IF;

      FOR i IN l_loop_start .. l_loop_end
      LOOP
         l_insert_query := NULL;
         l_select_generic := NULL;
         l_from_generic := NULL;
         l_where_generic := NULL;

         IF i = 1
         THEN                                -- Non completed tasks iteration
            l_is_unreleased := p_is_unreleased;
            l_is_queued  := p_is_queued;
            l_is_dispatched := p_is_dispatched;
            l_is_active  := p_is_active;
            l_is_pending := p_is_pending;
            l_is_loaded := p_is_loaded;
            l_is_completed := FALSE;
         ELSE                                               -- Completed tasks
            l_is_unreleased := FALSE;
            l_is_queued  := FALSE;
            l_is_dispatched := FALSE;
            l_is_active  := FALSE;
            l_is_pending := FALSE;
            l_is_loaded := FALSE;
            l_is_completed := p_is_completed;
         END IF;

         -- Insert section
         l_insert_query :=
            get_generic_insert (p_is_unreleased      => l_is_unreleased,
                                p_is_pending         => l_is_pending,
                                p_is_queued          => l_is_queued,
                                p_is_dispatched      => l_is_dispatched,
                                p_is_active          => l_is_active,
                                p_is_loaded          => l_is_loaded,
                                p_is_completed       => l_is_completed
                               );
         l_insert_query := l_insert_query || ') ';
         l_select_generic :=
            get_generic_select (p_is_unreleased             => l_is_unreleased,
                                p_is_pending                => l_is_pending,
                                p_is_queued                 => l_is_queued,
                                p_is_dispatched             => l_is_dispatched,
                                p_is_active                 => l_is_active,
                                p_is_loaded                 => l_is_loaded,
                                p_is_completed              => l_is_completed
                               );
         -- Generic from
         l_from_generic :=
            get_generic_from (  p_is_queued                 => l_is_queued,
                                p_is_dispatched             => l_is_dispatched,
                                p_is_active                 => l_is_active,
                                p_is_loaded                 => l_is_loaded,
                                p_is_completed              => l_is_completed,
                                p_item_category_id      => p_item_category_id,
                                p_category_set_id       => p_category_set_id
                             );
         --Generic Where
         l_where_generic :=
            get_generic_where
                            (p_add                       => p_add,
                             p_organization_id           => p_organization_id,
                             p_subinventory_code         => p_subinventory_code,
                             p_locator_id                => p_locator_id,
                             p_to_subinventory_code      => p_to_subinventory_code,
                             p_to_locator_id             => p_to_locator_id,
                             p_inventory_item_id         => p_inventory_item_id,
                             p_category_set_id           => p_category_set_id,
                             p_item_category_id          => p_item_category_id,
                             p_person_id                 => p_person_id,
                             p_person_resource_id        => p_person_resource_id,
                             p_equipment_type_id         => p_equipment_type_id,
                             p_machine_resource_id       => p_machine_resource_id,
                             p_machine_instance          => p_machine_instance,
                             p_user_task_type_id         => p_user_task_type_id,
                             p_from_task_quantity        => p_from_task_quantity,
                             p_to_task_quantity          => p_to_task_quantity,
                             p_from_task_priority        => p_from_task_priority,
                             p_to_task_priority          => p_to_task_priority,
                             p_from_creation_date        => p_from_creation_date,
                             p_to_creation_date          => p_to_creation_date,
                             p_is_unreleased             => l_is_unreleased,
                             p_is_pending                => l_is_pending,
                             p_is_queued                 => l_is_queued,
                             p_is_dispatched             => l_is_dispatched,
                             p_is_active                 => l_is_active,
                             p_is_loaded                 => l_is_loaded,
                             p_is_completed              => l_is_completed,
                              -- R12: Additional query criteria
                              p_item_type_code             =>  p_item_type_code,
                              p_age_uom_code               =>  p_age_uom_code,
                              p_age_min                    =>  p_age_min,
                              p_age_max                    =>  p_age_max
                            );

         IF p_include_staging_move AND NOT p_include_inventory_move
         THEN
            IF i = 1
            THEN
               l_where_generic :=
                            l_where_generic || ' and mmtt.wms_task_type = 7 ';
            ELSE
               l_where_generic :=
                                l_where_generic || ' and wdth.task_type = 7 ';
            END IF;
         ELSIF NOT p_include_staging_move AND p_include_inventory_move
         THEN
            IF i = 1
            THEN
               l_where_generic :=
                            l_where_generic || ' and mmtt.wms_task_type = 4 ';
               l_where_generic :=
                    l_where_generic || ' and mmtt.transaction_action_id = 2 ';
               l_where_generic :=
                     l_where_generic
                  || ' and mmtt.transaction_source_type_id = 13 ';
            ELSE
               l_where_generic :=
                                l_where_generic || ' and wdth.task_type = 4 ';
               l_where_generic :=
                     l_where_generic || ' and mmt.transaction_action_id = 2 ';
               l_where_generic :=
                     l_where_generic
                  || ' and mmt.transaction_source_type_id = 13 ';
            END IF;
         ELSIF p_include_staging_move AND p_include_inventory_move
         THEN
            IF i = 1
            THEN
               l_where_generic :=
                      l_where_generic || ' and ((mmtt.wms_task_type = 7) or ';
               l_where_generic :=
                               l_where_generic || ' (mmtt.wms_task_type = 4 ';
               l_where_generic :=
                    l_where_generic || ' and mmtt.transaction_action_id = 2 ';
               l_where_generic :=
                     l_where_generic
                  || ' and mmtt.transaction_source_type_id = 13)) ';
            ELSE
               l_where_generic :=
                          l_where_generic || ' and ((wdth.task_type = 7) or ';
               l_where_generic := l_where_generic || ' (wdth.task_type = 4 ';
               l_where_generic :=
                     l_where_generic || ' and mmt.transaction_action_id = 2 ';
               l_where_generic :=
                     l_where_generic
                  || ' and mmt.transaction_source_type_id = 13)) ';
            END IF;
         END IF;

         -- Execute the query

         -- Concatenate the different sections of the query
         l_query :=
               l_insert_query
            || l_select_generic
            || l_from_generic
            || l_where_generic;
         -- Parse, Bind and Execute the dynamic query
         if l_debug = 1 then
    	   debug('MO Tasks Query ' || l_query,'query_move_tasks');
	 end if;
         l_query_handle := DBMS_SQL.open_cursor;
         DBMS_SQL.parse (l_query_handle, l_query, DBMS_SQL.native);

         --generic bind variables
         IF p_organization_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'org_id',
                                    p_organization_id
                                   );
         END IF;

         IF p_subinventory_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'sub_code',
                                    p_subinventory_code
                                   );
         END IF;

         IF p_locator_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'loc_id', p_locator_id);
         END IF;

         IF p_to_subinventory_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_sub_code',
                                    p_to_subinventory_code
                                   );
         END IF;

         IF p_to_locator_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_loc_id',
                                    p_to_locator_id
                                   );
         END IF;

         IF p_category_set_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'category_set_id',
                                    p_category_set_id
                                   );
         END IF;

         IF p_inventory_item_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_id',
                                    p_inventory_item_id
                                   );
         END IF;

         -- R12 : Additional Query Criteria using item type
         IF p_item_type_code IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_type_code',
                                    p_item_type_code
                                   );
         END IF;


         IF p_item_category_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'item_category_id',
                                    p_item_category_id
                                   );
         END IF;

         IF p_person_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle, 'person_id', p_person_id);
         END IF;

         IF p_person_resource_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'person_resource_id',
                                    p_person_resource_id
                                   );
         END IF;

         IF p_equipment_type_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'equipment_type_id',
                                    p_equipment_type_id
                                   );
         END IF;

         IF p_machine_resource_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'machine_resource_id',
                                    p_machine_resource_id
                                   );
         END IF;

         IF p_machine_instance IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'machine_instance',
                                    p_machine_instance
                                   );
         END IF;

         IF p_user_task_type_id IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'user_task_type_id',
                                    p_user_task_type_id
                                   );
         END IF;

         IF p_from_task_quantity IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_task_quantity',
                                    p_from_task_quantity
                                   );
         END IF;

         IF p_to_task_quantity IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_task_quantity',
                                    p_to_task_quantity
                                   );
         END IF;

         IF p_from_task_priority IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_task_priority',
                                    p_from_task_priority
                                   );
         END IF;

         IF p_to_task_priority IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_task_priority',
                                    p_to_task_priority
                                   );
         END IF;

         IF p_from_creation_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'from_creation_date',
                                    p_from_creation_date
                                   );
         END IF;

         IF p_to_creation_date IS NOT NULL
         THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'to_creation_date',
                                    p_to_creation_date
                                   );
         END IF;

         -- R12: Additional Query criteria using age of the task
         IF p_age_uom_code IS NOT NULL
         THEN

            IF p_age_min IS NOT NULL
            THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'age_min',
                                    p_age_min
                                   );
            END IF;

            IF p_age_max IS NOT NULL
            THEN
            DBMS_SQL.bind_variable (l_query_handle,
                                    'age_max',
                                    p_age_max
                                   );

            END IF;
         END IF;

         --execute the replenishment query
         l_query_count := DBMS_SQL.EXECUTE (l_query_handle);
         g_record_count := g_record_count + l_query_count;
    DBMS_SQL.close_cursor(l_query_handle);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN -- Bug 4150145
	IF dbms_sql.is_open(l_query_handle) THEN
           dbms_sql.close_cursor(l_query_handle);
        END IF;
        DEBUG (SQLERRM, 'Task_planning.query_mo_tasks');
   END query_move_tasks;

-- Prodedure query_tasks
-- Input: Parameters that define the kind of task
-- Output: This procedure populates the global temp table
--         wms_waveplan_tasks_temp based on the input parameters.
   PROCEDURE query_tasks (
      p_add                                       BOOLEAN DEFAULT FALSE,
      p_organization_id                           NUMBER DEFAULT NULL,
      p_subinventory_code                         VARCHAR2 DEFAULT NULL,
      p_locator_id                                NUMBER DEFAULT NULL,
      p_to_subinventory_code                      VARCHAR2 DEFAULT NULL,
      p_to_locator_id                             NUMBER DEFAULT NULL,
      p_inventory_item_id                         NUMBER DEFAULT NULL,
      p_category_set_id                           NUMBER DEFAULT NULL,
      p_item_category_id                          NUMBER DEFAULT NULL,
      p_person_id                                 NUMBER DEFAULT NULL,
      p_person_resource_id                        NUMBER DEFAULT NULL,
      p_equipment_type_id                         NUMBER DEFAULT NULL,
      p_machine_resource_id                       NUMBER DEFAULT NULL,
      p_machine_instance                          VARCHAR2 DEFAULT NULL,
      p_user_task_type_id                         NUMBER DEFAULT NULL,
      p_from_task_quantity                        NUMBER DEFAULT NULL,
      p_to_task_quantity                          NUMBER DEFAULT NULL,
      p_from_task_priority                        NUMBER DEFAULT NULL,
      p_to_task_priority                          NUMBER DEFAULT NULL,
      p_from_creation_date                        DATE DEFAULT NULL,
      p_to_creation_date                          DATE DEFAULT NULL,
      p_is_unreleased                             BOOLEAN DEFAULT FALSE,
      p_is_pending                                BOOLEAN DEFAULT FALSE,
      p_is_queued                                 BOOLEAN DEFAULT FALSE,
      p_is_dispatched                             BOOLEAN DEFAULT FALSE,
      p_is_active                                 BOOLEAN DEFAULT FALSE,
      p_is_loaded                                 BOOLEAN DEFAULT FALSE,
      p_is_completed                              BOOLEAN DEFAULT FALSE,
      p_include_inbound                           BOOLEAN DEFAULT FALSE,
      p_include_outbound                          BOOLEAN DEFAULT FALSE,
      p_include_crossdock                         BOOLEAN DEFAULT FALSE,
      p_include_manufacturing                     BOOLEAN DEFAULT FALSE,
      p_include_warehousing                       BOOLEAN DEFAULT FALSE,
      p_from_po_header_id                         NUMBER DEFAULT NULL,
      p_to_po_header_id                           NUMBER DEFAULT NULL,
      p_from_purchase_order                       VARCHAR2 DEFAULT NULL,
      p_to_purchase_order                         VARCHAR2 DEFAULT NULL,
      p_from_rma_header_id                        NUMBER DEFAULT NULL,
      p_to_rma_header_id                          NUMBER DEFAULT NULL,
      p_from_rma                                  VARCHAR2 DEFAULT NULL,
      p_to_rma                                    VARCHAR2 DEFAULT NULL,
      p_from_requisition_header_id                NUMBER DEFAULT NULL,
      p_to_requisition_header_id                  NUMBER DEFAULT NULL,
      p_from_requisition                          VARCHAR2 DEFAULT NULL,
      p_to_requisition                            VARCHAR2 DEFAULT NULL,
      p_from_shipment_number                      VARCHAR2 DEFAULT NULL,
      p_to_shipment_number                        VARCHAR2 DEFAULT NULL,
      p_include_sales_orders                      BOOLEAN DEFAULT TRUE,
      p_include_internal_orders                   BOOLEAN DEFAULT TRUE,
      p_from_sales_order_id                       NUMBER DEFAULT NULL,
      p_to_sales_order_id                         NUMBER DEFAULT NULL,
      p_from_pick_slip_number                     NUMBER DEFAULT NULL,
      p_to_pick_slip_number                       NUMBER DEFAULT NULL,
      p_customer_id                               NUMBER DEFAULT NULL,
      p_customer_category                         VARCHAR2 DEFAULT NULL,
      p_delivery_id                               NUMBER DEFAULT NULL,
      p_carrier_id                                NUMBER DEFAULT NULL,
      p_ship_method                               VARCHAR2 DEFAULT NULL,
      p_shipment_priority                         VARCHAR2 DEFAULT NULL,
      p_trip_id                                   NUMBER DEFAULT NULL,
      p_from_shipment_date                        DATE DEFAULT NULL,
      p_to_shipment_date                          DATE DEFAULT NULL,
      p_ship_to_state                             VARCHAR2 DEFAULT NULL,
      p_ship_to_country                           VARCHAR2 DEFAULT NULL,
      p_ship_to_postal_code                       VARCHAR2 DEFAULT NULL,
      p_from_number_of_order_lines                NUMBER DEFAULT NULL,
      p_to_number_of_order_lines                  NUMBER DEFAULT NULL,
      p_manufacturing_type                        VARCHAR2 DEFAULT NULL,
      p_from_job                                  VARCHAR2 DEFAULT NULL,
      p_to_job                                    VARCHAR2 DEFAULT NULL,
      p_assembly_id                               NUMBER DEFAULT NULL,
      p_from_start_date                           DATE DEFAULT NULL,
      p_to_start_date                             DATE DEFAULT NULL,
      p_from_line                                 VARCHAR2 DEFAULT NULL,
      p_to_line                                   VARCHAR2 DEFAULT NULL,
      p_department_id                             NUMBER DEFAULT NULL,
      p_include_replenishment                     BOOLEAN DEFAULT TRUE,
      p_from_replenishment_mo                     VARCHAR2 DEFAULT NULL,
      p_to_replenishment_mo                       VARCHAR2 DEFAULT NULL,
      p_include_mo_transfer                       BOOLEAN DEFAULT TRUE,
      p_include_mo_issue                          BOOLEAN DEFAULT TRUE,
      p_from_transfer_issue_mo                    VARCHAR2 DEFAULT NULL,
      p_to_transfer_issue_mo                      VARCHAR2 DEFAULT NULL,
      p_include_lpn_putaway                       BOOLEAN DEFAULT TRUE,
      p_include_staging_move                      BOOLEAN DEFAULT FALSE,
      p_include_cycle_count                       BOOLEAN DEFAULT TRUE,
      p_cycle_count_name                          VARCHAR2 DEFAULT NULL,
      x_record_count                 OUT NOCOPY   NUMBER,
      x_return_status                OUT NOCOPY   VARCHAR2,
      x_msg_data                     OUT NOCOPY   VARCHAR2,
      x_msg_count                    OUT NOCOPY   NUMBER,
      p_query_independent_tasks                   BOOLEAN DEFAULT TRUE,
      p_query_planned_tasks                       BOOLEAN DEFAULT TRUE,
      p_is_pending_plan                           BOOLEAN DEFAULT FALSE,
      p_is_inprogress_plan                        BOOLEAN DEFAULT FALSE,
      p_is_completed_plan                         BOOLEAN DEFAULT FALSE,
      p_is_cancelled_plan                         BOOLEAN DEFAULT FALSE,
      p_is_aborted_plan                           BOOLEAN DEFAULT FALSE,
      p_activity_id                               NUMBER DEFAULT NULL,
      p_plan_type_id                              NUMBER DEFAULT NULL,
      p_op_plan_id                                NUMBER DEFAULT NULL,
      -- R12 : Additional Query Criteria
      p_item_type_code                            VARCHAR2 DEFAULT NULL,
   	p_age_uom_code                              VARCHAR2 DEFAULT NULL,
   	p_age_min                                   NUMBER DEFAULT NULL,
   	p_age_max                                   NUMBER DEFAULT NULL,
      p_order_type_id                             NUMBER DEFAULT NULL,
   	p_time_till_shipment_uom_code               VARCHAR2 DEFAULT NULL,
   	p_time_till_shipment                        NUMBER DEFAULT NULL,
   	p_time_till_appt_uom_code                   VARCHAR2 DEFAULT NULL,
   	p_time_till_appt                            NUMBER DEFAULT NULL,
	   p_summary_mode				                    NUMBER DEFAULT 0
      -- R12 : Additional Query Criteria
      , p_wave_header_id                            NUMBER DEFAULT NULL
   )
   IS
      l_parent_inserted   NUMBER  := 0;
      l_is_pending        BOOLEAN := p_is_pending;
      l_debug             NUMBER  := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
   BEGIN
      x_return_status := 'S';

      -- Delete any existing records in the temp table
      IF NOT p_add
      THEN
         wms_plan_tasks_pvt.clear_globals ();

         DELETE FROM wms_waveplan_tasks_temp;

         g_record_count := 0;
      END IF;

      -- Populate the globals storing the status codes
      IF g_status_codes.COUNT = 0
      THEN
         set_status_codes;
      END IF;

      -- Populate the globals storing the task types
      IF g_task_types.COUNT = 0
      THEN
         set_task_type;
      END IF;

      --Change
      --Patchset J
       --Populate the globals storing plan task types
      IF g_plan_task_types.COUNT = 0
      THEN
         set_plan_task_types;
      END IF;

      --End of change

      -- Populate the globals storing the plan status codes
      IF g_plan_status_codes.COUNT = 0
      THEN
         set_plan_status_codes;
      END IF;

      -- Populate the globals storing the visible attribute of columns
      IF g_allocated_lpn_visible IS NULL
      THEN
         find_visible_columns;
      END IF;

      -- initialize the global summary table
      IF NOT p_add THEN
	      FOR i IN 1..8 LOOP
		g_wms_task_summary_tbl(i).wms_task_type := i;
		g_wms_task_summary_tbl(i).task_count := 0;
	      END LOOP;
      END IF;

      wms_plan_tasks_pvt.set_globals
                (p_organization_id                 => p_organization_id,
                 p_subinventory_code               => p_subinventory_code,
                 p_locator_id                      => p_locator_id,
                 p_to_subinventory_code            => p_to_subinventory_code,
                 p_to_locator_id                   => p_to_locator_id,
                 p_inventory_item_id               => p_inventory_item_id,
                 p_category_set_id                 => p_category_set_id,
                 p_item_category_id                => p_item_category_id,
                 p_person_id                       => p_person_id,
                 p_person_resource_id              => p_person_resource_id,
                 p_equipment_type_id               => p_equipment_type_id,
                 p_machine_resource_id             => p_machine_resource_id,
                 p_machine_instance                => p_machine_instance,
                 p_user_task_type_id               => p_user_task_type_id,
                 p_from_task_quantity              => p_from_task_quantity,
                 p_to_task_quantity                => p_to_task_quantity,
                 p_from_task_priority              => p_from_task_priority,
                 p_to_task_priority                => p_to_task_priority,
                 p_from_creation_date              => p_from_creation_date,
                 p_to_creation_date                => p_to_creation_date,
                 p_is_unreleased_task              => p_is_unreleased,
                 p_is_pending_task                 => p_is_pending,
                 p_is_queued_task                  => p_is_queued,
                 p_is_dispatched_task              => p_is_dispatched,
                 p_is_active_task                  => p_is_active,
                 p_is_loaded_task                  => p_is_loaded,
                 p_is_completed_task               => p_is_completed,
                 p_include_inbound                 => p_include_inbound,
                 p_include_outbound                => p_include_outbound,
                 p_include_crossdock               => p_include_crossdock,
                 p_include_manufacturing           => p_include_manufacturing,
                 p_include_warehousing             => p_include_warehousing,
                 p_from_po_header_id               => p_from_po_header_id,
                 p_to_po_header_id                 => p_to_po_header_id,
                 p_from_purchase_order             => p_from_purchase_order,
                 p_to_purchase_order               => p_to_purchase_order,
                 p_from_rma_header_id              => p_from_rma_header_id,
                 p_to_rma_header_id                => p_to_rma_header_id,
                 p_from_rma                        => p_from_rma,
                 p_to_rma                          => p_to_rma,
                 p_from_requisition_header_id      => p_from_requisition_header_id,
                 p_to_requisition_header_id        => p_to_requisition_header_id,
                 p_from_requisition                => p_from_requisition,
                 p_to_requisition                  => p_to_requisition,
                 p_from_shipment_number            => p_from_shipment_number,
                 p_to_shipment_number              => p_to_shipment_number,
                 p_include_sales_orders            => p_include_sales_orders,
                 p_include_internal_orders         => p_include_internal_orders,
                 p_from_sales_order_id             => p_from_sales_order_id,
                 p_to_sales_order_id               => p_to_sales_order_id,
                 p_from_pick_slip_number           => p_from_pick_slip_number,
                 p_to_pick_slip_number             => p_to_pick_slip_number,
                 p_customer_id                     => p_customer_id,
                 p_customer_category               => p_customer_category,
                 p_delivery_id                     => p_delivery_id,
                 p_carrier_id                      => p_carrier_id,
                 p_ship_method                     => p_ship_method,
                 p_shipment_priority               => p_shipment_priority,
                 p_trip_id                         => p_trip_id,
                 p_from_shipment_date              => p_from_shipment_date,
                 p_to_shipment_date                => p_to_shipment_date,
                 p_ship_to_state                   => p_ship_to_state,
                 p_ship_to_country                 => p_ship_to_country,
                 p_ship_to_postal_code             => p_ship_to_postal_code,
                 p_from_number_of_order_lines      => p_from_number_of_order_lines,
                 p_to_number_of_order_lines        => p_to_number_of_order_lines,
                 p_manufacturing_type              => p_manufacturing_type,
                 p_from_job                        => p_from_job,
                 p_to_job                          => p_to_job,
                 p_assembly_id                     => p_assembly_id,
                 p_from_start_date                 => p_from_start_date,
                 p_to_start_date                   => p_to_start_date,
                 p_from_line                       => p_from_line,
                 p_to_line                         => p_to_line,
                 p_department_id                   => p_department_id,
                 p_include_replenishment           => p_include_replenishment,
                 p_from_replenishment_mo           => p_from_replenishment_mo,
                 p_to_replenishment_mo             => p_to_replenishment_mo,
                 p_include_mo_transfer             => p_include_mo_transfer,
                 p_include_mo_issue                => p_include_mo_issue,
                 p_from_transfer_issue_mo          => p_from_transfer_issue_mo,
                 p_to_transfer_issue_mo            => p_to_transfer_issue_mo,
                 p_include_lpn_putaway             => p_include_lpn_putaway,
                 p_include_staging_move            => p_include_staging_move,
                 p_include_cycle_count             => p_include_cycle_count,
                 p_cycle_count_name                => p_cycle_count_name,
                 p_query_independent_tasks         => p_query_independent_tasks,
                 p_query_planned_tasks             => p_query_planned_tasks,
                 p_is_pending_plan                 => p_is_pending_plan,
                 p_is_inprogress_plan              => p_is_inprogress_plan,
                 p_is_completed_plan               => p_is_completed_plan,
                 p_is_cancelled_plan               => p_is_cancelled_plan,
                 p_is_aborted_plan                 => p_is_aborted_plan,
                 p_activity_id                     => p_activity_id,
                 p_plan_type_id                    => p_plan_type_id,
                 p_op_plan_id                      => p_op_plan_id
                );

      IF p_include_inbound OR p_include_crossdock
      THEN
         /* Patchset J - ATF: Call the new procedure
            wms_plan_tasks_pvt.query_inbound_plan_tasks
          */
         DEBUG ('calling wms_plan_tasks_pvt.query_inbound_plan_tasks',
                'query_tasks'
               );
         wms_plan_tasks_pvt.query_inbound_plan_tasks (x_return_status,p_summary_mode);
         g_record_count :=
                g_record_count + wms_plan_tasks_pvt.g_plans_tasks_record_count;
      END IF;

      IF p_include_outbound
   THEN
    --Need the pending status checked to ensure
    --children tasks are always fetched.  We need the children tasks
    --to successfully fetch the parents.
    --If p_is_pending isn't checked, children tasks won't be returned,
    --which means parents tasks won't be fetched either.
    IF NOT p_is_pending THEN
       l_is_pending := TRUE;
    END IF;
               query_outbound_tasks
               (p_add                             => p_add,
                p_organization_id                 => p_organization_id,
                p_subinventory_code               => p_subinventory_code,
                p_locator_id                      => p_locator_id,
                p_to_subinventory_code            => p_to_subinventory_code,
                p_to_locator_id                   => p_to_locator_id,
                p_inventory_item_id               => p_inventory_item_id,
                p_category_set_id                 => p_category_set_id,
                p_item_category_id                => p_item_category_id,
                p_person_id                       => p_person_id,
                p_person_resource_id              => p_person_resource_id,
                p_equipment_type_id               => p_equipment_type_id,
                p_machine_resource_id             => p_machine_resource_id,
                p_machine_instance                => p_machine_instance,
                p_user_task_type_id               => p_user_task_type_id,
                p_from_task_quantity              => p_from_task_quantity,
                p_to_task_quantity                => p_to_task_quantity,
                p_from_task_priority              => p_from_task_priority,
                p_to_task_priority                => p_to_task_priority,
                p_from_creation_date              => p_from_creation_date,
                p_to_creation_date                => p_to_creation_date,
                p_is_unreleased                   => p_is_unreleased,
                p_is_pending                      => l_is_pending,
                p_is_queued                       => p_is_queued,
                p_is_dispatched                   => p_is_dispatched,
                p_is_active                       => p_is_active,
                p_is_loaded                       => p_is_loaded,
                p_is_completed                    => p_is_completed,
                p_include_internal_orders         => p_include_internal_orders,
                p_include_sales_orders            => p_include_sales_orders,
                p_from_sales_order_id             => p_from_sales_order_id,
                p_to_sales_order_id               => p_to_sales_order_id,
                p_from_pick_slip_number           => p_from_pick_slip_number,
                p_to_pick_slip_number             => p_to_pick_slip_number,
                p_customer_id                     => p_customer_id,
                p_customer_category               => p_customer_category,
                p_delivery_id                     => p_delivery_id,
                p_carrier_id                      => p_carrier_id,
                p_ship_method                     => p_ship_method,
                p_shipment_priority               => p_shipment_priority,
                p_trip_id                         => p_trip_id,
                p_from_shipment_date              => p_from_shipment_date,
                p_to_shipment_date                => p_to_shipment_date,
                p_ship_to_state                   => p_ship_to_state,
                p_ship_to_country                 => p_ship_to_country,
                p_ship_to_postal_code             => p_ship_to_postal_code,
                p_from_number_of_order_lines      => p_from_number_of_order_lines,
                p_to_number_of_order_lines        => p_to_number_of_order_lines,
               -- R12: Additional query criteria
               p_item_type_code                   =>  p_item_type_code,
               p_age_uom_code                     =>  p_age_uom_code,
               p_age_min                          =>  p_age_min,
               p_age_max                          =>  p_age_max,
               p_order_type_id                    =>  p_order_type_id,
               p_time_till_shipment_uom_code      =>  p_time_till_shipment_uom_code,
               p_time_till_shipment               =>  p_time_till_shipment,
               p_time_till_appt_uom_code          =>  p_time_till_appt_uom_code,
               p_time_till_appt                   =>  p_time_till_appt,
	       p_summary_mode			  =>  p_summary_mode
		,p_wave_header_id                   => p_wave_header_id
               );
      END IF;

      IF p_include_manufacturing
      THEN
         query_manufacturing_tasks
                           (p_add                       => p_add,
                            p_organization_id           => p_organization_id,
                            p_subinventory_code         => p_subinventory_code,
                            p_locator_id                => p_locator_id,
                            p_to_subinventory_code      => p_to_subinventory_code,
                            p_to_locator_id             => p_to_locator_id,
                            p_inventory_item_id         => p_inventory_item_id,
                            p_category_set_id           => p_category_set_id,
                            p_item_category_id          => p_item_category_id,
                            p_person_id                 => p_person_id,
                            p_person_resource_id        => p_person_resource_id,
                            p_equipment_type_id         => p_equipment_type_id,
                            p_machine_resource_id       => p_machine_resource_id,
                            p_machine_instance          => p_machine_instance,
                            p_user_task_type_id         => p_user_task_type_id,
                            p_from_task_quantity        => p_from_task_quantity,
                            p_to_task_quantity          => p_to_task_quantity,
                            p_from_task_priority        => p_from_task_priority,
                            p_to_task_priority          => p_to_task_priority,
                            p_from_creation_date        => p_from_creation_date,
                            p_to_creation_date          => p_to_creation_date,
                            p_is_unreleased             => p_is_unreleased,
                            p_is_pending                => p_is_pending,
                            p_is_queued                 => p_is_queued,
                            p_is_dispatched             => p_is_dispatched,
                            p_is_active                 => p_is_active,
                            p_is_loaded                 => p_is_loaded,
                            p_is_completed              => p_is_completed,
                            p_manufacturing_type        => p_manufacturing_type,
                            p_from_job                  => p_from_job,
                            p_to_job                    => p_to_job,
                            p_assembly_id               => p_assembly_id,
                            p_from_start_date           => p_from_start_date,
                            p_to_start_date             => p_to_start_date,
                            p_from_line                 => p_from_line,
                            p_to_line                   => p_to_line,
                            p_department_id             => p_department_id,
                           -- R12: Additional query criteria
                           p_item_type_code             =>  p_item_type_code,
                           p_age_uom_code               =>  p_age_uom_code,
                           p_age_min                    =>  p_age_min,
                           p_age_max                    =>  p_age_max,
			   p_summary_mode		=>  p_summary_mode
                           );
      END IF;

      IF p_include_warehousing
      THEN
         -- Check for the replenishment, move order issuem, moxfer and cycle count tasks
         IF    p_include_replenishment
            OR p_include_mo_issue
            OR p_include_mo_transfer
         THEN
            query_mo_tasks
                       (p_add                         => p_add,
                        p_organization_id             => p_organization_id,
                        p_subinventory_code           => p_subinventory_code,
                        p_locator_id                  => p_locator_id,
                        p_to_subinventory_code        => p_to_subinventory_code,
                        p_to_locator_id               => p_to_locator_id,
                        p_inventory_item_id           => p_inventory_item_id,
                        p_category_set_id             => p_category_set_id,
                        p_item_category_id            => p_item_category_id,
                        p_person_id                   => p_person_id,
                        p_person_resource_id          => p_person_resource_id,
                        p_equipment_type_id           => p_equipment_type_id,
                        p_machine_resource_id         => p_machine_resource_id,
                        p_machine_instance            => p_machine_instance,
                        p_user_task_type_id           => p_user_task_type_id,
                        p_from_task_quantity          => p_from_task_quantity,
                        p_to_task_quantity            => p_to_task_quantity,
                        p_from_task_priority          => p_from_task_priority,
                        p_to_task_priority            => p_to_task_priority,
                        p_from_creation_date          => p_from_creation_date,
                        p_to_creation_date            => p_to_creation_date,
                        p_is_unreleased               => p_is_unreleased,
                        p_is_pending                  => p_is_pending,
                        p_is_queued                   => p_is_queued,
                        p_is_dispatched               => p_is_dispatched,
                        p_is_active                   => p_is_active,
                        p_is_loaded                   => p_is_loaded,
                        p_is_completed                => p_is_completed,
                        p_include_replenishment       => p_include_replenishment,
                        p_from_replenishment_mo       => p_from_replenishment_mo,
                        p_to_replenishment_mo         => p_to_replenishment_mo,
                        p_include_mo_issue            => p_include_mo_issue,
                        p_include_mo_transfer         => p_include_mo_transfer,
                        p_from_transfer_issue_mo      => p_from_transfer_issue_mo,
                        p_to_transfer_issue_mo        => p_to_transfer_issue_mo,
                        p_include_lpn_putaway         => p_include_lpn_putaway,
                        -- R12: Additional query criteria
                        p_item_type_code             =>  p_item_type_code,
                        p_age_uom_code               =>  p_age_uom_code,
                        p_age_min                    =>  p_age_min,
                        p_age_max                    =>  p_age_max,
			p_summary_mode		     =>  p_summary_mode
                       );
         END IF;

         IF p_include_staging_move OR p_include_lpn_putaway
         THEN
            query_move_tasks
                          (p_add                         => p_add,
                           p_organization_id             => p_organization_id,
                           p_subinventory_code           => p_subinventory_code,
                           p_locator_id                  => p_locator_id,
                           p_to_subinventory_code        => p_to_subinventory_code,
                           p_to_locator_id               => p_to_locator_id,
                           p_inventory_item_id           => p_inventory_item_id,
                           p_category_set_id             => p_category_set_id,
                           p_item_category_id            => p_item_category_id,
                           p_person_id                   => p_person_id,
                           p_person_resource_id          => p_person_resource_id,
                           p_equipment_type_id           => p_equipment_type_id,
                           p_machine_resource_id         => p_machine_resource_id,
                           p_machine_instance            => p_machine_instance,
                           p_user_task_type_id           => p_user_task_type_id,
                           p_from_task_quantity          => p_from_task_quantity,
                           p_to_task_quantity            => p_to_task_quantity,
                           p_from_task_priority          => p_from_task_priority,
                           p_to_task_priority            => p_to_task_priority,
                           p_from_creation_date          => p_from_creation_date,
                           p_to_creation_date            => p_to_creation_date,
                           p_include_staging_move        => p_include_staging_move,
                           p_include_inventory_move      => p_include_lpn_putaway,
                           p_is_unreleased               => p_is_unreleased,
                           p_is_pending                  => p_is_pending,
                           p_is_queued                   => p_is_queued,
                           p_is_dispatched               => p_is_dispatched,
                           p_is_active                   => p_is_active,
                           p_is_loaded                   => p_is_loaded,
                           p_is_completed                => p_is_completed,
                           -- R12: Additional query criteria
                           p_item_type_code             =>  p_item_type_code,
                           p_age_uom_code               =>  p_age_uom_code,
                           p_age_min                    =>  p_age_min,
                           p_age_max                    =>  p_age_max
                          );
         END IF;

         IF p_include_cycle_count
         THEN
            query_cycle_count_tasks
                           (p_add                       => p_add,
                            p_organization_id           => p_organization_id,
                            p_subinventory_code         => p_subinventory_code,
                            p_locator_id                => p_locator_id,
                            p_to_subinventory_code      => p_to_subinventory_code,
                            p_to_locator_id             => p_to_locator_id,
                            p_inventory_item_id         => p_inventory_item_id,
                            p_category_set_id           => p_category_set_id,
                            p_item_category_id          => p_item_category_id,
                            p_person_id                 => p_person_id,
                            p_person_resource_id        => p_person_resource_id,
                            p_equipment_type_id         => p_equipment_type_id,
                            p_machine_resource_id       => p_machine_resource_id,
                            p_machine_instance          => p_machine_instance,
                            p_user_task_type_id         => p_user_task_type_id,
                            p_from_task_quantity        => p_from_task_quantity,
                            p_to_task_quantity          => p_to_task_quantity,
                            p_from_task_priority        => p_from_task_priority,
                            p_to_task_priority          => p_to_task_priority,
                            p_from_creation_date        => p_from_creation_date,
                            p_to_creation_date          => p_to_creation_date,
                            p_cycle_count_name          => p_cycle_count_name,
                            p_is_pending                => p_is_pending,
                            p_is_queued                 => p_is_queued,
                            p_is_dispatched             => p_is_dispatched,
                            p_is_active                 => p_is_active,
                            p_is_completed              => p_is_completed,
                           -- R12: Additional query criteria
                           p_item_type_code             =>  p_item_type_code,
                           p_age_uom_code               =>  p_age_uom_code,
                           p_age_min                    =>  p_age_min,
                           p_age_max                    =>  p_age_max,
			   p_summary_mode		=>  p_summary_mode
                           );
         END IF;
      END IF;

      IF    p_include_outbound
         OR p_include_manufacturing
         OR (    p_include_warehousing
             AND (   p_include_replenishment
                  OR p_include_mo_transfer
                  OR p_include_mo_issue
                 )
            )
   THEN

         populate_merged_tasks (p_is_unreleased            => p_is_unreleased,
                                p_is_pending               => p_is_pending,
                                p_is_queued                => p_is_queued,
                                p_is_dispatched            => p_is_dispatched,
                                p_is_active                => p_is_active,
                                p_is_loaded                => p_is_loaded,
                                p_is_completed             => p_is_completed,
                                p_from_task_quantity       => p_from_task_quantity,
                                p_to_task_quantity         => p_to_task_quantity,
				p_person_id                => p_person_id,		/* Bug 5446146 */
				p_person_resource_id       => p_person_resource_id,
				p_equipment_type_id        => p_equipment_type_id,
				p_machine_resource_id      => p_machine_resource_id,
				p_machine_instance         => p_machine_instance,
				p_user_task_type_id        => p_user_task_type_id,     /* End of Bug 5446146 */
                                x_non_complete_parent      => l_parent_inserted
                               );

         /* Bug 5446146 - If Employee is entered and both queued and pending is checked, show only queued tasks
	                  as Employee does not hold good for Pending tasks. Hence delete the unwanted records from WWTT */
	IF ( p_is_queued OR p_is_dispatched OR p_is_active OR p_is_loaded OR p_is_completed
	     AND ( p_is_pending OR p_is_unreleased ) ) AND ( p_person_id IS NOT NULL OR
               p_person_resource_id IS NOT NULL OR
               p_equipment_type_id IS NOT NULL OR
               p_machine_resource_id IS NOT NULL OR
               p_machine_instance IS NOT NULL )
	THEN
	  IF (p_is_pending) THEN
	    l_is_pending := FALSE;
	  ELSE
	    l_is_pending := TRUE;
	  END IF;

	--Bug#8485284
	  IF (p_is_unreleased) THEN
		IF l_debug = 1 THEN
		   debug('Deleting unreleased tasks','query_tasks');
		END IF;

		DELETE FROM wms_waveplan_tasks_temp
		   WHERE status_id = 8;

		g_wms_task_summary_tbl(g_task_type_pick).task_count := g_wms_task_summary_tbl(g_task_type_pick).task_count - SQL%ROWCOUNT;
		--subtract the same from the summary information
		g_record_count := g_record_count - SQL%ROWCOUNT;
    	  END IF;

       END IF;
       /* End of Bug 5446146 */

    --Unwanted Pending tasks may have been returned since we always
    --queried outbound pending tasks to ensure children tasks are returned.
    --Below is to delete those from the temp table.
    IF l_is_pending <> p_is_pending THEN
       IF l_debug = 1 THEN
          debug('Done populating merged tasks.  Delete unwanted tasks','query_tasks');
       END IF;

       DELETE FROM wms_waveplan_tasks_temp
         WHERE status_id = 1;

	g_wms_task_summary_tbl(g_task_type_pick).task_count := g_wms_task_summary_tbl(g_task_type_pick).task_count - SQL%ROWCOUNT; --subtract the same from the summary information
       g_record_count := g_record_count - SQL%ROWCOUNT;
    END IF;

    IF l_debug = 1 THEN
	    FOR i IN 1..8 LOOP
		debug('Task type :' || g_wms_task_summary_tbl(i).wms_task_type, 'query_tasks');
		debug('TaskCount :' || g_wms_task_summary_tbl(i).task_count, 'query_tasks');
	    END LOOP;
    END IF;


    /* Bug - 5446146 If a user task type has been entered, delete the records which are not associated with a user task type */
    IF p_user_task_type_id IS NOT NULL THEN

         DELETE FROM wms_waveplan_tasks_temp
         WHERE user_task_type_id IS NULL;

	 g_record_count := g_record_count - SQL%ROWCOUNT;
    END IF;
    /* End of Bug 5446146 */

         --Patchset J bulk picking enhancement
         --Bulk pick only apply to outbound and manufacturing
         IF g_num_of_child_tasks_visible = 'T' AND l_parent_inserted > 0
         THEN
            --calculate number of children associated with parent tasks
            set_num_of_child_tasks;
         END IF;
      END IF;

      -- Populate the locator names for project locators
      set_project_locators (p_organization_id => p_organization_id);
      --bug: 4510849
      IF p_include_outbound OR p_include_replenishment OR p_include_mo_issue OR p_include_mo_transfer THEN
         IF p_is_loaded OR p_is_completed THEN
            set_picking_lpns(p_is_loaded => p_is_loaded, p_is_completed => p_is_completed);
         END IF;
      END IF;
      x_record_count := g_record_count;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := 'U';
         x_msg_data := SQLERRM;
   END query_tasks;

   FUNCTION getforcesignonflagvalue (
      p_transaction_temp_id   IN              mtl_material_transactions_temp.transaction_temp_id%TYPE,
      p_device_id             OUT NOCOPY      NUMBER
   )
      RETURN VARCHAR2
   IS
      l_force_sign_on   wms_devices_b.force_sign_on_flag%TYPE;
   BEGIN
      SELECT wms_task_dispatch_device.get_eligible_device
                                                      (mmtt.organization_id,
                                                       mmtt.subinventory_code,
                                                       mmtt.locator_id
                                                      )
        INTO p_device_id
        FROM mtl_material_transactions_temp mmtt
       WHERE mmtt.transaction_temp_id = p_transaction_temp_id;

      SELECT force_sign_on_flag
        INTO l_force_sign_on
        FROM wms_devices_b
       WHERE device_id = p_device_id;

      DEBUG ('l_force_sign_on  : ' || l_force_sign_on, ' FOrce Sign On  :');
      RETURN l_force_sign_on;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END;


   PROCEDURE update_task (
      p_transaction_temp_id     IN              wms_waveplan_tasks_pvt.transaction_temp_table_type,
      p_task_type_id            IN              wms_waveplan_tasks_pvt.task_type_id_table_type,
      p_employee                IN              VARCHAR2,
      p_employee_id             IN              NUMBER,
      p_user_task_type          IN              VARCHAR2,
      p_user_task_type_id       IN              NUMBER,
      p_effective_start_date    IN              DATE,
      p_effective_end_date      IN              DATE,
      p_person_resource_id      IN              NUMBER,
      p_person_resource_code    IN              VARCHAR2,
      p_force_employee_change   IN              BOOLEAN,
      p_to_status               IN              VARCHAR2,
      p_to_status_id            IN              NUMBER,
      p_update_priority_type    IN              VARCHAR2,
      p_update_priority         IN              NUMBER,
      p_clear_priority          IN              VARCHAR2,
      x_result                  OUT NOCOPY      wms_waveplan_tasks_pvt.result_table_type,
      x_message                 OUT NOCOPY      wms_waveplan_tasks_pvt.message_table_type,
      x_task_id                 OUT NOCOPY      wms_waveplan_tasks_pvt.task_id_table_type,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_return_msg              OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER
   )
   IS
      l_task_id                     NUMBER;
      l_index                       NUMBER;
      l_message                     wms_waveplan_tasks_temp.error%TYPE;
      l_debug                       NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

      TYPE status_table_type IS TABLE OF wms_waveplan_tasks_temp.status%TYPE;

      l_transaction_temp_ids        wms_waveplan_tasks_pvt.transaction_temp_table_type;
      l_task_type_ids               wms_waveplan_tasks_pvt.task_type_id_table_type;
      l_statuses                    status_table_type;
      l_messages                    wms_waveplan_tasks_pvt.message_table_type;
      l_transaction_temp_ids_temp   wms_waveplan_tasks_pvt.transaction_temp_table_type;
      l_device_id                   NUMBER;
   BEGIN
      IF g_cannot_update_putaway IS NULL
      THEN
         fnd_message.set_name ('WMS', 'WMS_CANNOT_UPDATE_PUTAWAY_TASK');
         g_cannot_update_putaway := fnd_message.get;
         fnd_message.set_name ('WMS', 'WMS_CANNOT_UPDATE_STAGING_MOVE');
         g_cannot_update_staging_move := fnd_message.get;
         fnd_message.set_name ('WMS', 'WMS_TASK_UPDATED');
         g_task_updated := fnd_message.get;
         fnd_message.set_name ('WMS', 'WMS_CANNOT_UNRELEASE_CC');
         g_cannot_unrelease_cc := fnd_message.get;
      END IF;

      FORALL i IN p_transaction_temp_id.FIRST .. p_transaction_temp_id.LAST
         UPDATE wms_waveplan_tasks_temp
            SET RESULT = 'X'
          WHERE transaction_temp_id = p_transaction_temp_id (i)
            AND task_type_id = p_task_type_id (i);

      -- Validations

      -- 1  Pick
      -- 2  Putaway
      -- 3  Cycle Count
      -- 4  Replenish
      -- 5  Move Order Transfer
      -- 6  Move Order Issue
      -- 7  Staging Move

      -- Cannot update putaway tasks or staging moves
      UPDATE wms_waveplan_tasks_temp
         SET RESULT = 'E',
             error =
                DECODE (task_type_id,
                        2, g_cannot_update_putaway,
                        7, g_cannot_update_staging_move
                       )
       WHERE RESULT = 'X' AND task_type_id IN (2, 7);

      -- Cannot set cycle count tasks to unreleased
      IF p_to_status_id = 8
      THEN
         UPDATE wms_waveplan_tasks_temp
            SET RESULT = 'E',
                error = g_cannot_unrelease_cc
          WHERE RESULT = 'X' AND task_type_id = 3;
      END IF;

      -- Invalid status changes
      IF p_to_status_id IS NOT NULL
      THEN
         SELECT transaction_temp_id, task_type_id, status
         BULK COLLECT INTO l_transaction_temp_ids, l_task_type_ids, l_statuses
           FROM wms_waveplan_tasks_temp
          WHERE RESULT = 'X'
            AND NOT (   (status_id = 8 AND p_to_status_id IN (1, 2)
                        )                   -- Unreleased to pending or queued
                     OR (status_id = 1 AND p_to_status_id IN (2, 8)
                        )                   -- Pending to queued or unreleased
                     OR (status_id = 2 AND p_to_status_id IN (1, 8)
                        )                   -- Queued to pending or unreleased
                     OR (status_id = 9 AND p_to_status_id IN (1, 8)
                        )                   -- R12:Active to Pending or unreleased
                     OR (status_id = 3 AND p_to_status_id IN (1, 8)
                        )                   -- R12:Dispatched to Pending or unreleased
                     OR (status_id = p_to_status_id)
                    );                      -- No Status Change

         IF l_transaction_temp_ids.COUNT > 0
         THEN
            FOR i IN
               l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST
            LOOP
               fnd_message.set_name ('WMS', 'WMS_CANNOT_UPDATE_STATUS');
               fnd_message.set_token ('FROM_STATUS', l_statuses (i));
               fnd_message.set_token ('TO_STATUS', p_to_status);
               l_messages (i) := fnd_message.get;
            END LOOP;

            FORALL i IN l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST
               UPDATE wms_waveplan_tasks_temp
                  SET RESULT = 'E',
                      error = l_messages (i)
                WHERE transaction_temp_id = l_transaction_temp_ids (i)
                  AND task_type_id = l_task_type_ids (i);
         END IF;

         IF p_to_status_id IN (1, 8) THEN

            -- if the original task status is dispatched, check if any of the tasks belonging to
            -- this group is active

	--BUG: 4707588
	SELECT wwtt.transaction_temp_id, wwtt.task_type_id, wwtt.status
		BULK COLLECT INTO l_transaction_temp_ids, l_task_type_ids, l_statuses
		FROM wms_waveplan_tasks_temp wwtt, mtl_material_transactions_temp mmtt, WMS_DISPATCHED_TASKS wdt
		WHERE wwtt.transaction_temp_id = wdt.transaction_temp_id AND
				   wwtt.transaction_temp_id = mmtt.transaction_temp_id AND
		       wwtt.RESULT = 'X' AND
		       wwtt.status_id = 3   AND
		       EXISTS (   SELECT 1 FROM WMS_DISPATCHED_TASKS wdt2
		                  WHERE  wdt2.person_id = wwtt.person_id AND
		                  wdt2.status = 9 AND
				  wdt2.task_method IS NOT NULL AND
				  wdt2.transaction_temp_id IN( SELECT transaction_temp_id FROM mtl_material_transactions_temp mmtt1
				   			       WHERE DECODE(wdt.TASK_METHOD,
							           	'CARTON', mmtt1.cartonization_id,
									'PICK_SLIP', mmtt1.pick_slip_number,
									'DISCRETE', mmtt1.pick_slip_number,
									mmtt1.transaction_source_id) = DECODE(wdt.TASK_METHOD,
										   			'CARTON', mmtt.cartonization_id,
												 	'PICK_SLIP', mmtt.pick_slip_number,
												 	'DISCRETE', mmtt.pick_slip_number,
													mmtt.transaction_source_id))
		           );
            IF l_transaction_temp_ids.COUNT > 0
            THEN
              --BUG: 4707588  (Picking message from msg dictionary)
              FOR i IN
                  l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST
               LOOP
                  fnd_message.set_name ('WMS', 'WMS_GROUP_TASKS_CANNOT_UPDATE');
                  l_messages (i) := fnd_message.get;
               END LOOP;


               FORALL i IN l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST
                  UPDATE wms_waveplan_tasks_temp
                     SET RESULT = 'E',
                         error = 'This group of tasks is currently being worked, cannot change status'
                   WHERE transaction_temp_id = l_transaction_temp_ids (i)
                     AND task_type_id = l_task_type_ids (i);
            END IF;

            -- if the original task status is Active, check if the user whom the task is assigned is
            -- logged on to the system
            SELECT transaction_temp_id, task_type_id, status
            BULK COLLECT INTO l_transaction_temp_ids, l_task_type_ids, l_statuses
              FROM wms_waveplan_tasks_temp wwtt
             WHERE RESULT = 'X' AND
                   status_id = 9 AND
                   EXISTS (   SELECT 1 FROM MTL_MOBILE_LOGIN_HIST MMLH, WMS_DISPATCHED_TASKS WDT
                              WHERE WDT.TRANSACTION_TEMP_ID = WWTT.TRANSACTION_TEMP_ID AND
                                    MMLH.USER_ID = WDT.LAST_UPDATED_BY AND
                                    MMLH.LOGOFF_DATE IS NULL AND
                                    MMLH.EVENT_MESSAGE IS NULL
                               );

            IF l_transaction_temp_ids.COUNT > 0
            THEN
               FORALL i IN l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST
                  UPDATE wms_waveplan_tasks_temp
                     SET RESULT = 'E',
                         error = 'This task is currently being worked, cannot change status'
                   WHERE transaction_temp_id = l_transaction_temp_ids (i)
                     AND task_type_id = l_task_type_ids (i);
            END IF;

         END IF;

      END IF;

      -- Employee eligibility validation
      IF p_employee_id IS NOT NULL AND NOT p_force_employee_change
      THEN
         fnd_message.set_name ('WMS', 'WMS_CANNOT_UPDATE_EMPLOYEE');
         fnd_message.set_token ('EMPLOYEE', p_employee);
         l_message := fnd_message.get;

         UPDATE wms_waveplan_tasks_temp wwtt
            SET RESULT = 'E',
                error = l_message
          WHERE RESULT = 'X'
            AND NOT EXISTS (
                   SELECT 1
                     FROM bom_std_op_resources bsor,
                          bom_resource_employees bre
                    WHERE wwtt.user_task_type_id = bsor.standard_operation_id
                      AND bsor.resource_id = bre.resource_id
                      AND bre.person_id = p_employee_id);

         --j Develop
         SELECT transaction_temp_id
         BULK COLLECT INTO l_transaction_temp_ids_temp
           FROM wms_waveplan_tasks_temp
          WHERE RESULT = 'X';

         IF (l_transaction_temp_ids_temp.COUNT > 0)
         THEN
            FOR i IN
               l_transaction_temp_ids_temp.FIRST .. l_transaction_temp_ids_temp.LAST
            LOOP
               IF (getforcesignonflagvalue (l_transaction_temp_ids_temp (i),
                                            l_device_id
                                           ) = 'Y'
                  )
               THEN
                  fnd_message.set_name ('WMS', 'WMS_CANNOT_UPDATE_EMPLOYEE');
                  fnd_message.set_token ('EMPLOYEE', p_employee);
                  l_message := fnd_message.get;
                  if l_debug = 1 then
		    DEBUG ('l_device_id : ' || l_device_id, ' Update_TAsk :');
                    DEBUG (' p_employee_id : ' || p_employee_id,
                         ' Update_TAsk :'
                        );
		  end if;

                  UPDATE wms_waveplan_tasks_temp wwtt
                     SET RESULT = 'E',
                         error = l_message
                   WHERE transaction_temp_id = l_transaction_temp_ids_temp (i)
                     AND NOT EXISTS (
                            SELECT 1
                              FROM wms_device_assignment_temp
                             WHERE device_id = l_device_id
                               AND employee_id = p_employee_id);
               END IF;
            END LOOP;
         END IF;
      -- End  of J Develop
      END IF;

      UPDATE wms_waveplan_tasks_temp wwtt
         SET person_resource_id =
                (SELECT bre.resource_id
                   FROM bom_std_op_resources bsor, bom_resource_employees bre
                  WHERE wwtt.user_task_type_id = bsor.standard_operation_id
                    AND bsor.resource_id = bre.resource_id
                    AND bre.person_id = wwtt.person_id
                    AND ROWNUM < 2)
       WHERE RESULT = 'X';

      IF p_user_task_type_id IS NOT NULL
      THEN
         -- R12: Can update User Task Type if task is dispatched, active  IF
         -- Dispatched or Active tasks are in the process of getting updated to pending or Unreleased
         IF p_to_status_id IS NOT NULL THEN
            UPDATE    wms_waveplan_tasks_temp wwtt
                  SET RESULT = 'E',
                      error = l_message
                WHERE RESULT = 'X' AND (status_id NOT IN (1, 2, 3, 8, 9) AND p_to_status_id IN (1, 8))
            RETURNING         transaction_temp_id, task_type_id, status
            BULK COLLECT INTO l_transaction_temp_ids, l_task_type_ids, l_statuses;
         ELSE
            -- R12: Cannot update User Task Type if task is dispatched, active or loaded IF
            -- Dispatched or Active tasks are NOT in the process of getting updated to pending or Unreleased
            UPDATE    wms_waveplan_tasks_temp wwtt
                  SET RESULT = 'E',
                      error = l_message
                WHERE RESULT = 'X' AND status_id NOT IN (1, 8)
            RETURNING         transaction_temp_id, task_type_id, status
            BULK COLLECT INTO l_transaction_temp_ids, l_task_type_ids, l_statuses;
         END IF;

         IF l_transaction_temp_ids.COUNT > 0
         THEN
            FOR i IN
               l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST
            LOOP
               fnd_message.set_name ('WMS', 'WMS_CANNOT_UPDATE_USER_TASK_TYPE');
               fnd_message.set_token ('STATUS', l_statuses (i));
               l_messages (i) := fnd_message.get;
            END LOOP;

            FORALL i IN l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST
               UPDATE wms_waveplan_tasks_temp
                  SET RESULT = 'E',
                      error = l_messages (i)
                WHERE transaction_temp_id = l_transaction_temp_ids (i)
                  AND task_type_id = l_task_type_ids (i);
         END IF;
      END IF;


      IF (p_update_priority_type IS NOT NULL AND p_update_priority IS NOT NULL) OR p_clear_priority = 'Y'
      THEN
         -- R12: Can update priority if task is dispatched, active  IF
         -- Dispatched or Active tasks are in the process of getting updated to pending or Unreleased
         IF p_to_status_id IS NOT NULL THEN
            UPDATE    wms_waveplan_tasks_temp wwtt
                  SET RESULT = 'E',
                      error = l_message
                WHERE RESULT = 'X' AND (status_id NOT IN (1, 2, 3, 8, 9) AND p_to_status_id IN (1, 8))
            RETURNING         transaction_temp_id, task_type_id, status
            BULK COLLECT INTO l_transaction_temp_ids, l_task_type_ids, l_statuses;
         ELSE
            -- R12: Cannot update priority if task is dispatched, active or loaded IF
            -- Dispatched or Active tasks are NOT in the process of getting updated to pending or Unreleased
            UPDATE    wms_waveplan_tasks_temp wwtt
                  SET RESULT = 'E',
                      error = l_message
                WHERE RESULT = 'X' AND status_id NOT IN (1, 2, 8)
            RETURNING         transaction_temp_id, task_type_id, status
            BULK COLLECT INTO l_transaction_temp_ids, l_task_type_ids, l_statuses;
         END IF;

         IF l_transaction_temp_ids.COUNT > 0
         THEN
            FOR i IN
               l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST
            LOOP
               fnd_message.set_name ('WMS', 'WMS_CANNOT_UPDATE_PRIORITY');
               fnd_message.set_token ('STATUS', l_statuses (i));
               l_messages (i) := fnd_message.get;
            END LOOP;

            FORALL i IN l_transaction_temp_ids.FIRST .. l_transaction_temp_ids.LAST
               UPDATE wms_waveplan_tasks_temp
                  SET RESULT = 'E',
                      error = l_messages (i)
                WHERE transaction_temp_id = l_transaction_temp_ids (i)
                  AND task_type_id = l_task_type_ids (i);
         END IF;
      END IF;

      -- If changing status to Queued
      IF p_to_status_id = 2
      THEN
         UPDATE wms_waveplan_tasks_temp
            SET task_id = NVL (task_id, wms_dispatched_tasks_s.NEXTVAL),
                status = p_to_status,
                status_id = p_to_status_id,
                priority =
                   DECODE (p_clear_priority,
                           'Y', NULL,
                           DECODE(p_update_priority_type,
                                 'I', NVL(priority,0) + p_update_priority,             -- R12: Increment priority
                                 'D', DECODE(SIGN(NVL(priority,0) - p_update_priority),-- R12: Decrement priority
                                             -1, 0,
                                             +1, NVL(priority,0) - p_update_priority,
                                              0, 0),
                                 'S', NVL(p_update_priority, priority),	               -- R12: Set       priority
                                  priority)
                          ),
                person = p_employee,
                person_id = p_employee_id,
                effective_start_date = p_effective_start_date,
                effective_end_date = p_effective_end_date,
                person_resource_code = p_person_resource_code,
                person_resource_id = p_person_resource_id,
                RESULT = 'S',
                error = g_task_updated,
                is_modified = 'Y'
          WHERE RESULT = 'X';
      ELSE
         if l_debug = 1 then
	   DEBUG ('Else Part  ______________________: ', ' Update_TAsk :');
         end if;
         UPDATE wms_waveplan_tasks_temp
            SET task_id = DECODE (p_to_status_id, 1, NULL, 8, NULL, task_id),
                status = NVL (p_to_status, status),
                status_id = NVL (p_to_status_id, status_id),
                user_task_type = NVL (p_user_task_type, user_task_type),         -- R12: Assign User Task Type
                user_task_type_id = NVL (p_user_task_type_id, user_task_type_id),-- R12: Assign User Task Type
                priority =
                   DECODE (p_clear_priority,
                           'Y', NULL,
                           DECODE(p_update_priority_type,
                                 'I', NVL(priority,0) + p_update_priority,             -- R12: Increment priority
                                 'D', DECODE(SIGN(NVL(priority,0) - p_update_priority),-- R12: Decrement priority
                                             -1, 0,
                                             +1, NVL(priority,0) - p_update_priority,
                                              0, 0),
                                 'S', NVL(p_update_priority, priority),                -- R12: Set Constant priority value
                                  priority)
                          ),
                person = DECODE (p_to_status_id, 1, NULL, 8, NULL, person),
                person_id =
                          DECODE (p_to_status_id,
                                  1, NULL,
                                  8, NULL,
                                  person_id
                                 ),
                effective_start_date =
                   DECODE (p_to_status_id,
                           1, NULL,
                           8, NULL,
                           effective_start_date
                          ),
                effective_end_date =
                   DECODE (p_to_status_id,
                           1, NULL,
                           8, NULL,
                           effective_end_date
                          ),
                person_resource_code =
                   DECODE (p_to_status_id,
                           1, NULL,
                           8, NULL,
                           person_resource_code
                          ),
                person_resource_id =
                   DECODE (p_person_resource_id,
                           1, NULL,
                           8, NULL,
                           person_resource_id
                          ),
                RESULT = 'S',
                error = g_task_updated,
                is_modified = 'Y'
          WHERE RESULT = 'X';

         if l_debug = 1 then
	   DEBUG ('Else Part : ________________2' || SQL%ROWCOUNT,
                ' Update_TAsk :'
               );
	 end if;
      END IF;

      FORALL i IN p_transaction_temp_id.FIRST .. p_transaction_temp_id.LAST
         UPDATE    wms_waveplan_tasks_temp
               SET RESULT = RESULT
             WHERE transaction_temp_id = p_transaction_temp_id (i)
               AND task_type_id = p_task_type_id (i)
         RETURNING         task_id, RESULT, error
         BULK COLLECT INTO x_task_id, x_result, x_message;
      x_return_status := 'S';
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := 'U';
         x_return_msg := SQLERRM;
         DEBUG ('Sql Error: ' || SQLERRM, 'Task Planning.Task Update');
   END update_task;

   PROCEDURE cancel_task (
      p_transaction_temp_id     IN              wms_waveplan_tasks_pvt.transaction_temp_table_type,
      p_task_type_id            IN              wms_waveplan_tasks_pvt.task_type_id_table_type,
      p_is_crossdock            IN              BOOLEAN DEFAULT FALSE, /* Bug 5623122 */
      x_result                  OUT NOCOPY      wms_waveplan_tasks_pvt.result_table_type,
      x_message                 OUT NOCOPY      wms_waveplan_tasks_pvt.message_table_type,
      x_task_id                 OUT NOCOPY      wms_waveplan_tasks_pvt.task_id_table_type,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_return_msg              OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER
   )
   IS
      l_task_id                     NUMBER;
      l_index                       NUMBER;
      l_message                     wms_waveplan_tasks_temp.error%TYPE;

      TYPE status_table_type IS TABLE OF wms_waveplan_tasks_temp.status%TYPE;

      l_transaction_temp_ids        wms_waveplan_tasks_pvt.transaction_temp_table_type;
      l_task_type_ids               wms_waveplan_tasks_pvt.task_type_id_table_type;
      l_statuses                    status_table_type;
      l_messages                    wms_waveplan_tasks_pvt.message_table_type;
      l_transaction_temp_ids_temp   wms_waveplan_tasks_pvt.transaction_temp_table_type;
   BEGIN

      /*IF g_cannot_update_putaway IS NULL
      THEN
         fnd_message.set_name ('WMS', 'WMS_CANNOT_UPDATE_PUTAWAY_TASK');
         g_cannot_update_putaway := fnd_message.get;
         fnd_message.set_name ('WMS', 'WMS_CANNOT_UPDATE_STAGING_MOVE');
         g_cannot_update_staging_move := fnd_message.get;
         fnd_message.set_name ('WMS', 'WMS_TASK_UPDATED');
         g_task_updated := fnd_message.get;
         fnd_message.set_name ('WMS', 'WMS_CANNOT_UNRELEASE_CC');
         g_cannot_unrelease_cc := fnd_message.get;
      END IF;*/


      FORALL i IN p_transaction_temp_id.FIRST .. p_transaction_temp_id.LAST
         UPDATE wms_waveplan_tasks_temp
            SET RESULT = 'X'
          WHERE transaction_temp_id = p_transaction_temp_id (i)
            AND task_type_id = p_task_type_id (i);

      -- Validations
      -- 1  Pick
      -- 2  Putaway
      -- 3  Cycle Count
      -- 4  Replenish
      -- 5  Move Order Transfer
      -- 6  Move Order Issue
      -- 7  Staging Move

      -- Cannot update the following :
      UPDATE wms_waveplan_tasks_temp
         SET RESULT = 'E',
             error =
                DECODE (task_type_id,
                        1, 'Can not cancel pick task',
                        3, 'Can not cancel cycle count task',
                        4, 'Can not cancel replenish task',
                        5, 'Can not cancel move order transfer task',
                        6, 'Can not cancel move order issue task',
                        7, 'Can not cancel staging move task'
                       )
       WHERE RESULT = 'X' AND task_type_id <> 2;

      /* Bug 5623122 */
      -- Cannot update Putaway tasks
      IF NOT p_is_crossdock THEN
        UPDATE wms_waveplan_tasks_temp
           SET RESULT = 'E',
             error =
                DECODE (task_type_id,
                        2, 'Can not cancel putaway task'
                       )
         WHERE RESULT = 'X' AND task_type_id = 2;
      END IF;
      /* End of Bug 5623122 */

      -- cannot update completed tasks
      UPDATE wms_waveplan_tasks_temp
         SET RESULT = 'E',
             error =  'Can not cancel completed tasks'
       WHERE RESULT = 'X' AND status_id = 6;

      UPDATE wms_waveplan_tasks_temp
         SET status_id = 12,
             status = g_status_codes(12),
             is_modified = 'Y',
             RESULT = 'S',
             error = 'Task Canceled'
       WHERE RESULT = 'X';

      FORALL i IN p_transaction_temp_id.FIRST .. p_transaction_temp_id.LAST
         UPDATE    wms_waveplan_tasks_temp
               SET RESULT = RESULT
             WHERE transaction_temp_id = p_transaction_temp_id (i)
               AND task_type_id = p_task_type_id (i)
         RETURNING         task_id, RESULT, error
         BULK COLLECT INTO x_task_id, x_result, x_message;
      x_return_status := 'S';
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := 'U';
         x_return_msg := SQLERRM;
         DEBUG ('Sql Error: ' || SQLERRM, 'Task Planning.Cancel Task');
   END cancel_task;

   PROCEDURE remove_tasks (
      p_transaction_temp_id   IN              wms_waveplan_tasks_pvt.transaction_temp_table_type,
      x_record_count          OUT NOCOPY      NUMBER,
      x_return_status         OUT NOCOPY      VARCHAR2,
      x_msg_data              OUT NOCOPY      VARCHAR2
   )
   IS
      l_removed_count   NUMBER := 0;
   BEGIN
      x_return_status := 'S';
      FORALL i IN p_transaction_temp_id.FIRST .. p_transaction_temp_id.LAST
         DELETE FROM wms_waveplan_tasks_temp
               WHERE transaction_temp_id = p_transaction_temp_id (i);
      l_removed_count := SQL%ROWCOUNT;
      g_record_count := g_record_count - l_removed_count;
      x_record_count := g_record_count;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := 'U';
         x_msg_data := SQLERRM;
   END remove_tasks;

   PROCEDURE save_tasks (
      p_task_action                  VARCHAR2,
      p_commit                       BOOLEAN,
      p_user_id                      NUMBER,
      p_login_id                     NUMBER,
      x_save_count      OUT NOCOPY   NUMBER,
      x_return_status   OUT NOCOPY   VARCHAR2,
      x_msg_data        OUT NOCOPY   VARCHAR2,
      x_msg_count       OUT NOCOPY   NUMBER
   )
   IS
      TYPE transaction_temp_id_table_type IS TABLE OF mtl_material_transactions_temp.transaction_temp_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE wms_task_status_table_type IS TABLE OF mtl_material_transactions_temp.wms_task_status%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE task_priority_table_type IS TABLE OF mtl_material_transactions_temp.task_priority%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE person_id_table_type IS TABLE OF wms_dispatched_tasks.person_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE person_resource_id_table_type IS TABLE OF wms_dispatched_tasks.person_resource_id%TYPE  /* Bug 5630187 */
         INDEX BY BINARY_INTEGER;

      TYPE effective_start_date IS TABLE OF wms_dispatched_tasks.effective_start_date%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE effective_end_date IS TABLE OF wms_dispatched_tasks.effective_end_date%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE task_type_id IS TABLE OF wms_waveplan_tasks_temp.task_type_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE user_task_type_id IS TABLE OF wms_waveplan_tasks_temp.user_task_type_id%TYPE   -- R12: Update User Task Type Id
         INDEX BY BINARY_INTEGER;

      l_transaction_temp_id_table    transaction_temp_id_table_type;
      l_wms_task_status_table        wms_task_status_table_type;
      l_task_priority_table          task_priority_table_type;
      l_person_id_table              person_id_table_type;
      l_person_resource_id_table     person_resource_id_table_type; /* Bug 5630187 */
      l_effective_start_date_table   effective_start_date;
      l_effective_end_date_table     effective_end_date;
      l_task_type_id                 task_type_id;
      l_user_task_type_id            user_task_type_id;         -- R12: Update User Task Type Id
      l_error_message                VARCHAR2 (120);
      l_update_date                  DATE;
      l_non_cycle_count_number       NUMBER                         := 0;
      l_cycle_count_number           NUMBER                         := 0;
      l_children_task_count          NUMBER                         := 0;
      l_debug			     NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

      CURSOR cur_wwtt
      IS
         SELECT transaction_temp_id, task_type_id, mmtt_last_updated_by,
                mmtt_last_update_date, wdt_last_updated_by,
                wdt_last_update_date, person_id, person_id_original,person_resource_id,/* Bug 5630187 - Added person_resource_id */
                effective_start_date, effective_end_date, status_id,
                status_id_original, priority, priority_original, user_task_type_id, num_of_child_tasks  -- R12: Added User Task Type Id
           FROM wms_waveplan_tasks_temp wwtt
          WHERE wwtt.is_modified = 'Y';

      --Patchset J: Bulk picking
      --Get the transaction_temp_id of the children tasks
      CURSOR bulk_children_tasks_cur(trx_temp_id NUMBER)
   IS
      SELECT transaction_temp_id
        FROM mtl_material_transactions_temp
        WHERE parent_line_id = trx_temp_id
        AND transaction_temp_id <> trx_temp_id
        FOR UPDATE nowait;
      --end bulk picking

      i                              NUMBER;
      record_locked                  EXCEPTION;
      PRAGMA EXCEPTION_INIT (record_locked, -54);
   BEGIN
      x_return_status := 'S';
      x_save_count := 0;
      SAVEPOINT save_tasks;
      wwtt_dump;
      i := 1;

      IF p_task_action = 'U' THEN -- Update tasks

      FOR rec_wwtt IN cur_wwtt
      LOOP
         BEGIN
            IF rec_wwtt.task_type_id IN (2, 8) AND rec_wwtt.status_id = 12 THEN
               if l_debug = 1 then
      	         DEBUG ('Cancelled Plan');
	       end if;

               x_save_count := x_save_count + 1;
               if l_debug = 1 then
	         DEBUG ('no of records saved are' || x_save_count);
               end if;

               IF g_plan_cancelled IS NULL THEN
                fnd_message.set_name ('WMS', 'WMS_PLAN_CANCELLED');
                g_plan_cancelled := fnd_message.get;
               END IF;


               UPDATE wms_waveplan_tasks_temp
                  SET is_modified = 'N',
                  RESULT = 'S',
                   error = g_plan_cancelled
                WHERE transaction_temp_id = rec_wwtt.transaction_temp_id;

             END IF;

	    if l_debug = 1 then
              DEBUG ('In the wwtt for loop');
	    end if;

            IF rec_wwtt.task_type_id <> 3
            THEN
               SELECT     mmtt.transaction_temp_id
                     INTO l_transaction_temp_id_table (i)
                     FROM mtl_material_transactions_temp mmtt,
                          wms_dispatched_tasks wdt
                    WHERE mmtt.transaction_temp_id =
                                                  rec_wwtt.transaction_temp_id
                      AND mmtt.transaction_temp_id = wdt.transaction_temp_id(+)
                      AND mmtt.wms_task_type = wdt.task_type(+)
                      AND DECODE (wdt.status,
                                  NULL, NVL (mmtt.wms_task_status, 1),
                                  wdt.status
                                 ) = NVL (rec_wwtt.status_id_original, -1)
                      AND NVL (mmtt.task_priority, -1) =
                                           NVL (rec_wwtt.priority_original,
                                                -1)
                      AND NVL (wdt.person_id, -1) =
                                          NVL (rec_wwtt.person_id_original,
                                               -1)
                      AND mmtt.last_updated_by = rec_wwtt.mmtt_last_updated_by
                      AND mmtt.last_update_date =
                                                rec_wwtt.mmtt_last_update_date
                      AND NVL (wdt.last_updated_by, -1) =
                                         NVL (rec_wwtt.wdt_last_updated_by,
                                              -1)
                      AND (   wdt.last_update_date =
                                                 rec_wwtt.wdt_last_update_date
                           OR (    wdt.last_update_date IS NULL
                               AND rec_wwtt.wdt_last_update_date IS NULL
                              )
                          )
               FOR UPDATE NOWAIT;

               l_non_cycle_count_number := l_non_cycle_count_number + 1;
            ELSE
               SELECT     mcce.cycle_count_entry_id
                     INTO l_transaction_temp_id_table (i)
                     FROM mtl_cycle_count_entries mcce,
                          wms_dispatched_tasks wdt
                    WHERE mcce.cycle_count_entry_id =
                                                  rec_wwtt.transaction_temp_id
                      AND mcce.cycle_count_entry_id = wdt.transaction_temp_id(+)
                      AND 3 = wdt.task_type(+)
                      AND DECODE (wdt.status, NULL, 1, wdt.status) =
                                          NVL (rec_wwtt.status_id_original,
                                               -1)
                      AND NVL (mcce.task_priority, -1) =
                                           NVL (rec_wwtt.priority_original,
                                                -1)
                      AND NVL (wdt.person_id, -1) =
                                          NVL (rec_wwtt.person_id_original,
                                               -1)
                      AND mcce.last_updated_by = rec_wwtt.mmtt_last_updated_by
                      AND mcce.last_update_date =
                                                rec_wwtt.mmtt_last_update_date
                      AND NVL (wdt.last_updated_by, -1) =
                                         NVL (rec_wwtt.wdt_last_updated_by,
                                              -1)
                      AND (   wdt.last_update_date =
                                                 rec_wwtt.wdt_last_update_date
                           OR (    wdt.last_update_date IS NULL
                               AND rec_wwtt.wdt_last_update_date IS NULL
                              )
                          )
               FOR UPDATE NOWAIT;

               l_cycle_count_number := l_cycle_count_number + 1;
            END IF;

            l_wms_task_status_table (i) := rec_wwtt.status_id;
            l_task_priority_table (i) := rec_wwtt.priority;
            l_person_id_table (i) := rec_wwtt.person_id;
	    l_person_resource_id_table (i) := rec_wwtt.person_resource_id;
            l_effective_start_date_table (i) := sysdate ; -- rec_wwtt.effective_start_date; --bug#6409956
            l_effective_end_date_table (i) := sysdate ; --rec_wwtt.effective_end_date; --bug#6409956
            l_task_type_id (i) := rec_wwtt.task_type_id;
            l_user_task_type_id (i) := rec_wwtt.user_task_type_id;  -- R12: Update User Task Type Id
            i := i + 1;

       --Patchset J bulk picking
       --If updating a bulk tasks, update the children tasks also.
       --Condition to check if it's a bulk task is with the
       --num_of_child_task column.
       --Bulk task should always have children tasks
       IF rec_wwtt.num_of_child_tasks IS NOT NULL
         AND rec_wwtt.num_of_child_tasks > 0 THEN
          FOR bulk_children IN bulk_children_tasks_cur(l_transaction_temp_id_table(i-1))
       LOOP
          l_transaction_temp_id_table(i) :=
            bulk_children.transaction_temp_id;

          l_wms_task_status_table (i) := rec_wwtt.status_id;
          l_task_priority_table (i) := rec_wwtt.priority;
          l_person_id_table (i) := rec_wwtt.person_id;
	  l_person_resource_id_table (i) := rec_wwtt.person_resource_id;
          l_effective_start_date_table (i) := sysdate ; -- rec_wwtt.effective_start_date; --bug#6409956
          l_effective_end_date_table (i) := sysdate ; --rec_wwtt.effective_end_date; --bug#6409956
          l_task_type_id (i) := rec_wwtt.task_type_id;
          l_user_task_type_id (i) := rec_wwtt.user_task_type_id;  -- R12: Update User Task Type Id
          i := i + 1;
          l_children_task_count := l_children_task_count + 1;
       END LOOP;
       END IF;
       --/bulk picking
         EXCEPTION
            WHEN record_locked
            THEN
               NULL;
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;
      END LOOP;

      x_save_count := x_save_count + l_transaction_temp_id_table.COUNT - l_children_task_count;

      if l_debug = 1 then
        DEBUG ('Save Count is ' || x_save_count);
      end if;

      -- IF l_transaction_temp_id_table.COUNT > 0 THEN
      IF x_save_count > 0
      THEN
         if l_debug = 1 then
	   DEBUG ('Save Count is ' || x_save_count);
         end if;

         IF l_non_cycle_count_number > 0
         THEN
            FORALL i IN l_transaction_temp_id_table.FIRST .. l_transaction_temp_id_table.LAST
               UPDATE mtl_material_transactions_temp
                  SET wms_task_status =
                         DECODE (l_wms_task_status_table (i),
                                 8, 8,
                                 1, 1,
                                 NULL
                                ),
                      task_priority = l_task_priority_table (i),
                      last_update_date = SYSDATE,
                      last_updated_by = p_user_id,
                      last_update_login = p_login_id,
                      standard_operation_id = l_user_task_type_id (i)
                WHERE transaction_temp_id = l_transaction_temp_id_table (i)   -- R12: Update User Task Type Id
                  AND l_task_type_id (i) <> 3;
            if l_debug = 1 then
	      DEBUG ('No of records updated are-777 ' || SQL%ROWCOUNT);
	    end if;
         END IF;

         IF l_cycle_count_number > 0 THEN
            FORALL i IN l_transaction_temp_id_table.FIRST .. l_transaction_temp_id_table.LAST
               UPDATE mtl_cycle_count_entries
                  SET task_priority = l_task_priority_table (i),
                      last_update_date = SYSDATE,
                      last_updated_by = p_user_id,
                      last_update_login = p_login_id,
                      standard_operation_id = l_user_task_type_id (i)         -- R12: Update User Task Type Id
                WHERE cycle_count_entry_id = l_transaction_temp_id_table (i)
                  AND l_task_type_id (i) = 3;
            if l_debug = 1 then
	      DEBUG ('No of records updated are-666 ' || SQL%ROWCOUNT);
	    end if;
         END IF;

         -- Delete WDT line for tasks that were queued but now are pending or unreleased
         DELETE      wms_dispatched_tasks wdt
               WHERE wdt.status IN (2, 3, 9) -- R12: Delete the Active or Dispatched tasks which were updated to pending/Unreleased
                 AND wdt.transaction_temp_id IN (
                        SELECT transaction_temp_id
                          FROM wms_waveplan_tasks_temp wwtt
                         WHERE wwtt.status_id IN (1, 8)
                           AND wwtt.is_modified = 'Y');
	 if l_debug = 1 then
           DEBUG ('No of records deleted are-555 ' || SQL%ROWCOUNT);
	 end if;

         l_update_date := SYSDATE;
	 if l_debug = 1 then
           DEBUG ('inserting into WDT ' || x_save_count);
	 end if;

         -- Insert into WDT tasks that have become queued from pending or unreleased
         INSERT INTO wms_dispatched_tasks
                     (task_id, transaction_temp_id, organization_id,
                      user_task_type, person_id, effective_start_date,
                      effective_end_date, person_resource_id,
                      machine_resource_id, status, dispatched_time,
                      last_update_date, last_updated_by, creation_date,
                      created_by, last_update_login, task_type, priority,
                      move_order_line_id, operation_plan_id, transfer_lpn_id)
            (SELECT wwtt.task_id, wwtt.transaction_temp_id,
                    wwtt.organization_id, NVL (wwtt.user_task_type_id, 0),
                    wwtt.person_id,sysdate, sysdate ,  /*bug#6409956.replaced effective dates by sysdate */
		    wwtt.person_resource_id, NULL, 2, -- Queued
                    NULL, l_update_date, p_user_id, l_update_date, p_user_id,
                    p_login_id, wwtt.task_type_id, wwtt.priority,
                    wwtt.move_order_line_id, wwtt.operation_plan_id,
                    wwtt.to_lpn_id
               FROM wms_waveplan_tasks_temp wwtt
              WHERE wwtt.status_id = 2
                AND wwtt.status_id_original IN (1, 8)
                AND wwtt.is_modified = 'Y'
                AND NOT EXISTS (
                       SELECT 1
                         FROM wms_dispatched_tasks wdt
                        WHERE wdt.transaction_temp_id =
                                                      wwtt.transaction_temp_id));
	 if l_debug = 1 then
           DEBUG ('No of records inserted are-444 ' || SQL%ROWCOUNT);
	 end if;
         --  forall i IN l_transaction_temp_id_table.first..l_transaction_temp_id_table.last
         FORALL i IN 1 .. l_transaction_temp_id_table.COUNT
            UPDATE wms_dispatched_tasks
               SET person_id = l_person_id_table (i),
	           person_resource_id = l_person_resource_id_table (i),
                   effective_start_date = l_effective_start_date_table (i),
                   effective_end_date = l_effective_end_date_table (i),
                   priority = l_task_priority_table (i),
                   last_update_date = l_update_date,
                   last_updated_by = p_user_id,
                   last_update_login = p_login_id
             WHERE transaction_temp_id = l_transaction_temp_id_table (i);
         if l_debug = 1 then
	   DEBUG ('No of records updated are-333 ' || SQL%ROWCOUNT);
           DEBUG ('Commiting ');
	 end if;

	 /* Bug 5507934 - Placed at the end of the procedure*/
         /*IF p_commit
         THEN
            DEBUG ('Commiting the record');
            COMMIT;
         END IF;*/
	 /* End Bug 5507934 */

         IF g_task_saved IS NULL
         THEN
            fnd_message.set_name ('WMS', 'WMS_TASK_SAVED');
            g_task_saved := fnd_message.get;
         END IF;

         --  forall i IN l_transaction_temp_id_table.first..l_transaction_temp_id_table.last
         FORALL i IN 1 .. l_transaction_temp_id_table.COUNT
            UPDATE wms_waveplan_tasks_temp
               SET RESULT = 'S',
                   error = g_task_saved,
                   is_modified = 'N',
                   person_id_original = l_person_id_table (i),
                   status_id_original = l_wms_task_status_table (i),
                   priority_original = l_task_priority_table (i),
                   mmtt_last_updated_by = p_user_id,
                   mmtt_last_update_date = l_update_date,
                   wdt_last_updated_by =
                      DECODE (l_wms_task_status_table (i),
                              1, NULL,
                              8, NULL,
                              p_user_id
                             ),
                   wdt_last_update_date =
                      TO_DATE (DECODE (l_wms_task_status_table (i),
                                       1, NULL,
                                       8, NULL,
                                       TO_CHAR (l_update_date,
                                                'DD-MON-YY HH24:MI:SS'
                                               )
                                      ),
                               'DD-MON-YY HH24:MI:SS'
                              )
             WHERE transaction_temp_id = l_transaction_temp_id_table (i);
         if l_debug = 1 then
	   DEBUG ('No of records updated are-222 ' || SQL%ROWCOUNT);
	 end if;
      END IF;                                                     -- count > 0

      ELSIF p_task_action = 'C' THEN -- cancel tasks

         FOR rec_wwtt IN cur_wwtt
         LOOP
            IF rec_wwtt.task_type_id = 2 AND rec_wwtt.status_id = 12 THEN

               WMS_Cross_Dock_Pvt.cancel_crossdock_task(
                             p_transaction_temp_id => rec_wwtt.transaction_temp_id
                           , x_return_status       => x_return_status
                           , x_msg_data            => x_msg_data
                           , x_msg_count           => x_msg_count
                           );
               IF  x_return_status = fnd_api.g_ret_sts_success THEN
                  UPDATE wms_waveplan_tasks_temp
                     SET RESULT = 'S',
                         error = 'Task Cancelled',
                         is_modified = 'N'
                   WHERE transaction_temp_id = rec_wwtt.transaction_temp_id;
                  x_save_count :=  x_save_count + 1;
               END IF;

            END IF;
         END LOOP;
      END IF;

      fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
      l_error_message := fnd_message.get;

      UPDATE wms_waveplan_tasks_temp
         SET RESULT = 'E',
             error = l_error_message
       WHERE is_modified = 'Y';

      if l_debug = 1 then
        DEBUG ('No of records updated are-111 ' || SQL%ROWCOUNT);
      end if;

      /* Bug 5507934 */
      IF p_commit
      THEN
        if l_debug = 1 then
	  DEBUG ('Commiting the record');
	end if;
        COMMIT;
      END IF;
     /* End of 5507934 */
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK TO save_tasks;
         x_return_status := 'U';
         x_msg_data := SQLERRM;
         DEBUG ('SQL error: ' || SQLERRM, 'Task Planning.Save Tasks');
   END;

-- This procedure will populate the required data for the performance chart
   PROCEDURE get_status_dist (
      x_status_chart_data   OUT NOCOPY      cb_chart_status_tbl_type,
      x_status_data_count   OUT NOCOPY      NUMBER,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      p_task_type_id        IN              NUMBER DEFAULT NULL
   )
   IS
      CURSOR status_cursor
      IS
         SELECT   status_id, COUNT (*) task_count
             FROM wms_waveplan_tasks_temp
            WHERE task_type_id = NVL (p_task_type_id, task_type_id)
         GROUP BY status_id;

      l_loop_index   NUMBER;
   BEGIN
      -- Get all of the lookup values for the status code
      -- There are 7, 1-Pending, 2-Queued, 3-Dispatched, 4-Loaded , 5 -errored, 6-Completed, 7-Hold
      -- 8-Unreleased, 9-Active, 10-Suspended
      IF g_status_codes_orig.COUNT = 0
      THEN
         set_status_codes;
      END IF;

      x_status_data_count := 0;
      l_loop_index := 0;

      FOR c1 IN status_cursor
      LOOP
         l_loop_index := l_loop_index + 1;
         x_status_chart_data (l_loop_index).status :=
                                           g_status_codes_orig (c1.status_id);
         x_status_chart_data (l_loop_index).task_count := c1.task_count;
      END LOOP;

      x_status_data_count := l_loop_index;
      x_return_status := fnd_api.g_ret_sts_success;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         DEBUG (SQLERRM, 'Task_planning.get_status_dist');
   END get_status_dist;

-- This procedure will populate the required data for the performance chart
   PROCEDURE get_type_dist (
      x_type_chart_data   OUT NOCOPY      cb_chart_type_tbl_type,
      x_type_data_count   OUT NOCOPY      NUMBER,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      p_task_type_id      IN              NUMBER DEFAULT NULL
   )
   IS
      CURSOR type_cursor
      IS
         SELECT   task_type_id, COUNT (*) task_count
             FROM wms_waveplan_tasks_temp
            WHERE task_type_id = NVL (p_task_type_id, task_type_id)
         GROUP BY task_type_id;

      l_loop_index   NUMBER;
   BEGIN
      -- Get all of the lookup values for the task type description
      -- There should be only 6, 1-Pick, 2-Putaway, 3-Cycle Count, 4-Replenish 5-MOXfer 6-MOIssue
      IF g_task_types_orig.COUNT = 0
      THEN
         set_task_type;
      END IF;

      x_type_data_count := 0;
      l_loop_index := 0;

      FOR c1 IN type_cursor
      LOOP
         l_loop_index := l_loop_index + 1;
         x_type_chart_data (l_loop_index).TYPE :=
                                          g_task_types_orig (c1.task_type_id);
         x_type_chart_data (l_loop_index).task_count := c1.task_count;
      END LOOP;

      x_type_data_count := l_loop_index;
      x_return_status := fnd_api.g_ret_sts_success;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         DEBUG (SQLERRM, 'Task_planning.get_type_dist');
   END get_type_dist;

   PROCEDURE calculate_summary (
      p_calculate_time      IN              BOOLEAN DEFAULT FALSE,
      p_time_per_task       IN              wms_waveplan_tasks_pvt.time_per_task_table_type,
      p_time_per_task_uom   IN              wms_waveplan_tasks_pvt.time_uom_table_type,
      p_time_uom_code       IN              VARCHAR2 DEFAULT NULL,
      p_time_uom            IN              VARCHAR2 DEFAULT NULL,
      p_calculate_volume    IN              BOOLEAN DEFAULT FALSE,
      p_volume_uom_code     IN              VARCHAR2 DEFAULT NULL,
      p_volume_uom          IN              VARCHAR2 DEFAULT NULL,
      p_calculate_weight    IN              BOOLEAN DEFAULT FALSE,
      p_weight_uom_code     IN              VARCHAR2 DEFAULT NULL,
      p_weight_uom          IN              VARCHAR2 DEFAULT NULL,
      x_total_tasks         OUT NOCOPY      NUMBER,
      x_total_time          OUT NOCOPY      NUMBER,
      x_total_weight        OUT NOCOPY      NUMBER,
      x_total_volume        OUT NOCOPY      NUMBER,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER
   )
   IS
      TYPE user_task_type_id_type IS TABLE OF wms_waveplan_tasks_temp.user_task_type_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE time_type IS TABLE OF wms_waveplan_tasks_temp.time_estimate%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE volume_type IS TABLE OF wms_waveplan_tasks_temp.unit_volume%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE weight_type IS TABLE OF wms_waveplan_tasks_temp.unit_weight%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE volume_uom_type IS TABLE OF wms_waveplan_tasks_temp.volume_uom_code%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE weight_uom_type IS TABLE OF wms_waveplan_tasks_temp.weight_uom_code%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE item_id_type IS TABLE OF wms_waveplan_tasks_temp.inventory_item_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE quantity_type IS TABLE OF wms_waveplan_tasks_temp.transaction_quantity%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE result_type IS TABLE OF wms_waveplan_tasks_temp.RESULT%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE ERROR_TYPE IS TABLE OF wms_waveplan_tasks_temp.error%TYPE
         INDEX BY BINARY_INTEGER;

      l_user_task_type_id     user_task_type_id_type;
      l_time                  time_type;
      l_volume                volume_type;
      l_volume_uom_code       volume_uom_type;
      l_weight                weight_type;
      l_weight_uom_code       weight_uom_type;
      l_inventory_item_id     item_id_type;
      l_quantity              quantity_type;
      l_result                result_type;
      l_error                 ERROR_TYPE;
      l_transaction_temp_id   transaction_temp_table_type;
      l_task_type_id          task_type_id_table_type;
   BEGIN
      IF p_calculate_time OR p_calculate_weight OR p_calculate_volume
      THEN
         SELECT transaction_temp_id, task_type_id, user_task_type_id,
                unit_volume, volume_uom_code, unit_weight, weight_uom_code,
                inventory_item_id, transaction_quantity
         BULK COLLECT INTO l_transaction_temp_id, l_task_type_id, l_user_task_type_id,
                l_volume, l_volume_uom_code, l_weight, l_weight_uom_code,
                l_inventory_item_id, l_quantity
           FROM wms_waveplan_tasks_temp
          WHERE RESULT IN ('X', 'Y', 'Z');

         x_total_tasks := l_transaction_temp_id.COUNT;

         IF p_calculate_time
         THEN
            x_total_time := 0;
         END IF;

         IF p_calculate_weight
         THEN
            x_total_weight := 0;
         END IF;

         IF p_calculate_volume
         THEN
            x_total_volume := 0;
         END IF;

         FOR i IN 1 .. l_transaction_temp_id.COUNT
         LOOP
            l_result (i) := 'S';
            l_time (i) := NULL;
            l_error (i) := NULL;

            IF p_calculate_time AND l_user_task_type_id (i) IS NOT NULL
            THEN
               IF p_time_per_task_uom.EXISTS ((l_user_task_type_id (i)))
               THEN
                  IF NVL (p_time_per_task_uom (l_user_task_type_id (i)),
                          '@@@'
                         ) <> p_time_uom_code
                  THEN
                     l_time (i) :=
                        inv_convert.inv_um_convert
                           (item_id            => l_inventory_item_id (i),
                            PRECISION          => NULL,
                            from_quantity      => p_time_per_task
                                                       (l_user_task_type_id
                                                                           (i)
                                                       ),
                            from_unit          => p_time_per_task_uom
                                                       (l_user_task_type_id
                                                                           (i)
                                                       ),
                            to_unit            => p_time_uom_code,
                            from_name          => NULL,
                            to_name            => NULL
                           );

                     IF l_time (i) = -99999
                     THEN
                        l_time (i) := NULL;
                        l_result (i) := 'E';

                        IF g_time_uom_error IS NULL
                        THEN
                           fnd_message.set_name ('WMS', 'WMS_TIME_UOM_ERROR');
                           g_time_uom_error := fnd_message.get;
                        END IF;

                        IF g_cannot_summarize_time IS NULL
                        THEN
                           fnd_message.set_name ('WMS',
                                                 'WMS_CANNOT_SUMMARIZE_TIME'
                                                );
                           g_cannot_summarize_time := fnd_message.get;
                        END IF;

                        l_error (i) :=
                           SUBSTR (   l_error (i)
                                   || g_time_uom_error
                                   || g_cannot_summarize_time,
                                   1,
                                   240
                                  );
                     ELSE
                        IF g_summarized_time IS NULL
                        THEN
                           fnd_message.set_name ('WMS',
                                                 'WMS_SUMMARIZED_TIME');
                           g_summarized_time := fnd_message.get;
                        END IF;

                        l_error (i) :=
                              SUBSTR (l_error (i) || g_summarized_time, 1,
                                      240);
                     END IF;                                 -- UOM converted?
                  ELSE
                     IF g_summarized_time IS NULL
                     THEN
                        fnd_message.set_name ('WMS', 'WMS_SUMMARIZED_TIME');
                        g_summarized_time := fnd_message.get;
                     END IF;

                     l_error (i) :=
                              SUBSTR (l_error (i) || g_summarized_time, 1,
                                      240);
                     l_time (i) := p_time_per_task (l_user_task_type_id (i));
                  END IF;                                 -- UOM is different?

                  x_total_time := x_total_time + NVL (l_time (i), 0);
               ELSE
                  IF g_cannot_summarize_time IS NULL
                  THEN
                     fnd_message.set_name ('WMS',
                                           'WMS_CANNOT_SUMMARIZE_TIME');
                     g_cannot_summarize_time := fnd_message.get;
                  END IF;

                  l_error (i) :=
                        SUBSTR (l_error (i) || g_cannot_summarize_time, 1,
                                240);
                  l_result (i) := 'E';
               END IF;
            ELSIF p_calculate_time AND l_user_task_type_id (i) IS NULL
            THEN
               IF g_cannot_summarize_time IS NULL
               THEN
                  fnd_message.set_name ('WMS', 'WMS_CANNOT_SUMMARIZE_TIME');
                  g_cannot_summarize_time := fnd_message.get;
               END IF;

               l_error (i) :=
                        SUBSTR (l_error (i) || g_cannot_summarize_time, 1,
                                240);
               l_result (i) := 'E';
            END IF;

            IF p_calculate_volume
            THEN
               IF l_volume (i) IS NULL
               THEN
                  IF g_no_item_vol IS NULL
                  THEN
                     fnd_message.set_name ('WMS', 'WMS_NO_ITEM_VOL');
                     g_no_item_vol := fnd_message.get;
                  END IF;

                  IF g_cannot_summarize_vol IS NULL
                  THEN
                     fnd_message.set_name ('WMS', 'WMS_CANNOT_SUMMARIZE_VOL');
                     g_cannot_summarize_vol := fnd_message.get;
                  END IF;

                  l_result (i) := 'E';
                  l_error (i) :=
                     SUBSTR (   l_error (i)
                             || g_no_item_vol
                             || g_cannot_summarize_vol,
                             1,
                             240
                            );
               ELSE
                  IF NVL (l_volume_uom_code (i), '@@@') <> p_volume_uom_code
                  THEN
                     l_volume (i) :=
                        inv_convert.inv_um_convert
                                          (item_id            => l_inventory_item_id
                                                                           (i),
                                           PRECISION          => NULL,
                                           from_quantity      =>   l_quantity
                                                                           (i)
                                                                 * l_volume
                                                                           (i),
                                           from_unit          => l_volume_uom_code
                                                                           (i),
                                           to_unit            => p_volume_uom_code,
                                           from_name          => NULL,
                                           to_name            => NULL
                                          );

                     IF l_volume (i) = -99999
                     THEN
                        l_volume (i) := NULL;
                        l_result (i) := 'E';

                        IF g_vol_uom_error IS NULL
                        THEN
                           fnd_message.set_name ('WMS', 'WMS_VOL_UOM_ERROR');
                           g_vol_uom_error := fnd_message.get;
                        END IF;

                        IF g_cannot_summarize_vol IS NULL
                        THEN
                           fnd_message.set_name ('WMS',
                                                 'WMS_CANNOT_SUMMARIZE_VOL'
                                                );
                           g_cannot_summarize_vol := fnd_message.get;
                        END IF;

                        l_error (i) :=
                           SUBSTR (   l_error (i)
                                   || g_vol_uom_error
                                   || g_cannot_summarize_vol,
                                   1,
                                   240
                                  );
                     ELSE
                        IF g_summarized_volume IS NULL
                        THEN
                           fnd_message.set_name ('WMS',
                                                 'WMS_SUMMARIZED_VOLUME'
                                                );
                           g_summarized_volume := fnd_message.get;
                        END IF;

                        l_error (i) :=
                            SUBSTR (l_error (i) || g_summarized_volume, 1,
                                    240);
                     END IF;
                  ELSE
                     IF g_summarized_volume IS NULL
                     THEN
                        fnd_message.set_name ('WMS', 'WMS_SUMMARIZED_VOLUME');
                        g_summarized_volume := fnd_message.get;
                     END IF;

                     l_error (i) :=
                            SUBSTR (l_error (i) || g_summarized_volume, 1,
                                    240);
                     l_volume (i) := l_quantity (i) * l_volume (i);
                  END IF;

                  x_total_volume := x_total_volume + NVL (l_volume (i), 0);
               END IF;
            ELSE                                           -- Calculate Volume
               l_volume (i) := NULL;
            END IF;

            IF p_calculate_weight
            THEN
               IF l_weight (i) IS NULL
               THEN
                  IF g_no_item_wt IS NULL
                  THEN
                     fnd_message.set_name ('WMS', 'WMS_NO_ITEM_WT');
                     g_no_item_wt := fnd_message.get;
                  END IF;

                  IF g_cannot_summarize_wt IS NULL
                  THEN
                     fnd_message.set_name ('WMS', 'WMS_CANNOT_SUMMARIZE_WT');
                     g_cannot_summarize_wt := fnd_message.get;
                  END IF;

                  l_result (i) := 'E';
                  l_error (i) :=
                     SUBSTR (   l_error (i)
                             || g_no_item_wt
                             || g_cannot_summarize_wt,
                             1,
                             240
                            );
               ELSE
                  IF     l_weight (i) IS NOT NULL
                     AND NVL (l_weight_uom_code (i), '@@@') <>
                                                             p_weight_uom_code
                  THEN
                     l_weight (i) :=
                        inv_convert.inv_um_convert
                                          (item_id            => l_inventory_item_id
                                                                           (i),
                                           PRECISION          => NULL,
                                           from_quantity      =>   l_quantity
                                                                           (i)
                                                                 * l_weight
                                                                           (i),
                                           from_unit          => l_weight_uom_code
                                                                           (i),
                                           to_unit            => p_weight_uom_code,
                                           from_name          => NULL,
                                           to_name            => NULL
                                          );

                     IF l_weight (i) = -99999
                     THEN
                        l_weight (i) := NULL;
                        l_result (i) := 'E';

                        IF g_wt_uom_error IS NULL
                        THEN
                           fnd_message.set_name ('WMS', 'WMS_WT_UOM_ERROR');
                           g_wt_uom_error := fnd_message.get;
                        END IF;

                        IF g_cannot_summarize_wt IS NULL
                        THEN
                           fnd_message.set_name ('WMS',
                                                 'WMS_CANNOT_SUMMARIZE_WT'
                                                );
                           g_cannot_summarize_wt := fnd_message.get;
                        END IF;

                        l_error (i) :=
                           SUBSTR (   l_error (i)
                                   || g_wt_uom_error
                                   || g_cannot_summarize_wt,
                                   1,
                                   240
                                  );
                     ELSE
                        IF g_summarized_weight IS NULL
                        THEN
                           fnd_message.set_name ('WMS',
                                                 'WMS_SUMMARIZED_WEIGHT'
                                                );
                           g_summarized_weight := fnd_message.get;
                        END IF;

                        l_error (i) :=
                            SUBSTR (l_error (i) || g_summarized_weight, 1,
                                    240);
                     END IF;
                  ELSE
                     IF g_summarized_weight IS NULL
                     THEN
                        fnd_message.set_name ('WMS', 'WMS_SUMMARIZED_WEIGHT');
                        g_summarized_weight := fnd_message.get;
                     END IF;

                     l_error (i) :=
                            SUBSTR (l_error (i) || g_summarized_weight, 1,
                                    240);
                     l_weight (i) := l_quantity (i) * l_weight (i);
                  END IF;

                  x_total_weight := x_total_weight + NVL (l_weight (i), 0);
               END IF;
            ELSE                                             -- compute weight
               l_weight (i) := NULL;
            END IF;
         END LOOP;

         FORALL i IN l_transaction_temp_id.FIRST .. l_transaction_temp_id.LAST
            UPDATE wms_waveplan_tasks_temp
               SET time_estimate = l_time (i),
                   display_weight = l_weight (i),
                   display_volume = l_volume (i)
             WHERE transaction_temp_id = l_transaction_temp_id (i)
               AND task_type_id = l_task_type_id (i);
      END IF;

      DELETE FROM wms_waveplan_summary_temp;

      INSERT INTO wms_waveplan_summary_temp
                  (task_type_id, task_type, task_type_description,
                   total_tasks, total_time, time_uom, weight, weight_uom,
                   volume, volume_uom, organization_id)
         SELECT   wwtt.user_task_type_id, bso.operation_code,
                  bso.operation_description, COUNT (*),
                  ROUND (SUM (wwtt.time_estimate), 1), p_time_uom,
                  ROUND (SUM (wwtt.display_weight), 1), p_weight_uom,
                  ROUND (SUM (wwtt.display_volume), 1), p_volume_uom,
                  wwtt.organization_id
             FROM wms_waveplan_tasks_temp wwtt, bom_standard_operations bso
            WHERE wwtt.RESULT IN ('X', 'Y', 'Z')
              AND wwtt.user_task_type_id = bso.standard_operation_id(+)
              AND wwtt.organization_id = bso.organization_id(+)
         GROUP BY wwtt.user_task_type_id,
                  bso.operation_code,
                  bso.operation_description,
                  wwtt.organization_id;

      FORALL i IN l_transaction_temp_id.FIRST .. l_transaction_temp_id.LAST
         UPDATE wms_waveplan_tasks_temp
            SET RESULT = l_result (i),
                error = l_error (i)
          WHERE transaction_temp_id = l_transaction_temp_id (i)
            AND task_type_id = l_task_type_id (i);
      x_total_time := ROUND (x_total_time, 2);
      x_total_volume := ROUND (x_total_volume, 2);
      x_total_weight := ROUND (x_total_weight, 2);
      g_rows_marked := FALSE;
   END;

   PROCEDURE cancel_plans (
      x_return_status            OUT NOCOPY   VARCHAR2,
      x_ret_code                 OUT NOCOPY   wms_waveplan_tasks_pvt.message_table_type,
      p_transaction_temp_table                wms_waveplan_tasks_pvt.transaction_temp_table_type
   )
   IS
      l_transaction_temp_id   wms_waveplan_tasks_temp.transaction_temp_id%TYPE;
      l_return_status         VARCHAR2 (1);
      l_msg_data              VARCHAR2 (2000);
      l_msg_count             NUMBER;
      l_error_code            NUMBER;
      l_cancel_plan           BOOLEAN;
      l_debug		      NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
   BEGIN

      FOR i IN 1 .. p_transaction_temp_table.COUNT
      LOOP
         BEGIN

           SELECT transaction_temp_id
           INTO l_transaction_temp_id
           FROM wms_waveplan_tasks_temp
           WHERE parent_line_id = p_transaction_temp_table (i)
           AND status = 'Pending';

           l_cancel_plan := TRUE;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               if l_debug = 1 then
 	         debug('Pending Task record does not exists..');
	       end if;
               l_cancel_plan := FALSE;
         END;


         IF l_cancel_plan THEN

            --call the runtime api to cancel the plan
	    if l_debug = 1 then
              DEBUG ('calling wms_atf_runtime_pub_apis.cancel_operation_plan ');
              DEBUG (   'p_source_task_id '
                   || l_transaction_temp_id
                   || ' p_activity_type_id  1'
                  );
	    end if;
            wms_atf_runtime_pub_apis.cancel_operation_plan
                                      (x_return_status         => l_return_status,
                                       x_msg_data              => l_msg_data,
                                       x_msg_count             => l_msg_count,
                                       x_error_code            => l_error_code,
                                       p_source_task_id        => l_transaction_temp_id,
                                       p_activity_type_id      => 1
                                      );
            if l_debug = 1 then
	      DEBUG ('ret status from atf cancel ' || l_return_status);
	    end if;

            IF l_return_status = fnd_api.g_ret_sts_success
            THEN
               x_ret_code (i) := fnd_api.g_ret_sts_success;
	       if l_debug = 1 then
                 DEBUG ('success for ' || i || ' ' || x_ret_code (i));
	       end if;
            ELSE
               x_ret_code (i) := l_msg_data;
	       if l_debug = 1 then
                 DEBUG ('failure for ' || i || ' ' || l_msg_data);
	       end if;
            END IF;
         ELSE
           fnd_message.set_name('WMS','WMS_CANCEL_FAILED');
           x_ret_code(i) := fnd_message.get;
         END IF;

         END LOOP;

         FORALL i IN 1 .. p_transaction_temp_table.COUNT

            UPDATE wms_waveplan_tasks_temp
               SET is_modified = 'Y',
                   status_id = 12,
                   status = g_status_codes(12)
             WHERE transaction_temp_id = p_transaction_temp_table (i)
               AND x_ret_code (i) = fnd_api.g_ret_sts_success;

         if l_debug = 1 then
	   DEBUG ('No of records updated are' || SQL%ROWCOUNT);
	 end if;

         FORALL j IN 1..p_transaction_temp_table.COUNT
            DELETE FROM wms_waveplan_tasks_temp
              WHERE parent_line_id = p_transaction_temp_table (j)
              AND   status_id        = 1
              AND x_ret_code (j)   = fnd_api.g_ret_sts_success;

         if l_debug = 1 then
	   DEBUG ('No of records deleted are' || SQL%ROWCOUNT);
	 end if;

      x_return_status := fnd_api.g_ret_sts_success;
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG ('other exception in cancel_plans ' || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END cancel_plans;


   FUNCTION get_final_query
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_final_query;
   END get_final_query;

   FUNCTION get_task_summary
       RETURN wms_task_summary_tbl_type
   IS
   BEGIN
      RETURN g_wms_task_summary_tbl;
   END get_task_summary;

   PROCEDURE set_task_summary(p_wms_task_summary_tbl wms_task_summary_tbl_type)
      IS
   BEGIN
      g_wms_task_summary_tbl := p_wms_task_summary_tbl;
   END set_task_summary;

END wms_waveplan_tasks_pvt;

/
