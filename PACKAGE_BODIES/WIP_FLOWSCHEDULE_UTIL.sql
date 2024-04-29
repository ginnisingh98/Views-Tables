--------------------------------------------------------
--  DDL for Package Body WIP_FLOWSCHEDULE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_FLOWSCHEDULE_UTIL" AS
/* $Header: WIPUFLOB.pls 115.11 2002/12/03 11:50:55 simishra ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Flowschedule_Util';


--  Function Complete_Record

FUNCTION Complete_Record
(   p_FlowSchedule_rec              IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type
,   p_old_FlowSchedule_rec          IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type
,   p_ForceCopy                     IN  BOOLEAN := FALSE
) RETURN WIP_Work_Order_PUB.Flowschedule_Rec_Type
IS
l_FlowSchedule_rec            WIP_Work_Order_PUB.Flowschedule_Rec_Type := p_FlowSchedule_rec;
BEGIN

   IF p_ForceCopy = TRUE
     THEN

    IF p_old_FlowSchedule_rec.alternate_bom_designator <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.alternate_bom_designator := p_old_FlowSchedule_rec.alternate_bom_designator;
    END IF;

    IF p_old_FlowSchedule_rec.alternate_rout_designator <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.alternate_rout_designator := p_old_FlowSchedule_rec.alternate_rout_designator;
    END IF;

    IF p_old_FlowSchedule_rec.attribute1 <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute1 := p_old_FlowSchedule_rec.attribute1;
    END IF;

    IF p_old_FlowSchedule_rec.attribute10 <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute10 := p_old_FlowSchedule_rec.attribute10;
    END IF;

    IF p_old_FlowSchedule_rec.attribute11 <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute11 := p_old_FlowSchedule_rec.attribute11;
    END IF;

    IF p_old_FlowSchedule_rec.attribute12 <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute12 := p_old_FlowSchedule_rec.attribute12;
    END IF;

    IF p_old_FlowSchedule_rec.attribute13 <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute13 := p_old_FlowSchedule_rec.attribute13;
    END IF;

    IF p_old_FlowSchedule_rec.attribute14 <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute14 := p_old_FlowSchedule_rec.attribute14;
    END IF;

    IF p_old_FlowSchedule_rec.attribute15 <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute15 := p_old_FlowSchedule_rec.attribute15;
    END IF;

    IF p_old_FlowSchedule_rec.attribute2 <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute2 := p_old_FlowSchedule_rec.attribute2;
    END IF;

    IF p_old_FlowSchedule_rec.attribute3 <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute3 := p_old_FlowSchedule_rec.attribute3;
    END IF;

    IF p_old_FlowSchedule_rec.attribute4 <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute4 := p_old_FlowSchedule_rec.attribute4;
    END IF;

    IF p_old_FlowSchedule_rec.attribute5 <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute5 := p_old_FlowSchedule_rec.attribute5;
    END IF;

    IF p_old_FlowSchedule_rec.attribute6 <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute6 := p_old_FlowSchedule_rec.attribute6;
    END IF;

    IF p_old_FlowSchedule_rec.attribute7 <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute7 := p_old_FlowSchedule_rec.attribute7;
    END IF;

    IF p_old_FlowSchedule_rec.attribute8 <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute8 := p_old_FlowSchedule_rec.attribute8;
    END IF;

    IF p_old_FlowSchedule_rec.attribute9 <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute9 := p_old_FlowSchedule_rec.attribute9;
    END IF;

    IF p_old_FlowSchedule_rec.attribute_category <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute_category := p_old_FlowSchedule_rec.attribute_category;
    END IF;

    IF p_old_FlowSchedule_rec.bom_revision <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.bom_revision := p_old_FlowSchedule_rec.bom_revision;
    END IF;

    IF p_old_FlowSchedule_rec.bom_revision_date <> FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.bom_revision_date := p_old_FlowSchedule_rec.bom_revision_date;
    END IF;

    IF p_old_FlowSchedule_rec.build_sequence <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.build_sequence := p_old_FlowSchedule_rec.build_sequence;
    END IF;

    IF p_old_FlowSchedule_rec.class_code <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.class_code := p_old_FlowSchedule_rec.class_code;
    END IF;

    IF p_old_FlowSchedule_rec.completion_locator_id <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.completion_locator_id := p_old_FlowSchedule_rec.completion_locator_id;
    END IF;

    IF p_old_FlowSchedule_rec.completion_subinventory <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.completion_subinventory := p_old_FlowSchedule_rec.completion_subinventory;
    END IF;

    IF p_old_FlowSchedule_rec.created_by <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.created_by := p_old_FlowSchedule_rec.created_by;
    END IF;

    IF p_old_FlowSchedule_rec.creation_date <> FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.creation_date := p_old_FlowSchedule_rec.creation_date;
    END IF;

    IF p_old_FlowSchedule_rec.date_closed <> FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.date_closed := p_old_FlowSchedule_rec.date_closed;
    END IF;

    IF p_old_FlowSchedule_rec.demand_class <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.demand_class := p_old_FlowSchedule_rec.demand_class;
    END IF;

    IF p_old_FlowSchedule_rec.demand_source_delivery <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.demand_source_delivery := p_old_FlowSchedule_rec.demand_source_delivery;
    END IF;

    IF p_old_FlowSchedule_rec.demand_source_header_id <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.demand_source_header_id := p_old_FlowSchedule_rec.demand_source_header_id;
    END IF;

    IF p_old_FlowSchedule_rec.demand_source_line <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.demand_source_line := p_old_FlowSchedule_rec.demand_source_line;
    END IF;

    IF p_old_FlowSchedule_rec.demand_source_type <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.demand_source_type := p_old_FlowSchedule_rec.demand_source_type;
    END IF;

    IF p_old_FlowSchedule_rec.kanban_card_id <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.kanban_card_id := p_old_FlowSchedule_rec.kanban_card_id;
    END IF;

    IF p_old_FlowSchedule_rec.last_updated_by <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.last_updated_by := p_old_FlowSchedule_rec.last_updated_by;
    END IF;

    IF p_old_FlowSchedule_rec.last_update_date <> FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.last_update_date := p_old_FlowSchedule_rec.last_update_date;
    END IF;

    IF p_old_FlowSchedule_rec.last_update_login <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.last_update_login := p_old_FlowSchedule_rec.last_update_login;
    END IF;

    IF p_old_FlowSchedule_rec.line_id <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.line_id := p_old_FlowSchedule_rec.line_id;
    END IF;

    IF p_old_FlowSchedule_rec.material_account <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.material_account := p_old_FlowSchedule_rec.material_account;
    END IF;

    IF p_old_FlowSchedule_rec.material_overhead_account <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.material_overhead_account := p_old_FlowSchedule_rec.material_overhead_account;
    END IF;

    IF p_old_FlowSchedule_rec.material_variance_account <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.material_variance_account := p_old_FlowSchedule_rec.material_variance_account;
    END IF;

    IF p_old_FlowSchedule_rec.mps_net_quantity <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.mps_net_quantity := p_old_FlowSchedule_rec.mps_net_quantity;
    END IF;

    IF p_old_FlowSchedule_rec.mps_scheduled_cpl_date <> FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.mps_scheduled_cpl_date := p_old_FlowSchedule_rec.mps_scheduled_cpl_date;
    END IF;

    IF p_old_FlowSchedule_rec.organization_id <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.organization_id := p_old_FlowSchedule_rec.organization_id;
    END IF;

    IF p_old_FlowSchedule_rec.osp_account <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.osp_account := p_old_FlowSchedule_rec.osp_account;
    END IF;

    IF p_old_FlowSchedule_rec.osp_variance_account <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.osp_variance_account := p_old_FlowSchedule_rec.osp_variance_account;
    END IF;

    IF p_old_FlowSchedule_rec.overhead_account <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.overhead_account := p_old_FlowSchedule_rec.overhead_account;
    END IF;

    IF p_old_FlowSchedule_rec.overhead_variance_account <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.overhead_variance_account := p_old_FlowSchedule_rec.overhead_variance_account;
    END IF;

    IF p_old_FlowSchedule_rec.planned_quantity <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.planned_quantity := p_old_FlowSchedule_rec.planned_quantity;
    END IF;

    IF p_old_FlowSchedule_rec.primary_item_id <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.primary_item_id := p_old_FlowSchedule_rec.primary_item_id;
    END IF;

    IF p_old_FlowSchedule_rec.program_application_id <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.program_application_id := p_old_FlowSchedule_rec.program_application_id;
    END IF;

    IF p_old_FlowSchedule_rec.program_id <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.program_id := p_old_FlowSchedule_rec.program_id;
    END IF;

    IF p_old_FlowSchedule_rec.program_update_date <> FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.program_update_date := p_old_FlowSchedule_rec.program_update_date;
    END IF;

    IF p_old_FlowSchedule_rec.project_id <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.project_id := p_old_FlowSchedule_rec.project_id;
    END IF;

    IF p_old_FlowSchedule_rec.quantity_completed <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.quantity_completed := p_old_FlowSchedule_rec.quantity_completed;
    END IF;

    IF p_old_FlowSchedule_rec.request_id <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.request_id := p_old_FlowSchedule_rec.request_id;
    END IF;

    IF p_old_FlowSchedule_rec.resource_account <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.resource_account := p_old_FlowSchedule_rec.resource_account;
    END IF;

    IF p_old_FlowSchedule_rec.resource_variance_account <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.resource_variance_account := p_old_FlowSchedule_rec.resource_variance_account;
    END IF;

    IF p_old_FlowSchedule_rec.routing_revision <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.routing_revision := p_old_FlowSchedule_rec.routing_revision;
    END IF;

    IF p_old_FlowSchedule_rec.routing_revision_date <> FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.routing_revision_date := p_old_FlowSchedule_rec.routing_revision_date;
    END IF;

    IF p_old_FlowSchedule_rec.scheduled_completion_date <> FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.scheduled_completion_date := p_old_FlowSchedule_rec.scheduled_completion_date;
    END IF;

    IF p_old_FlowSchedule_rec.scheduled_flag <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.scheduled_flag := p_old_FlowSchedule_rec.scheduled_flag;
    END IF;

    IF p_old_FlowSchedule_rec.scheduled_start_date <> FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.scheduled_start_date := p_old_FlowSchedule_rec.scheduled_start_date;
    END IF;

    IF p_old_FlowSchedule_rec.schedule_group_id <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.schedule_group_id := p_old_FlowSchedule_rec.schedule_group_id;
    END IF;

    IF p_old_FlowSchedule_rec.schedule_number <> FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.schedule_number := p_old_FlowSchedule_rec.schedule_number;
    END IF;

    IF p_old_FlowSchedule_rec.status <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.status := p_old_FlowSchedule_rec.status;
    END IF;

    IF p_old_FlowSchedule_rec.std_cost_adj_account <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.std_cost_adj_account := p_old_FlowSchedule_rec.std_cost_adj_account;
    END IF;

    IF p_old_FlowSchedule_rec.task_id <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.task_id := p_old_FlowSchedule_rec.task_id;
    END IF;

    IF p_old_FlowSchedule_rec.wip_entity_id <> FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.wip_entity_id := p_old_FlowSchedule_rec.wip_entity_id;
    END IF;

    ELSE

    IF l_FlowSchedule_rec.alternate_bom_designator = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.alternate_bom_designator := p_old_FlowSchedule_rec.alternate_bom_designator;
    END IF;

    IF l_FlowSchedule_rec.alternate_rout_designator = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.alternate_rout_designator := p_old_FlowSchedule_rec.alternate_rout_designator;
    END IF;

    IF l_FlowSchedule_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute1 := p_old_FlowSchedule_rec.attribute1;
    END IF;

    IF l_FlowSchedule_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute10 := p_old_FlowSchedule_rec.attribute10;
    END IF;

    IF l_FlowSchedule_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute11 := p_old_FlowSchedule_rec.attribute11;
    END IF;

    IF l_FlowSchedule_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute12 := p_old_FlowSchedule_rec.attribute12;
    END IF;

    IF l_FlowSchedule_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute13 := p_old_FlowSchedule_rec.attribute13;
    END IF;

    IF l_FlowSchedule_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute14 := p_old_FlowSchedule_rec.attribute14;
    END IF;

    IF l_FlowSchedule_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute15 := p_old_FlowSchedule_rec.attribute15;
    END IF;

    IF l_FlowSchedule_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute2 := p_old_FlowSchedule_rec.attribute2;
    END IF;

    IF l_FlowSchedule_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute3 := p_old_FlowSchedule_rec.attribute3;
    END IF;

    IF l_FlowSchedule_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute4 := p_old_FlowSchedule_rec.attribute4;
    END IF;

    IF l_FlowSchedule_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute5 := p_old_FlowSchedule_rec.attribute5;
    END IF;

    IF l_FlowSchedule_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute6 := p_old_FlowSchedule_rec.attribute6;
    END IF;

    IF l_FlowSchedule_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute7 := p_old_FlowSchedule_rec.attribute7;
    END IF;

    IF l_FlowSchedule_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute8 := p_old_FlowSchedule_rec.attribute8;
    END IF;

    IF l_FlowSchedule_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute9 := p_old_FlowSchedule_rec.attribute9;
    END IF;

    IF l_FlowSchedule_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute_category := p_old_FlowSchedule_rec.attribute_category;
    END IF;

    IF l_FlowSchedule_rec.bom_revision = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.bom_revision := p_old_FlowSchedule_rec.bom_revision;
    END IF;

    IF l_FlowSchedule_rec.bom_revision_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.bom_revision_date := p_old_FlowSchedule_rec.bom_revision_date;
    END IF;

    IF l_FlowSchedule_rec.build_sequence = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.build_sequence := p_old_FlowSchedule_rec.build_sequence;
    END IF;

    IF l_FlowSchedule_rec.class_code = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.class_code := p_old_FlowSchedule_rec.class_code;
    END IF;

    IF l_FlowSchedule_rec.completion_locator_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.completion_locator_id := p_old_FlowSchedule_rec.completion_locator_id;
    END IF;

    IF l_FlowSchedule_rec.completion_subinventory = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.completion_subinventory := p_old_FlowSchedule_rec.completion_subinventory;
    END IF;

    IF l_FlowSchedule_rec.created_by = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.created_by := p_old_FlowSchedule_rec.created_by;
    END IF;

    IF l_FlowSchedule_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.creation_date := p_old_FlowSchedule_rec.creation_date;
    END IF;

    IF l_FlowSchedule_rec.date_closed = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.date_closed := p_old_FlowSchedule_rec.date_closed;
    END IF;

    IF l_FlowSchedule_rec.demand_class = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.demand_class := p_old_FlowSchedule_rec.demand_class;
    END IF;

    IF l_FlowSchedule_rec.demand_source_delivery = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.demand_source_delivery := p_old_FlowSchedule_rec.demand_source_delivery;
    END IF;

    IF l_FlowSchedule_rec.demand_source_header_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.demand_source_header_id := p_old_FlowSchedule_rec.demand_source_header_id;
    END IF;

    IF l_FlowSchedule_rec.demand_source_line = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.demand_source_line := p_old_FlowSchedule_rec.demand_source_line;
    END IF;

    IF l_FlowSchedule_rec.demand_source_type = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.demand_source_type := p_old_FlowSchedule_rec.demand_source_type;
    END IF;

    IF l_FlowSchedule_rec.kanban_card_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.kanban_card_id := p_old_FlowSchedule_rec.kanban_card_id;
    END IF;

    IF l_FlowSchedule_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.last_updated_by := p_old_FlowSchedule_rec.last_updated_by;
    END IF;

    IF l_FlowSchedule_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.last_update_date := p_old_FlowSchedule_rec.last_update_date;
    END IF;

    IF l_FlowSchedule_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.last_update_login := p_old_FlowSchedule_rec.last_update_login;
    END IF;

    IF l_FlowSchedule_rec.line_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.line_id := p_old_FlowSchedule_rec.line_id;
    END IF;

    IF l_FlowSchedule_rec.material_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.material_account := p_old_FlowSchedule_rec.material_account;
    END IF;

    IF l_FlowSchedule_rec.material_overhead_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.material_overhead_account := p_old_FlowSchedule_rec.material_overhead_account;
    END IF;

    IF l_FlowSchedule_rec.material_variance_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.material_variance_account := p_old_FlowSchedule_rec.material_variance_account;
    END IF;

    IF l_FlowSchedule_rec.mps_net_quantity = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.mps_net_quantity := p_old_FlowSchedule_rec.mps_net_quantity;
    END IF;

    IF l_FlowSchedule_rec.mps_scheduled_cpl_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.mps_scheduled_cpl_date := p_old_FlowSchedule_rec.mps_scheduled_cpl_date;
    END IF;

    IF l_FlowSchedule_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.organization_id := p_old_FlowSchedule_rec.organization_id;
    END IF;

    IF l_FlowSchedule_rec.osp_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.osp_account := p_old_FlowSchedule_rec.osp_account;
    END IF;

    IF l_FlowSchedule_rec.osp_variance_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.osp_variance_account := p_old_FlowSchedule_rec.osp_variance_account;
    END IF;

    IF l_FlowSchedule_rec.overhead_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.overhead_account := p_old_FlowSchedule_rec.overhead_account;
    END IF;

    IF l_FlowSchedule_rec.overhead_variance_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.overhead_variance_account := p_old_FlowSchedule_rec.overhead_variance_account;
    END IF;

    IF l_FlowSchedule_rec.planned_quantity = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.planned_quantity := p_old_FlowSchedule_rec.planned_quantity;
    END IF;

    IF l_FlowSchedule_rec.primary_item_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.primary_item_id := p_old_FlowSchedule_rec.primary_item_id;
    END IF;

    IF l_FlowSchedule_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.program_application_id := p_old_FlowSchedule_rec.program_application_id;
    END IF;

    IF l_FlowSchedule_rec.program_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.program_id := p_old_FlowSchedule_rec.program_id;
    END IF;

    IF l_FlowSchedule_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.program_update_date := p_old_FlowSchedule_rec.program_update_date;
    END IF;

    IF l_FlowSchedule_rec.project_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.project_id := p_old_FlowSchedule_rec.project_id;
    END IF;

    IF l_FlowSchedule_rec.quantity_completed = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.quantity_completed := p_old_FlowSchedule_rec.quantity_completed;
    END IF;

    IF l_FlowSchedule_rec.request_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.request_id := p_old_FlowSchedule_rec.request_id;
    END IF;

    IF l_FlowSchedule_rec.resource_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.resource_account := p_old_FlowSchedule_rec.resource_account;
    END IF;

    IF l_FlowSchedule_rec.resource_variance_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.resource_variance_account := p_old_FlowSchedule_rec.resource_variance_account;
    END IF;

    IF l_FlowSchedule_rec.routing_revision = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.routing_revision := p_old_FlowSchedule_rec.routing_revision;
    END IF;

    IF l_FlowSchedule_rec.routing_revision_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.routing_revision_date := p_old_FlowSchedule_rec.routing_revision_date;
    END IF;

    IF l_FlowSchedule_rec.scheduled_completion_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.scheduled_completion_date := p_old_FlowSchedule_rec.scheduled_completion_date;
    END IF;

    IF l_FlowSchedule_rec.scheduled_flag = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.scheduled_flag := p_old_FlowSchedule_rec.scheduled_flag;
    END IF;

    IF l_FlowSchedule_rec.scheduled_start_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.scheduled_start_date := p_old_FlowSchedule_rec.scheduled_start_date;
    END IF;

    IF l_FlowSchedule_rec.schedule_group_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.schedule_group_id := p_old_FlowSchedule_rec.schedule_group_id;
    END IF;

    IF l_FlowSchedule_rec.schedule_number = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.schedule_number := p_old_FlowSchedule_rec.schedule_number;
    END IF;

    IF l_FlowSchedule_rec.status = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.status := p_old_FlowSchedule_rec.status;
    END IF;

    IF l_FlowSchedule_rec.std_cost_adj_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.std_cost_adj_account := p_old_FlowSchedule_rec.std_cost_adj_account;
    END IF;

    IF l_FlowSchedule_rec.task_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.task_id := p_old_FlowSchedule_rec.task_id;
    END IF;

    IF l_FlowSchedule_rec.wip_entity_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.wip_entity_id := p_old_FlowSchedule_rec.wip_entity_id;
    END IF;
   END IF;

    RETURN l_FlowSchedule_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_FlowSchedule_rec              IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type
) RETURN WIP_Work_Order_PUB.Flowschedule_Rec_Type
IS
l_FlowSchedule_rec            WIP_Work_Order_PUB.Flowschedule_Rec_Type := p_FlowSchedule_rec;
BEGIN

    IF l_FlowSchedule_rec.alternate_bom_designator = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.alternate_bom_designator := NULL;
    END IF;

    IF l_FlowSchedule_rec.alternate_rout_designator = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.alternate_rout_designator := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute1 := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute10 := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute11 := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute12 := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute13 := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute14 := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute15 := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute2 := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute3 := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute4 := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute5 := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute6 := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute7 := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute8 := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute9 := NULL;
    END IF;

    IF l_FlowSchedule_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.attribute_category := NULL;
    END IF;

    IF l_FlowSchedule_rec.bom_revision = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.bom_revision := NULL;
    END IF;

    IF l_FlowSchedule_rec.bom_revision_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.bom_revision_date := NULL;
    END IF;

    IF l_FlowSchedule_rec.build_sequence = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.build_sequence := NULL;
    END IF;

    IF l_FlowSchedule_rec.class_code = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.class_code := NULL;
    END IF;

    IF l_FlowSchedule_rec.completion_locator_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.completion_locator_id := NULL;
    END IF;

    IF l_FlowSchedule_rec.completion_subinventory = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.completion_subinventory := NULL;
    END IF;

    IF l_FlowSchedule_rec.created_by = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.created_by := NULL;
    END IF;

    IF l_FlowSchedule_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.creation_date := NULL;
    END IF;

    IF l_FlowSchedule_rec.date_closed = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.date_closed := NULL;
    END IF;

    IF l_FlowSchedule_rec.demand_class = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.demand_class := NULL;
    END IF;

    IF l_FlowSchedule_rec.demand_source_delivery = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.demand_source_delivery := NULL;
    END IF;

    IF l_FlowSchedule_rec.demand_source_header_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.demand_source_header_id := NULL;
    END IF;

    IF l_FlowSchedule_rec.demand_source_line = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.demand_source_line := NULL;
    END IF;

    IF l_FlowSchedule_rec.demand_source_type = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.demand_source_type := NULL;
    END IF;

    IF l_FlowSchedule_rec.kanban_card_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.kanban_card_id := NULL;
    END IF;

    IF l_FlowSchedule_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.last_updated_by := NULL;
    END IF;

    IF l_FlowSchedule_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.last_update_date := NULL;
    END IF;

    IF l_FlowSchedule_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.last_update_login := NULL;
    END IF;

    IF l_FlowSchedule_rec.line_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.line_id := NULL;
    END IF;

    IF l_FlowSchedule_rec.material_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.material_account := NULL;
    END IF;

    IF l_FlowSchedule_rec.material_overhead_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.material_overhead_account := NULL;
    END IF;

    IF l_FlowSchedule_rec.material_variance_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.material_variance_account := NULL;
    END IF;

    IF l_FlowSchedule_rec.mps_net_quantity = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.mps_net_quantity := NULL;
    END IF;

    IF l_FlowSchedule_rec.mps_scheduled_cpl_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.mps_scheduled_cpl_date := NULL;
    END IF;

    IF l_FlowSchedule_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.organization_id := NULL;
    END IF;

    IF l_FlowSchedule_rec.osp_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.osp_account := NULL;
    END IF;

    IF l_FlowSchedule_rec.osp_variance_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.osp_variance_account := NULL;
    END IF;

    IF l_FlowSchedule_rec.overhead_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.overhead_account := NULL;
    END IF;

    IF l_FlowSchedule_rec.overhead_variance_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.overhead_variance_account := NULL;
    END IF;

    IF l_FlowSchedule_rec.planned_quantity = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.planned_quantity := NULL;
    END IF;

    IF l_FlowSchedule_rec.primary_item_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.primary_item_id := NULL;
    END IF;

    IF l_FlowSchedule_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.program_application_id := NULL;
    END IF;

    IF l_FlowSchedule_rec.program_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.program_id := NULL;
    END IF;

    IF l_FlowSchedule_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.program_update_date := NULL;
    END IF;

    IF l_FlowSchedule_rec.project_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.project_id := NULL;
    END IF;

    IF l_FlowSchedule_rec.quantity_completed = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.quantity_completed := NULL;
    END IF;

    IF l_FlowSchedule_rec.request_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.request_id := NULL;
    END IF;

    IF l_FlowSchedule_rec.resource_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.resource_account := NULL;
    END IF;

    IF l_FlowSchedule_rec.resource_variance_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.resource_variance_account := NULL;
    END IF;

    IF l_FlowSchedule_rec.routing_revision = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.routing_revision := NULL;
    END IF;

    IF l_FlowSchedule_rec.routing_revision_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.routing_revision_date := NULL;
    END IF;

    IF l_FlowSchedule_rec.scheduled_completion_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.scheduled_completion_date := NULL;
    END IF;

    IF l_FlowSchedule_rec.scheduled_flag = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.scheduled_flag := NULL;
    END IF;

    IF l_FlowSchedule_rec.scheduled_start_date = FND_API.G_MISS_DATE THEN
        l_FlowSchedule_rec.scheduled_start_date := NULL;
    END IF;

    IF l_FlowSchedule_rec.schedule_group_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.schedule_group_id := NULL;
    END IF;

    IF l_FlowSchedule_rec.schedule_number = FND_API.G_MISS_CHAR THEN
        l_FlowSchedule_rec.schedule_number := NULL;
    END IF;

    IF l_FlowSchedule_rec.status = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.status := NULL;
    END IF;

    IF l_FlowSchedule_rec.std_cost_adj_account = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.std_cost_adj_account := NULL;
    END IF;

    IF l_FlowSchedule_rec.task_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.task_id := NULL;
    END IF;

    IF l_FlowSchedule_rec.wip_entity_id = FND_API.G_MISS_NUM THEN
        l_FlowSchedule_rec.wip_entity_id := NULL;
    END IF;

    RETURN l_FlowSchedule_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_FlowSchedule_rec              IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type
)
IS
BEGIN

    UPDATE  WIP_FLOW_SCHEDULES
    SET     ALTERNATE_BOM_DESIGNATOR       = p_FlowSchedule_rec.alternate_bom_designator
    ,       ALTERNATE_ROUTING_DESIGNATOR   = p_FlowSchedule_rec.alternate_rout_designator
    ,       ATTRIBUTE1                     = p_FlowSchedule_rec.attribute1
    ,       ATTRIBUTE10                    = p_FlowSchedule_rec.attribute10
    ,       ATTRIBUTE11                    = p_FlowSchedule_rec.attribute11
    ,       ATTRIBUTE12                    = p_FlowSchedule_rec.attribute12
    ,       ATTRIBUTE13                    = p_FlowSchedule_rec.attribute13
    ,       ATTRIBUTE14                    = p_FlowSchedule_rec.attribute14
    ,       ATTRIBUTE15                    = p_FlowSchedule_rec.attribute15
    ,       ATTRIBUTE2                     = p_FlowSchedule_rec.attribute2
    ,       ATTRIBUTE3                     = p_FlowSchedule_rec.attribute3
    ,       ATTRIBUTE4                     = p_FlowSchedule_rec.attribute4
    ,       ATTRIBUTE5                     = p_FlowSchedule_rec.attribute5
    ,       ATTRIBUTE6                     = p_FlowSchedule_rec.attribute6
    ,       ATTRIBUTE7                     = p_FlowSchedule_rec.attribute7
    ,       ATTRIBUTE8                     = p_FlowSchedule_rec.attribute8
    ,       ATTRIBUTE9                     = p_FlowSchedule_rec.attribute9
    ,       ATTRIBUTE_CATEGORY             = p_FlowSchedule_rec.attribute_category
    ,       BOM_REVISION                   = p_FlowSchedule_rec.bom_revision
    ,       BOM_REVISION_DATE              = p_FlowSchedule_rec.bom_revision_date
    ,       BUILD_SEQUENCE                 = p_FlowSchedule_rec.build_sequence
    ,       CLASS_CODE                     = p_FlowSchedule_rec.class_code
    ,       COMPLETION_LOCATOR_ID          = p_FlowSchedule_rec.completion_locator_id
    ,       COMPLETION_SUBINVENTORY        = p_FlowSchedule_rec.completion_subinventory
    ,       CREATED_BY                     = p_FlowSchedule_rec.created_by
    ,       CREATION_DATE                  = p_FlowSchedule_rec.creation_date
    ,       DATE_CLOSED                    = p_FlowSchedule_rec.date_closed
    ,       DEMAND_CLASS                   = p_FlowSchedule_rec.demand_class
    ,       DEMAND_SOURCE_DELIVERY         = p_FlowSchedule_rec.demand_source_delivery
    ,       DEMAND_SOURCE_HEADER_ID        = p_FlowSchedule_rec.demand_source_header_id
    ,       DEMAND_SOURCE_LINE             = p_FlowSchedule_rec.demand_source_line
    ,       DEMAND_SOURCE_TYPE             = p_FlowSchedule_rec.demand_source_type
    ,       KANBAN_CARD_ID                 = p_FlowSchedule_rec.kanban_card_id
    ,       LAST_UPDATED_BY                = p_FlowSchedule_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_FlowSchedule_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_FlowSchedule_rec.last_update_login
    ,       LINE_ID                        = p_FlowSchedule_rec.line_id
    ,       MATERIAL_ACCOUNT               = p_FlowSchedule_rec.material_account
    ,       MATERIAL_OVERHEAD_ACCOUNT      = p_FlowSchedule_rec.material_overhead_account
    ,       MATERIAL_VARIANCE_ACCOUNT      = p_FlowSchedule_rec.material_variance_account
    ,       MPS_NET_QUANTITY               = p_FlowSchedule_rec.mps_net_quantity
    ,       MPS_SCHEDULED_COMPLETION_DATE  = p_FlowSchedule_rec.mps_scheduled_cpl_date
    ,       ORGANIZATION_ID                = p_FlowSchedule_rec.organization_id
    ,       OUTSIDE_PROCESSING_ACCOUNT     = p_FlowSchedule_rec.osp_account
    ,       OUTSIDE_PROC_VARIANCE_ACCOUNT  = p_FlowSchedule_rec.osp_variance_account
    ,       OVERHEAD_ACCOUNT               = p_FlowSchedule_rec.overhead_account
    ,       OVERHEAD_VARIANCE_ACCOUNT      = p_FlowSchedule_rec.overhead_variance_account
    ,       PLANNED_QUANTITY               = p_FlowSchedule_rec.planned_quantity
    ,       PRIMARY_ITEM_ID                = p_FlowSchedule_rec.primary_item_id
    ,       PROGRAM_APPLICATION_ID         = p_FlowSchedule_rec.program_application_id
    ,       PROGRAM_ID                     = p_FlowSchedule_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_FlowSchedule_rec.program_update_date
    ,       PROJECT_ID                     = p_FlowSchedule_rec.project_id
    ,       QUANTITY_COMPLETED             = p_FlowSchedule_rec.quantity_completed
    ,       REQUEST_ID                     = p_FlowSchedule_rec.request_id
    ,       RESOURCE_ACCOUNT               = p_FlowSchedule_rec.resource_account
    ,       RESOURCE_VARIANCE_ACCOUNT      = p_FlowSchedule_rec.resource_variance_account
    ,       ROUTING_REVISION               = p_FlowSchedule_rec.routing_revision
    ,       ROUTING_REVISION_DATE          = p_FlowSchedule_rec.routing_revision_date
    ,       SCHEDULED_COMPLETION_DATE      = p_FlowSchedule_rec.scheduled_completion_date
    ,       SCHEDULED_FLAG                 = p_FlowSchedule_rec.scheduled_flag
    ,       SCHEDULED_START_DATE           = p_FlowSchedule_rec.scheduled_start_date
    ,       SCHEDULE_GROUP_ID              = p_FlowSchedule_rec.schedule_group_id
    ,       SCHEDULE_NUMBER                = p_FlowSchedule_rec.schedule_number
    ,       STATUS                         = p_FlowSchedule_rec.status
    ,       STD_COST_ADJUSTMENT_ACCOUNT    = p_FlowSchedule_rec.std_cost_adj_account
    ,       TASK_ID                        = p_FlowSchedule_rec.task_id
    ,       WIP_ENTITY_ID                  = p_FlowSchedule_rec.wip_entity_id
    WHERE   SCHEDULE_NUMBER = p_FlowSchedule_rec.schedule_number
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
(   p_FlowSchedule_rec              IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type
)
IS
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
    ,       KANBAN_CARD_ID
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
    )
    VALUES
    (       p_FlowSchedule_rec.alternate_bom_designator
    ,       p_FlowSchedule_rec.alternate_rout_designator
    ,       p_FlowSchedule_rec.attribute1
    ,       p_FlowSchedule_rec.attribute10
    ,       p_FlowSchedule_rec.attribute11
    ,       p_FlowSchedule_rec.attribute12
    ,       p_FlowSchedule_rec.attribute13
    ,       p_FlowSchedule_rec.attribute14
    ,       p_FlowSchedule_rec.attribute15
    ,       p_FlowSchedule_rec.attribute2
    ,       p_FlowSchedule_rec.attribute3
    ,       p_FlowSchedule_rec.attribute4
    ,       p_FlowSchedule_rec.attribute5
    ,       p_FlowSchedule_rec.attribute6
    ,       p_FlowSchedule_rec.attribute7
    ,       p_FlowSchedule_rec.attribute8
    ,       p_FlowSchedule_rec.attribute9
    ,       p_FlowSchedule_rec.attribute_category
    ,       p_FlowSchedule_rec.bom_revision
    ,       p_FlowSchedule_rec.bom_revision_date
    ,       p_FlowSchedule_rec.build_sequence
    ,       p_FlowSchedule_rec.class_code
    ,       p_FlowSchedule_rec.completion_locator_id
    ,       p_FlowSchedule_rec.completion_subinventory
    ,       p_FlowSchedule_rec.created_by
    ,       p_FlowSchedule_rec.creation_date
    ,       p_FlowSchedule_rec.date_closed
    ,       p_FlowSchedule_rec.demand_class
    ,       p_FlowSchedule_rec.demand_source_delivery
    ,       p_FlowSchedule_rec.demand_source_header_id
    ,       p_FlowSchedule_rec.demand_source_line
    ,       p_FlowSchedule_rec.demand_source_type
    ,       p_FlowSchedule_rec.kanban_card_id
    ,       p_FlowSchedule_rec.last_updated_by
    ,       p_FlowSchedule_rec.last_update_date
    ,       p_FlowSchedule_rec.last_update_login
    ,       p_FlowSchedule_rec.line_id
    ,       p_FlowSchedule_rec.material_account
    ,       p_FlowSchedule_rec.material_overhead_account
    ,       p_FlowSchedule_rec.material_variance_account
    ,       p_FlowSchedule_rec.mps_net_quantity
    ,       p_FlowSchedule_rec.mps_scheduled_cpl_date
    ,       p_FlowSchedule_rec.organization_id
    ,       p_FlowSchedule_rec.osp_account
    ,       p_FlowSchedule_rec.osp_variance_account
    ,       p_FlowSchedule_rec.overhead_account
    ,       p_FlowSchedule_rec.overhead_variance_account
    ,       p_FlowSchedule_rec.planned_quantity
    ,       p_FlowSchedule_rec.primary_item_id
    ,       p_FlowSchedule_rec.program_application_id
    ,       p_FlowSchedule_rec.program_id
    ,       p_FlowSchedule_rec.program_update_date
    ,       p_FlowSchedule_rec.project_id
    ,       p_FlowSchedule_rec.quantity_completed
    ,       p_FlowSchedule_rec.request_id
    ,       p_FlowSchedule_rec.resource_account
    ,       p_FlowSchedule_rec.resource_variance_account
    ,       p_FlowSchedule_rec.routing_revision
    ,       p_FlowSchedule_rec.routing_revision_date
    ,       p_FlowSchedule_rec.scheduled_completion_date
    ,       p_FlowSchedule_rec.scheduled_flag
    ,       p_FlowSchedule_rec.scheduled_start_date
    ,       p_FlowSchedule_rec.schedule_group_id
    ,       p_FlowSchedule_rec.schedule_number
    ,       p_FlowSchedule_rec.status
    ,       p_FlowSchedule_rec.std_cost_adj_account
    ,       p_FlowSchedule_rec.task_id
    ,       p_FlowSchedule_rec.wip_entity_id
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
(   p_schedule_number               IN  VARCHAR2
)
IS
BEGIN

    DELETE  FROM WIP_FLOW_SCHEDULES
    WHERE   SCHEDULE_NUMBER = p_schedule_number
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
(   p_schedule_number               IN  VARCHAR2
) RETURN WIP_Work_Order_PUB.Flowschedule_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_schedule_number             => p_schedule_number
        )(1);

END Query_Row;


FUNCTION Query_Row
(   p_wip_entity_id               IN  NUMBER
) RETURN WIP_Work_Order_PUB.Flowschedule_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_wip_entity_id             => p_wip_entity_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_schedule_number               IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   p_wip_entity_id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN WIP_Work_Order_PUB.Flowschedule_Tbl_Type
IS
l_FlowSchedule_rec            WIP_Work_Order_PUB.Flowschedule_Rec_Type;
l_FlowSchedule_tbl            WIP_Work_Order_PUB.Flowschedule_Tbl_Type;

CURSOR l_FlowSchedule_csr IS
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
    ,       KANBAN_CARD_ID
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
    FROM    WIP_FLOW_SCHEDULES
    WHERE ( SCHEDULE_NUMBER = p_schedule_number
    )
    OR (    WIP_ENTITY_ID = p_wip_entity_id
    );

BEGIN

    IF
    (p_schedule_number IS NOT NULL
     AND
     p_schedule_number <> FND_API.G_MISS_CHAR)
    AND
    (p_wip_entity_id IS NOT NULL
     AND
     p_wip_entity_id <> FND_API.G_MISS_NUM)
    THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: schedule_number = '|| p_schedule_number || ', wip_entity_id = '|| p_wip_entity_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_FlowSchedule_csr LOOP

        l_FlowSchedule_rec.alternate_bom_designator := l_implicit_rec.ALTERNATE_BOM_DESIGNATOR;
        l_FlowSchedule_rec.alternate_rout_designator := l_implicit_rec.ALTERNATE_ROUTING_DESIGNATOR;
        l_FlowSchedule_rec.attribute1  := l_implicit_rec.ATTRIBUTE1;
        l_FlowSchedule_rec.attribute10 := l_implicit_rec.ATTRIBUTE10;
        l_FlowSchedule_rec.attribute11 := l_implicit_rec.ATTRIBUTE11;
        l_FlowSchedule_rec.attribute12 := l_implicit_rec.ATTRIBUTE12;
        l_FlowSchedule_rec.attribute13 := l_implicit_rec.ATTRIBUTE13;
        l_FlowSchedule_rec.attribute14 := l_implicit_rec.ATTRIBUTE14;
        l_FlowSchedule_rec.attribute15 := l_implicit_rec.ATTRIBUTE15;
        l_FlowSchedule_rec.attribute2  := l_implicit_rec.ATTRIBUTE2;
        l_FlowSchedule_rec.attribute3  := l_implicit_rec.ATTRIBUTE3;
        l_FlowSchedule_rec.attribute4  := l_implicit_rec.ATTRIBUTE4;
        l_FlowSchedule_rec.attribute5  := l_implicit_rec.ATTRIBUTE5;
        l_FlowSchedule_rec.attribute6  := l_implicit_rec.ATTRIBUTE6;
        l_FlowSchedule_rec.attribute7  := l_implicit_rec.ATTRIBUTE7;
        l_FlowSchedule_rec.attribute8  := l_implicit_rec.ATTRIBUTE8;
        l_FlowSchedule_rec.attribute9  := l_implicit_rec.ATTRIBUTE9;
        l_FlowSchedule_rec.attribute_category := l_implicit_rec.ATTRIBUTE_CATEGORY;
        l_FlowSchedule_rec.bom_revision := l_implicit_rec.BOM_REVISION;
        l_FlowSchedule_rec.bom_revision_date := l_implicit_rec.BOM_REVISION_DATE;
        l_FlowSchedule_rec.build_sequence := l_implicit_rec.BUILD_SEQUENCE;
        l_FlowSchedule_rec.class_code  := l_implicit_rec.CLASS_CODE;
        l_FlowSchedule_rec.completion_locator_id := l_implicit_rec.COMPLETION_LOCATOR_ID;
        l_FlowSchedule_rec.completion_subinventory := l_implicit_rec.COMPLETION_SUBINVENTORY;
        l_FlowSchedule_rec.created_by  := l_implicit_rec.CREATED_BY;
        l_FlowSchedule_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_FlowSchedule_rec.date_closed := l_implicit_rec.DATE_CLOSED;
        l_FlowSchedule_rec.demand_class := l_implicit_rec.DEMAND_CLASS;
        l_FlowSchedule_rec.demand_source_delivery := l_implicit_rec.DEMAND_SOURCE_DELIVERY;
        l_FlowSchedule_rec.demand_source_header_id := l_implicit_rec.DEMAND_SOURCE_HEADER_ID;
        l_FlowSchedule_rec.demand_source_line := l_implicit_rec.DEMAND_SOURCE_LINE;
        l_FlowSchedule_rec.demand_source_type := l_implicit_rec.DEMAND_SOURCE_TYPE;
        l_FlowSchedule_rec.kanban_card_id := l_implicit_rec.KANBAN_CARD_ID;
        l_FlowSchedule_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_FlowSchedule_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_FlowSchedule_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_FlowSchedule_rec.line_id     := l_implicit_rec.LINE_ID;
        l_FlowSchedule_rec.material_account := l_implicit_rec.MATERIAL_ACCOUNT;
        l_FlowSchedule_rec.material_overhead_account := l_implicit_rec.MATERIAL_OVERHEAD_ACCOUNT;
        l_FlowSchedule_rec.material_variance_account := l_implicit_rec.MATERIAL_VARIANCE_ACCOUNT;
        l_FlowSchedule_rec.mps_net_quantity := l_implicit_rec.MPS_NET_QUANTITY;
        l_FlowSchedule_rec.mps_scheduled_cpl_date := l_implicit_rec.MPS_SCHEDULED_COMPLETION_DATE;
        l_FlowSchedule_rec.organization_id := l_implicit_rec.ORGANIZATION_ID;
        l_FlowSchedule_rec.osp_account := l_implicit_rec.OUTSIDE_PROCESSING_ACCOUNT;
        l_FlowSchedule_rec.osp_variance_account := l_implicit_rec.OUTSIDE_PROC_VARIANCE_ACCOUNT;
        l_FlowSchedule_rec.overhead_account := l_implicit_rec.OVERHEAD_ACCOUNT;
        l_FlowSchedule_rec.overhead_variance_account := l_implicit_rec.OVERHEAD_VARIANCE_ACCOUNT;
        l_FlowSchedule_rec.planned_quantity := l_implicit_rec.PLANNED_QUANTITY;
        l_FlowSchedule_rec.primary_item_id := l_implicit_rec.PRIMARY_ITEM_ID;
        l_FlowSchedule_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_FlowSchedule_rec.program_id  := l_implicit_rec.PROGRAM_ID;
        l_FlowSchedule_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_FlowSchedule_rec.project_id  := l_implicit_rec.PROJECT_ID;
        l_FlowSchedule_rec.quantity_completed := l_implicit_rec.QUANTITY_COMPLETED;
        l_FlowSchedule_rec.request_id  := l_implicit_rec.REQUEST_ID;
        l_FlowSchedule_rec.resource_account := l_implicit_rec.RESOURCE_ACCOUNT;
        l_FlowSchedule_rec.resource_variance_account := l_implicit_rec.RESOURCE_VARIANCE_ACCOUNT;
        l_FlowSchedule_rec.routing_revision := l_implicit_rec.ROUTING_REVISION;
        l_FlowSchedule_rec.routing_revision_date := l_implicit_rec.ROUTING_REVISION_DATE;
        l_FlowSchedule_rec.scheduled_completion_date := l_implicit_rec.SCHEDULED_COMPLETION_DATE;
        l_FlowSchedule_rec.scheduled_flag := l_implicit_rec.SCHEDULED_FLAG;
        l_FlowSchedule_rec.scheduled_start_date := l_implicit_rec.SCHEDULED_START_DATE;
        l_FlowSchedule_rec.schedule_group_id := l_implicit_rec.SCHEDULE_GROUP_ID;
        l_FlowSchedule_rec.schedule_number := l_implicit_rec.SCHEDULE_NUMBER;
        l_FlowSchedule_rec.status      := l_implicit_rec.STATUS;
        l_FlowSchedule_rec.std_cost_adj_account := l_implicit_rec.STD_COST_ADJUSTMENT_ACCOUNT;
        l_FlowSchedule_rec.task_id     := l_implicit_rec.TASK_ID;
        l_FlowSchedule_rec.wip_entity_id := l_implicit_rec.WIP_ENTITY_ID;

        l_FlowSchedule_tbl(l_FlowSchedule_tbl.COUNT + 1) := l_FlowSchedule_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_schedule_number IS NOT NULL
     AND
     p_schedule_number <> FND_API.G_MISS_CHAR)
    AND
    (l_FlowSchedule_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_FlowSchedule_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_FlowSchedule_rec              IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type
,   x_FlowSchedule_rec              OUT NOCOPY WIP_Work_Order_PUB.Flowschedule_Rec_Type
)
IS
l_FlowSchedule_rec            WIP_Work_Order_PUB.Flowschedule_Rec_Type;
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
    ,       KANBAN_CARD_ID
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
    INTO    l_FlowSchedule_rec.alternate_bom_designator
    ,       l_FlowSchedule_rec.alternate_rout_designator
    ,       l_FlowSchedule_rec.attribute1
    ,       l_FlowSchedule_rec.attribute10
    ,       l_FlowSchedule_rec.attribute11
    ,       l_FlowSchedule_rec.attribute12
    ,       l_FlowSchedule_rec.attribute13
    ,       l_FlowSchedule_rec.attribute14
    ,       l_FlowSchedule_rec.attribute15
    ,       l_FlowSchedule_rec.attribute2
    ,       l_FlowSchedule_rec.attribute3
    ,       l_FlowSchedule_rec.attribute4
    ,       l_FlowSchedule_rec.attribute5
    ,       l_FlowSchedule_rec.attribute6
    ,       l_FlowSchedule_rec.attribute7
    ,       l_FlowSchedule_rec.attribute8
    ,       l_FlowSchedule_rec.attribute9
    ,       l_FlowSchedule_rec.attribute_category
    ,       l_FlowSchedule_rec.bom_revision
    ,       l_FlowSchedule_rec.bom_revision_date
    ,       l_FlowSchedule_rec.build_sequence
    ,       l_FlowSchedule_rec.class_code
    ,       l_FlowSchedule_rec.completion_locator_id
    ,       l_FlowSchedule_rec.completion_subinventory
    ,       l_FlowSchedule_rec.created_by
    ,       l_FlowSchedule_rec.creation_date
    ,       l_FlowSchedule_rec.date_closed
    ,       l_FlowSchedule_rec.demand_class
    ,       l_FlowSchedule_rec.demand_source_delivery
    ,       l_FlowSchedule_rec.demand_source_header_id
    ,       l_FlowSchedule_rec.demand_source_line
    ,       l_FlowSchedule_rec.demand_source_type
    ,       l_FlowSchedule_rec.kanban_card_id
    ,       l_FlowSchedule_rec.last_updated_by
    ,       l_FlowSchedule_rec.last_update_date
    ,       l_FlowSchedule_rec.last_update_login
    ,       l_FlowSchedule_rec.line_id
    ,       l_FlowSchedule_rec.material_account
    ,       l_FlowSchedule_rec.material_overhead_account
    ,       l_FlowSchedule_rec.material_variance_account
    ,       l_FlowSchedule_rec.mps_net_quantity
    ,       l_FlowSchedule_rec.mps_scheduled_cpl_date
    ,       l_FlowSchedule_rec.organization_id
    ,       l_FlowSchedule_rec.osp_account
    ,       l_FlowSchedule_rec.osp_variance_account
    ,       l_FlowSchedule_rec.overhead_account
    ,       l_FlowSchedule_rec.overhead_variance_account
    ,       l_FlowSchedule_rec.planned_quantity
    ,       l_FlowSchedule_rec.primary_item_id
    ,       l_FlowSchedule_rec.program_application_id
    ,       l_FlowSchedule_rec.program_id
    ,       l_FlowSchedule_rec.program_update_date
    ,       l_FlowSchedule_rec.project_id
    ,       l_FlowSchedule_rec.quantity_completed
    ,       l_FlowSchedule_rec.request_id
    ,       l_FlowSchedule_rec.resource_account
    ,       l_FlowSchedule_rec.resource_variance_account
    ,       l_FlowSchedule_rec.routing_revision
    ,       l_FlowSchedule_rec.routing_revision_date
    ,       l_FlowSchedule_rec.scheduled_completion_date
    ,       l_FlowSchedule_rec.scheduled_flag
    ,       l_FlowSchedule_rec.scheduled_start_date
    ,       l_FlowSchedule_rec.schedule_group_id
    ,       l_FlowSchedule_rec.schedule_number
    ,       l_FlowSchedule_rec.status
    ,       l_FlowSchedule_rec.std_cost_adj_account
    ,       l_FlowSchedule_rec.task_id
    ,       l_FlowSchedule_rec.wip_entity_id
    FROM    WIP_FLOW_SCHEDULES
    WHERE   SCHEDULE_NUMBER = p_FlowSchedule_rec.schedule_number
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  WIP_GLOBALS.Equal(p_FlowSchedule_rec.alternate_bom_designator,
                         l_FlowSchedule_rec.alternate_bom_designator)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.alternate_rout_designator,
                         l_FlowSchedule_rec.alternate_rout_designator)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute1,
                         l_FlowSchedule_rec.attribute1)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute10,
                         l_FlowSchedule_rec.attribute10)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute11,
                         l_FlowSchedule_rec.attribute11)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute12,
                         l_FlowSchedule_rec.attribute12)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute13,
                         l_FlowSchedule_rec.attribute13)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute14,
                         l_FlowSchedule_rec.attribute14)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute15,
                         l_FlowSchedule_rec.attribute15)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute2,
                         l_FlowSchedule_rec.attribute2)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute3,
                         l_FlowSchedule_rec.attribute3)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute4,
                         l_FlowSchedule_rec.attribute4)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute5,
                         l_FlowSchedule_rec.attribute5)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute6,
                         l_FlowSchedule_rec.attribute6)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute7,
                         l_FlowSchedule_rec.attribute7)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute8,
                         l_FlowSchedule_rec.attribute8)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute9,
                         l_FlowSchedule_rec.attribute9)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.attribute_category,
                         l_FlowSchedule_rec.attribute_category)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.bom_revision,
                         l_FlowSchedule_rec.bom_revision)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.bom_revision_date,
                         l_FlowSchedule_rec.bom_revision_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.build_sequence,
                         l_FlowSchedule_rec.build_sequence)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.class_code,
                         l_FlowSchedule_rec.class_code)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.completion_locator_id,
                         l_FlowSchedule_rec.completion_locator_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.completion_subinventory,
                         l_FlowSchedule_rec.completion_subinventory)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.created_by,
                         l_FlowSchedule_rec.created_by)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.creation_date,
                         l_FlowSchedule_rec.creation_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.date_closed,
                         l_FlowSchedule_rec.date_closed)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.demand_class,
                         l_FlowSchedule_rec.demand_class)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.demand_source_delivery,
                         l_FlowSchedule_rec.demand_source_delivery)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.demand_source_header_id,
                         l_FlowSchedule_rec.demand_source_header_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.demand_source_line,
                         l_FlowSchedule_rec.demand_source_line)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.demand_source_type,
                         l_FlowSchedule_rec.demand_source_type)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.kanban_card_id,
                         l_FlowSchedule_rec.kanban_card_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.last_updated_by,
                         l_FlowSchedule_rec.last_updated_by)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.last_update_date,
                         l_FlowSchedule_rec.last_update_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.last_update_login,
                         l_FlowSchedule_rec.last_update_login)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.line_id,
                         l_FlowSchedule_rec.line_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.material_account,
                         l_FlowSchedule_rec.material_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.material_overhead_account,
                         l_FlowSchedule_rec.material_overhead_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.material_variance_account,
                         l_FlowSchedule_rec.material_variance_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.mps_net_quantity,
                         l_FlowSchedule_rec.mps_net_quantity)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.mps_scheduled_cpl_date,
                         l_FlowSchedule_rec.mps_scheduled_cpl_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.organization_id,
                         l_FlowSchedule_rec.organization_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.osp_account,
                         l_FlowSchedule_rec.osp_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.osp_variance_account,
                         l_FlowSchedule_rec.osp_variance_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.overhead_account,
                         l_FlowSchedule_rec.overhead_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.overhead_variance_account,
                         l_FlowSchedule_rec.overhead_variance_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.planned_quantity,
                         l_FlowSchedule_rec.planned_quantity)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.primary_item_id,
                         l_FlowSchedule_rec.primary_item_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.program_application_id,
                         l_FlowSchedule_rec.program_application_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.program_id,
                         l_FlowSchedule_rec.program_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.program_update_date,
                         l_FlowSchedule_rec.program_update_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.project_id,
                         l_FlowSchedule_rec.project_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.quantity_completed,
                         l_FlowSchedule_rec.quantity_completed)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.request_id,
                         l_FlowSchedule_rec.request_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.resource_account,
                         l_FlowSchedule_rec.resource_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.resource_variance_account,
                         l_FlowSchedule_rec.resource_variance_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.routing_revision,
                         l_FlowSchedule_rec.routing_revision)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.routing_revision_date,
                         l_FlowSchedule_rec.routing_revision_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.scheduled_completion_date,
                         l_FlowSchedule_rec.scheduled_completion_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.scheduled_flag,
                         l_FlowSchedule_rec.scheduled_flag)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.scheduled_start_date,
                         l_FlowSchedule_rec.scheduled_start_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.schedule_group_id,
                         l_FlowSchedule_rec.schedule_group_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.schedule_number,
                         l_FlowSchedule_rec.schedule_number)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.status,
                         l_FlowSchedule_rec.status)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.std_cost_adj_account,
                         l_FlowSchedule_rec.std_cost_adj_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.task_id,
                         l_FlowSchedule_rec.task_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec.wip_entity_id,
                         l_FlowSchedule_rec.wip_entity_id)
    THEN

        --  Row has not changed. Set out parameter.

        x_FlowSchedule_rec             := l_FlowSchedule_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_FlowSchedule_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_FlowSchedule_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','OE_LOCK_ROW_CHANGED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_FlowSchedule_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','OE_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_FlowSchedule_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','OE_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_FlowSchedule_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;


FUNCTION Compare( p_FlowSchedule_rec1   IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type,
                  p_FlowSchedule_rec2   IN  WIP_Work_Order_PUB.Flowschedule_Rec_Type)
  RETURN BOOLEAN
  IS
BEGIN

    IF  WIP_GLOBALS.Equal(p_FlowSchedule_rec1.alternate_bom_designator,
                         p_FlowSchedule_rec2.alternate_bom_designator)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.alternate_rout_designator,
                         p_FlowSchedule_rec2.alternate_rout_designator)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute1,
                         p_FlowSchedule_rec2.attribute1)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute10,
                         p_FlowSchedule_rec2.attribute10)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute11,
                         p_FlowSchedule_rec2.attribute11)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute12,
                         p_FlowSchedule_rec2.attribute12)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute13,
                         p_FlowSchedule_rec2.attribute13)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute14,
                         p_FlowSchedule_rec2.attribute14)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute15,
                         p_FlowSchedule_rec2.attribute15)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute2,
                         p_FlowSchedule_rec2.attribute2)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute3,
                         p_FlowSchedule_rec2.attribute3)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute4,
                         p_FlowSchedule_rec2.attribute4)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute5,
                         p_FlowSchedule_rec2.attribute5)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute6,
                         p_FlowSchedule_rec2.attribute6)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute7,
                         p_FlowSchedule_rec2.attribute7)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute8,
                         p_FlowSchedule_rec2.attribute8)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute9,
                         p_FlowSchedule_rec2.attribute9)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.attribute_category,
                         p_FlowSchedule_rec2.attribute_category)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.bom_revision,
                         p_FlowSchedule_rec2.bom_revision)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.bom_revision_date,
                         p_FlowSchedule_rec2.bom_revision_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.build_sequence,
                         p_FlowSchedule_rec2.build_sequence)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.class_code,
                         p_FlowSchedule_rec2.class_code)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.completion_locator_id,
                         p_FlowSchedule_rec2.completion_locator_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.completion_subinventory,
                         p_FlowSchedule_rec2.completion_subinventory)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.created_by,
                         p_FlowSchedule_rec2.created_by)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.creation_date,
                         p_FlowSchedule_rec2.creation_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.date_closed,
                         p_FlowSchedule_rec2.date_closed)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.demand_class,
                         p_FlowSchedule_rec2.demand_class)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.demand_source_delivery,
                         p_FlowSchedule_rec2.demand_source_delivery)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.demand_source_header_id,
                         p_FlowSchedule_rec2.demand_source_header_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.demand_source_line,
                         p_FlowSchedule_rec2.demand_source_line)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.demand_source_type,
                         p_FlowSchedule_rec2.demand_source_type)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.kanban_card_id,
                         p_FlowSchedule_rec2.kanban_card_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.last_updated_by,
                         p_FlowSchedule_rec2.last_updated_by)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.last_update_date,
                         p_FlowSchedule_rec2.last_update_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.last_update_login,
                         p_FlowSchedule_rec2.last_update_login)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.line_id,
                         p_FlowSchedule_rec2.line_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.material_account,
                         p_FlowSchedule_rec2.material_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.material_overhead_account,
                         p_FlowSchedule_rec2.material_overhead_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.material_variance_account,
                         p_FlowSchedule_rec2.material_variance_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.mps_net_quantity,
                         p_FlowSchedule_rec2.mps_net_quantity)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.mps_scheduled_cpl_date,
                         p_FlowSchedule_rec2.mps_scheduled_cpl_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.organization_id,
                         p_FlowSchedule_rec2.organization_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.osp_account,
                         p_FlowSchedule_rec2.osp_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.osp_variance_account,
                         p_FlowSchedule_rec2.osp_variance_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.overhead_account,
                         p_FlowSchedule_rec2.overhead_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.overhead_variance_account,
                         p_FlowSchedule_rec2.overhead_variance_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.planned_quantity,
                         p_FlowSchedule_rec2.planned_quantity)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.primary_item_id,
                         p_FlowSchedule_rec2.primary_item_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.program_application_id,
                         p_FlowSchedule_rec2.program_application_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.program_id,
                         p_FlowSchedule_rec2.program_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.program_update_date,
                         p_FlowSchedule_rec2.program_update_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.project_id,
                         p_FlowSchedule_rec2.project_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.quantity_completed,
                         p_FlowSchedule_rec2.quantity_completed)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.request_id,
                         p_FlowSchedule_rec2.request_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.resource_account,
                         p_FlowSchedule_rec2.resource_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.resource_variance_account,
                         p_FlowSchedule_rec2.resource_variance_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.routing_revision,
                         p_FlowSchedule_rec2.routing_revision)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.routing_revision_date,
                         p_FlowSchedule_rec2.routing_revision_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.scheduled_completion_date,
                         p_FlowSchedule_rec2.scheduled_completion_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.scheduled_flag,
                         p_FlowSchedule_rec2.scheduled_flag)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.scheduled_start_date,
                         p_FlowSchedule_rec2.scheduled_start_date)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.schedule_group_id,
                         p_FlowSchedule_rec2.schedule_group_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.schedule_number,
                         p_FlowSchedule_rec2.schedule_number)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.status,
                         p_FlowSchedule_rec2.status)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.std_cost_adj_account,
                         p_FlowSchedule_rec2.std_cost_adj_account)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.task_id,
                         p_FlowSchedule_rec2.task_id)
    AND WIP_GLOBALS.Equal(p_FlowSchedule_rec1.wip_entity_id,
                         p_FlowSchedule_rec2.wip_entity_id)
    THEN
       RETURN TRUE;
     ELSE
       RETURN FALSE;
    END IF;

END Compare;

PROCEDURE dprintf(p_FlowSchedule_rec    IN WIP_Work_Order_PUB.FlowSchedule_Rec_Type)
  IS
BEGIN

   null;
-- dbms_output.new_line;
-- dbms_output.put_line('Flow Schedule Record:');
-- dbms_output.put_line('--------------------');
-- dbms_output.put_line('completion_locator_id    : ' || To_char(p_FlowSchedule_rec.completion_locator_id));
-- dbms_output.put_line('completion_subinventory  : ' || p_FlowSchedule_rec.completion_subinventory);
-- dbms_output.put_line('line_id                  : ' || To_char(p_FlowSchedule_rec.line_id));
-- dbms_output.put_line('organization_id          : ' || To_char(p_FlowSchedule_rec.organization_id));
-- dbms_output.put_line('planned_quantity         : ' || To_char(p_FlowSchedule_rec.planned_quantity));
-- dbms_output.put_line('primary_item_id          : ' || To_char(p_FlowSchedule_rec.primary_item_id));
-- dbms_output.put_line('quantity_completed       : ' || To_char(p_FlowSchedule_rec.quantity_completed));
-- dbms_output.put_line('scheduled_completion_date: ' || To_char(p_FlowSchedule_rec.scheduled_completion_date,'DD-MON-RR'));
-- dbms_output.put_line('scheduled_flag           : ' || To_char(p_FlowSchedule_rec.scheduled_flag));
-- dbms_output.put_line('scheduled_start_date     : ' || To_char(p_FlowSchedule_rec.scheduled_start_date,'DD-MON-RR'));
-- dbms_output.put_line('schedule_group_id        : ' || To_char(p_FlowSchedule_rec.schedule_group_id));
-- dbms_output.put_line('schedule_number          : ' || p_FlowSchedule_rec.schedule_number);
-- dbms_output.put_line('wip_entity_id            : ' || To_char(p_FlowSchedule_rec.wip_entity_id));
-- dbms_output.put_line('kanban_card_id           : ' || To_char(p_FlowSchedule_rec.kanban_card_id));
-- dbms_output.put_line('return_status            : ' || p_FlowSchedule_rec.return_status);
-- dbms_output.put_line('db_flag                  : ' || p_FlowSchedule_rec.db_flag);
-- dbms_output.put_line('action                   : ' || p_FlowSchedule_rec.action);
-- dbms_output.put_line('End Flow Schedule Record');
EXCEPTION
   WHEN OTHERS THEN
      NULL;

END dprintf;

END WIP_Flowschedule_Util;

/
