--------------------------------------------------------
--  DDL for Package Body WSMPLBJI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPLBJI" AS
/* $Header: WSMLBJIB.pls 120.11 2006/09/06 06:21:58 mprathap noship $ */

-- the following declarations are global to WSMPLBJI
-- PS: Although they have been declared as private to the package,
-- please note that each concurrent request submitted has it's own
-- session, hence each submission of launch worker will have it's
-- own set of "global" variables and tables.

-- BUG 3934661
-- when calling dbms_utility.get_hash_value use larger seed number
-- OLD: dbms_utility.get_hash_value(str, 1000, 5625);
-- NEW: dbms_utility.get_hash_value(str, 37, 1073741824);

v_index NUMBER;
v_wsli_index  NUMBER;

-- ==============================================================================================
-- nested table types used to bulk bind data from wlji to the PL/SQL tables.
-- ==============================================================================================
type t_wlji_err_code                    is table of wsm_lot_job_interface.error_code%type;
type t_wlji_err_msg                     is table of wsm_lot_job_interface.error_msg%type;
type t_wlji_last_updt_date              is table of wsm_lot_job_interface.last_update_date%type;
type t_wlji_request_id                  is table of wsm_lot_job_interface.request_id%type;
type t_wlji_program_id                  is table of wsm_lot_job_interface.program_id%type;
type t_wlji_program_application_id      is table of wsm_lot_job_interface.program_application_id%type;
type t_wlji_last_updt_by                is table of wsm_lot_job_interface.last_updated_by%type;
type t_wlji_creation_date               is table of wsm_lot_job_interface.creation_date%type;
type t_wlji_created_by                  is table of wsm_lot_job_interface.created_by%type;
type t_wlji_last_updt_login             is table of wsm_lot_job_interface.last_update_login%type;
type t_wlji_prog_updt_date              is table of wsm_lot_job_interface.program_update_date%type;
type t_wlji_last_updt_by_name           is table of wsm_lot_job_interface.last_updated_by_name%type;
type t_wlji_created_by_name             is table of wsm_lot_job_interface.created_by_name%type;
type t_wlji_org                         is table of wsm_lot_job_interface.organization_id%type;
type t_wlji_item                        is table of wsm_lot_job_interface.primary_item_id%type;
type t_wlji_header_id                   is table of wsm_lot_job_interface.header_id%type;
type t_wlji_process_status              is table of wsm_lot_job_interface.process_status%type;
type t_wlji_routing_reference_id        is table of wsm_lot_job_interface.routing_reference_id%type;
type t_wlji_completion_subinventory     is table of wsm_lot_job_interface.completion_subinventory%type;
type t_wlji_completion_locator_id       is table of wsm_lot_job_interface.completion_locator_id%type;
type t_wlji_mode_flag                   is table of wsm_lot_job_interface.mode_flag%type;
type t_wlji_group_id                    is table of wsm_lot_job_interface.group_id%type;
type t_wlji_load_type                   is table of wsm_lot_job_interface.load_type%type;
type t_wlji_status_type                 is table of wsm_lot_job_interface.status_type%type;
type t_wlji_lucd                        is table of wsm_lot_job_interface.last_unit_completion_date%type;
type t_wlji_old_completion_date         is table of wsm_lot_job_interface.old_completion_date%type;
type t_wlji_bom_reference_id            is table of wsm_lot_job_interface.bom_reference_id%type;
type t_wlji_bom_revision_date           is table of wsm_lot_job_interface.bom_revision_date%type;
type t_wlji_routing_revision_date       is table of wsm_lot_job_interface.routing_revision_date%type;
type t_wlji_wip_supply_type             is table of wsm_lot_job_interface.wip_supply_type%type;
type t_wlji_class_code                  is table of wsm_lot_job_interface.class_code%type;
type t_wlji_lot_number                  is table of wsm_lot_job_interface.lot_number%type;
type t_wlji_job_name                    is table of wsm_lot_job_interface.job_name%type;
type t_wlji_description                 is table of wsm_lot_job_interface.description%type;
type t_wlji_firm_planned_flag           is table of wsm_lot_job_interface.firm_planned_flag%type;
type t_wlji_alt_routing_designator      is table of wsm_lot_job_interface.alternate_routing_designator%type;
type t_wlji_alt_bom_designator          is table of wsm_lot_job_interface.alternate_bom_designator%type;
type t_wlji_demand_class                is table of wsm_lot_job_interface.demand_class%type;
type t_wlji_start_quantity              is table of wsm_lot_job_interface.start_quantity%type;
type t_wlji_old_start_quantity          is table of wsm_lot_job_interface.old_start_quantity%type;
type t_wlji_wip_entity_id               is table of wsm_lot_job_interface.wip_entity_id%type;
type t_wlji_error                       is table of wsm_lot_job_interface.error%type;
type t_wlji_process_phase               is table of wsm_lot_job_interface.process_phase%type;
type t_wlji_fusd                        is table of wsm_lot_job_interface.first_unit_start_date%type;
type t_wlji_fucd                        is table of wsm_lot_job_interface.first_unit_completion_date%type;
type t_wlji_last_unit_start_date        is table of wsm_lot_job_interface.last_unit_start_date%type;
type t_wlji_scheduling_method           is table of wsm_lot_job_interface.scheduling_method%type;
type t_wlji_routing_revision            is table of wsm_lot_job_interface.routing_revision%type;
type t_wlji_bom_revision                is table of wsm_lot_job_interface.bom_revision%type;
type t_wlji_schedule_group_id           is table of wsm_lot_job_interface.schedule_group_id%type;
type t_wlji_schedule_group_name         is table of wsm_lot_job_interface.schedule_group_name%type;
type t_wlji_build_sequence              is table of wsm_lot_job_interface.build_sequence%type;
type t_wlji_net_quantity                is table of wsm_lot_job_interface.net_quantity%type;
type t_wlji_allow_explosion             is table of wsm_lot_job_interface.allow_explosion%type;
type t_wlji_old_status_type             is table of wsm_lot_job_interface.old_status_type%type;
type t_wlji_interface_id                is table of wsm_lot_job_interface.interface_id%type;
type t_wlji_coproducts_supply           is table of wsm_lot_job_interface.coproducts_supply%type;
type t_wlji_job_type                    is table of wsm_lot_job_interface.job_type%type;
type t_wlji_source_code                 is table of wsm_lot_job_interface.source_code%type;
type t_wlji_source_line_id              is table of wsm_lot_job_interface.source_line_id%type;
type t_wlji_project_id                  is table of wsm_lot_job_interface.project_id%type;
type t_wlji_project_name                is table of wsm_lot_job_interface.project_name%type;
type t_wlji_task_id                     is table of wsm_lot_job_interface.task_id%type;
type t_wlji_delivery_id                 is table of wsm_lot_job_interface.delivery_id%type;
type t_wlji_desc_flx_sgmts              is table of wsm_lot_job_interface.descriptive_flex_segments%type;
type t_wlji_project_number              is table of wsm_lot_job_interface.project_number%type;
type t_wlji_task_number                 is table of wsm_lot_job_interface.task_number%type;
type t_wlji_project_costed              is table of wsm_lot_job_interface.project_costed%type;
type t_wlji_end_item_unit_number        is table of wsm_lot_job_interface.end_item_unit_number%type;
type t_wlji_overcompl_tol_type          is table of wsm_lot_job_interface.overcompletion_tolerance_type%type;
type t_wlji_overcompl_tol_value         is table of wsm_lot_job_interface.overcompletion_tolerance_value%type;
type t_wlji_kanban_card_id              is table of wsm_lot_job_interface.kanban_card_id%type;
type t_wlji_priority                    is table of wsm_lot_job_interface.priority%type;
type t_wlji_due_date                    is table of wsm_lot_job_interface.due_date%type;
type t_wlji_task_name                   is table of wsm_lot_job_interface.task_name%type;
type t_wlji_process_type                is table of wsm_lot_job_interface.process_type%type;
type t_wlji_processing_work_days        is table of wsm_lot_job_interface.processing_work_days%type;
type t_wlji_compl_locator_segments      is table of wsm_lot_job_interface.completion_locator_segments%type;
type t_wlji_daily_production_rate       is table of wsm_lot_job_interface.daily_production_rate%type;
type t_wlji_line_id                     is table of wsm_lot_job_interface.line_id%type;
type t_wlji_lot_control_code            is table of wsm_lot_job_interface.lot_control_code%type;
type t_wlji_repetitive_schedule_id      is table of wsm_lot_job_interface.repetitive_schedule_id%type;
type t_wlji_parent_group_id             is table of wsm_lot_job_interface.parent_group_id%type;
type t_wlji_attribute_category          is table of wsm_lot_job_interface.attribute_category%type;
type t_wlji_attribute1                  is table of wsm_lot_job_interface.attribute1%type;
type t_wlji_attribute2                  is table of wsm_lot_job_interface.attribute2%type;
type t_wlji_attribute3                  is table of wsm_lot_job_interface.attribute3%type;
type t_wlji_attribute4                  is table of wsm_lot_job_interface.attribute4%type;
type t_wlji_attribute5                  is table of wsm_lot_job_interface.attribute5%type;
type t_wlji_attribute6                  is table of wsm_lot_job_interface.attribute6%type;
type t_wlji_attribute7                  is table of wsm_lot_job_interface.attribute7%type;
type t_wlji_attribute8                  is table of wsm_lot_job_interface.attribute8%type;
type t_wlji_attribute9                  is table of wsm_lot_job_interface.attribute9%type;
type t_wlji_attribute10                 is table of wsm_lot_job_interface.attribute10%type;
type t_wlji_attribute11                 is table of wsm_lot_job_interface.attribute11%type;
type t_wlji_attribute12                 is table of wsm_lot_job_interface.attribute12%type;
type t_wlji_attribute13                 is table of wsm_lot_job_interface.attribute13%type;
type t_wlji_attribute14                 is table of wsm_lot_job_interface.attribute14%type;
type t_wlji_attribute15                 is table of wsm_lot_job_interface.attribute15%type;
type t_wlji_organization_code           is table of wsm_lot_job_interface.organization_code%type;
type t_wlji_line_code                   is table of wsm_lot_job_interface.line_code%type;
type t_wlji_primary_item_segments       is table of wsm_lot_job_interface.primary_item_segments%type;
type t_wlji_bom_reference_segments      is table of wsm_lot_job_interface.bom_reference_segments%type;
type t_wlji_rtg_ref_segs                is table of wsm_lot_job_interface.routing_reference_segments%type;
type t_wlji_date_released               is table of wsm_lot_job_interface.date_released%type;  --bugfix 2697295


-- ==============================================================================================
-- instantiating the tables used to bulk bind data from wlji to the PL/SQL tables.
-- ==============================================================================================

v_wlji_err_code                         t_wlji_err_code := t_wlji_err_code();
v_wlji_err_msg                          t_wlji_err_msg := t_wlji_err_msg();
v_wlji_last_updt_date                   t_wlji_last_updt_date := t_wlji_last_updt_date();
v_wlji_request_id                       t_wlji_request_id := t_wlji_request_id();
v_wlji_program_id                       t_wlji_program_id := t_wlji_program_id();
v_wlji_program_application_id           t_wlji_program_application_id := t_wlji_program_application_id();
v_wlji_last_updt_by                     t_wlji_last_updt_by := t_wlji_last_updt_by();
v_wlji_creation_date                    t_wlji_creation_date := t_wlji_creation_date();
v_wlji_created_by                       t_wlji_created_by := t_wlji_created_by();
v_wlji_last_updt_login                  t_wlji_last_updt_login := t_wlji_last_updt_login();
v_wlji_prog_updt_date                   t_wlji_prog_updt_date := t_wlji_prog_updt_date();
v_wlji_last_updt_by_name                t_wlji_last_updt_by_name := t_wlji_last_updt_by_name();
v_wlji_created_by_name                  t_wlji_created_by_name := t_wlji_created_by_name();
v_wlji_org                              t_wlji_org := t_wlji_org();
v_wlji_item                             t_wlji_item := t_wlji_item();
v_wlji_header_id                        t_wlji_header_id := t_wlji_header_id();
v_wlji_process_status                   t_wlji_process_status := t_wlji_process_status();
v_wlji_routing_reference_id             t_wlji_routing_reference_id := t_wlji_routing_reference_id();
v_wlji_completion_subinventory          t_wlji_completion_subinventory := t_wlji_completion_subinventory();
v_wlji_completion_locator_id            t_wlji_completion_locator_id := t_wlji_completion_locator_id();
v_wlji_mode_flag                        t_wlji_mode_flag := t_wlji_mode_flag();
v_wlji_group_id                         t_wlji_group_id := t_wlji_group_id();
v_wlji_load_type                        t_wlji_load_type := t_wlji_load_type();
v_wlji_status_type                      t_wlji_status_type := t_wlji_status_type();
v_wlji_old_status_type                  t_wlji_old_status_type := t_wlji_old_status_type();
v_wlji_lucd                             t_wlji_lucd := t_wlji_lucd();
v_wlji_old_completion_date              t_wlji_old_completion_date := t_wlji_old_completion_date();
v_wlji_bom_reference_id                 t_wlji_bom_reference_id := t_wlji_bom_reference_id();
v_wlji_bom_revision_date                t_wlji_bom_revision_date := t_wlji_bom_revision_date();
v_wlji_routing_revision_date            t_wlji_routing_revision_date := t_wlji_routing_revision_date();
v_wlji_wip_supply_type                  t_wlji_wip_supply_type := t_wlji_wip_supply_type();
v_wlji_class_code                       t_wlji_class_code := t_wlji_class_code();
v_wlji_lot_number                       t_wlji_lot_number := t_wlji_lot_number();
v_wlji_job_name                         t_wlji_job_name := t_wlji_job_name();
v_wlji_description                      t_wlji_description := t_wlji_description();
v_wlji_firm_planned_flag                t_wlji_firm_planned_flag := t_wlji_firm_planned_flag();
v_wlji_alt_routing_designator           t_wlji_alt_routing_designator := t_wlji_alt_routing_designator();
v_wlji_alt_bom_designator               t_wlji_alt_bom_designator := t_wlji_alt_bom_designator();
v_wlji_demand_class                     t_wlji_demand_class := t_wlji_demand_class();
v_wlji_start_quantity                   t_wlji_start_quantity := t_wlji_start_quantity();
v_wlji_old_start_quantity               t_wlji_old_start_quantity := t_wlji_old_start_quantity();
v_wlji_wip_entity_id                    t_wlji_wip_entity_id := t_wlji_wip_entity_id();
v_wlji_error                            t_wlji_error := t_wlji_error();
v_wlji_process_phase                    t_wlji_process_phase := t_wlji_process_phase();
v_wlji_fusd                             t_wlji_fusd := t_wlji_fusd();
v_wlji_fucd                             t_wlji_fucd := t_wlji_fucd();
v_wlji_last_unit_start_date             t_wlji_last_unit_start_date := t_wlji_last_unit_start_date();
v_wlji_scheduling_method                t_wlji_scheduling_method := t_wlji_scheduling_method();
v_wlji_routing_revision                 t_wlji_routing_revision := t_wlji_routing_revision();
v_wlji_bom_revision                     t_wlji_bom_revision := t_wlji_bom_revision();
v_wlji_schedule_group_id                t_wlji_schedule_group_id := t_wlji_schedule_group_id();
v_wlji_schedule_group_name              t_wlji_schedule_group_name := t_wlji_schedule_group_name();
v_wlji_build_sequence                   t_wlji_build_sequence := t_wlji_build_sequence();
v_wlji_net_quantity                     t_wlji_net_quantity := t_wlji_net_quantity();
v_wlji_allow_explosion                  t_wlji_allow_explosion := t_wlji_allow_explosion();
v_wlji_interface_id                     t_wlji_interface_id := t_wlji_interface_id();
v_wlji_coproducts_supply                t_wlji_coproducts_supply := t_wlji_coproducts_supply();
v_wlji_job_type                         t_wlji_job_type := t_wlji_job_type();
v_wlji_source_code                      t_wlji_source_code := t_wlji_source_code();
v_wlji_source_line_id                   t_wlji_source_line_id := t_wlji_source_line_id();
v_wlji_process_type                     t_wlji_process_type := t_wlji_process_type();
v_wlji_processing_work_days             t_wlji_processing_work_days := t_wlji_processing_work_days();
v_wlji_daily_production_rate            t_wlji_daily_production_rate := t_wlji_daily_production_rate();
v_wlji_line_id                          t_wlji_line_id := t_wlji_line_id();
v_wlji_lot_control_code                 t_wlji_lot_control_code := t_wlji_lot_control_code();
v_wlji_repetitive_schedule_id           t_wlji_repetitive_schedule_id := t_wlji_repetitive_schedule_id();
v_wlji_parent_group_id                  t_wlji_parent_group_id := t_wlji_parent_group_id();
v_wlji_attribute_category               t_wlji_attribute_category := t_wlji_attribute_category();
v_wlji_attribute1                       t_wlji_attribute1 := t_wlji_attribute1();
v_wlji_attribute2                       t_wlji_attribute2 := t_wlji_attribute2();
v_wlji_attribute3                       t_wlji_attribute3 := t_wlji_attribute3();
v_wlji_attribute4                       t_wlji_attribute4 := t_wlji_attribute4();
v_wlji_attribute5                       t_wlji_attribute5 := t_wlji_attribute5();
v_wlji_attribute6                       t_wlji_attribute6 := t_wlji_attribute6();
v_wlji_attribute7                       t_wlji_attribute7 := t_wlji_attribute7();
v_wlji_attribute8                       t_wlji_attribute8 := t_wlji_attribute8();
v_wlji_attribute9                       t_wlji_attribute9 := t_wlji_attribute9();
v_wlji_attribute10                      t_wlji_attribute10 := t_wlji_attribute10();
v_wlji_attribute11                      t_wlji_attribute11 := t_wlji_attribute11();
v_wlji_attribute12                      t_wlji_attribute12 := t_wlji_attribute12();
v_wlji_attribute13                      t_wlji_attribute13 := t_wlji_attribute13();
v_wlji_attribute14                      t_wlji_attribute14 := t_wlji_attribute14();
v_wlji_attribute15                      t_wlji_attribute15 := t_wlji_attribute15();
v_wlji_organization_code                t_wlji_organization_code := t_wlji_organization_code();
v_wlji_line_code                        t_wlji_line_code := t_wlji_line_code();
v_wlji_primary_item_segments            t_wlji_primary_item_segments := t_wlji_primary_item_segments();
v_wlji_bom_reference_segments           t_wlji_bom_reference_segments := t_wlji_bom_reference_segments();
v_wlji_rtg_ref_segs                     t_wlji_rtg_ref_segs := t_wlji_rtg_ref_segs();
v_wlji_compl_locator_segments           t_wlji_compl_locator_segments := t_wlji_compl_locator_segments();
v_wlji_project_id                       t_wlji_project_id := t_wlji_project_id();
v_wlji_project_name                     t_wlji_project_name := t_wlji_project_name();
v_wlji_task_id                          t_wlji_task_id := t_wlji_task_id();
v_wlji_task_name                        t_wlji_task_name := t_wlji_task_name();
v_wlji_desc_flx_sgmts                   t_wlji_desc_flx_sgmts := t_wlji_desc_flx_sgmts();
v_wlji_project_number                   t_wlji_project_number := t_wlji_project_number();
v_wlji_task_number                      t_wlji_task_number := t_wlji_task_number();
v_wlji_project_costed                   t_wlji_project_costed := t_wlji_project_costed();
v_wlji_end_item_unit_number             t_wlji_end_item_unit_number := t_wlji_end_item_unit_number();
v_wlji_overcompl_tol_type               t_wlji_overcompl_tol_type := t_wlji_overcompl_tol_type();
v_wlji_overcompl_tol_value              t_wlji_overcompl_tol_value := t_wlji_overcompl_tol_value();
v_wlji_kanban_card_id                   t_wlji_kanban_card_id := t_wlji_kanban_card_id();
v_wlji_priority                         t_wlji_priority := t_wlji_priority();
v_wlji_due_date                         t_wlji_due_date := t_wlji_due_date();
v_wlji_delivery_id                      t_wlji_delivery_id := t_wlji_delivery_id();
v_wlji_date_released                    t_wlji_date_released := t_wlji_date_released();       --bugfix 2697295


--=======================================================================================================
--corresponding table type and table declarations for wsm_starting_lots_interface
--=======================================================================================================

type t_wsli_header_id           is table of wsm_starting_lots_interface.header_id%type;
type t_wsli_lot_number          is table of wsm_starting_lots_interface.lot_number%type;
type t_wsli_inventory_item_id   is table of wsm_starting_lots_interface.inventory_item_id%type;
type t_wsli_organization_id     is table of wsm_starting_lots_interface.organization_id%type;
type t_wsli_quantity            is table of wsm_starting_lots_interface.quantity%type;
type t_wsli_subinventory_code   is table of wsm_starting_lots_interface.subinventory_code%type;
type t_wsli_locator_id          is table of wsm_starting_lots_interface.locator_id%type;
type t_wsli_revision            is table of wsm_starting_lots_interface.revision%type;
type t_wsli_last_updated_by     is table of wsm_starting_lots_interface.last_updated_by%type;
type t_wsli_created_by          is table of wsm_starting_lots_interface.created_by%type;
type t_wsli_primary_uom_code    is table of mtl_system_items.primary_uom_code%type;
type t_wsli_comp_issue_qty      is table of wsm_starting_lots_interface.component_issue_quantity%type;

v_wsli_header_id                t_wsli_header_id := t_wsli_header_id();
v_wsli_lot_number               t_wsli_lot_number := t_wsli_lot_number();
v_wsli_inventory_item_id        t_wsli_inventory_item_id := t_wsli_inventory_item_id();
v_wsli_organization_id          t_wsli_organization_id := t_wsli_organization_id();
v_wsli_quantity                 t_wsli_quantity := t_wsli_quantity();
v_wsli_subinventory_code        t_wsli_subinventory_code := t_wsli_subinventory_code();
v_wsli_locator_id               t_wsli_locator_id := t_wsli_locator_id();
v_wsli_revision                 t_wsli_revision := t_wsli_revision();
v_wsli_last_updated_by          t_wsli_last_updated_by := t_wsli_last_updated_by();
v_wsli_created_by               t_wsli_created_by := t_wsli_created_by();
v_wsli_primary_uom_code         t_wsli_primary_uom_code := t_wsli_primary_uom_code();
v_wsli_comp_issue_qty           t_wsli_comp_issue_qty := t_wsli_comp_issue_qty();

-- ========================================================================================================
-- creating an index by table that'll store the wsli values with header_id as the index for easy validation
-- ========================================================================================================

type rec_wsli IS record(
        lot_number              wsm_starting_lots_interface.lot_number%type,
        inventory_item_id       wsm_starting_lots_interface.inventory_item_id%type,
        organization_id         wsm_starting_lots_interface.organization_id%type,
        quantity                wsm_starting_lots_interface.quantity%type,
        subinventory_code       wsm_starting_lots_interface.subinventory_code%type,
        locator_id              wsm_starting_lots_interface.locator_id%type,
        revision                wsm_starting_lots_interface.revision%type,
        last_updated_by         wsm_starting_lots_interface.last_updated_by%type,
        created_by              wsm_starting_lots_interface.created_by%type,
        primary_uom_code        mtl_system_items.primary_uom_code%type,
        comp_issue_quantity     wsm_starting_lots_interface.component_issue_quantity%type);

v_rec_wsli rec_wsli;

type t_wsli                     IS table of rec_wsli index by binary_integer;
v_wsli  t_wsli;


routing_seq_id                  NUMBER;
bom_seq_id                      NUMBER;
p_common_routing_sequence_id    NUMBER;
p_common_bill_sequence_id       NUMBER;
l_atleast_one_osp_exists        NUMBER := 0;

--***********************************************************************************************
-- ==============================================================================================
-- PROCESS_INTERFACE_ROWS
-- ==============================================================================================
--***********************************************************************************************


-- BEGIN: CZHDBG TBD after UT
function get_one_org_id (
    p_group_id in number,
    p_status   in number
) RETURN NUMBER IS

cursor c_org is
    select  organization_id,
            organization_code
    from    wsm_lot_job_interface
    where   process_status = p_status
    and     NVL(transaction_date, creation_date) <= sysdate+1
    and     NVL(group_id, -99) = NVL(p_group_id, NVL(group_id, -99))
    and     load_type in (5, 6)
    union
    select  organization_id,
            organization_code
    from    wsm_lot_job_dtl_interface
    where   process_status = p_status
    and     parent_header_id IS NULL
    and     NVL(group_id, -99) = NVL(p_group_id, NVL(group_id, -99))
    and     transaction_date <= sysdate+1;

l_temp      number;
l_org_id    number      := null;
l_org_code  varchar2(10):= null;

BEGIN

    -- get an org_id from interface table
    OPEN c_org;
    FETCH c_org into l_org_id, l_org_code;
    if c_org%NOTFOUND then
        fnd_file.put_line(fnd_file.log, 'get_one_org_id: No entry is found in interface table');
        return -1;
    end if;
    CLOSE c_org;

    if l_org_id IS NULL then
        begin
            --bug 5051783:Replaced org_organization_definitions with mtl_parameters.
            select organization_id
            into   l_org_id
            --from   ORG_ORGANIZATION_DEFINITIONS
            from   mtl_parameters
            where  organization_code = l_org_code;
        exception
            when others then
                fnd_message.set_name('WSM','WSM_INVALID_FIELD');
                fnd_message.set_token('FLD_NAME', 'Organization Code');
                fnd_file.put_line(fnd_file.log, 'get_one_org_id: ' || fnd_message.get);
                return -1;
        end;
    end if;

    begin
        select  1
        into    l_temp
        from    MTL_PARAMETERS MP ,
                WSM_PARAMETERS WSM,
                HR_ALL_ORGANIZATION_UNITS ORG,
                WIP_PARAMETERS WP
        where   MP.ORGANIZATION_ID  =  WSM.ORGANIZATION_ID
        and     ORG.ORGANIZATION_ID =  WSM.ORGANIZATION_ID
        and     WP.ORGANIZATION_ID  =  WSM.ORGANIZATION_ID
        and     UPPER(MP.WSM_ENABLED_FLAG)='Y'
        and     TRUNC(SYSDATE) <= NVL(ORG.DATE_TO, SYSDATE+1)
        and     WSM.ORGANIZATION_ID = l_org_id;
    exception
        when others then
            fnd_message.set_name('WSM','WSM_INVALID_FIELD');
            fnd_message.set_token('FLD_NAME', 'Organization ID');
            fnd_file.put_line(fnd_file.log, 'get_one_org_id: ' || fnd_message.get);
            return -1;
    end;

    return l_org_id;
END;
-- END: CZHDBG TBD after UT


PROCEDURE process_interface_rows (
        retcode         OUT NOCOPY NUMBER,
        errbuf          OUT NOCOPY VARCHAR2,
        p_group_id      IN  NUMBER) IS

l_org_id        number;
l_profile       number;
conc_status     boolean;

BEGIN

    IF (WSMPUTIL.REFER_SITE_LEVEL_PROFILE = 'Y') THEN
        l_profile := WSMPUTIL.CREATE_LBJ_COPY_RTG_PROFILE(0);
    ELSE
        l_org_id := get_one_org_id(p_group_id, WIP_CONSTANTS.PENDING);
        if (l_org_id = -1) then
            conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
                        'Error: failed in  get_one_org_id');
            return;
        end if;
        l_profile := WSMPUTIL.CREATE_LBJ_COPY_RTG_PROFILE(l_org_id);
    END IF;

    if(l_profile = 2) then
        g_create_job_copy := 'N';
        fnd_file.put_line(fnd_file.log,
            '++++++ Start calling WSMPLBJI.process_lbji_rows_1159 ++++++');
        process_lbji_rows_1159 (retcode, errbuf, p_group_id);
        fnd_file.put_line(fnd_file.log,
            '++++++ End calling WSMPLBJI.process_lbji_rows_1159 ++++++');
    else
        g_create_job_copy := 'Y';
        fnd_file.put_line(fnd_file.log,
            '++++++ Start calling WSM_LBJ_INTERFACE_PVT.process_lbji_rows ++++++');
        WSM_LBJ_INTERFACE_PVT.process_lbji_rows(retcode, errbuf, p_group_id);
        fnd_file.put_line(fnd_file.log,
            '++++++ End calling WSM_LBJ_INTERFACE_PVT.process_lbji_rows ++++++');
    end if;

END process_interface_rows ;


--***********************************************************************************************
-- ==============================================================================================
-- LAUNCH WORKER
-- ==============================================================================================
--***********************************************************************************************

PROCEDURE  launch_worker (
        retcode         OUT NOCOPY NUMBER,
        errbuf          OUT NOCOPY VARCHAR2,
        l_group_id      IN  NUMBER,
        alotted_rows    IN  NUMBER  ) IS

l_org_id        number; -- CZHDBG: TBD after UT
l_profile       number;
conc_status     boolean;

BEGIN

    IF (WSMPUTIL.REFER_SITE_LEVEL_PROFILE = 'Y') THEN
        l_profile := WSMPUTIL.CREATE_LBJ_COPY_RTG_PROFILE(0);
    ELSE
        l_org_id := get_one_org_id(l_group_id, WIP_CONSTANTS.RUNNING);
        if (l_org_id = -1) then
            conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
                        'Error: failed in  get_one_org_id');
            return;
        end if;
        l_profile := WSMPUTIL.CREATE_LBJ_COPY_RTG_PROFILE(l_org_id);
    END IF;

    if(l_profile = 2) then
        g_create_job_copy := 'N';
        fnd_file.put_line(fnd_file.log, '++++++ Calling WSMPLBJI.launch_worker_1159 ++++++');
        WSMPLBJI.launch_worker_1159(retcode, errbuf, l_group_id, alotted_rows);
    else
        g_create_job_copy := 'Y';
        fnd_file.put_line(fnd_file.log, '++++++ Calling WSM_LBJ_INTERFACE_PVT.launch_worker ++++++');
        WSM_LBJ_INTERFACE_PVT.launch_worker(retcode, errbuf, l_group_id, alotted_rows);
    end if;

END launch_worker;




--***********************************************************************************************
-- ==============================================================================================
-- PROCEDURE build_lbji_info
-- ==============================================================================================
--***********************************************************************************************

-- For job creation, this needs to be called with p_rtg_op_seq_num as the rtg op_seq_num of the
-- first operation. The other option is to call this with rtg_op_seq_num as null, then it'll be
-- assumed that the procedure is being called for job creation. This is being done solely for
-- avoiding repetition of code. hence from a performance point of view.

-- p_explode_header_detail = null => write into we,wdj and wo tables
--                         = 1 => write only into wo tables
--                         = 2 => write only into we/wdj tables

-- Note that a new wip_entity_id will be generated only if the procedure is called with
-- p_explode_header_detail as null or 2. In some cases we may use build_lbji_info for
-- just exploding details for an existing header. In that case, p_explode_header_detail
-- should have value 1 and the value of wip_entity_id that is passed is used.

-- p_src_client_server: 1 => this procedure is being called from client side,
--              any other value => server side call.

-- p_po_creation_time: => pass the value of po_creation_time in wip_parameters for the org

procedure build_lbji_info(
        p_routing_seq_id                IN      number,
        p_common_bill_sequence_id       IN      number,
        p_explode_header_detail         IN      number,
        p_status_type                   IN      number,
        p_class_code                    IN      varchar2,
        p_org                           IN      number,
        p_wip_entity_id                 IN OUT NOCOPY number,
        p_last_updt_date                IN      date,
        p_last_updt_by                  IN      number,
        p_creation_date                 IN      date,
        p_created_by                    IN      number,
        p_last_updt_login               IN      number,
        p_request_id                    IN      number,
        p_program_application_id        IN      number,
        p_program_id                    IN      number,
        p_prog_updt_date                IN      date,
        p_source_line_id                IN      number,
        p_source_code                   IN      varchar2,
        p_description                   IN      varchar2,
        p_item                          IN      number,
        p_job_type                      IN      number,
        p_bom_reference_id              IN      number,
        p_routing_reference_id          IN      number,
        p_firm_planned_flag             IN      number,
        p_wip_supply_type               IN      number,
        p_fusd                          IN      date,
        p_lucd                          IN      date,
        p_start_quantity                IN      number,
        p_net_quantity                  IN      number,
        p_coproducts_supply             IN      number,
        p_bom_revision                  IN      varchar2,
        p_routing_revision              IN      varchar2,
        p_bom_revision_date             IN      date,
        p_routing_revision_date         IN      date,
        p_lot_number                    IN      varchar2,
        p_alt_bom_designator            IN      varchar2,
        p_alt_routing_designator        IN      varchar2,
        p_priority                      IN      number,
        p_due_date                      IN      date,
        p_attribute_category            IN      varchar2,
        p_attribute1                    IN      varchar2,
        p_attribute2                    IN      varchar2,
        p_attribute3                    IN      varchar2,
        p_attribute4                    IN      varchar2,
        p_attribute5                    IN      varchar2,
        p_attribute6                    IN      varchar2,
        p_attribute7                    IN      varchar2,
        p_attribute8                    IN      varchar2,
        p_attribute9                    IN      varchar2,
        p_attribute10                   IN      varchar2,
        p_attribute11                   IN      varchar2,
        p_attribute12                   IN      varchar2,
        p_attribute13                   IN      varchar2,
        p_attribute14                   IN      varchar2,
        p_attribute15                   IN      varchar2,
        p_job_name                      IN      varchar2,
        p_completion_subinventory       IN      varchar2,
        p_completion_locator_id         IN      number,
        p_demand_class                  IN      varchar2,
        p_project_id                    IN      number,
        p_task_id                       IN      number,
        p_schedule_group_id             IN      number,
        p_build_sequence                IN      number,
        p_line_id                       IN      number,
        p_kanban_card_id                IN      number,
        p_overcompl_tol_type            IN      number,
        p_overcompl_tol_value           IN      number,
        p_end_item_unit_number          IN      number,
        p_rtg_op_seq_num                IN      number,
        p_src_client_server             IN      number,
        p_po_creation_time              IN      number,
        p_date_released                 IN      date,  -- bug 2697295
        p_error_code             OUT NOCOPY number,
        p_error_msg              OUT NOCOPY     varchar2) IS


l_stmt_num                      number;
l_common_routing_sequence_id    number;
l_error_code                    number;
l_error_msg                     varchar2(2000);
l_material_account              number;
l_material_overhead_account     number;
l_resource_account              number;
l_outside_processing_account    number;
l_material_variance_account     number;
l_resource_variance_account     number;
l_outside_proc_var_acc          number;
l_std_cost_adjustment_account   number;
l_overhead_account              number;
l_overhead_variance_account     number;
l_po_creation_time              number;
l_est_scrap_account             number;
l_est_scrap_var_account         number;
l_bon_seq_id1                   number;
l_bon_seq_id2                   number;
l_dummy                         number;
l_job_seq_num                   number;
l_op_seq_incr                   number;
l_end_seq_id                    number;
l_start_seq_id                  number;
abb_op_seq_num                  number;
l_rtg_op_seq_num                number;
max_op_seq_num                  number;
l_returnstatus                  varchar2(1);
translated_meaning              varchar2(240);
l_lucd                          date; -- BUG 3520916
--Bug 5207481: issued quantity is not updated any more.
--l_include_comp_yld              NUMBER; -- VJ: Added for Component Shrinkage project

build_job_exception             exception;

cursor wsm_bon_cur is (
    select from_op_seq_id "from_opseq_id", level
    from   bom_operation_networks
    where  transition_type = 1
    start with to_op_seq_id = l_bon_seq_id1 and transition_type = 1
    connect by to_op_seq_id = prior from_op_seq_id and transition_type = 1
    union
    select l_bon_seq_id1 "from_opseq_id", -1
    from   dual
) order by 2 desc;


BEGIN
    l_rtg_op_seq_num := p_rtg_op_seq_num;

    if (p_explode_header_detail is null) or (p_explode_header_detail = 2) then
        select wip_entities_s.nextval
        into p_wip_entity_id
        from dual;
    end if;

    p_error_code := 0;
    p_error_msg := '';

    if (p_explode_header_detail is null) or (p_explode_header_detail = 1) then

l_stmt_num := 10;
        Begin

            wsmputil.find_common_routing(
                        p_routing_sequence_id => p_routing_seq_id,
                        p_common_routing_sequence_id => l_common_routing_sequence_id,
                        x_err_code => l_error_code,
                        x_err_msg => l_error_msg);

            if l_error_code <> 0 then
                raise build_job_exception;
            end if;


l_stmt_num := 20;
-- If the op-seq-id in bon is effective as of the rgt_rev_date, fine. If it's not, check to see
-- if a replacement exitsts in bos. If no, then return error. Otherwise return no error, but
-- return the ORIGINAL op-seq-id defined in bon with the understanding that it may actually not be eff.
-- This holds for both find_routing_start and end.

            wsmputil.FIND_ROUTING_START(
                        l_common_routing_sequence_id,
                        p_routing_revision_date,  -- CZH.I_OED-1
                        l_start_seq_id,
                        l_error_code,
                        l_error_msg);

            if l_error_code <> 0 then
                raise build_job_exception;
            end if;


            -- BA: CZH.I_OED-1, call this to make sure the end is effective
l_stmt_num := 25;
            wsmputil.FIND_ROUTING_END(
                        l_common_routing_sequence_id,
                        p_routing_revision_date,  -- CZH.I_OED-1
                        l_end_seq_id,
                        l_error_code,
                        l_error_msg);

            if l_error_code <> 0 then
                raise build_job_exception;
            end if;
            -- EA: CZH.I_OED-1

l_stmt_num := 35;
            if l_rtg_op_seq_num is null then -- first operation

                -- While this start_seq_id is not necessarily the "effective" op_seq_id as of routing-rev-date in BON,
                -- here we are intesrested in the op-seq-num from bos... (abb)

                select operation_seq_num
                into   l_rtg_op_seq_num
                from   bom_operation_sequences
                where  operation_sequence_id = l_start_seq_id
                and    routing_sequence_id = l_common_routing_sequence_id;
                -- BD: CZH.I_OED-1
                --and    sysdate <= nvl(disable_date, sysdate+1)
                --and    effectivity_date <= sysdate;
                -- ED: CZH.I_OED-1

                l_bon_seq_id1 := l_start_seq_id;
            else

                -- Here, on the contrary, we are to find the op-seq-id given the op-seq-num. Validations for bonus
                -- will make sure that either all the operations till the user-entered op-seq-num is valid
                -- or there are replacements defined. Now, in bos, given an op-seq-num, we may find multiple
                -- number of op-seq-id's, thus the following sql WOULD have returned multiple rows if not I had
                -- included a condition that the op-seq-id must exists in bon too. Note that this op-seq-id
                -- is not necessarily the effective one, but this exists in the network and would be used by the
                -- wsm_bon_cur cursor to find the other op-seq-id's in the network. IN the cursor loop,
                -- wsmputil.replacement_op_seq_id has been used to find the equivalent effective op-seq-id's. (abb)

                select  unique(bos.operation_sequence_id)
                into    l_bon_seq_id1
                from    bom_operation_sequences bos, bom_operation_networks bon
                where   bos.operation_seq_num = l_rtg_op_seq_num
                and     bos.routing_sequence_id = l_common_routing_sequence_id
                -- BA: CZH.OED-2, it may have a replacement
                and     (bos.operation_sequence_id = bon.from_op_seq_id
                or      bos.operation_sequence_id = bon.to_op_seq_id);
                -- EA: CZH.OED-2

            end if;

            -- osp begin
            if  wsmputil.check_po_move (
                        p_sequence_id => l_bon_seq_id1,
                        p_sequence_id_type => 'O',
                        p_routing_rev_date => p_routing_revision_date,
                        x_err_code => l_error_code,
                        x_err_msg => l_error_msg) then
                fnd_message.set_name('WSM','WSM_FIRST_OP_PO_MOVE');
                p_error_code := -1;
                p_error_msg := fnd_message.get;
                return;
            end if;
            --osp end

l_stmt_num := 40;
            select nvl(OP_SEQ_NUM_INCREMENT, 10)
            into   l_op_seq_incr
            from   wsm_parameters
            where  ORGANIZATION_ID = p_org;

            l_job_seq_num := 0;

l_stmt_num := 50;
            OPEN wsm_bon_cur;
            LOOP
                FETCH wsm_bon_cur into l_bon_seq_id2, l_dummy;
                EXIT when wsm_bon_cur%NOTFOUND;

                -- BA: CZH.I_OED-2
                l_bon_seq_id2 := wsmputil.replacement_op_seq_id(
                                         l_bon_seq_id2,
                                         p_routing_revision_date);
                -- EA: CZH.I_OED-2

                l_job_seq_num := l_job_seq_num + l_op_seq_incr;

                -- BA: bug 3520916
                if (l_bon_seq_id2 =  l_bon_seq_id1) then
                    l_lucd := p_lucd;
                else
                    l_lucd := p_fusd;
                end if;
                -- EA: bug 3520916


l_stmt_num := 60;
                insert_procedure(
                        p_seq_id => l_bon_seq_id2,
                        p_job_seq_num => l_job_seq_num,
                        p_common_routing_sequence_id => l_common_routing_sequence_id,
                        p_supply_type => p_wip_supply_type,
                        p_wip_entity_id => p_wip_entity_id,
                        p_organization_id => p_org,
                        p_quantity => p_start_quantity,
                        p_job_type => p_job_type,
                        p_bom_reference_id => p_bom_reference_id,
                        p_rtg_reference_id => p_routing_reference_id,
                        p_assembly_item_id => p_item,
                        p_alt_bom_designator => p_alt_bom_designator,
                        p_alt_rtg_designator => p_alt_routing_designator,
                        p_fusd => p_fusd,
                        --p_lucd => p_lucd, -- bug 3520916
                        p_lucd => l_lucd,   -- bug 3520916
                        p_rtg_revision_date => p_routing_revision_date,
                        p_bom_revision_date => p_bom_revision_date,
                        p_last_updt_date => p_last_updt_date,
                        p_last_updt_by => p_last_updt_by,
                        p_creation_date => p_creation_date,
                        p_created_by => p_created_by,
                        p_last_updt_login => p_last_updt_login,
                        p_request_id => p_request_id,
                        p_program_application_id => p_program_application_id,
                        p_program_id => p_program_id,
                        p_prog_updt_date => p_prog_updt_date,
                        p_error_code => l_error_code,
                        p_error_msg => l_error_msg);

                if l_error_code <> 0 then
                        raise build_job_exception;
                end if;

            END LOOP;
            CLOSE wsm_bon_cur;

l_stmt_num := 75;
            select operation_seq_num
            into   abb_op_seq_num
            from   wip_operations
            where  wip_entity_id = p_wip_entity_id
            and    operation_sequence_id = wsmputil.replacement_op_seq_id(
                                                 l_bon_seq_id1,
                                                 p_routing_revision_date);

l_stmt_num := 76;
            select max(operation_seq_num)
            into   max_op_seq_num
            from   wip_operations
            where  wip_entity_id = p_wip_entity_id;


l_stmt_num := 80;

            UPDATE  WIP_OPERATIONS WO
            set     wo.previous_operation_seq_num =
                        (select max(operation_seq_num)
                           from wip_operations
                          where wip_entity_id = p_wip_entity_id
                            and operation_seq_num < wo.operation_seq_num),
                    wo.next_operation_seq_num =
                        (select min(operation_seq_num)
                           from wip_operations
                          where wip_entity_id = p_wip_entity_id
                            and operation_seq_num > wo.operation_seq_num),
                    wo.quantity_in_queue = decode(operation_seq_num, max_op_seq_num,
                                        (decode(p_status_type, 3,
                                        ROUND(p_start_quantity, WIP_CONSTANTS.MAX_DISPLAYED_PRECISION), 0)), 0)
            where   wo.wip_entity_id = p_wip_entity_id;


            if (lbji_debug = 'Y') then
                fnd_file.put_line(fnd_file.log,'update wo('||l_stmt_num||'): '|| SQL%ROWCOUNT);
            end if;

            update WIP_OPERATIONS
            --Bug 5207481:Actual quantity changes for bonus:costed_quantity_completed
            -- is updated instead of quantity_completed.
            set    wsm_costed_quantity_completed = p_start_quantity
            --Bug 5510126:Scheduled quantity is getting populated in insert_procedure
            --for old operations also during move.
                  ,scheduled_quantity = 0
            where  wip_entity_id = p_wip_entity_id
            and    operation_seq_num < abb_op_seq_num;

            if (lbji_debug = 'Y') then
                fnd_file.put_line(fnd_file.log,'update quantity_cmplted in wo('||l_stmt_num||'): '|| SQL%ROWCOUNT);
            end if;

           --Bug 5207481:Actual quantity changes for bonus-Start of changes
            -- CJ: Start changes for Component Shrinkage project --
           /* select include_component_yield
            into   l_include_comp_yld
            from   wip_parameters
            where  organization_id = p_org;*/

            --IF (nvl(l_include_comp_yld, 1) = 1) THEN -- Include Component Yield
                update wip_requirement_operations
                --set    quantity_issued = required_quantity
                set    quantity_issued = 0
                       ,required_quantity = 0
                where  wip_entity_id = p_wip_entity_id
                and    operation_seq_num < abb_op_seq_num;
                --Bug 5207481:Actual quantity changes:Issued qty and reviewed qty should be
                --set to 0 irrespective of supply type as these fields are not used by costing now.
                --and    wip_supply_type not in (2, 4, 5, 6); -- Fix for bug #2685463

            /*ELSIF (nvl(l_include_comp_yld, 1) = 2) THEN -- DO NOT Include Component Yield
                update wip_requirement_operations
                set    quantity_issued = round(quantity_per_assembly * decode(nvl(basis_type,1), 2, 1, p_start_quantity), 6)
                where  wip_entity_id = p_wip_entity_id
                and    operation_seq_num < abb_op_seq_num
                and    wip_supply_type not in (2, 4, 5, 6); -- Fix for bug #2685463
            END IF;*/
            -- CJ: End changes for Component Shrinkage project --
           --Bug 5207481:Actual quantity changes for bonus-End of changes

            if (lbji_debug = 'Y') then
                fnd_file.put_line(fnd_file.log,'update quantity_issued in wro('||l_stmt_num||'): '|| SQL%ROWCOUNT);
            end if;

        Exception

            when build_job_exception then
                p_error_code := l_error_code;
                p_error_msg := substr('wsmplbji.build_lbji_info: stmt no: '||l_stmt_num||' '||l_error_msg, 1, 2000);
                return;

        End;

    end if; -- p_explode_header_detail

    if (p_explode_header_detail is null) or (p_explode_header_detail = 2) then

l_stmt_num := 100;

        if p_explode_header_detail = 2 then
            wsmputil.find_common_routing(
                p_routing_sequence_id => p_routing_seq_id,
                p_common_routing_sequence_id => l_common_routing_sequence_id,
                x_err_code => p_error_code,
                x_err_msg => p_error_msg);

            if p_error_code <> 0 then
                return;
            end if;
        end if;

        BEGIN
        select  wac.material_account,
                wac.material_overhead_account,
                wac.resource_account,
                wac.outside_processing_account,
                wac.material_variance_account,
                wac.resource_variance_account,
                wac.outside_proc_variance_account,
                wac.std_cost_adjustment_account,
                wac.overhead_account,
                wac.overhead_variance_account,
                params.po_creation_time,
                wac.est_scrap_account,
                wac.est_scrap_var_account
        into    l_material_account,
                l_material_overhead_account,
                l_resource_account,
                l_outside_processing_account,
                l_material_variance_account,
                l_resource_variance_account,
                l_outside_proc_var_acc,
                l_std_cost_adjustment_account,
                l_overhead_account,
                l_overhead_variance_account,
                l_po_creation_time,
                l_est_scrap_account,
                l_est_scrap_var_account
        from    wip_accounting_classes wac,
                wip_parameters params
        where   wac.class_code(+)= p_class_code
        and     wac.organization_id(+)= p_org
        and     params.organization_id = p_org;
        EXCEPTION
            when others then
                p_error_code := SQLCODE;
                p_error_msg := substr('wsmplbji.build_lbji_info: stmt no: '||l_stmt_num||' '||SQLERRM, 1, 2000);
                return;
        END;



l_stmt_num := 110;

        if wsmputil.WSM_ESA_ENABLED(p_wip_entity_id => null,
                        err_code => l_error_code,
                        err_msg => l_error_msg,
                        p_org_id => p_org,
                        p_job_type => p_job_type) = 1
                and (l_est_scrap_account is null or l_est_scrap_var_account is null) then
                        fnd_message.set_name('WSM','WSM_NO_WAC_SCRAP_ACC');
                        fnd_message.set_token('CC',p_class_code);
                        p_error_code := -1;
                        p_error_msg := fnd_message.get;
            return;
        end if;


l_stmt_num := 120;

        Begin

            INSERT INTO WIP_DISCRETE_JOBS (
                 wip_entity_id,
                 organization_id,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date,
                 source_line_id,
                 source_code,
                 description,
                 status_type,
                 date_released,
                 primary_item_id,
                 bom_reference_id,
                 routing_reference_id,
                 firm_planned_flag,
                 job_type,
                 wip_supply_type,
                 class_code,
                 material_account,
                 material_overhead_account,
                 resource_account,
                 outside_processing_account,
                 material_variance_account,
                 resource_variance_account,
                 outside_proc_variance_account,
                 std_cost_adjustment_account,
                 overhead_account,
                 overhead_variance_account,
                 scheduled_start_date,
                 scheduled_completion_date,
                 start_quantity,
                 quantity_completed,
                 quantity_scrapped,
                 net_quantity,
                 common_bom_sequence_id,
                 common_routing_sequence_id,
                 bom_revision,
                 routing_revision,
                 bom_revision_date,
                 routing_revision_date,
                 lot_number,
                 alternate_bom_designator,
                 alternate_routing_designator,
                 completion_subinventory,
                 completion_locator_id,
                 demand_class,
                 project_id,
                 task_id,
                 schedule_group_id,
                 build_sequence,
                 line_id,
                 kanban_card_id,
                 overcompletion_tolerance_type,
                 overcompletion_tolerance_value,
                 end_item_unit_number,
                 po_creation_time,
                 priority,
                 due_date,
                 attribute_category,
                 attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 est_scrap_account,
                 est_scrap_var_account,
                 coproducts_supply
            )
            VALUES
            (
                 p_wip_entity_id,
                 p_org,
                 p_last_updt_date,
                 p_last_updt_by,
                 p_creation_date,
                 p_created_by,
                 p_last_updt_login,
                 p_request_id,
                 p_program_application_id,
                 p_program_id,
                 p_prog_updt_date,
                 p_source_line_id,
                 p_source_code,
                 p_description,
                 p_status_type,
                 p_date_released,
        --       decode(p_status_type, WIP_CONSTANTS.UNRELEASED, NULL, SYSDATE), --Removed TRUNC for HH24MISS
                 p_item,
                 decode(p_job_type, 3,p_bom_reference_id, null),
                 decode(p_job_type, 3, p_routing_reference_id, null),
                 p_firm_planned_flag,
                 decode(p_job_type, 3, WIP_CONSTANTS.NONSTANDARD, WIP_CONSTANTS.STANDARD),
                 p_wip_supply_type,
                 p_class_code,
                 l_material_account,
                 l_material_overhead_account,
                 l_resource_account,
                 l_outside_processing_account,
                 l_material_variance_account,
                 l_resource_variance_account,
                 l_outside_proc_var_acc,
                 l_std_cost_adjustment_account,
                 l_overhead_account,
                 l_overhead_variance_account,
                 TRUNC(p_fusd,'MI'),        --round(p_fusd,'MI'),
                 TRUNC(p_lucd,'MI'),        --round(p_lucd,'MI'),
                 ROUND(p_start_quantity, WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
                 0,
                 0,
                 ROUND(p_net_quantity, WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
                 p_common_bill_sequence_id,
                 l_common_routing_sequence_id,
                 p_bom_revision,
                 p_routing_revision,
                 p_bom_revision_date, -- HH24MISS -- Removed rounding to 'MI'
                 p_routing_revision_date, -- HH24MISS -- Removed rounding to 'MI'
                 p_lot_number,
                 p_alt_bom_designator,
                 p_alt_routing_designator,
                 p_completion_subinventory,
                 p_completion_locator_id,
                 p_demand_class,
                 p_project_id,
                 p_task_id,
                 p_schedule_group_id,
                 p_build_sequence,
                 p_line_id,
                 p_kanban_card_id,
                 p_overcompl_tol_type,
                 p_overcompl_tol_value,
                 p_end_item_unit_number,
                 l_po_creation_time,
                 p_priority,
                 p_due_date,
                 p_attribute_category,
                 p_attribute1,
                 p_attribute2,
                 p_attribute3,
                 p_attribute4,
                 p_attribute5,
                 p_attribute6,
                 p_attribute7,
                 p_attribute8,
                 p_attribute9,
                 p_attribute10,
                 p_attribute11,
                 p_attribute12,
                 p_attribute13,
                 p_attribute14,
                 p_attribute15,
                 l_est_scrap_account,
                 l_est_scrap_var_account,
                 p_coproducts_supply
            );
            --returning date_released into l_date_released;

        Exception
            when others then
                p_error_code := SQLCODE;
                p_error_msg := substr('wsmplbji.build_lbji_info: stmt no: '||l_stmt_num||' '||SQLERRM, 1, 2000);
                return;
        End;

        if lbji_debug = 'Y' then
            fnd_file.put_line(fnd_file.log, 'Inserted '||SQL%ROWCOUNT||' rows into wdj');
        end if;

l_stmt_num := 130;
        begin

            INSERT INTO WIP_ENTITIES (
                 wip_entity_id,
                 organization_id,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date,
                 wip_entity_name,
                 entity_type,
                 description,
                 primary_item_id,
                 gen_object_id
            )
            values
            (
                 p_wip_entity_id,
                 p_org,
                 p_last_updt_date,
                 p_last_updt_by,
                 p_creation_date,
                 p_created_by,
                 p_last_updt_login,
                 p_request_id,
                 p_program_application_id,
                 p_program_id,
                 p_prog_updt_date,
                 p_job_name,
                 5,
                 p_description,
                 p_item,
                 MTL_GEN_OBJECT_ID_S.nextval
            );

        exception
            when others then
                p_error_code := SQLCODE;
                p_error_msg := substr('wsmplbji.build_lbji_info: stmt no: '||l_stmt_num||' '||SQLERRM, 1, 2000);
                return;
        end;

        if lbji_debug = 'Y' then
            fnd_file.put_line(fnd_file.log, 'Inserted '||SQL%ROWCOUNT||' rows into we');
        end if;


l_stmt_num := 135;
        -- call Update_Card_Supply_Status to set the status of the kanban card to InProcess,
        -- if a card reference exists

        if ( p_kanban_card_id is not null ) then
            inv_kanban_pvt.update_card_supply_status(
                           x_return_status => l_returnStatus,
                           p_kanban_card_id => p_kanban_card_id,
                           p_supply_status => inv_kanban_pvt.g_supply_status_InProcess,
                           p_document_type => inv_kanban_pvt.G_Doc_type_lot_job,
                           p_document_header_id => p_wip_entity_id,
                           p_Document_detail_Id => null,
                           p_replenish_quantity => p_start_quantity);

            if ( l_returnStatus <> fnd_api.g_ret_sts_success ) then
                p_error_code := -1;
                fnd_message.set_name('WSM', 'WSM_KNBN_CARD_STS_FAIL');
                select meaning
                into   translated_meaning
                from   mfg_lookups
                where  lookup_type = 'MTL_KANBAN_SUPPLY_STATUS'
                and lookup_code = 5
                and upper(enabled_flag) = 'Y';
                fnd_message.set_token('STATUS',translated_meaning);
                p_error_msg := fnd_message.get;
                return;
                end if;
        end if;


l_stmt_num := 140;

        if p_status_type = WIP_CONSTANTS.RELEASED then
            insert_into_period_balances (
                    p_wip_entity_id   => p_wip_entity_id,
                    p_organization_id => p_org,
                    p_class_code      => p_class_code,
                    p_release_date    => p_date_released,
                    p_error_code      => l_error_code,
                    p_err_msg         => l_error_msg );

            if l_error_code <> 0 then
                p_error_code := l_error_code;
                p_error_msg := l_error_msg;
                return;
            end if;
        end if;

    end if; -- p_explode_header_detail


    -- osp begin -- this has to be put after insertion into wip_entities
    if p_explode_header_detail is null then

        if p_status_type = 3 and p_po_creation_time <> wip_constants.manual_creation then
            if p_src_client_server = 1 then

                if wsmputil.check_osp_operation(p_wip_entity_id, l_job_seq_num, p_org) then
                    l_atleast_one_osp_exists := l_atleast_one_osp_exists + 1;
                    wip_osp.create_requisition(
                            P_Wip_Entity_Id => p_wip_entity_id,
                            P_Organization_Id => p_org,
                            P_Repetitive_Schedule_Id => null,
                            P_Operation_Seq_Num => l_job_seq_num,
                            P_Resource_Seq_Num => null,
                            P_Run_ReqImport => WIP_CONSTANTS.YES);
                end if; -- check_osp_operation
            else

            -- if build_lbji_info is called from form, only then P_Run_ReqImport should be YES, i.e.
            -- the requisition import concurrent request should be launched immediately.

                    if wsmputil.check_osp_operation(p_wip_entity_id, l_job_seq_num, p_org) then
                        l_atleast_one_osp_exists := l_atleast_one_osp_exists + 1;
                        wip_osp.create_requisition(
                            P_Wip_Entity_Id => p_wip_entity_id,
                            P_Organization_Id => p_org,
                            P_Repetitive_Schedule_Id => null,
                            P_Operation_Seq_Num => l_job_seq_num,
                            P_Resource_Seq_Num => null,
                            P_Run_ReqImport => WIP_CONSTANTS.NO);
                    end if; -- check_osp_operation

            end if; --  p_src_client_server
        end if; --  p_status_type = 3

    end if; -- explode_header_detail
    -- osp end

EXCEPTION
    when others then
        p_error_code := SQLCODE;
        p_error_msg := substr('wsmplbji.build_lbji_info: stmt no: '||l_stmt_num||' '||SQLERRM, 1, 2000);
        return;


END build_lbji_info;



-- Overloaded version of build_lbji_info where p_released_date is not passed as a parameter
-- bugfix 2697295

procedure build_lbji_info(
        p_routing_seq_id                IN      number,
        p_common_bill_sequence_id       IN      number,
        p_explode_header_detail         IN      number,
        p_status_type                   IN      number,
        p_class_code                    IN      varchar2,
        p_org                           IN      number,
        p_wip_entity_id                 IN OUT NOCOPY number,
        p_last_updt_date                IN      date,
        p_last_updt_by                  IN      number,
        p_creation_date                 IN      date,
        p_created_by                    IN      number,
        p_last_updt_login               IN      number,
        p_request_id                    IN      number,
        p_program_application_id        IN      number,
        p_program_id                    IN      number,
        p_prog_updt_date                IN      date,
        p_source_line_id                IN      number,
        p_source_code                   IN      varchar2,
        p_description                   IN      varchar2,
        p_item                          IN      number,
        p_job_type                      IN      number,
        p_bom_reference_id              IN      number,
        p_routing_reference_id          IN      number,
        p_firm_planned_flag             IN      number,
        p_wip_supply_type               IN      number,
        p_fusd                          IN      date,
        p_lucd                          IN      date,
        p_start_quantity                IN      number,
        p_net_quantity                  IN      number,
        p_coproducts_supply             IN      number,
        p_bom_revision                  IN      varchar2,
        p_routing_revision              IN      varchar2,
        p_bom_revision_date             IN      date,
        p_routing_revision_date         IN      date,
        p_lot_number                    IN      varchar2,
        p_alt_bom_designator            IN      varchar2,
        p_alt_routing_designator        IN      varchar2,
        p_priority                      IN      number,
        p_due_date                      IN      date,
        p_attribute_category            IN      varchar2,
        p_attribute1                    IN      varchar2,
        p_attribute2                    IN      varchar2,
        p_attribute3                    IN      varchar2,
        p_attribute4                    IN      varchar2,
        p_attribute5                    IN      varchar2,
        p_attribute6                    IN      varchar2,
        p_attribute7                    IN      varchar2,
        p_attribute8                    IN      varchar2,
        p_attribute9                    IN      varchar2,
        p_attribute10                   IN      varchar2,
        p_attribute11                   IN      varchar2,
        p_attribute12                   IN      varchar2,
        p_attribute13                   IN      varchar2,
        p_attribute14                   IN      varchar2,
        p_attribute15                   IN      varchar2,
        p_job_name                      IN      varchar2,
        p_completion_subinventory       IN      varchar2,
        p_completion_locator_id         IN      number,
        p_demand_class                  IN      varchar2,
        p_project_id                    IN      number,
        p_task_id                       IN      number,
        p_schedule_group_id             IN      number,
        p_build_sequence                IN      number,
        p_line_id                       IN      number,
        p_kanban_card_id                IN      number,
        p_overcompl_tol_type            IN      number,
        p_overcompl_tol_value           IN      number,
        p_end_item_unit_number          IN      number,
        p_rtg_op_seq_num                IN      number,
        p_src_client_server             IN      number,
        p_po_creation_time              IN      number,
        p_error_code             OUT NOCOPY     number,
        p_error_msg              OUT NOCOPY     varchar2) IS

l_date_released date;
BEGIN

    if p_status_type = 3 then
        l_date_released := sysdate;
    else
        l_date_released := null;
    end if;

    build_lbji_info(
                p_routing_seq_id            => p_routing_seq_id,
                p_common_bill_sequence_id   => p_common_bill_sequence_id,
                p_explode_header_detail     => p_explode_header_detail,
                p_status_type               => p_status_type,
                p_class_code                => p_class_code,
                p_org                       => p_org,
                p_wip_entity_id             => p_wip_entity_id,
                p_last_updt_date            => p_last_updt_date,
                p_last_updt_by              => p_last_updt_by,
                p_creation_date             => p_creation_date,
                p_created_by                => p_created_by,
                p_last_updt_login           => p_last_updt_login,
                p_request_id                => p_request_id,
                p_program_application_id    => p_program_application_id,
                p_program_id                => p_program_id,
                p_prog_updt_date            => p_prog_updt_date,
                p_source_line_id            => p_source_line_id,
                p_source_code               => p_source_code,
                p_description               => p_description,
                p_item                      => p_item,
                p_job_type                  => p_job_type,
                p_bom_reference_id          => p_bom_reference_id,
                p_routing_reference_id      => p_routing_reference_id,
                p_firm_planned_flag         => p_firm_planned_flag,
                p_wip_supply_type           => p_wip_supply_type,
                p_fusd                      => p_fusd,
                p_lucd                      => p_lucd,
                p_start_quantity            => p_start_quantity,
                p_net_quantity              => p_net_quantity,
                p_coproducts_supply         => p_coproducts_supply,
                p_bom_revision              => p_bom_revision,
                p_routing_revision          => p_routing_revision,
                p_bom_revision_date         => p_bom_revision_date,
                p_routing_revision_date     => p_routing_revision_date,
                p_lot_number                => p_lot_number,
                p_alt_bom_designator        => p_alt_bom_designator,
                p_alt_routing_designator    => p_alt_routing_designator,
                p_priority                  => p_priority,
                p_due_date                  => p_due_date,
                p_attribute_category        => p_attribute_category,
                p_attribute1                => p_attribute1,
                p_attribute2                => p_attribute2,
                p_attribute3                => p_attribute3,
                p_attribute4                => p_attribute4,
                p_attribute5                => p_attribute5,
                p_attribute6                => p_attribute6,
                p_attribute7                => p_attribute7,
                p_attribute8                => p_attribute8,
                p_attribute9                => p_attribute9,
                p_attribute10               => p_attribute10,
                p_attribute11               => p_attribute11,
                p_attribute12               => p_attribute12,
                p_attribute13               => p_attribute13,
                p_attribute14               => p_attribute14,
                p_attribute15               => p_attribute15,
                p_job_name                  => p_job_name,
                p_completion_subinventory   => p_completion_subinventory,
                p_completion_locator_id     => p_completion_locator_id,
                p_demand_class              => p_demand_class,
                p_project_id                => p_project_id,
                p_task_id                   => p_task_id,
                p_schedule_group_id         => p_schedule_group_id,
                p_build_sequence            => p_build_sequence,
                p_line_id                   => p_line_id,
                p_kanban_card_id            => p_kanban_card_id,
                p_overcompl_tol_type        => p_overcompl_tol_type,
                p_overcompl_tol_value       => p_overcompl_tol_value,
                p_end_item_unit_number      => p_end_item_unit_number,
                p_rtg_op_seq_num            => p_rtg_op_seq_num,
                p_src_client_server         => p_src_client_server,
                p_po_creation_time          => p_po_creation_time,
                p_date_released             => l_date_released,
                p_error_code                => p_error_code,
                p_error_msg                 =>p_error_msg);

END build_lbji_info;




--***********************************************************************************************
-- ==============================================================================================
-- PROCEDURE load_wsli_data
-- ==============================================================================================
--***********************************************************************************************

PROCEDURE load_wsli_data (l_group_id IN NUMBER) IS

-- ==============================================================================================
-- cursors used to bulk bind data from wsli to PL/SQL tables
-- ==============================================================================================
cursor c_wsli_1 is
select
        wsli.header_id,
        wsli.lot_number,
        wsli.inventory_item_id,
        wsli.organization_id,
        wsli.quantity,
        wsli.subinventory_code,
        wsli.locator_id,
        wsli.revision,
        wsli.last_updated_by,
        wsli.created_by,
        msi.primary_uom_code,
        wsli.component_issue_quantity
from    wsm_starting_lots_interface wsli,
        wsm_lot_job_interface wlji,
        mtl_system_items msi
where   wsli.header_id = wlji.source_line_id
and     wlji.group_id = l_group_id
and     wlji.process_status = 2 -- WIP_CONSTANTS.running
and     wlji.mode_flag = 2
and     msi.inventory_item_id = wsli.inventory_item_id
and     msi.organization_id = wsli.organization_id;

BEGIN

-- ==============================================================================================
-- bulk fetching data from wsli to PL/SQL tables
-- ==============================================================================================

    open c_wsli_1;

    fetch c_wsli_1 bulk collect into
        v_wsli_header_id,
        v_wsli_lot_number,
        v_wsli_inventory_item_id,
        v_wsli_organization_id,
        v_wsli_quantity,
        v_wsli_subinventory_code,
        v_wsli_locator_id,
        v_wsli_revision,
        v_wsli_last_updated_by,
        v_wsli_created_by,
        v_wsli_primary_uom_code,
        v_wsli_comp_issue_qty;

-- ==============================================================================================
-- transfering wsli data into index by PL/SQL table for ease of validation
-- ==============================================================================================
    v_wsli_index := v_wsli_header_id.first;
    while v_wsli_index <= v_wsli_header_id.last
    loop
        v_wsli(v_wsli_header_id(v_wsli_index)).lot_number := v_wsli_lot_number(v_wsli_index);
        v_wsli(v_wsli_header_id(v_wsli_index)).inventory_item_id := v_wsli_inventory_item_id(v_wsli_index);
        v_wsli(v_wsli_header_id(v_wsli_index)).organization_id := v_wsli_organization_id(v_wsli_index);
        v_wsli(v_wsli_header_id(v_wsli_index)).quantity := v_wsli_quantity(v_wsli_index);
        v_wsli(v_wsli_header_id(v_wsli_index)).subinventory_code := v_wsli_subinventory_code(v_wsli_index);
        v_wsli(v_wsli_header_id(v_wsli_index)).locator_id := v_wsli_locator_id(v_wsli_index);
        v_wsli(v_wsli_header_id(v_wsli_index)).revision := v_wsli_revision(v_wsli_index);
        v_wsli(v_wsli_header_id(v_wsli_index)).last_updated_by := v_wsli_last_updated_by(v_wsli_index);
        v_wsli(v_wsli_header_id(v_wsli_index)).created_by := v_wsli_created_by(v_wsli_index);
        v_wsli(v_wsli_header_id(v_wsli_index)).primary_uom_code := v_wsli_primary_uom_code(v_wsli_index);
        v_wsli(v_wsli_header_id(v_wsli_index)).comp_issue_quantity := v_wsli_comp_issue_qty(v_wsli_index);

    v_wsli_index := v_wsli_header_id.next(v_wsli_index);
    end loop;

    close c_wsli_1;

END load_wsli_data;



--***********************************************************************************************
-- ==============================================================================================
-- PROCEDURE check_errored_mmtt_records
-- ==============================================================================================
--***********************************************************************************************

PROCEDURE check_errored_mmtt_records (
        p_header_id     IN NUMBER,
        x_err_code      OUT NOCOPY NUMBER,
        x_err_msg       OUT NOCOPY VARCHAR2) IS
l_transaction_temp_id   NUMBER;
l_wsli_header_id        NUMBER;
l_wlji_header_id        NUMBER;
l_interface_id          NUMBER;
l_err_code              VARCHAR2(240);
l_err_explanation       VARCHAR2(240);
l_stmt_num              NUMBER;

cursor recs is
        select  mmtt.transaction_temp_id,
                mmtt.error_code,
                mmtt.error_explanation,
                wsli.header_id,
                wlji.header_id
        from    mtl_material_transactions_temp mmtt,
                wsm_starting_lots_interface wsli,
                wsm_lot_job_interface wlji
        where   mmtt.transaction_header_id = p_header_id
        and     mmtt.source_line_id = wsli.header_id
        and     wsli.header_id = wlji.source_line_id ;
BEGIN

    open recs;
    loop
        fetch recs into
                l_transaction_temp_id,
                l_err_code,
                l_err_explanation,
                l_wsli_header_id,
                l_wlji_header_id ;

        exit when recs%notfound ;

        update  wsm_lot_job_interface wljia
        set     wljia.process_status = 4,
                wljia.error_code = -2,
                wljia.error_msg = substr(l_err_explanation,1,240)
        where   wljia.header_id = l_wlji_header_id ;

        x_err_code := -2;
    close recs;
    END LOOP;

EXCEPTION

        when others then
                x_err_code := SQLCODE;
                x_err_msg :=    'WSMPLBJI.check_errored_mmtt_records' ||
                                '(stmt_num='||l_stmt_num||') : '||
                                '(Header_Id=' ||l_wlji_header_id||') : '||
                                 SUBSTRB(SQLERRM,1,1000);
END check_errored_mmtt_records;


--***********************************************************************************************
-- ==============================================================================================
-- PROCEDURE insert_procedure
-- ==============================================================================================
--***********************************************************************************************

-- This procedure does not populate any quantity value (except scheduled_quantity) in wip_operations.
-- Quantity is populated in build_lbji_info according to whether the job is unreleased, or bonus
-- (released a special case of bonus). Note however that wsmpwrot.populate_wro called from this
-- operation populates quantity values in wro. Also, this procedure doesn't update the prev/vext_op_seq_num
-- in wo. That's taken care of in build_lbji_info. It's more efficient that way.


PROCEDURE insert_procedure(
        p_seq_id                        IN      NUMBER,
        p_job_seq_num                   IN      NUMBER,
        p_common_routing_sequence_id    IN      NUMBER, -- routing of the assembly
        p_supply_type                   IN      NUMBER,
        p_wip_entity_id                 IN      NUMBER,
        p_organization_id               IN      NUMBER,
        p_quantity                      IN      NUMBER,
        p_job_type                      IN      NUMBER,
        p_bom_reference_id              IN      NUMBER,
        p_rtg_reference_id              IN      NUMBER,
        p_assembly_item_id              IN      NUMBER,
        p_alt_bom_designator            IN      VARCHAR2,
        p_alt_rtg_designator            IN      VARCHAR2,
        p_fusd                          IN      DATE,
        p_lucd                          IN      DATE,
        p_rtg_revision_date             IN      DATE,
        p_bom_revision_date             IN      DATE,
        p_last_updt_date                IN      date,
        p_last_updt_by                  IN      number,
        p_creation_date                 IN      date,
        p_created_by                    IN      number,
        p_last_updt_login               IN      number,
        p_request_id                    IN      number,
        p_program_application_id        IN      number,
        p_program_id                    IN      number,
        p_prog_updt_date                IN      date,
        p_error_code             OUT NOCOPY     NUMBER,
        p_error_msg              OUT NOCOPY     VARCHAR2) IS


l_start_date                    VARCHAR2(50);
l_completion_date               VARCHAR2(50);
--l_routing_rev_date            VARCHAR2(50);  -- CHG: BUG2754825
l_routing_rev_date              DATE;          -- CHG: BUG2754825
l_item_id                       NUMBER;
l_yield                         NUMBER;
l_operation_yield_enabled       VARCHAR2(10);
l_department_id                 NUMBER;
l_scrap_account                 NUMBER;
l_est_scrap_abs_account         NUMBER;
l_first_flag                    NUMBER;
l_op_seq_incr                   NUMBER;
l_error_code                    NUMBER;
l_error_msg                     VARCHAR2(2000);
l_stat_num                      NUMBER;
l_seq_incr                      NUMBER;  --bug 2026218
l_routing_seq_id                NUMBER;  --bug 2445489  assembly item, abb

e_proc_error                    EXCEPTION;
no_dept_error                   EXCEPTION;

BEGIN


        l_start_date := to_char(p_fusd, WIP_CONSTANTS.DT_NOSEC_FMT);
        l_completion_date := to_char(p_lucd, WIP_CONSTANTS.DT_NOSEC_FMT);
        -- BC: BUG2754825
        --l_routing_rev_date := to_char(p_rtg_revision_date, WIP_CONSTANTS.DATETIME_FMT);
        l_routing_rev_date := p_rtg_revision_date;
        -- EC: BUG2754825

        if p_job_type = 3 then
                l_item_id := p_bom_reference_id;
        else
                l_item_id := p_assembly_item_id;
        end if;

        select nvl(OP_SEQ_NUM_INCREMENT, 10)
        into   l_op_seq_incr
        from   wsm_parameters
        where  ORGANIZATION_ID = p_organization_id;


l_stat_num := 10;
        select  yield, to_char(operation_yield_enabled), department_id
        into    l_yield, l_operation_yield_enabled,l_department_id
        from    bom_operation_sequences
        where   operation_sequence_id = p_seq_id;

l_stat_num := 30;
        select  scrap_account, est_absorption_account
        into    l_scrap_account, l_est_scrap_abs_account
        from    bom_departments
        where   department_id = l_department_id;


-- abb H optional scrap accounting
l_stat_num := 40;

        if (l_scrap_account is NULL or l_est_scrap_abs_account is NULL) and
                wsmputil.WSM_ESA_ENABLED(
                          p_wip_entity_id => null,
                          err_code => l_error_code,
                          err_msg => l_error_msg,
                          p_org_id => p_organization_id,
                          p_job_type => p_job_type) = 1 then
                raise no_dept_error;
        end if;

l_stat_num := 50;
        INSERT INTO WIP_OPERATIONS
                (WIP_ENTITY_ID,
                OPERATION_SEQ_NUM,
                ORGANIZATION_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
                OPERATION_SEQUENCE_ID,
                STANDARD_OPERATION_ID,
                DEPARTMENT_ID,
                DESCRIPTION,
                SCHEDULED_QUANTITY,
                QUANTITY_IN_QUEUE,
                QUANTITY_RUNNING,
                QUANTITY_WAITING_TO_MOVE,
                QUANTITY_REJECTED,
                QUANTITY_SCRAPPED,
                QUANTITY_COMPLETED,
                FIRST_UNIT_START_DATE,
                FIRST_UNIT_COMPLETION_DATE,
                LAST_UNIT_START_DATE,
                LAST_UNIT_COMPLETION_DATE,
                PREVIOUS_OPERATION_SEQ_NUM,
                NEXT_OPERATION_SEQ_NUM,
                COUNT_POINT_TYPE,
                BACKFLUSH_FLAG,
                MINIMUM_TRANSFER_QUANTITY,
                DATE_LAST_MOVED,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15,
                OPERATION_YIELD,
                OPERATION_YIELD_ENABLED)
        SELECT  p_wip_entity_id,
                p_job_seq_num,
                p_organization_id,
                p_last_updt_date,
                p_last_updt_by,
                p_creation_date,
                p_created_by,
                p_last_updt_login,
                p_request_id,
                p_program_application_id,
                p_program_id,
                p_prog_updt_date,
                SEQ.OPERATION_SEQUENCE_ID,
                SEQ.STANDARD_OPERATION_ID,
                SEQ.DEPARTMENT_ID,
                SEQ.OPERATION_DESCRIPTION,
                --Bug 5207481:Actual quantity changes-Scheduled_quantity should be zero.
                --Bug 5510126:Scheduled quantity was made as 0 earlier as infinite
                --is going to finally update this.But before infinite scheduler is
                --called, create_requsitions is being called which uses the value
                --in the field scheduled quantity.Hence the previous change is reverted.
                ROUND(p_quantity, WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
                --0,
                0, 0, 0, 0, 0, 0,
                TO_DATE(l_start_date, WIP_CONSTANTS.DT_NOSEC_FMT),
                TO_DATE(l_completion_date, WIP_CONSTANTS.DT_NOSEC_FMT),
                TO_DATE(l_start_date, WIP_CONSTANTS.DT_NOSEC_FMT),
                TO_DATE(l_completion_date, WIP_CONSTANTS.DT_NOSEC_FMT),
                0,
                0,
                SEQ.COUNT_POINT_TYPE,
                SEQ.BACKFLUSH_FLAG,
                NVL(SEQ.MINIMUM_TRANSFER_QUANTITY, 0),
                '',
                SEQ.ATTRIBUTE_CATEGORY,
                SEQ.ATTRIBUTE1,
                SEQ.ATTRIBUTE2,
                SEQ.ATTRIBUTE3,
                SEQ.ATTRIBUTE4,
                SEQ.ATTRIBUTE5,
                SEQ.ATTRIBUTE6,
                SEQ.ATTRIBUTE7,
                SEQ.ATTRIBUTE8,
                SEQ.ATTRIBUTE9,
                SEQ.ATTRIBUTE10,
                SEQ.ATTRIBUTE11,
                SEQ.ATTRIBUTE12,
                SEQ.ATTRIBUTE13,
                SEQ.ATTRIBUTE14,
                SEQ.ATTRIBUTE15,
                l_yield,
                l_operation_yield_enabled
        FROM    BOM_OPERATION_SEQUENCES SEQ
        WHERE   SEQ.ROUTING_SEQUENCE_ID = p_common_routing_sequence_id
        AND     NVL(SEQ.OPERATION_TYPE, 1) = 1
        --BC: CZH.I_OED-1
        /****************
        AND     TO_DATE(TO_CHAR(SEQ.EFFECTIVITY_DATE, WIP_CONSTANTS.DT_NOSEC_FMT),
                     WIP_CONSTANTS.DT_NOSEC_FMT) <=
                TO_DATE(l_routing_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT)
        AND     NVL(TO_DATE(TO_CHAR(SEQ.DISABLE_DATE, WIP_CONSTANTS.DT_NOSEC_FMT),
                         WIP_CONSTANTS.DT_NOSEC_FMT),
                TO_DATE(l_routing_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT) + 1) >=
                TRUNC(TO_DATE(l_routing_rev_date,WIP_CONSTANTS.DT_NOSEC_FMT))
        ****************/

        /** HH24MISSS - Timestamp FPI changes - DATETIME_FMT **/

        -- BC: BUG2754825
        --AND   TO_DATE(TO_CHAR(SEQ.EFFECTIVITY_DATE, WIP_CONSTANTS.DATETIME_FMT), WIP_CONSTANTS.DATETIME_FMT)
        --          <= TO_DATE(l_routing_rev_date, WIP_CONSTANTS.DATETIME_FMT)
        --AND   NVL(TO_DATE(TO_CHAR(SEQ.DISABLE_DATE, WIP_CONSTANTS.DATETIME_FMT), WIP_CONSTANTS.DATETIME_FMT),
        --          TO_DATE(l_routing_rev_date, WIP_CONSTANTS.DATETIME_FMT) + 1)
        --          >= TO_DATE(l_routing_rev_date, WIP_CONSTANTS.DATETIME_FMT)
        AND     l_routing_rev_date BETWEEN SEQ.EFFECTIVITY_DATE AND NVL(SEQ.DISABLE_DATE, l_routing_rev_date+1)
        -- EC: BUG2754825

        --EC: CZH.I_OED-1
        AND     OPERATION_SEQUENCE_ID = p_seq_id
        AND NOT EXISTS (select 'x' from wip_operations
                         where wip_entity_id = p_wip_entity_id
                         and   operation_sequence_id = p_seq_id
                         and   operation_seq_num = p_job_seq_num);
        --bugfix 2026218
        --copy attachment from operations document attachment defined in the network routing form.
        if sql%rowcount > 0 then
                select p_job_seq_num
                into   l_seq_incr
                from   sys.dual;

                FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
                                X_FROM_ENTITY_NAME => 'BOM_OPERATION_SEQUENCES',
                                X_FROM_PK1_VALUE   => to_char(p_seq_id),
                                X_TO_ENTITY_NAME   => 'WSM_LOT_BASED_OPERATIONS',
                                X_TO_PK1_VALUE   => to_char(p_wip_entity_id),
                                X_TO_PK2_VALUE   => to_char(l_seq_incr),
                                X_TO_PK3_VALUE   => to_char(p_organization_id),
                                X_CREATED_BY     => to_char(p_last_updt_by),
                                X_LAST_UPDATE_LOGIN => to_char(p_last_updt_login),
                                X_PROGRAM_APPLICATION_ID => to_char(p_program_application_id),
                                X_PROGRAM_ID => to_char(p_program_id),
                                X_REQUEST_ID => to_char(p_request_id)) ;
        end if;
        --endfix 20026218

        if lbji_debug = 'Y' then
                fnd_file.put_line(fnd_file.log, 'Inserted '||SQL%ROWCOUNT||' rows into wo');
        end if;

l_stat_num := 60;
        -- The below insert is used for Costing Changes (OP Yield)
        INSERT INTO WIP_OPERATION_YIELDS
                (WIP_ENTITY_ID,
                OPERATION_SEQ_NUM,
                ORGANIZATION_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
                STATUS,
                SCRAP_ACCOUNT,
                EST_SCRAP_ABSORB_ACCOUNT)
        SELECT  p_wip_entity_id,
                WO.OPERATION_SEQ_NUM,
                p_organization_id,
                p_last_updt_date,
                p_last_updt_by,
                p_creation_date,
                p_created_by,
                p_last_updt_login,
                p_request_id,
                p_program_application_id,
                p_program_id,
                p_prog_updt_date,
                NULL,
                l_scrap_account,
                l_est_scrap_abs_account
        FROM    WIP_OPERATIONS WO
        WHERE   WO.WIP_ENTITY_ID = p_wip_entity_id
        AND     WO.OPERATION_SEQUENCE_ID = p_seq_id
        AND     WO.OPERATION_SEQ_NUM NOT IN (SELECT WOY.OPERATION_SEQ_NUM
                                             FROM   WIP_OPERATION_YIELDS WOY
                                             WHERE  WOY.WIP_ENTITY_ID = p_wip_entity_id);

        if lbji_debug = 'Y' then
                fnd_file.put_line(fnd_file.log, 'Inserted '||SQL%ROWCOUNT||' rows into woy');
        end if;


l_stat_num := 80;
        INSERT INTO WIP_OPERATION_RESOURCES
                (WIP_ENTITY_ID,
                OPERATION_SEQ_NUM,
                RESOURCE_SEQ_NUM,
                ORGANIZATION_ID,
                LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
                CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
                PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE,
                RESOURCE_ID, UOM_CODE,
                BASIS_TYPE, USAGE_RATE_OR_AMOUNT, ACTIVITY_ID,
                SCHEDULED_FLAG, ASSIGNED_UNITS, AUTOCHARGE_TYPE,
                STANDARD_RATE_FLAG, APPLIED_RESOURCE_UNITS, APPLIED_RESOURCE_VALUE,
                START_DATE, COMPLETION_DATE,
                ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
                ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
                ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
                ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
                ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
                ATTRIBUTE15,
                SCHEDULE_SEQ_NUM,SUBSTITUTE_GROUP_NUM,PRINCIPLE_FLAG,SETUP_ID,
                -- ST : Detailed Scheduling --
                maximum_assigned_units,
                firm_flag
                -- ST : Detailed Scheduling --
                )
         SELECT OPS.WIP_ENTITY_ID,
                OPS.OPERATION_SEQ_NUM,
                ORS.RESOURCE_SEQ_NUM,
                OPS.ORGANIZATION_ID,
                OPS.LAST_UPDATE_DATE, OPS.LAST_UPDATED_BY, OPS.CREATION_DATE,
                OPS.CREATED_BY, OPS.LAST_UPDATE_LOGIN, OPS.REQUEST_ID,
                OPS.PROGRAM_APPLICATION_ID, OPS.PROGRAM_ID,
                OPS.PROGRAM_UPDATE_DATE, ORS.RESOURCE_ID, RSC.UNIT_OF_MEASURE,
                ORS.BASIS_TYPE, ORS.USAGE_RATE_OR_AMOUNT, ORS.ACTIVITY_ID,
                ORS.SCHEDULE_FLAG, ORS.ASSIGNED_UNITS, ORS.AUTOCHARGE_TYPE,
                ORS.STANDARD_RATE_FLAG, 0, 0,
                OPS.FIRST_UNIT_START_DATE, OPS.LAST_UNIT_COMPLETION_DATE,
                ORS.ATTRIBUTE_CATEGORY, ORS.ATTRIBUTE1, ORS.ATTRIBUTE2,
                ORS.ATTRIBUTE3, ORS.ATTRIBUTE4, ORS.ATTRIBUTE5,
                ORS.ATTRIBUTE6, ORS.ATTRIBUTE7, ORS.ATTRIBUTE8,
                ORS.ATTRIBUTE9, ORS.ATTRIBUTE10, ORS.ATTRIBUTE11,
                ORS.ATTRIBUTE12, ORS.ATTRIBUTE13, ORS.ATTRIBUTE14,
                ORS.ATTRIBUTE15,
                ORS.SCHEDULE_SEQ_NUM,ORS.SUBSTITUTE_GROUP_NUM,ORS.PRINCIPLE_FLAG,ORS.SETUP_ID,
                -- ST : Detailed Scheduling --
                ORS.ASSIGNED_UNITS,
                0
                -- ST : Detailed Scheduling --
        FROM    BOM_RESOURCES RSC,
                BOM_OPERATION_RESOURCES ORS,
                WIP_OPERATIONS OPS
        WHERE   OPS.ORGANIZATION_ID = p_organization_id
        AND     OPS.WIP_ENTITY_ID = p_wip_entity_id
        AND     OPS.OPERATION_SEQUENCE_ID = ORS.OPERATION_SEQUENCE_ID
        AND     ORS.RESOURCE_ID = RSC.RESOURCE_ID
        AND     RSC.ORGANIZATION_ID = OPS.ORGANIZATION_ID
        AND     ORS.OPERATION_SEQUENCE_ID = p_seq_id
        AND     OPS.OPERATION_SEQ_NUM NOT IN (select WOR.OPERATION_SEQ_NUM
                                              from Wip_operation_resources WOR
                                              where WOR.wip_entity_id = p_wip_entity_id);

        if lbji_debug = 'Y' then
                fnd_file.put_line(fnd_file.log, 'Inserted '||SQL%ROWCOUNT||' rows into wor');
        end if;

l_stat_num := 90;
        if p_job_seq_num = l_op_seq_incr then -- if this is the first operation
                l_first_flag := 1;
        else
                l_first_flag := 0;
        end if;

l_stat_num := 90.5;
        SELECT  common_routing_sequence_id INTO l_routing_seq_id
        FROM    BOM_OPERATIONAL_ROUTINGS BOR
        WHERE   BOR.assembly_item_id= decode(p_job_type,1,p_assembly_item_id,p_rtg_reference_id)
        AND     nvl(BOR.alternate_routing_designator, '***') = nvl(p_alt_rtg_designator, '***')
        and     bor.organization_id = p_organization_id;

        WSMPWROT.POPULATE_WRO (
                p_first_flag => l_first_flag,
                p_wip_entity_id => p_wip_entity_id,
                p_organization_id => p_organization_id,
                p_assembly_item_id => l_item_id,
                p_bom_revision_date => p_bom_revision_date,
                p_alt_bom => p_alt_bom_designator,
                p_quantity => p_quantity,
                p_operation_sequence_id => p_seq_id,
                p_wip_supply_type => p_supply_type,
                x_err_code => l_error_code,
                x_err_msg => l_error_msg,
                --BC: 2754825
                --p_routing_revision_date => TO_DATE(l_routing_rev_date, WIP_CONSTANTS.DATETIME_FMT),
                p_routing_revision_date => l_routing_rev_date,
                --EC: 2754825
                p_routing_sequence_id => l_routing_seq_id); --bug 2445489
        -- EA: NSO-WLT

                if l_error_code <> 0 then
                        p_error_msg := l_error_msg;
                        p_error_code := -1;
                        if (lbji_debug = 'Y') then
                            fnd_file.put_line(fnd_file.log,p_error_msg);
                        end if;
                        return;
                end if;

        if lbji_debug = 'Y' then
                fnd_file.put_line(fnd_file.log, 'Inserted rows into wro');
        end if;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                p_error_msg := 'WSMPLBJI.insert_procedure('||l_stat_num||'): No Data Found';
                p_error_code := -1;
                if (lbji_debug = 'Y') then
                    fnd_file.put_line(fnd_file.log,p_error_msg);
                end if;

        WHEN e_proc_error THEN
                p_error_msg := 'WSMPLBJI.insert_procedure('||l_stat_num||'): '||p_error_msg;
                p_error_code := -1;
                if (lbji_debug = 'Y') then
                    fnd_file.put_line(fnd_file.log,p_error_msg);
                end if;

        WHEN no_dept_error THEN
                fnd_message.set_name('WSM', 'WSM_NO_SCRAP_ACC');
                fnd_message.set_token('DEPT_ID',to_char(l_department_id));
                p_error_msg := fnd_message.get;
                p_error_code := -1;

        when others then
                p_error_code := SQLCODE;
                p_error_msg := 'WSMPLBJI.insert_procedure('||l_stat_num||')'|| substr(SQLERRM,1,200);
                if (lbji_debug = 'Y') then
                    fnd_file.put_line(fnd_file.log,p_error_msg);
                end if;

END insert_procedure;



--***********************************************************************************************
-- ==============================================================================================
-- FUNCTION DISCRETE_CHARGES_EXIST
-- ==============================================================================================
--***********************************************************************************************


FUNCTION discrete_charges_exist(
        p_wip_entity_id         IN  NUMBER,
        p_organization_id       IN  NUMBER,
        p_check_mode            IN  NUMBER )
RETURN BOOLEAN IS

retnvalue BOOLEAN;
charges_exist VARCHAR2(2);
l_stmt_num  NUMBER;

cursor check_discrete_charges is
        SELECT  DISTINCT 'X'
        FROM    WIP_DISCRETE_JOBS DJ, WIP_PERIOD_BALANCES WPB
        WHERE   DJ.WIP_ENTITY_ID = WPB.WIP_ENTITY_ID
                AND DJ.ORGANIZATION_ID = WPB.ORGANIZATION_ID
                AND DJ.WIP_ENTITY_ID = p_wip_entity_id
                AND DJ.ORGANIZATION_ID = p_organization_id
                AND (DJ.QUANTITY_COMPLETED <> 0
                        OR DJ.QUANTITY_SCRAPPED <> 0
                        OR WPB.TL_RESOURCE_IN <> 0
                        OR WPB.TL_OVERHEAD_IN <> 0
                        OR WPB.TL_OUTSIDE_PROCESSING_IN <> 0
                        OR WPB.PL_MATERIAL_IN <> 0
                        OR WPB.PL_MATERIAL_OVERHEAD_IN <> 0
                        OR WPB.PL_RESOURCE_IN <> 0
                        OR WPB.PL_OVERHEAD_IN <> 0
                        OR WPB.PL_OUTSIDE_PROCESSING_IN <> 0
                        OR WPB.TL_MATERIAL_OUT <> 0
                        OR WPB.TL_RESOURCE_OUT <> 0
                        OR WPB.TL_OVERHEAD_OUT <> 0
                        OR WPB.TL_OUTSIDE_PROCESSING_OUT <> 0
                        OR WPB.PL_MATERIAL_OUT <> 0
                        OR WPB.PL_MATERIAL_OVERHEAD_OUT <> 0
                        OR WPB.PL_RESOURCE_OUT <> 0
                        OR WPB.PL_OVERHEAD_OUT <> 0
                        OR WPB.PL_OUTSIDE_PROCESSING_OUT <> 0
                        OR EXISTS (SELECT 'X'
                                   FROM   WIP_REQUIREMENT_OPERATIONS
                                   WHERE  ORGANIZATION_ID = p_organization_id
                                   AND    WIP_ENTITY_ID = p_wip_entity_id
                                   AND    QUANTITY_ISSUED <> 0)
                        OR EXISTS (SELECT 'X'
                                   FROM   WIP_MOVE_TXN_INTERFACE
                                   WHERE  ORGANIZATION_ID = p_organization_id
                                   AND    WIP_ENTITY_ID = p_wip_entity_id)
                        OR EXISTS (SELECT 'X'
                                   FROM   WSM_LOT_MOVE_TXN_INTERFACE
                                   WHERE  ORGANIZATION_ID = p_organization_id
                                   AND    WIP_ENTITY_ID = p_wip_entity_id)
                        OR EXISTS (SELECT 'X'
                                   FROM   WIP_COST_TXN_INTERFACE
                                   WHERE  ORGANIZATION_ID = p_organization_id
                                   AND    WIP_ENTITY_ID = p_wip_entity_id)
                        OR EXISTS (SELECT 'X'
                                   FROM   MTL_MATERIAL_TRANSACTIONS_TEMP
                                   WHERE  ORGANIZATION_ID = p_organization_id
                                   AND    TRANSACTION_SOURCE_TYPE_ID = 5
                                   AND    TRANSACTION_SOURCE_ID = p_wip_entity_id)
                        OR EXISTS (SELECT 'X'
                                   FROM   WIP_MOVE_TRANSACTIONS
                                   WHERE  ORGANIZATION_ID = p_organization_id
                                   AND    WIP_ENTITY_ID = p_wip_entity_id)
                        -- CZH check WLT also
                        OR EXISTS (SELECT 'X'
                                   FROM   WSM_SM_RESULTING_JOBS
                                   WHERE  ORGANIZATION_ID = p_organization_id
                                   AND    WIP_ENTITY_ID = p_wip_entity_id)
                        OR EXISTS (SELECT 'X'
                                   FROM   WIP_OPERATION_RESOURCES
                                   WHERE  ORGANIZATION_ID = p_organization_id
                                   AND    WIP_ENTITY_ID = p_wip_entity_id
                                   AND    APPLIED_RESOURCE_UNITS <> 0));

--check for only shop floor transactions

cursor check_discrete_charges_1 is
        SELECT  DISTINCT 'X'
        FROM    WIP_DISCRETE_JOBS DJ, WIP_PERIOD_BALANCES WPB
        WHERE   DJ.WIP_ENTITY_ID = WPB.WIP_ENTITY_ID
                AND DJ.ORGANIZATION_ID = WPB.ORGANIZATION_ID
                AND DJ.WIP_ENTITY_ID = p_wip_entity_id
                AND DJ.ORGANIZATION_ID = p_organization_id
                AND (DJ.QUANTITY_COMPLETED <> 0
                        OR DJ.QUANTITY_SCRAPPED <> 0
                        OR WPB.TL_RESOURCE_IN <> 0
                        OR WPB.TL_OVERHEAD_IN <> 0
                        OR WPB.TL_OUTSIDE_PROCESSING_IN <> 0
                        OR WPB.PL_RESOURCE_IN <> 0
                        OR WPB.PL_OVERHEAD_IN <> 0
                        OR WPB.PL_OUTSIDE_PROCESSING_IN <> 0
                        OR WPB.TL_RESOURCE_OUT <> 0
                        OR WPB.TL_OVERHEAD_OUT <> 0
                        OR WPB.TL_OUTSIDE_PROCESSING_OUT <> 0
                        OR WPB.PL_RESOURCE_OUT <> 0
                        OR WPB.PL_OVERHEAD_OUT <> 0
                        OR WPB.PL_OUTSIDE_PROCESSING_OUT <> 0
                        OR EXISTS (SELECT 'X'
                                   FROM   WIP_MOVE_TXN_INTERFACE
                                   WHERE  ORGANIZATION_ID = p_organization_id
                                   AND    WIP_ENTITY_ID = p_wip_entity_id)
                        OR EXISTS (SELECT 'X'
                                   FROM   WSM_LOT_MOVE_TXN_INTERFACE
                                   WHERE  ORGANIZATION_ID = p_organization_id
                                   AND    WIP_ENTITY_ID = p_wip_entity_id)
                        OR EXISTS (SELECT 'X'
                                   FROM   WIP_COST_TXN_INTERFACE
                                   WHERE  ORGANIZATION_ID = p_organization_id
                                   AND    WIP_ENTITY_ID = p_wip_entity_id)
                        OR EXISTS (SELECT 'X'
                                   FROM   WIP_MOVE_TRANSACTIONS
                                   WHERE  ORGANIZATION_ID = p_organization_id
                                   AND    WIP_ENTITY_ID = p_wip_entity_id)
                        -- CZH check WLT also
                        OR EXISTS (SELECT 'X'
                                   FROM   WSM_SM_RESULTING_JOBS
                                   WHERE  ORGANIZATION_ID = p_organization_id
                                   AND    WIP_ENTITY_ID = p_wip_entity_id)
                        OR EXISTS (SELECT 'X'
                                   FROM   WIP_OPERATION_RESOURCES
                                   WHERE  ORGANIZATION_ID = p_organization_id
                                   AND    WIP_ENTITY_ID = p_wip_entity_id
                                   AND    APPLIED_RESOURCE_UNITS <> 0));
BEGIN

    retnvalue := FALSE;

    if (p_check_mode = 1) then
        open check_discrete_charges_1;
        fetch check_discrete_charges_1 into charges_exist;

        IF (check_discrete_charges_1%FOUND) THEN
                retnvalue := TRUE;
                close  check_discrete_charges_1;
                RETURN retnvalue;
        ELSE
                close  check_discrete_charges_1;
        END IF;

    else
        open check_discrete_charges;
        fetch check_discrete_charges into charges_exist;

        IF (check_discrete_charges%FOUND) THEN
                retnvalue := TRUE;
                close  check_discrete_charges;
                RETURN retnvalue;
        ELSE
                close  check_discrete_charges;
        END IF;

    end if;

    RETURN retnvalue;

END discrete_charges_exist;






--***********************************************************************************************
-- ==============================================================================================
-- PROCEDURE insert_into_period_balances
-- ==============================================================================================
--***********************************************************************************************


PROCEDURE insert_into_period_balances(
        p_wip_entity_id     IN NUMBER,
        p_organization_id   IN NUMBER,
        p_class_code        IN VARCHAR2,
        p_release_date      IN DATE,
        p_error_code        OUT NOCOPY NUMBER,
        p_err_msg           OUT NOCOPY VARCHAR2 ) IS

x_user_id       NUMBER := FND_GLOBAL.USER_ID;
x_login_id      NUMBER := FND_GLOBAL.LOGIN_ID;
l_cnt           NUMBER;     -- bug 3571360
--l_inv_period_id number;   -- bug 3126650

BEGIN

    -- BD: bugfix 3299811, this is a regression of bugfix 3126650
    --l_inv_period_id := wsmputil.get_inv_acct_period (
    --        x_err_code         => p_error_code,
    --        x_err_msg          => p_err_msg,
    --        p_organization_id  => p_organization_id,
    --        p_date             => trunc(nvl(p_release_date, sysdate)) );
    --if(p_error_code <> 0) then
    --    p_error_code := -1;
    --    fnd_message.set_name('WIP', 'WIP_NO_ACCT_PERIOD');
    --    fnd_message.set_token('FLD_NAME','Wip Accounting Period');
    --    p_err_msg := fnd_message.get;
    --    return;
    --end if;
    -- ED: bugfix 3299811

    insert into wip_period_balances (
            acct_period_id,
            wip_entity_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            organization_id,
            class_type,
            tl_resource_in,
            tl_overhead_in,
            tl_outside_processing_in,
            pl_material_in,
            pl_material_overhead_in,
            pl_resource_in,
            pl_overhead_in,
            pl_outside_processing_in,
            tl_material_out,
            tl_resource_out,
            tl_overhead_out,
            tl_outside_processing_out,
            pl_material_out,
            pl_material_overhead_out,
            pl_resource_out,
            pl_overhead_out,
            pl_outside_processing_out,
            pl_material_overhead_var,
            pl_material_var,
            pl_outside_processing_var,
            pl_overhead_var,
            pl_resource_var,
            tl_material_var,
            tl_outside_processing_var,
            tl_overhead_var,
            tl_resource_var,
            tl_material_overhead_out,
            tl_material_overhead_var)
    select  oap.acct_period_id,
            p_wip_entity_id,
            sysdate, x_user_id,
            sysdate, x_user_id, x_login_id,
            p_organization_id, wc.class_type,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0
     from   org_acct_periods oap,
            wip_accounting_classes wc
     where  wc.class_code = p_class_code
     and    wc.organization_id = p_organization_id
     and    oap.organization_id = p_organization_id
     and    oap.schedule_close_date >=
                 trunc(inv_le_timezone_pub.get_le_day_for_inv_org(
                        nvl(p_release_date, sysdate),
                        p_organization_id))
     and    oap.period_close_date is null
     and    not exists (
                 select 'balance record already there'
                 from   wip_period_balances wpb
                 where  wpb.wip_entity_id = p_wip_entity_id
                 and    wpb.acct_period_id = oap.acct_period_id
                 and    wpb.organization_id = oap.organization_id);

    l_cnt := SQL%ROWCOUNT;      -- bug 3571360

    -- BD: bugfix 3299811, this is a regression of bugfix 3126650
    --select  l_inv_period_id,
    --        p_wip_entity_id,
    --        sysdate, x_user_id,
    --        sysdate, x_user_id, x_login_id,
    --        p_organization_id,
    --        wc.class_type,
    --        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    --        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    --        0, 0, 0, 0, 0, 0, 0, 0
    --from    wip_accounting_classes wc
    --where   wc.class_code = p_class_code
    --and     wc.organization_id = p_organization_id
    --and     not exists (
    --             select 'balance record already there'
    --             from   wip_period_balances wpb
    --             where  wpb.wip_entity_id = p_wip_entity_id
    --             and    wpb.acct_period_id = l_inv_period_id
    --             and    wpb.organization_id = p_organization_id);
    -- ED: bugfix 3299811


    if lbji_debug = 'Y' then
        fnd_file.put_line(fnd_file.log, 'Inserted '|| l_cnt ||' rows into wip_period_balances');
    end if;

    --if SQL%NOTFOUND then      -- bug 3571360
    if l_cnt <= 0 then          -- bug 3571360
        p_error_code := -1;
        fnd_message.set_name('WIP', 'WIP_NO_ACCT_PERIOD');
        fnd_message.set_token('FLD_NAME','Wip Accounting Period');
        p_err_msg := fnd_message.get;
    end if;

exception
        when others then
                p_err_msg := 'WSMPLBJI.insert_into_period_balances: '|| substr(SQLERRM,1,200);
                p_error_code := SQLCODE;

end insert_into_period_balances;




--***********************************************************************************************
-- ==============================================================================================
-- PROCESS_INVALID_FIELD
-- ==============================================================================================
--***********************************************************************************************


-- ==============================================================================================
-- this is called to display message of WSM_INVALID_FIELD type.
-- sets the process_status to 3, sets values of error_code and error_message,
-- writes into fnd log and calls write_to_wie
-- ==============================================================================================

PROCEDURE process_invalid_field (
        p_fld          IN VARCHAR2,
        aux_string     IN VARCHAR2,
        stmt_number    IN NUMBER) IS

x_err_msg  VARCHAR2(2000) := NULL;

BEGIN

      v_wlji_process_status(v_index) := 3;
      v_wlji_err_code(v_index) := -1;
      fnd_message.set_name('WSM','WSM_INVALID_FIELD');
      fnd_message.set_token('FLD_NAME', p_fld);
      x_err_msg :=  fnd_message.get;
      v_wlji_err_msg(v_index) := x_err_msg;
      fnd_file.put_line(fnd_file.log, 'stmt_num: '|| stmt_number||'  '||x_err_msg||' '||aux_string);
      fnd_file.new_line(fnd_file.log, 3);


END process_invalid_field;



--***********************************************************************************************
-- ==============================================================================================
-- PROCESS_ERRORRED_FIELD
-- ==============================================================================================
--***********************************************************************************************

-- ==============================================================================================
-- this is called to display message of any type which does not involve setting any token
-- sets the process_status to 3, sets values of error_code and error_message,
-- writes into fnd log and calls write_to_wie
-- ==============================================================================================

PROCEDURE process_errorred_field(
        p_product      IN VARCHAR2,
        p_message_name IN VARCHAR2,
        stmt_number    IN NUMBER) IS

x_err_msg  VARCHAR2(2000) := NULL;

BEGIN
        v_wlji_process_status(v_index) := 3; --ERROR
        v_wlji_err_code(v_index) := -1;
        fnd_message.set_name(p_product, p_message_name);
        x_err_msg :=  fnd_message.get;
        v_wlji_err_msg(v_index) := x_err_msg;
        fnd_file.put_line(fnd_file.log, 'stmt_num: '|| stmt_number||'  '||x_err_msg);
        fnd_file.new_line(fnd_file.log, 3);


END process_errorred_field;


--***********************************************************************************************
-- ==============================================================================================
-- HANDLE_ERROR
-- ==============================================================================================
--***********************************************************************************************


PROCEDURE handle_error  (
        p_err_code     IN NUMBER,
        p_err_msg      IN VARCHAR2,
        stmt_number    IN NUMBER) IS

BEGIN
        v_wlji_process_status(v_index) := 3; --ERROR
        v_wlji_err_code(v_index) := p_err_code;
        v_wlji_err_msg(v_index) := substr(p_err_msg,1,2000);
        fnd_file.put_line(fnd_file.log, 'stmt_num: ' || stmt_number||'  '||p_err_msg);
        fnd_file.new_line(fnd_file.log, 3);

END handle_error;


--***********************************************************************************************
-- ==============================================================================================
-- HANDLE_WARNING
-- ==============================================================================================
--***********************************************************************************************


PROCEDURE handle_warning(
        p_err_msg                      IN      VARCHAR2,
        p_header_id                    IN      NUMBER,
        p_request_id                   IN      NUMBER,
        p_program_id                   IN      NUMBER,
        p_program_application_id       IN      NUMBER) IS

dummy_err_code number;
dummy_err_msg varchar2(2000);

BEGIN
        fnd_file.new_line(fnd_file.log, 1);
        fnd_file.put_line(fnd_file.log, '*** WARNING MESSAGE BEGIN ***');
        fnd_file.put_line(fnd_file.log, p_err_msg);
        fnd_file.put_line(fnd_file.log, '*** WARNING MESSAGE END ***');
        fnd_file.new_line(fnd_file.log, 1);
        wsmputil.WRITE_TO_WIE (
                 p_header_id,
                 substr(p_err_msg,1,2000),
                 p_request_id,
                 p_program_id,
                 p_program_application_id,
                 2,
                 dummy_err_code,
                 dummy_err_msg );
END handle_warning;




--***********************************************************************************************
-- ==============================================================================================
-- OVERLOADED PROCESS_INTERFACE_ROWS
-- ==============================================================================================
--***********************************************************************************************

PROCEDURE  process_interface_rows (
        retcode         OUT NOCOPY NUMBER,
        errbuf          OUT NOCOPY VARCHAR2 ) IS
begin

        process_interface_rows (retcode, errbuf, '');

end process_interface_rows;



--***********************************************************************************************
-- ==============================================================================================
-- FUNCTION honor_kanban_size
-- ==============================================================================================
--***********************************************************************************************

-- This function should ideally return either 1 or 2 for every kanban (i.e. pull sequence)
-- 1 => honor kanban size limitations
-- 2 => do not honor kanban size limitations
-- This is of course applicable when the user chooses a starting lot for creating a kanban
-- replenishment order, because, otherwise, the order is always created for the kanban size.
-- If a starting lot is chosen, the work order can be of any arbitrary size. If the api returns
-- 1, and if the job quantity exceeds the kanban size, the job quantity is truncated to match the
-- kanban size. E.g. Say kanba size is 20. User chooses an inv lot of quantity 1000, component per
-- is 2, i.e. a work order is generated for 500. If this api returns 1, the work order will be
-- generated for 20 only.
-- Ideally, the option to specify a value for this parameter should be provided when the user creates
-- a pull sequence. For DM_FP I user will see this as an option on wsm parameters screen. Thus of all
-- the parameters passed to the api, only the organization id will be used to query wsm_parameters.

function  honor_kanban_size (
        p_org_id            IN NUMBER,
        p_item_id           IN NUMBER,
        p_subinv            IN VARCHAR2,
        p_locator_id        IN NUMBER,
        p_kanban_plan_id    IN NUMBER)
return number is
    l_hon_kanban_size number;
begin

    select honor_kanban_size
    into   l_hon_kanban_size
    from   wsm_parameters
    where  organization_id = p_org_id;

    if l_hon_kanban_size is null then
        return 2;
    else
        return l_hon_kanban_size;
    end if;

exception
    when others then
        return 2;

end honor_kanban_size;


--***********************************************************************************************
-- ==============================================================================================
-- PROCESS_LBJI_ROWS_1159
-- ==============================================================================================
--***********************************************************************************************

-- This is the old process_interface_rows, retained to support Option A
-- This procedure will not be called for Release 12.

PROCEDURE  process_lbji_rows_1159 (
        retcode         OUT NOCOPY NUMBER,
        errbuf          OUT NOCOPY VARCHAR2,
        p_group_id      IN  NUMBER) IS

cursor c_pir is
        select  header_id
        from    wsm_lot_job_interface
        where   process_status = wip_constants.pending
--      and     group_id is null
        and     creation_date <= sysdate+1
        and     load_type in (5,6)
        order by job_name, organization_id;  -- CZH: this will group the job together


x_header           NUMBER;
l_group_id         NUMBER;
l_reqid            NUMBER ;
l_stmt_num         NUMBER;
conc_status        BOOLEAN;
alotted_rows       NUMBER := 0;
row_count          NUMBER := 0;
total_no_rows      NUMBER := 0;
no_rows_per_worker NUMBER := 30;
l_user_id          NUMBER;
l_resp_id          NUMBER;
l_resp_appl_id     NUMBER;

BEGIN

    fnd_file.put_line(fnd_file.log, 'Processing Interface rows..');

    retcode := 0;       -- bugfix 2845397: set the code to 0 (success)

    l_user_id := fnd_global.USER_ID;
    l_resp_id := fnd_global.RESP_ID;
    l_resp_appl_id := fnd_global.RESP_APPL_ID;

    fnd_global.apps_initialize(l_user_id, l_resp_id, l_resp_appl_id) ;

    if p_group_id is null then

        select  count(*)
        into    total_no_rows
        from    wsm_lot_job_interface
        where   process_status = wip_constants.pending
        --and   group_id is null
        and     creation_date <= sysdate+1
        and     load_type in (5,6);

        if mod(total_no_rows, no_of_workers) = 0 then
            no_rows_per_worker := total_no_rows / no_of_workers;
        else
            no_rows_per_worker := floor(total_no_rows / no_of_workers) + 1;
        end if;

        if no_rows_per_worker < batch_size then
            no_rows_per_worker := batch_size;
        end if;

        fnd_file.put_line(fnd_file.log, 'Total Pending Rows = '||total_no_rows);
        fnd_file.put_line(fnd_file.log, 'Number of Workers = '||no_of_workers);
        fnd_file.put_line(fnd_file.log, 'Batch Size = '||batch_size);
        fnd_file.put_line(fnd_file.log, 'Number of Rows per worker = '||no_rows_per_worker);

        select wsm_lot_job_interface_s.NEXTVAL
        into   l_group_id
        from   dual;

        open c_pir;
        loop

            fetch c_pir into x_header;

            if c_pir%notfound and (c_pir%rowcount - row_count) = 0 then exit; end if;

            if not c_pir%notfound then
                update  wsm_lot_job_interface wlji
                set     wlji.group_id =  l_group_id,
                        wlji.process_status = wip_constants.running
                where   header_id = x_header;
            end if;

            if (c_pir%rowcount - row_count) = no_rows_per_worker or c_pir%notfound then
                alotted_rows := c_pir%rowcount - row_count;

                row_count := c_pir%rowcount;

                l_reqid := FND_REQUEST.SUBMIT_REQUEST (
                              application   => 'WSM',
                              program       => 'WSMLNCHW',
                              sub_request   => FALSE,
                              argument1     => l_group_id,
                              argument2     => alotted_rows);
                if l_reqid = 0 then
                    rollback;
                else
                    commit;
                end if;

                fnd_file.put_line(fnd_file.log, 'Request_id: '||l_reqid||' submitted');

                if c_pir%notfound then exit; end if;

                if  not c_pir%notfound then
                    select wsm_lot_job_interface_s.NEXTVAL
                    into   l_group_id
                    from   dual;
                end if;

            end if;

        end loop;
        close c_pir;

    else -- p_group_id is not null
    -- note that in that case only one worker will be launched, i.e. the benefits of
    -- parallelization will not be realized. Hence it's advisable not to use the import lot
    -- job program to process rows with a specific group id unless the number of such rows is very small.

        select  count(*)
        into    total_no_rows
        from    wsm_lot_job_interface
        where   process_status = wip_constants.pending
        and     group_id = p_group_id
        and     creation_date <= sysdate+1
        and     load_type in (5,6);

        if total_no_rows > 0 then

            update  wsm_lot_job_interface wlji
            set     wlji.process_status = wip_constants.running
            where   group_id = p_group_id;

            l_reqid :=  FND_REQUEST.SUBMIT_REQUEST (
                              application   => 'WSM',
                              program       => 'WSMLNCHW',
                              sub_request   => FALSE,
                              argument1     => p_group_id,
                              argument2     => total_no_rows);

            if l_reqid = 0 then
                rollback;
            else
                commit;
            end if;

            fnd_file.put_line(fnd_file.log, 'Request_id: '||l_reqid||' submitted');

        else -- total_no_rows <= 0
                fnd_file.put_line(fnd_file.log, 'No Rows found in interface table');
        end if;

    end if; -- group_id


EXCEPTION

    when others then
        retcode := 1;
        errbuf := 'WSMLBJIB.process_lbji_rows_1159: stmt num= '||l_stmt_num||' '||SUBSTR(SQLERRM, 1,240);
        fnd_file.put_line(fnd_file.log,errbuf);
        conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',errbuf);

END process_lbji_rows_1159 ;


--***********************************************************************************************
-- ==============================================================================================
-- LAUNCH WORKER_1159
-- ==============================================================================================
--***********************************************************************************************

PROCEDURE  launch_worker_1159 (
        retcode         OUT NOCOPY NUMBER,
        errbuf          OUT NOCOPY VARCHAR2,
        l_group_id      IN  NUMBER,
        alotted_rows    IN  NUMBER  ) IS

-- ==============================================================================================
-- cursors used to bulk bind data from wlji to PL/SQL tables
-- ==============================================================================================
cursor c_wlji_1 is
select
        error_code,
        error_msg,
        last_update_date,
        request_id,
        program_id,
        program_application_id,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        program_update_date,
        last_updated_by_name,
        created_by_name,
        organization_id,
        primary_item_id,
        header_id,
        process_status,
        routing_reference_id,
        completion_subinventory,
        completion_locator_id,
        mode_flag,
        group_id,
        load_type,
        status_type,
        last_unit_completion_date,
        old_completion_date,
        bom_reference_id,
        bom_revision_date,
        routing_revision_date,
        wip_supply_type,
        class_code,
        lot_number,
        job_name,
        description,
        firm_planned_flag,
        alternate_routing_designator,
        alternate_bom_designator,
        demand_class,
        start_quantity,
        old_start_quantity,
        wip_entity_id,
        error,
        process_phase,
        first_unit_start_date,
        first_unit_completion_date,
        last_unit_start_date,
        scheduling_method,
        routing_revision,
        bom_revision,
        schedule_group_id,
        schedule_group_name,
        build_sequence,
        net_quantity,
        allow_explosion,
        old_status_type,
        interface_id,
        coproducts_supply,
        source_code,
        source_line_id,
        process_type,
        processing_work_days,
        daily_production_rate,
        line_id,
        lot_control_code,
        repetitive_schedule_id,
        parent_group_id,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        organization_code,
        line_code,
        primary_item_segments,
        bom_reference_segments,
        routing_reference_segments,
        completion_locator_segments,
        project_id,
        project_name,
        task_id,
        delivery_id,
        descriptive_flex_segments,
        project_number,
        task_number,
        project_costed,
        end_item_unit_number,
        overcompletion_tolerance_type,
        overcompletion_tolerance_value,
        kanban_card_id,
        priority,
        due_date,
        task_name,
        job_type,
        date_released        --bugfix 2697295
from    wsm_lot_job_interface
where   group_id = l_group_id
and     process_status = 2 -- WIP_CONSTANTS.running;
order by organization_id,
         priority,
         due_date;

-- ==============================================================================================
-- other variables
-- ==============================================================================================

txn_header_id                   NUMBER;
txn_tmp_header_id               NUMBER;

l_source_item_rev               VARCHAR2(3);
--l_source_item_rev_date        date;           -- Del: bug 2963225
l_rev_control_code              number;         -- Add: bug 2963225
l_start_lot_revision            number;         -- Add: bug 2963225
l_rev_sysdate                   DATE;
l_last_update_date              DATE := SYSDATE;
l_request_id                    NUMBER := fnd_global.conc_request_id;
l_program_id                    NUMBER := fnd_global.conc_program_id;
l_program_application_id        NUMBER := fnd_global.prog_appl_id;
l_user                          NUMBER := FND_GLOBAL.user_id;
l_login                         NUMBER := FND_GLOBAL.login_id;
l_creation_date                 DATE := sysdate;
l_prog_updt_date                DATE := sysdate;
conc_status                     BOOLEAN;
l_default_subinventory          VARCHAR2(10);
l_default_compl_loc_id          NUMBER;
l_segs                          VARCHAR2(10000);
l_loc_success                   BOOLEAN;
l_sub_loc_control               NUMBER;
l_org_loc_control               NUMBER;
l_item_loc_control              NUMBER;
l_restrict_locators_code        NUMBER;
l_del_int_prof_value            number;

l_error_code                    NUMBER := 0;
l_return_value                  NUMBER := 0;
l_error_msg                     VARCHAR2(2000) := NULL;
translated_meaning              varchar2(240);
l_error_count                   NUMBER := 0;
l_warning_count                 NUMBER := 0;
x_return_status                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_returnStatus                  VARCHAR2(1);
x_msg_data                      VARCHAR2(2000);

l_boolean_success               BOOLEAN := false;
l_inv_worker_req_id             NUMBER := 0;
req_phase                       VARCHAR2(2000);
req_status                      VARCHAR2(2000);
req_devphase                    VARCHAR2(2000);
req_devstatus                   VARCHAR2(2000);
req_message                     VARCHAR2(1000);
req_wait                        BOOLEAN;

l_atleast_one_row_in_mmtt       NUMBER := 0;

dummy_err_code                  NUMBER;
dummy_err_msg                   VARCHAR2(2000);

l_stmt_num                      NUMBER;

l_item_id                       NUMBER;
l_sub                           VARCHAR2(10);
l_revision                      VARCHAR2(3);
l_quantity                      NUMBER;
l_build_sequence                NUMBER;
l_line_id                       NUMBER;
l_schedule_group_id             NUMBER;
p_date_released                 DATE;
p_old_date_released             DATE;
l_department_id                 NUMBER;
p_est_scrap_account             NUMBER;
p_est_scrap_var_account         NUMBER;

p_old_primary_item_id           NUMBER;
p_old_class_code                VARCHAR2(10);
p_old_start_date                DATE;
p_old_complete_date             DATE;
p_old_quantity                  NUMBER;
p_old_net_quantity              NUMBER;
p_old_bom_revision              varchar2(3);
p_old_routing_revision          varchar2(3);
p_skip_updt                     NUMBER;
p_old_status_type               NUMBER;
p_old_firm_planned_flag         NUMBER;
p_old_job_type                  NUMBER;
dummy_number                    NUMBER;
dummy_varchar                   VARCHAR2(3);
dummy_date                      DATE;
p_change_bom_alt                NUMBER; -- bug 2762029
p_change_routing_alt            NUMBER; -- bug 2762029
p_change_alt_flag               NUMBER; -- bug 2762029
p_change_bom_reference          NUMBER;
p_change_routing_reference      NUMBER;
p_old_bom_reference_id          NUMBER;
p_old_alt_bom_designator        VARCHAR2(10);
p_old_routing_reference_id      NUMBER;
p_old_alt_routing_designator    VARCHAR2(10);
p_old_bom_revision_date         DATE;
p_old_routing_revision_date     DATE;
p_old_com_rtg_seq_id            NUMBER;
p_old_com_bom_seq_id            NUMBER;
p_old_supply_type               NUMBER;
p_coproducts_supply             NUMBER;
p_scheduled_start_date          DATE;
p_scheduled_completion_date     DATE;
p_old_completion_subinv         varchar2(10);
p_old_completion_locator        number;
temp_start_quantity             NUMBER;
temp_fusd                       DATE;
temp_lucd                       DATE;
temp_supply                     NUMBER;

xst                             BOOLEAN := true;
l_no_of_records                 NUMBER := 0;
l_aux_mesg                      VARCHAR2(240):= NULL;
str                             VARCHAR2(100);
hash_value                      NUMBER;
l_dummy                         NUMBER := 0;
l_err_msg                       VARCHAR2(2000):= NULL;

l_locator_id                    NUMBER;
l_job_type                      NUMBER;
l_rev_date                      DATE;
l_date_text                     VARCHAR2(100);
l_component_quantity            NUMBER;
l_kanban_size                   NUMBER;
l_qoh                           NUMBER;
l_att                           NUMBER;
l_atr                           NUMBER;
l_component_yield_factor        NUMBER;
l_required_quantity             NUMBER;
l_quantity_tobe_issued          NUMBER;
l_start_op_seq_id               NUMBER;
l_start_seq_id                  NUMBER;
l_end_seq_id                    NUMBER;
l_txnexist                      NUMBER;
l_qntydiff                      NUMBER;
mtl_locator_type                NUMBER;
l_src_lot_number                wsm_starting_lots_interface.lot_number%type;
l_src_inv_item_id               NUMBER;
l_comp_basis_type               NUMBER ;  --LBM enh: - basis type null=Item, 2=Lot based. defaults to null=Item.

-- abb H
min_op_seq_num                  NUMBER;
max_op_seq_num                  NUMBER;
l_scrap_account10               NUMBER;
l_est_scrap_abs_account10       NUMBER;
l_scrap_account9999             NUMBER;
l_est_scrap_abs_account9999     NUMBER;
l_temp_cc                       VARCHAR2(10);

invalid_id_error                EXCEPTION;
invalid_job_name_error          EXCEPTION;
abort_request                   EXCEPTION;
build_job_exception             EXCEPTION;
update_job_exception            EXCEPTION;
invalid_qnty_error              EXCEPTION;

prev_rowcount                   NUMBER := 0;
aReturnBoolean                  BOOLEAN := false;

batch_group_id                  NUMBER;
l_rtg_rev_date                  DATE;    --ADD: CZH.I_OED-1
l_bom_rev_date                  DATE;    --ADD: BUGFIX 2380517

v_load_wsli                     BOOLEAN;
l_req_request_id                number;
l_osp_op_seq_num                NUMBER; -- OSP FP I

job_type_meaning                VARCHAR2(30);
assembly_name                   VARCHAR2(40);
status_name                     VARCHAR2(30);
org_code                        VARCHAR2(3);

-- bugfix 2820900:  Added new variables

x_new_name      varchar2(240);
l_dup_job_name      varchar2(240);

-- end bugfix 2820900

BEGIN   -- for launch_worker

    retcode := 0;       -- bugfix 2845397: set the code to 0 (success)

    SAVEPOINT back_to_square_one;

-- ==============================================================================================
-- bulk fetching data into PL/SQL tables for ease of validation
-- ==============================================================================================

    begin

l_stmt_num := 1;
        WSMPLCVA.load_org_table;

l_stmt_num := 2;
        WSMPLCVA.load_subinventory;

l_stmt_num := 3;
        WSMPLCVA.load_class_code;

        if lbji_debug = 'Y' then
            fnd_file.put_line(fnd_file.log, 'loading org/subinv/class-code values into memory (once per worker).. Success.');
        end if;

    exception
        when others then
            raise abort_request;
    end;

-- ==============================================================================================
-- bulk fetching data from wlji to PL/SQL tables
-- ==============================================================================================

l_stmt_num := 40;
    open c_wlji_1;
    loop  -- main loop

        v_load_wsli  := true; --i.e. run the load wsli routine for every batch

        fetch c_wlji_1 bulk collect into
            v_wlji_err_code,
            v_wlji_err_msg,
            v_wlji_last_updt_date,
            v_wlji_request_id,
            v_wlji_program_id,
            v_wlji_program_application_id,
            v_wlji_last_updt_by,
            v_wlji_creation_date,
            v_wlji_created_by,
            v_wlji_last_updt_login,
            v_wlji_prog_updt_date,
            v_wlji_last_updt_by_name,
            v_wlji_created_by_name,
            v_wlji_org,
            v_wlji_item,
            v_wlji_header_id,
            v_wlji_process_status,
            v_wlji_routing_reference_id,
            v_wlji_completion_subinventory,
            v_wlji_completion_locator_id,
            v_wlji_mode_flag,
            v_wlji_group_id,
            v_wlji_load_type,
            v_wlji_status_type,
            v_wlji_lucd,
            v_wlji_old_completion_date,
            v_wlji_bom_reference_id,
            v_wlji_bom_revision_date,
            v_wlji_routing_revision_date,
            v_wlji_wip_supply_type,
            v_wlji_class_code,
            v_wlji_lot_number,
            v_wlji_job_name,
            v_wlji_description,
            v_wlji_firm_planned_flag,
            v_wlji_alt_routing_designator,
            v_wlji_alt_bom_designator,
            v_wlji_demand_class,
            v_wlji_start_quantity,
            v_wlji_old_start_quantity,
            v_wlji_wip_entity_id,
            v_wlji_error,
            v_wlji_process_phase ,
            v_wlji_fusd,
            v_wlji_fucd,
            v_wlji_last_unit_start_date,
            v_wlji_scheduling_method,
            v_wlji_routing_revision ,
            v_wlji_bom_revision ,
            v_wlji_schedule_group_id,
            v_wlji_schedule_group_name,
            v_wlji_build_sequence ,
            v_wlji_net_quantity ,
            v_wlji_allow_explosion ,
            v_wlji_old_status_type,
            v_wlji_interface_id ,
            v_wlji_coproducts_supply,
            v_wlji_source_code,
            v_wlji_source_line_id,
            v_wlji_process_type,
            v_wlji_processing_work_days,
            v_wlji_daily_production_rate,
            v_wlji_line_id,
            v_wlji_lot_control_code,
            v_wlji_repetitive_schedule_id,
            v_wlji_parent_group_id,
            v_wlji_attribute_category,
            v_wlji_attribute1,
            v_wlji_attribute2,
            v_wlji_attribute3,
            v_wlji_attribute4 ,
            v_wlji_attribute5 ,
            v_wlji_attribute6 ,
            v_wlji_attribute7 ,
            v_wlji_attribute8 ,
            v_wlji_attribute9 ,
            v_wlji_attribute10 ,
            v_wlji_attribute11 ,
            v_wlji_attribute12 ,
            v_wlji_attribute13 ,
            v_wlji_attribute14 ,
            v_wlji_attribute15 ,
            v_wlji_organization_code,
            v_wlji_line_code ,
            v_wlji_primary_item_segments,
            v_wlji_bom_reference_segments,
            v_wlji_rtg_ref_segs,
            v_wlji_compl_locator_segments,
            v_wlji_project_id ,
            v_wlji_project_name ,
            v_wlji_task_id ,
            v_wlji_delivery_id ,
            v_wlji_desc_flx_sgmts,
            v_wlji_project_number ,
            v_wlji_task_number ,
            v_wlji_project_costed ,
            v_wlji_end_item_unit_number,
            v_wlji_overcompl_tol_type,
            v_wlji_overcompl_tol_value,
            v_wlji_kanban_card_id ,
            v_wlji_priority ,
            v_wlji_due_date ,
            v_wlji_task_name,
            v_wlji_job_type,
            v_wlji_date_released   --bugfix 2697295
        limit batch_size;

        if lbji_debug = 'Y' then
            fnd_file.put_line(fnd_file.log, 'no of rows loaded for the current batch: '||c_wlji_1%rowcount);
        end if;

        if c_wlji_1%rowcount - prev_rowcount <> 0 then

            -- do the procesing --
-- ==============================================================================================
-- getting the header_id to be populated for mmtt
-- ==============================================================================================

            select mtl_material_transactions_s.nextval
            into   txn_header_id
            from   dual;

-- ==============================================================================================
-- updating the group_id column of wlji with a number unique for this particular batch. This'll
-- help when I select corresponding rows from wsli.
-- ==============================================================================================
l_stmt_num := 78;

            select wsm_lot_job_interface_s.NEXTVAL
            into   batch_group_id
            from   dual;

            forall indx in v_wlji_header_id.first..v_wlji_header_id.last
            update wsm_lot_job_interface
            set    group_id = batch_group_id
            where  header_id = v_wlji_header_id(indx);

            fnd_file.put_line(fnd_file.output, '         ----  Lot Based Job Creation  ----         ');
            fnd_file.put_line(fnd_file.output, ' ');
            fnd_file.put_line(fnd_file.output, ' ');

-- ==============================================================================================
-- processing of data begins here
-- ==============================================================================================
l_stmt_num := 80;

            v_index := v_wlji_header_id.first;
            while v_index <= v_wlji_header_id.last
            loop  -- inner loop

                if lbji_debug = 'Y' then
                    fnd_file.put_line(fnd_file.log,'***************************************************************');
                    fnd_file.put_line(fnd_file.log,'new job ... wlji header_id: '||v_wlji_header_id(v_index));
                    fnd_file.put_line(fnd_file.log,'        ... job name: '||v_wlji_job_name(v_index));
                    fnd_file.put_line(fnd_file.log,'***************************************************************');
                end if;

                SAVEPOINT row_skip;

                BEGIN  -- main block

                    routing_seq_id := '';
                    bom_seq_id := '';
                    dummy_err_code := 0;
                    dummy_err_msg := NULL;
                    l_error_code := 0;
                    l_return_value := 0;
                    l_error_msg:= NULL;
                    x_return_status:= FND_API.G_RET_STS_SUCCESS;
                    l_returnStatus :=  FND_API.G_RET_STS_SUCCESS;
                    l_dummy:= 0;
                    xst:= true;
                    str := '';
                    hash_value := 0;
                    l_no_of_records:= 0;
                    l_err_msg:= NULL;
                    l_aux_mesg:= NULL;
                    l_default_subinventory := '';
                    l_default_compl_loc_id := 0;
                    l_segs := '';
                    l_loc_success := true;
                    l_sub_loc_control := 0;
                    l_org_loc_control := 0;
                    l_item_loc_control := 0;
                    l_restrict_locators_code := 0;
                    l_item_id := 0;
                    l_sub := '';
                    l_revision := '';
                    l_quantity := 0;
                    l_locator_id := 0;
                    l_rev_date := '';
                    l_date_text := '';
                    l_component_quantity := 0;
                    l_qoh := 0;
                    l_att := 0;
                    l_atr := 0;
                    l_component_yield_factor := 0;
                    l_required_quantity := 0;
                    l_quantity_tobe_issued := 0;
                    l_start_op_seq_id := 0;
                    l_start_seq_id := 0;
                    l_end_seq_id := 0;
                    p_date_released := '';
                    p_old_date_released := '';
                    p_common_bill_sequence_id := 0;
                    p_common_routing_sequence_id := 0;
                    p_old_primary_item_id := 0;
                    p_old_class_code := '';
                    p_old_start_date := '';
                    p_old_complete_date := '';
                    p_est_scrap_account := NULL;
                    p_est_scrap_var_account := NULL;
                    p_old_quantity := 0;
                    p_old_bom_revision := '';
                    p_old_routing_revision := '';
                    p_old_net_quantity := 0;
                    p_skip_updt:=0;
                    p_old_status_type := 0;
                    l_department_id := 0;
                    p_old_firm_planned_flag := 0;
                    p_old_job_type:= 0;
                    dummy_number:=0;
                    dummy_varchar:='';
                    dummy_date:=sysdate;
                    p_change_bom_reference:=0;
                    p_change_routing_reference:=0;
                    p_change_bom_alt:=0;
                    p_change_routing_alt:=0;
                    p_change_alt_flag:=0;
                    p_old_bom_reference_id:=0;
                    p_old_alt_bom_designator:='';
                    p_old_routing_reference_id:=0;
                    p_old_alt_routing_designator:='';
                    p_old_bom_revision_date:='';
                    p_old_routing_revision_date:='';
                    p_old_com_rtg_seq_id:=0;
                    p_old_com_bom_seq_id:=0;
                    p_old_supply_type:=0;
                    p_scheduled_start_date:='';
                    p_scheduled_completion_date:='';
                    p_old_completion_subinv:='';
                    p_old_completion_locator:='';
                    p_coproducts_supply:='';
                    temp_start_quantity:=0;
                    temp_fusd:='';
                    temp_lucd:='';
                    temp_supply:=0;
                    l_build_sequence := 0;
                    l_line_id := 0;
                    l_schedule_group_id := 0;
                    l_src_lot_number:=NULL;
                    l_src_inv_item_id:=NULL;

                    -- abb H
                    min_op_seq_num:=0;
                    max_op_seq_num:=0;
                    l_scrap_account10:=NULL;
                    l_est_scrap_abs_account10:=NULL;
                    l_scrap_account9999:=NULL;
                    l_est_scrap_abs_account9999:=NULL;

                    v_wlji_err_code(v_index)                := l_error_code;
                    v_wlji_err_msg(v_index)                 := l_error_msg;
                    v_wlji_last_updt_date(v_index)          := l_last_update_date;
                    v_wlji_request_id(v_index)              := l_request_id;
                    v_wlji_program_id(v_index)              := l_program_id;
                    v_wlji_program_application_id(v_index)  := l_program_application_id;
                    v_wlji_creation_date(v_index)           := l_creation_date;
                    v_wlji_last_updt_login(v_index)         := l_login;
                    v_wlji_prog_updt_date(v_index)          := l_prog_updt_date;


-- ==============================================================================================
-- VALIDATIONS BEGIN
-- ==============================================================================================

l_stmt_num := 81;
                    -- *** job_type = 3 => non-standard job. Anything else/null => standard job ***
                    if v_wlji_job_type(v_index) is null then v_wlji_job_type(v_index):= 1; end if;


l_stmt_num := 82;
                    -- *** mode_flag cannot be 2 for non-standard jobs ***
                    if v_wlji_job_type(v_index) = 3 and v_wlji_mode_flag(v_index) = 2 then
                        l_aux_mesg := 'Mode Flag cannot be 2 for Non Standard Jobs';
                        process_invalid_field('MODE FlAG',
                                              l_aux_mesg,
                                              l_stmt_num);
                        l_error_code := -1;
                        GOTO skip_validate_constants;
                    end if;


l_stmt_num := 83;
                    -- *** load_wsli_data loads relevant rows from wsli into PL/SQL ***
                    -- *** tables for easy validation. I do not want this procedure ***
                    -- *** to be executed if there's no mode_flag = 2 rec in wlji.  ***
                    -- *** v_load_wsli (true/false) ensures that the procedure is   ***
                    -- *** called only once per worker                              ***
                    if v_wlji_load_type(v_index) = 5 and v_wlji_mode_flag(v_index) = 2
                       and v_load_wsli = true then

                        if (lbji_debug = 'Y') then
                            fnd_file.put_line(fnd_file.log,'loading wsli for batch group id: '||batch_group_id||'..');
                        end if;

                        load_wsli_data(batch_group_id);
                        v_load_wsli := false;
                    end if;


l_stmt_num := 84;
                    if v_wlji_load_type(v_index) = 5 and v_wlji_job_type(v_index) <> 3 then
                        if v_wlji_firm_planned_flag(v_index) is null then
                            v_wlji_firm_planned_flag(v_index) := 2;
                        elsif v_wlji_firm_planned_flag(v_index) <> 1 and
                              v_wlji_firm_planned_flag(v_index) <> 2 then
                            l_aux_mesg := 'Firm Planned Flag should be 1 or 2';
                            process_invalid_field('FIRM_PLANNED_FLAG',
                                                  l_aux_mesg,
                                                  l_stmt_num);
                            l_error_code := -1;
                            GOTO skip_validate_constants;
                        end if;
                    end if;


l_stmt_num := 85;
                    if WSMPVERS.get_osfm_release_version < '110509' and v_wlji_kanban_card_id(v_index) is not null then
                        l_error_code := -1;
                        process_errorred_field('WSM',
                                               'WSM_KANBAN_NOT ALLOWED',
                                                l_stmt_num);
                    end if;
                    if l_error_code <> 0 then
                        l_error_count := l_error_count + 1;
                        GOTO skip_other_steps;
                    end if;


l_stmt_num := 91;
                    -- *** check that there's a row in wsli for this mode 2 job ***
                    xst := true;
                    if v_wlji_load_type(v_index) = 5 AND v_wlji_mode_flag(v_index) = 2 then
                        if v_wlji_source_line_id(v_index) is NULL then
                            l_error_code := -1;
                            process_errorred_field('WSM',
                                                   'WSM_START_LOT_REQUIRED',
                                                   l_stmt_num);
                        else
                            xst := v_wsli.exists(v_wlji_source_line_id(v_index));
                            if xst = false then
                                l_error_code := -1;
                                process_errorred_field('WSM',
                                                       'WSM_START_LOT_REQUIRED',
                                                       l_stmt_num);
                            end if;
                        end if;
                    end if;

                    if l_error_code <> 0 then
                        l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                    end if;
                    xst := true;


l_stmt_num := 100;
                    -- *** validate org id begin ***
                    xst :=  WSMPLCVA.v_org.exists(v_wlji_org(v_index));
                    if xst = false then
                        l_error_code := -1;
                        process_invalid_field('ORGANIZATION ID',
                                              '',
                                              l_stmt_num);
                    end if;

                    if l_error_code <> 0 then
                        l_error_count := l_error_count + 1;
                        GOTO skip_other_steps;
                    end if;
                    xst := true;

                    if lbji_debug = 'Y' then
                        fnd_file.put_line(fnd_file.log, 'Org Id Validation..Success.');
                    end if;
                    -- *** validate org id end ***


l_stmt_num := 110;
                    -- *** make sure that no one is trying to create a wip lot out of an inventory ***
                    -- *** lot by splitting/merging/etc. CZH: check wlsmi
                    if v_wlji_load_type(v_index) = 5 then

                        begin
                            select  1
                            into    l_no_of_records
                            from    wsm_starting_lots_interface    wsli,
                                    wsm_lot_split_merges_interface wlsmi
                            where   wsli.lot_number = v_wlji_job_name(v_index)
                            and     wsli.header_id = wlsmi.header_id
                            and     wlsmi.process_status in (1,2);

                        exception
                            when too_many_rows then l_no_of_records := 1;
                            when no_data_found then NULL;
                        end;

                        if l_no_of_records <> 0 then
                            l_error_code := -1;
                            process_errorred_field('WSM',
                                                   'WSM_LOT_EXISTS',
                                                   l_stmt_num);
                        end if;

                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;
                        l_no_of_records := 0;

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Checking existance of inv lots of the same name.. Success');
                        end if;

                    end if; -- load type 5


l_stmt_num := 120;
                    -- *** validate constants begin ***  CZH: this should be moved above

l_stmt_num := 130;
                    if (v_wlji_load_type(v_index) <> 5) AND (v_wlji_load_type(v_index) <> 6) then
                        l_aux_mesg := 'Load type should be 5 or 6';
                        process_invalid_field('LOAD TYPE',
                                              l_aux_mesg,
                                              l_stmt_num);
                        l_error_code := -1;
                        GOTO skip_validate_constants;
                    end if;

l_stmt_num := 140;
                    if v_wlji_load_type(v_index) = 5 AND
                      (v_wlji_scheduling_method(v_index) <> 3 AND
                       v_wlji_scheduling_method(v_index) <> 2) then
                        l_aux_mesg := 'Scheduling method should be 2 or 3 for load_type 5';
                        process_invalid_field('SCHEDULING METHOD',
                                              l_aux_mesg,
                                              l_stmt_num);
                        l_error_code := -1;
                        GOTO skip_validate_constants;
                    end if;

l_stmt_num := 150;
                    if v_wlji_load_type(v_index) = 5 AND
                       v_wlji_job_type(v_index) <> 3 and
                       v_wlji_mode_flag(v_index) not in (1,2) then
                        l_aux_mesg := 'For creating new jobs, mode flag should have value 1 or 2';
                        process_invalid_field('MODE FLAG',
                                              l_aux_mesg,
                                              l_stmt_num);
                        l_error_code := -1;
                        GOTO skip_validate_constants;
                    elsif v_wlji_job_type(v_index) = 3 then
                        if v_wlji_mode_flag(v_index) <> 1 then
                            if lbji_debug = 'Y' then
                                fnd_file.put_line(fnd_file.log, 'Ignoring mode_flag, has to be 1 for non-standard jobs.');
                            end if;
                        end if;
                        if v_wlji_mode_flag(v_index) is null then
                            v_wlji_mode_flag(v_index) := 1;
                        end if;
                    end if;

l_stmt_num := 160;
                    if v_wlji_load_type(v_index)  = 6 AND
                      (v_wlji_scheduling_method(v_index) <> 3 AND
                       v_wlji_scheduling_method(v_index) <> 2) then
                        l_aux_mesg := 'Scheduling method should be 2 or 3 for load_type 6';
                        process_invalid_field('SCHEDULING METHOD',
                                               l_aux_mesg,
                                               l_stmt_num);
                        l_error_code := -1;
                        GOTO skip_validate_constants;
                    end if;

l_stmt_num := 170;
                    if UPPER(v_wlji_allow_explosion(v_index))  = 'N' then
                        process_errorred_field('WSM',
                                               'WSM_ALLOW_EXPL_Y',
                                               l_stmt_num);
                        l_error_code := -1;
                        GOTO skip_validate_constants;
                    else
                        v_wlji_allow_explosion(v_index) := 'Y';
                    end if;

l_stmt_num := 180;
                    if v_wlji_wip_supply_type(v_index) is null then
                        v_wlji_wip_supply_type(v_index) := 7;
                    elsif v_wlji_wip_supply_type(v_index) not in (1,2,3,4,5,7) then
                        l_aux_mesg := '';
                        process_invalid_field('WIP SUPPLY TYPE',
                                              l_aux_mesg,
                                              l_stmt_num);
                        l_error_code := -1;
                        GOTO skip_validate_constants;
                    end if;

l_stmt_num := 181;
                    if v_wlji_status_type(v_index) not in
                    (WIP_CONSTANTS.UNRELEASED,
                     WIP_CONSTANTS.RELEASED,
                     WIP_CONSTANTS.HOLD,
                     WIP_CONSTANTS.CANCELLED) then
                        l_aux_mesg := '';
                        process_invalid_field('STATUS TYPE',
                                              l_aux_mesg,
                                              l_stmt_num);
                        l_error_code := -1;
                        GOTO skip_validate_constants;
                    end if;

<< skip_validate_constants >>

                    if l_error_code <> 0 then
                        l_error_count := l_error_count + 1;
                        GOTO skip_other_steps;
                    end if;
                    l_aux_mesg := '';

                    if lbji_debug = 'Y' then
                        fnd_file.put_line(fnd_file.log, 'Validating Constants.. Success.');
                    end if;

                    -- *** validate constants end ***



l_stmt_num := 181.5;
                    l_error_code := 0;
                    l_err_msg := '';

                    -- *** validation of a non-standard job for creation***

                    if v_wlji_job_type(v_index) = 3 and v_wlji_load_type(v_index) = 5 then

                        -- validation_level = 0 => validations performed during job creation

                        -- *** Error Code and Message Guide ***
                        -- 1: Routing Reference Cannot be Null
                        -- 2: Invalid Assembly Item Id
                        -- 3: Invalid Routing Reference Id
                        -- 4: Invalid Bom Reference Id
                        -- 5: Invalid Alternate Routing Designator
                        -- 0: Invalid Alternate Bom Designator -- WARNING
                        -- 7: Start Date cannot be greater than End Date
                        -- 8: Both Start and End Dates must be Entered
                        -- 9: Invalid Start Quantity
                        -- 10: Invalid Net Quantity
                        -- 11: Invalid Class Code
                        -- 12: Invalid Completion Locator Id
                        -- 13: Invalid Completion Subinventory
                        -- 14: Invalid Firm Planned Flag


                        wsmputil.validate_non_std_references(v_wlji_item(v_index),
                                  v_wlji_routing_reference_id(v_index),
                                  v_wlji_bom_reference_id(v_index),
                                  v_wlji_alt_routing_designator(v_index),
                                  v_wlji_alt_bom_designator(v_index),
                                  v_wlji_org(v_index),
                                  v_wlji_fusd(v_index),
                                  v_wlji_lucd(v_index),
                                  v_wlji_start_quantity(v_index),
                                  v_wlji_net_quantity(v_index),
                                  v_wlji_class_code(v_index),
                                  v_wlji_completion_subinventory(v_index),
                                  v_wlji_completion_locator_id(v_index),
                                  v_wlji_firm_planned_flag(v_index),
                                  v_wlji_bom_revision(v_index),
                                  v_wlji_bom_revision_date(v_index),
                                  v_wlji_routing_revision(v_index),
                                  v_wlji_routing_revision_date(v_index),
                                  routing_seq_id,
                                  bom_seq_id,
                                  0,
                                  l_error_code,
                                  l_err_msg);


                        if l_error_code <> 0 then
                            HANDLE_ERROR( l_error_code, l_err_msg, l_stmt_num);
                            l_error_code := -1;
                        end if;

                        if l_error_code = 0 and l_err_msg is not null then
                            fnd_file.new_line(fnd_file.log, 2);
                            fnd_file.put_line(fnd_file.log,l_err_msg);
                            fnd_file.new_line(fnd_file.log, 2);
                            l_err_msg := '';
                        end if;
                    end if; -- non-standard validations end

                    if l_error_code <> 0 then
                        l_error_count := l_error_count + 1;
                        GOTO skip_other_steps;
                    end if;


l_stmt_num := 240;
                    -- *** validate assembly quantity begin ***
                    if v_wlji_job_type(v_index) <> 3 then

                        if v_wlji_start_quantity(v_index) < 0 then
                            l_error_code := -1;
                            l_aux_mesg := 'Start quantity cannot be negative';
                            process_invalid_field(
                                  'START QUANTITY',
                                  l_aux_mesg,
                                  l_stmt_num);
                            GOTO skip_validate_strt_qnty;
                        end if;


                        if v_wlji_load_type(v_index) = 5 and
                          (v_wlji_start_quantity(v_index) is NULL or
                           v_wlji_start_quantity(v_index) = 0) then
                            l_error_code := -1;
                            l_aux_mesg := 'Start quantity cannot be NULL or 0 for job creation';
                            process_invalid_field(
                                  'START QUANTITY',
                                  l_aux_mesg,
                                  l_stmt_num);
                        end if;

<< skip_validate_strt_qnty >>

                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;
                        l_aux_mesg := '';

                        if lbji_debug = 'Y' and v_wlji_mode_flag(v_index) = 1 then
                            fnd_file.put_line(fnd_file.log, 'Assembly Quantity OK');
                        end if;
                    end if; -- job_type
                    -- *** validate assembly quantity end ***

l_stmt_num := 260;
                    -- *** validate mode one item id begin ***
                    -- CZH: why only for standard job ???
                    if v_wlji_load_type(v_index) = 5 and v_wlji_job_type(v_index) <> 3 then

                        if v_wlji_mode_flag(v_index) = 1 then
                            xst :=  WSMPLCVA.v_item.exists(v_wlji_item(v_index));
                        else -- mode flag 2
                            str := to_char(v_wlji_item(v_index))||
                                   to_char(v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id);
                            hash_value := dbms_utility.get_hash_value(str, 37, 1073741824);

                            xst := WSMPLCVA.v_mode2_item.exists(hash_value)
                                   AND WSMPLCVA.v_mode2_item(hash_value).INVENTORY_ITEM_ID =
                                            v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id
                                   AND WSMPLCVA.v_mode2_item(hash_value).PRIMARY_ITEM_ID = v_wlji_item(v_index);
                        end if;

                        if xst = false then

                            begin
                                select  1
                                into    l_no_of_records
                                from    mtl_system_items_kfv msi
                                where   msi.inventory_item_id = v_wlji_item(v_index)
                                and     msi.organization_id = v_wlji_org(v_index)
                                and     msi.lot_control_code = 2;
                            exception
                                when too_many_rows then l_no_of_records := 1;
                                when no_data_found then
                                    l_error_code := -1;
                                    process_errorred_field('WSM',
                                                           'WSM_ASSEMBLY_NO_LOT',
                                                           l_stmt_num);
                            end;

                            if l_no_of_records <> 0 then
                                begin
                                    l_no_of_records := 0;
                                    select  1
                                    into    l_no_of_records
                                    from    mtl_system_items_kfv msi
                                    where   msi.inventory_item_id = v_wlji_item(v_index)
                                    and     msi.organization_id = v_wlji_org(v_index)
                                    and     msi.serial_number_control_code = 1;
                                exception
                                    when too_many_rows then l_no_of_records := 1;
                                    when no_data_found then
                                        l_error_code := -1;
                                        process_errorred_field('WSM',
                                                               'WSM_ASSEMBLY_NOT_SERIAL',
                                                               l_stmt_num);
                                end;
                            end if;

                        end if; -- xst = false

                        if xst = false AND l_no_of_records <> 0 then
                            if v_wlji_mode_flag(v_index) = 2 then
                                WSMPLCVA.v_mode2_item(hash_value).INVENTORY_ITEM_ID :=
                                    v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id;
                                WSMPLCVA.v_mode2_item(hash_value).PRIMARY_ITEM_ID :=
                                    v_wlji_item(v_index);
                            else -- mode flag = 1
                                WSMPLCVA.v_item(v_wlji_item(v_index)) := v_wlji_item(v_index);
                            end if;
                        end if;

                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;
                        l_no_of_records := 0;
                        l_dummy := 0;
                        l_aux_mesg := '';
                        xst := true;
                        str := '';
                        hash_value := 0;

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Validation of Item.. Success');
                        end if;

                    end if; -- load type 5
                    -- *** validate mode one item id end ***


l_stmt_num := 280;
                    -- *** validate dates begin ***
                    if v_wlji_load_type(v_index) = 5 then

                        IF v_wlji_fusd(v_index) IS NOT NULL AND
                           v_wlji_lucd(v_index) IS NOT NULL THEN

                            IF  v_wlji_fusd(v_index) > v_wlji_lucd(v_index) THEN
                                process_errorred_field('WSM',
                                                       'WSM_FUSD_GT_LUCD',
                                                       l_stmt_num);
                                l_error_code := -1;
                                GOTO skip_date_validation;
                            END IF;
                        ELSIF v_wlji_fusd(v_index) IS NULL AND
                              v_wlji_lucd(v_index) IS NULL THEN
                            process_errorred_field('WSM',
                                                   'WSM_DATES_NULL',
                                                   l_stmt_num);
                            l_error_code := -1;
                            GOTO skip_date_validation;
                        END IF;

                        IF v_wlji_fusd(v_index) IS NOT NULL AND
                           v_wlji_lucd(v_index) IS NULL THEN
                            v_wlji_lucd(v_index) := wsmputil.GET_SCHEDULED_DATE (
                                       v_wlji_org(v_index),
                                       v_wlji_item(v_index),
                                       'F',
                                       v_wlji_fusd(v_index),
                                       --v_wlji_start_quantity(v_index),
                                       l_error_code,
                                       l_err_msg,
                                       v_wlji_start_quantity(v_index));     --Fixed bug # 2313574

                            if lbji_debug = 'Y' then
                                fnd_file.put_line(fnd_file.log, 'Getting complete date based on item lead time');
                            end if;

                        END IF ;


                        IF v_wlji_fusd(v_index) IS NULL AND
                           v_wlji_lucd(v_index) IS NOT NULL THEN
                            v_wlji_fusd(v_index) := wsmputil.GET_SCHEDULED_DATE (
                                       v_wlji_org(v_index),
                                       v_wlji_item(v_index),
                                       'B',
                                       v_wlji_lucd(v_index),
                                       --v_wlji_start_quantity(v_index),
                                       l_error_code,
                                       l_err_msg,
                                       v_wlji_start_quantity(v_index));     --Fixed bug # 2313574

                            if lbji_debug = 'Y' then
                                fnd_file.put_line(fnd_file.log, 'Getting start date based on item lead time');
                            end if;
                        END IF;

                        if l_error_code <> 0 OR l_err_msg IS NOT NULL then
                            HANDLE_ERROR( l_error_code, l_err_msg, l_stmt_num);
                            l_error_code := -1;
                        end if;

<< skip_date_validation >>

                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;
                        l_err_msg := '';

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Date Validation.. Success.');
                        end if;

                    end if; -- load type 5
                    -- *** validate dates end ***


l_stmt_num := 300;
                    -- *** validate net quantity begin ***
                    if v_wlji_load_type(v_index) = 5 and v_wlji_job_type(v_index) <> 3 then

                        if (v_wlji_net_quantity(v_index) < 0) then
                            l_aux_mesg := 'Net Quantity should be > 0';
                            process_invalid_field('NET QUANTITY',
                                                  l_aux_mesg,
                                                  l_stmt_num);
                            l_error_code := -1;
                        end if;

                        if (v_wlji_net_quantity(v_index) IS NULL) then
                            v_wlji_net_quantity(v_index) :=  v_wlji_start_quantity(v_index);
                        end if;

                        if v_wlji_net_quantity(v_index) > v_wlji_start_quantity(v_index) then
                            l_aux_mesg := 'Net Quantity should be <= start quantity';
                            process_invalid_field('NET QUANTITY',
                                                  l_aux_mesg,
                                                  l_stmt_num);
                            l_error_code := -1;
                        end if;
                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;
                        l_aux_mesg := '';

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Net Quantity Validation.. Success.');
                        end if;

                    end if; -- load type 5
                    -- *** validate net quantity end ***


                    l_stmt_num := 320;
                    -- *** validate coproduct-supply flag begin ***
                    if v_wlji_load_type(v_index) = 5 then

                        IF v_wlji_coproducts_supply(v_index) is NULL THEN
                            v_wlji_coproducts_supply(v_index) :=
                                    WSMPLCVA.v_org(v_wlji_org(v_index)).COPRODUCTS_SUPPLY_DEFAULT;
                        ELSIF ( v_wlji_coproducts_supply(v_index) <> 1
                            OR  v_wlji_coproducts_supply(v_index) <> 2)  THEN
                            v_wlji_coproducts_supply(v_index) := 2;
                        END IF;

                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Co Product Supply Flag Validation.. Success.');
                        end if;

                    end if; -- load type 5
                    -- *** validate coproduct-supply flag end ***


l_stmt_num := 340;
                    -- *** get routing_seq_id begin ***
                    if v_wlji_load_type(v_index) = 5 and v_wlji_job_type(v_index) <> 3 then

                        begin
                        -- bugfix 2681637 validation of alternate designator should check disable_date. (original bug for form 2558447)
                        -- view bom_routing_alternates_v does not have designator disable_date infor.

                           select bor.routing_sequence_id,
                                  bor.COMPLETION_SUBINVENTORY,
                                  bor.COMPLETION_LOCATOR_ID
                           into   routing_seq_id,
                                  l_default_subinventory,
                                  l_default_compl_loc_id
                           --from bom_routing_alternates_v bor
                           from   bom_operational_routings bor,
                                  bom_alternate_designators bad
                           where  ((bor.alternate_routing_designator is null and
                                    bad.alternate_designator_code is null
                                    and bad.organization_id = -1)
                                   or (bor.alternate_routing_designator = bad.alternate_designator_code
                                       and bor.organization_id = bad.organization_id))
                           and    bor.organization_id = v_wlji_org(v_index)
                           and    bor.assembly_item_id = v_wlji_item(v_index)
                           and    NVL(bor.alternate_routing_designator, '&*') = NVL(v_wlji_alt_routing_designator(v_index), '&*')
                           and    bor.routing_type = 1
                           and    bor.cfm_routing_flag = 3;
                           --Bug 5107339: Disable_date validation is not applicable here.
                           --and    trunc(nvl(bad.disable_date, sysdate + 1)) > trunc(sysdate);

                        exception
                            when no_data_found then
                                l_aux_mesg := '';
                                process_invalid_field('ALTERNATE ROUTING DESIGNATOR',
                                                      l_aux_mesg,
                                                      l_stmt_num);
                                l_error_code := -1;
                        end;

                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Getting Routing Sequence Id: '||routing_seq_id);
                        end if;

                        IF v_wlji_completion_subinventory(v_index) IS NULL AND
                           v_wlji_completion_locator_id(v_index) IS NULL THEN
                            v_wlji_completion_subinventory(v_index) := l_default_subinventory;
                            v_wlji_completion_locator_id(v_index) := l_default_compl_loc_id;
                        END IF;

                        IF v_wlji_completion_subinventory(v_index) IS NULL AND
                           v_wlji_completion_locator_id(v_index) IS NOT NULL THEN
                            v_wlji_completion_subinventory(v_index) := l_default_subinventory;
                        END IF;

                        IF v_wlji_completion_subinventory(v_index) IS NOT NULL AND
                           v_wlji_completion_locator_id(v_index) IS NULL THEN

                        -- do the subinventory validation here...
                        -- validation of subinv begin
                            str := to_char(v_wlji_org(v_index))||v_wlji_completion_subinventory(v_index);
                            hash_value := dbms_utility.get_hash_value(str, 37, 1073741824);
                            if WSMPLCVA.v_subinv.exists(hash_value) then
                                NULL;
                            else
                                l_aux_mesg := '';
                                process_invalid_field('COMPLETION SUBINVENTORY',
                                                      l_aux_mesg,
                                                      l_stmt_num);
                                l_error_code := -1;
                            end if;

                            if l_error_code <> 0 then
                                l_error_count := l_error_count + 1;
                                GOTO skip_other_steps;
                            end if;

                            l_aux_mesg := '';
                            str := '';
                            hash_value := 0;

                            -- validation of subinv end

                            select locator_type
                            into   mtl_locator_type
                            from   mtl_secondary_inventories
                            where  secondary_inventory_name = v_wlji_completion_subinventory(v_index)
                            and    organization_id = v_wlji_org(v_index);

                            if v_wlji_completion_subinventory(v_index) = l_default_subinventory then
                                v_wlji_completion_locator_id(v_index) := l_default_compl_loc_id;
                            else
                                if mtl_locator_type = 2 then
                                    l_aux_mesg := '';
                                    process_invalid_field('COMPLETION SUBINVENTORY',
                                                          l_aux_mesg,
                                                          l_stmt_num);
                                    l_error_code := -1;
                                    l_error_count := l_error_count + 1;
                                    GOTO skip_other_steps;
                                else
                                    NULL;
                                end if;
                            end if;
                        END IF;

                        l_aux_mesg := '';
                    end if; -- load type 5
                    -- *** get routing_seq_id end ***


                    l_stmt_num := 360;
                    -- *** get bill_seq_id begin ***
                    --if the alternate_bom_designator has NULL in wlji, bill_seq_id can have either a
                    --NULL or a primary bom value. But if the designator has ALT, then there must be a
                    --bill id for the alternate bom.

                    if v_wlji_load_type(v_index) = 5  and v_wlji_job_type(v_index) <> 3 then

                        IF v_wlji_alt_bom_designator(v_index) is NULL THEN
                            begin
                                SELECT  bom.common_bill_sequence_id
                                INTO    bom_seq_id
                                FROM    bom_bill_of_materials bom
                                WHERE   bom.alternate_bom_designator is NULL
                                AND     BOM.assembly_item_id = v_wlji_item(v_index)
                                AND     bom.organization_id = v_wlji_org(v_index);
                            exception
                                WHEN NO_DATA_FOUND THEN
                                    NULL;
                            end;
                        ELSE
                            begin
                                -- bugfix 2681637 validation of alternate designator should check disable_date.
                                -- (original bug for form 2558447)
                                -- table bom_bill_of_materials does not have designator disable_date infor.

                                SELECT  bom.common_bill_sequence_id
                                INTO    bom_seq_id
                                FROM    bom_bill_of_materials bom,
                                        bom_alternate_designators bad
                                WHERE   ((bom.alternate_bom_designator is null and
                                          bad.alternate_designator_code is null
                                          and bad.organization_id = -1)
                                         OR (bom.alternate_bom_designator = bad.alternate_designator_code
                                             and bom.organization_id = bad.organization_id))
                                AND     bom.alternate_bom_designator = v_wlji_alt_bom_designator(v_index)
                                AND     BOM.assembly_item_id = v_wlji_item(v_index)
                                AND     bom.organization_id = v_wlji_org(v_index);
                                --Bug 5107339: Disable_date validation is not applicable here.
                                --AND     trunc(nvl(bad.disable_date, sysdate + 1)) > trunc(sysdate);

                            exception
                                WHEN no_data_found  THEN
                                    l_aux_mesg := '';
                                    process_invalid_field('ALTERNATE BOM DESIGNATOR',
                                                          l_aux_mesg,
                                                          l_stmt_num);
                                    l_error_code := -1;
                            end;
                        END IF;

                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;
                        l_aux_mesg := '';

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Getting Bill Sequence Id: '||bom_seq_id);
                        end if;

                    end if; -- load type 5
                    -- *** get bill_seq_id end ***


l_stmt_num := 400;
                    -- *** validate locator id begin ***
                    if v_wlji_load_type(v_index) = 5 and v_wlji_job_type(v_index) <> 3 then

                        SELECT  nvl(msub.locator_type, 1) sub_loc_control,
                                MP.stock_locator_control_code org_loc_control,
                                MS.restrict_locators_code,
                                MS.location_control_code item_loc_control
                        into    l_sub_loc_control, l_org_loc_control,
                                l_restrict_locators_code, l_item_loc_control
                        FROM    mtl_system_items MS,
                                mtl_secondary_inventories MSUB,
                                mtl_parameters MP
                        WHERE   MP.organization_id = v_wlji_org(v_index)
                        AND     MS.organization_id = v_wlji_org(v_index)
                        AND     MS.inventory_item_id = v_wlji_item(v_index)
                        AND     MSUB.secondary_inventory_name = v_wlji_completion_subinventory(v_index)
                        AND     MSUB.organization_id = v_wlji_org(v_index);

                        l_locator_id := v_wlji_completion_locator_id(v_index) ;

                        WIP_LOCATOR.validate(
                                            v_wlji_org(v_index),
                                            v_wlji_item(v_index),
                                            v_wlji_completion_subinventory(v_index),
                                            l_org_loc_control,
                                            l_sub_loc_control,
                                            l_item_loc_control,
                                            l_restrict_locators_code,
                                            NULL, NULL, NULL, NULL,
                                            l_locator_id,
                                            l_segs,
                                            l_loc_success);

                        IF not l_loc_success THEN
                            l_aux_mesg := '';
                            process_invalid_field('COMPLETION SUBINVENTORY',
                                                  l_aux_mesg,
                                                  l_stmt_num);
                            l_error_code := -1;
                        end if;

                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;
                        l_aux_mesg := '';
                        l_locator_id := 0;

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Locator Id Validation.. Success.');
                        end if;

                    end if; -- load type 5
                    -- *** validate locator id end ***


l_stmt_num := 420;
                    -- *** validate last_updt_by begin ***
                    if v_wlji_load_type(v_index) = 5 then

                        if v_wlji_last_updt_by(v_index) is NULL then
                            v_wlji_last_updt_by(v_index) := l_user;
                        else
                            xst :=  WSMPLCVA.v_user.exists(v_wlji_last_updt_by(v_index));
                            if xst = false then
                                begin
                                    select 1
                                    into   l_no_of_records
                                    from   fnd_user
                                    where  user_id = v_wlji_last_updt_by(v_index)
                                    and    sysdate between start_date and nvl(end_date,sysdate+1);
                                exception
                                    when too_many_rows then l_no_of_records := 1;
                                    when no_data_found then
                                        l_error_code := -1;
                                        l_aux_mesg := '';
                                        process_invalid_field( 'Last Updated By',
                                                               l_aux_mesg,
                                                               l_stmt_num);
                                end;
                            end if;

                            if xst = false AND l_no_of_records <> 0 then
                                WSMPLCVA.v_user(v_wlji_last_updt_by(v_index)) := v_wlji_last_updt_by(v_index);
                            end if;


                            if l_error_code <> 0 then
                                l_error_count := l_error_count + 1;
                                GOTO skip_other_steps;
                            end if;
                            l_aux_mesg := '';
                            l_no_of_records := 0;
                            xst := true;
                        end if;

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Last Updt By Validation.. Success.');
                        end if;

                    end if; -- load type 5
                    -- *** validate last_updt_by end ***


l_stmt_num := 440;
                    -- *** validate created_by begin ***
                    if v_wlji_load_type(v_index) = 5 then

                        if v_wlji_created_by(v_index) is NULL then
                            v_wlji_created_by(v_index) := l_user;
                        else
                            xst :=  WSMPLCVA.v_user.exists(v_wlji_created_by(v_index));
                            if xst = false then
                                begin
                                    select 1
                                    into   l_no_of_records
                                    from   fnd_user
                                    where  user_id = v_wlji_created_by(v_index)
                                    and    sysdate between start_date and nvl(end_date,sysdate+1);
                                exception
                                    when too_many_rows then l_no_of_records := 1;
                                    when no_data_found then
                                        l_error_code := -1;
                                        l_aux_mesg := '';
                                        process_invalid_field( 'Created By', l_aux_mesg, 'l_stmt_num.vldt_created_by');
                                end;
                            end if;

                            if xst = false AND l_no_of_records <> 0 then
                                WSMPLCVA.v_user(v_wlji_created_by(v_index)) := v_wlji_created_by(v_index);
                            end if;

                            if l_error_code <> 0 then
                                l_error_count := l_error_count + 1;
                                GOTO skip_other_steps;
                            end if;
                            l_aux_mesg := '';
                            l_no_of_records := 0;
                            xst := true;
                        end if;

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Created By Validation.. Success.');
                        end if;

                    end if; -- load type 5
                    -- *** validate created_by end ***


l_stmt_num := 460;
                    -- *** validate job name and id begin ***
                    if LENGTH(v_wlji_job_name(v_index)) > 80 then       -- Changed for OPM Convergence project
                        process_errorred_field('WSM',
                                               'WSM_JOB_NAME_EIGHTY_CHAR',
                                               l_stmt_num);
                        l_error_code := -1;
                        GOTO skip_job_id_valid;
                    end if;

                    l_return_value := 0;

l_stmt_num := 460.1;
                    /*Bug 3414163:Call to Check_wmti is commented.*/
                    /*
                    l_return_value := wsmputil.CHECK_WMTI(   -- CZH.I
                            P_WIP_ENTITY_ID => null,
                            P_WIP_ENTITY_NAME => v_wlji_job_name(v_index),
                            P_TRANSACTION_DATE => null,
                            X_ERR_CODE => l_error_code,
                            X_ERR_MSG => l_err_msg,
                            P_ORGANIZATION_ID => v_wlji_org(v_index)
                            );
                    IF (l_return_value > 0 OR l_return_value <> 0) THEN
                        process_errorred_field('WSM',
                                               'WSM_PENDING_MOVE_TXNS',
                                               l_stmt_num);
                        l_error_code := -1;
                        GOTO skip_job_id_valid;
                    END IF;
                    */
                    /*Bug 3414163:End of changes*/
l_stmt_num := 460.2;
                    -- bug 3453139 remove this
                    --l_return_value := wsmputil.CHECK_WSMT(   -- CZH.I
                    --        P_WIP_ENTITY_ID => null,
                    --        P_WIP_ENTITY_NAME => v_wlji_job_name(v_index),
                    --        P_TRANSACTION_ID => NULL,
                    --        P_TRANSACTION_DATE => null,
                    --        X_ERR_CODE => l_error_code,
                    --        X_ERR_MSG => l_err_msg,
                    --        P_ORGANIZATION_ID => v_wlji_org(v_index)
                    --        );

                    --IF (l_return_value > 0 OR l_return_value <> 0) THEN
                    --    FND_MESSAGE.SET_NAME('WSM', 'WSM_PENDING_TXN');
                    --    FND_MESSAGE.SET_TOKEN('TABLE', 'wsm_split_merge_transactions');
                    --    l_err_msg := fnd_message.get;
                    --    l_error_code := -1;
                    --    HANDLE_ERROR( l_error_code, l_err_msg, l_stmt_num);
                    --    l_error_code := -1;
                    --    GOTO skip_job_id_valid;
                    --ELSE
                    --    l_error_code := 0;
                    --    l_err_msg := '';
                    --END IF;



                    Begin
                        l_dummy := 0;
                        if v_wlji_load_type(v_index) = 5 then

                            if (v_wlji_job_name(v_index) is null) then

                                -- Derive JOB_NAME.
                                select FND_Profile.value('WIP_JOB_PREFIX') || wip_job_number_s.nextval
                                into   v_wlji_job_name(v_index)
                                from   dual ;

                            else

                                -- Be sure the provided JOB_NAME is not already in use.
                                begin

                                    select 1 into l_dummy
                                    from   wip_entities
                                    where
                                        wip_entity_name = v_wlji_job_name(v_index) and
                                        organization_id = v_wlji_org(v_index);

                                    if l_dummy = 1 then
                                        process_errorred_field('WIP',
                                                               'WIP_ML_JOB_NAME',
                                                               l_stmt_num);
                                        l_error_code := -1;
                                        GOTO skip_job_id_valid;
                                    end if;

                                exception

                                    -- This Exception added by BBK .
                                    when no_data_found then
                                            null;

                                    when others then
                                            process_errorred_field('WIP',
                                                                   'WIP_ML_JOB_NAME',
                                                                   l_stmt_num);
                                            l_error_code := -1;
                                            GOTO skip_job_id_valid;
                                end ;

                            end if ;

                        elsif v_wlji_load_type(v_index) = 6 then

                            if (v_wlji_wip_entity_id(v_index) is null) then

                                if (v_wlji_job_name(v_index) is null) then
                                    raise invalid_job_name_error;
                                end if ;

                                begin
                                    select wip_entity_id
                                    into   v_wlji_wip_entity_id(v_index)
                                    from   wip_entities
                                    where
                                        wip_entity_name = v_wlji_job_name(v_index) and
                                        organization_id = v_wlji_org(v_index) ;
                                exception when others then
                                    raise invalid_job_name_error;
                                end ;

                            else
                                begin

                                    /* commented out by BBK as per Hari to remove dual usage.
                                    select 1 into l_dummy from dual where exists (
                                        select 1
                                        from   wip_discrete_jobs
                                        where
                                            wip_entity_id = v_wlji_wip_entity_id(v_index) and
                                            organization_id = v_wlji_org(v_index) and
                                            status_type in (
                                                WIP_CONSTANTS.UNRELEASED,
                                                WIP_CONSTANTS.RELEASED,
                                                WIP_CONSTANTS.HOLD,
                                                WIP_CONSTANTS.CANCELLED)
                                        );
                                    */
                                    -- added by BBK.
                                    select 1 into l_dummy
                                    from   wip_discrete_jobs
                                    where
                                        wip_entity_id = v_wlji_wip_entity_id(v_index) and
                                        status_type in (
                                            WIP_CONSTANTS.UNRELEASED,
                                            WIP_CONSTANTS.RELEASED,
                                            WIP_CONSTANTS.HOLD,
                                            WIP_CONSTANTS.CANCELLED) ;
                                exception
                                    -- This Exception added by BBK .
                                    when no_data_found then
                                        raise invalid_id_error;
                                    when others then
                                        raise invalid_id_error;
                                end ;

                            end if ;
                        end if;

                    Exception
                        when invalid_id_error then
                            l_aux_mesg := '';
                            process_invalid_field('WIP_ENTITY_ID',
                                                  l_aux_mesg,
                                                  l_stmt_num);
                            l_error_code := -1;

                        when invalid_job_name_error then
                            l_aux_mesg := '';
                            process_invalid_field('JOB_NAME',
                                                  l_aux_mesg,
                                                  l_stmt_num);
                            l_error_code := -1;

                    End;

<< skip_job_id_valid >>

                    if l_error_code <> 0 then
                        l_error_count := l_error_count + 1;
                        GOTO skip_other_steps;
                    end if;
                    l_aux_mesg := '';

                    if lbji_debug = 'Y' then
                        fnd_file.put_line(fnd_file.log, 'Job Name and Id Validation.. Success.');
                    end if;

                    l_dummy := 0;
                    -- *** validate job name and id end ***


l_stmt_num := 480;
                    -- *** validate class code begin ***
                    if v_wlji_load_type(v_index) = 5 and v_wlji_job_type(v_index) <> 3 then
                        begin

                            IF v_wlji_class_code(v_index) is NULL then

                                begin
                                    select wse.DEFAULT_ACCT_CLASS_CODE
                                    into   v_wlji_class_code(v_index)
                                    from   wsm_sector_extensions wse, wsm_item_extensions wie
                                    where  wie.INVENTORY_ITEM_ID = v_wlji_item(v_index)
                                    and    wie.ORGANIZATION_ID = v_wlji_org(v_index)
                                    and    wie.SECTOR_EXTENSION_ID = wse.SECTOR_EXTENSION_ID
                                    and    wie.ORGANIZATION_ID = wse.ORGANIZATION_ID;
                                exception
                                    WHEN NO_DATA_FOUND THEN
                                        v_wlji_class_code(v_index) := NULL;
                                end;

                                IF v_wlji_class_code(v_index) is NULL then

                                    begin

                                        select wse.DEFAULT_ACCT_CLASS_CODE
                                        into   v_wlji_class_code(v_index)
                                        from   wsm_sector_extensions wse, wsm_subinventory_extensions wve
                                        where  wve.SECONDARY_INVENTORY_NAME = v_wlji_completion_subinventory(v_index)
                                        and    wve.ORGANIZATION_ID = v_wlji_org(v_index)
                                        and    wve.SECTOR_EXTENSION_ID = wse.SECTOR_EXTENSION_ID
                                        and     wve.ORGANIZATION_ID = wse.ORGANIZATION_ID;
                                    exception
                                        WHEN NO_DATA_FOUND THEN
                                            v_wlji_class_code(v_index) := NULL;
                                    end;

                                    IF v_wlji_class_code(v_index) is NULL then
                                        v_wlji_class_code(v_index) := WSMPLCVA.v_org(v_wlji_org(v_index)).DEFAULT_ACCT_CLASS_CODE;
                                    END IF;

                                END IF;

                                IF v_wlji_class_code(v_index) IS NULL THEN
                                    raise no_data_found;
                                END IF;

                            ELSE
                                str := to_char(v_wlji_org(v_index))||v_wlji_class_code(v_index);
                                hash_value := dbms_utility.get_hash_value(str, 37, 1073741824);
                                if WSMPLCVA.v_class_code.exists(hash_value) then
                                    NULL;
                                else
                                    raise no_data_found;
                                end if;
                            END IF;

                        exception
                            WHEN no_data_found  THEN
                                l_aux_mesg := 'Or class code maybe NULL';
                                process_invalid_field('CLASS_CODE',
                                                      l_aux_mesg,
                                                      l_stmt_num);
                                l_error_code := -1;
                        end;


                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;
                        l_aux_mesg := '';
                        str := '';
                        hash_value := 0;

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Class Code Validation.. Success.');
                        end if;

                    end if; -- load type 5
                    -- *** validate class code end ***


l_stmt_num := 500;
                    -- *** default lot_number begin ***
                    if v_wlji_load_type(v_index) = 5 then
                        v_wlji_lot_number(v_index) := v_wlji_job_name(v_index);

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Lot Number Defaulted.. Success.');
                        end if;
                    end if; -- load type 5
                    -- *** default lot_number end ***


l_stmt_num := 520;
                    -- *** get revisions begin ***
                    -- this procedure is called only after date validation so that the start date is not null.
                    -- this is to be called only for job creation.

                    -- CZH.I_OED-1: if we are creating a job (load_type = 5), wip_revisions.routing_revision
                    -- is called, hence, v_wlji_routing_revision_date(v_index) will be populated

                    if v_wlji_load_type(v_index) = 5 and v_wlji_job_type(v_index) <> 3 then

                        if v_wlji_fusd(v_index) > SYSDATE then
                            l_rev_date := v_wlji_fusd(v_index);
                        else
                            l_rev_date := SYSDATE;
                        end if;

                        wip_revisions.bom_revision (v_wlji_org(v_index),
                                                    v_wlji_item(v_index),
                                                    v_wlji_bom_revision(v_index),
                                                    v_wlji_bom_revision_date(v_index),
                                                    l_rev_date);


                        wip_revisions.routing_revision (v_wlji_org(v_index),
                                                        v_wlji_item(v_index),
                                                        v_wlji_routing_revision(v_index),
                                                        v_wlji_routing_revision_date(v_index),
                                                        l_rev_date);

                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Getting Revisions.. Success.');
                        end if;

                    end if; -- load type 5
                    -- *** get revisions end ***


l_stmt_num := 540;
                    -- *** default description begin ***
                    -- this is to be called only for job creation.
                    if v_wlji_load_type(v_index) = 5 then
                        if RTRIM(v_wlji_description(v_index)) is NULL then
                            l_date_text := fnd_date.date_to_charDT(sysdate) ;
                            fnd_message.set_name('WIP','WIP_MLD_DESC');
                            fnd_message.set_token('LOAD_DATE', l_date_text, false) ;
                            v_wlji_description(v_index) := FND_Message.get;
                        else
                            v_wlji_description(v_index) := RTRIM(v_wlji_description(v_index));
                        end if;

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Default Description.. Success.');
                        end if;
                    end if; -- load type 5
                    -- *** default description end ***



                    if v_wlji_load_type(v_index) = 5 then

l_stmt_num := 560;
                        -- *** validations for the starting lot in wsli. These validations are ***
                        -- *** to be performed only for jobs of mode flag 2.                   ***

                        if v_wlji_mode_flag(v_index) = 2 then
                        -- *** validation of starting lot begin ***
l_stmt_num := 600;
                            -- BA: bug 3299026 do not allow serial controlled component
                            select  SERIAL_NUMBER_CONTROL_CODE,
                                    revision_qty_control_code       -- Add bug 2963225
                            into    l_dummy,
                                    l_rev_control_code              -- Add bug 2963225
                            from    mtl_system_items_kfv msi
                            where   msi.inventory_item_id = v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id
                            and     msi.organization_id = v_wlji_org(v_index);

                            if(l_dummy <> 1) then
                                l_error_code := -1;
                                process_errorred_field('WSM',
                                                       'WSM_SERIAL_COMP_NOT_SUPPORTED',
                                                       l_stmt_num);
                                l_error_count := l_error_count + 1;
                                GOTO skip_other_steps;
                            end if;
                            --EA bug 3299026

                            -- *** last_updated_by ***
l_stmt_num := 601;
                            xst :=  WSMPLCVA.v_user.exists(v_wsli(v_wlji_source_line_id(v_index)).last_updated_by);
                            if xst = false then
                                begin
                                    select 1
                                    into   l_no_of_records
                                    from   fnd_user
                                    where  user_id = v_wsli(v_wlji_source_line_id(v_index)).last_updated_by
                                    and    sysdate between start_date and nvl(end_date,sysdate+1);
                                exception
                                    when too_many_rows then l_no_of_records := 1;
                                    when no_data_found then
                                        l_error_code := -1;
                                        l_aux_mesg := '';
                                        process_invalid_field( 'Last Updated By in WSM_STARTING_LOTS_INTERFACE',
                                                                l_aux_mesg,
                                                                l_stmt_num);
                                end;
                            end if;

                            if xst = false AND l_no_of_records <> 0 then
                                WSMPLCVA.v_user(v_wsli(v_wlji_source_line_id(v_index)).last_updated_by)
                                    := v_wsli(v_wlji_source_line_id(v_index)).last_updated_by;
                            end if;

                            if l_error_code <> 0 then
                                l_error_count := l_error_count + 1;
                                GOTO skip_other_steps;
                            end if;
                            l_aux_mesg := '';
                            l_no_of_records := 0;
                            xst := true;

                            -- *** created_by ***
l_stmt_num := 602;
                            xst :=  WSMPLCVA.v_user.exists(v_wsli(v_wlji_source_line_id(v_index)).created_by);
                            if xst = false then
                                begin
                                    select 1
                                    into   l_no_of_records
                                    from   fnd_user
                                    where  user_id = v_wsli(v_wlji_source_line_id(v_index)).created_by
                                    and    sysdate between start_date and nvl(end_date,sysdate+1);
                                exception
                                    when too_many_rows then l_no_of_records := 1;
                                    when no_data_found then
                                        l_error_code := -1;
                                        l_aux_mesg := '';
                                        process_invalid_field( 'CREATED BY in WSM_STARTING_LOTS_INTERFACE',
                                                                l_aux_mesg,
                                                                l_stmt_num);
                                end;
                            end if;

                            if xst = false AND l_no_of_records <> 0 then
                                WSMPLCVA.v_user(v_wsli(v_wlji_source_line_id(v_index)).created_by)
                                            := v_wsli(v_wlji_source_line_id(v_index)).created_by;
                            end if;

                            if l_error_code <> 0 then
                                l_error_count := l_error_count + 1;
                                GOTO skip_other_steps;
                            end if;
                            l_aux_mesg := '';
                            l_no_of_records := 0;
                            xst := true;
                            -- *** created_by ***


l_stmt_num := 603;
                            begin

                                select 1 into l_dummy
                                from   mtl_transaction_lots_temp
                                where  lot_number = v_wsli(v_wlji_source_line_id(v_index)).lot_number
                                and    rownum = 1;

                                if l_dummy <>0 then
                                    SELECT 0 into l_dummy
                                    FROM   mtl_material_transactions_temp mmtt
                                    WHERE  mmtt.organization_id = v_wsli(v_wlji_source_line_id(v_index)).organization_id
                                    and    mmtt.inventory_item_id = v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id
                                    and    NVL(mmtt.lot_number, '@#$') = v_wsli(v_wlji_source_line_id(v_index)).lot_number
                                    and    mmtt.subinventory_code = v_wsli(v_wlji_source_line_id(v_index)).subinventory_code
                                    and    NVL(mmtt.locator_id, -9999) = NVL(v_wsli(v_wlji_source_line_id(v_index)).locator_id, -9999)
                                    and    mmtt.transaction_type_id = 42 -- Miscellaneous Receipt
                                    and    mmtt.transaction_action_id = 27 -- Receipt into stores
                                    and    mmtt.transaction_source_type_id = 13 -- Inventory
                                    and    v_wsli(v_wlji_source_line_id(v_index)).quantity = ((-1) * mmtt.transaction_quantity)
                                    and    mmtt.transaction_date = (
                                            SELECT max(mmtt2.transaction_date)
                                            FROM mtl_material_transactions_temp mmtt2
                                            WHERE mmtt2.organization_id = v_wsli(v_wlji_source_line_id(v_index)).organization_id
                                            and mmtt2.inventory_item_id = v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id
                                            and NVL(mmtt2.lot_number, '@#$') = NVL(v_wsli(v_wlji_source_line_id(v_index)).lot_number, '@#$')
                                            and mmtt2.subinventory_code = v_wsli(v_wlji_source_line_id(v_index)).subinventory_code
                                            and NVL(mmtt2.locator_id, -9999) = NVL(v_wsli(v_wlji_source_line_id(v_index)).locator_id, -9999)
                                        );
                                end if;
                                If l_dummy <> 0 then
                                    fnd_message.set_name('WSM', 'WSM_PENDING_TXN');
                                    FND_MESSAGE.SET_TOKEN('TABLE',
                                       'Starting Lot:'||v_wsli(v_wlji_source_line_id(v_index)).lot_number
                                       ||'Table: mtl_transaction_lots_temp ');
                                    l_err_msg := fnd_message.get;
                                    l_error_code := -1;
                                    HANDLE_ERROR( l_error_code, l_err_msg, l_stmt_num);
                                END IF;

                            exception
                                When NO_DATA_FOUND Then
                                    Null;
                            end;

                            if l_error_code <> 0 then
                                l_error_count := l_error_count + 1;
                                GOTO skip_other_steps;
                            end if;
                            l_err_msg := '';
                            l_dummy := 0;


l_stmt_num := 604;
                            -- check that the item in the inventory lot exists as a component of the
                            -- assembly item for the given alt bom designator, attached at the first operation.

                            wsmputil.find_common_routing(
                                            p_routing_sequence_id => routing_seq_id,
                                            p_common_routing_sequence_id => p_common_routing_sequence_id,
                                            x_err_code => l_error_code,
                                            x_err_msg => l_err_msg);

                            if l_error_code <> 0 OR l_err_msg IS NOT NULL then
                                HANDLE_ERROR( l_error_code, l_err_msg, l_stmt_num);
                                l_error_code := -1;
                            end if;


l_stmt_num := 604.1;
                            -- BA: CZH.I_OED-1
                            -- This is for Mode 2 job creation. Hence, v_wlji_routing_revision_date(v_index)
                            -- should have been populated
                            l_rtg_rev_date := v_wlji_routing_revision_date(v_index);
                            l_bom_rev_date := v_wlji_bom_revision_date(v_index); --BUGFIX 2380517
                            -- EA: CZH.I_OED-1

                            wsmputil.find_routing_start(
                                            p_common_routing_sequence_id,
                                            l_rtg_rev_date,              -- ADD: CZH.I_OED-1
                                            l_start_op_seq_id,
                                            l_error_code,
                                            l_err_msg );

                            if l_error_code <> 0 OR l_err_msg IS NOT NULL then
                                HANDLE_ERROR( l_error_code, l_err_msg, l_stmt_num);
                                l_error_code := -1;
                            end if;

                            --BA: CZH.I_OED-2
                            l_start_op_seq_id := wsmputil.replacement_op_seq_id(
                                                            l_start_op_seq_id,
                                                            l_rtg_rev_date);
                            --EA: CZH.I_OED-2

                            if l_error_code = 0 then
                                begin
                                    SELECT  1
                                    INTO    l_dummy
                                    FROM    BOM_INVENTORY_COMPONENTS BIC,
                                            MTL_SYSTEM_ITEMS C
                                    WHERE   BIC.COMPONENT_ITEM_ID = C.INVENTORY_ITEM_ID
                                    AND     C.ORGANIZATION_ID = v_wlji_org(v_index)
                                    AND     BIC.BILL_SEQUENCE_ID = bom_seq_id
                                    AND     BIC.COMPONENT_ITEM_ID = v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id
                                    AND     (BIC.operation_seq_num = (SELECT BOS.operation_seq_num
                                                                      FROM   BOM_OPERATION_SEQUENCES BOS
                                                                      WHERE  operation_sequence_id = l_start_op_seq_id )
                                             OR
                                             BIC.operation_seq_num = 1)
                                    -- BC: BUGFIX 2380517 (CZH.I_OED-2)
                                    --AND   EFFECTIVITY_DATE <= SYSDATE
                                    --AND   nvl(DISABLE_DATE, SYSDATE + 1) > SYSDATE
                                    AND     l_bom_rev_date between BIC.EFFECTIVITY_DATE
                                                           and     nvl(BIC.DISABLE_DATE, l_bom_rev_date + 1)
                                    -- EC: BUGFIX 2380517
                                    AND     EFFECTIVITY_DATE =(
                                                SELECT  MAX (EFFECTIVITY_DATE)
                                                FROM    BOM_INVENTORY_COMPONENTS BIC2,
                                                        ENG_REVISED_ITEMS        ERI
                                                WHERE   BIC2.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
                                                AND     BIC2.COMPONENT_ITEM_ID = BIC.COMPONENT_ITEM_ID
                                                AND     (decode(BIC2.IMPLEMENTATION_DATE,
                                                                NULL, BIC2.OLD_COMPONENT_SEQUENCE_ID,
                                                                BIC2.COMPONENT_SEQUENCE_ID) =
                                                         decode(BIC.IMPLEMENTATION_DATE,
                                                                NULL, BIC.OLD_COMPONENT_SEQUENCE_ID,
                                                                BIC.COMPONENT_SEQUENCE_ID)
                                                         OR BIC2.OPERATION_SEQ_NUM = BIC.OPERATION_SEQ_NUM)
                                                --AND   BIC2.EFFECTIVITY_DATE <= SYSDATE       --BUGFIX 2380517
                                                AND     BIC2.EFFECTIVITY_DATE <= l_bom_rev_date  --BUGFIX 2380517
                                                AND     BIC2.REVISED_ITEM_SEQUENCE_ID =
                                                        ERI.REVISED_ITEM_SEQUENCE_ID(+)
                                                AND     ( NVL(ERI.STATUS_TYPE,6) IN (4,6,7))
                                                AND     NOT EXISTS (
                                                            SELECT 'X'
                                                            FROM   BOM_INVENTORY_COMPONENTS BICN,
                                                                   ENG_REVISED_ITEMS ERI1
                                                            WHERE  BICN.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
                                                            AND    BICN.OLD_COMPONENT_SEQUENCE_ID =
                                                                   BIC.COMPONENT_SEQUENCE_ID
                                                            AND    BICN.ACD_TYPE in (2,3)
                                                            --AND  BICN.DISABLE_DATE <= SYSDATE       --BUGFIX 2380517
                                                            AND    BICN.DISABLE_DATE <= l_bom_rev_date  --BUGFIX 2380517
                                                            AND    ERI1.REVISED_ITEM_SEQUENCE_ID = BICN.REVISED_ITEM_SEQUENCE_ID
                                                            AND    ( nvl(ERI1.STATUS_TYPE,6) IN (4,6,7) )
                                                        )
                                            );
                                exception
                                    -- BA: BUGFIX 2380517
                                    when no_data_found then
                                        l_error_code := -1;
                                        fnd_message.set_name('WSM','WSM_INVALID_BOM_ROUT');
                                        l_err_msg := fnd_message.get;
                                        handle_error(l_error_code, l_err_msg, l_stmt_num);
                                    --EA: BUGFIX 2380517

                                    when others then
                                        l_error_code := SQLCODE;
                                        l_err_msg :=  'WSMLBJIB.launch_worker: stmt num= '||l_stmt_num||' '||SUBSTR(SQLERRM, 1,1000);
                                        handle_error(l_error_code, l_err_msg, l_stmt_num);
                                end;
                            end if;

                            if l_error_code <> 0 then
                                l_error_count := l_error_count + 1;
                                GOTO skip_other_steps;
                            end if;
                            l_dummy := 0;
                            l_err_msg := '';

                            if lbji_debug = 'Y' then
                                fnd_file.put_line(fnd_file.log, 'Verify that the component is reqd. at the first operation of the assembly.. Success');
                            end if;

l_stmt_num := 640;
                            -- abbKanban begin
                            if v_wlji_kanban_card_id(v_index) is not null then
                                if honor_kanban_size(v_wlji_org(v_index),
                                                     v_wlji_item(v_index),
                                                     v_wlji_completion_subinventory(v_index),
                                                     v_wlji_completion_locator_id(v_index),
                                                     -1) = 1 then
                                    select kanban_size
                                    into   l_kanban_size
                                    from   mtl_kanban_cards
                                    where  kanban_card_id = v_wlji_kanban_card_id(v_index);

                                    if v_wlji_start_quantity(v_index) > l_kanban_size then
                                        v_wlji_start_quantity(v_index) := l_kanban_size;
                                        v_wlji_net_quantity(v_index) := v_wlji_start_quantity(v_index);
                                    end if;
                                end if;
                            end if;
                            -- abbKanban end

                            -- *** begin validate quantity ***
l_stmt_num := 645;
                            -- BC: bug 3852078  do not use wsm_components_v
                            /*****
                            SELECT  component_quantity, component_yield_factor
                            INTO    l_component_quantity, l_component_yield_factor
                            FROM    wsm_components_v
                            WHERE   assembly_item_id = v_wlji_item(v_index)
                            AND     component_item_id = v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id
                            AND     nvl(alternate_bom_designator,'NULL') = nvl(v_wlji_alt_bom_designator(v_index),'NULL')
                            AND     organization_id = v_wlji_org(v_index);
                            *****/

                            SELECT  bic.component_quantity,
                                    decode(bic.component_yield_factor, 0, 1,
                                           bic.component_yield_factor) component_yield_factor,
                                    bic.basis_type             -- LBM enh
                            INTO    l_component_quantity,
                                    l_component_yield_factor,
                                    l_comp_basis_type           -- LBM enh
                            from    mtl_System_items msi,
                                    bom_inventory_components bic,
                                    bom_bill_of_materials bom,
                                    bom_bill_of_materials bom2
                            WHERE   bic.bill_sequence_id = bom2.bill_sequence_id
                            and     bom.common_bill_sequence_id = bom2.bill_sequence_id
                            and     msi.organization_id = bom.organization_id
                            and     msi.inventory_item_id = bom.assembly_item_id
                            and     msi.build_in_wip_flag = 'Y'
                            and     msi.pick_components_flag = 'N'
                            and     bic.implementation_date is not null
                            and     bom.assembly_item_id = v_wlji_item(v_index)
                            and     bic.component_item_id = v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id
                            and     bom.organization_id = v_wlji_org(v_index)
                            and     nvl(bom.alternate_bom_designator,'NULL') = nvl(v_wlji_alt_bom_designator(v_index),'NULL')
                            and     l_bom_rev_date between bic.effectivity_date
                                                   and     nvl(bic.disable_date, l_bom_rev_date + 1);
                            -- EC: bug 3852078

                            -- quantity of component required per assembly
                           --3913296:Rounding of required qty is removed and to be issued is rounded
                            --l_required_quantity := round((l_component_quantity / l_component_yield_factor), 6);
                            l_required_quantity := l_component_quantity / l_component_yield_factor;
                            -- LBM enh
                            if nvl(l_comp_basis_type, 1) = 2 then  --lot based
                                l_quantity_tobe_issued := round(l_required_quantity, 6);
                            else   -- item based
                                l_quantity_tobe_issued := round(l_required_quantity * v_wlji_start_quantity(v_index),6);
                            end if;
                            -- end LBM enh

l_stmt_num := 646;
                            if v_wsli(v_wlji_source_line_id(v_index)).comp_issue_quantity is not null then
                                if v_wsli(v_wlji_source_line_id(v_index)).comp_issue_quantity <= 0 then
                                    l_error_code := -1;
                                    process_errorred_field('WSM',
                                                           'WSM_QTY_ISSUE_NO_NEG',
                                                           l_stmt_num);
                                else
                                    l_quantity_tobe_issued := v_wsli(v_wlji_source_line_id(v_index)).comp_issue_quantity;
                                end if;
                            end if;
l_stmt_num := 648;
                            -- if the user does not provide a revision in wsm_starting_lots_interface
                            -- then get the current revision and use that to issue components. if user
                            -- provides one, validate it

                            l_source_item_rev := v_wsli(v_wlji_source_line_id(v_index)).revision;
                            declare
                                err_lot_revision    exception;  -- Add: bug 2963225
                            begin
                                -- BC: bug 2963225 this is to validate the revision of the item
                                -- which is not right, instead, we should validate / default
                                -- the revision of the starting lot, so comment out the following

                                --l_rev_sysdate := sysdate;
                                --wip_revisions.bom_revision (
                                --       v_wlji_org(v_index),
                                --       v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id,
                                --       l_source_item_rev,
                                --       l_source_item_rev_date,
                                --       l_rev_sysdate);

                                if l_rev_control_code = 1 then -- not revision control
                                    if(l_source_item_rev is not null) then
                                        raise err_lot_revision;
                                    end if;
                                else    -- revision control item
                                    select  revision
                                    into    l_start_lot_revision
                                    from    WSM_source_lots_v
                                    where   lot_number = v_wsli(v_wlji_source_line_id(v_index)).lot_number
                                    and     organization_id = v_wlji_org(v_index)
                                    and     inventory_item_id = v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id;

                                    if(l_source_item_rev is null) then
                                        v_wsli(v_wlji_source_line_id(v_index)).revision := l_start_lot_revision;
                                    elsif(l_source_item_rev <> l_start_lot_revision) then
                                        raise err_lot_revision;
                                    end if;
                                end if;
                                -- EC: bug 2963225

                            exception
                                when err_lot_revision then  -- Add: bug 2963225
                                    l_error_code := -1;
                                    l_error_count := l_error_count +1;
                                    process_invalid_field('Component Lot Revision', '', l_stmt_num);
                                    GOTO skip_other_steps;

                                when others then
                                    l_error_code := -1;
                                    l_error_count := l_error_count +1;
                                    process_invalid_field('Component Lot Revision', '', l_stmt_num);
                                    GOTO skip_other_steps;
                            end;

l_stmt_num := 650;
                            wsmputil.return_att_quantity(p_org_id => v_wlji_org(v_index),
                                 p_item_id => v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id,
                                 p_rev => v_wsli(v_wlji_source_line_id(v_index)).revision,
                                 p_lot_no => v_wsli(v_wlji_source_line_id(v_index)).lot_number,
                                 p_subinv => v_wsli(v_wlji_source_line_id(v_index)).subinventory_code,
                                 p_locator_id => v_wsli(v_wlji_source_line_id(v_index)).locator_id,
                                 p_qoh => l_qoh,
                                 p_atr => l_atr,
                                 p_att => l_att,
                                 p_err_code => l_error_code,
                                 p_err_msg => l_err_msg );

                            if l_error_code <> 0 then
                                HANDLE_ERROR( l_error_code, l_err_msg, l_stmt_num);
                                l_error_count := l_error_count + 1;
                                GOTO skip_other_steps;
                            end if;

                            if l_quantity_tobe_issued > l_att then
                                -- bug 3741740 remove this validation because we allow issue
                                -- less quantity than job required quantity through form
                                -- we will issue all the quantity if qty_tobe_issued > l_att
                                l_quantity_tobe_issued := l_att;
                                --l_error_code := -1;
                                --process_errorred_field('WSM',
                                --                       'WSM_INSUFFICIENT_QTY',
                                --                       l_stmt_num);
                            end if;


                            if l_error_code <> 0 then
                                    l_error_count := l_error_count + 1;
                                    GOTO skip_other_steps;
                            end if;

                            if lbji_debug = 'Y' then
                                fnd_file.put_line(fnd_file.log, 'Mode 2 Quantity Verification.. Success');
                            end if;
                            -- *** end validate quantity ***


l_stmt_num := 661;
                            -- *** validate starting lot is not phantom begin ***
                            begin
                                SELECT  1
                                INTO    l_dummy
                                FROM    BOM_INVENTORY_COMPONENTS BIC,
                                        MTL_SYSTEM_ITEMS         C
                                WHERE   BIC.COMPONENT_ITEM_ID = C.INVENTORY_ITEM_ID
                                AND     C.ORGANIZATION_ID = v_wlji_org(v_index)
                                AND     BIC.BILL_SEQUENCE_ID = bom_seq_id
                                AND     BIC.COMPONENT_ITEM_ID = v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id
                                AND     (BIC.operation_seq_num = (SELECT  BOS.operation_seq_num
                                                                  FROM    BOM_OPERATION_SEQUENCES BOS
                                                                  WHERE   operation_sequence_id = l_start_op_seq_id)
                                         OR BIC.operation_seq_num = 1 )
                                AND     NVL(BIC.wip_supply_type, 1) <> 6  -- CHG: BUG 2696937/2652076

                                -- BC: BUGFIX 2380517 (CZH.I_OED-2)
                                --AND   EFFECTIVITY_DATE <= SYSDATE
                                --AND   nvl(DISABLE_DATE, SYSDATE + 1) > SYSDATE
                                AND     l_bom_rev_date between BIC.EFFECTIVITY_DATE
                                                       and     nvl(BIC.DISABLE_DATE, l_bom_rev_date + 1)
                                -- EC: BUGFIX 2380517
                                AND     EFFECTIVITY_DATE = (
                                            SELECT MAX(EFFECTIVITY_DATE)
                                            FROM   BOM_INVENTORY_COMPONENTS BIC2,
                                                   ENG_REVISED_ITEMS        ERI
                                            WHERE  BIC2.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
                                            AND    BIC2.COMPONENT_ITEM_ID = BIC.COMPONENT_ITEM_ID
                                            AND    (decode(BIC2.IMPLEMENTATION_DATE,
                                                           NULL, BIC2.OLD_COMPONENT_SEQUENCE_ID,
                                                           BIC2.COMPONENT_SEQUENCE_ID) =
                                                    decode(BIC.IMPLEMENTATION_DATE,
                                                           NULL, BIC.OLD_COMPONENT_SEQUENCE_ID,
                                                           BIC.COMPONENT_SEQUENCE_ID)
                                                    OR BIC2.OPERATION_SEQ_NUM = BIC.OPERATION_SEQ_NUM)
                                            --AND  BIC2.EFFECTIVITY_DATE <= SYSDATE      --BUGFIX 2380517
                                            AND    BIC2.EFFECTIVITY_DATE <= l_bom_rev_date --BUGFIX 2380517
                                            AND    BIC2.REVISED_ITEM_SEQUENCE_ID = ERI.REVISED_ITEM_SEQUENCE_ID(+)
                                            AND    (NVL(ERI.STATUS_TYPE,6) IN (4,6,7))
                                            AND    NOT EXISTS (
                                                       SELECT  'X'
                                                       FROM    BOM_INVENTORY_COMPONENTS BICN,
                                                               ENG_REVISED_ITEMS ERI1
                                                       WHERE   BICN.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
                                                       AND     BICN.OLD_COMPONENT_SEQUENCE_ID = BIC.COMPONENT_SEQUENCE_ID
                                                       AND     BICN.ACD_TYPE in (2,3)
                                                       --AND   BICN.DISABLE_DATE <= SYSDATE        --BUGFIX 2380517
                                                       AND     BICN.DISABLE_DATE <= l_bom_rev_date --BUGFIX 2380517
                                                       AND     ERI1.REVISED_ITEM_SEQUENCE_ID = BICN.REVISED_ITEM_SEQUENCE_ID
                                                       AND     ( NVL(ERI1.STATUS_TYPE,6) IN (4,6,7) )
                                                   )
                                        );
                            exception
                                -- BA: BUGFIX 2380517
                                when no_data_found then
                                    l_error_code := -1;
                                    fnd_message.set_name('WSM','WSM_INVALID_BOM_ROUT');
                                    l_err_msg := fnd_message.get;
                                    handle_error(l_error_code, l_err_msg, l_stmt_num);
                                --EA: BUGFIX 2380517
                                when others then
                                    l_error_code := -1;
                                    process_errorred_field('WSM',
                                                           'WSM_PHANTOM_COMP_NOT_ALLOWED',
                                                           l_stmt_num);
                            end;

                            if l_error_code <> 0 then
                                    l_error_count := l_error_count + 1;
                                    GOTO skip_other_steps;
                            end if;
                            l_dummy := 0;
                            l_err_msg := '';

                            if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Verify that the starting lot is not phantom.. Success');
                            end if;
                            -- *** validate starting lot is not phantom end ***

                        end if; -- mode flag 2
                       -- *** end of mode flag 2 validations ***

                    end if; -- load type 5


                    -- *** check for disabled ops in the network and provide warning ***
                    if v_wlji_load_type(v_index) = 5 then
                        wsmputil.find_common_routing(
                                    p_routing_sequence_id => routing_seq_id,
                                    p_common_routing_sequence_id => p_common_routing_sequence_id,
                                    x_err_code => l_error_code,
                                    x_err_msg => l_err_msg);


                        if (wsmputil.network_with_disabled_op(
                                              p_common_routing_sequence_id,
                                              v_wlji_routing_revision_date(v_index),
                                              l_error_code,
                                              l_err_msg) = 1)
                        then
                            fnd_message.set_name('WSM','WSM_NET_HAS_DISABLED_OP');
                            l_err_msg := fnd_message.get;
                            l_warning_count := l_warning_count + 1;
                            handle_warning(p_err_msg => l_err_msg,
                                           p_header_id => v_wlji_header_id(v_index),
                                           p_request_id => v_wlji_request_id(v_index),
                                           p_program_id => v_wlji_program_id(v_index),
                                           p_program_application_id => v_wlji_program_application_id(v_index));

                        end if;

                    end if; -- load type 5


                    -- bugfix 2697295 begin
l_stmt_num := 669;
                    if v_wlji_load_type(v_index) = 5 then
                        if (v_wlji_status_type(v_index) = WIP_CONSTANTS.UNRELEASED) and (v_wlji_date_released(v_index) is not null ) then

                            v_wlji_date_released(v_index) := null;

                            if lbji_debug = 'Y' then
                                fnd_file.put_line(fnd_file.log, 'value for column DATE_RELEASED is being ignored for unreleased job');
                            end if;
                        elsif (v_wlji_status_type(v_index) = WIP_CONSTANTS.RELEASED ) then
                            if (v_wlji_date_released(v_index) > sysdate ) then

                                l_error_code := -1;
                                process_errorred_field('WIP',
                                                       'WIP_INVALID_RELEASE_DATE',
                                                       l_stmt_num);

                            elsif (v_wlji_date_released(v_index) is null) then

                                v_wlji_date_released(v_index) := sysdate;

                            end if;
                        end if;

                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;

                        l_err_msg := '';

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Date_Released Validation.. First Phase Done.');
                        end if;

                    end if; -- load type 5
                    -- bugfix 2697295 ends


l_stmt_num := 670;

                    if v_wlji_job_type(v_index) <> 3 then -- job type for schedule group and build sequence

                        -- *** validate schedule_group_id begin ***
                        if (v_wlji_load_type(v_index) = 6 and v_wlji_schedule_group_id(v_index) is NULL) then
                            select schedule_group_id
                            into   v_wlji_schedule_group_id(v_index)
                            from   wip_discrete_jobs
                            where  wip_entity_id = v_wlji_wip_entity_id(v_index)
                            and    organization_id = v_wlji_org(v_index);
                        end if;

                        if (v_wlji_source_code(v_index) = 'WICDOL' and v_wlji_schedule_group_name(v_index) IS NULL
                            and v_wlji_schedule_group_id(v_index) IS NULL) then
                            insert into wip_schedule_groups (
                                    schedule_group_id,
                                    schedule_group_name,
                                    organization_id,
                                    description,
                                    created_by,
                                    last_updated_by,
                                    creation_date,
                                    last_update_date)
                            select  wip_schedule_groups_s.nextval,
                                    wds.name,
                                    v_wlji_org(v_index),
                                    to_char(sysdate),
                                    l_user,
                                    l_user,
                                    sysdate,
                                    sysdate
                            from    wsh_new_deliveries wds
                            where   wds.delivery_id = v_wlji_delivery_id(v_index)
                                    and not exists  (
                                            select  1
                                            from    wip_schedule_groups wsg
                                            where   wsg.organization_id = v_wlji_org(v_index)
                                                    and WSG.schedule_group_name = WDS.name);

                            select wsg.schedule_group_name, wsg.schedule_group_id
                            into   v_wlji_schedule_group_name(v_index), v_wlji_schedule_group_id(v_index)
                            from   wip_schedule_groups wsg,
                                   wsh_new_deliveries wds
                            where  wds.delivery_id = v_wlji_delivery_id(v_index)
                               and wsg.schedule_group_name = wds.name
                               and wsg.organization_id = v_wlji_org(v_index);
                        end if;

                        if ((v_wlji_schedule_group_id(v_index) is not NULL) and (v_wlji_load_type(v_index) in (5,6))) then
                            begin
                                select 1 into l_dummy
                                from   wip_schedule_groups_val_v wsg
                                where  wsg.schedule_group_id = v_wlji_schedule_group_id(v_index)
                                and    wsg.organization_id = v_wlji_org(v_index);
                            exception
                                when too_many_rows then
                                    l_dummy := 1;
                            end;

                            if l_dummy = 0 then
                                l_error_code := -1;
                                process_errorred_field('WIP',
                                                       'WIP_ML_SCHEDULE_GROUP',
                                                       l_stmt_num);
                            end if;
                        end if;


                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;
                        l_dummy := 0;

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Schedule Group Id Verification.. Success');
                        end if;
                        -- *** validate schedule_group_id end ***


l_stmt_num := 690;
                        -- *** validate build_seq_id begin ***
                        begin
                            select
                                nvl(v_wlji_build_sequence(v_index), WDJ.build_sequence),
                                nvl(v_wlji_line_id(v_index), WDJ.line_id),
                                nvl(v_wlji_schedule_group_id(v_index), WDJ.schedule_group_id)
                            into
                                l_build_sequence,
                                l_line_id,
                                l_schedule_group_id
                            from
                                wip_discrete_jobs WDJ
                            where
                                WDJ.wip_entity_id = v_wlji_wip_entity_id(v_index);
                        exception
                            when no_data_found then null;
                            when too_many_rows then null;
                        end;

                        -- Added by BBK. Only if l_build_sequence is not null, we want to execute
                        -- this WIP_VALIDATE function. Otherwise, DO NOT.
                        if l_build_sequence is not null and l_build_sequence <> 0 Then
                            aReturnBoolean := WIP_Validate.build_sequence (
                                    p_build_sequence => l_build_sequence,
                                    p_wip_entity_id => v_wlji_wip_entity_id(v_index),
                                    p_organization_id => v_wlji_org(v_index),
                                    p_line_id => l_line_id,
                                    p_schedule_group_id => l_schedule_group_id
                                    );

                            if NOT aReturnBoolean Then
                                l_error_code := -1;
                                process_errorred_field('WIP',
                                                       'WIP_ML_BUILD_SEQUENCE',
                                                       l_stmt_num);
                            end if;
                        end if;
                        -- End of mod by BBK.

                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;

                        if lbji_debug = 'Y' then
                            fnd_file.put_line(fnd_file.log, 'Build Seq. Id Verification.. Success');
                        end if;

                    end if; -- job type <> 3 for schedule group and build sequence.
                    -- *** validate build_seq_id end ***


--************************************************************************************************
--**************************** Reschedule Job Validations Begin **********************************
--************************************************************************************************
                    if v_wlji_load_type(v_index) = 6 then
l_stmt_num := 700;
                        select  primary_item_id,
                                class_code,
                                scheduled_start_date,
                                scheduled_completion_date,
                                start_quantity,
                                net_quantity,
                                status_type,
                                firm_planned_flag,
                                job_type,
                                bom_reference_id,
                                alternate_bom_designator,
                                routing_reference_id,
                                alternate_routing_designator,
                                bom_revision_date,
                                routing_revision_date,
                                bom_revision,
                                routing_revision,
                                common_routing_sequence_id,
                                common_bom_sequence_id,
                                wip_supply_type,
                                scheduled_start_date,
                                scheduled_completion_date,
                                coproducts_supply,
                                kanban_card_id,
                                completion_subinventory, -- bug 2762029
                                completion_locator_id, -- bug 2762029
                                date_released
                        into    p_old_primary_item_id,
                                p_old_class_code,
                                p_old_start_date,
                                p_old_complete_date,
                                p_old_quantity,
                                p_old_net_quantity,
                                p_old_status_type,
                                p_old_firm_planned_flag,
                                p_old_job_type,
                                p_old_bom_reference_id,
                                p_old_alt_bom_designator,
                                p_old_routing_reference_id,
                                p_old_alt_routing_designator,
                                p_old_bom_revision_date,
                                p_old_routing_revision_date,
                                p_old_bom_revision,  -- bug 2762029
                                p_old_routing_revision, -- bug 2762029
                                p_old_com_rtg_seq_id,
                                p_old_com_bom_seq_id,
                                p_old_supply_type,
                                p_scheduled_start_date,
                                p_scheduled_completion_date,
                                p_coproducts_supply,
                                v_wlji_kanban_card_id(v_index),
                                p_old_completion_subinv,
                                p_old_completion_locator,
                                p_old_date_released
                        from    wip_discrete_jobs
                        where   wip_entity_id = v_wlji_wip_entity_id(v_index)
                        and     organization_id = v_wlji_org(v_index);

                        /* *** Bug 2762029 commenting begins
                        -- for update of a standard job, if the user populates any of the following fields,
                        -- they are ignored
                        if p_old_job_type = 1 then

                                if
                                (v_wlji_routing_reference_id(v_index) is not null) or
                                (v_wlji_bom_reference_id(v_index) is not null) or
                                (v_wlji_routing_revision_date(v_index) is not null) or
                                (v_wlji_routing_revision(v_index) is not null) or
                                (v_wlji_bom_revision_date(v_index) is not null) or
                                (v_wlji_bom_revision(v_index) is not null) or
                                (v_wlji_alt_bom_designator(v_index) is not null) or
                                (v_wlji_alt_routing_designator(v_index) is not null) then

                                        v_wlji_routing_reference_id(v_index) := null;
                                        v_wlji_bom_reference_id(v_index) := null;
                                        v_wlji_routing_revision_date(v_index) := null;
                                        v_wlji_routing_revision(v_index) := null;
                                        v_wlji_bom_revision_date(v_index) := null;
                                        v_wlji_bom_revision(v_index) := null;
                                        v_wlji_alt_bom_designator(v_index) := null;
                                        v_wlji_alt_routing_designator(v_index) := null;

                                        fnd_file.put_line(fnd_file.log, 'Ignoring any of the following fields if provided by the user for this standard job:');
                        --              fnd_file.new_line(fnd_file.log, 1);
                                        fnd_file.put_line(fnd_file.log, 'ROUTING_REFERENCE_ID, BOM_REFERENCE_ID, ROUTING_REVISION_DATE, ROUTING_REVISION, BOM_REVISION_DATE, BOM_REVISION, ALTERNATE_BOM_DESIGNATOR, ALTERNATE_ROUTING_DESIGNATOR');
                                end if;

                        end if; -- job type 1
                        */ -- Bug 2762029 commenting ends


                        -- Bug 2762029 begins
                        -- initializing some variables.
                        p_common_bill_sequence_id    := p_old_com_bom_seq_id;
                        p_common_routing_sequence_id := p_old_com_rtg_seq_id;

-- =============================================================================================
-- UPDATE OF ALTERNATES BEGIN
-- =============================================================================================
                        Begin
                            p_change_bom_alt := 0;
                            p_change_routing_alt := 0;
                            p_change_alt_flag := 0;

                            -- if the user wants to update an alternate to NULL value, s/he should populate '-99' in the interface.
l_stmt_num := 700.1;
                            if p_old_job_type = 1 then

                                if v_wlji_alt_bom_designator(v_index) is NOT NULL AND
                                 ((p_old_alt_bom_designator is NULL AND v_wlji_alt_bom_designator(v_index) <> '-99') OR
                                  (p_old_alt_bom_designator is NOT NULL AND
                                   v_wlji_alt_bom_designator(v_index) <> p_old_alt_bom_designator)
                                 ) THEN
                                    p_change_bom_alt := 1;
                                end if;

                                if v_wlji_alt_routing_designator(v_index) is NOT NULL AND
                                 ((p_old_alt_routing_designator is NULL AND v_wlji_alt_routing_designator(v_index) <> '-99') OR
                                  (p_old_alt_routing_designator is NOT NULL AND
                                   v_wlji_alt_routing_designator(v_index) <> p_old_alt_routing_designator)
                                 ) THEN
                                    p_change_routing_alt := 1;
                                end if;

                                -- change bom/routing alternate
                                if (p_change_bom_alt = 1 OR p_change_routing_alt = 1) and p_old_status_type = 1 then
                                    p_change_alt_flag := 1; --i.e. update of at least one alternate has happenned

                                    -- populate local variables
                                    v_wlji_item(v_index) := p_old_primary_item_id;

                                    if p_change_bom_alt = 1 AND p_change_routing_alt = 0 then
                                        if v_wlji_alt_bom_designator(v_index) = '-99' then
                                            v_wlji_alt_bom_designator(v_index) := null;
                                        end if;
                                        v_wlji_alt_routing_designator(v_index) := p_old_alt_routing_designator;
                                    end if; --p_change_bom_alt = 1

                                    if p_change_routing_alt = 1 AND p_change_bom_alt = 0 then
                                        if v_wlji_alt_routing_designator(v_index) = '-99' then
                                            v_wlji_alt_routing_designator(v_index) := null;
                                        end if;
                                        v_wlji_alt_bom_designator(v_index) := p_old_alt_bom_designator;
                                    end if; --p_change_routing_alt = 1

                                    if p_change_routing_alt = 1 AND p_change_bom_alt = 1 then
                                        if v_wlji_alt_bom_designator(v_index) = '-99' then
                                            v_wlji_alt_bom_designator(v_index) := null;
                                        end if;
                                        if v_wlji_alt_routing_designator(v_index) = '-99' then
                                            v_wlji_alt_routing_designator(v_index) := null;
                                        end if;
                                    end if;

l_stmt_num := 700.2;
                                    delete from wip_operations where wip_entity_id = v_wlji_wip_entity_id(v_index);
                                    delete from wip_operation_resources where wip_entity_id = v_wlji_wip_entity_id(v_index);
                                    delete from wip_requirement_operations where wip_entity_id = v_wlji_wip_entity_id(v_index);
                                    delete from wip_operation_yields where wip_entity_id = v_wlji_wip_entity_id(v_index);

l_stmt_num := 700.3;
                                    -- Now validate the alternate designators to get the routing and bom sequence id.
                                    -- Also get the completion subinventory and locator. If the user has provided them
                                    -- use them after validation, else use these default values.
                                    -- Also validate/default the bom/rtg revision and revision-dates

                                    begin
                                        select bor.routing_sequence_id,
                                               bor.COMPLETION_SUBINVENTORY,
                                               bor.COMPLETION_LOCATOR_ID
                                        into   p_common_routing_sequence_id,
                                               l_default_subinventory,
                                               l_default_compl_loc_id
                                        from   bom_operational_routings bor, bom_alternate_designators bad
                                        where  ((bor.alternate_routing_designator is null and bad.alternate_designator_code is null
                                                and bad.organization_id = -1)
                                                or (bor.alternate_routing_designator = bad.alternate_designator_code
                                                and bor.organization_id = bad.organization_id))
                                        and    bor.organization_id = v_wlji_org(v_index)
                                        and    bor.assembly_item_id = v_wlji_item(v_index)
                                        and    NVL(bor.alternate_routing_designator, '&*') = NVL(v_wlji_alt_routing_designator(v_index), '&*')
                                        and    bor.routing_type = 1
                                        and    bor.cfm_routing_flag = 3;
                                        --Bug 5107339: Disable_date validation is not applicable here.
                                        -- and    trunc(nvl(bad.disable_date, sysdate + 1)) > trunc(sysdate);

                                    exception
                                        when no_data_found then
                                            l_aux_mesg := '';
                                            process_invalid_field('ALTERNATE ROUTING DESIGNATOR',
                                                                  l_aux_mesg,
                                                                  l_stmt_num);
                                            l_error_code := -1;
                                    end;

                                    if l_error_code <> 0 then
                                            l_error_count := l_error_count + 1;
                                            GOTO skip_resched_validations;
                                    end if;

l_stmt_num := 700.4;
                                    IF v_wlji_completion_subinventory(v_index) IS NULL AND
                                       v_wlji_completion_locator_id(v_index) IS NULL THEN
                                        v_wlji_completion_subinventory(v_index) := l_default_subinventory;
                                        v_wlji_completion_locator_id(v_index) := l_default_compl_loc_id;
                                    END IF;

                                    IF v_wlji_completion_subinventory(v_index) IS NULL AND
                                       v_wlji_completion_locator_id(v_index) IS NOT NULL THEN
                                        v_wlji_completion_subinventory(v_index) := l_default_subinventory;
                                    END IF;

                                    IF v_wlji_completion_subinventory(v_index) IS NOT NULL AND
                                       v_wlji_completion_locator_id(v_index) IS NULL THEN

                                        str := to_char(v_wlji_org(v_index))||v_wlji_completion_subinventory(v_index);
                                        hash_value := dbms_utility.get_hash_value(str, 37, 1073741824);
                                        if WSMPLCVA.v_subinv.exists(hash_value) then
                                            NULL;
                                        else
                                            l_aux_mesg := '';
                                            process_invalid_field('COMPLETION SUBINVENTORY',
                                                                  l_aux_mesg,
                                                                  l_stmt_num);
                                            l_error_code := -1;
                                        end if;

                                        if l_error_code <> 0 then
                                            l_error_count := l_error_count + 1;
                                            GOTO skip_resched_validations;
                                        end if;
                                        l_aux_mesg := '';
                                        str := '';
                                        hash_value := 0;

l_stmt_num := 700.5;
                                        select locator_type
                                        into   mtl_locator_type
                                        from   mtl_secondary_inventories
                                        where  secondary_inventory_name = v_wlji_completion_subinventory(v_index)
                                        and    organization_id = v_wlji_org(v_index);

                                        if v_wlji_completion_subinventory(v_index) = l_default_subinventory then
                                            v_wlji_completion_locator_id(v_index) := l_default_compl_loc_id;
                                        else
                                            if mtl_locator_type = 2 then
                                                l_aux_mesg := '';
                                                process_invalid_field('COMPLETION SUBINVENTORY',
                                                                      l_aux_mesg,
                                                                      l_stmt_num);
                                                l_error_code := -1;
                                                l_error_count := l_error_count + 1;
                                                GOTO skip_resched_validations;
                                            else
                                                NULL;
                                            end if;
                                        end if;
                                    END IF;

                                    l_aux_mesg := '';

l_stmt_num := 700.6;
                                    IF v_wlji_alt_bom_designator(v_index) is NULL THEN
                                        begin
                                            SELECT  bom.common_bill_sequence_id
                                              INTO  p_common_bill_sequence_id
                                              FROM  bom_bill_of_materials bom
                                             WHERE  bom.alternate_bom_designator is NULL
                                               AND  BOM.assembly_item_id = v_wlji_item(v_index)
                                               AND  bom.organization_id = v_wlji_org(v_index);
                                        exception
                                            WHEN NO_DATA_FOUND THEN
                                                NULL;
                                        end;
                                    ELSE
                                        begin
                                               SELECT  bom.common_bill_sequence_id
                                                 INTO  p_common_bill_sequence_id
                                                 FROM  bom_bill_of_materials bom, bom_alternate_designators bad
                                                WHERE  ((bom.alternate_bom_designator is null and bad.alternate_designator_code is null
                                                          and bad.organization_id = -1)
                                                         OR (bom.alternate_bom_designator = bad.alternate_designator_code
                                                             and bom.organization_id = bad.organization_id))
                                                  AND  bom.alternate_bom_designator = v_wlji_alt_bom_designator(v_index)
                                                  AND  BOM.assembly_item_id = v_wlji_item(v_index)
                                                  AND  bom.organization_id = v_wlji_org(v_index);
                                                  --Bug 5107339: Disable_date validation is not applicable here.
                                                  --AND  trunc(nvl(bad.disable_date, sysdate + 1)) > trunc(sysdate);

                                        exception
                                            WHEN no_data_found  THEN
                                                l_aux_mesg := '';
                                                process_invalid_field('ALTERNATE BOM DESIGNATOR',
                                                                      l_aux_mesg,
                                                                      l_stmt_num);
                                                l_error_code := -1;
                                        end;
                                    END IF;

                                    if l_error_code <> 0 then
                                        l_error_count := l_error_count + 1;
                                        GOTO skip_resched_validations;
                                    end if;
                                    l_aux_mesg := '';

l_stmt_num := 700.6;

                                    SELECT  nvl(msub.locator_type, 1) sub_loc_control,
                                            MP.stock_locator_control_code org_loc_control,
                                            MS.restrict_locators_code,
                                            MS.location_control_code item_loc_control
                                            into l_sub_loc_control, l_org_loc_control,
                                                    l_restrict_locators_code, l_item_loc_control
                                    FROM    mtl_system_items MS,
                                            mtl_secondary_inventories MSUB,
                                            mtl_parameters MP
                                    WHERE   MP.organization_id = v_wlji_org(v_index)
                                    AND     MS.organization_id = v_wlji_org(v_index)
                                    AND     MS.inventory_item_id = v_wlji_item(v_index)
                                    AND     MSUB.secondary_inventory_name = v_wlji_completion_subinventory(v_index)
                                    AND     MSUB.organization_id = v_wlji_org(v_index);

                                    l_locator_id := v_wlji_completion_locator_id(v_index) ;

                                    WIP_LOCATOR.validate(   v_wlji_org(v_index),
                                                            v_wlji_item(v_index),
                                                            v_wlji_completion_subinventory(v_index),
                                                            l_org_loc_control,
                                                            l_sub_loc_control,
                                                            l_item_loc_control,
                                                            l_restrict_locators_code,
                                                            NULL, NULL, NULL, NULL,
                                                            l_locator_id,
                                                            l_segs,
                                                            l_loc_success);

                                    IF not l_loc_success THEN
                                        l_aux_mesg := '';
                                        process_invalid_field('COMPLETION SUBINVENTORY',
                                                              l_aux_mesg,
                                                              l_stmt_num);
                                        l_error_code := -1;
                                    end if;

                                    if l_error_code <> 0 then
                                        l_error_count := l_error_count + 1;
                                        GOTO skip_resched_validations;
                                    end if;
                                    l_aux_mesg := '';
                                    l_locator_id := 0;

l_stmt_num := 700.7;
                                    if v_wlji_fusd(v_index) is null then
                                        v_wlji_fusd(v_index) := p_old_start_date;
                                    end if;

                                    if v_wlji_fusd(v_index) > SYSDATE then
                                        l_rev_date := v_wlji_fusd(v_index);
                                    else
                                        l_rev_date := SYSDATE;
                                    end if;

                                    wip_revisions.bom_revision (v_wlji_org(v_index),
                                                                v_wlji_item(v_index),
                                                                v_wlji_bom_revision(v_index),
                                                                v_wlji_bom_revision_date(v_index),
                                                                l_rev_date);


                                    wip_revisions.routing_revision (v_wlji_org(v_index),
                                                                    v_wlji_item(v_index),
                                                                    v_wlji_routing_revision(v_index),
                                                                    v_wlji_routing_revision_date(v_index),
                                                                    l_rev_date);

                                    if l_error_code <> 0 then
                                            l_error_count := l_error_count + 1;
                                            GOTO skip_resched_validations;
                                    end if;

l_stmt_num := 700.8;
                                    -- now that we have the bom and rtg seq_id's and values for completion-subinv and locator
                                    -- and revision info, we can proceed to populate the wo tables and update wdj

                                    build_lbji_info(p_routing_seq_id => p_common_routing_sequence_id,
                                                    p_common_bill_sequence_id => p_common_bill_sequence_id,
                                                    p_explode_header_detail => 1,
                                                    p_status_type => 1,
                                                    p_class_code => null,
                                                    p_org => v_wlji_org(v_index),
                                                    p_wip_entity_id => v_wlji_wip_entity_id(v_index),
                                                    p_last_updt_date => v_wlji_last_updt_date(v_index),
                                                    p_last_updt_by => v_wlji_last_updt_by(v_index),
                                                    p_creation_date => v_wlji_creation_date(v_index),
                                                    p_created_by => v_wlji_created_by(v_index),
                                                    p_last_updt_login => v_wlji_last_updt_login(v_index),
                                                    p_request_id => v_wlji_request_id(v_index),
                                                    p_program_application_id => v_wlji_program_application_id(v_index),
                                                    p_program_id => v_wlji_program_id(v_index),
                                                    p_prog_updt_date => v_wlji_prog_updt_date(v_index),
                                                    p_source_line_id => null,
                                                    p_source_code =>  null,
                                                    p_description => null,
                                                    p_item => p_old_primary_item_id,
                                                    p_job_type => 1,
                                                    p_bom_reference_id => null,
                                                    p_routing_reference_id => null,
                                                    p_firm_planned_flag => p_old_firm_planned_flag,
                                                    p_wip_supply_type => p_old_supply_type,
                                                    p_fusd => p_scheduled_start_date,
                                                    p_lucd => p_scheduled_completion_date,
                                                    p_start_quantity => p_old_quantity,
                                                    p_net_quantity => p_old_net_quantity,
                                                    p_coproducts_supply => p_coproducts_supply,
                                                    p_bom_revision => v_wlji_bom_revision(v_index),
                                                    p_routing_revision => v_wlji_routing_revision(v_index),
                                                    p_bom_revision_date => v_wlji_bom_revision_date(v_index),
                                                    p_routing_revision_date => v_wlji_routing_revision_date(v_index),
                                                    p_lot_number => null,
                                                    p_alt_bom_designator => v_wlji_alt_bom_designator(v_index),
                                                    p_alt_routing_designator => v_wlji_alt_routing_designator(v_index),
                                                    p_priority => null,
                                                    p_due_date => null,
                                                    p_attribute_category => null,
                                                    p_attribute1 => null,
                                                    p_attribute2 => null,
                                                    p_attribute3 => null,
                                                    p_attribute4 => null,
                                                    p_attribute5 => null,
                                                    p_attribute6 => null,
                                                    p_attribute7 => null,
                                                    p_attribute8 => null,
                                                    p_attribute9 => null,
                                                    p_attribute10 => null,
                                                    p_attribute11 => null,
                                                    p_attribute12 => null,
                                                    p_attribute13 => null,
                                                    p_attribute14 => null,
                                                    p_attribute15 => null,
                                                    p_job_name => null,
                                                    p_completion_subinventory => v_wlji_completion_subinventory(v_index),
                                                    p_completion_locator_id => v_wlji_completion_locator_id(v_index),
                                                    p_demand_class => null,
                                                    p_project_id => null,
                                                    p_task_id => null,
                                                    p_schedule_group_id => null,
                                                    p_build_sequence => null,
                                                    p_line_id => null,
                                                    p_kanban_card_id => null,
                                                    p_overcompl_tol_type => null,
                                                    p_overcompl_tol_value => null,
                                                    p_end_item_unit_number => null,
                                                    p_rtg_op_seq_num => null,
                                                    p_src_client_server => 0,
                                                    p_po_creation_time => null,
                                                    p_error_code => l_error_code,
                                                    p_error_msg => l_error_msg);

                                    if l_error_code <> 0 then
                                           handle_error(l_error_code, l_error_msg,  l_stmt_num);
                                           l_error_count := l_error_count + 1;
                                           GOTO skip_resched_validations;
                                    end if;

                                elsif p_old_status_type <> 1 then
                                    fnd_file.put_line(fnd_file.log, 'Ignoring any of the following fields if provided by the user for this standard job:');
                                    fnd_file.put_line(fnd_file.log, 'ROUTING_REVISION_DATE, ROUTING_REVISION, BOM_REVISION_DATE, BOM_REVISION,
                                                                            ALTERNATE_BOM_DESIGNATOR, ALTERNATE_ROUTING_DESIGNATOR');
                                end if; -- change bom/routing alternate

                            end if; -- job type 1, near l_stmt_num := 700.1;


                            if p_old_job_type = 1 then
                                v_wlji_bom_reference_id(v_index) := p_old_bom_reference_id;
                                v_wlji_routing_reference_id(v_index) := p_old_routing_reference_id;
                                if p_change_alt_flag = 0 then
                                    v_wlji_bom_revision(v_index) := p_old_bom_revision;
                                    v_wlji_routing_revision(v_index) := p_old_routing_revision;
                                    v_wlji_bom_revision_date(v_index) := p_old_bom_revision_date;
                                    v_wlji_routing_revision_date(v_index) := p_old_routing_revision_date;
                                    v_wlji_alt_bom_designator(v_index) := p_old_alt_bom_designator;
                                    v_wlji_alt_routing_designator(v_index) := p_old_alt_routing_designator;
                                    v_wlji_completion_subinventory(v_index) := p_old_completion_subinv;
                                    v_wlji_completion_locator_id(v_index) := p_old_completion_locator;
                                end if;
                            end if;

                        Exception
                            WHEN OTHERS THEN
                                l_error_code := SQLCODE;
                                l_err_msg:='WSMLBJIB.launch_worker: stmt num= '||l_stmt_num||' '||SUBSTR(SQLERRM, 1,1000);
                                handle_error(l_error_code, l_err_msg, l_stmt_num);
                                GOTO skip_resched_validations;
                        End;
-- =============================================================================================
-- UPDATE OF ALTERNATES END
-- =============================================================================================
                        -- Bug 2762029 ends


-- =============================================================================================
--  UPDATE OF REFERENCES BEGINS
-- =============================================================================================

                        -- non standard job bom/routing reference update. The assumption is that this module will
                        -- NOT update the quantity/dates/etc., they will be taken care in the later modules.
                        -- This module will just look at the reference info, and assume qnty/date/etc to be same
                        -- as the old values.
l_stmt_num:= 701;
                        if p_old_job_type = 3 then

                            p_change_bom_reference := 0;
                            p_change_routing_reference := 0;

                            if   v_wlji_routing_reference_id(v_index) is not null then
                                p_change_routing_reference := 1;
                            end if;

                            if   v_wlji_bom_reference_id(v_index) is not null then
                                p_change_bom_reference := 1;
                            end if;

l_stmt_num:= 701.7;
                            if p_change_routing_reference = 0 AND p_change_bom_reference = 0 then
                                bom_seq_id := p_old_com_bom_seq_id;
                                v_wlji_bom_revision_date(v_index):= p_old_bom_revision_date;
                                v_wlji_bom_reference_id(v_index):= p_old_bom_reference_id;
                                v_wlji_alt_bom_designator(v_index):= p_old_alt_bom_designator;
                                routing_seq_id := p_old_com_rtg_seq_id;
                                v_wlji_routing_revision_date(v_index):=p_old_routing_revision_date;
                                v_wlji_routing_reference_id(v_index):=p_old_routing_reference_id;
                                v_wlji_alt_routing_designator(v_index):=p_old_alt_routing_designator;
                            end if;


                            -- user can update the bom_reference and the routing reference of a non-standard job only if the
                            -- job is unreleased. If the user updates the bom/routing on an unreleased job as well as it's
                            -- status to released, the update of the bom/rtg will be assumed to have taken place before
                            -- the update of status.

                            if (p_change_bom_reference = 1 or p_change_routing_reference = 1)
                                and  p_old_status_type <> 1 then
                                    fnd_file.put_line(fnd_file.log,'Ignoring any of the following fields if provided by the user:');
                                    --fnd_file.new_line(fnd_file.log, 1);
                                    fnd_file.put_line(fnd_file.log, 'ROUTING_REFERENCE_ID, BOM_REFERENCE_ID, ROUTING_REVISION_DATE , ROUTING_REVISION, BOM_REVISION_DATE, BOM_REVISION, ALTERNATE_BOM_DESIGNATOR, ALTERNATE_ROUTING_DESIGNATOR');
                                    v_wlji_bom_revision_date(v_index):= p_old_bom_revision_date;
                                    v_wlji_bom_reference_id(v_index):= p_old_bom_reference_id;
                                    v_wlji_alt_bom_designator(v_index):= p_old_alt_bom_designator;
                                    v_wlji_routing_revision_date(v_index):=p_old_routing_revision_date;
                                    v_wlji_routing_reference_id(v_index):=p_old_routing_reference_id;
                                    v_wlji_alt_routing_designator(v_index):=p_old_alt_routing_designator;
                            end if;


                            if p_old_status_type = 1 then

                            -- the following three variables will temporarily assume the old values for reasons mentioned above.
                            -- their original values will be returned to them for possible verification at the end of the module

                                temp_start_quantity:=v_wlji_start_quantity(v_index);
                                temp_fusd:=v_wlji_fusd(v_index);
                                temp_lucd:=v_wlji_lucd(v_index);
                                temp_supply:=v_wlji_wip_supply_type(v_index);

                                v_wlji_start_quantity(v_index):=p_old_quantity;
                                v_wlji_fusd(v_index):=p_old_start_date;
                                v_wlji_lucd(v_index):=p_old_complete_date;
                                v_wlji_wip_supply_type(v_index):=p_old_supply_type;

l_stmt_num:= 702;
                                if (p_change_bom_reference = 1 or p_change_routing_reference = 1) then

                                    if p_change_bom_reference = 1 then
                                        wsmputil.validate_non_std_references(
                                                  null,
                                                  null,
                                                  v_wlji_bom_reference_id(v_index),
                                                  null,
                                                  v_wlji_alt_bom_designator(v_index),
                                                  v_wlji_org(v_index),
                                                  sysdate, -- this doesn't really make any diff, not used after all
                                                  null,
                                                  null,
                                                  dummy_number,
                                                  null,
                                                  null,
                                                  null,
                                                  dummy_number,
                                                  v_wlji_bom_revision(v_index),
                                                  v_wlji_bom_revision_date(v_index),
                                                  dummy_varchar,
                                                  dummy_date,
                                                  dummy_number,
                                                  bom_seq_id,
                                                  1,
                                                  l_error_code,
                                                  l_err_msg);

                                        if l_error_code <> 0 then
                                            HANDLE_ERROR( l_error_code, l_err_msg, l_stmt_num);
                                            l_error_code := -1;
                                            GOTO skip_resched_validations;
                                        end if;
                                    end if;

l_stmt_num:= 703;
                                    if p_change_routing_reference = 1 then
                                        wsmputil.validate_non_std_references(
                                                  null,
                                                  v_wlji_routing_reference_id(v_index),
                                                  null,
                                                  v_wlji_alt_routing_designator(v_index),
                                                  null,
                                                  v_wlji_org(v_index),
                                                  sysdate, -- this doesn't really make any diff, not used after all
                                                  null,
                                                  null,
                                                  dummy_number,
                                                  null,
                                                  null,
                                                  null,
                                                  dummy_number,
                                                  dummy_varchar,
                                                  dummy_date,
                                                  v_wlji_routing_revision(v_index),
                                                  v_wlji_routing_revision_date(v_index),
                                                  routing_seq_id,
                                                  dummy_number,
                                                  2,
                                                  l_error_code,
                                                  l_err_msg);

                                        if l_error_code <> 0 then
                                            HANDLE_ERROR( l_error_code, l_err_msg, l_stmt_num);
                                            l_error_code := -1;
                                            GOTO skip_resched_validations;
                                        end if;
                                    end if;

l_stmt_num:= 704;
                                    if p_change_routing_reference = 1 OR p_change_bom_reference = 1 then
                                        begin
                                            delete from wip_operations
                                            where  wip_entity_id = v_wlji_wip_entity_id(v_index);
                                            delete from wip_operation_yields
                                            where wip_entity_id = v_wlji_wip_entity_id(v_index);
                                            delete from wip_operation_resources
                                            where wip_entity_id = v_wlji_wip_entity_id(v_index);
                                            delete from wip_requirement_operations
                                            where wip_entity_id = v_wlji_wip_entity_id(v_index);
                                        exception
                                            when others then
                                                rollback;
                                                l_error_code := SQLCODE;
                                                l_err_msg:='WSMLBJIB.launch_worker: stmt num= '||l_stmt_num||' '||SUBSTR(SQLERRM, 1,1000);
                                                handle_error(l_error_code, l_err_msg, l_stmt_num);
                                                GOTO skip_resched_validations;
                                        end;
                                    end if;


                                    if p_change_routing_reference = 1 AND p_change_bom_reference = 0 then
                                        bom_seq_id := p_old_com_bom_seq_id;
                                        v_wlji_bom_revision_date(v_index):= p_old_bom_revision_date;
                                        v_wlji_bom_reference_id(v_index):= p_old_bom_reference_id;
                                        v_wlji_alt_bom_designator(v_index):= p_old_alt_bom_designator;
                                    end if;

                                    if p_change_routing_reference = 0 AND p_change_bom_reference = 1 then
                                        routing_seq_id := p_old_com_rtg_seq_id;
                                        v_wlji_routing_revision_date(v_index):=p_old_routing_revision_date;
                                        v_wlji_routing_reference_id(v_index):=p_old_routing_reference_id;
                                        v_wlji_alt_routing_designator(v_index):=p_old_alt_routing_designator;
                                    end if;

                                    begin
                                        build_lbji_info(
                                            p_routing_seq_id => routing_seq_id,
                                            p_common_bill_sequence_id => null,
                                            p_explode_header_detail => 1,
                                            p_status_type => 1,
                                            p_class_code => null,
                                            p_org => v_wlji_org(v_index),
                                            p_wip_entity_id => v_wlji_wip_entity_id(v_index),
                                            p_last_updt_date => v_wlji_last_updt_date(v_index),
                                            p_last_updt_by => v_wlji_last_updt_by(v_index),
                                            p_creation_date => v_wlji_creation_date(v_index),
                                            p_created_by => v_wlji_created_by(v_index),
                                            p_last_updt_login => v_wlji_last_updt_login(v_index),
                                            p_request_id => v_wlji_request_id(v_index),
                                            p_program_application_id => v_wlji_program_application_id(v_index),
                                            p_program_id => v_wlji_program_id(v_index),
                                            p_prog_updt_date => v_wlji_prog_updt_date(v_index),
                                            p_source_line_id => null,
                                            p_source_code =>  null,
                                            p_description => null,
                                            p_item => v_wlji_item(v_index),
                                            p_job_type => 3,
                                            p_bom_reference_id =>  v_wlji_bom_reference_id(v_index),
                                            p_routing_reference_id => v_wlji_routing_reference_id(v_index),
                                            p_firm_planned_flag => null,
                                            p_wip_supply_type => v_wlji_wip_supply_type(v_index),
                                            p_fusd => v_wlji_fusd(v_index),
                                            p_lucd => v_wlji_lucd(v_index),
                                            p_start_quantity => v_wlji_start_quantity(v_index),
                                            p_net_quantity => null,
                                            p_coproducts_supply => null,
                                            p_bom_revision => null,
                                            p_routing_revision => null,
                                            p_bom_revision_date => v_wlji_bom_revision_date(v_index),
                                            p_routing_revision_date => v_wlji_routing_revision_date(v_index),
                                            p_lot_number => null,
                                            p_alt_bom_designator => v_wlji_alt_bom_designator(v_index),
                                            p_alt_routing_designator => v_wlji_alt_routing_designator(v_index),
                                            p_priority => null,
                                            p_due_date => null,
                                            p_attribute_category => null,
                                            p_attribute1 => null,
                                            p_attribute2 => null,
                                            p_attribute3 => null,
                                            p_attribute4 => null,
                                            p_attribute5 => null,
                                            p_attribute6 => null,
                                            p_attribute7 => null,
                                            p_attribute8 => null,
                                            p_attribute9 => null,
                                            p_attribute10 => null,
                                            p_attribute11 => null,
                                            p_attribute12 => null,
                                            p_attribute13 => null,
                                            p_attribute14 => null,
                                            p_attribute15 => null,
                                            p_job_name => null,
                                            p_completion_subinventory => null,
                                            p_completion_locator_id => null,
                                            p_demand_class => null,
                                            p_project_id => null,
                                            p_task_id => null,
                                            p_schedule_group_id => null,
                                            p_build_sequence => null,
                                            p_line_id => null,
                                            p_kanban_card_id => null,
                                            p_overcompl_tol_type => null,
                                            p_overcompl_tol_value => null,
                                            p_end_item_unit_number => null,
                                            p_rtg_op_seq_num => null,
                                            p_src_client_server => 0,
                                            p_po_creation_time => WSMPLCVA.v_org(v_wlji_org(v_index)).PO_CREATION_TIME,
                                            p_error_code => l_error_code,
                                            p_error_msg => l_error_msg);

                                        if l_error_code <> 0 then
                                            raise update_job_exception;
                                        end if;

                                    exception
                                        when update_job_exception then
                                            handle_error(l_error_code, l_error_msg, l_stmt_num);
                                            l_error_count := l_error_count + 1;
                                            GOTO skip_resched_validations;
                                    end;

                                end if;
                                v_wlji_start_quantity(v_index):=temp_start_quantity;
                                v_wlji_fusd(v_index):=temp_fusd;
                                v_wlji_lucd(v_index):=temp_lucd;
                                v_wlji_wip_supply_type(v_index):=temp_supply;

                            end if; -- old_status_type = 1

                        end if; -- job type = 3

-- =============================================================================================
-- UPDATE OF REFERENCES ENDS
-- =============================================================================================


                        -- if the user wants to update only the references, the wo/wro/wor/woy updates are not needed
                        if (p_old_job_type = 3)
                           AND
                           (
                            (
                            (v_wlji_firm_planned_flag(v_index) is null) or
                            (v_wlji_firm_planned_flag(v_index) is not null and v_wlji_firm_planned_flag(v_index)=p_old_firm_planned_flag)
                            )
                            and
                            (
                            (v_wlji_status_type(v_index) is null) or
                            (v_wlji_status_type(v_index) is not null and v_wlji_status_type(v_index)=p_old_status_type)
                            )
                            and
                            (
                            (v_wlji_start_quantity(v_index) is null) or
                            (v_wlji_start_quantity(v_index) is not null and v_wlji_start_quantity(v_index)=p_old_quantity)
                            )
                            and
                            (
                            (v_wlji_net_quantity(v_index) is null) or
                            (v_wlji_net_quantity(v_index) is not null and v_wlji_net_quantity(v_index)=p_old_net_quantity)
                            )
                            and
                            (
                            (v_wlji_lucd(v_index) is null) or
                            (v_wlji_lucd(v_index) is not null and v_wlji_lucd(v_index)=p_scheduled_completion_date)
                            )
                            and
                            (
                            (v_wlji_fusd(v_index) is null) or
                            (v_wlji_fusd(v_index) is not null and v_wlji_fusd(v_index)=p_scheduled_start_date)
                            )
                            and
                            (
                            (v_wlji_coproducts_supply(v_index) is null) or
                            (v_wlji_coproducts_supply(v_index) is not null and v_wlji_coproducts_supply(v_index)=p_coproducts_supply)
                            )
                           ) then
                            p_skip_updt:= 1;
                        end if;


                        if lbji_debug = 'Y' then
                            if p_skip_updt = 1 then
                                fnd_file.put_line(fnd_file.log, 'Planning to skip update of wo, wor, wro');
                            else
                                fnd_file.put_line(fnd_file.log, 'No Plans to skip update of wo, wor, wro');
                            end if;
                        end if;


                        -- if the old firm_planned flag was 1, and the user populated null while updating the job,
                        -- no changes in quantity and date allowed. If the user changed the flag, this change is considered
                        -- "before" making a decision whether to allow update of qnty/date or not.
                        if v_wlji_firm_planned_flag(v_index) is NULL then
                            v_wlji_firm_planned_flag(v_index) := p_old_firm_planned_flag;
                        end if;

                        -- for non-std jobs, the firm flag is always 2. User cannot update it to 1.
                        if p_old_job_type = 3 then
                            if v_wlji_firm_planned_flag(v_index) is not null and
                               v_wlji_firm_planned_flag(v_index) <> 2 then
                                l_aux_mesg := '';
                                process_invalid_field('FIRM PLANNED FLAG',
                                                      l_aux_mesg,
                                                      l_stmt_num);
                                l_error_code := -1;
                                GOTO skip_resched_validations;
                            end if;
                        end if;

                        --validate status first
l_stmt_num := 710;

                        IF v_wlji_status_type(v_index) IS NULL THEN
                            v_wlji_status_type(v_index) := p_old_status_type;
                            -- bugfix 2697295, update of released date only is not allowed
                            v_wlji_date_released(v_index) := p_old_date_released;
                        ELSIF v_wlji_status_type(v_index) = p_old_status_type THEN
                            -- bugfix 2697295, update of released date only is not allowed
                            v_wlji_date_released(v_index) := p_old_date_released;
                        ELSE

                        -- status type should be one of RELEASED, HOLD, CANCELLED, UNRELEASED

                            IF v_wlji_status_type(v_index) NOT IN (1,3,6,7) THEN
                                l_aux_mesg := '';
                                process_invalid_field('LOAD TYPE',
                                                      l_aux_mesg,
                                                      l_stmt_num);
                                l_error_code := -1;
                                GOTO skip_resched_validations;
                            ELSE

                                if p_old_status_type = 7   then     -- cancelled
                                    l_error_code := -1;
                                    process_errorred_field('WSM',
                                                           'WSM_RESCHEDULE_CANCEL_JOB',
                                                           l_stmt_num);
                                    GOTO skip_resched_validations;
                                end if;

                                -- bugfix 2697295 begin
                                -- if the job is being released from an unreleased state...
                                if p_old_date_released is null and v_wlji_status_type(v_index) = 3 then
                                    if (v_wlji_date_released(v_index) is null ) then
                                        v_wlji_date_released(v_index) := sysdate;
                                    elsif (v_wlji_date_released(v_index) > sysdate ) then
                                        l_error_code := -1;
                                        process_errorred_field('WIP',
                                                               'WIP_INVALID_RELEASE_DATE',
                                                               l_stmt_num);
                                        GOTO skip_resched_validations;
                                    else
                                        -- BEGIN: BUG3126650
                                        --begin
                                        --    select 1
                                        --    into   l_dummy
                                        --    from   org_acct_periods
                                        --    where  organization_id = v_wlji_org(v_index)
                                        --    and    trunc(nvl(v_wlji_date_released(v_index),sysdate)) between PERIOD_START_DATE and SCHEDULE_CLOSE_DATE
                                        --    and    period_close_date is NULL;
                                        --exception
                                        --    when NO_DATA_FOUND then
                                        --        fnd_message.set_name('WIP', 'WIP_NO_ACCT_PERIOD');
                                        --        l_err_msg :=  fnd_message.get;
                                        --        l_error_code := -1;
                                        --        HANDLE_ERROR( l_error_code, l_err_msg, l_stmt_num);
                                        --        GOTO skip_resched_validations;
                                        --    when others then
                                        --        l_err_msg := SQLERRM;
                                        --        l_error_code := SQLCODE;
                                        --        HANDLE_ERROR( l_error_code, l_err_msg, l_stmt_num);
                                        --        GOTO skip_resched_validations;
                                        --end;
                                        l_dummy := WSMPUTIL.GET_INV_ACCT_PERIOD(
                                                    x_err_code         => l_error_code,
                                                    x_err_msg          => l_err_msg,
                                                    p_organization_id  => v_wlji_org(v_index),
                                                    p_date             => trunc(nvl(v_wlji_date_released(v_index),sysdate)));
                                        IF (l_error_code <> 0) THEN
                                            HANDLE_ERROR( l_error_code, l_error_msg, l_stmt_num);
                                            GOTO skip_resched_validations;
                                        END IF;
                                        -- END: BUG3126650
                                    end if;
                                -- else if the job is being unreleased from a released state...
                                elsif p_old_date_released is not null and v_wlji_status_type(v_index) = 1 then
                                    v_wlji_date_released(v_index) := null;
                                     -- ignore release date populated by user in any other condition...
                                else
                                    v_wlji_date_released(v_index) := p_old_date_released;
                                end if;
                                -- bugfix 2697295 end

                                if ((p_old_status_type = 3 and v_wlji_status_type(v_index) = 1) OR
                                   (p_old_status_type = 6 and  v_wlji_status_type(v_index) = 1)) then

                                    if (discrete_charges_exist(v_wlji_wip_entity_id(v_index), v_wlji_org(v_index),0)) then
                                        l_error_code := -1;
                                        process_errorred_field('WIP',
                                                               'WIP_UNRLS_JOB/SCHED',
                                                               l_stmt_num);
                                        GOTO skip_resched_validations;

                                    -- osp begin
                                    else
                                        if wip_osp.po_req_exists (
                                                    v_wlji_wip_entity_id(v_index),
                                                    null,
                                                    v_wlji_org(v_index),
                                                    null, 5) then
                                            fnd_message.set_name('WSM', 'WSM_JOB_PURCHASE_REQ');
                                            l_err_msg := fnd_message.get;
                                            l_warning_count := l_warning_count + 1;
                                            handle_warning(p_err_msg => l_err_msg,
                                                           p_header_id => v_wlji_header_id(v_index),
                                                           p_request_id => v_wlji_request_id(v_index),
                                                           p_program_id => v_wlji_program_id(v_index),
                                                           p_program_application_id => v_wlji_program_application_id(v_index));
                                        end if;
                                    -- osp end
                                    end if;
                                end if;

l_stmt_num := 712;
                                -- abb H: optional scrap accounting
                                -- if (p_old_status_type IN (1,6)) and (v_wlji_status_type(v_index) = 3) and
                                --     WSMPLCVA.v_org(v_wlji_org(v_index)).ESTIMATED_SCRAP_ACCOUNTING = 1
                                --     and p_old_job_type = 1 then

                                if (p_old_status_type IN (1,6)) and (v_wlji_status_type(v_index) = 3) and
                                    wsmputil.WSM_ESA_ENABLED(p_wip_entity_id => v_wlji_wip_entity_id(v_index),
                                                             err_code => l_error_code,
                                                             err_msg => l_error_msg,
                                                             p_org_id => '',
                                                             p_job_type => '') = 1 then

                                    if v_wlji_class_code(v_index) is null then
                                        l_temp_cc := p_old_class_code;
                                    else
                                        l_temp_cc := v_wlji_class_code(v_index);
                                    end if;

                                    select est_scrap_account,
                                           est_scrap_var_account
                                    into   p_est_scrap_account,
                                           p_est_scrap_var_account
                                    from   wip_accounting_classes
                                    where  class_code = l_temp_cc
                                    and    organization_id = v_wlji_org(v_index);

                                    if p_est_scrap_account is null or p_est_scrap_var_account is null then
                                        v_wlji_process_status(v_index) := 3; --ERROR
                                        v_wlji_err_code(v_index) := -1;
                                        fnd_message.set_name('WSM','WSM_NO_WAC_SCRAP_ACC');
                                        fnd_message.set_token('CC', l_temp_cc);
                                        v_wlji_err_msg(v_index) := fnd_message.get;
                                        fnd_file.put_line(fnd_file.log, 'stmt_num: '|| l_stmt_num ||'  ' ||v_wlji_err_msg(v_index));
                                        fnd_file.new_line(fnd_file.log, 3);
                                        l_error_code := -1;
                                        GOTO skip_resched_validations;
                                    end if;
                                        if p_est_scrap_account is null or p_est_scrap_var_account is null then
                                        v_wlji_process_status(v_index) := 3; --ERROR
                                        v_wlji_err_code(v_index) := -1;
                                        fnd_message.set_name('WSM','WSM_NO_WAC_SCRAP_ACC');
                                        fnd_message.set_token('CC', l_temp_cc);
                                        v_wlji_err_msg(v_index) := fnd_message.get;
                                        fnd_file.put_line(fnd_file.log, 'stmt_num: '|| l_stmt_num ||'  ' ||v_wlji_err_msg(v_index));
                                        fnd_file.new_line(fnd_file.log, 3);
                                        l_error_code := -1;
                                        GOTO skip_resched_validations;
                                    end if;
                                end if;
                            END IF;  -- status
                        END IF;

l_stmt_num := 720;
                        --validate quantity

                        IF v_wlji_start_quantity(v_index) IS NULL THEN
                            v_wlji_start_quantity(v_index) := p_old_quantity;
                        ELSIF  v_wlji_start_quantity(v_index) = p_old_quantity THEN
                            NULL;
                        ELSIF v_wlji_firm_planned_flag(v_index) = 1 THEN
                            l_error_code := -1;
                            process_errorred_field('WSM',
                                                   'WSM_JOB_FIRM',
                                                   l_stmt_num);
                            GOTO skip_resched_validations;
                        ELSE

                            begin
                                if (p_old_status_type IN (3 ,6)
                                   AND v_wlji_status_type(v_index) IN (1,3,6)) then
                                    if (discrete_charges_exist(v_wlji_wip_entity_id(v_index), v_wlji_org(v_index),0)) then
                                        raise invalid_qnty_error;
                                    end if;
                                end if;
                            exception
                                when invalid_qnty_error then
                                    l_error_code := -1;
                                    process_errorred_field('WSM',
                                                           'WSM_QNTY_NOCHANGE',
                                                           l_stmt_num);
                                    GOTO skip_resched_validations;
                            end;

                        END IF; -- qty change

                        -- osp begin
                        -- create requisitions/additional reuisitions under following conditions:
                        -- 1. user updates only status from unreleased to released, quantity unchanged
                        -- 2. user updates only quantity (increases) for a released job, status is unchanged
                        -- 3. user updates staus to released, and increases quantity.

                        if WSMPLCVA.v_org(v_wlji_org(v_index)).PO_CREATION_TIME <> WIP_CONSTANTS.MANUAL_CREATION then

                            if (v_wlji_status_type(v_index) = 3 and p_old_status_type = 1) then
                                if wsmputil.check_osp_operation(v_wlji_wip_entity_id(v_index), l_osp_op_seq_num , v_wlji_org(v_index)) then
                                    l_atleast_one_osp_exists := l_atleast_one_osp_exists + 1;
                                    wip_osp.create_requisition(
                                            P_Wip_Entity_Id => v_wlji_wip_entity_id(v_index),
                                            P_Organization_Id => v_wlji_org(v_index),
                                            P_Repetitive_Schedule_Id => null,
                                            P_Operation_Seq_Num => l_osp_op_seq_num,
                                            P_Resource_Seq_Num => null,
                                            P_Run_ReqImport => WIP_CONSTANTS.NO);
                                end if; -- check_osp_operation
                            end if;

                            if (v_wlji_start_quantity(v_index) > p_old_quantity) AND v_wlji_status_type(v_index) = 3 then
                                wip_osp.create_additional_req(
                                            P_Wip_Entity_Id => v_wlji_wip_entity_id(v_index),
                                            P_Organization_id => v_wlji_org(v_index),
                                            P_Repetitive_Schedule_Id => null,
                                            P_Added_Quantity => (v_wlji_start_quantity(v_index) - p_old_quantity),
                                            P_Op_Seq => null);
                            end if;

                        end if; -- wip_constants.manual_creation
                        -- osp end


l_stmt_num := 721;
                        -- validate net-quantity

                        if p_old_job_type = 3 then
                            if v_wlji_net_quantity(v_index) < 0 or
                                v_wlji_net_quantity(v_index) > v_wlji_start_quantity(v_index) then
                                l_aux_mesg := '';
                                process_invalid_field('NET QUANTITY',
                                                      l_aux_mesg,
                                                      l_stmt_num);
                                l_error_code := -1;
                                GOTO skip_resched_validations;
                            end if;
                        end if; -- job type

                        if p_old_job_type = 1 then
                            if (v_wlji_net_quantity(v_index) is not null) and (v_wlji_net_quantity(v_index) <> p_old_quantity)
                               and (v_wlji_firm_planned_flag(v_index) = 1) then
                                l_error_code := -1;
                                process_errorred_field('WSM',
                                                       'WSM_JOB_FIRM',
                                                       l_stmt_num);
                                GOTO skip_resched_validations;
                            end if;

                            if (v_wlji_net_quantity(v_index) is not null) and (v_wlji_start_quantity(v_index) is null)
                               and (v_wlji_net_quantity(v_index) > p_old_quantity) then
                                l_aux_mesg := '';
                                process_invalid_field('NET QUANTITY',
                                                      l_aux_mesg,
                                                      l_stmt_num);
                                l_error_code := -1;
                                GOTO skip_resched_validations;
                            end if;

l_stmt_num := 722;
                            if v_wlji_net_quantity(v_index) is null then
                            begin
                                select
                                       decode(wdj.primary_item_id, null, 0,
                                       decode(wdj.net_quantity,
                                       wdj.start_quantity, v_wlji_start_quantity(v_index),
                                       least(wdj.net_quantity,
                                       nvl(v_wlji_start_quantity(v_index), wdj.net_quantity))))
                                into   v_wlji_net_quantity(v_index)
                                from   wip_discrete_jobs wdj
                                where  wdj.wip_entity_id  = v_wlji_wip_entity_id(v_index)
                                and    wdj.organization_id  = v_wlji_org(v_index);
                            exception
                                when others then
                                    l_error_code := SQLCODE;
                                    l_err_msg :=  'WSMLBJIB.launch_worker: stmt num= '||l_stmt_num||' '||SUBSTR(SQLERRM, 1,1000);
                                    handle_error(l_error_code, l_err_msg, l_stmt_num);
                                    GOTO skip_resched_validations;
                            end;
                            end if;

                        end if; -- job_type


--validate dates
l_stmt_num := 830;

                        if (
                            (v_wlji_firm_planned_flag(v_index) = 1)
                            AND
                            (
                            ((v_wlji_fusd(v_index) IS NOT NULL) AND (v_wlji_fusd(v_index) <> p_old_start_date))
                             OR
                             ((v_wlji_lucd(v_index) IS NOT NULL) AND (v_wlji_lucd(v_index) <> p_old_complete_date))
                            )
                        ) then
                            l_error_code := -1;
                             process_errorred_field('WSM',
                                                    'WSM_JOB_FIRM',
                                                    l_stmt_num);
                            GOTO skip_resched_validations;
                        end if;

                        IF (((v_wlji_fusd(v_index) IS NULL) AND (v_wlji_lucd(v_index) IS NULL)) OR
                            ((v_wlji_fusd(v_index) IS NOT NULL) AND (v_wlji_lucd(v_index) IS NOT NULL))) THEN
                            v_wlji_scheduling_method(v_index) := 3;
                        ELSE
                            v_wlji_scheduling_method(v_index) := 2;
                        END IF;


                        IF v_wlji_scheduling_method(v_index) = 3 THEN
                            IF (v_wlji_fusd(v_index) IS NULL) AND (v_wlji_lucd(v_index) IS NULL) THEN
                                v_wlji_fusd(v_index) := p_old_start_date;
                                v_wlji_lucd(v_index) := p_old_complete_date;
                            ELSIF ((v_wlji_fusd(v_index) > v_wlji_lucd(v_index)) OR
                                  ((v_wlji_fusd(v_index) <> p_old_start_date) AND
                                  discrete_charges_exist(v_wlji_wip_entity_id(v_index), v_wlji_org(v_index),1))) THEN
                                l_aux_mesg := '';
                                process_invalid_field('START DATE',
                                                      l_aux_mesg,
                                                      l_stmt_num);
                                l_error_code := -1;
                                GOTO skip_resched_validations;
                            END IF;
                        END IF;

                        IF v_wlji_scheduling_method(v_index) = 2 THEN
                            IF ((v_wlji_fusd(v_index) IS NOT NULL) AND (v_wlji_lucd(v_index) IS NULL)) THEN
                                IF ((v_wlji_fusd(v_index) <> p_old_start_date) AND
                                   discrete_charges_exist(v_wlji_wip_entity_id(v_index), v_wlji_org(v_index),1)) THEN
                                    l_aux_mesg := '';
                                    process_invalid_field('START DATE',
                                                          l_aux_mesg,
                                                          l_stmt_num);
                                    l_error_code := -1;
                                    GOTO skip_resched_validations;
                                ELSE
                                    v_wlji_lucd(v_index) := wsmputil.GET_SCHEDULED_DATE(
                                                            v_wlji_org(v_index),
                                                            v_wlji_item(v_index),
                                                            'F',
                                                            v_wlji_fusd(v_index),
                                                            --v_wlji_start_quantity(v_index),
                                                            l_error_code,
                                                            l_err_msg,
                                                            v_wlji_start_quantity(v_index));  --Fixed bug # 2313574
                                END IF;
                            ELSIF ((v_wlji_fusd(v_index) IS NULL) AND (v_wlji_lucd(v_index) IS NOT NULL)) THEN
                                    v_wlji_fusd(v_index) := wsmputil.GET_SCHEDULED_DATE (
                                                            v_wlji_org(v_index),
                                                            v_wlji_item(v_index),
                                                            'B',
                                                            v_wlji_lucd(v_index),
                                                            --v_wlji_start_quantity(v_index),
                                                            l_error_code,
                                                            l_err_msg,
                                                            v_wlji_start_quantity(v_index));  --Fixed bug # 2313574
                            END IF;
                        END IF;

                        if l_error_code <> 0 OR l_err_msg IS NOT NULL then
                            HANDLE_ERROR( l_error_code, l_err_msg, l_stmt_num);
                            l_error_code := -1;
                            GOTO skip_resched_validations;
                        end if;


                        --validate coproducts
l_stmt_num := 840;

                        if ((v_wlji_coproducts_supply(v_index) IS NOT NULL) and
                           (v_wlji_coproducts_supply(v_index) NOT IN (1,2))) then
                            l_aux_mesg := '';
                            process_invalid_field('COPRODUCTS SUPPLY',
                                                  l_aux_mesg,
                                                  l_stmt_num);
                            l_error_code := -1;
                            GOTO skip_resched_validations;
                        end if;

<< skip_resched_validations >>

                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;


                        /* -- commenting out Bug 2762029
                        -- setting the common routing and bill sequence id for update

                        if p_old_job_type = 1 then
                            p_common_routing_sequence_id := p_old_com_rtg_seq_id;
                            p_common_bill_sequence_id := p_old_com_bom_seq_id;
                        end if;
                        */

                        if p_old_job_type = 3 then
                            if p_old_status_type = 3 then
                                if p_change_bom_reference = 0 and p_change_routing_reference = 0 then
                                    p_common_routing_sequence_id := p_old_com_rtg_seq_id;
                                    p_common_bill_sequence_id := p_old_com_bom_seq_id;
                                end if;
                                if p_change_bom_reference = 1 and p_change_routing_reference = 1 then
                                    p_common_routing_sequence_id := p_old_com_rtg_seq_id;
                                    p_common_bill_sequence_id := p_old_com_bom_seq_id;
                                end if;
                                if p_change_bom_reference = 1 and p_change_routing_reference = 0 then
                                    p_common_routing_sequence_id := p_old_com_rtg_seq_id;
                                    p_common_bill_sequence_id := p_old_com_bom_seq_id;
                                end if;
                                if p_change_bom_reference = 0 and p_change_routing_reference = 1 then
                                    p_common_routing_sequence_id := p_old_com_rtg_seq_id;
                                    p_common_bill_sequence_id := p_old_com_bom_seq_id;
                                end if;
                            end if;

                            if p_old_status_type = 1 then
                                if p_change_bom_reference = 0 and p_change_routing_reference = 0 then
                                    p_common_routing_sequence_id := p_old_com_rtg_seq_id;
                                    p_common_bill_sequence_id := p_old_com_bom_seq_id;
                                end if;
                                if p_change_bom_reference = 1 and p_change_routing_reference = 1 then
                                    --p_common_routing_sequence_id := p_common_routing_sequence_id;
                                    p_common_bill_sequence_id := bom_seq_id;
                                end if;
                                if p_change_bom_reference = 1 and p_change_routing_reference = 0 then
                                    --p_common_routing_sequence_id := p_common_routing_sequence_id;
                                    p_common_bill_sequence_id := bom_seq_id;
                                end if;
                                if p_change_bom_reference = 0 and p_change_routing_reference = 1 then
                                    --p_common_routing_sequence_id := p_common_routing_sequence_id;
                                    p_common_bill_sequence_id := bom_seq_id;
                                end if;
                            end if;
                        end if; -- job type=3

                    end if; --load_type 6

--************************************************************************************************
--****************************** Reschedule Job Validations End **********************************
--************************************************************************************************




-- ==============================================================================================
-- VALIDATIONS END, WRITING INTO BASE TABLES BEGIN
-- ==============================================================================================

-- ==============================================================================================
-- WRITING INTO BASE TABLES FOR JOB CREATION
-- ==============================================================================================

                    if v_wlji_load_type(v_index) = 5 then
                    -- calling the build_lbji_info with p_rtg_op_seq_num as the rtg op_seq_num null...
                        build_lbji_info(
                            p_routing_seq_id => routing_seq_id,
                            p_common_bill_sequence_id => bom_seq_id,
                            p_explode_header_detail => null,
                            p_status_type => v_wlji_status_type(v_index),
                            p_class_code => v_wlji_class_code(v_index),
                            p_org => v_wlji_org(v_index),
                            p_wip_entity_id => v_wlji_wip_entity_id(v_index),
                            p_last_updt_date => v_wlji_last_updt_date(v_index),
                            p_last_updt_by => v_wlji_last_updt_by(v_index),
                            p_creation_date => v_wlji_creation_date(v_index),
                            p_created_by => v_wlji_created_by(v_index),
                            p_last_updt_login => v_wlji_last_updt_login(v_index),
                            p_request_id => v_wlji_request_id(v_index),
                            p_program_application_id => v_wlji_program_application_id(v_index),
                            p_program_id => v_wlji_program_id(v_index),
                            p_prog_updt_date => v_wlji_prog_updt_date(v_index),
                            p_source_line_id => v_wlji_source_line_id(v_index),
                            p_source_code =>  v_wlji_source_code(v_index),
                            p_description => v_wlji_description(v_index),
                            p_item => v_wlji_item(v_index),
                            p_job_type => v_wlji_job_type(v_index),
                            p_bom_reference_id =>  v_wlji_bom_reference_id(v_index),
                            p_routing_reference_id => v_wlji_routing_reference_id(v_index),
                            p_firm_planned_flag => v_wlji_firm_planned_flag(v_index),
                            p_wip_supply_type => v_wlji_wip_supply_type(v_index),
                            p_fusd => v_wlji_fusd(v_index),
                            p_lucd => v_wlji_lucd(v_index),
                            p_start_quantity => v_wlji_start_quantity(v_index),
                            p_net_quantity => v_wlji_net_quantity(v_index),
                            p_coproducts_supply => v_wlji_coproducts_supply(v_index),
                            p_bom_revision => v_wlji_bom_revision(v_index),
                            p_routing_revision => v_wlji_routing_revision(v_index),
                            p_bom_revision_date => v_wlji_bom_revision_date(v_index),
                            p_routing_revision_date => v_wlji_routing_revision_date(v_index),
                            p_lot_number => v_wlji_lot_number(v_index),
                            p_alt_bom_designator => v_wlji_alt_bom_designator(v_index),
                            p_alt_routing_designator => v_wlji_alt_routing_designator(v_index),
                            p_priority => v_wlji_priority(v_index),
                            p_due_date => v_wlji_due_date(v_index),
                            p_attribute_category => v_wlji_attribute_category(v_index),
                            p_attribute1 => v_wlji_attribute1(v_index),
                            p_attribute2 => v_wlji_attribute2(v_index),
                            p_attribute3 => v_wlji_attribute3(v_index),
                            p_attribute4 => v_wlji_attribute4(v_index),
                            p_attribute5 => v_wlji_attribute5(v_index),
                            p_attribute6 => v_wlji_attribute6(v_index),
                            p_attribute7 => v_wlji_attribute7(v_index),
                            p_attribute8 => v_wlji_attribute8(v_index),
                            p_attribute9 => v_wlji_attribute9(v_index),
                            p_attribute10 => v_wlji_attribute10(v_index),
                            p_attribute11 => v_wlji_attribute11(v_index),
                            p_attribute12 => v_wlji_attribute12(v_index),
                            p_attribute13 => v_wlji_attribute13(v_index),
                            p_attribute14 => v_wlji_attribute14(v_index),
                            p_attribute15 => v_wlji_attribute15(v_index),
                            p_job_name => v_wlji_job_name(v_index),
                            p_completion_subinventory => v_wlji_completion_subinventory(v_index),
                            p_completion_locator_id => v_wlji_completion_locator_id(v_index),
                            p_demand_class => v_wlji_demand_class(v_index),
                            p_project_id => v_wlji_project_id(v_index),
                            p_task_id => v_wlji_task_id(v_index),
                            p_schedule_group_id => v_wlji_schedule_group_id(v_index),
                            p_build_sequence => v_wlji_build_sequence(v_index),
                            p_line_id => v_wlji_line_id(v_index),
                            p_kanban_card_id => v_wlji_kanban_card_id(v_index),
                            p_overcompl_tol_type => v_wlji_overcompl_tol_type(v_index),
                            p_overcompl_tol_value => v_wlji_overcompl_tol_value(v_index),
                            p_end_item_unit_number => v_wlji_end_item_unit_number(v_index),
                            p_rtg_op_seq_num => null,
                            p_src_client_server => 0,
                            p_po_creation_time => WSMPLCVA.v_org(v_wlji_org(v_index)).PO_CREATION_TIME,
                            p_date_released => v_wlji_date_released(v_index),
                            p_error_code => l_error_code,
                            p_error_msg => l_error_msg);

                        if l_error_code <> 0 then
                            handle_error(l_error_code, l_error_msg,  l_stmt_num);
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;

                    end if; -- load_type 5


-- ==============================================================================================
-- WRITING INTO BASE TABLES FOR JOB UPDATE
-- ==============================================================================================


                    if v_wlji_load_type(v_index) = 6 then

                        -- if the user wants to update only the references, the following updates are not needed
                        if p_skip_updt = 0 then

                            if discrete_charges_exist(v_wlji_wip_entity_id(v_index), v_wlji_org(v_index),1) then
                                l_txnexist := 1;
                            else
                                l_txnexist := 0;
                            end if;


                            if v_wlji_allow_explosion(v_index) = 'Y' and v_wlji_status_type(v_index) <> 7 then
                            Begin
l_stmt_num := 1062;
                                if v_wlji_start_quantity(v_index) <> p_old_quantity then
                                    l_qntydiff := 1;
                                else
                                    l_qntydiff := 0;
                                end if;

                                UPDATE WIP_OPERATIONS
                                SET
                                       FIRST_UNIT_START_DATE = decode(l_txnexist,
                                                                      0, NVL(v_wlji_fusd(v_index), FIRST_UNIT_START_DATE),  -- bug 3394520
                                                                      FIRST_UNIT_START_DATE),
                                       FIRST_UNIT_COMPLETION_DATE = decode(l_txnexist,
                                                                           0, NVL(v_wlji_lucd(v_index), FIRST_UNIT_COMPLETION_DATE), -- bug 3394520
                                                                           FIRST_UNIT_COMPLETION_DATE),
                                       LAST_UNIT_START_DATE = decode(l_txnexist,
                                                                     0, NVL(v_wlji_fusd(v_index), LAST_UNIT_START_DATE),  -- bug 3394520
                                                                     LAST_UNIT_START_DATE),
                                       LAST_UNIT_COMPLETION_DATE = decode(l_txnexist,
                                                                          0, NVL(v_wlji_lucd(v_index), LAST_UNIT_COMPLETION_DATE), -- bug 3394520
                                                                          LAST_UNIT_COMPLETION_DATE),
                                       SCHEDULED_QUANTITY = ROUND(v_wlji_start_quantity(v_index), WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
                                       QUANTITY_IN_QUEUE = decode(v_wlji_status_type(v_index),
                                            1, (decode(OPERATION_SEQ_NUM,10,0,QUANTITY_IN_QUEUE)),
                                            3, (decode(p_old_status_type,
                                                    1, decode(OPERATION_SEQ_NUM,10,ROUND(v_wlji_start_quantity(v_index),
                                                             WIP_CONSTANTS.MAX_DISPLAYED_PRECISION), QUANTITY_IN_QUEUE),
                                                    decode(l_qntydiff,
                                                    1, decode(OPERATION_SEQ_NUM,
                                                              10,ROUND(v_wlji_start_quantity(v_index),WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
                                                              QUANTITY_IN_QUEUE),
                                                    QUANTITY_IN_QUEUE))),
                                       QUANTITY_IN_QUEUE),
                                       LAST_UPDATED_BY = v_wlji_last_updt_by(v_index),
                                       LAST_UPDATE_DATE = SYSDATE,
                                       LAST_UPDATE_LOGIN = v_wlji_last_updt_login(v_index),
                                       PROGRAM_UPDATE_DATE = SYSDATE,
                                       REQUEST_ID = v_wlji_request_id(v_index),
                                       PROGRAM_APPLICATION_ID = v_wlji_program_application_id(v_index),
                                       PROGRAM_ID = v_wlji_program_id(v_index)
                                WHERE  ORGANIZATION_ID = v_wlji_org(v_index)
                                AND    WIP_ENTITY_ID = v_wlji_wip_entity_id(v_index);

                                if lbji_debug = 'Y' then
                                    fnd_file.put_line(fnd_file.log, 'Updated '||SQL%ROWCOUNT||' rows into wo');
                                end if;

l_stmt_num := 1063;
                                UPDATE WIP_OPERATION_RESOURCES
                                SET    START_DATE = decode(l_txnexist,
                                                           0, NVL(v_wlji_fusd(v_index), START_DATE), -- bug 3394520
                                                           START_DATE),
                                       COMPLETION_DATE =  decode(l_txnexist,
                                                                 0, NVL(v_wlji_lucd(v_index), COMPLETION_DATE),
                                                                 COMPLETION_DATE),
                                       LAST_UPDATED_BY = v_wlji_last_updt_by(v_index),
                                       LAST_UPDATE_DATE = SYSDATE,
                                       LAST_UPDATE_LOGIN = v_wlji_last_updt_login(v_index),
                                       PROGRAM_UPDATE_DATE = SYSDATE,
                                       REQUEST_ID = v_wlji_request_id(v_index),
                                       PROGRAM_APPLICATION_ID = v_wlji_program_application_id(v_index),
                                       PROGRAM_ID = v_wlji_program_id(v_index)
                                WHERE  ORGANIZATION_ID = v_wlji_org(v_index)
                                AND    WIP_ENTITY_ID = v_wlji_wip_entity_id(v_index);

                                if lbji_debug = 'Y' then
                                    fnd_file.put_line(fnd_file.log, 'Updated '||SQL%ROWCOUNT||' rows into wor');
                                end if;

l_stmt_num := 1064;
                                --LBM enh: modified the expression on required_quantity
                                UPDATE WIP_REQUIREMENT_OPERATIONS WRO
                                SET    WRO.DATE_REQUIRED =
                                       (SELECT NVL(MIN(FIRST_UNIT_START_DATE), v_wlji_fusd(v_index))
                                        FROM   WIP_OPERATIONS
                                        WHERE  ORGANIZATION_ID = v_wlji_org(v_index)
                                        AND    WIP_ENTITY_ID = v_wlji_wip_entity_id(v_index)
                                        AND    OPERATION_SEQ_NUM = ABS(WRO.OPERATION_SEQ_NUM)),
                                       LAST_UPDATED_BY = v_wlji_last_updt_by(v_index),
                                       LAST_UPDATE_DATE = SYSDATE,
                                       LAST_UPDATE_LOGIN = v_wlji_last_updt_login(v_index),
                                       REQUEST_ID = v_wlji_request_id(v_index),
                                       PROGRAM_UPDATE_DATE = SYSDATE,
                                       PROGRAM_ID = v_wlji_program_id(v_index),
                                       PROGRAM_APPLICATION_ID = v_wlji_program_application_id(v_index),
                                       REQUIRED_QUANTITY = (QUANTITY_PER_ASSEMBLY * decode(wro.basis_type, 2, 1, ROUND(v_wlji_start_quantity(v_index), 6)))
                                WHERE  ORGANIZATION_ID = v_wlji_org(v_index)
                                AND    WIP_ENTITY_ID = v_wlji_wip_entity_id(v_index);

                                if lbji_debug = 'Y' then
                                    fnd_file.put_line(fnd_file.log, 'Updated '||SQL%ROWCOUNT||' rows into wro');
                                end if;

l_stmt_num := 1065;
                                -- abb H: optional scrap accounting

                                if (p_old_status_type IN (1,6) and v_wlji_status_type(v_index) = 3) and
                                    wsmputil.WSM_ESA_ENABLED(
                                            p_wip_entity_id => v_wlji_wip_entity_id(v_index),
                                            err_code => l_error_code,
                                            err_msg => l_error_msg,
                                            p_org_id => '',
                                            p_job_type => '') = 1 then

                                    select min(operation_seq_num)
                                    into   min_op_seq_num
                                    from   wip_operations
                                    where  wip_entity_id =  v_wlji_wip_entity_id(v_index);

                                    select bd.scrap_account, bd.est_absorption_account, wo.department_id
                                    into   l_scrap_account10, l_est_scrap_abs_account10, l_department_id
                                    from   bom_departments bd, wip_operations wo
                                    where  wo.wip_entity_id =  v_wlji_wip_entity_id(v_index)
                                    and    wo.operation_seq_num = min_op_seq_num
                                    and    bd.department_id = wo.department_id;

                                    if l_scrap_account10 is null or l_est_scrap_abs_account10 is null then
                                        v_wlji_process_status(v_index) := 3; --ERROR
                                        v_wlji_err_code(v_index) := -1;
                                        fnd_message.set_name('WSM','WSM_NO_SCRAP_ACC');
                                        fnd_message.set_token('DEPT_ID',to_char(l_department_id));
                                        v_wlji_err_msg(v_index) := fnd_message.get;
                                        fnd_file.put_line(fnd_file.log, 'stmt_num: '|| l_stmt_num ||'  '||v_wlji_err_msg(v_index));
                                        fnd_file.new_line(fnd_file.log, 3);
                                        l_error_code := -1;
                                        l_error_count := l_error_count + 1;
                                        GOTO skip_other_steps;
                                    end if;

                                    UPDATE WIP_OPERATION_YIELDS WOY
                                           SET SCRAP_ACCOUNT = nvl(l_scrap_account10, WOY.SCRAP_ACCOUNT),
                                           EST_SCRAP_ABSORB_ACCOUNT = nvl(l_est_scrap_abs_account10, WOY.EST_SCRAP_ABSORB_ACCOUNT)
                                    WHERE  WIP_ENTITY_ID = v_wlji_wip_entity_id(v_index)
                                    and    operation_seq_num = min_op_seq_num;

                                    if lbji_debug = 'Y' then
                                        fnd_file.put_line(fnd_file.log, 'Updated '||SQL%ROWCOUNT||' rows into woy');
                                    end if;

                                    select max(operation_seq_num)
                                    into   max_op_seq_num
                                    from   wip_operations
                                    where  wip_entity_id = v_wlji_wip_entity_id(v_index);

                                    select bd.scrap_account, bd.est_absorption_account,  wo.department_id
                                    into   l_scrap_account9999, l_est_scrap_abs_account9999, l_department_id
                                    from   bom_departments bd, wip_operations wo
                                    where  wo.wip_entity_id =  v_wlji_wip_entity_id(v_index)
                                    and    wo.operation_seq_num = max_op_seq_num
                                    and    bd.department_id = wo.department_id;

                                    if l_scrap_account9999 is null or l_est_scrap_abs_account9999 is null then
                                        v_wlji_process_status(v_index) := 3; --ERROR
                                        v_wlji_err_code(v_index) := -1;
                                        fnd_message.set_name('WSM','WSM_NO_SCRAP_ACC');
                                        fnd_message.set_token('DEPT_ID',to_char(l_department_id));
                                        v_wlji_err_msg(v_index) := fnd_message.get;
                                        fnd_file.put_line(fnd_file.log, 'stmt_num: '|| l_stmt_num ||'  '||v_wlji_err_msg(v_index));
                                        fnd_file.new_line(fnd_file.log, 3);
                                        l_error_code := -1;
                                        l_error_count := l_error_count + 1;
                                        GOTO skip_other_steps;
                                    end if;

                                    UPDATE WIP_OPERATION_YIELDS WOY
                                           SET SCRAP_ACCOUNT = nvl(l_scrap_account9999, WOY.SCRAP_ACCOUNT),
                                           EST_SCRAP_ABSORB_ACCOUNT = nvl(l_est_scrap_abs_account9999, WOY.EST_SCRAP_ABSORB_ACCOUNT)
                                    WHERE  WIP_ENTITY_ID = v_wlji_wip_entity_id(v_index)
                                    and    operation_seq_num = max_op_seq_num;

                                    if lbji_debug = 'Y' then
                                        fnd_file.put_line(fnd_file.log, 'Updated '||SQL%ROWCOUNT||' rows into woy');
                                    end if;

                                end if;

                            Exception
                                   when others then
                                   l_error_code := SQLCODE;
                                   l_error_msg :=  'WSMLBJIB.launch_worker: stmt num= '||l_stmt_num||' '||SUBSTR(SQLERRM, 1,1000);
                                   handle_error(l_error_code, l_error_msg,  l_stmt_num);
                                   l_error_count := l_error_count + 1;
                                   GOTO skip_other_steps;
                            End;
                            end if; -- allow_explosion

                        end if; --p_skip_updt
l_stmt_num := 1071;
                        Begin
                            if p_old_status_type <> 1 AND v_wlji_status_type(v_index) = 1 then
                                delete from wip_period_balances
                                where  wip_entity_id = v_wlji_wip_entity_id(v_index)
                                and    organization_id = v_wlji_org(v_index);
                                if lbji_debug = 'Y' then
                                    fnd_file.put_line(fnd_file.log, 'Deleted '||SQL%ROWCOUNT||' rows from wpb');
                                end if;
                            end if;

l_stmt_num := 1072;
                            if v_wlji_status_type(v_index) = 7 then --cancelled

                                -- osp begin
                                if wip_osp.po_req_exists ( v_wlji_wip_entity_id(v_index),
                                                           null,
                                                           v_wlji_org(v_index),
                                                           null, 5) then
                                       fnd_message.set_name('WIP', 'WIP_CANCEL_JOB/SCHED_OPEN_PO');
                                       l_err_msg := fnd_message.get;
                                       l_warning_count := l_warning_count + 1;
                                       handle_warning( p_err_msg => l_err_msg,
                                                       p_header_id => v_wlji_header_id(v_index),
                                                       p_request_id => v_wlji_request_id(v_index),
                                                       p_program_id => v_wlji_program_id(v_index),
                                                       p_program_application_id => v_wlji_program_application_id(v_index));
                                end if;
                                -- osp end

                                wip_picking_pvt.cancel_allocations(v_wlji_wip_entity_id(v_index),
                                               5,
                                               NULL,
                                               x_return_status,
                                               x_msg_data);

                                if x_return_status <> FND_API.G_RET_STS_SUCCESS then
                                    handle_error(x_return_status, x_msg_data,  l_stmt_num);
                                    l_error_count := l_error_count + 1;
                                    GOTO skip_other_steps;
                                else
                                    update wip_discrete_jobs wdj
                                    set    status_type = 7
                                    where  wdj.wip_entity_id = v_wlji_wip_entity_id(v_index);
                                    if lbji_debug = 'Y' then
                                        fnd_file.put_line(fnd_file.log, 'Updated status type to 7 in wdj');
                                    end if;
                    --
                        -- begin Bugfix 2820900 : Update the job name with sector lot extn. once canceled.
                    -- Note: Since status update for canceled jobs are not allowed currently, there's
                    -- no logic to remove the sector lot extn.
                    --
                            x_new_name := WSMPOPRN.update_job_name
                                        (p_wip_entity_id    => v_wlji_wip_entity_id(v_index),
                            p_subinventory      => v_wlji_completion_subinventory(v_index),
                            p_org_id        => v_wlji_org(v_index),
                                        p_txn_type      => 2,       -- COMPLETION
                                        p_update_flag       => TRUE,
                                        p_dup_job_name      => l_dup_job_name,
                                        x_error_code        => l_error_code,
                                        x_error_msg     => l_error_msg);

                   if l_error_code <> 0 then
                            handle_error(l_error_code, l_error_msg,  l_stmt_num);
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                   end if;

                   --
                   -- end bugfix 2820900
                   --
                                end if;

                                --abbKanban begin
                                if v_wlji_kanban_card_id(v_index) is not null then
                                    inv_kanban_pvt.Update_Card_Supply_Status
                                            (X_Return_Status => l_returnStatus,
                                             p_Kanban_Card_Id => v_wlji_kanban_card_id(v_index),
                                             p_Supply_Status => inv_kanban_pvt.g_supply_status_Exception);

                                    if ( l_returnStatus <> fnd_api.g_ret_sts_success ) then
                                        l_error_code := -1;
                                        fnd_message.set_name('WSM', 'WSM_KNBN_CARD_STS_FAIL');

                                        select meaning
                                        into   translated_meaning
                                        from   mfg_lookups
                                        where  lookup_type = 'MTL_KANBAN_SUPPLY_STATUS'
                                        and    lookup_code = 7
                                        and    upper(enabled_flag) = 'Y';

                                        fnd_message.set_token('STATUS',translated_meaning);
                                        l_error_msg := fnd_message.get;
                                        handle_error(l_error_code, l_error_msg,  l_stmt_num);
                                        l_error_count := l_error_count + 1;
                                        GOTO skip_other_steps;
                                    end if;

                                    update wip_discrete_jobs
                                    set    kanban_card_id = null
                                    where  wip_entity_id =  v_wlji_wip_entity_id(v_index);

                                end if;
                                --abbKanban end


                            else
l_stmt_num := 1073;
                                -- bug 2762029 modification begin
                                UPDATE      WIP_DISCRETE_JOBS WDJ
                                set         last_updated_by = v_wlji_last_updt_by(v_index),
                                            last_update_login = v_wlji_last_updt_login(v_index),
                                            request_id = v_wlji_request_id(v_index),
                                            program_application_id = v_wlji_program_application_id(v_index),
                                            program_id = v_wlji_program_id(v_index),
                                            program_update_date = sysdate,
                                            last_update_date = sysdate,
                                            bom_reference_id = v_wlji_bom_reference_id(v_index),
                                            routing_reference_id = v_wlji_routing_reference_id(v_index),
                                            common_bom_sequence_id = p_common_bill_sequence_id,
                                            common_routing_sequence_id = p_common_routing_sequence_id,
                                            bom_revision = v_wlji_bom_revision(v_index),
                                            routing_revision = v_wlji_routing_revision(v_index),
                                            bom_revision_date = v_wlji_bom_revision_date(v_index),
                                            routing_revision_date = v_wlji_routing_revision_date(v_index),
                                            alternate_bom_designator = v_wlji_alt_bom_designator(v_index),
                                            alternate_routing_designator = v_wlji_alt_routing_designator(v_index),
                                            firm_planned_flag = v_wlji_firm_planned_flag(v_index),
                                            start_quantity = nvl(round(v_wlji_start_quantity(v_index), wip_constants.max_displayed_precision),
                                                        wdj.start_quantity),
                                            net_quantity = nvl(round(v_wlji_net_quantity(v_index), wip_constants.max_displayed_precision),
                                                        wdj.net_quantity),
                                            status_type = nvl(v_wlji_status_type(v_index),wdj.status_type),
                                            date_released = v_wlji_date_released(v_index), -- bug 2697295
                                            scheduled_start_date = decode(l_txnexist, 0,
                                                            trunc(v_wlji_fusd(v_index),'MI'), wdj.scheduled_start_date),
                                            scheduled_completion_date = trunc(v_wlji_lucd(v_index),'MI'),
                                            completion_locator_id = v_wlji_completion_locator_id(v_index),
                                            completion_subinventory = v_wlji_completion_subinventory(v_index),
                                            coproducts_supply = nvl(v_wlji_coproducts_supply(v_index), wdj.coproducts_supply),
                                            -- BA: BUG3272873
                                            source_code = nvl(v_wlji_source_code(v_index),wdj.source_code),
                                            source_line_id = nvl(v_wlji_source_line_id(v_index),wdj.source_line_id),
                                            overcompletion_tolerance_type = nvl(v_wlji_overcompl_tol_type(v_index),
                                                                wdj.overcompletion_tolerance_type),
                                            overcompletion_tolerance_value = nvl(v_wlji_overcompl_tol_value(v_index),
                                                                wdj.overcompletion_tolerance_value),
                                            priority = nvl(v_wlji_priority(v_index),wdj.priority),
                                            due_date = nvl(v_wlji_due_date(v_index),wdj.due_date),
                                            attribute_category = nvl(v_wlji_attribute_category(v_index),wdj.attribute_category),
                                            attribute1 = nvl(v_wlji_attribute1(v_index),wdj.attribute1),
                                            attribute2 = nvl(v_wlji_attribute2(v_index),wdj.attribute2),
                                            attribute3 = nvl(v_wlji_attribute3(v_index),wdj.attribute3),
                                            attribute4 = nvl(v_wlji_attribute4(v_index),wdj.attribute4),
                                            attribute5 = nvl(v_wlji_attribute5(v_index),wdj.attribute5),
                                            attribute6 = nvl(v_wlji_attribute6(v_index),wdj.attribute6),
                                            attribute7 = nvl(v_wlji_attribute7(v_index),wdj.attribute7),
                                            attribute8 = nvl(v_wlji_attribute8(v_index),wdj.attribute8),
                                            attribute9 = nvl(v_wlji_attribute9(v_index),wdj.attribute9),
                                            attribute10 = nvl(v_wlji_attribute10(v_index),wdj.attribute10),
                                            attribute11 = nvl(v_wlji_attribute11(v_index),wdj.attribute11),
                                            attribute12 = nvl(v_wlji_attribute12(v_index),wdj.attribute12),
                                            attribute13 = nvl(v_wlji_attribute13(v_index),wdj.attribute13),
                                            attribute14 = nvl(v_wlji_attribute14(v_index),wdj.attribute14),
                                            attribute15 = nvl(v_wlji_attribute15(v_index),wdj.attribute15),
                                            -- EA: BUG3272873
                                            est_scrap_account = nvl(p_est_scrap_account, wdj.est_scrap_account),
                                            est_scrap_var_account = nvl(p_est_scrap_var_account, wdj.est_scrap_var_account),
                                            description = nvl(RTRIM(v_wlji_description(v_index)), wdj.description)
                                            where wdj.wip_entity_id = v_wlji_wip_entity_id(v_index);
                                            --returning wdj.date_released into p_date_released;
                                -- bug 2762029 modification end
                            end if; -- update jobs for which status is not cancelled

                            if lbji_debug = 'Y' then
                                fnd_file.put_line(fnd_file.log, 'Updated '||SQL%ROWCOUNT||' rows of wdj');
                            end if;


l_stmt_num := 1074;
                            UPDATE WIP_ENTITIES WE
                            set    description = nvl(v_wlji_description(v_index), we.description),
                                   last_updated_by = v_wlji_last_updt_by(v_index),
                                   last_update_login = v_wlji_last_updt_login(v_index),
                                   request_id = v_wlji_request_id(v_index),
                                   program_application_id = v_wlji_program_application_id(v_index),
                                   program_id = v_wlji_program_id(v_index),
                                   program_update_date = v_wlji_prog_updt_date(v_index),
                                   last_update_date = v_wlji_last_updt_date(v_index)
                            where  we.wip_entity_id = v_wlji_wip_entity_id(v_index);

                            if lbji_debug = 'Y' then
                                fnd_file.put_line(fnd_file.log, 'Updated '||SQL%ROWCOUNT||' rows into we');
                            end if;

                        Exception
                           when others then
                           l_error_code := SQLCODE;
                           l_error_msg :=  'WSMLBJIB.launch_worker: stmt num= '||l_stmt_num||' '||SUBSTR(SQLERRM, 1,1000);
                           handle_error(l_error_code, l_error_msg,  l_stmt_num);
                           l_error_count := l_error_count + 1;
                           GOTO skip_other_steps;
                        End;

                    end if; -- load_type 6

l_stmt_num := 1080;

                    if (
                       (v_wlji_load_type(v_index) = 6 AND
                        v_wlji_status_type(v_index) = WIP_CONSTANTS.RELEASED and
                        p_old_status_type = WIP_CONSTANTS.UNRELEASED)
                    ) then

                        if ((v_wlji_load_type(v_index) = 6) AND (v_wlji_class_code(v_index) is NULL)) then
                            v_wlji_class_code(v_index) := p_old_class_code;
                        end if;
                        fnd_file.put_line(fnd_file.log, 'date released ****: '||v_wlji_date_released(v_index));
                        insert_into_period_balances (
                                p_wip_entity_id =>  v_wlji_wip_entity_id(v_index),
                                p_organization_id =>  v_wlji_org(v_index),
                                p_class_code =>   v_wlji_class_code(v_index),
                                p_release_date => v_wlji_date_released(v_index), --p_date_released,
                                p_error_code => l_error_code,
                                p_err_msg => l_error_msg
                        );

                        if l_error_code <> 0 then
                            handle_error(l_error_code, l_error_msg,  l_stmt_num);
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;
                    end if;



-- ==============================================================================================
--  MATERIAL TRANSACTION FOR MODE 2 JOB CREATE
-- ==============================================================================================

l_stmt_num := 1100;
                    -- *** material transaction for mode 2 jobs begin ***
                    if v_wlji_mode_flag(v_index) = 2 then

                        IF WSMPLCVA.v_org(v_wlji_org(v_index)).MAX_ORG_ACC_PERIODS is null or
                           WSMPLCVA.v_org(v_wlji_org(v_index)).MAX_ORG_ACC_PERIODS = 0
                        then
                             l_error_code := -1;
                             process_errorred_field('WIP',
                                                    'WIP_NO_ACCT_PERIOD',
                                                     l_stmt_num);
                            GOTO skip_mat_trans;
                        end if;

                        if WSMPLCVA.v_org(v_wlji_org(v_index)).MAX_STK_LOC_CNTRL is null then
                            WSMPLCVA.v_org(v_wlji_org(v_index)).MAX_STK_LOC_CNTRL := 1;
                        end if;

l_stmt_num := 1120;
                        /* commented out by BBK for DUAL usage reduction.
                        select mtl_material_transactions_s.nextval
                        into txn_tmp_header_id
                        from dual;
                        */

l_stmt_num := 1140;
                        Begin  -- material transaction

                            insert into mtl_material_transactions_temp(
                                    last_update_date,
                                    creation_date,
                                    last_updated_by,
                                    created_by,
                                    last_update_login,
                                    transaction_header_id,
                                    transaction_source_id,
                                    inventory_item_id,
                                    organization_id,
                                    revision,
                                    subinventory_code,
                                    locator_id,
                                    transaction_quantity,
                                    primary_quantity,
                                    transaction_uom,
                                    transaction_type_id,
                                    transaction_action_id,
                                    transaction_source_type_id,
                                    transaction_date,
                                    acct_period_id,
                                    source_code,
                                    source_line_id,
                                    wip_entity_type,
                                    negative_req_flag,
                                    operation_seq_num,
                                    wip_supply_type,
                                    wip_commit_flag,
                                    process_flag,
                                    posting_flag,
                                    transaction_temp_id)
                            values (
                                    v_wlji_last_updt_date(v_index),
                                    v_wlji_creation_date(v_index),
                                    v_wlji_last_updt_by(v_index),
                                    v_wlji_created_by(v_index),
                                    v_wlji_last_updt_login(v_index),
                                    txn_header_id,                                            /* TRANSACTION_HEADER_ID */
                                    v_wlji_wip_entity_id(v_index),                            /* TRANSACTION_SOURCE_ID */
                                    v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id, /* INVENTORY_ITEM_ID */
                                    v_wlji_org(v_index),                                      /* ORGANIZATION_ID */
                                    v_wsli(v_wlji_source_line_id(v_index)).revision,          /* REVISION */
                                    v_wsli(v_wlji_source_line_id(v_index)).subinventory_code, /* SUBINVENTORY_CODE */
                                    v_wsli(v_wlji_source_line_id(v_index)).locator_id,
                                    -l_quantity_tobe_issued,
                                    ---1 * v_wsli(v_wlji_source_line_id(v_index)).quantity,   /* TRANSACTION_QUANTITY */
                                    ---1 * v_wsli(v_wlji_source_line_id(v_index)).quantity,   /* PRIMARY_QUANTITY */
                                    -l_quantity_tobe_issued,
                                    v_wsli(v_wlji_source_line_id(v_index)).primary_uom_code,  /* UNIT_OF_MEASURE */
                                    35,                                                       /* TRANSACTION_TYPE_ID */
                                    1,                                                        /* TRANSACTION_ACTION_ID */
                                    5,                                                        /* TRANSACTION_SOURCE_TYPE_ID */
                                    SYSDATE,                                                  /* TRANSACTION_DATE */
                                    WSMPLCVA.v_org(v_wlji_org(v_index)).MAX_ORG_ACC_PERIODS,  /*ACCT_PERIOD_ID */
                                    'WSM',
                                    to_char(v_wlji_source_line_id(v_index)),                  /* SOURCE_LINE_ID */
                                    5,                                                        /* WIP_ENTITY_TYPE */
                                    1,                                                        /* neg req flag */
                                    10,                                                       /* op seq */
                                    '',                                                       /* supply type */
                                    'N',                                                      /* WIP_COMMIT_FLAG */
                                    'Y',                                                      /* PROCESS_FLAG */
                                    'Y',                                                      /* POSTING_FLAG */
                                    -- txn_tmp_header_id                                      /* Transaction Temp Id */
                                    mtl_material_transactions_s.nextval                       /* Transaction Temp Id */
                                    ) RETURNING transaction_temp_id into txn_tmp_header_id;

                            if lbji_debug = 'Y' then
                                fnd_file.put_line(fnd_file.log, 'Inserted '||SQL%ROWCOUNT||' rows into mmtt');
                            end if;

l_stmt_num := 1160;

                            INSERT INTO MTL_TRANSACTION_LOTS_TEMP (
                                    transaction_temp_id,
                                    last_update_date,
                                    creation_date,
                                    last_updated_by,
                                    created_by,
                                    last_update_login,
                                    transaction_quantity,
                                    primary_quantity,
                                    lot_number)
                            values (
                            txn_tmp_header_id,
                                    v_wlji_last_updt_date(v_index),
                                    v_wlji_creation_date(v_index),
                                    v_wlji_last_updt_by(v_index),
                                    v_wlji_created_by(v_index),
                                    v_wlji_last_updt_login(v_index),
                                    -l_quantity_tobe_issued,
                                    ---1 * v_wsli(v_wlji_source_line_id(v_index)).quantity,
                                    ---1 * v_wsli(v_wlji_source_line_id(v_index)).quantity,
                                    -l_quantity_tobe_issued,
                                    v_wsli(v_wlji_source_line_id(v_index)).lot_number);

                            if lbji_debug = 'Y' then
                                fnd_file.put_line(fnd_file.log, 'Inserted '||SQL%ROWCOUNT||' rows into mtlt');
                            end if;

l_stmt_num := 1160;
                            UPDATE WIP_REQUIREMENT_OPERATIONS
                            set    wip_supply_type = 1
                            where  wip_entity_id = v_wlji_wip_entity_id(v_index)
                            and    operation_seq_num = 10
                            and    inventory_item_id = v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id;


                        Exception  -- material transaction
                            when others then
                                l_error_code := SQLCODE;
                                l_error_msg :=  'WSMLBJIB.launch_worker: stmt num= '||l_stmt_num||' '||SUBSTR(SQLERRM, 1,1000);
                                handle_error(l_error_code, l_error_msg,  l_stmt_num);
                                GOTO skip_mat_trans;
                        End; -- material transaction

<< skip_mat_trans >>

                        if l_error_code <> 0 then
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        end if;

                        l_atleast_one_row_in_mmtt := l_atleast_one_row_in_mmtt + 1;
                        l_src_lot_number:=v_wsli(v_wlji_source_line_id(v_index)).lot_number;        -- LOTATTR
                        l_src_inv_item_id:=v_wsli(v_wlji_source_line_id(v_index)).inventory_item_id;    -- LOTATTR

                    end if; -- for mode 2
                    -- *** material transaction for mode 2 jobs end ***

                    /* LotAttr */
                    IF p_old_status_type in (0,1,3,6) THEN  -- Initialized Value,
                                --Unreleased, released, Hold
l_stmt_num := 1170;
                        IF (lbji_debug='Y') THEN
                            fnd_file.put_line(fnd_file.log, 'Before Calling WSM_LotAttr_PVT.create_update_lotattr');
                        END IF;
                        WSM_LotAttr_PVT.create_update_lotattr(
                                x_err_code          => l_error_code,
                                x_err_msg           => l_error_msg,
                                p_wip_entity_id     => v_wlji_wip_entity_id(v_index),
                                p_org_id            => v_wlji_org(v_index),
                                p_intf_txn_id       => v_wlji_header_id(v_index),
                                p_intf_src_code     => 'WSM',
                                p_src_lot_number    => l_src_lot_number,
                                p_src_inv_item_id   => l_src_inv_item_id);
                        IF (l_error_code <> 0) THEN
                            handle_error(l_error_code, l_error_msg,  l_stmt_num);
                            l_error_count := l_error_count + 1;
                            GOTO skip_other_steps;
                        END IF;
                        IF (lbji_debug='Y') THEN
                           fnd_file.put_line(fnd_file.log, 'WSM_LotAttr_PVT.create_update_lotattr returned Success');
                        END IF;
l_stmt_num := 1180;
                    END IF; -- p_old_status_type in (1,3,6)

                EXCEPTION -- main block
                    when others then
                        l_error_code := SQLCODE;
                        l_error_msg :=  'WSMLBJIB.launch_worker: stmt num= '||l_stmt_num||' '||SUBSTR(SQLERRM, 1,1000);
                        handle_error(l_error_code, l_error_msg,  l_stmt_num);
                        l_error_count := l_error_count + 1;

                END; -- main block

<<skip_other_steps>>


                -- *** write into output file ***
                -- note that this is a rudimentary piece of commentary on the job created,
                -- or failed to create because there's no customer requirement on this.
                if v_wlji_load_type(v_index) = 5 then
                    fnd_file.put_line(fnd_file.output, '-------------------------------------------------------');
                    --bug 5051783:Replaced org_organization_definitions with mtl_parameters.
                    select organization_code
                    into   org_code
                    --from   ORG_ORGANIZATION_DEFINITIONS
                    from   mtl_parameters
                    where  organization_id = v_wlji_org(v_index);

                    fnd_file.put_line(fnd_file.output, 'Organization: '||org_code);
                    fnd_file.put_line(fnd_file.output, 'Job_name: '|| v_wlji_job_name(v_index));
                    select meaning
                    into   job_type_meaning
                    from   mfg_lookups
                    where  lookup_type = 'WIP_DISCRETE_JOB'
                    and    lookup_code = v_wlji_job_type(v_index);
                    fnd_file.put_line(fnd_file.output, 'Job Type: '|| job_type_meaning);

                    begin
                        select unique(concatenated_segments)
                        into   assembly_name
                        from   mtl_system_items_kfv
                        where  inventory_item_id = v_wlji_item(v_index)
                        and    organization_id = v_wlji_org(v_index);
                    exception
                        when others then
                            assembly_name := 'Unknown';
                    end;
                    fnd_file.put_line(fnd_file.output, 'Assembly: '|| assembly_name);
                    fnd_file.put_line(fnd_file.output, 'Quantity: '|| v_wlji_start_quantity(v_index));
                    fnd_file.put_line(fnd_file.output, 'Start Date: '|| v_wlji_fusd(v_index));
                    fnd_file.put_line(fnd_file.output, 'Completion Date: '|| v_wlji_lucd(v_index));
                    fnd_file.put_line(fnd_file.output, 'Kanban Card: '|| v_wlji_kanban_card_id(v_index));
                    if v_wlji_process_status(v_index) <> 3 then
                        status_name := 'Success';
                    else
                        status_name := 'Falied To Create';
                    end if;
                    fnd_file.put_line(fnd_file.output, 'Process Status: '|| Status_name);
                    if v_wlji_process_status(v_index) = 3 then
                    fnd_file.put_line(fnd_file.output, v_wlji_err_msg(v_index));
                    end if;
                    fnd_file.put_line(fnd_file.output, '-------------------------------------------------------');
                end if; -- load type 5
                -- *** write into output file end***




                -- *** mark the rows without error to be deleted ***

                if v_wlji_err_code(v_index) <> 0 then
                    rollback to row_skip;
                end if;

                if v_wlji_process_status(v_index) <> 3 then
                    v_wlji_process_status(v_index) := 5; -- 5 : complete without error
                    if lbji_debug = 'Y' then
                        fnd_file.put_line(fnd_file.log, 'Everything OK, changing the status of the row to 5..');
                    end if;
                else
                    -- abbkanban begin
                    if v_wlji_kanban_card_id(v_index) is not null then
                        inv_kanban_pvt.Update_Card_Supply_Status(
                                X_Return_Status => l_returnStatus,
                                p_Kanban_Card_Id => v_wlji_kanban_card_id(v_index),
                                p_Supply_Status => inv_kanban_pvt.g_supply_status_Exception);

                        if ( l_returnStatus <> fnd_api.g_ret_sts_success ) then
                            l_error_code := -1;
                            fnd_message.set_name('WSM', 'WSM_KNBN_CARD_STS_FAIL');
                            select meaning
                            into   translated_meaning
                            from   mfg_lookups
                            where  lookup_type = 'MTL_KANBAN_SUPPLY_STATUS'
                            and    lookup_code = 7
                            and    upper(enabled_flag) = 'Y';

                            fnd_message.set_token('STATUS',translated_meaning);
                            l_error_msg := fnd_message.get;
                            handle_error(l_error_code, l_error_msg,  l_stmt_num);
                            l_error_count := l_error_count + 1;
                        end if;

                        update wip_discrete_jobs
                        set    kanban_card_id = null
                        where  wip_entity_id =  v_wlji_wip_entity_id(v_index);

                    end if;
                    -- abbkanban end

                    dummy_err_code := 0;
                    dummy_err_msg := NULL;
                    wsmputil.WRITE_TO_WIE (
                        v_wlji_header_id(v_index),
                        substr(v_wlji_err_msg(v_index),1,2000),
                        v_wlji_request_id(v_index),
                        v_wlji_program_id(v_index),
                        v_wlji_program_application_id(v_index),
                        1,
                        dummy_err_code,
                        dummy_err_msg );

                    if dummy_err_code <> 0 then
                        fnd_file.put_line(fnd_file.log, '*** WARNING ***');
                        fnd_file.put_line(fnd_file.log, 'WSMPLBJI.launch_worker: '||dummy_err_msg);
                        l_error_count := l_error_count + 1;
                    end if;
                end if;

                v_index := v_wlji_header_id.next(v_index);

            end loop; -- inner loop

            if lbji_debug = 'Y' then
                fnd_file.put_line(fnd_file.log, '                    ');
                fnd_file.put_line(fnd_file.log, '                    ');
                fnd_file.put_line(fnd_file.log, '                    ');
                fnd_file.put_line(fnd_file.log, '                    ');
            end if;

            -- *** RETCODE return values ***
            --      0: success
            --      1: success with warning
            --      2: error
            -- *** RETCODE return values ***

            if l_warning_count <> 0 then
                retcode := 1;
                errbuf := 'The interface process produced atleast one warning message';
                fnd_file.put_line(fnd_file.log,errbuf);
                conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',errbuf);
            end if;

            if l_error_count <> 0 then
                retcode := 1;
                errbuf := 'The interface process marked atleast one row as errored';
                fnd_file.put_line(fnd_file.log,errbuf);
                conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',errbuf);
            end if;

            -- *** bulk update wsm_lot_job_interface ***
            forall i in v_wlji_process_status.first..v_wlji_process_status.last
            update  wsm_lot_job_interface
            set     process_status = v_wlji_process_status(i),
                    error_code = v_wlji_err_code(i),
                    error_msg = v_wlji_err_msg(i),
                    request_id = v_wlji_request_id(i),
                    program_id = v_wlji_program_id(i),
                    program_application_id = v_wlji_program_application_id(i)
            where   header_id = v_wlji_header_id(i);

            l_boolean_success := false;

            if l_atleast_one_row_in_mmtt <>0 THEN
                fnd_file.put_line(fnd_file.log, 'Invoking Inventory Worker with header id: '||to_char(txn_header_id));
                l_inv_worker_req_id := FND_REQUEST.submit_request (
                                    'INV', 'INCTCW', NULL, NULL, FALSE,
                                    --to_char(txn_header_id), '1', NULL, NULL); -- bug 3733798
                                    to_char(txn_header_id), '4', NULL, NULL);   -- bug 3733798

                commit;

                fnd_file.put_line(fnd_file.log,'Material Transaction temp_header_id is '
                            ||to_char(txn_header_id));

                if l_inv_worker_req_id = 0 then

                    retcode := 1;
                    errbuf:= 'WSMPLBJI. Inventory worker returned failure '||
                             '(Transaction_header_id=' ||txn_header_id||') : '|| SUBSTRB(SQLERRM,1,1000);
                    fnd_file.put_line(fnd_file.log,errbuf);
                    conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',errbuf);
                    update  wsm_lot_job_interface
                    set     process_status = 4,
                            error_code = -2,
                            error_msg = l_error_msg
                    where   mode_flag = 2;

                else -- req_id <> 0

                    fnd_file.put_line(fnd_file.log,'Inventory Transaction Worker request_id is '
                            ||to_char(l_inv_worker_req_id));
                    req_wait := FND_CONCURRENT.WAIT_FOR_REQUEST
                            (request_id => l_inv_worker_req_id,
                             interval => 10, -- 10 seconds interval
                             max_wait => 36000, -- 10 Hours maximum wait.
                             phase => req_phase,
                             status => req_status,
                             dev_phase => req_devphase,
                             dev_status => req_devstatus,
                             message => req_message);

                    fnd_file.put_line(fnd_file.log, 'Inventory Transaction Worker status is '
                                                                                            ||req_status);
                    fnd_file.put_line(fnd_file.log, 'Inventory Transaction Worker Completion Message: '
                                                                                            ||req_message);

                    if  req_devphase <> 'COMPLETE' OR  req_devstatus <> 'NORMAL' THEN
                        retcode := 1;
                        errbuf:= 'WSMPLBJI. Inventory worker returned failure '||
                                 '(Transaction_header_id=' ||txn_header_id||') : '||
                                 SUBSTRB(SQLERRM,1,1000);
                        fnd_file.put_line(fnd_file.log,errbuf);
                        conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',errbuf);
                    end if;

                    check_errored_mmtt_records(txn_header_id, l_error_code, l_error_msg);

                    if (l_error_code <> 0) or (l_error_msg is not null ) then
                        retcode := 1;
                        errbuf:= 'WSMPLBJI. Errored Records in mmtt ' ||
                                 '(Transaction_header_id=' ||txn_header_id||') : '|| SUBSTRB(SQLERRM,1,1000);
                        fnd_file.put_line(fnd_file.log,errbuf);
                        conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',errbuf);
                    end if;

                end if;  -- req_id
            end if; -- l_atleast_one_row_in_mmtt


            -- *** delete marked rows (without error rows) from wlji ***
            Begin
                -- bug 3126758
                l_del_int_prof_value := fnd_profile.value('WSM_INTERFACE_HISTORY_DAYS');

                if l_atleast_one_row_in_mmtt <> 0 then
                    delete  from wsm_starting_lots_interface
                    where   header_id IN
                            (select wlji.source_line_id
                            from    wsm_lot_job_interface wlji
                            where   wlji.process_status = 5
                            --and     wlji.group_id = batch_group_id
                            and     NVL(transaction_date, creation_date)
                                        <= decode(l_del_int_prof_value,
                                                  null,
                                                  NVL(transaction_date, creation_date) -1,
                                                  SYSDATE-l_del_int_prof_value)
                            );

                    if lbji_debug = 'Y' then
                        fnd_file.put_line(fnd_file.log, 'Deleted '||SQL%ROWCOUNT||' rows from wsli');
                    end if;
                end if;

                delete  from wsm_lot_job_interface
                where   process_status = 5
                --and     group_id = batch_group_id
                and     NVL(transaction_date, creation_date)
                            <= decode(l_del_int_prof_value,
                                      null,
                                      NVL(transaction_date, creation_date) -1,
                                      SYSDATE-l_del_int_prof_value);

                if lbji_debug = 'Y' then
                    fnd_file.put_line(fnd_file.log, 'Deleted '||SQL%ROWCOUNT||' rows from wlji');
                end if;

            Exception
                when others then
                    retcode := 1;
                    errbuf := 'Deletion of successful rows from interface table(s) failed';
                    fnd_file.put_line(fnd_file.log,errbuf);
                    conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',errbuf);
            End;

            commit;

        end if; -- if c_wlji_1%rowcount - prev_rowcount <> 0 then process data

        prev_rowcount := c_wlji_1%rowcount;
        exit when c_wlji_1%rowcount = alotted_rows;

    end loop; -- main loop
    close c_wlji_1;

    -- osp begin
    if l_atleast_one_osp_exists <> 0 then
        l_req_request_id := fnd_request.submit_request(
                'PO', 'REQIMPORT', NULL, NULL, FALSE,'WIP', NULL, 'ITEM',
                NULL ,'N', 'Y' , chr(0), NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        ) ;

        fnd_file.put_line(fnd_file.log,'Concurrent Request for Requisition Inport Submitted');
        fnd_file.put_line(fnd_file.log,'Request_id: '||l_req_request_id);
    end if;
    -- osp end

    -- phantom project
    delete from bom_explosion_temp where group_id = wsmpwrot.explosion_group_id;
    wsmpwrot.explosion_group_id := null;
    wsmpwrot.use_phantom_routings := null;

    commit;

    if l_error_count = 0 then
        retcode := 0;
        errbuf := '';
        conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('SUCCESS',errbuf);
    end if;


EXCEPTION  -- for launch_worker
    when abort_request then
        rollback to back_to_square_one;
        retcode := 2;
        errbuf := 'WSMLBJIB.launch_worker_1159: stmt num= '||l_stmt_num||' '||SUBSTR(SQLERRM, 1,240);
        fnd_file.put_line(fnd_file.log,errbuf);
        conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',errbuf);
    when others then
        rollback to back_to_square_one;
        retcode := 2;
        errbuf := 'WSMLBJIB.launch_worker_1159: stmt num= '||l_stmt_num||' '||SUBSTR(SQLERRM, 1,240);
        fnd_file.put_line(fnd_file.log,errbuf);
        conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',errbuf);

END launch_worker_1159;

END WSMPLBJI;

/
