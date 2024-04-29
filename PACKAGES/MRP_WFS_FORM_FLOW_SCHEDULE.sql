--------------------------------------------------------
--  DDL for Package MRP_WFS_FORM_FLOW_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_WFS_FORM_FLOW_SCHEDULE" AUTHID CURRENT_USER AS
/* $Header: MRPFSCNS.pls 115.15 2003/05/12 11:38:37 soroy ship $ */

--  Procedure : Default_Attributes
--
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type).Also added local variables to make it
compatible with the call to (MRP_FLow_Schedule_PVT.Process_Flow_Schedule)
*/

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY	VARCHAR2
,   x_msg_count                     OUT NOCOPY	NUMBER
,   x_msg_data                      OUT NOCOPY	VARCHAR2
,   x_alternate_bom_designator      OUT NOCOPY	VARCHAR2
,   x_alternate_routing_desig       OUT NOCOPY	VARCHAR2
,   x_attribute1                    OUT NOCOPY	VARCHAR2
,   x_attribute10                   OUT NOCOPY	VARCHAR2
,   x_attribute11                   OUT NOCOPY	VARCHAR2
,   x_attribute12                   OUT NOCOPY	VARCHAR2
,   x_attribute13                   OUT NOCOPY	VARCHAR2
,   x_attribute14                   OUT NOCOPY	VARCHAR2
,   x_attribute15                   OUT NOCOPY	VARCHAR2
,   x_attribute2                    OUT NOCOPY	VARCHAR2
,   x_attribute3                    OUT NOCOPY	VARCHAR2
,   x_attribute4                    OUT NOCOPY	VARCHAR2
,   x_attribute5                    OUT NOCOPY	VARCHAR2
,   x_attribute6                    OUT NOCOPY	VARCHAR2
,   x_attribute7                    OUT NOCOPY	VARCHAR2
,   x_attribute8                    OUT NOCOPY	VARCHAR2
,   x_attribute9                    OUT NOCOPY	VARCHAR2
,   x_attribute_category            OUT NOCOPY	VARCHAR2
,   x_bom_revision                  OUT NOCOPY	VARCHAR2
,   x_bom_revision_date             OUT NOCOPY	DATE
,   x_build_sequence                OUT NOCOPY	NUMBER
,   x_class_code                    OUT NOCOPY	VARCHAR2
,   x_completion_locator_id         OUT NOCOPY	NUMBER
,   x_completion_subinventory       OUT NOCOPY	VARCHAR2
,   x_date_closed                   OUT NOCOPY	DATE
,   x_demand_class                  OUT NOCOPY	VARCHAR2
,   x_demand_source_delivery        OUT NOCOPY	VARCHAR2
,   x_demand_source_header_id       OUT NOCOPY	NUMBER
,   x_demand_source_line            OUT NOCOPY	VARCHAR2
,   x_demand_source_type            OUT NOCOPY	NUMBER
,   x_line_id                       OUT NOCOPY	NUMBER
,   x_material_account              OUT NOCOPY	NUMBER
,   x_material_overhead_account     OUT NOCOPY	NUMBER
,   x_material_variance_account     OUT NOCOPY	NUMBER
,   x_mps_net_quantity              OUT NOCOPY	NUMBER
,   x_mps_scheduled_comp_date       OUT NOCOPY	DATE
,   x_organization_id               OUT NOCOPY	NUMBER
,   x_outside_processing_acct       OUT NOCOPY	NUMBER
,   x_outside_proc_var_acct         OUT NOCOPY	NUMBER
,   x_overhead_account              OUT NOCOPY	NUMBER
,   x_overhead_variance_account     OUT NOCOPY	NUMBER
,   x_planned_quantity              OUT NOCOPY	NUMBER
,   x_primary_item_id               OUT NOCOPY	NUMBER
,   x_project_id                    OUT NOCOPY	NUMBER
,   x_quantity_completed            OUT NOCOPY	NUMBER
,   x_resource_account              OUT NOCOPY	NUMBER
,   x_resource_variance_account     OUT NOCOPY	NUMBER
,   x_routing_revision              OUT NOCOPY	VARCHAR2
,   x_routing_revision_date         OUT NOCOPY	DATE
,   x_scheduled_completion_date     OUT NOCOPY	DATE
,   x_scheduled_flag                OUT NOCOPY	NUMBER
,   x_scheduled_start_date          OUT NOCOPY	DATE
,   x_schedule_group_id             OUT NOCOPY	NUMBER
,   x_schedule_number               OUT NOCOPY	VARCHAR2
,   x_status                        OUT NOCOPY	NUMBER
,   x_std_cost_adjustment_acct      OUT NOCOPY	NUMBER
,   x_task_id                       OUT NOCOPY	NUMBER
,   x_wip_entity_id                 OUT NOCOPY	NUMBER
,   x_completion_locator            OUT NOCOPY	VARCHAR2
,   x_line                          OUT NOCOPY	VARCHAR2
,   x_organization                  OUT NOCOPY	VARCHAR2
,   x_primary_item                  OUT NOCOPY	VARCHAR2
,   x_project                       OUT NOCOPY	VARCHAR2
,   x_schedule_group                OUT NOCOPY	VARCHAR2
,   x_task                          OUT NOCOPY	VARCHAR2
,   x_wip_entity                    OUT NOCOPY	VARCHAR2
,   x_end_item_unit_number          OUT NOCOPY	VARCHAR2
,   x_quantity_scrapped             OUT NOCOPY	NUMBER
);

--  Procedure   :   Change_Attribute
--
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type).Also added local variables to make it
compatible with the call to (MRP_FLow_Schedule_PVT.Process_Flow_Schedule)
*/

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY	VARCHAR2
,   x_msg_count                     OUT NOCOPY	NUMBER
,   x_msg_data                      OUT NOCOPY	VARCHAR2
,   p_wip_entity_id                 IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_attribute_category            IN  VARCHAR2
,   x_alternate_bom_designator      OUT NOCOPY	VARCHAR2
,   x_alternate_routing_desig       OUT NOCOPY	VARCHAR2
,   x_attribute1                    OUT NOCOPY	VARCHAR2
,   x_attribute10                   OUT NOCOPY	VARCHAR2
,   x_attribute11                   OUT NOCOPY	VARCHAR2
,   x_attribute12                   OUT NOCOPY	VARCHAR2
,   x_attribute13                   OUT NOCOPY	VARCHAR2
,   x_attribute14                   OUT NOCOPY	VARCHAR2
,   x_attribute15                   OUT NOCOPY	VARCHAR2
,   x_attribute2                    OUT NOCOPY	VARCHAR2
,   x_attribute3                    OUT NOCOPY	VARCHAR2
,   x_attribute4                    OUT NOCOPY	VARCHAR2
,   x_attribute5                    OUT NOCOPY	VARCHAR2
,   x_attribute6                    OUT NOCOPY	VARCHAR2
,   x_attribute7                    OUT NOCOPY	VARCHAR2
,   x_attribute8                    OUT NOCOPY	VARCHAR2
,   x_attribute9                    OUT NOCOPY	VARCHAR2
,   x_attribute_category            OUT NOCOPY	VARCHAR2
,   x_bom_revision                  OUT NOCOPY	VARCHAR2
,   x_bom_revision_date             OUT NOCOPY	DATE
,   x_build_sequence                OUT NOCOPY	NUMBER
,   x_class_code                    OUT NOCOPY	VARCHAR2
,   x_completion_locator_id         OUT NOCOPY	NUMBER
,   x_completion_subinventory       OUT NOCOPY	VARCHAR2
,   x_date_closed                   OUT NOCOPY	DATE
,   x_demand_class                  OUT NOCOPY	VARCHAR2
,   x_demand_source_delivery        OUT NOCOPY	VARCHAR2
,   x_demand_source_header_id       OUT NOCOPY	NUMBER
,   x_demand_source_line            OUT NOCOPY	VARCHAR2
,   x_demand_source_type            OUT NOCOPY	NUMBER
,   x_line_id                       OUT NOCOPY	NUMBER
,   x_material_account              OUT NOCOPY	NUMBER
,   x_material_overhead_account     OUT NOCOPY	NUMBER
,   x_material_variance_account     OUT NOCOPY	NUMBER
,   x_mps_net_quantity              OUT NOCOPY	NUMBER
,   x_mps_scheduled_comp_date       OUT NOCOPY	DATE
,   x_organization_id               OUT NOCOPY	NUMBER
,   x_outside_processing_acct       OUT NOCOPY	NUMBER
,   x_outside_proc_var_acct         OUT NOCOPY	NUMBER
,   x_overhead_account              OUT NOCOPY	NUMBER
,   x_overhead_variance_account     OUT NOCOPY	NUMBER
,   x_planned_quantity              OUT NOCOPY	NUMBER
,   x_primary_item_id               OUT NOCOPY	NUMBER
,   x_project_id                    OUT NOCOPY	NUMBER
,   x_quantity_completed            OUT NOCOPY	NUMBER
,   x_request_id                    OUT NOCOPY	NUMBER
,   x_resource_account              OUT NOCOPY	NUMBER
,   x_resource_variance_account     OUT NOCOPY	NUMBER
,   x_routing_revision              OUT NOCOPY	VARCHAR2
,   x_routing_revision_date         OUT NOCOPY	DATE
,   x_scheduled_completion_date     OUT NOCOPY	DATE
,   x_scheduled_flag                OUT NOCOPY	NUMBER
,   x_scheduled_start_date          OUT NOCOPY	DATE
,   x_schedule_group_id             OUT NOCOPY	NUMBER
,   x_schedule_number               OUT NOCOPY	VARCHAR2
,   x_status                        OUT NOCOPY	NUMBER
,   x_std_cost_adjustment_acct      OUT NOCOPY	NUMBER
,   x_task_id                       OUT NOCOPY	NUMBER
,   x_wip_entity_id                 OUT NOCOPY	NUMBER
,   x_completion_locator            OUT NOCOPY	VARCHAR2
,   x_line                          OUT NOCOPY	VARCHAR2
,   x_organization                  OUT NOCOPY	VARCHAR2
,   x_primary_item                  OUT NOCOPY	VARCHAR2
,   x_project                       OUT NOCOPY	VARCHAR2
,   x_schedule_group                OUT NOCOPY	VARCHAR2
,   x_task                          OUT NOCOPY	VARCHAR2
,   x_wip_entity                    OUT NOCOPY	VARCHAR2
,   x_end_item_unit_number          OUT NOCOPY	VARCHAR2
,   x_quantity_scrapped             OUT NOCOPY	NUMBER
);

--  Procedure       Validate_And_Write
--
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY	VARCHAR2
,   x_msg_count                     OUT NOCOPY	NUMBER
,   x_msg_data                      OUT NOCOPY	VARCHAR2
,   p_wip_entity_id                 IN  NUMBER
,   x_creation_date                 OUT NOCOPY	DATE
,   x_created_by                    OUT NOCOPY	NUMBER
,   x_last_update_date              OUT NOCOPY	DATE
,   x_last_updated_by               OUT NOCOPY	NUMBER
,   x_last_update_login             OUT NOCOPY	NUMBER
);

--  Procedure       Delete_Row
--
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type).Also added local variables to make it
compatible with the call to (MRP_FLow_Schedule_PVT.Process_Flow_Schedule)
*/

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY	VARCHAR2
,   x_msg_count                     OUT NOCOPY	NUMBER
,   x_msg_data                      OUT NOCOPY	VARCHAR2
,   p_wip_entity_id                 IN  NUMBER
);

--  Procedure       Process_Entity
--
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type).Also added local variables to make it
compatible with the call to (MRP_FLow_Schedule_PVT.Process_Flow_Schedule)
*/

PROCEDURE Process_Entity
(   x_return_status                 OUT NOCOPY	VARCHAR2
,   x_msg_count                     OUT NOCOPY	NUMBER
,   x_msg_data                      OUT NOCOPY	VARCHAR2
);

--  Procedure       Process_Object
--

/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type).Also added local variables to make it
compatible with the call to (MRP_FLow_Schedule_PVT.Process_Flow_Schedule)
*/

PROCEDURE Process_Object
(   x_return_status                 OUT NOCOPY	VARCHAR2
,   x_msg_count                     OUT NOCOPY	NUMBER
,   x_msg_data                      OUT NOCOPY	VARCHAR2
);

--  Procedure       lock_Row
--
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/
PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY	VARCHAR2
,   x_msg_count                     OUT NOCOPY	NUMBER
,   x_msg_data                      OUT NOCOPY	VARCHAR2
,   p_alternate_bom_designator      IN  VARCHAR2
,   p_alternate_routing_desig       IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_attribute_category            IN  VARCHAR2
,   p_bom_revision                  IN  VARCHAR2
,   p_bom_revision_date             IN  DATE
,   p_build_sequence                IN  NUMBER
,   p_class_code                    IN  VARCHAR2
,   p_completion_locator_id         IN  NUMBER
,   p_completion_subinventory       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_date_closed                   IN  DATE
,   p_demand_class                  IN  VARCHAR2
,   p_demand_source_delivery        IN  VARCHAR2
,   p_demand_source_header_id       IN  NUMBER
,   p_demand_source_line            IN  VARCHAR2
,   p_demand_source_type            IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_material_account              IN  NUMBER
,   p_material_overhead_account     IN  NUMBER
,   p_material_variance_account     IN  NUMBER
,   p_mps_net_quantity              IN  NUMBER
,   p_mps_scheduled_comp_date       IN  DATE
,   p_organization_id               IN  NUMBER
,   p_outside_processing_acct       IN  NUMBER
,   p_outside_proc_var_acct         IN  NUMBER
,   p_overhead_account              IN  NUMBER
,   p_overhead_variance_account     IN  NUMBER
,   p_planned_quantity              IN  NUMBER
,   p_primary_item_id               IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_project_id                    IN  NUMBER
,   p_quantity_completed            IN  NUMBER
,   p_request_id                    IN  NUMBER
,   p_resource_account              IN  NUMBER
,   p_resource_variance_account     IN  NUMBER
,   p_routing_revision              IN  VARCHAR2
,   p_routing_revision_date         IN  DATE
,   p_scheduled_completion_date     IN  DATE
,   p_scheduled_flag                IN  NUMBER
,   p_scheduled_start_date          IN  DATE
,   p_schedule_group_id             IN  NUMBER
,   p_schedule_number               IN  VARCHAR2
,   p_status                        IN  NUMBER
,   p_std_cost_adjustment_acct      IN  NUMBER
,   p_task_id                       IN  NUMBER
,   p_wip_entity_id                 IN  NUMBER
,   p_end_item_unit_number          IN  VARCHAR2
,   p_quantity_scrapped             IN  NUMBER
);

/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type).Also added local variables to make it
compatible with the call to (MRP_FLow_Schedule_PVT.Process_Flow_Schedule)
*/
PROCEDURE Create_Flow_Schedule
(   x_return_status                 OUT NOCOPY	VARCHAR2
,   x_msg_count                     OUT NOCOPY	NUMBER
,   x_msg_data                      OUT NOCOPY	VARCHAR2
,   p_alternate_bom_designator      IN  VARCHAR2
,   p_alternate_routing_desig       IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_attribute_category            IN  VARCHAR2
,   p_bom_revision                  IN  VARCHAR2
,   p_bom_revision_date             IN  DATE
,   p_build_sequence                IN  NUMBER
,   p_class_code                    IN  VARCHAR2
,   p_completion_locator_id         IN  NUMBER
,   p_completion_subinventory       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_date_closed                   IN  DATE
,   p_demand_class                  IN  VARCHAR2
,   p_demand_source_delivery        IN  VARCHAR2
,   p_demand_source_header_id       IN  NUMBER
,   p_demand_source_line            IN  VARCHAR2
,   p_demand_source_type            IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_material_account              IN  NUMBER
,   p_material_overhead_account     IN  NUMBER
,   p_material_variance_account     IN  NUMBER
,   p_mps_net_quantity              IN  NUMBER
,   p_mps_scheduled_comp_date       IN  DATE
,   p_organization_id               IN  NUMBER
,   p_outside_processing_acct       IN  NUMBER
,   p_outside_proc_var_acct         IN  NUMBER
,   p_overhead_account              IN  NUMBER
,   p_overhead_variance_account     IN  NUMBER
,   p_planned_quantity              IN  NUMBER
,   p_primary_item_id               IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_project_id                    IN  NUMBER
,   p_quantity_completed            IN  NUMBER
,   p_request_id                    IN  NUMBER
,   p_resource_account              IN  NUMBER
,   p_resource_variance_account     IN  NUMBER
,   p_routing_revision              IN  VARCHAR2
,   p_routing_revision_date         IN  DATE
,   p_scheduled_completion_date     IN  DATE
,   p_scheduled_flag                IN  NUMBER
,   p_scheduled_start_date          IN  DATE
,   p_schedule_group_id             IN  NUMBER
,   p_schedule_number               IN  VARCHAR2
,   p_status                        IN  NUMBER
,   p_std_cost_adjustment_acct      IN  NUMBER
,   p_task_id                       IN  NUMBER
,   p_wip_entity_id                 IN  NUMBER
,   p_end_item_unit_number          IN  VARCHAR2
,   p_quantity_scrapped             IN  NUMBER
,   x_wip_entity_id                 OUT NOCOPY	NUMBER
);

PROCEDURE get_default_dff (
                x_return_status OUT NOCOPY varchar2,
                p_attribute1 IN OUT NOCOPY varchar2,
                p_attribute2 IN OUT NOCOPY varchar2,
                p_attribute3 IN OUT NOCOPY varchar2,
                p_attribute4 IN OUT NOCOPY varchar2,
                p_attribute5 IN OUT NOCOPY varchar2,
                p_attribute6 IN OUT NOCOPY varchar2,
                p_attribute7 IN OUT NOCOPY varchar2,
                p_attribute8 IN OUT NOCOPY varchar2,
                p_attribute9 IN OUT NOCOPY varchar2,
                p_attribute10 IN OUT NOCOPY varchar2,
                p_attribute11 IN OUT NOCOPY varchar2,
                p_attribute12 IN OUT NOCOPY varchar2,
                p_attribute13 IN OUT NOCOPY varchar2,
                p_attribute14 IN OUT NOCOPY varchar2,
                p_attribute15 IN OUT NOCOPY varchar2

);

/*
Enhancement : 2665434
Reversed the logic.Passing NULL instead of G_MISS when we call Create_Flow_Schedule.
*/

/*Bug 2906442 - added parameter p_primary_routing as part of porting
                FP-H BUTLER issue (2859310) to I */
PROCEDURE Create_Raw_Flow_Schedules
(   x_return_status                 OUT NOCOPY	VARCHAR2
,   x_msg_count                     OUT NOCOPY	NUMBER
,   x_msg_data                      OUT NOCOPY	VARCHAR2
,   x_created_count              IN OUT NOCOPY	NUMBER
,   x_lock_count                 IN OUT NOCOPY	NUMBER
,   p_organization_id               IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_unscheduled_order_type        IN  NUMBER
,   p_demand_start_date             IN  DATE
,   p_demand_end_date               IN  DATE
,   p_schedule_group_id             IN  NUMBER
,   p_schedule_rule_id              IN  NUMBER
,   p_rule_user_defined             IN  NUMBER
,   p_primary_routing               IN  NUMBER
);


END MRP_WFS_Form_Flow_Schedule;

 

/
