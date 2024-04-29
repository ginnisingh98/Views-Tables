--------------------------------------------------------
--  DDL for Package MRP_FLOW_SCHEDULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_FLOW_SCHEDULE_PUB" AUTHID CURRENT_USER AS
/* $Header: MRPPWFSS.pls 120.1 2006/03/21 15:43:58 yulin noship $ */
/*#
 * The Flow Schedule APIs are used to create, update, delete, retrieve, lock, schedule and
 * unlink order lines of flow schedules.
 * @rep:scope public
 * @rep:product FLM
 * @rep:lifecycle active
 * @rep:displayname Flow Schedule API
 * @rep:category BUSINESS_ENTITY FLM_FLOW_SCHEDULE
 */


--  Flow_Schedule record type

TYPE Flow_Schedule_Rec_Type IS RECORD
(   alternate_bom_designator      VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   alternate_routing_desig       VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   attribute1                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(150)  := FND_API.G_MISS_CHAR
,   attribute_category            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   bom_revision                  VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   bom_revision_date             DATE           := FND_API.G_MISS_DATE
,   build_sequence                NUMBER         := FND_API.G_MISS_NUM
,   class_code                    VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   completion_locator_id         NUMBER         := FND_API.G_MISS_NUM
,   completion_subinventory       VARCHAR2(10)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   date_closed                   DATE           := FND_API.G_MISS_DATE
,   demand_class                  VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   demand_source_delivery        VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   demand_source_header_id       NUMBER         := FND_API.G_MISS_NUM
,   demand_source_line            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   demand_source_type            NUMBER         := FND_API.G_MISS_NUM
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   line_id                       NUMBER         := FND_API.G_MISS_NUM
,   material_account              NUMBER         := FND_API.G_MISS_NUM
,   material_overhead_account     NUMBER         := FND_API.G_MISS_NUM
,   material_variance_account     NUMBER         := FND_API.G_MISS_NUM
,   mps_net_quantity              NUMBER         := FND_API.G_MISS_NUM
,   mps_scheduled_comp_date       DATE           := FND_API.G_MISS_DATE
,   organization_id               NUMBER         := FND_API.G_MISS_NUM
,   outside_processing_acct       NUMBER         := FND_API.G_MISS_NUM
,   outside_proc_var_acct         NUMBER         := FND_API.G_MISS_NUM
,   overhead_account              NUMBER         := FND_API.G_MISS_NUM
,   overhead_variance_account     NUMBER         := FND_API.G_MISS_NUM
,   planned_quantity              NUMBER         := FND_API.G_MISS_NUM
,   primary_item_id               NUMBER         := FND_API.G_MISS_NUM
,   program_application_id        NUMBER         := FND_API.G_MISS_NUM
,   program_id                    NUMBER         := FND_API.G_MISS_NUM
,   program_update_date           DATE           := FND_API.G_MISS_DATE
,   project_id                    NUMBER         := FND_API.G_MISS_NUM
,   quantity_completed            NUMBER         := FND_API.G_MISS_NUM
,   request_id                    NUMBER         := FND_API.G_MISS_NUM
,   resource_account              NUMBER         := FND_API.G_MISS_NUM
,   resource_variance_account     NUMBER         := FND_API.G_MISS_NUM
,   routing_revision              VARCHAR2(3)    := FND_API.G_MISS_CHAR
,   routing_revision_date         DATE           := FND_API.G_MISS_DATE
,   scheduled_completion_date     DATE           := FND_API.G_MISS_DATE
,   scheduled_flag                NUMBER         := FND_API.G_MISS_NUM
,   scheduled_start_date          DATE           := FND_API.G_MISS_DATE
,   schedule_group_id             NUMBER         := FND_API.G_MISS_NUM
,   schedule_number               VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   status                        NUMBER         := FND_API.G_MISS_NUM
,   std_cost_adjustment_acct      NUMBER         := FND_API.G_MISS_NUM
,   task_id                       NUMBER         := FND_API.G_MISS_NUM
,   wip_entity_id                 NUMBER         := FND_API.G_MISS_NUM
,   scheduled_by                  NUMBER         := FND_API.G_MISS_NUM
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   end_item_unit_number          VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   quantity_scrapped             NUMBER         := FND_API.G_MISS_NUM
,   kanban_card_id                NUMBER         := FND_API.G_MISS_NUM
,   synch_schedule_num            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   synch_operation_seq_num       NUMBER         := FND_API.G_MISS_NUM
,   roll_forwarded_flag		  NUMBER
,   current_line_operation 	  NUMBER
);

TYPE Flow_Schedule_Tbl_Type IS TABLE OF Flow_Schedule_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Flow_Schedule value record type

TYPE Flow_Schedule_Val_Rec_Type IS RECORD
(   completion_locator            VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   line                          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   organization                  VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   primary_item                  VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   project                       VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   schedule_group                VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   task                          VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   wip_entity                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
);

TYPE Flow_Schedule_Val_Tbl_Type IS TABLE OF Flow_Schedule_Val_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Variables representing missing records and tables

G_MISS_FLOW_SCHEDULE_REC      Flow_Schedule_Rec_Type;
G_MISS_FLOW_SCHEDULE_VAL_REC  Flow_Schedule_Val_Rec_Type;
G_MISS_FLOW_SCHEDULE_TBL      Flow_Schedule_Tbl_Type;
G_MISS_FLOW_SCHEDULE_VAL_TBL  Flow_Schedule_Val_Tbl_Type;

--  Start of Comments
--  API name    Process_Flow_Schedule
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

/*
Enhancement : 2665434
Description : Called a conversion function to convert from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type) for IN variables and a
conversion function to convert from new record type to new record type
.Also added local variables to make it compatible with the call to
(MRP_FLow_Schedule_PVT package procedures).Removed call to BOM code from this
procedure.It has been shifted to PVT API.
*/
/*#
 * The Process_Flow_Schedule API is used to create, update and delete a flow schedule.
 * @param p_api_version_number API version number
 * @paraminfo {@rep:required}
 * @param p_init_msg_list Pass fnd_api.g_false or fnd_api.g_true to determin whether to clear message stack or not
 * @param p_return_values Return values
 * @param p_commit Pass fnd_api.g_false or fnd_api.g_true to determin whether to commit or not
 * @param x_return_status Return status
 * @param x_msg_count Number of messages
 * @param x_msg_data  Message data
 * @param p_flow_schedule_rec Input flow schedule record of type MRP_FLOW_SCHEDULE_PUB. FLOW_SCHEDULE_REC_TYPE. Default value: G_MISS_FLOW_SCHEDULE_VAL_REC
 * @param p_flow_schedule_val_rec Input flow schedule value record of type MRP_FLOW_SCHEDULE_PUB.FLOW_SCHEDULE_VAL_REC_TYPE. Default value: G_MISS_FLOW_SCHEDULE_VAL_REC
 * @param x_flow_schedule_rec Output flow schedule record of type MRP_FLOW_SCHEDULE_PUB. FLOW_SCHEDULE_REC_TYPE
 * @param x_flow_schedule_val_rec Output flow schedule value record of type MRP_FLOW_SCHEDULE_PUB.FLOW_SCHEDULE_VAL_REC_TYPE
 * @param p_explode_bom Whether to expode BOM
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Flow Schedule
 */
PROCEDURE Process_Flow_Schedule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_flow_schedule_rec             IN  Flow_Schedule_Rec_Type :=
                                        G_MISS_FLOW_SCHEDULE_REC
,   p_flow_schedule_val_rec         IN  Flow_Schedule_Val_Rec_Type :=
                                        G_MISS_FLOW_SCHEDULE_VAL_REC
,   x_flow_schedule_rec             OUT NOCOPY Flow_Schedule_Rec_Type
,   x_flow_schedule_val_rec         OUT NOCOPY Flow_Schedule_Val_Rec_Type
,   p_explode_bom		    IN  VARCHAR2 := 'N'
);

--  Start of Comments
--  API name    Lock_Flow_Schedule
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
/*
Enhancement : 2665434
Description : Called a conversion function to convert from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type) for IN variables and a
conversion function to convert from new record type to new record type
.Also added local variables to make it compatible with the call to
(MRP_FLow_Schedule_PVT package procedures).Removed call to BOM code from this
procedure.It has been shifted to PVT API.
*/

PROCEDURE Lock_Flow_Schedule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_flow_schedule_rec             IN  Flow_Schedule_Rec_Type :=
                                        G_MISS_FLOW_SCHEDULE_REC
,   p_flow_schedule_val_rec         IN  Flow_Schedule_Val_Rec_Type :=
                                        G_MISS_FLOW_SCHEDULE_VAL_REC
,   x_flow_schedule_rec             OUT NOCOPY Flow_Schedule_Rec_Type
,   x_flow_schedule_val_rec         OUT NOCOPY Flow_Schedule_Val_Rec_Type
);

--  Start of Comments
--  API name    Get_Flow_Schedule
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
/*
Enhancement : 2665434
Description : Called a conversion function to convert from new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type) to old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) for OUT variable
*/
/*#
 * The Get_Flow_Schedule API is to get the information for the a flow schedule.
 * @param p_api_version_number API version number
 * @paraminfo {@rep:required}
 * @param p_init_msg_list Pass fnd_api.g_false or fnd_api.g_true to determin whether to clear message stack or not
 * @param p_return_values Return values
 * @param x_return_status Return status
 * @param x_msg_count Number of messages
 * @param x_msg_data  Message data
 * @param p_wip_entity_id The wip entity identifier associated with the flow schedule
 * @param p_wip_entity The name of the flow schedule
 * @param x_flow_schedule_rec Output flow schedule record of type MRP_FLOW_SCHEDULE_PUB. FLOW_SCHEDULE_REC_TYPE
 * @param x_flow_schedule_val_rec Output flow schedule value record of type MRP_FLOW_SCHEDULE_PUB.FLOW_SCHEDULE_VAL_REC_TYPE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Flow Schedule
 */
PROCEDURE Get_Flow_Schedule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_wip_entity_id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_wip_entity                    IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_flow_schedule_rec             OUT NOCOPY Flow_Schedule_Rec_Type
,   x_flow_schedule_val_rec         OUT NOCOPY Flow_Schedule_Val_Rec_Type
);

--  Start of Comments
--  API name    Line_Schedule
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
/*#
 * The Line_Schedule API will reschedule the flow schedules in the given line,
 * organization, and completion date range using the scheduling rule. This API only
 * schedules the flow schedules created in the same session as the creation of the
 * original flow schedule, which is created by PROCESS_FLOW_SCHEDULE API.
 * @param p_api_version_number API version number
 * @paraminfo {@rep:required}
 * @param x_return_status Return status
 * @param x_msg_count Number of messages
 * @param x_msg_data  Message data
 * @param p_rule_id The scheduling rule identifier
 * @paraminfo {@rep:required}
 * @param p_line_id The production line identifier
 * @paraminfo {@rep:required}
 * @param p_org_id The organization identifier
 * @paraminfo {@rep:required}
 * @param p_sched_start_date The start date of the flow schedules to be scheduled
 * @paraminfo {@rep:required}
 * @param p_sched_end_date The end date of the flow schedules to be scheduled
 * @paraminfo {@rep:required}
 * @param p_update To update the database
 * @paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Line Schedule
 */
PROCEDURE Line_Schedule
(   p_api_version_number            IN  NUMBER
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_rule_id                       IN NUMBER
,   p_line_id                       IN NUMBER
,   p_org_id                        IN NUMBER
,   p_sched_start_date              IN DATE
,   p_sched_end_date                IN DATE
,   p_update                        IN NUMBER
);

--  Start of Comments
--  API name    get_first_unit_completion_date
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

FUNCTION get_first_unit_completion_date
(   p_api_version_number            IN  NUMBER
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_org_id                        IN NUMBER
,   p_item_id                       IN NUMBER
,   p_qty                           IN NUMBER
,   p_line_id                       IN NUMBER
,   p_start_date                    IN DATE
) RETURN DATE;

--  Start of Comments
--  API name    get_operation_offset_date
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

FUNCTION get_operation_offset_date
(p_api_version_number 		IN NUMBER,
x_return_status		 	OUT NOCOPY VARCHAR2,
x_msg_count 			OUT NOCOPY NUMBER,
x_msg_data 			OUT NOCOPY VARCHAR2,
p_org_id 			IN NUMBER,
p_assembly_item_id 		IN NUMBER,
p_routing_sequence_id 		IN NUMBER,
p_operation_sequence_id 	IN NUMBER,
p_assembly_qty 			IN NUMBER,
p_assembly_comp_date 		IN DATE,
p_calculate_option 		IN NUMBER
) return DATE;


--  Start of Comments
--  API name    unlink_order_line
--  Type        Public
--  Procedure
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--  This API is used to remove sales order reference in
--  flow schedules. The following is one of the scenario :
--    Flow schedules created from sales order line
--    Sales order line got canceled or become unavailalbe
--    Flow schedules now referenced to dangling sale order line
--
--  End of Comments
/*#
 * The Unlink_Order_Line API will remove a given sales order reference from all
 * flow schedules that make reference to the given sales order.
 * @param p_api_version_number API version number
 * @paraminfo {@rep:required}
 * @param x_return_status Return status
 * @param x_msg_count Number of messages
 * @param x_msg_data  Message data
 * @param p_assembly_item_id The assembly identifier
 * @paraminfo {@rep:required}
 * @param p_line_id Sales order Line identifier
 * @paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Unlink Order Line
 */
procedure unlink_order_line
(
p_api_version_number 		IN NUMBER,
x_return_status		 	OUT NOCOPY VARCHAR2,
x_msg_count 			OUT NOCOPY NUMBER,
x_msg_data 			OUT NOCOPY VARCHAR2,
p_assembly_item_id 		IN NUMBER,
p_line_id                       IN NUMBER
);


END MRP_Flow_Schedule_PUB;

 

/
