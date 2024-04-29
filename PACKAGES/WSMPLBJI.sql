--------------------------------------------------------
--  DDL for Package WSMPLBJI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPLBJI" AUTHID CURRENT_USER AS
/* $Header: WSMLBJIS.pls 115.18 2003/09/17 18:44:48 zchen ship $ */

lbji_debug VARCHAR2(1):= fnd_profile.value('MRP_DEBUG');

no_of_workers NUMBER := fnd_profile.value('WSM_LBJIMPORT_WORKER');

batch_size NUMBER := fnd_profile.value('WSM_LBJIMPORT_BATCHSIZE');



g_create_job_copy   VARCHAR2(1) := 'Y';

PROCEDURE  process_interface_rows (
        retcode         OUT NOCOPY NUMBER,
        errbuf          OUT NOCOPY VARCHAR2 );


PROCEDURE  process_interface_rows (
        retcode         OUT NOCOPY NUMBER,
        errbuf          OUT NOCOPY VARCHAR2,
        p_group_id      IN  NUMBER);


PROCEDURE  launch_worker (
        retcode         OUT NOCOPY NUMBER,
        errbuf          OUT NOCOPY VARCHAR2,
        l_group_id      IN  NUMBER,
        alotted_rows    IN  NUMBER  );


procedure build_lbji_info(
        p_routing_seq_id                IN number,
        p_common_bill_sequence_id       IN number,
        p_explode_header_detail         IN number,
        p_status_type                   IN number,
        p_class_code                    IN varchar2,
        p_org                           IN number,
        p_wip_entity_id      IN OUT NOCOPY number,
        p_last_updt_date                IN date,
        p_last_updt_by                  IN number,
        p_creation_date                 IN date,
        p_created_by                    IN number,
        p_last_updt_login               IN number,
        p_request_id                    IN number,
        p_program_application_id        IN number,
        p_program_id                    IN number,
        p_prog_updt_date                IN date,
        p_source_line_id                IN number,
        p_source_code                   IN varchar2,
        p_description                   IN varchar2,
        p_item                          IN number,
        p_job_type                      IN number,
        p_bom_reference_id              IN number,
        p_routing_reference_id          IN number,
        p_firm_planned_flag             IN number,
        p_wip_supply_type               IN number,
        p_fusd                          IN date,
        p_lucd                          IN date,
        p_start_quantity                IN number,
        p_net_quantity                  IN number,
        p_coproducts_supply             IN number,
        p_bom_revision                  IN varchar2,
        p_routing_revision              IN varchar2,
        p_bom_revision_date             IN date,
        p_routing_revision_date         IN date,
        p_lot_number                    IN varchar2,
        p_alt_bom_designator            IN varchar2,
        p_alt_routing_designator        IN varchar2,
        p_priority                      IN number,
        p_due_date                      IN date,
        p_attribute_category            IN varchar2,
        p_attribute1                    IN varchar2,
        p_attribute2                    IN varchar2,
        p_attribute3                    IN varchar2,
        p_attribute4                    IN varchar2,
        p_attribute5                    IN varchar2,
        p_attribute6                    IN varchar2,
        p_attribute7                    IN varchar2,
        p_attribute8                    IN varchar2,
        p_attribute9                    IN varchar2,
        p_attribute10                   IN varchar2,
        p_attribute11                   IN varchar2,
        p_attribute12                   IN varchar2,
        p_attribute13                   IN varchar2,
        p_attribute14                   IN varchar2,
        p_attribute15                   IN varchar2,
        p_job_name                      IN varchar2,
        p_completion_subinventory       IN varchar2,
        p_completion_locator_id         IN number,
        p_demand_class                  IN varchar2,
        p_project_id                    IN number,
        p_task_id                       IN number,
        p_schedule_group_id             IN number,
        p_build_sequence                IN number,
        p_line_id                       IN number,
        p_kanban_card_id                IN number,
        p_overcompl_tol_type            IN number,
        p_overcompl_tol_value           IN number,
        p_end_item_unit_number          IN number,
        p_rtg_op_seq_num                IN number,
        p_src_client_server             IN number,
        p_po_creation_time              IN number,
        p_error_code            OUT NOCOPY number,
        p_error_msg             OUT NOCOPY varchar2);


procedure build_lbji_info(
        p_routing_seq_id                IN number,
        p_common_bill_sequence_id       IN number,
        p_explode_header_detail         IN number,
        p_status_type                   IN number,
        p_class_code                    IN varchar2,
        p_org                           IN number,
        p_wip_entity_id      IN OUT NOCOPY number,
        p_last_updt_date                IN date,
        p_last_updt_by                  IN number,
        p_creation_date                 IN date,
        p_created_by                    IN number,
        p_last_updt_login               IN number,
        p_request_id                    IN number,
        p_program_application_id        IN number,
        p_program_id                    IN number,
        p_prog_updt_date                IN date,
        p_source_line_id                IN number,
        p_source_code                   IN varchar2,
        p_description                   IN varchar2,
        p_item                          IN number,
        p_job_type                      IN number,
        p_bom_reference_id              IN number,
        p_routing_reference_id          IN number,
        p_firm_planned_flag             IN number,
        p_wip_supply_type               IN number,
        p_fusd                          IN date,
        p_lucd                          IN date,
        p_start_quantity                IN number,
        p_net_quantity                  IN number,
        p_coproducts_supply             IN number,
        p_bom_revision                  IN varchar2,
        p_routing_revision              IN varchar2,
        p_bom_revision_date             IN date,
        p_routing_revision_date         IN date,
        p_lot_number                    IN varchar2,
        p_alt_bom_designator            IN varchar2,
        p_alt_routing_designator        IN varchar2,
        p_priority                      IN number,
        p_due_date                      IN date,
        p_attribute_category            IN varchar2,
        p_attribute1                    IN varchar2,
        p_attribute2                    IN varchar2,
        p_attribute3                    IN varchar2,
        p_attribute4                    IN varchar2,
        p_attribute5                    IN varchar2,
        p_attribute6                    IN varchar2,
        p_attribute7                    IN varchar2,
        p_attribute8                    IN varchar2,
        p_attribute9                    IN varchar2,
        p_attribute10                   IN varchar2,
        p_attribute11                   IN varchar2,
        p_attribute12                   IN varchar2,
        p_attribute13                   IN varchar2,
        p_attribute14                   IN varchar2,
        p_attribute15                   IN varchar2,
        p_job_name                      IN varchar2,
        p_completion_subinventory       IN varchar2,
        p_completion_locator_id         IN number,
        p_demand_class                  IN varchar2,
        p_project_id                    IN number,
        p_task_id                       IN number,
        p_schedule_group_id             IN number,
        p_build_sequence                IN number,
        p_line_id                       IN number,
        p_kanban_card_id                IN number,
        p_overcompl_tol_type            IN number,
        p_overcompl_tol_value           IN number,
        p_end_item_unit_number          IN number,
        p_rtg_op_seq_num                IN number,
        p_src_client_server             IN number,
        p_po_creation_time              IN number,
        p_date_released                 IN date,
        p_error_code            OUT NOCOPY number,
        p_error_msg             OUT NOCOPY varchar2);

PROCEDURE load_wsli_data(l_group_id IN NUMBER);


PROCEDURE check_errored_mmtt_records (
        p_header_id     IN NUMBER,
        x_err_code      OUT NOCOPY NUMBER,
        x_err_msg       OUT NOCOPY VARCHAR2);


PROCEDURE insert_procedure(
        p_seq_id                        IN NUMBER,
        p_job_seq_num                   IN NUMBER,
        p_common_routing_sequence_id    IN NUMBER, -- routing of the assembly
        p_supply_type                   IN NUMBER,
        p_wip_entity_id                 IN NUMBER,
        p_organization_id               IN NUMBER,
        p_quantity                      IN NUMBER,
        p_job_type                      IN NUMBER,
        p_bom_reference_id              IN NUMBER,
        p_rtg_reference_id              IN NUMBER,
        p_assembly_item_id              IN NUMBER,
        p_alt_bom_designator            IN VARCHAR2,
        p_alt_rtg_designator            IN VARCHAR2,
        p_fusd                          IN DATE,
        p_lucd                          IN DATE,
        p_rtg_revision_date             IN DATE,
        p_bom_revision_date             IN DATE,
        p_last_updt_date                IN  date,
        p_last_updt_by                  IN number,
        p_creation_date                 IN date,
        p_created_by                    IN number,
        p_last_updt_login               IN number,
        p_request_id                    IN number,
        p_program_application_id        IN number,
        p_program_id                    IN number,
        p_prog_updt_date                IN date,
        p_error_code            OUT NOCOPY NUMBER,
        p_error_msg             OUT NOCOPY VARCHAR2);


FUNCTION discrete_charges_exist(
        p_wip_entity_id         IN NUMBER,
        p_organization_id       IN NUMBER,
        p_check_mode            IN NUMBER ) RETURN BOOLEAN;


PROCEDURE insert_into_period_balances(
        p_wip_entity_id     IN NUMBER,
        p_organization_id   IN NUMBER,
        p_class_code        IN VARCHAR2,
        p_release_date      IN DATE,
        p_error_code        OUT NOCOPY NUMBER,
        p_err_msg           OUT NOCOPY VARCHAR2);


PROCEDURE process_invalid_field (
        p_fld          IN VARCHAR2,
        aux_string     IN VARCHAR2,
        stmt_number    IN NUMBER);


PROCEDURE process_errorred_field (
        p_product      IN VARCHAR2,
        p_message_name IN VARCHAR2,
        stmt_number    IN NUMBER);


PROCEDURE handle_error (
        p_err_code     IN NUMBER,
        p_err_msg      IN VARCHAR2,
        stmt_number    IN NUMBER);


PROCEDURE handle_warning(
        p_err_msg                      IN VARCHAR2,
        p_header_id                    IN NUMBER,
        p_request_id                   IN NUMBER,
        p_program_id                   IN NUMBER,
        p_program_application_id       IN NUMBER);


FUNCTION honor_kanban_size (
        p_org_id IN NUMBER,
        p_item_id IN NUMBER,
        p_subinv  IN VARCHAR2,
        p_locator_id IN NUMBER,
        p_kanban_plan_id IN NUMBER)
return number;

-- This is the old process_interface_rows, retained to support Option A
PROCEDURE  process_lbji_rows_1159 (
        retcode         OUT NOCOPY NUMBER,
        errbuf          OUT NOCOPY VARCHAR2,
        p_group_id      IN  NUMBER);


PROCEDURE  launch_worker_1159 (
        retcode         OUT NOCOPY NUMBER,
        errbuf          OUT NOCOPY VARCHAR2,
        l_group_id      IN  NUMBER,
        alotted_rows    IN  NUMBER  );

END;

 

/
