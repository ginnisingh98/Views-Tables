--------------------------------------------------------
--  DDL for Package Body MRP_FLOW_SCHEDULE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_FLOW_SCHEDULE_UTIL" AS
/* $Header: MRPUSCNB.pls 120.10.12010000.2 2009/05/19 06:38:06 adasa ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Flow_Schedule_Util';

--
-- Local Types
--
TYPE t_line_rec IS RECORD (
  line_id	NUMBER,
  order_quantity	NUMBER,
  fs_quantity	NUMBER,
  needed_quantity	NUMBER,
  distributed_quantity	NUMBER,
  parent_line_id	NUMBER,
  first_child		NUMBER,
  last_child		NUMBER,
  previous_brother      NUMBER, /** Bug 2536351 **/
  next_brother		NUMBER);

TYPE t_line_tbl IS TABLE OF  t_line_rec
  INDEX BY BINARY_INTEGER;

l_lines	t_line_tbl;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER DEFAULT NULL
,   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_old_flow_schedule_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   x_flow_schedule_rec             IN  OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_flow_schedule_rec := p_flow_schedule_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    -- Commenting for pl-sql coding standards and instead check if p_attr_id is null
    -- IF p_attr_id = FND_API.G_MISS_NUM THEN
    IF p_attr_id IS NULL THEN

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.alternate_bom_designator,p_old_flow_schedule_rec.alternate_bom_designator)
        THEN
            x_flow_schedule_rec.bom_revision := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.bom_revision_date := FND_API.G_MISS_DATE;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.alternate_routing_desig,p_old_flow_schedule_rec.alternate_routing_desig)
        THEN
            x_flow_schedule_rec.routing_revision := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.routing_revision_date := FND_API.G_MISS_DATE;
            x_flow_schedule_rec.completion_subinventory := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.completion_locator_id := FND_API.G_MISS_NUM;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.bom_revision,p_old_flow_schedule_rec.bom_revision)
        THEN
            x_flow_schedule_rec.bom_revision_date := FND_API.G_MISS_DATE;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.bom_revision_date,p_old_flow_schedule_rec.bom_revision_date)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.build_sequence,p_old_flow_schedule_rec.build_sequence)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.class_code,p_old_flow_schedule_rec.class_code)
        THEN
            x_flow_schedule_rec.material_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.material_overhead_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.resource_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.outside_processing_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.material_variance_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.resource_variance_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.outside_proc_var_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.std_cost_adjustment_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.overhead_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.overhead_variance_account := FND_API.G_MISS_NUM;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.completion_locator_id,p_old_flow_schedule_rec.completion_locator_id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.completion_subinventory,p_old_flow_schedule_rec.completion_subinventory)
        THEN
            x_flow_schedule_rec.completion_locator_id := FND_API.G_MISS_NUM;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.created_by,p_old_flow_schedule_rec.created_by)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.creation_date,p_old_flow_schedule_rec.creation_date)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.date_closed,p_old_flow_schedule_rec.date_closed)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.demand_class,p_old_flow_schedule_rec.demand_class)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.demand_source_delivery,p_old_flow_schedule_rec.demand_source_delivery)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.demand_source_header_id,p_old_flow_schedule_rec.demand_source_header_id)
        THEN
            x_flow_schedule_rec.demand_source_line := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.demand_source_delivery := FND_API.G_MISS_CHAR;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.demand_source_line,p_old_flow_schedule_rec.demand_source_line)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.demand_source_type,p_old_flow_schedule_rec.demand_source_type)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.last_updated_by,p_old_flow_schedule_rec.last_updated_by)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.last_update_date,p_old_flow_schedule_rec.last_update_date)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.last_update_login,p_old_flow_schedule_rec.last_update_login)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.line_id,p_old_flow_schedule_rec.line_id)
        THEN
            x_flow_schedule_rec.alternate_routing_desig := FND_API.G_MISS_CHAR;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.material_account,p_old_flow_schedule_rec.material_account)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.material_overhead_account,p_old_flow_schedule_rec.material_overhead_account)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.material_variance_account,p_old_flow_schedule_rec.material_variance_account)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.mps_net_quantity,p_old_flow_schedule_rec.mps_net_quantity)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.mps_scheduled_comp_date,p_old_flow_schedule_rec.mps_scheduled_comp_date)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.organization_id,p_old_flow_schedule_rec.organization_id)
        THEN
            x_flow_schedule_rec.primary_item_id := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.completion_subinventory := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.completion_locator_id := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.demand_source_header_id := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.demand_source_type := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.demand_source_line := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.demand_source_delivery := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.alternate_bom_designator := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.bom_revision := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.bom_revision_date := FND_API.G_MISS_DATE;
            x_flow_schedule_rec.alternate_routing_desig := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.routing_revision := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.routing_revision_date := FND_API.G_MISS_DATE;
            x_flow_schedule_rec.line_id := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.class_code := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.schedule_group_id := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.material_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.material_overhead_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.resource_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.outside_processing_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.material_variance_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.resource_variance_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.outside_proc_var_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.std_cost_adjustment_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.overhead_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.overhead_variance_account := FND_API.G_MISS_NUM;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.outside_processing_acct,p_old_flow_schedule_rec.outside_processing_acct)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.outside_proc_var_acct,p_old_flow_schedule_rec.outside_proc_var_acct)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.overhead_account,p_old_flow_schedule_rec.overhead_account)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.overhead_variance_account,p_old_flow_schedule_rec.overhead_variance_account)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.planned_quantity,p_old_flow_schedule_rec.planned_quantity)
        THEN
            x_flow_schedule_rec.scheduled_start_date := FND_API.G_MISS_DATE;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.primary_item_id,p_old_flow_schedule_rec.primary_item_id)
        THEN
            x_flow_schedule_rec.completion_subinventory := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.completion_locator_id := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.demand_source_header_id := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.demand_source_type := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.demand_source_line := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.demand_source_delivery := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.alternate_bom_designator := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.bom_revision := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.bom_revision_date := FND_API.G_MISS_DATE;
            x_flow_schedule_rec.alternate_routing_desig := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.routing_revision := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.routing_revision_date := FND_API.G_MISS_DATE;
            x_flow_schedule_rec.class_code := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.scheduled_start_date := FND_API.G_MISS_DATE;
            x_flow_schedule_rec.material_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.material_overhead_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.resource_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.outside_processing_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.material_variance_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.resource_variance_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.outside_proc_var_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.std_cost_adjustment_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.overhead_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.overhead_variance_account := FND_API.G_MISS_NUM;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.program_application_id,p_old_flow_schedule_rec.program_application_id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.program_id,p_old_flow_schedule_rec.program_id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.program_update_date,p_old_flow_schedule_rec.program_update_date)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.project_id,p_old_flow_schedule_rec.project_id)
        THEN
            x_flow_schedule_rec.task_id := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.class_code := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.material_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.material_overhead_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.resource_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.outside_processing_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.material_variance_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.resource_variance_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.outside_proc_var_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.std_cost_adjustment_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.overhead_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.overhead_variance_account := FND_API.G_MISS_NUM;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.quantity_completed,p_old_flow_schedule_rec.quantity_completed)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.request_id,p_old_flow_schedule_rec.request_id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.resource_account,p_old_flow_schedule_rec.resource_account)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.resource_variance_account,p_old_flow_schedule_rec.resource_variance_account)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.routing_revision,p_old_flow_schedule_rec.routing_revision)
        THEN
            x_flow_schedule_rec.routing_revision_date := FND_API.G_MISS_DATE;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.routing_revision_date,p_old_flow_schedule_rec.routing_revision_date)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.scheduled_completion_date,p_old_flow_schedule_rec.scheduled_completion_date)
        THEN
            x_flow_schedule_rec.scheduled_start_date := FND_API.G_MISS_DATE;
            x_flow_schedule_rec.bom_revision := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.bom_revision_date := FND_API.G_MISS_DATE;
            x_flow_schedule_rec.routing_revision := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.routing_revision_date := FND_API.G_MISS_DATE;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.scheduled_flag,p_old_flow_schedule_rec.scheduled_flag)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.scheduled_start_date,p_old_flow_schedule_rec.scheduled_start_date)
        THEN
            NULL;
        END IF;

-- Comment it out to fix bug 1198493. We don't want the build_sequence set to null
-- when schedule group is changed
/*
        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.schedule_group_id,p_old_flow_schedule_rec.schedule_group_id)
        THEN
            x_flow_schedule_rec.build_sequence := FND_API.G_MISS_NUM;
        END IF;
*/

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.schedule_number,p_old_flow_schedule_rec.schedule_number)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.status,p_old_flow_schedule_rec.status)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.std_cost_adjustment_acct,p_old_flow_schedule_rec.std_cost_adjustment_acct)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.task_id,p_old_flow_schedule_rec.task_id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.wip_entity_id,p_old_flow_schedule_rec.wip_entity_id)
        THEN
            NULL;
        END IF;

    ELSIF p_attr_id = G_ALTERNATE_BOM_DESIGNATOR THEN
        x_flow_schedule_rec.bom_revision := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.bom_revision_date := FND_API.G_MISS_DATE;
    ELSIF p_attr_id = G_ALTERNATE_ROUTING_DESIG THEN
        x_flow_schedule_rec.routing_revision := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.routing_revision_date := FND_API.G_MISS_DATE;
        x_flow_schedule_rec.completion_subinventory := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.completion_locator_id := FND_API.G_MISS_NUM;
    ELSIF p_attr_id = G_BOM_REVISION THEN
        x_flow_schedule_rec.bom_revision_date := FND_API.G_MISS_DATE;
    ELSIF p_attr_id = G_BOM_REVISION_DATE THEN
        NULL;
    ELSIF p_attr_id = G_BUILD_SEQUENCE THEN
        NULL;
    ELSIF p_attr_id = G_CLASS THEN
        x_flow_schedule_rec.material_account := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.material_overhead_account := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.resource_account := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.outside_processing_acct := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.material_variance_account := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.resource_variance_account := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.outside_proc_var_acct := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.std_cost_adjustment_acct := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.overhead_account := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.overhead_variance_account := FND_API.G_MISS_NUM;
    ELSIF p_attr_id = G_COMPLETION_LOCATOR THEN
        NULL;
    ELSIF p_attr_id = G_COMPLETION_SUBINVENTORY THEN
        x_flow_schedule_rec.completion_locator_id := FND_API.G_MISS_NUM;
    ELSIF p_attr_id = G_CREATED_BY THEN
        NULL;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        NULL;
    ELSIF p_attr_id = G_DATE_CLOSED THEN
        NULL;
    ELSIF p_attr_id = G_DEMAND_CLASS THEN
        NULL;
    ELSIF p_attr_id = G_DEMAND_SOURCE_DELIVERY THEN
        NULL;
    ELSIF p_attr_id = G_DEMAND_SOURCE_HEADER THEN
        x_flow_schedule_rec.demand_source_line := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.demand_source_delivery := FND_API.G_MISS_CHAR;
    ELSIF p_attr_id = G_DEMAND_SOURCE_LINE THEN
        NULL;
    ELSIF p_attr_id = G_DEMAND_SOURCE_TYPE THEN
        NULL;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        NULL;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        NULL;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        NULL;
    ELSIF p_attr_id = G_LINE THEN
        NULL;
    ELSIF p_attr_id = G_MATERIAL_ACCOUNT THEN
        NULL;
    ELSIF p_attr_id = G_MATERIAL_OVERHEAD_ACCOUNT THEN
        NULL;
    ELSIF p_attr_id = G_MATERIAL_VARIANCE_ACCOUNT THEN
        NULL;
    ELSIF p_attr_id = G_MPS_NET_QUANTITY THEN
        NULL;
    ELSIF p_attr_id = G_MPS_SCHEDULED_COMP_DATE THEN
        NULL;
    ELSIF p_attr_id = G_ORGANIZATION THEN
        x_flow_schedule_rec.primary_item_id := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.completion_subinventory := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.completion_locator_id := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.demand_source_header_id := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.demand_source_type := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.demand_source_line := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.demand_source_delivery := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.alternate_bom_designator := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.bom_revision := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.bom_revision_date := FND_API.G_MISS_DATE;
        x_flow_schedule_rec.alternate_routing_desig := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.routing_revision := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.routing_revision_date := FND_API.G_MISS_DATE;
        x_flow_schedule_rec.line_id := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.class_code := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.schedule_group_id := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.material_account := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.material_overhead_account := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.resource_account := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.outside_processing_acct := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.material_variance_account := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.resource_variance_account := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.outside_proc_var_acct := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.std_cost_adjustment_acct := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.overhead_account := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.overhead_variance_account := FND_API.G_MISS_NUM;
    ELSIF p_attr_id = G_OUTSIDE_PROCESSING_ACCT THEN
        NULL;
    ELSIF p_attr_id = G_OUTSIDE_PROC_VAR_ACCT THEN
        NULL;
    ELSIF p_attr_id = G_OVERHEAD_ACCOUNT THEN
        NULL;
    ELSIF p_attr_id = G_OVERHEAD_VARIANCE_ACCOUNT THEN
        NULL;
    ELSIF p_attr_id = G_PLANNED_QUANTITY THEN
        x_flow_schedule_rec.scheduled_start_date := FND_API.G_MISS_DATE;
    ELSIF p_attr_id = G_PRIMARY_ITEM THEN
        x_flow_schedule_rec.completion_subinventory := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.completion_locator_id := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.demand_source_header_id := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.demand_source_type := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.demand_source_line := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.demand_source_delivery := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.alternate_bom_designator := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.bom_revision := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.bom_revision_date := FND_API.G_MISS_DATE;
        x_flow_schedule_rec.alternate_routing_desig := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.routing_revision := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.routing_revision_date := FND_API.G_MISS_DATE;
        x_flow_schedule_rec.class_code := FND_API.G_MISS_CHAR;
        x_flow_schedule_rec.scheduled_start_date := FND_API.G_MISS_DATE;
            x_flow_schedule_rec.material_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.material_overhead_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.resource_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.outside_processing_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.material_variance_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.resource_variance_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.outside_proc_var_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.std_cost_adjustment_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.overhead_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.overhead_variance_account := FND_API.G_MISS_NUM;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        NULL;
    ELSIF p_attr_id = G_PROGRAM THEN
        NULL;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        NULL;
    ELSIF p_attr_id = G_PROJECT THEN
        x_flow_schedule_rec.task_id := FND_API.G_MISS_NUM;
        x_flow_schedule_rec.class_code := FND_API.G_MISS_CHAR;
            x_flow_schedule_rec.material_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.material_overhead_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.resource_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.outside_processing_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.material_variance_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.resource_variance_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.outside_proc_var_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.std_cost_adjustment_acct := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.overhead_account := FND_API.G_MISS_NUM;
            x_flow_schedule_rec.overhead_variance_account := FND_API.G_MISS_NUM;
    ELSIF p_attr_id = G_QUANTITY_COMPLETED THEN
        NULL;
    ELSIF p_attr_id = G_REQUEST THEN
        NULL;
    ELSIF p_attr_id = G_RESOURCE_ACCOUNT THEN
        NULL;
    ELSIF p_attr_id = G_RESOURCE_VARIANCE_ACCOUNT THEN
        NULL;
    ELSIF p_attr_id = G_ROUTING_REVISION THEN
        x_flow_schedule_rec.routing_revision_date := FND_API.G_MISS_DATE;
    ELSIF p_attr_id = G_ROUTING_REVISION_DATE THEN
        NULL;
    ELSIF p_attr_id = G_SCHEDULED_COMPLETION_DATE THEN
        x_flow_schedule_rec.scheduled_start_date := FND_API.G_MISS_DATE;
    ELSIF p_attr_id = G_SCHEDULED THEN
        NULL;
    ELSIF p_attr_id = G_SCHEDULED_START_DATE THEN
        NULL;
    ELSIF p_attr_id = G_SCHEDULE_GROUP THEN
        x_flow_schedule_rec.build_sequence := FND_API.G_MISS_NUM;
    ELSIF p_attr_id = G_SCHEDULE_NUMBER THEN
        NULL;
    ELSIF p_attr_id = G_STATUS THEN
        NULL;
    ELSIF p_attr_id = G_STD_COST_ADJUSTMENT_ACCT THEN
        NULL;
    ELSIF p_attr_id = G_TASK THEN
        NULL;
    ELSIF p_attr_id = G_WIP_ENTITY THEN
        NULL;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_old_flow_schedule_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   x_flow_schedule_rec             IN  OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
)
IS
l_bom_revision		NUMBER := NULL;
l_revision		NUMBER := NULL;
l_bom_date		DATE := NULL;
l_routing_revision	NUMBER := NULL;
l_routing_date		DATE := NULL;
l_error_number		NUMBER := 1;
BEGIN

    --  Load out record

    x_flow_schedule_rec := p_flow_schedule_rec;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.alternate_bom_designator,p_old_flow_schedule_rec.alternate_bom_designator)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.alternate_routing_desig,p_old_flow_schedule_rec.alternate_routing_desig)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.bom_revision,p_old_flow_schedule_rec.bom_revision)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.bom_revision_date,p_old_flow_schedule_rec.bom_revision_date)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.build_sequence,p_old_flow_schedule_rec.build_sequence)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.class_code,p_old_flow_schedule_rec.class_code)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.completion_locator_id,p_old_flow_schedule_rec.completion_locator_id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.completion_subinventory,p_old_flow_schedule_rec.completion_subinventory)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.created_by,p_old_flow_schedule_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.creation_date,p_old_flow_schedule_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.date_closed,p_old_flow_schedule_rec.date_closed)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.demand_class,p_old_flow_schedule_rec.demand_class)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.demand_source_delivery,p_old_flow_schedule_rec.demand_source_delivery)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.demand_source_header_id,p_old_flow_schedule_rec.demand_source_header_id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.demand_source_line,p_old_flow_schedule_rec.demand_source_line)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.demand_source_type,p_old_flow_schedule_rec.demand_source_type)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.last_updated_by,p_old_flow_schedule_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.last_update_date,p_old_flow_schedule_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.last_update_login,p_old_flow_schedule_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.line_id,p_old_flow_schedule_rec.line_id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.material_account,p_old_flow_schedule_rec.material_account)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.material_overhead_account,p_old_flow_schedule_rec.material_overhead_account)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.material_variance_account,p_old_flow_schedule_rec.material_variance_account)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.mps_net_quantity,p_old_flow_schedule_rec.mps_net_quantity)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.mps_scheduled_comp_date,p_old_flow_schedule_rec.mps_scheduled_comp_date)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.organization_id,p_old_flow_schedule_rec.organization_id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.outside_processing_acct,p_old_flow_schedule_rec.outside_processing_acct)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.outside_proc_var_acct,p_old_flow_schedule_rec.outside_proc_var_acct)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.overhead_account,p_old_flow_schedule_rec.overhead_account)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.overhead_variance_account,p_old_flow_schedule_rec.overhead_variance_account)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.planned_quantity,p_old_flow_schedule_rec.planned_quantity)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.primary_item_id,p_old_flow_schedule_rec.primary_item_id)
    THEN
    /* Fix for bug 3661250. Added the following SQL to update primary_item_id in WIP_ENTITIES if it has been changed.
    */
        UPDATE WIP_ENTITIES
           SET primary_item_id = p_flow_schedule_rec.primary_item_id
         WHERE wip_entity_id   = p_flow_schedule_rec.wip_entity_id
           AND organization_id = p_flow_schedule_rec.organization_id;

   /* End of fix for bug 3661250 */
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.program_application_id,p_old_flow_schedule_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.program_id,p_old_flow_schedule_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.program_update_date,p_old_flow_schedule_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.project_id,p_old_flow_schedule_rec.project_id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.quantity_completed,p_old_flow_schedule_rec.quantity_completed)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.request_id,p_old_flow_schedule_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.resource_account,p_old_flow_schedule_rec.resource_account)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.resource_variance_account,p_old_flow_schedule_rec.resource_variance_account)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.routing_revision,p_old_flow_schedule_rec.routing_revision)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.routing_revision_date,p_old_flow_schedule_rec.routing_revision_date)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.scheduled_completion_date,p_old_flow_schedule_rec.scheduled_completion_date)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.scheduled_flag,p_old_flow_schedule_rec.scheduled_flag)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.scheduled_start_date,p_old_flow_schedule_rec.scheduled_start_date)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.schedule_group_id,p_old_flow_schedule_rec.schedule_group_id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.schedule_number,p_old_flow_schedule_rec.schedule_number)
    THEN
        UPDATE wip_entities
        SET wip_entity_name = p_flow_schedule_rec.schedule_number
        WHERE wip_entity_id = p_flow_schedule_rec.wip_entity_id;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.status,p_old_flow_schedule_rec.status)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.std_cost_adjustment_acct,p_old_flow_schedule_rec.std_cost_adjustment_acct)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.task_id,p_old_flow_schedule_rec.task_id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.wip_entity_id,p_old_flow_schedule_rec.wip_entity_id)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_old_flow_schedule_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
) RETURN MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
IS
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type := p_flow_schedule_rec;
BEGIN

    IF l_flow_schedule_rec.alternate_bom_designator = FND_API.G_MISS_CHAR THEN
	l_flow_schedule_rec.alternate_bom_designator := NULL ;
    ELSIF l_flow_schedule_rec.alternate_bom_designator IS NULL THEN
        l_flow_schedule_rec.alternate_bom_designator := p_old_flow_schedule_rec.alternate_bom_designator;
    END IF;

    IF l_flow_schedule_rec.alternate_routing_desig = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.alternate_routing_desig :=  NULL ;
    ELSIF l_flow_schedule_rec.alternate_routing_desig IS NULL THEN
        l_flow_schedule_rec.alternate_routing_desig := p_old_flow_schedule_rec.alternate_routing_desig;
    END IF;

    IF l_flow_schedule_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute1 :=  NULL ;
    ELSIF l_flow_schedule_rec.attribute1 IS NULL THEN
        l_flow_schedule_rec.attribute1 := p_old_flow_schedule_rec.attribute1;
    END IF;

    IF l_flow_schedule_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute10 := NULL ;
    ELSIF l_flow_schedule_rec.attribute10 IS NULL THEN
        l_flow_schedule_rec.attribute10 := p_old_flow_schedule_rec.attribute10;
    END IF;

    IF l_flow_schedule_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute11 := NULL ;
    ELSIF l_flow_schedule_rec.attribute11 IS NULL THEN
        l_flow_schedule_rec.attribute11 := p_old_flow_schedule_rec.attribute11;
    END IF;

    IF l_flow_schedule_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute12 := NULL ;
    ELSIF l_flow_schedule_rec.attribute12 IS NULL THEN
        l_flow_schedule_rec.attribute12 := p_old_flow_schedule_rec.attribute12;
    END IF;

    IF l_flow_schedule_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute13 := NULL ;
    ELSIF l_flow_schedule_rec.attribute13 IS NULL THEN
        l_flow_schedule_rec.attribute13 := p_old_flow_schedule_rec.attribute13;
    END IF;

    IF l_flow_schedule_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute14 := NULL ;
    ELSIF l_flow_schedule_rec.attribute14 IS NULL THEN
        l_flow_schedule_rec.attribute14 := p_old_flow_schedule_rec.attribute14;
    END IF;

    IF l_flow_schedule_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute15 := NULL ;
    ELSIF l_flow_schedule_rec.attribute15 IS NULL THEN
        l_flow_schedule_rec.attribute15 := p_old_flow_schedule_rec.attribute15;
    END IF;

    IF l_flow_schedule_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute2 :=  NULL ;
    ELSIF l_flow_schedule_rec.attribute2 IS NULL THEN
        l_flow_schedule_rec.attribute2 := p_old_flow_schedule_rec.attribute2;
    END IF;

    IF l_flow_schedule_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute3 :=  NULL ;
    ELSIF l_flow_schedule_rec.attribute3 IS NULL THEN
        l_flow_schedule_rec.attribute3 := p_old_flow_schedule_rec.attribute3;
    END IF;

    IF l_flow_schedule_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute4 :=  NULL ;
    ELSIF l_flow_schedule_rec.attribute4 IS NULL THEN
        l_flow_schedule_rec.attribute4 := p_old_flow_schedule_rec.attribute4;
    END IF;

    IF l_flow_schedule_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute5 :=  NULL ;
    ELSIF l_flow_schedule_rec.attribute5 IS NULL THEN
        l_flow_schedule_rec.attribute5 := p_old_flow_schedule_rec.attribute5;
    END IF;

    IF l_flow_schedule_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute6 :=  NULL ;
    ELSIF l_flow_schedule_rec.attribute6 IS NULL THEN
        l_flow_schedule_rec.attribute6 := p_old_flow_schedule_rec.attribute6;
    END IF;

    IF l_flow_schedule_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute7 :=  NULL ;
    ELSIF l_flow_schedule_rec.attribute7 IS NULL THEN
        l_flow_schedule_rec.attribute7 := p_old_flow_schedule_rec.attribute7;
    END IF;

    IF l_flow_schedule_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute8 :=  NULL ;
    ELSIF l_flow_schedule_rec.attribute8 IS NULL THEN
        l_flow_schedule_rec.attribute8 := p_old_flow_schedule_rec.attribute8;
    END IF;

    IF l_flow_schedule_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute9 :=  NULL ;
    ELSIF l_flow_schedule_rec.attribute9 IS NULL THEN
        l_flow_schedule_rec.attribute9 := p_old_flow_schedule_rec.attribute9;
    END IF;

    IF l_flow_schedule_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute_category :=  NULL ;
    ELSIF l_flow_schedule_rec.attribute_category IS NULL  THEN
        l_flow_schedule_rec.attribute_category := p_old_flow_schedule_rec.attribute_category;
    END IF;

    IF l_flow_schedule_rec.bom_revision = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.bom_revision :=  NULL ;
    ELSIF l_flow_schedule_rec.bom_revision IS NULL THEN
        l_flow_schedule_rec.bom_revision := p_old_flow_schedule_rec.bom_revision;
    END IF;

    IF l_flow_schedule_rec.bom_revision_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.bom_revision_date :=  NULL ;
    ELSIF l_flow_schedule_rec.bom_revision_date IS NULL THEN
        l_flow_schedule_rec.bom_revision_date := p_old_flow_schedule_rec.bom_revision_date;
    END IF;

    IF l_flow_schedule_rec.build_sequence = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.build_sequence :=  NULL ;
    ELSIF l_flow_schedule_rec.build_sequence IS NULL THEN
        l_flow_schedule_rec.build_sequence := p_old_flow_schedule_rec.build_sequence;
    END IF;

    IF l_flow_schedule_rec.class_code = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.class_code :=  NULL ;
    ELSIF l_flow_schedule_rec.class_code IS NULL THEN
        l_flow_schedule_rec.class_code := p_old_flow_schedule_rec.class_code;
    END IF;

    IF l_flow_schedule_rec.completion_locator_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.completion_locator_id :=  NULL ;
    ELSIF l_flow_schedule_rec.completion_locator_id IS NULL THEN
        l_flow_schedule_rec.completion_locator_id := p_old_flow_schedule_rec.completion_locator_id;
    END IF;

    IF l_flow_schedule_rec.completion_subinventory = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.completion_subinventory := NULL ;
    ELSIF l_flow_schedule_rec.completion_subinventory IS NULL THEN
        l_flow_schedule_rec.completion_subinventory := p_old_flow_schedule_rec.completion_subinventory;
    END IF;

    IF l_flow_schedule_rec.created_by = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.created_by :=  NULL ;
    ELSIF l_flow_schedule_rec.created_by IS NULL THEN
        l_flow_schedule_rec.created_by := p_old_flow_schedule_rec.created_by;
    END IF;

    IF l_flow_schedule_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.creation_date :=  NULL ;
    ELSIF l_flow_schedule_rec.creation_date IS NULL THEN
        l_flow_schedule_rec.creation_date := p_old_flow_schedule_rec.creation_date;
    END IF;

    IF l_flow_schedule_rec.date_closed = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.date_closed :=  NULL ;
    ELSIF l_flow_schedule_rec.date_closed IS NULL THEN
        l_flow_schedule_rec.date_closed := p_old_flow_schedule_rec.date_closed;
    END IF;

    IF l_flow_schedule_rec.demand_class = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.demand_class := NULL ;
    ELSIF l_flow_schedule_rec.demand_class IS NULL THEN
        l_flow_schedule_rec.demand_class := p_old_flow_schedule_rec.demand_class;
    END IF;

    IF l_flow_schedule_rec.demand_source_delivery = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.demand_source_delivery :=  NULL ;
    ELSIF l_flow_schedule_rec.demand_source_delivery IS NULL THEN
        l_flow_schedule_rec.demand_source_delivery := p_old_flow_schedule_rec.demand_source_delivery;
    END IF;

    IF l_flow_schedule_rec.demand_source_header_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.demand_source_header_id := NULL ;
    ELSIF l_flow_schedule_rec.demand_source_header_id IS NULL THEN
        l_flow_schedule_rec.demand_source_header_id := p_old_flow_schedule_rec.demand_source_header_id;
    END IF;

    IF l_flow_schedule_rec.demand_source_line = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.demand_source_line :=  NULL ;
    ELSIF l_flow_schedule_rec.demand_source_line IS NULL THEN
        l_flow_schedule_rec.demand_source_line := p_old_flow_schedule_rec.demand_source_line;
    END IF;

    IF l_flow_schedule_rec.demand_source_type = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.demand_source_type :=  NULL ;
    ELSIF l_flow_schedule_rec.demand_source_type IS NULL THEN
        l_flow_schedule_rec.demand_source_type := p_old_flow_schedule_rec.demand_source_type;
    END IF;

    IF l_flow_schedule_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.last_updated_by :=  NULL ;
    ELSIF l_flow_schedule_rec.last_updated_by IS NULL THEN
        l_flow_schedule_rec.last_updated_by := p_old_flow_schedule_rec.last_updated_by;
    END IF;

    IF l_flow_schedule_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.last_update_date := NULL ;
    ELSIF l_flow_schedule_rec.last_update_date IS NULL THEN
        l_flow_schedule_rec.last_update_date := p_old_flow_schedule_rec.last_update_date;
    END IF;

    IF l_flow_schedule_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.last_update_login :=  NULL ;
    ELSIF l_flow_schedule_rec.last_update_login IS NULL THEN
        l_flow_schedule_rec.last_update_login := p_old_flow_schedule_rec.last_update_login;
    END IF;

    IF l_flow_schedule_rec.line_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.line_id :=  NULL ;
    ELSIF l_flow_schedule_rec.line_id IS NULL THEN
        l_flow_schedule_rec.line_id := p_old_flow_schedule_rec.line_id;
    END IF;

    IF l_flow_schedule_rec.material_account = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.material_account := NULL ;
    ELSIF l_flow_schedule_rec.material_account IS NULL THEN
        l_flow_schedule_rec.material_account := p_old_flow_schedule_rec.material_account;
    END IF;

    IF l_flow_schedule_rec.material_overhead_account = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.material_overhead_account :=   NULL ;
    ELSIF l_flow_schedule_rec.material_overhead_account IS NULL THEN
        l_flow_schedule_rec.material_overhead_account := p_old_flow_schedule_rec.material_overhead_account;
    END IF;

    IF l_flow_schedule_rec.material_variance_account = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.material_variance_account :=  NULL ;
    ELSIF l_flow_schedule_rec.material_variance_account IS NULL THEN
        l_flow_schedule_rec.material_variance_account := p_old_flow_schedule_rec.material_variance_account;
    END IF;

    IF l_flow_schedule_rec.mps_net_quantity = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.mps_net_quantity :=   NULL ;
    ELSIF l_flow_schedule_rec.mps_net_quantity IS NULL THEN
        l_flow_schedule_rec.mps_net_quantity := p_old_flow_schedule_rec.mps_net_quantity;
    END IF;

    IF l_flow_schedule_rec.mps_scheduled_comp_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.mps_scheduled_comp_date :=   NULL ;
    ELSIF l_flow_schedule_rec.mps_scheduled_comp_date IS NULL THEN
        l_flow_schedule_rec.mps_scheduled_comp_date := p_old_flow_schedule_rec.mps_scheduled_comp_date;
    END IF;

    IF l_flow_schedule_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.organization_id :=   NULL ;
    ELSIF l_flow_schedule_rec.organization_id IS NULL THEN
        l_flow_schedule_rec.organization_id := p_old_flow_schedule_rec.organization_id;
    END IF;

    IF l_flow_schedule_rec.outside_processing_acct = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.outside_processing_acct :=   NULL ;
    ELSIF l_flow_schedule_rec.outside_processing_acct IS NULL  THEN
        l_flow_schedule_rec.outside_processing_acct := p_old_flow_schedule_rec.outside_processing_acct;
    END IF;

    IF l_flow_schedule_rec.outside_proc_var_acct = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.outside_proc_var_acct :=   NULL ;
    ELSIF l_flow_schedule_rec.outside_proc_var_acct IS NULL THEN
        l_flow_schedule_rec.outside_proc_var_acct := p_old_flow_schedule_rec.outside_proc_var_acct;
    END IF;

    IF l_flow_schedule_rec.overhead_account = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.overhead_account :=   NULL ;
    ELSIF l_flow_schedule_rec.overhead_account IS NULL THEN
        l_flow_schedule_rec.overhead_account := p_old_flow_schedule_rec.overhead_account;
    END IF;

    IF l_flow_schedule_rec.overhead_variance_account = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.overhead_variance_account :=  NULL ;
    ELSIF l_flow_schedule_rec.overhead_variance_account IS NULL THEN
        l_flow_schedule_rec.overhead_variance_account := p_old_flow_schedule_rec.overhead_variance_account;
    END IF;

    IF l_flow_schedule_rec.planned_quantity = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.planned_quantity :=   NULL ;
    ELSIF l_flow_schedule_rec.overhead_variance_account IS NULL THEN
        l_flow_schedule_rec.planned_quantity := p_old_flow_schedule_rec.planned_quantity;
    END IF;

    IF l_flow_schedule_rec.primary_item_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.primary_item_id :=   NULL ;
    ELSIF l_flow_schedule_rec.primary_item_id IS NULL THEN
        l_flow_schedule_rec.primary_item_id := p_old_flow_schedule_rec.primary_item_id;
    END IF;

    IF l_flow_schedule_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.program_application_id :=   NULL ;
    ELSIF l_flow_schedule_rec.program_application_id IS NULL THEN
        l_flow_schedule_rec.program_application_id := p_old_flow_schedule_rec.program_application_id;
    END IF;

    IF l_flow_schedule_rec.program_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.program_id :=   NULL ;
    ELSIF l_flow_schedule_rec.program_id IS NULL THEN
        l_flow_schedule_rec.program_id := p_old_flow_schedule_rec.program_id;
    END IF;

    IF l_flow_schedule_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.program_update_date :=  NULL ;
    ELSIF l_flow_schedule_rec.program_update_date IS NULL THEN
        l_flow_schedule_rec.program_update_date := p_old_flow_schedule_rec.program_update_date;
    END IF;

    IF l_flow_schedule_rec.project_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.project_id :=   NULL ;
    ELSIF l_flow_schedule_rec.project_id IS NULL THEN
        l_flow_schedule_rec.project_id := p_old_flow_schedule_rec.project_id;
    END IF;

    IF l_flow_schedule_rec.quantity_completed = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.quantity_completed :=   NULL ;
    ELSIF l_flow_schedule_rec.quantity_completed IS NULL  THEN
        l_flow_schedule_rec.quantity_completed := p_old_flow_schedule_rec.quantity_completed;
    END IF;

    IF l_flow_schedule_rec.request_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.request_id :=   NULL ;
    ELSIF l_flow_schedule_rec.request_id IS NULL THEN
        l_flow_schedule_rec.request_id := p_old_flow_schedule_rec.request_id;
    END IF;

    IF l_flow_schedule_rec.resource_account = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.resource_account :=   NULL ;
    ELSIF l_flow_schedule_rec.resource_account IS NULL THEN
        l_flow_schedule_rec.resource_account := p_old_flow_schedule_rec.resource_account;
    END IF;

    IF l_flow_schedule_rec.resource_variance_account = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.resource_variance_account :=  NULL ;
    ELSIF l_flow_schedule_rec.resource_variance_account IS NULL THEN
        l_flow_schedule_rec.resource_variance_account := p_old_flow_schedule_rec.resource_variance_account;
    END IF;

    IF l_flow_schedule_rec.routing_revision = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.routing_revision :=   NULL ;
    ELSIF l_flow_schedule_rec.routing_revision IS NULL THEN
        l_flow_schedule_rec.routing_revision := p_old_flow_schedule_rec.routing_revision;
    END IF;

    IF l_flow_schedule_rec.routing_revision_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.routing_revision_date :=   NULL ;
    ELSIF l_flow_schedule_rec.routing_revision_date IS NULL THEN
        l_flow_schedule_rec.routing_revision_date := p_old_flow_schedule_rec.routing_revision_date;
    END IF;

    IF l_flow_schedule_rec.scheduled_completion_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.scheduled_completion_date :=   NULL ;
    ELSIF l_flow_schedule_rec.scheduled_completion_date IS NULL THEN
        l_flow_schedule_rec.scheduled_completion_date := p_old_flow_schedule_rec.scheduled_completion_date;
    END IF;

    IF l_flow_schedule_rec.scheduled_flag = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.scheduled_flag :=   NULL ;
    ELSIF l_flow_schedule_rec.scheduled_flag IS NULL THEN
        l_flow_schedule_rec.scheduled_flag := p_old_flow_schedule_rec.scheduled_flag;
    END IF;

    IF l_flow_schedule_rec.scheduled_start_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.scheduled_start_date :=   NULL ;
    ELSIF l_flow_schedule_rec.scheduled_start_date IS NULL THEN
        l_flow_schedule_rec.scheduled_start_date := p_old_flow_schedule_rec.scheduled_start_date;
    END IF;

    IF l_flow_schedule_rec.schedule_group_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.schedule_group_id :=   NULL ;
    ELSIF l_flow_schedule_rec.schedule_group_id IS NULL THEN
        l_flow_schedule_rec.schedule_group_id := p_old_flow_schedule_rec.schedule_group_id;
    END IF;

    IF l_flow_schedule_rec.schedule_number = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.schedule_number :=   NULL ;
    ELSIF l_flow_schedule_rec.schedule_number IS NULL THEN
        l_flow_schedule_rec.schedule_number := p_old_flow_schedule_rec.schedule_number;
    END IF;

    IF l_flow_schedule_rec.status = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.status :=   NULL ;
    ELSIF l_flow_schedule_rec.status IS NULL THEN
        l_flow_schedule_rec.status := p_old_flow_schedule_rec.status;
    END IF;

    IF l_flow_schedule_rec.std_cost_adjustment_acct = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.std_cost_adjustment_acct :=   NULL ;
    ELSIF l_flow_schedule_rec.std_cost_adjustment_acct IS NULL THEN
        l_flow_schedule_rec.std_cost_adjustment_acct := p_old_flow_schedule_rec.std_cost_adjustment_acct;
    END IF;

    IF l_flow_schedule_rec.task_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.task_id :=   NULL ;
    ELSIF l_flow_schedule_rec.task_id IS NULL THEN
        l_flow_schedule_rec.task_id := p_old_flow_schedule_rec.task_id;
    END IF;

    IF l_flow_schedule_rec.wip_entity_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.wip_entity_id :=   NULL ;
    ELSIF l_flow_schedule_rec.wip_entity_id IS NULL THEN
        l_flow_schedule_rec.wip_entity_id := p_old_flow_schedule_rec.wip_entity_id;
    END IF;

    IF l_flow_schedule_rec.end_item_unit_number = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.end_item_unit_number :=   NULL ;
    ELSIF l_flow_schedule_rec.end_item_unit_number IS NULL THEN
        l_flow_schedule_rec.end_item_unit_number := p_old_flow_schedule_rec.end_item_unit_number;
    END IF;


    IF l_flow_schedule_rec.quantity_scrapped = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.quantity_scrapped :=   NULL ;
    ELSIF l_flow_schedule_rec.quantity_scrapped IS NULL THEN
        l_flow_schedule_rec.quantity_scrapped := p_old_flow_schedule_rec.quantity_scrapped;
    END IF;

    RETURN l_flow_schedule_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
) RETURN MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
IS
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type:= p_flow_schedule_rec;
BEGIN

    IF l_flow_schedule_rec.alternate_bom_designator = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.alternate_bom_designator := NULL;
    END IF;

    IF l_flow_schedule_rec.alternate_routing_desig = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.alternate_routing_desig := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute1 := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute10 := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute11 := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute12 := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute13 := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute14 := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute15 := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute2 := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute3 := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute4 := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute5 := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute6 := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute7 := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute8 := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute9 := NULL;
    END IF;

    IF l_flow_schedule_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.attribute_category := NULL;
    END IF;

    IF l_flow_schedule_rec.bom_revision = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.bom_revision := NULL;
    END IF;

    IF l_flow_schedule_rec.bom_revision_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.bom_revision_date := NULL;
    END IF;

    IF l_flow_schedule_rec.build_sequence = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.build_sequence := NULL;
    END IF;

    IF l_flow_schedule_rec.class_code = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.class_code := NULL;
    END IF;

    IF l_flow_schedule_rec.completion_locator_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.completion_locator_id := NULL;
    END IF;

    IF l_flow_schedule_rec.completion_subinventory = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.completion_subinventory := NULL;
    END IF;

    IF l_flow_schedule_rec.created_by = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.created_by := NULL;
    END IF;

    IF l_flow_schedule_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.creation_date := NULL;
    END IF;

    IF l_flow_schedule_rec.date_closed = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.date_closed := NULL;
    END IF;

    IF l_flow_schedule_rec.demand_class = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.demand_class := NULL;
    END IF;

    IF l_flow_schedule_rec.demand_source_delivery = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.demand_source_delivery := NULL;
    END IF;

    IF l_flow_schedule_rec.demand_source_header_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.demand_source_header_id := NULL;
    END IF;

    IF l_flow_schedule_rec.demand_source_line = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.demand_source_line := NULL;
    END IF;

    IF l_flow_schedule_rec.demand_source_type = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.demand_source_type := NULL;
    END IF;

    IF l_flow_schedule_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.last_updated_by := NULL;
    END IF;

    IF l_flow_schedule_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.last_update_date := NULL;
    END IF;

    IF l_flow_schedule_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.last_update_login := NULL;
    END IF;

    IF l_flow_schedule_rec.line_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.line_id := NULL;
    END IF;

    IF l_flow_schedule_rec.material_account = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.material_account := NULL;
    END IF;

    IF l_flow_schedule_rec.material_overhead_account = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.material_overhead_account := NULL;
    END IF;

    IF l_flow_schedule_rec.material_variance_account = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.material_variance_account := NULL;
    END IF;

    IF l_flow_schedule_rec.mps_net_quantity = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.mps_net_quantity := NULL;
    END IF;

    IF l_flow_schedule_rec.mps_scheduled_comp_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.mps_scheduled_comp_date := NULL;
    END IF;

    IF l_flow_schedule_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.organization_id := NULL;
    END IF;

    IF l_flow_schedule_rec.outside_processing_acct = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.outside_processing_acct := NULL;
    END IF;

    IF l_flow_schedule_rec.outside_proc_var_acct = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.outside_proc_var_acct := NULL;
    END IF;

    IF l_flow_schedule_rec.overhead_account = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.overhead_account := NULL;
    END IF;

    IF l_flow_schedule_rec.overhead_variance_account = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.overhead_variance_account := NULL;
    END IF;

    IF l_flow_schedule_rec.planned_quantity = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.planned_quantity := NULL;
    END IF;

    IF l_flow_schedule_rec.primary_item_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.primary_item_id := NULL;
    END IF;

    IF l_flow_schedule_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.program_application_id := NULL;
    END IF;

    IF l_flow_schedule_rec.program_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.program_id := NULL;
    END IF;

    IF l_flow_schedule_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.program_update_date := NULL;
    END IF;

    IF l_flow_schedule_rec.project_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.project_id := NULL;
    END IF;

    IF l_flow_schedule_rec.quantity_completed = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.quantity_completed := NULL;
    END IF;

    IF l_flow_schedule_rec.request_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.request_id := NULL;
    END IF;

    IF l_flow_schedule_rec.resource_account = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.resource_account := NULL;
    END IF;

    IF l_flow_schedule_rec.resource_variance_account = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.resource_variance_account := NULL;
    END IF;

    IF l_flow_schedule_rec.routing_revision = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.routing_revision := NULL;
    END IF;

    IF l_flow_schedule_rec.routing_revision_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.routing_revision_date := NULL;
    END IF;

    IF l_flow_schedule_rec.scheduled_completion_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.scheduled_completion_date := NULL;
    END IF;

    IF l_flow_schedule_rec.scheduled_flag = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.scheduled_flag := NULL;
    END IF;

    IF l_flow_schedule_rec.scheduled_start_date = FND_API.G_MISS_DATE THEN
        l_flow_schedule_rec.scheduled_start_date := NULL;
    END IF;

    IF l_flow_schedule_rec.schedule_group_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.schedule_group_id := NULL;
    END IF;

    IF l_flow_schedule_rec.schedule_number = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.schedule_number := NULL;
    END IF;

    IF l_flow_schedule_rec.status = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.status := NULL;
    END IF;

    IF l_flow_schedule_rec.std_cost_adjustment_acct = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.std_cost_adjustment_acct := NULL;
    END IF;

    IF l_flow_schedule_rec.task_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.task_id := NULL;
    END IF;

    IF l_flow_schedule_rec.wip_entity_id = FND_API.G_MISS_NUM THEN
        l_flow_schedule_rec.wip_entity_id := NULL;
    END IF;

    IF l_flow_schedule_rec.end_item_unit_number = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.end_item_unit_number := NULL;
    END IF;

    IF l_flow_schedule_rec.quantity_scrapped = FND_API.G_MISS_NUM THEN
       l_flow_schedule_rec.quantity_scrapped := NULL;
    END IF;

    IF l_flow_schedule_rec.kanban_card_id = FND_API.G_MISS_NUM THEN
       l_flow_schedule_rec.kanban_card_id := NULL;
    END IF;

    IF l_flow_schedule_rec.synch_schedule_num = FND_API.G_MISS_CHAR THEN
        l_flow_schedule_rec.synch_schedule_num := NULL;
    END IF;

    IF l_flow_schedule_rec.synch_operation_seq_num = FND_API.G_MISS_NUM THEN
       l_flow_schedule_rec.synch_operation_seq_num := NULL;
    END IF;

    IF l_flow_schedule_rec.roll_forwarded_flag = FND_API.G_MISS_NUM THEN
       l_flow_schedule_rec.roll_forwarded_flag := NULL;
    END IF;

    IF l_flow_schedule_rec.current_line_operation = FND_API.G_MISS_NUM THEN
       l_flow_schedule_rec.current_line_operation := NULL;
    END IF;

    RETURN l_flow_schedule_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
)
IS
    --bug 3906891: also changed the p_flow_schedules_rec.XXX to l_flow_schedule_rec.XXX
    --in the UPDATE statement below
    l_flow_schedule_rec MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type := Convert_Miss_To_Null (p_flow_schedule_rec);
BEGIN

    UPDATE  WIP_FLOW_SCHEDULES
    SET     ALTERNATE_BOM_DESIGNATOR       = l_flow_schedule_rec.alternate_bom_designator
    ,       ALTERNATE_ROUTING_DESIGNATOR   = l_flow_schedule_rec.alternate_routing_desig
    ,       ATTRIBUTE1                     = l_flow_schedule_rec.attribute1
    ,       ATTRIBUTE10                    = l_flow_schedule_rec.attribute10
    ,       ATTRIBUTE11                    = l_flow_schedule_rec.attribute11
    ,       ATTRIBUTE12                    = l_flow_schedule_rec.attribute12
    ,       ATTRIBUTE13                    = l_flow_schedule_rec.attribute13
    ,       ATTRIBUTE14                    = l_flow_schedule_rec.attribute14
    ,       ATTRIBUTE15                    = l_flow_schedule_rec.attribute15
    ,       ATTRIBUTE2                     = l_flow_schedule_rec.attribute2
    ,       ATTRIBUTE3                     = l_flow_schedule_rec.attribute3
    ,       ATTRIBUTE4                     = l_flow_schedule_rec.attribute4
    ,       ATTRIBUTE5                     = l_flow_schedule_rec.attribute5
    ,       ATTRIBUTE6                     = l_flow_schedule_rec.attribute6
    ,       ATTRIBUTE7                     = l_flow_schedule_rec.attribute7
    ,       ATTRIBUTE8                     = l_flow_schedule_rec.attribute8
    ,       ATTRIBUTE9                     = l_flow_schedule_rec.attribute9
    ,       ATTRIBUTE_CATEGORY             = l_flow_schedule_rec.attribute_category
    ,       BOM_REVISION                   = l_flow_schedule_rec.bom_revision
    ,       BOM_REVISION_DATE              = l_flow_schedule_rec.bom_revision_date
    ,       BUILD_SEQUENCE                 = l_flow_schedule_rec.build_sequence
    ,       CLASS_CODE                     = l_flow_schedule_rec.class_code
    ,       COMPLETION_LOCATOR_ID          = l_flow_schedule_rec.completion_locator_id
    ,       COMPLETION_SUBINVENTORY        = l_flow_schedule_rec.completion_subinventory
    ,       CREATED_BY                     = l_flow_schedule_rec.created_by
    ,       CREATION_DATE                  = l_flow_schedule_rec.creation_date
    ,       DATE_CLOSED                    = l_flow_schedule_rec.date_closed
    ,       DEMAND_CLASS                   = l_flow_schedule_rec.demand_class
    ,       DEMAND_SOURCE_DELIVERY         = l_flow_schedule_rec.demand_source_delivery
    ,       DEMAND_SOURCE_HEADER_ID        = l_flow_schedule_rec.demand_source_header_id
    ,       DEMAND_SOURCE_LINE             = l_flow_schedule_rec.demand_source_line
    ,       DEMAND_SOURCE_TYPE             = l_flow_schedule_rec.demand_source_type
    ,       LAST_UPDATED_BY                = l_flow_schedule_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = l_flow_schedule_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = l_flow_schedule_rec.last_update_login
    ,       LINE_ID                        = l_flow_schedule_rec.line_id
    ,       MATERIAL_ACCOUNT               = l_flow_schedule_rec.material_account
    ,       MATERIAL_OVERHEAD_ACCOUNT      = l_flow_schedule_rec.material_overhead_account
    ,       MATERIAL_VARIANCE_ACCOUNT      = l_flow_schedule_rec.material_variance_account
    ,       MPS_NET_QUANTITY               = l_flow_schedule_rec.mps_net_quantity
    ,       MPS_SCHEDULED_COMPLETION_DATE  = l_flow_schedule_rec.mps_scheduled_comp_date
    ,       ORGANIZATION_ID                = l_flow_schedule_rec.organization_id
    ,       OUTSIDE_PROCESSING_ACCOUNT     = l_flow_schedule_rec.outside_processing_acct
    ,       OUTSIDE_PROC_VARIANCE_ACCOUNT  = l_flow_schedule_rec.outside_proc_var_acct
    ,       OVERHEAD_ACCOUNT               = l_flow_schedule_rec.overhead_account
    ,       OVERHEAD_VARIANCE_ACCOUNT      = l_flow_schedule_rec.overhead_variance_account
    ,       PLANNED_QUANTITY               = l_flow_schedule_rec.planned_quantity
    ,       PRIMARY_ITEM_ID                = l_flow_schedule_rec.primary_item_id
    ,       PROGRAM_APPLICATION_ID         = l_flow_schedule_rec.program_application_id
    ,       PROGRAM_ID                     = l_flow_schedule_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = l_flow_schedule_rec.program_update_date
    ,       PROJECT_ID                     = l_flow_schedule_rec.project_id
    ,       QUANTITY_COMPLETED             = l_flow_schedule_rec.quantity_completed
    ,       REQUEST_ID                     = l_flow_schedule_rec.request_id
    ,       RESOURCE_ACCOUNT               = l_flow_schedule_rec.resource_account
    ,       RESOURCE_VARIANCE_ACCOUNT      = l_flow_schedule_rec.resource_variance_account
    ,       ROUTING_REVISION               = l_flow_schedule_rec.routing_revision
    ,       ROUTING_REVISION_DATE          = l_flow_schedule_rec.routing_revision_date
    ,       SCHEDULED_COMPLETION_DATE      = l_flow_schedule_rec.scheduled_completion_date
    ,       SCHEDULED_FLAG                 = l_flow_schedule_rec.scheduled_flag
    ,       SCHEDULED_START_DATE           = l_flow_schedule_rec.scheduled_start_date
    ,       SCHEDULE_GROUP_ID              = l_flow_schedule_rec.schedule_group_id
    ,       SCHEDULE_NUMBER                = l_flow_schedule_rec.schedule_number
    ,       STATUS                         = l_flow_schedule_rec.status
    ,       STD_COST_ADJUSTMENT_ACCOUNT    = l_flow_schedule_rec.std_cost_adjustment_acct
    ,       TASK_ID                        = l_flow_schedule_rec.task_id
    ,       END_ITEM_UNIT_NUMBER           = l_flow_schedule_rec.end_item_unit_number
    ,       QUANTITY_SCRAPPED              = l_flow_schedule_rec.quantity_scrapped
    ,       WIP_ENTITY_ID                  = l_flow_schedule_rec.wip_entity_id
    ,       SO_CONSUMED_PLAN_ID            = l_flow_schedule_rec.so_consumed_plan_id /*Added for bugfix:8200872 */
    WHERE   ORGANIZATION_ID = l_flow_schedule_rec.organization_id
    AND     WIP_ENTITY_ID = l_flow_schedule_rec.wip_entity_id
    ;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
)
IS
    --bug 3906891: also changed the p_flow_schedules_rec.XXX to l_flow_schedule_rec.XXX
    --in the INSERT statement below
    l_flow_schedule_rec MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type := Convert_Miss_To_Null (p_flow_schedule_rec);
BEGIN

    INSERT  INTO WIP_FLOW_SCHEDULES
    (       ALTERNATE_BOM_DESIGNATOR
    ,       ALTERNATE_ROUTING_DESIGNATOR
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE_CATEGORY
    ,       BOM_REVISION
    ,       BOM_REVISION_DATE
    ,       BUILD_SEQUENCE
    ,       CLASS_CODE
    ,       COMPLETION_LOCATOR_ID
    ,       COMPLETION_SUBINVENTORY
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DATE_CLOSED
    ,       DEMAND_CLASS
    ,       DEMAND_SOURCE_DELIVERY
    ,       DEMAND_SOURCE_HEADER_ID
    ,       DEMAND_SOURCE_LINE
    ,       DEMAND_SOURCE_TYPE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       MATERIAL_ACCOUNT
    ,       MATERIAL_OVERHEAD_ACCOUNT
    ,       MATERIAL_VARIANCE_ACCOUNT
    ,       MPS_NET_QUANTITY
    ,       MPS_SCHEDULED_COMPLETION_DATE
    ,       ORGANIZATION_ID
    ,       OUTSIDE_PROCESSING_ACCOUNT
    ,       OUTSIDE_PROC_VARIANCE_ACCOUNT
    ,       OVERHEAD_ACCOUNT
    ,       OVERHEAD_VARIANCE_ACCOUNT
    ,       PLANNED_QUANTITY
    ,       PRIMARY_ITEM_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PROJECT_ID
    ,       QUANTITY_COMPLETED
    ,       REQUEST_ID
    ,       RESOURCE_ACCOUNT
    ,       RESOURCE_VARIANCE_ACCOUNT
    ,       ROUTING_REVISION
    ,       ROUTING_REVISION_DATE
    ,       SCHEDULED_COMPLETION_DATE
    ,       SCHEDULED_FLAG
    ,       SCHEDULED_START_DATE
    ,       SCHEDULE_GROUP_ID
    ,       SCHEDULE_NUMBER
    ,       STATUS
    ,       STD_COST_ADJUSTMENT_ACCOUNT
    ,       TASK_ID
    ,       END_ITEM_UNIT_NUMBER
    ,       QUANTITY_SCRAPPED
    ,       WIP_ENTITY_ID
    ,	    KANBAN_CARD_ID
    ,	    SYNCH_SCHEDULE_NUM
    ,	    SYNCH_OPERATION_SEQ_NUM
    ,       ROLL_FORWARDED_FLAG
    ,       CURRENT_LINE_OPERATION
    )
    VALUES
    (       l_flow_schedule_rec.alternate_bom_designator
    ,       l_flow_schedule_rec.alternate_routing_desig
    ,       l_flow_schedule_rec.attribute1
    ,       l_flow_schedule_rec.attribute10
    ,       l_flow_schedule_rec.attribute11
    ,       l_flow_schedule_rec.attribute12
    ,       l_flow_schedule_rec.attribute13
    ,       l_flow_schedule_rec.attribute14
    ,       l_flow_schedule_rec.attribute15
    ,       l_flow_schedule_rec.attribute2
    ,       l_flow_schedule_rec.attribute3
    ,       l_flow_schedule_rec.attribute4
    ,       l_flow_schedule_rec.attribute5
    ,       l_flow_schedule_rec.attribute6
    ,       l_flow_schedule_rec.attribute7
    ,       l_flow_schedule_rec.attribute8
    ,       l_flow_schedule_rec.attribute9
    ,       l_flow_schedule_rec.attribute_category
    ,       l_flow_schedule_rec.bom_revision
    ,       l_flow_schedule_rec.bom_revision_date
    ,       l_flow_schedule_rec.build_sequence
    ,       l_flow_schedule_rec.class_code
    ,       l_flow_schedule_rec.completion_locator_id
    ,       l_flow_schedule_rec.completion_subinventory
    ,       l_flow_schedule_rec.created_by
    ,       l_flow_schedule_rec.creation_date
    ,       l_flow_schedule_rec.date_closed
    ,       l_flow_schedule_rec.demand_class
    ,       l_flow_schedule_rec.demand_source_delivery
    ,       l_flow_schedule_rec.demand_source_header_id
    ,       l_flow_schedule_rec.demand_source_line
    ,       l_flow_schedule_rec.demand_source_type
    ,       l_flow_schedule_rec.last_updated_by
    ,       l_flow_schedule_rec.last_update_date
    ,       l_flow_schedule_rec.last_update_login
    ,       l_flow_schedule_rec.line_id
    ,       l_flow_schedule_rec.material_account
    ,       l_flow_schedule_rec.material_overhead_account
    ,       l_flow_schedule_rec.material_variance_account
    ,       l_flow_schedule_rec.mps_net_quantity
    ,       l_flow_schedule_rec.mps_scheduled_comp_date
    ,       l_flow_schedule_rec.organization_id
    ,       l_flow_schedule_rec.outside_processing_acct
    ,       l_flow_schedule_rec.outside_proc_var_acct
    ,       l_flow_schedule_rec.overhead_account
    ,       l_flow_schedule_rec.overhead_variance_account
    ,       l_flow_schedule_rec.planned_quantity
    ,       l_flow_schedule_rec.primary_item_id
    ,       l_flow_schedule_rec.program_application_id
    ,       l_flow_schedule_rec.program_id
    ,       l_flow_schedule_rec.program_update_date
    ,       l_flow_schedule_rec.project_id
    ,       l_flow_schedule_rec.quantity_completed
    ,       l_flow_schedule_rec.request_id
    ,       l_flow_schedule_rec.resource_account
    ,       l_flow_schedule_rec.resource_variance_account
    ,       l_flow_schedule_rec.routing_revision
    ,       l_flow_schedule_rec.routing_revision_date
    ,       l_flow_schedule_rec.scheduled_completion_date
    ,       l_flow_schedule_rec.scheduled_flag
    ,       l_flow_schedule_rec.scheduled_start_date
    ,       l_flow_schedule_rec.schedule_group_id
    ,       l_flow_schedule_rec.schedule_number
    ,       l_flow_schedule_rec.status
    ,       l_flow_schedule_rec.std_cost_adjustment_acct
    ,       l_flow_schedule_rec.task_id
    ,       l_flow_schedule_rec.end_item_unit_number
    ,       l_flow_schedule_rec.quantity_scrapped
    ,       l_flow_schedule_rec.wip_entity_id
    ,       l_flow_schedule_rec.kanban_card_id
    ,       l_flow_schedule_rec.synch_schedule_num
    ,       l_flow_schedule_rec.synch_operation_seq_num
    ,       l_flow_schedule_rec.roll_forwarded_flag
    ,       l_flow_schedule_rec.current_line_operation
    );

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_wip_entity_id                 IN  NUMBER
)
IS
BEGIN

    DELETE  FROM WIP_FLOW_SCHEDULES
    WHERE   WIP_ENTITY_ID = p_wip_entity_id
    ;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_wip_entity_id                 IN  NUMBER
) RETURN MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
IS
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
BEGIN

    SELECT  ALTERNATE_BOM_DESIGNATOR
    ,       ALTERNATE_ROUTING_DESIGNATOR
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE_CATEGORY
    ,       BOM_REVISION
    ,       BOM_REVISION_DATE
    ,       BUILD_SEQUENCE
    ,       CLASS_CODE
    ,       COMPLETION_LOCATOR_ID
    ,       COMPLETION_SUBINVENTORY
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DATE_CLOSED
    ,       DEMAND_CLASS
    ,       DEMAND_SOURCE_DELIVERY
    ,       DEMAND_SOURCE_HEADER_ID
    ,       DEMAND_SOURCE_LINE
    ,       DEMAND_SOURCE_TYPE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       MATERIAL_ACCOUNT
    ,       MATERIAL_OVERHEAD_ACCOUNT
    ,       MATERIAL_VARIANCE_ACCOUNT
    ,       MPS_NET_QUANTITY
    ,       MPS_SCHEDULED_COMPLETION_DATE
    ,       ORGANIZATION_ID
    ,       OUTSIDE_PROCESSING_ACCOUNT
    ,       OUTSIDE_PROC_VARIANCE_ACCOUNT
    ,       OVERHEAD_ACCOUNT
    ,       OVERHEAD_VARIANCE_ACCOUNT
    ,       PLANNED_QUANTITY
    ,       PRIMARY_ITEM_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PROJECT_ID
    ,       QUANTITY_COMPLETED
    ,       REQUEST_ID
    ,       RESOURCE_ACCOUNT
    ,       RESOURCE_VARIANCE_ACCOUNT
    ,       ROUTING_REVISION
    ,       ROUTING_REVISION_DATE
    ,       SCHEDULED_COMPLETION_DATE
    ,       SCHEDULED_FLAG
    ,       SCHEDULED_START_DATE
    ,       SCHEDULE_GROUP_ID
    ,       SCHEDULE_NUMBER
    ,       STATUS
    ,       STD_COST_ADJUSTMENT_ACCOUNT
    ,       TASK_ID
    ,       WIP_ENTITY_ID
    ,       END_ITEM_UNIT_NUMBER
    ,       QUANTITY_SCRAPPED
    INTO    l_flow_schedule_rec.alternate_bom_designator
    ,       l_flow_schedule_rec.alternate_routing_desig
    ,       l_flow_schedule_rec.attribute1
    ,       l_flow_schedule_rec.attribute10
    ,       l_flow_schedule_rec.attribute11
    ,       l_flow_schedule_rec.attribute12
    ,       l_flow_schedule_rec.attribute13
    ,       l_flow_schedule_rec.attribute14
    ,       l_flow_schedule_rec.attribute15
    ,       l_flow_schedule_rec.attribute2
    ,       l_flow_schedule_rec.attribute3
    ,       l_flow_schedule_rec.attribute4
    ,       l_flow_schedule_rec.attribute5
    ,       l_flow_schedule_rec.attribute6
    ,       l_flow_schedule_rec.attribute7
    ,       l_flow_schedule_rec.attribute8
    ,       l_flow_schedule_rec.attribute9
    ,       l_flow_schedule_rec.attribute_category
    ,       l_flow_schedule_rec.bom_revision
    ,       l_flow_schedule_rec.bom_revision_date
    ,       l_flow_schedule_rec.build_sequence
    ,       l_flow_schedule_rec.class_code
    ,       l_flow_schedule_rec.completion_locator_id
    ,       l_flow_schedule_rec.completion_subinventory
    ,       l_flow_schedule_rec.created_by
    ,       l_flow_schedule_rec.creation_date
    ,       l_flow_schedule_rec.date_closed
    ,       l_flow_schedule_rec.demand_class
    ,       l_flow_schedule_rec.demand_source_delivery
    ,       l_flow_schedule_rec.demand_source_header_id
    ,       l_flow_schedule_rec.demand_source_line
    ,       l_flow_schedule_rec.demand_source_type
    ,       l_flow_schedule_rec.last_updated_by
    ,       l_flow_schedule_rec.last_update_date
    ,       l_flow_schedule_rec.last_update_login
    ,       l_flow_schedule_rec.line_id
    ,       l_flow_schedule_rec.material_account
    ,       l_flow_schedule_rec.material_overhead_account
    ,       l_flow_schedule_rec.material_variance_account
    ,       l_flow_schedule_rec.mps_net_quantity
    ,       l_flow_schedule_rec.mps_scheduled_comp_date
    ,       l_flow_schedule_rec.organization_id
    ,       l_flow_schedule_rec.outside_processing_acct
    ,       l_flow_schedule_rec.outside_proc_var_acct
    ,       l_flow_schedule_rec.overhead_account
    ,       l_flow_schedule_rec.overhead_variance_account
    ,       l_flow_schedule_rec.planned_quantity
    ,       l_flow_schedule_rec.primary_item_id
    ,       l_flow_schedule_rec.program_application_id
    ,       l_flow_schedule_rec.program_id
    ,       l_flow_schedule_rec.program_update_date
    ,       l_flow_schedule_rec.project_id
    ,       l_flow_schedule_rec.quantity_completed
    ,       l_flow_schedule_rec.request_id
    ,       l_flow_schedule_rec.resource_account
    ,       l_flow_schedule_rec.resource_variance_account
    ,       l_flow_schedule_rec.routing_revision
    ,       l_flow_schedule_rec.routing_revision_date
    ,       l_flow_schedule_rec.scheduled_completion_date
    ,       l_flow_schedule_rec.scheduled_flag
    ,       l_flow_schedule_rec.scheduled_start_date
    ,       l_flow_schedule_rec.schedule_group_id
    ,       l_flow_schedule_rec.schedule_number
    ,       l_flow_schedule_rec.status
    ,       l_flow_schedule_rec.std_cost_adjustment_acct
    ,       l_flow_schedule_rec.task_id
    ,       l_flow_schedule_rec.wip_entity_id
    ,       l_flow_schedule_rec.end_item_unit_number
    ,       l_flow_schedule_rec.quantity_scrapped
    FROM    WIP_FLOW_SCHEDULES
    WHERE   WIP_ENTITY_ID = p_wip_entity_id
    ;

    RETURN l_flow_schedule_rec;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Row;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   x_flow_schedule_rec             IN  OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
)
IS
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
temp		VARCHAR2(240);
BEGIN

    SELECT  ALTERNATE_BOM_DESIGNATOR
    ,       ALTERNATE_ROUTING_DESIGNATOR
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE_CATEGORY
    ,       BOM_REVISION
    ,       BOM_REVISION_DATE
    ,       BUILD_SEQUENCE
    ,       CLASS_CODE
    ,       COMPLETION_LOCATOR_ID
    ,       COMPLETION_SUBINVENTORY
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DATE_CLOSED
    ,       DEMAND_CLASS
    ,       DEMAND_SOURCE_DELIVERY
    ,       DEMAND_SOURCE_HEADER_ID
    ,       DEMAND_SOURCE_LINE
    ,       DEMAND_SOURCE_TYPE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       MATERIAL_ACCOUNT
    ,       MATERIAL_OVERHEAD_ACCOUNT
    ,       MATERIAL_VARIANCE_ACCOUNT
    ,       MPS_NET_QUANTITY
    ,       MPS_SCHEDULED_COMPLETION_DATE
    ,       ORGANIZATION_ID
    ,       OUTSIDE_PROCESSING_ACCOUNT
    ,       OUTSIDE_PROC_VARIANCE_ACCOUNT
    ,       OVERHEAD_ACCOUNT
    ,       OVERHEAD_VARIANCE_ACCOUNT
    ,       PLANNED_QUANTITY
    ,       PRIMARY_ITEM_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PROJECT_ID
    ,       QUANTITY_COMPLETED
    ,       REQUEST_ID
    ,       RESOURCE_ACCOUNT
    ,       RESOURCE_VARIANCE_ACCOUNT
    ,       ROUTING_REVISION
    ,       ROUTING_REVISION_DATE
    ,       SCHEDULED_COMPLETION_DATE
    ,       SCHEDULED_FLAG
    ,       SCHEDULED_START_DATE
    ,       SCHEDULE_GROUP_ID
    ,       SCHEDULE_NUMBER
    ,       STATUS
    ,       STD_COST_ADJUSTMENT_ACCOUNT
    ,       TASK_ID
    ,       WIP_ENTITY_ID
    ,       END_ITEM_UNIT_NUMBER
    ,       QUANTITY_SCRAPPED
    INTO    l_flow_schedule_rec.alternate_bom_designator
    ,       l_flow_schedule_rec.alternate_routing_desig
    ,       l_flow_schedule_rec.attribute1
    ,       l_flow_schedule_rec.attribute10
    ,       l_flow_schedule_rec.attribute11
    ,       l_flow_schedule_rec.attribute12
    ,       l_flow_schedule_rec.attribute13
    ,       l_flow_schedule_rec.attribute14
    ,       l_flow_schedule_rec.attribute15
    ,       l_flow_schedule_rec.attribute2
    ,       l_flow_schedule_rec.attribute3
    ,       l_flow_schedule_rec.attribute4
    ,       l_flow_schedule_rec.attribute5
    ,       l_flow_schedule_rec.attribute6
    ,       l_flow_schedule_rec.attribute7
    ,       l_flow_schedule_rec.attribute8
    ,       l_flow_schedule_rec.attribute9
    ,       l_flow_schedule_rec.attribute_category
    ,       l_flow_schedule_rec.bom_revision
    ,       l_flow_schedule_rec.bom_revision_date
    ,       l_flow_schedule_rec.build_sequence
    ,       l_flow_schedule_rec.class_code
    ,       l_flow_schedule_rec.completion_locator_id
    ,       l_flow_schedule_rec.completion_subinventory
    ,       l_flow_schedule_rec.created_by
    ,       l_flow_schedule_rec.creation_date
    ,       l_flow_schedule_rec.date_closed
    ,       l_flow_schedule_rec.demand_class
    ,       l_flow_schedule_rec.demand_source_delivery
    ,       l_flow_schedule_rec.demand_source_header_id
    ,       l_flow_schedule_rec.demand_source_line
    ,       l_flow_schedule_rec.demand_source_type
    ,       l_flow_schedule_rec.last_updated_by
    ,       l_flow_schedule_rec.last_update_date
    ,       l_flow_schedule_rec.last_update_login
    ,       l_flow_schedule_rec.line_id
    ,       l_flow_schedule_rec.material_account
    ,       l_flow_schedule_rec.material_overhead_account
    ,       l_flow_schedule_rec.material_variance_account
    ,       l_flow_schedule_rec.mps_net_quantity
    ,       l_flow_schedule_rec.mps_scheduled_comp_date
    ,       l_flow_schedule_rec.organization_id
    ,       l_flow_schedule_rec.outside_processing_acct
    ,       l_flow_schedule_rec.outside_proc_var_acct
    ,       l_flow_schedule_rec.overhead_account
    ,       l_flow_schedule_rec.overhead_variance_account
    ,       l_flow_schedule_rec.planned_quantity
    ,       l_flow_schedule_rec.primary_item_id
    ,       l_flow_schedule_rec.program_application_id
    ,       l_flow_schedule_rec.program_id
    ,       l_flow_schedule_rec.program_update_date
    ,       l_flow_schedule_rec.project_id
    ,       l_flow_schedule_rec.quantity_completed
    ,       l_flow_schedule_rec.request_id
    ,       l_flow_schedule_rec.resource_account
    ,       l_flow_schedule_rec.resource_variance_account
    ,       l_flow_schedule_rec.routing_revision
    ,       l_flow_schedule_rec.routing_revision_date
    ,       l_flow_schedule_rec.scheduled_completion_date
    ,       l_flow_schedule_rec.scheduled_flag
    ,       l_flow_schedule_rec.scheduled_start_date
    ,       l_flow_schedule_rec.schedule_group_id
    ,       l_flow_schedule_rec.schedule_number
    ,       l_flow_schedule_rec.status
    ,       l_flow_schedule_rec.std_cost_adjustment_acct
    ,       l_flow_schedule_rec.task_id
    ,       l_flow_schedule_rec.wip_entity_id
    ,       l_flow_schedule_rec.end_item_unit_number
    ,       l_flow_schedule_rec.quantity_scrapped
    FROM    WIP_FLOW_SCHEDULES
    WHERE   WIP_ENTITY_ID = p_flow_schedule_rec.wip_entity_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  (   (l_flow_schedule_rec.alternate_bom_designator =
             p_flow_schedule_rec.alternate_bom_designator) OR
            ((p_flow_schedule_rec.alternate_bom_designator = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.alternate_bom_designator IS NULL) AND
                (p_flow_schedule_rec.alternate_bom_designator IS NULL))))
    AND (   (l_flow_schedule_rec.alternate_routing_desig =
             p_flow_schedule_rec.alternate_routing_desig) OR
            ((p_flow_schedule_rec.alternate_routing_desig = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.alternate_routing_desig IS NULL) AND
                (p_flow_schedule_rec.alternate_routing_desig IS NULL))))
    AND (   (l_flow_schedule_rec.attribute1 =
             p_flow_schedule_rec.attribute1) OR
            ((p_flow_schedule_rec.attribute1 = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute1 IS NULL) AND
                (p_flow_schedule_rec.attribute1 IS NULL))))
    AND (   (l_flow_schedule_rec.attribute10 =
             p_flow_schedule_rec.attribute10) OR
            ((p_flow_schedule_rec.attribute10 = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute10 IS NULL) AND
                (p_flow_schedule_rec.attribute10 IS NULL))))
    AND (   (l_flow_schedule_rec.attribute11 =
             p_flow_schedule_rec.attribute11) OR
            ((p_flow_schedule_rec.attribute11 = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute11 IS NULL) AND
                (p_flow_schedule_rec.attribute11 IS NULL))))
    AND (   (l_flow_schedule_rec.attribute12 =
             p_flow_schedule_rec.attribute12) OR
            ((p_flow_schedule_rec.attribute12 = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute12 IS NULL) AND
                (p_flow_schedule_rec.attribute12 IS NULL))))
    AND (   (l_flow_schedule_rec.attribute13 =
             p_flow_schedule_rec.attribute13) OR
            ((p_flow_schedule_rec.attribute13 = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute13 IS NULL) AND
                (p_flow_schedule_rec.attribute13 IS NULL))))
    AND (   (l_flow_schedule_rec.attribute14 =
             p_flow_schedule_rec.attribute14) OR
            ((p_flow_schedule_rec.attribute14 = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute14 IS NULL) AND
                (p_flow_schedule_rec.attribute14 IS NULL))))
    AND (   (l_flow_schedule_rec.attribute15 =
             p_flow_schedule_rec.attribute15) OR
            ((p_flow_schedule_rec.attribute15 = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute15 IS NULL) AND
                (p_flow_schedule_rec.attribute15 IS NULL))))
    AND (   (l_flow_schedule_rec.attribute2 =
             p_flow_schedule_rec.attribute2) OR
            ((p_flow_schedule_rec.attribute2 = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute2 IS NULL) AND
                (p_flow_schedule_rec.attribute2 IS NULL))))
    AND (   (l_flow_schedule_rec.attribute3 =
             p_flow_schedule_rec.attribute3) OR
            ((p_flow_schedule_rec.attribute3 = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute3 IS NULL) AND
                (p_flow_schedule_rec.attribute3 IS NULL))))
    AND (   (l_flow_schedule_rec.attribute4 =
             p_flow_schedule_rec.attribute4) OR
            ((p_flow_schedule_rec.attribute4 = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute4 IS NULL) AND
                (p_flow_schedule_rec.attribute4 IS NULL))))
    AND (   (l_flow_schedule_rec.attribute5 =
             p_flow_schedule_rec.attribute5) OR
            ((p_flow_schedule_rec.attribute5 = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute5 IS NULL) AND
                (p_flow_schedule_rec.attribute5 IS NULL))))
    AND (   (l_flow_schedule_rec.attribute6 =
             p_flow_schedule_rec.attribute6) OR
            ((p_flow_schedule_rec.attribute6 = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute6 IS NULL) AND
                (p_flow_schedule_rec.attribute6 IS NULL))))
    AND (   (l_flow_schedule_rec.attribute7 =
             p_flow_schedule_rec.attribute7) OR
            ((p_flow_schedule_rec.attribute7 = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute7 IS NULL) AND
                (p_flow_schedule_rec.attribute7 IS NULL))))
    AND (   (l_flow_schedule_rec.attribute8 =
             p_flow_schedule_rec.attribute8) OR
            ((p_flow_schedule_rec.attribute8 = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute8 IS NULL) AND
                (p_flow_schedule_rec.attribute8 IS NULL))))
    AND (   (l_flow_schedule_rec.attribute9 =
             p_flow_schedule_rec.attribute9) OR
            ((p_flow_schedule_rec.attribute9 = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute9 IS NULL) AND
                (p_flow_schedule_rec.attribute9 IS NULL))))
    AND (   (l_flow_schedule_rec.attribute_category =
             p_flow_schedule_rec.attribute_category) OR
            ((p_flow_schedule_rec.attribute_category = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.attribute_category IS NULL) AND
                (p_flow_schedule_rec.attribute_category IS NULL))))
    AND (   (l_flow_schedule_rec.bom_revision =
             p_flow_schedule_rec.bom_revision) OR
            ((p_flow_schedule_rec.bom_revision = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.bom_revision IS NULL) AND
                (p_flow_schedule_rec.bom_revision IS NULL))))
    AND (   (l_flow_schedule_rec.bom_revision_date =
             p_flow_schedule_rec.bom_revision_date) OR
            ((p_flow_schedule_rec.bom_revision_date = FND_API.G_MISS_DATE) OR
            (   (l_flow_schedule_rec.bom_revision_date IS NULL) AND
                (p_flow_schedule_rec.bom_revision_date IS NULL))))
    AND (   (l_flow_schedule_rec.build_sequence =
             p_flow_schedule_rec.build_sequence) OR
            ((p_flow_schedule_rec.build_sequence = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.build_sequence IS NULL) AND
                (p_flow_schedule_rec.build_sequence IS NULL))))
    AND (   (l_flow_schedule_rec.class_code =
             p_flow_schedule_rec.class_code) OR
            ((p_flow_schedule_rec.class_code = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.class_code IS NULL) AND
                (p_flow_schedule_rec.class_code IS NULL))))
    AND (   (l_flow_schedule_rec.completion_locator_id =
             p_flow_schedule_rec.completion_locator_id) OR
            ((p_flow_schedule_rec.completion_locator_id = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.completion_locator_id IS NULL) AND
                (p_flow_schedule_rec.completion_locator_id IS NULL))))
    AND (   (l_flow_schedule_rec.completion_subinventory =
             p_flow_schedule_rec.completion_subinventory) OR
            ((p_flow_schedule_rec.completion_subinventory = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.completion_subinventory IS NULL) AND
                (p_flow_schedule_rec.completion_subinventory IS NULL))))
/*    AND (   (l_flow_schedule_rec.created_by =
             p_flow_schedule_rec.created_by) OR
            ((p_flow_schedule_rec.created_by = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.created_by IS NULL) AND
                (p_flow_schedule_rec.created_by IS NULL))))
    AND (   (l_flow_schedule_rec.creation_date =
             p_flow_schedule_rec.creation_date) OR
            ((p_flow_schedule_rec.creation_date = FND_API.G_MISS_DATE) OR
            (   (l_flow_schedule_rec.creation_date IS NULL) AND
                (p_flow_schedule_rec.creation_date IS NULL)))) */
    AND (   (l_flow_schedule_rec.date_closed =
             p_flow_schedule_rec.date_closed) OR
            ((p_flow_schedule_rec.date_closed = FND_API.G_MISS_DATE) OR
            (   (l_flow_schedule_rec.date_closed IS NULL) AND
                (p_flow_schedule_rec.date_closed IS NULL))))
    AND (   (l_flow_schedule_rec.demand_class =
             p_flow_schedule_rec.demand_class) OR
            ((p_flow_schedule_rec.demand_class = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.demand_class IS NULL) AND
                (p_flow_schedule_rec.demand_class IS NULL))))
    AND (   (l_flow_schedule_rec.demand_source_delivery =
             p_flow_schedule_rec.demand_source_delivery) OR
            ((p_flow_schedule_rec.demand_source_delivery = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.demand_source_delivery IS NULL) AND
                (p_flow_schedule_rec.demand_source_delivery IS NULL))))
    AND (   (l_flow_schedule_rec.demand_source_header_id =
             p_flow_schedule_rec.demand_source_header_id) OR
            ((p_flow_schedule_rec.demand_source_header_id = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.demand_source_header_id IS NULL) AND
                (p_flow_schedule_rec.demand_source_header_id IS NULL))))
    AND (   (l_flow_schedule_rec.demand_source_line =
             p_flow_schedule_rec.demand_source_line) OR
            ((p_flow_schedule_rec.demand_source_line = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.demand_source_line IS NULL) AND
                (p_flow_schedule_rec.demand_source_line IS NULL))))
    AND (   (l_flow_schedule_rec.demand_source_type =
             p_flow_schedule_rec.demand_source_type) OR
            ((p_flow_schedule_rec.demand_source_type = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.demand_source_type IS NULL) AND
                (p_flow_schedule_rec.demand_source_type IS NULL))))
/*    AND (   (l_flow_schedule_rec.last_updated_by =
             p_flow_schedule_rec.last_updated_by) OR
            ((p_flow_schedule_rec.last_updated_by = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.last_updated_by IS NULL) AND
                (p_flow_schedule_rec.last_updated_by IS NULL))))
    AND (   (l_flow_schedule_rec.last_update_date =
             p_flow_schedule_rec.last_update_date) OR
            ((p_flow_schedule_rec.last_update_date = FND_API.G_MISS_DATE) OR
            (   (l_flow_schedule_rec.last_update_date IS NULL) AND
                (p_flow_schedule_rec.last_update_date IS NULL))))
    AND (   (l_flow_schedule_rec.last_update_login =
             p_flow_schedule_rec.last_update_login) OR
            ((p_flow_schedule_rec.last_update_login = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.last_update_login IS NULL) AND
                (p_flow_schedule_rec.last_update_login IS NULL)))) */
    AND (   (l_flow_schedule_rec.line_id =
             p_flow_schedule_rec.line_id) OR
            ((p_flow_schedule_rec.line_id = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.line_id IS NULL) AND
                (p_flow_schedule_rec.line_id IS NULL))))
    AND (   (l_flow_schedule_rec.material_account =
             p_flow_schedule_rec.material_account) OR
            ((p_flow_schedule_rec.material_account = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.material_account IS NULL) AND
                (p_flow_schedule_rec.material_account IS NULL))))
    AND (   (l_flow_schedule_rec.material_overhead_account =
             p_flow_schedule_rec.material_overhead_account) OR
            ((p_flow_schedule_rec.material_overhead_account = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.material_overhead_account IS NULL) AND
                (p_flow_schedule_rec.material_overhead_account IS NULL))))
    AND (   (l_flow_schedule_rec.material_variance_account =
             p_flow_schedule_rec.material_variance_account) OR
            ((p_flow_schedule_rec.material_variance_account = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.material_variance_account IS NULL) AND
                (p_flow_schedule_rec.material_variance_account IS NULL))))
    AND (   (l_flow_schedule_rec.mps_net_quantity =
             p_flow_schedule_rec.mps_net_quantity) OR
            ((p_flow_schedule_rec.mps_net_quantity = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.mps_net_quantity IS NULL) AND
                (p_flow_schedule_rec.mps_net_quantity IS NULL))))
    AND (   (l_flow_schedule_rec.mps_scheduled_comp_date =
             p_flow_schedule_rec.mps_scheduled_comp_date) OR
            ((p_flow_schedule_rec.mps_scheduled_comp_date = FND_API.G_MISS_DATE) OR
            (   (l_flow_schedule_rec.mps_scheduled_comp_date IS NULL) AND
                (p_flow_schedule_rec.mps_scheduled_comp_date IS NULL))))
    AND (   (l_flow_schedule_rec.organization_id =
             p_flow_schedule_rec.organization_id) OR
            ((p_flow_schedule_rec.organization_id = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.organization_id IS NULL) AND
                (p_flow_schedule_rec.organization_id IS NULL))))
    AND (   (l_flow_schedule_rec.outside_processing_acct =
             p_flow_schedule_rec.outside_processing_acct) OR
            ((p_flow_schedule_rec.outside_processing_acct = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.outside_processing_acct IS NULL) AND
                (p_flow_schedule_rec.outside_processing_acct IS NULL))))
    AND (   (l_flow_schedule_rec.outside_proc_var_acct =
             p_flow_schedule_rec.outside_proc_var_acct) OR
            ((p_flow_schedule_rec.outside_proc_var_acct = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.outside_proc_var_acct IS NULL) AND
                (p_flow_schedule_rec.outside_proc_var_acct IS NULL))))
    AND (   (l_flow_schedule_rec.overhead_account =
             p_flow_schedule_rec.overhead_account) OR
            ((p_flow_schedule_rec.overhead_account = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.overhead_account IS NULL) AND
                (p_flow_schedule_rec.overhead_account IS NULL))))
    AND (   (l_flow_schedule_rec.overhead_variance_account =
             p_flow_schedule_rec.overhead_variance_account) OR
            ((p_flow_schedule_rec.overhead_variance_account = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.overhead_variance_account IS NULL) AND
                (p_flow_schedule_rec.overhead_variance_account IS NULL))))
    AND (   (l_flow_schedule_rec.planned_quantity =
             p_flow_schedule_rec.planned_quantity) OR
            ((p_flow_schedule_rec.planned_quantity = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.planned_quantity IS NULL) AND
                (p_flow_schedule_rec.planned_quantity IS NULL))))
    AND (   (l_flow_schedule_rec.primary_item_id =
             p_flow_schedule_rec.primary_item_id) OR
            ((p_flow_schedule_rec.primary_item_id = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.primary_item_id IS NULL) AND
                (p_flow_schedule_rec.primary_item_id IS NULL))))
    AND (   (l_flow_schedule_rec.program_application_id =
             p_flow_schedule_rec.program_application_id) OR
            ((p_flow_schedule_rec.program_application_id = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.program_application_id IS NULL) AND
                (p_flow_schedule_rec.program_application_id IS NULL))))
    AND (   (l_flow_schedule_rec.program_id =
             p_flow_schedule_rec.program_id) OR
            ((p_flow_schedule_rec.program_id = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.program_id IS NULL) AND
                (p_flow_schedule_rec.program_id IS NULL))))
    AND (   (l_flow_schedule_rec.program_update_date =
             p_flow_schedule_rec.program_update_date) OR
            ((p_flow_schedule_rec.program_update_date = FND_API.G_MISS_DATE) OR
            (   (l_flow_schedule_rec.program_update_date IS NULL) AND
                (p_flow_schedule_rec.program_update_date IS NULL))))
    AND (   (l_flow_schedule_rec.project_id =
             p_flow_schedule_rec.project_id) OR
            ((p_flow_schedule_rec.project_id = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.project_id IS NULL) AND
                (p_flow_schedule_rec.project_id IS NULL))))
    AND (   (l_flow_schedule_rec.quantity_completed =
             p_flow_schedule_rec.quantity_completed) OR
            ((p_flow_schedule_rec.quantity_completed = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.quantity_completed IS NULL) AND
                (p_flow_schedule_rec.quantity_completed IS NULL))))
    AND (   (l_flow_schedule_rec.request_id =
             p_flow_schedule_rec.request_id) OR
            ((p_flow_schedule_rec.request_id = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.request_id IS NULL) AND
                (p_flow_schedule_rec.request_id IS NULL))))
    AND (   (l_flow_schedule_rec.resource_account =
             p_flow_schedule_rec.resource_account) OR
            ((p_flow_schedule_rec.resource_account = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.resource_account IS NULL) AND
                (p_flow_schedule_rec.resource_account IS NULL))))
    AND (   (l_flow_schedule_rec.resource_variance_account =
             p_flow_schedule_rec.resource_variance_account) OR
            ((p_flow_schedule_rec.resource_variance_account = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.resource_variance_account IS NULL) AND
                (p_flow_schedule_rec.resource_variance_account IS NULL))))
    AND (   (l_flow_schedule_rec.routing_revision =
             p_flow_schedule_rec.routing_revision) OR
            ((p_flow_schedule_rec.routing_revision = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.routing_revision IS NULL) AND
                (p_flow_schedule_rec.routing_revision IS NULL))))
    AND (   (l_flow_schedule_rec.routing_revision_date =
             p_flow_schedule_rec.routing_revision_date) OR
            ((p_flow_schedule_rec.routing_revision_date = FND_API.G_MISS_DATE) OR
            (   (l_flow_schedule_rec.routing_revision_date IS NULL) AND
                (p_flow_schedule_rec.routing_revision_date IS NULL))))
    AND (   (l_flow_schedule_rec.scheduled_completion_date =
             p_flow_schedule_rec.scheduled_completion_date) OR
            ((p_flow_schedule_rec.scheduled_completion_date = FND_API.G_MISS_DATE) OR
            (   (l_flow_schedule_rec.scheduled_completion_date IS NULL) AND
                (p_flow_schedule_rec.scheduled_completion_date IS NULL))))
    AND (   (l_flow_schedule_rec.scheduled_flag =
             p_flow_schedule_rec.scheduled_flag) OR
            ((p_flow_schedule_rec.scheduled_flag = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.scheduled_flag IS NULL) AND
                (p_flow_schedule_rec.scheduled_flag IS NULL))))
    AND (   (l_flow_schedule_rec.scheduled_start_date =
             p_flow_schedule_rec.scheduled_start_date) OR
            ((p_flow_schedule_rec.scheduled_start_date = FND_API.G_MISS_DATE) OR
            (   (l_flow_schedule_rec.scheduled_start_date IS NULL) AND
                (p_flow_schedule_rec.scheduled_start_date IS NULL))))
    AND (   (l_flow_schedule_rec.schedule_group_id =
             p_flow_schedule_rec.schedule_group_id) OR
            ((p_flow_schedule_rec.schedule_group_id = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.schedule_group_id IS NULL) AND
                (p_flow_schedule_rec.schedule_group_id IS NULL))))
    AND (   (l_flow_schedule_rec.schedule_number =
             p_flow_schedule_rec.schedule_number) OR
            ((p_flow_schedule_rec.schedule_number = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.schedule_number IS NULL) AND
                (p_flow_schedule_rec.schedule_number IS NULL))))
    AND (   (l_flow_schedule_rec.status =
             p_flow_schedule_rec.status) OR
            ((p_flow_schedule_rec.status = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.status IS NULL) AND
                (p_flow_schedule_rec.status IS NULL))))
    AND (   (l_flow_schedule_rec.std_cost_adjustment_acct =
             p_flow_schedule_rec.std_cost_adjustment_acct) OR
            ((p_flow_schedule_rec.std_cost_adjustment_acct = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.std_cost_adjustment_acct IS NULL) AND
                (p_flow_schedule_rec.std_cost_adjustment_acct IS NULL))))
    AND (   (l_flow_schedule_rec.task_id =
             p_flow_schedule_rec.task_id) OR
            ((p_flow_schedule_rec.task_id = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.task_id IS NULL) AND
                (p_flow_schedule_rec.task_id IS NULL))))
    AND (   (l_flow_schedule_rec.end_item_unit_number =
             p_flow_schedule_rec.end_item_unit_number) OR
            ((p_flow_schedule_rec.end_item_unit_number = FND_API.G_MISS_CHAR) OR
            (   (l_flow_schedule_rec.end_item_unit_number IS NULL) AND
                (p_flow_schedule_rec.end_item_unit_number IS NULL))))
    AND (   (l_flow_schedule_rec.quantity_scrapped =
             p_flow_schedule_rec.quantity_scrapped) OR
            ((p_flow_schedule_rec.quantity_scrapped = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.quantity_scrapped IS NULL) AND
                (p_flow_schedule_rec.quantity_scrapped IS NULL))))
    AND (   (l_flow_schedule_rec.wip_entity_id =
             p_flow_schedule_rec.wip_entity_id) OR
            ((p_flow_schedule_rec.wip_entity_id = FND_API.G_MISS_NUM) OR
            (   (l_flow_schedule_rec.wip_entity_id IS NULL) AND
                (p_flow_schedule_rec.wip_entity_id IS NULL))))
    THEN

        --  Row has not changed. Set out parameter.

        x_flow_schedule_rec            := l_flow_schedule_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_flow_schedule_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE
        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_flow_schedule_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_LOCK_ROW_CHANGED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_flow_schedule_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_flow_schedule_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_flow_schedule_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

--  Function Get_Values

FUNCTION Get_Values
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_old_flow_schedule_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
) RETURN MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type
IS
l_flow_schedule_val_rec       MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type ;
BEGIN

    IF p_flow_schedule_rec.completion_locator_id IS NOT NULL AND
        p_flow_schedule_rec.completion_locator_id <> FND_API.G_MISS_NUM AND
        NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.completion_locator_id,
        p_old_flow_schedule_rec.completion_locator_id)
    THEN
        l_flow_schedule_val_rec.completion_locator := MRP_Id_To_Value.Completion_Locator
        (   p_completion_locator_id       => p_flow_schedule_rec.completion_locator_id
        );
    END IF;

    IF p_flow_schedule_rec.line_id IS NOT NULL AND
        p_flow_schedule_rec.line_id <> FND_API.G_MISS_NUM AND
        NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.line_id,
        p_old_flow_schedule_rec.line_id)
    THEN
        l_flow_schedule_val_rec.line := MRP_Id_To_Value.Line
        (   p_line_id                     => p_flow_schedule_rec.line_id
        );
    END IF;

    IF p_flow_schedule_rec.organization_id IS NOT NULL AND
        p_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM AND
        NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.organization_id,
        p_old_flow_schedule_rec.organization_id)
    THEN
        l_flow_schedule_val_rec.organization := MRP_Id_To_Value.Organization
        (   p_organization_id             => p_flow_schedule_rec.organization_id
        );
    END IF;

    IF p_flow_schedule_rec.primary_item_id IS NOT NULL AND
        p_flow_schedule_rec.primary_item_id <> FND_API.G_MISS_NUM AND
        NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.primary_item_id,
        p_old_flow_schedule_rec.primary_item_id)
    THEN
        l_flow_schedule_val_rec.primary_item := MRP_Id_To_Value.Primary_Item
        (   p_primary_item_id             => p_flow_schedule_rec.primary_item_id
        );
    END IF;

    IF p_flow_schedule_rec.project_id IS NOT NULL AND
        p_flow_schedule_rec.project_id <> FND_API.G_MISS_NUM AND
        NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.project_id,
        p_old_flow_schedule_rec.project_id)
    THEN
        l_flow_schedule_val_rec.project := MRP_Id_To_Value.Project
        (   p_project_id                  => p_flow_schedule_rec.project_id
        );
    END IF;

    IF p_flow_schedule_rec.schedule_group_id IS NOT NULL AND
        p_flow_schedule_rec.schedule_group_id <> FND_API.G_MISS_NUM AND
        NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.schedule_group_id,
        p_old_flow_schedule_rec.schedule_group_id)
    THEN
        l_flow_schedule_val_rec.schedule_group := MRP_Id_To_Value.Schedule_Group
        (   p_schedule_group_id           => p_flow_schedule_rec.schedule_group_id
        );
    END IF;

    IF p_flow_schedule_rec.task_id IS NOT NULL AND
        p_flow_schedule_rec.task_id <> FND_API.G_MISS_NUM AND
        NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.task_id,
        p_old_flow_schedule_rec.task_id)
    THEN
        l_flow_schedule_val_rec.task := MRP_Id_To_Value.Task
        (   p_task_id                     => p_flow_schedule_rec.task_id
        );
    END IF;

    IF p_flow_schedule_rec.wip_entity_id IS NOT NULL AND
        p_flow_schedule_rec.wip_entity_id <> FND_API.G_MISS_NUM AND
        NOT MRP_GLOBALS.Equal(p_flow_schedule_rec.wip_entity_id,
        p_old_flow_schedule_rec.wip_entity_id)
    THEN
        l_flow_schedule_val_rec.wip_entity := MRP_Id_To_Value.Wip_Entity
        (   p_wip_entity_id               => p_flow_schedule_rec.wip_entity_id
        );
    END IF;

    RETURN l_flow_schedule_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_flow_schedule_val_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_Val_PVT_Rec_Type
) RETURN MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
IS
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_flow_schedule_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_flow_schedule_rec.

    l_flow_schedule_rec := p_flow_schedule_rec;

    IF  p_flow_schedule_val_rec.completion_locator <> FND_API.G_MISS_CHAR
    THEN

        IF p_flow_schedule_rec.completion_locator_id <> FND_API.G_MISS_NUM THEN

            l_flow_schedule_rec.completion_locator_id := p_flow_schedule_rec.completion_locator_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('MRP','MRP_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','completion_locator');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_flow_schedule_rec.completion_locator_id := MRP_Value_To_Id.completion_locator
            (   p_completion_locator          => p_flow_schedule_val_rec.completion_locator
            );

            IF l_flow_schedule_rec.completion_locator_id = FND_API.G_MISS_NUM THEN
                l_flow_schedule_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_flow_schedule_val_rec.line <> FND_API.G_MISS_CHAR
    THEN

        IF p_flow_schedule_rec.line_id <> FND_API.G_MISS_NUM THEN

            l_flow_schedule_rec.line_id := p_flow_schedule_rec.line_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('MRP','MRP_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_flow_schedule_rec.line_id := MRP_Value_To_Id.line
            (   p_line                        => p_flow_schedule_val_rec.line
            );

            IF l_flow_schedule_rec.line_id = FND_API.G_MISS_NUM THEN
                l_flow_schedule_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_flow_schedule_val_rec.organization <> FND_API.G_MISS_CHAR
    THEN

        IF p_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM THEN

            l_flow_schedule_rec.organization_id := p_flow_schedule_rec.organization_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('MRP','MRP_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_flow_schedule_rec.organization_id := MRP_Value_To_Id.organization
            (   p_organization                => p_flow_schedule_val_rec.organization
            );

            IF l_flow_schedule_rec.organization_id = FND_API.G_MISS_NUM THEN
                l_flow_schedule_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_flow_schedule_val_rec.primary_item <> FND_API.G_MISS_CHAR
    THEN

        IF p_flow_schedule_rec.primary_item_id <> FND_API.G_MISS_NUM THEN

            l_flow_schedule_rec.primary_item_id := p_flow_schedule_rec.primary_item_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('MRP','MRP_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','primary_item');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_flow_schedule_rec.primary_item_id := MRP_Value_To_Id.primary_item
            (   p_primary_item                => p_flow_schedule_val_rec.primary_item
            );

            IF l_flow_schedule_rec.primary_item_id = FND_API.G_MISS_NUM THEN
                l_flow_schedule_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_flow_schedule_val_rec.project <> FND_API.G_MISS_CHAR
    THEN

        IF p_flow_schedule_rec.project_id <> FND_API.G_MISS_NUM THEN

            l_flow_schedule_rec.project_id := p_flow_schedule_rec.project_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('MRP','MRP_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','project');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_flow_schedule_rec.project_id := MRP_Value_To_Id.project
            (   p_project                     => p_flow_schedule_val_rec.project
            );

            IF l_flow_schedule_rec.project_id = FND_API.G_MISS_NUM THEN
                l_flow_schedule_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_flow_schedule_val_rec.schedule_group <> FND_API.G_MISS_CHAR
    THEN

        IF p_flow_schedule_rec.schedule_group_id <> FND_API.G_MISS_NUM THEN

            l_flow_schedule_rec.schedule_group_id := p_flow_schedule_rec.schedule_group_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('MRP','MRP_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','schedule_group');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_flow_schedule_rec.schedule_group_id := MRP_Value_To_Id.schedule_group
            (   p_schedule_group              => p_flow_schedule_val_rec.schedule_group
            );

            IF l_flow_schedule_rec.schedule_group_id = FND_API.G_MISS_NUM THEN
                l_flow_schedule_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_flow_schedule_val_rec.task <> FND_API.G_MISS_CHAR
    THEN

        IF p_flow_schedule_rec.task_id <> FND_API.G_MISS_NUM THEN

            l_flow_schedule_rec.task_id := p_flow_schedule_rec.task_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('MRP','MRP_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','task');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_flow_schedule_rec.task_id := MRP_Value_To_Id.task
            (   p_task                        => p_flow_schedule_val_rec.task
            );

            IF l_flow_schedule_rec.task_id = FND_API.G_MISS_NUM THEN
                l_flow_schedule_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_flow_schedule_val_rec.wip_entity <> FND_API.G_MISS_CHAR
    THEN

        IF p_flow_schedule_rec.wip_entity_id <> FND_API.G_MISS_NUM THEN

            l_flow_schedule_rec.wip_entity_id := p_flow_schedule_rec.wip_entity_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('MRP','MRP_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','wip_entity');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_flow_schedule_rec.wip_entity_id := MRP_Value_To_Id.wip_entity
            (   p_wip_entity                  => p_flow_schedule_val_rec.wip_entity
            );

            IF l_flow_schedule_rec.wip_entity_id = FND_API.G_MISS_NUM THEN
                l_flow_schedule_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_flow_schedule_rec;

END Get_Ids;

PROCEDURE Populate_Flow_Summary(
        x_return_status         OUT     NOCOPY	VARCHAR2,
        p_line_id               IN      NUMBER,
        p_org_id                IN      NUMBER,
        p_first_bucket_date     IN      DATE,   -- server timezone of client
                                                -- start date of week at 0:00:00
        p_query_id              IN      NUMBER
)
IS

CURSOR flow_schedule_info(l_query_id NUMBER, x NUMBER, start_date DATE,
                          client_start_date DATE) IS  --TZ BOM Calendar bug 3832684 --fix bug#3170105
SELECT  mls.primary_item_id,
        -- bucket_counter
        floor(mls.scheduled_completion_date-start_date)+1,
        -- bucket_date
        floor(mls.scheduled_completion_date-start_date)+client_start_date,--TZ BOM Calendar bug 3832684
        decode(x,1,sum(nvl(mls.planned_quantity,0)),
                2,sum(nvl(mls.quantity_completed,0)),
                sum((nvl(mls.planned_quantity,0)-nvl(mls.quantity_completed,0))))
FROM mrp_line_sch_avail_v mls
WHERE mls.line_id = p_line_id
AND mls.organization_id = p_org_id
AND mls.scheduled_completion_date
BETWEEN start_date and start_date+(7-1/(24*60*60))
GROUP BY mls.primary_item_id, floor(mls.scheduled_completion_date-start_date)
order by mls.primary_item_id;

TYPE summary_rec IS RECORD
        ( item_id               NUMBER,
          bucket_counter        NUMBER,
          bucket_date           DATE,
          quantity              NUMBER );

flow_activity_rec       summary_rec;

TYPE calendar_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE column_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

l_last_item_id          NUMBER := -1;
bucket_dates            calendar_date;
bucket_quantity         column_number;
l_query_id1             NUMBER;

l_first_bucket_client	DATE;  --fix bug#3170105

PROCEDURE flush_summary_rec (p_item_id NUMBER,
                                p_query_id NUMBER,
				x NUMBER) IS

  l_item_segments		VARCHAR2(2000);

  CURSOR ITEM_SEGMENTS IS
	SELECT concatenated_segments
	FROM mtl_system_items_kfv
	WHERE inventory_item_id = p_item_id
	AND organization_id = p_org_id;

BEGIN

  OPEN ITEM_SEGMENTS;
  FETCH ITEM_SEGMENTS INTO l_item_segments;
  CLOSE ITEM_SEGMENTS;

  INSERT INTO mrp_form_query(
        query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        number15,
        char1,
        number14,
        date1,
        date2,
        date3,
        date4,
        date5,
        date6,
        date7,
        number1,
        number2,
        number3,
        number4,
        number5,
        number6,
        number7,
	number10 )
  VALUES (
        p_query_id,
        sysdate,
        1,
        sysdate,
        1,
        p_item_id,
        substr(l_item_segments,1,80),
        x,
        bucket_dates(1),
        bucket_dates(2),
        bucket_dates(3),
        bucket_dates(4),
        bucket_dates(5),
        bucket_dates(6),
        bucket_dates(7),
        bucket_quantity(1),
        bucket_quantity(2),
        bucket_quantity(3),
        bucket_quantity(4),
        bucket_quantity(5),
        bucket_quantity(6),
        bucket_quantity(7),
	bucket_quantity(1)+bucket_quantity(2)+bucket_quantity(3)+bucket_quantity(4)+bucket_quantity(5)+bucket_quantity(6)+bucket_quantity(7)
  );

END flush_summary_rec;

PROCEDURE Calculate_Totals(p_query_id NUMBER) IS
BEGIN

  INSERT INTO mrp_form_query(
        query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        number14,
        number1,
        number2,
        number3,
        number4,
        number5,
        number6,
        number7,
        number10 )
  SELECT
        p_query_id,
        sysdate,
        1,
        sysdate,
        1,
        number14 + 10,
        sum(number1),
        sum(number2),
        sum(number3),
        sum(number4),
        sum(number5),
        sum(number6),
        sum(number7),
        sum(number1) + sum(number2) + sum(number3) + sum(number4) +
		sum(number5) + sum(number6) + sum(number7)
  FROM mrp_form_query
  WHERE query_id = p_query_id
  AND number14 in (1,2,3)
  GROUP BY number14;

END Calculate_Totals;

BEGIN

  FND_MSG_PUB.Initialize;

  --start bug 3783650: TZ BOM Calendar bug 3832684
  IF flm_timezone.g_enabled THEN
  --fix bug#3170105
    l_first_bucket_client := flm_timezone.server_to_client(p_first_bucket_date);
    l_first_bucket_client := trunc(l_first_bucket_client);
  --end of fix bug#3170105
  ELSE
    l_first_bucket_client := trunc(p_first_bucket_date);
  END IF;
  --end bug 3783650

  SELECT mrp_form_query_s.nextval
  INTO l_query_id1
  FROM dual;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR loop in 1..7 LOOP
    INSERT INTO mrp_form_query (
        query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        number13,
        number14,
        number1,
        date1 )
    VALUES (
        l_query_id1,
        sysdate,
        1,
        sysdate,
        1,
        p_line_id,
        p_org_id,
        loop,
        l_first_bucket_client + (loop - 1)  --fix bug#3170105
    );
  END LOOP;

  FOR x in 1..3 LOOP

    -- -----------------------------
    -- Initialize bucket values
    -- -----------------------------
    FOR loop in 1..7 LOOP
      bucket_dates(loop) := l_first_bucket_client + (loop - 1);
      bucket_quantity(loop) := 0;
    END LOOP;

    l_last_item_id := -1;

    --fix bug#3170105
    --TZ BOM Calendar bug 3832684
    OPEN flow_schedule_info(l_query_id1,x,p_first_bucket_date,l_first_bucket_client);

    LOOP
      FETCH flow_schedule_info
      INTO flow_activity_rec;

      -- ---------------------------------------
      -- Flush previous record to mrp_form_query
      -- ---------------------------------------
      IF ( (flow_schedule_info%NOTFOUND) OR
        	(flow_activity_rec.item_id <> l_last_item_id))
        	AND (l_last_item_id <> -1) THEN
        flush_summary_rec(l_last_item_id, p_query_id, x);

        -- ---------------------------
        -- Reinitialize bucket values
        -- ---------------------------
        FOR loop in 1..7 LOOP
          bucket_dates(loop) := l_first_bucket_client + (loop - 1);  --fix bug#3170105
          bucket_quantity(loop) := 0;
        END LOOP;

      ELSIF ((flow_schedule_info%NOTFOUND) AND (l_last_item_id = -1)) THEN

        FOR loop in 1..7 LOOP
          bucket_dates(loop) := l_first_bucket_client + (loop - 1);  --fix bug#3170105
          bucket_quantity(loop) := NULL;
        END LOOP;

        flush_summary_rec(NULL, p_query_id, x);

        EXIT;

      END IF;

      -- ------------------------
      -- Set bucket values
      -- ------------------------

      bucket_dates(flow_activity_rec.bucket_counter) :=
                flow_activity_rec.bucket_date;
      bucket_quantity(flow_activity_rec.bucket_counter) :=
                flow_activity_rec.quantity;

      -- --------------------------
      -- Reinitialize last_item_id
      -- --------------------------
      l_last_item_id := flow_activity_rec.item_id;

      EXIT WHEN flow_schedule_info%NOTFOUND;
    END LOOP;
    CLOSE flow_schedule_info;

  END LOOP;

  calculate_totals(p_query_id);

EXCEPTION

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

      FND_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'populate_flow_summary'
      );
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Populate_Flow_Summary;

PROCEDURE Update_Quantity(
	x_return_status 	OUT	NOCOPY	VARCHAR2,
        x_msg_count		OUT	NOCOPY	NUMBER,
        x_msg_data		OUT	NOCOPY	VARCHAR2,
	p_wip_entity_id		IN	NUMBER,
	p_quantity		IN	NUMBER ) IS

BEGIN

    FND_MSG_PUB.Initialize;

    UPDATE wip_flow_schedules
    SET planned_quantity = planned_quantity + p_quantity
    WHERE wip_entity_id = p_wip_entity_id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

EXCEPTION

  WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

          FND_MSG_PUB.Add_Exc_Msg
          (   G_PKG_NAME
          ,   'update_quantity'
          );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Update_Quantity;

PROCEDURE Update_Quantity(
	p_wip_entity_id		IN	NUMBER,
	p_quantity		IN	NUMBER ) IS

BEGIN

    UPDATE wip_flow_schedules
    SET planned_quantity = planned_quantity + p_quantity
    WHERE wip_entity_id = p_wip_entity_id;

EXCEPTION

  WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

          FND_MSG_PUB.Add_Exc_Msg
          (   G_PKG_NAME
          ,   'update_quantity'
          );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Quantity;

PROCEDURE Delete_Flow_Row
(  x_return_status      OUT NOCOPY	VARCHAR2,
   x_msg_count          OUT NOCOPY	NUMBER,
   x_msg_data           OUT NOCOPY	VARCHAR2,
   p_wip_entity_id      IN  NUMBER
)
IS
BEGIN

    FND_MSG_PUB.Initialize;

    DELETE  FROM WIP_FLOW_SCHEDULES
    WHERE   WIP_ENTITY_ID = p_wip_entity_id
      AND status = 1
      AND nvl(transacted_flag, 'N') = 'N'
      AND quantity_completed = 0
      AND quantity_scrapped = 0 ;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

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
            ,   'Delete_Flow_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Delete_Flow_Row;

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
                                 p_to_category          IN      VARCHAR2) IS

  -- Local variables
  l_log_message         VARCHAR2(2000);
  l_return              BOOLEAN;
  l_err_buf             VARCHAR2(2000);
  l_where_clause        VARCHAR2(2000) := NULL;
  l_item_where_clause   VARCHAR2(2000) := NULL;
  l_cat_where_clause    VARCHAR2(2000) := NULL;
  l_rows_processed      INTEGER := 0;
  l_dummy      		INTEGER;
  l_cursor              INTEGER;
  l_sql_stmt            VARCHAR2(2000) := NULL;
  l_demand_source_line	VARCHAR2(30);
  l_replenish_to_order_flag VARCHAR2(1);
  l_build_in_wip_flag VARCHAR2(1);
  l_wip_entity_id	NUMBER;
  l_return_status       VARCHAR2(100);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  -- Exceptions
  expected_error        EXCEPTION;
  unexpected_error      EXCEPTION;

  --fix bug#3170105
  l_start_date		DATE;
  l_end_date		DATE;
  --end of fix bug#3170105

BEGIN

  --fix bug#3170105
  l_start_date := flm_timezone.client_to_server(
    fnd_date.canonical_to_date(p_start_date));
  l_end_date := flm_timezone.client_to_server(
    fnd_date.canonical_to_date(p_end_date));
  --end of fix bug#3170105

  -- Print report parameters
  FND_MESSAGE.set_name('MRP','EC_REPORT_PARAMETERS');
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','1');
  FND_MESSAGE.set_token('TOKEN','(ORGANIZATION_ID)');
  FND_MESSAGE.set_token('VALUE',to_char(p_organization_id));
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','2');
  FND_MESSAGE.set_token('TOKEN','(START_DATE)');
  FND_MESSAGE.set_token('VALUE',to_char(l_start_date));  --fix bug#3170105
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','3');
  FND_MESSAGE.set_token('TOKEN','(END_DATE)');
  FND_MESSAGE.set_token('VALUE',to_char(l_end_date));  --fix bug#3170105
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','4');
  FND_MESSAGE.set_token('TOKEN','(FROM_LINE)');
  FND_MESSAGE.set_token('VALUE',p_from_line);
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','5');
  FND_MESSAGE.set_token('TOKEN','(TO_LINE)');
  FND_MESSAGE.set_token('VALUE',p_to_line);
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','6');
  FND_MESSAGE.set_token('TOKEN','(FROM_ITEM)');
  FND_MESSAGE.set_token('VALUE',p_from_item);
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','7');
  FND_MESSAGE.set_token('TOKEN','(TO_ITEM)');
  FND_MESSAGE.set_token('VALUE',p_to_item);
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','8');
  FND_MESSAGE.set_token('TOKEN','(CATEGORY_SET_ID)');
  FND_MESSAGE.set_token('VALUE',to_char(p_category_set_id));
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','9');
  FND_MESSAGE.set_token('TOKEN','(CATEGORY_STRUCTURE_ID)');
  FND_MESSAGE.set_token('VALUE',to_char(p_category_structure_id));
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','10');
  FND_MESSAGE.set_token('TOKEN','(FROM_CATEGORY)');
  FND_MESSAGE.set_token('VALUE',p_from_category);
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','11');
  FND_MESSAGE.set_token('TOKEN','(TO_CATEGORY)');
  FND_MESSAGE.set_token('VALUE',p_to_category);
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  -- Check for mandatory parameters and issue an error message
  -- Check for mandatory parameters and issue an error message
  -- if NULL.  If line, item or category are null, assume all.
  IF p_organization_id IS NULL THEN
    FND_MESSAGE.set_name('MRP','MRP_ORG_ID_REQUIRED');
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);
    RAISE expected_error;
  END IF;
  IF p_start_date IS NULL THEN
    FND_MESSAGE.set_name('MRP','MRP_START_DATE_REQUIRED');
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);
    RAISE expected_error;
  END IF;
  IF p_end_date IS NULL THEN
    FND_MESSAGE.set_name('MRP','MRP_END_DATE_REQUIRED');
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);
    RAISE expected_error;
  END IF;

  -- begin new binds
  flm_util.init_bind;

  -- Construct where clause
  IF p_from_line IS NOT NULL and p_to_line IS NOT NULL THEN
    l_where_clause := ' and wfs.line_id in (select line_id from wip_lines '||
                      '  where line_code between :from_line and :to_line )';
    flm_util.add_bind(':from_line', p_from_line);
    flm_util.add_bind(':to_line', p_to_line);
  END IF;

  IF p_from_item IS NOT NULL and p_to_item IS NOT NULL THEN
    -- Call procedure (from Kanban) to construct item_where_clause
    l_return := flm_util.Item_Where_Clause(
                        p_from_item,
                        p_to_item,
                        'msi',
                        l_item_where_clause,
                        l_err_buf);

    IF NOT l_return THEN
      -- English because unexpected error
      l_log_message := 'Problem constructing item_where_clause';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;
    END IF;
    l_item_where_clause := ' AND wfs.primary_item_id in ' ||
	    '(select inventory_item_id from mtl_system_items msi ' ||
 	    ' where ' || l_item_where_clause || ')';
  END IF;

  IF (p_from_category IS NOT NULL OR p_to_category IS NOT NULL)
  AND p_category_set_id IS NOT NULL THEN
    l_return := flm_util.Category_Where_Clause(
                        p_from_category,
                        p_to_category,
                        'cat',
                        p_category_structure_id,
                        l_cat_where_clause,
                        l_err_buf);

    IF NOT l_return THEN
      -- English because unexpected error
      l_log_message := 'Problem constructing category_where_clause';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;
    END IF;
    l_cat_where_clause := ' AND wfs.primary_item_id in (select ' ||
		' inventory_item_id from mtl_item_categories mic, '||
		' mtl_categories cat where ' ||
                ' cat.category_id = mic.category_id ' ||
                ' and mic.organization_id = :cat_organization_id ' ||
		' and mic.category_set_id = :cat_category_set_id ' ||
		' and ' || l_cat_where_clause || ')';
    flm_util.add_bind(':cat_organization_id', p_organization_id);
    flm_util.add_bind(':cat_category_set_id', p_category_set_id);
  ELSIF p_category_set_id IS NOT NULL THEN
    l_cat_where_clause := ' AND wfs.primary_item_id in (select ' ||
                ' inventory_item_id from mtl_item_categories mic '||
                ' where mic.organization_id = :cat_organization_id '||
                ' and mic.category_set_id = :cat_category_set_id ) ';
    flm_util.add_bind(':cat_organization_id', p_organization_id);
    flm_util.add_bind(':cat_category_set_id', p_category_set_id);
  END IF;

  l_where_clause := l_where_clause || l_item_where_clause ||
		l_cat_where_clause;

  --fix bug#3170105
/* Bug 3267578: Added not exists from MTL_TRANSACTIONS_INTERFACE */
  l_sql_stmt :=
    'SELECT wfs.wip_entity_id, wfs.demand_source_line, msi.replenish_to_order_flag, msi.build_in_wip_flag ' ||
    ' FROM wip_flow_schedules wfs, mtl_system_items msi ' ||
    ' WHERE wfs.primary_item_id = msi.inventory_item_id '||
    '   AND wfs.organization_id = msi.organization_id ' ||
    '   AND wfs.organization_id = to_char(:organization_id) ' ||
    l_where_clause ||
    '   AND wfs.status = 1 AND wfs.quantity_completed = 0 ' ||
    '   AND wfs.scheduled_completion_date between ' ||
    '         :start_date ' ||
    '         and :end_date '||
    ' and not exists ( select 1 from mtl_transactions_interface ' ||
    '                   where transaction_source_id = wfs.wip_entity_id ' ||
    '                     and organization_id = wfs.organization_id ' ||
    '                     and transaction_source_type_id = 5 ' || -- perf bug 4911894
    '                     and transaction_action_id in (1, 27, 30, 31, 32, 33, 34)  ) ';
  flm_util.add_bind(':organization_id', p_organization_id);
  flm_util.add_bind(':start_date', l_start_date);
  flm_util.add_bind(':end_date', l_end_date+1-1/(24*60*60));
  --end of fix bug#3170105
  -- get the cursor
  l_cursor := dbms_sql.open_cursor;

  -- parse the sql statement
  dbms_sql.parse(l_cursor, l_sql_stmt, dbms_sql.native);
  flm_util.do_binds(l_cursor);


  -- define column
  dbms_sql.define_column(l_cursor, 1, l_wip_entity_id);
  dbms_sql.define_column(l_cursor, 2, l_demand_source_line, 30);
  dbms_sql.define_column(l_cursor, 3, l_replenish_to_order_flag, 1);
  dbms_sql.define_column(l_cursor, 4, l_build_in_wip_flag, 1);

  -- execute the sql statement
  l_dummy := dbms_sql.execute(l_cursor);

  WHILE dbms_sql.fetch_rows(l_cursor) > 0 LOOP
    dbms_sql.column_value(l_cursor,1, l_wip_entity_id);
    dbms_sql.column_value(l_cursor,2, l_demand_source_line);
    dbms_sql.column_value(l_cursor,3, l_replenish_to_order_flag);
    dbms_sql.column_value(l_cursor,4, l_build_in_wip_flag);

    -- Added to support component picking. It will cancel the move order when the flow
    -- schedule is to be deleted.
    wip_picking_pvt.cancel_allocations(l_wip_entity_id, 4, null, l_return_status, l_msg_data);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      MRP_UTIL.MRP_LOG(l_msg_data);
    ELSE
      DELETE FROM wip_flow_schedules
      WHERE wip_entity_id = l_wip_entity_id AND organization_id = p_organization_id;

      l_rows_processed := l_rows_processed + 1;

      IF (l_replenish_to_order_flag = 'Y' AND l_build_in_wip_flag = 'Y'  AND l_demand_source_line IS NOT NULL) THEN
        CTO_WIP_WORKFLOW_API_PK.flow_deletion(to_number(l_demand_source_line), l_return_status,
					    l_msg_count, l_msg_data);
      END IF;

      -- Added for Flow Execution Workstation. Deleting from execution table
      delete from flm_exe_operations
      where organization_id = p_organization_id and wip_entity_id = l_wip_entity_id;
      delete from flm_exe_req_operations
      where organization_id = p_organization_id and wip_entity_id = l_wip_entity_id;
      delete from flm_exe_lot_numbers
      where organization_id = p_organization_id and wip_entity_id = l_wip_entity_id;
      delete from flm_exe_serial_numbers
      where organization_id = p_organization_id and wip_entity_id = l_wip_entity_id;
    END IF;

  END LOOP;

  -- close the cursor
  dbms_sql.close_cursor(l_cursor);

  FND_MESSAGE.set_name('MRP','MRP_ROWS_DELETED');
  FND_MESSAGE.set_token('ROW_COUNT',l_rows_processed);
  ERRBUF := FND_MESSAGE.get;
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRP_FLOW_DELETE');
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  RETCODE := G_SUCCESS;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK;
    RETCODE := G_WARNING;
    FND_MESSAGE.set_name('MRP','MRP_NO_FLOW_DELETED');
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);

  WHEN expected_error THEN
    ROLLBACK;
    IF RETCODE <> 1 THEN
      RETCODE := G_ERROR;
    END IF;
    FND_MESSAGE.set_name('MRP','MRP_DELETE_FLOW_ERROR');
    ERRBUF := FND_MESSAGE.get;
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);

  WHEN unexpected_error THEN
    ROLLBACK;
    RETCODE := G_ERROR;
    FND_MESSAGE.set_name('MRP','MRP_DELETE_FLOW_ERROR');
    ERRBUF := FND_MESSAGE.get;
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);

  WHEN OTHERS THEN
    ROLLBACK;
    RETCODE := G_ERROR;
    FND_MESSAGE.set_name('MRP','MRP_DELETE_FLOW_ERROR');
    ERRBUF := FND_MESSAGE.get;
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);
    l_log_message := 'Unexpected SQL Error: '||sqlerrm;
    MRP_UTIL.MRP_LOG(l_log_message);

END Delete_Flow_Schedules;


PROCEDURE Roll_Flow_Schedules( ERRBUF                 OUT     NOCOPY	VARCHAR2,
                                 RETCODE                OUT     NOCOPY	VARCHAR2,
                                 p_organization_id      IN      NUMBER,
                                 p_spread_qty           IN      NUMBER,
                                 p_dummy	        IN      NUMBER,
                                 p_dummy1	        IN      NUMBER,
                                 p_dummy2	        IN      NUMBER,
                                 p_dummy3	        IN      NUMBER,
                                 p_dummy4	        IN      NUMBER,
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
                                 p_to_category          IN      VARCHAR2)
IS

  --b boolean;
  -- Local variables
  l_log_message         VARCHAR2(2000);
  l_out_message         VARCHAR2(2000);
  l_return              BOOLEAN;
  l_err_buf             VARCHAR2(2000);

  l_cursor		INTEGER := NULL;
  l_rows		INTEGER := NULL;

  l_temp_date		DATE;  --fix bug#3170105
  l_from_start_date	DATE;  --fix bug#3170105
  l_from_end_date	DATE;
  l_to_end_date		DATE;
  l_to_start_date	DATE;

  l_to_start_time       NUMBER;  --TZ BOM Calendar bug 3832684
  l_to_end_time         NUMBER;  --TZ BOM Calendar bug 3832684

  l_variance		NUMBER := 0;
  l_daily_variance	NUMBER := 0;
  l_update_variance     NUMBER := 0;
  l_unprocessed_var	NUMBER := 0;
  l_remainder		NUMBER := 0;
  l_row_count		NUMBER := 0;

  l_wip_entity_id	NUMBER := FND_API.G_MISS_NUM;
  l_wip_entity_id2	NUMBER := FND_API.G_MISS_NUM;
  l_completion_date	DATE := FND_API.G_MISS_DATE;
  l_old_completion_date DATE := FND_API.G_MISS_DATE;
  l_planned_quantity    NUMBER := FND_API.G_MISS_NUM;
  l_quantity_completed    NUMBER := FND_API.G_MISS_NUM;

  l_report_query_id     NUMBER;

  fs_report_rec		REPORT_REC_TYPE;

  l_planned_total	NUMBER;
  l_completed_total	NUMBER;
  l_variance1_total	NUMBER;
  l_scheduled_total	NUMBER;
  l_adjusted_total	NUMBER;
  l_variance2_total	NUMBER;

  l_old_line_id		NUMBER := -1;
  l_old_line_code	VARCHAR2(30);
  l_old_item_id		NUMBER := -1;
  l_old_item		VARCHAR2(240);
  l_old_sg_id		NUMBER := -1;

  l_trans_var1		VARCHAR2(30);
  l_trans_var2		VARCHAR2(30);
  l_trans_var3		VARCHAR2(30);
  l_trans_var4		VARCHAR2(30);
  l_trans_var5		VARCHAR2(30);
  l_trans_var6		VARCHAR2(30);

  l_flow_schedule_rec	MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
  l_x_flow_schedule_rec	MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
  l_control_rec         MRP_GLOBALS.Control_Rec_Type := MRP_GLOBALS.G_MISS_CONTROL_REC;
  l_old_flow_schedule_rec         MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type ;


  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);
  i			NUMBER;
  msg			VARCHAR2(2000);

  /* Added for Enhancement #2829204 */
  l_auto_replenish	VARCHAR2(1);
  l_kanban_activity_id	NUMBER;

  CURSOR Kanban_Card_Activity_Csr(p_wip_entity_id IN NUMBER) IS
    SELECT Kanban_Activity_Id
      FROM mtl_kanban_card_activity
     WHERE source_wip_entity_id = p_wip_entity_id;

-- Bug 2213859
   TYPE build_seq_counter_rec_type is RECORD(
   current_build_seq     NUMBER,
   base_number           NUMBER);

   TYPE l_build_seq_counter_type is TABLE of build_seq_counter_rec_type index by binary_integer;
   l_build_seq_counter   l_build_seq_counter_type;
   l_temp_build_sequence NUMBER;
   l_base_number         NUMBER;
   l_total_count         NUMBER;
   l_index               BINARY_INTEGER;
-- Bug 2213859

  -- Exceptions
  expected_error        EXCEPTION;
  unexpected_error      EXCEPTION;

  -- Added for project 'Roll Flow Schedules: Maintain Schedule Number'
  -- To hold old/new schedule_number/wip_entity_id that will be used for swapping at the end of process
  oldFSSchNum		FSSchNum;
  oldFSWipId		FSWipId;
  newFSSchNum		FSSchNum;
  newFSWipId		FSWipId;
  l_loop_count		NUMBER:=0;

  CURSOR C1(p_line_id NUMBER, p_item_id NUMBER, p_schedule_group_id NUMBER,
            p_to_start_date DATE, p_to_end_date DATE)  --fix bug#3170105
  IS
  SELECT nvl(sum(planned_quantity),0)
  FROM wip_flow_schedules
  WHERE organization_id = p_organization_id
  AND line_id = p_line_id
  AND primary_item_id = p_item_id
  AND nvl(schedule_group_id,-1) = nvl(p_schedule_group_id,-1)
  AND build_sequence IS NULL
  AND demand_source_header_id IS NULL
  AND scheduled_completion_date  --fix bug#3170105
	BETWEEN p_to_start_date AND p_to_end_date+1-1/(24*60*60);

  CURSOR C2(p_line_id NUMBER, p_item_id NUMBER, p_schedule_group_id NUMBER,
            p_to_start_date DATE, p_to_end_date DATE)  --fix bug#3170105
  IS
  SELECT wip_entity_id,
	planned_quantity
  FROM wip_flow_schedules
  WHERE organization_id = p_organization_id
  AND line_id = p_line_id
  AND primary_item_id = p_item_id
  AND nvl(schedule_group_id,-1) = nvl(p_schedule_group_id,-1)
  AND build_sequence IS NULL
  AND demand_source_header_id IS NULL
  AND scheduled_completion_date  --fix bug#3170105
	BETWEEN p_to_start_date AND p_to_end_date+1-1/(24*60*60);

  CURSOR C3(p_line_id NUMBER, p_item_id NUMBER,
            p_to_start_date DATE, p_to_end_date DATE)  --fix bug#3170105
  IS
  SELECT wip_entity_id,
	scheduled_completion_date,
	planned_quantity,
        quantity_completed
  FROM wip_flow_schedules
  WHERE organization_id = p_organization_id
  AND line_id = p_line_id
  AND primary_item_id = p_item_id
  AND demand_source_header_id IS NULL
  AND planned_quantity > quantity_completed
  AND scheduled_completion_date  --fix bug#3170105
	BETWEEN p_to_start_date AND p_to_end_date+1-1/(24*60*60)
  UNION
  SELECT 0,
	flm_timezone.calendar_to_server(calendar_date), --TZ Bug 3832684
	0,
        0
  FROM mtl_parameters mp,
	bom_calendar_dates bom
  WHERE mp.organization_id = p_organization_id
  AND mp.calendar_exception_set_id = bom.exception_set_id
  AND mp.calendar_code = bom.calendar_code
  AND bom.seq_num IS NOT NULL
  AND bom.calendar_date between flm_timezone.server_to_calendar(p_to_start_date) --fix bug#3170105
      AND flm_timezone.server_to_calendar(p_to_end_date)
  AND bom.calendar_date NOT IN (select flm_timezone.server_to_calendar(scheduled_completion_date)
  	FROM wip_flow_schedules
        WHERE organization_id = p_organization_id
  	AND line_id = p_line_id
  	AND primary_item_id = p_item_id
  	AND demand_source_header_id IS NULL
        AND scheduled_completion_date  --fix bug#3170105
	BETWEEN p_to_start_date AND p_to_end_date+1-1/(24*60*60))
  ORDER BY 2 desc;

  CURSOR C4(p_line_id NUMBER, p_item_id NUMBER,
            p_to_start_date DATE, p_to_end_date DATE)  --fix bug#3170105
  IS
  SELECT count(bom.calendar_date)
  FROM mtl_parameters mp,
 	bom_calendar_dates bom
  WHERE mp.calendar_exception_set_id = bom.exception_set_id
  AND mp.calendar_code = bom.calendar_code
  AND mp.organization_id = p_organization_id
  AND bom.calendar_date BETWEEN flm_timezone.server_to_calendar(p_to_start_date) --fix bug#3170105
      AND flm_timezone.server_to_calendar(p_to_end_date)
  AND ((bom.seq_num IS NOT NULL) OR
	(bom.calendar_date IN (SELECT flm_timezone.server_to_calendar(scheduled_completion_date)
	FROM wip_flow_schedules
	WHERE organization_id = p_organization_id
	AND line_id = p_line_id
	AND primary_item_id = p_item_id
        AND scheduled_completion_date BETWEEN
            flm_timezone.calendar_to_server(bom.calendar_date)
        AND flm_timezone.calendar_to_server(bom.calendar_date)+1-1/(24*60*60)
	AND demand_source_header_id IS NULL)));

  CURSOR C5(p_line_id NUMBER, p_item_id NUMBER,
            p_to_start_date DATE, p_to_end_date DATE)  --fix bug#3170105
  IS
  SELECT wip_entity_id,
	scheduled_completion_date,  --fix bug#3170105
	planned_quantity
  FROM wip_flow_schedules
  WHERE organization_id = p_organization_id
  AND line_id = p_line_id
  AND primary_item_id = p_item_id
  AND build_sequence IS NULL
  AND demand_source_header_id IS NULL
  AND scheduled_completion_date  --fix bug#3170105
BETWEEN p_to_start_date AND p_to_end_date+1-1/(24*60*60)
  ORDER BY scheduled_completion_date desc
  FOR UPDATE OF wip_entity_id NOWAIT;

  CURSOR C6(p_line_id NUMBER, p_item_id NUMBER, p_schedule_group_id NUMBER,
		p_completion_date DATE,
            p_from_start_date DATE, p_from_end_date DATE,
            p_to_start_date DATE, p_to_end_date DATE)  --fix bug#3170105
  IS
  SELECT wip_entity_id,
	scheduled_completion_date,  --fix bug#3170105
	planned_quantity
  FROM wip_flow_schedules
  WHERE organization_id = p_organization_id
  AND line_id = p_line_id
  AND primary_item_id = p_item_id
  AND planned_quantity > 0
  AND nvl(schedule_group_id,-1) = nvl(p_schedule_group_id,-1)
  AND build_sequence IS NULL
  AND demand_source_header_id IS NULL
  AND scheduled_completion_date BETWEEN
     p_to_start_date + (p_completion_date - p_from_start_date)
  AND p_to_start_date + (p_completion_date - p_from_start_date) +1-1/(24*60*60)
  AND scheduled_completion_date  --fix bug#3170105
	BETWEEN p_to_start_date AND p_to_end_date+1-1/(24*60*60)
  ORDER BY scheduled_completion_date desc
  FOR UPDATE OF wip_entity_id NOWAIT;

  CURSOR REPORT_CURSOR(l_query_id NUMBER) IS
  SELECT rpad(substr(wl.line_code,1,10),10),
        number1,
	rpad(substr(kfv.concatenated_segments,1,14),14),
        number2,
	rpad(substr(nvl(sg.schedule_group_name,' '),1,8),8),
        number3,
	date1,
	number4,
	number5,
	number4 - number5,
	date2,
	nvl(number6,0),
	number7,
	number7 - nvl(number6,0)
  FROM wip_lines wl,
	mtl_system_items_kfv kfv,
	wip_schedule_groups sg,
	mrp_form_query
  WHERE wl.line_id = number1
  AND wl.organization_id = number10
  AND kfv.inventory_item_id = number2
  AND kfv.organization_id = number10
  AND sg.schedule_group_id(+) = number3
  AND sg.organization_id(+) = number10
  AND query_id = l_query_id
  ORDER BY wl.line_code, kfv.concatenated_segments,schedule_group_name,
	date1, date2, number4, number5, number6, number7;

  CURSOR REPORT_TOTALS(l_query_id NUMBER, l_line_id NUMBER,
	l_item_id NUMBER, l_schedule_group_id NUMBER) IS
  SELECT sum(number4),
	sum(number5),
	sum(number4 - number5),
	sum(nvl(number6,0)),
	sum(number7),
	sum(number7 - nvl(number6,0))
  FROM mrp_form_query
  WHERE query_id = l_query_id
  AND number1 = l_line_id
  AND number2 = l_item_id
  AND nvl(number3,-1) = nvl(l_schedule_group_id,-1);

-- Bug 2213859
 FUNCTION Get_Base_Number(p_line_id NUMBER ,p_target_date DATE,
                          p_from_start_date DATE, p_from_end_date DATE)  --fix bug#3170105
  RETURN NUMBER IS
 CURSOR Get_Target_Max_Build_Seq(p_line_id NUMBER, p_target_date DATE)
   IS
     SELECT nvl(max(build_sequence),0)
       FROM wip_flow_schedules
      WHERE organization_id = p_organization_id
        AND line_id = p_line_id
        AND build_sequence is NOT NULL
        AND (ROLL_FORWARDED_FLAG <> G_INTERMEDIATE_ROLL_FORWARDED OR
             ROLL_FORWARDED_FLAG IS NULL) /*Bug 3019639*/
        /** Forward ported bug 3055939 */
        AND scheduled_completion_date >= flm_timezone.client00_in_server(p_target_date)  --fix bug#3170105
        AND scheduled_completion_date < flm_timezone.client00_in_server(p_target_date+1);  --fix bug#3170105

 CURSOR Count_Orig_Schedules (p_line_id NUMBER,
                              p_from_start_date DATE, p_from_end_date DATE)  --fix bug#3170105)
   IS
   SELECT count(*)
   FROM wip_flow_schedules
   WHERE organization_id = p_organization_id
   AND line_id = p_line_id
   AND nvl(planned_quantity,0) > nvl(quantity_completed,0)
        /** Forward ported bug 3055939 */
   AND scheduled_completion_date >= p_from_start_date  --fix bug#3170105
   AND scheduled_completion_date < p_from_end_date+1;  --fix bug#3170105

    l_max_build_seq         NUMBER:=0;
    l_count_schedule        NUMBER:=0;
 BEGIN
   OPEN Get_Target_Max_Build_Seq(p_line_id, p_target_date);
   FETCH Get_Target_Max_Build_Seq INTO l_max_build_seq;
   CLOSE Get_Target_Max_Build_Seq;

   OPEN Count_Orig_Schedules(p_line_id,p_from_start_date,p_from_end_date);
   FETCH Count_Orig_Schedules INTO l_count_schedule;
   CLOSE Count_Orig_Schedules;

   RETURN (l_max_build_seq + l_count_schedule + 1);
 END Get_Base_Number;

-- Bug 2213859

FUNCTION Time_Schedule(p_line_id NUMBER ,p_scheduled_completion_date DATE,
                           p_quantity NUMBER)
 RETURN DATE IS
 CURSOR Check_Schedule_Roll_Types
 (p_line_id NUMBER ,p_scheduled_completion_date DATE)
  IS
  SELECT count(distinct(nvl(roll_forwarded_flag,-1)))
  FROM wip_flow_schedules
  WHERE organization_id = p_organization_id
  AND line_id = p_line_id
        /** Forward ported bug 3055939 */
  AND scheduled_completion_date >= flm_timezone.client00_in_server(p_scheduled_completion_date)  --fix bug#3170105
  AND scheduled_completion_date < flm_timezone.client00_in_server(p_scheduled_completion_date+1);  --fix bug#3170105

 CURSOR Check_Schedule_Distinct_Type
 (p_line_id NUMBER ,p_scheduled_completion_date DATE)
  IS
  SELECT distinct(nvl(roll_forwarded_flag,-1))
  FROM wip_flow_schedules
  WHERE organization_id = p_organization_id
  AND line_id = p_line_id
        /** Forward ported bug 3055939 */
  AND scheduled_completion_date >= flm_timezone.client00_in_server(p_scheduled_completion_date)  --fix bug#3170105
  AND scheduled_completion_date < flm_timezone.client00_in_server(p_scheduled_completion_date+1);  --fix bug#3170105

  CURSOR Line_Details(p_line_id NUMBER)
   IS SELECT START_TIME,MAXIMUM_RATE FROM wip_lines
   WHERE organization_id = p_organization_id
   AND LINE_ID = p_line_id;

 CURSOR Check_Last_Schedule
 (p_line_id NUMBER ,p_scheduled_completion_date DATE)
  IS
  SELECT MAX(scheduled_completion_date)
  FROM wip_flow_schedules
  WHERE organization_id = p_organization_id
  AND line_id = p_line_id
        /** Forward ported bug 3055939 */
  AND scheduled_completion_date >= flm_timezone.client00_in_server(p_scheduled_completion_date)  --fix bug#3170105
  AND scheduled_completion_date < flm_timezone.client00_in_server(p_scheduled_completion_date+1);  --fix bug#3170105

   l_type_count           NUMBER:=0;
   l_distinct_type        NUMBER:=0;
   l_start_time           NUMBER:=0;
   l_time_flag            NUMBER:=0;
   l_time                 NUMBER:=0;
   l_maximum_rate         NUMBER:=0;
   l_schedule_date        DATE;
   l_last_schedule_date   DATE;
BEGIN
  OPEN Check_Schedule_Roll_Types(p_line_id, p_scheduled_completion_date);  --fix bug#3170105
    FETCH Check_Schedule_Roll_Types INTO l_type_count;
    IF l_type_count = 0 THEN
      l_time_flag := 2;--meaning no schedules
    ELSIF l_type_count =1 THEN
      OPEN Check_Schedule_Distinct_Type(
      p_line_id, p_scheduled_completion_date);  --fix bug#3170105
      FETCH Check_Schedule_Distinct_Type INTO l_distinct_type;
      CLOSE Check_Schedule_Distinct_Type;
      IF l_distinct_type = 2 THEN
        l_time_flag := 1;
        /*meaning schedules are present but
        all are created in this session.*/
      ELSE
        l_time_flag := 0;
        /*meaning schedules are present and
        all are created previously.*/
      END IF;
    ELSIF l_type_count > 1 THEN
        l_time_flag := 0;
        /*meaning schedules are present and
        may be some are created previously.*/
    END IF;

    IF l_time_flag <> 0 THEN
      OPEN Line_Details(p_line_id);
      FETCH Line_Details INTO l_start_time,l_maximum_rate;

      --TZ 3832684: Calculate completion date in Client TZ.
      --l_schedule_date and p_completion_date should be in Client00 time.
      --If p_completion_date is not in Client00 time, which means that there are
      --FS in the date, then l_time_flag=0 and thus, will not get into this IF flow.
      if flm_timezone.g_enabled then
        l_start_time := flm_timezone.g_client_start_time;
	l_schedule_date := flm_timezone.server_to_client(p_scheduled_completion_date);
      else
        l_schedule_date := p_scheduled_completion_date;  --fix bug#3170105
      end if;

      IF l_time_flag = 1 THEN
        OPEN Check_Last_Schedule(p_line_id,p_scheduled_completion_date);  --fix bug#3170105
        FETCH Check_Last_Schedule INTO l_last_schedule_date;

	--TZ 3832684: calculate completion date in Client TZ
	if flm_timezone.g_enabled then
	  l_last_schedule_date := flm_timezone.server_to_client(l_last_schedule_date);
	end if;

        --TZ 3832684: better way to get the seconds in Client time
	l_start_time := to_char(l_last_schedule_date,'SSSSS');

	CLOSE Check_Last_Schedule;
      END IF;
      l_time := l_start_time + 60*60*(p_quantity/l_maximum_rate);

      --fix bug#3170105 not yet
      MRP_UTIL.MRP_LOG('the client date before :'||to_char(l_schedule_date,'DD-MON-YYYY HH24:MI:SS'));

      --TZ 3832684: Will have to do the time addition in Client TZ doe to some corner cases
      --The p_completion_date is assumed to be in Client00_in_server
      l_schedule_date := l_schedule_date+(l_time/86400);

      MRP_UTIL.MRP_LOG('the client date after :'||to_char(l_schedule_date,'DD-MON-YYYY HH24:MI:SS'));
      --end of fix bug#3170105

      --TZ 3832684: conversion back to server to be passed back to caller
      if flm_timezone.g_enabled then
        l_schedule_date := flm_timezone.client_to_server(l_schedule_date);
        MRP_UTIL.MRP_LOG('the datetime after conv :'||to_char(l_schedule_date,'DD-MON-YY HH24:MI:SS'));
      end if;

      CLOSE Line_Details;
    ELSE
        l_schedule_date := p_scheduled_completion_date;  --fix bug#3170105
    END IF;
  CLOSE Check_Schedule_Roll_Types;
  return l_schedule_date;
END;

FUNCTION Close_All_Past_Schedules
 RETURN INTEGER IS
  l_where_clause		VARCHAR2(2000);
  l_item_where_clause		VARCHAR2(2000);
  l_cat_where_clause		VARCHAR2(2000);
  l_cat_sql 			VARCHAR2(2000);
  l_cat_table_sql		VARCHAR2(2000);
  l_sql_stmt			VARCHAR2(2000) := NULL;
  l_rows_processed		NUMBER;
  l_cursor_name			INTEGER := NULL;

  l_log_message			VARCHAR2(2000);
  l_return			BOOLEAN;
BEGIN

  -- begin new binds
  flm_util.init_bind;

  -- Construct where clause
  IF p_from_line IS NOT NULL and p_to_line IS NOT NULL THEN
   l_where_clause := ' and line.line_code between :from_line and :to_line ';
    flm_util.add_bind(':from_line', p_from_line);
    flm_util.add_bind(':to_line', p_to_line);
  END IF;

  IF p_from_item IS NOT NULL and p_to_item IS NOT NULL THEN
    -- Call procedure to construct item_where_clause
    l_return := flm_util.Item_Where_Clause(
                        p_from_item,
                        p_to_item,
                        'msi',
                        l_item_where_clause,
                        l_err_buf);

    IF NOT l_return THEN
      -- English because unexpected error
      l_log_message := 'Problem constructing item_where_clause';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;
    END IF;
    l_item_where_clause := ' AND ' || l_item_where_clause;
  END IF;

  IF (p_from_category IS NOT NULL OR p_to_category IS NOT NULL)
  AND p_category_set_id IS NOT NULL THEN

    l_return := flm_util.Category_Where_Clause(
                        p_from_category,
                        p_to_category,
                        'cat',
                        p_category_structure_id,
                        l_cat_where_clause,
                        l_err_buf);

    IF NOT l_return THEN
      -- English because unexpected error
      l_log_message := 'Problem constructing category_where_clause';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;
    END IF;
    l_cat_where_clause := ' AND fs.primary_item_id in (select ' ||
		' inventory_item_id from mtl_item_categories mic, '||
		' mtl_categories cat where ' ||
                ' cat.category_id = mic.category_id ' ||
                ' and mic.organization_id = :cat_organization_id ' ||
		' and mic.category_set_id = :cat_category_set_id ' ||
		' and ' || l_cat_where_clause || ')';
    flm_util.add_bind(':cat_organization_id', p_organization_id);
    flm_util.add_bind(':cat_category_set_id', p_category_set_id);
  END IF;

  l_where_clause := l_where_clause || l_item_where_clause ||
		l_cat_where_clause;

  IF p_category_set_id IS NOT NULL THEN
    l_cat_table_sql := ' mtl_item_categories mic, ';
    l_cat_sql :=
    ' and mic.inventory_item_id = fs.primary_item_id ' ||
    ' and mic.organization_id = fs.organization_id ' ||
    ' and mic.category_set_id = :cat2_category_set_id ';
    flm_util.add_bind(':cat2_category_set_id', p_category_set_id);
  ELSE
    l_cat_table_sql := ' ';
    l_cat_sql := ' ';
  END IF;

/* Bug 2998385: Added not exists from MTL_TRANSACTIONS_INTERFACE */
  -- Define the select statement
  --fix bug#3170105
  l_sql_stmt :=
    'SELECT fs.wip_entity_id ' ||
    ' FROM wip_lines line, '||
    l_cat_table_sql ||
    ' mtl_system_items_kfv msi, '||
    ' wip_flow_schedules fs ' ||
    ' WHERE fs.organization_id = to_char( :organization_id) ' ||
    l_where_clause ||
    ' AND fs.scheduled_completion_date < flm_timezone.sysdate00_in_server' ||
    ' and line.line_id = fs.line_id ' ||
    ' and line.organization_id = fs.organization_id '||
    ' and nvl(fs.status ,0) = 1 '||
    l_cat_sql ||
    ' and msi.inventory_item_id = fs.primary_item_id ' ||
    ' and msi.organization_id = fs.organization_id ' ||
    ' and not exists ( select 1 from mtl_transactions_interface ' ||
    '                   where transaction_source_id = fs.wip_entity_id ' ||
    '                     and organization_id = fs.organization_id '  ||
    '                     and transaction_source_type_id = 5 ' || -- perf bug 4911894
    '                     and transaction_action_id in (1, 27, 30, 31, 32, 33, 34)  ) ';


  flm_util.add_bind(':organization_id', p_organization_id);

  -- get the cursor
  l_cursor_name := dbms_sql.open_cursor;

  -- parse the sql statement
  dbms_sql.parse(l_cursor_name, l_sql_stmt, dbms_sql.native);
  flm_util.do_binds(l_cursor_name);

  dbms_sql.define_column(l_cursor_name, 1, l_flow_schedule_rec.wip_entity_id);


  -- execute the sql statement
  -- execute will return zero rows processed since this is just a select
  -- statement.  Need a variable for the return value.
  l_rows_processed := dbms_sql.execute(l_cursor_name);

  return(l_cursor_name);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
      RETCODE := G_ERROR;
      FND_MESSAGE.set_name('MRP','MRP_NO_ROLL_RECORDS');
      ERRBUF := FND_MESSAGE.get;
      l_log_message := FND_MESSAGE.get;
      MRP_UTIL.MRP_LOG(l_log_message);
      RETURN NULL;

  WHEN OTHERS THEN
      -- English because unexpected error
      l_log_message := 'Problem Closing all past Schedules';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_err_buf := 'Unexpected SQL Error: '||sqlerrm;
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;
      RETURN NULL;
END Close_All_Past_Schedules;

FUNCTION Create_Cursor_WOD(p_from_start_date IN DATE, p_from_end_date IN DATE)  --fix bug#3170105
  RETURN INTEGER IS

  l_where_clause		VARCHAR2(2000);
  l_item_where_clause		VARCHAR2(2000);
  l_cat_where_clause		VARCHAR2(2000);
  l_log_message			VARCHAR2(2000);
  l_sql_stmt			VARCHAR2(2000) := NULL;
  l_return			BOOLEAN;
  l_rows_processed		NUMBER;
  l_cursor_name			INTEGER := NULL;
  fs_report_rec			REPORT_REC_TYPE;
  l_cat_sql                     VARCHAR2(2000);
  l_cat_table_sql		VARCHAR2(2000);

BEGIN

  -- new binds
  flm_util.init_bind;

  -- Construct where clause
  IF p_from_line IS NOT NULL and p_to_line IS NOT NULL THEN
   l_where_clause := ' and line.line_code between :from_line and :to_line ';
    flm_util.add_bind(':from_line', p_from_line);
    flm_util.add_bind(':to_line', p_to_line);
  END IF;

  IF p_from_item IS NOT NULL and p_to_item IS NOT NULL THEN
    -- Call procedure to construct item_where_clause
    l_return := flm_util.Item_Where_Clause(
                        p_from_item,
                        p_to_item,
                        'msi',
                        l_item_where_clause,
                        l_err_buf);

    IF NOT l_return THEN
      -- English because unexpected error
      l_log_message := 'Problem constructing item_where_clause';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;
    END IF;
    l_item_where_clause := ' AND ' || l_item_where_clause;
  END IF;

  IF (p_from_category IS NOT NULL OR p_to_category IS NOT NULL)
  AND p_category_set_id IS NOT NULL THEN
    l_return := flm_util.Category_Where_Clause(
                        p_from_category,
                        p_to_category,
                        'cat',
                        p_category_structure_id,
                        l_cat_where_clause,
                        l_err_buf);

    IF NOT l_return THEN
      -- English because unexpected error
      l_log_message := 'Problem constructing category_where_clause';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;
    END IF;
    l_cat_where_clause := ' AND fs.primary_item_id in (select ' ||
		' inventory_item_id from mtl_item_categories mic, '||
		' mtl_categories cat where ' ||
                ' cat.category_id = mic.category_id ' ||
                ' and mic.organization_id = :cat_organization_id ' ||
		' and mic.category_set_id = :cat_category_set_id ' ||
		' and ' || l_cat_where_clause || ')';
    flm_util.add_bind(':cat_organization_id', p_organization_id);
    flm_util.add_bind(':cat_category_set_id', p_category_set_id);
  END IF;

  l_where_clause := l_where_clause || l_item_where_clause ||
		l_cat_where_clause;

  -- Define the select statement
  IF p_category_set_id IS NOT NULL THEN
    l_cat_table_sql := ' mtl_item_categories mic, ';
    l_cat_sql :=
    ' and mic.inventory_item_id = fs.primary_item_id ' ||
    ' and mic.organization_id = fs.organization_id ' ||
    ' and mic.category_set_id = :cat2_category_set_id ';
    flm_util.add_bind(':cat2_category_set_id', p_category_set_id);
  ELSE
    l_cat_table_sql := ' ';
    l_cat_sql := ' ';
  END IF;

/* Bug 2998385: Added not exists from MTL_TRANSACTIONS_INTERFACE */
  --fix bug#3170105
  l_sql_stmt :=
    ' SELECT fs.line_id, line.line_code, fs.primary_item_id, ' ||
    ' msi.concatenated_segments,null' ||
    ' ,sum(nvl(fs.planned_quantity,0)), ' ||
    ' sum(nvl(fs.quantity_completed,0)) ' ||
    ' FROM wip_lines line, '||
    l_cat_table_sql ||
    ' mtl_system_items_kfv msi, '||
    ' wip_flow_schedules fs ' ||
    ' WHERE fs.organization_id = to_char( :organization_id ) ' ||
    l_where_clause ||
    ' AND (nvl(fs.planned_quantity,0) - nvl(fs.quantity_completed,0)) <> 0 ' ||
    ' AND fs.scheduled_completion_date between ' ||
    '     :from_start_date ' ||
    '     and :from_end_date ' ||
    ' and line.line_id = fs.line_id ' ||
    ' and fs.demand_source_header_id IS NULL '||
    ' and line.organization_id = fs.organization_id '||
  --  ' and nvl(fs.status ,0) = 1 '||
    l_cat_sql ||
    ' and msi.inventory_item_id = fs.primary_item_id ' ||
    ' and msi.organization_id = fs.organization_id '||
    ' and not exists ( select 1 from mtl_transactions_interface ' ||
    '                   where transaction_source_id = fs.wip_entity_id ' ||
    '                     and organization_id = fs.organization_id '||
    '                     and transaction_source_type_id = 5 ' || -- perf bug 4911894
    '                     and transaction_action_id in (1, 27, 30, 31, 32, 33, 34)  ) ' ||
    ' group by fs.line_id, line.line_code, fs.primary_item_id, ' ||
    ' msi.concatenated_segments ' ||
    ' order by line.line_code, msi.concatenated_segments ' ;

  flm_util.add_bind(':organization_id', p_organization_id);
  flm_util.add_bind(':from_start_date', p_from_start_date);
  flm_util.add_bind(':from_end_date', p_from_end_date+1-1/(24*60*60));
  --end of fix bug#3170105

  -- get the cursor
  l_cursor_name := dbms_sql.open_cursor;

  -- parse the sql statement
  dbms_sql.parse(l_cursor_name, l_sql_stmt, dbms_sql.native);
  flm_util.do_binds(l_cursor_name);

  -- define columns
  dbms_sql.define_column(l_cursor_name, 1, fs_report_rec.line_id);
  dbms_sql.define_column(l_cursor_name, 2, fs_report_rec.line_code, 10);
  dbms_sql.define_column(l_cursor_name, 3, fs_report_rec.primary_item_id);
  dbms_sql.define_column(l_cursor_name, 4, fs_report_rec.item, 2000);
  dbms_sql.define_column(l_cursor_name, 5, fs_report_rec.schedule_group_id);
  dbms_sql.define_column(l_cursor_name, 6, fs_report_rec.planned_quantity);
  dbms_sql.define_column(l_cursor_name, 7, fs_report_rec.quantity_completed);


  -- execute the sql statement
  -- execute will return zero rows processed since this is just a select
  -- statement.  Need a variable for the return value.
  l_rows_processed := dbms_sql.execute(l_cursor_name);

  -- return cursor name
  return(l_cursor_name);

EXCEPTION

  WHEN NO_DATA_FOUND THEN

      RETCODE := G_ERROR;
      FND_MESSAGE.set_name('MRP','MRP_NO_ROLL_RECORDS');
      ERRBUF := FND_MESSAGE.get;
      l_log_message := FND_MESSAGE.get;
      MRP_UTIL.MRP_LOG(l_log_message);

      RETURN NULL;

  WHEN OTHERS THEN

      -- English because unexpected error
      l_log_message := 'Problem constructing cursor';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_err_buf := 'Unexpected SQL Error: '||sqlerrm;
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;

      RETURN NULL;

END Create_Cursor_WOD;

FUNCTION Create_Cursor_WD (p_from_start_date IN DATE, p_from_end_date IN DATE)  --fix bug#3170105
  RETURN INTEGER IS

  l_where_clause		VARCHAR2(2000);
  l_item_where_clause		VARCHAR2(2000);
  l_cat_where_clause		VARCHAR2(2000);
  l_log_message			VARCHAR2(2000);
  l_sql_stmt			VARCHAR2(32000) := NULL;
  l_return			BOOLEAN;
  l_rows_processed		NUMBER;
  l_cursor_name			INTEGER := NULL;
  fs_report_rec			REPORT_REC_TYPE;
  l_select			VARCHAR2(100);
  l_cat_sql                     VARCHAR2(2000);
  l_cat_table_sql               VARCHAR2(2000);

BEGIN

  -- new binds
  flm_util.init_bind;

  -- Construct where clause
  IF p_from_line IS NOT NULL and p_to_line IS NOT NULL THEN
    l_where_clause := ' and line.line_code between :from_line and :to_line ';
    flm_util.add_bind(':from_line', p_from_line);
    flm_util.add_bind(':to_line', p_to_line);
  END IF;

  IF p_from_item IS NOT NULL and p_to_item IS NOT NULL THEN
    -- Call procedure to construct item_where_clause
    l_return := flm_util.Item_Where_Clause(
                        p_from_item,
                        p_to_item,
                        'msi',
                        l_item_where_clause,
                        l_err_buf);

    IF NOT l_return THEN
      -- English because unexpected error
      l_log_message := 'Problem constructing item_where_clause';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;
    END IF;
    l_item_where_clause := ' AND ' || l_item_where_clause;
  END IF;

  IF (p_from_category IS NOT NULL OR p_to_category IS NOT NULL)
  AND p_category_set_id IS NOT NULL THEN

    l_return := flm_util.Category_Where_Clause(
                        p_from_category,
                        p_to_category,
                        'cat',
                        p_category_structure_id,
                        l_cat_where_clause,
                        l_err_buf);

    IF NOT l_return THEN
      -- English because unexpected error
      l_log_message := 'Problem constructing category_where_clause';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;
    END IF;
    l_cat_where_clause := ' AND fs.primary_item_id in (select ' ||
		' inventory_item_id from mtl_item_categories mic, '||
		' mtl_categories cat where ' ||
                ' cat.category_id = mic.category_id ' ||
                ' and mic.organization_id = :cat_organization_id ' ||
		' and mic.category_set_id = :cat_category_set_id ' ||
		' and ' || l_cat_where_clause || ')';
    flm_util.add_bind(':cat_organization_id', p_organization_id);
    flm_util.add_bind(':cat_category_set_id', p_category_set_id);
  END IF;

  l_where_clause := l_where_clause || l_item_where_clause ||
		l_cat_where_clause;

  IF p_category_set_id IS NOT NULL THEN
    l_cat_table_sql := ' mtl_item_categories mic, ';
    l_cat_sql :=
    ' and mic.inventory_item_id = fs.primary_item_id ' ||
    ' and mic.organization_id = fs.organization_id ' ||
    ' and mic.category_set_id = :cat2_category_set_id ';
    flm_util.add_bind(':cat2_category_set_id', p_category_set_id);
  ELSE
    l_cat_table_sql := ' ';
    l_cat_sql := ' ';
  END IF;

/* Bug 2998385: Added not exists from MTL_TRANSACTIONS_INTERFACE */
  -- Define the select statement
  --fix bug#3170105
  l_sql_stmt :=
    ' SELECT fs.line_id, line.line_code, fs.primary_item_id, ' ||
    ' fs.schedule_group_id,fs.schedule_number,'||
    ' fs.build_sequence,fs.demand_source_header_id,fs.demand_source_line, ' ||
    ' fs.demand_source_delivery,fs.demand_source_type,fs.demand_class, ' ||
    ' msi.concatenated_segments ' ||
    ' ,nvl(fs.planned_quantity,0), ' ||
    ' nvl(fs.quantity_completed,0), ' ||
    ' fs.MPS_SCHEDULED_COMPLETION_DATE, nvl(fs.MPS_NET_QUANTITY,0), '||
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
    ' fs.CURRENT_LINE_OPERATION, '||
    ' fs.WIP_ENTITY_ID '||
    ' FROM wip_lines line, '||
    l_cat_table_sql ||
    ' mtl_system_items_kfv msi, '||
    ' wip_flow_schedules fs ' ||
    ' WHERE fs.organization_id = to_char(:organization_id) '||
    l_where_clause ||
    ' AND (nvl(fs.planned_quantity,0) - nvl(fs.quantity_completed,0)) > 0 ' ||
    ' AND fs.scheduled_completion_date between ' ||
    '       :from_start_date ' ||
    '       and :from_end_date ' ||
    ' and line.line_id = fs.line_id ' ||
    ' and line.organization_id = fs.organization_id '||
    ' and nvl(fs.status,0) = 1 '||
    l_cat_sql ||
    ' and msi.inventory_item_id = fs.primary_item_id ' ||
    ' and msi.organization_id = fs.organization_id '||
    ' and not exists ( select 1 from mtl_transactions_interface ' ||
    '                   where transaction_source_id = fs.wip_entity_id ' ||
    '                     and organization_id = fs.organization_id ' ||
    '                     and transaction_source_type_id = 5 ' || -- perf bug 4911894
    '                     and transaction_action_id in (1, 27, 30, 31, 32, 33, 34)  ) ' ||
    ' order by line.line_code, trunc(fs.scheduled_completion_date), fs.build_sequence ';
  flm_util.add_bind(':organization_id', p_organization_id);
  flm_util.add_bind(':from_start_date', p_from_start_date);
  flm_util.add_bind(':from_end_date', p_from_end_date+1-1/(24*60*60));
  --end of fix bug#3170105
/*
   Bug 2213859 - Removed  ' order by line.line_code, msi.concatenated_segments,fs.build_sequence '
   and added a new order by above
*/
 --MRP_UTIL.MRP_LOG(l_sql_stmt);
  -- get the cursor
  l_cursor_name := dbms_sql.open_cursor;

  -- parse the sql statement
  dbms_sql.parse(l_cursor_name, l_sql_stmt, dbms_sql.native);
  flm_util.do_binds(l_cursor_name);


  -- define columns
  dbms_sql.define_column(l_cursor_name, 1, fs_report_rec.line_id);
  dbms_sql.define_column(l_cursor_name, 2, fs_report_rec.line_code, 10);
  dbms_sql.define_column(l_cursor_name, 3, fs_report_rec.primary_item_id);
  dbms_sql.define_column(l_cursor_name, 4, fs_report_rec.schedule_group_id);
  dbms_sql.define_column(l_cursor_name, 5, fs_report_rec.schedule_number,30);
  dbms_sql.define_column(l_cursor_name, 6, fs_report_rec.build_sequence);
  dbms_sql.define_column(l_cursor_name, 7,
    fs_report_rec.demand_source_header_id);
  dbms_sql.define_column(l_cursor_name, 8,
    fs_report_rec.demand_source_line,30);
  dbms_sql.define_column(l_cursor_name, 9,fs_report_rec.demand_source_delivery,
  30);
  dbms_sql.define_column(l_cursor_name, 10,fs_report_rec.demand_source_type);
  dbms_sql.define_column(l_cursor_name, 11,fs_report_rec.demand_class,30);
  dbms_sql.define_column(l_cursor_name, 12, fs_report_rec.item, 2000);
  dbms_sql.define_column(l_cursor_name, 13, fs_report_rec.planned_quantity);
  dbms_sql.define_column(l_cursor_name, 14, fs_report_rec.quantity_completed);
  -- execute the sql statement
  dbms_sql.define_column(l_cursor_name, 15,
    fs_report_rec.MPS_SCHEDULED_COMPLETION_DATE);
  dbms_sql.define_column(l_cursor_name, 16, fs_report_rec.MPS_NET_QUANTITY);
  dbms_sql.define_column(l_cursor_name, 17, fs_report_rec.BOM_REVISION,3);
  dbms_sql.define_column(l_cursor_name, 18, fs_report_rec.ROUTING_REVISION,3);
  dbms_sql.define_column(l_cursor_name, 19, fs_report_rec.BOM_REVISION_DATE);
  dbms_sql.define_column(l_cursor_name, 20,
    fs_report_rec.ROUTING_REVISION_DATE);
  dbms_sql.define_column(l_cursor_name, 21,
    fs_report_rec.ALTERNATE_BOM_DESIGNATOR,10);
  dbms_sql.define_column(l_cursor_name, 22,
    fs_report_rec.ALTERNATE_ROUTING_DESIGNATOR,10);
  dbms_sql.define_column(l_cursor_name, 23,
    fs_report_rec.COMPLETION_SUBINVENTORY,10);
  dbms_sql.define_column(l_cursor_name, 24,
    fs_report_rec.COMPLETION_LOCATOR_ID);
  dbms_sql.define_column(l_cursor_name, 25, fs_report_rec.MATERIAL_ACCOUNT);
  dbms_sql.define_column(l_cursor_name, 26,
    fs_report_rec.MATERIAL_OVERHEAD_ACCOUNT);
  dbms_sql.define_column(l_cursor_name, 27, fs_report_rec.RESOURCE_ACCOUNT);
  dbms_sql.define_column(l_cursor_name, 28,
    fs_report_rec.OUTSIDE_PROCESSING_ACCOUNT);
  dbms_sql.define_column(l_cursor_name, 29,
    fs_report_rec.MATERIAL_VARIANCE_ACCOUNT);
  dbms_sql.define_column(l_cursor_name, 30,
    fs_report_rec.RESOURCE_VARIANCE_ACCOUNT);
  dbms_sql.define_column(l_cursor_name, 31,
    fs_report_rec.OUTSIDE_PROC_VARIANCE_ACCOUNT);
  dbms_sql.define_column(l_cursor_name, 32,
    fs_report_rec.STD_COST_ADJUSTMENT_ACCOUNT);
  dbms_sql.define_column(l_cursor_name, 33, fs_report_rec.OVERHEAD_ACCOUNT);
  dbms_sql.define_column(l_cursor_name, 34,
    fs_report_rec.OVERHEAD_VARIANCE_ACCOUNT);
  dbms_sql.define_column(l_cursor_name, 35, fs_report_rec.PROJECT_ID);
  dbms_sql.define_column(l_cursor_name, 36, fs_report_rec.TASK_ID);
  dbms_sql.define_column(l_cursor_name, 37,
    fs_report_rec.ATTRIBUTE_CATEGORY,30);
  dbms_sql.define_column(l_cursor_name, 38, fs_report_rec.ATTRIBUTE1,30);
  dbms_sql.define_column(l_cursor_name, 39, fs_report_rec.ATTRIBUTE2,150);
  dbms_sql.define_column(l_cursor_name, 40, fs_report_rec.ATTRIBUTE3,150);
  dbms_sql.define_column(l_cursor_name, 41, fs_report_rec.ATTRIBUTE4,150);
  dbms_sql.define_column(l_cursor_name, 42, fs_report_rec.ATTRIBUTE5,150);
  dbms_sql.define_column(l_cursor_name, 43, fs_report_rec.ATTRIBUTE6,150);
  dbms_sql.define_column(l_cursor_name, 44, fs_report_rec.ATTRIBUTE7,150);
  dbms_sql.define_column(l_cursor_name, 45, fs_report_rec.ATTRIBUTE8,150);
  dbms_sql.define_column(l_cursor_name, 46, fs_report_rec.ATTRIBUTE9,150);
  dbms_sql.define_column(l_cursor_name, 47, fs_report_rec.ATTRIBUTE10,150);
  dbms_sql.define_column(l_cursor_name, 48, fs_report_rec.ATTRIBUTE11,150);
  dbms_sql.define_column(l_cursor_name, 49, fs_report_rec.ATTRIBUTE12,150);
  dbms_sql.define_column(l_cursor_name, 50, fs_report_rec.ATTRIBUTE13,150);
  dbms_sql.define_column(l_cursor_name, 51, fs_report_rec.ATTRIBUTE14,150);
  dbms_sql.define_column(l_cursor_name, 52, fs_report_rec.ATTRIBUTE15,150);
  dbms_sql.define_column(l_cursor_name, 53, fs_report_rec.KANBAN_CARD_ID);
  dbms_sql.define_column(l_cursor_name, 54, fs_report_rec.END_ITEM_UNIT_NUMBER,30);
  dbms_sql.define_column(l_cursor_name, 55, fs_report_rec.CURRENT_LINE_OPERATION);
  dbms_sql.define_column(l_cursor_name, 56, fs_report_rec.WIP_ENTITY_ID);
  -- execute will return zero rows processed since this is just a select
  -- statement.  Need a variable for the return value.
  l_rows_processed := dbms_sql.execute(l_cursor_name);

  -- return cursor name
  return(l_cursor_name);

EXCEPTION

  WHEN NO_DATA_FOUND THEN

      RETCODE := G_ERROR;
      FND_MESSAGE.set_name('MRP','MRP_NO_ROLL_RECORDS');
      ERRBUF := FND_MESSAGE.get;
      l_log_message := FND_MESSAGE.get;
      MRP_UTIL.MRP_LOG(l_log_message);

      RETURN NULL;

  WHEN OTHERS THEN

      -- English because unexpected error
      l_log_message := 'Problem constructing cursor';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_err_buf := 'Unexpected SQL Error: '||sqlerrm;
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;

      RETURN NULL;

END Create_Cursor_WD;

FUNCTION Close_Single_Schedule_WithID ( p_wip_entity_id NUMBER,
  p_organization_id NUMBER) RETURN BOOLEAN IS

  l_log_message			VARCHAR2(2000);
BEGIN

  UPDATE WIP_FLOW_SCHEDULES SET
  status = 2 , date_closed = flm_timezone.sysdate00_in_server  --fix bug#3170105
  WHERE wip_entity_id = p_wip_entity_id
  AND organization_id = p_organization_id;

  return TRUE;
EXCEPTION

  WHEN NO_DATA_FOUND THEN

      RETCODE := G_ERROR;
      FND_MESSAGE.set_name('MRP','MRP_NO_ROLL_RECORDS');
      ERRBUF := FND_MESSAGE.get;
      l_log_message := FND_MESSAGE.get;
      MRP_UTIL.MRP_LOG(l_log_message);

      RETURN FALSE;

  WHEN OTHERS THEN

      -- English because unexpected error
      l_log_message := 'Problem Closing Schedule';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_err_buf := 'Unexpected SQL Error: '||sqlerrm;
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;

      RETURN FALSE;

END Close_Single_Schedule_WithId;

FUNCTION Close_Single_Schedule ( p_schedule_number VARCHAR2,
  p_organization_id NUMBER) RETURN BOOLEAN IS

  l_log_message			VARCHAR2(2000);
  l_sql_stmt			VARCHAR2(2000) := NULL;
  l_return			BOOLEAN;
  l_rows_processed		NUMBER;
  l_cursor_name			INTEGER := NULL;
  fs_report_rec			REPORT_REC_TYPE;
  l_select			VARCHAR2(100);
BEGIN

  UPDATE WIP_FLOW_SCHEDULES SET
  status = 2 , date_closed = flm_timezone.sysdate00_in_server  --fix bug#3170105
  WHERE schedule_number = p_schedule_number
  AND organization_id = p_organization_id;

  return TRUE;
EXCEPTION

  WHEN NO_DATA_FOUND THEN

      RETCODE := G_ERROR;
      FND_MESSAGE.set_name('MRP','MRP_NO_ROLL_RECORDS');
      ERRBUF := FND_MESSAGE.get;
      l_log_message := FND_MESSAGE.get;
      MRP_UTIL.MRP_LOG(l_log_message);

      RETURN FALSE;

  WHEN OTHERS THEN

      -- English because unexpected error
      l_log_message := 'Problem Closing Schedule';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_err_buf := 'Unexpected SQL Error: '||sqlerrm;
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;

      RETURN FALSE;

END Close_Single_Schedule;


FUNCTION Create_Relieve_Cursor(p_from_start_date IN DATE, p_from_end_date IN DATE)
  RETURN INTEGER IS  --fix bug#3170105

  l_where_clause                VARCHAR2(2000);
  l_item_where_clause           VARCHAR2(2000);
  l_cat_where_clause            VARCHAR2(2000);
  l_log_message                 VARCHAR2(2000);
  l_sql_stmt                    VARCHAR2(2000) := NULL;
  l_return                      BOOLEAN;
  l_rows_processed              NUMBER;
  l_cursor_name                 INTEGER := NULL;
  l_wip_entity_id               NUMBER;
  l_select                      VARCHAR2(2000);
  l_cat_sql                     VARCHAR2(2000);
  l_cat_table_sql               VARCHAR2(2000);

BEGIN

  -- new binds
  flm_util.init_bind;

  -- Construct where clause
  IF p_from_line IS NOT NULL and p_to_line IS NOT NULL THEN
   l_where_clause := ' and line.line_code between :from_line and :to_line ';
    flm_util.add_bind(':from_line', p_from_line);
    flm_util.add_bind(':to_line', p_to_line);
  END IF;

  IF p_from_item IS NOT NULL and p_to_item IS NOT NULL THEN
    -- Call procedure to construct item_where_clause
    l_return := flm_util.Item_Where_Clause(
                        p_from_item,
                        p_to_item,
                        'msi',
                        l_item_where_clause,
                        l_err_buf);

    IF NOT l_return THEN
      -- English because unexpected error
      l_log_message := 'Problem constructing item_where_clause';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;
    END IF;
    l_item_where_clause := ' AND ' || l_item_where_clause;
  END IF;

  IF (p_from_category IS NOT NULL OR p_to_category IS NOT NULL)
  AND p_category_set_id IS NOT NULL THEN

    l_return := flm_util.Category_Where_Clause(
                        p_from_category,
                        p_to_category,
                        'cat',
                        p_category_structure_id,
                        l_cat_where_clause,
                        l_err_buf);

    IF NOT l_return THEN
      -- English because unexpected error
      l_log_message := 'Problem constructing category_where_clause';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;
    END IF;
    l_cat_where_clause := ' AND fs.primary_item_id in (select ' ||
                ' inventory_item_id from mtl_item_categories mic, '||
                ' mtl_categories cat where ' ||
                ' cat.category_id = mic.category_id ' ||
                ' and mic.organization_id = :cat_organization_id ' ||
                ' and mic.category_set_id = :cat_category_set_id ' ||
                ' and ' || l_cat_where_clause || ')';
    flm_util.add_bind(':cat_organization_id', p_organization_id);
    flm_util.add_bind(':cat_category_set_id', p_category_set_id);
  END IF;

  l_where_clause := l_where_clause || l_item_where_clause ||
                l_cat_where_clause;

  IF p_spread_qty = 2 THEN
    l_select :=  ' AND (nvl(fs.planned_quantity,0) - nvl(fs.quantity_completed,0)) > 0 AND nvl(fs.status,0) = 1 ';
  ELSIF p_spread_qty = 1 THEN
    l_select :=  ' AND (nvl(fs.planned_quantity,0) - nvl(fs.quantity_completed,0)) <> 0  AND fs.demand_source_header_id IS NULL ';
  END IF;

  IF p_category_set_id IS NOT NULL THEN
    l_cat_table_sql := ' mtl_item_categories mic, ';
    l_cat_sql :=
    ' and mic.inventory_item_id = fs.primary_item_id ' ||
    ' and mic.organization_id = fs.organization_id ' ||
    ' and mic.category_set_id = :cat2_category_set_id ';
    flm_util.add_bind(':cat2_category_set_id', p_category_set_id);
  ELSE
    l_cat_table_sql := ' ';
    l_cat_sql := ' ';
  END IF;

/* Bug 2998385: Added not exists from MTL_TRANSACTIONS_INTERFACE */
  -- Define the select statement
  --fix bug#3170105
  l_sql_stmt :=
    ' SELECT fs.wip_entity_id ' ||
    ' FROM wip_lines line, '||
    l_cat_table_sql ||
    ' mtl_system_items_kfv msi, '||
    ' wip_flow_schedules fs ' ||
    ' WHERE fs.organization_id = to_char(:organization_id) ' ||
    l_where_clause ||
    l_select ||
    ' AND fs.scheduled_completion_date between ' ||
    '      :from_start_date ' ||
    '      and :from_end_date ' ||
    ' and line.line_id = fs.line_id ' ||
    ' and line.organization_id = fs.organization_id '||
    l_cat_sql ||
    ' and msi.inventory_item_id = fs.primary_item_id ' ||
    ' and msi.organization_id = fs.organization_id ' ||
    ' and not exists ( select 1 from mtl_transactions_interface ' ||
    '                   where transaction_source_id = fs.wip_entity_id ' ||
    '                     and organization_id = fs.organization_id  ' ||
    '                     and transaction_source_type_id = 5 ' || -- perf bug 4911894
    '                     and transaction_action_id in (1, 27, 30, 31, 32, 33, 34)  ) ';

  flm_util.add_bind(':organization_id', p_organization_id);
  flm_util.add_bind(':from_start_date', p_from_start_date);
  flm_util.add_bind(':from_end_date', p_from_end_date+1-1/(24*60*60));
  --end of fix bug#3170105x

  -- get the cursor
  l_cursor_name := dbms_sql.open_cursor;

  -- parse the sql statement
  dbms_sql.parse(l_cursor_name, l_sql_stmt, dbms_sql.native);
  flm_util.do_binds(l_cursor_name);

  -- define columns
  dbms_sql.define_column(l_cursor_name, 1, l_wip_entity_id);


  -- execute the sql statement
  -- execute will return zero rows processed since this is just a select
  -- statement.  Need a variable for the return value.
  l_rows_processed := dbms_sql.execute(l_cursor_name);

  -- return cursor name
  return(l_cursor_name);

EXCEPTION

  WHEN NO_DATA_FOUND THEN

      RETCODE := G_ERROR;
      FND_MESSAGE.set_name('MRP','MRP_NO_ROLL_RECORDS');
      ERRBUF := FND_MESSAGE.get;
      l_log_message := FND_MESSAGE.get;
      MRP_UTIL.MRP_LOG(l_log_message);

      RETURN NULL;

  WHEN OTHERS THEN

      -- English because unexpected error
      l_log_message := 'Problem constructing Relieve cursor';
      MRP_UTIL.MRP_LOG(l_log_message);
      l_err_buf := 'Unexpected SQL Error: '||sqlerrm;
      l_log_message := l_err_buf;
      MRP_UTIL.MRP_LOG(l_log_message);
      RAISE unexpected_error;

      RETURN NULL;

END Create_Relieve_Cursor;

PROCEDURE initialize_report_WOD(p_query_id OUT NOCOPY NUMBER
  ,p_from_start_date IN DATE, p_from_end_date IN DATE
  ,p_to_start_date IN DATE, p_to_end_date IN DATE) IS  --fix bug#3170105

BEGIN
    SELECT mrp_form_query_s.nextval
    INTO p_query_id
    FROM DUAL;

  IF (p_from_category IS NOT NULL OR p_to_category IS NOT NULL)
     AND p_category_set_id IS NOT NULL THEN

/* Bug 2998385: Added not exists from MTL_TRANSACTIONS_INTERFACE */
    INSERT INTO mrp_form_query
        (query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        number1,
        number2,
        number3,
        date1,
        number4,
        number5,
        date2,
        number6,
        number7,
        number10)
    SELECT p_query_id,
        sysdate,
        1,
        sysdate,
        1,
        fs1.line_id,
        fs1.primary_item_id,
        null,
        --fs1.schedule_group_id,
        trunc(flm_timezone.server_to_client(fs1.scheduled_completion_date)),  --fix bug#3170105
        sum(fs1.planned_quantity),
        sum(fs1.quantity_completed),
        trunc(flm_timezone.server_to_client(fs1.scheduled_completion_date))  --fix bug#3170105
        +floor(p_to_start_date-p_from_start_date),
        NULL,
        0,
        fs1.organization_id
    FROM wip_lines wl,
        mtl_system_items_kfv kfv,
        mtl_categories_kfv cat,
        mtl_item_categories mic,
        wip_flow_schedules fs1
    WHERE wl.line_id = fs1.line_id
    AND fs1.demand_source_header_id IS NULL
  --  AND nvl(fs1.closed,0) = 0
    AND wl.organization_id = fs1.organization_id
    AND wl.line_code
        BETWEEN NVL(p_from_line,wl.line_code) AND NVL(p_to_line,wl.line_code)
    AND kfv.inventory_item_id = fs1.primary_item_id
    AND kfv.organization_id = fs1.organization_id
    AND kfv.concatenated_segments
        BETWEEN NVL(p_from_item,kfv.concatenated_segments) AND
        NVL(p_to_item,kfv.concatenated_segments)
    AND mic.inventory_item_id = fs1.primary_item_id
    AND mic.organization_id = fs1.organization_id
    AND mic.category_set_id = p_category_set_id
    AND cat.category_id = mic.category_id
    AND cat.concatenated_segments BETWEEN
        NVL(p_from_category,cat.concatenated_segments)
        AND NVL(p_to_category,cat.concatenated_segments)
    AND fs1.scheduled_completion_date  --fix bug#3170105
        BETWEEN p_from_start_date AND
                p_from_end_date+1-1/(24*60*60)
    AND fs1.organization_id = p_organization_id
    AND not exists ( select 1 from mtl_transactions_interface
                      where transaction_source_id = fs1.wip_entity_id
                        and organization_id = fs1.organization_id
                        and transaction_source_type_id = 5 -- perf bug 4911894
                        and transaction_action_id in (1, 27, 30, 31, 32, 33, 34) )
    GROUP BY fs1.line_id,
        fs1.primary_item_id,
        --fs1.schedule_group_id,
	trunc(flm_timezone.server_to_client(fs1.scheduled_completion_date)),--bug 3827600
        --floor(fs1.scheduled_completion_date-p_from_start_date),  --fix bug#3170105
        fs1.organization_id;

  ELSIF  p_category_set_id IS NOT NULL THEN

/* Bug 2998385: Added not exists from MTL_TRANSACTIONS_INTERFACE */
    INSERT INTO mrp_form_query
        (query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        number1,
        number2,
        number3,
        date1,
        number4,
        number5,
        date2,
        number6,
        number7,
        number10)
    SELECT p_query_id,
        sysdate,
        1,
        sysdate,
        1,
        fs1.line_id,
        fs1.primary_item_id,
        null,
        --fs1.schedule_group_id,
        trunc(flm_timezone.server_to_client(fs1.scheduled_completion_date)),  --fix bug#3170105
        sum(fs1.planned_quantity),
        sum(fs1.quantity_completed),
        trunc(flm_timezone.server_to_client(fs1.scheduled_completion_date))  --fix bug#3170105
        +floor(p_to_start_date-p_from_start_date),
        NULL,
        0,
        fs1.organization_id
    FROM wip_lines wl,
        mtl_system_items_kfv kfv,
        mtl_item_categories mic,
        wip_flow_schedules fs1
    WHERE wl.line_id = fs1.line_id
    AND fs1.demand_source_header_id IS NULL
  --  AND nvl(fs1.closed,0) = 0
    AND wl.organization_id = fs1.organization_id
    AND wl.line_code
        BETWEEN NVL(p_from_line,wl.line_code) AND NVL(p_to_line,wl.line_code)
    AND kfv.inventory_item_id = fs1.primary_item_id
    AND kfv.organization_id = fs1.organization_id
    AND kfv.concatenated_segments
        BETWEEN NVL(p_from_item,kfv.concatenated_segments) AND
        NVL(p_to_item,kfv.concatenated_segments)
    AND mic.inventory_item_id = fs1.primary_item_id
    AND mic.organization_id = fs1.organization_id
    AND mic.category_set_id = p_category_set_id
    AND fs1.scheduled_completion_date  --fix bug#3170105
        BETWEEN p_from_start_date AND
                p_from_end_date+1-1/(24*60*60)
    AND fs1.organization_id = p_organization_id
    AND not exists ( select 1 from mtl_transactions_interface
                      where transaction_source_id = fs1.wip_entity_id
                        and organization_id = fs1.organization_id
                        and transaction_source_type_id = 5 -- perf bug 4911894
                        and transaction_action_id in (1, 27, 30, 31, 32, 33, 34) )
    GROUP BY fs1.line_id,
        fs1.primary_item_id,
        --fs1.schedule_group_id,
	trunc(flm_timezone.server_to_client(fs1.scheduled_completion_date)),--bug 3827600
        --floor(fs1.scheduled_completion_date-p_from_start_date),  --fix bug#3170105
        fs1.organization_id;
  ELSE
/* Bug 2998385: Added not exists from MTL_TRANSACTIONS_INTERFACE */
    INSERT INTO mrp_form_query
        (query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        number1,
        number2,
        number3,
        date1,
        number4,
        number5,
        date2,
        number6,
        number7,
        number10)
    SELECT p_query_id,
        sysdate,
        1,
        sysdate,
        1,
        fs1.line_id,
        fs1.primary_item_id,
        null,
        --fs1.schedule_group_id,
        trunc(flm_timezone.server_to_client(fs1.scheduled_completion_date)),  --fix bug#3170105
        sum(fs1.planned_quantity),
        sum(fs1.quantity_completed),
        trunc(flm_timezone.server_to_client(fs1.scheduled_completion_date))  --fix bug#3170105
        +floor(p_to_start_date-p_from_start_date),
        NULL,
        0,
        fs1.organization_id
    FROM wip_lines wl,
        mtl_system_items_kfv kfv,
        wip_flow_schedules fs1
    WHERE wl.line_id = fs1.line_id
    AND fs1.demand_source_header_id IS NULL
  --  AND nvl(fs1.closed,0) = 0
    AND wl.organization_id = fs1.organization_id
    AND wl.line_code
        BETWEEN NVL(p_from_line,wl.line_code) AND NVL(p_to_line,wl.line_code)
    AND kfv.inventory_item_id = fs1.primary_item_id
    AND kfv.organization_id = fs1.organization_id
    AND kfv.concatenated_segments
        BETWEEN NVL(p_from_item,kfv.concatenated_segments) AND
        NVL(p_to_item,kfv.concatenated_segments)
    AND fs1.scheduled_completion_date  --fix bug#3170105
        BETWEEN p_from_start_date AND
                p_from_end_date+1-1/(24*60*60)
    AND fs1.organization_id = p_organization_id
    AND not exists ( select 1 from mtl_transactions_interface
                      where transaction_source_id = fs1.wip_entity_id
                        and organization_id = fs1.organization_id
                        and transaction_source_type_id = 5 -- perf bug 4911894
                        and transaction_action_id in (1, 27, 30, 31, 32, 33, 34) )
    GROUP BY fs1.line_id,
        fs1.primary_item_id,
        --fs1.schedule_group_id,
	trunc(flm_timezone.server_to_client(fs1.scheduled_completion_date)),--bug 3827600
        --floor(fs1.scheduled_completion_date-p_from_start_date),  --fix bug#3170105
        fs1.organization_id;
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    NULL;

  WHEN OTHERS THEN
    ROLLBACK;
    RETCODE := G_ERROR;
    FND_MESSAGE.set_name('MRP','MRP_ROLL_FLOW_ERROR');
    ERRBUF := FND_MESSAGE.get;
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);
    l_log_message := 'Problem with initialize_report procedure';
    MRP_UTIL.MRP_LOG(l_log_message);
    l_log_message := 'Unexpected SQL Error: '||sqlerrm;

END initialize_report_WOD;

PROCEDURE initialize_report_WD(p_query_id OUT NOCOPY NUMBER
  ,p_from_start_date IN DATE, p_from_end_date IN DATE
  ,p_to_start_date IN DATE, p_to_end_date IN DATE) IS  --fix bug#3170105

BEGIN

    SELECT mrp_form_query_s.nextval
    INTO p_query_id
    FROM DUAL;

  IF (p_from_category IS NOT NULL OR p_to_category IS NOT NULL)
     AND p_category_set_id IS NOT NULL THEN

/* Bug 2998385: Added not exists from MTL_TRANSACTIONS_INTERFACE */
    INSERT INTO mrp_form_query
        (query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        number1,
        number2,
        number3,
        date1,
        number4,
        number5,
        date2,
        number6,
        number7,
        number10,
        number11)
    SELECT p_query_id,
        sysdate,
        1,
        sysdate,
        1,
        fs1.line_id,
        fs1.primary_item_id,
        fs1.schedule_group_id,
        trunc(flm_timezone.server_to_client(fs1.scheduled_completion_date)),  --fix bug#3170105
        fs1.planned_quantity,
        fs1.quantity_completed,
        flm_timezone.server_to_client(p_to_start_date),  --fix bug#3170105
        NULL,
        0,
        fs1.organization_id,
        NVL(fs1.build_sequence,0)
    FROM wip_lines wl,
        mtl_system_items_kfv kfv,
        mtl_categories_kfv cat,
        mtl_item_categories mic,
        wip_flow_schedules fs1
    WHERE wl.line_id = fs1.line_id
    AND wl.organization_id = fs1.organization_id
    AND wl.line_code
        BETWEEN NVL(p_from_line,wl.line_code) AND NVL(p_to_line,wl.line_code)
    AND kfv.inventory_item_id = fs1.primary_item_id
    AND (nvl(fs1.planned_quantity,0) - nvl(fs1.quantity_completed,0)) > 0
    AND nvl(fs1.status,0) = 1
    AND kfv.organization_id = fs1.organization_id
    AND kfv.concatenated_segments
        BETWEEN NVL(p_from_item,kfv.concatenated_segments) AND
        NVL(p_to_item,kfv.concatenated_segments)
    AND mic.inventory_item_id = fs1.primary_item_id
    AND mic.organization_id = fs1.organization_id
    AND mic.category_set_id = p_category_set_id
    AND cat.category_id = mic.category_id
    AND cat.concatenated_segments BETWEEN
        NVL(p_from_category,cat.concatenated_segments)
        AND NVL(p_to_category,cat.concatenated_segments)
    AND fs1.scheduled_completion_date  --fix bug#3170105
        BETWEEN p_from_start_date AND
                p_from_end_date+1-1/(24*60*60)
    AND fs1.organization_id = p_organization_id
    AND not exists ( select 1 from mtl_transactions_interface
                      where transaction_source_id = fs1.wip_entity_id
                        and organization_id = fs1.organization_id
                        and transaction_source_type_id = 5  -- perf bug 4911894
                        and transaction_action_id in (1, 27, 30, 31, 32, 33, 34) );

  ELSIF  p_category_set_id IS NOT NULL THEN

/* Bug 2998385: Added not exists from MTL_TRANSACTIONS_INTERFACE */
    INSERT INTO mrp_form_query
        (query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        number1,
        number2,
        number3,
        date1,
        number4,
        number5,
        date2,
        number6,
        number7,
        number10,
        number11)
    SELECT p_query_id,
        sysdate,
        1,
        sysdate,
        1,
        fs1.line_id,
        fs1.primary_item_id,
        fs1.schedule_group_id,
        trunc(flm_timezone.server_to_client(fs1.scheduled_completion_date)),  --fix bug#3170105
        fs1.planned_quantity,
        fs1.quantity_completed,
        flm_timezone.server_to_client(p_to_start_date),  --fix bug#3170105
        NULL,
        0,
        fs1.organization_id,
        NVL(fs1.build_sequence,0)
    FROM wip_lines wl,
        mtl_system_items_kfv kfv,
        mtl_item_categories mic,
        wip_flow_schedules fs1
    WHERE wl.line_id = fs1.line_id
    AND wl.organization_id = fs1.organization_id
    AND wl.line_code
        BETWEEN NVL(p_from_line,wl.line_code) AND NVL(p_to_line,wl.line_code)
    AND kfv.inventory_item_id = fs1.primary_item_id
    AND (nvl(fs1.planned_quantity,0) - nvl(fs1.quantity_completed,0)) > 0
    AND nvl(fs1.status,0) = 1
    AND kfv.organization_id = fs1.organization_id
    AND kfv.concatenated_segments
        BETWEEN NVL(p_from_item,kfv.concatenated_segments) AND
        NVL(p_to_item,kfv.concatenated_segments)
    AND mic.inventory_item_id = fs1.primary_item_id
    AND mic.organization_id = fs1.organization_id
    AND mic.category_set_id = p_category_set_id
    AND fs1.scheduled_completion_date  --fix bug#3170105
        BETWEEN p_from_start_date AND
                p_from_end_date+1-1/(24*60*60)
    AND fs1.organization_id = p_organization_id
    AND not exists ( select 1 from mtl_transactions_interface
                      where transaction_source_id = fs1.wip_entity_id
                        and organization_id = fs1.organization_id
                        and transaction_source_type_id = 5
                        and transaction_action_id in (1, 27, 30, 31, 32, 33, 34) );

  ELSE

/* Bug 2998385: Added not exists from MTL_TRANSACTIONS_INTERFACE */
    INSERT INTO mrp_form_query
        (query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        number1,
        number2,
        number3,
        date1,
        number4,
        number5,
        date2,
        number6,
        number7,
        number10,
        number11)
    SELECT p_query_id,
        sysdate,
        1,
        sysdate,
        1,
        fs1.line_id,
        fs1.primary_item_id,
        fs1.schedule_group_id,
        trunc(flm_timezone.server_to_client(fs1.scheduled_completion_date)),  --fix bug#3170105
        fs1.planned_quantity,
        fs1.quantity_completed,
        flm_timezone.server_to_client(p_to_start_date),  --fix bug#3170105
        NULL,
        0,
        fs1.organization_id,
        NVL(fs1.build_sequence,0)
    FROM wip_lines wl,
        mtl_system_items_kfv kfv,
        wip_flow_schedules fs1
    WHERE wl.line_id = fs1.line_id
    AND wl.organization_id = fs1.organization_id
    AND wl.line_code
        BETWEEN NVL(p_from_line,wl.line_code) AND NVL(p_to_line,wl.line_code)
    AND kfv.inventory_item_id = fs1.primary_item_id
    AND (nvl(fs1.planned_quantity,0) - nvl(fs1.quantity_completed,0)) > 0
    AND nvl(fs1.status,0) = 1
    AND kfv.organization_id = fs1.organization_id
    AND kfv.concatenated_segments
        BETWEEN NVL(p_from_item,kfv.concatenated_segments) AND
        NVL(p_to_item,kfv.concatenated_segments)
    AND fs1.scheduled_completion_date  --fix bug#3170105
        BETWEEN p_from_start_date AND
                p_from_end_date+1-1/(24*60*60)
    AND fs1.organization_id = p_organization_id
    AND not exists ( select 1 from mtl_transactions_interface
                      where transaction_source_id = fs1.wip_entity_id
                        and organization_id = fs1.organization_id
                        and transaction_source_type_id = 5
                        and transaction_action_id in (1, 27, 30, 31, 32, 33,34) );
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    NULL;

  WHEN OTHERS THEN
    ROLLBACK;
    RETCODE := G_ERROR;
    FND_MESSAGE.set_name('MRP','MRP_ROLL_FLOW_ERROR');
    ERRBUF := FND_MESSAGE.get;
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);
    l_log_message := 'Problem with initialize_report procedure';
    MRP_UTIL.MRP_LOG(l_log_message);
    l_log_message := 'Unexpected SQL Error: '||sqlerrm;

END initialize_report_WD;

PROCEDURE report_update_WD(p_query_id IN NUMBER,
			p_line_id IN NUMBER,
			p_item_id IN NUMBER,
                        p_schedule_group_id IN NUMBER,
			p_completion_date IN DATE,
			p_build_sequence IN NUMBER,
			p_quantity IN NUMBER,
                        p_from_start_date IN DATE,
                        p_from_end_date IN DATE,
                        p_to_start_date IN DATE,
                        p_to_end_date IN DATE) IS  --fix bug#3170105

    l_rowid             VARCHAR2(80);
    l_to_upd_qty        NUMBER := 0;

    CURSOR C1 IS
    SELECT rowid
    FROM mrp_form_query
    WHERE query_id = p_query_id
    AND number1 = p_line_id
    AND number2 = p_item_id
    AND NVL(number3,-1) = NVL(p_schedule_group_id,-1)
    AND trunc(date2) = trunc(flm_timezone.server_to_client(p_completion_date))  --fix bug#3170105
    AND NVL(number11,0) = NVL(p_build_sequence,0);
    --mrp form query dates are in client timezone

    CURSOR C2 IS
    SELECT planned_quantity
    FROM wip_flow_schedules
    WHERE   line_id = p_line_id
    AND primary_item_id = p_item_id
    AND     organization_id = p_organization_id
    AND     nvl(schedule_group_id,-1) = nvl(p_schedule_group_id,-1)
    AND NVL(build_sequence,0) = NVL(p_build_sequence,0)
    AND scheduled_completion_date between flm_timezone.client00_in_server(p_completion_date)
    AND flm_timezone.client00_in_server(p_completion_date)+1-1/(24*60*60);  --fix bug#3170105

BEGIN

    OPEN C1;
    FETCH C1 INTO l_rowid;

    IF C1%NOTFOUND THEN

/* Bug 2998385: Added not exists from MTL_TRANSACTIONS_INTERFACE */
        INSERT INTO mrp_form_query
                (query_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                number1,
                number2,
                number3,
                date1,
                number4,
                number5,
                date2,
                number6,
                number7,
                number10,
                number11)
        SELECT
                p_query_id,
                sysdate,
                1,
                sysdate,
                1,
                p_line_id,
                p_item_id,
                p_schedule_group_id,
                flm_timezone.server_to_client(p_completion_date)
                -floor(p_to_start_date-p_from_start_date),  --fix bug#3170105
                0,
                0,
                flm_timezone.server_to_client(p_completion_date),  --fix bug#3170105
                0,
                p_quantity,
                p_organization_id,
                NVL(p_build_sequence,0)
        FROM    wip_flow_schedules fs
        WHERE   fs.line_id = p_line_id
        AND     fs.primary_item_id = p_item_id
        AND     fs.organization_id = p_organization_id
        AND     nvl(fs.schedule_group_id,-1) = nvl(p_schedule_group_id,-1)
        AND     scheduled_completion_date
        BETWEEN flm_timezone.client00_in_server(p_completion_date)
            AND flm_timezone.client00_in_server(p_completion_date)+1-1/(24*60*60)  --fix bug#3170105
        AND     not exists ( select 1 from mtl_transactions_interface
                              where transaction_source_id = fs.wip_entity_id
                                and organization_id = fs.organization_id
                                and transaction_source_type_id = 5
                                and transaction_action_id in (1, 27, 30, 31, 32, 33, 34) );

    ELSE

        OPEN C2;
        FETCH C2 INTO l_to_upd_qty;
        CLOSE C2;

        UPDATE mrp_form_query
        SET number6 = decode(number6,NULL,nvl(l_to_upd_qty,0),number6),
        number7 = decode(nvl(number7,0),0,nvl(l_to_upd_qty,0),number7) +
        p_quantity
        WHERE rowid = l_rowid;

    END IF;
    CLOSE C1;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
        ROLLBACK;
        RETCODE := G_ERROR;
        FND_MESSAGE.set_name('MRP','MRP_ROLL_FLOW_ERROR');
        ERRBUF := FND_MESSAGE.get;
        l_log_message := FND_MESSAGE.get;
        MRP_UTIL.MRP_LOG(l_log_message);
        l_log_message := 'Problem in report_update_WD procedure';
        MRP_UTIL.MRP_LOG(l_log_message);
        l_log_message := 'Unexpected SQL Error: '||sqlerrm;
        MRP_UTIL.MRP_LOG(l_log_message);
END report_update_WD;

PROCEDURE report_update_WOD(p_query_id IN NUMBER,
			p_line_id IN NUMBER,
			p_item_id IN NUMBER,
                        p_schedule_group_id IN NUMBER,
			p_completion_date IN DATE,
			p_quantity IN NUMBER,
                        p_from_start_date IN DATE,
                        p_from_end_date IN DATE,
                        p_to_start_date IN DATE,
                        p_to_end_date IN DATE) IS  --fix bug#3170105

    l_rowid		VARCHAR2(80);
    l_to_upd_qty        NUMBER := 0;

    CURSOR C1 IS
    SELECT rowid
    FROM mrp_form_query
    WHERE query_id = p_query_id
    AND number1 = p_line_id
    AND number2 = p_item_id
--2    AND NVL(number3,-1) = NVL(p_schedule_group_id,-1)
    AND trunc(date2) = trunc(flm_timezone.server_to_client(p_completion_date));  --fix bug#3170105

    CURSOR C2 IS
    SELECT sum(planned_quantity)
    FROM wip_flow_schedules
    WHERE   line_id = p_line_id
    AND	primary_item_id = p_item_id
    AND     organization_id = p_organization_id
--3    AND     nvl(schedule_group_id,-1) = nvl(p_schedule_group_id,-1)
    AND scheduled_completion_date between flm_timezone.client00_in_server(p_completion_date)
    AND flm_timezone.client00_in_server(p_completion_date)+1-1/(24*60*60);  --fix bug#3170105

BEGIN

    OPEN C1;
    FETCH C1 INTO l_rowid;

    IF C1%NOTFOUND THEN

/* Bug 2998385: Added not exists from MTL_TRANSACTIONS_INTERFACE */
        INSERT INTO mrp_form_query
       		(query_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		number1,
		number2,
		number3,
		date1,
		number4,
		number5,
		date2,
		number6,
		number7,
                number10)
        SELECT
		p_query_id,
		sysdate,
		1,
		sysdate,
		1,
		p_line_id,
		p_item_id,
		null,
		--p_schedule_group_id,
                flm_timezone.server_to_client(p_completion_date)
                -floor(p_to_start_date-p_from_start_date),  --fix bug#3170105
		0,
		0,
                flm_timezone.server_to_client(p_completion_date),  --fix bug#3170105
		nvl(sum(planned_quantity),0),
		nvl(sum(planned_quantity),0) + p_quantity,
                p_organization_id
        FROM    wip_flow_schedules fs
        WHERE   fs.line_id = p_line_id
	AND	fs.primary_item_id = p_item_id
        AND     fs.organization_id = p_organization_id
--4        AND     nvl(fs.schedule_group_id,-1) = nvl(p_schedule_group_id,-1)
        AND     scheduled_completion_date
        BETWEEN flm_timezone.client00_in_server(p_completion_date)
            AND flm_timezone.client00_in_server(p_completion_date)+1-1/(24*60*60)  --fix bug#317010
        AND     not exists ( select 1 from mtl_transactions_interface
                              where transaction_source_id = fs.wip_entity_id
                                and organization_id = fs.organization_id
                                and transaction_source_type_id = 5
                                and transaction_action_id in (1, 27, 30, 31, 32, 33, 34) );

    ELSE

        OPEN C2;
        FETCH C2 INTO l_to_upd_qty;
        CLOSE C2;

        UPDATE mrp_form_query
        SET number6 = decode(number6,NULL,nvl(l_to_upd_qty,0),number6),
	    number7 =
            decode(nvl(number7,0),0,nvl(l_to_upd_qty,0),number7) + p_quantity
        WHERE rowid = l_rowid;

    END IF;

    CLOSE C1;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        NULL;

    WHEN OTHERS THEN

        ROLLBACK;
        RETCODE := G_ERROR;
        FND_MESSAGE.set_name('MRP','MRP_ROLL_FLOW_ERROR');
        ERRBUF := FND_MESSAGE.get;
        l_log_message := FND_MESSAGE.get;
        MRP_UTIL.MRP_LOG(l_log_message);
        l_log_message := 'Problem in report_update_WOD procedure';
        MRP_UTIL.MRP_LOG(l_log_message);
        l_log_message := 'Unexpected SQL Error: '||sqlerrm;
        MRP_UTIL.MRP_LOG(l_log_message);

END report_update_WOD;

PROCEDURE relieve_rolled_schedules(p_wip_entity_id IN NUMBER) IS
BEGIN

  /*-------------------------------------------------------------------+
   | This procedure performs MPS relief to relieve flow schedules that |
   | were over-completed and rolled forward.                           |
   |                                                                   |
   | This is done because when the flow schedule is rolled forward     |
   | a new flow schedule quantity is created.  In order not to double  |
   | count the relief, we need to relieve the old quantity.            |
   +-------------------------------------------------------------------*/

      INSERT INTO mrp_relief_interface
                    (inventory_item_id,         -- NN
                     organization_id,           -- NN
                     last_update_date,          -- NN  sysdate
                     last_updated_by,           -- NN  :new.last_updated_by
                     creation_date,             -- NN  sysdate
                     created_by,                -- NN  :new.created_by
                     last_update_login,         --  N   -1
                     new_order_quantity,        -- NN
                     old_order_quantity,        --  N
                     new_order_date,            -- NN
                     old_order_date,            --  N
                     disposition_id,            -- NN  :new.wip_entity_id
                     planned_order_id,          --  N
                     relief_type,               -- NN  2
                     disposition_type,          -- NN  9
                     demand_class,              --  N
                     old_demand_class,          --  N
                     line_num,                  --  N  null
                     request_id,                --  N  null
                     program_application_id,    --  N  null
                     program_id,                --  N  null
                     program_update_date,       --  N  null
                     process_status,            -- NN  2
                     source_code,               --  N  'WIP'
                     source_line_id,            --  N  null
                     error_message,             --  N  null
                     transaction_id,            -- NN
                     project_id,
                     old_project_id,
                     task_id,
                     old_task_id
                    )
    SELECT primary_item_id,
                organization_id,
                sysdate,
                1,
                sysdate,
                1,
                -1,
                greatest(planned_quantity, quantity_completed)
                        - (planned_quantity - quantity_completed),
                greatest(planned_quantity, quantity_completed),
                scheduled_completion_date,
                scheduled_completion_date,
                wip_entity_id,
                DECODE(demand_source_type,100,
                        to_number(demand_source_line), NULL),
                2,
                9,
                demand_class,
                demand_class,
                null,
                null,
                null,
                null,
                null,
                2,
                'WIP',
                null,
                null,
                mrp_relief_interface_s.nextval,
                project_id,
                project_id,
                task_id,
                task_id
        FROM wip_flow_schedules
        WHERE wip_entity_id = p_wip_entity_id
          AND planned_quantity > quantity_completed;

END relieve_rolled_schedules;

BEGIN  --begin roll_flow_schedules

  flm_timezone.init_timezone(p_organization_id);--3827600

  -- Set the return code
  RETCODE := G_SUCCESS;

  --fix bug#3170105
  l_from_start_date := flm_timezone.client_to_server(
    fnd_date.canonical_to_date(p_from_start_date));
  l_from_end_date := flm_timezone.client_to_server(
    fnd_date.canonical_to_date(p_from_end_date));
  l_to_start_date := flm_timezone.client_to_server(
    fnd_date.canonical_to_date(p_to_start_date));
  l_to_end_date := flm_timezone.client_to_server(
    fnd_date.canonical_to_date(p_to_end_date));
  --end of fix bug#3170105

  --TZ BOM Calendar Bug 3832684
  l_to_start_time := to_char(l_to_start_date,'SSSSS');
  l_to_end_time := to_char(l_to_end_date,'SSSSS');

  -- Print the parameters
  FND_MESSAGE.set_name('MRP','EC_REPORT_PARAMETERS');
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','1');
  FND_MESSAGE.set_token('TOKEN','(ORGANIZATION_ID)');
  FND_MESSAGE.set_token('VALUE',to_char(p_organization_id));
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','2');
  FND_MESSAGE.set_token('TOKEN','(OUTPUT)');
  FND_MESSAGE.set_token('VALUE',to_char(p_output));
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','3');
  FND_MESSAGE.set_token('TOKEN','(FROM_START_DATE)');
  FND_MESSAGE.set_token('VALUE',to_char(l_from_start_date));  --fix bug#3170105
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','4');
  FND_MESSAGE.set_token('TOKEN','(FROM_END_DATE)');
  FND_MESSAGE.set_token('VALUE',to_char(l_from_end_date));  --fix bug#3170105
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','5');
  FND_MESSAGE.set_token('TOKEN','(TO_START_DATE)');
  FND_MESSAGE.set_token('VALUE',to_char(l_to_start_date));  --fix bug#3170105
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','6');
  FND_MESSAGE.set_token('TOKEN','(TO_END_DATE)');
  FND_MESSAGE.set_token('VALUE',to_char(l_to_end_date));  --fix bug#3170105
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','7');
  FND_MESSAGE.set_token('TOKEN','(FROM_LINE)');
  FND_MESSAGE.set_token('VALUE',p_from_line);
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','8');
  FND_MESSAGE.set_token('TOKEN','(TO_LINE)');
  FND_MESSAGE.set_token('VALUE',p_to_line);
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','9');
  FND_MESSAGE.set_token('TOKEN','(FROM_ITEM)');
  FND_MESSAGE.set_token('VALUE',p_from_item);
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','10');
  FND_MESSAGE.set_token('TOKEN','(TO_ITEM)');
  FND_MESSAGE.set_token('VALUE',p_to_item);
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','11');
  FND_MESSAGE.set_token('TOKEN','(CATEGORY_SET_ID)');
  FND_MESSAGE.set_token('VALUE',to_char(p_category_set_id));
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','12');
  FND_MESSAGE.set_token('TOKEN','(CATEGORY_STRUCTURE_ID)');
  FND_MESSAGE.set_token('VALUE',to_char(p_category_structure_id));
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','13');
  FND_MESSAGE.set_token('TOKEN','(FROM_CATEGORY)');
  FND_MESSAGE.set_token('VALUE',p_from_category);
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','14');
  FND_MESSAGE.set_token('TOKEN','(TO_CATEGORY)');
  FND_MESSAGE.set_token('VALUE',p_to_category);
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  FND_MESSAGE.set_name('MRP','MRCONC-ARGS INFO');
  FND_MESSAGE.set_token('NUMBER','15');
  FND_MESSAGE.set_token('TOKEN','(SPREAD_QTY)');
  FND_MESSAGE.set_token('VALUE',to_char(p_spread_qty));
  l_log_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_LOG(l_log_message);

  -- Check for mandatory parameters and issue an error message
  -- if NULL.  If line, item or category are null, assume all.
  IF p_organization_id IS NULL THEN
    FND_MESSAGE.set_name('MRP','MRP_ORG_ID_REQUIRED');
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);
    RAISE expected_error;
  END IF;
  IF (p_from_start_date IS NULL OR p_to_start_date IS NULL) AND
     (p_spread_qty <> 3)  THEN
    FND_MESSAGE.set_name('MRP','MRP_START_DATE_REQUIRED');
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);
    RAISE expected_error;
  END IF;
  IF p_from_end_date IS NULL AND (p_spread_qty <> 3)  THEN
    FND_MESSAGE.set_name('MRP','MRP_END_DATE_REQUIRED');
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);
    RAISE expected_error;
  END IF;

  IF p_to_end_date IS NULL AND (p_spread_qty = 1)  THEN
    FND_MESSAGE.set_name('MRP','MRP_END_DATE_REQUIRED');
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);
    RAISE expected_error;
  END IF;

  -- If either the from_end_date or the to_end_date are non-workdays
  -- then return the next work day and log a message.

  IF p_spread_qty <> 3 THEN
    -- Bug 2213859 no work day conversion required for FROM DATE ranges
    --fix bug#3170105 l_from_end_date := to_date(p_from_end_date, 'YYYY/MM/DD');
    null;
    /************** Commented - Bug 2213859 *********************
      l_from_end_date := mrp_calendar.next_work_day(p_organization_id,
        	1, to_date(p_from_end_date, 'YYYY/MM/DD'));
      IF to_date(p_from_end_date, 'YYYY/MM/DD') <> l_from_end_date THEN
        FND_MESSAGE.set_name('MRP','MRP_FROM_DATE_CHANGED');
        FND_MESSAGE.set_token('ORIG_DATE',p_from_end_date);
        FND_MESSAGE.set_token('NEW_DATE',l_from_end_date);
        l_log_message := FND_MESSAGE.get;
        MRP_UTIL.MRP_LOG(l_log_message);
      END IF;
    ******************** Comment ends ***********************/
  END IF;

  --fix bug#3170105
  IF p_spread_qty <> 3 THEN
    l_temp_date := mrp_calendar.next_work_day(p_organization_id,
        1, flm_timezone.server_to_calendar(l_to_start_date));
    --TZ BOM Calendar bug 3832684
    l_temp_date := flm_timezone.calendar_to_server(l_temp_date,l_to_start_time);

    /**
    Bug 2213859 - l_to_start_date is compared with to_date(p_to_start_date, 'YYYY/MM/DD')
    instead of l_to_end_date
    **/
    IF flm_timezone.server_to_calendar(l_temp_date) <> flm_timezone.server_to_calendar(l_to_start_date) AND
      (p_spread_qty = 2 ) THEN
      FND_MESSAGE.set_name('MRP','MRP_TO_DATE_CHANGED');
      FND_MESSAGE.set_token('ORIG_DATE',to_char(l_to_start_date));
      FND_MESSAGE.set_token('NEW_DATE',to_char(l_temp_date));
      l_log_message := FND_MESSAGE.get;
      MRP_UTIL.MRP_LOG(l_log_message);
    END IF;

    --bug 3832684: need it also for Spread Evenly wo Details
    l_to_start_date := l_temp_date;

  END IF;
  --end of fix bug#3170105

/*******************************************************************************
   Bug 2213859 - l_to_end_date is calculated for both p_spread_qty = 1 and 2
   If p_to_end_date is NULL (possible for p_spread_qty = 2),
   then default with l_to_start_date calculated above
********************************************************************************/

  IF p_spread_qty <> 3 THEN
    IF p_to_end_date is NULL THEN
      l_to_end_date := l_to_start_date;
    ELSE
      --fix bug#3170105
      l_temp_date := mrp_calendar.next_work_day(p_organization_id,
        	1, flm_timezone.server_to_calendar(l_to_end_date));
      --TZ BOM Calendar bug 3832684
      l_temp_date := flm_timezone.calendar_to_server(l_temp_date,l_to_end_time);

      IF flm_timezone.server_to_calendar(l_temp_date) <> flm_timezone.server_to_calendar(l_to_end_date) THEN
        FND_MESSAGE.set_name('MRP','MRP_TO_DATE_CHANGED');
        FND_MESSAGE.set_token('ORIG_DATE',l_to_end_date);
        FND_MESSAGE.set_token('NEW_DATE',l_temp_date);
        l_log_message := FND_MESSAGE.get;
        l_to_end_date := l_temp_date;
        MRP_UTIL.MRP_LOG(l_log_message);
      END IF;
    --end of fix bug#3170105

      --bug 3832684: need it also for Spread Evenly wo Details
      l_to_end_date := l_temp_date;

    END IF;
  END IF;

  /**** Bug 2213859 - Code is moved up before to_end_date validation
  IF p_spread_qty <> 3 THEN
  l_to_start_date := mrp_calendar.next_work_day(p_organization_id,
	1, to_date(p_to_start_date, 'YYYY/MM/DD'));
  IF to_date(p_to_start_date, 'YYYY/MM/DD') <> l_to_end_date AND
    (p_spread_qty = 2 ) THEN
    FND_MESSAGE.set_name('MRP','MRP_TO_DATE_CHANGED');
    FND_MESSAGE.set_token('ORIG_DATE',p_to_start_date);
    FND_MESSAGE.set_token('NEW_DATE',l_to_start_date);
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);
  END IF;
  END IF;
  ****************************************************************************/

  FND_MESSAGE.set_name('MRP','EC_DATE');
  l_trans_var1 := FND_MESSAGE.get;
  SELECT to_char(sysdate)
  INTO l_trans_var2
  FROM dual;
  l_out_message := l_trans_var1 || ':  ' || l_trans_var2;
  MRP_UTIL.MRP_OUT(l_out_message);

  FND_MESSAGE.set_name('MRP','MRP_ROLL_FLOW_REPORT');
  l_out_message := FND_MESSAGE.get;
  MRP_UTIL.MRP_OUT('                                '||l_out_message);

  /*-----------------------------------------------------+
   | Do setup for report by inserting existing records   |
   | into mrp_form_query                                 |
   +-----------------------------------------------------*/

  /* this part of code is moved from the buttom of the procedure to here,
     because after the schedules got rolled, there would be no flow schedules
     to be queried to insert into mrp_relief_interface */
  IF p_output = 2 THEN
    l_cursor := Create_Relieve_Cursor(l_from_start_date,l_from_end_date);  --fix bug#317105

    IF l_cursor IS NULL THEN
      RAISE unexpected_error;
    END IF;

    LOOP
      l_rows := dbms_sql.fetch_rows(l_cursor);
      IF l_rows = 0 THEN
        EXIT;
      END IF;
      IF l_rows > 0 THEN
        dbms_sql.column_value(l_cursor, 1, l_wip_entity_id2);
      END IF;
      Relieve_Rolled_Schedules(l_wip_entity_id2);
    END LOOP;
  END IF;

  /*-----------------------------------------------------+
   | If spread quantities then distribute evenly over to |
   | timeframe  without details                          |
   +-----------------------------------------------------*/
  IF p_spread_qty = 1 THEN
    initialize_report_WOD(l_report_query_id,l_from_start_date,l_from_end_date,
                          l_to_start_date,l_to_end_date);  --fix bug#3170105

    l_cursor := Create_Cursor_WOD(l_from_start_date,l_from_end_date);  --fix bug#3170105
    IF l_cursor IS NULL THEN
      RAISE unexpected_error;
    END IF;

    LOOP
      l_rows := dbms_sql.fetch_rows(l_cursor);
      IF l_rows = 0 THEN
        EXIT;
      END IF;
      IF l_rows > 0 THEN
        dbms_sql.column_value(l_cursor, 1, fs_report_rec.line_id);
        dbms_sql.column_value(l_cursor, 2, fs_report_rec.line_code);
        dbms_sql.column_value(l_cursor, 3, fs_report_rec.primary_item_id);
        dbms_sql.column_value(l_cursor, 4, fs_report_rec.item);
        dbms_sql.column_value(l_cursor, 5, fs_report_rec.schedule_group_id);
        dbms_sql.column_value(l_cursor, 6, fs_report_rec.planned_quantity);
        dbms_sql.column_value(l_cursor, 7, fs_report_rec.quantity_completed);
      END IF;

      -- If there is a variance, then process record
      IF (fs_report_rec.planned_quantity
	- fs_report_rec.quantity_completed) <> 0
      THEN

        l_variance := fs_report_rec.planned_quantity
				- fs_report_rec.quantity_completed;

        OPEN C4(fs_report_rec.line_id, fs_report_rec.primary_item_id,
                l_to_start_date, l_to_end_date);  --fix bug#3170105

        -- Get the rowcount and remainder
        FETCH C4 INTO l_row_count;
        IF l_row_count = 0 THEN
          EXIT;
        END IF;

        IF l_variance < 0 THEN
          l_daily_variance := ceil(l_variance/l_row_count);
        ELSE
          l_daily_variance := floor(l_variance/l_row_count);
        END IF;
        l_remainder := abs(mod(l_variance,l_row_count));

        CLOSE C4;

        l_old_completion_date := FND_API.G_MISS_DATE;
        OPEN C3(fs_report_rec.line_id, fs_report_rec.primary_item_id,
                l_to_start_date, l_to_end_date);  --fix bug#3170105

        LOOP
          FETCH C3 INTO l_wip_entity_id, l_completion_date, l_planned_quantity,
          l_quantity_completed;
          EXIT WHEN C3%NOTFOUND;

          /*--------------------------------------------------------------+
           | We can have more than one schedule on a given date           |
           | The cursor is sorted descending so we get the last schedule  |
           | of the day.  If the day was already processed, we don't      |
           | enter the if unless the variance was negative and the        |
           | first schedule didn't have enough quantity to handle it.     |
           +--------------------------------------------------------------*/
          IF (l_completion_date <> l_old_completion_date) OR
		(l_update_variance <> 0) THEN
            /*-------------------------------------------------------+
             | Add one to each until there is no remainder left.     |
             | l_update_variance will equal zero unless variance was |
             | negative and there is still some left after reducing  |
             | the last schedule                                     |
             | If the schedule is still on the same date, we want to |
             | carry over the variance that is left over from the    |
             | previous schedules (which is still on the same day).  |
             +-------------------------------------------------------*/


            IF l_completion_date <> l_old_completion_date THEN
              IF l_remainder > 0 THEN
                IF l_variance < 0 THEN
                  l_update_variance := l_update_variance + l_daily_variance - 1;
                ELSE
                  l_update_variance := l_update_variance + l_daily_variance + 1;
                END IF;
                l_remainder := l_remainder - 1;
              ELSE
                l_update_variance := l_update_variance + l_daily_variance;
              END IF;
            END IF;

            /*-------------------------------------------------------+
             | If the variance is greater than zero, always create   |
             | a new schedule (call private procedure)               |
             +-------------------------------------------------------*/

            IF l_update_variance > 0 THEN
              l_flow_schedule_rec.operation := MRP_GLOBALS.G_OPR_CREATE;
              l_flow_schedule_rec.organization_id
			:= p_organization_id;
              l_flow_schedule_rec.schedule_group_id
			:= fs_report_rec.schedule_group_id;
              l_flow_schedule_rec.primary_item_id
			:= fs_report_rec.primary_item_id;
              l_flow_schedule_rec.line_id
			:= fs_report_rec.line_id;
              l_flow_schedule_rec.planned_quantity := l_update_variance;
              l_flow_schedule_rec.scheduled_completion_date
			:= Time_Schedule(fs_report_rec.line_id,
                                         l_completion_date,l_update_variance);

              l_flow_schedule_rec.roll_forwarded_flag :=
              G_INTERMEDIATE_ROLL_FORWARDED;
              l_flow_schedule_rec.status := 1;


              -- Call procedure to update mrp_form_query for the report
              report_update_WOD(l_report_query_id,
				fs_report_rec.line_id,
				fs_report_rec.primary_item_id,
                                fs_report_rec.schedule_group_id,
				l_completion_date,
				l_update_variance,
                                l_from_start_date,
                                l_from_end_date,
                                l_to_start_date,
                                l_to_end_date);

              MRP_Flow_Schedule_PVT.Process_Flow_Schedule
          	  ( 	p_api_version_number		=> 1.0,
			x_return_status			=> l_return_status,
			x_msg_count			=> l_msg_count,
			x_msg_data			=> l_msg_data,
			p_control_rec			=> l_control_rec,
			p_old_flow_schedule_rec         => l_old_flow_schedule_rec,
			p_flow_schedule_rec		=> l_flow_schedule_rec,
			x_flow_schedule_rec		=> l_x_flow_schedule_rec
	      );

              IF p_output = 2 THEN
                -- Write either error or success message to log
                IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                  FND_MESSAGE.set_name('MRP','MRP_ROLL_CREATE');
                  FND_MESSAGE.set_token('LINE',fs_report_rec.line_code);
                  FND_MESSAGE.set_token('ITEM',fs_report_rec.item);
                  FND_MESSAGE.set_token('COMP_DATE',l_x_flow_schedule_rec.scheduled_completion_date);
	          FND_MESSAGE.set_token('QTY',l_x_flow_schedule_rec.planned_quantity);
                  l_log_message := FND_MESSAGE.get;
                  MRP_UTIL.MRP_LOG(l_log_message);
                ELSE
                  IF l_msg_count > 0 THEN
                    FOR i in 1..l_msg_count LOOP
                      l_log_message := fnd_msg_pub.get(i,'F');
                      MRP_UTIL.MRP_LOG(l_log_message);
                    END LOOP;
                  END IF;
                END IF;
              -- End if for p_output = 2 loop (report and update)
              END IF;
              l_update_variance := 0;

            /*------------------------------------------------------------+
             | If the variance is less than zero, then there are 3 cases: |
             |      - schedule planned quantity = 0                       |
             |          - carry variance to next schedule                 |
             |      - schedule planned quantity > variance                |
             |          - reduce schedule by variance                     |
             |      - schedule planned quantity < variance                |
             |          - delete schedule and carry remainder variance    |
             |            to next schedule                                |
             +------------------------------------------------------------*/

            ELSIF l_update_variance < 0 THEN
              IF l_planned_quantity = 0 THEN
                /*---------------------------------------------+
                 | Store variance to be handled the next day   |
                 | Just don't zero out l_update_variance,      |
                 | nothing else needs to be done               |
                 +---------------------------------------------*/
                NULL;
              ELSE
                IF -(l_update_variance) < (l_planned_quantity -
                     l_quantity_completed) THEN
                   -- Call procedure to update mrp_form_query for the report
                   report_update_WOD(l_report_query_id,
				fs_report_rec.line_id,
				fs_report_rec.primary_item_id,
                                fs_report_rec.schedule_group_id,
				l_completion_date,
				l_update_variance,
                                l_from_start_date,
                                l_from_end_date,
                                l_to_start_date,
                                l_to_end_date);
                 /*-----------------------------+
                  | Update existing schedule    |
                  +-----------------------------*/
                  Update_Quantity(l_wip_entity_id,
				l_update_variance);
                  IF p_output = 2 THEN
                    FND_MESSAGE.set_name('MRP','MRP_ROLL_UPDATE');
                    FND_MESSAGE.set_token('LINE',fs_report_rec.line_code);
                    FND_MESSAGE.set_token('ITEM',fs_report_rec.item);
                    FND_MESSAGE.set_token('COMP_DATE',l_completion_date);
                    FND_MESSAGE.set_token('OLD_QTY',l_planned_quantity);
                    FND_MESSAGE.set_token('NEW_QTY',
			(l_planned_quantity + l_update_variance));
                    l_log_message := FND_MESSAGE.get;
                    MRP_UTIL.MRP_LOG(l_log_message);
                  END IF;
                  l_update_variance := 0;
                ELSIF -(l_update_variance) >= (l_planned_quantity -
                        l_quantity_completed) THEN
                   -- Call procedure to update mrp_form_query for the report
                   report_update_WOD(l_report_query_id,
				fs_report_rec.line_id,
				fs_report_rec.primary_item_id,
                                fs_report_rec.schedule_group_id,
				l_completion_date,
				-(l_planned_quantity - l_quantity_completed),
                                l_from_start_date,
                                l_from_end_date,
                                l_to_start_date,
                                l_to_end_date);
                  IF(l_planned_quantity = (l_planned_quantity -
                     l_quantity_completed )) THEN
                  /*------------------------------------------------------+
                  | Delete existing schedule and save remaining update   |
                  | variance for next schedule                           |
                  +------------------------------------------------------*/
                     Delete_Row(l_wip_entity_id);
                  ELSE
                 /*-----------------------------+
                  | Update existing schedule    |
                  +-----------------------------*/
                     Update_Quantity(l_wip_entity_id,
                                  - (l_planned_quantity-l_quantity_completed));
                     IF (NOT Close_Single_Schedule_WithID(l_wip_entity_id,
                       p_organization_id)) THEN
                       RAISE unexpected_error;
                     END IF;

                  END IF;
                  IF p_output = 2 THEN
                    FND_MESSAGE.set_name('MRP','MRP_ROLL_DELETE');
                    FND_MESSAGE.set_token('LINE',fs_report_rec.line_code);
                    FND_MESSAGE.set_token('ITEM',fs_report_rec.item);
                    FND_MESSAGE.set_token('COMP_DATE',l_completion_date);
                    FND_MESSAGE.set_token('QTY',l_planned_quantity);
                    l_log_message := FND_MESSAGE.get;
                    MRP_UTIL.MRP_LOG(l_log_message);
                  END IF;
                  l_update_variance := l_update_variance +
                  (l_planned_quantity-l_quantity_completed);
                END IF;
              END IF;
            END IF;
          END IF;
          l_old_completion_date := l_completion_date;
        END LOOP;
        CLOSE C3;
        /*---------------------------------------------------------+
         | After loop completes, check to see if we still have a   |
         | quantity in l_update_variance (from a negative variance |
         | that didn't have enough quantities to delete on the     |
         | right days).  This is a corner case but it is possible  |
         | that there will be other schedules in the timeframe     |
         | that we can delete from so we loop again.               |
         | e.g. Day 1 Qty = 5                                      |
         |      Day 2 Qty = 5                                      |
         |      Day 3 Qty = 2                                      |
         | If the daily update variance was -3, then after the     |
         | first loop we have:                                     |
         |      Day 1 Qty = 2                                      |
         |      Day 2 Qty = 2                                      |
         |      Day 3 Qty = 0                                      |
         | and a remainder variance of -1.  The second loop will   |
         | reduce the Day 1 Qty to 1.                              |
         | If we still have a remainder qty after the second loop  |
         | then generate an error message to the log               |
         +---------------------------------------------------------*/
        IF l_update_variance < 0 THEN
          -- Log what's going on
          FND_MESSAGE.set_name('MRP','MRP_ROLL_SECOND_LOOP');
          l_log_message := FND_MESSAGE.get;
          MRP_UTIL.MRP_LOG(l_log_message);

          OPEN C5(fs_report_rec.line_id, fs_report_rec.primary_item_id,
                  l_to_start_date, l_to_end_date);  --fix bug#3170105
          LOOP
            FETCH C5 INTO l_wip_entity_id, l_completion_date,
				l_planned_quantity;
            EXIT WHEN C5%NOTFOUND;
            IF -(l_update_variance) < (l_planned_quantity -
                     l_quantity_completed) THEN
              -- Call procedure to update mrp_form_query for the report
              report_update_WOD(l_report_query_id,
				fs_report_rec.line_id,
				fs_report_rec.primary_item_id,
                                fs_report_rec.schedule_group_id,
				l_completion_date,
				l_update_variance,
                                l_from_start_date,
                                l_from_end_date,
                                l_to_start_date,
                                l_to_end_date);
             /*-----------------------------+
              | Update existing schedule    |
              +-----------------------------*/
              Update_Quantity(l_wip_entity_id,
			l_update_variance);

              IF p_output = 2 THEN
                FND_MESSAGE.set_name('MRP','MRP_ROLL_UPDATE');
                FND_MESSAGE.set_token('LINE',fs_report_rec.line_code);
                FND_MESSAGE.set_token('ITEM',fs_report_rec.item);
                FND_MESSAGE.set_token('COMP_DATE',l_completion_date);
                FND_MESSAGE.set_token('OLD_QTY',l_planned_quantity);
                FND_MESSAGE.set_token('NEW_QTY',
			(l_planned_quantity + l_update_variance));
                l_log_message := FND_MESSAGE.get;
              END IF;
              l_update_variance := 0;
              ELSIF -(l_update_variance) >= (l_planned_quantity -
                        l_quantity_completed) THEN
              -- Call procedure to update mrp_form_query for the report
              report_update_WOD(l_report_query_id,
				fs_report_rec.line_id,
				fs_report_rec.primary_item_id,
                                fs_report_rec.schedule_group_id,
				l_completion_date,
				-(l_planned_quantity- l_quantity_completed),
                                l_from_start_date,
                                l_from_end_date,
                                l_to_start_date,
                                l_to_end_date);

              IF(l_planned_quantity = (l_planned_quantity -
                 l_quantity_completed )) THEN
              /*------------------------------------------------------+
              | Delete existing schedule and save remaining update   |
              | variance for next schedule                           |
              +------------------------------------------------------*/
                 Delete_Row(l_wip_entity_id);
              ELSE
             /*-----------------------------+
              | Update existing schedule    |
              +-----------------------------*/
                 Update_Quantity(l_wip_entity_id,
                              - (l_planned_quantity-l_quantity_completed));
                 IF (NOT Close_Single_Schedule_WithID(l_wip_entity_id,
                   p_organization_id)) THEN
                   RAISE unexpected_error;
                 END IF;
              END IF;

              IF p_output = 2 THEN
                FND_MESSAGE.set_name('MRP','MRP_ROLL_DELETE');
                FND_MESSAGE.set_token('LINE',fs_report_rec.line_code);
                FND_MESSAGE.set_token('ITEM',fs_report_rec.item);
                FND_MESSAGE.set_token('COMP_DATE',l_completion_date);
                FND_MESSAGE.set_token('QTY',l_planned_quantity);
                l_log_message := FND_MESSAGE.get;
                MRP_UTIL.MRP_LOG(l_log_message);
              END IF;
              l_update_variance := l_update_variance +
              (l_planned_quantity-l_quantity_completed);
            END IF;
            EXIT WHEN l_update_variance = 0;
          END LOOP;
          CLOSE C5;
          /*-------------------------------------------------------+
           | If l_update_variance is still less than zero, print a |
           | message to the log.                                   |
           +-------------------------------------------------------*/
           IF l_update_variance < 0 THEN
             FND_MESSAGE.set_name('MRP','MRP_ROLL_QTY_REMAINDER');
             FND_MESSAGE.set_token('QTY',l_update_variance);
             l_log_message := FND_MESSAGE.get;
             MRP_UTIL.MRP_LOG(l_log_message);
             RETCODE := G_WARNING;
             l_update_variance := 0;
           END IF;
        END IF;
      END IF;

    END LOOP;
  UPDATE wip_flow_schedules set roll_forwarded_flag =
  G_ROLL_FORWARDED
  where roll_forwarded_flag =
  G_INTERMEDIATE_ROLL_FORWARDED;
  ELSIF p_spread_qty = 2 THEN

   initialize_report_WD(l_report_query_id,l_from_start_date,l_from_end_date,
                        l_to_start_date,l_to_end_date);  --fix bug#3170105

    l_cursor := Create_Cursor_WD(l_from_start_date,l_from_end_date);  --fix bug#3170105

    IF l_cursor IS NULL THEN
      RAISE unexpected_error;
    END IF;

    LOOP
      l_rows := dbms_sql.fetch_rows(l_cursor);
      IF l_rows > 0 THEN
        dbms_sql.column_value(l_cursor, 1, fs_report_rec.line_id);
        dbms_sql.column_value(l_cursor, 2, fs_report_rec.line_code);
        dbms_sql.column_value(l_cursor, 3, fs_report_rec.primary_item_id);
        dbms_sql.column_value(l_cursor, 4, fs_report_rec.schedule_group_id);
        dbms_sql.column_value(l_cursor, 5, fs_report_rec.schedule_number);
        dbms_sql.column_value(l_cursor, 6, fs_report_rec.build_sequence);
        dbms_sql.column_value(l_cursor, 7, fs_report_rec.
        demand_source_header_id);
        dbms_sql.column_value(l_cursor, 8, fs_report_rec.demand_source_line);
        dbms_sql.column_value(l_cursor, 9, fs_report_rec.
        demand_source_delivery);
        dbms_sql.column_value(l_cursor, 10, fs_report_rec.demand_source_type);
        dbms_sql.column_value(l_cursor, 11, fs_report_rec.demand_class);
        dbms_sql.column_value(l_cursor, 12, fs_report_rec.item);
        dbms_sql.column_value(l_cursor, 13, fs_report_rec.planned_quantity);
        dbms_sql.column_value(l_cursor, 14, fs_report_rec.quantity_completed);

        dbms_sql.column_value(l_cursor, 15, fs_report_rec.MPS_SCHEDULED_COMPLETION_DATE);
        dbms_sql.column_value(l_cursor, 16, fs_report_rec.MPS_NET_QUANTITY);
        dbms_sql.column_value(l_cursor, 17, fs_report_rec.BOM_REVISION);
        dbms_sql.column_value(l_cursor, 18, fs_report_rec.ROUTING_REVISION);
        dbms_sql.column_value(l_cursor, 19, fs_report_rec.BOM_REVISION_DATE);
        dbms_sql.column_value(l_cursor, 20,
          fs_report_rec.ROUTING_REVISION_DATE);
        dbms_sql.column_value(l_cursor, 21,
          fs_report_rec.ALTERNATE_BOM_DESIGNATOR);
        dbms_sql.column_value(l_cursor, 22,
          fs_report_rec.ALTERNATE_ROUTING_DESIGNATOR);
        dbms_sql.column_value(l_cursor, 23,
          fs_report_rec.COMPLETION_SUBINVENTORY);
        dbms_sql.column_value(l_cursor, 24,
          fs_report_rec.COMPLETION_LOCATOR_ID);
        dbms_sql.column_value(l_cursor, 25, fs_report_rec.MATERIAL_ACCOUNT);
        dbms_sql.column_value(l_cursor, 26,
          fs_report_rec.MATERIAL_OVERHEAD_ACCOUNT);
        dbms_sql.column_value(l_cursor, 27, fs_report_rec.RESOURCE_ACCOUNT);
        dbms_sql.column_value(l_cursor, 28,
          fs_report_rec.OUTSIDE_PROCESSING_ACCOUNT);
        dbms_sql.column_value(l_cursor, 29,
          fs_report_rec.MATERIAL_VARIANCE_ACCOUNT);
        dbms_sql.column_value(l_cursor, 30,
          fs_report_rec.RESOURCE_VARIANCE_ACCOUNT);
        dbms_sql.column_value(l_cursor, 31,
          fs_report_rec.OUTSIDE_PROC_VARIANCE_ACCOUNT);
        dbms_sql.column_value(l_cursor, 32,
          fs_report_rec.STD_COST_ADJUSTMENT_ACCOUNT);
        dbms_sql.column_value(l_cursor, 33, fs_report_rec.OVERHEAD_ACCOUNT);
        dbms_sql.column_value(l_cursor, 34,
          fs_report_rec.OVERHEAD_VARIANCE_ACCOUNT);
        dbms_sql.column_value(l_cursor, 35, fs_report_rec.PROJECT_ID);
        dbms_sql.column_value(l_cursor, 36, fs_report_rec.TASK_ID);
        dbms_sql.column_value(l_cursor, 37, fs_report_rec.ATTRIBUTE_CATEGORY);
        dbms_sql.column_value(l_cursor, 38, fs_report_rec.ATTRIBUTE1);
        dbms_sql.column_value(l_cursor, 39, fs_report_rec.ATTRIBUTE2);
        dbms_sql.column_value(l_cursor, 40, fs_report_rec.ATTRIBUTE3);
        dbms_sql.column_value(l_cursor, 41, fs_report_rec.ATTRIBUTE4);
        dbms_sql.column_value(l_cursor, 42, fs_report_rec.ATTRIBUTE5);
        dbms_sql.column_value(l_cursor, 43, fs_report_rec.ATTRIBUTE6);
        dbms_sql.column_value(l_cursor, 44, fs_report_rec.ATTRIBUTE7);
        dbms_sql.column_value(l_cursor, 45, fs_report_rec.ATTRIBUTE8);
        dbms_sql.column_value(l_cursor, 46, fs_report_rec.ATTRIBUTE9);
        dbms_sql.column_value(l_cursor, 47, fs_report_rec.ATTRIBUTE10);
        dbms_sql.column_value(l_cursor, 48, fs_report_rec.ATTRIBUTE11);
        dbms_sql.column_value(l_cursor, 49, fs_report_rec.ATTRIBUTE12);
        dbms_sql.column_value(l_cursor, 50, fs_report_rec.ATTRIBUTE13);
        dbms_sql.column_value(l_cursor, 51, fs_report_rec.ATTRIBUTE14);
        dbms_sql.column_value(l_cursor, 52, fs_report_rec.ATTRIBUTE15);
        dbms_sql.column_value(l_cursor, 53, fs_report_rec.KANBAN_CARD_ID);
        dbms_sql.column_value(l_cursor, 54, fs_report_rec.END_ITEM_UNIT_NUMBER);
        dbms_sql.column_value(l_cursor, 55, fs_report_rec.CURRENT_LINE_OPERATION);
        dbms_sql.column_value(l_cursor, 56, fs_report_rec.WIP_ENTITY_ID);

      END IF;

      /*---------------------------------------------------------+
       | After loop completes, check to see if we still have a   |
       | quantity in l_unprocessed_var then we add/subtract from |
       | last bucket and produce an error message otherwise      |
       +---------------------------------------------------------*/

      EXIT WHEN l_rows = 0;

      -- If the variance is positive(under completions) , then process record
      IF (fs_report_rec.planned_quantity
	- fs_report_rec.quantity_completed) > 0
      THEN

        l_update_variance := fs_report_rec.planned_quantity
				- fs_report_rec.quantity_completed;
MRP_UTIL.MRP_LOG('quantity OK');

          /*--------------------------------------------------------------+
           | We can have more than one schedule on a given date           |
           | The cursor is sorted descending so we get the last schedule  |
           | of the day.                                                  |
           +--------------------------------------------------------------*/

          /*-------------------------------------------------------+
           | Since the variance is greater than zero, always create|
           | a new schedule (call private procedure)               |
           +-------------------------------------------------------*/
          l_flow_schedule_rec.operation := MRP_GLOBALS.G_OPR_CREATE;
          l_flow_schedule_rec.organization_id
			:= p_organization_id;
          l_flow_schedule_rec.schedule_group_id
			:= fs_report_rec.schedule_group_id;
          l_flow_schedule_rec.primary_item_id
			:= fs_report_rec.primary_item_id;
          l_flow_schedule_rec.line_id
			:= fs_report_rec.line_id;
          l_flow_schedule_rec.planned_quantity := l_update_variance;

          l_flow_schedule_rec.scheduled_completion_date
                        := Time_Schedule(fs_report_rec.line_id,
                           l_to_start_date,
                           l_update_variance);
                           --l_to_end_date,l_update_variance);
                           --p_to_end_date,l_update_variance);

          -- Bug 2213859
          -- Commented l_flow_schedule_rec.build_sequence:= fs_report_rec.build_sequence;
          /*-----------------------------------------------------------------+
           | Set the build sequence for newly forwarded schedules            |
	   | Start with a BASE NUMBER and keep incrementing it               |
           | Keep separate counter linewise                                  |
           | Keep NULL build sequence as NULL (manual)                       |
           +-----------------------------------------------------------------*/
          MRP_UTIL.MRP_LOG('Creating new build sequence for line='||fs_report_rec.line_id);
	  if (fs_report_rec.build_sequence is not null) then
	    if ( not l_build_seq_counter.exists(fs_report_rec.line_id) ) then
	      -- Initialization of the Seq Counter table
	      MRP_UTIL.MRP_LOG('Initialize the counter for line='||fs_report_rec.line_id);
	      l_build_seq_counter(fs_report_rec.line_id).base_number
	                   := Get_Base_Number(fs_report_rec.line_id,
	        flm_timezone.client00_in_server(l_flow_schedule_rec.scheduled_completion_date),
                                              l_from_start_date, l_from_end_date);  --fix bug#3170105
	      MRP_UTIL.MRP_LOG('Initialized base number='||
	                        l_build_seq_counter(fs_report_rec.line_id).base_number);
	      l_build_seq_counter(fs_report_rec.line_id).current_build_seq :=
	                     l_build_seq_counter(fs_report_rec.line_id).base_number + 1;
	      MRP_UTIL.MRP_LOG('Initialized current build Seq number='||
	                        l_build_seq_counter(fs_report_rec.line_id).current_build_seq);
	    else
	      MRP_UTIL.MRP_LOG('Increment the counter for line='||fs_report_rec.line_id);
	      l_build_seq_counter(fs_report_rec.line_id).current_build_seq :=
	            l_build_seq_counter(fs_report_rec.line_id).current_build_seq + 1;
	    end if;
	      l_temp_build_sequence := l_build_seq_counter(fs_report_rec.line_id).current_build_seq;
	  else
	    MRP_UTIL.MRP_LOG('Build Seq Counter is NULL for line='||fs_report_rec.line_id);
	    l_temp_build_sequence := null;
            l_build_seq_counter(fs_report_rec.line_id).current_build_seq := NULL;
	  end if;
	  MRP_UTIL.MRP_LOG('Resultant Build Seq Counter is ='||l_temp_build_sequence);

	  l_flow_schedule_rec.build_sequence:= l_temp_build_sequence;

          -- Bug 2213859

          l_flow_schedule_rec.demand_source_header_id :=
          fs_report_rec.demand_source_header_id;

          l_flow_schedule_rec.demand_source_line :=
          fs_report_rec.demand_source_line;
          l_flow_schedule_rec.demand_source_delivery :=
          fs_report_rec.demand_source_delivery;
          l_flow_schedule_rec.demand_source_type :=
          fs_report_rec.demand_source_type;
          l_flow_schedule_rec.demand_class :=
          fs_report_rec.demand_class;

          l_flow_schedule_rec.roll_forwarded_flag :=
          G_INTERMEDIATE_ROLL_FORWARDED;
          l_flow_schedule_rec.status := 1;

          l_flow_schedule_rec.mps_scheduled_comp_date :=
          fs_report_rec.MPS_SCHEDULED_COMPLETION_DATE;
          l_flow_schedule_rec.mps_net_quantity:=
          fs_report_rec.MPS_NET_QUANTITY;
          l_flow_schedule_rec.bom_revision:=
          fs_report_rec.BOM_REVISION;
          l_flow_schedule_rec.routing_revision:=
          fs_report_rec.ROUTING_REVISION;
          l_flow_schedule_rec.bom_revision_date:=
          fs_report_rec.BOM_REVISION_DATE;
          l_flow_schedule_rec.routing_revision_date:=
          fs_report_rec.ROUTING_REVISION_DATE;
          l_flow_schedule_rec.alternate_bom_designator:=
          fs_report_rec.ALTERNATE_BOM_DESIGNATOR;
          l_flow_schedule_rec.alternate_routing_desig:=
          fs_report_rec.ALTERNATE_ROUTING_DESIGNATOR;
          l_flow_schedule_rec.completion_subinventory:=
          fs_report_rec.COMPLETION_SUBINVENTORY;
          l_flow_schedule_rec.completion_locator_id:=
          fs_report_rec.COMPLETION_LOCATOR_ID;
          l_flow_schedule_rec.material_account:=
          fs_report_rec.MATERIAL_ACCOUNT;
          l_flow_schedule_rec.material_overhead_account:=
          fs_report_rec.MATERIAL_OVERHEAD_ACCOUNT;
          l_flow_schedule_rec.resource_account:=
          fs_report_rec.RESOURCE_ACCOUNT;
          l_flow_schedule_rec.outside_processing_acct:=
          fs_report_rec.OUTSIDE_PROCESSING_ACCOUNT;
          l_flow_schedule_rec.material_variance_account:=
          fs_report_rec.MATERIAL_VARIANCE_ACCOUNT;
          l_flow_schedule_rec.resource_variance_account:=
          fs_report_rec.RESOURCE_VARIANCE_ACCOUNT;
          l_flow_schedule_rec.outside_proc_var_acct:=
          fs_report_rec.OUTSIDE_PROC_VARIANCE_ACCOUNT;
          l_flow_schedule_rec.std_cost_adjustment_acct:=
          fs_report_rec.STD_COST_ADJUSTMENT_ACCOUNT;
          l_flow_schedule_rec.overhead_account:=
          fs_report_rec.OVERHEAD_ACCOUNT;
          l_flow_schedule_rec.overhead_variance_account:=
          fs_report_rec.OVERHEAD_VARIANCE_ACCOUNT;
          l_flow_schedule_rec.project_id:=
          fs_report_rec.PROJECT_ID;
          l_flow_schedule_rec.task_id:=
          fs_report_rec.TASK_ID;
          l_flow_schedule_rec.attribute_category :=
          fs_report_rec.ATTRIBUTE_CATEGORY;
          l_flow_schedule_rec.attribute1:=
          fs_report_rec.ATTRIBUTE1;
          l_flow_schedule_rec.attribute2:=
          fs_report_rec.ATTRIBUTE2;
          l_flow_schedule_rec.attribute3:=
          fs_report_rec.ATTRIBUTE3;
          l_flow_schedule_rec.attribute4:=
          fs_report_rec.ATTRIBUTE4;
          l_flow_schedule_rec.attribute5:=
          fs_report_rec.ATTRIBUTE5;
          l_flow_schedule_rec.attribute6:=
          fs_report_rec.ATTRIBUTE6;
          l_flow_schedule_rec.attribute7:=
          fs_report_rec.ATTRIBUTE7;
          l_flow_schedule_rec.attribute8:=
          fs_report_rec.ATTRIBUTE8;
          l_flow_schedule_rec.attribute9:=
          fs_report_rec.ATTRIBUTE9;
          l_flow_schedule_rec.attribute10:=
          fs_report_rec.ATTRIBUTE10;
          l_flow_schedule_rec.attribute11:=
          fs_report_rec.ATTRIBUTE11;
          l_flow_schedule_rec.attribute12:=
          fs_report_rec.ATTRIBUTE12;
          l_flow_schedule_rec.attribute13:=
          fs_report_rec.ATTRIBUTE13;
          l_flow_schedule_rec.attribute14:=
          fs_report_rec.ATTRIBUTE14;
          l_flow_schedule_rec.attribute15:=
          fs_report_rec.ATTRIBUTE15;
          l_flow_schedule_rec.kanban_card_id:=
          fs_report_rec.KANBAN_CARD_ID;
          l_flow_schedule_rec.end_item_unit_number:=
          fs_report_rec.END_ITEM_UNIT_NUMBER;
          l_flow_schedule_rec.current_line_operation:=
          fs_report_rec.CURRENT_LINE_OPERATION;

          IF (NOT Close_Single_Schedule(fs_report_rec.schedule_number,
          p_organization_id)) THEN
            RAISE unexpected_error;
         END IF;

          -- Call procedure to update mrp_form_query for the report
	  /** Bug 2558664 - passed old build sequence as report goes haywire
	      if modified build sequence is passed **/
          report_update_WD(l_report_query_id,
				fs_report_rec.line_id,
				fs_report_rec.primary_item_id,
                                fs_report_rec.schedule_group_id,
				l_flow_schedule_rec.scheduled_completion_date,
                                fs_report_rec.build_sequence, /* Bug 2558664 */
				l_update_variance,
                                l_from_start_date,
                                l_from_end_date,
                                l_to_start_date,
                                l_to_end_date);

         -- Bug 2213859
           MRP_UTIL.MRP_LOG('Calling  MRP_Flow_Schedule_PVT.Process_Flow_Schedule');
         -- Bug 2213859

          MRP_Flow_Schedule_PVT.Process_Flow_Schedule
       		( 	p_api_version_number		=> 1.0,
			x_return_status			=> l_return_status,
			x_msg_count			=> l_msg_count,
			x_msg_data			=> l_msg_data,
			p_control_rec			=> l_control_rec,
			p_old_flow_schedule_rec         => l_old_flow_schedule_rec,
			p_flow_schedule_rec		=> l_flow_schedule_rec,
			x_flow_schedule_rec		=> l_x_flow_schedule_rec
		);

          /* Added for Enhancement #2829204 */
	  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
	    SELECT auto_replenish,
	           wip_entity_id
	      INTO l_auto_replenish,
	           l_wip_entity_id
	      FROM wip_flow_schedules
	     WHERE schedule_number = fs_report_rec.schedule_number
	       AND organization_id = p_organization_id;

	    /* Update the auto_replenish flag of new schedules with the old value,
	       if auto_replenish is not null for old flow schedule */
	    IF l_auto_replenish IS NOT NULL THEN
	      UPDATE wip_flow_schedules
	         SET auto_replenish = l_auto_replenish
	       WHERE schedule_number = l_x_flow_schedule_rec.schedule_number
	         AND organization_id = p_organization_id;

	      /* Update the Kanban Cards to reference the new flow schedule */
	      IF (nvl(l_auto_replenish, 'N') = 'Y') THEN
	        FOR l_kanban_card_activity_csr IN kanban_card_activity_csr(l_wip_entity_id)
                LOOP
                  l_kanban_activity_id := l_kanban_card_activity_csr.kanban_activity_id;

                  UPDATE mtl_kanban_card_activity
                     SET source_wip_entity_id = l_x_flow_schedule_rec.wip_entity_id
                   WHERE kanban_activity_id = l_kanban_activity_id;

                END LOOP; /* end of for loop cursor */
              END IF; /* end of if for nvl(l_auto_replenish,'N') */
            END IF; /* end of if for l_auto_replenish is not null */

  -- Added for project 'Roll Flow Schedules: Maintain Schedule Number'
  -- Store the old/new values of schedule_number and wip_entity_id
            l_loop_count:=l_loop_count+1;
            oldFSSchNum(l_loop_count) := fs_report_rec.schedule_number;
	    newFSSchNum(l_loop_count) := l_x_flow_schedule_rec.schedule_number;
            oldFSWipId(l_loop_count) := fs_report_rec.wip_entity_id;
	    newFSWipId(l_loop_count) := l_x_flow_schedule_rec.wip_entity_id;

	  END IF; /* end of if for l_return_status */

          IF p_output = 2  THEN
            -- Write either error or success message to log
            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
              FND_MESSAGE.set_name('MRP','MRP_ROLL_CREATE');
              FND_MESSAGE.set_token('LINE',fs_report_rec.line_code);
              FND_MESSAGE.set_token('ITEM',fs_report_rec.item);
              FND_MESSAGE.set_token('COMP_DATE',l_x_flow_schedule_rec.scheduled_completion_date);
              FND_MESSAGE.set_token('QTY',l_x_flow_schedule_rec.planned_quantity);
              l_log_message := FND_MESSAGE.get;
              MRP_UTIL.MRP_LOG(l_log_message);
            ELSE
              IF l_msg_count > 0 THEN
                FOR i in 1..l_msg_count LOOP
                  l_log_message := fnd_msg_pub.get(i,'F');
                  MRP_UTIL.MRP_LOG(l_log_message);
                END LOOP;
              END IF;
            END IF;
          -- end if for p_output = 2
          END IF;
          l_update_variance := 0;
      END IF;


      l_old_line_id := fs_report_rec.line_id;
      l_old_line_code := fs_report_rec.line_code;
      l_old_item_id := fs_report_rec.primary_item_id;
      l_old_item := fs_report_rec.item;
      l_old_sg_id := fs_report_rec.schedule_group_id;
      MRP_UTIL.MRP_LOG('item = '||to_char(l_old_item_id)||' var = '||to_char(l_unprocessed_var));
    END LOOP;

    -- Bug 2213859
          /*-----------------------------------------------------------------+
           | After the LOOP completes, all the schedules on the destination  |
           | day are shifted with the count per line which has been newly    |
           | forwarded to avoid bumping;                                     |
           +-----------------------------------------------------------------*/

  /******************* Commented ********************
  UPDATE wip_flow_schedules set roll_forwarded_flag =
  G_ROLL_FORWARDED
  where roll_forwarded_flag =
  G_INTERMEDIATE_ROLL_FORWARDED;
  **************************************************/

    MRP_UTIL.MRP_LOG('Shift build sequences of existing schedules on destination day');
    -- Bug 2558664 handled NULL build sequence counter gracefully
    if (l_build_seq_counter.count > 0) then
      l_index := l_build_seq_counter.first;
      loop
	if (l_build_seq_counter.exists(l_index)) then
          MRP_UTIL.MRP_LOG('Proccessing for line='||l_index);
          l_base_number := nvl(l_build_seq_counter(l_index).base_number,0);
          l_total_count := nvl(l_build_seq_counter(l_index).current_build_seq,0) - l_base_number;
          MRP_UTIL.MRP_LOG('Shift each BUILD_SEQ of existing eligible schedules by '||l_total_count);

          UPDATE wip_flow_schedules
             set BUILD_SEQUENCE = BUILD_SEQUENCE + l_total_count
           WHERE organization_id = p_organization_id
             AND line_id = l_index
             AND nvl(planned_quantity,0) > nvl(quantity_completed,0)
             AND scheduled_completion_date  --fix bug#3170105
                 BETWEEN l_to_start_date AND l_to_end_date+1-1/(24*60*60)
             AND (ROLL_FORWARDED_FLAG <> G_INTERMEDIATE_ROLL_FORWARDED OR
                  ROLL_FORWARDED_FLAG IS NULL); /*Bug 3019639*/

           /*-----------------------------------------------------------------+
            | Update the newly forwarded schedules as ROLL FORWARDED;         |
            | Deduct the base number from the build_sequence                  |
            +-----------------------------------------------------------------*/

          UPDATE wip_flow_schedules set
          roll_forwarded_flag = G_ROLL_FORWARDED,
          build_sequence = build_sequence - l_base_number
          where roll_forwarded_flag = G_INTERMEDIATE_ROLL_FORWARDED
            and line_id = l_index
	    --bug 3749052:
	    and scheduled_completion_date
	        BETWEEN l_to_start_date AND l_to_end_date+1-1/(24*60*60);

	  exit when ( l_index is NULL or l_index = l_build_seq_counter.last );

          l_index := l_build_seq_counter.next(l_index);
	end if; /** END OF if (l_build_seq_counter.exists(l_index)) then **/
      end loop;
    end if;  /** END OF if (l_build_seq_counter.count > 0) then **/

-- Bug 2213859

/* Added for project 'Roll Flow Schedules: Maintain Schedule Number'
   Logic to swap the new schedule number with old schedule number. */
    --First step is to change the schedule number of the rolled FS
    --to a temporaryones to avoid violating the unique contraints
    --on Schedule Number and Org ID and this is done for WIP_FLOW_SCHEDULES
    FORALL i IN 1..l_loop_count
       UPDATE wip_flow_schedules
         SET schedule_number=('?*?'||oldFSSchNum(i))
	 WHERE wip_entity_id=oldFSWipId(i)
	 AND organization_id=p_organization_id;

    --Second Step is to Update the New FS created to use the old rolled FS
    --Schedule Number. This is need to be done for WIP_FLOW_SCHEDULES
    FORALL i IN 1..l_loop_count
       UPDATE wip_flow_schedules
         SET schedule_number=oldFSSchNum(i)
	 WHERE wip_entity_id=newFSWipId(i)
	 AND organization_id=p_organization_id;

    --Third Step is to Update the Old rolled FS to use the Newly created FS
    --Schedule Number. This is need to be done for WIP_FLOW_SCHEDULES
    FORALL i IN 1..l_loop_count
       UPDATE wip_flow_schedules
         SET schedule_number=newFSSchNum(i)
	 WHERE wip_entity_id=oldFSWipId(i)
	 AND organization_id=p_organization_id;

    --Update the detail record in execution to point to new schedule number.
    FORALL i IN 1..l_loop_count
       UPDATE flm_exe_operations
         SET wip_entity_id=newFSWipId(i)
	 WHERE wip_entity_id=oldFSWipId(i)
	 AND organization_id=p_organization_id;
    FORALL i IN 1..l_loop_count
       UPDATE flm_exe_req_operations
         SET wip_entity_id=newFSWipId(i)
	 WHERE wip_entity_id=oldFSWipId(i)
	 AND organization_id=p_organization_id;
    FORALL i IN 1..l_loop_count
       UPDATE flm_exe_lot_numbers
         SET wip_entity_id=newFSWipId(i)
	 WHERE wip_entity_id=oldFSWipId(i)
	 AND organization_id=p_organization_id;
    FORALL i IN 1..l_loop_count
       UPDATE flm_exe_serial_numbers
         SET wip_entity_id=newFSWipId(i)
	 WHERE wip_entity_id=oldFSWipId(i)
	 AND organization_id=p_organization_id;


  ELSIF p_spread_qty = 3 THEN
  /* this means close all the past schedules */

    l_cursor := Close_All_Past_Schedules;
    IF l_cursor IS NULL THEN
      RAISE unexpected_error;
    END IF;

    LOOP
      l_rows := dbms_sql.fetch_rows(l_cursor);
      IF l_rows > 0 THEN
        dbms_sql.column_value(l_cursor, 1, l_flow_schedule_rec.wip_entity_id);
      END IF;
      EXIT WHEN l_rows = 0;
      UPDATE wip_flow_schedules SET status = 2,
             date_closed = flm_timezone.sysdate00_in_server  --fix bug#3170105
      WHERE wip_entity_id = l_flow_schedule_rec.wip_entity_id;
      MRP_UTIL.MRP_LOG('Closed Schedule with wip_entity_id:'||to_char(
      l_flow_schedule_rec.wip_entity_id));
    END LOOP;
  END IF;

  IF (dbms_sql.is_open(l_cursor)) THEN
    dbms_sql.close_cursor(l_cursor);
  END IF;
  IF p_spread_qty = 3 THEN
    RETURN;
  END IF;
  FND_MESSAGE.set_name('MRP','EC_FROM');
  l_trans_var1 := FND_MESSAGE.get;
  FND_MESSAGE.set_name('MRP','EC_TO');
  l_trans_var2 := FND_MESSAGE.get;
  FND_MESSAGE.set_name('MRP','EC_ORIGINAL');
  l_trans_var3 := FND_MESSAGE.get;
  FND_MESSAGE.set_name('MRP','EC_ADJUSTED');
  l_trans_var4 := FND_MESSAGE.get;

  l_out_message := '                                   ' ||
	rpad(substr(l_trans_var1,1,8),38) || ' ' ||
    	rpad(substr(l_trans_var2,1,9),9) || ' ' ||
    	rpad(substr(l_trans_var3,1,8),8) || ' ' ||
        rpad(substr(l_trans_var4,1,8),8);
  MRP_UTIL.MRP_OUT(l_out_message);

  FND_MESSAGE.set_name('MRP','EC_SCHEDULE');
  l_trans_var1 := FND_MESSAGE.get;
  FND_MESSAGE.set_name('MRP','EC_SCHEDULED');
  l_trans_var2 := FND_MESSAGE.get;
  FND_MESSAGE.set_name('MRP','EC_COMPLETED');
  l_trans_var3 := FND_MESSAGE.get;
  FND_MESSAGE.set_name('MRP','EC_ADJUSTED');
  l_trans_var4 := FND_MESSAGE.get;

  l_out_message := '                          ' ||
	rpad(substr(l_trans_var1,1,8),8) || ' ' ||
	rpad(substr(l_trans_var1,1,9),9) || ' ' ||
        rpad(substr(l_trans_var2,1,9),9) || ' ' ||
        rpad(substr(l_trans_var3,1,9),18) || ' ' ||
	rpad(substr(l_trans_var1,1,9),9) || ' ' ||
	rpad(substr(l_trans_var1,1,8),8) || ' ' ||
	rpad(substr(l_trans_var1,1,8),8) || ' ' ||
	rpad(substr(l_trans_var4,1,8),8);

  MRP_UTIL.MRP_OUT(l_out_message);

  FND_MESSAGE.set_name('MRP','EC_LINE');
  l_trans_var1 := FND_MESSAGE.get;
  FND_MESSAGE.set_name('MRP','EC_ITEM');
  l_trans_var2 := FND_MESSAGE.get;
  FND_MESSAGE.set_name('MRP','EC_GROUP');
  l_trans_var3 := FND_MESSAGE.get;
  FND_MESSAGE.set_name('MRP','EC_DATE');
  l_trans_var4 := FND_MESSAGE.get;
  FND_MESSAGE.set_name('MRP','EC_QUANTITY');
  l_trans_var5 := FND_MESSAGE.get;
  FND_MESSAGE.set_name('MRP','EC_VARIANCE');
  l_trans_var6 := FND_MESSAGE.get;

  l_out_message := rpad(substr(l_trans_var1,1,10),10) || ' ' ||
	rpad(substr(l_trans_var2,1,14),14) || ' ' ||
	rpad(substr(l_trans_var3,1,8),8) || ' ' ||
	rpad(substr(l_trans_var4,1,9),9) || ' ' ||
	rpad(substr(l_trans_var5,1,9),9) || ' ' ||
	rpad(substr(l_trans_var5,1,9),9) || ' ' ||
	rpad(substr(l_trans_var6,1,8),8) || ' ' ||
	rpad(substr(l_trans_var4,1,9),9) || ' ' ||
	rpad(substr(l_trans_var5,1,8),8) || ' ' ||
	rpad(substr(l_trans_var5,1,8),8) || ' ' ||
	rpad(substr(l_trans_var5,1,8),8);
  MRP_UTIL.MRP_OUT(l_out_message);
  l_out_message := '---------- -------------- -------- --------- --------- --------- -------- --------- -------- -------- --------';
  MRP_UTIL.MRP_OUT(l_out_message);

  -- Reinitialize values
  l_old_line_id := -1;
  l_old_item_id := -1;
  l_old_sg_id := -1;

  OPEN REPORT_CURSOR(l_report_query_id);

  LOOP

      FETCH REPORT_CURSOR INTO
        fs_report_rec.line_code,
        fs_report_rec.line_id,
	fs_report_rec.item,
        fs_report_rec.primary_item_id,
	fs_report_rec.schedule_group,
        fs_report_rec.schedule_group_id,
	fs_report_rec.completion_date,
	fs_report_rec.planned_quantity,
	fs_report_rec.quantity_completed,
 	fs_report_rec.variance1,
	fs_report_rec.to_completion_date,
	fs_report_rec.to_scheduled_qty,
	fs_report_rec.to_adjusted_qty,
	fs_report_rec.variance2;

      IF REPORT_CURSOR%NOTFOUND THEN
         fs_report_rec.primary_item_id := -1;
      END IF;

      IF (NVL(fs_report_rec.schedule_group_id,-1) <> NVL(l_old_sg_id,-1)
           AND l_old_sg_id <> -1) OR
	   (fs_report_rec.primary_item_id <> l_old_item_id
	   AND l_old_item_id <> -1) OR
           (fs_report_rec.line_id <> l_old_line_id
           AND l_old_line_id <> -1)
      THEN
          OPEN REPORT_TOTALS(l_report_query_id, l_old_line_id,
		l_old_item_id, l_old_sg_id);

          FETCH REPORT_TOTALS INTO
		l_planned_total,
		l_completed_total,
		l_variance1_total,
		l_scheduled_total,
		l_adjusted_total,
		l_variance2_total;

          CLOSE REPORT_TOTALS;

          l_out_message := '-------------------------------------------- --------- --------- -------- --------- -------- -------- --------';
          MRP_UTIL.MRP_OUT(l_out_message);

          FND_MESSAGE.set_name('MRP','EC_TOTAL');
          l_out_message := FND_MESSAGE.get;

          l_out_message := rpad(substr(l_out_message,1,8),8) || '                                     '||
			lpad(l_planned_total,9) || ' ' ||
			lpad(l_completed_total,9) || ' ' || lpad(l_variance1_total,8) ||
			'           ' ||
			lpad(l_scheduled_total,8) || ' ' || lpad(l_adjusted_total,8) || ' ' ||
 			lpad(l_variance2_total,8);

          MRP_UTIL.MRP_OUT(l_out_message);

          l_out_message := ' ';
          MRP_UTIL.MRP_OUT(l_out_message);
      END IF;

      IF REPORT_CURSOR%NOTFOUND THEN
        FND_MESSAGE.set_name('MRP','EC_END_OF_REPORT');
        l_out_message := FND_MESSAGE.get;
        MRP_UTIL.MRP_OUT(l_out_message);
        EXIT;
      END IF;

      l_out_message := fs_report_rec.line_code || ' ' ||
	fs_report_rec.item || ' ' ||
	fs_report_rec.schedule_group || ' ' ||
	fs_report_rec.completion_date || ' ' ||
	lpad(fs_report_rec.planned_quantity,9) || ' ' ||
	lpad(fs_report_rec.quantity_completed,9) || ' ' ||
 	lpad(fs_report_rec.variance1,8) || ' ' ||
	fs_report_rec.to_completion_date || ' ' ||
	lpad(fs_report_rec.to_scheduled_qty,8) || ' ' ||
	lpad(fs_report_rec.to_adjusted_qty,8) || ' ' ||
	lpad(fs_report_rec.variance2,8);

      MRP_UTIL.MRP_OUT(l_out_message);

      l_old_sg_id := fs_report_rec.schedule_group_id;
      l_old_item_id := fs_report_rec.primary_item_id;
      l_old_line_id := fs_report_rec.line_id;
  END LOOP;

  CLOSE REPORT_CURSOR;

  -- Rollback if haven't selected update
  IF p_output <> 2 THEN
    ROLLBACK;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;

  WHEN expected_error THEN
    ROLLBACK;
    IF RETCODE <> 1 THEN
      RETCODE := G_ERROR;
    END IF;
    FND_MESSAGE.set_name('MRP','MRP_ROLL_FLOW_ERROR');
    ERRBUF := FND_MESSAGE.get;
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);
    l_log_message := 'Unexpected SQL Error: '||sqlerrm;
    MRP_UTIL.MRP_LOG(l_log_message);

  WHEN unexpected_error THEN
    ROLLBACK;
    RETCODE := G_ERROR;
    FND_MESSAGE.set_name('MRP','MRP_ROLL_FLOW_ERROR');
    ERRBUF := FND_MESSAGE.get;
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);
    l_log_message := 'Unexpected SQL Error: '||sqlerrm;
    MRP_UTIL.MRP_LOG(l_log_message);

  WHEN OTHERS THEN
    ROLLBACK;
    RETCODE := G_ERROR;
    FND_MESSAGE.set_name('MRP','MRP_ROLL_FLOW_ERROR');
    ERRBUF := FND_MESSAGE.get;
    l_log_message := FND_MESSAGE.get;
    MRP_UTIL.MRP_LOG(l_log_message);
    l_log_message := 'Unexpected SQL Error: '||sqlerrm;
    MRP_UTIL.MRP_LOG(l_log_message);

END Roll_Flow_Schedules;

-- ========================================================================
--  This function builds the where clause for the item range specified
--  Function accepts system items as delimited strings and build the where
--  clause. It expects proper escaping, if 'delimiter' itself a valid
--  character within the segment values.
--  Delimiter is ignored if only ONE segment is enabled.
-- ========================================================================
/** Bug 2558664 - modified Item_Where_Clause to use fnd_flex_server.parse_flex_values
                  which handles 'delimiter' more gracefully **/
/** don't use this method!!! */
/* this method is moved to package FLM_UTIL */
FUNCTION Item_Where_Clause( p_item_lo          IN      VARCHAR2,
                            p_item_hi          IN      VARCHAR2,
                            p_table_name       IN      VARCHAR2,
                            x_where            OUT     NOCOPY	VARCHAR2,
                            x_err_buf          OUT     NOCOPY	VARCHAR2)
RETURN BOOLEAN IS

BEGIN

  x_where := ' ';
  x_err_buf := ' ';

  RETURN TRUE;

END Item_Where_Clause;

-- ========================================================================
--  This function builds the where clause for the category range specified
-- ========================================================================
/** don't use this method!!! */
/* this method is moved to package FLM_UTIL */
FUNCTION Category_Where_Clause (  p_cat_lo      IN      VARCHAR2,
                                  p_cat_hi      IN      VARCHAR2,
                                  p_table_name  IN      VARCHAR2,
                                  p_cat_struct_id IN    NUMBER,
                                  p_where       OUT     NOCOPY	VARCHAR2,
                                  x_err_buf     OUT     NOCOPY	VARCHAR2 )
RETURN BOOLEAN IS

BEGIN
  p_where := ' ';
  x_err_buf := ' ';

  RETURN TRUE;

END Category_Where_Clause;


PROCEDURE Line_Schedule (       p_rule_id               IN NUMBER,
                                p_line_id               IN NUMBER,
                                p_org_id                IN NUMBER,
                                p_sched_start_date      IN DATE,
                                p_sched_end_date        IN DATE,
                                p_update                IN NUMBER,
                                p_flex_tolerance        IN NUMBER,
                                x_return_status         OUT NOCOPY	VARCHAR2,
                                x_msg_count             OUT NOCOPY	NUMBER,
                                x_msg_data              OUT NOCOPY	VARCHAR2) IS

  CURSOR RULE_CURSOR IS
  SELECT distinct user_defined
  FROM mrp_scheduling_rules
  WHERE rule_id = p_rule_id;

  l_api_version_number		CONSTANT NUMBER := 1.0;
  l_api_name			CONSTANT VARCHAR2(30) := 'Line_Schedule';
  l_user_defined		NUMBER;

  l_return_status		VARCHAR2(1);
  l_msg_count			NUMBER;
  l_msg_data			VARCHAR2(2000);

BEGIN

    OPEN RULE_CURSOR;
    FETCH RULE_CURSOR into l_user_defined;
    CLOSE RULE_CURSOR;

    IF p_rule_id <> -1 THEN
      IF l_user_defined = 1 THEN
        MRP_CUSTOM_LINE_SCHEDULE.Custom_Schedule(
                l_api_version_number,
		p_rule_id,
		p_line_id,
		p_org_id,
                p_flex_tolerance, /* Added in the bug 1949098*/
		p_sched_start_date,
		p_sched_end_date,
		x_return_status,
		x_msg_count,
		x_msg_data);
      ELSE
        MRP_LINE_SCHEDULE_ALGORITHM.Schedule(
		p_rule_id,
		p_line_id,
		p_org_id,
		p_sched_start_date,
		p_sched_end_date,
                p_flex_tolerance,
		x_return_status,
		x_msg_count,
		x_msg_data);
      END IF;
    END IF;

    IF p_update = 1 THEN
        Post_Schedule_Update (p_org_id);
    END IF;

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
            ,   'Line_Schedule'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Line_Schedule;

PROCEDURE Post_Schedule_Update (p_org_id IN NUMBER)
IS

  CURSOR C1 IS
  SELECT wip_entity_id, schedule_number
  FROM wip_flow_schedules
  WHERE request_id = USERENV( 'SESSIONID' );

  CURSOR C2 IS
  SELECT sum(planned_quantity), demand_source_line
  FROM wip_flow_schedules
  WHERE organization_id = p_org_id
  AND demand_source_header_id IS NULL
  AND request_id = USERENV('SESSIONID')
  GROUP BY demand_source_line;

  l_wip_entity_id NUMBER;
  l_schedule_number       VARCHAR2(30);
  l_schedule_number_out VARCHAR2(30);
  l_error         NUMBER;
  l_quantity              NUMBER;
  l_trans_id              NUMBER;

BEGIN

  OPEN C1;
  LOOP
    FETCH C1 INTO l_wip_entity_id, l_schedule_number;
    EXIT WHEN C1%NOTFOUND;

    --Bug 6122344
    IF l_schedule_number =
        --(nvl(substr(FND_PROFILE.value('WIP_JOB_PREFIX'),1,20),'X')
        --        || to_char(l_wip_entity_id))
        'FLM-INTERNAL' || (to_char(l_wip_entity_id))

    THEN
      l_schedule_number_out := NULL;
      l_error := WIP_FLOW_DERIVE.schedule_number(l_schedule_number_out);
      IF l_error = 1 THEN
        UPDATE wip_flow_schedules
        SET schedule_number = l_schedule_number_out
        WHERE wip_entity_id = l_wip_entity_id;

        UPDATE wip_entities
        SET wip_entity_name = l_schedule_number_out
        WHERE wip_entity_id = l_wip_entity_id;
      ELSE
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END LOOP;
  CLOSE C1;

  Explode_New_Items;

  OPEN C2;
  LOOP
    FETCH C2 into l_quantity, l_trans_id;
    EXIT WHEN C2%NOTFOUND;

    UPDATE mrp_recommendations
    SET quantity_in_process = nvl(quantity_in_process,0) + l_quantity
    WHERE transaction_id = l_trans_id;
  END LOOP;
  CLOSE C2;

  UPDATE wip_flow_schedules
  SET request_id = NULL,
	scheduled_flag = 1
  WHERE request_id = USERENV('SESSIONID');

END Post_Schedule_Update;

PROCEDURE Explode_New_Items
IS
  CURSOR C1 IS
  SELECT distinct primary_item_id, organization_id, alternate_bom_designator
  FROM wip_flow_schedules
  WHERE request_id = USERENV('SESSIONID');

  l_item_id		NUMBER;
  l_org_id		NUMBER;
  l_alt_bom		VARCHAR2(10);
  l_error_msg		VARCHAR2(2000);
  l_error_code		NUMBER;

BEGIN

  OPEN C1;

  LOOP
    FETCH C1 INTO l_item_id, l_org_id, l_alt_bom;
    EXIT WHEN C1%NOTFOUND;

    BOM_OE_EXPLODER_PKG.be_exploder(
        arg_org_id => l_org_id,
        arg_starting_rev_date => sysdate - 3,
        arg_expl_type => 'ALL',
        arg_order_by => 1,
        arg_levels_to_explode => 20,
        arg_item_id => l_item_id,
        arg_comp_code => '',
        arg_user_id => 0,
        arg_err_msg => l_error_msg,
        arg_error_code => l_error_code,
	arg_alt_bom_desig => l_alt_bom
    );

    IF l_error_code = 9998 THEN
      -- Do nothing, there was just no bill to explode
      NULL;
    ELSIF l_error_code <> 0 THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('BOM',l_error_msg);
        FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END LOOP;

  CLOSE C1;

END Explode_New_Items;


/** Bug 2906437 -- Calculate_Needed--
      all right hand side expressions are nvl-ed
      and weeded out old commented code
**/
PROCEDURE calculate_needed(i_root	IN	NUMBER) IS
  l_index	NUMBER;
BEGIN
  IF l_lines.COUNT <= 0 THEN
    RETURN;
  END IF;
  IF l_lines(i_root).first_child IS NOT NULL THEN  -- Not a Leaf
    l_lines(i_root).needed_quantity := 0;
    l_index := l_lines(i_root).first_child;
    LOOP
      calculate_needed(l_index);
      l_lines(i_root).needed_quantity := nvl(l_lines(i_root).needed_quantity,0) +
	                                 nvl(l_lines(l_index).needed_quantity,0);
      EXIT WHEN l_lines(l_index).next_brother IS NULL;
      l_index := l_lines(l_index).next_brother;
    END LOOP;
    l_lines(i_root).needed_quantity := nvl(l_lines(i_root).needed_quantity,0) +
	nvl(l_lines(i_root).order_quantity,0) - nvl(l_lines(i_root).fs_quantity,0);
    IF l_lines(i_root).needed_quantity < 0 THEN
      l_lines(i_root).needed_quantity := 0;
    END IF;
  ELSE  -- Leaf
    -- calculate needed_quantity
    l_lines(i_root).needed_quantity :=
	greatest(nvl(l_lines(i_root).order_quantity,0) - nvl(l_lines(i_root).fs_quantity,0),
		 0);
  END IF;
END calculate_needed;


PROCEDURE distribute_quantity(i_root	IN	NUMBER) IS
  l_index	NUMBER;
  l_index1      NUMBER; -- Bug 3039782
  l_index2      NUMBER; -- Bug 3039782
  l_overquantity	NUMBER;
  l_flag    BOOLEAN := TRUE;  -- Bug 3267542
BEGIN
  IF l_lines.COUNT <= 0 THEN
    RETURN;
  END IF;
  IF l_lines(i_root).first_child IS NOT NULL THEN  -- Not a Leaf
    l_overquantity := l_lines(i_root).fs_quantity +
			l_lines(i_root).distributed_quantity -
			l_lines(i_root).order_quantity;
    IF l_overquantity <= 0 THEN
  /* Bug 3039782 -- Code additition starts */
/***************************************************
     Removed code added in fix for bug 2906437
     and added the following
*****************************************************/
        l_index2 := l_lines(i_root).first_child;
        loop
          l_lines(l_index2).distributed_quantity := 0;
          distribute_quantity(l_index2);
          EXIT WHEN l_lines(l_index2).next_brother IS NULL;
          l_index2 := l_lines(l_index2).next_brother;
        end loop;
  /* Bug 3039782 -- Code additition ends */
      l_lines(i_root).needed_quantity := 0 - l_overquantity;
      RETURN;
    ELSE
    /*************************************************************************
     Bug 2536351-
     Whole logic of filling up overquantity is changed, rather made opposite.
     Now, any 'overqunatity' obtained from parent is being filled up starting
     from last child to first child browsing through previous brothers
    **************************************************************************/
      l_lines(i_root).needed_quantity := 0;
      l_index := l_lines(i_root).last_child;
      LOOP
        IF l_lines(l_index).needed_quantity > 0 THEN
          IF l_lines(l_index).needed_quantity > l_overquantity THEN
	    l_lines(l_index).distributed_quantity := l_overquantity;
	    l_overquantity := 0;
          ELSE
	    l_lines(l_index).distributed_quantity := l_lines(l_index).needed_quantity;
	    l_overquantity := l_overquantity - l_lines(l_index).needed_quantity;
          END IF;
	  distribute_quantity(l_index);
        END IF;
        /*Bug 3267542 -
        EXIT WHEN l_lines(l_index).previous_brother IS NULL or l_overquantity <= 0;
        Commented the above line and added the following to set l_flag */
        IF l_lines(l_index).previous_brother IS NULL or l_overquantity <= 0 THEN
          IF l_lines(l_index).previous_brother IS NULL THEN
            l_flag := FALSE;
          ELSE
            l_flag := TRUE;
            l_index1 := l_lines(l_index).previous_brother;
          END IF;
          EXIT;
        END IF;
        /*Bug 3267542 - addition for bug ends */
        l_index := l_lines(l_index).previous_brother;
	/** Modification for Bug 2536351 **/
      END LOOP; -- All Children
    END IF; -- Overquantity > 0
  /* Bug 3039782 -- Code additition starts */
/***************************************************
     Removed code added in fix for bug 2906437
     and added the following
*****************************************************/
     /*Bug 3267542 - modification starts. Call distribute_quantity util no prev. brother, if l_flag is set*/
     if l_flag then
       loop
         distribute_quantity(l_index1);
         EXIT WHEN l_lines(l_index1).previous_brother IS NULL;
         l_index1 := l_lines(l_index1).previous_brother;
       end loop;
     end if;
     /*Bug 3267542 - modification ends*/
  /* Bug 3039782 -- Code additition ends */
  ELSE
    -- nothing to distribute
    l_lines(i_root).needed_quantity :=
	greatest(l_lines(i_root).needed_quantity -
		 l_lines(i_root).distributed_quantity,
		 0);
  END IF;
END distribute_quantity;

/*Bug 3042045 - new parameter p_use_open_quantity added*/
FUNCTION get_flow_quantity_split(p_demand_source_line	  IN	VARCHAR2,
				 p_demand_source_type     IN 	NUMBER,
				 p_demand_source_delivery IN    VARCHAR2,
                                 p_use_open_quantity      IN    VARCHAR2 )
RETURN NUMBER
IS

--
-- Local Variables and Cursors
--
  l_header_id	number;
  l_item_id	number;

/*Bug 3042045*/
  CURSOR all_lines(i_header_id number, i_item_id number) IS
    SELECT line_id,
           --fix bug#3417588
	   decode(nvl(p_use_open_quantity, 'N'), 'Y',
	     decode(SL.SHIPPED_QUANTITY, NULL,
               greatest(INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY(SL.SHIP_FROM_ORG_ID,
 			SL.INVENTORY_ITEM_ID,
			SL.ORDER_QUANTITY_UOM,
			SL.ORDERED_QUANTITY)
		    - MRP_FLOW_SCHEDULE_UTIL.GET_RESERVATION_QUANTITY(
			SL.SHIP_FROM_ORG_ID,
			SL.INVENTORY_ITEM_ID,
			SL.LINE_ID,
			p_use_open_quantity), 0),
               0),
             greatest(INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY(SL.SHIP_FROM_ORG_ID,
 			SL.INVENTORY_ITEM_ID,
			SL.ORDER_QUANTITY_UOM,
			SL.ORDERED_QUANTITY)
		    - MRP_FLOW_SCHEDULE_UTIL.GET_RESERVATION_QUANTITY(
			SL.SHIP_FROM_ORG_ID,
			SL.INVENTORY_ITEM_ID,
			SL.LINE_ID,
			p_use_open_quantity), 0))
             order_quantity,
             --end of fix bug#3417588
	   split_from_line_id parent_line_id
    FROM oe_order_lines_all sl
    WHERE header_id = i_header_id
      AND inventory_item_id = i_item_id
    ORDER BY sl.line_id;

  l_root_id	NUMBER;
  l_this_root	NUMBER;
  l_index	NUMBER;
  l_index_temp	NUMBER;

BEGIN
  -- get the header and item id
  SELECT header_id, inventory_item_id
  INTO l_header_id, l_item_id
  FROM oe_order_lines_all
  WHERE line_id = to_number(p_demand_source_line);

  -- get all potentially relevant lines
  l_lines.DELETE;
  FOR line_rec IN all_lines(l_header_id, l_item_id) LOOP
    -- fetch line_id, order_quantity, parent_line_id
    l_lines(line_rec.line_id).line_id := line_rec.line_id;
    l_lines(line_rec.line_id).order_quantity := line_rec.order_quantity;
    l_lines(line_rec.line_id).parent_line_id := line_rec.parent_line_id;
  END LOOP;

  -- this shouldn't happen
  IF l_lines.COUNT <= 0 THEN
    RETURN 0;
  END IF;

  --
  -- Build Tree
  --
  -- find root
  l_root_id := to_number(p_demand_source_line);
  WHILE l_lines(l_root_id).parent_line_id IS NOT NULL LOOP
    l_root_id := l_lines(l_root_id).parent_line_id;
  END LOOP;
  -- delete un-relevant lines
  l_index := l_lines.FIRST;
  LOOP
    -- Find the root for this line
    l_this_root := l_lines(l_index).line_id;
    WHILE l_lines(l_this_root).parent_line_id IS NOT NULL LOOP
      l_this_root := l_lines(l_this_root).parent_line_id;
      IF NOT l_lines.EXISTS(l_this_root) THEN
        EXIT;
      END IF;
    END LOOP;
    -- If a different root, then delete
    IF l_this_root <> l_root_id THEN
      l_index_temp := l_index;
      IF l_index = l_lines.LAST THEN
        l_lines.DELETE(l_index_temp);
        EXIT;
      ELSE
        l_index := l_lines.NEXT(l_index);
        l_lines.DELETE(l_index_temp);
      END IF;
    ELSE  -- If in the same root, plug into the tree
      IF l_lines(l_index).parent_line_id IS NOT NULL THEN
        IF l_lines(l_lines(l_index).parent_line_id).first_child IS NULL THEN
          l_lines(l_lines(l_index).parent_line_id).first_child := l_index;
          l_lines(l_lines(l_index).parent_line_id).last_child := l_index;
        ELSE
          l_lines(l_lines(l_lines(l_index).parent_line_id).last_child).next_brother := l_index;
          l_lines(l_lines(l_index).parent_line_id).last_child := l_index;
        END IF;
      END IF;
      EXIT WHEN l_index = l_lines.LAST;
      l_index := l_lines.NEXT(l_index);
    END IF;
  END LOOP;

/** Bug 2536351 - update previous_brother of each child node **/
  for i in l_lines.FIRST..l_lines.LAST
  LOOP
    if (l_lines.exists(i)) then
      if (l_lines(i).next_brother is NOT NULL) THEN
        l_lines(l_lines(i).next_brother).previous_brother := i;
      END IF;
    end if;
  END LOOP;
/** Bug 2536351 - update previous_brother ends ****************/

  -- query flow quantity
  l_index := l_lines.FIRST;
  LOOP
/*Bug 3042045 - modified decode statement
    if 'Use Open Quantity' = 'Y'         - if 'closed schedule' return 0,
                                             else return (planned_quantity minus quantity_completed)
    if 'Use Open Quantity' = 'N' or NULL - if 'closed schedule' return quantity_completed,
                                             else return planned_quantity
*/
    SELECT nvl(sum(decode(nvl(p_use_open_quantity,'N'),'Y',decode(status,2,0,
                                                                          (planned_quantity-quantity_completed)),
                                                           decode(status,2,quantity_completed,
 	 		                                                   planned_quantity))),0)
    INTO l_lines(l_index).fs_quantity
    FROM wip_flow_schedules
    WHERE primary_item_id = l_item_id
      AND demand_source_line = to_char(l_lines(l_index).line_id)
      AND demand_source_type = p_demand_source_type
      AND ((demand_source_delivery IS NULL) or
	   (demand_source_delivery = p_demand_source_delivery));
    l_lines(l_index).distributed_quantity := 0;
    EXIT WHEN l_index = l_lines.LAST;
    l_index := l_lines.NEXT(l_index);
  END LOOP;

  -- calculate needed quantity
  calculate_needed(l_root_id);
  -- distribute quantity
  distribute_quantity(l_root_id);
  --return l_lines(to_number(p_demand_source_line)).fs_quantity;
  /** Bug 2536351 **/
  RETURN greatest(l_lines(to_number(p_demand_source_line)).order_quantity -
	          l_lines(to_number(p_demand_source_line)).needed_quantity,0);
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END get_flow_quantity_split;

/*Bug 3042045 - new parameter p_use_open_quantity added*/
FUNCTION Get_Flow_Quantity(	p_demand_source_line	 IN	VARCHAR2,
				p_demand_source_type 	 IN 	NUMBER,
				p_demand_source_delivery IN     VARCHAR2,
				p_use_open_quantity      IN     VARCHAR2 )
RETURN NUMBER
IS

/*Bug 3042045 - modified decode statement
    if 'Use Open Quantity' = 'Y'         - if 'closed schedule' return 0,
                                             else return (planned_quantity minus quantity_completed)
    if 'Use Open Quantity' = 'N' or NULL - if 'closed schedule' return quantity_completed,
                                             else return planned_quantity
*/
  CURSOR FLOW_QUANTITY IS
  SELECT nvl(sum(decode(nvl(p_use_open_quantity,'N'),'Y',decode(status,2,0,
                                                                        (planned_quantity-quantity_completed)),
                                                         decode(status,2,quantity_completed,
  		                                                         planned_quantity))),0)
  FROM wip_flow_schedules
  WHERE ((demand_source_line = p_demand_source_line
  AND demand_source_type = p_demand_source_type
  AND ((demand_source_delivery IS NULL)or(demand_source_delivery = p_demand_source_delivery))) or (so_consumed_plan_id = p_demand_source_line)/*Added for bugfix:8200872 */);

 l_quantity	NUMBER := 0;
  l_split_from_line	NUMBER := NULL;
BEGIN
  IF p_demand_source_type = 2 THEN
    SELECT split_from_line_id
    INTO l_split_from_line
    FROM oe_order_lines_all
    WHERE line_id = to_number(p_demand_source_line);
  END IF;

  IF l_split_from_line IS NOT NULL THEN
    return get_flow_quantity_split(p_demand_source_line,
				   p_demand_source_type,
				   p_demand_source_delivery,
				   p_use_open_quantity);                  /*Bug 3042045*/
  ELSE
    OPEN FLOW_QUANTITY;
    FETCH FLOW_QUANTITY INTO l_quantity;
    CLOSE FLOW_QUANTITY;

    RETURN l_quantity;
  END IF;
EXCEPTION

  WHEN NO_DATA_FOUND THEN

    RETURN 0;

END Get_Flow_Quantity;

FUNCTION Get_Demand_Project(	p_demand_id 	IN 	NUMBER,
				p_type		IN	NUMBER )
RETURN NUMBER
IS

  CURSOR DEMAND_PROJECT IS
  SELECT project_id, task_id
  FROM pjm_project_demand_v
  WHERE demand_id = p_demand_id;

  l_project_id	NUMBER;
  l_task_id	NUMBER;

BEGIN

  OPEN DEMAND_PROJECT;
  FETCH DEMAND_PROJECT INTO l_project_id, l_task_id;
  CLOSE DEMAND_PROJECT;

  IF p_type = 1 THEN
    RETURN l_project_id;
  ELSIF p_type = 2 THEN
    RETURN l_task_id;
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    RETURN NULL;

END Get_Demand_Project;

FUNCTION check_ato_holds(p_line_id      IN      NUMBER,
                        p_header_id     IN      NUMBER,
                        p_action_id     IN      NUMBER)
RETURN NUMBER IS

  l_check_holds_result     VARCHAR2(30);
  l_return_status          VARCHAR2(30);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_return NUMBER;

BEGIN
     OE_HOLDS_PUB.Check_Holds
          (p_api_version      => 1.0
          ,p_header_id        => p_header_id
          ,p_line_id          => p_line_id
          ,x_result_out       => l_check_holds_result
          ,x_return_status    => l_return_status
          ,x_msg_count        => l_msg_count
          ,x_msg_data         => l_msg_data
     );

     l_return := 1;
     IF ( l_return_status = FND_API.G_RET_STS_SUCCESS AND
          l_check_holds_result = FND_API.G_FALSE ) THEN
             l_return := 0;
     END IF;

     return l_return;

EXCEPTION
 WHEN OTHERS THEN
  mrp_util.mrp_log('Excpetion during checking holds ' || sqlerrm );
  return 1;

END Check_ATO_Holds;

/*Bug 3042045 - new parameter p_use_open_quantity added*/
FUNCTION Get_Reservation_Quantity ( p_org_id   IN NUMBER,
                                    p_item_id  IN NUMBER,
                                    p_line_id  IN NUMBER,
                                    p_use_open_quantity IN VARCHAR2 )
RETURN NUMBER IS

  l_reserved_qty        NUMBER := 0;
  l_wip_state_qty       NUMBER := 0;

BEGIN

   /* Fix bug 2466429, do UOM conversion. */

   /*fix bug#3294125: Added 'demand_source_line = nvl (p_line_id,-1)'.
    *This would allow the reservation qty to be taken into account
    *whenever the order source is inconsistent with the corresponding
    *flow schedule.
    */
   SELECT nvl(sum(INV_DECIMALS_PUB.GET_PRIMARY_QUANTITY(P_ORG_ID,
						       P_ITEM_ID,
						       RESERVATION_UOM_CODE,
						       RESERVATION_QUANTITY)), 0)
   INTO l_reserved_qty
   FROM mtl_reservations
   WHERE organization_id = p_org_id
     AND inventory_item_id = p_item_id
     AND demand_source_line_id = p_line_id
     AND ( nvl(p_use_open_quantity,'N') = 'N'
           and (supply_source_header_id is NULL
                or not exists (select wip_entity_id
                               from wip_flow_schedules
		               where wip_entity_id = supply_source_header_id
                                 and demand_source_line = nvl(p_line_id,-1))
                )
           or nvl(p_use_open_quantity,'N') = 'Y') ;  /*Bug 3042045 - do not check supply source for ATO items*/

  if p_use_open_quantity = 'Y' then
     SELECT nvl(SUM(mtrl.primary_quantity),0)
     INTO l_wip_state_qty
     FROM mtl_txn_request_lines mtrl, wms_license_plate_numbers wlpn, wip_lpn_completions wlc
     WHERE mtrl.organization_id = p_org_id
       AND mtrl.inventory_item_id = p_item_id
       AND NVL(mtrl.quantity_delivered, 0) = 0
       AND mtrl.line_status <> inv_globals.g_to_status_closed
       AND mtrl.lpn_id = wlpn.lpn_id
       AND wlpn.lpn_context = 2 -- WIP
       AND wlc.header_id = mtrl.reference_id
       AND wlc.wip_entity_id = mtrl.txn_source_id
       AND wlc.lpn_id = mtrl.lpn_id
       AND wlc.inventory_item_id = mtrl.inventory_item_id
       AND wlc.organization_id = mtrl.organization_id
       AND wlc.demand_source_line = p_line_id
       AND wlc.wip_entity_type = 4;

     l_reserved_qty := l_reserved_qty + l_wip_state_qty;
  end if;

  RETURN l_reserved_qty;

END Get_Reservation_Quantity;

FUNCTION check_std_holds(p_line_id  IN NUMBER) return NUMBER
IS
  CURSOR OM_LINE_STD_HOLDS IS
    SELECT count(*)
    FROM   oe_hold_sources_all hs,
           oe_order_holds_all oh,
           oe_hold_definitions hd
    WHERE  oh.hold_source_id = hs.hold_source_id
    AND    oh.line_id = p_line_id
    AND    oh.hold_release_id IS NULL
    AND    hd.item_type = 'OEOL'
    AND    hd.activity_name = 'LINE_SCHEDULING'
    AND    hd.hold_id = hs.hold_id;

  l_cnt NUMBER;
  l_return NUMBER;
BEGIN
   OPEN OM_LINE_STD_HOLDS;
   FETCH OM_LINE_STD_HOLDS INTO l_cnt;
   CLOSE OM_LINE_STD_HOLDS;
   if( l_cnt > 0) then
      l_return := 1;
    else
      l_return := 0;
    end if;

    return l_return;
EXCEPTION WHEN OTHERS THEN
  return 0;

END check_std_holds;

/*
 * Check holds on order header/line
 * if p_wf_item and p_wf_activity both are null
 * then only check generic holds. Otherwise
 * check for both generic and the specifid activity holds
 *
 */
FUNCTION Check_Holds(
        p_header_id     IN NUMBER,
        p_line_id       IN NUMBER ,
        p_wf_item       IN VARCHAR2,
        p_wf_activity   IN VARCHAR2)
return number
IS
  l_check_holds_result     VARCHAR2(30);
  l_return_status          VARCHAR2(30);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_return NUMBER;

BEGIN
     OE_HOLDS_PUB.Check_Holds
          (p_api_version      => 1.0
          ,p_header_id        => p_header_id
          ,p_line_id          => p_line_id
          ,p_wf_item          => p_wf_item
          ,p_wf_activity      => p_wf_activity
          ,x_result_out       => l_check_holds_result
          ,x_return_status    => l_return_status
          ,x_msg_count        => l_msg_count
          ,x_msg_data         => l_msg_data
     );

     l_return := 1;
     IF ( l_return_status = FND_API.G_RET_STS_SUCCESS AND
          l_check_holds_result = FND_API.G_FALSE ) THEN
             l_return := 0;
     END IF;

     return l_return;
EXCEPTION
 WHEN OTHERS THEN
  mrp_util.mrp_log('Excpetion during checking holds ' || sqlerrm );
  return 1;
END Check_Holds;

FUNCTION get_routing_designator(
        p_item_id IN NUMBER,
        p_organization_id IN NUMBER,
        p_line_id IN NUMBER)
RETURN VARCHAR2 IS

  CURSOR C_ALT IS
  SELECT alternate_routing_designator
  FROM bom_operational_routings
  WHERE line_id = p_line_id
  AND assembly_item_id = p_item_id
  AND organization_id = p_organization_id
  AND cfm_routing_flag = 1
  ORDER BY alternate_routing_designator desc;

  l_alt_rtg_desig VARCHAR2(10) := null;
BEGIN
   OPEN C_ALT;
   LOOP
     FETCH C_ALT into l_alt_rtg_desig;
     /* We just want one row so exit */
     EXIT;
   END LOOP;
   CLOSE C_ALT;

   RETURN l_alt_rtg_desig;

END get_routing_designator;


END MRP_Flow_Schedule_Util;

/
