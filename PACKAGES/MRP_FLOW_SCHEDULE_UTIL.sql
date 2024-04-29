--------------------------------------------------------
--  DDL for Package MRP_FLOW_SCHEDULE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_FLOW_SCHEDULE_UTIL" AUTHID CURRENT_USER AS
/* $Header: MRPUSCNS.pls 120.1 2005/06/01 10:16:06 appldev  $ */

--  Attributes global constants

G_ALTERNATE_BOM_DESIGNATOR    CONSTANT NUMBER := 1;
G_ALTERNATE_ROUTING_DESIG     CONSTANT NUMBER := 2;
G_ATTRIBUTE1                  CONSTANT NUMBER := 3;
G_ATTRIBUTE10                 CONSTANT NUMBER := 4;
G_ATTRIBUTE11                 CONSTANT NUMBER := 5;
G_ATTRIBUTE12                 CONSTANT NUMBER := 6;
G_ATTRIBUTE13                 CONSTANT NUMBER := 7;
G_ATTRIBUTE14                 CONSTANT NUMBER := 8;
G_ATTRIBUTE15                 CONSTANT NUMBER := 9;
G_ATTRIBUTE2                  CONSTANT NUMBER := 10;
G_ATTRIBUTE3                  CONSTANT NUMBER := 11;
G_ATTRIBUTE4                  CONSTANT NUMBER := 12;
G_ATTRIBUTE5                  CONSTANT NUMBER := 13;
G_ATTRIBUTE6                  CONSTANT NUMBER := 14;
G_ATTRIBUTE7                  CONSTANT NUMBER := 15;
G_ATTRIBUTE8                  CONSTANT NUMBER := 16;
G_ATTRIBUTE9                  CONSTANT NUMBER := 17;
G_ATTRIBUTE_CATEGORY          CONSTANT NUMBER := 18;
G_BOM_REVISION                CONSTANT NUMBER := 19;
G_BOM_REVISION_DATE           CONSTANT NUMBER := 20;
G_BUILD_SEQUENCE              CONSTANT NUMBER := 21;
G_CLASS                       CONSTANT NUMBER := 22;
G_COMPLETION_LOCATOR          CONSTANT NUMBER := 23;
G_COMPLETION_SUBINVENTORY     CONSTANT NUMBER := 24;
G_CREATED_BY                  CONSTANT NUMBER := 25;
G_CREATION_DATE               CONSTANT NUMBER := 26;
G_DATE_CLOSED                 CONSTANT NUMBER := 27;
G_DEMAND_CLASS                CONSTANT NUMBER := 28;
G_DEMAND_SOURCE_DELIVERY      CONSTANT NUMBER := 29;
G_DEMAND_SOURCE_HEADER        CONSTANT NUMBER := 30;
G_DEMAND_SOURCE_LINE          CONSTANT NUMBER := 31;
G_DEMAND_SOURCE_TYPE          CONSTANT NUMBER := 32;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 33;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 34;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 35;
G_LINE                        CONSTANT NUMBER := 36;
G_MATERIAL_ACCOUNT            CONSTANT NUMBER := 37;
G_MATERIAL_OVERHEAD_ACCOUNT   CONSTANT NUMBER := 38;
G_MATERIAL_VARIANCE_ACCOUNT   CONSTANT NUMBER := 39;
G_MPS_NET_QUANTITY            CONSTANT NUMBER := 40;
G_MPS_SCHEDULED_COMP_DATE     CONSTANT NUMBER := 41;
G_ORGANIZATION                CONSTANT NUMBER := 42;
G_OUTSIDE_PROCESSING_ACCT     CONSTANT NUMBER := 43;
G_OUTSIDE_PROC_VAR_ACCT       CONSTANT NUMBER := 44;
G_OVERHEAD_ACCOUNT            CONSTANT NUMBER := 45;
G_OVERHEAD_VARIANCE_ACCOUNT   CONSTANT NUMBER := 46;
G_PLANNED_QUANTITY            CONSTANT NUMBER := 47;
G_PRIMARY_ITEM                CONSTANT NUMBER := 48;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 49;
G_PROGRAM                     CONSTANT NUMBER := 50;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 51;
G_PROJECT                     CONSTANT NUMBER := 52;
G_QUANTITY_COMPLETED          CONSTANT NUMBER := 53;
G_REQUEST                     CONSTANT NUMBER := 54;
G_RESOURCE_ACCOUNT            CONSTANT NUMBER := 55;
G_RESOURCE_VARIANCE_ACCOUNT   CONSTANT NUMBER := 56;
G_ROUTING_REVISION            CONSTANT NUMBER := 57;
G_ROUTING_REVISION_DATE       CONSTANT NUMBER := 58;
G_SCHEDULED_COMPLETION_DATE   CONSTANT NUMBER := 59;
G_SCHEDULED                   CONSTANT NUMBER := 60;
G_SCHEDULED_START_DATE        CONSTANT NUMBER := 61;
G_SCHEDULE_GROUP              CONSTANT NUMBER := 62;
G_SCHEDULE_NUMBER             CONSTANT NUMBER := 63;
G_STATUS                      CONSTANT NUMBER := 64;
G_STD_COST_ADJUSTMENT_ACCT    CONSTANT NUMBER := 65;
G_TASK                        CONSTANT NUMBER := 66;
G_WIP_ENTITY                  CONSTANT NUMBER := 67;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 68;
G_END_ITEM_UNIT_NUMBER        CONSTANT NUMBER := 69;
G_QUANTITY_SCRAPPED           CONSTANT NUMBER := 70;

G_ROLL_FORWARDED              CONSTANT NUMBER := 1;
G_INTERMEDIATE_ROLL_FORWARDED  CONSTANT NUMBER := 2;
--  Define record type
TYPE report_rec_type IS RECORD(
    line_id		NUMBER,
    line_code		VARCHAR2(10),
    primary_item_id 	NUMBER,
    item		VARCHAR2(2000),
    schedule_number     VARCHAR2(30),
    build_sequence      NUMBER,
    demand_class        VARCHAR2(30),
    demand_source_line          VARCHAR2(30),
    demand_source_header_id     NUMBER,
    demand_source_delivery      VARCHAR2(30),
    demand_source_type          NUMBER,
    schedule_group_id		NUMBER,
    schedule_group		VARCHAR2(30),
    completion_date		DATE,
    planned_quantity 		NUMBER,
    quantity_completed  	NUMBER,
    variance1			NUMBER,
    to_completion_date  	DATE,
    to_scheduled_qty    	NUMBER,
    to_adjusted_qty    		NUMBER,
    variance2			NUMBER,
    MPS_SCHEDULED_COMPLETION_DATE DATE,
    MPS_NET_QUANTITY		NUMBER,
    BOM_REVISION 		VARCHAR2(3),
    ROUTING_REVISION 		VARCHAR2(3),
    BOM_REVISION_DATE   	DATE,
    ROUTING_REVISION_DATE  	DATE,
    ALTERNATE_BOM_DESIGNATOR    VARCHAR2(10),
    ALTERNATE_ROUTING_DESIGNATOR VARCHAR2(10),
    COMPLETION_SUBINVENTORY     VARCHAR2(10),
    COMPLETION_LOCATOR_ID       NUMBER,
    MATERIAL_ACCOUNT            NUMBER,
    MATERIAL_OVERHEAD_ACCOUNT                NUMBER,
    RESOURCE_ACCOUNT                         NUMBER,
    OUTSIDE_PROCESSING_ACCOUNT               NUMBER,
    MATERIAL_VARIANCE_ACCOUNT                NUMBER,
    RESOURCE_VARIANCE_ACCOUNT                NUMBER,
    OUTSIDE_PROC_VARIANCE_ACCOUNT            NUMBER,
    STD_COST_ADJUSTMENT_ACCOUNT              NUMBER,
    OVERHEAD_ACCOUNT                         NUMBER,
    OVERHEAD_VARIANCE_ACCOUNT                NUMBER,
    PROJECT_ID                               NUMBER,
    TASK_ID                                  NUMBER,
    ATTRIBUTE_CATEGORY                       VARCHAR2(30),
    ATTRIBUTE1                               VARCHAR2(150),
    ATTRIBUTE2                               VARCHAR2(150),
    ATTRIBUTE3                               VARCHAR2(150),
    ATTRIBUTE4                               VARCHAR2(150),
    ATTRIBUTE5                               VARCHAR2(150),
    ATTRIBUTE6                               VARCHAR2(150),
    ATTRIBUTE7                               VARCHAR2(150),
    ATTRIBUTE8                               VARCHAR2(150),
    ATTRIBUTE9                               VARCHAR2(150),
    ATTRIBUTE10                              VARCHAR2(150),
    ATTRIBUTE11                              VARCHAR2(150),
    ATTRIBUTE12                              VARCHAR2(150),
    ATTRIBUTE13                              VARCHAR2(150),
    ATTRIBUTE14                              VARCHAR2(150),
    ATTRIBUTE15                              VARCHAR2(150),
    KANBAN_CARD_ID                           NUMBER,
    END_ITEM_UNIT_NUMBER                     VARCHAR2(30),
    CURRENT_LINE_OPERATION                   NUMBER,
    WIP_ENTITY_ID			     NUMBER /*Added to support 'Roll Flow Schedules: Maintain Schedule Number' project.*/
);

/* To support 'Roll Flow Schedules: Maintain Schedule Number' project.
   This type is used in the variable to store old/new schedule/wip_entity_id */
TYPE FSSchNum IS TABLE OF WIP_FLOW_SCHEDULES.schedule_number%TYPE
	INDEX BY BINARY_INTEGER;
TYPE FSWipId IS TABLE OF WIP_FLOW_SCHEDULES.wip_entity_id%TYPE
	INDEX BY BINARY_INTEGER;


/**?
    ' fs.MPS_SCHEDULED_COMPLETION_DATE, fs.MPS_NET_QUANTITY, '||
    ' fs.BOM_REVISION, fs.ROUTING_REVISION,fs.BOM_REVISION_DATE, '||
    ' fs.ROUTING_REVISION_DATE, fs.ALTERNATE_BOM_DESIGNATOR, '||
    ' fs.ALTERNATE_ROUTING_DESIGNATOR, fs.COMPLETION_SUBINVENTORY, '||
    ' fs.COMPLETION_LOCATOR_ID, fs.MATERIAL_ACCOUNT, '||
    ' fs.MATERIAL_OVERHEAD_ACCOUNT, fs.RESOURCE_ACCOUNT, '||
    ' fs.OUTSIDE_PROCESSING_ACCOUNT, fs.MATERIAL_VARIANCE_ACCOUNT, '||
    ' fs.RESOURCE_VARIANCE_ACCOUNT, fs.OUTSIDE_PROC_VARIANCE_ACCOUNT, '||
    ' fs.STD_COST_ADJUSTMENT_ACCOUNT, fs.OVERHEAD_ACCOUNT, '||
    ' fs.OVERHEAD_VARIANCE_ACCOUNT, fs.PROJECT_ID,fs.TASK_ID, '||
    ' fs.ATTRIBUTE_CATEGORY, fs.ATTRIBUTE1,fs.ATTRIBUTE2, '||
    ' fs.ATTRIBUTE3, fs.ATTRIBUTE4,fs.ATTRIBUTE5, '||
    ' fs.ATTRIBUTE6, fs.ATTRIBUTE7,fs.ATTRIBUTE8, '||
    ' fs.ATTRIBUTE9, fs.ATTRIBUTE10,fs.ATTRIBUTE11, '||
    ' fs.ATTRIBUTE12, fs.ATTRIBUTE13,fs.ATTRIBUTE14, '||
    ' fs.ATTRIBUTE15, fs.KANBAN_CARD_ID,fs.END_ITEM_UNIT_NUMBER, '||
    ' fs.CURRENT_LINE_OPERATION '||

/**/
--  Procedure Clear_Dependent_Attr
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER DEFAULT NULL
,   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_old_flow_schedule_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   x_flow_schedule_rec             IN  OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
);

--  Procedure Apply_Attribute_Changes
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/

PROCEDURE Apply_Attribute_Changes
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_old_flow_schedule_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   x_flow_schedule_rec             IN  OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
);

--  Function Complete_Record
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type) and also reversed the logic.
*/
FUNCTION Complete_Record
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_old_flow_schedule_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
) RETURN MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;

--  Function Convert_Miss_To_Null
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/

FUNCTION Convert_Miss_To_Null
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
) RETURN MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;

--  Procedure Update_Row
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/
PROCEDURE Update_Row
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
);

--  Procedure Insert_Row
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/
PROCEDURE Insert_Row
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_wip_entity_id                 IN  NUMBER
);

--  Function Query_Row
/*
Enhancement : 2665434
Description : Changed the return type from old record type (MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to
new record type (MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/
FUNCTION Query_Row
(   p_wip_entity_id                 IN  NUMBER
) RETURN MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;

--  Procedure       lock_Row
--
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/
PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   x_flow_schedule_rec             IN  OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
);

--  Function Get_Values
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type) .
*/
FUNCTION Get_Values
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_old_flow_schedule_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
) RETURN MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type;

--  Function Get_Ids
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/

FUNCTION Get_Ids
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_flow_schedule_val_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type
) RETURN MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;

-- Procedure populates mrp_form_query with the values necessary
-- for the flow schedule summary buckets.

PROCEDURE populate_flow_summary(
        x_return_status         OUT     NOCOPY	VARCHAR2,
        p_line_id               IN      NUMBER,
        p_org_id                IN      NUMBER,
        p_first_bucket_date     IN      DATE,
        p_query_id              IN     NUMBER
);

-- Simple update to update the quantity of a summary bucket

PROCEDURE Update_Quantity(
	x_return_status		OUT 	NOCOPY	VARCHAR2,
        x_msg_count		OUT 	NOCOPY	NUMBER,
        x_msg_data		OUT	NOCOPY	VARCHAR2,
	p_wip_entity_id		IN	NUMBER,
	p_quantity		IN	NUMBER
);

PROCEDURE Update_Quantity(
	p_wip_entity_id		IN	NUMBER,
	p_quantity		IN	NUMBER
);

PROCEDURE Delete_Flow_Row(
        x_return_status         OUT     NOCOPY	VARCHAR2,
        x_msg_count             OUT     NOCOPY	NUMBER,
        x_msg_data              OUT     NOCOPY	VARCHAR2,
        p_wip_entity_id         IN      NUMBER
);

-- Globals used for the concurrent procedure
G_SUCCESS                       CONSTANT NUMBER := 0;
G_WARNING                       CONSTANT NUMBER := 1;
G_ERROR                         CONSTANT NUMBER := 2;

-- Delete flow schedules concurrent procedure
PROCEDURE Delete_Flow_Schedules( ERRBUF                 OUT     NOCOPY	VARCHAR2,
                                 RETCODE                OUT     NOCOPY	VARCHAR2,
                                 p_organization_id      IN      NUMBER,
                                 p_start_date           IN      VARCHAR2,
                                 p_end_date             IN      VARCHAR2,
                                 p_from_line            IN      VARCHAR2,
                                 p_to_line              IN      VARCHAR2,
                                 p_from_item            IN      VARCHAR2,
                                 p_to_item              IN      VARCHAR2,
                                 p_category_set_id      IN      NUMBER,
                                 p_category_structure_id IN     NUMBER,
                                 p_from_category        IN      VARCHAR2,
                                 p_to_category          IN      VARCHAR2);

-- Roll flow schedules concurrent procedure
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type).Also added local variables to make it
compatible with the call to (MRP_FLow_Schedule_PVT.Process_Flow_Schedule)
*/
PROCEDURE Roll_Flow_Schedules( ERRBUF                 OUT     NOCOPY	VARCHAR2,
                                 RETCODE                OUT     NOCOPY	VARCHAR2,
                                 p_organization_id      IN      NUMBER,
                                 p_spread_qty           IN      NUMBER,
                                 p_dummy                IN      NUMBER,
                                 p_dummy1               IN      NUMBER,
                                 p_dummy2               IN      NUMBER,
                                 p_dummy3               IN      NUMBER,
                                 p_dummy4               IN      NUMBER,
                                 p_output               IN      NUMBER,
                                 p_from_start_date      IN      VARCHAR2,
                                 p_from_end_date        IN      VARCHAR2,
                                 p_to_start_date        IN      VARCHAR2,
                                 p_to_end_date          IN      VARCHAR2,
                                 p_from_line            IN      VARCHAR2,
                                 p_to_line              IN      VARCHAR2,
                                 p_from_item            IN      VARCHAR2,
                                 p_to_item              IN      VARCHAR2,
                                 p_category_set_id      IN      NUMBER,
                                 p_category_structure_id IN     NUMBER,
                                 p_from_category        IN      VARCHAR2,
                                 p_to_category          IN      VARCHAR2);

FUNCTION Item_Where_Clause( p_item_lo           IN      VARCHAR2,
                             p_item_hi          IN      VARCHAR2,
                             p_table_name       IN      VARCHAR2,
                             x_where            OUT     NOCOPY	VARCHAR2,
                             x_err_buf          OUT     NOCOPY	VARCHAR2)
RETURN BOOLEAN;

FUNCTION Category_Where_Clause (  p_cat_lo      IN      VARCHAR2,
                                  p_cat_hi      IN      VARCHAR2,
                                  p_table_name  IN      VARCHAR2,
                                  p_cat_struct_id IN    NUMBER,
                                  p_where       OUT     NOCOPY	VARCHAR2,
                                  x_err_buf     OUT     NOCOPY	VARCHAR2 )
RETURN BOOLEAN;

PROCEDURE Line_Schedule (	p_rule_id		IN NUMBER,
				p_line_id		IN NUMBER,
				p_org_id		IN NUMBER,
				p_sched_start_date	IN DATE,
				p_sched_end_date	IN DATE,
				p_update		IN NUMBER,
				p_flex_tolerance	IN NUMBER,
				x_return_status		OUT NOCOPY	VARCHAR2,
				x_msg_count		OUT NOCOPY	NUMBER,
				x_msg_data		OUT NOCOPY	VARCHAR2);

PROCEDURE Post_Schedule_Update ( p_org_id IN NUMBER) ;
PROCEDURE Explode_New_Items;

/*Bug 3042045*/
FUNCTION Get_Flow_Quantity (	 p_demand_source_line	  IN 	VARCHAR2,
				 p_demand_source_type     IN	NUMBER,
				 p_demand_source_delivery IN    VARCHAR2,
                                 p_use_open_quantity      IN    VARCHAR2 )
RETURN NUMBER;

FUNCTION Get_Demand_Project (	 p_demand_id	IN 	NUMBER,
				 p_type		IN 	NUMBER)
RETURN NUMBER;

FUNCTION Check_ATO_Holds (	p_line_id	IN	NUMBER,
				p_header_id	IN	NUMBER,
				p_action_id	IN	NUMBER)
RETURN NUMBER;

/*Bug 3042045*/
FUNCTION Get_Reservation_Quantity ( p_org_id            IN NUMBER,
				    p_item_id           IN NUMBER,
				    p_line_id           IN NUMBER,
                                    p_use_open_quantity IN VARCHAR2 )
RETURN NUMBER;

FUNCTION check_std_holds(p_line_id  IN NUMBER) return NUMBER;

/*
 * check holds for order header/line
 */
FUNCTION Check_Holds(
        p_header_id     IN      NUMBER,
        p_line_id       IN      NUMBER,
        p_wf_item       IN VARCHAR2,
        p_wf_activity   IN VARCHAR2)
RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES (get_flow_quantity, WNDS, WNPS);
--PRAGMA RESTRICT_REFERENCES (get_demand_project, WNDS, WNPS);
--PRAGMA RESTRICT_REFERENCES (check_ato_holds, WNDS, WNPS);

/*
 * get the first alternate routing designator for the item on the line
 */
FUNCTION get_routing_designator(
        p_item_id IN NUMBER,
        p_organization_id IN NUMBER,
        p_line_id IN NUMBER)
RETURN VARCHAR2;



END MRP_Flow_Schedule_Util;

 

/
