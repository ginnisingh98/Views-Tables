--------------------------------------------------------
--  DDL for Package Body MRP_FLOW_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_FLOW_SCHEDULE_PVT" AS
/* $Header: MRPVWFSB.pls 115.6 2003/02/13 23:56:58 yulin ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Flow_Schedule_PVT';

PROCEDURE  PUB_Flow_Sched_Val_Rec_To_PVT (
	p_flow_schedule_Val_rec IN MRP_Flow_Schedule_PUB.Flow_Schedule_Val_Rec_Type  ,
	x_Flow_Schedule_Val_Pvt_Rec OUT NOCOPY Flow_Schedule_Val_Pvt_Rec_Type)
IS
BEGIN

	IF (   p_flow_schedule_Val_rec.Completion_locator   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Val_Pvt_Rec.completion_locator   := NULL;
	ELSE
		x_Flow_Schedule_Val_Pvt_Rec.completion_locator   := nvl(p_flow_schedule_Val_rec.Completion_locator,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (  p_flow_schedule_Val_rec.line   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Val_Pvt_Rec.line :=  NULL;
	ELSE
		x_Flow_Schedule_Val_Pvt_Rec.line := nvl(p_flow_schedule_Val_rec.line,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (  p_flow_schedule_Val_rec.organization = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Val_Pvt_Rec.organization :=  NULL;
	ELSE
		x_Flow_Schedule_Val_Pvt_Rec.organization:= nvl(p_flow_schedule_Val_rec.organization,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (  p_flow_schedule_Val_rec.primary_item = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Val_Pvt_Rec.primary_item :=  NULL;
	ELSE
		x_Flow_Schedule_Val_Pvt_Rec.primary_item := nvl(p_flow_schedule_Val_rec.primary_item,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (  p_flow_schedule_Val_rec.project = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Val_Pvt_Rec.project :=  NULL;
	ELSE
		x_Flow_Schedule_Val_Pvt_Rec.project  := nvl(p_flow_schedule_Val_rec.project,FND_API.G_MISS_CHAR )  ;
	END IF;

	IF (  p_flow_schedule_Val_rec.schedule_group   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Val_Pvt_Rec.schedule_group :=  NULL;
	ELSE
		x_Flow_Schedule_Val_Pvt_Rec.schedule_group := nvl(p_flow_schedule_Val_rec.schedule_group,FND_API.G_MISS_CHAR ) ;
	END IF;

END;

PROCEDURE  PUB_Flow_Sched_Rec_To_PVT (
	p_flow_schedule_rec IN MRP_Flow_Schedule_PUB.Flow_Schedule_Rec_Type  ,
	x_Flow_Schedule_Pvt_Rec OUT NOCOPY Flow_Schedule_Pvt_Rec_Type)
IS
BEGIN

	IF (   p_flow_schedule_rec.alternate_bom_designator   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.alternate_bom_designator   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.alternate_bom_designator   := nvl(p_flow_schedule_rec.alternate_bom_designator,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (   p_flow_schedule_rec.alternate_routing_desig   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.alternate_routing_desig   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.alternate_routing_desig   := nvl(p_flow_schedule_rec.alternate_routing_desig,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (   p_flow_schedule_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute1 := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute1 := nvl(p_flow_schedule_rec.attribute1,FND_API.G_MISS_CHAR )  ;
	END IF;

	IF (   p_flow_schedule_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute10 := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute10 := nvl(p_flow_schedule_rec.attribute10,FND_API.G_MISS_CHAR )  ;
	END IF;

	IF (   p_flow_schedule_rec.attribute11   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute11   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute11   := nvl(p_flow_schedule_rec.attribute11,FND_API.G_MISS_CHAR )    ;
	END IF;

	IF (   p_flow_schedule_rec.attribute12   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute12   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute12   := nvl(p_flow_schedule_rec.attribute12,FND_API.G_MISS_CHAR )    ;
	END IF;

	IF (   p_flow_schedule_rec.attribute13  = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute13  := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute13   := nvl(p_flow_schedule_rec.attribute13,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_rec.attribute14              = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute14  := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute14  := nvl(p_flow_schedule_rec.attribute14,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_rec.attribute15  = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute15  := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute15  := nvl(p_flow_schedule_rec.attribute15,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_rec.attribute2   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute2   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute2   := nvl(p_flow_schedule_rec.attribute2,FND_API.G_MISS_CHAR )    ;
	END IF;

	IF (   p_flow_schedule_rec.attribute3   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute3   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute3   := nvl(p_flow_schedule_rec.attribute3,FND_API.G_MISS_CHAR )    ;
	END IF;

	IF (   p_flow_schedule_rec.attribute4   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute4   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute4   := nvl(p_flow_schedule_rec.attribute4 ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_rec.attribute5   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute5   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute5   := nvl(p_flow_schedule_rec.attribute5 ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_rec.attribute6   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute6   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute6   := nvl(p_flow_schedule_rec.attribute6 ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_rec.attribute7   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute7   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute7   := nvl(p_flow_schedule_rec.attribute7 ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_rec.attribute8   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute8   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute8   := nvl(p_flow_schedule_rec.attribute8 ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_rec.attribute9   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute9   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute9   := nvl(p_flow_schedule_rec.attribute9 ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_rec.attribute_category   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.attribute_category   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.attribute_category   := nvl(p_flow_schedule_rec.attribute_category ,FND_API.G_MISS_CHAR )  ;
	END IF;

	IF (   p_flow_schedule_rec.bom_revision         = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.bom_revision         := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.bom_revision         := nvl(p_flow_schedule_rec.bom_revision ,FND_API.G_MISS_CHAR )        ;
	END IF;

	IF (   p_flow_schedule_rec.bom_revision_date    = FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Pvt_Rec.bom_revision_date    := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.bom_revision_date    := nvl(p_flow_schedule_rec.bom_revision_date,FND_API.G_MISS_DATE )    ;
	END IF;

	IF (   p_flow_schedule_rec.build_sequence      = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.build_sequence      := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.build_sequence      := NVL(p_flow_schedule_rec.build_sequence , FND_API.G_MISS_NUM );
	END IF;

	IF (   p_flow_schedule_rec.class_code = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.class_code := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.class_code := nvl(p_flow_schedule_rec.class_code,FND_API.G_MISS_CHAR) ;
	END IF;

	IF (   p_flow_schedule_rec.completion_locator_id    = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.completion_locator_id    := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.completion_locator_id    := nvl(p_flow_schedule_rec.completion_locator_id,FND_API.G_MISS_NUM)    ;
	END IF;

	IF (   p_flow_schedule_rec.completion_subinventory  = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.completion_subinventory  := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.completion_subinventory    := nvl(p_flow_schedule_rec.completion_subinventory,FND_API.G_MISS_CHAR)  ;
	END IF;

	IF (   p_flow_schedule_rec.created_by      = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.created_by      := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.created_by      := nvl(p_flow_schedule_rec.created_by,FND_API.G_MISS_NUM );
	END IF;

	IF (   p_flow_schedule_rec.creation_date   = FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Pvt_Rec.creation_date   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.creation_date   := nvl(p_flow_schedule_rec.creation_date,FND_API.G_MISS_DATE )   ;
	END IF;

	IF (   p_flow_schedule_rec.date_closed     = FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Pvt_Rec.date_closed     := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.date_closed     := nvl(p_flow_schedule_rec.date_closed,FND_API.G_MISS_DATE)    ;
	END IF;

	IF (   p_flow_schedule_rec.demand_class    = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.demand_class    := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.demand_class    := nvl(p_flow_schedule_rec.demand_class ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_rec.demand_source_delivery   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.demand_source_delivery   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.demand_source_delivery   := nvl(p_flow_schedule_rec.demand_source_delivery ,FND_API.G_MISS_CHAR)  ;
	END IF;

	IF (   p_flow_schedule_rec.demand_source_header_id  = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.demand_source_header_id  := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.demand_source_header_id  := nvl(p_flow_schedule_rec.demand_source_header_id ,FND_API.G_MISS_NUM ) ;
	END IF;

	IF (   p_flow_schedule_rec.demand_source_line   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.demand_source_line   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.demand_source_line   := nvl(p_flow_schedule_rec.demand_source_line,FND_API.G_MISS_CHAR )    ;
	END IF;

	IF (   p_flow_schedule_rec.demand_source_type   = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.demand_source_type   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.demand_source_type   := nvl(p_flow_schedule_rec.demand_source_type,FND_API.G_MISS_NUM )  ;
	END IF;

	IF (   p_flow_schedule_rec.last_updated_by    = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Pvt_Rec.last_updated_by      := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.last_updated_by    := nvl(p_flow_schedule_rec.last_updated_by,FND_API.G_MISS_NUM)    ;
	END IF;

	IF (   p_flow_schedule_rec.last_update_date    = FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Pvt_Rec.last_update_date     := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.last_update_date   := nvl(p_flow_schedule_rec.last_update_date,FND_API.G_MISS_DATE)   ;
	END IF;

	IF (   p_flow_schedule_rec.last_update_login  = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.last_update_login    := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.last_update_login  := nvl(p_flow_schedule_rec.last_update_login,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_rec.line_id    = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.line_id    := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.line_id    := nvl(p_flow_schedule_rec.line_id ,FND_API.G_MISS_NUM)   ;
	END IF;

	IF (   p_flow_schedule_rec.material_account   = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.material_account    := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.material_account    := nvl(p_flow_schedule_rec.material_account,FND_API.G_MISS_NUM ) ;
	END IF;

	IF (   p_flow_schedule_rec.material_overhead_account = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.material_overhead_account := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.material_overhead_account := nvl(p_flow_schedule_rec.material_overhead_account,FND_API.G_MISS_NUM ) ;
	END IF;

	IF (   p_flow_schedule_rec.material_variance_account = FND_API.G_MISS_NUM  ) THEN
		x_Flow_Schedule_Pvt_Rec.material_variance_account := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.material_variance_account := nvl(p_flow_schedule_rec.material_variance_account ,FND_API.G_MISS_NUM ) ;
	END IF;

	IF (   p_flow_schedule_rec.mps_net_quantity   = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.mps_net_quantity     := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.mps_net_quantity   := nvl(p_flow_schedule_rec.mps_net_quantity,FND_API.G_MISS_NUM )    ;
	END IF;

	IF (   p_flow_schedule_rec.mps_scheduled_comp_date  = FND_API.G_MISS_DATE) THEN
		x_Flow_Schedule_Pvt_Rec.mps_scheduled_comp_date  := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.mps_scheduled_comp_date  := nvl(p_flow_schedule_rec.mps_scheduled_comp_date,FND_API.G_MISS_DATE)  ;
	END IF;

	IF (   p_flow_schedule_rec.organization_id          = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.organization_id          := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.organization_id          := nvl(p_flow_schedule_rec.organization_id,FND_API.G_MISS_NUM) ;
	END IF;

	IF (   p_flow_schedule_rec.outside_processing_acct  = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Pvt_Rec.outside_processing_acct  := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.outside_processing_acct  := nvl(p_flow_schedule_rec.outside_processing_acct,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_rec.outside_proc_var_acct    = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.outside_proc_var_acct    := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.outside_proc_var_acct    := nvl(p_flow_schedule_rec.outside_proc_var_acct,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_rec.overhead_account         = FND_API.G_MISS_NUM  ) THEN
		x_Flow_Schedule_Pvt_Rec.overhead_account         := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.overhead_account         := nvl(p_flow_schedule_rec.overhead_account,FND_API.G_MISS_NUM )  ;
	END IF;

	IF (   p_flow_schedule_rec.overhead_variance_account= FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.overhead_variance_account:= NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.overhead_variance_account:= nvl(p_flow_schedule_rec.overhead_variance_account,FND_API.G_MISS_NUM );
	END IF;

	IF (   p_flow_schedule_rec.planned_quantity   = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.planned_quantity     := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.planned_quantity   := nvl(p_flow_schedule_rec.planned_quantity,FND_API.G_MISS_NUM )   ;
	END IF;

	IF (   p_flow_schedule_rec.primary_item_id    = FND_API.G_MISS_NUM  ) THEN
		x_Flow_Schedule_Pvt_Rec.primary_item_id    := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.primary_item_id    := nvl(p_flow_schedule_rec.primary_item_id,FND_API.G_MISS_NUM )    ;
	END IF;

	IF (   p_flow_schedule_rec.program_application_id= FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.program_application_id:= NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.program_application_id:= nvl(p_flow_schedule_rec.program_application_id,FND_API.G_MISS_NUM );
	END IF;

	IF (   p_flow_schedule_rec.program_id   = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.program_id   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.program_id   := nvl(p_flow_schedule_rec.program_id ,FND_API.G_MISS_NUM )   ;
	END IF;

	IF (   p_flow_schedule_rec.program_update_date  = FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Pvt_Rec.program_update_date  := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.program_update_date  := nvl(p_flow_schedule_rec.program_update_date,FND_API.G_MISS_DATE)  ;
	END IF;

	IF (   p_flow_schedule_rec.project_id           = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.project_id           := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.project_id           := nvl(p_flow_schedule_rec.project_id,FND_API.G_MISS_NUM) ;
	END IF;

	IF (   p_flow_schedule_rec.quantity_completed   = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Pvt_Rec.quantity_completed    := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.quantity_completed   := nvl(p_flow_schedule_rec.quantity_completed ,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_rec.request_id    = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Pvt_Rec.request_id    := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.request_id    := nvl(p_flow_schedule_rec.request_id ,FND_API.G_MISS_NUM) ;
	END IF;

	IF (   p_flow_schedule_rec.resource_account  = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Pvt_Rec.resource_account  := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.resource_account  := nvl(p_flow_schedule_rec.resource_account ,FND_API.G_MISS_NUM) ;
	END IF;

	IF (   p_flow_schedule_rec.resource_variance_account  = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Pvt_Rec.resource_variance_account  := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.resource_variance_account  := nvl(p_flow_schedule_rec.resource_variance_account,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_rec.routing_revision     = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.routing_revision     := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.routing_revision     := nvl(p_flow_schedule_rec.routing_revision ,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (   p_flow_schedule_rec.routing_revision_date= FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Pvt_Rec.routing_revision_date         := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.routing_revision_date    := nvl(p_flow_schedule_rec.routing_revision_date ,FND_API.G_MISS_DATE);
	END IF;

	IF (   p_flow_schedule_rec.scheduled_completion_date = FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Pvt_Rec.scheduled_completion_date:= NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.scheduled_completion_date:= nvl(p_flow_schedule_rec.scheduled_completion_date,FND_API.G_MISS_DATE);
	END IF;

	IF (   p_flow_schedule_rec.scheduled_flag   = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.scheduled_flag   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.scheduled_flag     := nvl(p_flow_schedule_rec.scheduled_flag,FND_API.G_MISS_NUM );
	END IF;

	IF (   p_flow_schedule_rec.scheduled_start_date   = FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Pvt_Rec.scheduled_start_date   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.scheduled_start_date     := nvl(p_flow_schedule_rec.scheduled_start_date,FND_API.G_MISS_DATE) ;
	END IF;

	IF (   p_flow_schedule_rec.schedule_group_id      = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.schedule_group_id      := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.schedule_group_id      := nvl(p_flow_schedule_rec.schedule_group_id ,FND_API.G_MISS_NUM)     ;
	END IF;

	IF (   p_flow_schedule_rec.schedule_number  = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.schedule_number  := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.schedule_number  := nvl(p_flow_schedule_rec.schedule_number  ,FND_API.G_MISS_CHAR );
	END IF;


	IF (   p_flow_schedule_rec.status   = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.status   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.status   := nvl(p_flow_schedule_rec.status ,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_rec.std_cost_adjustment_acct   = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Pvt_Rec.std_cost_adjustment_acct   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.std_cost_adjustment_acct   := nvl(p_flow_schedule_rec.std_cost_adjustment_acct ,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_rec.task_id    = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Pvt_Rec.task_id    := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.task_id     := nvl(p_flow_schedule_rec.task_id ,FND_API.G_MISS_NUM)   ;
	END IF;

	IF (   p_flow_schedule_rec.wip_entity_id   = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Pvt_Rec.wip_entity_id   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.wip_entity_id   := nvl(p_flow_schedule_rec.wip_entity_id ,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_rec.scheduled_by    = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Pvt_Rec.scheduled_by      := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.scheduled_by    := nvl(p_flow_schedule_rec.scheduled_by,FND_API.G_MISS_NUM)    ;
	END IF;

	IF (   p_flow_schedule_rec.return_status   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.return_status   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.return_status   := nvl(p_flow_schedule_rec.return_status ,FND_API.G_MISS_CHAR)  ;
	END IF;

	IF (   p_flow_schedule_rec.db_flag    = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.db_flag    := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.db_flag    := nvl(p_flow_schedule_rec.db_flag ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_rec.operation  = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.operation  := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.operation  := nvl(p_flow_schedule_rec.operation ,FND_API.G_MISS_CHAR )  ;
	END IF;

	IF (   p_flow_schedule_rec.end_item_unit_number   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.end_item_unit_number := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.end_item_unit_number := nvl(p_flow_schedule_rec.end_item_unit_number,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (   p_flow_schedule_rec.quantity_scrapped    = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.quantity_scrapped         := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.quantity_scrapped    := nvl(p_flow_schedule_rec.quantity_scrapped ,FND_API.G_MISS_NUM)   ;
	END IF;

	IF (   p_flow_schedule_rec.kanban_card_id       = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Pvt_Rec.kanban_card_id       := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.kanban_card_id       := nvl(p_flow_schedule_rec.kanban_card_id ,FND_API.G_MISS_NUM)      ;
	END IF;

	IF (   p_flow_schedule_rec.synch_schedule_num   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Pvt_Rec.synch_schedule_num   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.synch_schedule_num   := nvl(p_flow_schedule_rec.synch_schedule_num ,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (   p_flow_schedule_rec.synch_operation_seq_num  = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Pvt_Rec.synch_operation_seq_num   := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.synch_operation_seq_num  := nvl(p_flow_schedule_rec.synch_operation_seq_num ,FND_API.G_MISS_NUM) ;
	END IF;

	IF (   p_flow_schedule_rec.roll_forwarded_flag	= FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Pvt_Rec.roll_forwarded_flag	:= NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.roll_forwarded_flag	:= nvl(p_flow_schedule_rec.roll_forwarded_flag,FND_API.G_MISS_NUM);
	END IF;

	IF (   p_flow_schedule_rec.current_line_operation = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Pvt_Rec.current_line_operation := NULL;
	ELSE
		x_Flow_Schedule_Pvt_Rec.current_line_operation := nvl(p_flow_schedule_rec.current_line_operation ,FND_API.G_MISS_NUM);
	END IF;
END;

PROCEDURE  PVT_Flow_Sched_Val_Rec_To_PUB (
	p_flow_schedule_val_pvt_rec IN Flow_Schedule_Val_Pvt_Rec_Type,
	x_flow_schedule_val_rec OUT NOCOPY MRP_Flow_Schedule_PUB.Flow_Schedule_Val_Rec_Type  )
IS
BEGIN

	IF (   p_flow_schedule_val_pvt_rec.Completion_locator   = FND_API.G_MISS_CHAR ) THEN
		x_flow_schedule_val_rec.completion_locator   := NULL;
	ELSE
		x_flow_schedule_val_rec.completion_locator   := nvl(p_flow_schedule_val_pvt_rec.Completion_locator,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (  p_flow_schedule_val_pvt_rec.line   = FND_API.G_MISS_CHAR ) THEN
		x_flow_schedule_val_rec.line :=  NULL;
	ELSE
		x_flow_schedule_val_rec.line := nvl(p_flow_schedule_val_pvt_rec.line,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (  p_flow_schedule_val_pvt_rec.organization = FND_API.G_MISS_CHAR ) THEN
		x_flow_schedule_val_rec.organization :=  NULL;
	ELSE
		x_flow_schedule_val_rec.organization:= nvl(p_flow_schedule_val_pvt_rec.organization,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (  p_flow_schedule_val_pvt_rec.primary_item = FND_API.G_MISS_CHAR ) THEN
		x_flow_schedule_val_rec.primary_item :=  NULL;
	ELSE
		x_flow_schedule_val_rec.primary_item := nvl(p_flow_schedule_val_pvt_rec.primary_item,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (  p_flow_schedule_val_pvt_rec.project = FND_API.G_MISS_CHAR ) THEN
		x_flow_schedule_val_rec.project :=  NULL;
	ELSE
		x_flow_schedule_val_rec.project  := nvl(p_flow_schedule_val_pvt_rec.project,FND_API.G_MISS_CHAR )  ;
	END IF;

	IF (  p_flow_schedule_val_pvt_rec.schedule_group   = FND_API.G_MISS_CHAR ) THEN
		x_flow_schedule_val_rec.schedule_group :=  NULL;
	ELSE
		x_flow_schedule_val_rec.schedule_group := nvl(p_flow_schedule_val_pvt_rec.schedule_group,FND_API.G_MISS_CHAR ) ;
	END IF;

END;

PROCEDURE  PVT_Flow_Sched_Rec_To_PUB (
	p_flow_schedule_pvt_rec IN Flow_Schedule_Pvt_Rec_Type  ,
	x_Flow_Schedule_Rec OUT NOCOPY MRP_Flow_Schedule_PUB.Flow_Schedule_Rec_Type  )
IS
BEGIN

	IF (   p_flow_schedule_pvt_rec.alternate_bom_designator   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.alternate_bom_designator   := NULL;
	ELSE
		x_Flow_Schedule_Rec.alternate_bom_designator   := nvl(p_flow_schedule_pvt_rec.alternate_bom_designator,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.alternate_routing_desig   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.alternate_routing_desig   := NULL;
	ELSE
		x_Flow_Schedule_Rec.alternate_routing_desig   := nvl(p_flow_schedule_pvt_rec.alternate_routing_desig,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute1 = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute1 := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute1 := nvl(p_flow_schedule_pvt_rec.attribute1,FND_API.G_MISS_CHAR )  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute10 = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute10 := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute10 := nvl(p_flow_schedule_pvt_rec.attribute10,FND_API.G_MISS_CHAR )  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute11   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute11   := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute11   := nvl(p_flow_schedule_pvt_rec.attribute11,FND_API.G_MISS_CHAR )    ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute12   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute12   := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute12   := nvl(p_flow_schedule_pvt_rec.attribute12,FND_API.G_MISS_CHAR )    ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute13  = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute13  := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute13   := nvl(p_flow_schedule_pvt_rec.attribute13,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute14              = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute14  := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute14  := nvl(p_flow_schedule_pvt_rec.attribute14,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute15  = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute15  := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute15  := nvl(p_flow_schedule_pvt_rec.attribute15,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute2   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute2   := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute2   := nvl(p_flow_schedule_pvt_rec.attribute2,FND_API.G_MISS_CHAR )    ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute3   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute3   := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute3   := nvl(p_flow_schedule_pvt_rec.attribute3,FND_API.G_MISS_CHAR )    ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute4   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute4   := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute4   := nvl(p_flow_schedule_pvt_rec.attribute4 ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute5   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute5   := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute5   := nvl(p_flow_schedule_pvt_rec.attribute5 ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute6   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute6   := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute6   := nvl(p_flow_schedule_pvt_rec.attribute6 ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute7   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute7   := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute7   := nvl(p_flow_schedule_pvt_rec.attribute7 ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute8   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute8   := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute8   := nvl(p_flow_schedule_pvt_rec.attribute8 ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute9   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute9   := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute9   := nvl(p_flow_schedule_pvt_rec.attribute9 ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.attribute_category   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.attribute_category   := NULL;
	ELSE
		x_Flow_Schedule_Rec.attribute_category   := nvl(p_flow_schedule_pvt_rec.attribute_category ,FND_API.G_MISS_CHAR )  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.bom_revision         = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.bom_revision         := NULL;
	ELSE
		x_Flow_Schedule_Rec.bom_revision         := nvl(p_flow_schedule_pvt_rec.bom_revision ,FND_API.G_MISS_CHAR )        ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.bom_revision_date    = FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Rec.bom_revision_date    := NULL;
	ELSE
		x_Flow_Schedule_Rec.bom_revision_date    := nvl(p_flow_schedule_pvt_rec.bom_revision_date,FND_API.G_MISS_DATE )    ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.build_sequence      = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.build_sequence      := NULL;
	ELSE
		x_Flow_Schedule_Rec.build_sequence      := NVL(p_flow_schedule_pvt_rec.build_sequence , FND_API.G_MISS_NUM );
	END IF;

	IF (   p_flow_schedule_pvt_rec.class_code = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.class_code := NULL;
	ELSE
		x_Flow_Schedule_Rec.class_code := nvl(p_flow_schedule_pvt_rec.class_code,FND_API.G_MISS_CHAR) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.completion_locator_id    = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.completion_locator_id    := NULL;
	ELSE
		x_Flow_Schedule_Rec.completion_locator_id    := nvl(p_flow_schedule_pvt_rec.completion_locator_id,FND_API.G_MISS_NUM)    ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.completion_subinventory  = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.completion_subinventory  := NULL;
	ELSE
		x_Flow_Schedule_Rec.completion_subinventory    := nvl(p_flow_schedule_pvt_rec.completion_subinventory,FND_API.G_MISS_CHAR)  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.created_by      = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.created_by      := NULL;
	ELSE
		x_Flow_Schedule_Rec.created_by      := nvl(p_flow_schedule_pvt_rec.created_by,FND_API.G_MISS_NUM );
	END IF;

	IF (   p_flow_schedule_pvt_rec.creation_date   = FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Rec.creation_date   := NULL;
	ELSE
		x_Flow_Schedule_Rec.creation_date   := nvl(p_flow_schedule_pvt_rec.creation_date,FND_API.G_MISS_DATE )   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.date_closed     = FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Rec.date_closed     := NULL;
	ELSE
		x_Flow_Schedule_Rec.date_closed     := nvl(p_flow_schedule_pvt_rec.date_closed,FND_API.G_MISS_DATE)    ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.demand_class    = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.demand_class    := NULL;
	ELSE
		x_Flow_Schedule_Rec.demand_class    := nvl(p_flow_schedule_pvt_rec.demand_class ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.demand_source_delivery   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.demand_source_delivery   := NULL;
	ELSE
		x_Flow_Schedule_Rec.demand_source_delivery   := nvl(p_flow_schedule_pvt_rec.demand_source_delivery ,FND_API.G_MISS_CHAR)  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.demand_source_header_id  = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.demand_source_header_id  := NULL;
	ELSE
		x_Flow_Schedule_Rec.demand_source_header_id  := nvl(p_flow_schedule_pvt_rec.demand_source_header_id ,FND_API.G_MISS_NUM ) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.demand_source_line   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.demand_source_line   := NULL;
	ELSE
		x_Flow_Schedule_Rec.demand_source_line   := nvl(p_flow_schedule_pvt_rec.demand_source_line,FND_API.G_MISS_CHAR )    ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.demand_source_type   = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.demand_source_type   := NULL;
	ELSE
		x_Flow_Schedule_Rec.demand_source_type   := nvl(p_flow_schedule_pvt_rec.demand_source_type,FND_API.G_MISS_NUM )  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.last_updated_by    = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Rec.last_updated_by      := NULL;
	ELSE
		x_Flow_Schedule_Rec.last_updated_by    := nvl(p_flow_schedule_pvt_rec.last_updated_by,FND_API.G_MISS_NUM)    ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.last_update_date    = FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Rec.last_update_date     := NULL;
	ELSE
		x_Flow_Schedule_Rec.last_update_date   := nvl(p_flow_schedule_pvt_rec.last_update_date,FND_API.G_MISS_DATE)   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.last_update_login  = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.last_update_login    := NULL;
	ELSE
		x_Flow_Schedule_Rec.last_update_login  := nvl(p_flow_schedule_pvt_rec.last_update_login,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.line_id    = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.line_id    := NULL;
	ELSE
		x_Flow_Schedule_Rec.line_id    := nvl(p_flow_schedule_pvt_rec.line_id ,FND_API.G_MISS_NUM)   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.material_account   = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.material_account    := NULL;
	ELSE
		x_Flow_Schedule_Rec.material_account    := nvl(p_flow_schedule_pvt_rec.material_account,FND_API.G_MISS_NUM ) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.material_overhead_account = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.material_overhead_account := NULL;
	ELSE
		x_Flow_Schedule_Rec.material_overhead_account := nvl(p_flow_schedule_pvt_rec.material_overhead_account,FND_API.G_MISS_NUM ) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.material_variance_account = FND_API.G_MISS_NUM  ) THEN
		x_Flow_Schedule_Rec.material_variance_account := NULL;
	ELSE
		x_Flow_Schedule_Rec.material_variance_account := nvl(p_flow_schedule_pvt_rec.material_variance_account ,FND_API.G_MISS_NUM ) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.mps_net_quantity   = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.mps_net_quantity     := NULL;
	ELSE
		x_Flow_Schedule_Rec.mps_net_quantity   := nvl(p_flow_schedule_pvt_rec.mps_net_quantity,FND_API.G_MISS_NUM )    ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.mps_scheduled_comp_date  = FND_API.G_MISS_DATE) THEN
		x_Flow_Schedule_Rec.mps_scheduled_comp_date  := NULL;
	ELSE
		x_Flow_Schedule_Rec.mps_scheduled_comp_date  := nvl(p_flow_schedule_pvt_rec.mps_scheduled_comp_date,FND_API.G_MISS_DATE)  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.organization_id          = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.organization_id          := NULL;
	ELSE
		x_Flow_Schedule_Rec.organization_id          := nvl(p_flow_schedule_pvt_rec.organization_id,FND_API.G_MISS_NUM) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.outside_processing_acct  = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Rec.outside_processing_acct  := NULL;
	ELSE
		x_Flow_Schedule_Rec.outside_processing_acct  := nvl(p_flow_schedule_pvt_rec.outside_processing_acct,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.outside_proc_var_acct    = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.outside_proc_var_acct    := NULL;
	ELSE
		x_Flow_Schedule_Rec.outside_proc_var_acct    := nvl(p_flow_schedule_pvt_rec.outside_proc_var_acct,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.overhead_account         = FND_API.G_MISS_NUM  ) THEN
		x_Flow_Schedule_Rec.overhead_account         := NULL;
	ELSE
		x_Flow_Schedule_Rec.overhead_account         := nvl(p_flow_schedule_pvt_rec.overhead_account,FND_API.G_MISS_NUM )  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.overhead_variance_account= FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.overhead_variance_account:= NULL;
	ELSE
		x_Flow_Schedule_Rec.overhead_variance_account:= nvl(p_flow_schedule_pvt_rec.overhead_variance_account,FND_API.G_MISS_NUM );
	END IF;

	IF (   p_flow_schedule_pvt_rec.planned_quantity   = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.planned_quantity     := NULL;
	ELSE
		x_Flow_Schedule_Rec.planned_quantity   := nvl(p_flow_schedule_pvt_rec.planned_quantity,FND_API.G_MISS_NUM )   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.primary_item_id    = FND_API.G_MISS_NUM  ) THEN
		x_Flow_Schedule_Rec.primary_item_id    := NULL;
	ELSE
		x_Flow_Schedule_Rec.primary_item_id    := nvl(p_flow_schedule_pvt_rec.primary_item_id,FND_API.G_MISS_NUM )    ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.program_application_id= FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.program_application_id:= NULL;
	ELSE
		x_Flow_Schedule_Rec.program_application_id:= nvl(p_flow_schedule_pvt_rec.program_application_id,FND_API.G_MISS_NUM );
	END IF;

	IF (   p_flow_schedule_pvt_rec.program_id   = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.program_id   := NULL;
	ELSE
		x_Flow_Schedule_Rec.program_id   := nvl(p_flow_schedule_pvt_rec.program_id ,FND_API.G_MISS_NUM )   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.program_update_date  = FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Rec.program_update_date  := NULL;
	ELSE
		x_Flow_Schedule_Rec.program_update_date  := nvl(p_flow_schedule_pvt_rec.program_update_date,FND_API.G_MISS_DATE)  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.project_id           = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.project_id           := NULL;
	ELSE
		x_Flow_Schedule_Rec.project_id           := nvl(p_flow_schedule_pvt_rec.project_id,FND_API.G_MISS_NUM) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.quantity_completed   = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Rec.quantity_completed    := NULL;
	ELSE
		x_Flow_Schedule_Rec.quantity_completed   := nvl(p_flow_schedule_pvt_rec.quantity_completed ,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.request_id    = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Rec.request_id    := NULL;
	ELSE
		x_Flow_Schedule_Rec.request_id    := nvl(p_flow_schedule_pvt_rec.request_id ,FND_API.G_MISS_NUM) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.resource_account  = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Rec.resource_account  := NULL;
	ELSE
		x_Flow_Schedule_Rec.resource_account  := nvl(p_flow_schedule_pvt_rec.resource_account ,FND_API.G_MISS_NUM) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.resource_variance_account  = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Rec.resource_variance_account  := NULL;
	ELSE
		x_Flow_Schedule_Rec.resource_variance_account  := nvl(p_flow_schedule_pvt_rec.resource_variance_account,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.routing_revision     = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.routing_revision     := NULL;
	ELSE
		x_Flow_Schedule_Rec.routing_revision     := nvl(p_flow_schedule_pvt_rec.routing_revision ,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.routing_revision_date= FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Rec.routing_revision_date         := NULL;
	ELSE
		x_Flow_Schedule_Rec.routing_revision_date    := nvl(p_flow_schedule_pvt_rec.routing_revision_date ,FND_API.G_MISS_DATE);
	END IF;

	IF (   p_flow_schedule_pvt_rec.scheduled_completion_date = FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Rec.scheduled_completion_date:= NULL;
	ELSE
		x_Flow_Schedule_Rec.scheduled_completion_date:= nvl(p_flow_schedule_pvt_rec.scheduled_completion_date,FND_API.G_MISS_DATE);
	END IF;

	IF (   p_flow_schedule_pvt_rec.scheduled_flag   = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.scheduled_flag   := NULL;
	ELSE
		x_Flow_Schedule_Rec.scheduled_flag     := nvl(p_flow_schedule_pvt_rec.scheduled_flag,FND_API.G_MISS_NUM );
	END IF;

	IF (   p_flow_schedule_pvt_rec.scheduled_start_date   = FND_API.G_MISS_DATE ) THEN
		x_Flow_Schedule_Rec.scheduled_start_date   := NULL;
	ELSE
		x_Flow_Schedule_Rec.scheduled_start_date     := nvl(p_flow_schedule_pvt_rec.scheduled_start_date,FND_API.G_MISS_DATE) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.schedule_group_id      = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.schedule_group_id      := NULL;
	ELSE
		x_Flow_Schedule_Rec.schedule_group_id      := nvl(p_flow_schedule_pvt_rec.schedule_group_id ,FND_API.G_MISS_NUM)     ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.schedule_number  = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.schedule_number  := NULL;
	ELSE
		x_Flow_Schedule_Rec.schedule_number  := nvl(p_flow_schedule_pvt_rec.schedule_number  ,FND_API.G_MISS_CHAR );
	END IF;


	IF (   p_flow_schedule_pvt_rec.status   = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.status   := NULL;
	ELSE
		x_Flow_Schedule_Rec.status   := nvl(p_flow_schedule_pvt_rec.status ,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.std_cost_adjustment_acct   = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Rec.std_cost_adjustment_acct   := NULL;
	ELSE
		x_Flow_Schedule_Rec.std_cost_adjustment_acct   := nvl(p_flow_schedule_pvt_rec.std_cost_adjustment_acct ,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.task_id    = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Rec.task_id    := NULL;
	ELSE
		x_Flow_Schedule_Rec.task_id     := nvl(p_flow_schedule_pvt_rec.task_id ,FND_API.G_MISS_NUM)   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.wip_entity_id   = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Rec.wip_entity_id   := NULL;
	ELSE
		x_Flow_Schedule_Rec.wip_entity_id   := nvl(p_flow_schedule_pvt_rec.wip_entity_id ,FND_API.G_MISS_NUM)  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.scheduled_by    = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Rec.scheduled_by      := NULL;
	ELSE
		x_Flow_Schedule_Rec.scheduled_by    := nvl(p_flow_schedule_pvt_rec.scheduled_by,FND_API.G_MISS_NUM)    ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.return_status   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.return_status   := NULL;
	ELSE
		x_Flow_Schedule_Rec.return_status   := nvl(p_flow_schedule_pvt_rec.return_status ,FND_API.G_MISS_CHAR)  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.db_flag    = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.db_flag    := NULL;
	ELSE
		x_Flow_Schedule_Rec.db_flag    := nvl(p_flow_schedule_pvt_rec.db_flag ,FND_API.G_MISS_CHAR )   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.operation  = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.operation  := NULL;
	ELSE
		x_Flow_Schedule_Rec.operation  := nvl(p_flow_schedule_pvt_rec.operation ,FND_API.G_MISS_CHAR )  ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.end_item_unit_number   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.end_item_unit_number := NULL;
	ELSE
		x_Flow_Schedule_Rec.end_item_unit_number := nvl(p_flow_schedule_pvt_rec.end_item_unit_number,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.quantity_scrapped    = FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.quantity_scrapped         := NULL;
	ELSE
		x_Flow_Schedule_Rec.quantity_scrapped    := nvl(p_flow_schedule_pvt_rec.quantity_scrapped ,FND_API.G_MISS_NUM)   ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.kanban_card_id       = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Rec.kanban_card_id       := NULL;
	ELSE
		x_Flow_Schedule_Rec.kanban_card_id       := nvl(p_flow_schedule_pvt_rec.kanban_card_id ,FND_API.G_MISS_NUM)      ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.synch_schedule_num   = FND_API.G_MISS_CHAR ) THEN
		x_Flow_Schedule_Rec.synch_schedule_num   := NULL;
	ELSE
		x_Flow_Schedule_Rec.synch_schedule_num   := nvl(p_flow_schedule_pvt_rec.synch_schedule_num ,FND_API.G_MISS_CHAR ) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.synch_operation_seq_num  = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Rec.synch_operation_seq_num   := NULL;
	ELSE
		x_Flow_Schedule_Rec.synch_operation_seq_num  := nvl(p_flow_schedule_pvt_rec.synch_operation_seq_num ,FND_API.G_MISS_NUM) ;
	END IF;

	IF (   p_flow_schedule_pvt_rec.roll_forwarded_flag	= FND_API.G_MISS_NUM ) THEN
		x_Flow_Schedule_Rec.roll_forwarded_flag	:= NULL;
	ELSE
		x_Flow_Schedule_Rec.roll_forwarded_flag	:= nvl(p_flow_schedule_pvt_rec.roll_forwarded_flag,FND_API.G_MISS_NUM);
	END IF;

	IF (   p_flow_schedule_pvt_rec.current_line_operation = FND_API.G_MISS_NUM) THEN
		x_Flow_Schedule_Rec.current_line_operation := NULL;
	ELSE
		x_Flow_Schedule_Rec.current_line_operation := nvl(p_flow_schedule_pvt_rec.current_line_operation ,FND_API.G_MISS_NUM);
	END IF;
END;


--  Flow_Schedule

PROCEDURE Flow_Schedule
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  MRP_GLOBALS.Control_Rec_Type
,   x_flow_schedule_rec             IN  OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   x_old_flow_schedule_rec         IN  OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type := x_flow_schedule_rec;
l_old_flow_schedule_rec       MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type := x_old_flow_schedule_rec;
BEGIN

    --  Load API control record
    l_control_rec := MRP_GLOBALS.Init_Control_Rec
    (   p_operation     => l_flow_schedule_rec.operation
    ,   p_control_rec   => p_control_rec
    );

    --  Set record return status.

    l_flow_schedule_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  Prepare record.

    IF l_flow_schedule_rec.operation = MRP_GLOBALS.G_OPR_CREATE THEN

        l_flow_schedule_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        l_old_flow_schedule_rec :=
        MRP_Flow_Schedule_Util.Convert_Miss_To_Null (l_old_flow_schedule_rec);


    ELSIF l_flow_schedule_rec.operation = MRP_GLOBALS.G_OPR_UPDATE
    OR    l_flow_schedule_rec.operation = MRP_GLOBALS.G_OPR_DELETE
    THEN
        l_flow_schedule_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_flow_schedule_rec.organization_id  IS NULL
        OR  l_old_flow_schedule_rec.wip_entity_id IS NULL
        THEN


            l_old_flow_schedule_rec := MRP_Flow_Schedule_Util.Query_Row
            (   p_wip_entity_id               => l_flow_schedule_rec.wip_entity_id
            );

        ELSE

            --  Set missing old record elements to NULL.

            l_old_flow_schedule_rec :=
            MRP_Flow_Schedule_Util.Convert_Miss_To_Null (l_old_flow_schedule_rec);

        END IF;

        --  Complete new record from old

        l_flow_schedule_rec := MRP_Flow_Schedule_Util.Complete_Record
        (   p_flow_schedule_rec           => l_flow_schedule_rec
        ,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
        );

    END IF;

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

            MRP_Validate_Flow_Schedule.Attributes
            (   x_return_status               => l_return_status
            ,   p_flow_schedule_rec           => l_flow_schedule_rec
            ,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    END IF;

        --  Clear dependent attributes.

    IF  l_control_rec.change_attributes and l_flow_schedule_rec.operation <> MRP_GLOBALS.G_OPR_CREATE THEN

        MRP_Flow_Schedule_Util.Clear_Dependent_Attr
        (   p_flow_schedule_rec           => l_flow_schedule_rec
        ,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
        ,   x_flow_schedule_rec           => l_flow_schedule_rec
        );

    END IF;

    --  Default missing attributes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        MRP_Default_Flow_Schedule.Attributes
        (   p_flow_schedule_rec           => l_flow_schedule_rec
        ,   x_flow_schedule_rec           => l_flow_schedule_rec
        );

    END IF;

    --  Apply attribute changes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        MRP_Flow_Schedule_Util.Apply_Attribute_Changes
        (   p_flow_schedule_rec           => l_flow_schedule_rec
        ,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
        ,   x_flow_schedule_rec           => l_flow_schedule_rec
        );

    END IF;

    --  Entity level validation.

    IF l_control_rec.validate_entity THEN

        IF l_flow_schedule_rec.operation = MRP_GLOBALS.G_OPR_DELETE THEN

            MRP_Validate_Flow_Schedule.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_flow_schedule_rec           => l_flow_schedule_rec
            );

        ELSE

            MRP_Validate_Flow_Schedule.Entity
            (   x_return_status               => l_return_status
            ,   p_flow_schedule_rec           => l_flow_schedule_rec
            ,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
            );

        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    --  Step 4. Write to DB

    IF l_control_rec.write_to_db THEN

        IF l_flow_schedule_rec.operation = MRP_GLOBALS.G_OPR_DELETE THEN

            MRP_Flow_Schedule_Util.Delete_Row
            (   p_wip_entity_id               => l_flow_schedule_rec.wip_entity_id
            );

        ELSE


            --  Get Who Information

            l_flow_schedule_rec.last_update_date := SYSDATE;
            l_flow_schedule_rec.last_updated_by := FND_GLOBAL.USER_ID;
            l_flow_schedule_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

            IF l_flow_schedule_rec.operation = MRP_GLOBALS.G_OPR_UPDATE THEN

                MRP_Flow_Schedule_Util.Update_Row (l_flow_schedule_rec);

            ELSIF l_flow_schedule_rec.operation = MRP_GLOBALS.G_OPR_CREATE THEN

                l_flow_schedule_rec.creation_date := SYSDATE;
                l_flow_schedule_rec.created_by := FND_GLOBAL.USER_ID;

                MRP_Flow_Schedule_Util.Insert_Row (l_flow_schedule_rec);

            END IF;

        END IF;

    END IF;

    --  Load OUT parameters

    x_flow_schedule_rec            := l_flow_schedule_rec;
    x_old_flow_schedule_rec        := l_old_flow_schedule_rec;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_flow_schedule_rec.return_status := FND_API.G_RET_STS_ERROR;
        x_flow_schedule_rec            := l_flow_schedule_rec;
        x_old_flow_schedule_rec        := l_old_flow_schedule_rec;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_flow_schedule_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_flow_schedule_rec            := l_flow_schedule_rec;
        x_old_flow_schedule_rec        := l_old_flow_schedule_rec;

        RAISE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Flow_Schedule'
            );
        END IF;

        l_flow_schedule_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_flow_schedule_rec            := l_flow_schedule_rec;
        x_old_flow_schedule_rec        := l_old_flow_schedule_rec;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Flow_Schedule;

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
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Flow_Schedule';
l_return_status               VARCHAR2(1);
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type :=p_flow_schedule_rec  ;
l_old_flow_schedule_rec       MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type :=p_old_flow_schedule_rec ;
l_error_msg		      VARCHAR2(2000);
l_error_code		      NUMBER;
BEGIN



    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(NVL(p_init_msg_list,FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Flow_Schedule
    Flow_Schedule
    (   p_validation_level            => nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL)
    ,   p_control_rec                 => p_control_rec
    ,   x_flow_schedule_rec           => l_flow_schedule_rec
    ,   x_old_flow_schedule_rec       => l_old_flow_schedule_rec
    );

    --  Perform flow_schedule group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = MRP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = MRP_GLOBALS.G_ENTITY_FLOW_SCHEDULE)
    THEN

        NULL;

    END IF;

    --  Step 6. Perform Object group logic

    IF p_control_rec.process AND
        p_control_rec.process_entity = MRP_GLOBALS.G_ENTITY_ALL
    THEN

        NULL;

    END IF;

    --  Done processing, load OUT parameters.

    x_flow_schedule_rec := l_flow_schedule_rec;

    --  Clear API cache.

    IF p_control_rec.clear_api_cache THEN

        NULL;

    END IF;

    --  Clear API request tbl.

    IF p_control_rec.clear_api_requests THEN

        NULL;

    END IF;

    -- Explode BOM if indicated
    IF p_explode_bom = 'Y' THEN
      BOM_OE_EXPLODER_PKG.be_exploder(
        arg_org_id => l_flow_schedule_rec.organization_id,
        arg_starting_rev_date => sysdate - 3,
        arg_expl_type => 'ALL',
        arg_order_by => 1,
        arg_levels_to_explode => 20,
        arg_item_id => l_flow_schedule_rec.primary_item_id,
        arg_comp_code => '',
        arg_user_id => 0,
        arg_err_msg => l_error_msg,
        arg_error_code => l_error_code,
	arg_alt_bom_desig => l_flow_schedule_rec.alternate_bom_designator
      );
    END IF;

    --  Derive return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_flow_schedule_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

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
            ,   'Process_Flow_Schedule'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Flow_Schedule;

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


PROCEDURE Lock_Flow_Schedule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := NULL
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   x_flow_schedule_rec             IN  OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Flow_Schedule';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(NVL(p_init_msg_list,FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Set Savepoint

    SAVEPOINT Lock_Flow_Schedule_PVT;

    --  Lock flow_schedule

    IF p_flow_schedule_rec.operation = MRP_GLOBALS.G_OPR_LOCK THEN

        MRP_Flow_Schedule_Util.Lock_Row
        (   p_flow_schedule_rec           => p_flow_schedule_rec
        ,   x_flow_schedule_rec           => x_flow_schedule_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Set return status

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

        --  Rollback

        ROLLBACK TO Lock_Flow_Schedule_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Flow_Schedule_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Flow_Schedule'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Flow_Schedule_PVT;

END Lock_Flow_Schedule;

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
Description : Changed x_flow_schedule_rec and l_flow_schedule_rec to be of
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
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Flow_Schedule';
l_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(NVL(p_init_msg_list,FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Get flow_schedule ( parent = flow_schedule )

    l_flow_schedule_rec :=  MRP_Flow_Schedule_Util.Query_Row
    (   p_wip_entity_id       => p_wip_entity_id
    );

    --  Load out parameters

    x_flow_schedule_rec            := l_flow_schedule_rec;

    --  Set return status

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
            ,   'Get_Flow_Schedule'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Flow_Schedule;

END MRP_Flow_Schedule_PVT;

/
