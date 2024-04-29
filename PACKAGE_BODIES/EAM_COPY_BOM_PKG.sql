--------------------------------------------------------
--  DDL for Package Body EAM_COPY_BOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_COPY_BOM_PKG" as
/* $Header: EAMCPBMB.pls 120.0.12000000.2 2007/04/09 10:10:32 rasahoo ship $ */

/*
  Procedure to copy materials from  workorder to bom
--  p_organization_id   Organization Id
--  p_organization_code Organization Code
--  p_asset_number      Asset Number
--  p_asset_group_id    Inventory Item  Id
--  p_component_table   Table of workorder materials
--  x_error_code        0   success
                        1   some of components are already in the asset bom
                        2   error in the bom api
*/
PROCEDURE copy_to_bom(
		p_organization_id	IN	NUMBER,
		p_organization_code	IN	VARCHAR2,
		p_asset_number		IN	VARCHAR2,
		p_asset_group_id	IN	NUMBER,
		p_component_table	IN	t_component_table,
		x_error_code		OUT NOCOPY	NUMBER)
IS
  l_component_table EAM_WORKORDER_UTIL_PKG.t_component_table;
  l_index  NUMBER;
  i  NUMBER;
  l_error_code  NUMBER;
BEGIN

   i:= 1;

--Copy the information from the input table to table type of EAM_WORKORDER_UTIL_PKG.t_component_table
  l_index := p_component_table.FIRST;
  loop

     l_component_table(i).component_item := p_component_table(l_index).component_item;
     l_component_table(i).component_item_id:=  p_component_table(l_index).component_item_id;
     l_component_table(i).start_effective_date:=    SYSDATE;
    l_component_table(i).operation_sequence_number:=    p_component_table(l_index).operation_sequence_number;
    l_component_table(i).quantity_per_assembly:=    p_component_table(l_index).quantity_per_assembly;
    l_component_table(i).wip_supply_type:=    p_component_table(l_index).wip_supply_type;
    l_component_table(i).supply_subinventory :=   p_component_table(l_index).supply_subinventory;
    l_component_table(i).supply_locator_id:=    p_component_table(l_index).supply_locator_id;
    l_component_table(i).supply_locator_name:=    p_component_table(l_index).supply_locator_name;

   exit when l_index = p_component_table.LAST;
    l_index := p_component_table.NEXT(l_index);
   i := i+1;
  end loop;


   EAM_WORKORDER_UTIL_PKG.copy_to_bom(
             p_organization_id,
             p_organization_code,
             p_asset_number,
             p_asset_group_id,
             l_component_table,
             x_error_code);

END copy_to_bom;

/*
   Procedure to copy materials from the asset bom to workorder
-- p_organization_id      Organization Id
-- p_wip_entity_id        Wip Entity Id
-- p_operation_seq_num    Operation to which materials are to be copied
-- p_department_id        Department
-- p_bom_table            Table of bom materials
-- x_error_code           S    success
                          U    error
                          E    error
*/
PROCEDURE retrieve_asset_bom(
		p_organization_id	IN 	NUMBER,
		p_wip_entity_id         IN      NUMBER,
                p_operation_seq_num     IN      NUMBER,
                p_department_id         IN      NUMBER,
 		p_bom_table		IN 	t_bom_table,
                x_error_code		OUT NOCOPY	VARCHAR2)
IS
  l_index   NUMBER;
  l_msg_count    NUMBER;
  i  NUMBER;
  l_output_dir VARCHAR2(512);

  l_material_req_table   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;

	l_eam_wo_tbl EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
  	l_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;


	l_out_eam_wo_tbl EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
	l_out_eam_op_tbl  EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_out_eam_op_network_tbl  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_out_eam_res_tbl  EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_out_eam_res_inst_tbl  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_out_eam_sub_res_tbl   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_out_eam_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_out_eam_mat_req_tbl   EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_out_eam_di_tbl   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_eam_wo_relations_tbl      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_eam_wo_relations_tbl1      EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
	l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
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


   i := 1;

--Copy the information from the input table to table type of EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
  l_index := p_bom_table.FIRST;
  loop

    l_material_req_table(i).batch_id := 1;
    l_material_req_table(i).header_id :=p_wip_entity_id;
    l_material_req_table(i).transaction_type := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
    l_material_req_table(i).wip_entity_id := p_wip_entity_id;
    l_material_req_table(i).organization_id := p_organization_id;
    l_material_req_table(i).operation_seq_num := p_operation_seq_num;
    l_material_req_table(i).inventory_item_id :=p_bom_table(l_index).component_item_id;
    l_material_req_table(i).quantity_per_assembly := p_bom_table(l_index).component_quantity;
    l_material_req_table(i).department_id :=p_department_id;
    l_material_req_table(i).wip_supply_type := p_bom_table(l_index).wip_supply_type;

    /* Added for bug#5679199 Start */
    BEGIN
            SELECT first_unit_start_date
              INTO l_material_req_table(i).date_required
              FROM wip_operations
             WHERE wip_entity_id = p_wip_entity_id
               AND operation_seq_num = p_operation_seq_num
               AND organization_id = p_organization_id;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
        l_material_req_table(i).date_required  :=SYSDATE;
     END;

    /* Added for bug#5679199 End */

    l_material_req_table(i).required_quantity :=  p_bom_table(l_index).component_quantity;


  exit when l_index = p_bom_table.LAST;
    l_index := p_bom_table.NEXT(l_index);
   i := i+1;
  end loop;


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
    	         , p_eam_mat_req_tbl         => l_material_req_table
                 , p_eam_direct_items_tbl     =>   l_eam_di_tbl
		 , p_eam_res_usage_tbl	      => l_eam_res_usage_tbl
		 , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
		, p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl     => l_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl          => l_eam_op_comp_tbl
		, p_eam_request_tbl          => l_eam_request_tbl
  	         , x_eam_wo_tbl              => l_out_eam_wo_tbl
                 , x_eam_wo_relations_tbl    => l_eam_wo_relations_tbl1
  	         , x_eam_op_tbl              => l_out_eam_op_tbl
  	         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
  	         , x_eam_res_tbl             => l_out_eam_res_tbl
  	         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
  	         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
  	         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                 , x_eam_direct_items_tbl    => l_out_eam_di_tbl
		 , x_eam_res_usage_tbl	     => l_out_eam_res_usage_tbl
		  , x_eam_wo_comp_tbl         => l_out_eam_wo_comp_tbl
		 , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
		 , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
		 , x_eam_counter_prop_tbl     => l_out_eam_counter_prop_tbl
		 , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
		 , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
		 , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
		 , x_eam_request_tbl          => l_out_eam_request_tbl
  	         , x_return_status           => x_error_code
  	         , x_msg_count               => l_msg_count
  	         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
  	         , p_debug_filename          => 'copytoreq.log'
  	         , p_output_dir              => l_output_dir
                 , p_commit                  => 'N'
                 , p_debug_file_mode         => 'W'
           );
IF(x_error_code='S') THEN
   COMMIT;
 END IF;

END retrieve_asset_bom;


END EAM_COPY_BOM_PKG;

/
