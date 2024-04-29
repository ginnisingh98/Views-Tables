--------------------------------------------------------
--  DDL for Package Body WIP_REPSCHEDULE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_REPSCHEDULE_UTIL" AS
/* $Header: WIPUWRSB.pls 115.12 2002/11/29 13:33:24 simishra ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Repschedule_Util';


--  Function Complete_Record

FUNCTION Complete_Record
(   p_RepSchedule_rec               IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
,   p_old_RepSchedule_rec           IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
,   p_ForceCopy                     IN  BOOLEAN := NULL
) RETURN WIP_Work_Order_PUB.Repschedule_Rec_Type
IS
l_RepSchedule_rec             WIP_Work_Order_PUB.Repschedule_Rec_Type := p_RepSchedule_rec;
BEGIN
 IF(p_ForceCopy IS NOT NULL) THEN
   IF(p_ForceCopy = TRUE)
     THEN

      IF p_old_RepSchedule_rec.alternate_bom_designator <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.alternate_bom_designator := p_old_RepSchedule_rec.alternate_bom_designator;
      END IF;

      IF p_old_RepSchedule_rec.alternate_rout_designator <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.alternate_rout_designator := p_old_RepSchedule_rec.alternate_rout_designator;
      END IF;

      IF p_old_RepSchedule_rec.attribute1 <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute1 := p_old_RepSchedule_rec.attribute1;
      END IF;

      IF p_old_RepSchedule_rec.attribute10 <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute10 := p_old_RepSchedule_rec.attribute10;
      END IF;

      IF p_old_RepSchedule_rec.attribute11 <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute11 := p_old_RepSchedule_rec.attribute11;
      END IF;

      IF p_old_RepSchedule_rec.attribute12 <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute12 := p_old_RepSchedule_rec.attribute12;
      END IF;

      IF p_old_RepSchedule_rec.attribute13 <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute13 := p_old_RepSchedule_rec.attribute13;
      END IF;

      IF p_old_RepSchedule_rec.attribute14 <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute14 := p_old_RepSchedule_rec.attribute14;
      END IF;

      IF p_old_RepSchedule_rec.attribute15 <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute15 := p_old_RepSchedule_rec.attribute15;
      END IF;

      IF p_old_RepSchedule_rec.attribute2 <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute2 := p_old_RepSchedule_rec.attribute2;
      END IF;

      IF p_old_RepSchedule_rec.attribute3 <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute3 := p_old_RepSchedule_rec.attribute3;
      END IF;

      IF p_old_RepSchedule_rec.attribute4 <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute4 := p_old_RepSchedule_rec.attribute4;
      END IF;

      IF p_old_RepSchedule_rec.attribute5 <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute5 := p_old_RepSchedule_rec.attribute5;
      END IF;

      IF p_old_RepSchedule_rec.attribute6 <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute6 := p_old_RepSchedule_rec.attribute6;
      END IF;

      IF p_old_RepSchedule_rec.attribute7 <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute7 := p_old_RepSchedule_rec.attribute7;
      END IF;

      IF p_old_RepSchedule_rec.attribute8 <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute8 := p_old_RepSchedule_rec.attribute8;
      END IF;

      IF p_old_RepSchedule_rec.attribute9 <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute9 := p_old_RepSchedule_rec.attribute9;
      END IF;

      IF p_old_RepSchedule_rec.attribute_category <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute_category := p_old_RepSchedule_rec.attribute_category;
      END IF;

      IF p_old_RepSchedule_rec.bom_revision <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.bom_revision := p_old_RepSchedule_rec.bom_revision;
      END IF;

      IF p_old_RepSchedule_rec.bom_revision_date <> FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.bom_revision_date := p_old_RepSchedule_rec.bom_revision_date;
      END IF;

      IF p_old_RepSchedule_rec.common_bom_sequence_id <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.common_bom_sequence_id := p_old_RepSchedule_rec.common_bom_sequence_id;
      END IF;

      IF p_old_RepSchedule_rec.common_rout_sequence_id <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.common_rout_sequence_id := p_old_RepSchedule_rec.common_rout_sequence_id;
      END IF;

      IF p_old_RepSchedule_rec.created_by <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.created_by := p_old_RepSchedule_rec.created_by;
      END IF;

      IF p_old_RepSchedule_rec.creation_date <> FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.creation_date := p_old_RepSchedule_rec.creation_date;
      END IF;

      IF p_old_RepSchedule_rec.daily_production_rate <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.daily_production_rate := p_old_RepSchedule_rec.daily_production_rate;
      END IF;

      IF p_old_RepSchedule_rec.date_closed <> FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.date_closed := p_old_RepSchedule_rec.date_closed;
      END IF;

      IF p_old_RepSchedule_rec.date_released <> FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.date_released := p_old_RepSchedule_rec.date_released;
      END IF;

      IF p_old_RepSchedule_rec.demand_class <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.demand_class := p_old_RepSchedule_rec.demand_class;
      END IF;

      IF p_old_RepSchedule_rec.description <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.description := p_old_RepSchedule_rec.description;
      END IF;

      IF p_old_RepSchedule_rec.firm_planned_flag <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.firm_planned_flag := p_old_RepSchedule_rec.firm_planned_flag;
      END IF;

      IF p_old_RepSchedule_rec.first_unit_cpl_date <> FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.first_unit_cpl_date := p_old_RepSchedule_rec.first_unit_cpl_date;
      END IF;

      IF p_old_RepSchedule_rec.first_unit_start_date <> FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.first_unit_start_date := p_old_RepSchedule_rec.first_unit_start_date;
      END IF;

      IF p_old_RepSchedule_rec.last_unit_cpl_date <> FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.last_unit_cpl_date := p_old_RepSchedule_rec.last_unit_cpl_date;
      END IF;

      IF p_old_RepSchedule_rec.last_unit_start_date <> FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.last_unit_start_date := p_old_RepSchedule_rec.last_unit_start_date;
      END IF;

      IF p_old_RepSchedule_rec.last_updated_by <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.last_updated_by := p_old_RepSchedule_rec.last_updated_by;
      END IF;

      IF p_old_RepSchedule_rec.last_update_date <> FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.last_update_date := p_old_RepSchedule_rec.last_update_date;
      END IF;

      IF p_old_RepSchedule_rec.last_update_login <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.last_update_login := p_old_RepSchedule_rec.last_update_login;
      END IF;

      IF p_old_RepSchedule_rec.line_id <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.line_id := p_old_RepSchedule_rec.line_id;
      END IF;

      IF p_old_RepSchedule_rec.material_account <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.material_account := p_old_RepSchedule_rec.material_account;
      END IF;

      IF p_old_RepSchedule_rec.material_overhead_account <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.material_overhead_account := p_old_RepSchedule_rec.material_overhead_account;
      END IF;

      IF p_old_RepSchedule_rec.material_variance_account <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.material_variance_account := p_old_RepSchedule_rec.material_variance_account;
      END IF;

      IF p_old_RepSchedule_rec.organization_id <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.organization_id := p_old_RepSchedule_rec.organization_id;
      END IF;

      IF p_old_RepSchedule_rec.osp_account <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.osp_account := p_old_RepSchedule_rec.osp_account;
      END IF;

      IF p_old_RepSchedule_rec.osp_variance_account <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.osp_variance_account := p_old_RepSchedule_rec.osp_variance_account;
      END IF;

      IF p_old_RepSchedule_rec.overhead_account <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.overhead_account := p_old_RepSchedule_rec.overhead_account;
      END IF;

      IF p_old_RepSchedule_rec.overhead_variance_account <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.overhead_variance_account := p_old_RepSchedule_rec.overhead_variance_account;
      END IF;

      IF p_old_RepSchedule_rec.processing_work_days <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.processing_work_days := p_old_RepSchedule_rec.processing_work_days;
      END IF;

      IF p_old_RepSchedule_rec.program_application_id <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.program_application_id := p_old_RepSchedule_rec.program_application_id;
      END IF;

      IF p_old_RepSchedule_rec.program_id <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.program_id := p_old_RepSchedule_rec.program_id;
      END IF;

      IF p_old_RepSchedule_rec.program_update_date <> FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.program_update_date := p_old_RepSchedule_rec.program_update_date;
      END IF;

      IF p_old_RepSchedule_rec.quantity_completed <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.quantity_completed := p_old_RepSchedule_rec.quantity_completed;
      END IF;

      IF p_old_RepSchedule_rec.repetitive_schedule_id <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.repetitive_schedule_id := p_old_RepSchedule_rec.repetitive_schedule_id;
      END IF;

      IF p_old_RepSchedule_rec.request_id <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.request_id := p_old_RepSchedule_rec.request_id;
      END IF;

      IF p_old_RepSchedule_rec.resource_account <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.resource_account := p_old_RepSchedule_rec.resource_account;
      END IF;

      IF p_old_RepSchedule_rec.resource_variance_account <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.resource_variance_account := p_old_RepSchedule_rec.resource_variance_account;
      END IF;

      IF p_old_RepSchedule_rec.routing_revision <> FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.routing_revision := p_old_RepSchedule_rec.routing_revision;
      END IF;

      IF p_old_RepSchedule_rec.routing_revision_date <> FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.routing_revision_date := p_old_RepSchedule_rec.routing_revision_date;
      END IF;

      IF p_old_RepSchedule_rec.status_type <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.status_type := p_old_RepSchedule_rec.status_type;
      END IF;

      IF p_old_RepSchedule_rec.wip_entity_id <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.wip_entity_id := p_old_RepSchedule_rec.wip_entity_id;
      END IF;

      IF p_old_RepSchedule_rec.kanban_card_id <> FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.kanban_card_id := p_old_RepSchedule_rec.kanban_card_id;
      END IF;

    ELSE

      IF l_RepSchedule_rec.alternate_bom_designator = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.alternate_bom_designator := p_old_RepSchedule_rec.alternate_bom_designator;
      END IF;

      IF l_RepSchedule_rec.alternate_rout_designator = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.alternate_rout_designator := p_old_RepSchedule_rec.alternate_rout_designator;
      END IF;

      IF l_RepSchedule_rec.attribute1 = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute1 := p_old_RepSchedule_rec.attribute1;
      END IF;

      IF l_RepSchedule_rec.attribute10 = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute10 := p_old_RepSchedule_rec.attribute10;
      END IF;

      IF l_RepSchedule_rec.attribute11 = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute11 := p_old_RepSchedule_rec.attribute11;
      END IF;

      IF l_RepSchedule_rec.attribute12 = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute12 := p_old_RepSchedule_rec.attribute12;
      END IF;

      IF l_RepSchedule_rec.attribute13 = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute13 := p_old_RepSchedule_rec.attribute13;
      END IF;

      IF l_RepSchedule_rec.attribute14 = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute14 := p_old_RepSchedule_rec.attribute14;
      END IF;

      IF l_RepSchedule_rec.attribute15 = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute15 := p_old_RepSchedule_rec.attribute15;
      END IF;

      IF l_RepSchedule_rec.attribute2 = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute2 := p_old_RepSchedule_rec.attribute2;
      END IF;

      IF l_RepSchedule_rec.attribute3 = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute3 := p_old_RepSchedule_rec.attribute3;
      END IF;

      IF l_RepSchedule_rec.attribute4 = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute4 := p_old_RepSchedule_rec.attribute4;
      END IF;

      IF l_RepSchedule_rec.attribute5 = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute5 := p_old_RepSchedule_rec.attribute5;
      END IF;

      IF l_RepSchedule_rec.attribute6 = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute6 := p_old_RepSchedule_rec.attribute6;
      END IF;

      IF l_RepSchedule_rec.attribute7 = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute7 := p_old_RepSchedule_rec.attribute7;
      END IF;

      IF l_RepSchedule_rec.attribute8 = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute8 := p_old_RepSchedule_rec.attribute8;
      END IF;

      IF l_RepSchedule_rec.attribute9 = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute9 := p_old_RepSchedule_rec.attribute9;
      END IF;

      IF l_RepSchedule_rec.attribute_category = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.attribute_category := p_old_RepSchedule_rec.attribute_category;
      END IF;

      IF l_RepSchedule_rec.bom_revision = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.bom_revision := p_old_RepSchedule_rec.bom_revision;
      END IF;

      IF l_RepSchedule_rec.bom_revision_date = FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.bom_revision_date := p_old_RepSchedule_rec.bom_revision_date;
      END IF;

      IF l_RepSchedule_rec.common_bom_sequence_id = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.common_bom_sequence_id := p_old_RepSchedule_rec.common_bom_sequence_id;
      END IF;

      IF l_RepSchedule_rec.common_rout_sequence_id = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.common_rout_sequence_id := p_old_RepSchedule_rec.common_rout_sequence_id;
      END IF;

      IF l_RepSchedule_rec.created_by = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.created_by := p_old_RepSchedule_rec.created_by;
      END IF;

      IF l_RepSchedule_rec.creation_date = FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.creation_date := p_old_RepSchedule_rec.creation_date;
      END IF;

      IF l_RepSchedule_rec.daily_production_rate = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.daily_production_rate := p_old_RepSchedule_rec.daily_production_rate;
      END IF;

      IF l_RepSchedule_rec.date_closed = FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.date_closed := p_old_RepSchedule_rec.date_closed;
      END IF;

      IF l_RepSchedule_rec.date_released = FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.date_released := p_old_RepSchedule_rec.date_released;
      END IF;

      IF l_RepSchedule_rec.demand_class = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.demand_class := p_old_RepSchedule_rec.demand_class;
      END IF;

      IF l_RepSchedule_rec.description = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.description := p_old_RepSchedule_rec.description;
      END IF;

      IF l_RepSchedule_rec.firm_planned_flag = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.firm_planned_flag := p_old_RepSchedule_rec.firm_planned_flag;
      END IF;

      IF l_RepSchedule_rec.first_unit_cpl_date = FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.first_unit_cpl_date := p_old_RepSchedule_rec.first_unit_cpl_date;
      END IF;

      IF l_RepSchedule_rec.first_unit_start_date = FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.first_unit_start_date := p_old_RepSchedule_rec.first_unit_start_date;
      END IF;

      IF l_RepSchedule_rec.last_unit_cpl_date = FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.last_unit_cpl_date := p_old_RepSchedule_rec.last_unit_cpl_date;
      END IF;

      IF l_RepSchedule_rec.last_unit_start_date = FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.last_unit_start_date := p_old_RepSchedule_rec.last_unit_start_date;
      END IF;

      IF l_RepSchedule_rec.last_updated_by = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.last_updated_by := p_old_RepSchedule_rec.last_updated_by;
      END IF;

      IF l_RepSchedule_rec.last_update_date = FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.last_update_date := p_old_RepSchedule_rec.last_update_date;
      END IF;

      IF l_RepSchedule_rec.last_update_login = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.last_update_login := p_old_RepSchedule_rec.last_update_login;
      END IF;

      IF l_RepSchedule_rec.line_id = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.line_id := p_old_RepSchedule_rec.line_id;
      END IF;

      IF l_RepSchedule_rec.material_account = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.material_account := p_old_RepSchedule_rec.material_account;
      END IF;

      IF l_RepSchedule_rec.material_overhead_account = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.material_overhead_account := p_old_RepSchedule_rec.material_overhead_account;
      END IF;

      IF l_RepSchedule_rec.material_variance_account = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.material_variance_account := p_old_RepSchedule_rec.material_variance_account;
      END IF;

      IF l_RepSchedule_rec.organization_id = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.organization_id := p_old_RepSchedule_rec.organization_id;
      END IF;

      IF l_RepSchedule_rec.osp_account = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.osp_account := p_old_RepSchedule_rec.osp_account;
      END IF;

      IF l_RepSchedule_rec.osp_variance_account = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.osp_variance_account := p_old_RepSchedule_rec.osp_variance_account;
      END IF;

      IF l_RepSchedule_rec.overhead_account = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.overhead_account := p_old_RepSchedule_rec.overhead_account;
      END IF;

      IF l_RepSchedule_rec.overhead_variance_account = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.overhead_variance_account := p_old_RepSchedule_rec.overhead_variance_account;
      END IF;

      IF l_RepSchedule_rec.processing_work_days = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.processing_work_days := p_old_RepSchedule_rec.processing_work_days;
      END IF;

      IF l_RepSchedule_rec.program_application_id = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.program_application_id := p_old_RepSchedule_rec.program_application_id;
      END IF;

      IF l_RepSchedule_rec.program_id = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.program_id := p_old_RepSchedule_rec.program_id;
      END IF;

      IF l_RepSchedule_rec.program_update_date = FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.program_update_date := p_old_RepSchedule_rec.program_update_date;
      END IF;

      IF l_RepSchedule_rec.quantity_completed = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.quantity_completed := p_old_RepSchedule_rec.quantity_completed;
      END IF;

      IF l_RepSchedule_rec.repetitive_schedule_id = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.repetitive_schedule_id := p_old_RepSchedule_rec.repetitive_schedule_id;
      END IF;

      IF l_RepSchedule_rec.request_id = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.request_id := p_old_RepSchedule_rec.request_id;
      END IF;

      IF l_RepSchedule_rec.resource_account = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.resource_account := p_old_RepSchedule_rec.resource_account;
      END IF;

      IF l_RepSchedule_rec.resource_variance_account = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.resource_variance_account := p_old_RepSchedule_rec.resource_variance_account;
      END IF;

      IF l_RepSchedule_rec.routing_revision = FND_API.G_MISS_CHAR THEN
	 l_RepSchedule_rec.routing_revision := p_old_RepSchedule_rec.routing_revision;
      END IF;

      IF l_RepSchedule_rec.routing_revision_date = FND_API.G_MISS_DATE THEN
	 l_RepSchedule_rec.routing_revision_date := p_old_RepSchedule_rec.routing_revision_date;
      END IF;

      IF l_RepSchedule_rec.status_type = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.status_type := p_old_RepSchedule_rec.status_type;
      END IF;

      IF l_RepSchedule_rec.wip_entity_id = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.wip_entity_id := p_old_RepSchedule_rec.wip_entity_id;
      END IF;

      IF l_RepSchedule_rec.kanban_card_id = FND_API.G_MISS_NUM THEN
	 l_RepSchedule_rec.kanban_card_id := p_old_RepSchedule_rec.kanban_card_id;
      END IF;
   END IF;
 END IF;
    RETURN l_RepSchedule_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_RepSchedule_rec               IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
) RETURN WIP_Work_Order_PUB.Repschedule_Rec_Type
IS
l_RepSchedule_rec             WIP_Work_Order_PUB.Repschedule_Rec_Type := p_RepSchedule_rec;
BEGIN

    IF l_RepSchedule_rec.alternate_bom_designator = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.alternate_bom_designator := NULL;
    END IF;

    IF l_RepSchedule_rec.alternate_rout_designator = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.alternate_rout_designator := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute1 := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute10 := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute11 := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute12 := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute13 := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute14 := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute15 := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute2 := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute3 := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute4 := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute5 := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute6 := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute7 := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute8 := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute9 := NULL;
    END IF;

    IF l_RepSchedule_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.attribute_category := NULL;
    END IF;

    IF l_RepSchedule_rec.bom_revision = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.bom_revision := NULL;
    END IF;

    IF l_RepSchedule_rec.bom_revision_date = FND_API.G_MISS_DATE THEN
        l_RepSchedule_rec.bom_revision_date := NULL;
    END IF;

    IF l_RepSchedule_rec.common_bom_sequence_id = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.common_bom_sequence_id := NULL;
    END IF;

    IF l_RepSchedule_rec.common_rout_sequence_id = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.common_rout_sequence_id := NULL;
    END IF;

    IF l_RepSchedule_rec.created_by = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.created_by := NULL;
    END IF;

    IF l_RepSchedule_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_RepSchedule_rec.creation_date := NULL;
    END IF;

    IF l_RepSchedule_rec.daily_production_rate = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.daily_production_rate := NULL;
    END IF;

    IF l_RepSchedule_rec.date_closed = FND_API.G_MISS_DATE THEN
        l_RepSchedule_rec.date_closed := NULL;
    END IF;

    IF l_RepSchedule_rec.date_released = FND_API.G_MISS_DATE THEN
        l_RepSchedule_rec.date_released := NULL;
    END IF;

    IF l_RepSchedule_rec.demand_class = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.demand_class := NULL;
    END IF;

    IF l_RepSchedule_rec.description = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.description := NULL;
    END IF;

    IF l_RepSchedule_rec.firm_planned_flag = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.firm_planned_flag := NULL;
    END IF;

    IF l_RepSchedule_rec.first_unit_cpl_date = FND_API.G_MISS_DATE THEN
        l_RepSchedule_rec.first_unit_cpl_date := NULL;
    END IF;

    IF l_RepSchedule_rec.first_unit_start_date = FND_API.G_MISS_DATE THEN
        l_RepSchedule_rec.first_unit_start_date := NULL;
    END IF;

    IF l_RepSchedule_rec.last_unit_cpl_date = FND_API.G_MISS_DATE THEN
        l_RepSchedule_rec.last_unit_cpl_date := NULL;
    END IF;

    IF l_RepSchedule_rec.last_unit_start_date = FND_API.G_MISS_DATE THEN
        l_RepSchedule_rec.last_unit_start_date := NULL;
    END IF;

    IF l_RepSchedule_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.last_updated_by := NULL;
    END IF;

    IF l_RepSchedule_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_RepSchedule_rec.last_update_date := NULL;
    END IF;

    IF l_RepSchedule_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.last_update_login := NULL;
    END IF;

    IF l_RepSchedule_rec.line_id = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.line_id := NULL;
    END IF;

    IF l_RepSchedule_rec.material_account = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.material_account := NULL;
    END IF;

    IF l_RepSchedule_rec.material_overhead_account = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.material_overhead_account := NULL;
    END IF;

    IF l_RepSchedule_rec.material_variance_account = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.material_variance_account := NULL;
    END IF;

    IF l_RepSchedule_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.organization_id := NULL;
    END IF;

    IF l_RepSchedule_rec.osp_account = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.osp_account := NULL;
    END IF;

    IF l_RepSchedule_rec.osp_variance_account = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.osp_variance_account := NULL;
    END IF;

    IF l_RepSchedule_rec.overhead_account = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.overhead_account := NULL;
    END IF;

    IF l_RepSchedule_rec.overhead_variance_account = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.overhead_variance_account := NULL;
    END IF;

    IF l_RepSchedule_rec.processing_work_days = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.processing_work_days := NULL;
    END IF;

    IF l_RepSchedule_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.program_application_id := NULL;
    END IF;

    IF l_RepSchedule_rec.program_id = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.program_id := NULL;
    END IF;

    IF l_RepSchedule_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_RepSchedule_rec.program_update_date := NULL;
    END IF;

    IF l_RepSchedule_rec.quantity_completed = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.quantity_completed := NULL;
    END IF;

    IF l_RepSchedule_rec.repetitive_schedule_id = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.repetitive_schedule_id := NULL;
    END IF;

    IF l_RepSchedule_rec.request_id = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.request_id := NULL;
    END IF;

    IF l_RepSchedule_rec.resource_account = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.resource_account := NULL;
    END IF;

    IF l_RepSchedule_rec.resource_variance_account = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.resource_variance_account := NULL;
    END IF;

    IF l_RepSchedule_rec.routing_revision = FND_API.G_MISS_CHAR THEN
        l_RepSchedule_rec.routing_revision := NULL;
    END IF;

    IF l_RepSchedule_rec.routing_revision_date = FND_API.G_MISS_DATE THEN
        l_RepSchedule_rec.routing_revision_date := NULL;
    END IF;

    IF l_RepSchedule_rec.status_type = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.status_type := NULL;
    END IF;

    IF l_RepSchedule_rec.wip_entity_id = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.wip_entity_id := NULL;
    END IF;

    IF l_RepSchedule_rec.kanban_card_id = FND_API.G_MISS_NUM THEN
        l_RepSchedule_rec.kanban_card_id := NULL;
    END IF;

    RETURN l_RepSchedule_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_RepSchedule_rec               IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
)
IS
BEGIN

    UPDATE  WIP_REPETITIVE_SCHEDULES
    SET     ALTERNATE_BOM_DESIGNATOR       = p_RepSchedule_rec.alternate_bom_designator
    ,       ALTERNATE_ROUTING_DESIGNATOR   = p_RepSchedule_rec.alternate_rout_designator
    ,       ATTRIBUTE1                     = p_RepSchedule_rec.attribute1
    ,       ATTRIBUTE10                    = p_RepSchedule_rec.attribute10
    ,       ATTRIBUTE11                    = p_RepSchedule_rec.attribute11
    ,       ATTRIBUTE12                    = p_RepSchedule_rec.attribute12
    ,       ATTRIBUTE13                    = p_RepSchedule_rec.attribute13
    ,       ATTRIBUTE14                    = p_RepSchedule_rec.attribute14
    ,       ATTRIBUTE15                    = p_RepSchedule_rec.attribute15
    ,       ATTRIBUTE2                     = p_RepSchedule_rec.attribute2
    ,       ATTRIBUTE3                     = p_RepSchedule_rec.attribute3
    ,       ATTRIBUTE4                     = p_RepSchedule_rec.attribute4
    ,       ATTRIBUTE5                     = p_RepSchedule_rec.attribute5
    ,       ATTRIBUTE6                     = p_RepSchedule_rec.attribute6
    ,       ATTRIBUTE7                     = p_RepSchedule_rec.attribute7
    ,       ATTRIBUTE8                     = p_RepSchedule_rec.attribute8
    ,       ATTRIBUTE9                     = p_RepSchedule_rec.attribute9
    ,       ATTRIBUTE_CATEGORY             = p_RepSchedule_rec.attribute_category
    ,       BOM_REVISION                   = p_RepSchedule_rec.bom_revision
    ,       BOM_REVISION_DATE              = p_RepSchedule_rec.bom_revision_date
    ,       COMMON_BOM_SEQUENCE_ID         = p_RepSchedule_rec.common_bom_sequence_id
    ,       COMMON_ROUTING_SEQUENCE_ID     = p_RepSchedule_rec.common_rout_sequence_id
    ,       CREATED_BY                     = p_RepSchedule_rec.created_by
    ,       CREATION_DATE                  = p_RepSchedule_rec.creation_date
    ,       DAILY_PRODUCTION_RATE          = p_RepSchedule_rec.daily_production_rate
    ,       DATE_CLOSED                    = p_RepSchedule_rec.date_closed
    ,       DATE_RELEASED                  = p_RepSchedule_rec.date_released
    ,       DEMAND_CLASS                   = p_RepSchedule_rec.demand_class
    ,       DESCRIPTION                    = p_RepSchedule_rec.description
    ,       FIRM_PLANNED_FLAG              = p_RepSchedule_rec.firm_planned_flag
    ,       FIRST_UNIT_COMPLETION_DATE     = p_RepSchedule_rec.first_unit_cpl_date
    ,       FIRST_UNIT_START_DATE          = p_RepSchedule_rec.first_unit_start_date
    ,       LAST_UNIT_COMPLETION_DATE      = p_RepSchedule_rec.last_unit_cpl_date
    ,       LAST_UNIT_START_DATE           = p_RepSchedule_rec.last_unit_start_date
    ,       LAST_UPDATED_BY                = p_RepSchedule_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_RepSchedule_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_RepSchedule_rec.last_update_login
    ,       LINE_ID                        = p_RepSchedule_rec.line_id
    ,       MATERIAL_ACCOUNT               = p_RepSchedule_rec.material_account
    ,       MATERIAL_OVERHEAD_ACCOUNT      = p_RepSchedule_rec.material_overhead_account
    ,       MATERIAL_VARIANCE_ACCOUNT      = p_RepSchedule_rec.material_variance_account
    ,       ORGANIZATION_ID                = p_RepSchedule_rec.organization_id
    ,       OUTSIDE_PROCESSING_ACCOUNT     = p_RepSchedule_rec.osp_account
    ,       OUTSIDE_PROC_VARIANCE_ACCOUNT  = p_RepSchedule_rec.osp_variance_account
    ,       OVERHEAD_ACCOUNT               = p_RepSchedule_rec.overhead_account
    ,       OVERHEAD_VARIANCE_ACCOUNT      = p_RepSchedule_rec.overhead_variance_account
    ,       PROCESSING_WORK_DAYS           = p_RepSchedule_rec.processing_work_days
    ,       PROGRAM_APPLICATION_ID         = p_RepSchedule_rec.program_application_id
    ,       PROGRAM_ID                     = p_RepSchedule_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_RepSchedule_rec.program_update_date
    ,       QUANTITY_COMPLETED             = p_RepSchedule_rec.quantity_completed
    ,       REPETITIVE_SCHEDULE_ID         = p_RepSchedule_rec.repetitive_schedule_id
    ,       REQUEST_ID                     = p_RepSchedule_rec.request_id
    ,       RESOURCE_ACCOUNT               = p_RepSchedule_rec.resource_account
    ,       RESOURCE_VARIANCE_ACCOUNT      = p_RepSchedule_rec.resource_variance_account
    ,       ROUTING_REVISION               = p_RepSchedule_rec.routing_revision
    ,       ROUTING_REVISION_DATE          = p_RepSchedule_rec.routing_revision_date
    ,       STATUS_TYPE                    = p_RepSchedule_rec.status_type
    ,       WIP_ENTITY_ID                  = p_RepSchedule_rec.wip_entity_id
    WHERE   REPETITIVE_SCHEDULE_ID = p_RepSchedule_rec.repetitive_schedule_id
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
(   p_RepSchedule_rec               IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
)
IS
BEGIN

    INSERT  INTO WIP_REPETITIVE_SCHEDULES
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
    ,       COMMON_BOM_SEQUENCE_ID
    ,       COMMON_ROUTING_SEQUENCE_ID
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DAILY_PRODUCTION_RATE
    ,       DATE_CLOSED
    ,       DATE_RELEASED
    ,       DEMAND_CLASS
    ,       DESCRIPTION
    ,       FIRM_PLANNED_FLAG
    ,       FIRST_UNIT_COMPLETION_DATE
    ,       FIRST_UNIT_START_DATE
    ,       LAST_UNIT_COMPLETION_DATE
    ,       LAST_UNIT_START_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       MATERIAL_ACCOUNT
    ,       MATERIAL_OVERHEAD_ACCOUNT
    ,       MATERIAL_VARIANCE_ACCOUNT
    ,       ORGANIZATION_ID
    ,       OUTSIDE_PROCESSING_ACCOUNT
    ,       OUTSIDE_PROC_VARIANCE_ACCOUNT
    ,       OVERHEAD_ACCOUNT
    ,       OVERHEAD_VARIANCE_ACCOUNT
    ,       PROCESSING_WORK_DAYS
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUANTITY_COMPLETED
    ,       REPETITIVE_SCHEDULE_ID
    ,       REQUEST_ID
    ,       RESOURCE_ACCOUNT
    ,       RESOURCE_VARIANCE_ACCOUNT
    ,       ROUTING_REVISION
    ,       ROUTING_REVISION_DATE
    ,       STATUS_TYPE
    ,       WIP_ENTITY_ID
    )
    VALUES
    (       p_RepSchedule_rec.alternate_bom_designator
    ,       p_RepSchedule_rec.alternate_rout_designator
    ,       p_RepSchedule_rec.attribute1
    ,       p_RepSchedule_rec.attribute10
    ,       p_RepSchedule_rec.attribute11
    ,       p_RepSchedule_rec.attribute12
    ,       p_RepSchedule_rec.attribute13
    ,       p_RepSchedule_rec.attribute14
    ,       p_RepSchedule_rec.attribute15
    ,       p_RepSchedule_rec.attribute2
    ,       p_RepSchedule_rec.attribute3
    ,       p_RepSchedule_rec.attribute4
    ,       p_RepSchedule_rec.attribute5
    ,       p_RepSchedule_rec.attribute6
    ,       p_RepSchedule_rec.attribute7
    ,       p_RepSchedule_rec.attribute8
    ,       p_RepSchedule_rec.attribute9
    ,       p_RepSchedule_rec.attribute_category
    ,       p_RepSchedule_rec.bom_revision
    ,       p_RepSchedule_rec.bom_revision_date
    ,       p_RepSchedule_rec.common_bom_sequence_id
    ,       p_RepSchedule_rec.common_rout_sequence_id
    ,       p_RepSchedule_rec.created_by
    ,       p_RepSchedule_rec.creation_date
    ,       p_RepSchedule_rec.daily_production_rate
    ,       p_RepSchedule_rec.date_closed
    ,       p_RepSchedule_rec.date_released
    ,       p_RepSchedule_rec.demand_class
    ,       p_RepSchedule_rec.description
    ,       p_RepSchedule_rec.firm_planned_flag
    ,       p_RepSchedule_rec.first_unit_cpl_date
    ,       p_RepSchedule_rec.first_unit_start_date
    ,       p_RepSchedule_rec.last_unit_cpl_date
    ,       p_RepSchedule_rec.last_unit_start_date
    ,       p_RepSchedule_rec.last_updated_by
    ,       p_RepSchedule_rec.last_update_date
    ,       p_RepSchedule_rec.last_update_login
    ,       p_RepSchedule_rec.line_id
    ,       p_RepSchedule_rec.material_account
    ,       p_RepSchedule_rec.material_overhead_account
    ,       p_RepSchedule_rec.material_variance_account
    ,       p_RepSchedule_rec.organization_id
    ,       p_RepSchedule_rec.osp_account
    ,       p_RepSchedule_rec.osp_variance_account
    ,       p_RepSchedule_rec.overhead_account
    ,       p_RepSchedule_rec.overhead_variance_account
    ,       p_RepSchedule_rec.processing_work_days
    ,       p_RepSchedule_rec.program_application_id
    ,       p_RepSchedule_rec.program_id
    ,       p_RepSchedule_rec.program_update_date
    ,       p_RepSchedule_rec.quantity_completed
    ,       p_RepSchedule_rec.repetitive_schedule_id
    ,       p_RepSchedule_rec.request_id
    ,       p_RepSchedule_rec.resource_account
    ,       p_RepSchedule_rec.resource_variance_account
    ,       p_RepSchedule_rec.routing_revision
    ,       p_RepSchedule_rec.routing_revision_date
    ,       p_RepSchedule_rec.status_type
    ,       p_RepSchedule_rec.wip_entity_id
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
(   p_repetitive_schedule_id        IN  NUMBER
)
IS
BEGIN

    DELETE  FROM WIP_REPETITIVE_SCHEDULES
    WHERE   REPETITIVE_SCHEDULE_ID = p_repetitive_schedule_id
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
(   p_repetitive_schedule_id        IN  NUMBER
) RETURN WIP_Work_Order_PUB.Repschedule_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_repetitive_schedule_id      => p_repetitive_schedule_id
        )(1);

END Query_Row;

FUNCTION Query_Row
(   p_wip_entity_id        IN  NUMBER
) RETURN WIP_Work_Order_PUB.Repschedule_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_wip_entity_id      => p_wip_entity_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_repetitive_schedule_id        IN  NUMBER :=
                                        NULL
,   p_wip_entity_id                 IN  NUMBER :=
                                        NULL
) RETURN WIP_Work_Order_PUB.Repschedule_Tbl_Type
IS
l_RepSchedule_rec             WIP_Work_Order_PUB.Repschedule_Rec_Type;
l_RepSchedule_tbl             WIP_Work_Order_PUB.Repschedule_Tbl_Type;

CURSOR l_RepSchedule_csr IS
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
    ,       COMMON_BOM_SEQUENCE_ID
    ,       COMMON_ROUTING_SEQUENCE_ID
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DAILY_PRODUCTION_RATE
    ,       DATE_CLOSED
    ,       DATE_RELEASED
    ,       DEMAND_CLASS
    ,       DESCRIPTION
    ,       FIRM_PLANNED_FLAG
    ,       FIRST_UNIT_COMPLETION_DATE
    ,       FIRST_UNIT_START_DATE
    ,       LAST_UNIT_COMPLETION_DATE
    ,       LAST_UNIT_START_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       MATERIAL_ACCOUNT
    ,       MATERIAL_OVERHEAD_ACCOUNT
    ,       MATERIAL_VARIANCE_ACCOUNT
    ,       ORGANIZATION_ID
    ,       OUTSIDE_PROCESSING_ACCOUNT
    ,       OUTSIDE_PROC_VARIANCE_ACCOUNT
    ,       OVERHEAD_ACCOUNT
    ,       OVERHEAD_VARIANCE_ACCOUNT
    ,       PROCESSING_WORK_DAYS
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUANTITY_COMPLETED
    ,       REPETITIVE_SCHEDULE_ID
    ,       REQUEST_ID
    ,       RESOURCE_ACCOUNT
    ,       RESOURCE_VARIANCE_ACCOUNT
    ,       ROUTING_REVISION
    ,       ROUTING_REVISION_DATE
    ,       STATUS_TYPE
    ,       WIP_ENTITY_ID
    FROM    WIP_REPETITIVE_SCHEDULES
    WHERE ( REPETITIVE_SCHEDULE_ID = nvl(p_repetitive_schedule_id,FND_API.G_MISS_NUM)
    )
    OR (    WIP_ENTITY_ID = nvl(p_wip_entity_id,FND_API.G_MISS_NUM)
    );

BEGIN

    IF
    (p_repetitive_schedule_id IS NOT NULL
     AND
     p_repetitive_schedule_id <> FND_API.G_MISS_NUM)
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
                ,   'Keys are mutually exclusive: repetitive_schedule_id = '|| p_repetitive_schedule_id || ', wip_entity_id = '|| p_wip_entity_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_RepSchedule_csr LOOP

        l_RepSchedule_rec.alternate_bom_designator := l_implicit_rec.ALTERNATE_BOM_DESIGNATOR;
        l_RepSchedule_rec.alternate_rout_designator := l_implicit_rec.ALTERNATE_ROUTING_DESIGNATOR;
        l_RepSchedule_rec.attribute1   := l_implicit_rec.ATTRIBUTE1;
        l_RepSchedule_rec.attribute10  := l_implicit_rec.ATTRIBUTE10;
        l_RepSchedule_rec.attribute11  := l_implicit_rec.ATTRIBUTE11;
        l_RepSchedule_rec.attribute12  := l_implicit_rec.ATTRIBUTE12;
        l_RepSchedule_rec.attribute13  := l_implicit_rec.ATTRIBUTE13;
        l_RepSchedule_rec.attribute14  := l_implicit_rec.ATTRIBUTE14;
        l_RepSchedule_rec.attribute15  := l_implicit_rec.ATTRIBUTE15;
        l_RepSchedule_rec.attribute2   := l_implicit_rec.ATTRIBUTE2;
        l_RepSchedule_rec.attribute3   := l_implicit_rec.ATTRIBUTE3;
        l_RepSchedule_rec.attribute4   := l_implicit_rec.ATTRIBUTE4;
        l_RepSchedule_rec.attribute5   := l_implicit_rec.ATTRIBUTE5;
        l_RepSchedule_rec.attribute6   := l_implicit_rec.ATTRIBUTE6;
        l_RepSchedule_rec.attribute7   := l_implicit_rec.ATTRIBUTE7;
        l_RepSchedule_rec.attribute8   := l_implicit_rec.ATTRIBUTE8;
        l_RepSchedule_rec.attribute9   := l_implicit_rec.ATTRIBUTE9;
        l_RepSchedule_rec.attribute_category := l_implicit_rec.ATTRIBUTE_CATEGORY;
        l_RepSchedule_rec.bom_revision := l_implicit_rec.BOM_REVISION;
        l_RepSchedule_rec.bom_revision_date := l_implicit_rec.BOM_REVISION_DATE;
        l_RepSchedule_rec.common_bom_sequence_id := l_implicit_rec.COMMON_BOM_SEQUENCE_ID;
        l_RepSchedule_rec.common_rout_sequence_id := l_implicit_rec.COMMON_ROUTING_SEQUENCE_ID;
        l_RepSchedule_rec.created_by   := l_implicit_rec.CREATED_BY;
        l_RepSchedule_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_RepSchedule_rec.daily_production_rate := l_implicit_rec.DAILY_PRODUCTION_RATE;
        l_RepSchedule_rec.date_closed  := l_implicit_rec.DATE_CLOSED;
        l_RepSchedule_rec.date_released := l_implicit_rec.DATE_RELEASED;
        l_RepSchedule_rec.demand_class := l_implicit_rec.DEMAND_CLASS;
        l_RepSchedule_rec.description  := l_implicit_rec.DESCRIPTION;
        l_RepSchedule_rec.firm_planned_flag := l_implicit_rec.FIRM_PLANNED_FLAG;
        l_RepSchedule_rec.first_unit_cpl_date := l_implicit_rec.FIRST_UNIT_COMPLETION_DATE;
        l_RepSchedule_rec.first_unit_start_date := l_implicit_rec.FIRST_UNIT_START_DATE;
        l_RepSchedule_rec.last_unit_cpl_date := l_implicit_rec.LAST_UNIT_COMPLETION_DATE;
        l_RepSchedule_rec.last_unit_start_date := l_implicit_rec.LAST_UNIT_START_DATE;
        l_RepSchedule_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_RepSchedule_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_RepSchedule_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_RepSchedule_rec.line_id      := l_implicit_rec.LINE_ID;
        l_RepSchedule_rec.material_account := l_implicit_rec.MATERIAL_ACCOUNT;
        l_RepSchedule_rec.material_overhead_account := l_implicit_rec.MATERIAL_OVERHEAD_ACCOUNT;
        l_RepSchedule_rec.material_variance_account := l_implicit_rec.MATERIAL_VARIANCE_ACCOUNT;
        l_RepSchedule_rec.organization_id := l_implicit_rec.ORGANIZATION_ID;
        l_RepSchedule_rec.osp_account  := l_implicit_rec.OUTSIDE_PROCESSING_ACCOUNT;
        l_RepSchedule_rec.osp_variance_account := l_implicit_rec.OUTSIDE_PROC_VARIANCE_ACCOUNT;
        l_RepSchedule_rec.overhead_account := l_implicit_rec.OVERHEAD_ACCOUNT;
        l_RepSchedule_rec.overhead_variance_account := l_implicit_rec.OVERHEAD_VARIANCE_ACCOUNT;
        l_RepSchedule_rec.processing_work_days := l_implicit_rec.PROCESSING_WORK_DAYS;
        l_RepSchedule_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_RepSchedule_rec.program_id   := l_implicit_rec.PROGRAM_ID;
        l_RepSchedule_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_RepSchedule_rec.quantity_completed := l_implicit_rec.QUANTITY_COMPLETED;
        l_RepSchedule_rec.repetitive_schedule_id := l_implicit_rec.REPETITIVE_SCHEDULE_ID;
        l_RepSchedule_rec.request_id   := l_implicit_rec.REQUEST_ID;
        l_RepSchedule_rec.resource_account := l_implicit_rec.RESOURCE_ACCOUNT;
        l_RepSchedule_rec.resource_variance_account := l_implicit_rec.RESOURCE_VARIANCE_ACCOUNT;
        l_RepSchedule_rec.routing_revision := l_implicit_rec.ROUTING_REVISION;
        l_RepSchedule_rec.routing_revision_date := l_implicit_rec.ROUTING_REVISION_DATE;
        l_RepSchedule_rec.status_type  := l_implicit_rec.STATUS_TYPE;
        l_RepSchedule_rec.wip_entity_id := l_implicit_rec.WIP_ENTITY_ID;

        l_RepSchedule_tbl(l_RepSchedule_tbl.COUNT + 1) := l_RepSchedule_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_repetitive_schedule_id IS NOT NULL
     AND
     p_repetitive_schedule_id <> FND_API.G_MISS_NUM)
    AND
    (l_RepSchedule_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_RepSchedule_tbl;

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
,   p_RepSchedule_rec               IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
,   x_RepSchedule_rec               OUT NOCOPY WIP_Work_Order_PUB.Repschedule_Rec_Type
)
IS
l_RepSchedule_rec             WIP_Work_Order_PUB.Repschedule_Rec_Type;
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
    ,       COMMON_BOM_SEQUENCE_ID
    ,       COMMON_ROUTING_SEQUENCE_ID
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DAILY_PRODUCTION_RATE
    ,       DATE_CLOSED
    ,       DATE_RELEASED
    ,       DEMAND_CLASS
    ,       DESCRIPTION
    ,       FIRM_PLANNED_FLAG
    ,       FIRST_UNIT_COMPLETION_DATE
    ,       FIRST_UNIT_START_DATE
    ,       LAST_UNIT_COMPLETION_DATE
    ,       LAST_UNIT_START_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       MATERIAL_ACCOUNT
    ,       MATERIAL_OVERHEAD_ACCOUNT
    ,       MATERIAL_VARIANCE_ACCOUNT
    ,       ORGANIZATION_ID
    ,       OUTSIDE_PROCESSING_ACCOUNT
    ,       OUTSIDE_PROC_VARIANCE_ACCOUNT
    ,       OVERHEAD_ACCOUNT
    ,       OVERHEAD_VARIANCE_ACCOUNT
    ,       PROCESSING_WORK_DAYS
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUANTITY_COMPLETED
    ,       REPETITIVE_SCHEDULE_ID
    ,       REQUEST_ID
    ,       RESOURCE_ACCOUNT
    ,       RESOURCE_VARIANCE_ACCOUNT
    ,       ROUTING_REVISION
    ,       ROUTING_REVISION_DATE
    ,       STATUS_TYPE
    ,       WIP_ENTITY_ID
    INTO    l_RepSchedule_rec.alternate_bom_designator
    ,       l_RepSchedule_rec.alternate_rout_designator
    ,       l_RepSchedule_rec.attribute1
    ,       l_RepSchedule_rec.attribute10
    ,       l_RepSchedule_rec.attribute11
    ,       l_RepSchedule_rec.attribute12
    ,       l_RepSchedule_rec.attribute13
    ,       l_RepSchedule_rec.attribute14
    ,       l_RepSchedule_rec.attribute15
    ,       l_RepSchedule_rec.attribute2
    ,       l_RepSchedule_rec.attribute3
    ,       l_RepSchedule_rec.attribute4
    ,       l_RepSchedule_rec.attribute5
    ,       l_RepSchedule_rec.attribute6
    ,       l_RepSchedule_rec.attribute7
    ,       l_RepSchedule_rec.attribute8
    ,       l_RepSchedule_rec.attribute9
    ,       l_RepSchedule_rec.attribute_category
    ,       l_RepSchedule_rec.bom_revision
    ,       l_RepSchedule_rec.bom_revision_date
    ,       l_RepSchedule_rec.common_bom_sequence_id
    ,       l_RepSchedule_rec.common_rout_sequence_id
    ,       l_RepSchedule_rec.created_by
    ,       l_RepSchedule_rec.creation_date
    ,       l_RepSchedule_rec.daily_production_rate
    ,       l_RepSchedule_rec.date_closed
    ,       l_RepSchedule_rec.date_released
    ,       l_RepSchedule_rec.demand_class
    ,       l_RepSchedule_rec.description
    ,       l_RepSchedule_rec.firm_planned_flag
    ,       l_RepSchedule_rec.first_unit_cpl_date
    ,       l_RepSchedule_rec.first_unit_start_date
    ,       l_RepSchedule_rec.last_unit_cpl_date
    ,       l_RepSchedule_rec.last_unit_start_date
    ,       l_RepSchedule_rec.last_updated_by
    ,       l_RepSchedule_rec.last_update_date
    ,       l_RepSchedule_rec.last_update_login
    ,       l_RepSchedule_rec.line_id
    ,       l_RepSchedule_rec.material_account
    ,       l_RepSchedule_rec.material_overhead_account
    ,       l_RepSchedule_rec.material_variance_account
    ,       l_RepSchedule_rec.organization_id
    ,       l_RepSchedule_rec.osp_account
    ,       l_RepSchedule_rec.osp_variance_account
    ,       l_RepSchedule_rec.overhead_account
    ,       l_RepSchedule_rec.overhead_variance_account
    ,       l_RepSchedule_rec.processing_work_days
    ,       l_RepSchedule_rec.program_application_id
    ,       l_RepSchedule_rec.program_id
    ,       l_RepSchedule_rec.program_update_date
    ,       l_RepSchedule_rec.quantity_completed
    ,       l_RepSchedule_rec.repetitive_schedule_id
    ,       l_RepSchedule_rec.request_id
    ,       l_RepSchedule_rec.resource_account
    ,       l_RepSchedule_rec.resource_variance_account
    ,       l_RepSchedule_rec.routing_revision
    ,       l_RepSchedule_rec.routing_revision_date
    ,       l_RepSchedule_rec.status_type
    ,       l_RepSchedule_rec.wip_entity_id
    FROM    WIP_REPETITIVE_SCHEDULES
    WHERE   REPETITIVE_SCHEDULE_ID = p_RepSchedule_rec.repetitive_schedule_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  WIP_GLOBALS.Equal(p_RepSchedule_rec.alternate_bom_designator,
                         l_RepSchedule_rec.alternate_bom_designator)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.alternate_rout_designator,
                         l_RepSchedule_rec.alternate_rout_designator)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute1,
                         l_RepSchedule_rec.attribute1)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute10,
                         l_RepSchedule_rec.attribute10)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute11,
                         l_RepSchedule_rec.attribute11)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute12,
                         l_RepSchedule_rec.attribute12)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute13,
                         l_RepSchedule_rec.attribute13)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute14,
                         l_RepSchedule_rec.attribute14)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute15,
                         l_RepSchedule_rec.attribute15)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute2,
                         l_RepSchedule_rec.attribute2)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute3,
                         l_RepSchedule_rec.attribute3)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute4,
                         l_RepSchedule_rec.attribute4)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute5,
                         l_RepSchedule_rec.attribute5)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute6,
                         l_RepSchedule_rec.attribute6)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute7,
                         l_RepSchedule_rec.attribute7)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute8,
                         l_RepSchedule_rec.attribute8)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute9,
                         l_RepSchedule_rec.attribute9)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.attribute_category,
                         l_RepSchedule_rec.attribute_category)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.bom_revision,
                         l_RepSchedule_rec.bom_revision)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.bom_revision_date,
                         l_RepSchedule_rec.bom_revision_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.common_bom_sequence_id,
                         l_RepSchedule_rec.common_bom_sequence_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.common_rout_sequence_id,
                         l_RepSchedule_rec.common_rout_sequence_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.created_by,
                         l_RepSchedule_rec.created_by)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.creation_date,
                         l_RepSchedule_rec.creation_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.daily_production_rate,
                         l_RepSchedule_rec.daily_production_rate)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.date_closed,
                         l_RepSchedule_rec.date_closed)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.date_released,
                         l_RepSchedule_rec.date_released)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.demand_class,
                         l_RepSchedule_rec.demand_class)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.description,
                         l_RepSchedule_rec.description)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.firm_planned_flag,
                         l_RepSchedule_rec.firm_planned_flag)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.first_unit_cpl_date,
                         l_RepSchedule_rec.first_unit_cpl_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.first_unit_start_date,
                         l_RepSchedule_rec.first_unit_start_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.last_unit_cpl_date,
                         l_RepSchedule_rec.last_unit_cpl_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.last_unit_start_date,
                         l_RepSchedule_rec.last_unit_start_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.last_updated_by,
                         l_RepSchedule_rec.last_updated_by)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.last_update_date,
                         l_RepSchedule_rec.last_update_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.last_update_login,
                         l_RepSchedule_rec.last_update_login)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.line_id,
                         l_RepSchedule_rec.line_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.material_account,
                         l_RepSchedule_rec.material_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.material_overhead_account,
                         l_RepSchedule_rec.material_overhead_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.material_variance_account,
                         l_RepSchedule_rec.material_variance_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.organization_id,
                         l_RepSchedule_rec.organization_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.osp_account,
                         l_RepSchedule_rec.osp_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.osp_variance_account,
                         l_RepSchedule_rec.osp_variance_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.overhead_account,
                         l_RepSchedule_rec.overhead_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.overhead_variance_account,
                         l_RepSchedule_rec.overhead_variance_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.processing_work_days,
                         l_RepSchedule_rec.processing_work_days)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.program_application_id,
                         l_RepSchedule_rec.program_application_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.program_id,
                         l_RepSchedule_rec.program_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.program_update_date,
                         l_RepSchedule_rec.program_update_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.quantity_completed,
                         l_RepSchedule_rec.quantity_completed)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.repetitive_schedule_id,
                         l_RepSchedule_rec.repetitive_schedule_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.request_id,
                         l_RepSchedule_rec.request_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.resource_account,
                         l_RepSchedule_rec.resource_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.resource_variance_account,
                         l_RepSchedule_rec.resource_variance_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.routing_revision,
                         l_RepSchedule_rec.routing_revision)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.routing_revision_date,
                         l_RepSchedule_rec.routing_revision_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.status_type,
                         l_RepSchedule_rec.status_type)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec.wip_entity_id,
                         l_RepSchedule_rec.wip_entity_id)
    THEN

        --  Row has not changed. Set out parameter.

        x_RepSchedule_rec              := l_RepSchedule_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_RepSchedule_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_RepSchedule_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','OE_LOCK_ROW_CHANGED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_RepSchedule_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','OE_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_RepSchedule_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','OE_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_RepSchedule_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;


FUNCTION Compare(p_RepSchedule_rec1    IN  WIP_Work_Order_PUB.Repschedule_Rec_Type,
                 p_RepSchedule_rec2    IN  WIP_Work_Order_PUB.Repschedule_Rec_Type)
  RETURN BOOLEAN
  IS
BEGIN

    IF  WIP_GLOBALS.Equal(p_RepSchedule_rec1.alternate_bom_designator,
                         p_RepSchedule_rec2.alternate_bom_designator)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.alternate_rout_designator,
                         p_RepSchedule_rec2.alternate_rout_designator)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute1,
                         p_RepSchedule_rec2.attribute1)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute10,
                         p_RepSchedule_rec2.attribute10)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute11,
                         p_RepSchedule_rec2.attribute11)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute12,
                         p_RepSchedule_rec2.attribute12)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute13,
                         p_RepSchedule_rec2.attribute13)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute14,
                         p_RepSchedule_rec2.attribute14)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute15,
                         p_RepSchedule_rec2.attribute15)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute2,
                         p_RepSchedule_rec2.attribute2)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute3,
                         p_RepSchedule_rec2.attribute3)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute4,
                         p_RepSchedule_rec2.attribute4)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute5,
                         p_RepSchedule_rec2.attribute5)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute6,
                         p_RepSchedule_rec2.attribute6)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute7,
                         p_RepSchedule_rec2.attribute7)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute8,
                         p_RepSchedule_rec2.attribute8)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute9,
                         p_RepSchedule_rec2.attribute9)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.attribute_category,
                         p_RepSchedule_rec2.attribute_category)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.bom_revision,
                         p_RepSchedule_rec2.bom_revision)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.bom_revision_date,
                         p_RepSchedule_rec2.bom_revision_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.common_bom_sequence_id,
                         p_RepSchedule_rec2.common_bom_sequence_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.common_rout_sequence_id,
                         p_RepSchedule_rec2.common_rout_sequence_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.created_by,
                         p_RepSchedule_rec2.created_by)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.creation_date,
                         p_RepSchedule_rec2.creation_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.daily_production_rate,
                         p_RepSchedule_rec2.daily_production_rate)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.date_closed,
                         p_RepSchedule_rec2.date_closed)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.date_released,
                         p_RepSchedule_rec2.date_released)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.demand_class,
                         p_RepSchedule_rec2.demand_class)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.description,
                         p_RepSchedule_rec2.description)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.firm_planned_flag,
                         p_RepSchedule_rec2.firm_planned_flag)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.first_unit_cpl_date,
                         p_RepSchedule_rec2.first_unit_cpl_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.first_unit_start_date,
                         p_RepSchedule_rec2.first_unit_start_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.last_unit_cpl_date,
                         p_RepSchedule_rec2.last_unit_cpl_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.last_unit_start_date,
                         p_RepSchedule_rec2.last_unit_start_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.last_updated_by,
                         p_RepSchedule_rec2.last_updated_by)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.last_update_date,
                         p_RepSchedule_rec2.last_update_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.last_update_login,
                         p_RepSchedule_rec2.last_update_login)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.line_id,
                         p_RepSchedule_rec2.line_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.material_account,
                         p_RepSchedule_rec2.material_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.material_overhead_account,
                         p_RepSchedule_rec2.material_overhead_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.material_variance_account,
                         p_RepSchedule_rec2.material_variance_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.organization_id,
                         p_RepSchedule_rec2.organization_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.osp_account,
                         p_RepSchedule_rec2.osp_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.osp_variance_account,
                         p_RepSchedule_rec2.osp_variance_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.overhead_account,
                         p_RepSchedule_rec2.overhead_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.overhead_variance_account,
                         p_RepSchedule_rec2.overhead_variance_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.processing_work_days,
                         p_RepSchedule_rec2.processing_work_days)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.program_application_id,
                         p_RepSchedule_rec2.program_application_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.program_id,
                         p_RepSchedule_rec2.program_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.program_update_date,
                         p_RepSchedule_rec2.program_update_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.quantity_completed,
                         p_RepSchedule_rec2.quantity_completed)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.repetitive_schedule_id,
                         p_RepSchedule_rec2.repetitive_schedule_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.request_id,
                         p_RepSchedule_rec2.request_id)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.resource_account,
                         p_RepSchedule_rec2.resource_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.resource_variance_account,
                         p_RepSchedule_rec2.resource_variance_account)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.routing_revision,
                         p_RepSchedule_rec2.routing_revision)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.routing_revision_date,
                         p_RepSchedule_rec2.routing_revision_date)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.status_type,
                         p_RepSchedule_rec2.status_type)
    AND WIP_GLOBALS.Equal(p_RepSchedule_rec1.wip_entity_id,
                         p_RepSchedule_rec2.wip_entity_id)
    THEN
          RETURN TRUE;
     ELSE
       RETURN FALSE;
    END IF;

END Compare;

PROCEDURE dprintf(p_RepSchedule_rec    IN WIP_Work_Order_PUB.RepSchedule_Rec_Type)
  IS
BEGIN

   null;
-- dbms_output.new_line;
-- dbms_output.put_line('Rep Schedule Record:');
-- dbms_output.put_line('-------------------');
-- dbms_output.put_line('daily_production_rate    : ' || To_char(p_RepSchedule_rec.daily_production_rate));
-- dbms_output.put_line('date_closed              : ' || To_char(p_RepSchedule_rec.date_closed,WIP_CONSTANTS.DATE_FMT));
-- dbms_output.put_line('date_released            : ' || To_char(p_RepSchedule_rec.date_released,WIP_CONSTANTS.DATE_FMT));
-- dbms_output.put_line('description              : ' || p_RepSchedule_rec.description);
-- dbms_output.put_line('first_unit_cpl_date      : ' || To_char(p_RepSchedule_rec.first_unit_cpl_date,WIP_CONSTANTS.DATE_FMT));
-- dbms_output.put_line('first_unit_start_date    : ' || To_char(p_RepSchedule_rec.first_unit_start_date,WIP_CONSTANTS.DATE_FMT));
-- dbms_output.put_line('last_unit_cpl_date       : ' || To_char(p_RepSchedule_rec.last_unit_cpl_date,WIP_CONSTANTS.DATE_FMT));
-- dbms_output.put_line('last_unit_start_date     : ' || To_char(p_RepSchedule_rec.last_unit_start_date,WIP_CONSTANTS.DATE_FMT));
-- dbms_output.put_line('line_id                  : ' || To_char(p_RepSchedule_rec.line_id));
-- dbms_output.put_line('organization_id          : ' || To_char(p_RepSchedule_rec.organization_id));
-- dbms_output.put_line('processing_work_days     : ' || To_char(p_RepSchedule_rec.processing_work_days));
-- dbms_output.put_line('quantity_completed       : ' || To_char(p_RepSchedule_rec.quantity_completed));
-- dbms_output.put_line('repetitive_schedule_id   : ' || To_char(p_RepSchedule_rec.repetitive_schedule_id));
-- dbms_output.put_line('status_type              : ' || To_char(p_RepSchedule_rec.status_type));
-- dbms_output.put_line('wip_entity_id            : ' || To_char(p_RepSchedule_rec.wip_entity_id));
-- dbms_output.put_line('kanban_card_id           : ' || To_char(p_RepSchedule_rec.kanban_card_id));
-- dbms_output.put_line('return_status            : ' || p_RepSchedule_rec.return_status);
-- dbms_output.put_line('db_flag                  : ' || p_RepSchedule_rec.db_flag);
-- dbms_output.put_line('action                   : ' || p_RepSchedule_rec.action);
-- dbms_output.put_line('End Rep Schedule Record');

EXCEPTION
   WHEN OTHERS THEN
      NULL;

END dprintf;

END WIP_Repschedule_Util;

/
