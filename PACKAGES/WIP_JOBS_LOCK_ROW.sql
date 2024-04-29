--------------------------------------------------------
--  DDL for Package WIP_JOBS_LOCK_ROW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_JOBS_LOCK_ROW" AUTHID CURRENT_USER as
/* $Header: wipdjlrs.pls 115.19 2002/12/12 16:57:50 rmahidha ship $ */

PROCEDURE Lock_Row
(X_Row_Id VARCHAR2,
X_wip_entity_id NUMBER,
X_organization_id               NUMBER,
X_last_update_date              DATE,
X_last_updated_by               NUMBER,
X_creation_date                 DATE,
X_created_by                    NUMBER,
X_last_update_login             NUMBER,
X_description                   VARCHAR2,
X_status_type                   NUMBER,
X_primary_item_id               NUMBER,
X_firm_planned_flag             NUMBER,
X_job_type                      NUMBER,
X_wip_supply_type               NUMBER,
X_class_code                    VARCHAR2,
X_material_account              NUMBER,
X_material_overhead_account     NUMBER,
X_resource_account              NUMBER,
X_outside_processing_account    NUMBER,
X_material_variance_account     NUMBER,
X_resource_variance_account     NUMBER,
X_outside_proc_var_account      NUMBER,
X_std_cost_adjustment_account   NUMBER,
X_overhead_account              NUMBER,
X_overhead_variance_account     NUMBER,
X_scheduled_start_date          DATE,
X_date_released                 DATE,
X_scheduled_completion_date     DATE,
X_date_completed                DATE,
X_date_closed                   DATE,
X_start_quantity                NUMBER,
X_overcompletion_toleran_type	NUMBER,
X_overcompletion_toleran_value	NUMBER,
X_quantity_completed            NUMBER,
X_quantity_scrapped             NUMBER,
X_net_quantity                  NUMBER,
X_bom_reference_id              NUMBER,
X_routing_reference_id          NUMBER,
X_common_bom_sequence_id        NUMBER,
X_common_routing_sequence_id    NUMBER,
X_bom_revision                  VARCHAR2,
X_routing_revision              VARCHAR2,
X_bom_revision_date             DATE,
X_routing_revision_date         DATE,
X_lot_number                    VARCHAR2,
X_alternate_bom_designator      VARCHAR2,
X_alternate_routing_designator  VARCHAR2,
X_completion_subinventory       VARCHAR2,
X_completion_locator_id         NUMBER,
X_demand_class                  VARCHAR2,
X_attribute_category            VARCHAR2,
X_attribute1                    VARCHAR2,
X_attribute2                    VARCHAR2,
X_attribute3                    VARCHAR2,
X_attribute4                    VARCHAR2,
X_attribute5                    VARCHAR2,
X_attribute6                    VARCHAR2,
X_attribute7                    VARCHAR2,
X_attribute8                    VARCHAR2,
X_attribute9                    VARCHAR2,
X_attribute10                   VARCHAR2,
X_attribute11                   VARCHAR2,
X_attribute12                   VARCHAR2,
X_attribute13                   VARCHAR2,
X_attribute14                   VARCHAR2,
X_attribute15                   VARCHAR2,
X_end_item_unit_number		VARCHAR2,
X_Schedule_Group_Id		NUMBER,
X_Build_Sequence		NUMBER,
X_Line_Id			NUMBER,
X_Project_Id			NUMBER,
X_Task_Id			NUMBER,
X_priority                      NUMBER,
X_due_date                      DATE,
X_due_date_penalty              NUMBER,
X_due_date_tolerance            NUMBER,
X_requested_start_date          DATE,
x_serialization_start_op        NUMBER := null);
/*X_Project_Costed		NUMBER);*/

END WIP_JOBS_LOCK_ROW;

 

/