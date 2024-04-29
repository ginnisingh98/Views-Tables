--------------------------------------------------------
--  DDL for Package WIP_WORK_ORDER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WORK_ORDER_PUB" AUTHID CURRENT_USER AS
/* $Header: WIPPWORS.pls 120.1 2005/06/13 09:27:20 appldev  $ */

--  Wip_Entities record type

TYPE Wip_Entities_Rec_Type IS RECORD
(   created_by                    NUMBER
,   creation_date                 DATE
,   description                   VARCHAR2(240)
,   entity_type                   NUMBER
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   organization_id               NUMBER
,   primary_item_id               NUMBER
,   program_application_id        NUMBER
,   program_id                    NUMBER
,   program_update_date           DATE
,   request_id                    NUMBER
,   wip_entity_id                 NUMBER
,   wip_entity_name               VARCHAR2(240)
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   action                        VARCHAR2(30)
);

TYPE Wip_Entities_Tbl_Type IS TABLE OF Wip_Entities_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Wip_Entities value record type

TYPE Wip_Entities_Val_Rec_Type IS RECORD
(   organization                  VARCHAR2(240)
,   primary_item                  VARCHAR2(240)
,   wip_entity                    VARCHAR2(240)
);

TYPE Wip_Entities_Val_Tbl_Type IS TABLE OF Wip_Entities_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Flowschedule record type

TYPE Flowschedule_Rec_Type IS RECORD
(   alternate_bom_designator      VARCHAR2(10)
,   alternate_rout_designator     VARCHAR2(10)
,   attribute1                    VARCHAR2(150)
,   attribute10                   VARCHAR2(150)
,   attribute11                   VARCHAR2(150)
,   attribute12                   VARCHAR2(150)
,   attribute13                   VARCHAR2(150)
,   attribute14                   VARCHAR2(150)
,   attribute15                   VARCHAR2(150)
,   attribute2                    VARCHAR2(150)
,   attribute3                    VARCHAR2(150)
,   attribute4                    VARCHAR2(150)
,   attribute5                    VARCHAR2(150)
,   attribute6                    VARCHAR2(150)
,   attribute7                    VARCHAR2(150)
,   attribute8                    VARCHAR2(150)
,   attribute9                    VARCHAR2(150)
,   attribute_category            VARCHAR2(30)
,   bom_revision                  VARCHAR2(3)
,   bom_revision_date             DATE
,   build_sequence                NUMBER
,   class_code                    VARCHAR2(10)
,   completion_locator_id         NUMBER
,   completion_subinventory       VARCHAR2(10)
,   created_by                    NUMBER
,   creation_date                 DATE
,   date_closed                   DATE
,   demand_class                  VARCHAR2(30)
,   demand_source_delivery        VARCHAR2(30)
,   demand_source_header_id       NUMBER
,   demand_source_line            VARCHAR2(30)
,   demand_source_type            NUMBER
,   kanban_card_id                NUMBER
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   line_id                       NUMBER
,   material_account              NUMBER
,   material_overhead_account     NUMBER
,   material_variance_account     NUMBER
,   mps_net_quantity              NUMBER
,   mps_scheduled_cpl_date        DATE
,   organization_id               NUMBER
,   osp_account                   NUMBER
,   osp_variance_account          NUMBER
,   overhead_account              NUMBER
,   overhead_variance_account     NUMBER
,   planned_quantity              NUMBER
,   primary_item_id               NUMBER
,   program_application_id        NUMBER
,   program_id                    NUMBER
,   program_update_date           DATE
,   project_id                    NUMBER
,   quantity_completed            NUMBER
,   request_id                    NUMBER
,   resource_account              NUMBER
,   resource_variance_account     NUMBER
,   routing_revision              VARCHAR2(3)
,   routing_revision_date         DATE
,   scheduled_completion_date     DATE
,   scheduled_flag                NUMBER
,   scheduled_start_date          DATE
,   schedule_group_id             NUMBER
,   schedule_number               VARCHAR2(30)
,   status                        NUMBER
,   std_cost_adj_account          NUMBER
,   task_id                       NUMBER
,   wip_entity_id                 NUMBER
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   action                        VARCHAR2(30)
,   Wip_Entities_index            NUMBER
);

TYPE Flowschedule_Tbl_Type IS TABLE OF Flowschedule_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Flowschedule value record type

TYPE Flowschedule_Val_Rec_Type IS RECORD
(   class                         VARCHAR2(240)
,   completion_locator            VARCHAR2(240)
,   demand_source_header          VARCHAR2(240)
,   kanban_card                   VARCHAR2(240)
,   line                          VARCHAR2(240)
,   organization                  VARCHAR2(240)
,   primary_item                  VARCHAR2(240)
,   project                       VARCHAR2(240)
,   scheduled                     VARCHAR2(240)
,   schedule_group                VARCHAR2(240)
,   task                          VARCHAR2(240)
,   wip_entity                    VARCHAR2(240)
);

TYPE Flowschedule_Val_Tbl_Type IS TABLE OF Flowschedule_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Discretejob record type

/* ER 4378835: Increased length of lot_number from 30 to 80 to support OPM Lot-model changes */
TYPE Discretejob_Rec_Type IS RECORD
(   alternate_bom_designator      VARCHAR2(10)
,   alternate_rout_designator     VARCHAR2(10)
,   attribute1                    VARCHAR2(150)
,   attribute10                   VARCHAR2(150)
,   attribute11                   VARCHAR2(150)
,   attribute12                   VARCHAR2(150)
,   attribute13                   VARCHAR2(150)
,   attribute14                   VARCHAR2(150)
,   attribute15                   VARCHAR2(150)
,   attribute2                    VARCHAR2(150)
,   attribute3                    VARCHAR2(150)
,   attribute4                    VARCHAR2(150)
,   attribute5                    VARCHAR2(150)
,   attribute6                    VARCHAR2(150)
,   attribute7                    VARCHAR2(150)
,   attribute8                    VARCHAR2(150)
,   attribute9                    VARCHAR2(150)
,   attribute_category            VARCHAR2(30)
,   bom_reference_id              NUMBER
,   bom_revision                  VARCHAR2(3)
,   bom_revision_date             DATE
,   build_sequence                NUMBER
,   class_code                    VARCHAR2(10)
,   common_bom_sequence_id        NUMBER
,   common_rout_sequence_id       NUMBER
,   completion_locator_id         NUMBER
,   completion_subinventory       VARCHAR2(10)
,   created_by                    NUMBER
,   creation_date                 DATE
,   date_closed                   DATE
,   date_completed                DATE
,   date_released                 DATE
,   demand_class                  VARCHAR2(30)
,   description                   VARCHAR2(240)
,   firm_planned_flag             NUMBER
,   job_type                      NUMBER
,   kanban_card_id                NUMBER
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   line_id                       NUMBER
,   lot_number                    VARCHAR2(80)
,   material_account              NUMBER
,   material_overhead_account     NUMBER
,   material_variance_account     NUMBER
,   mps_net_quantity              NUMBER
,   mps_scheduled_cpl_date        DATE
,   net_quantity                  NUMBER
,   organization_id               NUMBER
,   osp_account                   NUMBER
,   osp_variance_account          NUMBER
,   overcpl_tolerance_type        NUMBER
,   overcpl_tolerance_value       NUMBER
,   overhead_account              NUMBER
,   overhead_variance_account     NUMBER
,   primary_item_id               NUMBER
,   program_application_id        NUMBER
,   program_id                    NUMBER
,   program_update_date           DATE
,   project_costed                NUMBER
,   project_id                    NUMBER
,   quantity_completed            NUMBER
,   quantity_scrapped             NUMBER
,   request_id                    NUMBER
,   resource_account              NUMBER
,   resource_variance_account     NUMBER
,   routing_reference_id          NUMBER
,   routing_revision              VARCHAR2(3)
,   routing_revision_date         DATE
,   scheduled_completion_date     DATE
,   scheduled_start_date          DATE
,   schedule_group_id             NUMBER
,   source_code                   VARCHAR2(30)
,   source_line_id                NUMBER
,   start_quantity                NUMBER
,   status_type                   NUMBER
,   std_cost_adj_account          NUMBER
,   task_id                       NUMBER
,   wip_entity_id                 NUMBER
,   wip_supply_type               NUMBER
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   action                        VARCHAR2(30)
,   Wip_Entities_index            NUMBER
);

TYPE Discretejob_Tbl_Type IS TABLE OF Discretejob_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Discretejob value record type

TYPE Discretejob_Val_Rec_Type IS RECORD
(   bom_reference                 VARCHAR2(240)
,   class                         VARCHAR2(240)
,   common_bom_sequence           VARCHAR2(240)
,   common_rout_sequence          VARCHAR2(240)
,   completion_locator            VARCHAR2(240)
,   firm_planned                  VARCHAR2(240)
,   kanban_card                   VARCHAR2(240)
,   line                          VARCHAR2(240)
,   organization                  VARCHAR2(240)
,   primary_item                  VARCHAR2(240)
,   project                       VARCHAR2(240)
,   routing_reference             VARCHAR2(240)
,   schedule_group                VARCHAR2(240)
,   source                        VARCHAR2(240)
,   source_line                   VARCHAR2(240)
,   task                          VARCHAR2(240)
,   wip_entity                    VARCHAR2(240)
);

TYPE Discretejob_Val_Tbl_Type IS TABLE OF Discretejob_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Repschedule record type

TYPE Repschedule_Rec_Type IS RECORD
(   alternate_bom_designator      VARCHAR2(10)
,   alternate_rout_designator     VARCHAR2(10)
,   attribute1                    VARCHAR2(150)
,   attribute10                   VARCHAR2(150)
,   attribute11                   VARCHAR2(150)
,   attribute12                   VARCHAR2(150)
,   attribute13                   VARCHAR2(150)
,   attribute14                   VARCHAR2(150)
,   attribute15                   VARCHAR2(150)
,   attribute2                    VARCHAR2(150)
,   attribute3                    VARCHAR2(150)
,   attribute4                    VARCHAR2(150)
,   attribute5                    VARCHAR2(150)
,   attribute6                    VARCHAR2(150)
,   attribute7                    VARCHAR2(150)
,   attribute8                    VARCHAR2(150)
,   attribute9                    VARCHAR2(150)
,   attribute_category            VARCHAR2(30)
,   bom_revision                  VARCHAR2(3)
,   bom_revision_date             DATE
,   common_bom_sequence_id        NUMBER
,   common_rout_sequence_id       NUMBER
,   created_by                    NUMBER
,   creation_date                 DATE
,   daily_production_rate         NUMBER
,   date_closed                   DATE
,   date_released                 DATE
,   demand_class                  VARCHAR2(30)
,   description                   VARCHAR2(240)
,   firm_planned_flag             NUMBER
,   first_unit_cpl_date           DATE
,   first_unit_start_date         DATE
,   last_unit_cpl_date            DATE
,   last_unit_start_date          DATE
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   line_id                       NUMBER
,   material_account              NUMBER
,   material_overhead_account     NUMBER
,   material_variance_account     NUMBER
,   organization_id               NUMBER
,   osp_account                   NUMBER
,   osp_variance_account          NUMBER
,   overhead_account              NUMBER
,   overhead_variance_account     NUMBER
,   processing_work_days          NUMBER
,   program_application_id        NUMBER
,   program_id                    NUMBER
,   program_update_date           DATE
,   quantity_completed            NUMBER
,   repetitive_schedule_id        NUMBER
,   request_id                    NUMBER
,   resource_account              NUMBER
,   resource_variance_account     NUMBER
,   routing_revision              VARCHAR2(3)
,   routing_revision_date         DATE
,   status_type                   NUMBER
,   wip_entity_id                 NUMBER
,   kanban_card_id                NUMBER
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   action                        VARCHAR2(30)
,   Wip_Entities_index            NUMBER
,   primary_item_id               NUMBER
);

TYPE Repschedule_Tbl_Type IS TABLE OF Repschedule_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Repschedule value record type

TYPE Repschedule_Val_Rec_Type IS RECORD
(   common_bom_sequence           VARCHAR2(240)
,   common_rout_sequence          VARCHAR2(240)
,   firm_planned                  VARCHAR2(240)
,   line                          VARCHAR2(240)
,   organization                  VARCHAR2(240)
,   repetitive_schedule           VARCHAR2(240)
,   wip_entity                    VARCHAR2(240)
);

TYPE Repschedule_Val_Tbl_Type IS TABLE OF Repschedule_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Variables representing missing records and tables

G_MISS_WIP_ENTITIES_REC       Wip_Entities_Rec_Type;
G_MISS_WIP_ENTITIES_VAL_REC   Wip_Entities_Val_Rec_Type;
G_MISS_WIP_ENTITIES_TBL       Wip_Entities_Tbl_Type;
G_MISS_WIP_ENTITIES_VAL_TBL   Wip_Entities_Val_Tbl_Type;
G_MISS_FLOWSCHEDULE_REC       Flowschedule_Rec_Type;
G_MISS_FLOWSCHEDULE_VAL_REC   Flowschedule_Val_Rec_Type;
G_MISS_FLOWSCHEDULE_TBL       Flowschedule_Tbl_Type;
G_MISS_FLOWSCHEDULE_VAL_TBL   Flowschedule_Val_Tbl_Type;
G_MISS_DISCRETEJOB_REC        Discretejob_Rec_Type;
G_MISS_DISCRETEJOB_VAL_REC    Discretejob_Val_Rec_Type;
G_MISS_DISCRETEJOB_TBL        Discretejob_Tbl_Type;
G_MISS_DISCRETEJOB_VAL_TBL    Discretejob_Val_Tbl_Type;
G_MISS_REPSCHEDULE_REC        Repschedule_Rec_Type;
G_MISS_REPSCHEDULE_VAL_REC    Repschedule_Val_Rec_Type;
G_MISS_REPSCHEDULE_TBL        Repschedule_Tbl_Type;
G_MISS_REPSCHEDULE_VAL_TBL    Repschedule_Val_Tbl_Type;


--  Start of Comments
--  API name    Get_Work_Order
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Work_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2
,   p_return_values                 IN  VARCHAR2
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_wip_entity_id                 IN  NUMBER
,   x_Wip_Entities_tbl              OUT NOCOPY Wip_Entities_Tbl_Type
,   x_Wip_Entities_val_tbl          OUT NOCOPY Wip_Entities_Val_Tbl_Type
,   x_FlowSchedule_tbl              OUT NOCOPY Flowschedule_Tbl_Type
,   x_FlowSchedule_val_tbl          OUT NOCOPY Flowschedule_Val_Tbl_Type
,   x_DiscreteJob_tbl               OUT NOCOPY Discretejob_Tbl_Type
,   x_DiscreteJob_val_tbl           OUT NOCOPY Discretejob_Val_Tbl_Type
,   x_RepSchedule_tbl               OUT NOCOPY Repschedule_Tbl_Type
,   x_RepSchedule_val_tbl           OUT NOCOPY Repschedule_Val_Tbl_Type
);

END WIP_Work_Order_PUB;

 

/
