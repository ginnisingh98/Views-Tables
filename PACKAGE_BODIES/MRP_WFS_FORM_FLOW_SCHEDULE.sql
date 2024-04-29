--------------------------------------------------------
--  DDL for Package Body MRP_WFS_FORM_FLOW_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_WFS_FORM_FLOW_SCHEDULE" AS
/* $Header: MRPFSCNB.pls 120.2.12000000.2 2007/07/26 01:43:53 ksuleman ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_WFS_Form_Flow_Schedule';

--  Global variables holding cached record.

g_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
g_db_flow_schedule_rec        MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/

PROCEDURE Write_flow_schedule
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_db_record                     IN  BOOLEAN := NULL
);

/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/
FUNCTION Get_flow_schedule
(   p_db_record                     IN  BOOLEAN := NULL
,   p_wip_entity_id                 IN  NUMBER
)
RETURN MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;

/*Enhancement : 2665434
Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
Using the logic to initialize g_flow_schedule_rec and g_db_flow_schedule_rec to NULL instead
of G_MISS_REC.
*/
PROCEDURE Clear_flow_schedule;

/*Enhancement : 2665434
New Function created to store the value in the cache correctly.
*/
FUNCTION Convert_Null_To_Miss
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
) RETURN MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type ;


--  Global variable holding performed operations.

g_opr__tbl                    MRP_Flow_Schedule_PUB.Flow_Schedule_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   x_alternate_bom_designator      OUT NOCOPY VARCHAR2
,   x_alternate_routing_desig       OUT NOCOPY VARCHAR2
,   x_attribute1                    OUT NOCOPY VARCHAR2
,   x_attribute10                   OUT NOCOPY VARCHAR2
,   x_attribute11                   OUT NOCOPY VARCHAR2
,   x_attribute12                   OUT NOCOPY VARCHAR2
,   x_attribute13                   OUT NOCOPY VARCHAR2
,   x_attribute14                   OUT NOCOPY VARCHAR2
,   x_attribute15                   OUT NOCOPY VARCHAR2
,   x_attribute2                    OUT NOCOPY VARCHAR2
,   x_attribute3                    OUT NOCOPY VARCHAR2
,   x_attribute4                    OUT NOCOPY VARCHAR2
,   x_attribute5                    OUT NOCOPY VARCHAR2
,   x_attribute6                    OUT NOCOPY VARCHAR2
,   x_attribute7                    OUT NOCOPY VARCHAR2
,   x_attribute8                    OUT NOCOPY VARCHAR2
,   x_attribute9                    OUT NOCOPY VARCHAR2
,   x_attribute_category            OUT NOCOPY VARCHAR2
,   x_bom_revision                  OUT NOCOPY VARCHAR2
,   x_bom_revision_date             OUT NOCOPY DATE
,   x_build_sequence                OUT NOCOPY NUMBER
,   x_class_code                    OUT NOCOPY VARCHAR2
,   x_completion_locator_id         OUT NOCOPY NUMBER
,   x_completion_subinventory       OUT NOCOPY VARCHAR2
,   x_date_closed                   OUT NOCOPY DATE
,   x_demand_class                  OUT NOCOPY VARCHAR2
,   x_demand_source_delivery        OUT NOCOPY VARCHAR2
,   x_demand_source_header_id       OUT NOCOPY NUMBER
,   x_demand_source_line            OUT NOCOPY VARCHAR2
,   x_demand_source_type            OUT NOCOPY NUMBER
,   x_line_id                       OUT NOCOPY NUMBER
,   x_material_account              OUT NOCOPY NUMBER
,   x_material_overhead_account     OUT NOCOPY NUMBER
,   x_material_variance_account     OUT NOCOPY NUMBER
,   x_mps_net_quantity              OUT NOCOPY NUMBER
,   x_mps_scheduled_comp_date       OUT NOCOPY DATE
,   x_organization_id               OUT NOCOPY NUMBER
,   x_outside_processing_acct       OUT NOCOPY NUMBER
,   x_outside_proc_var_acct         OUT NOCOPY NUMBER
,   x_overhead_account              OUT NOCOPY NUMBER
,   x_overhead_variance_account     OUT NOCOPY NUMBER
,   x_planned_quantity              OUT NOCOPY NUMBER
,   x_primary_item_id               OUT NOCOPY NUMBER
,   x_project_id                    OUT NOCOPY NUMBER
,   x_quantity_completed            OUT NOCOPY NUMBER
,   x_resource_account              OUT NOCOPY NUMBER
,   x_resource_variance_account     OUT NOCOPY NUMBER
,   x_routing_revision              OUT NOCOPY VARCHAR2
,   x_routing_revision_date         OUT NOCOPY DATE
,   x_scheduled_completion_date     OUT NOCOPY DATE
,   x_scheduled_flag                OUT NOCOPY NUMBER
,   x_scheduled_start_date          OUT NOCOPY DATE
,   x_schedule_group_id             OUT NOCOPY NUMBER
,   x_schedule_number               OUT NOCOPY VARCHAR2
,   x_status                        OUT NOCOPY NUMBER
,   x_std_cost_adjustment_acct      OUT NOCOPY NUMBER
,   x_task_id                       OUT NOCOPY NUMBER
,   x_wip_entity_id                 OUT NOCOPY NUMBER
,   x_completion_locator            OUT NOCOPY VARCHAR2
,   x_line                          OUT NOCOPY VARCHAR2
,   x_organization                  OUT NOCOPY VARCHAR2
,   x_primary_item                  OUT NOCOPY VARCHAR2
,   x_project                       OUT NOCOPY VARCHAR2
,   x_schedule_group                OUT NOCOPY VARCHAR2
,   x_task                          OUT NOCOPY VARCHAR2
,   x_wip_entity                    OUT NOCOPY VARCHAR2
,   x_end_item_unit_number          OUT NOCOPY VARCHAR2
,   x_quantity_scrapped            OUT NOCOPY NUMBER
)
IS
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_flow_schedule_val_rec       MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type;
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_flow_schedule_rec         MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_p_old_flow_schedule_rec     MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.default_attributes   := TRUE;

    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Load IN parameters if any exist


    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.
    --  Take this out so the default values in the form works.
/*
    l_flow_schedule_rec.attribute1                := 'NULL';
    l_flow_schedule_rec.attribute10               := 'NULL';
    l_flow_schedule_rec.attribute11               := 'NULL';
    l_flow_schedule_rec.attribute12               := 'NULL';
    l_flow_schedule_rec.attribute13               := 'NULL';
    l_flow_schedule_rec.attribute14               := 'NULL';
    l_flow_schedule_rec.attribute15               := 'NULL';
    l_flow_schedule_rec.attribute2                := 'NULL';
    l_flow_schedule_rec.attribute3                := 'NULL';
    l_flow_schedule_rec.attribute4                := 'NULL';
    l_flow_schedule_rec.attribute5                := 'NULL';
    l_flow_schedule_rec.attribute6                := 'NULL';
    l_flow_schedule_rec.attribute7                := 'NULL';
    l_flow_schedule_rec.attribute8                := 'NULL';
    l_flow_schedule_rec.attribute9                := 'NULL';
    l_flow_schedule_rec.attribute_category        := 'NULL';
*/

    -- Schedule number must be set by the form so that the
    -- sequence can be maintained
    l_flow_schedule_rec.schedule_number		  := NULL;

    --  Set Operation to Create

    l_flow_schedule_rec.operation := MRP_GLOBALS.G_OPR_CREATE;

    --  Call MRP_Flow_Schedule_PVT.Process_flow_schedule

    MRP_Flow_Schedule_PVT.Process_flow_schedule
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_flow_schedule_rec           => l_flow_schedule_rec
    ,   p_old_flow_schedule_rec       => l_p_old_flow_schedule_rec
    ,   x_flow_schedule_rec           => l_x_flow_schedule_rec
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    x_alternate_bom_designator     := l_x_flow_schedule_rec.alternate_bom_designator;
    x_alternate_routing_desig      := l_x_flow_schedule_rec.alternate_routing_desig;
    x_attribute1                   := l_x_flow_schedule_rec.attribute1;
    x_attribute10                  := l_x_flow_schedule_rec.attribute10;
    x_attribute11                  := l_x_flow_schedule_rec.attribute11;
    x_attribute12                  := l_x_flow_schedule_rec.attribute12;
    x_attribute13                  := l_x_flow_schedule_rec.attribute13;
    x_attribute14                  := l_x_flow_schedule_rec.attribute14;
    x_attribute15                  := l_x_flow_schedule_rec.attribute15;
    x_attribute2                   := l_x_flow_schedule_rec.attribute2;
    x_attribute3                   := l_x_flow_schedule_rec.attribute3;
    x_attribute4                   := l_x_flow_schedule_rec.attribute4;
    x_attribute5                   := l_x_flow_schedule_rec.attribute5;
    x_attribute6                   := l_x_flow_schedule_rec.attribute6;
    x_attribute7                   := l_x_flow_schedule_rec.attribute7;
    x_attribute8                   := l_x_flow_schedule_rec.attribute8;
    x_attribute9                   := l_x_flow_schedule_rec.attribute9;
    x_attribute_category           := l_x_flow_schedule_rec.attribute_category;
    x_bom_revision                 := l_x_flow_schedule_rec.bom_revision;
    x_bom_revision_date            := l_x_flow_schedule_rec.bom_revision_date;
    x_build_sequence               := l_x_flow_schedule_rec.build_sequence;
    x_class_code                   := l_x_flow_schedule_rec.class_code;
    x_completion_locator_id        := l_x_flow_schedule_rec.completion_locator_id;
    x_completion_subinventory      := l_x_flow_schedule_rec.completion_subinventory;
    x_date_closed                  := l_x_flow_schedule_rec.date_closed;
    x_demand_class                 := l_x_flow_schedule_rec.demand_class;
    x_demand_source_delivery       := l_x_flow_schedule_rec.demand_source_delivery;
    x_demand_source_header_id      := l_x_flow_schedule_rec.demand_source_header_id;
    x_demand_source_line           := l_x_flow_schedule_rec.demand_source_line;
    x_demand_source_type           := l_x_flow_schedule_rec.demand_source_type;
    x_line_id                      := l_x_flow_schedule_rec.line_id;
    x_material_account             := l_x_flow_schedule_rec.material_account;
    x_material_overhead_account    := l_x_flow_schedule_rec.material_overhead_account;
    x_material_variance_account    := l_x_flow_schedule_rec.material_variance_account;
    x_mps_net_quantity             := l_x_flow_schedule_rec.mps_net_quantity;
    x_mps_scheduled_comp_date      := l_x_flow_schedule_rec.mps_scheduled_comp_date;
    x_organization_id              := l_x_flow_schedule_rec.organization_id;
    x_outside_processing_acct      := l_x_flow_schedule_rec.outside_processing_acct;
    x_outside_proc_var_acct        := l_x_flow_schedule_rec.outside_proc_var_acct;
    x_overhead_account             := l_x_flow_schedule_rec.overhead_account;
    x_overhead_variance_account    := l_x_flow_schedule_rec.overhead_variance_account;
    x_planned_quantity             := l_x_flow_schedule_rec.planned_quantity;
    x_primary_item_id              := l_x_flow_schedule_rec.primary_item_id;
    x_project_id                   := l_x_flow_schedule_rec.project_id;
    x_quantity_completed           := l_x_flow_schedule_rec.quantity_completed;
    x_resource_account             := l_x_flow_schedule_rec.resource_account;
    x_resource_variance_account    := l_x_flow_schedule_rec.resource_variance_account;
    x_routing_revision             := l_x_flow_schedule_rec.routing_revision;
    x_routing_revision_date        := l_x_flow_schedule_rec.routing_revision_date;
    x_scheduled_completion_date    := l_x_flow_schedule_rec.scheduled_completion_date;
    x_scheduled_flag               := l_x_flow_schedule_rec.scheduled_flag;
    x_scheduled_start_date         := l_x_flow_schedule_rec.scheduled_start_date;
    x_schedule_group_id            := l_x_flow_schedule_rec.schedule_group_id;
    x_schedule_number              := l_x_flow_schedule_rec.schedule_number;
    x_status                       := l_x_flow_schedule_rec.status;
    x_std_cost_adjustment_acct     := l_x_flow_schedule_rec.std_cost_adjustment_acct;
    x_task_id                      := l_x_flow_schedule_rec.task_id;
    x_wip_entity_id                := l_x_flow_schedule_rec.wip_entity_id;
    x_end_item_unit_number         := l_x_flow_schedule_rec.end_item_unit_number;
    x_quantity_scrapped           := l_x_flow_schedule_rec.quantity_scrapped;
    --  Load display out parameters if any

    l_flow_schedule_val_rec := MRP_Flow_Schedule_Util.Get_Values
    (   p_flow_schedule_rec           => l_x_flow_schedule_rec
    ,   p_old_flow_schedule_rec	      => l_p_old_flow_schedule_rec
    );

    x_completion_locator           := l_flow_schedule_val_rec.completion_locator;
    x_line                         := l_flow_schedule_val_rec.line;
    x_organization                 := l_flow_schedule_val_rec.organization;
    x_primary_item                 := l_flow_schedule_val_rec.primary_item;
    x_project                      := l_flow_schedule_val_rec.project;
    x_schedule_group               := l_flow_schedule_val_rec.schedule_group;
    x_task                         := l_flow_schedule_val_rec.task;
    x_wip_entity                   := l_flow_schedule_val_rec.wip_entity;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_flow_schedule_rec.db_flag := FND_API.G_FALSE;

    Write_flow_schedule
    (   p_flow_schedule_rec           => l_x_flow_schedule_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Default_Attributes'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Default_Attributes;

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
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
,   x_alternate_bom_designator      OUT NOCOPY VARCHAR2
,   x_alternate_routing_desig       OUT NOCOPY VARCHAR2
,   x_attribute1                    OUT NOCOPY VARCHAR2
,   x_attribute10                   OUT NOCOPY VARCHAR2
,   x_attribute11                   OUT NOCOPY VARCHAR2
,   x_attribute12                   OUT NOCOPY VARCHAR2
,   x_attribute13                   OUT NOCOPY VARCHAR2
,   x_attribute14                   OUT NOCOPY VARCHAR2
,   x_attribute15                   OUT NOCOPY VARCHAR2
,   x_attribute2                    OUT NOCOPY VARCHAR2
,   x_attribute3                    OUT NOCOPY VARCHAR2
,   x_attribute4                    OUT NOCOPY VARCHAR2
,   x_attribute5                    OUT NOCOPY VARCHAR2
,   x_attribute6                    OUT NOCOPY VARCHAR2
,   x_attribute7                    OUT NOCOPY VARCHAR2
,   x_attribute8                    OUT NOCOPY VARCHAR2
,   x_attribute9                    OUT NOCOPY VARCHAR2
,   x_attribute_category            OUT NOCOPY VARCHAR2
,   x_bom_revision                  OUT NOCOPY VARCHAR2
,   x_bom_revision_date             OUT NOCOPY DATE
,   x_build_sequence                OUT NOCOPY NUMBER
,   x_class_code                    OUT NOCOPY VARCHAR2
,   x_completion_locator_id         OUT NOCOPY NUMBER
,   x_completion_subinventory       OUT NOCOPY VARCHAR2
,   x_date_closed                   OUT NOCOPY DATE
,   x_demand_class                  OUT NOCOPY VARCHAR2
,   x_demand_source_delivery        OUT NOCOPY VARCHAR2
,   x_demand_source_header_id       OUT NOCOPY NUMBER
,   x_demand_source_line            OUT NOCOPY VARCHAR2
,   x_demand_source_type            OUT NOCOPY NUMBER
,   x_line_id                       OUT NOCOPY NUMBER
,   x_material_account              OUT NOCOPY NUMBER
,   x_material_overhead_account     OUT NOCOPY NUMBER
,   x_material_variance_account     OUT NOCOPY NUMBER
,   x_mps_net_quantity              OUT NOCOPY NUMBER
,   x_mps_scheduled_comp_date       OUT NOCOPY DATE
,   x_organization_id               OUT NOCOPY NUMBER
,   x_outside_processing_acct       OUT NOCOPY NUMBER
,   x_outside_proc_var_acct         OUT NOCOPY NUMBER
,   x_overhead_account              OUT NOCOPY NUMBER
,   x_overhead_variance_account     OUT NOCOPY NUMBER
,   x_planned_quantity              OUT NOCOPY NUMBER
,   x_primary_item_id               OUT NOCOPY NUMBER
,   x_project_id                    OUT NOCOPY NUMBER
,   x_quantity_completed            OUT NOCOPY NUMBER
,   x_request_id                    OUT NOCOPY NUMBER
,   x_resource_account              OUT NOCOPY NUMBER
,   x_resource_variance_account     OUT NOCOPY NUMBER
,   x_routing_revision              OUT NOCOPY VARCHAR2
,   x_routing_revision_date         OUT NOCOPY DATE
,   x_scheduled_completion_date     OUT NOCOPY DATE
,   x_scheduled_flag                OUT NOCOPY NUMBER
,   x_scheduled_start_date          OUT NOCOPY DATE
,   x_schedule_group_id             OUT NOCOPY NUMBER
,   x_schedule_number               OUT NOCOPY VARCHAR2
,   x_status                        OUT NOCOPY NUMBER
,   x_std_cost_adjustment_acct      OUT NOCOPY NUMBER
,   x_task_id                       OUT NOCOPY NUMBER
,   x_wip_entity_id                 OUT NOCOPY NUMBER
,   x_completion_locator            OUT NOCOPY VARCHAR2
,   x_line                          OUT NOCOPY VARCHAR2
,   x_organization                  OUT NOCOPY VARCHAR2
,   x_primary_item                  OUT NOCOPY VARCHAR2
,   x_project                       OUT NOCOPY VARCHAR2
,   x_schedule_group                OUT NOCOPY VARCHAR2
,   x_task                          OUT NOCOPY VARCHAR2
,   x_wip_entity                    OUT NOCOPY VARCHAR2
,   x_end_item_unit_number          OUT NOCOPY VARCHAR2
,   x_quantity_scrapped             OUT NOCOPY NUMBER
)
IS
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_old_flow_schedule_rec       MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_flow_schedule_val_rec       MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type;
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_flow_schedule_rec         MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
temp		varchar2(1000);
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read flow_schedule from cache

    l_flow_schedule_rec := Get_flow_schedule
    (   p_db_record                   => FALSE
    ,   p_wip_entity_id               => p_wip_entity_id
    );

    l_old_flow_schedule_rec        := l_flow_schedule_rec;

    IF p_attr_id = MRP_Flow_Schedule_Util.G_ALTERNATE_BOM_DESIGNATOR THEN
        l_flow_schedule_rec.alternate_bom_designator := p_attr_value;
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_ALTERNATE_ROUTING_DESIG THEN
        l_flow_schedule_rec.alternate_routing_desig := p_attr_value;
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_BOM_REVISION THEN
        l_flow_schedule_rec.bom_revision := p_attr_value;
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_BOM_REVISION_DATE THEN
        l_flow_schedule_rec.bom_revision_date := fnd_date.canonical_to_date(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_BUILD_SEQUENCE THEN
        l_flow_schedule_rec.build_sequence := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_CLASS THEN
        l_flow_schedule_rec.class_code := p_attr_value;
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_COMPLETION_LOCATOR THEN
        l_flow_schedule_rec.completion_locator_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_COMPLETION_SUBINVENTORY THEN
        l_flow_schedule_rec.completion_subinventory := p_attr_value;
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_DATE_CLOSED THEN
        l_flow_schedule_rec.date_closed := fnd_date.canonical_to_date(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_DEMAND_CLASS THEN
        l_flow_schedule_rec.demand_class := p_attr_value;
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_DEMAND_SOURCE_DELIVERY THEN
        l_flow_schedule_rec.demand_source_delivery := p_attr_value;
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_DEMAND_SOURCE_HEADER THEN
        l_flow_schedule_rec.demand_source_header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_DEMAND_SOURCE_LINE THEN
        l_flow_schedule_rec.demand_source_line := p_attr_value;
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_DEMAND_SOURCE_TYPE THEN
        l_flow_schedule_rec.demand_source_type := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_LINE THEN
        l_flow_schedule_rec.line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_MATERIAL_ACCOUNT THEN
        l_flow_schedule_rec.material_account := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_MATERIAL_OVERHEAD_ACCOUNT THEN
        l_flow_schedule_rec.material_overhead_account := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_MATERIAL_VARIANCE_ACCOUNT THEN
        l_flow_schedule_rec.material_variance_account := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_MPS_NET_QUANTITY THEN
        l_flow_schedule_rec.mps_net_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_MPS_SCHEDULED_COMP_DATE THEN
        l_flow_schedule_rec.mps_scheduled_comp_date := fnd_date.canonical_to_date(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_ORGANIZATION THEN
        l_flow_schedule_rec.organization_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_OUTSIDE_PROCESSING_ACCT THEN
        l_flow_schedule_rec.outside_processing_acct := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_OUTSIDE_PROC_VAR_ACCT THEN
        l_flow_schedule_rec.outside_proc_var_acct := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_OVERHEAD_ACCOUNT THEN
        l_flow_schedule_rec.overhead_account := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_OVERHEAD_VARIANCE_ACCOUNT THEN
        l_flow_schedule_rec.overhead_variance_account := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_PLANNED_QUANTITY THEN
        l_flow_schedule_rec.planned_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_PRIMARY_ITEM THEN
        l_flow_schedule_rec.primary_item_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_PROJECT THEN
        l_flow_schedule_rec.project_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_QUANTITY_COMPLETED THEN
        l_flow_schedule_rec.quantity_completed := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_REQUEST THEN
        l_flow_schedule_rec.request_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_RESOURCE_ACCOUNT THEN
        l_flow_schedule_rec.resource_account := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_RESOURCE_VARIANCE_ACCOUNT THEN
        l_flow_schedule_rec.resource_variance_account := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_ROUTING_REVISION THEN
        l_flow_schedule_rec.routing_revision := p_attr_value;
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_ROUTING_REVISION_DATE THEN
        l_flow_schedule_rec.routing_revision_date := fnd_date.canonical_to_date(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_SCHEDULED_COMPLETION_DATE THEN
        l_flow_schedule_rec.scheduled_completion_date := fnd_date.canonical_to_date(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_SCHEDULED THEN
        l_flow_schedule_rec.scheduled_flag := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_SCHEDULED_START_DATE THEN
        l_flow_schedule_rec.scheduled_start_date := fnd_date.canonical_to_date(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_SCHEDULE_GROUP THEN
        l_flow_schedule_rec.schedule_group_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_SCHEDULE_NUMBER THEN
        l_flow_schedule_rec.schedule_number := p_attr_value;
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_STATUS THEN
        l_flow_schedule_rec.status := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_STD_COST_ADJUSTMENT_ACCT THEN
        l_flow_schedule_rec.std_cost_adjustment_acct := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_TASK THEN
        l_flow_schedule_rec.task_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_WIP_ENTITY THEN
        l_flow_schedule_rec.wip_entity_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_END_ITEM_UNIT_NUMBER THEN
        l_flow_schedule_rec.end_item_unit_number:= p_attr_value;
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_QUANTITY_SCRAPPED THEN
        l_flow_schedule_rec.quantity_scrapped:=  TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE1
    OR     p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE10
    OR     p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE11
    OR     p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE12
    OR     p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE13
    OR     p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE14
    OR     p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE15
    OR     p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE2
    OR     p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE3
    OR     p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE4
    OR     p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE5
    OR     p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE6
    OR     p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE7
    OR     p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE8
    OR     p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE9
    OR     p_attr_id = MRP_Flow_Schedule_Util.G_ATTRIBUTE_CATEGORY
    THEN

        l_flow_schedule_rec.attribute1 := p_attribute1;
        l_flow_schedule_rec.attribute10 := p_attribute10;
        l_flow_schedule_rec.attribute11 := p_attribute11;
        l_flow_schedule_rec.attribute12 := p_attribute12;
        l_flow_schedule_rec.attribute13 := p_attribute13;
        l_flow_schedule_rec.attribute14 := p_attribute14;
        l_flow_schedule_rec.attribute15 := p_attribute15;
        l_flow_schedule_rec.attribute2 := p_attribute2;
        l_flow_schedule_rec.attribute3 := p_attribute3;
        l_flow_schedule_rec.attribute4 := p_attribute4;
        l_flow_schedule_rec.attribute5 := p_attribute5;
        l_flow_schedule_rec.attribute6 := p_attribute6;
        l_flow_schedule_rec.attribute7 := p_attribute7;
        l_flow_schedule_rec.attribute8 := p_attribute8;
        l_flow_schedule_rec.attribute9 := p_attribute9;
        l_flow_schedule_rec.attribute_category := p_attribute_category;

    ELSE

        --  Unexpected error, unrecognized attribute

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            ,   'Unrecognized attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    --  Set Operation.

    IF FND_API.To_Boolean(l_flow_schedule_rec.db_flag) THEN
        l_flow_schedule_rec.operation := MRP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_flow_schedule_rec.operation := MRP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call MRP_Flow_Schedule_PVT.Process_flow_schedule

    MRP_Flow_Schedule_PVT.Process_flow_schedule
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_flow_schedule_rec           => l_flow_schedule_rec
    ,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
    ,   x_flow_schedule_rec           => l_x_flow_schedule_rec
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Init OUT parameters to missing.

    x_alternate_bom_designator     := NULL;
    x_alternate_routing_desig      := NULL;
    x_attribute1                   := NULL;
    x_attribute10                  := NULL;
    x_attribute11                  := NULL;
    x_attribute12                  := NULL;
    x_attribute13                  := NULL;
    x_attribute14                  := NULL;
    x_attribute15                  := NULL;
    x_attribute2                   := NULL;
    x_attribute3                   := NULL;
    x_attribute4                   := NULL;
    x_attribute5                   := NULL;
    x_attribute6                   := NULL;
    x_attribute7                   := NULL;
    x_attribute8                   := NULL;
    x_attribute9                   := NULL;
    x_attribute_category           := NULL;
    x_bom_revision                 := NULL;
    x_bom_revision_date            := NULL;
    x_build_sequence               := NULL;
    x_class_code                   := NULL;
    x_completion_locator_id        := NULL;
    x_completion_subinventory      := NULL;
    x_date_closed                  := NULL;
    x_demand_class                 := NULL;
    x_demand_source_delivery       := NULL;
    x_demand_source_header_id      := NULL;
    x_demand_source_line           := NULL;
    x_demand_source_type           := NULL;
    x_line_id                      := NULL;
    x_material_account             := NULL;
    x_material_overhead_account    := NULL;
    x_material_variance_account    := NULL;
    x_mps_net_quantity             := NULL;
    x_mps_scheduled_comp_date      := NULL;
    x_organization_id              := NULL;
    x_outside_processing_acct      := NULL;
    x_outside_proc_var_acct        := NULL;
    x_overhead_account             := NULL;
    x_overhead_variance_account    := NULL;
    x_planned_quantity             := NULL;
    x_primary_item_id              := NULL;
    x_project_id                   := NULL;
    x_quantity_completed           := NULL;
    x_request_id		   := NULL;
    x_resource_account             := NULL;
    x_resource_variance_account    := NULL;
    x_routing_revision             := NULL;
    x_routing_revision_date        := NULL;
    x_scheduled_completion_date    := NULL;
    x_scheduled_flag               := NULL;
    x_scheduled_start_date         := NULL;
    x_schedule_group_id            := NULL;
    x_schedule_number              := NULL;
    x_status                       := NULL;
    x_std_cost_adjustment_acct     := NULL;
    x_task_id                      := NULL;
    x_wip_entity_id                := NULL;
    x_completion_locator           := NULL;
    x_line                         := NULL;
    x_organization                 := NULL;
    x_primary_item                 := NULL;
    x_project                      := NULL;
    x_schedule_group               := NULL;
    x_task                         := NULL;
    x_wip_entity                   := NULL;
    x_end_item_unit_number         := NULL;
    x_quantity_scrapped           := NULL;

    --  Load display out parameters if any

    l_flow_schedule_val_rec := MRP_Flow_Schedule_Util.Get_Values
    (   p_flow_schedule_rec           => l_x_flow_schedule_rec
    ,   p_old_flow_schedule_rec       => l_flow_schedule_rec
    );

    --  Return changed attributes.

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.alternate_bom_designator,
                            l_flow_schedule_rec.alternate_bom_designator)
    THEN
        x_alternate_bom_designator := l_x_flow_schedule_rec.alternate_bom_designator;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.alternate_routing_desig,
                            l_flow_schedule_rec.alternate_routing_desig)
    THEN
        x_alternate_routing_desig := l_x_flow_schedule_rec.alternate_routing_desig;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute1,
                            l_flow_schedule_rec.attribute1)
    THEN
        x_attribute1 := l_x_flow_schedule_rec.attribute1;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute10,
                            l_flow_schedule_rec.attribute10)
    THEN
        x_attribute10 := l_x_flow_schedule_rec.attribute10;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute11,
                            l_flow_schedule_rec.attribute11)
    THEN
        x_attribute11 := l_x_flow_schedule_rec.attribute11;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute12,
                            l_flow_schedule_rec.attribute12)
    THEN
        x_attribute12 := l_x_flow_schedule_rec.attribute12;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute13,
                            l_flow_schedule_rec.attribute13)
    THEN
        x_attribute13 := l_x_flow_schedule_rec.attribute13;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute14,
                            l_flow_schedule_rec.attribute14)
    THEN
        x_attribute14 := l_x_flow_schedule_rec.attribute14;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute15,
                            l_flow_schedule_rec.attribute15)
    THEN
        x_attribute15 := l_x_flow_schedule_rec.attribute15;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute2,
                            l_flow_schedule_rec.attribute2)
    THEN
        x_attribute2 := l_x_flow_schedule_rec.attribute2;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute3,
                            l_flow_schedule_rec.attribute3)
    THEN
        x_attribute3 := l_x_flow_schedule_rec.attribute3;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute4,
                            l_flow_schedule_rec.attribute4)
    THEN
        x_attribute4 := l_x_flow_schedule_rec.attribute4;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute5,
                            l_flow_schedule_rec.attribute5)
    THEN
        x_attribute5 := l_x_flow_schedule_rec.attribute5;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute6,
                            l_flow_schedule_rec.attribute6)
    THEN
        x_attribute6 := l_x_flow_schedule_rec.attribute6;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute7,
                            l_flow_schedule_rec.attribute7)
    THEN
        x_attribute7 := l_x_flow_schedule_rec.attribute7;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute8,
                            l_flow_schedule_rec.attribute8)
    THEN
        x_attribute8 := l_x_flow_schedule_rec.attribute8;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute9,
                            l_flow_schedule_rec.attribute9)
    THEN
        x_attribute9 := l_x_flow_schedule_rec.attribute9;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.attribute_category,
                            l_flow_schedule_rec.attribute_category)
    THEN
        x_attribute_category := l_x_flow_schedule_rec.attribute_category;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.bom_revision,
                            l_flow_schedule_rec.bom_revision)
    THEN
        x_bom_revision := l_x_flow_schedule_rec.bom_revision;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.bom_revision_date,
                            l_flow_schedule_rec.bom_revision_date)
    THEN
        x_bom_revision_date := l_x_flow_schedule_rec.bom_revision_date;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.build_sequence,
                            l_flow_schedule_rec.build_sequence)
    THEN
        x_build_sequence := l_x_flow_schedule_rec.build_sequence;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.class_code,
                            l_flow_schedule_rec.class_code)
    THEN
        x_class_code := l_x_flow_schedule_rec.class_code;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.completion_locator_id,
                            l_flow_schedule_rec.completion_locator_id)
    THEN
        x_completion_locator_id := l_x_flow_schedule_rec.completion_locator_id;
        x_completion_locator := l_flow_schedule_val_rec.completion_locator;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.completion_subinventory,
                            l_flow_schedule_rec.completion_subinventory)
    THEN
        x_completion_subinventory := l_x_flow_schedule_rec.completion_subinventory;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.date_closed,
                            l_flow_schedule_rec.date_closed)
    THEN
        x_date_closed := l_x_flow_schedule_rec.date_closed;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.demand_class,
                            l_flow_schedule_rec.demand_class)
    THEN
        x_demand_class := l_x_flow_schedule_rec.demand_class;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.demand_source_delivery,
                            l_flow_schedule_rec.demand_source_delivery)
    THEN
        x_demand_source_delivery := l_x_flow_schedule_rec.demand_source_delivery;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.demand_source_header_id,
                            l_flow_schedule_rec.demand_source_header_id)
    THEN
        x_demand_source_header_id := l_x_flow_schedule_rec.demand_source_header_id;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.demand_source_line,
                            l_flow_schedule_rec.demand_source_line)
    THEN
        x_demand_source_line := l_x_flow_schedule_rec.demand_source_line;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.demand_source_type,
                            l_flow_schedule_rec.demand_source_type)
    THEN
        x_demand_source_type := l_x_flow_schedule_rec.demand_source_type;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.line_id,
                            l_flow_schedule_rec.line_id)
    THEN
        x_line_id := l_x_flow_schedule_rec.line_id;
        x_line := l_flow_schedule_val_rec.line;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.material_account,
                            l_flow_schedule_rec.material_account)
    THEN
        x_material_account := l_x_flow_schedule_rec.material_account;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.material_overhead_account,
                            l_flow_schedule_rec.material_overhead_account)
    THEN
        x_material_overhead_account := l_x_flow_schedule_rec.material_overhead_account;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.material_variance_account,
                            l_flow_schedule_rec.material_variance_account)
    THEN
        x_material_variance_account := l_x_flow_schedule_rec.material_variance_account;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.mps_net_quantity,
                            l_flow_schedule_rec.mps_net_quantity)
    THEN
        x_mps_net_quantity := l_x_flow_schedule_rec.mps_net_quantity;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.mps_scheduled_comp_date,
                            l_flow_schedule_rec.mps_scheduled_comp_date)
    THEN
        x_mps_scheduled_comp_date := l_x_flow_schedule_rec.mps_scheduled_comp_date;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.organization_id,
                            l_flow_schedule_rec.organization_id)
    THEN
        x_organization_id := l_x_flow_schedule_rec.organization_id;
        x_organization := l_flow_schedule_val_rec.organization;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.outside_processing_acct,
                            l_flow_schedule_rec.outside_processing_acct)
    THEN
        x_outside_processing_acct := l_x_flow_schedule_rec.outside_processing_acct;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.outside_proc_var_acct,
                            l_flow_schedule_rec.outside_proc_var_acct)
    THEN
        x_outside_proc_var_acct := l_x_flow_schedule_rec.outside_proc_var_acct;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.overhead_account,
                            l_flow_schedule_rec.overhead_account)
    THEN
        x_overhead_account := l_x_flow_schedule_rec.overhead_account;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.overhead_variance_account,
                            l_flow_schedule_rec.overhead_variance_account)
    THEN
        x_overhead_variance_account := l_x_flow_schedule_rec.overhead_variance_account;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.planned_quantity,
                            l_flow_schedule_rec.planned_quantity)
    THEN
        x_planned_quantity := l_x_flow_schedule_rec.planned_quantity;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.primary_item_id,
                            l_flow_schedule_rec.primary_item_id)
    THEN
        x_primary_item_id := l_x_flow_schedule_rec.primary_item_id;
        x_primary_item := l_flow_schedule_val_rec.primary_item;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.project_id,
                            l_flow_schedule_rec.project_id)
    THEN
        x_project_id := l_x_flow_schedule_rec.project_id;
        x_project := l_flow_schedule_val_rec.project;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.quantity_completed,
                            l_flow_schedule_rec.quantity_completed)
    THEN
        x_quantity_completed := l_x_flow_schedule_rec.quantity_completed;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.request_id,
                            l_flow_schedule_rec.request_id)
    THEN
        x_request_id := l_x_flow_schedule_rec.request_id;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.resource_account,
                            l_flow_schedule_rec.resource_account)
    THEN
        x_resource_account := l_x_flow_schedule_rec.resource_account;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.resource_variance_account,
                            l_flow_schedule_rec.resource_variance_account)
    THEN
        x_resource_variance_account := l_x_flow_schedule_rec.resource_variance_account;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.routing_revision,
                            l_flow_schedule_rec.routing_revision)
    THEN
        x_routing_revision := l_x_flow_schedule_rec.routing_revision;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.routing_revision_date,
                            l_flow_schedule_rec.routing_revision_date)
    THEN
        x_routing_revision_date := l_x_flow_schedule_rec.routing_revision_date;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.scheduled_completion_date,
                            l_flow_schedule_rec.scheduled_completion_date)
    THEN
        x_scheduled_completion_date := l_x_flow_schedule_rec.scheduled_completion_date;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.scheduled_flag,
                            l_flow_schedule_rec.scheduled_flag)
    THEN
        x_scheduled_flag := l_x_flow_schedule_rec.scheduled_flag;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.scheduled_start_date,
                            l_flow_schedule_rec.scheduled_start_date)
    THEN
        x_scheduled_start_date := l_x_flow_schedule_rec.scheduled_start_date;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.schedule_group_id,
                            l_flow_schedule_rec.schedule_group_id)
    THEN
        x_schedule_group_id := l_x_flow_schedule_rec.schedule_group_id;
        x_schedule_group := l_flow_schedule_val_rec.schedule_group;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.schedule_number,
                            l_flow_schedule_rec.schedule_number)
    THEN
        x_schedule_number := l_x_flow_schedule_rec.schedule_number;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.status,
                            l_flow_schedule_rec.status)
    THEN
        x_status := l_x_flow_schedule_rec.status;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.std_cost_adjustment_acct,
                            l_flow_schedule_rec.std_cost_adjustment_acct)
    THEN
        x_std_cost_adjustment_acct := l_x_flow_schedule_rec.std_cost_adjustment_acct;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.task_id,
                            l_flow_schedule_rec.task_id)
    THEN
        x_task_id := l_x_flow_schedule_rec.task_id;
        x_task := l_flow_schedule_val_rec.task;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.wip_entity_id,
                            l_flow_schedule_rec.wip_entity_id)
    THEN
        x_wip_entity_id := l_x_flow_schedule_rec.wip_entity_id;
        x_wip_entity := l_flow_schedule_val_rec.wip_entity;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.end_item_unit_number,
                            l_flow_schedule_rec.end_item_unit_number)
    THEN
        x_end_item_unit_number := l_x_flow_schedule_rec.end_item_unit_number;
    END IF;

    IF NOT MRP_GLOBALS.Equal(l_x_flow_schedule_rec.quantity_scrapped,
                            l_flow_schedule_rec.quantity_scrapped)
    THEN
        x_quantity_scrapped := l_x_flow_schedule_rec.quantity_scrapped;
    END IF;

    /*Store in the cache G_MISS values instead of NULL .So that when we call
    complete_record finally it can update to NULL */

    l_x_flow_schedule_rec := convert_null_to_miss(l_x_flow_schedule_rec);

    --  Write to cache.

    Write_flow_schedule
    (   p_flow_schedule_rec           => l_x_flow_schedule_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Change_Attribute;

-- Function Convert_Miss_To_Null
--

FUNCTION Convert_Null_To_Miss
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
) RETURN MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
IS
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type:= p_flow_schedule_rec;
BEGIN

    IF l_flow_schedule_rec.alternate_bom_designator IS NULL THEN
        l_flow_schedule_rec.alternate_bom_designator := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.alternate_routing_desig  IS NULL  THEN
        l_flow_schedule_rec.alternate_routing_desig := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute1  IS NULL  THEN
        l_flow_schedule_rec.attribute1 := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute10  IS NULL  THEN
        l_flow_schedule_rec.attribute10 := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute11  IS NULL  THEN
        l_flow_schedule_rec.attribute11 := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute12  IS NULL  THEN
        l_flow_schedule_rec.attribute12 := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute13  IS NULL  THEN
        l_flow_schedule_rec.attribute13 := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute14  IS NULL  THEN
        l_flow_schedule_rec.attribute14 := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute15  IS NULL  THEN
        l_flow_schedule_rec.attribute15 := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute2  IS NULL  THEN
        l_flow_schedule_rec.attribute2 := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute3  IS NULL  THEN
        l_flow_schedule_rec.attribute3 := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute4  IS NULL  THEN
        l_flow_schedule_rec.attribute4 := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute5  IS NULL  THEN
        l_flow_schedule_rec.attribute5 := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute6  IS NULL  THEN
        l_flow_schedule_rec.attribute6 := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute7  IS NULL  THEN
        l_flow_schedule_rec.attribute7 := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute8  IS NULL  THEN
        l_flow_schedule_rec.attribute8 := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute9  IS NULL  THEN
        l_flow_schedule_rec.attribute9 := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.attribute_category  IS NULL  THEN
        l_flow_schedule_rec.attribute_category := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.bom_revision  IS NULL  THEN
        l_flow_schedule_rec.bom_revision := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.bom_revision_date  IS NULL  THEN
        l_flow_schedule_rec.bom_revision_date := FND_API.G_MISS_DATE;
    END IF;

    IF l_flow_schedule_rec.build_sequence  IS NULL  THEN
        l_flow_schedule_rec.build_sequence := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.class_code  IS NULL  THEN
        l_flow_schedule_rec.class_code := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.completion_locator_id  IS NULL  THEN
        l_flow_schedule_rec.completion_locator_id := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.completion_subinventory  IS NULL  THEN
        l_flow_schedule_rec.completion_subinventory := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.created_by  IS NULL  THEN
        l_flow_schedule_rec.created_by := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.creation_date  IS NULL  THEN
        l_flow_schedule_rec.creation_date := FND_API.G_MISS_DATE;
    END IF;

    IF l_flow_schedule_rec.date_closed  IS NULL  THEN
        l_flow_schedule_rec.date_closed := FND_API.G_MISS_DATE;
    END IF;

    IF l_flow_schedule_rec.demand_class  IS NULL  THEN
        l_flow_schedule_rec.demand_class := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.demand_source_delivery  IS NULL  THEN
        l_flow_schedule_rec.demand_source_delivery := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.demand_source_header_id  IS NULL  THEN
        l_flow_schedule_rec.demand_source_header_id := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.demand_source_line  IS NULL  THEN
        l_flow_schedule_rec.demand_source_line := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.demand_source_type  IS NULL  THEN
        l_flow_schedule_rec.demand_source_type := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.last_updated_by  IS NULL  THEN
        l_flow_schedule_rec.last_updated_by := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.last_update_date  IS NULL  THEN
        l_flow_schedule_rec.last_update_date := FND_API.G_MISS_DATE;
    END IF;

    IF l_flow_schedule_rec.last_update_login  IS NULL  THEN
        l_flow_schedule_rec.last_update_login := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.line_id  IS NULL  THEN
        l_flow_schedule_rec.line_id := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.material_account  IS NULL  THEN
        l_flow_schedule_rec.material_account := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.material_overhead_account  IS NULL  THEN
        l_flow_schedule_rec.material_overhead_account := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.material_variance_account  IS NULL  THEN
        l_flow_schedule_rec.material_variance_account := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.mps_net_quantity  IS NULL  THEN
        l_flow_schedule_rec.mps_net_quantity := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.mps_scheduled_comp_date  IS NULL  THEN
        l_flow_schedule_rec.mps_scheduled_comp_date := FND_API.G_MISS_DATE;
    END IF;

    IF l_flow_schedule_rec.organization_id  IS NULL  THEN
        l_flow_schedule_rec.organization_id := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.outside_processing_acct  IS NULL  THEN
        l_flow_schedule_rec.outside_processing_acct := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.outside_proc_var_acct  IS NULL  THEN
        l_flow_schedule_rec.outside_proc_var_acct := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.overhead_account  IS NULL  THEN
        l_flow_schedule_rec.overhead_account := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.overhead_variance_account  IS NULL  THEN
        l_flow_schedule_rec.overhead_variance_account := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.planned_quantity  IS NULL  THEN
        l_flow_schedule_rec.planned_quantity := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.primary_item_id  IS NULL  THEN
        l_flow_schedule_rec.primary_item_id := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.program_application_id  IS NULL  THEN
        l_flow_schedule_rec.program_application_id := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.program_id  IS NULL  THEN
        l_flow_schedule_rec.program_id := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.program_update_date  IS NULL  THEN
        l_flow_schedule_rec.program_update_date := FND_API.G_MISS_DATE;
    END IF;

    IF l_flow_schedule_rec.project_id  IS NULL  THEN
        l_flow_schedule_rec.project_id := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.quantity_completed  IS NULL  THEN
        l_flow_schedule_rec.quantity_completed := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.request_id  IS NULL  THEN
        l_flow_schedule_rec.request_id := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.resource_account  IS NULL  THEN
        l_flow_schedule_rec.resource_account := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.resource_variance_account  IS NULL  THEN
        l_flow_schedule_rec.resource_variance_account := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.routing_revision  IS NULL  THEN
        l_flow_schedule_rec.routing_revision := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.routing_revision_date  IS NULL  THEN
        l_flow_schedule_rec.routing_revision_date := FND_API.G_MISS_DATE;
    END IF;

    IF l_flow_schedule_rec.scheduled_completion_date  IS NULL  THEN
        l_flow_schedule_rec.scheduled_completion_date := FND_API.G_MISS_DATE;
    END IF;

    IF l_flow_schedule_rec.scheduled_flag  IS NULL  THEN
        l_flow_schedule_rec.scheduled_flag := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.scheduled_start_date  IS NULL  THEN
        l_flow_schedule_rec.scheduled_start_date := FND_API.G_MISS_DATE;
    END IF;

    IF l_flow_schedule_rec.schedule_group_id  IS NULL  THEN
        l_flow_schedule_rec.schedule_group_id := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.schedule_number  IS NULL  THEN
        l_flow_schedule_rec.schedule_number := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.status  IS NULL  THEN
        l_flow_schedule_rec.status := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.std_cost_adjustment_acct  IS NULL  THEN
        l_flow_schedule_rec.std_cost_adjustment_acct := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.task_id  IS NULL  THEN
        l_flow_schedule_rec.task_id := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.wip_entity_id  IS NULL  THEN
        l_flow_schedule_rec.wip_entity_id := FND_API.G_MISS_NUM;
    END IF;

    IF l_flow_schedule_rec.end_item_unit_number  IS NULL  THEN
        l_flow_schedule_rec.end_item_unit_number := FND_API.G_MISS_CHAR;
    END IF;

    IF l_flow_schedule_rec.quantity_scrapped  IS NULL  THEN
       l_flow_schedule_rec.quantity_scrapped := FND_API.G_MISS_NUM;
    END IF;

    RETURN l_flow_schedule_rec;

END Convert_Null_To_Miss;

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_wip_entity_id                 IN  NUMBER
,   x_creation_date                 OUT NOCOPY DATE
,   x_created_by                    OUT NOCOPY NUMBER
,   x_last_update_date              OUT NOCOPY DATE
,   x_last_updated_by               OUT NOCOPY NUMBER
,   x_last_update_login             OUT NOCOPY NUMBER
)
IS
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_old_flow_schedule_rec       MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_flow_schedule_rec         MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read flow_schedule from cache

    l_old_flow_schedule_rec := Get_flow_schedule
    (   p_db_record                   => TRUE
    ,   p_wip_entity_id               => p_wip_entity_id
    );

    l_flow_schedule_rec := Get_flow_schedule
    (   p_db_record                   => FALSE
    ,   p_wip_entity_id               => p_wip_entity_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_flow_schedule_rec.db_flag) THEN
        l_flow_schedule_rec.operation := MRP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_flow_schedule_rec.operation := MRP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call MRP_Flow_Schedule_PVT.Process_flow_schedule
    MRP_Flow_Schedule_PVT.Process_flow_schedule
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_flow_schedule_rec           => l_flow_schedule_rec
    ,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
    ,   x_flow_schedule_rec           => l_x_flow_schedule_rec
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Load OUT parameters.


    x_creation_date                := l_x_flow_schedule_rec.creation_date;
    x_created_by                   := l_x_flow_schedule_rec.created_by;
    x_last_update_date             := l_x_flow_schedule_rec.last_update_date;
    x_last_updated_by              := l_x_flow_schedule_rec.last_updated_by;
    x_last_update_login            := l_x_flow_schedule_rec.last_update_login;

    --  Clear flow_schedule record cache

    Clear_flow_schedule;

    --  Keep track of performed operations.

    l_old_flow_schedule_rec.operation := l_flow_schedule_rec.operation;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_And_Write'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Validate_And_Write;

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_wip_entity_id                 IN  NUMBER
)
IS
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_p_old_flow_schedule_rec     MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_flow_schedule_rec         MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read DB record from cache

    l_flow_schedule_rec := Get_flow_schedule
    (   p_db_record                   => TRUE
    ,   p_wip_entity_id               => p_wip_entity_id
    );

    --  Set Operation.

    l_flow_schedule_rec.operation := MRP_GLOBALS.G_OPR_DELETE;

    --  Call MRP_Flow_Schedule_PVT.Process_flow_schedule

    MRP_Flow_Schedule_PVT.Process_flow_schedule
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_flow_schedule_rec           => l_flow_schedule_rec
    ,	p_old_flow_schedule_rec       => l_p_old_flow_schedule_rec
    ,   x_flow_schedule_rec           => l_x_flow_schedule_rec
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear flow_schedule record cache

    Clear_flow_schedule;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Delete_Row;

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
)
IS
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_flow_schedule_rec         MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_p_flow_schedule_rec	      MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_p_old_flow_schedule_rec     MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := MRP_GLOBALS.G_ENTITY_FLOW_SCHEDULE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call MRP_Flow_Schedule_PVT.Process_flow_schedule

    MRP_Flow_Schedule_PVT.Process_flow_schedule
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_flow_schedule_rec           => l_x_flow_schedule_rec
    ,   p_flow_schedule_rec           => l_p_flow_schedule_rec
    ,   p_old_flow_schedule_rec       => l_p_old_flow_schedule_rec
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Entity'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Entity;

--  Procedure       Process_Object
--

PROCEDURE Process_Object
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
)
IS
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_flow_schedule_rec         MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_p_flow_schedule_rec	      MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_p_old_flow_schedule_rec     MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;

BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := MRP_GLOBALS.G_ENTITY_ALL;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := TRUE;

    --  Call MRP_Flow_Schedule_PVT.Process_flow_schedule

    MRP_Flow_Schedule_PVT.Process_flow_schedule
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_flow_schedule_rec           => l_x_flow_schedule_rec
    ,   p_flow_schedule_rec           => l_p_flow_schedule_rec
    ,   p_old_flow_schedule_rec       => l_p_old_flow_schedule_rec
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Object'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Object;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
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
)
IS
l_return_status               VARCHAR2(1);
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_x_flow_schedule_rec         MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_file				UTL_FILE.file_type;
BEGIN

    --  Load flow_schedule record

    l_flow_schedule_rec.alternate_bom_designator := p_alternate_bom_designator;
    l_flow_schedule_rec.alternate_routing_desig := p_alternate_routing_desig;
    l_flow_schedule_rec.attribute1 := p_attribute1;
    l_flow_schedule_rec.attribute10 := p_attribute10;
    l_flow_schedule_rec.attribute11 := p_attribute11;
    l_flow_schedule_rec.attribute12 := p_attribute12;
    l_flow_schedule_rec.attribute13 := p_attribute13;
    l_flow_schedule_rec.attribute14 := p_attribute14;
    l_flow_schedule_rec.attribute15 := p_attribute15;
    l_flow_schedule_rec.attribute2 := p_attribute2;
    l_flow_schedule_rec.attribute3 := p_attribute3;
    l_flow_schedule_rec.attribute4 := p_attribute4;
    l_flow_schedule_rec.attribute5 := p_attribute5;
    l_flow_schedule_rec.attribute6 := p_attribute6;
    l_flow_schedule_rec.attribute7 := p_attribute7;
    l_flow_schedule_rec.attribute8 := p_attribute8;
    l_flow_schedule_rec.attribute9 := p_attribute9;
    l_flow_schedule_rec.attribute_category := p_attribute_category;
    l_flow_schedule_rec.bom_revision := p_bom_revision;
    l_flow_schedule_rec.bom_revision_date := p_bom_revision_date;
    l_flow_schedule_rec.build_sequence := p_build_sequence;
    l_flow_schedule_rec.class_code := p_class_code;
    l_flow_schedule_rec.completion_locator_id := p_completion_locator_id;
    l_flow_schedule_rec.completion_subinventory := p_completion_subinventory;
    l_flow_schedule_rec.created_by := p_created_by;
    l_flow_schedule_rec.creation_date := p_creation_date;
    l_flow_schedule_rec.date_closed := p_date_closed;
    l_flow_schedule_rec.demand_class := p_demand_class;
    l_flow_schedule_rec.demand_source_delivery := p_demand_source_delivery;
    l_flow_schedule_rec.demand_source_header_id := p_demand_source_header_id;
    l_flow_schedule_rec.demand_source_line := p_demand_source_line;
    l_flow_schedule_rec.demand_source_type := p_demand_source_type;
    l_flow_schedule_rec.last_updated_by := p_last_updated_by;
    l_flow_schedule_rec.last_update_date := p_last_update_date;
    l_flow_schedule_rec.last_update_login := p_last_update_login;
    l_flow_schedule_rec.line_id    := p_line_id;
    l_flow_schedule_rec.material_account := p_material_account;
    l_flow_schedule_rec.material_overhead_account := p_material_overhead_account;
    l_flow_schedule_rec.material_variance_account := p_material_variance_account;
    l_flow_schedule_rec.mps_net_quantity := p_mps_net_quantity;
    l_flow_schedule_rec.mps_scheduled_comp_date := p_mps_scheduled_comp_date;
    l_flow_schedule_rec.organization_id := p_organization_id;
    l_flow_schedule_rec.outside_processing_acct := p_outside_processing_acct;
    l_flow_schedule_rec.outside_proc_var_acct := p_outside_proc_var_acct;
    l_flow_schedule_rec.overhead_account := p_overhead_account;
    l_flow_schedule_rec.overhead_variance_account := p_overhead_variance_account;
    l_flow_schedule_rec.planned_quantity := p_planned_quantity;
    l_flow_schedule_rec.primary_item_id := p_primary_item_id;
    l_flow_schedule_rec.program_application_id := p_program_application_id;
    l_flow_schedule_rec.program_id := p_program_id;
    l_flow_schedule_rec.program_update_date := p_program_update_date;
    l_flow_schedule_rec.project_id := p_project_id;
    l_flow_schedule_rec.quantity_completed := p_quantity_completed;
    l_flow_schedule_rec.request_id := p_request_id;
    l_flow_schedule_rec.resource_account := p_resource_account;
    l_flow_schedule_rec.resource_variance_account := p_resource_variance_account;
    l_flow_schedule_rec.routing_revision := p_routing_revision;
    l_flow_schedule_rec.routing_revision_date := p_routing_revision_date;
    l_flow_schedule_rec.scheduled_completion_date := p_scheduled_completion_date;
    l_flow_schedule_rec.scheduled_flag := p_scheduled_flag;
    l_flow_schedule_rec.scheduled_start_date := p_scheduled_start_date;
    l_flow_schedule_rec.schedule_group_id := p_schedule_group_id;
    l_flow_schedule_rec.schedule_number := p_schedule_number;
    l_flow_schedule_rec.status     := p_status;
    l_flow_schedule_rec.std_cost_adjustment_acct := p_std_cost_adjustment_acct;
    l_flow_schedule_rec.task_id    := p_task_id;
    l_flow_schedule_rec.wip_entity_id := p_wip_entity_id;
    l_flow_schedule_rec.end_item_unit_number := p_end_item_unit_number;
    l_flow_schedule_rec.quantity_scrapped := p_quantity_scrapped;

    l_flow_schedule_rec.operation := MRP_GLOBALS.G_OPR_LOCK;

    --  Call MRP_Flow_Schedule_PVT.Lock_flow_schedule

    MRP_Flow_Schedule_PVT.Lock_flow_schedule
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_flow_schedule_rec           => l_flow_schedule_rec
    ,   x_flow_schedule_rec           => l_x_flow_schedule_rec
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_flow_schedule_rec.db_flag := FND_API.G_TRUE;

        Write_flow_schedule
        (   p_flow_schedule_rec           => l_x_flow_schedule_rec
        ,   p_db_record                   => TRUE
        );

    END IF;

    --  Set return status.

    x_return_status := l_return_status;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN OTHERS THEN

            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row: yes you really are here'
            );
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Row;

PROCEDURE Create_Flow_Schedule
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
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
,   x_wip_entity_id                 OUT NOCOPY NUMBER

)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 MRP_GLOBALS.Control_Rec_Type ;
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_x_flow_schedule_rec         MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
l_p_old_flow_schedule_rec     MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
BEGIN

    --  Load flow_schedule record

    l_flow_schedule_rec.alternate_bom_designator := p_alternate_bom_designator;
    l_flow_schedule_rec.alternate_routing_desig := p_alternate_routing_desig;
    l_flow_schedule_rec.attribute1 := p_attribute1;
    l_flow_schedule_rec.attribute10 := p_attribute10;
    l_flow_schedule_rec.attribute11 := p_attribute11;
    l_flow_schedule_rec.attribute12 := p_attribute12;
    l_flow_schedule_rec.attribute13 := p_attribute13;
    l_flow_schedule_rec.attribute14 := p_attribute14;
    l_flow_schedule_rec.attribute15 := p_attribute15;
    l_flow_schedule_rec.attribute2 := p_attribute2;
    l_flow_schedule_rec.attribute3 := p_attribute3;
    l_flow_schedule_rec.attribute4 := p_attribute4;
    l_flow_schedule_rec.attribute5 := p_attribute5;
    l_flow_schedule_rec.attribute6 := p_attribute6;
    l_flow_schedule_rec.attribute7 := p_attribute7;
    l_flow_schedule_rec.attribute8 := p_attribute8;
    l_flow_schedule_rec.attribute9 := p_attribute9;
    l_flow_schedule_rec.attribute_category := p_attribute_category;
    l_flow_schedule_rec.bom_revision := p_bom_revision;
    l_flow_schedule_rec.bom_revision_date := p_bom_revision_date;
    l_flow_schedule_rec.build_sequence := p_build_sequence;
    l_flow_schedule_rec.class_code := p_class_code;
    l_flow_schedule_rec.completion_locator_id := p_completion_locator_id;
    l_flow_schedule_rec.completion_subinventory := p_completion_subinventory;
    l_flow_schedule_rec.created_by := p_created_by;
    l_flow_schedule_rec.creation_date := p_creation_date;
    l_flow_schedule_rec.date_closed := p_date_closed;
    l_flow_schedule_rec.demand_class := p_demand_class;
    l_flow_schedule_rec.demand_source_delivery := p_demand_source_delivery;
    l_flow_schedule_rec.demand_source_header_id := p_demand_source_header_id;
    l_flow_schedule_rec.demand_source_line := p_demand_source_line;
    l_flow_schedule_rec.demand_source_type := p_demand_source_type;
    l_flow_schedule_rec.last_updated_by := p_last_updated_by;
    l_flow_schedule_rec.last_update_date := p_last_update_date;
    l_flow_schedule_rec.last_update_login := p_last_update_login;
    l_flow_schedule_rec.line_id    := p_line_id;
    l_flow_schedule_rec.material_account := p_material_account;
    l_flow_schedule_rec.material_overhead_account := p_material_overhead_account;
    l_flow_schedule_rec.material_variance_account := p_material_variance_account;
    l_flow_schedule_rec.mps_net_quantity := p_mps_net_quantity;
    l_flow_schedule_rec.mps_scheduled_comp_date := p_mps_scheduled_comp_date;
    l_flow_schedule_rec.organization_id := p_organization_id;
    l_flow_schedule_rec.outside_processing_acct := p_outside_processing_acct;
    l_flow_schedule_rec.outside_proc_var_acct := p_outside_proc_var_acct;
    l_flow_schedule_rec.overhead_account := p_overhead_account;
    l_flow_schedule_rec.overhead_variance_account := p_overhead_variance_account;
    l_flow_schedule_rec.planned_quantity := p_planned_quantity;
    l_flow_schedule_rec.primary_item_id := p_primary_item_id;
    l_flow_schedule_rec.program_application_id := p_program_application_id;
    l_flow_schedule_rec.program_id := p_program_id;
    l_flow_schedule_rec.program_update_date := p_program_update_date;
    l_flow_schedule_rec.project_id := p_project_id;
    l_flow_schedule_rec.quantity_completed := p_quantity_completed;
    l_flow_schedule_rec.request_id := p_request_id;
    l_flow_schedule_rec.resource_account := p_resource_account;
    l_flow_schedule_rec.resource_variance_account := p_resource_variance_account;
    l_flow_schedule_rec.routing_revision := p_routing_revision;
    l_flow_schedule_rec.routing_revision_date := p_routing_revision_date;
    l_flow_schedule_rec.scheduled_completion_date := p_scheduled_completion_date;
    l_flow_schedule_rec.scheduled_flag := p_scheduled_flag;
    l_flow_schedule_rec.scheduled_start_date := p_scheduled_start_date;
    l_flow_schedule_rec.schedule_group_id := p_schedule_group_id;
    l_flow_schedule_rec.schedule_number := p_schedule_number;
    l_flow_schedule_rec.status     := p_status;
    l_flow_schedule_rec.std_cost_adjustment_acct := p_std_cost_adjustment_acct;
    l_flow_schedule_rec.task_id    := p_task_id;
    l_flow_schedule_rec.wip_entity_id := p_wip_entity_id;
    l_flow_schedule_rec.end_item_unit_number := p_end_item_unit_number;
    l_flow_schedule_rec.quantity_scrapped := p_quantity_scrapped;
    l_flow_schedule_rec.operation := MRP_GLOBALS.G_OPR_CREATE;

    --  Call MRP_Flow_Schedule_PVT.Process_Flow_Schedule

    MRP_Flow_Schedule_PVT.Process_Flow_Schedule
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec		      => l_control_rec
    ,   p_flow_schedule_rec           => l_flow_schedule_rec
    ,   p_old_flow_schedule_rec	      => l_p_old_flow_schedule_rec
    ,   x_flow_schedule_rec           => l_x_flow_schedule_rec
    );

    x_wip_entity_id := l_x_flow_schedule_rec.wip_entity_id;

    x_return_status := l_return_status;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Flow_Schedule'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Create_Flow_Schedule;


--  Procedures maintaining flow_schedule record cache.

PROCEDURE Write_flow_schedule
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_db_record                     IN  BOOLEAN := NULL
)
IS
BEGIN

    g_flow_schedule_rec := p_flow_schedule_rec;

    IF nvl(p_db_record,FALSE) THEN

        g_db_flow_schedule_rec := p_flow_schedule_rec;

    END IF;

END Write_Flow_Schedule;

FUNCTION Get_flow_schedule
(   p_db_record                     IN  BOOLEAN := NULL
,   p_wip_entity_id                 IN  NUMBER
)
RETURN MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
IS
BEGIN

    IF  ((p_wip_entity_id <> g_flow_schedule_rec.wip_entity_id ) or (g_flow_schedule_rec.wip_entity_id IS NULL)) and (p_wip_entity_id IS NOT NULL)
    THEN

        --  Query row from DB

        g_flow_schedule_rec := MRP_Flow_Schedule_Util.Query_Row
        (   p_wip_entity_id               => p_wip_entity_id
        );

        g_flow_schedule_rec.db_flag    := FND_API.G_TRUE;

        --  Load DB record

        g_db_flow_schedule_rec         := g_flow_schedule_rec;

    END IF;

    IF nvl(p_db_record,FALSE) THEN

        RETURN g_db_flow_schedule_rec;

    ELSE

        RETURN g_flow_schedule_rec;

    END IF;

END Get_Flow_Schedule;

PROCEDURE Clear_Flow_Schedule
IS
	l_flow_schedule_rec            MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
	l_db_flow_schedule_rec         MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
BEGIN

    g_flow_schedule_rec            := l_flow_schedule_rec            ;
    g_db_flow_schedule_rec         := l_db_flow_schedule_rec         ;

END Clear_Flow_Schedule;

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

) IS
   flexfield fnd_dflex.dflex_r;
   flexinfo  fnd_dflex.dflex_dr;
   contexts  fnd_dflex.contexts_dr;
   cur_context fnd_dflex.context_r;
   i BINARY_INTEGER;
   segments  fnd_dflex.segments_dr;

BEGIN

   x_return_status := NULL;
   fnd_dflex.get_flexfield('WIP', 'WIP_FLOW_SCHEDULES', flexfield, flexinfo);

   fnd_dflex.get_contexts(flexfield, contexts);
   FOR i IN 1 .. contexts.ncontexts LOOP
      IF(contexts.is_enabled(i) and (contexts.is_global(i) or flexinfo.default_context_value = contexts.context_code(i))) THEN
         cur_context.flexfield := flexfield;
         cur_context.context_code := contexts.context_code(i);
         fnd_dflex.get_segments(cur_context,segments,TRUE);
         FOR j IN 1 .. segments.nsegments LOOP
           IF (segments.application_column_name(j) = 'ATTRIBUTE1') THEN
             p_attribute1 := segments.default_value(j);
           ELSIF (segments.application_column_name(j) = 'ATTRIBUTE2') THEN
             p_attribute2 := segments.default_value(j);
           ELSIF (segments.application_column_name(j) = 'ATTRIBUTE3') THEN
             p_attribute3 := segments.default_value(j);
           ELSIF (segments.application_column_name(j) = 'ATTRIBUTE4') THEN
             p_attribute4 := segments.default_value(j);
           ELSIF (segments.application_column_name(j) = 'ATTRIBUTE5') THEN
             p_attribute5 := segments.default_value(j);
           ELSIF (segments.application_column_name(j) = 'ATTRIBUTE6') THEN
             p_attribute6 := segments.default_value(j);
           ELSIF (segments.application_column_name(j) = 'ATTRIBUTE7') THEN
             p_attribute7 := segments.default_value(j);
           ELSIF (segments.application_column_name(j) = 'ATTRIBUTE8') THEN
             p_attribute8 := segments.default_value(j);
           ELSIF (segments.application_column_name(j) = 'ATTRIBUTE9') THEN
             p_attribute9 := segments.default_value(j);
           ELSIF (segments.application_column_name(j) = 'ATTRIBUTE10') THEN
             p_attribute10 := segments.default_value(j);
           ELSIF (segments.application_column_name(j) = 'ATTRIBUTE11') THEN
             p_attribute11 := segments.default_value(j);
           ELSIF (segments.application_column_name(j) = 'ATTRIBUTE12') THEN
             p_attribute12 := segments.default_value(j);
           ELSIF (segments.application_column_name(j) = 'ATTRIBUTE13') THEN
             p_attribute13 := segments.default_value(j);
           ELSIF (segments.application_column_name(j) = 'ATTRIBUTE14') THEN
             p_attribute14 := segments.default_value(j);
           ELSIF (segments.application_column_name(j) = 'ATTRIBUTE15') THEN
             p_attribute15 := segments.default_value(j);
           END IF;
         END LOOP;
      END IF;
   END LOOP;

EXCEPTION
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END get_default_dff;

PROCEDURE Create_Raw_Flow_Schedules
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   x_created_count              IN OUT NOCOPY NUMBER
,   x_lock_count                 IN OUT NOCOPY NUMBER
,   p_organization_id               IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_unscheduled_order_type        IN  NUMBER
,   p_demand_start_date             IN  DATE
,   p_demand_end_date               IN  DATE
,   p_schedule_group_id             IN  NUMBER
,   p_schedule_rule_id              IN  NUMBER
,   p_rule_user_defined             IN  NUMBER
,   p_primary_routing               IN  NUMBER  /* Bug 2906442 */
    )
IS
   l_return_status      varchar2(1);
   l_msg_count		NUMBER;
   l_msg_data		VARCHAR2(2000);
   l_wip_entity_id      NUMBER;
   l_wip_entity_id2      NUMBER;
   l_valid_demand	BOOLEAN;


   l_demand_class		VARCHAR2(30) := NULL;
   l_demand_source_delivery 	VARCHAR2(30) := NULL;
   l_demand_source_header_id	NUMBER := NULL;
   l_demand_source_line		VARCHAR2(30) := NULL;
   l_demand_source_type		NUMBER := NULL;
   l_line_id			NUMBER := NULL;
   l_organization_id		NUMBER := NULL;
   l_planned_quantity		NUMBER := NULL;
   l_primary_item_id		NUMBER := NULL;
   l_project_id			NUMBER := NULL;
   l_scheduled_completion_date	DATE := NULL;
   l_schedule_group_id		NUMBER := NULL;
   l_task_id			NUMBER := NULL;
   l_schedule_number		VARCHAR2(30) := NULL;
   l_scheduled_flag		NUMBER := NULL;
   l_end_item_unit_number       VARCHAR2(30) := NULL;
   l_replenish_to_order_flag	VARCHAR2(1) := 'N';
   l_build_in_wip_flag		VARCHAR2(1) := 'N';

   l_attribute1			VARCHAR2(150);
   l_attribute10		VARCHAR2(150);
   l_attribute11		VARCHAR2(150);
   l_attribute12		VARCHAR2(150);
   l_attribute13		VARCHAR2(150);
   l_attribute14		VARCHAR2(150);
   l_attribute15		VARCHAR2(150);
   l_attribute2			VARCHAR2(150);
   l_attribute3			VARCHAR2(150);
   l_attribute4			VARCHAR2(150);
   l_attribute5			VARCHAR2(150);
   l_attribute6			VARCHAR2(150);
   l_attribute7			VARCHAR2(150);
   l_attribute8			VARCHAR2(150);
   l_attribute9			VARCHAR2(150);

   l_rowid	VARCHAR2(100);

/* performance bug 4911906 - split C1 to so/po part */
   CURSOR C1_SO IS
      SELECT
	row_id,
	demand_class,
	demand_source_delivery,
	demand_source_header_id,
	demand_source_line,
	demand_source_type,
	order_quantity,
	inventory_item_id,
	project_id,
	order_date,
	task_id,
	end_item_unit_number,
	replenish_to_order_flag,
	build_in_wip_flag
      FROM
      /*mrp_unscheduled_orders_v */
  (
  SELECT
       sl1.rowid row_id,
       sl1.ship_from_org_id organization_id,
       sl1.inventory_item_id,
       inv_salesorder.get_salesorder_for_oeheader(SL1.HEADER_ID) demand_source_header_id,
       TO_CHAR(SL1.LINE_ID) demand_source_line,
       TO_CHAR(NULL) demand_source_delivery,
       2 demand_source_type,
       wl.line_id,
       sl1.schedule_ship_date order_date,
       GREATEST((INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY(SL1.SHIP_FROM_ORG_ID,
                                                       SL1.INVENTORY_ITEM_ID,
                                                       SL1.ORDER_QUANTITY_UOM,
                                                       SL1.ORDERED_QUANTITY) -
                MRP_FLOW_SCHEDULE_UTIL.GET_FLOW_QUANTITY(SL1.LINE_ID,
                                                          2,
                                                          TO_CHAR(NULL),
                                                          MSI1.REPLENISH_TO_ORDER_FLAG) -
                MRP_FLOW_SCHEDULE_UTIL.GET_RESERVATION_QUANTITY(SL1.SHIP_FROM_ORG_ID,
                                                                 SL1.INVENTORY_ITEM_ID,
                                                                 SL1.LINE_ID,
                                                                 MSI1.REPLENISH_TO_ORDER_FLAG)),
                0) order_quantity,
       SL1.Project_Id,
       SL1.Task_Id,
       sl1.demand_class_code demand_class,
       sl1.end_item_unit_number,
       msi1.replenish_to_order_flag,
       msi1.build_in_wip_flag,
       MRP_FLOW_SCHEDULE_UTIL.GET_ROUTING_DESIGNATOR(SL1.INVENTORY_ITEM_ID,
                                                     SL1.SHIP_FROM_ORG_ID,
                                                     WL.LINE_ID) alternate_routing_designator
  FROM
       OE_ORDER_LINES_ALL SL1,
       MTL_SYSTEM_ITEMS_KFV MSI1,
       WIP_LINES WL,
       (select sl2.line_id,
               decode((select 1
                        from oe_order_holds_all oh
                       where oh.header_id = sl2.header_id
                         and rownum = 1
                         and oh.released_flag = 'N'),
                      null,
                      0,
                      decode(sl2.ato_line_id,
                             null,
                             mrp_flow_schedule_util.check_holds(sl2.header_id,
                                                                sl2.line_id,
                                                                'OEOL',
                                                                'LINE_SCHEDULING'),
                             mrp_flow_schedule_util.check_holds(sl2.header_id,
                                                                sl2.line_id,
                                                                null,
                                                                null))) hold
          from oe_order_lines_all sl2) line_holds,
       (select sl2.line_id,
               CTO_WIP_WORKFLOW_API_PK.workflow_build_status(sl2.LINE_ID) status
          from oe_order_lines_all sl2) line_build
 WHERE
   line_build.line_id = sl1.line_id
   AND 1 = decode(MSI1.REPLENISH_TO_ORDER_FLAG, 'N', 1, line_build.status)
   AND MSI1.BUILD_IN_WIP_FLAG = 'Y'
   AND MSI1.PICK_COMPONENTS_FLAG = 'N'
   AND MSI1.BOM_ITEM_TYPE = 4
   AND MSI1.ORGANIZATION_ID = SL1.SHIP_FROM_ORG_ID
   AND MSI1.INVENTORY_ITEM_ID = SL1.INVENTORY_ITEM_ID
   AND SL1.ORDERED_QUANTITY > 0
   AND SL1.VISIBLE_DEMAND_FLAG = 'Y'
   AND SL1.OPEN_FLAG = 'Y'
   AND SL1.ITEM_TYPE_CODE in ('STANDARD', 'CONFIG', 'INCLUDED', 'OPTION')
   AND OE_INSTALL.GET_ACTIVE_PRODUCT = 'ONT'
   AND wl.organization_id = sl1.ship_from_org_id
   AND wl.line_id in (select line_id
                        from bom_operational_routings bor2
                       where bor2.assembly_item_id = sl1.inventory_item_id
                         and bor2.organization_id = sl1.ship_from_org_id
                         and bor2.cfm_routing_flag = 1)
   AND SL1.SHIPPED_QUANTITY is NULL
   and sl1.line_id = line_holds.line_id
   and line_holds.hold = 0
   AND NVL(SL1.FULFILLED_FLAG, 'N') <> 'Y'
  ) so_orders
      WHERE line_id = p_line_id
	AND organization_id = p_organization_id
	AND order_quantity > 0
/*	AND unscheduled_order_option = p_unscheduled_order_type */
	AND order_date >= p_demand_start_date
	AND order_date <= p_demand_end_date
        AND ((p_primary_routing = 1                /* Bug 2906442 */
              and alternate_routing_designator is null)
             or
              p_primary_routing = 2 );


   CURSOR C1_PO IS
      SELECT
	row_id,
	demand_class,
	demand_source_delivery,
	demand_source_header_id,
	demand_source_line,
	demand_source_type,
	order_quantity,
	inventory_item_id,
	project_id,
	order_date,
	task_id,
	end_item_unit_number,
	replenish_to_order_flag,
	build_in_wip_flag
      FROM
  (
  SELECT MR1.ROWID row_id,
       MR1.ORGANIZATION_ID,
       MR1.INVENTORY_ITEM_ID,
       mr1.demand_class,
       100 demand_source_type,
       null DEMAND_SOURCE_HEADER_ID,
       TO_CHAR(MR1.TRANSACTION_ID) DEMAND_SOURCE_LINE,
       null demand_source_delivery,
       WL.LINE_ID,
       NVL(MR1.FIRM_DATE, MR1.NEW_SCHEDULE_DATE) order_date,
       GREATEST((NVL(MR1.FIRM_QUANTITY, MR1.NEW_ORDER_QUANTITY) -
                MRP_FLOW_SCHEDULE_UTIL.GET_FLOW_QUANTITY(TO_CHAR(MR1.TRANSACTION_ID),
                                                          100,
                                                          NULL,
                                                          NULL)),
                0) order_quantity,
       MR1.PROJECT_ID,
       MR1.TASK_ID,
       MR1.END_ITEM_UNIT_NUMBER,
       KFV.REPLENISH_TO_ORDER_FLAG,
       KFV.BUILD_IN_WIP_FLAG,
       MRP_FLOW_SCHEDULE_UTIL.GET_ROUTING_DESIGNATOR(MR1.INVENTORY_ITEM_ID,
                                                     MR1.ORGANIZATION_ID,
                                                     WL.LINE_ID) alternate_routing_designator
  FROM MTL_SYSTEM_ITEMS_B   KFV,
       MRP_SYSTEM_ITEMS     RSI1,
       MRP_PLANS            MP1,
       MRP_RECOMMENDATIONS  MR1,
       WIP_LINES            WL
 WHERE MP1.PLAN_COMPLETION_DATE IS NOT NULL
   AND MP1.DATA_COMPLETION_DATE IS NOT NULL
   AND MP1.COMPILE_DESIGNATOR = MR1.COMPILE_DESIGNATOR
   AND (MP1.ORGANIZATION_ID = MR1.ORGANIZATION_ID OR
       (MP1.ORGANIZATION_ID IN
       (SELECT ORGANIZATION_ID
            FROM MRP_PLAN_ORGANIZATIONS
           WHERE COMPILE_DESIGNATOR = MR1.COMPILE_DESIGNATOR
             AND PLANNED_ORGANIZATION = MR1.ORGANIZATION_ID)))
   AND MR1.ORGANIZATION_ID = MR1.SOURCE_ORGANIZATION_ID
   AND KFV.INVENTORY_ITEM_ID = RSI1.INVENTORY_ITEM_ID
   AND KFV.ORGANIZATION_ID = RSI1.ORGANIZATION_ID
   AND NVL(KFV.RELEASE_TIME_FENCE_CODE, -1) <> 6 /* KANBAN ITEM */
   AND MR1.ORDER_TYPE = 5 /* PLANNED ORDER */
   AND MR1.ORGANIZATION_ID = RSI1.ORGANIZATION_ID
   AND MR1.COMPILE_DESIGNATOR = RSI1.COMPILE_DESIGNATOR
   AND MR1.INVENTORY_ITEM_ID = RSI1.INVENTORY_ITEM_ID
   AND MR1.COMPILE_DESIGNATOR =
       (SELECT DESIGNATOR
          FROM MRP_DESIGNATORS_VIEW
         WHERE PRODUCTION = 1
           AND ORGANIZATION_ID = MP1.ORGANIZATION_ID
           AND DESIGNATOR = MR1.COMPILE_DESIGNATOR)
   AND RSI1.BUILD_IN_WIP_FLAG = 1 /* YES */
   AND RSI1.BOM_ITEM_TYPE = 4
   AND (RSI1.IN_SOURCE_PLAN = 2 OR RSI1.IN_SOURCE_PLAN IS NULL)
   AND wl.organization_id = MR1.ORGANIZATION_ID
   AND wl.line_id in (select line_id
                        from bom_operational_routings bor2
                       where bor2.assembly_item_id = MR1.INVENTORY_ITEM_ID
                         and bor2.organization_id = MR1.ORGANIZATION_ID
                         and bor2.cfm_routing_flag = 1)
  ) po_orders
      WHERE line_id = p_line_id
	AND organization_id = p_organization_id
	AND order_quantity > 0
/*	AND unscheduled_order_option = p_unscheduled_order_type */
	AND order_date >= p_demand_start_date
	AND order_date <= p_demand_end_date
        AND ((p_primary_routing = 1                /* Bug 2906442 */
              and alternate_routing_designator is null)
             or
              p_primary_routing = 2 );

   CURSOR C2 IS
      SELECT
	wip_entities_s.nextval
      FROM dual;

BEGIN

   x_created_count := 0;
   x_lock_count := 0;
   l_return_status := FND_API.G_RET_STS_SUCCESS;


   l_line_id			:= p_LINE_ID;
   l_organization_id		:= p_ORGANIZATION_ID;
   l_schedule_group_id		:= p_SCHEDULE_GROUP_ID;

   -- Set the status to 3 for to be scheduled
   l_scheduled_flag		:= 3;

   MRP_WFS_Form_Flow_Schedule.get_default_dff
     (
      l_return_status,
      l_attribute1,
      l_attribute2,
      l_attribute3,
      l_attribute4,
      l_attribute5,
      l_attribute6,
      l_attribute7,
      l_attribute8,
      l_attribute9,
      l_attribute10,
      l_attribute11,
      l_attribute12,
      l_attribute13,
      l_attribute14,
      l_attribute15);

/*   OPEN C1; */
   if( p_unscheduled_order_type = 1 ) then /* sales order */
     OPEN C1_SO;
   else
     OPEN C1_PO;
   end if;

   LOOP

   if( p_unscheduled_order_type = 1 ) then
      FETCH C1_SO INTO
        l_rowid,
        l_demand_class,
	l_demand_source_delivery,
	l_demand_source_header_id,
	l_demand_source_line,
	l_demand_source_type,
	l_planned_quantity,
	l_primary_item_id,
	l_project_id,
	l_scheduled_completion_date,
	l_task_id,
        l_end_item_unit_number,
	l_replenish_to_order_flag,
	l_build_in_wip_flag;

      EXIT WHEN C1_SO%NOTFOUND;
  else
      FETCH C1_PO INTO
        l_rowid,
        l_demand_class,
	l_demand_source_delivery,
	l_demand_source_header_id,
	l_demand_source_line,
	l_demand_source_type,
	l_planned_quantity,
	l_primary_item_id,
	l_project_id,
	l_scheduled_completion_date,
	l_task_id,
        l_end_item_unit_number,
	l_replenish_to_order_flag,
	l_build_in_wip_flag;

      EXIT WHEN C1_PO%NOTFOUND;
  end if;

      IF (p_SCHEDULE_RULE_ID <> -1 AND p_RULE_USER_DEFINED = 1) THEN
	 MRP_CUSTOM_LINE_SCHEDULE.Is_Valid_Demand
	   (
	    1.0,
	    p_SCHEDULE_RULE_ID,
	    p_LINE_ID,
	    p_ORGANIZATION_ID,
	    l_demand_source_type,
	    l_demand_source_line,
	    l_valid_demand,
	    l_return_status,
	    l_msg_count,
	    l_msg_data
	   );

	 -- Check return status
	 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    x_return_status := l_return_status;
	    x_msg_count := l_msg_count;
	    x_msg_data := l_msg_data;

	    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     ELSE
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
	 END IF;

      ELSE
	 l_valid_demand := TRUE;
      END IF;

      IF l_valid_demand THEN
	 -- Planned orders
	 IF p_unscheduled_order_type = 2 THEN
          BEGIN
	     -- Lock the planned order rows so we don't get duplicate
	     -- flow schedules
	     SELECT rowid
	     INTO l_rowid
	     FROM mrp_recommendations
	     WHERE rowid = l_rowid
	     FOR UPDATE of quantity_in_process NOWAIT;

          EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		NULL;
	     WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
		x_lock_count := x_lock_count + 1;
          END;
	 END IF;

	 OPEN C2;
	 FETCH C2 INTO l_wip_entity_id;
	 CLOSE C2;

	 --l_schedule_number := nvl(substr(FND_PROFILE.value('WIP_JOB_PREFIX'),1,20), 'X')
	 --  || to_char(l_wip_entity_id);

         --Bug 6122344
         l_schedule_number := 'FLM-INTERNAL' || to_char(l_wip_entity_id);

	 MRP_WFS_Form_Flow_Schedule.Create_Flow_Schedule
	   (
	    x_return_status		=> l_return_status,
	    x_msg_count		        => l_msg_count,
	    x_msg_data		        => l_msg_data,
	    p_alternate_bom_designator  => FND_API.G_MISS_CHAR,
	    p_alternate_routing_desig	=> FND_API.G_MISS_CHAR,
	    p_attribute1		=> l_attribute1,
	    p_attribute10		=> l_attribute10,
	    p_attribute11		=> l_attribute11,
	    p_attribute12		=> l_attribute12,
	    p_attribute13		=> l_attribute13,
	    p_attribute14		=> l_attribute14,
	    p_attribute15		=> l_attribute15,
	    p_attribute2		=> l_attribute2,
	    p_attribute3		=> l_attribute3,
	    p_attribute4		=> l_attribute4,
	    p_attribute5		=> l_attribute5,
	    p_attribute6		=> l_attribute6,
	    p_attribute7		=> l_attribute7,
	    p_attribute8		=> l_attribute8,
	    p_attribute9		=> l_attribute9,
	    p_attribute_category	=> FND_API.G_MISS_CHAR,
	    p_bom_revision		=> FND_API.G_MISS_CHAR,
	    p_bom_revision_date	        => FND_API.G_MISS_DATE,
	    p_build_sequence		=> FND_API.G_MISS_NUM,
	    p_class_code		=> FND_API.G_MISS_CHAR,
	   p_completion_locator_id	=> FND_API.G_MISS_NUM,
	   p_completion_subinventory	=> FND_API.G_MISS_CHAR,
	   p_created_by		        => FND_API.G_MISS_NUM,
	   p_creation_date		=> FND_API.G_MISS_DATE,
	   p_date_closed		=> FND_API.G_MISS_DATE,
	   p_demand_class		=> l_demand_class,
	   p_demand_source_delivery	=> l_demand_source_delivery,
	   p_demand_source_header_id	=> l_demand_source_header_id,
	   p_demand_source_line	        => l_demand_source_line,
	   p_demand_source_type	        => l_demand_source_type,
	   p_last_updated_by		=> FND_API.G_MISS_NUM,
	   p_last_update_date		=> FND_API.G_MISS_DATE,
	   p_last_update_login	        => FND_API.G_MISS_NUM,
	   p_line_id			=> l_line_id,
	   p_material_account		=> FND_API.G_MISS_NUM,
	   p_material_overhead_account  => FND_API.G_MISS_NUM,
	   p_material_variance_account  => FND_API.G_MISS_NUM,
	   p_mps_net_quantity		=> FND_API.G_MISS_NUM,
	   p_mps_scheduled_comp_date	=> FND_API.G_MISS_DATE,
	   p_organization_id		=> l_organization_id,
	   p_outside_processing_acct	=> FND_API.G_MISS_NUM,
	   p_outside_proc_var_acct	=> FND_API.G_MISS_NUM,
	   p_overhead_account		=> FND_API.G_MISS_NUM,
	   p_overhead_variance_account  => FND_API.G_MISS_NUM,
	   p_planned_quantity		=> l_planned_quantity,
	   p_primary_item_id		=> l_primary_item_id,
	   p_program_application_id	=> FND_API.G_MISS_NUM,
	   p_program_id		        => FND_API.G_MISS_NUM,
	   p_program_update_date	=> FND_API.G_MISS_DATE,
	   p_project_id		        => l_project_id,
	   p_quantity_completed	        => FND_API.G_MISS_NUM,
	   p_request_id		        => USERENV('SESSIONID'), -- bug 4529167
	   p_resource_account		=> FND_API.G_MISS_NUM,
	   p_resource_variance_account  => FND_API.G_MISS_NUM,
	   p_routing_revision		=> FND_API.G_MISS_CHAR,
	   p_routing_revision_date	=> FND_API.G_MISS_DATE,
	   p_scheduled_completion_date  => l_scheduled_completion_date,
	   p_scheduled_flag		=> l_scheduled_flag,
	   p_scheduled_start_date	=> FND_API.G_MISS_DATE,
	   p_schedule_group_id	        => l_schedule_group_id,
	   p_schedule_number		=> l_schedule_number,
	   p_status			=> FND_API.G_MISS_NUM,
	   p_std_cost_adjustment_acct	=> FND_API.G_MISS_NUM,
	   p_task_id			=> l_task_id,
	   p_wip_entity_id		=> l_wip_entity_id,
	   p_end_item_unit_number       => l_end_item_unit_number,
	   p_quantity_scrapped          => FND_API.G_MISS_NUM,
	   x_wip_entity_id		=> l_wip_entity_id2
	   );

	 -- Check return status
	 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    x_return_status := l_return_status;
	    x_msg_count := l_msg_count;
	    x_msg_data := l_msg_data;

	    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     ELSE
	       RAISE FND_API.G_EXC_ERROR;
	    END IF;
	 END IF;

	 --fix bug#3235193
         --Description: move the CTO create API call to a centralized place in
         --             MRPSLSWB.fmb - pu MRPSLSWB - set_schedule_number()
         --             comment CTO create API call below
	 -- For config item linked to SO, call CTO create API to notify workflow
 	 /*IF (l_replenish_to_order_flag = 'Y' AND
	     l_build_in_wip_flag = 'Y' AND
	     l_demand_source_line IS NOT NULL AND
	     l_demand_source_type = 2) THEN
	    CTO_WIP_WORKFLOW_API_PK.flow_creation
	      (
	       to_number(l_demand_source_line),
	       l_return_status,
	       l_msg_count,
	       l_msg_data);
         END IF;*/
         --end of fix bug#3235193

	 x_created_count := x_created_count + 1;

      END IF;

   END LOOP;

/*   CLOSE C1; */
   if(p_unscheduled_order_type = 1 ) then
     CLOSE C1_SO;
   else
     CLOSE C1_PO;
   end if;

   x_return_status := l_return_status;

   --  Get message count and data

   FND_MSG_PUB.Count_And_Get
     (   p_count     => x_msg_count
	,p_data      => x_msg_data
     );

EXCEPTION

   WHEN OTHERS THEN

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (   G_PKG_NAME
	      ,'Create_Schedules'
	   );
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      --  Get message count and data

      FND_MSG_PUB.Count_And_Get
	(
	   p_count    => x_msg_count
	  ,p_data     => x_msg_data
	);

END Create_Raw_Flow_Schedules;


END MRP_WFS_Form_Flow_Schedule;

/
