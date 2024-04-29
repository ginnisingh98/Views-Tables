--------------------------------------------------------
--  DDL for Package Body WIP_DISCRETEJOB_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DISCRETEJOB_UTIL" AS
/* $Header: WIPUWDJB.pls 120.3 2005/10/24 17:16:07 sjchen ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Discretejob_Util';


--  Function Complete_Record

FUNCTION Complete_Record
(   p_DiscreteJob_rec               IN  WIP_Work_Order_PUB.Discretejob_Rec_Type
,   p_old_DiscreteJob_rec           IN  WIP_Work_Order_PUB.Discretejob_Rec_Type
,   p_ForceCopy                     IN BOOLEAN := NULL
) RETURN WIP_Work_Order_PUB.Discretejob_Rec_Type
IS
l_DiscreteJob_rec             WIP_Work_Order_PUB.Discretejob_Rec_Type := p_DiscreteJob_rec;
BEGIN

 IF (p_ForceCopy is NOT NULL) THEN
   IF (p_ForceCopy = TRUE)
     THEN

      IF p_old_DiscreteJob_rec.alternate_bom_designator = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.alternate_bom_designator := p_old_DiscreteJob_rec.alternate_bom_designator;
      END IF;

      IF p_old_DiscreteJob_rec.alternate_rout_designator = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.alternate_rout_designator := p_old_DiscreteJob_rec.alternate_rout_designator;
      END IF;

      IF p_old_DiscreteJob_rec.attribute1 = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute1 := p_old_DiscreteJob_rec.attribute1;
      END IF;

      IF p_old_DiscreteJob_rec.attribute10 = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute10 := p_old_DiscreteJob_rec.attribute10;
      END IF;

      IF p_old_DiscreteJob_rec.attribute11 = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute11 := p_old_DiscreteJob_rec.attribute11;
      END IF;

      IF p_old_DiscreteJob_rec.attribute12 = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute12 := p_old_DiscreteJob_rec.attribute12;
      END IF;

      IF p_old_DiscreteJob_rec.attribute13 = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute13 := p_old_DiscreteJob_rec.attribute13;
      END IF;

      IF p_old_DiscreteJob_rec.attribute14 = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute14 := p_old_DiscreteJob_rec.attribute14;
      END IF;

      IF p_old_DiscreteJob_rec.attribute15 = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute15 := p_old_DiscreteJob_rec.attribute15;
      END IF;

      IF p_old_DiscreteJob_rec.attribute2 = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute2 := p_old_DiscreteJob_rec.attribute2;
      END IF;

      IF p_old_DiscreteJob_rec.attribute3 = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute3 := p_old_DiscreteJob_rec.attribute3;
      END IF;

      IF p_old_DiscreteJob_rec.attribute4 = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute4 := p_old_DiscreteJob_rec.attribute4;
      END IF;

      IF p_old_DiscreteJob_rec.attribute5 = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute5 := p_old_DiscreteJob_rec.attribute5;
      END IF;

      IF p_old_DiscreteJob_rec.attribute6 = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute6 := p_old_DiscreteJob_rec.attribute6;
      END IF;

      IF p_old_DiscreteJob_rec.attribute7 = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute7 := p_old_DiscreteJob_rec.attribute7;
      END IF;

      IF p_old_DiscreteJob_rec.attribute8 = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute8 := p_old_DiscreteJob_rec.attribute8;
      END IF;

      IF p_old_DiscreteJob_rec.attribute9 = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute9 := p_old_DiscreteJob_rec.attribute9;
      END IF;

      IF p_old_DiscreteJob_rec.attribute_category = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.attribute_category := p_old_DiscreteJob_rec.attribute_category;
      END IF;

      IF p_old_DiscreteJob_rec.bom_reference_id = FND_API.G_MISS_NUM THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.bom_reference_id := p_old_DiscreteJob_rec.bom_reference_id;
      END IF;

      IF p_old_DiscreteJob_rec.bom_revision = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.bom_revision := p_old_DiscreteJob_rec.bom_revision;
      END IF;

      IF p_old_DiscreteJob_rec.bom_revision_date = FND_API.G_MISS_DATE THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.bom_revision_date := p_old_DiscreteJob_rec.bom_revision_date;
      END IF;

      IF p_old_DiscreteJob_rec.build_sequence = FND_API.G_MISS_NUM THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.build_sequence := p_old_DiscreteJob_rec.build_sequence;
      END IF;

      IF p_old_DiscreteJob_rec.class_code = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.class_code := p_old_DiscreteJob_rec.class_code;
      END IF;

      IF p_old_DiscreteJob_rec.common_bom_sequence_id = FND_API.G_MISS_NUM THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.common_bom_sequence_id := p_old_DiscreteJob_rec.common_bom_sequence_id;
      END IF;

      IF p_old_DiscreteJob_rec.common_rout_sequence_id = FND_API.G_MISS_NUM THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.common_rout_sequence_id := p_old_DiscreteJob_rec.common_rout_sequence_id;
      END IF;

      IF p_old_DiscreteJob_rec.completion_locator_id = FND_API.G_MISS_NUM THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.completion_locator_id := p_old_DiscreteJob_rec.completion_locator_id;
      END IF;

      IF p_old_DiscreteJob_rec.completion_subinventory = FND_API.G_MISS_CHAR THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.completion_subinventory := p_old_DiscreteJob_rec.completion_subinventory;
      END IF;

      IF p_old_DiscreteJob_rec.created_by = FND_API.G_MISS_NUM THEN
	 NULL;
       ELSE
	 l_DiscreteJob_rec.created_by := p_old_DiscreteJob_rec.created_by;
      END IF;

      IF p_old_DiscreteJob_rec.creation_date = FND_API.G_MISS_DATE THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.creation_date := p_old_DiscreteJob_rec.creation_date;
      END IF;

      IF p_old_DiscreteJob_rec.date_closed = FND_API.G_MISS_DATE THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.date_closed := p_old_DiscreteJob_rec.date_closed;
      END IF;

      IF p_old_DiscreteJob_rec.date_completed = FND_API.G_MISS_DATE THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.date_completed := p_old_DiscreteJob_rec.date_completed;
      END IF;

      IF p_old_DiscreteJob_rec.date_released = FND_API.G_MISS_DATE THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.date_released := p_old_DiscreteJob_rec.date_released;
      END IF;

      IF p_old_DiscreteJob_rec.demand_class = FND_API.G_MISS_CHAR THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.demand_class := p_old_DiscreteJob_rec.demand_class;
      END IF;

      IF p_old_DiscreteJob_rec.description = FND_API.G_MISS_CHAR THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.description := p_old_DiscreteJob_rec.description;
      END IF;

      IF p_old_DiscreteJob_rec.firm_planned_flag = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.firm_planned_flag := p_old_DiscreteJob_rec.firm_planned_flag;
      END IF;

      IF p_old_DiscreteJob_rec.job_type = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.job_type := p_old_DiscreteJob_rec.job_type;
      END IF;

      IF p_old_DiscreteJob_rec.kanban_card_id = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.kanban_card_id := p_old_DiscreteJob_rec.kanban_card_id;
      END IF;

      IF p_old_DiscreteJob_rec.last_updated_by = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.last_updated_by := p_old_DiscreteJob_rec.last_updated_by;
      END IF;

      IF p_old_DiscreteJob_rec.last_update_date = FND_API.G_MISS_DATE THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.last_update_date := p_old_DiscreteJob_rec.last_update_date;
      END IF;

      IF p_old_DiscreteJob_rec.last_update_login = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.last_update_login := p_old_DiscreteJob_rec.last_update_login;
      END IF;

      IF p_old_DiscreteJob_rec.line_id = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.line_id := p_old_DiscreteJob_rec.line_id;
      END IF;

      IF p_old_DiscreteJob_rec.lot_number = FND_API.G_MISS_CHAR THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.lot_number := p_old_DiscreteJob_rec.lot_number;
      END IF;

      IF p_old_DiscreteJob_rec.material_account = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.material_account := p_old_DiscreteJob_rec.material_account;
      END IF;

      IF p_old_DiscreteJob_rec.material_overhead_account = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.material_overhead_account := p_old_DiscreteJob_rec.material_overhead_account;
      END IF;

      IF p_old_DiscreteJob_rec.material_variance_account = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.material_variance_account := p_old_DiscreteJob_rec.material_variance_account;
      END IF;

      IF p_old_DiscreteJob_rec.mps_net_quantity = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.mps_net_quantity := p_old_DiscreteJob_rec.mps_net_quantity;
      END IF;

      IF p_old_DiscreteJob_rec.mps_scheduled_cpl_date = FND_API.G_MISS_DATE THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.mps_scheduled_cpl_date := p_old_DiscreteJob_rec.mps_scheduled_cpl_date;
      END IF;

      IF p_old_DiscreteJob_rec.net_quantity = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.net_quantity := p_old_DiscreteJob_rec.net_quantity;
      END IF;

      IF p_old_DiscreteJob_rec.organization_id = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.organization_id := p_old_DiscreteJob_rec.organization_id;
      END IF;

      IF p_old_DiscreteJob_rec.osp_account = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.osp_account := p_old_DiscreteJob_rec.osp_account;
      END IF;

      IF p_old_DiscreteJob_rec.osp_variance_account = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.osp_variance_account := p_old_DiscreteJob_rec.osp_variance_account;
      END IF;

      IF p_old_DiscreteJob_rec.overcpl_tolerance_type = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.overcpl_tolerance_type := p_old_DiscreteJob_rec.overcpl_tolerance_type;
      END IF;

      IF p_old_DiscreteJob_rec.overcpl_tolerance_value = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.overcpl_tolerance_value := p_old_DiscreteJob_rec.overcpl_tolerance_value;
      END IF;

      IF p_old_DiscreteJob_rec.overhead_account = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.overhead_account := p_old_DiscreteJob_rec.overhead_account;
      END IF;

      IF p_old_DiscreteJob_rec.overhead_variance_account = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.overhead_variance_account := p_old_DiscreteJob_rec.overhead_variance_account;
      END IF;

      IF p_old_DiscreteJob_rec.primary_item_id = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.primary_item_id := p_old_DiscreteJob_rec.primary_item_id;
      END IF;

      IF p_old_DiscreteJob_rec.program_application_id = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.program_application_id := p_old_DiscreteJob_rec.program_application_id;
      END IF;

      IF p_old_DiscreteJob_rec.program_id = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.program_id := p_old_DiscreteJob_rec.program_id;
      END IF;

      IF p_old_DiscreteJob_rec.program_update_date = FND_API.G_MISS_DATE THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.program_update_date := p_old_DiscreteJob_rec.program_update_date;
      END IF;

      IF p_old_DiscreteJob_rec.project_costed = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.project_costed := p_old_DiscreteJob_rec.project_costed;
      END IF;

      IF p_old_DiscreteJob_rec.project_id = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.project_id := p_old_DiscreteJob_rec.project_id;
      END IF;

      IF p_old_DiscreteJob_rec.quantity_completed = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.quantity_completed := p_old_DiscreteJob_rec.quantity_completed;
      END IF;

      IF p_old_DiscreteJob_rec.quantity_scrapped = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.quantity_scrapped := p_old_DiscreteJob_rec.quantity_scrapped;
      END IF;

      IF p_old_DiscreteJob_rec.request_id = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.request_id := p_old_DiscreteJob_rec.request_id;
      END IF;

      IF p_old_DiscreteJob_rec.resource_account = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.resource_account := p_old_DiscreteJob_rec.resource_account;
      END IF;

      IF p_old_DiscreteJob_rec.resource_variance_account = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.resource_variance_account := p_old_DiscreteJob_rec.resource_variance_account;
      END IF;

      IF p_old_DiscreteJob_rec.routing_reference_id = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.routing_reference_id := p_old_DiscreteJob_rec.routing_reference_id;
      END IF;

      IF p_old_DiscreteJob_rec.routing_revision = FND_API.G_MISS_CHAR THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.routing_revision := p_old_DiscreteJob_rec.routing_revision;
      END IF;

      IF p_old_DiscreteJob_rec.routing_revision_date = FND_API.G_MISS_DATE THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.routing_revision_date := p_old_DiscreteJob_rec.routing_revision_date;
      END IF;

      IF p_old_DiscreteJob_rec.scheduled_completion_date = FND_API.G_MISS_DATE THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.scheduled_completion_date := p_old_DiscreteJob_rec.scheduled_completion_date;
      END IF;

      IF p_old_DiscreteJob_rec.scheduled_start_date = FND_API.G_MISS_DATE THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.scheduled_start_date := p_old_DiscreteJob_rec.scheduled_start_date;
      END IF;

      IF p_old_DiscreteJob_rec.schedule_group_id = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.schedule_group_id := p_old_DiscreteJob_rec.schedule_group_id;
      END IF;

      IF p_old_DiscreteJob_rec.source_code = FND_API.G_MISS_CHAR THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.source_code := p_old_DiscreteJob_rec.source_code;
      END IF;

      IF p_old_DiscreteJob_rec.source_line_id = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.source_line_id := p_old_DiscreteJob_rec.source_line_id;
      END IF;

      IF p_old_DiscreteJob_rec.start_quantity = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.start_quantity := p_old_DiscreteJob_rec.start_quantity;
      END IF;

      IF p_old_DiscreteJob_rec.status_type = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.status_type := p_old_DiscreteJob_rec.status_type;
      END IF;

      IF p_old_DiscreteJob_rec.std_cost_adj_account = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.std_cost_adj_account := p_old_DiscreteJob_rec.std_cost_adj_account;
      END IF;

      IF p_old_DiscreteJob_rec.task_id = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.task_id := p_old_DiscreteJob_rec.task_id;
      END IF;

      IF p_old_DiscreteJob_rec.wip_entity_id = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.wip_entity_id := p_old_DiscreteJob_rec.wip_entity_id;
      END IF;

      IF p_old_DiscreteJob_rec.wip_supply_type = FND_API.G_MISS_NUM THEN
 	 NULL;
       ELSE
	 l_DiscreteJob_rec.wip_supply_type := p_old_DiscreteJob_rec.wip_supply_type;
      END IF;

    ELSE

      IF l_DiscreteJob_rec.alternate_bom_designator = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.alternate_bom_designator := p_old_DiscreteJob_rec.alternate_bom_designator;
      END IF;

      IF l_DiscreteJob_rec.alternate_rout_designator = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.alternate_rout_designator := p_old_DiscreteJob_rec.alternate_rout_designator;
      END IF;

      IF l_DiscreteJob_rec.attribute1 = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute1 := p_old_DiscreteJob_rec.attribute1;
      END IF;

      IF l_DiscreteJob_rec.attribute10 = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute10 := p_old_DiscreteJob_rec.attribute10;
      END IF;

      IF l_DiscreteJob_rec.attribute11 = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute11 := p_old_DiscreteJob_rec.attribute11;
      END IF;

      IF l_DiscreteJob_rec.attribute12 = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute12 := p_old_DiscreteJob_rec.attribute12;
      END IF;

      IF l_DiscreteJob_rec.attribute13 = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute13 := p_old_DiscreteJob_rec.attribute13;
      END IF;

      IF l_DiscreteJob_rec.attribute14 = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute14 := p_old_DiscreteJob_rec.attribute14;
      END IF;

      IF l_DiscreteJob_rec.attribute15 = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute15 := p_old_DiscreteJob_rec.attribute15;
      END IF;

      IF l_DiscreteJob_rec.attribute2 = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute2 := p_old_DiscreteJob_rec.attribute2;
      END IF;

      IF l_DiscreteJob_rec.attribute3 = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute3 := p_old_DiscreteJob_rec.attribute3;
      END IF;

      IF l_DiscreteJob_rec.attribute4 = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute4 := p_old_DiscreteJob_rec.attribute4;
      END IF;

      IF l_DiscreteJob_rec.attribute5 = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute5 := p_old_DiscreteJob_rec.attribute5;
      END IF;

      IF l_DiscreteJob_rec.attribute6 = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute6 := p_old_DiscreteJob_rec.attribute6;
      END IF;

      IF l_DiscreteJob_rec.attribute7 = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute7 := p_old_DiscreteJob_rec.attribute7;
      END IF;

      IF l_DiscreteJob_rec.attribute8 = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute8 := p_old_DiscreteJob_rec.attribute8;
      END IF;

      IF l_DiscreteJob_rec.attribute9 = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute9 := p_old_DiscreteJob_rec.attribute9;
      END IF;

      IF l_DiscreteJob_rec.attribute_category = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.attribute_category := p_old_DiscreteJob_rec.attribute_category;
      END IF;

      IF l_DiscreteJob_rec.bom_reference_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.bom_reference_id := p_old_DiscreteJob_rec.bom_reference_id;
      END IF;

      IF l_DiscreteJob_rec.bom_revision = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.bom_revision := p_old_DiscreteJob_rec.bom_revision;
      END IF;

      IF l_DiscreteJob_rec.bom_revision_date = FND_API.G_MISS_DATE THEN
	 l_DiscreteJob_rec.bom_revision_date := p_old_DiscreteJob_rec.bom_revision_date;
      END IF;

      IF l_DiscreteJob_rec.build_sequence = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.build_sequence := p_old_DiscreteJob_rec.build_sequence;
      END IF;

      IF l_DiscreteJob_rec.class_code = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.class_code := p_old_DiscreteJob_rec.class_code;
      END IF;

      IF l_DiscreteJob_rec.common_bom_sequence_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.common_bom_sequence_id := p_old_DiscreteJob_rec.common_bom_sequence_id;
      END IF;

      IF l_DiscreteJob_rec.common_rout_sequence_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.common_rout_sequence_id := p_old_DiscreteJob_rec.common_rout_sequence_id;
      END IF;

      IF l_DiscreteJob_rec.completion_locator_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.completion_locator_id := p_old_DiscreteJob_rec.completion_locator_id;
      END IF;

      IF l_DiscreteJob_rec.completion_subinventory = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.completion_subinventory := p_old_DiscreteJob_rec.completion_subinventory;
      END IF;

      IF l_DiscreteJob_rec.created_by = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.created_by := p_old_DiscreteJob_rec.created_by;
      END IF;

      IF l_DiscreteJob_rec.creation_date = FND_API.G_MISS_DATE THEN
	 l_DiscreteJob_rec.creation_date := p_old_DiscreteJob_rec.creation_date;
      END IF;

      IF l_DiscreteJob_rec.date_closed = FND_API.G_MISS_DATE THEN
	 l_DiscreteJob_rec.date_closed := p_old_DiscreteJob_rec.date_closed;
      END IF;

      IF l_DiscreteJob_rec.date_completed = FND_API.G_MISS_DATE THEN
	 l_DiscreteJob_rec.date_completed := p_old_DiscreteJob_rec.date_completed;
      END IF;

      IF l_DiscreteJob_rec.date_released = FND_API.G_MISS_DATE THEN
	 l_DiscreteJob_rec.date_released := p_old_DiscreteJob_rec.date_released;
      END IF;

      IF l_DiscreteJob_rec.demand_class = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.demand_class := p_old_DiscreteJob_rec.demand_class;
      END IF;

      IF l_DiscreteJob_rec.description = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.description := p_old_DiscreteJob_rec.description;
      END IF;

      IF l_DiscreteJob_rec.firm_planned_flag = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.firm_planned_flag := p_old_DiscreteJob_rec.firm_planned_flag;
      END IF;

      IF l_DiscreteJob_rec.job_type = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.job_type := p_old_DiscreteJob_rec.job_type;
      END IF;

      IF l_DiscreteJob_rec.kanban_card_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.kanban_card_id := p_old_DiscreteJob_rec.kanban_card_id;
      END IF;

      IF l_DiscreteJob_rec.last_updated_by = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.last_updated_by := p_old_DiscreteJob_rec.last_updated_by;
      END IF;

      IF l_DiscreteJob_rec.last_update_date = FND_API.G_MISS_DATE THEN
	 l_DiscreteJob_rec.last_update_date := p_old_DiscreteJob_rec.last_update_date;
      END IF;

      IF l_DiscreteJob_rec.last_update_login = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.last_update_login := p_old_DiscreteJob_rec.last_update_login;
      END IF;

      IF l_DiscreteJob_rec.line_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.line_id := p_old_DiscreteJob_rec.line_id;
      END IF;

      IF l_DiscreteJob_rec.lot_number = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.lot_number := p_old_DiscreteJob_rec.lot_number;
      END IF;

      IF l_DiscreteJob_rec.material_account = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.material_account := p_old_DiscreteJob_rec.material_account;
      END IF;

      IF l_DiscreteJob_rec.material_overhead_account = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.material_overhead_account := p_old_DiscreteJob_rec.material_overhead_account;
      END IF;

      IF l_DiscreteJob_rec.material_variance_account = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.material_variance_account := p_old_DiscreteJob_rec.material_variance_account;
      END IF;

      IF l_DiscreteJob_rec.mps_net_quantity = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.mps_net_quantity := p_old_DiscreteJob_rec.mps_net_quantity;
      END IF;

      IF l_DiscreteJob_rec.mps_scheduled_cpl_date = FND_API.G_MISS_DATE THEN
	 l_DiscreteJob_rec.mps_scheduled_cpl_date := p_old_DiscreteJob_rec.mps_scheduled_cpl_date;
      END IF;

      IF l_DiscreteJob_rec.net_quantity = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.net_quantity := p_old_DiscreteJob_rec.net_quantity;
      END IF;

      IF l_DiscreteJob_rec.organization_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.organization_id := p_old_DiscreteJob_rec.organization_id;
      END IF;

      IF l_DiscreteJob_rec.osp_account = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.osp_account := p_old_DiscreteJob_rec.osp_account;
      END IF;

      IF l_DiscreteJob_rec.osp_variance_account = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.osp_variance_account := p_old_DiscreteJob_rec.osp_variance_account;
      END IF;

      IF l_DiscreteJob_rec.overcpl_tolerance_type = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.overcpl_tolerance_type := p_old_DiscreteJob_rec.overcpl_tolerance_type;
      END IF;

      IF l_DiscreteJob_rec.overcpl_tolerance_value = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.overcpl_tolerance_value := p_old_DiscreteJob_rec.overcpl_tolerance_value;
      END IF;

      IF l_DiscreteJob_rec.overhead_account = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.overhead_account := p_old_DiscreteJob_rec.overhead_account;
      END IF;

      IF l_DiscreteJob_rec.overhead_variance_account = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.overhead_variance_account := p_old_DiscreteJob_rec.overhead_variance_account;
      END IF;

      IF l_DiscreteJob_rec.primary_item_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.primary_item_id := p_old_DiscreteJob_rec.primary_item_id;
      END IF;

      IF l_DiscreteJob_rec.program_application_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.program_application_id := p_old_DiscreteJob_rec.program_application_id;
      END IF;

      IF l_DiscreteJob_rec.program_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.program_id := p_old_DiscreteJob_rec.program_id;
      END IF;

      IF l_DiscreteJob_rec.program_update_date = FND_API.G_MISS_DATE THEN
	 l_DiscreteJob_rec.program_update_date := p_old_DiscreteJob_rec.program_update_date;
      END IF;

      IF l_DiscreteJob_rec.project_costed = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.project_costed := p_old_DiscreteJob_rec.project_costed;
      END IF;

      IF l_DiscreteJob_rec.project_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.project_id := p_old_DiscreteJob_rec.project_id;
      END IF;

      IF l_DiscreteJob_rec.quantity_completed = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.quantity_completed := p_old_DiscreteJob_rec.quantity_completed;
      END IF;

      IF l_DiscreteJob_rec.quantity_scrapped = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.quantity_scrapped := p_old_DiscreteJob_rec.quantity_scrapped;
      END IF;

      IF l_DiscreteJob_rec.request_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.request_id := p_old_DiscreteJob_rec.request_id;
      END IF;

      IF l_DiscreteJob_rec.resource_account = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.resource_account := p_old_DiscreteJob_rec.resource_account;
      END IF;

      IF l_DiscreteJob_rec.resource_variance_account = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.resource_variance_account := p_old_DiscreteJob_rec.resource_variance_account;
      END IF;

      IF l_DiscreteJob_rec.routing_reference_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.routing_reference_id := p_old_DiscreteJob_rec.routing_reference_id;
      END IF;

      IF l_DiscreteJob_rec.routing_revision = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.routing_revision := p_old_DiscreteJob_rec.routing_revision;
      END IF;

      IF l_DiscreteJob_rec.routing_revision_date = FND_API.G_MISS_DATE THEN
	 l_DiscreteJob_rec.routing_revision_date := p_old_DiscreteJob_rec.routing_revision_date;
      END IF;

      IF l_DiscreteJob_rec.scheduled_completion_date = FND_API.G_MISS_DATE THEN
	 l_DiscreteJob_rec.scheduled_completion_date := p_old_DiscreteJob_rec.scheduled_completion_date;
      END IF;

      IF l_DiscreteJob_rec.scheduled_start_date = FND_API.G_MISS_DATE THEN
	 l_DiscreteJob_rec.scheduled_start_date := p_old_DiscreteJob_rec.scheduled_start_date;
      END IF;

      IF l_DiscreteJob_rec.schedule_group_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.schedule_group_id := p_old_DiscreteJob_rec.schedule_group_id;
      END IF;

      IF l_DiscreteJob_rec.source_code = FND_API.G_MISS_CHAR THEN
	 l_DiscreteJob_rec.source_code := p_old_DiscreteJob_rec.source_code;
      END IF;

      IF l_DiscreteJob_rec.source_line_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.source_line_id := p_old_DiscreteJob_rec.source_line_id;
      END IF;

      IF l_DiscreteJob_rec.start_quantity = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.start_quantity := p_old_DiscreteJob_rec.start_quantity;
      END IF;

      IF l_DiscreteJob_rec.status_type = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.status_type := p_old_DiscreteJob_rec.status_type;
      END IF;

      IF l_DiscreteJob_rec.std_cost_adj_account = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.std_cost_adj_account := p_old_DiscreteJob_rec.std_cost_adj_account;
      END IF;

      IF l_DiscreteJob_rec.task_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.task_id := p_old_DiscreteJob_rec.task_id;
      END IF;

      IF l_DiscreteJob_rec.wip_entity_id = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.wip_entity_id := p_old_DiscreteJob_rec.wip_entity_id;
      END IF;

      IF l_DiscreteJob_rec.wip_supply_type = FND_API.G_MISS_NUM THEN
	 l_DiscreteJob_rec.wip_supply_type := p_old_DiscreteJob_rec.wip_supply_type;
      END IF;

   END IF;
  END IF;
   RETURN l_DiscreteJob_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_DiscreteJob_rec               IN  WIP_Work_Order_PUB.Discretejob_Rec_Type
) RETURN WIP_Work_Order_PUB.Discretejob_Rec_Type
IS
l_DiscreteJob_rec             WIP_Work_Order_PUB.Discretejob_Rec_Type := p_DiscreteJob_rec;
BEGIN

    IF l_DiscreteJob_rec.alternate_bom_designator = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.alternate_bom_designator := NULL;
    END IF;

    IF l_DiscreteJob_rec.alternate_rout_designator = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.alternate_rout_designator := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute1 := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute10 := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute11 := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute12 := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute13 := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute14 := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute15 := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute2 := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute3 := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute4 := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute5 := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute6 := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute7 := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute8 := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute9 := NULL;
    END IF;

    IF l_DiscreteJob_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.attribute_category := NULL;
    END IF;

    IF l_DiscreteJob_rec.bom_reference_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.bom_reference_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.bom_revision = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.bom_revision := NULL;
    END IF;

    IF l_DiscreteJob_rec.bom_revision_date = FND_API.G_MISS_DATE THEN
        l_DiscreteJob_rec.bom_revision_date := NULL;
    END IF;

    IF l_DiscreteJob_rec.build_sequence = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.build_sequence := NULL;
    END IF;

    IF l_DiscreteJob_rec.class_code = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.class_code := NULL;
    END IF;

    IF l_DiscreteJob_rec.common_bom_sequence_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.common_bom_sequence_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.common_rout_sequence_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.common_rout_sequence_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.completion_locator_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.completion_locator_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.completion_subinventory = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.completion_subinventory := NULL;
    END IF;

    IF l_DiscreteJob_rec.created_by = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.created_by := NULL;
    END IF;

    IF l_DiscreteJob_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_DiscreteJob_rec.creation_date := NULL;
    END IF;

    IF l_DiscreteJob_rec.date_closed = FND_API.G_MISS_DATE THEN
        l_DiscreteJob_rec.date_closed := NULL;
    END IF;

    IF l_DiscreteJob_rec.date_completed = FND_API.G_MISS_DATE THEN
        l_DiscreteJob_rec.date_completed := NULL;
    END IF;

    IF l_DiscreteJob_rec.date_released = FND_API.G_MISS_DATE THEN
        l_DiscreteJob_rec.date_released := NULL;
    END IF;

    IF l_DiscreteJob_rec.demand_class = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.demand_class := NULL;
    END IF;

    IF l_DiscreteJob_rec.description = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.description := NULL;
    END IF;

    IF l_DiscreteJob_rec.firm_planned_flag = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.firm_planned_flag := NULL;
    END IF;

    IF l_DiscreteJob_rec.job_type = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.job_type := NULL;
    END IF;

    IF l_DiscreteJob_rec.kanban_card_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.kanban_card_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.last_updated_by := NULL;
    END IF;

    IF l_DiscreteJob_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_DiscreteJob_rec.last_update_date := NULL;
    END IF;

    IF l_DiscreteJob_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.last_update_login := NULL;
    END IF;

    IF l_DiscreteJob_rec.line_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.line_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.lot_number = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.lot_number := NULL;
    END IF;

    IF l_DiscreteJob_rec.material_account = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.material_account := NULL;
    END IF;

    IF l_DiscreteJob_rec.material_overhead_account = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.material_overhead_account := NULL;
    END IF;

    IF l_DiscreteJob_rec.material_variance_account = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.material_variance_account := NULL;
    END IF;

    IF l_DiscreteJob_rec.mps_net_quantity = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.mps_net_quantity := NULL;
    END IF;

    IF l_DiscreteJob_rec.mps_scheduled_cpl_date = FND_API.G_MISS_DATE THEN
        l_DiscreteJob_rec.mps_scheduled_cpl_date := NULL;
    END IF;

    IF l_DiscreteJob_rec.net_quantity = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.net_quantity := NULL;
    END IF;

    IF l_DiscreteJob_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.organization_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.osp_account = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.osp_account := NULL;
    END IF;

    IF l_DiscreteJob_rec.osp_variance_account = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.osp_variance_account := NULL;
    END IF;

    IF l_DiscreteJob_rec.overcpl_tolerance_type = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.overcpl_tolerance_type := NULL;
    END IF;

    IF l_DiscreteJob_rec.overcpl_tolerance_value = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.overcpl_tolerance_value := NULL;
    END IF;

    IF l_DiscreteJob_rec.overhead_account = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.overhead_account := NULL;
    END IF;

    IF l_DiscreteJob_rec.overhead_variance_account = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.overhead_variance_account := NULL;
    END IF;

    IF l_DiscreteJob_rec.primary_item_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.primary_item_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.program_application_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.program_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.program_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_DiscreteJob_rec.program_update_date := NULL;
    END IF;

    IF l_DiscreteJob_rec.project_costed = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.project_costed := NULL;
    END IF;

    IF l_DiscreteJob_rec.project_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.project_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.quantity_completed = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.quantity_completed := NULL;
    END IF;

    IF l_DiscreteJob_rec.quantity_scrapped = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.quantity_scrapped := NULL;
    END IF;

    IF l_DiscreteJob_rec.request_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.request_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.resource_account = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.resource_account := NULL;
    END IF;

    IF l_DiscreteJob_rec.resource_variance_account = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.resource_variance_account := NULL;
    END IF;

    IF l_DiscreteJob_rec.routing_reference_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.routing_reference_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.routing_revision = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.routing_revision := NULL;
    END IF;

    IF l_DiscreteJob_rec.routing_revision_date = FND_API.G_MISS_DATE THEN
        l_DiscreteJob_rec.routing_revision_date := NULL;
    END IF;

    IF l_DiscreteJob_rec.scheduled_completion_date = FND_API.G_MISS_DATE THEN
        l_DiscreteJob_rec.scheduled_completion_date := NULL;
    END IF;

    IF l_DiscreteJob_rec.scheduled_start_date = FND_API.G_MISS_DATE THEN
        l_DiscreteJob_rec.scheduled_start_date := NULL;
    END IF;

    IF l_DiscreteJob_rec.schedule_group_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.schedule_group_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.source_code = FND_API.G_MISS_CHAR THEN
        l_DiscreteJob_rec.source_code := NULL;
    END IF;

    IF l_DiscreteJob_rec.source_line_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.source_line_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.start_quantity = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.start_quantity := NULL;
    END IF;

    IF l_DiscreteJob_rec.status_type = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.status_type := NULL;
    END IF;

    IF l_DiscreteJob_rec.std_cost_adj_account = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.std_cost_adj_account := NULL;
    END IF;

    IF l_DiscreteJob_rec.task_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.task_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.wip_entity_id = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.wip_entity_id := NULL;
    END IF;

    IF l_DiscreteJob_rec.wip_supply_type = FND_API.G_MISS_NUM THEN
        l_DiscreteJob_rec.wip_supply_type := NULL;
    END IF;

    RETURN l_DiscreteJob_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_DiscreteJob_rec               IN  WIP_Work_Order_PUB.Discretejob_Rec_Type
)
IS
BEGIN

    UPDATE  WIP_DISCRETE_JOBS
    SET     ALTERNATE_BOM_DESIGNATOR       = p_DiscreteJob_rec.alternate_bom_designator
    ,       ALTERNATE_ROUTING_DESIGNATOR   = p_DiscreteJob_rec.alternate_rout_designator
    ,       ATTRIBUTE1                     = p_DiscreteJob_rec.attribute1
    ,       ATTRIBUTE10                    = p_DiscreteJob_rec.attribute10
    ,       ATTRIBUTE11                    = p_DiscreteJob_rec.attribute11
    ,       ATTRIBUTE12                    = p_DiscreteJob_rec.attribute12
    ,       ATTRIBUTE13                    = p_DiscreteJob_rec.attribute13
    ,       ATTRIBUTE14                    = p_DiscreteJob_rec.attribute14
    ,       ATTRIBUTE15                    = p_DiscreteJob_rec.attribute15
    ,       ATTRIBUTE2                     = p_DiscreteJob_rec.attribute2
    ,       ATTRIBUTE3                     = p_DiscreteJob_rec.attribute3
    ,       ATTRIBUTE4                     = p_DiscreteJob_rec.attribute4
    ,       ATTRIBUTE5                     = p_DiscreteJob_rec.attribute5
    ,       ATTRIBUTE6                     = p_DiscreteJob_rec.attribute6
    ,       ATTRIBUTE7                     = p_DiscreteJob_rec.attribute7
    ,       ATTRIBUTE8                     = p_DiscreteJob_rec.attribute8
    ,       ATTRIBUTE9                     = p_DiscreteJob_rec.attribute9
    ,       ATTRIBUTE_CATEGORY             = p_DiscreteJob_rec.attribute_category
    ,       BOM_REFERENCE_ID               = p_DiscreteJob_rec.bom_reference_id
    ,       BOM_REVISION                   = p_DiscreteJob_rec.bom_revision
    ,       BOM_REVISION_DATE              = p_DiscreteJob_rec.bom_revision_date
    ,       BUILD_SEQUENCE                 = p_DiscreteJob_rec.build_sequence
    ,       CLASS_CODE                     = p_DiscreteJob_rec.class_code
    ,       COMMON_BOM_SEQUENCE_ID         = p_DiscreteJob_rec.common_bom_sequence_id
    ,       COMMON_ROUTING_SEQUENCE_ID     = p_DiscreteJob_rec.common_rout_sequence_id
    ,       COMPLETION_LOCATOR_ID          = p_DiscreteJob_rec.completion_locator_id
    ,       COMPLETION_SUBINVENTORY        = p_DiscreteJob_rec.completion_subinventory
    ,       CREATED_BY                     = p_DiscreteJob_rec.created_by
    ,       CREATION_DATE                  = p_DiscreteJob_rec.creation_date
    ,       DATE_CLOSED                    = p_DiscreteJob_rec.date_closed
    ,       DATE_COMPLETED                 = p_DiscreteJob_rec.date_completed
    ,       DATE_RELEASED                  = p_DiscreteJob_rec.date_released
    ,       DEMAND_CLASS                   = p_DiscreteJob_rec.demand_class
    ,       DESCRIPTION                    = p_DiscreteJob_rec.description
    ,       FIRM_PLANNED_FLAG              = p_DiscreteJob_rec.firm_planned_flag
    ,       JOB_TYPE                       = p_DiscreteJob_rec.job_type
    ,       KANBAN_CARD_ID                 = p_DiscreteJob_rec.kanban_card_id
    ,       LAST_UPDATED_BY                = p_DiscreteJob_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_DiscreteJob_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_DiscreteJob_rec.last_update_login
    ,       LINE_ID                        = p_DiscreteJob_rec.line_id
    ,       LOT_NUMBER                     = p_DiscreteJob_rec.lot_number
    ,       MATERIAL_ACCOUNT               = p_DiscreteJob_rec.material_account
    ,       MATERIAL_OVERHEAD_ACCOUNT      = p_DiscreteJob_rec.material_overhead_account
    ,       MATERIAL_VARIANCE_ACCOUNT      = p_DiscreteJob_rec.material_variance_account
    ,       MPS_NET_QUANTITY               = p_DiscreteJob_rec.mps_net_quantity
    ,       MPS_SCHEDULED_COMPLETION_DATE  = p_DiscreteJob_rec.mps_scheduled_cpl_date
    ,       NET_QUANTITY                   = p_DiscreteJob_rec.net_quantity
    ,       ORGANIZATION_ID                = p_DiscreteJob_rec.organization_id
    ,       OUTSIDE_PROCESSING_ACCOUNT     = p_DiscreteJob_rec.osp_account
    ,       OUTSIDE_PROC_VARIANCE_ACCOUNT  = p_DiscreteJob_rec.osp_variance_account
    ,       OVERCOMPLETION_TOLERANCE_TYPE  = p_DiscreteJob_rec.overcpl_tolerance_type
    ,       OVERCOMPLETION_TOLERANCE_VALUE = p_DiscreteJob_rec.overcpl_tolerance_value
    ,       OVERHEAD_ACCOUNT               = p_DiscreteJob_rec.overhead_account
    ,       OVERHEAD_VARIANCE_ACCOUNT      = p_DiscreteJob_rec.overhead_variance_account
    ,       PRIMARY_ITEM_ID                = p_DiscreteJob_rec.primary_item_id
    ,       PROGRAM_APPLICATION_ID         = p_DiscreteJob_rec.program_application_id
    ,       PROGRAM_ID                     = p_DiscreteJob_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_DiscreteJob_rec.program_update_date
--    ,       PROJECT_COSTED                 = p_DiscreteJob_rec.project_costed
    ,       PROJECT_ID                     = p_DiscreteJob_rec.project_id
    ,       QUANTITY_COMPLETED             = p_DiscreteJob_rec.quantity_completed
    ,       QUANTITY_SCRAPPED              = p_DiscreteJob_rec.quantity_scrapped
    ,       REQUEST_ID                     = p_DiscreteJob_rec.request_id
    ,       RESOURCE_ACCOUNT               = p_DiscreteJob_rec.resource_account
    ,       RESOURCE_VARIANCE_ACCOUNT      = p_DiscreteJob_rec.resource_variance_account
    ,       ROUTING_REFERENCE_ID           = p_DiscreteJob_rec.routing_reference_id
    ,       ROUTING_REVISION               = p_DiscreteJob_rec.routing_revision
    ,       ROUTING_REVISION_DATE          = p_DiscreteJob_rec.routing_revision_date
    ,       SCHEDULED_COMPLETION_DATE      = p_DiscreteJob_rec.scheduled_completion_date
    ,       SCHEDULED_START_DATE           = p_DiscreteJob_rec.scheduled_start_date
    ,       SCHEDULE_GROUP_ID              = p_DiscreteJob_rec.schedule_group_id
    ,       SOURCE_CODE                    = p_DiscreteJob_rec.source_code
    ,       SOURCE_LINE_ID                 = p_DiscreteJob_rec.source_line_id
    ,       START_QUANTITY                 = p_DiscreteJob_rec.start_quantity
    ,       STATUS_TYPE                    = p_DiscreteJob_rec.status_type
    ,       STD_COST_ADJUSTMENT_ACCOUNT    = p_DiscreteJob_rec.std_cost_adj_account
    ,       TASK_ID                        = p_DiscreteJob_rec.task_id
    ,       WIP_ENTITY_ID                  = p_DiscreteJob_rec.wip_entity_id
    ,       WIP_SUPPLY_TYPE                = p_DiscreteJob_rec.wip_supply_type
    WHERE   WIP_ENTITY_ID = p_DiscreteJob_rec.wip_entity_id
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
(   p_DiscreteJob_rec               IN  WIP_Work_Order_PUB.Discretejob_Rec_Type
)
IS
BEGIN

    INSERT  INTO WIP_DISCRETE_JOBS
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
    ,       BOM_REFERENCE_ID
    ,       BOM_REVISION
    ,       BOM_REVISION_DATE
    ,       BUILD_SEQUENCE
    ,       CLASS_CODE
    ,       COMMON_BOM_SEQUENCE_ID
    ,       COMMON_ROUTING_SEQUENCE_ID
    ,       COMPLETION_LOCATOR_ID
    ,       COMPLETION_SUBINVENTORY
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DATE_CLOSED
    ,       DATE_COMPLETED
    ,       DATE_RELEASED
    ,       DEMAND_CLASS
    ,       DESCRIPTION
    ,       FIRM_PLANNED_FLAG
    ,       JOB_TYPE
    ,       KANBAN_CARD_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       LOT_NUMBER
    ,       MATERIAL_ACCOUNT
    ,       MATERIAL_OVERHEAD_ACCOUNT
    ,       MATERIAL_VARIANCE_ACCOUNT
    ,       MPS_NET_QUANTITY
    ,       MPS_SCHEDULED_COMPLETION_DATE
    ,       NET_QUANTITY
    ,       ORGANIZATION_ID
    ,       OUTSIDE_PROCESSING_ACCOUNT
    ,       OUTSIDE_PROC_VARIANCE_ACCOUNT
    ,       OVERCOMPLETION_TOLERANCE_TYPE
    ,       OVERCOMPLETION_TOLERANCE_VALUE
    ,       OVERHEAD_ACCOUNT
    ,       OVERHEAD_VARIANCE_ACCOUNT
    ,       PRIMARY_ITEM_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
--    ,       PROJECT_COSTED
    ,       PROJECT_ID
    ,       QUANTITY_COMPLETED
    ,       QUANTITY_SCRAPPED
    ,       REQUEST_ID
    ,       RESOURCE_ACCOUNT
    ,       RESOURCE_VARIANCE_ACCOUNT
    ,       ROUTING_REFERENCE_ID
    ,       ROUTING_REVISION
    ,       ROUTING_REVISION_DATE
    ,       SCHEDULED_COMPLETION_DATE
    ,       SCHEDULED_START_DATE
    ,       SCHEDULE_GROUP_ID
    ,       SOURCE_CODE
    ,       SOURCE_LINE_ID
    ,       START_QUANTITY
    ,       STATUS_TYPE
    ,       STD_COST_ADJUSTMENT_ACCOUNT
    ,       TASK_ID
    ,       WIP_ENTITY_ID
    ,       WIP_SUPPLY_TYPE
    )
    VALUES
    (       p_DiscreteJob_rec.alternate_bom_designator
    ,       p_DiscreteJob_rec.alternate_rout_designator
    ,       p_DiscreteJob_rec.attribute1
    ,       p_DiscreteJob_rec.attribute10
    ,       p_DiscreteJob_rec.attribute11
    ,       p_DiscreteJob_rec.attribute12
    ,       p_DiscreteJob_rec.attribute13
    ,       p_DiscreteJob_rec.attribute14
    ,       p_DiscreteJob_rec.attribute15
    ,       p_DiscreteJob_rec.attribute2
    ,       p_DiscreteJob_rec.attribute3
    ,       p_DiscreteJob_rec.attribute4
    ,       p_DiscreteJob_rec.attribute5
    ,       p_DiscreteJob_rec.attribute6
    ,       p_DiscreteJob_rec.attribute7
    ,       p_DiscreteJob_rec.attribute8
    ,       p_DiscreteJob_rec.attribute9
    ,       p_DiscreteJob_rec.attribute_category
    ,       p_DiscreteJob_rec.bom_reference_id
    ,       p_DiscreteJob_rec.bom_revision
    ,       p_DiscreteJob_rec.bom_revision_date
    ,       p_DiscreteJob_rec.build_sequence
    ,       p_DiscreteJob_rec.class_code
    ,       p_DiscreteJob_rec.common_bom_sequence_id
    ,       p_DiscreteJob_rec.common_rout_sequence_id
    ,       p_DiscreteJob_rec.completion_locator_id
    ,       p_DiscreteJob_rec.completion_subinventory
    ,       p_DiscreteJob_rec.created_by
    ,       p_DiscreteJob_rec.creation_date
    ,       p_DiscreteJob_rec.date_closed
    ,       p_DiscreteJob_rec.date_completed
    ,       p_DiscreteJob_rec.date_released
    ,       p_DiscreteJob_rec.demand_class
    ,       p_DiscreteJob_rec.description
    ,       p_DiscreteJob_rec.firm_planned_flag
    ,       p_DiscreteJob_rec.job_type
    ,       p_DiscreteJob_rec.kanban_card_id
    ,       p_DiscreteJob_rec.last_updated_by
    ,       p_DiscreteJob_rec.last_update_date
    ,       p_DiscreteJob_rec.last_update_login
    ,       p_DiscreteJob_rec.line_id
    ,       p_DiscreteJob_rec.lot_number
    ,       p_DiscreteJob_rec.material_account
    ,       p_DiscreteJob_rec.material_overhead_account
    ,       p_DiscreteJob_rec.material_variance_account
    ,       p_DiscreteJob_rec.mps_net_quantity
    ,       p_DiscreteJob_rec.mps_scheduled_cpl_date
    ,       p_DiscreteJob_rec.net_quantity
    ,       p_DiscreteJob_rec.organization_id
    ,       p_DiscreteJob_rec.osp_account
    ,       p_DiscreteJob_rec.osp_variance_account
    ,       p_DiscreteJob_rec.overcpl_tolerance_type
    ,       p_DiscreteJob_rec.overcpl_tolerance_value
    ,       p_DiscreteJob_rec.overhead_account
    ,       p_DiscreteJob_rec.overhead_variance_account
    ,       p_DiscreteJob_rec.primary_item_id
    ,       p_DiscreteJob_rec.program_application_id
    ,       p_DiscreteJob_rec.program_id
    ,       p_DiscreteJob_rec.program_update_date
--    ,       p_DiscreteJob_rec.project_costed
    ,       p_DiscreteJob_rec.project_id
    ,       p_DiscreteJob_rec.quantity_completed
    ,       p_DiscreteJob_rec.quantity_scrapped
    ,       p_DiscreteJob_rec.request_id
    ,       p_DiscreteJob_rec.resource_account
    ,       p_DiscreteJob_rec.resource_variance_account
    ,       p_DiscreteJob_rec.routing_reference_id
    ,       p_DiscreteJob_rec.routing_revision
    ,       p_DiscreteJob_rec.routing_revision_date
    ,       p_DiscreteJob_rec.scheduled_completion_date
    ,       p_DiscreteJob_rec.scheduled_start_date
    ,       p_DiscreteJob_rec.schedule_group_id
    ,       p_DiscreteJob_rec.source_code
    ,       p_DiscreteJob_rec.source_line_id
    ,       p_DiscreteJob_rec.start_quantity
    ,       p_DiscreteJob_rec.status_type
    ,       p_DiscreteJob_rec.std_cost_adj_account
    ,       p_DiscreteJob_rec.task_id
    ,       p_DiscreteJob_rec.wip_entity_id
    ,       p_DiscreteJob_rec.wip_supply_type
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

    DELETE  FROM WIP_DISCRETE_JOBS
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
) RETURN WIP_Work_Order_PUB.Discretejob_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_wip_entity_id               => p_wip_entity_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_wip_entity_id                 IN  NUMBER :=
                                        NULL
) RETURN WIP_Work_Order_PUB.Discretejob_Tbl_Type
IS
l_DiscreteJob_rec             WIP_Work_Order_PUB.Discretejob_Rec_Type;
l_DiscreteJob_tbl             WIP_Work_Order_PUB.Discretejob_Tbl_Type;

CURSOR l_DiscreteJob_csr IS
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
    ,       BOM_REFERENCE_ID
    ,       BOM_REVISION
    ,       BOM_REVISION_DATE
    ,       BUILD_SEQUENCE
    ,       CLASS_CODE
    ,       COMMON_BOM_SEQUENCE_ID
    ,       COMMON_ROUTING_SEQUENCE_ID
    ,       COMPLETION_LOCATOR_ID
    ,       COMPLETION_SUBINVENTORY
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DATE_CLOSED
    ,       DATE_COMPLETED
    ,       DATE_RELEASED
    ,       DEMAND_CLASS
    ,       DESCRIPTION
    ,       FIRM_PLANNED_FLAG
    ,       JOB_TYPE
    ,       KANBAN_CARD_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       LOT_NUMBER
    ,       MATERIAL_ACCOUNT
    ,       MATERIAL_OVERHEAD_ACCOUNT
    ,       MATERIAL_VARIANCE_ACCOUNT
    ,       MPS_NET_QUANTITY
    ,       MPS_SCHEDULED_COMPLETION_DATE
    ,       NET_QUANTITY
    ,       ORGANIZATION_ID
    ,       OUTSIDE_PROCESSING_ACCOUNT
    ,       OUTSIDE_PROC_VARIANCE_ACCOUNT
    ,       OVERCOMPLETION_TOLERANCE_TYPE
    ,       OVERCOMPLETION_TOLERANCE_VALUE
    ,       OVERHEAD_ACCOUNT
    ,       OVERHEAD_VARIANCE_ACCOUNT
    ,       PRIMARY_ITEM_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
--    ,       PROJECT_COSTED
    ,       PROJECT_ID
    ,       QUANTITY_COMPLETED
    ,       QUANTITY_SCRAPPED
    ,       REQUEST_ID
    ,       RESOURCE_ACCOUNT
    ,       RESOURCE_VARIANCE_ACCOUNT
    ,       ROUTING_REFERENCE_ID
    ,       ROUTING_REVISION
    ,       ROUTING_REVISION_DATE
    ,       SCHEDULED_COMPLETION_DATE
    ,       SCHEDULED_START_DATE
    ,       SCHEDULE_GROUP_ID
    ,       SOURCE_CODE
    ,       SOURCE_LINE_ID
    ,       START_QUANTITY
    ,       STATUS_TYPE
    ,       STD_COST_ADJUSTMENT_ACCOUNT
    ,       TASK_ID
    ,       WIP_ENTITY_ID
    ,       WIP_SUPPLY_TYPE
    FROM    WIP_DISCRETE_JOBS
    WHERE ( WIP_ENTITY_ID = p_wip_entity_id
    );

BEGIN

    --  Loop over fetched records

    FOR l_implicit_rec IN l_DiscreteJob_csr LOOP

        l_DiscreteJob_rec.alternate_bom_designator := l_implicit_rec.ALTERNATE_BOM_DESIGNATOR;
        l_DiscreteJob_rec.alternate_rout_designator := l_implicit_rec.ALTERNATE_ROUTING_DESIGNATOR;
        l_DiscreteJob_rec.attribute1   := l_implicit_rec.ATTRIBUTE1;
        l_DiscreteJob_rec.attribute10  := l_implicit_rec.ATTRIBUTE10;
        l_DiscreteJob_rec.attribute11  := l_implicit_rec.ATTRIBUTE11;
        l_DiscreteJob_rec.attribute12  := l_implicit_rec.ATTRIBUTE12;
        l_DiscreteJob_rec.attribute13  := l_implicit_rec.ATTRIBUTE13;
        l_DiscreteJob_rec.attribute14  := l_implicit_rec.ATTRIBUTE14;
        l_DiscreteJob_rec.attribute15  := l_implicit_rec.ATTRIBUTE15;
        l_DiscreteJob_rec.attribute2   := l_implicit_rec.ATTRIBUTE2;
        l_DiscreteJob_rec.attribute3   := l_implicit_rec.ATTRIBUTE3;
        l_DiscreteJob_rec.attribute4   := l_implicit_rec.ATTRIBUTE4;
        l_DiscreteJob_rec.attribute5   := l_implicit_rec.ATTRIBUTE5;
        l_DiscreteJob_rec.attribute6   := l_implicit_rec.ATTRIBUTE6;
        l_DiscreteJob_rec.attribute7   := l_implicit_rec.ATTRIBUTE7;
        l_DiscreteJob_rec.attribute8   := l_implicit_rec.ATTRIBUTE8;
        l_DiscreteJob_rec.attribute9   := l_implicit_rec.ATTRIBUTE9;
        l_DiscreteJob_rec.attribute_category := l_implicit_rec.ATTRIBUTE_CATEGORY;
        l_DiscreteJob_rec.bom_reference_id := l_implicit_rec.BOM_REFERENCE_ID;
        l_DiscreteJob_rec.bom_revision := l_implicit_rec.BOM_REVISION;
        l_DiscreteJob_rec.bom_revision_date := l_implicit_rec.BOM_REVISION_DATE;
        l_DiscreteJob_rec.build_sequence := l_implicit_rec.BUILD_SEQUENCE;
        l_DiscreteJob_rec.class_code   := l_implicit_rec.CLASS_CODE;
        l_DiscreteJob_rec.common_bom_sequence_id := l_implicit_rec.COMMON_BOM_SEQUENCE_ID;
        l_DiscreteJob_rec.common_rout_sequence_id := l_implicit_rec.COMMON_ROUTING_SEQUENCE_ID;
        l_DiscreteJob_rec.completion_locator_id := l_implicit_rec.COMPLETION_LOCATOR_ID;
        l_DiscreteJob_rec.completion_subinventory := l_implicit_rec.COMPLETION_SUBINVENTORY;
        l_DiscreteJob_rec.created_by   := l_implicit_rec.CREATED_BY;
        l_DiscreteJob_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_DiscreteJob_rec.date_closed  := l_implicit_rec.DATE_CLOSED;
        l_DiscreteJob_rec.date_completed := l_implicit_rec.DATE_COMPLETED;
        l_DiscreteJob_rec.date_released := l_implicit_rec.DATE_RELEASED;
        l_DiscreteJob_rec.demand_class := l_implicit_rec.DEMAND_CLASS;
        l_DiscreteJob_rec.description  := l_implicit_rec.DESCRIPTION;
        l_DiscreteJob_rec.firm_planned_flag := l_implicit_rec.FIRM_PLANNED_FLAG;
        l_DiscreteJob_rec.job_type     := l_implicit_rec.JOB_TYPE;
        l_DiscreteJob_rec.kanban_card_id := l_implicit_rec.KANBAN_CARD_ID;
        l_DiscreteJob_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_DiscreteJob_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_DiscreteJob_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_DiscreteJob_rec.line_id      := l_implicit_rec.LINE_ID;
        l_DiscreteJob_rec.lot_number   := l_implicit_rec.LOT_NUMBER;
        l_DiscreteJob_rec.material_account := l_implicit_rec.MATERIAL_ACCOUNT;
        l_DiscreteJob_rec.material_overhead_account := l_implicit_rec.MATERIAL_OVERHEAD_ACCOUNT;
        l_DiscreteJob_rec.material_variance_account := l_implicit_rec.MATERIAL_VARIANCE_ACCOUNT;
        l_DiscreteJob_rec.mps_net_quantity := l_implicit_rec.MPS_NET_QUANTITY;
        l_DiscreteJob_rec.mps_scheduled_cpl_date := l_implicit_rec.MPS_SCHEDULED_COMPLETION_DATE;
        l_DiscreteJob_rec.net_quantity := l_implicit_rec.NET_QUANTITY;
        l_DiscreteJob_rec.organization_id := l_implicit_rec.ORGANIZATION_ID;
        l_DiscreteJob_rec.osp_account  := l_implicit_rec.OUTSIDE_PROCESSING_ACCOUNT;
        l_DiscreteJob_rec.osp_variance_account := l_implicit_rec.OUTSIDE_PROC_VARIANCE_ACCOUNT;
        l_DiscreteJob_rec.overcpl_tolerance_type := l_implicit_rec.OVERCOMPLETION_TOLERANCE_TYPE;
        l_DiscreteJob_rec.overcpl_tolerance_value := l_implicit_rec.OVERCOMPLETION_TOLERANCE_VALUE;
        l_DiscreteJob_rec.overhead_account := l_implicit_rec.OVERHEAD_ACCOUNT;
        l_DiscreteJob_rec.overhead_variance_account := l_implicit_rec.OVERHEAD_VARIANCE_ACCOUNT;
        l_DiscreteJob_rec.primary_item_id := l_implicit_rec.PRIMARY_ITEM_ID;
        l_DiscreteJob_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_DiscreteJob_rec.program_id   := l_implicit_rec.PROGRAM_ID;
        l_DiscreteJob_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
--        l_DiscreteJob_rec.project_costed := l_implicit_rec.PROJECT_COSTED;
        l_DiscreteJob_rec.project_id   := l_implicit_rec.PROJECT_ID;
        l_DiscreteJob_rec.quantity_completed := l_implicit_rec.QUANTITY_COMPLETED;
        l_DiscreteJob_rec.quantity_scrapped := l_implicit_rec.QUANTITY_SCRAPPED;
        l_DiscreteJob_rec.request_id   := l_implicit_rec.REQUEST_ID;
        l_DiscreteJob_rec.resource_account := l_implicit_rec.RESOURCE_ACCOUNT;
        l_DiscreteJob_rec.resource_variance_account := l_implicit_rec.RESOURCE_VARIANCE_ACCOUNT;
        l_DiscreteJob_rec.routing_reference_id := l_implicit_rec.ROUTING_REFERENCE_ID;
        l_DiscreteJob_rec.routing_revision := l_implicit_rec.ROUTING_REVISION;
        l_DiscreteJob_rec.routing_revision_date := l_implicit_rec.ROUTING_REVISION_DATE;
        l_DiscreteJob_rec.scheduled_completion_date := l_implicit_rec.SCHEDULED_COMPLETION_DATE;
        l_DiscreteJob_rec.scheduled_start_date := l_implicit_rec.SCHEDULED_START_DATE;
        l_DiscreteJob_rec.schedule_group_id := l_implicit_rec.SCHEDULE_GROUP_ID;
        l_DiscreteJob_rec.source_code  := l_implicit_rec.SOURCE_CODE;
        l_DiscreteJob_rec.source_line_id := l_implicit_rec.SOURCE_LINE_ID;
        l_DiscreteJob_rec.start_quantity := l_implicit_rec.START_QUANTITY;
        l_DiscreteJob_rec.status_type  := l_implicit_rec.STATUS_TYPE;
        l_DiscreteJob_rec.std_cost_adj_account := l_implicit_rec.STD_COST_ADJUSTMENT_ACCOUNT;
        l_DiscreteJob_rec.task_id      := l_implicit_rec.TASK_ID;
        l_DiscreteJob_rec.wip_entity_id := l_implicit_rec.WIP_ENTITY_ID;
        l_DiscreteJob_rec.wip_supply_type := l_implicit_rec.WIP_SUPPLY_TYPE;

        l_DiscreteJob_tbl(l_DiscreteJob_tbl.COUNT + 1) := l_DiscreteJob_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_wip_entity_id IS NOT NULL
     AND
     p_wip_entity_id <> FND_API.G_MISS_NUM)
    AND
    (l_DiscreteJob_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_DiscreteJob_tbl;

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
,   p_DiscreteJob_rec               IN  WIP_Work_Order_PUB.Discretejob_Rec_Type
,   x_DiscreteJob_rec               OUT NOCOPY WIP_Work_Order_PUB.Discretejob_Rec_Type
)
IS
l_DiscreteJob_rec             WIP_Work_Order_PUB.Discretejob_Rec_Type;
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
    ,       BOM_REFERENCE_ID
    ,       BOM_REVISION
    ,       BOM_REVISION_DATE
    ,       BUILD_SEQUENCE
    ,       CLASS_CODE
    ,       COMMON_BOM_SEQUENCE_ID
    ,       COMMON_ROUTING_SEQUENCE_ID
    ,       COMPLETION_LOCATOR_ID
    ,       COMPLETION_SUBINVENTORY
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DATE_CLOSED
    ,       DATE_COMPLETED
    ,       DATE_RELEASED
    ,       DEMAND_CLASS
    ,       DESCRIPTION
    ,       FIRM_PLANNED_FLAG
    ,       JOB_TYPE
    ,       KANBAN_CARD_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       LOT_NUMBER
    ,       MATERIAL_ACCOUNT
    ,       MATERIAL_OVERHEAD_ACCOUNT
    ,       MATERIAL_VARIANCE_ACCOUNT
    ,       MPS_NET_QUANTITY
    ,       MPS_SCHEDULED_COMPLETION_DATE
    ,       NET_QUANTITY
    ,       ORGANIZATION_ID
    ,       OUTSIDE_PROCESSING_ACCOUNT
    ,       OUTSIDE_PROC_VARIANCE_ACCOUNT
    ,       OVERCOMPLETION_TOLERANCE_TYPE
    ,       OVERCOMPLETION_TOLERANCE_VALUE
    ,       OVERHEAD_ACCOUNT
    ,       OVERHEAD_VARIANCE_ACCOUNT
    ,       PRIMARY_ITEM_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
--    ,       PROJECT_COSTED
    ,       PROJECT_ID
    ,       QUANTITY_COMPLETED
    ,       QUANTITY_SCRAPPED
    ,       REQUEST_ID
    ,       RESOURCE_ACCOUNT
    ,       RESOURCE_VARIANCE_ACCOUNT
    ,       ROUTING_REFERENCE_ID
    ,       ROUTING_REVISION
    ,       ROUTING_REVISION_DATE
    ,       SCHEDULED_COMPLETION_DATE
    ,       SCHEDULED_START_DATE
    ,       SCHEDULE_GROUP_ID
    ,       SOURCE_CODE
    ,       SOURCE_LINE_ID
    ,       START_QUANTITY
    ,       STATUS_TYPE
    ,       STD_COST_ADJUSTMENT_ACCOUNT
    ,       TASK_ID
    ,       WIP_ENTITY_ID
    ,       WIP_SUPPLY_TYPE
    INTO    l_DiscreteJob_rec.alternate_bom_designator
    ,       l_DiscreteJob_rec.alternate_rout_designator
    ,       l_DiscreteJob_rec.attribute1
    ,       l_DiscreteJob_rec.attribute10
    ,       l_DiscreteJob_rec.attribute11
    ,       l_DiscreteJob_rec.attribute12
    ,       l_DiscreteJob_rec.attribute13
    ,       l_DiscreteJob_rec.attribute14
    ,       l_DiscreteJob_rec.attribute15
    ,       l_DiscreteJob_rec.attribute2
    ,       l_DiscreteJob_rec.attribute3
    ,       l_DiscreteJob_rec.attribute4
    ,       l_DiscreteJob_rec.attribute5
    ,       l_DiscreteJob_rec.attribute6
    ,       l_DiscreteJob_rec.attribute7
    ,       l_DiscreteJob_rec.attribute8
    ,       l_DiscreteJob_rec.attribute9
    ,       l_DiscreteJob_rec.attribute_category
    ,       l_DiscreteJob_rec.bom_reference_id
    ,       l_DiscreteJob_rec.bom_revision
    ,       l_DiscreteJob_rec.bom_revision_date
    ,       l_DiscreteJob_rec.build_sequence
    ,       l_DiscreteJob_rec.class_code
    ,       l_DiscreteJob_rec.common_bom_sequence_id
    ,       l_DiscreteJob_rec.common_rout_sequence_id
    ,       l_DiscreteJob_rec.completion_locator_id
    ,       l_DiscreteJob_rec.completion_subinventory
    ,       l_DiscreteJob_rec.created_by
    ,       l_DiscreteJob_rec.creation_date
    ,       l_DiscreteJob_rec.date_closed
    ,       l_DiscreteJob_rec.date_completed
    ,       l_DiscreteJob_rec.date_released
    ,       l_DiscreteJob_rec.demand_class
    ,       l_DiscreteJob_rec.description
    ,       l_DiscreteJob_rec.firm_planned_flag
    ,       l_DiscreteJob_rec.job_type
    ,       l_DiscreteJob_rec.kanban_card_id
    ,       l_DiscreteJob_rec.last_updated_by
    ,       l_DiscreteJob_rec.last_update_date
    ,       l_DiscreteJob_rec.last_update_login
    ,       l_DiscreteJob_rec.line_id
    ,       l_DiscreteJob_rec.lot_number
    ,       l_DiscreteJob_rec.material_account
    ,       l_DiscreteJob_rec.material_overhead_account
    ,       l_DiscreteJob_rec.material_variance_account
    ,       l_DiscreteJob_rec.mps_net_quantity
    ,       l_DiscreteJob_rec.mps_scheduled_cpl_date
    ,       l_DiscreteJob_rec.net_quantity
    ,       l_DiscreteJob_rec.organization_id
    ,       l_DiscreteJob_rec.osp_account
    ,       l_DiscreteJob_rec.osp_variance_account
    ,       l_DiscreteJob_rec.overcpl_tolerance_type
    ,       l_DiscreteJob_rec.overcpl_tolerance_value
    ,       l_DiscreteJob_rec.overhead_account
    ,       l_DiscreteJob_rec.overhead_variance_account
    ,       l_DiscreteJob_rec.primary_item_id
    ,       l_DiscreteJob_rec.program_application_id
    ,       l_DiscreteJob_rec.program_id
    ,       l_DiscreteJob_rec.program_update_date
--    ,       l_DiscreteJob_rec.project_costed
    ,       l_DiscreteJob_rec.project_id
    ,       l_DiscreteJob_rec.quantity_completed
    ,       l_DiscreteJob_rec.quantity_scrapped
    ,       l_DiscreteJob_rec.request_id
    ,       l_DiscreteJob_rec.resource_account
    ,       l_DiscreteJob_rec.resource_variance_account
    ,       l_DiscreteJob_rec.routing_reference_id
    ,       l_DiscreteJob_rec.routing_revision
    ,       l_DiscreteJob_rec.routing_revision_date
    ,       l_DiscreteJob_rec.scheduled_completion_date
    ,       l_DiscreteJob_rec.scheduled_start_date
    ,       l_DiscreteJob_rec.schedule_group_id
    ,       l_DiscreteJob_rec.source_code
    ,       l_DiscreteJob_rec.source_line_id
    ,       l_DiscreteJob_rec.start_quantity
    ,       l_DiscreteJob_rec.status_type
    ,       l_DiscreteJob_rec.std_cost_adj_account
    ,       l_DiscreteJob_rec.task_id
    ,       l_DiscreteJob_rec.wip_entity_id
    ,       l_DiscreteJob_rec.wip_supply_type
    FROM    WIP_DISCRETE_JOBS
    WHERE   WIP_ENTITY_ID = p_DiscreteJob_rec.wip_entity_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  WIP_GLOBALS.Equal(p_DiscreteJob_rec.alternate_bom_designator,
                         l_DiscreteJob_rec.alternate_bom_designator)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.alternate_rout_designator,
                         l_DiscreteJob_rec.alternate_rout_designator)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute1,
                         l_DiscreteJob_rec.attribute1)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute10,
                         l_DiscreteJob_rec.attribute10)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute11,
                         l_DiscreteJob_rec.attribute11)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute12,
                         l_DiscreteJob_rec.attribute12)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute13,
                         l_DiscreteJob_rec.attribute13)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute14,
                         l_DiscreteJob_rec.attribute14)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute15,
                         l_DiscreteJob_rec.attribute15)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute2,
                         l_DiscreteJob_rec.attribute2)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute3,
                         l_DiscreteJob_rec.attribute3)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute4,
                         l_DiscreteJob_rec.attribute4)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute5,
                         l_DiscreteJob_rec.attribute5)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute6,
                         l_DiscreteJob_rec.attribute6)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute7,
                         l_DiscreteJob_rec.attribute7)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute8,
                         l_DiscreteJob_rec.attribute8)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute9,
                         l_DiscreteJob_rec.attribute9)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.attribute_category,
                         l_DiscreteJob_rec.attribute_category)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.bom_reference_id,
                         l_DiscreteJob_rec.bom_reference_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.bom_revision,
                         l_DiscreteJob_rec.bom_revision)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.bom_revision_date,
                         l_DiscreteJob_rec.bom_revision_date)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.build_sequence,
                         l_DiscreteJob_rec.build_sequence)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.class_code,
                         l_DiscreteJob_rec.class_code)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.common_bom_sequence_id,
                         l_DiscreteJob_rec.common_bom_sequence_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.common_rout_sequence_id,
                         l_DiscreteJob_rec.common_rout_sequence_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.completion_locator_id,
                         l_DiscreteJob_rec.completion_locator_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.completion_subinventory,
                         l_DiscreteJob_rec.completion_subinventory)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.created_by,
                         l_DiscreteJob_rec.created_by)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.creation_date,
                         l_DiscreteJob_rec.creation_date)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.date_closed,
                         l_DiscreteJob_rec.date_closed)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.date_completed,
                         l_DiscreteJob_rec.date_completed)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.date_released,
                         l_DiscreteJob_rec.date_released)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.demand_class,
                         l_DiscreteJob_rec.demand_class)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.description,
                         l_DiscreteJob_rec.description)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.firm_planned_flag,
                         l_DiscreteJob_rec.firm_planned_flag)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.job_type,
                         l_DiscreteJob_rec.job_type)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.kanban_card_id,
                         l_DiscreteJob_rec.kanban_card_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.last_updated_by,
                         l_DiscreteJob_rec.last_updated_by)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.last_update_date,
                         l_DiscreteJob_rec.last_update_date)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.last_update_login,
                         l_DiscreteJob_rec.last_update_login)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.line_id,
                         l_DiscreteJob_rec.line_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.lot_number,
                         l_DiscreteJob_rec.lot_number)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.material_account,
                         l_DiscreteJob_rec.material_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.material_overhead_account,
                         l_DiscreteJob_rec.material_overhead_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.material_variance_account,
                         l_DiscreteJob_rec.material_variance_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.mps_net_quantity,
                         l_DiscreteJob_rec.mps_net_quantity)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.mps_scheduled_cpl_date,
                         l_DiscreteJob_rec.mps_scheduled_cpl_date)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.net_quantity,
                         l_DiscreteJob_rec.net_quantity)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.organization_id,
                         l_DiscreteJob_rec.organization_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.osp_account,
                         l_DiscreteJob_rec.osp_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.osp_variance_account,
                         l_DiscreteJob_rec.osp_variance_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.overcpl_tolerance_type,
                         l_DiscreteJob_rec.overcpl_tolerance_type)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.overcpl_tolerance_value,
                         l_DiscreteJob_rec.overcpl_tolerance_value)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.overhead_account,
                         l_DiscreteJob_rec.overhead_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.overhead_variance_account,
                         l_DiscreteJob_rec.overhead_variance_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.primary_item_id,
                         l_DiscreteJob_rec.primary_item_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.program_application_id,
                         l_DiscreteJob_rec.program_application_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.program_id,
                         l_DiscreteJob_rec.program_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.program_update_date,
                         l_DiscreteJob_rec.program_update_date)
--    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.project_costed,
--                         l_DiscreteJob_rec.project_costed)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.project_id,
                         l_DiscreteJob_rec.project_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.quantity_completed,
                         l_DiscreteJob_rec.quantity_completed)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.quantity_scrapped,
                         l_DiscreteJob_rec.quantity_scrapped)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.request_id,
                         l_DiscreteJob_rec.request_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.resource_account,
                         l_DiscreteJob_rec.resource_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.resource_variance_account,
                         l_DiscreteJob_rec.resource_variance_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.routing_reference_id,
                         l_DiscreteJob_rec.routing_reference_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.routing_revision,
                         l_DiscreteJob_rec.routing_revision)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.routing_revision_date,
                         l_DiscreteJob_rec.routing_revision_date)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.scheduled_completion_date,
                         l_DiscreteJob_rec.scheduled_completion_date)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.scheduled_start_date,
                         l_DiscreteJob_rec.scheduled_start_date)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.schedule_group_id,
                         l_DiscreteJob_rec.schedule_group_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.source_code,
                         l_DiscreteJob_rec.source_code)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.source_line_id,
                         l_DiscreteJob_rec.source_line_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.start_quantity,
                         l_DiscreteJob_rec.start_quantity)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.status_type,
                         l_DiscreteJob_rec.status_type)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.std_cost_adj_account,
                         l_DiscreteJob_rec.std_cost_adj_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.task_id,
                         l_DiscreteJob_rec.task_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.wip_entity_id,
                         l_DiscreteJob_rec.wip_entity_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec.wip_supply_type,
                         l_DiscreteJob_rec.wip_supply_type)
    THEN

        --  Row has not changed. Set out parameter.

        x_DiscreteJob_rec              := l_DiscreteJob_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_DiscreteJob_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_DiscreteJob_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','OE_LOCK_ROW_CHANGED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_DiscreteJob_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','OE_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_DiscreteJob_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','OE_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_DiscreteJob_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;



FUNCTION Compare( p_DiscreteJob_rec1    IN WIP_Work_Order_PUB.Discretejob_Rec_Type,
                  p_DiscreteJob_rec2    IN WIP_Work_Order_PUB.Discretejob_Rec_Type)
  RETURN BOOLEAN
  IS
BEGIN

    IF  WIP_GLOBALS.Equal(p_DiscreteJob_rec1.alternate_bom_designator,
			  p_DiscreteJob_rec2.alternate_bom_designator)
      AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.alternate_rout_designator,
			    p_DiscreteJob_rec2.alternate_rout_designator)
      AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute1,
			    p_DiscreteJob_rec2.attribute1)
      AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute10,
			    p_DiscreteJob_rec2.attribute10)
      AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute11,
			    p_DiscreteJob_rec2.attribute11)
      AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute12,
			    p_DiscreteJob_rec2.attribute12)
      AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute13,
                         p_DiscreteJob_rec2.attribute13)
      AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute14,
			    p_DiscreteJob_rec2.attribute14)
      AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute15,
			    p_DiscreteJob_rec2.attribute15)
      AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute2,
			    p_DiscreteJob_rec2.attribute2)
      AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute3,
			    p_DiscreteJob_rec2.attribute3)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute4,
                         p_DiscreteJob_rec2.attribute4)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute5,
                         p_DiscreteJob_rec2.attribute5)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute6,
                         p_DiscreteJob_rec2.attribute6)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute7,
                         p_DiscreteJob_rec2.attribute7)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute8,
                         p_DiscreteJob_rec2.attribute8)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute9,
                         p_DiscreteJob_rec2.attribute9)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.attribute_category,
                         p_DiscreteJob_rec2.attribute_category)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.bom_reference_id,
                         p_DiscreteJob_rec2.bom_reference_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.bom_revision,
                         p_DiscreteJob_rec2.bom_revision)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.bom_revision_date,
                         p_DiscreteJob_rec2.bom_revision_date)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.build_sequence,
                         p_DiscreteJob_rec2.build_sequence)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.class_code,
                         p_DiscreteJob_rec2.class_code)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.common_bom_sequence_id,
                         p_DiscreteJob_rec2.common_bom_sequence_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.common_rout_sequence_id,
                         p_DiscreteJob_rec2.common_rout_sequence_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.completion_locator_id,
                         p_DiscreteJob_rec2.completion_locator_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.completion_subinventory,
                         p_DiscreteJob_rec2.completion_subinventory)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.created_by,
                         p_DiscreteJob_rec2.created_by)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.creation_date,
                         p_DiscreteJob_rec2.creation_date)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.date_closed,
                         p_DiscreteJob_rec2.date_closed)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.date_completed,
                         p_DiscreteJob_rec2.date_completed)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.date_released,
                         p_DiscreteJob_rec2.date_released)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.demand_class,
                         p_DiscreteJob_rec2.demand_class)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.description,
                         p_DiscreteJob_rec2.description)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.firm_planned_flag,
                         p_DiscreteJob_rec2.firm_planned_flag)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.job_type,
                         p_DiscreteJob_rec2.job_type)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.kanban_card_id,
                         p_DiscreteJob_rec2.kanban_card_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.last_updated_by,
                         p_DiscreteJob_rec2.last_updated_by)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.last_update_date,
                         p_DiscreteJob_rec2.last_update_date)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.last_update_login,
                         p_DiscreteJob_rec2.last_update_login)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.line_id,
                         p_DiscreteJob_rec2.line_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.lot_number,
                         p_DiscreteJob_rec2.lot_number)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.material_account,
                         p_DiscreteJob_rec2.material_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.material_overhead_account,
                         p_DiscreteJob_rec2.material_overhead_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.material_variance_account,
                         p_DiscreteJob_rec2.material_variance_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.mps_net_quantity,
                         p_DiscreteJob_rec2.mps_net_quantity)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.mps_scheduled_cpl_date,
                         p_DiscreteJob_rec2.mps_scheduled_cpl_date)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.net_quantity,
                         p_DiscreteJob_rec2.net_quantity)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.organization_id,
                         p_DiscreteJob_rec2.organization_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.osp_account,
                         p_DiscreteJob_rec2.osp_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.osp_variance_account,
                         p_DiscreteJob_rec2.osp_variance_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.overcpl_tolerance_type,
                         p_DiscreteJob_rec2.overcpl_tolerance_type)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.overcpl_tolerance_value,
                         p_DiscreteJob_rec2.overcpl_tolerance_value)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.overhead_account,
                         p_DiscreteJob_rec2.overhead_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.overhead_variance_account,
                         p_DiscreteJob_rec2.overhead_variance_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.primary_item_id,
                         p_DiscreteJob_rec2.primary_item_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.program_application_id,
                         p_DiscreteJob_rec2.program_application_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.program_id,
                         p_DiscreteJob_rec2.program_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.program_update_date,
                         p_DiscreteJob_rec2.program_update_date)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.project_costed,
                         p_DiscreteJob_rec2.project_costed)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.project_id,
                         p_DiscreteJob_rec2.project_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.quantity_completed,
                         p_DiscreteJob_rec2.quantity_completed)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.quantity_scrapped,
                         p_DiscreteJob_rec2.quantity_scrapped)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.request_id,
                         p_DiscreteJob_rec2.request_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.resource_account,
                         p_DiscreteJob_rec2.resource_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.resource_variance_account,
                         p_DiscreteJob_rec2.resource_variance_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.routing_reference_id,
                         p_DiscreteJob_rec2.routing_reference_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.routing_revision,
                         p_DiscreteJob_rec2.routing_revision)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.routing_revision_date,
                         p_DiscreteJob_rec2.routing_revision_date)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.scheduled_completion_date,
                         p_DiscreteJob_rec2.scheduled_completion_date)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.scheduled_start_date,
                         p_DiscreteJob_rec2.scheduled_start_date)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.schedule_group_id,
                         p_DiscreteJob_rec2.schedule_group_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.source_code,
                         p_DiscreteJob_rec2.source_code)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.source_line_id,
                         p_DiscreteJob_rec2.source_line_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.start_quantity,
                         p_DiscreteJob_rec2.start_quantity)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.status_type,
                         p_DiscreteJob_rec2.status_type)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.std_cost_adj_account,
                         p_DiscreteJob_rec2.std_cost_adj_account)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.task_id,
                         p_DiscreteJob_rec2.task_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.wip_entity_id,
                         p_DiscreteJob_rec2.wip_entity_id)
    AND WIP_GLOBALS.Equal(p_DiscreteJob_rec1.wip_supply_type,
                         p_DiscreteJob_rec2.wip_supply_type)
      THEN
       RETURN TRUE;
     ELSE
       RETURN FALSE;
    END IF;
END Compare;

PROCEDURE dprintf(p_DiscreteJob_rec    IN WIP_Work_Order_PUB.Discretejob_Rec_Type)
  IS
BEGIN

   null;
-- dbms_output.new_line;
-- dbms_output.put_line('Discrete Job Record:');
-- dbms_output.put_line('-------------------');
-- dbms_output.put_line('completion_locator_id    : ' || To_char(p_DiscreteJob_rec.completion_locator_id));
-- dbms_output.put_line('completion_subinventory  : ' || p_DiscreteJob_rec.completion_subinventory);
-- dbms_output.put_line('date_completed           : ' || To_char(p_DiscreteJob_rec.date_completed,WIP_CONSTANTS.DATE_FMT));
-- dbms_output.put_line('date_released            : ' || To_char(p_DiscreteJob_rec.date_released,WIP_CONSTANTS.DATE_FMT));
-- dbms_output.put_line('description              : ' || p_DiscreteJob_rec.description);
-- dbms_output.put_line('job_type                 : ' || To_char(p_DiscreteJob_rec.job_type));
-- dbms_output.put_line('net_quantity             : ' || To_char(p_DiscreteJob_rec.net_quantity));
-- dbms_output.put_line('organization_id          : ' || To_char(p_DiscreteJob_rec.organization_id));
-- dbms_output.put_line('primary_item_id          : ' || To_char(p_DiscreteJob_rec.primary_item_id));
-- dbms_output.put_line('quantity_completed       : ' || To_char(p_DiscreteJob_rec.quantity_completed));
-- dbms_output.put_line('quantity_scrapped        : ' || To_char(p_DiscreteJob_rec.quantity_scrapped));
-- dbms_output.put_line('scheduled_completion_date: ' || To_char(p_DiscreteJob_rec.scheduled_completion_date,WIP_CONSTANTS.DATE_FMT));
-- dbms_output.put_line('scheduled_start_date     : ' || To_char(p_DiscreteJob_rec.scheduled_start_date,WIP_CONSTANTS.DATE_FMT));
-- dbms_output.put_line('start_quantity           : ' || To_char(p_DiscreteJob_rec.start_quantity));
-- dbms_output.put_line('status_type              : ' || To_char(p_DiscreteJob_rec.status_type));
-- dbms_output.put_line('wip_entity_id            : ' || To_char(p_DiscreteJob_rec.wip_entity_id));
-- dbms_output.put_line('kanban_card_id           : ' || To_char(p_DiscreteJob_rec.kanban_card_id));
-- dbms_output.put_line('return_status            : ' || p_DiscreteJob_rec.return_status);
-- dbms_output.put_line('db_flag                  : ' || p_DiscreteJob_rec.db_flag);
-- dbms_output.put_line('action                   : ' || p_DiscreteJob_rec.action);
-- dbms_output.put_line('End Discrete Job Record');
EXCEPTION
   WHEN OTHERS THEN
      NULL;

END dprintf;

PROCEDURE update_job_details(p_org_id IN NUMBER,
                             p_wip_entity_id IN NUMBER,
                             p_due_date IN DATE,
                             p_line_id IN NUMBER,
                             p_schedule_group_id IN NUMBER,
                             p_build_sequence IN NUMBER,
                             p_expedited IN VARCHAR2,
                             p_initialize IN VARCHAR2,
                             x_err_msg OUT NOCOPY VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2) IS
CURSOR c_build_seq IS
	SELECT 1
	FROM WIP_DISCRETE_JOBS
	WHERE SCHEDULE_GROUP_ID = p_schedule_group_id
	AND   BUILD_SEQUENCE = p_build_sequence
	AND   WIP_ENTITY_ID <> NVL(p_wip_entity_id, -1);

CURSOR c_jobname IS
  select wip_entity_name
  from wip_entities
  where wip_entity_id = p_wip_entity_id;

  x_dummy varchar(1);
  x_wip_entity_name VARCHAR2(240);

BEGIN

  x_return_status := FND_API.G_RET_STS_ERROR;

  if (p_initialize = 'Y') then
    fnd_msg_pub.initialize;
  end if;

  open c_jobname;
  fetch c_jobname into x_wip_entity_name;
  close c_jobname;

  -- if build sequence with no schedule group then error out
  if (p_build_sequence is not null and p_schedule_group_id is null) then
    x_err_msg := x_wip_entity_name || ' ' || fnd_message.get_string('WIP','WIP_SCHEDULE_GROUP_NULL');
    fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_discretejob_util',
                              p_procedure_name => 'update_job_details',
                              p_error_text => x_err_msg);

    -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    return;
  end if;

  -- Verify that the schedule group and build sequence are unique
  if (p_build_sequence is not null) then

    open c_build_seq;
    fetch c_build_seq into x_dummy;

    if c_build_seq%found then
       x_err_msg := x_wip_entity_name || ' ' || fnd_message.get_string('WIP','WIP_BUILD_SEQUENCE');
       fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_discretejob_util',
                              p_procedure_name => 'update_job_details',
                              p_error_text => x_err_msg);

      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	close c_build_seq;
        return;
    end if;

    close c_build_seq;
  end if;

  update wip_discrete_jobs
    set due_date = p_due_date,
        line_id = p_line_id,
        schedule_group_id = p_schedule_group_id,
        build_sequence = p_build_sequence,
        expedited = p_expedited
    where organization_id = p_org_id and
          wip_entity_id = p_wip_entity_id;


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when fnd_api.g_exc_unexpected_error then
      x_return_status := fnd_api.g_ret_sts_unexp_error;

    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_discretejob_util',
                              p_procedure_name => 'update_job_details',
                              p_error_text => SQLERRM);

END update_job_details;


END WIP_Discretejob_Util;

/
