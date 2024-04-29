--------------------------------------------------------
--  DDL for Package MRP_FLOW_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_FLOW_SCHEDULE_PVT" AUTHID CURRENT_USER AS
/* $Header: MRPVWFSS.pls 120.0.12010000.2 2009/05/19 06:36:05 adasa ship $ */

--  Start of Comments
--  API name    Process_Flow_Schedule
--  Type        Private
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

/*Enhancement : 2665434 .New record types defined for PLSQL standards compliance.
These record types do not have any defaulting .
*/

TYPE Flow_Schedule_PVT_Rec_Type IS RECORD
(   alternate_bom_designator      VARCHAR2(10)
,   alternate_routing_desig       VARCHAR2(10)
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
,   last_updated_by               NUMBER
,   last_update_date              DATE
,   last_update_login             NUMBER
,   line_id                       NUMBER
,   material_account              NUMBER
,   material_overhead_account     NUMBER
,   material_variance_account     NUMBER
,   mps_net_quantity              NUMBER
,   mps_scheduled_comp_date       DATE
,   organization_id               NUMBER
,   outside_processing_acct       NUMBER
,   outside_proc_var_acct         NUMBER
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
,   std_cost_adjustment_acct      NUMBER
,   task_id                       NUMBER
,   wip_entity_id                 NUMBER
,   scheduled_by                  NUMBER
,   return_status                 VARCHAR2(1)
,   db_flag                       VARCHAR2(1)
,   operation                     VARCHAR2(30)
,   end_item_unit_number          VARCHAR2(30)
,   quantity_scrapped             NUMBER
,   kanban_card_id                NUMBER
,   synch_schedule_num            VARCHAR2(30)
,   synch_operation_seq_num       NUMBER
,   roll_forwarded_flag		  NUMBER
,   current_line_operation 	  NUMBER
,   so_consumed_plan_id           VARCHAR2(30) /*Added for bug 8200872 */
);

TYPE Flow_Schedule_Val_PVT_Rec_Type IS RECORD
(   completion_locator     VARCHAR2(240)
,   line                   VARCHAR2(240)
,   organization           VARCHAR2(240)
,   primary_item           VARCHAR2(240)
,   project                VARCHAR2(240)
,   schedule_group         VARCHAR2(240)
,   task                   VARCHAR2(240)
,   wip_entity             VARCHAR2(240)
);

/*
Enhancement 2665434 : The following four procedures are for inter conversion between
MRP_Flow_Schedule_PUB.flow_schedule_rec_type and MRP_Flow_Schedule_PVT.flow_schedule_PVT_rec_type .
Similarly for inter conversion between Flow_Schedule_Val_Rec_Type and Flow_Schedule_Val_Pvt_Rec_Type.
*/


PROCEDURE  PUB_Flow_Sched_Val_Rec_To_PVT (
	p_flow_schedule_Val_rec IN MRP_Flow_Schedule_PUB.Flow_Schedule_Val_Rec_Type  ,
	x_Flow_Schedule_Val_Pvt_Rec OUT NOCOPY Flow_Schedule_Val_Pvt_Rec_Type) ;

PROCEDURE  PUB_Flow_Sched_Rec_To_PVT (
	p_flow_schedule_rec IN MRP_Flow_Schedule_PUB.Flow_Schedule_Rec_Type  ,
	x_Flow_Schedule_Pvt_Rec OUT NOCOPY Flow_Schedule_Pvt_Rec_Type) ;

PROCEDURE  PVT_Flow_Sched_Val_Rec_To_PUB (
	p_Flow_Schedule_Val_Pvt_Rec IN Flow_Schedule_Val_Pvt_Rec_Type ,
	x_flow_schedule_Val_Rec OUT NOCOPY MRP_Flow_Schedule_PUB.Flow_Schedule_Val_Rec_Type  ) ;

PROCEDURE  PVT_Flow_Sched_Rec_To_PUB (
	p_Flow_Schedule_Pvt_Rec IN Flow_Schedule_Pvt_Rec_Type ,
	x_flow_schedule_Rec OUT NOCOPY MRP_Flow_Schedule_PUB.Flow_Schedule_Rec_Type  ) ;

/*Enhancement 2665434
Added parameter p_explode_bom . The code for BOM_OE_EXPLODER_PKG.be_exploder has been
shifted from MRP_Flow_Schedule_PUB.Process_Flow_Schedule to the PVT Process_Flow_Schedule
Changed defaulting from non-null values to NULL for p_init_msg_list,p_commit and p_validation_level
Removed defaulting from record types .
*/

PROCEDURE Process_Flow_Schedule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := NULL
,   p_commit                        IN  VARCHAR2 := NULL
,   p_validation_level              IN  NUMBER := NULL
,   p_control_rec                   IN  MRP_GLOBALS.Control_Rec_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_old_flow_schedule_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   x_flow_schedule_rec             IN  OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_explode_bom		    IN  VARCHAR2 := NULL
);

--  Start of Comments
--  API name    Lock_Flow_Schedule
--  Type        Private
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

/*
Enhancement : 2665434
Description : Changed x_flow_schedule_rec to be of MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
Also removed defaulting for p_flow_Schedule_rec ,as the 2 allers to the procedure
1)From MRP_Flow_Schedule_PUB.Lock_Row
2)From MRP_WFS_Form_Flow_Schedule.Lock_Row
are passing this record type explicitly.
*/

PROCEDURE Lock_Flow_Schedule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := NULL
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   x_flow_schedule_rec             IN  OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
);

--  Start of Comments
--  API name    Get_Flow_Schedule
--  Type        Private
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

/*
Enhancement : 2665434
Description : Changed x_flow_schedule_rec to be of
MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
*/

PROCEDURE Get_Flow_Schedule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := NULL
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_wip_entity_id                 IN  NUMBER
,   x_flow_schedule_rec             OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
);

END MRP_Flow_Schedule_PVT;

/
