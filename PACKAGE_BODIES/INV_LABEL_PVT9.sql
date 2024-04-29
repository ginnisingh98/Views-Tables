--------------------------------------------------------
--  DDL for Package Body INV_LABEL_PVT9
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LABEL_PVT9" AS
  /* $Header: INVLAP9B.pls 120.8.12010000.2 2008/07/29 13:41:16 ptkumar ship $ */
  label_b    CONSTANT VARCHAR2(50)              := '<label';
  label_e    CONSTANT VARCHAR2(50)              := '</label>' || fnd_global.local_chr(10);
  variable_b CONSTANT VARCHAR2(50)              := '<variable name= "';
  variable_e CONSTANT VARCHAR2(50)              := '</variable>' || fnd_global.local_chr(10);
  tag_e      CONSTANT VARCHAR2(50)              := '>' || fnd_global.local_chr(10);
  l_debug             NUMBER;
  -- Bug 2795525 : This mask is used to mask all date fields.
  g_date_format_mask  VARCHAR2(100)             := inv_label.g_date_format_mask;
  g_header_printed    BOOLEAN                   := FALSE;
  g_user_name         fnd_user.user_name%TYPE   := fnd_global.user_name;

  PROCEDURE TRACE(p_message VARCHAR2) IS
  BEGIN
    IF (g_header_printed = FALSE) THEN
      inv_label.TRACE('$Header: INVLAP9B.pls 120.8.12010000.2 2008/07/29 13:41:16 ptkumar ship $', g_pkg_name || ' - ' || 'LABEL_WIP_CONT');
      g_header_printed  := TRUE;
    END IF;

    inv_label.TRACE(g_user_name || ': ' || p_message, 'LABEL_WIP_CONT');
  END TRACE;

  PROCEDURE get_variable_data(
    x_variable_content       OUT NOCOPY    inv_label.label_tbl_type
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , x_return_status          OUT NOCOPY    VARCHAR2
  , p_label_type_info        IN            inv_label.label_type_rec
  , p_transaction_id         IN            NUMBER
  , p_input_param            IN            mtl_material_transactions_temp%ROWTYPE
  , p_transaction_identifier IN            NUMBER
  ) IS
    l_api_name               VARCHAR2(20)                            := 'get_variable_data';

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--   Following variables were added (as a part of 11i10+ 'Custom Labels' Project)            |
--   to retrieve and hold the SQL Statement and it's result.                                 |
---------------------------------------------------------------------------------------------
   l_sql_stmt  VARCHAR2(4000);
   l_sql_stmt_result VARCHAR2(4000) := NULL;
   TYPE sql_stmt IS REF CURSOR;
   c_sql_stmt sql_stmt;
   l_custom_sql_ret_status VARCHAR2(1);
   l_custom_sql_ret_msg VARCHAR2(2000);

   -- Fix for bug: 4179593 Start
   l_CustSqlWarnFlagSet BOOLEAN;
   l_CustSqlErrFlagSet BOOLEAN;
   l_CustSqlWarnMsg VARCHAR2(2000);
   l_CustSqlErrMsg VARCHAR2(2000);
   -- Fix for bug: 4179593 End

------------------------End of this change for Custom Labels project code--------------------

    l_organization_id        NUMBER                                  := NULL;
    l_wip_entity_id          NUMBER                                  := NULL;

    --Bug #6417575,Label Printing Support for WIP Move Transactions (12.1)
    --  Created new cursor to fetch WIP Job Attributes based on wip_entity_id.
    CURSOR wip_discrete_cur IS
      SELECT
             -- Discrete Job
             wipent.wip_entity_name job_schedule_name
           , wipent.description job_schedule_description
           , msik3.concatenated_segments job_assembly
           , msik3.description assembly_description
           , mfglkp1.meaning job_schedule_type
           , wipdj.class_code job_accounting_class
           , wipdj.attribute_category job_attribute_category
           , wipdj.attribute1 job_attribute1
           , wipdj.attribute2 job_attribute2
           , wipdj.attribute3 job_attribute3
           , wipdj.attribute4 job_attribute4
           , wipdj.attribute5 job_attribute5
           , wipdj.attribute6 job_attribute6
           , wipdj.attribute7 job_attribute7
           , wipdj.attribute8 job_attribute8
           , wipdj.attribute9 job_attribute9
           , wipdj.attribute10 job_attribute10
           , wipdj.attribute11 job_attribute11
           , wipdj.attribute12 job_attribute12
           , wipdj.attribute13 job_attribute13
           , wipdj.attribute14 job_attribute14
           , wipdj.attribute15 job_attribute15
           , wipdj.bom_revision job_bom_revision
           , inv_project.get_locsegs(mila.inventory_location_id, mila.organization_id) job_completion_locator
           , wipdj.completion_subinventory job_completion_subinventory
           , wipdj.demand_class job_demand_class
           , TO_CHAR(wipdj.due_date, g_date_format_mask) job_due_date
           ,   -- Added for Bug 2795525
             mfglkp2.meaning job_job_type
           , wipdj.net_quantity job_net_quantity
           , wipdj.priority job_priority
           , TO_CHAR(wipdj.date_released, g_date_format_mask) job_release_date
           ,   -- Added for Bug 2795525
             wipdj.routing_revision job_routing_revision
           , TO_CHAR(wipdj.scheduled_completion_date, g_date_format_mask) job_schedule_completion_date
           ,   -- Added for Bug 2795525
             TO_CHAR(wipdj.scheduled_start_date, g_date_format_mask) job_start_date
           ,   -- Added for Bug 2795525
             wipdj.start_quantity job_start_quantity
           , mfglkp3.meaning job_status_type
           ,
             -- Repetitive Schedule
             NULL repet_sched_alternate_bom
           , NULL repet_sched_alternate_routing
           , NULL repet_sched_attribute_category
           , NULL repet_sched_attribute1
           , NULL repet_sched_attribute2
           , NULL repet_sched_attribute3
           , NULL repet_sched_attribute4
           , NULL repet_sched_attribute5
           , NULL repet_sched_attribute6
           , NULL repet_sched_attribute7
           , NULL repet_sched_attribute8
           , NULL repet_sched_attribute9
           , NULL repet_sched_attribute10
           , NULL repet_sched_attribute11
           , NULL repet_sched_attribute12
           , NULL repet_sched_attribute13
           , NULL repet_sched_attribute14
           , NULL repet_sched_attribute15
           , NULL repet_sched_bom_revision
           , NULL repet_sched_daily_quantity
           , NULL repet_sched_demand_class
           , NULL repet_sched_description
           , NULL repet_sched_firm_flag
           , NULL repet_sched_first_comple_dt
           ,   -- Added for Bug 2795525
             NULL repet_sched_first_start_date
           ,   -- Added for Bug 2795525
             NULL repet_sched_last_complet_dt
           ,   -- Added for Bug 2795525
             NULL repet_sched_last_start_date
           ,   -- Added for Bug 2795525
             NULL repet_sched_processing_date
           ,   -- Added for Bug 2795525
             NULL repet_sched_release_date
           ,   -- Added for Bug 2795525
             NULL repet_sched_routing_revision
           , NULL repet_sched_schedule_status
           ,
             -- Operations
             NULL operations_attribute_category
           , NULL operations_attribute1
           , NULL operations_attribute2
           , NULL operations_attribute3
           , NULL operations_attribute4
           , NULL operations_attribute5
           , NULL operations_attribute6
           , NULL operations_attribute7
           , NULL operations_attribute8
           , NULL operations_attribute9
           , NULL operations_attribute10
           , NULL operations_attribute11
           , NULL operations_attribute12
           , NULL operations_attribute13
           , NULL operations_attribute14
           , NULL operations_attribute15
           , NULL operations_backflush_flag
           , NULL operations_department
           , NULL operations_description
           , NULL operations_first_complet_dt
           ,   -- Added for Bug 2795525
             NULL operations_first_receipt_date
           ,   -- Added for Bug 2795525
             NULL operations_last_complet_dt
           ,   -- Added for Bug 2795525
             NULL operations_last_receipt_date
           ,   -- Added for Bug 2795525
             NULL operations_min_transfer_qty
           , NULL operations_schedule_quantity
           , NULL operations_standard_operation
           , NULL operations_yield
           , NULL operations_yield_enabled
           ,
             -- Requirements
             NULL requirements_attribute_categ
           , NULL requirements_attribute1
           , NULL requirements_attribute2
           , NULL requirements_attribute3
           , NULL requirements_attribute4
           , NULL requirements_attribute5
           , NULL requirements_attribute6
           , NULL requirements_attribute7
           , NULL requirements_attribute8
           , NULL requirements_attribute9
           , NULL requirements_attribute10
           , NULL requirements_attribute11
           , NULL requirements_attribute12
           , NULL requirements_attribute13
           , NULL requirements_attribute14
           , NULL requirements_attribute15
           , NULL requirements_comments
           , NULL requirements_date_required
           ,   -- Added for Bug 2795525
             NULL requirements_department_name
           , NULL requirements_operation_seq
           , NULL requirements_qty_per_assembly
           , NULL requirements_required_quantity
           , NULL requirements_supply_locator
           , NULL requirements_supply_sub
           , NULL requirements_wip_supply_type
           , NULL requirements_item_name
           , wipent.organization_id organization_id
           , NULL inventory_item_id
           , wipent.entity_type entity_type
           ,
             -- LPN Content
             NULL lpn_id
           , NULL lpn
           , NULL parent_lpn_id
           , NULL parent_lpn
           , NULL volume
           , NULL volume_uom
           , NULL gross_weight
           , NULL gross_weight_uom
           , NULL tare_weight
           , NULL tare_weight_uom
           , NULL lpn_container_item_id
           , NULL lpn_container_item
           , mp.organization_code ORGANIZATION
           , NULL item
           , NULL item_description
           , NULL revision
           , NULL lot
           , NULL lot_status
           , NULL lot_expiration_date
           , NULL quantity
           , NULL uom
           , NULL cost_group
           , NULL item_hazard_class
           , NULL item_attribute_category
           , NULL item_attribute1
           , NULL item_attribute2
           , NULL item_attribute3
           , NULL item_attribute4
           , NULL item_attribute5
           , NULL item_attribute6
           , NULL item_attribute7
           , NULL item_attribute8
           , NULL item_attribute9
           , NULL item_attribute10
           , NULL item_attribute11
           , NULL item_attribute12
           , NULL item_attribute13
           , NULL item_attribute14
           , NULL item_attribute15
           , NULL lpn_attribute_category
           , NULL lpn_attribute1
           , NULL lpn_attribute2
           , NULL lpn_attribute3
           , NULL lpn_attribute4
           , NULL lpn_attribute5
           , NULL lpn_attribute6
           , NULL lpn_attribute7
           , NULL lpn_attribute8
           , NULL lpn_attribute9
           , NULL lpn_attribute10
           , NULL lpn_attribute11
           , NULL lpn_attribute12
           , NULL lpn_attribute13
           , NULL lpn_attribute14
           , NULL lpn_attribute15
           , NULL lot_attribute_category
           , NULL lot_c_attribute1
           , NULL lot_c_attribute2
           , NULL lot_c_attribute3
           , NULL lot_c_attribute4
           , NULL lot_c_attribute5
           , NULL lot_c_attribute6
           , NULL lot_c_attribute7
           , NULL lot_c_attribute8
           , NULL lot_c_attribute9
           , NULL lot_c_attribute10
           , NULL lot_c_attribute11
           , NULL lot_c_attribute12
           , NULL lot_c_attribute13
           , NULL lot_c_attribute14
           , NULL lot_c_attribute15
           , NULL lot_c_attribute16
           , NULL lot_c_attribute17
           , NULL lot_c_attribute18
           , NULL lot_c_attribute19
           , NULL lot_c_attribute20
           , NULL lot_d_attribute1   -- Added for Bug 2795525,
           , NULL lot_d_attribute2   -- Added for Bug 2795525,
           , NULL lot_d_attribute3   -- Added for Bug 2795525,
           , NULL lot_d_attribute4   -- Added for Bug 2795525,
           , NULL lot_d_attribute5   -- Added for Bug 2795525,
           , NULL lot_d_attribute6   -- Added for Bug 2795525,
           , NULL lot_d_attribute7   -- Added for Bug 2795525,
           , NULL lot_d_attribute8   -- Added for Bug 2795525,
           , NULL lot_d_attribute9   -- Added for Bug 2795525,
           , NULL lot_d_attribute10   -- Added for Bug 2795525,
           , NULL lot_n_attribute1
           , NULL lot_n_attribute2
           , NULL lot_n_attribute3
           , NULL lot_n_attribute4
           , NULL lot_n_attribute5
           , NULL lot_n_attribute6
           , NULL lot_n_attribute7
           , NULL lot_n_attribute8
           , NULL lot_n_attribute9
           , NULL lot_n_attribute10
           , NULL lot_country_of_origin
           , NULL lot_grade_code
           , NULL lot_origination_date   -- Added for Bug 2795525,
           , NULL lot_date_code
           , NULL lot_change_date   -- Added for Bug 2795525,
           , NULL lot_age
           , NULL lot_retest_date   -- Added for Bug 2795525,
           , NULL lot_maturity_date   -- Added for Bug 2795525,
           , NULL lot_item_size
           , NULL lot_color
           , NULL lot_volume
           , NULL lot_volume_uom
           , NULL lot_place_of_origin
           , NULL lot_best_by_date   -- Added for Bug 2795525,
           , NULL lot_length
           , NULL lot_length_uom
           , NULL lot_recycled_cont
           , NULL lot_thickness
           , NULL lot_thickness_uom
           , NULL lot_width
           , NULL lot_width_uom
           , NULL lot_curl
           , NULL lot_vendor
           , NULL subinventory_code
           , NULL LOCATOR
        FROM  wip_entities      wipent
            , wip_discrete_jobs wipdj
            , mfg_lookups mfglkp1
            , mfg_lookups mfglkp2
            , mfg_lookups mfglkp3
            , mtl_system_items_vl msik3
            , mtl_item_locations mila
            , mtl_parameters mp
        WHERE wipdj.wip_entity_id = wipent.wip_entity_id
          AND wipdj.organization_id = wipent.organization_id
          AND wipent.wip_entity_id = l_wip_entity_id
          AND wipent.organization_id = l_organization_id
          AND mp.organization_id = wipent.organization_id
          AND mfglkp1.lookup_code(+) = wipent.entity_type
          AND mfglkp1.lookup_type(+) = 'WIP_ENTITY'
          AND mfglkp2.lookup_code(+) = wipdj.job_type
          AND mfglkp2.lookup_type(+) = 'WIP_DISCRETE_JOB'
          AND mfglkp3.lookup_code(+) = wipdj.status_type
          AND mfglkp3.lookup_type(+) = 'WIP_JOB_STATUS'
          AND msik3.inventory_item_id(+) = wipent.primary_item_id
          AND msik3.organization_id(+) = wipent.organization_id
          AND mila.inventory_location_id(+) = wipdj.completion_locator_id;

    -- Bug 2829872
    -- Cursor for Manufacturing Cross-Dock(37)
    CURSOR wip_cross_dock_cur IS
      SELECT mmtt.organization_id
           , mmtt.demand_source_header_id
           , mmtt.schedule_id
           , mmtt.inventory_item_id
           , mmtt.operation_seq_num
           , NVL(mmtt.content_lpn_id, mmtt.lpn_id)
           , mmtt.revision
           , mtlt.lot_number
           , NVL(mtlt.transaction_quantity, mmtt.transaction_quantity)
           , mmtt.transaction_uom
           , mmtt.cost_group_id
           , mmtt.subinventory_code
           , pp.NAME
           , pt.task_name
        FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt, pa_projects pp, pa_tasks pt
       WHERE mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
         AND mmtt.project_id = pp.project_id(+)
         AND mmtt.task_id = pt.task_id(+)
         AND mmtt.transaction_temp_id = p_transaction_id;

    CURSOR wip_lines_cur IS
      SELECT mtrl.organization_id
           , mtrl.txn_source_id
           , mtrl.reference_id
           , mtrl.inventory_item_id
           , mtrl.txn_source_line_id
           , mmtt.transfer_lpn_id
           , mmtt.revision
           , mtlt.lot_number
           -- Bug 2781198. labels fails for lot controlled component
      ,      NVL(mtlt.transaction_quantity, mmtt.transaction_quantity)
           , mmtt.transaction_uom
           , mmtt.cost_group_id
           , mmtt.subinventory_code
           -- Bug 2673874 : joabraha
      ,      pp.NAME
           , pt.task_name
        FROM mtl_txn_request_lines mtrl
           , mtl_material_transactions_temp mmtt
           , mtl_transaction_lots_temp mtlt
           -- bug 3075322
                -- , mtl_item_locations mil commented for bug 3776231
      ,      wip_discrete_jobs wdj   -- added for bug 3776231
           -- Bug 2673874 : joabraha
      ,      pa_projects pp
           , pa_tasks pt
       WHERE mtrl.line_id = mmtt.move_order_line_id
         AND mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
            /*commented for bug 3776231
              -- start bug 3075322
         AND   mmtt.locator_id = mil.inventory_location_id(+)
         AND   pp.project_id(+) = mil.segment19
         AND   pt.task_id(+)    = mil.segment20
           -- end bug 3075322
            Added the following for bug 3776231*/
         AND mmtt.transaction_source_id = wdj.wip_entity_id
         AND pp.project_id(+) = wdj.project_id
         AND pt.task_id(+) = wdj.task_id
         -- End of fix for 3776231
         AND mmtt.transaction_temp_id = p_transaction_id;

    CURSOR wip_drop_lines_cur IS
      SELECT mtrl.organization_id
           , mtrl.txn_source_id
           , mtrl.reference_id
           , mtrl.inventory_item_id
           , mtrl.txn_source_line_id
           , mmtt.transfer_lpn_id
           , mmtt.revision
           , mtlt.lot_number
           -- Bug 2781198. labels fails for lot controlled component
      ,      NVL(mtlt.transaction_quantity, mmtt.transaction_quantity)
           , mmtt.transaction_uom
           , mmtt.cost_group_id
           , mmtt.transfer_subinventory
           -- Bug 2673874 : joabraha
      ,      pp.NAME
           , pt.task_name
        FROM mtl_txn_request_lines mtrl
           , mtl_material_transactions_temp mmtt
           , mtl_transaction_lots_temp mtlt
                  -- bug 3075322
           -- , mtl_item_locations mil commented for bug 3776231
      ,      wip_discrete_jobs wdj   -- added for bug 3776231
           -- Bug 2673874 : joabraha
      ,      pa_projects pp
           , pa_tasks pt
       WHERE mtrl.line_id = mmtt.move_order_line_id
         AND mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
         /*commented for bug 3776231
               -- start bug 3075322
         AND   mmtt.locator_id = mil.inventory_location_id(+)
         AND   pp.project_id(+) = mil.segment19
         AND   pt.task_id(+)    = mil.segment20
            -- end bug 3075322
          Added the following for bug 3776231*/
         AND mmtt.transaction_source_id = wdj.wip_entity_id
         AND pp.project_id(+) = wdj.project_id
         AND pt.task_id(+) = wdj.task_id
         -- End of fix for 3776231
         AND mmtt.transaction_temp_id = p_transaction_id;


    l_repetitive_schedule_id NUMBER                                  := NULL;
    l_inventory_item_id      NUMBER                                  := NULL;
    l_subinventory           VARCHAR2(30)                            := NULL;
    l_operation_seq_num      NUMBER                                  := NULL;
    l_lpn_id                 NUMBER                                  := NULL;
    l_revision               VARCHAR2(3)                             := NULL;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number             VARCHAR2(80)                            := NULL;
    l_cost_group_id          NUMBER                                  := NULL;
    l_quantity               NUMBER                                  := NULL;
    l_uom                    VARCHAR2(3)                             := NULL;
    -- Bug 2660701 : joabraha
    l_project_name           VARCHAR2(240)                           := NULL;
    l_task_name              VARCHAR2(240)                           := NULL;

    CURSOR wip_content_cur IS
      SELECT
             -- Discrete Job
             wipent.wip_entity_name job_schedule_name
           , wipent.description job_schedule_description
           , msik3.concatenated_segments job_assembly
           , msik3.description assembly_description
           , mfglkp1.meaning job_schedule_type
           , wipdj.class_code job_accounting_class
           , wipdj.attribute_category job_attribute_category
           , wipdj.attribute1 job_attribute1
           , wipdj.attribute2 job_attribute2
           , wipdj.attribute3 job_attribute3
           , wipdj.attribute4 job_attribute4
           , wipdj.attribute5 job_attribute5
           , wipdj.attribute6 job_attribute6
           , wipdj.attribute7 job_attribute7
           , wipdj.attribute8 job_attribute8
           , wipdj.attribute9 job_attribute9
           , wipdj.attribute10 job_attribute10
           , wipdj.attribute11 job_attribute11
           , wipdj.attribute12 job_attribute12
           , wipdj.attribute13 job_attribute13
           , wipdj.attribute14 job_attribute14
           , wipdj.attribute15 job_attribute15
           , wipdj.bom_revision job_bom_revision
           , inv_project.get_locsegs(mila.inventory_location_id, mila.organization_id) job_completion_locator
           , wipdj.completion_subinventory job_completion_subinventory
           , wipdj.demand_class job_demand_class
           , TO_CHAR(wipdj.due_date, g_date_format_mask) job_due_date
           ,   -- Added for Bug 2795525
             mfglkp2.meaning job_job_type
           , wipdj.net_quantity job_net_quantity
           , wipdj.priority job_priority
           , TO_CHAR(wipdj.date_released, g_date_format_mask) job_release_date
           ,   -- Added for Bug 2795525
             wipdj.routing_revision job_routing_revision
           , TO_CHAR(wipdj.scheduled_completion_date, g_date_format_mask) job_schedule_completion_date
           ,   -- Added for Bug 2795525
             TO_CHAR(wipdj.scheduled_start_date, g_date_format_mask) job_start_date
           ,   -- Added for Bug 2795525
             wipdj.start_quantity job_start_quantity
           , mfglkp3.meaning job_status_type
           ,
             -- Repetitive Schedule
             wiprs.alternate_bom_designator repet_sched_alternate_bom
           , wiprs.alternate_routing_designator repet_sched_alternate_routing
           , wiprs.attribute_category repet_sched_attribute_category
           , wiprs.attribute1 repet_sched_attribute1
           , wiprs.attribute2 repet_sched_attribute2
           , wiprs.attribute3 repet_sched_attribute3
           , wiprs.attribute4 repet_sched_attribute4
           , wiprs.attribute5 repet_sched_attribute5
           , wiprs.attribute6 repet_sched_attribute6
           , wiprs.attribute7 repet_sched_attribute7
           , wiprs.attribute8 repet_sched_attribute8
           , wiprs.attribute9 repet_sched_attribute9
           , wiprs.attribute10 repet_sched_attribute10
           , wiprs.attribute11 repet_sched_attribute11
           , wiprs.attribute12 repet_sched_attribute12
           , wiprs.attribute13 repet_sched_attribute13
           , wiprs.attribute14 repet_sched_attribute14
           , wiprs.attribute15 repet_sched_attribute15
           , wiprs.bom_revision repet_sched_bom_revision
           , wiprs.daily_production_rate repet_sched_daily_quantity
           , wiprs.demand_class repet_sched_demand_class
           , wiprs.description repet_sched_description
           , wiprs.firm_planned_flag repet_sched_firm_flag
           , TO_CHAR(wiprs.first_unit_completion_date, g_date_format_mask) repet_sched_first_comple_dt
           ,   -- Added for Bug 2795525
             TO_CHAR(wiprs.first_unit_start_date, g_date_format_mask) repet_sched_first_start_date
           ,   -- Added for Bug 2795525
             TO_CHAR(wiprs.last_unit_completion_date, g_date_format_mask) repet_sched_last_complet_dt
           ,   -- Added for Bug 2795525
             TO_CHAR(wiprs.last_unit_start_date, g_date_format_mask) repet_sched_last_start_date
           ,   -- Added for Bug 2795525
             TO_CHAR(wiprs.processing_work_days, g_date_format_mask) repet_sched_processing_date
           ,   -- Added for Bug 2795525
             TO_CHAR(wiprs.date_released, g_date_format_mask) repet_sched_release_date
           ,   -- Added for Bug 2795525
             wiprs.routing_revision repet_sched_routing_revision
           , mfglkp4.meaning repet_sched_schedule_status
           ,
             -- Operations
             wipops.attribute_category operations_attribute_category
           , wipops.attribute1 operations_attribute1
           , wipops.attribute2 operations_attribute2
           , wipops.attribute3 operations_attribute3
           , wipops.attribute4 operations_attribute4
           , wipops.attribute5 operations_attribute5
           , wipops.attribute6 operations_attribute6
           , wipops.attribute7 operations_attribute7
           , wipops.attribute8 operations_attribute8
           , wipops.attribute9 operations_attribute9
           , wipops.attribute10 operations_attribute10
           , wipops.attribute11 operations_attribute11
           , wipops.attribute12 operations_attribute12
           , wipops.attribute13 operations_attribute13
           , wipops.attribute14 operations_attribute14
           , wipops.attribute15 operations_attribute15
           , mfglkp5.meaning operations_backflush_flag
           , bomdep1.department_code operations_department
           , wipops.description operations_description
           , TO_CHAR(wipops.first_unit_completion_date, g_date_format_mask) operations_first_complet_dt
           ,   -- Added for Bug 2795525
             TO_CHAR(wipops.first_unit_start_date, g_date_format_mask) operations_first_receipt_date
           ,   -- Added for Bug 2795525
             TO_CHAR(wipops.last_unit_completion_date, g_date_format_mask) operations_last_complet_dt
           ,   -- Added for Bug 2795525
             TO_CHAR(wipops.last_unit_start_date, g_date_format_mask) operations_last_receipt_date
           ,   -- Added for Bug 2795525
             wipops.minimum_transfer_quantity operations_min_transfer_qty
           , wipops.scheduled_quantity operations_schedule_quantity
           , wipops.standard_operation_id operations_standard_operation
           , wipops.operation_yield operations_yield
           , wipops.operation_yield_enabled operations_yield_enabled
           ,
             -- Requirements
             wipreqops.attribute_category requirements_attribute_categ
           , wipreqops.attribute1 requirements_attribute1
           , wipreqops.attribute2 requirements_attribute2
           , wipreqops.attribute3 requirements_attribute3
           , wipreqops.attribute4 requirements_attribute4
           , wipreqops.attribute5 requirements_attribute5
           , wipreqops.attribute6 requirements_attribute6
           , wipreqops.attribute7 requirements_attribute7
           , wipreqops.attribute8 requirements_attribute8
           , wipreqops.attribute9 requirements_attribute9
           , wipreqops.attribute10 requirements_attribute10
           , wipreqops.attribute11 requirements_attribute11
           , wipreqops.attribute12 requirements_attribute12
           , wipreqops.attribute13 requirements_attribute13
           , wipreqops.attribute14 requirements_attribute14
           , wipreqops.attribute15 requirements_attribute15
           , wipreqops.comments requirements_comments
           , TO_CHAR(wipreqops.date_required, g_date_format_mask) requirements_date_required
           ,   -- Added for Bug 2795525
             bomdep2.department_code requirements_department_name
           , wipreqops.operation_seq_num requirements_operation_seq
           , wipreqops.quantity_per_assembly requirements_qty_per_assembly
           , wipreqops.required_quantity requirements_required_quantity
           , inv_project.get_locsegs(milb.inventory_location_id, milb.organization_id) requirements_supply_locator
           , wipreqops.supply_subinventory requirements_supply_sub
           , mfglkp6.meaning requirements_wip_supply_type
           , msik2.concatenated_segments requirements_item_name
           , wipent.organization_id organization_id
           , wipreqops.inventory_item_id inventory_item_id
           , wipent.entity_type entity_type
           ,
             -- LPN Content
             lpn.lpn_id lpn_id
           , lpn.license_plate_number lpn
           , plpn.lpn_id parent_lpn_id
           , plpn.license_plate_number parent_lpn
           , lpn.content_volume volume
           , lpn.content_volume_uom_code volume_uom
           , lpn.gross_weight gross_weight
           , lpn.gross_weight_uom_code gross_weight_uom
           , lpn.tare_weight tare_weight
           , lpn.tare_weight_uom_code tare_weight_uom
           , lpn.inventory_item_id lpn_container_item_id
           , msik1.concatenated_segments lpn_container_item
           , mp.organization_code ORGANIZATION
           , msik2.concatenated_segments item
           , msik2.description item_description
           , NVL(wlc.revision, l_revision) revision
           , NVL(wlc.lot_number, l_lot_number) lot
           , mmsv1.status_code lot_status
           , mln.expiration_date lot_expiration_date
           , ABS(NVL(wlc.quantity, l_quantity)) quantity
           , NVL(wlc.uom_code, l_uom) uom
           , ccg.cost_group cost_group
           , poh.hazard_class item_hazard_class
           , msik2.attribute_category item_attribute_category
           , msik2.attribute1 item_attribute1
           , msik2.attribute2 item_attribute2
           , msik2.attribute3 item_attribute3
           , msik2.attribute4 item_attribute4
           , msik2.attribute5 item_attribute5
           , msik2.attribute6 item_attribute6
           , msik2.attribute7 item_attribute7
           , msik2.attribute8 item_attribute8
           , msik2.attribute9 item_attribute9
           , msik2.attribute10 item_attribute10
           , msik2.attribute11 item_attribute11
           , msik2.attribute12 item_attribute12
           , msik2.attribute13 item_attribute13
           , msik2.attribute14 item_attribute14
           , msik2.attribute15 item_attribute15
           , lpn.attribute_category lpn_attribute_category
           , lpn.attribute1 lpn_attribute1
           , lpn.attribute2 lpn_attribute2
           , lpn.attribute3 lpn_attribute3
           , lpn.attribute4 lpn_attribute4
           , lpn.attribute5 lpn_attribute5
           , lpn.attribute6 lpn_attribute6
           , lpn.attribute7 lpn_attribute7
           , lpn.attribute8 lpn_attribute8
           , lpn.attribute9 lpn_attribute9
           , lpn.attribute10 lpn_attribute10
           , lpn.attribute11 lpn_attribute11
           , lpn.attribute12 lpn_attribute12
           , lpn.attribute13 lpn_attribute13
           , lpn.attribute14 lpn_attribute14
           , lpn.attribute15 lpn_attribute15
           , mln.lot_attribute_category lot_attribute_category
           , mln.c_attribute1 lot_c_attribute1
           , mln.c_attribute2 lot_c_attribute2
           , mln.c_attribute3 lot_c_attribute3
           , mln.c_attribute4 lot_c_attribute4
           , mln.c_attribute5 lot_c_attribute5
           , mln.c_attribute6 lot_c_attribute6
           , mln.c_attribute7 lot_c_attribute7
           , mln.c_attribute8 lot_c_attribute8
           , mln.c_attribute9 lot_c_attribute9
           , mln.c_attribute10 lot_c_attribute10
           , mln.c_attribute11 lot_c_attribute11
           , mln.c_attribute12 lot_c_attribute12
           , mln.c_attribute13 lot_c_attribute13
           , mln.c_attribute14 lot_c_attribute14
           , mln.c_attribute15 lot_c_attribute15
           , mln.c_attribute16 lot_c_attribute16
           , mln.c_attribute17 lot_c_attribute17
           , mln.c_attribute18 lot_c_attribute18
           , mln.c_attribute19 lot_c_attribute19
           , mln.c_attribute20 lot_c_attribute20
           , TO_CHAR(mln.d_attribute1, g_date_format_mask) lot_d_attribute1   -- Added for Bug 2795525,
           , TO_CHAR(mln.d_attribute2, g_date_format_mask) lot_d_attribute2   -- Added for Bug 2795525,
           , TO_CHAR(mln.d_attribute3, g_date_format_mask) lot_d_attribute3   -- Added for Bug 2795525,
           , TO_CHAR(mln.d_attribute4, g_date_format_mask) lot_d_attribute4   -- Added for Bug 2795525,
           , TO_CHAR(mln.d_attribute5, g_date_format_mask) lot_d_attribute5   -- Added for Bug 2795525,
           , TO_CHAR(mln.d_attribute6, g_date_format_mask) lot_d_attribute6   -- Added for Bug 2795525,
           , TO_CHAR(mln.d_attribute7, g_date_format_mask) lot_d_attribute7   -- Added for Bug 2795525,
           , TO_CHAR(mln.d_attribute8, g_date_format_mask) lot_d_attribute8   -- Added for Bug 2795525,
           , TO_CHAR(mln.d_attribute9, g_date_format_mask) lot_d_attribute9   -- Added for Bug 2795525,
           , TO_CHAR(mln.d_attribute10, g_date_format_mask) lot_d_attribute10   -- Added for Bug 2795525,
           , mln.n_attribute1 lot_n_attribute1
           , mln.n_attribute2 lot_n_attribute2
           , mln.n_attribute3 lot_n_attribute3
           , mln.n_attribute4 lot_n_attribute4
           , mln.n_attribute5 lot_n_attribute5
           , mln.n_attribute6 lot_n_attribute6
           , mln.n_attribute7 lot_n_attribute7
           , mln.n_attribute8 lot_n_attribute8
           , mln.n_attribute9 lot_n_attribute9
           , mln.n_attribute10 lot_n_attribute10
           , mln.territory_code lot_country_of_origin
           , mln.grade_code lot_grade_code
           , TO_CHAR(mln.origination_date, g_date_format_mask) lot_origination_date   -- Added for Bug 2795525,
           , mln.date_code lot_date_code
           , TO_CHAR(mln.change_date, g_date_format_mask) lot_change_date   -- Added for Bug 2795525,
           , mln.age lot_age
           , TO_CHAR(mln.retest_date, g_date_format_mask) lot_retest_date   -- Added for Bug 2795525,
           , TO_CHAR(mln.maturity_date, g_date_format_mask) lot_maturity_date   -- Added for Bug 2795525,
           , mln.item_size lot_item_size
           , mln.color lot_color
           , mln.volume lot_volume
           , mln.volume_uom lot_volume_uom
           , mln.place_of_origin lot_place_of_origin
           , TO_CHAR(mln.best_by_date, g_date_format_mask) lot_best_by_date   -- Added for Bug 2795525,
           , mln.LENGTH lot_length
           , mln.length_uom lot_length_uom
           , mln.recycled_content lot_recycled_cont
           , mln.thickness lot_thickness
           , mln.thickness_uom lot_thickness_uom
           , mln.width lot_width
           , mln.width_uom lot_width_uom
           , mln.curl_wrinkle_fold lot_curl
           , mln.vendor_name lot_vendor
           , lpn.subinventory_code subinventory_code
           , inv_project.get_locsegs(milkfv.inventory_location_id, milkfv.organization_id) LOCATOR
        FROM wip_entities wipent
           , wip_discrete_jobs wipdj
           , wip_repetitive_schedules wiprs
           , wip_operations wipops
           , wip_requirement_operations wipreqops
           , mtl_item_locations mila
           , mtl_item_locations milb
           , mfg_lookups mfglkp1
           , mfg_lookups mfglkp2
           , mfg_lookups mfglkp3
           , mfg_lookups mfglkp4
           , mfg_lookups mfglkp5
           , mfg_lookups mfglkp6
           , bom_departments bomdep1
           , bom_departments bomdep2
           , wms_license_plate_numbers lpn
           , wms_license_plate_numbers plpn
           , mtl_system_items_vl msik1
           , mtl_system_items_vl msik2
           , mtl_system_items_vl msik3
           , mtl_parameters mp
           , wms_lpn_contents wlc
           , mtl_lot_numbers mln
           , cst_cost_groups ccg
           , po_hazard_classes poh
           , mtl_material_statuses_vl mmsv1
           , mtl_item_locations milkfv
       WHERE wipdj.wip_entity_id(+) = wipent.wip_entity_id
         AND wipdj.organization_id(+) = wipent.organization_id
         AND wiprs.wip_entity_id(+) = wipent.wip_entity_id
         AND wiprs.organization_id(+) = wipent.organization_id
         -- Bug 2781198. operation information missing for discrete jobs
         -- should join to wipent
         AND wipops.wip_entity_id(+) = wipent.wip_entity_id
         AND wipops.organization_id(+) = wipent.organization_id
         AND NVL(wipops.repetitive_schedule_id, -999) = NVL(wiprs.repetitive_schedule_id, NVL(wipops.repetitive_schedule_id, -999))
         AND wipreqops.wip_entity_id = wipent.wip_entity_id
         AND wipreqops.organization_id = wipent.organization_id
         AND wipreqops.operation_seq_num = NVL(wipops.operation_seq_num, l_operation_seq_num)
         AND NVL(wipreqops.repetitive_schedule_id, 999) = NVL(wipops.repetitive_schedule_id, NVL(wipreqops.repetitive_schedule_id, 999))
         AND mfglkp1.lookup_code(+) = wipent.entity_type
         AND mfglkp1.lookup_type(+) = 'WIP_ENTITY'
         AND mfglkp2.lookup_code(+) = wipdj.job_type
         AND mfglkp2.lookup_type(+) = 'WIP_DISCRETE_JOB'
         AND mfglkp3.lookup_code(+) = wipdj.status_type
         AND mfglkp3.lookup_type(+) = 'WIP_JOB_STATUS'
         AND mfglkp4.lookup_code(+) = wiprs.status_type
         AND mfglkp4.lookup_type(+) = 'WIP_JOB_STATUS'
         AND mfglkp5.lookup_code(+) = wipops.backflush_flag
         AND mfglkp5.lookup_type(+) = 'SYS_YES_NO'
         AND mfglkp6.lookup_code(+) = wipreqops.wip_supply_type
         AND mfglkp6.lookup_type(+) = 'WIP_SUPPLY'
         AND mila.inventory_location_id(+) = wipdj.completion_locator_id
         AND milb.inventory_location_id(+) = wipreqops.supply_locator_id
         AND bomdep1.department_id(+) = wipops.department_id
         AND bomdep2.department_id(+) = wipreqops.department_id
         AND wipreqops.inventory_item_id = l_inventory_item_id
         AND wipreqops.operation_seq_num = l_operation_seq_num
         AND wipent.wip_entity_id = l_wip_entity_id
         AND wipent.organization_id = l_organization_id
         AND NVL(wiprs.repetitive_schedule_id, -99) = NVL(l_repetitive_schedule_id, NVL(wiprs.repetitive_schedule_id, -99))
         AND lpn.lpn_id = l_lpn_id
         AND lpn.parent_lpn_id = plpn.lpn_id(+)
         AND wlc.parent_lpn_id(+) = l_lpn_id
         AND wlc.inventory_item_id(+) = wipreqops.inventory_item_id
         AND NVL(wlc.revision, NVL(l_revision, '$$$')) =
                      NVL(l_revision, NVL(wlc.revision, '$$$'))   -- Bug 2440672 For Agilent -- Takes care of non-LPN Revision controlled items
         AND NVL(wlc.lot_number, NVL(l_lot_number, '$$$')) =
                       NVL(l_lot_number, NVL(wlc.lot_number, '$$$'))   -- Bug 2440672 For Agilent -- Takes care of non-LPN Lot controlled items
         AND msik1.inventory_item_id(+) = lpn.inventory_item_id
         AND msik1.organization_id(+) = lpn.organization_id
         AND mp.organization_id = lpn.organization_id
         AND milkfv.organization_id(+) = lpn.organization_id
         AND milkfv.subinventory_code(+) = lpn.subinventory_code
         AND milkfv.inventory_location_id(+) = lpn.locator_id
         AND msik2.inventory_item_id(+) = NVL(wlc.inventory_item_id, l_inventory_item_id)
         AND msik2.organization_id(+) = NVL(wlc.organization_id, l_organization_id)
         AND mln.organization_id(+) = NVL(wlc.organization_id, l_organization_id)
         AND mln.inventory_item_id(+) = NVL(wlc.inventory_item_id, l_inventory_item_id)
         AND mln.lot_number(+) = NVL(wlc.lot_number, l_lot_number)
         AND mmsv1.status_id(+) = mln.status_id
         AND ccg.cost_group_id(+) = NVL(wlc.cost_group_id, l_cost_group_id)
         AND poh.hazard_class_id(+) = msik2.hazard_class_id
         AND msik3.inventory_item_id(+) = wipent.primary_item_id   -- Bug 2440672 For Agilent  -- Added Outer Join for non-Standard Jobs.
         AND msik3.organization_id(+) = wipent.organization_id;   -- Bug 2440672 For Agilent  -- Added Outer Join for non-Standard Jobs.

    l_selected_fields        inv_label.label_field_variable_tbl_type;
    l_selected_fields_count  NUMBER;
    l_label_format_id        NUMBER                                  := 0;
    l_label_format           VARCHAR2(100);
    l_printer                VARCHAR2(30);
    l_content_item_data      LONG;
    l_content_rec_index      NUMBER                                  := 0;
    l_return_status          VARCHAR2(240);
    l_error_message          VARCHAR2(240);
    l_msg_count              NUMBER;
    l_api_status             VARCHAR2(240);
    l_msg_data               VARCHAR2(240);
    i                        NUMBER;
    l_id                     NUMBER;
    l_label_index            NUMBER;
    l_label_request_id       NUMBER;
    --I cleanup, use l_prev_format_id to record the previous label format
    l_prev_format_id         NUMBER;
    -- I cleanup, user l_prev_sub to record the previous subinventory
    --so that get_printer is not called if the subinventory is the same
    l_prev_sub               VARCHAR2(30);
    -- a list of columns that are selected for format
    l_column_name_list       LONG;
    v_wip_content            wip_content_cur%ROWTYPE;
  BEGIN
    l_debug              := inv_label.l_debug;
    -- Initialize return status as success
    x_return_status      := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      TRACE('**In PVT9: Wip Content label**');
      TRACE('  Business_flow: ' || p_label_type_info.business_flow_code);
      TRACE('  Transaction ID:' || p_transaction_id);
    END IF;

    -- Get
    IF p_transaction_id IS NOT NULL THEN
      -- txn driven
      IF p_label_type_info.business_flow_code IN(28) THEN
        -- WIP Pick Load
        OPEN wip_lines_cur;

        FETCH wip_lines_cur
         INTO l_organization_id
            , l_wip_entity_id
            , l_repetitive_schedule_id
            , l_inventory_item_id
            , l_operation_seq_num
            , l_lpn_id
            , l_revision
            , l_lot_number
            , l_quantity
            , l_uom
            , l_cost_group_id
            , l_subinventory
            , l_project_name
            , l_task_name;

        IF wip_lines_cur%NOTFOUND THEN
          IF (l_debug = 1) THEN
            TRACE(' No record found for Wip Pick load , no WIP content label print');
          END IF;

          CLOSE wip_lines_cur;

          RETURN;
        END IF;
        -- Bug 2781198 Label fails for  lot controlled component
        -- Should not close cursor here so that more lot will be retrieved later
      --CLOSE wip_lines_cur;
      ELSIF p_label_type_info.business_flow_code IN(29) THEN
        -- WIP Pick Drop
        OPEN wip_drop_lines_cur;

        FETCH wip_drop_lines_cur
         INTO l_organization_id
            , l_wip_entity_id
            , l_repetitive_schedule_id
            , l_inventory_item_id
            , l_operation_seq_num
            , l_lpn_id
            , l_revision
            , l_lot_number
            , l_quantity
            , l_uom
            , l_cost_group_id
            , l_subinventory
            , l_project_name
            , l_task_name;

        IF wip_drop_lines_cur%NOTFOUND THEN
          IF (l_debug = 1) THEN
            TRACE(' No record found for Wip Pick drop, no WIP content label print');
          END IF;

          CLOSE wip_drop_lines_cur;

          RETURN;
        END IF;
      -- Bug 2781198 Label fails for  lot controlled component
        -- Should not close cursor here so that more lot will be retrieved later
      --CLOSE wip_drop_lines_cur;
      ELSIF p_label_type_info.business_flow_code = 37 THEN
           -- Bug Number: 2829872
        -- Manufacturing Cross Dock(37)
        OPEN wip_cross_dock_cur;

        FETCH wip_cross_dock_cur
         INTO l_organization_id
            , l_wip_entity_id
            , l_repetitive_schedule_id
            , l_inventory_item_id
            , l_operation_seq_num
            , l_lpn_id
            , l_revision
            , l_lot_number
            , l_quantity
            , l_uom
            , l_cost_group_id
            , l_subinventory
            , l_project_name
            , l_task_name;

        IF wip_cross_dock_cur%NOTFOUND THEN
          IF (l_debug = 1) THEN
            TRACE(' No record found for Manufacturing cross dock, no WIP content label print');
          END IF;

          CLOSE wip_cross_dock_cur;

          RETURN;
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          TRACE(' Invalid business flow code ' || p_label_type_info.business_flow_code);
        END IF;

        RETURN;
      END IF;
    ELSE
      -- On demand, get information from input_param
      --hjogleka, Bug #6417575,Label Printing Support for WIP Move Transactions (12.1)
      l_wip_entity_id      := p_input_param.transaction_source_id;
      l_organization_id    := p_input_param.organization_id;
      IF (l_debug = 1) THEN
        TRACE('Manual mode, now available');
      END IF;

    END IF;

    IF (l_debug = 1) THEN
      TRACE(' Getting selected fields ');
    END IF;

    inv_label.get_variables_for_format(x_variables => l_selected_fields, x_variables_count => l_selected_fields_count
    , p_format_id                  => p_label_type_info.default_format_id);

    IF (l_selected_fields_count = 0)
       OR(l_selected_fields.COUNT = 0) THEN
      IF (l_debug = 1) THEN
        TRACE('no fields defined for this format: ' || p_label_type_info.default_format_id || ',' || p_label_type_info.default_format_name);
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      TRACE(' Found variable defined for this format, count = ' || l_selected_fields_count);
    END IF;

    l_content_rec_index  := 0;

    IF (l_debug = 1) THEN
      TRACE('** in PVT9.get_variable_data ** , start ');
    END IF;

    l_printer            := p_label_type_info.default_printer;
    l_label_index        := 1;
    l_prev_format_id     := p_label_type_info.default_format_id;
    l_prev_sub           := '####';

    WHILE l_wip_entity_id IS NOT NULL LOOP
      l_content_item_data  := '';

      IF (l_debug = 1) THEN
        TRACE(
             ' New WIP Content label '
          || ' l_inventory_item_id='
          || l_inventory_item_id
          || ' l_operation_seq_num='
          || l_operation_seq_num
          || ' l_wip_entity_id='
          || l_wip_entity_id
          || ' l_organization_id='
          || l_organization_id
          || ' l_repetitive_schedule_id='
          || l_repetitive_schedule_id
          || ' l_lpn_id='
          || l_lpn_id
        );
      END IF;

      --hjogleka, Bug #6417575,Label Printing Support for WIP Move Transactions (12.1)
      --  Choosing the cursor to fetch WIP Job Attributes based on transaction mode.

      IF p_transaction_id IS NOT NULL THEN
        OPEN wip_content_cur;
        IF (l_debug = 1) THEN
          TRACE('Opening wip_content_cur');
        END IF;
      ELSE
        OPEN wip_discrete_cur;
        IF (l_debug = 1) THEN
          TRACE('Opening wip_discrete_cur');
        END IF;

        -- Bug #6843199, 7031542, getting project name and task number
        --     for the job when the label is printed in manual mode.
        BEGIN
           SELECT pp.SEGMENT1
                , pt.TASK_NUMBER
           INTO   l_project_name
                , l_task_name
           FROM   wip_discrete_jobs wdj
                , pa_projects_all pp
                , pa_tasks pt
           WHERE  wdj.wip_entity_id = l_wip_entity_id
             AND  wdj.organization_id = l_organization_id
             AND  pp.project_id(+) = wdj.project_id
             AND  pt.task_id(+) = wdj.task_id;

        EXCEPTION
           WHEN OTHERS THEN
              l_project_name := NULL;
              l_task_name    := NULL;
        END;
      END IF;

      --FOR v_wip_content IN wip_content_cur
      LOOP

        IF p_transaction_id IS NOT NULL THEN
          FETCH wip_content_cur INTO v_wip_content;
          EXIT WHEN wip_content_cur%NOTFOUND;
        ELSE
          FETCH wip_discrete_cur INTO v_wip_content;
          EXIT WHEN wip_discrete_cur%NOTFOUND;
        END IF;

        l_content_rec_index                                 := l_content_rec_index + 1;

        IF (l_debug = 1) THEN
          TRACE(' New Label ' || l_content_rec_index);
        END IF;



	--R12 : RFID compliance project
	--Calling rules engine before calling to get printer

        IF (l_debug = 1) THEN
          TRACE(
               'Apply Rules engine for format'
            || ',manual_format_id='
            || p_label_type_info.manual_format_id
            || ',manual_format_name='
            || p_label_type_info.manual_format_name
          );
        END IF;

        /* insert a record into wms_label_requests entity to
        call the label rules engine to get appropriate label */

        inv_label.get_format_with_rule(
          p_document_id                => p_label_type_info.label_type_id
        , p_label_format_id            => p_label_type_info.manual_format_id
        , p_organization_id            => v_wip_content.organization_id
        , p_inventory_item_id          => v_wip_content.inventory_item_id
	, p_lpn_id                     => l_lpn_id -- Bug 5509692.
        , p_last_update_date           => SYSDATE
        , p_last_updated_by            => fnd_global.user_id
        , p_creation_date              => SYSDATE
        , p_created_by                 => fnd_global.user_id
        --, p_printer_name               => l_printer-- Removed in R12: 4396558
        , p_business_flow_code         => p_label_type_info.business_flow_code
        , x_return_status              => l_return_status
        , x_label_format_id            => l_label_format_id
        , x_label_format               => l_label_format
        , x_label_request_id           => l_label_request_id
        );

        IF l_return_status <> 'S' THEN
          fnd_message.set_name('WMS', 'WMS_LABL_RULE_ENGINE_FAILED');
          fnd_msg_pub.ADD;
          l_label_format     := p_label_type_info.default_format_id;
          l_label_format_id  := p_label_type_info.default_format_name;
        END IF;

        IF (l_debug = 1) THEN
          TRACE('did apply label ' || l_label_format || ',' || l_label_format_id || ',req_id ' || l_label_request_id);
        END IF;

        IF p_label_type_info.manual_format_id IS NOT NULL THEN
          l_label_format_id  := p_label_type_info.manual_format_id;
          l_label_format     := p_label_type_info.manual_format_name;

          IF (l_debug = 1) THEN
            TRACE('Manual format passed in:' || l_label_format_id || ',' || l_label_format);
          END IF;
        END IF;


        IF (l_debug = 1) THEN
          TRACE(
               ' Getting printer, manual_printer='
            || p_label_type_info.manual_printer
            || ',sub='
            || l_subinventory
            || ',default printer='
            || p_label_type_info.default_printer
          );
        END IF;

        -- IF clause Added for Add format/printer for manual request
        IF p_label_type_info.manual_printer IS NULL THEN
          IF (l_subinventory IS NOT NULL)
             AND(l_subinventory <> l_prev_sub) THEN
            IF (l_debug = 1) THEN
              TRACE('getting printer with org, sub' || l_organization_id || ',' || l_subinventory);
            END IF;

            BEGIN
              wsh_report_printers_pvt.get_printer(
                p_concurrent_program_id      => p_label_type_info.label_type_id
              , p_user_id                    => fnd_global.user_id
              , p_responsibility_id          => fnd_global.resp_id
              , p_application_id             => fnd_global.resp_appl_id
              , p_organization_id            => l_organization_id
	      , p_format_id                  =>l_label_format_id --added in r12 RFID 4396558
	      , p_zone                       => l_subinventory
              , x_printer                    => l_printer
              , x_api_status                 => l_api_status
              , x_error_message              => l_error_message
              );

              IF l_api_status <> 'S' THEN
                IF (l_debug = 1) THEN
                  TRACE('Error in calling get_printer, set printer as default printer, err_msg:' || l_error_message);
                END IF;

                l_printer  := p_label_type_info.default_printer;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                l_printer  := p_label_type_info.default_printer;
            END;

            l_prev_sub  := l_subinventory;

          END IF;
        ELSE
          IF (l_debug = 1) THEN
            TRACE('Set printer as Manual Printer passed in:' || p_label_type_info.manual_printer);
          END IF;

          l_printer  := p_label_type_info.manual_printer;
        END IF;




        IF (l_label_format_id IS NOT NULL) THEN
          -- Derive the fields for the format either passed in or derived via the rules engine.
          IF l_label_format_id <> NVL(l_prev_format_id, -999) THEN
            IF (l_debug = 1) THEN
              TRACE(' Getting variables for new format ' || l_label_format);
            END IF;

            inv_label.get_variables_for_format(x_variables => l_selected_fields, x_variables_count => l_selected_fields_count
            , p_format_id                  => l_label_format_id);
            l_prev_format_id  := l_label_format_id;

            IF (l_selected_fields_count = 0)
               OR(l_selected_fields.COUNT = 0) THEN
              IF (l_debug = 1) THEN
                TRACE('no fields defined for this format: ' || l_label_format || ',' || l_label_format_id);
              END IF;

              GOTO nextlabel;
            END IF;

            IF (l_debug = 1) THEN
              TRACE('   Found selected_fields for format ' || l_label_format || ', num=' || l_selected_fields_count);
            END IF;
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            TRACE('No format exists for this label, goto nextlabel');
          END IF;

          GOTO nextlabel;
        END IF;

        /* variable header */
        l_content_item_data                                 := l_content_item_data || label_b;

        IF l_label_format <> NVL(p_label_type_info.default_format_name, '@@@') THEN
          l_content_item_data  := l_content_item_data || ' _FORMAT="' || NVL(p_label_type_info.manual_format_name, l_label_format) || '"';
        END IF;

        IF (l_printer IS NOT NULL)
           AND(l_printer <> NVL(p_label_type_info.default_printer, '###')) THEN
          l_content_item_data  := l_content_item_data || ' _PRINTERNAME="' || l_printer || '"';
        END IF;

        l_content_item_data                                 := l_content_item_data || tag_e;

        IF (l_debug = 1) THEN
          TRACE('Starting assign variables, ');
        END IF;

        l_column_name_list                                  := 'Set variables for ';

        /* Modified for Bug 4072474 -start*/
		  l_custom_sql_ret_status := FND_API.G_RET_STS_SUCCESS;
		  /* Modified for Bug 4072474 -End*/

        -- Fix for bug: 4179593 Start
        l_CustSqlWarnFlagSet := FALSE;
        l_CustSqlErrFlagSet := FALSE;
        l_CustSqlWarnMsg := NULL;
        l_CustSqlErrMsg := NULL;
        -- Fix for bug: 4179593 End

        /* Loop for each selected fields, find the columns and write into the XML_content*/
        FOR i IN 1 .. l_selected_fields.COUNT LOOP
          IF (l_debug = 1) THEN
            l_column_name_list  := l_column_name_list || ',' || l_selected_fields(i).column_name;
          END IF;

---------------------------------------------------------------------------------------------
-- Project: 'Custom Labels' (A 11i10+ Project)                                               |
-- Author: Dinesh (dchithir@oracle.com)                                                      |
-- Change Description:                                                                       |
--  The check (SQL_STMT <> NULL and COLUMN_NAME = NULL) implies that the field is a          |
--  Custom SQL based field. Handle it appropriately.                                         |
---------------------------------------------------------------------------------------------
      		  IF (l_selected_fields(i).SQL_STMT IS NOT NULL AND l_selected_fields(i).column_name = 'sql_stmt') THEN
      			 IF (l_debug = 1) THEN
      			  trace('Custom Labels Trace [INVLAP9B.pls]: ------------------------- REPORT BEGIN-------------------------------------');
      			  trace('Custom Labels Trace [INVLAP9B.pls]: LABEL_FIELD_ID       : ' || l_selected_fields(i).label_field_id);
      			  trace('Custom Labels Trace [INVLAP9B.pls]: FIELD_VARIABLE_NAME  : ' || l_selected_fields(i).variable_name);
      			  trace('Custom Labels Trace [INVLAP9B.pls]: COLUMN_NAME          : ' || l_selected_fields(i).column_name);
      			  trace('Custom Labels Trace [INVLAP9B.pls]: SQL_STMT             : ' || l_selected_fields(i).sql_stmt);
      			 END IF;
      			 l_sql_stmt := l_selected_fields(i).sql_stmt;
      			 IF (l_debug = 1) THEN
      			  trace('Custom Labels Trace [INVLAP9B.pls]: l_sql_stmt BEFORE REQUEST_ID Filter Concatenation: ' || l_sql_stmt);
      			 END IF;
      			 l_sql_stmt := l_sql_stmt || ' AND WLR.LABEL_REQUEST_ID = :REQUEST_ID';
      			 IF (l_debug = 1) THEN
      			  trace('Custom Labels Trace [INVLAP9B.pls]: l_sql_stmt AFTER REQUEST_ID Filter Concatenation: ' || l_sql_stmt);

      			 END IF;
      			 BEGIN
      			 IF (l_debug = 1) THEN
      			  trace('Custom Labels Trace [INVLAP9B.pls]: At Breadcrumb 1');
      			  trace('Custom Labels Trace [INVLAP9B.pls]: LABEL_REQUEST_ID     : ' || l_label_request_id);
      			 END IF;
      			 OPEN c_sql_stmt FOR l_sql_stmt using l_label_request_id;
      			 LOOP
      				 FETCH c_sql_stmt INTO l_sql_stmt_result;
      				 EXIT WHEN c_sql_stmt%notfound OR c_sql_stmt%rowcount >=2;
      			 END LOOP;

                IF (c_sql_stmt%rowcount=1 AND l_sql_stmt_result IS NULL) THEN
                  x_return_status := FND_API.G_RET_STS_SUCCESS;
                  l_custom_sql_ret_status  := INV_LABEL.G_WARNING;

                  fnd_message.set_name('WMS','WMS_CS_NULL_VALUE_RETURNED');
                  fnd_msg_pub.ADD;
                  -- Fix for bug: 4179593 Start
                  --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
                  l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                  l_CustSqlWarnMsg := l_custom_sql_ret_msg;
                  l_CustSqlWarnFlagSet := TRUE;
                  -- Fix for bug: 4179593 End
                 IF (l_debug = 1) THEN
                  trace('Custom Labels Trace [INVLAP9B.pls]: At Breadcrumb 2');
                  trace('Custom Labels Trace [INVLAP9B.pls]: l_sql_stmt_result is: ' || l_sql_stmt_result);
                  trace('Custom Labels Trace [INVLAP9B.pls]: WARNING: NULL value returned by the custom SQL Query.');
                  trace('Custom Labels Trace [INVLAP9B.pls]: l_custom_sql_ret_status  is set to : ' || l_custom_sql_ret_status );
                 END IF;
                ELSIF c_sql_stmt%rowcount=0 THEN
      				IF (l_debug = 1) THEN
      				 trace('Custom Labels Trace [INVLAP9B.pls]: At Breadcrumb 3');
                   trace('Custom Labels Trace [INVLAP9B.pls]: WARNING: No row returned by the Custom SQL query');
      				END IF;
                  x_return_status := FND_API.G_RET_STS_SUCCESS;
                  l_custom_sql_ret_status  := INV_LABEL.G_WARNING;

      				fnd_message.set_name('WMS','WMS_CS_NO_DATA_FOUND');
      				fnd_msg_pub.ADD;
                  /* Replaced following statement for Bug 4207625: Anupam Jain*/
         			/*fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_status);*/
                  -- Fix for bug: 4179593 Start
                  --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
                  l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                  l_CustSqlWarnMsg := l_custom_sql_ret_msg;
                  l_CustSqlWarnFlagSet := TRUE;
                  -- Fix for bug: 4179593 End
      			 ELSIF c_sql_stmt%rowcount>=2 THEN
      				IF (l_debug = 1) THEN
      				 trace('Custom Labels Trace [INVLAP9B.pls]: At Breadcrumb 4');
      				 trace('Custom Labels Trace [INVLAP9B.pls]: ERROR: Multiple values returned by the Custom SQL query');
      				END IF;
                  l_sql_stmt_result := NULL;
                  x_return_status := FND_API.G_RET_STS_SUCCESS;
                  l_custom_sql_ret_status  := FND_API.G_RET_STS_ERROR;
      				fnd_message.set_name('WMS','WMS_CS_MULTIPLE_VALUES_RETURN');
      				fnd_msg_pub.ADD;
                  /* Replaced following statement for Bug 4207625: Anupam Jain*/
         			/*fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_status);*/
                  -- Fix for bug: 4179593 Start
                  --fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => l_custom_sql_ret_msg);
                  l_custom_sql_ret_msg := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_last, p_encoded => fnd_api.g_false);
                  l_CustSqlErrMsg := l_custom_sql_ret_msg;
                  l_CustSqlErrFlagSet := TRUE;
                  -- Fix for bug: 4179593 End
      			 END IF;
                IF (c_sql_stmt%ISOPEN) THEN
	               CLOSE c_sql_stmt;
                END IF;
      			EXCEPTION
      			WHEN OTHERS THEN
               IF (c_sql_stmt%ISOPEN) THEN
	               CLOSE c_sql_stmt;
               END IF;
      			  IF (l_debug = 1) THEN
      				trace('Custom Labels Trace [INVLAP9B.pls]: At Breadcrumb 5');
      				trace('Custom Labels Trace [INVLAP9B.pls]: Unexpected Error has occured in GET_VARIABLES_DATA');
      			  END IF;
      			  x_return_status := FND_API.G_RET_STS_ERROR;
      			  fnd_message.set_name('WMS','WMS_CS_WRONG_SQL_CONSTRUCT');
      			  fnd_msg_pub.ADD;
      			  fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      			  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      		   END;
      		   IF (l_debug = 1) THEN
      			  trace('Custom Labels Trace [INVLAP9B.pls]: At Breadcrumb 6');
      			  trace('Custom Labels Trace [INVLAP9B.pls]: Before assigning it to l_content_item_data');
      		   END IF;
      			l_content_item_data  :=   l_content_item_data
      							   || variable_b
      							   || l_selected_fields(i).variable_name
      							   || '">'
      							   || l_sql_stmt_result
      							   || variable_e;
      			l_sql_stmt_result := NULL;
      			l_sql_stmt        := NULL;
      			IF (l_debug = 1) THEN
      			  trace('Custom Labels Trace [INVLAP9B.pls]: At Breadcrumb 7');
      			  trace('Custom Labels Trace [INVLAP9B.pls]: After assigning it to l_content_item_data');
                 trace('Custom Labels Trace [INVLAP9B.pls]: --------------------------REPORT END-------------------------------------');
      			END IF;
------------------------End of this change for Custom Labels project code--------------------
          ELSIF LOWER(l_selected_fields(i).column_name) = 'current_date' THEN
            l_content_item_data  :=
                          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || inv_label.g_date || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'current_time' THEN
            l_content_item_data  :=
                          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || inv_label.g_time || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'request_user' THEN
            l_content_item_data  :=
                          l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || inv_label.g_user || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_schedule_type' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_schedule_type
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_schedule_name' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_schedule_name
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_schedule_description' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.job_schedule_description
              || variable_e;
          -- Bug 2112635. A data field for the Assembly of the Job on the WIP Contents Label.
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_assembly' THEN
            l_content_item_data  :=
                l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_assembly || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'assembly_description' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.assembly_description
              || variable_e;
          /* Discrete Jobs */
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_accounting_class' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.job_accounting_class
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute_category' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.job_attribute_category
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute1' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_attribute1 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute2' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_attribute2 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute3' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_attribute3 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute4' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_attribute4 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute5' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_attribute5 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute6' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_attribute6 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute7' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_attribute7 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute8' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_attribute8 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute9' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_attribute9 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute10' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_attribute10
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute11' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_attribute11
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute12' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_attribute12
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute13' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_attribute13
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute14' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_attribute14
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_attribute15' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_attribute15
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_bom_revision' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_bom_revision
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_completion_locator' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.job_completion_locator
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_completion_subinventory' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.job_completion_subinventory
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_demand_class' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_demand_class
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_due_date' THEN
            l_content_item_data  :=
                l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_due_date || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_job_type' THEN
            l_content_item_data  :=
                l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_job_type || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_net_quantity' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_net_quantity
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_priority' THEN
            l_content_item_data  :=
                l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_priority || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_release_date' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_release_date
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_routing_revision' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.job_routing_revision
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_schedule_completion_date' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.job_schedule_completion_date
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_start_date' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_start_date || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_start_quantity' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_start_quantity
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'job_status_type' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.job_status_type
              || variable_e;
          /* Repetive Schedule */
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_alternate_bom' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_alternate_bom
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_alternate_routing' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_alternate_routing
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute_category' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute_category
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute1' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute1
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute2' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute2
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute3' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute3
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute4' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute4
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute5' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute5
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute6' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute6
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute7' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute7
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute8' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute8
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute9' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute9
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute10' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute10
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute11' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute11
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute12' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute12
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute13' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute13
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute14' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute14
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_attribute15' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_attribute15
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_bom_revision' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_bom_revision
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_daily_quantity' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_daily_quantity
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_demand_class' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_demand_class
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_description' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_description
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_firm_flag' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_firm_flag
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_first_comple_dt' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_first_comple_dt
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_first_start_date' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_first_start_date
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_last_complet_dt' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_last_complet_dt
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_last_start_date' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_last_start_date
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_processing_date' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_processing_date
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_release_date' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_release_date
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_routing_revision' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_routing_revision
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'repet_sched_schedule_status' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.repet_sched_schedule_status
              || variable_e;
          /*Operations*/
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute_category' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute_category
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute1' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute1
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute2' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute2
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute3' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute3
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute4' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute4
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute5' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute5
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute6' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute6
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute7' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute7
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute8' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute8
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute9' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute9
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute10' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute10
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute11' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute11
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute12' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute12
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute13' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute13
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute14' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute14
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_attribute15' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_attribute15
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_backflush_flag' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_backflush_flag
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_department' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_department
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_description' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_description
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_first_complet_dt' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_first_complet_dt
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_first_receipt_date' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_first_receipt_date
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_last_complet_dt' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_last_complet_dt
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_last_receipt_date' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_last_receipt_date
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_min_transfer_qty' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_min_transfer_qty
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_schedule_quantity' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_schedule_quantity
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_standard_operation' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_standard_operation
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_yield' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.operations_yield
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'operations_yield_enabled' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.operations_yield_enabled
              || variable_e;
          /* Requirements */
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute_categ' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute_categ
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute1' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute1
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute2' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute2
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute3' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute3
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute4' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute4
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute5' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute5
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute6' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute6
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute7' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute7
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute8' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute8
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute9' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute9
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute10' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute10
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute11' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute11
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute12' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute12
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute13' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute13
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute14' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute14
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_attribute15' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_attribute15
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_comments' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_comments
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_date_required' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_date_required
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_department_name' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_department_name
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_operation_seq' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_operation_seq
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_qty_per_assembly' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_qty_per_assembly
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_required_quantity' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_required_quantity
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_supply_locator' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_supply_locator
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_supply_sub' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_supply_sub
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_wip_supply_type' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_wip_supply_type
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'requirements_item_name' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.requirements_item_name
              || variable_e;
          /* LPN Content*/
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn' THEN
            l_content_item_data  :=
                         l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'parent_lpn' THEN
            l_content_item_data  :=
                  l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.parent_lpn || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'volume' THEN
            l_content_item_data  :=
                      l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.volume || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'volume_uom' THEN
            l_content_item_data  :=
                  l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.volume_uom || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'gross_weight' THEN
            l_content_item_data  :=
                l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.gross_weight || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'gross_weight_uom' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.gross_weight_uom
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'tare_weight' THEN
            l_content_item_data  :=
                 l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.tare_weight || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'tare_weight_uom' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.tare_weight_uom
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_container_item' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_container_item
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'organization' THEN
            l_content_item_data  :=
                l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.ORGANIZATION || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'subinventory_code' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.subinventory_code
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'locator' THEN
            l_content_item_data  :=
                     l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.LOCATOR || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item' THEN
            l_content_item_data  :=
                        l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_description' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_description
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'revision' THEN
            l_content_item_data  :=
                    l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.revision || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot' THEN
            l_content_item_data  :=
                         l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_status' THEN
            l_content_item_data  :=
                  l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_status || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_expiration_date' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_expiration_date
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'quantity' THEN
			   /* bug 7016426 */
			   IF  p_label_type_info.business_flow_code = 37  THEN
			      -- in case x-dock dock qty does not consume the entire qty
			      -- IN the lpn, it should only print the qty that is
			      -- allocated  TO the wip x-dock and not the entire left out
			      -- qty IN the LPN, taking qty from corresponding MMTT
			      -- instead FOR wip x-dock

			      l_content_item_data  := l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || Abs(l_quantity) || variable_e;
			    ELSE
			      l_content_item_data  :=l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.quantity || variable_e;
			   END IF;
			   /*  bug 7016426 */
				 ELSIF LOWER(l_selected_fields(i).column_name) = 'uom' THEN
            l_content_item_data  :=
                         l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.uom || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'cost_group' THEN
            l_content_item_data  :=
                  l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.cost_group || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_hazard_class' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_hazard_class
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute_category' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.item_attribute_category
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute1' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_attribute1
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute2' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_attribute2
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute3' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_attribute3
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute4' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_attribute4
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute5' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_attribute5
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute6' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_attribute6
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute7' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_attribute7
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute8' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_attribute8
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute9' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_attribute9
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute10' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_attribute10
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute11' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_attribute11
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute12' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_attribute12
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute13' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_attribute13
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute14' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_attribute14
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'item_attribute15' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.item_attribute15
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute_category' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.lpn_attribute_category
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute1' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_attribute1 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute2' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_attribute2 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute3' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_attribute3 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute4' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_attribute4 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute5' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_attribute5 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute6' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_attribute6 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute7' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_attribute7 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute8' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_attribute8 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute9' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_attribute9 || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute10' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_attribute10
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute11' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_attribute11
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute12' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_attribute12
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute13' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_attribute13
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute14' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_attribute14
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lpn_attribute15' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lpn_attribute15
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_attribute_category' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.lot_attribute_category
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute1' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute1
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute2' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute2
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute3' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute3
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute4' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute4
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute5' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute5
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute6' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute6
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute7' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute7
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute8' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute8
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute9' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute9
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute10' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute10
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute11' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute11
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute12' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute12
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute13' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute13
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute14' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute14
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute15' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute15
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute16' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute16
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute17' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute17
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute18' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute18
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute19' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute19
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_c_attribute20' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_c_attribute20
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute1' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_d_attribute1
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute2' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_d_attribute2
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute3' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_d_attribute3
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute4' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_d_attribute4
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute5' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_d_attribute5
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute6' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_d_attribute6
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute7' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_d_attribute7
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute8' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_d_attribute8
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute9' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_d_attribute9
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_d_attribute10' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_d_attribute10
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute1' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_n_attribute1
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute2' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_n_attribute2
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute3' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_n_attribute3
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute4' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_n_attribute4
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute5' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_n_attribute5
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute6' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_n_attribute6
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute7' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_n_attribute7
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute8' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_n_attribute8
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute9' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_n_attribute9
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_n_attribute10' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_n_attribute10
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_country_of_origin' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.lot_country_of_origin
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_grade_code' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_grade_code || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_origination_date' THEN
            l_content_item_data  :=
                 l_content_item_data
              || variable_b
              || l_selected_fields(i).variable_name
              || '">'
              || v_wip_content.lot_origination_date
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_date_code' THEN
            l_content_item_data  :=
               l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_date_code || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_change_date' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_change_date
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_age' THEN
            l_content_item_data  :=
                     l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_age || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_retest_date' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_retest_date
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_maturity_date' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_maturity_date
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_item_size' THEN
            l_content_item_data  :=
               l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_item_size || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_color' THEN
            l_content_item_data  :=
                   l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_color || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_volume' THEN
            l_content_item_data  :=
                  l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_volume || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_volume_uom' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_volume_uom || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_place_of_origin' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_place_of_origin
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_best_by_date' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_best_by_date
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_length' THEN
            l_content_item_data  :=
                  l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_length || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_length_uom' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_length_uom || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_recycled_cont' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_recycled_cont
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_thickness' THEN
            l_content_item_data  :=
               l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_thickness || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_thickness_uom' THEN
            l_content_item_data  :=
              l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_thickness_uom
              || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_width' THEN
            l_content_item_data  :=
                   l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_width || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_width_uom' THEN
            l_content_item_data  :=
               l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_width_uom || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_curl' THEN
            l_content_item_data  :=
                    l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_curl || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'lot_vendor' THEN
            l_content_item_data  :=
                  l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || v_wip_content.lot_vendor || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'project' THEN
            l_content_item_data  :=
                            l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || l_project_name || variable_e;
          ELSIF LOWER(l_selected_fields(i).column_name) = 'task' THEN
            l_content_item_data  :=
                               l_content_item_data || variable_b || l_selected_fields(i).variable_name || '">' || l_task_name || variable_e;
          END IF;
        END LOOP;

        l_content_item_data                                 := l_content_item_data || label_e;
        x_variable_content(l_label_index).label_content     := l_content_item_data;
        x_variable_content(l_label_index).label_request_id  := l_label_request_id;

------------------------Start of changes for Custom Labels project code------------------
        -- Fix for bug: 4179593 Start
        IF (l_CustSqlWarnFlagSet) THEN
         l_custom_sql_ret_status := INV_LABEL.G_WARNING;
         l_custom_sql_ret_msg := l_CustSqlWarnMsg;
        END IF;

        IF (l_CustSqlErrFlagSet) THEN
         l_custom_sql_ret_status := FND_API.G_RET_STS_ERROR;
         l_custom_sql_ret_msg := l_CustSqlErrMsg;
        END IF;
        -- Fix for bug: 4179593 End

        x_variable_content(l_label_index).label_status      := l_custom_sql_ret_status ;
        x_variable_content(l_label_index).error_message     := l_custom_sql_ret_msg;

------------------------End of this changes for Custom Labels project code---------------

        l_label_index                                       := l_label_index + 1;

        <<nextlabel>>
	  l_content_item_data                                 := '';
	l_custom_sql_ret_status  := NULL;
	l_custom_sql_ret_msg     := NULL;

        IF (l_debug = 1) THEN
          TRACE(l_column_name_list);
          TRACE('	Finished writing variables ');
        END IF;
      END LOOP;

      IF p_transaction_id IS NOT NULL THEN
        CLOSE wip_content_cur;
      ELSE
        CLOSE wip_discrete_cur;
      END IF;

      --x_variable_content := x_variable_content || l_content_item_data ;

        IF p_label_type_info.business_flow_code IN(28) THEN
          FETCH wip_lines_cur
           INTO l_organization_id
              , l_wip_entity_id
              , l_repetitive_schedule_id
              , l_inventory_item_id
              , l_operation_seq_num
              , l_lpn_id
              , l_revision
              , l_lot_number
              , l_quantity
              , l_uom
              , l_cost_group_id
              , l_subinventory
              , l_project_name
              , l_task_name;

          IF wip_lines_cur%NOTFOUND THEN
            IF (l_debug = 1) THEN
              TRACE(' No more record found for Wip Pick load, end of WIP content label');
            END IF;

            CLOSE wip_lines_cur;

            l_wip_entity_id  := NULL;
          END IF;
        ELSIF p_label_type_info.business_flow_code IN(29) THEN
          FETCH wip_drop_lines_cur
           INTO l_organization_id
              , l_wip_entity_id
              , l_repetitive_schedule_id
              , l_inventory_item_id
              , l_operation_seq_num
              , l_lpn_id
              , l_revision
              , l_lot_number
              , l_quantity
              , l_uom
              , l_cost_group_id
              , l_subinventory
              , l_project_name
              , l_task_name;

          IF wip_drop_lines_cur%NOTFOUND THEN
            IF (l_debug = 1) THEN
              TRACE(' No more record found for Wip Pick drop, end of WIP content label');
            END IF;

            CLOSE wip_drop_lines_cur;

            l_wip_entity_id  := NULL;
          END IF;
        ELSIF p_label_type_info.business_flow_code = 37 THEN
          -- Bug Number: 2829872
          -- Manufacturing Cross Dock(37)
          FETCH wip_cross_dock_cur
           INTO l_organization_id
              , l_wip_entity_id
              , l_repetitive_schedule_id
              , l_inventory_item_id
              , l_operation_seq_num
              , l_lpn_id
              , l_revision
              , l_lot_number
              , l_quantity
              , l_uom
              , l_cost_group_id
              , l_subinventory
              , l_project_name
              , l_task_name;

          IF wip_cross_dock_cur%NOTFOUND THEN
            IF (l_debug = 1) THEN
              TRACE(' No more record found for Manufacturing cross dock, end of WIP content label');
            END IF;

            CLOSE wip_cross_dock_cur;

            l_wip_entity_id  := NULL;
          END IF;
        ELSE
          l_wip_entity_id  := NULL;
        END IF;
    END LOOP;
  END get_variable_data;

  PROCEDURE get_variable_data(
    x_variable_content       OUT NOCOPY    LONG
  , x_msg_count              OUT NOCOPY    NUMBER
  , x_msg_data               OUT NOCOPY    VARCHAR2
  , x_return_status          OUT NOCOPY    VARCHAR2
  , p_label_type_info        IN            inv_label.label_type_rec
  , p_transaction_id         IN            NUMBER
  , p_input_param            IN            mtl_material_transactions_temp%ROWTYPE
  , p_transaction_identifier IN            NUMBER
  ) IS
    l_variable_data_tbl inv_label.label_tbl_type;
  BEGIN
    get_variable_data(
      x_variable_content           => l_variable_data_tbl
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_return_status              => x_return_status
    , p_label_type_info            => p_label_type_info
    , p_transaction_id             => p_transaction_id
    , p_input_param                => p_input_param
    , p_transaction_identifier     => p_transaction_identifier
    );
    x_variable_content  := '';

    FOR i IN 1 .. l_variable_data_tbl.COUNT() LOOP
      x_variable_content  := x_variable_content || l_variable_data_tbl(i).label_content;
    END LOOP;
  END get_variable_data;
END inv_label_pvt9;

/
