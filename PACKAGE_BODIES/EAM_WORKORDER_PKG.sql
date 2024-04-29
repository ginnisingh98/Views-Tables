--------------------------------------------------------
--  DDL for Package Body EAM_WORKORDER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WORKORDER_PKG" as
/* $Header: EAMWOTHB.pls 120.9.12010000.2 2008/11/14 19:20:59 lakmohan ship $ */




PROCEDURE Update_Genealogy(       X_wip_entity_id            IN  NUMBER,
                                  X_organization_id          IN  NUMBER,
                                  X_parent_wip_entity_id     IN	 NUMBER,
	           	                  X_rebuild_item_id		     IN  NUMBER,
	           	                  X_rebuild_serial_number    IN	 VARCHAR2,
	           	                  X_manual_rebuild_flag	     IN	 VARCHAR2,
								  x_maintenance_object_type  IN  NUMBER,
								  x_maintenance_object_id    IN  Number ) IS
                l_serial_status    NUMBER;

x_returnStatus   varchar2(5);
l_msgCount Number;
l_msgData   varchar2(100);
l_error_message varchar2(4000);
l_status WIP_DISCRETE_JOBS.status_type%TYPE;

BEGIN

--added the following procedure to fix bug number 2899984. This procedure checks to see if
-- the rebuild serial number is provided on creating a new rebuild work order for serialized
--rebuild item. If so then it will update the genealogy of the parent asset or rebuild item.


/* It will no longer be possible to define work orders on rebuilds in
   Pre-defined status (Current Status = 1). Hence, the following check
   is unnecessry. Commenting the code below */

/* IB Component of Configuration should be updated as well */

if ((X_parent_wip_entity_id is not null) and (X_manual_rebuild_flag= 'N'))  then

Begin

wip_eam_genealogy_pvt.update_eam_genealogy(
p_api_version => 1.0,
p_object_type => 2, -- serial number
p_serial_number => X_rebuild_serial_number,
p_inventory_item_id => X_rebuild_item_id,
p_organization_id => X_Organization_Id,
p_genealogy_type => 5, -- asset item relationship
p_end_date_active => sysdate,
x_return_status => x_returnStatus,
x_msg_count => l_msgCount,
x_msg_data => l_msgData);

if (x_maintenance_object_type = 3) then

select status_type
into l_status
from wip_discrete_jobs
where wip_entity_id = X_parent_wip_entity_id
and organization_id = X_organization_id;

if (l_status in (12, 14, 15, 4, 5, 7)) then

csi_eam_interface_grp.rebuildable_return(
p_wip_entity_id => X_parent_wip_entity_id,
p_organization_id => X_organization_id,
p_instance_id => x_maintenance_object_id,
x_return_status => x_returnStatus,
x_error_message => l_error_message
);
end if;

end if;

EXCEPTION

   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('EAM','EAM_UPDATE_GENEALOGY_FAIL');
      FND_MESSAGE.RAISE_ERROR;
      APP_EXCEPTION.RAISE_EXCEPTION;

END;

end if; -- if clause to update the genealogy of the asset



END Update_Genealogy;

/*cboppana --Added this function to create a work order.This calls the Work Order api */
PROCEDURE Create_Workorder(X_Rowid            IN OUT NOCOPY VARCHAR2,
                X_wip_entity_id         IN OUT NOCOPY NUMBER,
                X_organization_id               NUMBER,
                X_last_update_date            DATE,
                X_last_updated_by                NUMBER,
                X_creation_date                 DATE,
                X_created_by                    NUMBER,
                X_last_update_login             NUMBER,
                X_description           IN OUT  NOCOPY  VARCHAR2,
                X_status_type           IN OUT NOCOPY        NUMBER,
		X_user_defined_status_id IN OUT NOCOPY	NUMBER,
		X_pending_flag		IN OUT NOCOPY	VARCHAR2,
		X_workflow_type		IN OUT NOCOPY	NUMBER ,
		X_warranty_claim_status	IN OUT NOCOPY	NUMBER,

		X_material_shortage_flag	IN OUT NOCOPY	NUMBER,
		X_material_shortage_check_date	IN OUT NOCOPY	DATE,

		X_primary_item_id               NUMBER,
		X_parent_wip_entity_id		NUMBER,
		X_asset_number			VARCHAR2,
		X_asset_group_id		NUMBER,
		X_pm_schedule_id		NUMBER,
		X_rebuild_item_id		NUMBER,
		X_rebuild_serial_number		VARCHAR2,
		X_manual_rebuild_flag	IN OUT NOCOPY	VARCHAR2,
		X_shutdown_type		IN OUT NOCOPY	VARCHAR2,
		X_tagout_required	IN OUT NOCOPY	VARCHAR2,
		X_plan_maintenance	IN OUT NOCOPY	VARCHAR2,
		X_estimation_status		VARCHAR2,
		X_requested_start_date	IN OUT NOCOPY	DATE,
		X_requested_due_date	IN OUT NOCOPY	DATE,
		X_notification_required	IN OUT NOCOPY	VARCHAR2,
		X_work_order_type	IN OUT NOCOPY	VARCHAR2,
		X_owning_department	IN OUT NOCOPY	NUMBER,
		X_activity_type		IN OUT NOCOPY	VARCHAR2,
		X_activity_cause	IN OUT NOCOPY	VARCHAR2,
                X_firm_planned_flag     IN OUT NOCOPY        NUMBER,
                X_job_type                    NUMBER:= 3,
                X_wip_supply_type              NUMBER := 7,
                X_class_code            IN OUT NOCOPY      VARCHAR2,
                X_material_account       IN OUT NOCOPY       NUMBER,
                X_material_overhead_account IN OUT NOCOPY    NUMBER,
                X_resource_account        IN OUT NOCOPY      NUMBER,
                X_outside_processing_account IN OUT NOCOPY   NUMBER,
                X_material_variance_account  IN OUT NOCOPY   NUMBER,
                X_resource_variance_account  IN OUT NOCOPY   NUMBER,
                X_outside_proc_var_account IN OUT NOCOPY	NUMBER,
                X_std_cost_adjustment_account IN OUT NOCOPY  NUMBER,
                X_overhead_account    IN OUT NOCOPY         NUMBER,
                X_overhead_variance_account  IN OUT NOCOPY   NUMBER,
                X_scheduled_start_date   IN OUT NOCOPY      DATE,
                X_date_released                DATE,
                X_scheduled_completion_date  IN OUT NOCOPY   DATE,
                X_date_completed               DATE,
                X_date_closed                  DATE,
                X_start_quantity	  NUMBER := 1,
		X_overcompletion_toleran_type 	NUMBER	:= null,
		X_overcompletion_toleran_value  NUMBER	:= null,
		X_quantity_completed		NUMBER	:= 0,
		X_quantity_scrapped		NUMBER	:= 0,
		X_net_quantity			NUMBER	:= 1,
                X_bom_reference_id             NUMBER,
                X_routing_reference_id         NUMBER,
                X_common_bom_sequence_id    IN OUT NOCOPY    NUMBER,
                X_common_routing_sequence_id  IN OUT NOCOPY NUMBER,
                X_bom_revision        IN OUT NOCOPY        VARCHAR2,
                X_routing_revision      IN OUT NOCOPY       VARCHAR2,
                X_bom_revision_date      IN OUT NOCOPY      DATE,
                X_routing_revision_date   IN OUT NOCOPY  DATE,
                X_lot_number                    VARCHAR2,
                X_alternate_bom_designator   IN OUT NOCOPY  VARCHAR2,
                X_alternate_routing_designator IN OUT NOCOPY VARCHAR2,
                X_completion_subinventory      VARCHAR2,
                X_completion_locator_id        NUMBER,
                X_demand_class               VARCHAR2,
                X_attribute_category    IN OUT NOCOPY      VARCHAR2,
                X_attribute1        IN OUT NOCOPY          VARCHAR2,
                X_attribute2      IN OUT NOCOPY          VARCHAR2,
                X_attribute3       IN OUT NOCOPY             VARCHAR2,
                X_attribute4      IN OUT NOCOPY            VARCHAR2,
                X_attribute5      IN OUT NOCOPY              VARCHAR2,
                X_attribute6       IN OUT NOCOPY       VARCHAR2,
                X_attribute7       IN OUT NOCOPY            VARCHAR2,
                X_attribute8      IN OUT NOCOPY             VARCHAR2,
                X_attribute9       IN OUT NOCOPY             VARCHAR2,
                X_attribute10      IN OUT NOCOPY            VARCHAR2,
                X_attribute11       IN OUT NOCOPY           VARCHAR2,
                X_attribute12      IN OUT NOCOPY            VARCHAR2,
                X_attribute13      IN OUT NOCOPY           VARCHAR2,
                X_attribute14     IN OUT NOCOPY             VARCHAR2,
                X_attribute15     IN OUT NOCOPY            VARCHAR2,
		X_We_Rowid		IN OUT NOCOPY  VARCHAR2,
		X_Entity_Type			NUMBER,
		X_Wip_Entity_Name		VARCHAR2,
                X_Schedule_Group_Id         NUMBER default null,
                X_Build_Sequence                NUMBER default null,
                X_Line_Id                       NUMBER default null,
		X_Project_Id			NUMBER,
		X_Task_Id			NUMBER,
                X_end_item_unit_number       VARCHAR2 default null,
		X_po_creation_time		NUMBER default 1,
                X_priority          IN OUT NOCOPY            NUMBER ,
                X_due_date                     DATE default null,
                X_maintenance_object_id         NUMBER,
		X_maintenance_object_source     NUMBER,
		X_maintenance_object_type       NUMBER,
		X_material_issue_by_mo     IN OUT NOCOPY     VARCHAR2,
		X_activity_source       IN OUT NOCOPY        VARCHAR2,
                X_Parent_Wip_Name                 VARCHAR2 := null,
                X_Relationship_Type              NUMBER := null,
                X_Relation_Status        IN OUT NOCOPY VARCHAR2,
		x_failure_code_required  IN OUT NOCOPY VARCHAR2,
                x_eam_failure_entry_record IN OUT NOCOPY eam_process_failure_entry_pub.eam_failure_entry_record_typ ,
                x_eam_failure_codes_tbl    IN OUT NOCOPY eam_process_failure_entry_pub.eam_failure_codes_tbl_typ
		) IS

                -- Bug # 2251186
                l_errbuf        VARCHAR2(1000) ;
                l_retcode       NUMBER := 0;
                l_return_status  VARCHAR2(80) :='';
                l_msg_data       VARCHAR2(2000) := '';
                l_msg_count      NUMBER;


	l_workorder_rec		EAM_PROCESS_WO_PUB.eam_wo_rec_type;
	l_workorder_rec1	EAM_PROCESS_WO_PUB.eam_wo_rec_type;
	l_eam_op_tbl		EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_op_tbl1		EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_op_tbl2		EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_op_network_tbl	EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_op_network_tbl1	EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_op_network_tbl2	EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_res_tbl		EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_res_tbl1		EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_res_tbl2		EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_res_inst_tbl	EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_res_inst_tbl1	EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_res_inst_tbl2	EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_sub_res_tbl	EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_sub_res_tbl1	EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_sub_res_tbl2	EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_res_usage_tbl	EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_eam_res_usage_tbl1	EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_eam_res_usage_tbl2	EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_eam_mat_req_tbl	EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_eam_mat_req_tbl1	EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_eam_mat_req_tbl2	EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
        l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
        l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
        l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
        l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
        l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;

	l_eam_direct_items_tbl	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_eam_direct_items_tbl_1    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

	l_eam_wo_relations_tbl      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_relations_tbl1     EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_relations_tbl2     EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_relations_rec1     EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
	l_eam_wo_relations_rec2     EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
	l_eam_wo_relations_rec3     EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
	l_eam_wo_relations_rec4     EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
	l_eam_wo_tbl                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl1               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl2               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;

	l_eam_wo_comp_tbl_1         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
        l_eam_wo_quality_tbl_1      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
        l_eam_meter_reading_tbl_1   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
        l_eam_wo_comp_rebuild_tbl_1 EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
        l_eam_wo_comp_mr_read_tbl_1 EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
        l_eam_op_comp_tbl_1         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl_1         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
        l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

	l_eam_msg_tbl  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;

	l_user_id NUMBER;
	l_responsibility_id NUMBER;

	l_message_text  VARCHAR2(1000);
	l_entity_index      NUMBER;
	l_entity_id         VARCHAR2(100);
	l_message_type      VARCHAR2(100);
	l_description       VARCHAR2(240);
	l_Expand_Parent       VARCHAR2(100);
	temp NUMBER;
	l_output_dir  VARCHAR2(512);
        l_err_text      VARCHAR2(2000);
        l_eam_failure_entry_record eam_process_failure_entry_pub.eam_failure_entry_record_typ ;
        l_eam_failure_codes_tbl    eam_process_failure_entry_pub.eam_failure_codes_tbl_typ;


BEGIN

 SAVEPOINT CREATE_WO;

  l_eam_failure_entry_record := x_eam_failure_entry_record;
  l_eam_failure_codes_tbl    := x_eam_failure_codes_tbl;


  /* get output directory path from database */
   EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

              l_user_id := fnd_global.user_id;
              l_workorder_rec.user_id := l_user_id;
              l_responsibility_id := fnd_global.resp_id;
              l_workorder_rec.responsibility_id := l_responsibility_id;
              l_workorder_rec.header_id  := 1;
              l_workorder_rec.batch_id   := 1;
              --l_workorder_rec.p_commit := FND_API.G_TRUE;

              l_workorder_rec.return_status := null;
              l_workorder_rec.wip_entity_name := X_Wip_Entity_Name;
              l_workorder_rec.wip_entity_id := null;
              l_workorder_rec.organization_id := X_organization_id;
              l_workorder_rec.description := X_description;
              l_workorder_rec.asset_number := X_asset_number;
              l_workorder_rec.asset_group_id := X_asset_group_id;
              l_workorder_rec.rebuild_serial_number := X_rebuild_serial_number;
              l_workorder_rec.rebuild_item_id := X_rebuild_item_id;
              l_workorder_rec.parent_wip_entity_id := X_parent_wip_entity_id;



              l_workorder_rec.firm_planned_flag := X_firm_planned_flag;

              l_workorder_rec.owning_department := X_owning_department;
              l_workorder_rec.scheduled_start_date := X_scheduled_start_date;
              l_workorder_rec.scheduled_completion_date := X_scheduled_completion_date;
              l_workorder_rec.status_type := X_status_type;

              l_workorder_rec.user_defined_status_id := X_user_defined_status_id;
              l_workorder_rec.pending_flag := X_pending_flag;
              l_workorder_rec.workflow_type := X_workflow_type;
              l_workorder_rec.warranty_claim_status := X_warranty_claim_status;
              l_workorder_rec.material_shortage_flag := X_material_shortage_flag;
              l_workorder_rec.material_shortage_check_date := X_material_shortage_check_date;

	      l_workorder_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
              l_workorder_rec.maintenance_object_id := X_maintenance_object_id;
      	      l_workorder_rec.maintenance_object_type := X_maintenance_object_type;
      	      l_workorder_rec.maintenance_object_source := X_maintenance_object_source;

               l_workorder_rec.asset_activity_id := X_primary_item_id;
      	      l_workorder_rec.activity_type := X_activity_type;
      	      l_workorder_rec.activity_cause := X_activity_cause;
      	      l_workorder_rec.activity_source := X_activity_source;
      	      l_workorder_rec.shutdown_type:=X_shutdown_type;
      	      l_workorder_rec.work_order_type := X_work_order_type;
              l_workorder_rec.priority := X_priority;
              l_workorder_rec.project_id := X_Project_Id;
              l_workorder_rec.task_id := X_Task_Id;
              l_workorder_rec.material_issue_by_mo := X_material_issue_by_mo;
              l_workorder_rec.manual_rebuild_flag  := X_manual_rebuild_flag;
	      l_workorder_rec.requested_start_date :=   X_requested_start_date;
              l_workorder_rec.due_date   :=  X_requested_due_date;
              l_workorder_rec.notification_required := X_notification_required;
              l_workorder_rec.tagout_required      := X_tagout_required;
              l_workorder_rec.plan_maintenance     := X_plan_maintenance;
              l_workorder_rec.pm_schedule_id       := X_pm_schedule_id;
              l_workorder_rec.wip_supply_type    := X_wip_supply_type;
              l_workorder_rec.class_code        :=  X_class_code;
              l_workorder_rec.material_account := X_material_account;
  	      l_workorder_rec.material_overhead_account:= X_material_overhead_account;
              l_workorder_rec.resource_account  := X_resource_account;
              l_workorder_rec.outside_processing_account := X_outside_processing_account;
              l_workorder_rec.material_variance_account  :=  X_material_variance_account;
              l_workorder_rec.resource_variance_account  := X_resource_variance_account;
              l_workorder_rec.outside_proc_variance_account  :=  X_outside_proc_var_account;
              l_workorder_rec.std_cost_adjustment_account  := X_std_cost_adjustment_account;
               l_workorder_rec.overhead_account   :=  X_overhead_account;
              l_workorder_rec.overhead_variance_account  := X_overhead_variance_account;
             -- l_workorder_rec.common_routing_reference_id   := X_routing_reference_id;
              l_workorder_rec.common_bom_sequence_id  := X_common_bom_sequence_id;
              l_workorder_rec.common_routing_sequence_id  := X_common_routing_sequence_id;
              l_workorder_rec.bom_revision   := X_bom_revision;
              l_workorder_rec.routing_revision   := X_routing_revision;
              l_workorder_rec.bom_revision_date   :=   X_bom_revision_date;
              l_workorder_rec.routing_revision_date   :=   X_routing_revision_date;
	      l_workorder_rec.alternate_bom_designator  :=  X_alternate_bom_designator;
 	      l_workorder_rec.alternate_routing_designator  :=   X_alternate_routing_designator;
               l_workorder_rec.Schedule_Group_Id   :=  X_Schedule_Group_Id;
              l_workorder_rec.attribute_category :=  X_attribute_category;
              l_workorder_rec.attribute1 :=  X_attribute1;
              l_workorder_rec.attribute2 :=  X_attribute2;
	      l_workorder_rec.attribute3 :=  X_attribute3;
              l_workorder_rec.attribute4 :=  X_attribute4;
              l_workorder_rec.attribute5 :=  X_attribute5;
              l_workorder_rec.attribute6 :=  X_attribute6;
              l_workorder_rec.attribute7 :=  X_attribute7;
              l_workorder_rec.attribute8 :=  X_attribute8;
              l_workorder_rec.attribute9 :=  X_attribute9;
              l_workorder_rec.attribute10 :=  X_attribute10;
              l_workorder_rec.attribute11 :=  X_attribute11;
              l_workorder_rec.attribute12 :=  X_attribute12;
              l_workorder_rec.attribute13 :=  X_attribute13;
              l_workorder_rec.attribute14 :=  X_attribute14;
              l_workorder_rec.attribute15 :=  X_attribute15;
              l_workorder_rec.end_item_unit_number   :=   X_end_item_unit_number;
              l_workorder_rec.po_creation_time  :=   X_po_creation_time;
	      l_workorder_rec.failure_code_required := x_failure_code_required;
              IF l_eam_failure_entry_record.failure_date IS NULL THEN
			l_eam_failure_entry_record.transaction_type := NULL;
              ELSE
			l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE ;
              END IF;
             l_workorder_rec.eam_failure_entry_record := l_eam_failure_entry_record;
             FOR i in 1..l_eam_failure_codes_tbl.count
	     LOOP
	             IF( NOT( l_eam_failure_codes_tbl(i).failure_code IS NULL
		              AND l_eam_failure_codes_tbl(i).cause_code IS NULL
			      AND l_eam_failure_codes_tbl(i).resolution_code IS NULL
	                      AND l_eam_failure_codes_tbl(i).comments IS NULL
		             )) THEN
					     l_eam_failure_codes_tbl(i).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE;
					     l_workorder_rec.eam_failure_codes_tbl(i) := l_eam_failure_codes_tbl(i);
		     ELSE
					     l_workorder_rec.eam_failure_codes_tbl(i) := l_eam_failure_codes_tbl(i);
					     l_workorder_rec.eam_failure_codes_tbl.delete(i);
		     END IF;
             END LOOP;
     l_eam_wo_tbl(1) := l_workorder_rec;

/*--Construct table for relationships if X_Parent_Wip_Id is not null*/
if(X_parent_wip_entity_id is not null) then
    l_eam_wo_relations_rec1.batch_id  :=  1;
     l_eam_wo_relations_rec1.parent_object_id := X_parent_wip_entity_id;
     l_eam_wo_relations_rec1.parent_object_type_id := 1;
     l_eam_wo_relations_rec1.parent_header_id := X_parent_wip_entity_id;
     l_eam_wo_relations_rec1.child_object_type_id := 1;
     l_eam_wo_relations_rec1.child_header_id    :=1;
     l_eam_wo_relations_rec1.child_object_id := 1;
     l_eam_wo_relations_rec1.parent_relationship_type  := 1;
     l_eam_wo_relations_rec1.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
     l_eam_wo_relations_tbl(1) := l_eam_wo_relations_rec1;

     l_eam_wo_relations_rec2.batch_id  :=  1;
     l_eam_wo_relations_rec2.parent_object_id :=X_parent_wip_entity_id;
     l_eam_wo_relations_rec2.parent_object_type_id := 1;
     l_eam_wo_relations_rec2.parent_header_id := X_parent_wip_entity_id;
     l_eam_wo_relations_rec2.child_object_type_id := 1;
     l_eam_wo_relations_rec2.child_header_id    :=1;
     l_eam_wo_relations_rec2.child_object_id := 1;
     l_eam_wo_relations_rec2.parent_relationship_type  := 4;
     l_eam_wo_relations_rec2.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
     l_eam_wo_relations_tbl(2) := l_eam_wo_relations_rec2;
end if;

begin
      EAM_PROCESS_WO_PUB.Process_Master_Child_WO
  	         ( p_bo_identifier           => 'EAM'
  	         , p_init_msg_list           => TRUE
  	         , p_api_version_number      => 1.0
  	         , p_eam_wo_tbl              => l_eam_wo_tbl
                 , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
  	         , p_eam_op_tbl              => l_eam_op_tbl
  	         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  	         , p_eam_res_tbl             => l_eam_res_tbl
  	         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  	         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
    	         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                 , p_eam_direct_items_tbl    => l_eam_direct_items_tbl

		 , p_eam_wo_comp_tbl         => l_eam_wo_comp_tbl
		 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
		 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
		 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
		 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
		 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
		 , p_eam_request_tbl         => l_eam_request_tbl

  	         , x_eam_wo_tbl              => l_eam_wo_tbl1
                 , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl1
  	         , x_eam_op_tbl              => l_eam_op_tbl1
  	         , x_eam_op_network_tbl      => l_eam_op_network_tbl1
  	         , x_eam_res_tbl             => l_eam_res_tbl1
  	         , x_eam_res_inst_tbl        => l_eam_res_inst_tbl1
  	         , x_eam_sub_res_tbl         => l_eam_sub_res_tbl1
		 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
  	         , x_eam_mat_req_tbl         => l_eam_mat_req_tbl1
                 , x_eam_direct_items_tbl =>   l_eam_direct_items_tbl_1

		 , x_eam_wo_comp_tbl         => l_eam_wo_comp_tbl_1
		 , x_eam_wo_quality_tbl      => l_eam_wo_quality_tbl_1
		 , x_eam_meter_reading_tbl   => l_eam_meter_reading_tbl_1
		 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		 , x_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl_1
		 , x_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl_1
		 , x_eam_op_comp_tbl         => l_eam_op_comp_tbl_1
		 , x_eam_request_tbl         => l_eam_request_tbl_1

  	         , x_return_status           => l_return_status
  	         , x_msg_count               => l_msg_count
  	         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  	         , p_debug_filename          => 'createwo.log'
  	         , p_output_dir              => l_output_dir
                 , p_commit                    => FND_API.G_FALSE
                 , p_debug_file_mode         => 'W'
           );
 exception
    when others then
                 rollback to CREATE_WO;
                l_msg_count := fnd_msg_pub.count_msg;
                   if(l_msg_count>0) then
 			  get_all_mesg(mesg=>l_message_text);
                   end if;
           	          fnd_message.set_name('EAM','EAM_ERROR_CREATE_WO');

           		fnd_message.set_token(token => 'MESG',
			  	  value => l_message_text,
			  	  translate => FALSE);
           		APP_EXCEPTION.RAISE_EXCEPTION;
 end;

   l_workorder_rec1 := l_eam_wo_tbl1(l_eam_wo_tbl1.first);


  if((nvl(l_return_status,'S'))='S') then

       X_wip_entity_id := l_workorder_rec1.wip_entity_id;

       select rowid into X_We_Rowid from WIP_ENTITIES where wip_entity_id=X_wip_entity_id;
       select rowid into X_Rowid from WIP_DISCRETE_JOBS where wip_entity_id=X_wip_entity_id;
       COMMIT;

   else
        X_wip_entity_id := 0;
        rollback to CREATE_WO;

                    l_msg_count := fnd_msg_pub.count_msg;
                   if(l_msg_count>0) then
 			  get_all_mesg(mesg=>l_message_text);
                   end if;
           	          fnd_message.set_name('EAM','EAM_ERROR_CREATE_WO');

           		fnd_message.set_token(token => 'MESG',
			  	  value => l_message_text,
			  	  translate => FALSE);
           		APP_EXCEPTION.RAISE_EXCEPTION;
   end if;


if(X_Parent_Wip_Name is not null and X_parent_wip_entity_id is null) then
 savepoint create_relation;

    select wip_entity_id
    into temp
    from wip_entities
    where wip_entity_name = X_Parent_Wip_Name AND organization_id=X_organization_id ;


     l_eam_wo_relations_rec3.batch_id  :=  1;
     l_eam_wo_relations_rec3.parent_object_id := temp;
     l_eam_wo_relations_rec3.parent_object_type_id := 1;
     l_eam_wo_relations_rec3.parent_header_id := temp;
     l_eam_wo_relations_rec3.child_object_type_id := 1;
     l_eam_wo_relations_rec3.child_header_id    :=X_wip_entity_id;
     l_eam_wo_relations_rec3.child_object_id := X_wip_entity_id;
     l_eam_wo_relations_rec3.parent_relationship_type  := 1;
     l_eam_wo_relations_rec3.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;


      l_eam_wo_relations_tbl2(1) := l_eam_wo_relations_rec3;

       EAM_PROCESS_WO_PUB.Process_Master_Child_WO
  	         ( p_bo_identifier           => 'EAM'
  	         , p_init_msg_list           => TRUE
  	         , p_api_version_number      => 1.0
  	         , p_eam_wo_tbl              => l_eam_wo_tbl2
                 , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl2
  	         , p_eam_op_tbl              => l_eam_op_tbl
  	         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  	         , p_eam_res_tbl             => l_eam_res_tbl
  	         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  	         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
    	         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                 , p_eam_direct_items_tbl  =>   l_eam_direct_items_tbl

	 	 , p_eam_wo_comp_tbl         => l_eam_wo_comp_tbl
		 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
		 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
		 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
		 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
		 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
		 , p_eam_request_tbl         => l_eam_request_tbl

  	         , x_eam_wo_tbl              => l_eam_wo_tbl1
                 , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl1
  	         , x_eam_op_tbl              => l_eam_op_tbl1
  	         , x_eam_op_network_tbl      => l_eam_op_network_tbl1
  	         , x_eam_res_tbl             => l_eam_res_tbl1
  	         , x_eam_res_inst_tbl        => l_eam_res_inst_tbl1
  	         , x_eam_sub_res_tbl         => l_eam_sub_res_tbl1
		 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
  	         , x_eam_mat_req_tbl         => l_eam_mat_req_tbl1
                 , x_eam_direct_items_tbl =>   l_eam_direct_items_tbl_1

		 , x_eam_wo_comp_tbl         => l_eam_wo_comp_tbl_1
		 , x_eam_wo_quality_tbl      => l_eam_wo_quality_tbl_1
		 , x_eam_meter_reading_tbl   => l_eam_meter_reading_tbl_1
		 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		 , x_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl_1
		 , x_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl_1
		 , x_eam_op_comp_tbl         => l_eam_op_comp_tbl_1
		 , x_eam_request_tbl         => l_eam_request_tbl_1

  	         , x_return_status           => l_return_status
  	         , x_msg_count               => l_msg_count
  	         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  	         , p_debug_filename          => 'createrel.log'
  	         , p_output_dir              => l_output_dir
                 , p_commit                    => FND_API.G_FALSE
                 , p_debug_file_mode         => 'W'
           );
    X_Relation_Status := l_return_status;
     if((nvl(l_return_status,'S'))='S') then
       commit;
     else
       rollback to create_relation;
     end if;


end if;


/*copy the values from the wo api back to the out parameters */

		X_description:=l_workorder_rec1.description ;
		X_firm_planned_flag :=l_workorder_rec1.firm_planned_flag;
		X_owning_department :=l_workorder_rec1.owning_department ;
		X_scheduled_start_date := l_workorder_rec1.scheduled_start_date ;
		X_scheduled_completion_date := l_workorder_rec1.scheduled_completion_date;
		X_status_type := l_workorder_rec1.status_type;
		X_user_defined_status_id :=l_workorder_rec1.user_defined_status_id ;
		X_pending_flag:= l_workorder_rec1.pending_flag ;
		X_workflow_type := l_workorder_rec1.workflow_type ;
		X_warranty_claim_status := l_workorder_rec1.warranty_claim_status ;
		X_material_shortage_flag := l_workorder_rec1.material_shortage_flag ;
		X_material_shortage_check_date := l_workorder_rec1.material_shortage_check_date ;

		X_activity_type:= l_workorder_rec1.activity_type;
		X_activity_cause:= l_workorder_rec1.activity_cause;
		X_activity_source := l_workorder_rec1.activity_source;
		X_shutdown_type := l_workorder_rec1.shutdown_type;
		X_work_order_type := l_workorder_rec1.work_order_type;
		X_priority := l_workorder_rec1.priority;
		X_material_issue_by_mo := l_workorder_rec1.material_issue_by_mo;
		X_manual_rebuild_flag :=  l_workorder_rec1.manual_rebuild_flag ;
		X_requested_start_date := l_workorder_rec1.requested_start_date;
		X_requested_due_date := l_workorder_rec1.due_date  ;
		X_notification_required := l_workorder_rec1.notification_required;
		X_tagout_required := l_workorder_rec1.tagout_required     ;
		X_plan_maintenance := l_workorder_rec1.plan_maintenance     ;
		X_class_code := l_workorder_rec1.class_code       ;
		X_material_account := l_workorder_rec1.material_account;
		X_material_overhead_account := l_workorder_rec1.material_overhead_account;
		X_resource_account := l_workorder_rec1.resource_account ;
		X_outside_processing_account := l_workorder_rec1.outside_processing_account;
		X_material_variance_account := l_workorder_rec1.material_variance_account  ;
		X_resource_variance_account := l_workorder_rec1.resource_variance_account  ;
		X_outside_proc_var_account := l_workorder_rec1.outside_proc_variance_account  ;
		X_std_cost_adjustment_account := l_workorder_rec1.std_cost_adjustment_account ;
		X_overhead_account :=  l_workorder_rec1.overhead_account  ;
		X_overhead_variance_account := l_workorder_rec1.overhead_variance_account  ;
		X_common_bom_sequence_id := l_workorder_rec1.common_bom_sequence_id  ;
		X_common_routing_sequence_id := l_workorder_rec1.common_routing_sequence_id  ;
		X_bom_revision := l_workorder_rec1.bom_revision   ;
		X_routing_revision:=  l_workorder_rec1.routing_revision  ;
		X_bom_revision_date := l_workorder_rec1.bom_revision_date  ;
		X_routing_revision_date := l_workorder_rec1.routing_revision_date  ;
		X_alternate_bom_designator := l_workorder_rec1.alternate_bom_designator ;
		X_alternate_routing_designator := l_workorder_rec1.alternate_routing_designator  ;
		X_attribute_category := l_workorder_rec1.attribute_category ;
		X_attribute1 := l_workorder_rec1.attribute1;
		X_attribute2 := l_workorder_rec1.attribute2;
		X_attribute3 := l_workorder_rec1.attribute3 ;
		X_attribute4 := l_workorder_rec1.attribute4;
		X_attribute5 := l_workorder_rec1.attribute5 ;
		X_attribute6 := l_workorder_rec1.attribute6 ;
		X_attribute7 := l_workorder_rec1.attribute7 ;
		X_attribute8 := l_workorder_rec1.attribute8;
		X_attribute9 := l_workorder_rec1.attribute9 ;
		X_attribute10 := l_workorder_rec1.attribute10;
		X_attribute11 := l_workorder_rec1.attribute11;
		X_attribute12 := l_workorder_rec1.attribute12;
		X_attribute13 := l_workorder_rec1.attribute13;
		X_attribute14 := l_workorder_rec1.attribute14 ;
		X_attribute15 := l_workorder_rec1.attribute15 ;
		x_failure_code_required  := l_workorder_rec1.failure_code_required;
                x_eam_failure_entry_record := l_workorder_rec1.eam_failure_entry_record;
                x_eam_failure_codes_tbl    := l_workorder_rec1.eam_failure_codes_tbl;



/*end of copy params */


    -- asset genealogy is updated when a automatic work order is created for a a rebuild serial number
    -- which is part of an asset hierarchy. bug number  2899984
 if (X_rebuild_serial_number is not null) then

 Update_Genealogy(    X_wip_entity_id               => X_wip_entity_id,
                                         X_organization_id             =>X_Organization_id,
                                         X_parent_wip_entity_id	       =>X_parent_wip_entity_id,
 		                                 X_rebuild_item_id	           => X_rebuild_item_id,
 		                                 X_rebuild_serial_number       =>X_rebuild_serial_number,
 		                                 X_manual_rebuild_flag	       =>X_manual_rebuild_flag,
										 x_maintenance_object_type     => x_maintenance_object_type ,
										 x_maintenance_object_id       => x_maintenance_object_id);

 end if;


-- Bug # 2251186

IF ( X_primary_item_id IS NOT NULL ) THEN

         CSTPECEP.Estimate_WorkOrder_Grp(
        p_api_version => 1.0,
        p_init_msg_list => fnd_api.g_false,
        p_commit  =>  fnd_api.g_false,
        p_validation_level  => fnd_api.g_valid_level_full,
        p_wip_entity_id => X_wip_entity_id,
        p_organization_id => X_Organization_Id,
        x_return_status      => l_return_status,
        x_msg_data           => l_err_text,
        x_msg_count          => l_msg_count );

END IF;

END Create_Workorder;


/*cboppana ----Added this function to update a work order.This calls the Work Order api */

PROCEDURE Update_Workorder( X_Rowid 			VARCHAR2,
		X_wip_entity_id			NUMBER,
		X_organization_id		NUMBER,
		X_last_update_date		DATE,
		X_last_updated_by		NUMBER,
		X_creation_date			DATE,
		X_created_by			NUMBER,
		X_last_update_login		NUMBER,
		X_description		IN OUT NOCOPY 	VARCHAR2,
		X_status_type		IN OUT NOCOPY	NUMBER,

		X_user_defined_status_id IN OUT NOCOPY	NUMBER,
		X_pending_flag		IN OUT NOCOPY	VARCHAR2,
		X_workflow_type		IN OUT NOCOPY	NUMBER ,
		X_warranty_claim_status	IN OUT NOCOPY	NUMBER,

		X_material_shortage_flag	IN OUT NOCOPY	NUMBER,
		X_material_shortage_check_date	IN OUT NOCOPY	DATE,

		X_primary_item_id		NUMBER,
		X_parent_wip_entity_id		NUMBER,
		X_asset_number			VARCHAR2,
		X_asset_group_id		NUMBER,
		X_pm_schedule_id		NUMBER,
		X_rebuild_item_id		NUMBER,
		X_rebuild_serial_number		VARCHAR2,
		X_manual_rebuild_flag	IN OUT NOCOPY	VARCHAR2,
		X_shutdown_type		IN OUT NOCOPY	VARCHAR2,
		X_tagout_required	IN OUT NOCOPY	VARCHAR2,
		X_plan_maintenance	IN OUT NOCOPY	VARCHAR2,
		X_estimation_status		VARCHAR2,
		X_requested_start_date	IN OUT NOCOPY	DATE,
		X_requested_due_date	IN OUT NOCOPY	DATE,
		X_notification_required	IN OUT NOCOPY	VARCHAR2,
		X_work_order_type	IN OUT NOCOPY	VARCHAR2,
		X_owning_department	IN OUT NOCOPY	NUMBER,
		X_activity_type		IN OUT NOCOPY	VARCHAR2,
		X_activity_cause	IN OUT NOCOPY	VARCHAR2,
		X_firm_planned_flag	IN OUT NOCOPY	NUMBER,
		X_class_code		IN OUT NOCOPY	VARCHAR2,
		X_material_account	IN OUT NOCOPY	NUMBER,
		X_material_overhead_account IN OUT NOCOPY	NUMBER,
		X_resource_account	IN OUT NOCOPY	NUMBER,
		X_outside_processing_account IN OUT NOCOPY	NUMBER,
		X_material_variance_account IN OUT NOCOPY	NUMBER,
		X_resource_variance_account IN OUT NOCOPY	NUMBER,
		X_outside_proc_var_account IN OUT NOCOPY	NUMBER,
		X_std_cost_adjustment_account IN OUT NOCOPY	NUMBER,
		X_overhead_account	IN OUT NOCOPY	NUMBER,
		X_overhead_variance_account IN OUT NOCOPY	NUMBER,
		X_scheduled_start_date	IN OUT NOCOPY	DATE,
		X_date_released			DATE,
		X_scheduled_completion_date IN OUT NOCOPY	DATE,
		X_date_completed		DATE,
		X_date_closed			DATE,
		X_bom_reference_id	NUMBER,
		X_routing_reference_id	 	NUMBER,
		X_common_bom_sequence_id IN OUT NOCOPY	NUMBER,
		X_common_routing_sequence_id IN OUT NOCOPY	NUMBER,
		X_bom_revision		IN OUT NOCOPY	VARCHAR2,
		X_routing_revision	IN OUT NOCOPY	VARCHAR2,
		X_bom_revision_date	IN OUT NOCOPY	DATE,
		X_routing_revision_date	IN OUT NOCOPY	DATE,
		X_lot_number			VARCHAR2,
		X_alternate_bom_designator IN OUT NOCOPY	VARCHAR2,
		X_alternate_routing_designator IN OUT NOCOPY	VARCHAR2,
		X_completion_subinventory 	VARCHAR2,
		X_completion_locator_id	 	NUMBER,
		X_demand_class			VARCHAR2,
		X_attribute_category	IN OUT NOCOPY	VARCHAR2,
		X_attribute1	IN OUT NOCOPY		VARCHAR2,
		X_attribute2	IN OUT NOCOPY		VARCHAR2,
		X_attribute3	IN OUT NOCOPY		VARCHAR2,
		X_attribute4	IN OUT NOCOPY		VARCHAR2,
		X_attribute5	IN OUT NOCOPY		VARCHAR2,
		X_attribute6	IN OUT NOCOPY		VARCHAR2,
		X_attribute7	IN OUT NOCOPY		VARCHAR2,
		X_attribute8	IN OUT NOCOPY		VARCHAR2,
		X_attribute9	IN OUT NOCOPY		VARCHAR2,
		X_attribute10	IN OUT NOCOPY		VARCHAR2,
		X_attribute11	IN OUT NOCOPY		VARCHAR2,
		X_attribute12	IN OUT NOCOPY		VARCHAR2,
		X_attribute13	IN OUT NOCOPY		VARCHAR2,
		X_attribute14	IN OUT NOCOPY		VARCHAR2,
		X_attribute15	IN OUT NOCOPY		VARCHAR2,
		X_We_Rowid		IN OUT NOCOPY	VARCHAR2,
		X_Entity_Type			NUMBER,
		X_Wip_Entity_Name		VARCHAR2,
		X_Update_Wip_Entities		VARCHAR2,
                X_Schedule_Group_Id             NUMBER,
		X_Project_Id			NUMBER,
		X_Task_Id			NUMBER,
                X_priority        IN OUT NOCOPY        NUMBER,
                X_maintenance_object_id         NUMBER,
		X_maintenance_object_source     NUMBER,
		X_maintenance_object_type      NUMBER,
		X_material_issue_by_mo  IN OUT NOCOPY        VARCHAR2,
		X_activity_source      IN OUT NOCOPY         VARCHAR2,
                X_old_rebuild_source            NUMBER := NULL,
		x_failure_code_required  IN OUT NOCOPY VARCHAR2,
                x_eam_failure_entry_record IN OUT NOCOPY eam_process_failure_entry_pub.eam_failure_entry_record_typ,
                x_eam_failure_codes_tbl    IN OUT NOCOPY eam_process_failure_entry_pub.eam_failure_codes_tbl_typ,
                x_return_status IN OUT NOCOPY VARCHAR2 /*7003588*/
                ) IS


	dummy NUMBER;
	l_return_status  VARCHAR2(80) :='';
	l_msg_data       VARCHAR2(2000) := '';
        l_msg_count      NUMBER;


	l_workorder_rec		EAM_PROCESS_WO_PUB.eam_wo_rec_type;
	l_workorder_rec1	EAM_PROCESS_WO_PUB.eam_wo_rec_type;
	l_eam_op_tbl		EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_op_tbl1		EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_op_tbl2		EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_op_network_tbl	EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_op_network_tbl1	EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_op_network_tbl2	EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_res_tbl		EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_res_tbl1		EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_res_tbl2		EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_res_inst_tbl	EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_res_inst_tbl1	EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_res_inst_tbl2	EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_sub_res_tbl	EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_sub_res_tbl1	EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_sub_res_tbl2	EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_res_usage_tbl	EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_eam_res_usage_tbl1	EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_eam_res_usage_tbl2	EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_eam_mat_req_tbl	EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_eam_mat_req_tbl1	EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_eam_mat_req_tbl2	EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
        l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
        l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
        l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
        l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
        l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;

	l_eam_direct_items_tbl	    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_eam_direct_items_tbl_1    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

	l_eam_wo_relations_tbl      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_relations_tbl1     EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_relations_rec1     EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
	l_eam_wo_relations_rec2     EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
	l_eam_wo_relations_rec3     EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
	l_eam_wo_relations_rec4     EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
	l_eam_wo_relations_rec5     EAM_PROCESS_WO_PUB.eam_wo_relations_rec_type;
	l_eam_wo_tbl                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl1               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl2               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_tbl3               EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_wo_comp_tbl_1         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
        l_eam_wo_quality_tbl_1      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
        l_eam_meter_reading_tbl_1   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
        l_eam_wo_comp_rebuild_tbl_1 EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
        l_eam_wo_comp_mr_read_tbl_1 EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
        l_eam_op_comp_tbl_1         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl_1         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;


	l_eam_msg_tbl  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;

	l_user_id NUMBER;
	l_responsibility_id NUMBER;

	l_message_text  VARCHAR2(1000);
	l_entity_index      NUMBER;
	l_entity_id         VARCHAR2(100);
	l_message_type      VARCHAR2(100);
	l_description       VARCHAR2(100);
	l_Expand_Parent       VARCHAR2(100);
	constraining_rel NUMBER;
	followup_rel  NUMBER;
	l_old_rebuild_source NUMBER := null;
	record_count number :=1;
	l_output_dir  VARCHAR2(512);
	l_prev_activity_id NUMBER := null;

	/* Added for bug#4555609 */
    l_prev_description VARCHAR2(240);
    l_prev_priority NUMBER;
    l_prev_work_order_type  VARCHAR2(30);
    l_prev_shutdown_type VARCHAR2(30);
    l_prev_activity_type VARCHAR2(30);
    l_prev_activity_cause VARCHAR2(30);
    l_prev_activity_source VARCHAR2(30);
    l_prev_attribute_category VARCHAR2(30);
    l_prev_attribute1 VARCHAR2(150);
    l_prev_attribute2 VARCHAR2(150);
    l_prev_attribute3 VARCHAR2(150);
    l_prev_attribute4 VARCHAR2(150);
    l_prev_attribute5 VARCHAR2(150);
    l_prev_attribute6 VARCHAR2(150);
    l_prev_attribute7 VARCHAR2(150);
    l_prev_attribute8 VARCHAR2(150);
    l_prev_attribute9 VARCHAR2(150);
    l_prev_attribute10 VARCHAR2(150);
    l_prev_attribute11 VARCHAR2(150);
    l_prev_attribute12 VARCHAR2(150);
    l_prev_attribute13 VARCHAR2(150);
    l_prev_attribute14 VARCHAR2(150);
    l_prev_attribute15 VARCHAR2(150);
    l_eam_failure_entry_record eam_process_failure_entry_pub.eam_failure_entry_record_typ;
    l_eam_failure_codes_tbl eam_process_failure_entry_pub.eam_failure_codes_tbl_typ;

    /* Added for bug#5346446 Start */
    l_prev_project_id  NUMBER;
    l_prev_task_id     NUMBER;
    /* Added for bug#5346446 End */


BEGIN
   l_eam_failure_entry_record := x_eam_failure_entry_record;
   l_eam_failure_codes_tbl := x_eam_failure_codes_tbl;


/* get output directory path from database */
    EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


              l_user_id := fnd_global.user_id;
              l_responsibility_id := fnd_global.resp_id;

              l_workorder_rec.header_id  := X_wip_Entity_Id;
              l_workorder_rec.batch_id   := 1;
              --l_workorder_rec.p_commit := FND_API.G_TRUE;

              l_workorder_rec.return_status := null;
              l_workorder_rec.wip_entity_name := X_Wip_Entity_Name;
              l_workorder_rec.wip_entity_id := X_wip_Entity_Id;
              l_workorder_rec.organization_id := X_organization_id;
              l_workorder_rec.asset_number := X_asset_number;
              l_workorder_rec.asset_group_id := X_asset_group_id;
              l_workorder_rec.rebuild_serial_number := X_rebuild_serial_number;
              l_workorder_rec.rebuild_item_id := X_rebuild_item_id;
              l_workorder_rec.parent_wip_entity_id := X_parent_wip_entity_id;
              l_workorder_rec.firm_planned_flag := X_firm_planned_flag;
              l_workorder_rec.owning_department := X_owning_department;
              l_workorder_rec.scheduled_start_date := X_scheduled_start_date;
              l_workorder_rec.scheduled_completion_date := X_scheduled_completion_date;
              l_workorder_rec.status_type := X_status_type;

              l_workorder_rec.user_defined_status_id := X_user_defined_status_id;
              l_workorder_rec.pending_flag := X_pending_flag;
              l_workorder_rec.workflow_type := X_workflow_type;
              l_workorder_rec.warranty_claim_status := X_warranty_claim_status;
              l_workorder_rec.material_shortage_flag := X_material_shortage_flag;
              l_workorder_rec.material_shortage_check_date := X_material_shortage_check_date;

	      l_workorder_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
              l_workorder_rec.maintenance_object_id := X_maintenance_object_id;
      	      l_workorder_rec.maintenance_object_type := X_maintenance_object_type;
      	      l_workorder_rec.maintenance_object_source := X_maintenance_object_source;

             -- # 3436679   code added to prevent the defaulting of the asset activity if user removes it while updating work order

	      BEGIN
								select primary_item_id
								,description
								,priority
								,work_order_type
								,shutdown_type
								,activity_type
								,activity_cause
								,activity_source
								,attribute_category
								,attribute1
								,attribute2
								,attribute3
								,attribute4
								,attribute5
								,attribute6
								,attribute7
								,attribute8
								,attribute9
								,attribute10
								,attribute11
								,attribute12
								,attribute13
								,attribute14
								,attribute15
								,project_id -- added for bug 5346446
								,task_id
								into l_prev_activity_id
								,l_prev_description
								,l_prev_priority
								,l_prev_work_order_type
								,l_prev_shutdown_type
								,l_prev_activity_type
								,l_prev_activity_cause
								,l_prev_activity_source
								,l_prev_attribute_category
								,l_prev_attribute1
								,l_prev_attribute2
								,l_prev_attribute3
								,l_prev_attribute4
								,l_prev_attribute5
								,l_prev_attribute6
								,l_prev_attribute7
								,l_prev_attribute8
								,l_prev_attribute9
								,l_prev_attribute10
								,l_prev_attribute11
								,l_prev_attribute12
								,l_prev_attribute13
								,l_prev_attribute14
								,l_prev_attribute15
								,l_prev_project_id  --added for bug 5346446
								,l_prev_task_id
								from wip_discrete_jobs
								where wip_entity_id =X_wip_Entity_Id
								and organization_id = X_organization_id;

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  null;

	      END;

	      IF l_prev_activity_id is not null and X_primary_item_id is null THEN
			l_workorder_rec.asset_activity_id  := FND_API.G_MISS_NUM;
		ELSE
			l_workorder_rec.asset_activity_id := X_primary_item_id;
	       END IF;

	      IF l_prev_description is not null and X_description is null THEN
                        l_workorder_rec.description := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.description := X_description;
              END IF;

              IF l_prev_activity_type is not null and X_activity_type is null THEN
                        l_workorder_rec.activity_type  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.activity_type := X_activity_type;
              END IF;

              IF l_prev_activity_cause is not null and X_activity_cause is null THEN
                        l_workorder_rec.activity_cause  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.activity_cause := X_activity_cause;
              END IF;

              IF l_prev_activity_source is not null and X_activity_source is null THEN
                        l_workorder_rec.activity_source  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.activity_source := X_activity_source;
              END IF;

              IF l_prev_shutdown_type is not null and X_shutdown_type is null THEN
                        l_workorder_rec.shutdown_type  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.shutdown_type := X_shutdown_type;
              END IF;

              IF l_prev_priority is not null and X_priority is null THEN
                        l_workorder_rec.priority  := FND_API.G_MISS_NUM;
              ELSE
                        l_workorder_rec.priority := X_priority;
              END IF;

              IF l_prev_work_order_type is not null and X_work_order_type is null THEN
                        l_workorder_rec.work_order_type  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.work_order_type := X_work_order_type;
              END IF;

              /* Added for bug#5346446 Start */
              IF l_prev_project_id is not null AND X_Project_Id is null THEN
                 l_workorder_rec.project_id := FND_API.G_MISS_NUM;
              ELSE
                 l_workorder_rec.project_id := X_Project_Id;
              END IF;

              IF l_prev_task_id is not null AND X_Task_Id is null THEN
                 l_workorder_rec.task_id := FND_API.G_MISS_NUM;
              ELSE
                 l_workorder_rec.task_id := X_Task_Id;
              END IF;

              /* Added for bug#5346446 End */

              /* Commented for bug#5346446 Start
              l_workorder_rec.project_id := X_Project_Id;
              l_workorder_rec.task_id := X_Task_Id;
              Commented for bug#5346446 End */

              l_workorder_rec.material_issue_by_mo := X_material_issue_by_mo;

              -- Set user id and responsibility id so that we can set apps context
              -- before calling any concurrent program
              l_workorder_rec.user_id := l_user_id;
              l_workorder_rec.responsibility_id := l_responsibility_id;

              l_workorder_rec.manual_rebuild_flag  := X_manual_rebuild_flag;
	      l_workorder_rec.requested_start_date :=   X_requested_start_date;
              l_workorder_rec.due_date   :=  X_requested_due_date;
              l_workorder_rec.notification_required := X_notification_required;
              l_workorder_rec.tagout_required      := X_tagout_required;
              l_workorder_rec.plan_maintenance     := X_plan_maintenance;
              l_workorder_rec.pm_schedule_id       := X_pm_schedule_id;

              l_workorder_rec.class_code        :=  X_class_code;
              l_workorder_rec.material_account := X_material_account;
  	      l_workorder_rec.material_overhead_account:= X_material_overhead_account;
              l_workorder_rec.resource_account  := X_resource_account;
              l_workorder_rec.outside_processing_account := X_outside_processing_account;
              l_workorder_rec.material_variance_account  :=  X_material_variance_account;
              l_workorder_rec.resource_variance_account  := X_resource_variance_account;
              l_workorder_rec.outside_proc_variance_account  :=  X_outside_proc_var_account;
              l_workorder_rec.std_cost_adjustment_account  := X_std_cost_adjustment_account;
               l_workorder_rec.overhead_account   :=  X_overhead_account;
              l_workorder_rec.overhead_variance_account  := X_overhead_variance_account;
               l_workorder_rec.common_bom_sequence_id  := X_common_bom_sequence_id;
              l_workorder_rec.common_routing_sequence_id  := X_common_routing_sequence_id;
              l_workorder_rec.bom_revision   := X_bom_revision;
              l_workorder_rec.routing_revision   := X_routing_revision;
              l_workorder_rec.bom_revision_date   :=   X_bom_revision_date;
              l_workorder_rec.routing_revision_date   :=   X_routing_revision_date;
	      l_workorder_rec.alternate_bom_designator  :=  X_alternate_bom_designator;
 	      l_workorder_rec.alternate_routing_designator  :=   X_alternate_routing_designator;
               l_workorder_rec.Schedule_Group_Id   :=  X_Schedule_Group_Id;

              IF l_prev_attribute_category is not null and X_attribute_category is null THEN
                        l_workorder_rec.attribute_category  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute_category := X_attribute_category;
              END IF;

              IF l_prev_attribute1 is not null and X_attribute1 is null THEN
                        l_workorder_rec.attribute1  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute1 := X_attribute1;
              END IF;

              IF l_prev_attribute2 is not null and X_attribute2 is null THEN
                        l_workorder_rec.attribute2  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute2 := X_attribute2;
              END IF;

              IF l_prev_attribute3 is not null and X_attribute3 is null THEN
                        l_workorder_rec.attribute3  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute3 := X_attribute3;
              END IF;

              IF l_prev_attribute4 is not null and X_attribute4 is null THEN
                        l_workorder_rec.attribute4  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute4 := X_attribute4;
              END IF;

              IF l_prev_attribute5 is not null and X_attribute5 is null THEN
                        l_workorder_rec.attribute5  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute5 := X_attribute5;
              END IF;

              IF l_prev_attribute6 is not null and X_attribute6 is null THEN
                        l_workorder_rec.attribute6  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute6 := X_attribute6;
              END IF;

              IF l_prev_attribute7 is not null and X_attribute7 is null THEN
                        l_workorder_rec.attribute7  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute7 := X_attribute7;
              END IF;

              IF l_prev_attribute8 is not null and X_attribute8 is null THEN
                        l_workorder_rec.attribute8  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute8 := X_attribute8;
              END IF;

              IF l_prev_attribute9 is not null and X_attribute9 is null THEN
                        l_workorder_rec.attribute9  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute9 := X_attribute9;
              END IF;

              IF l_prev_attribute10 is not null and X_attribute10 is null THEN
                        l_workorder_rec.attribute10  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute10 := X_attribute10;
              END IF;

              IF l_prev_attribute11 is not null and X_attribute11 is null THEN
                        l_workorder_rec.attribute11  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute11 := X_attribute11;
              END IF;

              IF l_prev_attribute12 is not null and X_attribute12 is null THEN
                        l_workorder_rec.attribute12  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute12 := X_attribute12;
              END IF;

              IF l_prev_attribute13 is not null and X_attribute13 is null THEN
                        l_workorder_rec.attribute13  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute13 := X_attribute13;
              END IF;

              IF l_prev_attribute14 is not null and X_attribute14 is null THEN
                        l_workorder_rec.attribute14  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute14 := X_attribute14;
              END IF;

              IF l_prev_attribute15 is not null and X_attribute15 is null THEN
                        l_workorder_rec.attribute15  := FND_API.G_MISS_CHAR;
              ELSE
                        l_workorder_rec.attribute15 := X_attribute15;
              END IF;

	      IF x_failure_code_required is NULL THEN
                 l_workorder_rec.failure_code_required := FND_API.G_MISS_CHAR;
              ELSE
                 l_workorder_rec.failure_code_required := x_failure_code_required;
              END IF;
              IF (l_eam_failure_entry_record.failure_date IS NULL) THEN
                 l_eam_failure_entry_record.failure_date := FND_API.G_MISS_DATE;
              END IF;
              FOR  i IN 1..l_eam_failure_codes_tbl.count
	      LOOP
		      IF l_eam_failure_codes_tbl(i).failure_code IS NULL THEN
			  l_eam_failure_codes_tbl(i).failure_code := FND_API.G_MISS_CHAR;
		      END IF;
		      IF l_eam_failure_codes_tbl(i).cause_code IS NULL THEN
			 l_eam_failure_codes_tbl(i).cause_code := FND_API.G_MISS_CHAR;
		      END IF;
		      IF l_eam_failure_codes_tbl(i).resolution_code IS NULL THEN
			 l_eam_failure_codes_tbl(i).resolution_code := FND_API.G_MISS_CHAR;
		      END IF;
		      IF l_eam_failure_codes_tbl(i).comments IS NULL THEN
			 l_eam_failure_codes_tbl(i).comments := FND_API.G_MISS_CHAR;
		      END IF;
              END LOOP;

              IF l_eam_failure_entry_record.failure_id IS NOT NULL THEN
                      l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
              ELSIF l_eam_failure_entry_record.failure_date = FND_API.G_MISS_DATE THEN
                   l_eam_failure_entry_record.transaction_type :=null;
              ELSE
                   l_eam_failure_entry_record.transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE ;
              END IF;

	      FOR  i in 1..l_eam_failure_codes_tbl.count
	      LOOP
		      IF l_eam_failure_codes_tbl(i).failure_entry_id IS NOT NULL THEN
			    l_eam_failure_codes_tbl(i).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_UPDATE;
			    l_workorder_rec.eam_failure_codes_tbl(i) := l_eam_failure_codes_tbl(i);
		      ELSE
			IF  (not( (l_eam_failure_codes_tbl(i).failure_code = FND_API.G_MISS_CHAR)
			      and (l_eam_failure_codes_tbl(i).cause_code = FND_API.G_MISS_CHAR)
			      and (l_eam_failure_codes_tbl(i).resolution_code = FND_API.G_MISS_CHAR)
			      and (l_eam_failure_codes_tbl(i).comments = FND_API.G_MISS_CHAR)
			     )) THEN
				  l_eam_failure_codes_tbl(i).transaction_type := EAM_Process_Failure_Entry_PUB.G_FE_CREATE;
				  if l_eam_failure_codes_tbl(i).failure_code = FND_API.G_MISS_CHAR THEN
				     l_eam_failure_codes_tbl(i).failure_code := NULL;
				  END IF;
				  IF l_eam_failure_codes_tbl(i).cause_code = FND_API.G_MISS_CHAR THEN
				     l_eam_failure_codes_tbl(i).cause_code := NULL;
				  END IF;
				  IF l_eam_failure_codes_tbl(i).resolution_code = FND_API.G_MISS_CHAR THEN
				     l_eam_failure_codes_tbl(i).resolution_code := NULL;
				  END IF;
				  IF l_eam_failure_codes_tbl(i).comments = FND_API.G_MISS_CHAR THEN
				     l_eam_failure_codes_tbl(i).comments := NULL;
				  END IF;
				  l_workorder_rec.eam_failure_codes_tbl(i) := l_eam_failure_codes_tbl(i);
		       ELSE
				  l_workorder_rec.eam_failure_codes_tbl(i) := l_eam_failure_codes_tbl(i);
				  l_workorder_rec.eam_failure_codes_tbl.delete(i);
		       END IF;
		      END IF;
              END LOOP;
              l_workorder_rec.eam_failure_entry_record := l_eam_failure_entry_record;

 SAVEPOINT UPDATE_WO;

     select parent_wip_entity_id
     into l_old_rebuild_source
     from wip_discrete_jobs
     where wip_entity_id=X_wip_Entity_Id;

       l_eam_wo_tbl(1) := l_workorder_rec;
       l_eam_wo_tbl1(1) := l_workorder_rec1;




/*Delink child from the old rebuild source and attach to the new rebuild source */
if(X_manual_rebuild_flag='Y') then


if(((l_old_rebuild_source  is not null)  and (X_parent_wip_entity_id is null))
    or ((l_old_rebuild_source is null )  and  (X_parent_wip_entity_id is not null))
    or (l_old_rebuild_source  <> X_parent_wip_entity_id)
    )then


    if(l_old_rebuild_source is not null) then


   ----If constraining relationship exists with rebuild source delete it
     select count(*)
     into constraining_rel
     from eam_wo_relationships
     where parent_object_id=l_old_rebuild_source
     and child_object_id=X_wip_Entity_Id
     and parent_relationship_type=1;

   if(constraining_rel=1) then
     l_eam_wo_relations_rec1.batch_id  :=  1;
     l_eam_wo_relations_rec1.parent_object_id := l_old_rebuild_source;
     l_eam_wo_relations_rec1.parent_object_type_id := 1;
     l_eam_wo_relations_rec1.parent_header_id := l_old_rebuild_source;
     l_eam_wo_relations_rec1.child_object_type_id := 1;
     l_eam_wo_relations_rec1.child_header_id    :=X_wip_Entity_Id;
     l_eam_wo_relations_rec1.child_object_id    :=X_wip_Entity_Id;
     l_eam_wo_relations_rec1.parent_relationship_type  := 1;
     l_eam_wo_relations_rec1.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_DELETE;

         l_eam_wo_relations_tbl(record_count) := l_eam_wo_relations_rec1;
          record_count := record_count +1;

    end if;


  ----If followup relationship exists with rebuild source delete it

     select count(*)
     into followup_rel
     from eam_wo_relationships
     where parent_object_id=l_old_rebuild_source
     and child_object_id=X_wip_Entity_Id
     and parent_relationship_type=4;

   if(followup_rel=1) then
                 l_eam_wo_relations_rec2.batch_id  :=  1;
    		 l_eam_wo_relations_rec2.parent_object_id := l_old_rebuild_source;
   		  l_eam_wo_relations_rec2.parent_object_type_id := 1;
   		  l_eam_wo_relations_rec2.parent_header_id := l_old_rebuild_source;
   		  l_eam_wo_relations_rec2.child_object_type_id := 1;
   		  l_eam_wo_relations_rec2.child_header_id    :=X_wip_Entity_Id;
    		 l_eam_wo_relations_rec2.child_object_id    :=X_wip_Entity_Id;
   		  l_eam_wo_relations_rec2.parent_relationship_type  := 4;
    		 l_eam_wo_relations_rec2.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_DELETE;

         l_eam_wo_relations_tbl(record_count) := l_eam_wo_relations_rec2;
         record_count := record_count +1;



   end if;

   end if;



  if(X_parent_wip_entity_id is not null) then

     l_eam_wo_relations_rec3.batch_id  :=  1;
     l_eam_wo_relations_rec3.parent_object_id := X_parent_wip_entity_id;
     l_eam_wo_relations_rec3.parent_object_type_id := 1;
     l_eam_wo_relations_rec3.parent_header_id := X_parent_wip_entity_id;
     l_eam_wo_relations_rec3.child_object_type_id := 1;
     l_eam_wo_relations_rec3.child_header_id    :=X_wip_Entity_Id;
     l_eam_wo_relations_rec3.child_object_id    :=X_wip_Entity_Id;
     l_eam_wo_relations_rec3.parent_relationship_type  := 1;
     l_eam_wo_relations_rec3.adjust_parent   := FND_API.G_FALSE;
     l_eam_wo_relations_rec3.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;

         l_eam_wo_relations_tbl(record_count) := l_eam_wo_relations_rec3;
         record_count := record_count +1;


     l_eam_wo_relations_rec4.batch_id  :=  1;
     l_eam_wo_relations_rec4.parent_object_id := X_parent_wip_entity_id;
     l_eam_wo_relations_rec4.parent_object_type_id := 1;
     l_eam_wo_relations_rec4.parent_header_id := X_parent_wip_entity_id;
     l_eam_wo_relations_rec4.child_object_type_id := 1;
     l_eam_wo_relations_rec4.child_header_id    :=X_wip_Entity_Id;
     l_eam_wo_relations_rec4.child_object_id    :=X_wip_Entity_Id;
     l_eam_wo_relations_rec4.parent_relationship_type  := 4;
     l_eam_wo_relations_rec4.adjust_parent   := FND_API.G_FALSE;
     l_eam_wo_relations_rec4.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;

         l_eam_wo_relations_tbl(record_count) := l_eam_wo_relations_rec4;
          record_count := record_count +1;


    end if;
end if;
end if;

begin

      EAM_PROCESS_WO_PUB.Process_Master_Child_WO
  	         ( p_bo_identifier           => 'EAM'
  	         , p_init_msg_list           => TRUE
  	         , p_api_version_number      => 1.0
  	         , p_eam_wo_tbl              => l_eam_wo_tbl
                 , p_eam_wo_relations_tbl   => l_eam_wo_relations_tbl
  	         , p_eam_op_tbl              => l_eam_op_tbl
  	         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  	         , p_eam_res_tbl             => l_eam_res_tbl
  	         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  	         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
    	         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                 , p_eam_direct_items_tbl =>   l_eam_direct_items_tbl

		 , p_eam_wo_comp_tbl         => l_eam_wo_comp_tbl
		 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
		 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
		 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
		 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
		 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
		 , p_eam_request_tbl         => l_eam_request_tbl

  	         , x_eam_wo_tbl              => l_eam_wo_tbl1
                 , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl1
  	         , x_eam_op_tbl              => l_eam_op_tbl1
  	         , x_eam_op_network_tbl      => l_eam_op_network_tbl1
  	         , x_eam_res_tbl             => l_eam_res_tbl1
  	         , x_eam_res_inst_tbl        => l_eam_res_inst_tbl1
  	         , x_eam_sub_res_tbl         => l_eam_sub_res_tbl1
		 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
  	         , x_eam_mat_req_tbl         => l_eam_mat_req_tbl1
                , x_eam_direct_items_tbl =>   l_eam_direct_items_tbl_1

		, x_eam_wo_comp_tbl         => l_eam_wo_comp_tbl_1
		 , x_eam_wo_quality_tbl      => l_eam_wo_quality_tbl_1
		 , x_eam_meter_reading_tbl   => l_eam_meter_reading_tbl_1
		 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		 , x_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl_1
		 , x_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl_1
		 , x_eam_op_comp_tbl         => l_eam_op_comp_tbl_1
		 , x_eam_request_tbl         => l_eam_request_tbl_1

  	         , x_return_status           => l_return_status
  	         , x_msg_count               => l_msg_count
  	         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  	         , p_debug_filename          => 'updatewo.log'
  	         , p_output_dir              => l_output_dir
                 , p_commit                  => 'N'
                 , p_debug_file_mode         => 'w'
           );
    x_return_status := l_return_status; /*7003588*/
 exception
   when others then
      ROLLBACK TO UPDATE_WO;
        l_msg_count := FND_MSG_PUB.count_msg;
         l_message_text :=' ';
        if(l_msg_count>0) then
           get_all_mesg(mesg=>l_message_text);
        end if;
           fnd_message.set_name('EAM','EAM_ERROR_UPDATE_WO');

           fnd_message.set_token(token => 'MESG',
			    value => l_message_text,
			    translate => FALSE);


        APP_EXCEPTION.RAISE_EXCEPTION;
end;


   l_workorder_rec1 := l_eam_wo_tbl1(l_eam_wo_tbl1.first);



   if((nvl(l_return_status,'S'))='S') then

           select rowid into X_We_Rowid from WIP_ENTITIES where wip_entity_id=X_wip_entity_id;

   else
        ROLLBACK TO UPDATE_WO;
        l_msg_count := FND_MSG_PUB.count_msg;
         l_message_text :=' ';
        if(l_msg_count>0) then
           get_all_mesg(mesg=>l_message_text);
        end if;
           fnd_message.set_name('EAM','EAM_ERROR_UPDATE_WO');

           fnd_message.set_token(token => 'MESG',
			    value => l_message_text,
			    translate => FALSE);


        APP_EXCEPTION.RAISE_EXCEPTION;

   end if;


COMMIT;


/*copy the values from the wo api back to the out parameters */


		X_description:=l_workorder_rec1.description ;

		X_firm_planned_flag :=l_workorder_rec1.firm_planned_flag;

		X_owning_department :=l_workorder_rec1.owning_department ;
		X_scheduled_start_date := l_workorder_rec1.scheduled_start_date ;
		X_scheduled_completion_date := l_workorder_rec1.scheduled_completion_date;
		X_status_type := l_workorder_rec1.status_type;

		X_user_defined_status_id := l_workorder_rec1.user_defined_status_id;
		X_pending_flag := l_workorder_rec1.pending_flag;
		X_workflow_type := l_workorder_rec1.workflow_type;
		X_warranty_claim_status := l_workorder_rec1.warranty_claim_status;
		X_material_shortage_flag := l_workorder_rec1.material_shortage_flag;
		X_material_shortage_check_date := l_workorder_rec1.material_shortage_check_date;


		X_activity_type:= l_workorder_rec1.activity_type;
		X_activity_cause:= l_workorder_rec1.activity_cause;
		X_activity_source := l_workorder_rec1.activity_source;
		X_shutdown_type := l_workorder_rec1.shutdown_type;
		X_work_order_type := l_workorder_rec1.work_order_type;
		X_priority := l_workorder_rec1.priority;
		X_material_issue_by_mo := l_workorder_rec1.material_issue_by_mo;


		X_manual_rebuild_flag :=  l_workorder_rec1.manual_rebuild_flag ;
		X_requested_start_date := l_workorder_rec1.requested_start_date;
		X_requested_due_date := l_workorder_rec1.due_date  ;
		X_notification_required := l_workorder_rec1.notification_required;
		X_tagout_required := l_workorder_rec1.tagout_required     ;
		X_plan_maintenance := l_workorder_rec1.plan_maintenance     ;
		X_class_code := l_workorder_rec1.class_code       ;
		X_material_account := l_workorder_rec1.material_account;
		X_material_overhead_account := l_workorder_rec1.material_overhead_account;
		X_resource_account := l_workorder_rec1.resource_account ;
		X_outside_processing_account := l_workorder_rec1.outside_processing_account;
		X_material_variance_account := l_workorder_rec1.material_variance_account  ;
		X_resource_variance_account := l_workorder_rec1.resource_variance_account  ;
		X_outside_proc_var_account := l_workorder_rec1.outside_proc_variance_account  ;
		X_std_cost_adjustment_account := l_workorder_rec1.std_cost_adjustment_account ;
		X_overhead_account :=  l_workorder_rec1.overhead_account  ;
		X_overhead_variance_account := l_workorder_rec1.overhead_variance_account  ;
		-- l_workorder_rec.common_routing_reference_id   := X_routing_reference_id;
		X_common_bom_sequence_id := l_workorder_rec1.common_bom_sequence_id  ;
		X_common_routing_sequence_id := l_workorder_rec1.common_routing_sequence_id  ;
		X_bom_revision := l_workorder_rec1.bom_revision   ;
		X_routing_revision:=  l_workorder_rec1.routing_revision  ;
		X_bom_revision_date := l_workorder_rec1.bom_revision_date  ;
		X_routing_revision_date := l_workorder_rec1.routing_revision_date  ;
		X_alternate_bom_designator := l_workorder_rec1.alternate_bom_designator ;
		X_alternate_routing_designator := l_workorder_rec1.alternate_routing_designator  ;
		X_attribute_category := l_workorder_rec1.attribute_category ;
		X_attribute1 := l_workorder_rec1.attribute1;
		X_attribute2 := l_workorder_rec1.attribute2;
		X_attribute3 := l_workorder_rec1.attribute3 ;
		X_attribute4 := l_workorder_rec1.attribute4;
		X_attribute5 := l_workorder_rec1.attribute5 ;
		X_attribute6 := l_workorder_rec1.attribute6 ;
		X_attribute7 := l_workorder_rec1.attribute7 ;
		X_attribute8 := l_workorder_rec1.attribute8;
		X_attribute9 := l_workorder_rec1.attribute9 ;
		X_attribute10 := l_workorder_rec1.attribute10;
		X_attribute11 := l_workorder_rec1.attribute11;
		X_attribute12 := l_workorder_rec1.attribute12;
		X_attribute13 := l_workorder_rec1.attribute13;
		X_attribute14 := l_workorder_rec1.attribute14 ;
		X_attribute15 := l_workorder_rec1.attribute15 ;
		x_failure_code_required := l_workorder_rec1.failure_code_required;
                x_eam_failure_entry_record := l_workorder_rec1.eam_failure_entry_record;
                x_eam_failure_codes_tbl    := l_workorder_rec1.eam_failure_codes_tbl;


/*end of copy params */



    -- asset genealogy is updated when a automatic work order is created for a a rebuild serial number
    -- which is part of an asset hierarchy. bug number  2899984
 if (X_rebuild_serial_number is not null) then

 Update_Genealogy(   X_wip_entity_id        => X_Wip_Entity_Id,
                                         X_organization_id      =>X_Organization_Id,
                                         X_parent_wip_entity_id	=>X_parent_wip_entity_id,
 		                          X_rebuild_item_id	    => X_rebuild_item_id,
 		                          X_rebuild_serial_number=>X_rebuild_serial_number,
 		                           X_manual_rebuild_flag	=>X_manual_rebuild_flag,
									x_maintenance_object_type     => x_maintenance_object_type ,
										 x_maintenance_object_id       => x_maintenance_object_id);

 end if;



END Update_Workorder;

PROCEDURE Lock_Row( X_Rowid 			VARCHAR2,
		X_wip_entity_id			NUMBER,
		X_organization_id		NUMBER,
		X_description			VARCHAR2,
		X_status_type			NUMBER,

		X_user_defined_status_id	NUMBER,
		X_pending_flag			VARCHAR2,
		X_workflow_type			NUMBER ,
		X_warranty_claim_status		NUMBER,
		X_material_shortage_flag        NUMBER,
		X_material_shortage_check_date  DATE,

		X_primary_item_id		NUMBER,
		X_parent_wip_entity_id		NUMBER,
		X_asset_number			VARCHAR2,
		X_asset_group_id		NUMBER,
		X_pm_schedule_id		NUMBER,
		X_rebuild_item_id		NUMBER,
		X_rebuild_serial_number		VARCHAR2,
		X_manual_rebuild_flag		VARCHAR2,
		X_shutdown_type			VARCHAR2,
		X_tagout_required		VARCHAR2,
		X_plan_maintenance		VARCHAR2,
		X_estimation_status		VARCHAR2,
		X_requested_start_date		DATE,
		X_requested_due_date		DATE,
		X_notification_required		VARCHAR2,
		X_work_order_type		VARCHAR2,
		X_owning_department		NUMBER,
		X_activity_type			VARCHAR2,
		X_activity_cause		VARCHAR2,
		X_firm_planned_flag		NUMBER,
		X_class_code			VARCHAR2,
		X_material_account		NUMBER,
		X_material_overhead_account	NUMBER,
		X_resource_account		NUMBER,
		X_outside_processing_account	NUMBER,
		X_material_variance_account	NUMBER,
		X_resource_variance_account	NUMBER,
		X_outside_proc_var_account	NUMBER,
		X_std_cost_adjustment_account	NUMBER,
		X_overhead_account		NUMBER,
		X_overhead_variance_account	NUMBER,
		X_scheduled_start_date		DATE,
		X_date_released			DATE,
		X_scheduled_completion_date	DATE,
		X_date_completed		DATE,
		X_date_closed			DATE,
		X_bom_reference_id		NUMBER,
		X_routing_reference_id		NUMBER,
		X_common_bom_sequence_id	NUMBER,
		X_common_routing_sequence_id	NUMBER,
		X_bom_revision			VARCHAR2,
		X_routing_revision		VARCHAR2,
		X_bom_revision_date		DATE,
		X_routing_revision_date		DATE,
		X_lot_number			VARCHAR2,
		X_alternate_bom_designator	VARCHAR2,
		X_alternate_routing_designator	VARCHAR2,
		X_completion_subinventory	VARCHAR2,
		X_completion_locator_id		NUMBER,
		X_demand_class			VARCHAR2,
		X_attribute_category		VARCHAR2,
		X_attribute1			VARCHAR2,
		X_attribute2			VARCHAR2,
		X_attribute3			VARCHAR2,
		X_attribute4			VARCHAR2,
		X_attribute5			VARCHAR2,
		X_attribute6			VARCHAR2,
		X_attribute7			VARCHAR2,
		X_attribute8			VARCHAR2,
		X_attribute9			VARCHAR2,
		X_attribute10			VARCHAR2,
		X_attribute11			VARCHAR2,
		X_attribute12			VARCHAR2,
		X_attribute13			VARCHAR2,
		X_attribute14			VARCHAR2,
		X_attribute15			VARCHAR2,
		X_We_Rowid			VARCHAR2,
		X_Entity_Type			NUMBER,
		X_Wip_Entity_Name		VARCHAR2,
		X_Update_Wip_Entities		VARCHAR2,
		X_Schedule_Group_Id		NUMBER,
		X_Project_Id			NUMBER,
		X_Task_Id			NUMBER,
                X_priority                      NUMBER,
                X_maintenance_object_id         NUMBER,
		X_maintenance_object_source     NUMBER,
		X_maintenance_object_type       NUMBER,
		X_material_issue_by_mo          VARCHAR2,
		X_activity_source               VARCHAR2) IS

  CURSOR C_WDJ IS
    SELECT *
    FROM   WIP_DISCRETE_JOBS
    WHERE  rowid = X_Rowid
    FOR UPDATE of Wip_Entity_Id NOWAIT;

  CURSOR C_WE IS
    SELECT *
    FROM WIP_ENTITIES
    WHERE rowid = X_We_Rowid
    FOR UPDATE of Wip_Entity_Id NOWAIT;

  CURSOR C_ewod IS
    SELECT *
    FROM eam_work_order_details
    WHERE wip_entity_id = X_wip_entity_id
    FOR UPDATE of Wip_Entity_Id NOWAIT;

  Recinfo1 C_WDJ%ROWTYPE;
  Recinfo2 C_WE%ROWTYPE;
  Recinfo3 C_EWOD%ROWTYPE;

BEGIN
	-- Wip Discrete Jobs
	OPEN C_WDJ;
	FETCH C_WDJ INTO Recinfo1;
	if (C_WDJ%NOTFOUND) then
		CLOSE C_WDJ;
	  	FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
	  	APP_EXCEPTION.Raise_Exception;
	end if;
	CLOSE C_WDJ;

	if 	(Recinfo1.wip_entity_id =  X_Wip_Entity_Id)
	   AND 	(Recinfo1.organization_id =  X_Organization_Id)
	   AND 	(ltrim(rtrim(nvl(Recinfo1.description, 'xxxx'))) =
		 ltrim(rtrim(nvl(X_Description, 'xxxx'))))
	   AND 	(Recinfo1.status_type =  X_Status_Type)

	   AND 	(nvl(Recinfo1.primary_item_id, 0) =
		 nvl(X_Primary_Item_Id, 0))
	   AND 	(Recinfo1.firm_planned_flag =  X_Firm_Planned_Flag)
	   AND 	(Recinfo1.class_code =  X_Class_Code)
	   AND 	(nvl(Recinfo1.material_account, 0) =
		 nvl(X_Material_Account, 0))
	   AND	(nvl(Recinfo1.material_overhead_account, 0) =
		 nvl(X_Material_Overhead_Account, 0))
	   AND	(nvl(Recinfo1.resource_account, 0) =
		 nvl(X_Resource_Account, 0))
	   AND	(nvl(Recinfo1.outside_processing_account, 0) =
		 nvl(X_Outside_Processing_Account, 0))
	   AND	(nvl(Recinfo1.material_variance_account, 0) =
		 nvl(X_Material_Variance_Account, 0))
	   AND	(nvl(Recinfo1.resource_variance_account, 0) =
		 nvl(X_Resource_Variance_Account, 0))
	   AND	(nvl(Recinfo1.outside_proc_variance_account, 0) =
		 nvl(X_Outside_Proc_Var_Account, 0))
	   AND	(nvl(Recinfo1.std_cost_adjustment_account, 0) =
		 nvl(X_Std_Cost_Adjustment_Account, 0))
	   AND	(nvl(Recinfo1.overhead_account, 0) =
		 nvl(X_Overhead_Account, 0))
	   AND	(nvl(Recinfo1.overhead_variance_account, 0) =
		 nvl(X_Overhead_Variance_Account, 0))
	   AND	(Recinfo1.scheduled_start_date =  X_Scheduled_Start_Date)
	   AND	((Recinfo1.date_released =  X_Date_Released) OR
		 ((Recinfo1.date_released IS NULL) AND
		  (X_Date_Released IS NULL)))
	   AND 	(Recinfo1.scheduled_completion_date =  X_Scheduled_Completion_Date)
	   AND	((Recinfo1.date_completed =  X_Date_Completed) OR
		 ((Recinfo1.date_completed IS NULL) AND
		  (X_Date_Completed IS NULL)))
	   AND	((Recinfo1.date_closed =  X_Date_Closed) OR
		 ((Recinfo1.date_closed IS NULL) AND
		  (X_Date_Closed IS NULL)))
  	then
	  if 	(nvl(Recinfo1.bom_reference_id, 0) =
		 nvl(X_Bom_Reference_Id, 0))
	   AND	(nvl(Recinfo1.common_bom_sequence_id, 0) =
		 nvl(X_Common_Bom_Sequence_Id, 0))
	   AND	(nvl(Recinfo1.common_routing_sequence_id, 0) =
		 nvl(X_Common_Routing_Sequence_Id, 0))
	   AND	(nvl(Recinfo1.bom_revision, 'xxxx') =
		 nvl(X_Bom_Revision, 'xxxx'))
	   AND	(nvl(Recinfo1.routing_revision, 'xxxx') =
		 nvl(X_Routing_Revision, 'xxxx'))
	   AND	((Recinfo1.bom_revision_date =  X_Bom_Revision_Date) OR
		 ((Recinfo1.bom_revision_date IS NULL) AND
		  (X_Bom_Revision_Date IS NULL)))
	   AND	((Recinfo1.routing_revision_date =  X_Routing_Revision_Date) OR
		 ((Recinfo1.routing_revision_date IS NULL) AND
		  (X_Routing_Revision_Date IS NULL)))
	   AND	(nvl(Recinfo1.alternate_bom_designator, 'xxxx') =
		 nvl(X_Alternate_Bom_Designator, 'xxxx'))
	   AND	(nvl(Recinfo1.alternate_routing_designator, 'xxxx') =
		 nvl(X_Alternate_Routing_Designator, 'xxxx'))
	   AND  (nvl(Recinfo1.attribute_category, 'xxxx') =
		 nvl(X_Attribute_Category, 'xxxx'))
	   AND	(nvl(Recinfo1.attribute1, 'xxxx') =
		 nvl(X_Attribute1, 'xxxx'))
	   AND	(nvl(Recinfo1.attribute2, 'xxxx') =
		 nvl(X_Attribute2, 'xxxx'))
	   AND	(nvl(Recinfo1.attribute3, 'xxxx') =
		 nvl(X_Attribute3, 'xxxx'))
	   AND	(nvl(Recinfo1.attribute4, 'xxxx') =
		 nvl(X_Attribute4, 'xxxx'))
	   AND	(nvl(Recinfo1.attribute5, 'xxxx') =
		 nvl(X_Attribute5, 'xxxx'))
	   AND	(nvl(Recinfo1.attribute6, 'xxxx') =
		 nvl(X_Attribute6, 'xxxx'))
	   AND	(nvl(Recinfo1.attribute7, 'xxxx') =
		 nvl(X_Attribute7, 'xxxx'))
	   AND	(nvl(Recinfo1.attribute8, 'xxxx') =
		 nvl(X_Attribute8, 'xxxx'))
	   AND	(nvl(Recinfo1.attribute9, 'xxxx') =
		 nvl(X_Attribute9, 'xxxx'))
	   AND	(nvl(Recinfo1.attribute10, 'xxxx') =
		 nvl(X_Attribute10, 'xxxx'))
	   AND	(nvl(Recinfo1.attribute11, 'xxxx') =
		 nvl(X_Attribute11, 'xxxx'))
	   AND	(nvl(Recinfo1.attribute12, 'xxxx') =
		 nvl(X_Attribute12, 'xxxx'))
	   AND	(nvl(Recinfo1.attribute13, 'xxxx') =
		 nvl(X_Attribute13, 'xxxx'))
	   AND	(nvl(Recinfo1.attribute14, 'xxxx') =
		 nvl(X_Attribute14, 'xxxx'))
	   AND	(nvl(Recinfo1.attribute15, 'xxxx') =
		 nvl(X_Attribute15, 'xxxx'))
	   AND	(nvl(Recinfo1.Project_Id, 0) =
		 nvl(X_Project_Id, 0))
--	   AND  (nvl(Recinfo1.schedule_group_id, 0) =
	--	 nvl(X_Schedule_Group_Id, 0))
	   AND	(nvl(Recinfo1.task_id, 0) =
		 nvl(X_Task_Id, 0))
	   AND	(nvl(Recinfo1.priority, 0) =
		 nvl(X_priority, 0))
           AND	(nvl(Recinfo1.maintenance_object_id, 0) =
		 nvl(X_maintenance_object_id, 0))
	   AND	(nvl(Recinfo1.maintenance_object_source, 0) =
		 nvl(X_maintenance_object_source, 0))
	   AND	(nvl(Recinfo1.maintenance_object_type, 0) =
		 nvl(X_maintenance_object_type, 0))
           AND	(nvl(Recinfo1.material_issue_by_mo, 'XXXX') =
		 nvl(X_material_issue_by_mo, 'XXXX'))
           AND	(nvl(Recinfo1.activity_source, 'XXXX') =
		 nvl(X_activity_source, 'XXXX'))
	  then
	    null;
	  else
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
                null;
	  end if;
	else
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
                null;
	end if;

        -- Wip Entities
	-- Wip Discrete Jobs
	OPEN C_WE;
	FETCH C_WE INTO Recinfo2;
	if (C_WE%NOTFOUND) then
		CLOSE C_WE;
	  	FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
	  	APP_EXCEPTION.Raise_Exception;
	end if;
	CLOSE C_WE;
	if 	(Recinfo2.wip_entity_id = X_Wip_Entity_Id)
	    AND	(Recinfo2.organization_id = X_Organization_Id)
	    AND	(Recinfo2.wip_entity_name = X_Wip_Entity_Name)
	    AND	(Recinfo2.entity_type = X_Entity_Type)
	    AND	(rtrim(nvl(Recinfo2.description, 'xxxx')) =
		 rtrim(nvl(X_Description, 'xxxx')))
	    AND	(nvl(Recinfo2.primary_item_id, 0) =
		 nvl(X_Primary_Item_Id, 0))
	then
	  return;
	else
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	end if;

	-- eam_work_order_details
	OPEN C_EWOD;
	FETCH C_EWOD INTO Recinfo3;
	IF (C_EWOD%NOTFOUND) THEN
		CLOSE C_EWOD;
	  	FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
	  	APP_EXCEPTION.Raise_Exception;
	END IF;
	CLOSE C_EWOD;
	IF (Recinfo3.wip_entity_id = X_Wip_Entity_Id)
	    AND	(Recinfo3.organization_id = X_Organization_Id)
	   AND 	(NVL(Recinfo3.user_defined_status_id,0) =  NVL(X_user_defined_status_id,0))
	   AND 	(NVL(Recinfo3.pending_flag,0) =  NVL(X_pending_flag,0))
	   AND 	(NVL(Recinfo3.workflow_type,0) =  NVL(X_workflow_type,0))
	   AND 	(NVL(Recinfo3.warranty_claim_status,0) =  NVL(X_warranty_claim_status,0))
	   AND 	(NVL(Recinfo3.material_shortage_flag,0) =  NVL(X_material_shortage_flag,0))
	   AND 	(NVL(Recinfo3.material_shortage_check_date,sysdate) =  NVL(X_material_shortage_check_date,sysdate))
	THEN
	  return;
	ELSE
		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
		APP_EXCEPTION.Raise_Exception;
	END IF;
END Lock_Row;


PROCEDURE Get_All_Mesg(mesg IN OUT NOCOPY VARCHAR2)
IS
   l_msg_count NUMBER;
   temp varchar2(2000);
   i NUMBER;
   msg_index number;
BEGIN
    mesg := '';


   l_msg_count := fnd_msg_pub.count_msg;
     msg_index := l_msg_count;

    for i in 1..l_msg_count loop
      fnd_msg_pub.get(p_msg_index => FND_MSG_PUB.G_NEXT,
                    p_encoded   => 'F',
                    p_data      => temp,
                    p_msg_index_out => msg_index);
      msg_index := msg_index-1;
     mesg := mesg || '    ' ||  to_char(i) || ' . '||temp ;
    end loop;

END GET_ALL_MESG;



END EAM_WORKORDER_PKG;

/
