--------------------------------------------------------
--  DDL for Package WSM_LBJ_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_LBJ_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: WSMVLJIS.pls 120.1.12000000.1 2007/01/12 05:38:08 appldev ship $ */

lbji_debug      varchar2(1):= fnd_profile.value('mrp_debug');
g_no_of_workers number := fnd_profile.value('wsm_lbjimport_worker');
g_batch_size    number := fnd_profile.value('wsm_lbjimport_batchsize');

/* define constance for load_type */
WSM_LOAD_RES        number := 1;        -- load a resource
WSM_LOAD_COMP       number := 2;        -- load a component
WSM_LOAD_OP         number := 3;        -- load an operation
WSM_LOAD_RES_USE    number := 4;        -- load resource usage
WSM_LOAD_LINK       number := 5;        -- load a link
WSM_LOAD_LINK_OP    number := 6;        -- load link and/or operation
WSM_LOAD_RES_INS    number := 7;        -- load resource instance

WSM_SUB_DEL         number := 1;        -- delete
WSM_SUB_ADD         number := 2;        -- add
WSM_SUB_CHG         number := 3;        -- change/update
WSM_SUB_REC         number := 4;        -- recommend
WSM_SUB_DIS         number := 5;        -- discommend


LT_RESOURCE     number := 1;

--
-- R12Dev: for secondary quantity
--
type tbl_wjsq_uom_code          is table of wsm_job_secondary_quantities.uom_code%type       index by binary_integer;
type tbl_wjsq_start_quantity    is table of wsm_job_secondary_quantities.start_quantity%type index by binary_integer;

procedure  process_lbji_rows (
        retcode                         out nocopy number,
        errbuf                          out nocopy varchar2,
        p_group_id                      in number);


procedure  launch_worker (
        retcode                         out nocopy number,
        errbuf                          out nocopy varchar2,
        p_group_id                      in number,
        p_alotted_jobs                  in number  );


procedure build_job_header_info(
        p_common_routing_sequence_id    in number,
        p_common_bill_sequence_id       in number,
        p_status_type                   in number,
        p_class_code                    in varchar2,
        p_org_id                        in number,
        p_wip_entity_id                 in out nocopy number,
        p_last_updt_date                in date,
        p_last_updt_by                  in number,
        p_creation_date                 in date,
        p_created_by                    in number,
        p_last_updt_login               in number,
        p_request_id                    in number,
        p_program_appl_id               in number,
        p_program_id                    in number,
        p_prog_updt_date                in date,
        p_source_line_id                in number,
        p_source_code                   in varchar2,
        p_description                   in varchar2,
        p_item                          in number,
        p_job_type                      in number,
        p_bom_reference_id              in number,
        p_routing_reference_id          in number,
        p_firm_planned_flag             in number,
        p_wip_supply_type               in number,
        p_job_scheduled_start_date      in date,
        p_job_scheduled_compl_date      in date,
        p_start_quantity                in number,
        p_net_quantity                  in number,
        p_coproducts_supply             in number,
        p_bom_revision                  in varchar2,
        p_routing_revision              in varchar2,
        p_bom_revision_date             in date,
        p_routing_revision_date         in date,
        p_lot_number                    in varchar2,
        p_alt_bom_designator            in varchar2,
        p_alt_routing_designator        in varchar2,
        p_priority                      in number,
        p_due_date                      in date,
        p_attribute_category            in varchar2,
        p_attribute1                    in varchar2,
        p_attribute2                    in varchar2,
        p_attribute3                    in varchar2,
        p_attribute4                    in varchar2,
        p_attribute5                    in varchar2,
        p_attribute6                    in varchar2,
        p_attribute7                    in varchar2,
        p_attribute8                    in varchar2,
        p_attribute9                    in varchar2,
        p_attribute10                   in varchar2,
        p_attribute11                   in varchar2,
        p_attribute12                   in varchar2,
        p_attribute13                   in varchar2,
        p_attribute14                   in varchar2,
        p_attribute15                   in varchar2,
        p_job_name                      in varchar2,
        p_completion_subinventory       in varchar2,
        p_completion_locator_id         in number,
        p_demand_class                  in varchar2,
        p_project_id                    in number,
        p_task_id                       in number,
        p_schedule_group_id             in number,
        p_build_sequence                in number,
        p_line_id                       in number,
        p_kanban_card_id                in number,
        p_overcompl_tol_type            in number,
        p_overcompl_tol_value           in number,
        p_end_item_unit_number          in number,
        p_src_client_server             in number,
        p_po_creation_time              in number,
        p_date_released                 in date,
        p_error_code                    out nocopy number,
        p_error_msg                     out nocopy varchar2);


procedure build_job_copy_info(
        p_common_routing_sequence_id    in number,
        p_common_bill_sequence_id       in number,
        p_org_id                        in number,
        p_wip_entity_id                 in number,
        p_last_updt_date                in date,
        p_last_updt_by                  in number,
        p_creation_date                 in date,
        p_created_by                    in number,
        p_last_updt_login               in number,
        p_request_id                    in number,
        p_program_appl_id               in number,
        p_program_id                    in number,
        p_prog_updt_date                in date,
        p_item                          in number,
        p_bom_reference_id              in number,
        p_routing_reference_id          in number,
        p_wip_supply_type               in number,
        p_job_scheduled_start_date      in date,
        p_job_scheduled_compl_date      in date,
        p_start_quantity                in number,
        p_bom_revision_date             in date,
        p_routing_revision_date         in date,
        p_alt_bom_designator            in varchar2,
        p_alt_routing_designator        in varchar2,
        p_header_id                     in number,      -- header_id in WLJI, pass null if N/A
        p_num_of_children               in number,      -- number of children in WLJDI
        p_infinite_schedule             in varchar2,    -- call infinite scheduler or not: Y/N
        p_error_code                    out nocopy number,
        p_error_msg                     out nocopy varchar2);


procedure build_job_detail_info(
        p_common_routing_sequence_id    in number,
        p_common_bill_sequence_id       in number,
        p_status_type                   in number,
        p_org_id                        in number,
        p_wip_entity_id                 in number,
        p_last_updt_date                in date,
        p_last_updt_by                  in number,
        p_creation_date                 in date,
        p_created_by                    in number,
        p_last_updt_login               in number,
        p_request_id                    in number,
        p_program_appl_id               in number,
        p_program_id                    in number,
        p_prog_updt_date                in date,
        p_item                          in number,
        p_job_type                      in number,
        p_bom_reference_id              in number,
        p_routing_reference_id          in number,
        p_wip_supply_type               in number,
        p_job_scheduled_start_date      in date,        -- not used
        p_job_scheduled_compl_date      in date,        -- not used
        p_start_quantity                in number,
        p_bom_revision_date             in date,
        p_routing_revision_date         in date,
        p_alt_bom_designator            in varchar2,
        p_alt_routing_designator        in varchar2,
        p_rtg_op_seq_num                in number,
        p_error_code                    out nocopy number,
        p_error_msg                     out nocopy varchar2);


procedure import_lot_job_details(
        p_wip_entity_id                 in number,
        p_org_id                        in number,
        p_wo_records_exist              in varchar2,
        p_parent_header_id              in number,      -- header_id in WLJI not NULL
        p_job_scheduled_start_date      in date,
        p_job_scheduled_compl_date      in date,
        p_job_scheduled_quantity        in number,
        p_group_id                      in number,      -- only passed when handling independent wljdi records
        p_last_updt_date                in date,
        p_last_updt_by                  in number,
        p_creation_date                 in date,
        p_created_by                    in number,
        p_last_updt_login               in number,
        p_request_id                    in number,
        p_program_appl_id               in number,
        p_program_id                    in number,
        p_prog_updt_date                in date,
        p_error_code                    out nocopy number,
        p_error_msg                     out nocopy varchar2);


procedure load_wsli_data(
        p_group_id                      in number);


procedure check_errored_mmtt_records (
        p_header_id                     in number,
        x_err_code                      out nocopy number,
        x_err_msg                       out nocopy varchar2);


function discrete_charges_exist(
        p_wip_entity_id                 in number,
        p_organization_id               in number,
        p_check_mode                    in number ) return boolean;


procedure insert_into_period_balances (
        p_wip_entity_id                 in number,
        p_organization_id               in number,
        p_class_code                    in varchar2,
        p_release_date                  in date,
        p_error_code                    out nocopy number,
        p_err_msg                       out nocopy varchar2);


-- overloaded
procedure build_job_detail_info(
        p_common_routing_sequence_id    in number,
        p_common_bill_sequence_id       in number,
        p_status_type                   in number,
        p_org_id                        in number,
        p_wip_entity_id                 in number,
        p_last_updt_date                in date,
        p_last_updt_by                  in number,
        p_creation_date                 in date,
        p_created_by                    in number,
        p_last_updt_login               in number,
        p_request_id                    in number,
        p_program_appl_id               in number,
        p_program_id                    in number,
        p_prog_updt_date                in date,
        p_item                          in number,
        p_job_type                      in number,
        p_bom_reference_id              in number,
        p_routing_reference_id          in number,
        p_wip_supply_type               in number,
        p_job_scheduled_start_date      in date,        -- not used
        p_job_scheduled_compl_date      in date,        -- not used
        p_start_quantity                in number,
        p_bom_revision_date             in date,
        p_routing_revision_date         in date,
        p_alt_bom_designator            in varchar2,
        p_alt_routing_designator        in varchar2,
        p_rtg_op_seq_num                in number,
        p_error_code                    out nocopy number,
        p_error_msg                     out nocopy varchar2,
        p_src_client_server             in number,      -- bug 3311985 new parameter
        p_po_creation_time              in number);     -- bug 3311985 new parameter

--
-- R12Dev: for secondary quantity, overloaded
--
procedure build_job_header_info(
        p_common_routing_sequence_id    in number,
        p_common_bill_sequence_id       in number,
        p_status_type                   in number,
        p_class_code                    in varchar2,
        p_org_id                        in number,
        p_wip_entity_id                 in out nocopy number,
        p_last_updt_date                in date,
        p_last_updt_by                  in number,
        p_creation_date                 in date,
        p_created_by                    in number,
        p_last_updt_login               in number,
        p_request_id                    in number,
        p_program_appl_id               in number,
        p_program_id                    in number,
        p_prog_updt_date                in date,
        p_source_line_id                in number,
        p_source_code                   in varchar2,
        p_description                   in varchar2,
        p_item                          in number,
        p_job_type                      in number,
        p_bom_reference_id              in number,
        p_routing_reference_id          in number,
        p_firm_planned_flag             in number,
        p_wip_supply_type               in number,
        p_job_scheduled_start_date      in date,
        p_job_scheduled_compl_date      in date,
        p_start_quantity                in number,
        p_net_quantity                  in number,
        p_coproducts_supply             in number,
        p_bom_revision                  in varchar2,
        p_routing_revision              in varchar2,
        p_bom_revision_date             in date,
        p_routing_revision_date         in date,
        p_lot_number                    in varchar2,
        p_alt_bom_designator            in varchar2,
        p_alt_routing_designator        in varchar2,
        p_priority                      in number,
        p_due_date                      in date,
        p_attribute_category            in varchar2,
        p_attribute1                    in varchar2,
        p_attribute2                    in varchar2,
        p_attribute3                    in varchar2,
        p_attribute4                    in varchar2,
        p_attribute5                    in varchar2,
        p_attribute6                    in varchar2,
        p_attribute7                    in varchar2,
        p_attribute8                    in varchar2,
        p_attribute9                    in varchar2,
        p_attribute10                   in varchar2,
        p_attribute11                   in varchar2,
        p_attribute12                   in varchar2,
        p_attribute13                   in varchar2,
        p_attribute14                   in varchar2,
        p_attribute15                   in varchar2,
        p_job_name                      in varchar2,
        p_completion_subinventory       in varchar2,
        p_completion_locator_id         in number,
        p_demand_class                  in varchar2,
        p_project_id                    in number,
        p_task_id                       in number,
        p_schedule_group_id             in number,
        p_build_sequence                in number,
        p_line_id                       in number,
        p_kanban_card_id                in number,
        p_overcompl_tol_type            in number,
        p_overcompl_tol_value           in number,
        p_end_item_unit_number          in number,
        p_src_client_server             in number,
        p_po_creation_time              in number,
        p_date_released                 in date,
        p_wjsq_uom_code                 in tbl_wjsq_uom_code,           -- R12Dev new parameter
        p_wjsq_start_quantity           in tbl_wjsq_start_quantity,     -- R12Dev new parameter
        p_error_code                    out nocopy number,
        p_error_msg                     out nocopy varchar2);


END;

 

/
