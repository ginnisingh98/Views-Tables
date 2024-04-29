--------------------------------------------------------
--  DDL for Package Body EAM_REQUIREMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_REQUIREMENTS_PKG" as
/* $Header: EAMMRTHB.pls 120.3 2005/10/06 01:41:50 mmaduska noship $ */


PROCEDURE Pre_Insert IS
BEGIN
  null;
END Pre_Insert;


PROCEDURE Insert_Row   (X_row_id		IN OUT NOCOPY	VARCHAR2,
			X_inventory_item_id	IN 	NUMBER,
  			X_organization_id	IN	NUMBER,
  			X_wip_entity_id		IN	NUMBER,
  			X_operation_seq_num	IN	NUMBER,
  			X_repetitive_schedule_id  IN	NUMBER,
  			X_last_update_date	IN	DATE,
  			X_last_updated_by	IN	NUMBER,
  			X_creation_date		IN	DATE,
  			X_created_by		IN	NUMBER,
  			X_last_update_login	IN	NUMBER,
  			X_department_id		IN	NUMBER,
  			X_wip_supply_type	IN	NUMBER,
  			X_date_required		IN	DATE,
  			X_required_quantity	IN	NUMBER,
  			X_quantity_issued	IN	NUMBER,
  			X_quantity_per_assembly	IN	NUMBER,
  			X_comments		IN	VARCHAR2,
  			X_supply_subinventory	IN	VARCHAR2,
  			X_supply_locator_id	IN	NUMBER,
  			X_mrp_net_flag		IN	NUMBER,
  			X_mps_required_quantity	IN	NUMBER,
  			X_mps_date_required	IN	DATE,
  			X_attribute_category	IN	VARCHAR2,
  			X_attribute1		IN	VARCHAR2,
  			X_attribute2		IN	VARCHAR2,
  			X_attribute3		IN	VARCHAR2,
  			X_attribute4		IN	VARCHAR2,
  			X_attribute5		IN	VARCHAR2,
  			X_attribute6		IN	VARCHAR2,
  			X_attribute7		IN	VARCHAR2,
  			X_attribute8		IN	VARCHAR2,
  			X_attribute9		IN	VARCHAR2,
  			X_attribute10		IN	VARCHAR2,
  			X_attribute11		IN	VARCHAR2,
  			X_attribute12		IN	VARCHAR2,
  			X_attribute13		IN	VARCHAR2,
  			X_attribute14		IN	VARCHAR2,
  			X_attribute15		IN	VARCHAR2,
  			X_auto_request_material IN      VARCHAR2,
			X_L_EAM_MAT_REC	OUT NOCOPY 	EAM_PROCESS_WO_PUB.eam_mat_req_rec_type,
			X_material_shortage_flag	 OUT NOCOPY 	VARCHAR2,
			X_material_shortage_check_date	 OUT NOCOPY 	DATE
			) IS

			l_return_status    VARCHAR2(30) := '';
                        l_msg_count        NUMBER       := 0;
                        l_msg_data         VARCHAR2(2000) := '';
			l_status_type       NUMBER;
			l_material_issue_by_mo   VARCHAR2(1);
			l_output_dir	VARCHAR2(512);
			l_error_message    VARCHAR2(1000);

			l_eam_mat_req_rec       EAM_PROCESS_WO_PUB.eam_mat_req_rec_type ;
			l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;

			l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
			l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
			l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
			l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
			l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
			l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
			l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
			l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
			l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
			l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
			l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
			l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
			l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
			l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
			l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
			l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

			l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
			l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
			l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
			l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
			l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
			l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
			l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
			l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
			l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
			l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
			l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
			l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
			l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
			l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
			l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
			l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
			l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

  CURSOR C IS
    SELECT rowid
    FROM WIP_REQUIREMENT_OPERATIONS
    WHERE inventory_item_id = X_inventory_item_id
      AND organization_id = X_organization_id
      AND wip_entity_id = X_wip_entity_id
      AND operation_seq_num = X_operation_seq_num;
BEGIN

 /* get output directory path from database */
     EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


	  l_eam_mat_req_rec.header_id		         := X_wip_entity_id;
          l_eam_mat_req_rec.batch_id                     := 1;
          l_eam_mat_req_rec.wip_entity_id                := X_wip_entity_id;
          l_eam_mat_req_rec.organization_id              := X_organization_id;
          l_eam_mat_req_rec.operation_seq_num            := X_operation_seq_num;
          l_eam_mat_req_rec.inventory_item_id            := X_inventory_item_id;
          l_eam_mat_req_rec.quantity_per_assembly        := X_quantity_per_assembly;
          l_eam_mat_req_rec.department_id                := X_department_id;
          l_eam_mat_req_rec.wip_supply_type              := X_wip_supply_type;
          l_eam_mat_req_rec.date_required                := X_date_required;
          l_eam_mat_req_rec.required_quantity            := X_required_quantity;
          l_eam_mat_req_rec.quantity_issued              := X_quantity_issued;
          l_eam_mat_req_rec.supply_subinventory          := X_supply_subinventory;
          l_eam_mat_req_rec.supply_locator_id            := X_supply_locator_id;
          l_eam_mat_req_rec.mrp_net_flag                 := X_mrp_net_flag;
          l_eam_mat_req_rec.mps_required_quantity        := X_mps_required_quantity;
          l_eam_mat_req_rec.mps_date_required            := X_mps_date_required;
          l_eam_mat_req_rec.component_sequence_id        := null;
          l_eam_mat_req_rec.comments                     := X_comments;
          l_eam_mat_req_rec.attribute_category           := X_attribute_category;
          l_eam_mat_req_rec.attribute1                   := X_attribute1;
          l_eam_mat_req_rec.attribute2                   := X_attribute2;
          l_eam_mat_req_rec.attribute3                   := X_attribute3;
          l_eam_mat_req_rec.attribute4                   := X_attribute4;
          l_eam_mat_req_rec.attribute5                   := X_attribute5;
          l_eam_mat_req_rec.attribute6                   := X_attribute6;
          l_eam_mat_req_rec.attribute7                   := X_attribute7;
          l_eam_mat_req_rec.attribute8                   := X_attribute8;
          l_eam_mat_req_rec.attribute9                   := X_attribute9;
          l_eam_mat_req_rec.attribute10                  := X_attribute10;
          l_eam_mat_req_rec.attribute11                  := X_attribute11;
          l_eam_mat_req_rec.attribute12                  := X_attribute12;
          l_eam_mat_req_rec.attribute13                  := X_attribute13;
          l_eam_mat_req_rec.attribute14                  := X_attribute14;
          l_eam_mat_req_rec.attribute15                  := X_attribute15;
          l_eam_mat_req_rec.auto_request_material        := X_auto_request_material;
          l_eam_mat_req_rec.suggested_vendor_name        := null;
          l_eam_mat_req_rec.vendor_id                    := null;
          l_eam_mat_req_rec.unit_price                   := null;
          l_eam_mat_req_rec.request_id                   := null;
          l_eam_mat_req_rec.program_application_id       := null;
          l_eam_mat_req_rec.program_id                   := null;
          l_eam_mat_req_rec.program_update_date          := sysdate;
          l_eam_mat_req_rec.return_status                := null;
          l_eam_mat_req_rec.transaction_type             := EAM_PROCESS_WO_PVT.G_OPR_CREATE;

          l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;

	  begin
	  EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec          => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl          => l_eam_op_comp_tbl
			 , p_eam_request_tbl          => l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec          => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl          => l_out_eam_request_tbl
  		         , x_return_status           => l_return_status
  		         , x_msg_count               => l_msg_count
  		         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'insertmrthb.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );

     EXCEPTION
	WHEN OTHERS THEN
            EAM_WORKORDER_UTIL_PKG.show_mesg;
	    APP_EXCEPTION.RAISE_EXCEPTION;
     END;

	  IF (l_return_status = 'S') THEN
		X_L_EAM_MAT_REC := l_out_eam_mat_req_tbl(1);
                x_material_shortage_flag := l_out_eam_wo_rec.material_shortage_flag;
                x_material_shortage_check_date := l_out_eam_wo_rec.material_shortage_check_date;
	ELSE
            EAM_WORKORDER_UTIL_PKG.show_mesg;
	    APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;


  OPEN C;
  FETCH C INTO X_row_id;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;

END Insert_Row;



PROCEDURE Update_Row   (X_row_id		IN	VARCHAR2,
			X_inventory_item_id	IN 	NUMBER,
  			X_organization_id	IN	NUMBER,
  			X_wip_entity_id		IN	NUMBER,
  			X_operation_seq_num	IN	NUMBER,
  			X_repetitive_schedule_id IN	NUMBER,
  			X_last_update_date	IN	DATE,
  			X_last_updated_by	IN	NUMBER,
  			X_last_update_login	IN	NUMBER,
  			X_department_id		IN	NUMBER,
  			X_wip_supply_type	IN	NUMBER,
  			X_date_required		IN	DATE,
  			X_required_quantity	IN	NUMBER,
  			X_quantity_issued	IN	NUMBER,
  			X_quantity_per_assembly	IN	NUMBER,
  			X_comments		IN	VARCHAR2,
  			X_supply_subinventory	IN	VARCHAR2,
  			X_supply_locator_id	IN	NUMBER,
  			X_mrp_net_flag		IN	NUMBER,
  			X_mps_required_quantity	IN	NUMBER,
  			X_mps_date_required	IN	DATE,
  			X_attribute_category	IN	VARCHAR2,
  			X_attribute1		IN	VARCHAR2,
  			X_attribute2		IN	VARCHAR2,
  			X_attribute3		IN	VARCHAR2,
  			X_attribute4		IN	VARCHAR2,
  			X_attribute5		IN	VARCHAR2,
  			X_attribute6		IN	VARCHAR2,
  			X_attribute7		IN	VARCHAR2,
  			X_attribute8		IN	VARCHAR2,
  			X_attribute9		IN	VARCHAR2,
  			X_attribute10		IN	VARCHAR2,
  			X_attribute11		IN	VARCHAR2,
  			X_attribute12		IN	VARCHAR2,
  			X_attribute13		IN	VARCHAR2,
  			X_attribute14		IN	VARCHAR2,
  			X_attribute15		IN	VARCHAR2,
  			X_auto_request_material IN      VARCHAR2,
			X_L_EAM_MAT_REC	 OUT NOCOPY  	EAM_PROCESS_WO_PUB.eam_mat_req_rec_type,
			X_material_shortage_flag	 OUT NOCOPY 	VARCHAR2,
			X_material_shortage_check_date	 OUT NOCOPY 	DATE
			)IS

			l_return_status    VARCHAR2(30) := '';
                        l_msg_count        NUMBER       := 0;
                        l_msg_data         VARCHAR2(2000) := '';
                        l_req_qty          NUMBER	:= 0;
                        l_status_type       NUMBER;
			l_material_issue_by_mo    VARCHAR2(1);

			l_output_dir	VARCHAR2(512);
			l_eam_mat_req_rec       EAM_PROCESS_WO_PUB.eam_mat_req_rec_type ;
			l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;

			l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
			l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
			l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
			l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
			l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
			l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
			l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
			l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
			l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
			l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
			l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
			l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
			l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
			l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
			l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
			l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

			l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
			l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
			l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
			l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
			l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
			l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
			l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
			l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
			l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
			l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
			l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
			l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
			l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
			l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
			l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
			l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
			l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

BEGIN
 /* get output directory path from database */
     EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);



	  l_eam_mat_req_rec.header_id		         := X_wip_entity_id;
          l_eam_mat_req_rec.batch_id                     := 1;
          l_eam_mat_req_rec.wip_entity_id                := X_wip_entity_id;
          l_eam_mat_req_rec.organization_id              := X_organization_id;
          l_eam_mat_req_rec.operation_seq_num            := X_operation_seq_num;
          l_eam_mat_req_rec.inventory_item_id            := X_inventory_item_id;
          l_eam_mat_req_rec.quantity_per_assembly        := X_quantity_per_assembly;
          l_eam_mat_req_rec.department_id                := X_department_id;
          l_eam_mat_req_rec.wip_supply_type              := X_wip_supply_type;
          l_eam_mat_req_rec.date_required                := X_date_required;
          l_eam_mat_req_rec.required_quantity            := X_required_quantity;
          l_eam_mat_req_rec.quantity_issued              := X_quantity_issued;
          l_eam_mat_req_rec.supply_subinventory          := X_supply_subinventory;
          l_eam_mat_req_rec.supply_locator_id            := X_supply_locator_id;
          l_eam_mat_req_rec.mrp_net_flag                 := X_mrp_net_flag;
          l_eam_mat_req_rec.mps_required_quantity        := X_mps_required_quantity;
          l_eam_mat_req_rec.mps_date_required            := X_mps_date_required;
          l_eam_mat_req_rec.component_sequence_id        := null;
          l_eam_mat_req_rec.comments                     := X_comments;
          l_eam_mat_req_rec.attribute_category           := X_attribute_category;
          l_eam_mat_req_rec.attribute1                   := X_attribute1;
          l_eam_mat_req_rec.attribute2                   := X_attribute2;
          l_eam_mat_req_rec.attribute3                   := X_attribute3;
          l_eam_mat_req_rec.attribute4                   := X_attribute4;
          l_eam_mat_req_rec.attribute5                   := X_attribute5;
          l_eam_mat_req_rec.attribute6                   := X_attribute6;
          l_eam_mat_req_rec.attribute7                   := X_attribute7;
          l_eam_mat_req_rec.attribute8                   := X_attribute8;
          l_eam_mat_req_rec.attribute9                   := X_attribute9;
          l_eam_mat_req_rec.attribute10                  := X_attribute10;
          l_eam_mat_req_rec.attribute11                  := X_attribute11;
          l_eam_mat_req_rec.attribute12                  := X_attribute12;
          l_eam_mat_req_rec.attribute13                  := X_attribute13;
          l_eam_mat_req_rec.attribute14                  := X_attribute14;
          l_eam_mat_req_rec.attribute15                  := X_attribute15;
          l_eam_mat_req_rec.auto_request_material        := X_auto_request_material;
          l_eam_mat_req_rec.suggested_vendor_name        := null;
          l_eam_mat_req_rec.vendor_id                    := null;
          l_eam_mat_req_rec.unit_price                   := null;
          l_eam_mat_req_rec.request_id                   := null;
          l_eam_mat_req_rec.program_application_id       := null;
          l_eam_mat_req_rec.program_id                   := null;
          l_eam_mat_req_rec.program_update_date          := sysdate;
          l_eam_mat_req_rec.return_status                := null;
          l_eam_mat_req_rec.transaction_type             := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;

          l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;
	  EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec          => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl          => l_eam_op_comp_tbl
			 , p_eam_request_tbl          => l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec          => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl          => l_out_eam_request_tbl
  		         , x_return_status           => l_return_status
  		         , x_msg_count               => l_msg_count
  		         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'updatemrthb.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );
	  IF (l_return_status = 'S') THEN
	       X_L_EAM_MAT_REC := l_out_eam_mat_req_tbl(1);
               x_material_shortage_flag := l_out_eam_wo_rec.material_shortage_flag;
               x_material_shortage_check_date := l_out_eam_wo_rec.material_shortage_check_date;
	ELSE
		EAM_WORKORDER_UTIL_PKG.show_mesg;
		APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;


END Update_Row;


PROCEDURE Lock_Row(	X_row_id		IN	VARCHAR2,
			X_inventory_item_id	IN 	NUMBER,
  			X_organization_id	IN	NUMBER,
  			X_wip_entity_id		IN	NUMBER,
  			X_operation_seq_num	IN	NUMBER,
  			X_department_id		IN	NUMBER,
  			X_wip_supply_type	IN	NUMBER,
  			X_date_required		IN	DATE,
  			X_required_quantity	IN	NUMBER,
  			X_quantity_issued	IN	NUMBER,
  			X_quantity_per_assembly	IN	NUMBER,
  			X_comments		IN	VARCHAR2,
  			X_supply_subinventory	IN	VARCHAR2,
  			X_supply_locator_id	IN	NUMBER,
  			X_mrp_net_flag		IN	NUMBER,
  			X_attribute_category	IN	VARCHAR2,
  			X_attribute1		IN	VARCHAR2,
  			X_attribute2		IN	VARCHAR2,
  			X_attribute3		IN	VARCHAR2,
  			X_attribute4		IN	VARCHAR2,
  			X_attribute5		IN	VARCHAR2,
  			X_attribute6		IN	VARCHAR2,
  			X_attribute7		IN	VARCHAR2,
  			X_attribute8		IN	VARCHAR2,
  			X_attribute9		IN	VARCHAR2,
  			X_attribute10		IN	VARCHAR2,
  			X_attribute11		IN	VARCHAR2,
  			X_attribute12		IN	VARCHAR2,
  			X_attribute13		IN	VARCHAR2,
  			X_attribute14		IN	VARCHAR2,
  			X_attribute15		IN	VARCHAR2,
  			X_auto_request_material IN      VARCHAR2) IS
    CURSOR C IS
      SELECT *
      FROM   WIP_REQUIREMENT_OPERATIONS
      WHERE  rowid = X_row_id
      FOR    UPDATE of Wip_Entity_Id NOWAIT;
    Recinfo	C%ROWTYPE;
BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
      FND_MESSAGE.RAISE_ERROR;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;

    IF		(Recinfo.inventory_item_id =  X_Inventory_Item_Id)
    	AND 	(Recinfo.organization_id =  X_Organization_Id)
        AND 	(Recinfo.wip_entity_id =  X_Wip_Entity_Id)
        AND 	(Recinfo.operation_seq_num =  X_Operation_Seq_Num)
   	AND 	(nvl(Recinfo.department_id, -1) =
		 nvl(X_Department_Id, -1))
	AND 	(nvl(Recinfo.wip_supply_type, -1) =
		 nvl(X_Wip_Supply_Type, -1))
	AND 	(Recinfo.date_required = X_Date_Required OR
		 (Recinfo.date_required is NULL AND
		  X_Date_Required is NULL))
	AND 	(Recinfo.required_quantity =  X_Required_Quantity)
	AND	(Recinfo.quantity_issued =  X_Quantity_Issued OR
		 (Recinfo.quantity_issued = 0 AND
		  X_Quantity_Issued IS NULL))
	AND 	(Recinfo.quantity_per_assembly =  X_Quantity_Per_Assembly)
	AND	(nvl(Recinfo.comments, 'xxxx') =
		 nvl(X_Comments, 'xxxx'))
	AND	(nvl(Recinfo.supply_subinventory, 'xxxx') =
		 nvl(X_Supply_Subinventory, 'xxxx'))
	AND	(nvl(Recinfo.supply_locator_id, -1) =
		 nvl(X_Supply_Locator_Id, -1))
	AND	(Recinfo.mrp_net_flag =  X_Mrp_Net_Flag)
	AND	(nvl(Recinfo.attribute_category, 'xxxx') =
		 nvl(X_Attribute_Category, 'xxxx'))
	AND	(nvl(Recinfo.attribute1, 'xxxx') =
		 nvl(X_Attribute1, 'xxxx'))
	AND	(nvl(Recinfo.attribute2, 'xxxx') =
		 nvl(X_Attribute2, 'xxxx'))
	AND	(nvl(Recinfo.attribute3, 'xxxx') =
		 nvl(X_Attribute3, 'xxxx'))
	AND	(nvl(Recinfo.attribute4, 'xxxx') =
		 nvl(X_Attribute4, 'xxxx'))
	AND	(nvl(Recinfo.attribute5, 'xxxx') =
		 nvl(X_Attribute5, 'xxxx'))
	AND	(nvl(Recinfo.attribute6, 'xxxx') =
		 nvl(X_Attribute6, 'xxxx'))
	AND	(nvl(Recinfo.attribute7, 'xxxx') =
		 nvl(X_Attribute7, 'xxxx'))
	AND	(nvl(Recinfo.attribute8, 'xxxx') =
		 nvl(X_Attribute8, 'xxxx'))
	AND	(nvl(Recinfo.attribute9, 'xxxx') =
		 nvl(X_Attribute9, 'xxxx'))
	AND	(nvl(Recinfo.attribute10, 'xxxx') =
		 nvl(X_Attribute10, 'xxxx'))
	AND	(nvl(Recinfo.attribute11, 'xxxx') =
		 nvl(X_Attribute11, 'xxxx'))
	AND	(nvl(Recinfo.attribute12, 'xxxx') =
		 nvl(X_Attribute12, 'xxxx'))
	AND	(nvl(Recinfo.attribute13, 'xxxx') =
		 nvl(X_Attribute13, 'xxxx'))
	AND	(nvl(Recinfo.attribute14, 'xxxx') =
		 nvl(X_Attribute14, 'xxxx'))
	AND	(nvl(Recinfo.attribute15, 'xxxx') =
		 nvl(X_Attribute15, 'xxxx'))
        AND	(nvl(Recinfo.auto_request_material, 'T') =
		 nvl(X_auto_request_material, 'T'))
    THEN
      RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('FND','FORM_RECORD_CHANGED');
      FND_MESSAGE.RAISE_ERROR;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
END Lock_Row;


PROCEDURE Delete_Row(X_row_id		IN	VARCHAR2,
		     X_material_shortage_flag	 OUT NOCOPY 	VARCHAR2,
		     X_material_shortage_check_date	 OUT NOCOPY 	DATE) IS

    l_wip_entity_id        NUMBER := 0;
    l_org_id               NUMBER := 0;
    l_return_status    VARCHAR2(30) := '';
    l_msg_count        NUMBER       := 0;
    l_msg_data         VARCHAR2(30) := '';
    l_operation_seq_num  NUMBER;
    l_inventory_item_id  NUMBER;
    l_wip_entity_type  NUMBER;
    l_status_type     NUMBER;
    l_material_issue_by_mo   VARCHAR2(1);
    l_output_dir	VARCHAR2(512);

    l_eam_mat_req_rec       EAM_PROCESS_WO_PUB.eam_mat_req_rec_type ;
    l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;


BEGIN
 /* get output directory path from database */
   EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


  SELECT wip_entity_id, organization_id, operation_seq_num, inventory_item_id
    INTO l_wip_entity_id, l_org_id, l_operation_seq_num, l_inventory_item_id
    FROM WIP_REQUIREMENT_OPERATIONS
   WHERE rowid = X_row_id;

          l_eam_mat_req_rec.header_id		         := l_wip_entity_id;
          l_eam_mat_req_rec.batch_id                     := 1;
          l_eam_mat_req_rec.row_id                       := null;
          l_eam_mat_req_rec.wip_entity_id                := l_wip_entity_id;
          l_eam_mat_req_rec.organization_id              := l_org_id;
          l_eam_mat_req_rec.operation_seq_num            := l_operation_seq_num;
          l_eam_mat_req_rec.inventory_item_id            := l_inventory_item_id;
          l_eam_mat_req_rec.transaction_type             := EAM_PROCESS_WO_PVT.G_OPR_DELETE;

	  l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;
	  EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
                         , p_commit                  => 'N'
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
                         , p_eam_direct_items_tbl    => l_eam_di_tbl
			 , p_eam_wo_comp_rec          => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl          => l_eam_op_comp_tbl
			 , p_eam_request_tbl          => l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
			 , x_eam_wo_comp_rec          => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl          => l_out_eam_request_tbl
  		         , x_return_status           => l_return_status
  		         , x_msg_count               => l_msg_count
  		         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'delmrthb.log'
  		         , p_output_dir              => l_output_dir
                         , p_debug_file_mode         => 'w'
                       );
	  IF (l_return_status = 'S') THEN
		COMMIT;
               x_material_shortage_flag := l_out_eam_wo_rec.material_shortage_flag;
               x_material_shortage_check_date := l_out_eam_wo_rec.material_shortage_check_date;
	ELSE
           EAM_WORKORDER_UTIL_PKG.show_mesg;
           APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
EXCEPTION
	WHEN OTHERS THEN
            EAM_WORKORDER_UTIL_PKG.show_mesg;
           APP_EXCEPTION.RAISE_EXCEPTION;


END Delete_Row;



--
-- baroy - API to delete a requirements row (called from SS View Materials Page)
--
PROCEDURE Delete_Row_SS(
  p_api_version             IN    NUMBER,
  p_init_msg_list           IN    VARCHAR2,
  p_commit                  IN    VARCHAR2,
  p_validate_only           IN    VARCHAR2,
  p_record_version_number   IN    NUMBER,
  x_return_status           OUT NOCOPY  VARCHAR2,
  x_msg_count               OUT NOCOPY  NUMBER,
  x_msg_data                OUT NOCOPY  VARCHAR2,
  p_inventory_item_id	    IN 	  NUMBER,
  p_organization_id	    IN	  NUMBER,
  p_wip_entity_id	    IN	  NUMBER,
  p_operation_seq_num       IN    NUMBER) IS

  l_material        VARCHAR2(40);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(250);
  l_return_status   VARCHAR2(250);
  l_data            VARCHAR2(250);
  l_msg_index_out   NUMBER;
  l_quantity_issued NUMBER := 0;
  l_wip_entity_type  NUMBER;
  l_status_type      NUMBER;
  l_material_issue_by_mo  VARCHAR2(1);

/* Commenting out for implementing WO API */
/*  CURSOR pending_txns_cur IS
    SELECT 1
    FROM   MTL_MATERIAL_TRANSACTIONS_TEMP
    WHERE  operation_seq_num     = p_operation_seq_num
      AND  inventory_item_id     = p_inventory_item_id
      AND  transaction_source_id = p_wip_entity_id
      AND  organization_id       = p_organization_id
      AND  process_flag         <> 'N'
      AND  posting_flag         <> 'N';
  CURSOR mtl_del_cur IS
    SELECT 1
    FROM   MTL_MATERIAL_TRANSACTIONS
    WHERE  operation_seq_num     = p_operation_seq_num
      AND  inventory_item_id     = p_inventory_item_id
      AND  transaction_source_id = p_wip_entity_id
      AND  organization_id       = p_organization_id; */

  l_output_dir VARCHAR2(512);

     l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
     l_eam_mat_req_rec  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
     l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
     l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
     l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
     l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
     l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
     l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
     l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
     l_eam_direct_items_tbl	EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
     l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
     l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
     l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
     l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
     l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
     l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
     l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
     l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

   l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
   l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
   l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
   l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
   l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
   l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
   l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
   l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
   l_out_eam_direct_items_tbl	EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
   l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
   l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
   l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
   l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
   l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
   l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
   l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
   l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;


BEGIN

  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT delete_row_ss;
  END IF;

  IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;




    l_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_DELETE;
    l_eam_mat_req_rec.wip_entity_id := p_wip_entity_id;
    l_eam_mat_req_rec.organization_id := p_organization_id;
    l_eam_mat_req_rec.operation_seq_num := p_operation_seq_num;
    l_eam_mat_req_rec.inventory_item_id := p_inventory_item_id;

    l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;

   EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


     EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
			 , p_eam_direct_items_tbl    => l_eam_direct_items_tbl
			 , p_eam_wo_comp_rec          => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl          => l_eam_op_comp_tbl
			 , p_eam_request_tbl          => l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
			 , x_eam_direct_items_tbl    => l_out_eam_direct_items_tbl
			 , x_eam_wo_comp_rec          => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl          => l_out_eam_request_tbl
  		         , x_return_status           => x_return_status
  		         , x_msg_count               => x_msg_count
  		         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'delmrss.log'
  		         , p_output_dir              => l_output_dir
                       );


/* Commented out for implementing the WO API */
/*
  DELETE FROM WIP_REQUIREMENT_OPERATIONS
    WHERE wip_entity_id   = p_wip_entity_id
    and organization_id   = p_organization_id
    and inventory_item_id = p_inventory_item_id
    and operation_seq_num = p_operation_seq_num; */
 /* IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;

  ELSE */

/* Commented out for implementing the WO API */
  -- if validate not passed then raise error
/*  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count = 1 THEN
    eam_execution_jsp.Get_Messages
      (p_encoded  => FND_API.G_FALSE,
       p_msg_index => 1,
       p_msg_count => l_msg_count,
       p_msg_data  => nvl(l_msg_data,FND_API.g_MISS_CHAR),
       p_data      => l_data,
       p_msg_index_out => l_msg_index_out);
       x_msg_count := l_msg_count;
       x_msg_data  := l_msg_data;
  ELSE
    x_msg_count  := l_msg_count;
  END IF;

  IF l_msg_count > 0 THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;
*/


  IF FND_API.TO_BOOLEAN(P_COMMIT)
    AND x_return_status = 'S'  THEN
    COMMIT WORK;
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
      IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO delete_row_ss;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN FND_API.G_EXC_ERROR THEN
      IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO delete_row_ss;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO delete_row_ss;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Delete_Row_SS;



--  API to delete a description based item requirements row (called from SS View Materials Page)
--
PROCEDURE Delete_Desc_Row_SS(
  p_api_version             IN    NUMBER,
  p_init_msg_list           IN    VARCHAR2,
  p_commit                  IN    VARCHAR2,
  p_validate_only           IN    VARCHAR2,
  p_record_version_number   IN    NUMBER,
  x_return_status           OUT NOCOPY  VARCHAR2,
  x_msg_count               OUT NOCOPY  NUMBER,
  x_msg_data                OUT NOCOPY  VARCHAR2,
  p_di_sequence_id	    IN 	  NUMBER,
  p_organization_id	    IN	  NUMBER,
  p_wip_entity_id	    IN	  NUMBER,
  p_operation_seq_num       IN    NUMBER) IS

  l_material        VARCHAR2(40);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(250);
  l_return_status   VARCHAR2(250);
  l_data            VARCHAR2(250);
  l_msg_index_out   NUMBER;
  l_quantity_issued NUMBER := 0;
  l_wip_entity_type  NUMBER;
  l_status_type      NUMBER;
  l_material_issue_by_mo  VARCHAR2(1);

    l_output_dir VARCHAR2(512);

     l_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
     l_eam_mat_req_rec  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
     l_eam_direct_item_rec EAM_PROCESS_WO_PUB.eam_direct_items_rec_type;
     l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
     l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
     l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
     l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
     l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
     l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
     l_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
     l_eam_direct_items_tbl	EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
     l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
     l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
     l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
     l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
     l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
     l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
     l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
     l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

   l_out_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;
   l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
   l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
   l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
   l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
   l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
   l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
   l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
   l_out_eam_direct_items_tbl	EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
   l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
   l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
   l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
   l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
   l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
   l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
   l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
   l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

BEGIN

  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT delete_desc_row_ss;
  END IF;

  IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
 EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);


    l_eam_direct_item_rec.transaction_type := EAM_PROCESS_WO_PUB.G_OPR_DELETE;
    l_eam_direct_item_rec.wip_entity_id := p_wip_entity_id;
    l_eam_direct_item_rec.organization_id := p_organization_id;
    l_eam_direct_item_rec.operation_seq_num := p_operation_seq_num;
    l_eam_direct_item_rec.direct_item_sequence_id := p_di_sequence_id;

    l_eam_direct_items_tbl(1) := l_eam_direct_item_rec;

     EAM_PROCESS_WO_PUB.Process_WO
  		         ( p_bo_identifier           => 'EAM'
  		         , p_init_msg_list           => TRUE
  		         , p_api_version_number      => 1.0
  		         , p_eam_wo_rec              => l_eam_wo_rec
  		         , p_eam_op_tbl              => l_eam_op_tbl
  		         , p_eam_op_network_tbl      => l_eam_op_network_tbl
  		         , p_eam_res_tbl             => l_eam_res_tbl
  		         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
  		         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
  		         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
  		         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
			 , p_eam_direct_items_tbl    => l_eam_direct_items_tbl
			 , p_eam_wo_comp_rec          => l_eam_wo_comp_rec
			 , p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
			 , p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
			 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
			 , p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
			 , p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
			 , p_eam_op_comp_tbl          => l_eam_op_comp_tbl
			 , p_eam_request_tbl          => l_eam_request_tbl
  		         , x_eam_wo_rec              => l_out_eam_wo_rec
  		         , x_eam_op_tbl              => l_out_eam_op_tbl
  		         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  		         , x_eam_res_tbl             => l_out_eam_res_tbl
  		         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  		         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  		         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
  		         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
			 , x_eam_direct_items_tbl    => l_out_eam_direct_items_tbl
			 , x_eam_wo_comp_rec          => l_out_eam_wo_comp_rec
			 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
			 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
			 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
			 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
			 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
			 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
			 , x_eam_request_tbl          => l_out_eam_request_tbl
  		         , x_return_status           => x_return_status
  		         , x_msg_count               => x_msg_count
  		         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  		         , p_debug_filename          => 'deldiss.log'
  		         , p_output_dir              => l_output_dir
                       );



  IF FND_API.TO_BOOLEAN(P_COMMIT)
    AND x_return_status = 'S'  THEN
    COMMIT WORK;
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
      IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO delete_desc_row_ss;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN FND_API.G_EXC_ERROR THEN
      IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO delete_desc_row_ss;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO delete_desc_row_ss;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Delete_Desc_Row_SS;





END EAM_REQUIREMENTS_PKG;

/
