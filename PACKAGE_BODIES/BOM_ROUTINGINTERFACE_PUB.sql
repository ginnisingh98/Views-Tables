--------------------------------------------------------
--  DDL for Package Body BOM_ROUTINGINTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_ROUTINGINTERFACE_PUB" AS
/* $Header: BOMPRTGB.pls 120.1 2005/06/21 02:58:37 appldev ship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30):='BOM_RoutingInterface_PUB';
g_yes		CONSTANT number := 1;
g_no		CONSTANT number := 2;

g_CommitRows	number;
g_Commit	boolean;
g_OrgId		number;
g_OrgCode	varchar2(3);
g_AllOrgs	number;
g_DeleteRows	boolean;
g_UserId        number := -1;
g_LoginId       number;
g_RequestId     number;
g_ProgramId     number;
g_ApplicationId number;

PROCEDURE ImportHeader(x_return_status IN OUT NOCOPY VARCHAR2) is
cursor 	l_interface_csr is
	  Select rowid,
                 routing_sequence_id,
                 assembly_item_id,
                 organization_id,
                 alternate_routing_designator,
                 routing_type,
                 common_assembly_item_id,
                 common_routing_sequence_id,
                 routing_comment,
                 completion_subinventory,
                 completion_locator_id,
                 attribute_category,
                 attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 process_revision,
                 organization_code,
                 assembly_item_number,
                 common_item_number,
                 location_name,
                 transaction_type,
                 line_id,
                 line_code,
                 mixed_model_map_flag,
                 priority,
                 cfm_routing_flag,
                 total_product_cycle_time,
                 ctp_flag
	  From bom_op_routings_interface
          Where process_flag = 1
          And (g_AllOrgs = g_yes
 	       or organization_id = g_OrgId
 	       or organization_code = g_OrgCode
              );
l_phase NUMBER := 1; -- scan table twice in case commons point to new routings
l_return_status  VARCHAR2(1);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000);
l_msg_name	 VARCHAR2(80);
l_msg_app	 VARCHAR2(3);
l_DelGrpFound 	 BOOLEAN := false;
l_ret_code 	 NUMBER := 0;
cursor  l_RtgDeleteGroup_csr is
          Select delete_group_name,
	         description
          From bom_interface_delete_groups
	  Where upper(entity_name) = G_RtgDelEntity
          And rownum = 1;
cursor  l_Transaction_csr is
          Select mtl_system_items_interface_s.nextval transaction_id
          From dual;
l_api_name  	CONSTANT VARCHAR2(30)	:= 'ImportHeader';
Begin


  While l_phase <= 2 loop -- two passes
    For l_interface_rec in l_interface_csr loop
      Declare
        l_routing_rec BOM_RoutingHeader_PVT.routing_rec_type;
      Begin -- nested block within loop
	if (upper(l_interface_rec.transaction_type) = 'CREATE') then
         l_interface_rec.transaction_type := G_Insert ;
        else
         l_interface_rec.transaction_type := upper(l_interface_rec.transaction_type);
        end if ;

	-- primary keys
        If l_interface_rec.routing_sequence_id = G_NullNum then
          l_routing_rec.routing_sequence_id := null;
        Else
          l_routing_rec.routing_sequence_id :=
	    l_interface_rec.routing_sequence_id;
        End if;
        If l_interface_rec.assembly_item_id = G_NullNum then
          l_routing_rec.assembly_item_id := null;
        Else
          l_routing_rec.assembly_item_id := l_interface_rec.assembly_item_id;
        End if;
        If l_interface_rec.organization_id = G_NullNum then
          l_routing_rec.organization_id := null;
        Else
          l_routing_rec.organization_id := l_interface_rec.organization_id;
        End if;
        If l_interface_rec.alternate_routing_designator = G_NullChar then
          l_routing_rec.alternate_routing_designator := null;
        Else
          l_routing_rec.alternate_routing_designator :=
	    l_interface_rec.alternate_routing_designator;
        End if;
	-- end primary keys


        If l_interface_rec.routing_type = G_NullNum then
          l_routing_rec.routing_type := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.routing_type :=
            nvl(l_interface_rec.routing_type, Fnd_Api.G_Miss_Num);
        Else
          l_routing_rec.routing_type := l_interface_rec.routing_type;
        End if;

        If l_interface_rec.common_assembly_item_id = G_NullNum then
          l_routing_rec.common_assembly_item_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.common_assembly_item_id :=
            nvl(l_interface_rec.common_assembly_item_id, Fnd_Api.G_Miss_Num);
        Else
          l_routing_rec.common_assembly_item_id :=
	    l_interface_rec.common_assembly_item_id;
        End if;

        If l_interface_rec.common_routing_sequence_id = G_NullNum then
          l_routing_rec.common_routing_sequence_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.common_routing_sequence_id :=
            nvl(l_interface_rec.common_routing_sequence_id, Fnd_Api.G_Miss_Num);
        Else
          l_routing_rec.common_routing_sequence_id :=
	    l_interface_rec.common_routing_sequence_id;
        End if;

        If l_interface_rec.routing_comment = G_NullChar then
          l_routing_rec.routing_comment := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.routing_comment :=
            nvl(l_interface_rec.routing_comment, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.routing_comment := l_interface_rec.routing_comment;
        End if;

        If l_interface_rec.completion_subinventory = G_NullChar then
          l_routing_rec.completion_subinventory := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.completion_subinventory :=
            nvl(l_interface_rec.completion_subinventory, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.completion_subinventory :=
	    l_interface_rec.completion_subinventory;
        End if;

        If l_interface_rec.completion_locator_id = G_NullNum then
          l_routing_rec.completion_locator_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.completion_locator_id :=
            nvl(l_interface_rec.completion_locator_id, Fnd_Api.G_Miss_Num);
        Else
          l_routing_rec.completion_locator_id :=
	    l_interface_rec.completion_locator_id;
        End if;

        If l_interface_rec.attribute_category = G_NullChar then
          l_routing_rec.attribute_category := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute_category :=
            nvl(l_interface_rec.attribute_category, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute_category :=
	    l_interface_rec.attribute_category;
        End if;

        If l_interface_rec.attribute1 = G_NullChar then
          l_routing_rec.attribute1 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute1 :=
            nvl(l_interface_rec.attribute1, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute1 := l_interface_rec.attribute1;
        End if;

        If l_interface_rec.attribute2 = G_NullChar then
          l_routing_rec.attribute2 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute2 :=
            nvl(l_interface_rec.attribute2, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute2 := l_interface_rec.attribute2;
        End if;

        If l_interface_rec.attribute3 = G_NullChar then
          l_routing_rec.attribute3 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute3 :=
            nvl(l_interface_rec.attribute3, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute3 := l_interface_rec.attribute3;
        End if;

        If l_interface_rec.attribute4 = G_NullChar then
          l_routing_rec.attribute4 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute4 :=
            nvl(l_interface_rec.attribute4, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute4 := l_interface_rec.attribute4;
        End if;

        If l_interface_rec.attribute5 = G_NullChar then
          l_routing_rec.attribute5 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute5 :=
            nvl(l_interface_rec.attribute5, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute5 := l_interface_rec.attribute5;
        End if;

        If l_interface_rec.attribute6 = G_NullChar then
          l_routing_rec.attribute6 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute6 :=
            nvl(l_interface_rec.attribute6, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute6 := l_interface_rec.attribute6;
        End if;

        If l_interface_rec.attribute7 = G_NullChar then
          l_routing_rec.attribute7 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute7 :=
            nvl(l_interface_rec.attribute7, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute7 := l_interface_rec.attribute7;
        End if;

        If l_interface_rec.attribute8 = G_NullChar then
          l_routing_rec.attribute8 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute8 :=
            nvl(l_interface_rec.attribute8, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute8 := l_interface_rec.attribute8;
        End if;

        If l_interface_rec.attribute9 = G_NullChar then
          l_routing_rec.attribute9 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute9 :=
            nvl(l_interface_rec.attribute9, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute9 := l_interface_rec.attribute9;
        End if;

        If l_interface_rec.attribute10 = G_NullChar then
          l_routing_rec.attribute10 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute10 :=
            nvl(l_interface_rec.attribute10, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute10 := l_interface_rec.attribute10;
        End if;

        If l_interface_rec.attribute11 = G_NullChar then
          l_routing_rec.attribute11 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute11 :=
            nvl(l_interface_rec.attribute11, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute11 := l_interface_rec.attribute11;
        End if;

        If l_interface_rec.attribute12 = G_NullChar then
          l_routing_rec.attribute12 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute12 :=
            nvl(l_interface_rec.attribute12, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute12 := l_interface_rec.attribute12;
        End if;

        If l_interface_rec.attribute13 = G_NullChar then
          l_routing_rec.attribute13 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute13 :=
            nvl(l_interface_rec.attribute13, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute13 := l_interface_rec.attribute13;
        End if;

        If l_interface_rec.attribute14 = G_NullChar then
          l_routing_rec.attribute14 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute14 :=
            nvl(l_interface_rec.attribute14, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute14 := l_interface_rec.attribute14;
        End if;

        If l_interface_rec.attribute15 = G_NullChar then
          l_routing_rec.attribute15 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.attribute15 :=
            nvl(l_interface_rec.attribute15, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.attribute15 := l_interface_rec.attribute15;
        End if;

        If l_interface_rec.organization_code = G_NullChar then
          l_routing_rec.organization_code := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.organization_code :=
            nvl(l_interface_rec.organization_code, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.organization_code := l_interface_rec.organization_code;
        End if;

        If l_interface_rec.assembly_item_number = G_NullChar then
          l_routing_rec.assembly_item_number := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.assembly_item_number :=
            nvl(l_interface_rec.assembly_item_number, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.assembly_item_number :=
	    l_interface_rec.assembly_item_number;
        End if;

        If l_interface_rec.common_item_number = G_NullChar then
          l_routing_rec.common_item_number := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.common_item_number :=
            nvl(l_interface_rec.common_item_number, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.common_item_number :=
	    l_interface_rec.common_item_number;
        End if;

        If l_interface_rec.location_name = G_NullChar then
          l_routing_rec.location_name := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.location_name :=
            nvl(l_interface_rec.location_name, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.location_name := l_interface_rec.location_name;
        End if;

        If l_interface_rec.line_id = G_NullNum then
          l_routing_rec.line_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.line_id :=
            nvl(l_interface_rec.line_id, Fnd_Api.G_Miss_Num);
        Else
          l_routing_rec.line_id := l_interface_rec.line_id;
        End if;

        If l_interface_rec.line_code = G_NullChar then
          l_routing_rec.line_code := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.line_code :=
            nvl(l_interface_rec.line_code, Fnd_Api.G_Miss_Char);
        Else
          l_routing_rec.line_code := l_interface_rec.line_code;
        End if;

        If l_interface_rec.mixed_model_map_flag = G_NullNum then
          l_routing_rec.mixed_model_map_flag := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.mixed_model_map_flag :=
            nvl(l_interface_rec.mixed_model_map_flag, Fnd_Api.G_Miss_Num);
        Else
          l_routing_rec.mixed_model_map_flag :=
	    l_interface_rec.mixed_model_map_flag;
        End if;

        If l_interface_rec.priority = G_NullNum then
          l_routing_rec.priority := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.priority :=
            nvl(l_interface_rec.priority, Fnd_Api.G_Miss_Num);
        Else
          l_routing_rec.priority := l_interface_rec.priority;
        End if;

        If l_interface_rec.cfm_routing_flag = G_NullNum then
          l_routing_rec.cfm_routing_flag := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.cfm_routing_flag :=
            nvl(l_interface_rec.cfm_routing_flag, Fnd_Api.G_Miss_Num);
        Else
          l_routing_rec.cfm_routing_flag := l_interface_rec.cfm_routing_flag;
        End if;

        If l_interface_rec.total_product_cycle_time = G_NullNum then
          l_routing_rec.total_product_cycle_time := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.total_product_cycle_time :=
            nvl(l_interface_rec.total_product_cycle_time, Fnd_Api.G_Miss_Num);
        Else
          l_routing_rec.total_product_cycle_time :=
	    l_interface_rec.total_product_cycle_time;
        End if;

        If l_interface_rec.ctp_flag = G_NullNum then
          l_routing_rec.ctp_flag := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_routing_rec.ctp_flag :=
            nvl(l_interface_rec.ctp_flag, Fnd_Api.G_Miss_Num);
        Else
          l_routing_rec.ctp_flag := l_interface_rec.ctp_flag;
        End if;

        If l_interface_rec.transaction_type = G_Insert then

	  BOM_RoutingHeader_PVT.CreateRouting (
	    p_api_version           =>      1.0,
            p_init_msg_list         =>      FND_API.G_TRUE,
            p_commit                =>      FND_API.G_FALSE,
            p_validation_level      =>      FND_API.G_VALID_LEVEL_FULL,
            x_return_status         =>      l_return_status,
            x_msg_count             =>      l_msg_count,
            x_msg_data              =>      l_msg_data,
            p_routing_rec           =>      l_routing_rec,
            x_routing_rec           =>      l_routing_rec
          );

          -- insert given process_revision
          If nvl(l_interface_rec.process_revision, G_NullChar) <>
	  G_NullChar and l_phase = 1 then
            Insert into mtl_rtg_item_revs_interface
		   (inventory_item_id,
		    inventory_item_number,
                    organization_id,
		    organization_code,
		    process_revision,
                    process_flag,
		    effectivity_date,
                    implementation_date,
                    transaction_type)
            values (l_interface_rec.assembly_item_id,
		    l_interface_rec.assembly_item_number,
		    l_interface_rec.organization_id,
		    l_interface_rec.organization_code,
		    upper(l_interface_rec.process_revision),
		    1,
                    sysdate,
		    sysdate,
                    G_Insert);
	  End if; -- new routing revision

        Elsif l_interface_rec.transaction_type = G_Update then

 	  BOM_RoutingHeader_PVT.UpdateRouting(
            p_api_version           =>      1.0,
            p_init_msg_list         =>      FND_API.G_TRUE,
            p_commit                =>      FND_API.G_FALSE,
            p_validation_level      =>      FND_API.G_VALID_LEVEL_FULL,
            x_return_status         =>      l_return_status,
            x_msg_count             =>      l_msg_count,
            x_msg_data              =>      l_msg_data,
            p_routing_rec           =>      l_routing_rec,
	    x_routing_rec           =>      l_routing_rec);

        Elsif l_interface_rec.transaction_type = G_Delete then

	  l_DelGrpFound := false;
	  For l_DelGrp_rec in l_RtgDeleteGroup_csr loop
	    l_DelGrpFound := true;
	    BOM_RoutingHeader_PVT.DeleteRouting(
              p_api_version           =>      1.0,
              p_init_msg_list         =>      FND_API.G_TRUE,
              p_commit                =>      FND_API.G_FALSE,
              p_validation_level      =>      FND_API.G_VALID_LEVEL_FULL,
              x_return_status         =>      l_return_status,
              x_msg_count             =>      l_msg_count,
              x_msg_data              =>      l_msg_data,
              p_delete_group          =>      l_DelGrp_rec.delete_group_name,
              p_description           =>      l_DelGrp_rec.description,
              p_routing_rec           =>      l_routing_rec,
              x_routing_rec           =>      l_routing_rec
	    );
	  End loop; -- delete routing
          If not l_DelGrpFound then
	    Fnd_Message.Set_Name('BOM', 'BOM_DELETE_GROUP_NULL');
            l_return_status := FND_API.G_RET_STS_ERROR;
    	    FND_MSG_PUB.Initialize;
    	    FND_MSG_PUB.Add;
    	    FND_MSG_PUB.Count_And_Get(
      	      p_count => l_msg_count,
      	      p_data  => l_msg_data
    	    );
	  End if; -- Delete group unspecified
        End if; -- insert, update and delete

        If l_return_status = Fnd_Api.G_RET_STS_SUCCESS then
	  If g_DeleteRows then
            Delete from bom_op_routings_interface
	    Where rowid = l_interface_rec.rowid;
	  Else
	    Update bom_op_routings_interface
	    Set process_flag = 7,
	        transaction_id = mtl_system_items_interface_s.nextval,
		request_id = nvl(request_id,g_RequestId),
		program_id = nvl(program_id,g_ProgramId),
	program_application_id = nvl(program_application_id,g_ApplicationId),
		program_update_date = nvl(program_update_date,sysdate),
		created_by = nvl(created_by,g_UserId),
		last_updated_by = nvl(last_updated_by,g_UserId),
		creation_date = nvl(creation_date,sysdate),
		last_update_date = nvl(last_update_date,sysdate),
		last_update_login = nvl(last_update_login,g_LoginId)
	    Where rowid = l_interface_rec.rowid;
          End if;
        Elsif l_return_status = Fnd_Api.G_RET_STS_ERROR then
          If l_phase = 2 then
            If l_msg_count > 1 then
    	      l_msg_data := FND_MSG_PUB.Get;
            End if;
            Fnd_Message.Parse_Encoded(
              ENCODED_MESSAGE => l_msg_data,
              APP_SHORT_NAME  => l_msg_app,
              MESSAGE_NAME    => l_msg_name);
            For l_transaction_rec in l_Transaction_csr loop
  	      l_ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => g_OrgId,
                        user_id => g_UserId,
                        login_id => g_LoginId,
                        prog_appid => g_ApplicationId,
                        prog_id => g_ProgramId,
                        req_id => g_RequestId,
                        trans_id => l_transaction_rec.transaction_id,
                        error_text => l_msg_data,
                        tbl_name => 'BOM_OP_ROUTINGS_INTERFACE',
                        msg_name => l_msg_name,
                        err_text => l_msg_data);
              If l_ret_code <> 0 then
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
              end if;
	      Update bom_op_routings_interface
	      Set process_flag = 3,
	        transaction_id = l_transaction_rec.transaction_id
	      Where rowid = l_interface_rec.rowid;
            End loop; -- log error
          End if; -- final phase
        Elsif l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR then
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        End if; -- process return status
      End; -- nested block

      If g_Commit then
	If mod(l_interface_csr%rowcount, g_CommitRows) = 0 then
          COMMIT WORK;
        End if;
      End if; -- periodic commits
    End loop; -- scan interface table
    If g_Commit then
       COMMIT WORK;
    End if; -- commit remaining rows
    -- rescan table in case of commons pointing to new routings
    l_phase :=  l_phase + 1;
  End loop; -- phase
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
END ImportHeader;

PROCEDURE ImportOperation(x_return_status IN OUT NOCOPY VARCHAR2) is
cursor 	l_interface_csr is
	  Select rowid,
                 operation_sequence_id,
                 routing_sequence_id,
                 operation_seq_num,
                 standard_operation_id,
                 department_id,
                 operation_lead_time_percent,
                 minimum_transfer_quantity,
                 count_point_type,
                 operation_description,
                 effectivity_date,
                 disable_date,
                 backflush_flag,
                 option_dependent_flag,
                 attribute_category,
                 attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 assembly_item_id,
                 organization_id,
                 alternate_routing_designator,
                 organization_code,
                 assembly_item_number,
                 department_code,
                 operation_code,
                 resource_id1,
                 resource_id2,
                 resource_id3,
                 resource_code1,
                 resource_code2,
                 resource_code3,
                 transaction_type,
                 new_operation_seq_num,
                 new_effectivity_date,
                 operation_type,
                 reference_flag,
                 process_op_seq_id,
                 line_op_seq_id,
                 yield,
                 cumulative_yield,
                 reverse_cumulative_yield,
                 labor_time_calc,
                 machine_time_calc,
                 total_time_calc,
                 labor_time_user,
                 machine_time_user,
                 total_time_user,
                 net_planning_percent,
		 include_in_rollup,
		 operation_yield_enabled
	  From bom_op_sequences_interface
          Where process_flag = 1
          And (g_AllOrgs = g_yes
 	       or organization_id = g_OrgId
 	       or organization_code = g_OrgCode
              );
l_phase NUMBER := 1; -- scan table twice in case events point to new parents
l_return_status  VARCHAR2(1);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000);
l_msg_name	 VARCHAR2(80);
l_msg_app	 VARCHAR2(3);
l_DelGrpFound 	 BOOLEAN := false;
l_ret_code 	 NUMBER := 0;
cursor  l_OprDeleteGroup_csr is
          Select delete_group_name,
	         description
          From bom_interface_delete_groups
	  Where upper(entity_name) = G_OprDelEntity
 	  And rownum = 1;
cursor  l_Transaction_csr is
          Select mtl_system_items_interface_s.nextval transaction_id
          From dual;
l_api_name  	CONSTANT VARCHAR2(30)	:= 'ImportOperation';
Begin
  While l_phase <= 2 loop -- two passes
    For l_interface_rec in l_interface_csr loop
      Declare
        l_operation_rec BOM_Operation_PVT.operation_rec_type;
      Begin -- nested block within loop
	if (upper(l_interface_rec.transaction_type) = 'CREATE') then
         l_interface_rec.transaction_type := G_Insert ;
        else
         l_interface_rec.transaction_type := upper(l_interface_rec.transaction_type);
        end if ;

        If l_interface_rec.operation_sequence_id = G_NullNum then
          l_operation_rec.operation_sequence_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.operation_sequence_id :=
            nvl(l_interface_rec.operation_sequence_id, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.operation_sequence_id :=
	    l_interface_rec.operation_sequence_id;
        End if;

        If l_interface_rec.routing_sequence_id = G_NullNum then
          l_operation_rec.routing_sequence_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.routing_sequence_id :=
            nvl(l_interface_rec.routing_sequence_id, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.routing_sequence_id :=
	    l_interface_rec.routing_sequence_id;
        End if;

        If l_interface_rec.assembly_item_id = G_NullNum then
          l_operation_rec.assembly_item_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.assembly_item_id :=
            nvl(l_interface_rec.assembly_item_id, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.assembly_item_id := l_interface_rec.assembly_item_id;
        End if;

        If l_interface_rec.assembly_item_number = G_NullChar then
          l_operation_rec.assembly_item_number := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.assembly_item_number :=
            nvl(l_interface_rec.assembly_item_number, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.assembly_item_number :=
	    l_interface_rec.assembly_item_number;
        End if;

        If l_interface_rec.organization_id = G_NullNum then
          l_operation_rec.organization_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.organization_id :=
            nvl(l_interface_rec.organization_id, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.organization_id := l_interface_rec.organization_id;
        End if;

        If l_interface_rec.organization_code = G_NullChar then
          l_operation_rec.organization_code := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.organization_code :=
            nvl(l_interface_rec.organization_code, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.organization_code :=
	    l_interface_rec.organization_code;
        End if;

        If l_interface_rec.alternate_routing_designator = G_NullChar then
          l_operation_rec.alternate_routing_designator := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.alternate_routing_designator :=
            nvl(l_interface_rec.alternate_routing_designator,
	      Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.alternate_routing_designator :=
	    l_interface_rec.alternate_routing_designator;
        End if;

        If l_interface_rec.operation_seq_num = G_NullNum then
          l_operation_rec.operation_seq_num := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.operation_seq_num :=
            nvl(l_interface_rec.operation_seq_num, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.operation_seq_num :=
	    l_interface_rec.operation_seq_num;
        End if;

        If l_interface_rec.new_operation_seq_num = G_NullNum then
          l_operation_rec.new_operation_seq_num := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.new_operation_seq_num :=
            nvl(l_interface_rec.new_operation_seq_num, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.new_operation_seq_num :=
	    l_interface_rec.new_operation_seq_num;
        End if;

        If l_interface_rec.standard_operation_id = G_NullNum then
          l_operation_rec.standard_operation_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.standard_operation_id :=
            nvl(l_interface_rec.standard_operation_id, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.standard_operation_id :=
	    l_interface_rec.standard_operation_id;
        End if;

        If l_interface_rec.operation_code = G_NullChar then
          l_operation_rec.operation_code := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.operation_code :=
            nvl(l_interface_rec.operation_code, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.operation_code := l_interface_rec.operation_code;
        End if;

        If l_interface_rec.department_id = G_NullNum then
          l_operation_rec.department_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.department_id :=
            nvl(l_interface_rec.department_id, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.department_id := l_interface_rec.department_id;
        End if;

        If l_interface_rec.department_code = G_NullChar then
          l_operation_rec.department_code := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.department_code :=
            nvl(l_interface_rec.department_code, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.department_code := l_interface_rec.department_code;
        End if;

        If l_interface_rec.operation_lead_time_percent = G_NullNum then
          l_operation_rec.operation_lead_time_percent := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.operation_lead_time_percent :=
            nvl(l_interface_rec.operation_lead_time_percent,
	      Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.operation_lead_time_percent :=
	    l_interface_rec.operation_lead_time_percent;
        End if;

        If l_interface_rec.minimum_transfer_quantity = G_NullNum then
          l_operation_rec.minimum_transfer_quantity := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.minimum_transfer_quantity :=
            nvl(l_interface_rec.minimum_transfer_quantity, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.minimum_transfer_quantity :=
	    NVL(l_interface_rec.minimum_transfer_quantity, 0);
        End if;

        If l_interface_rec.count_point_type = G_NullNum then
          l_operation_rec.count_point_type := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.count_point_type :=
            nvl(l_interface_rec.count_point_type, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.count_point_type := l_interface_rec.count_point_type;
        End if;

        If l_interface_rec.operation_description = G_NullChar then
          l_operation_rec.operation_description := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.operation_description :=
            nvl(l_interface_rec.operation_description, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.operation_description :=
	    l_interface_rec.operation_description;
        End if;

        If l_interface_rec.effectivity_date = G_NullDate then
          l_operation_rec.effectivity_date := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.effectivity_date :=
            nvl(l_interface_rec.effectivity_date, Fnd_Api.G_Miss_Date);
        Else
          l_operation_rec.effectivity_date := l_interface_rec.effectivity_date;
        End if;

        If l_interface_rec.new_effectivity_date = G_NullDate then
          l_operation_rec.new_effectivity_date := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.new_effectivity_date :=
            nvl(l_interface_rec.new_effectivity_date, Fnd_Api.G_Miss_Date);
        Else
          l_operation_rec.new_effectivity_date :=
	    l_interface_rec.new_effectivity_date;
        End if;

        If l_interface_rec.disable_date = G_NullDate then
          l_operation_rec.disable_date := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.disable_date :=
            nvl(l_interface_rec.disable_date, Fnd_Api.G_Miss_Date);
        Else
          l_operation_rec.disable_date := l_interface_rec.disable_date;
        End if;

        If l_interface_rec.backflush_flag = G_NullNum then
          l_operation_rec.backflush_flag := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.backflush_flag :=
            nvl(l_interface_rec.backflush_flag, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.backflush_flag := l_interface_rec.backflush_flag;
        End if;

        If l_interface_rec.option_dependent_flag = G_NullNum then
          l_operation_rec.option_dependent_flag := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.option_dependent_flag :=
            nvl(l_interface_rec.option_dependent_flag, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.option_dependent_flag :=
	    l_interface_rec.option_dependent_flag;
        End if;

        If l_interface_rec.attribute_category = G_NullChar then
          l_operation_rec.attribute_category := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute_category :=
            nvl(l_interface_rec.attribute_category, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute_category :=
	    l_interface_rec.attribute_category;
        End if;

        If l_interface_rec.attribute1 = G_NullChar then
          l_operation_rec.attribute1 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute1 :=
            nvl(l_interface_rec.attribute1, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute1 := l_interface_rec.attribute1;
        End if;

        If l_interface_rec.attribute2 = G_NullChar then
          l_operation_rec.attribute2 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute2 :=
            nvl(l_interface_rec.attribute2, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute2 := l_interface_rec.attribute2;
        End if;

        If l_interface_rec.attribute3 = G_NullChar then
          l_operation_rec.attribute3 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute3 :=
            nvl(l_interface_rec.attribute3, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute3 := l_interface_rec.attribute3;
        End if;

        If l_interface_rec.attribute4 = G_NullChar then
          l_operation_rec.attribute4 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute4 :=
            nvl(l_interface_rec.attribute4, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute4 := l_interface_rec.attribute4;
        End if;

        If l_interface_rec.attribute5 = G_NullChar then
          l_operation_rec.attribute5 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute5 :=
            nvl(l_interface_rec.attribute5, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute5 := l_interface_rec.attribute5;
        End if;

        If l_interface_rec.attribute6 = G_NullChar then
          l_operation_rec.attribute6 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute6 :=
            nvl(l_interface_rec.attribute6, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute6 := l_interface_rec.attribute6;
        End if;

        If l_interface_rec.attribute7 = G_NullChar then
          l_operation_rec.attribute7 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute7 :=
            nvl(l_interface_rec.attribute7, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute7 := l_interface_rec.attribute7;
        End if;

        If l_interface_rec.attribute8 = G_NullChar then
          l_operation_rec.attribute8 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute8 :=
            nvl(l_interface_rec.attribute8, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute8 := l_interface_rec.attribute8;
        End if;

        If l_interface_rec.attribute9 = G_NullChar then
          l_operation_rec.attribute9 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute9 :=
            nvl(l_interface_rec.attribute9, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute9 := l_interface_rec.attribute9;
        End if;

        If l_interface_rec.attribute10 = G_NullChar then
          l_operation_rec.attribute10 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute10 :=
            nvl(l_interface_rec.attribute10, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute10 := l_interface_rec.attribute10;
        End if;

        If l_interface_rec.attribute11 = G_NullChar then
          l_operation_rec.attribute11 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute11 :=
            nvl(l_interface_rec.attribute11, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute11 := l_interface_rec.attribute11;
        End if;

        If l_interface_rec.attribute12 = G_NullChar then
          l_operation_rec.attribute12 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute12 :=
            nvl(l_interface_rec.attribute12, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute12 := l_interface_rec.attribute12;
        End if;

        If l_interface_rec.attribute13 = G_NullChar then
          l_operation_rec.attribute13 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute13 :=
            nvl(l_interface_rec.attribute13, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute13 := l_interface_rec.attribute13;
        End if;

        If l_interface_rec.attribute14 = G_NullChar then
          l_operation_rec.attribute14 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute14 :=
            nvl(l_interface_rec.attribute14, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute14 := l_interface_rec.attribute14;
        End if;

        If l_interface_rec.attribute15 = G_NullChar then
          l_operation_rec.attribute15 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.attribute15 :=
            nvl(l_interface_rec.attribute15, Fnd_Api.G_Miss_Char);
        Else
          l_operation_rec.attribute15 := l_interface_rec.attribute15;
        End if;

        If l_interface_rec.operation_type = G_NullNum then
          l_operation_rec.operation_type := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.operation_type :=
            nvl(l_interface_rec.operation_type, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.operation_type := l_interface_rec.operation_type;
        End if;

        If l_interface_rec.reference_flag = G_NullNum then
          l_operation_rec.reference_flag := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.reference_flag :=
            nvl(l_interface_rec.reference_flag, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.reference_flag := l_interface_rec.reference_flag;
        End if;

        If l_interface_rec.process_op_seq_id = G_NullNum then
          l_operation_rec.process_op_seq_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.process_op_seq_id :=
            nvl(l_interface_rec.process_op_seq_id, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.process_op_seq_id :=
	    l_interface_rec.process_op_seq_id;
        End if;

        If l_interface_rec.line_op_seq_id = G_NullNum then
          l_operation_rec.line_op_seq_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.line_op_seq_id :=
            nvl(l_interface_rec.line_op_seq_id, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.line_op_seq_id := l_interface_rec.line_op_seq_id;
        End if;

        If l_interface_rec.yield = G_NullNum then
          l_operation_rec.yield := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.yield :=
            nvl(l_interface_rec.yield, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.yield := l_interface_rec.yield;
        End if;

        If l_interface_rec.cumulative_yield = G_NullNum then
          l_operation_rec.cumulative_yield := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.cumulative_yield :=
            nvl(l_interface_rec.cumulative_yield, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.cumulative_yield := l_interface_rec.cumulative_yield;
        End if;

        If l_interface_rec.reverse_cumulative_yield = G_NullNum then
          l_operation_rec.reverse_cumulative_yield := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.reverse_cumulative_yield :=
            nvl(l_interface_rec.reverse_cumulative_yield, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.reverse_cumulative_yield :=
	    l_interface_rec.reverse_cumulative_yield;
        End if;

        If l_interface_rec.labor_time_calc = G_NullNum then
          l_operation_rec.labor_time_calc := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.labor_time_calc :=
            nvl(l_interface_rec.labor_time_calc, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.labor_time_calc := l_interface_rec.labor_time_calc;
        End if;

        If l_interface_rec.machine_time_calc = G_NullNum then
          l_operation_rec.machine_time_calc := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.machine_time_calc :=
            nvl(l_interface_rec.machine_time_calc, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.machine_time_calc :=
	    l_interface_rec.machine_time_calc;
        End if;

        If l_interface_rec.total_time_calc = G_NullNum then
          l_operation_rec.total_time_calc := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.total_time_calc :=
            nvl(l_interface_rec.total_time_calc, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.total_time_calc := l_interface_rec.total_time_calc;
        End if;

        If l_interface_rec.labor_time_user = G_NullNum then
          l_operation_rec.labor_time_user := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.labor_time_user :=
            nvl(l_interface_rec.labor_time_user, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.labor_time_user := l_interface_rec.labor_time_user;
        End if;

        If l_interface_rec.machine_time_user = G_NullNum then
          l_operation_rec.machine_time_user := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.machine_time_user :=
            nvl(l_interface_rec.machine_time_user, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.machine_time_user :=
	    l_interface_rec.machine_time_user;
        End if;

        If l_interface_rec.total_time_user = G_NullNum then
          l_operation_rec.total_time_user := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.total_time_user :=
            nvl(l_interface_rec.total_time_user, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.total_time_user := l_interface_rec.total_time_calc;
        End if;

        If l_interface_rec.net_planning_percent = G_NullNum then
          l_operation_rec.net_planning_percent := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.net_planning_percent :=
            nvl(l_interface_rec.net_planning_percent, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.net_planning_percent :=
	    l_interface_rec.net_planning_percent;
        End if;

        If l_interface_rec.include_in_rollup = G_NullNum then
          l_operation_rec.include_in_rollup := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.include_in_rollup :=
            nvl(l_interface_rec.include_in_rollup, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.include_in_rollup := l_interface_rec.include_in_rollup;
        End if;

        If l_interface_rec.operation_yield_enabled = G_NullNum then
          l_operation_rec.operation_yield_enabled := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_operation_rec.operation_yield_enabled :=
            nvl(l_interface_rec.operation_yield_enabled, Fnd_Api.G_Miss_Num);
        Else
          l_operation_rec.operation_yield_enabled := l_interface_rec.operation_yield_enabled;
        End if;

        If l_interface_rec.transaction_type = G_Insert then

	  BOM_Operation_PVT.CreateOperation(
	    p_api_version           =>      1.0,
            p_init_msg_list         =>      FND_API.G_TRUE,
            p_commit                =>      FND_API.G_FALSE,
            p_validation_level      =>      FND_API.G_VALID_LEVEL_FULL,
            x_return_status         =>      l_return_status,
            x_msg_count             =>      l_msg_count,
            x_msg_data              =>      l_msg_data,
            p_operation_rec         =>      l_operation_rec,
            x_operation_rec         =>      l_operation_rec
          );

          -- insert given operation resources into interface table
          If l_return_status = FND_API.G_RET_STS_SUCCESS then
            If nvl(l_interface_rec.resource_code1, G_NullChar) <> G_NullChar
	    or nvl(l_interface_rec.resource_id1, G_NullNum) <> G_NullNum then
    	      insert into bom_op_resources_interface(
	        OPERATION_SEQUENCE_ID,
	        ASSEMBLY_ITEM_ID,
	        ASSEMBLY_ITEM_NUMBER,
	        ORGANIZATION_ID,
	        ORGANIZATION_CODE,
	        ALTERNATE_ROUTING_DESIGNATOR,
	        OPERATION_SEQ_NUM,
	        EFFECTIVITY_DATE,
	        RESOURCE_SEQ_NUM,
	        RESOURCE_ID,
	        RESOURCE_CODE,
	        PROCESS_FLAG,
 		TRANSACTION_TYPE)
	      values (
	        l_operation_rec.operation_sequence_id,
	        l_operation_rec.assembly_item_id,
	        l_operation_rec.assembly_item_number,
	        l_operation_rec.organization_id,
	        l_operation_rec.organization_code,
	        l_operation_rec.alternate_routing_designator,
	        l_operation_rec.operation_seq_num,
	        l_operation_rec.effectivity_date,
	        10,
	        l_interface_rec.resource_id1,
	        l_interface_rec.resource_code1,
	        1,
                G_Insert);
	    end if; -- resource 1
            If nvl(l_interface_rec.resource_code2, G_NullChar) <> G_NullChar
	    or nvl(l_interface_rec.resource_id2, G_NullNum) <> G_NullNum then
              insert into bom_op_resources_interface (
	        OPERATION_SEQUENCE_ID,
	        ASSEMBLY_ITEM_ID,
	        ASSEMBLY_ITEM_NUMBER,
	        ORGANIZATION_ID,
	        ORGANIZATION_CODE,
	        ALTERNATE_ROUTING_DESIGNATOR,
	        OPERATION_SEQ_NUM,
	        EFFECTIVITY_DATE,
	        RESOURCE_SEQ_NUM,
	        RESOURCE_ID,
	        RESOURCE_CODE,
	        PROCESS_FLAG,
		TRANSACTION_TYPE)
	      values (
	        l_operation_rec.operation_sequence_id,
	        l_operation_rec.assembly_item_id,
	        l_operation_rec.assembly_item_number,
	        l_operation_rec.organization_id,
	        l_operation_rec.organization_code,
	        l_operation_rec.alternate_routing_designator,
	        l_operation_rec.operation_seq_num,
	        l_operation_rec.effectivity_date,
	        20,
	        l_interface_rec.resource_id2,
	        l_interface_rec.resource_code2,
	        1,
		G_Insert);
	    end if; -- resource 2
            If nvl(l_interface_rec.resource_code3, G_NullChar) <> G_NullChar
	    or nvl(l_interface_rec.resource_id3, G_NullNum) <> G_NullNum then
              insert into bom_op_resources_interface (
	        OPERATION_SEQUENCE_ID,
	        ASSEMBLY_ITEM_ID,
	        ASSEMBLY_ITEM_NUMBER,
	        ORGANIZATION_ID,
	        ORGANIZATION_CODE,
	        ALTERNATE_ROUTING_DESIGNATOR,
	        OPERATION_SEQ_NUM,
	        EFFECTIVITY_DATE,
	        RESOURCE_SEQ_NUM,
	        RESOURCE_ID,
	        RESOURCE_CODE,
	        PROCESS_FLAG,
		TRANSACTION_TYPE)
	      values(
	        l_operation_rec.operation_sequence_id,
	        l_operation_rec.assembly_item_id,
	        l_operation_rec.assembly_item_number,
	        l_operation_rec.organization_id,
	        l_operation_rec.organization_code,
	        l_operation_rec.alternate_routing_designator,
	        l_operation_rec.operation_seq_num,
	        l_operation_rec.effectivity_date,
	        30,
	        l_interface_rec.resource_id3,
	        l_interface_rec.resource_code3,
	        1,
		G_Insert);
	    end if; -- resource 3
          end if; -- denormalized resources

        Elsif l_interface_rec.transaction_type = G_Update then

 	  BOM_Operation_PVT.UpdateOperation(
            p_api_version           =>      1.0,
            p_init_msg_list         =>      FND_API.G_TRUE,
            p_commit                =>      FND_API.G_FALSE,
            p_validation_level      =>      FND_API.G_VALID_LEVEL_FULL,
            x_return_status         =>      l_return_status,
            x_msg_count             =>      l_msg_count,
            x_msg_data              =>      l_msg_data,
            p_operation_rec         =>      l_operation_rec,
	    x_operation_rec         =>      l_operation_rec);

        Elsif l_interface_rec.transaction_type = G_Delete then

	  l_DelGrpFound := false;
	  For l_DelGrp_rec in l_OprDeleteGroup_csr loop
	    l_DelGrpFound := true;
	    BOM_Operation_Pvt.DeleteOperation(
              p_api_version           =>      1.0,
              p_init_msg_list         =>      FND_API.G_TRUE,
              p_commit                =>      FND_API.G_FALSE,
              p_validation_level      =>      FND_API.G_VALID_LEVEL_FULL,
              x_return_status         =>      l_return_status,
              x_msg_count             =>      l_msg_count,
              x_msg_data              =>      l_msg_data,
              p_delete_group          =>      l_DelGrp_rec.delete_group_name,
              p_description           =>      l_DelGrp_rec.description,
              p_operation_rec         =>      l_operation_rec,
              x_operation_rec         =>      l_operation_rec
	    );
	  End loop; -- delete operation
          If not l_DelGrpFound then
	    Fnd_Message.Set_Name('BOM', 'BOM_DELETE_GROUP_NULL');
            l_return_status := FND_API.G_RET_STS_ERROR;
    	    FND_MSG_PUB.Initialize;
    	    FND_MSG_PUB.Add;
    	    FND_MSG_PUB.Count_And_Get(
      	      p_count => l_msg_count,
      	      p_data  => l_msg_data
    	    );
	  End if; -- Delete group unspecified
        End if; -- insert, update and delete

        If l_return_status = Fnd_Api.G_RET_STS_SUCCESS then
	  If g_DeleteRows then
            Delete from bom_op_sequences_interface
	    Where rowid = l_interface_rec.rowid;
	  Else
	    Update bom_op_sequences_interface
	    Set process_flag = 7,
	        transaction_id = mtl_system_items_interface_s.nextval,
		request_id = nvl(request_id,g_RequestId),
		program_id = nvl(program_id,g_ProgramId),
	program_application_id = nvl(program_application_id,g_ApplicationId),
		program_update_date = nvl(program_update_date,sysdate),
		created_by = nvl(created_by,g_UserId),
		last_updated_by = nvl(last_updated_by,g_UserId),
		creation_date = nvl(creation_date,sysdate),
		last_update_date = nvl(last_update_date,sysdate),
		last_update_login = nvl(last_update_login,g_LoginId)
	    Where rowid = l_interface_rec.rowid;
          End if;
        Elsif l_return_status = Fnd_Api.G_RET_STS_ERROR then
          If l_phase = 2 then
            If l_msg_count > 1 then
    	      l_msg_data := FND_MSG_PUB.Get;
            End if;
            Fnd_Message.Parse_Encoded(
              ENCODED_MESSAGE => l_msg_data,
              APP_SHORT_NAME  => l_msg_app,
              MESSAGE_NAME    => l_msg_name);
            For l_transaction_rec in l_Transaction_csr loop
  	      l_ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => g_OrgId,
                        user_id => g_UserId,
                        login_id => g_LoginId,
                        prog_appid => g_ApplicationId,
                        prog_id => g_ProgramId,
                        req_id => g_RequestId,
                        trans_id => l_transaction_rec.transaction_id,
                        error_text => l_msg_data,
                        tbl_name => 'BOM_OP_SEQUENCES_INTERFACE',
                        msg_name => l_msg_name,
                        err_text => l_msg_data);
              If l_ret_code <> 0 then
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
              end if;
	      Update bom_op_sequences_interface
	      Set process_flag = 3,
	        transaction_id = l_transaction_rec.transaction_id
	      Where rowid = l_interface_rec.rowid;
            End loop; -- log error
          End if; -- final phase
        Elsif l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR then
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        End if; -- process return status
      End; -- nested block

      If g_Commit then
	If mod(l_interface_csr%rowcount, g_CommitRows) = 0 then
          COMMIT WORK;
        End if;
      End if; -- periodic commits
    End loop; -- scan interface table
    If g_Commit then
       COMMIT WORK;
    End if; -- commit remaining rows
    -- rescan table in case of new event parents
    l_phase :=  l_phase + 1;
  End loop; -- phase
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
END ImportOperation;

PROCEDURE ImportResource(x_return_status IN OUT NOCOPY VARCHAR2) is
cursor 	l_interface_csr is
	  Select rowid,
                 operation_sequence_id,
                 routing_sequence_id,
                 assembly_item_id,
                 assembly_item_number,
                 organization_id,
                 organization_code,
                 alternate_routing_designator,
                 operation_seq_num,
                 effectivity_date,
                 resource_seq_num,
                 new_resource_seq_num,
                 resource_id,
                 resource_code,
                 activity_id,
                 activity,
                 standard_rate_flag,
                 assigned_units,
                 usage_rate_or_amount,
                 usage_rate_or_amount_inverse,
                 basis_type,
                 schedule_flag,
                 resource_offset_percent,
                 autocharge_type,
                 attribute_category,
                 attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 transaction_type,
		 principle_flag,		-- 2514018
		 schedule_seq_num		-- 2514018
	  From bom_op_resources_interface
          Where process_flag = 1
          And (g_AllOrgs = g_yes
 	       or organization_id = g_OrgId
 	       or organization_code = g_OrgCode
              );
l_phase NUMBER := 1; -- scan table twice in case inserting and updating same
		     -- resource
l_return_status  VARCHAR2(1);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000);
l_msg_name	 VARCHAR2(80);
l_msg_app	 VARCHAR2(3);
l_ret_code 	 NUMBER := 0;
cursor  l_Transaction_csr is
          Select mtl_system_items_interface_s.nextval transaction_id
          From dual;
l_api_name  	CONSTANT VARCHAR2(30)	:= 'ImportResource';
Begin
  While l_phase <= 2 loop -- two passes
    For l_interface_rec in l_interface_csr loop
      Declare
        l_resource_rec Bom_OpResource_Pvt.resource_rec_type;
      Begin -- nested block within loop
	if (upper(l_interface_rec.transaction_type) = 'CREATE') then
         l_interface_rec.transaction_type := G_Insert ;
        else
         l_interface_rec.transaction_type := upper(l_interface_rec.transaction_type);
        end if ;

        If l_interface_rec.operation_sequence_id = G_NullNum then
          l_resource_rec.operation_sequence_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.operation_sequence_id :=
            nvl(l_interface_rec.operation_sequence_id, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.operation_sequence_id :=
	    l_interface_rec.operation_sequence_id;
        End if;

        If l_interface_rec.routing_sequence_id = G_NullNum then
          l_resource_rec.routing_sequence_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.routing_sequence_id :=
            nvl(l_interface_rec.routing_sequence_id, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.routing_sequence_id :=
	    l_interface_rec.routing_sequence_id;
        End if;

        If l_interface_rec.assembly_item_id = G_NullNum then
          l_resource_rec.assembly_item_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.assembly_item_id :=
            nvl(l_interface_rec.assembly_item_id, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.assembly_item_id := l_interface_rec.assembly_item_id;
        End if;

        If l_interface_rec.assembly_item_number = G_NullChar then
          l_resource_rec.assembly_item_number := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.assembly_item_number :=
            nvl(l_interface_rec.assembly_item_number, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.assembly_item_number :=
	    l_interface_rec.assembly_item_number;
        End if;

        If l_interface_rec.organization_id = G_NullNum then
          l_resource_rec.organization_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.organization_id :=
            nvl(l_interface_rec.organization_id, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.organization_id := l_interface_rec.organization_id;
        End if;

        If l_interface_rec.organization_code = G_NullChar then
          l_resource_rec.organization_code := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.organization_code :=
            nvl(l_interface_rec.organization_code, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.organization_code := l_interface_rec.organization_code;
        End if;

        If l_interface_rec.alternate_routing_designator = G_NullChar then
          l_resource_rec.alternate_routing_designator := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.alternate_routing_designator :=
            nvl(l_interface_rec.alternate_routing_designator,
	      Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.alternate_routing_designator :=
	    l_interface_rec.alternate_routing_designator;
        End if;

        If l_interface_rec.operation_seq_num = G_NullNum then
          l_resource_rec.operation_seq_num := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.operation_seq_num :=
            nvl(l_interface_rec.operation_seq_num, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.operation_seq_num :=
	    l_interface_rec.operation_seq_num;
        End if;

        If l_interface_rec.effectivity_date = G_NullDate then
          l_resource_rec.effectivity_date := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.effectivity_date :=
            nvl(l_interface_rec.effectivity_date, Fnd_Api.G_Miss_Date);
        Else
          l_resource_rec.effectivity_date := l_interface_rec.effectivity_date;
        End if;

        If l_interface_rec.resource_seq_num = G_NullNum then
          l_resource_rec.resource_seq_num := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.resource_seq_num :=
            nvl(l_interface_rec.resource_seq_num, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.resource_seq_num := l_interface_rec.resource_seq_num;
        End if;

        If l_interface_rec.new_resource_seq_num = G_NullNum then
          l_resource_rec.new_resource_seq_num := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.new_resource_seq_num :=
            nvl(l_interface_rec.new_resource_seq_num, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.new_resource_seq_num :=
	    l_interface_rec.new_resource_seq_num;
        End if;

        If l_interface_rec.resource_id = G_NullNum then
          l_resource_rec.resource_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.resource_id :=
            nvl(l_interface_rec.resource_id, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.resource_id := l_interface_rec.resource_id;
        End if;

        If l_interface_rec.resource_code = G_NullChar then
          l_resource_rec.resource_code := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.resource_code :=
            nvl(l_interface_rec.resource_code, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.resource_code := l_interface_rec.resource_code;
        End if;

        If l_interface_rec.activity_id = G_NullNum then
          l_resource_rec.activity_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.activity_id :=
            nvl(l_interface_rec.activity_id, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.activity_id := l_interface_rec.activity_id;
        End if;

        If l_interface_rec.activity = G_NullChar then
          l_resource_rec.activity := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.activity :=
            nvl(l_interface_rec.activity, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.activity := l_interface_rec.activity;
        End if;

        If l_interface_rec.standard_rate_flag = G_NullNum then
          l_resource_rec.standard_rate_flag := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.standard_rate_flag :=
            nvl(l_interface_rec.standard_rate_flag, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.standard_rate_flag :=
	    l_interface_rec.standard_rate_flag;
        End if;

        If l_interface_rec.assigned_units = G_NullNum then
          l_resource_rec.assigned_units := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.assigned_units :=
            nvl(l_interface_rec.assigned_units, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.assigned_units := l_interface_rec.assigned_units;
        End if;

        If l_interface_rec.usage_rate_or_amount = G_NullNum then
          l_resource_rec.usage_rate_or_amount := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.usage_rate_or_amount :=
            nvl(l_interface_rec.usage_rate_or_amount, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.usage_rate_or_amount :=
	    l_interface_rec.usage_rate_or_amount;
        End if;

        If l_interface_rec.usage_rate_or_amount_inverse = G_NullNum then
          l_resource_rec.usage_rate_or_amount_inverse := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.usage_rate_or_amount_inverse :=
            nvl(l_interface_rec.usage_rate_or_amount_inverse,
	      Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.usage_rate_or_amount_inverse :=
	    l_interface_rec.usage_rate_or_amount_inverse;
        End if;

        If l_interface_rec.basis_type = G_NullNum then
          l_resource_rec.basis_type := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.basis_type :=
            nvl(l_interface_rec.basis_type, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.basis_type := l_interface_rec.basis_type;
        End if;

        If l_interface_rec.schedule_flag = G_NullNum then
          l_resource_rec.schedule_flag := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.schedule_flag :=
            nvl(l_interface_rec.schedule_flag, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.schedule_flag := l_interface_rec.schedule_flag;
        End if;

        If l_interface_rec.resource_offset_percent = G_NullNum then
          l_resource_rec.resource_offset_percent := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.resource_offset_percent :=
            nvl(l_interface_rec.resource_offset_percent, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.resource_offset_percent :=
	    l_interface_rec.resource_offset_percent;
        End if;

        If l_interface_rec.autocharge_type = G_NullNum then
          l_resource_rec.autocharge_type := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.autocharge_type :=
            nvl(l_interface_rec.autocharge_type, Fnd_Api.G_Miss_Num);
        Else
          l_resource_rec.autocharge_type := l_interface_rec.autocharge_type;
        End if;

        If l_interface_rec.attribute_category = G_NullChar then
          l_resource_rec.attribute_category := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute_category :=
            nvl(l_interface_rec.attribute_category, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute_category :=
	    l_interface_rec.attribute_category;
        End if;

        If l_interface_rec.attribute1 = G_NullChar then
          l_resource_rec.attribute1 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute1 :=
            nvl(l_interface_rec.attribute1, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute1 := l_interface_rec.attribute1;
        End if;

        If l_interface_rec.attribute2 = G_NullChar then
          l_resource_rec.attribute2 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute2 :=
            nvl(l_interface_rec.attribute2, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute2 := l_interface_rec.attribute2;
        End if;

        If l_interface_rec.attribute3 = G_NullChar then
          l_resource_rec.attribute3 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute3 :=
            nvl(l_interface_rec.attribute3, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute3 := l_interface_rec.attribute3;
        End if;

        If l_interface_rec.attribute4 = G_NullChar then
          l_resource_rec.attribute4 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute4 :=
            nvl(l_interface_rec.attribute4, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute4 := l_interface_rec.attribute4;
        End if;

        If l_interface_rec.attribute5 = G_NullChar then
          l_resource_rec.attribute5 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute5 :=
            nvl(l_interface_rec.attribute5, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute5 := l_interface_rec.attribute5;
        End if;

        If l_interface_rec.attribute6 = G_NullChar then
          l_resource_rec.attribute6 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute6 :=
            nvl(l_interface_rec.attribute6, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute6 := l_interface_rec.attribute6;
        End if;

        If l_interface_rec.attribute7 = G_NullChar then
          l_resource_rec.attribute7 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute7 :=
            nvl(l_interface_rec.attribute7, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute7 := l_interface_rec.attribute7;
        End if;

        If l_interface_rec.attribute8 = G_NullChar then
          l_resource_rec.attribute8 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute8 :=
            nvl(l_interface_rec.attribute8, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute8 := l_interface_rec.attribute8;
        End if;

        If l_interface_rec.attribute9 = G_NullChar then
          l_resource_rec.attribute9 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute9 :=
            nvl(l_interface_rec.attribute9, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute9 := l_interface_rec.attribute9;
        End if;

        If l_interface_rec.attribute10 = G_NullChar then
          l_resource_rec.attribute10 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute10 :=
            nvl(l_interface_rec.attribute10, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute10 := l_interface_rec.attribute10;
        End if;

        If l_interface_rec.attribute11 = G_NullChar then
          l_resource_rec.attribute11 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute11 :=
            nvl(l_interface_rec.attribute11, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute11 := l_interface_rec.attribute11;
        End if;

        If l_interface_rec.attribute12 = G_NullChar then
          l_resource_rec.attribute12 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute12 :=
            nvl(l_interface_rec.attribute12, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute12 := l_interface_rec.attribute12;
        End if;

        If l_interface_rec.attribute13 = G_NullChar then
          l_resource_rec.attribute13 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute13 :=
            nvl(l_interface_rec.attribute13, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute13 := l_interface_rec.attribute13;
        End if;

        If l_interface_rec.attribute14 = G_NullChar then
          l_resource_rec.attribute14 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute14 :=
            nvl(l_interface_rec.attribute14, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute14 := l_interface_rec.attribute14;
        End if;

        If l_interface_rec.attribute15 = G_NullChar then
          l_resource_rec.attribute15 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_resource_rec.attribute15 :=
            nvl(l_interface_rec.attribute15, Fnd_Api.G_Miss_Char);
        Else
          l_resource_rec.attribute15 := l_interface_rec.attribute15;
        End if;

--Bug 2514018
	If l_interface_rec.principle_flag = G_NullNum then
	   l_resource_rec.principle_flag := null;
	Elsif l_interface_rec.transaction_type = G_Update then
	   l_resource_rec.principle_flag :=
	     nvl(l_interface_rec.principle_flag,Fnd_Api.G_Miss_Num);
	Else
	   l_resource_rec.principle_flag := l_interface_rec.principle_flag;
        End if;
--Bug 2514018

--Bug 2514018
	If l_interface_rec.schedule_seq_num = G_NullNum then
	   l_resource_rec.schedule_seq_num := null;
	Elsif l_interface_rec.transaction_type = G_Update then
	   l_resource_rec.schedule_seq_num :=
	     nvl(l_interface_rec.schedule_seq_num,Fnd_Api.G_Miss_Num);
	Else
	   l_resource_rec.schedule_seq_num := l_interface_rec.schedule_seq_num;
        End if;
--Bug 2514018

        If l_interface_rec.transaction_type = G_Insert then

	  Bom_OpResource_Pvt.CreateResource(
	    p_api_version           =>      1.0,
            p_init_msg_list         =>      FND_API.G_TRUE,
            p_commit                =>      FND_API.G_FALSE,
            p_validation_level      =>      FND_API.G_VALID_LEVEL_FULL,
            x_return_status         =>      l_return_status,
            x_msg_count             =>      l_msg_count,
            x_msg_data              =>      l_msg_data,
            p_resource_rec          =>      l_resource_rec,
            x_resource_rec          =>      l_resource_rec
          );

        Elsif l_interface_rec.transaction_type = G_Update then

 	  Bom_OpResource_Pvt.UpdateResource(
            p_api_version           =>      1.0,
            p_init_msg_list         =>      FND_API.G_TRUE,
            p_commit                =>      FND_API.G_FALSE,
            p_validation_level      =>      FND_API.G_VALID_LEVEL_FULL,
            x_return_status         =>      l_return_status,
            x_msg_count             =>      l_msg_count,
            x_msg_data              =>      l_msg_data,
            p_resource_rec          =>      l_resource_rec,
	    x_resource_rec          =>      l_resource_rec
	  );

        Elsif l_interface_rec.transaction_type = G_Delete then

 	  Bom_OpResource_Pvt.DeleteResource(
            p_api_version           =>      1.0,
            p_init_msg_list         =>      FND_API.G_TRUE,
            p_commit                =>      FND_API.G_FALSE,
            p_validation_level      =>      FND_API.G_VALID_LEVEL_FULL,
            x_return_status         =>      l_return_status,
            x_msg_count             =>      l_msg_count,
            x_msg_data              =>      l_msg_data,
            p_resource_rec          =>      l_resource_rec,
	    x_resource_rec          =>      l_resource_rec
	  );
        End if; -- insert, update and delete

        If l_return_status = Fnd_Api.G_RET_STS_SUCCESS then
	  If g_DeleteRows then
            Delete from bom_op_resources_interface
	    Where rowid = l_interface_rec.rowid;
	  Else
	    Update bom_op_resources_interface
	    Set process_flag = 7,
	        transaction_id = mtl_system_items_interface_s.nextval,
		request_id = nvl(request_id,g_RequestId),
		program_id = nvl(program_id,g_ProgramId),
	program_application_id = nvl(program_application_id,g_ApplicationId),
		program_update_date = nvl(program_update_date,sysdate),
		created_by = nvl(created_by,g_UserId),
		last_updated_by = nvl(last_updated_by,g_UserId),
		creation_date = nvl(creation_date,sysdate),
		last_update_date = nvl(last_update_date,sysdate),
		last_update_login = nvl(last_update_login,g_LoginId)
	    Where rowid = l_interface_rec.rowid;
          End if;
        Elsif l_return_status = Fnd_Api.G_RET_STS_ERROR then
          If l_phase = 2 then
            If l_msg_count > 1 then
    	      l_msg_data := FND_MSG_PUB.Get;
            End if;
            Fnd_Message.Parse_Encoded(
              ENCODED_MESSAGE => l_msg_data,
              APP_SHORT_NAME  => l_msg_app,
              MESSAGE_NAME    => l_msg_name);
            For l_transaction_rec in l_Transaction_csr loop
  	      l_ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => g_OrgId,
                        user_id => g_UserId,
                        login_id => g_LoginId,
                        prog_appid => g_ApplicationId,
                        prog_id => g_ProgramId,
                        req_id => g_RequestId,
                        trans_id => l_transaction_rec.transaction_id,
                        error_text => l_msg_data,
                        tbl_name => 'BOM_OP_RESOURCES_INTERFACE',
                        msg_name => l_msg_name,
                        err_text => l_msg_data);
              If l_ret_code <> 0 then
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
              end if;
	      Update bom_op_resources_interface
	      Set process_flag = 3,
	        transaction_id = l_transaction_rec.transaction_id
	      Where rowid = l_interface_rec.rowid;
            End loop; -- log error
          End if; -- final phase
        Elsif l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR then
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        End if; -- process return status
      End; -- nested block

      If g_Commit then
	If mod(l_interface_csr%rowcount, g_CommitRows) = 0 then
          COMMIT WORK;
        End if;
      End if; -- periodic commits
    End loop; -- scan interface table
    If g_Commit then
       COMMIT WORK;
    End if; -- commit remaining rows
    -- rescan table in case updating new operation resources
    l_phase :=  l_phase + 1;
  End loop; -- phase
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
END ImportResource;

PROCEDURE ImportRevision(x_return_status IN OUT NOCOPY VARCHAR2) is
cursor 	l_interface_csr is
	  Select rowid,
                 inventory_item_id,
                 inventory_item_number,
                 organization_id,
                 organization_code,
                 process_revision,
                 change_notice,
                 ecn_initiation_date,
                 implementation_date,
                 implemented_serial_number,
                 effectivity_date,
                 attribute_category,
                 attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 transaction_type
	  From mtl_rtg_item_revs_interface
          Where process_flag = 1
          And (g_AllOrgs = g_yes
 	       or organization_id = g_OrgId
 	       or organization_code = g_OrgCode
              );
l_phase NUMBER := 1; -- scan table twice in case inserting and updating same
		     -- revision
l_return_status  VARCHAR2(1);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000);
l_msg_name	 VARCHAR2(80);
l_msg_app	 VARCHAR2(3);
l_ret_code 	 NUMBER := 0;
cursor  l_Transaction_csr is
          Select mtl_system_items_interface_s.nextval transaction_id
          From dual;
l_api_name  	CONSTANT VARCHAR2(30)	:= 'ImportRevision';
Begin
  While l_phase <= 2 loop -- two passes
    For l_interface_rec in l_interface_csr loop
      Declare
        l_revision_rec Bom_RoutingRevision_Pvt.rtg_revision_rec_type;
      Begin -- nested block within loop
	if (upper(l_interface_rec.transaction_type) = 'CREATE') then
         l_interface_rec.transaction_type := G_Insert ;
        else
         l_interface_rec.transaction_type := upper(l_interface_rec.transaction_type);
        end if ;

        If l_interface_rec.inventory_item_id = G_NullNum then
          l_revision_rec.inventory_item_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.inventory_item_id :=
            nvl(l_interface_rec.inventory_item_id, Fnd_Api.G_Miss_Num);
        Else
          l_revision_rec.inventory_item_id := l_interface_rec.inventory_item_id;
        End if;

        If l_interface_rec.inventory_item_number = G_NullChar then
          l_revision_rec.inventory_item_number := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.inventory_item_number :=
            nvl(l_interface_rec.inventory_item_number, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.inventory_item_number :=
	    l_interface_rec.inventory_item_number;
        End if;

        If l_interface_rec.organization_id = G_NullNum then
          l_revision_rec.organization_id := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.organization_id :=
            nvl(l_interface_rec.organization_id, Fnd_Api.G_Miss_Num);
        Else
          l_revision_rec.organization_id := l_interface_rec.organization_id;
        End if;

        If l_interface_rec.organization_code = G_NullChar then
          l_revision_rec.organization_code := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.organization_code :=
            nvl(l_interface_rec.organization_code, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.organization_code := l_interface_rec.organization_code;
        End if;

        If l_interface_rec.process_revision = G_NullChar then
          l_revision_rec.process_revision := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.process_revision :=
            nvl(l_interface_rec.process_revision, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.process_revision := l_interface_rec.process_revision;
        End if;

        If l_interface_rec.change_notice = G_NullChar then
          l_revision_rec.change_notice := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.change_notice :=
            nvl(l_interface_rec.change_notice, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.change_notice := l_interface_rec.change_notice;
        End if;

        If l_interface_rec.ecn_initiation_date = G_NullDate then
          l_revision_rec.ecn_initiation_date := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.ecn_initiation_date :=
            nvl(l_interface_rec.ecn_initiation_date, Fnd_Api.G_Miss_Date);
        Else
          l_revision_rec.ecn_initiation_date :=
	    l_interface_rec.ecn_initiation_date;
        End if;

        If l_interface_rec.implementation_date = G_NullDate then
          l_revision_rec.implementation_date := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.implementation_date :=
            nvl(l_interface_rec.implementation_date, Fnd_Api.G_Miss_Date);
        Else
          l_revision_rec.implementation_date :=
	    l_interface_rec.implementation_date;
        End if;

        If l_interface_rec.implemented_serial_number = G_NullChar then
          l_revision_rec.implemented_serial_number := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.implemented_serial_number :=
            nvl(l_interface_rec.implemented_serial_number, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.implemented_serial_number :=
	    l_interface_rec.implemented_serial_number;
        End if;

        If l_interface_rec.effectivity_date = G_NullDate then
          l_revision_rec.effectivity_date := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.effectivity_date :=
            nvl(l_interface_rec.effectivity_date, Fnd_Api.G_Miss_Date);
        Else
          l_revision_rec.effectivity_date := l_interface_rec.effectivity_date;
        End if;

        If l_interface_rec.attribute_category = G_NullChar then
          l_revision_rec.attribute_category := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute_category :=
            nvl(l_interface_rec.attribute_category, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute_category :=
	    l_interface_rec.attribute_category;
        End if;

        If l_interface_rec.attribute1 = G_NullChar then
          l_revision_rec.attribute1 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute1 :=
            nvl(l_interface_rec.attribute1, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute1 := l_interface_rec.attribute1;
        End if;

        If l_interface_rec.attribute2 = G_NullChar then
          l_revision_rec.attribute2 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute2 :=
            nvl(l_interface_rec.attribute2, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute2 := l_interface_rec.attribute2;
        End if;

        If l_interface_rec.attribute3 = G_NullChar then
          l_revision_rec.attribute3 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute3 :=
            nvl(l_interface_rec.attribute3, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute3 := l_interface_rec.attribute3;
        End if;

        If l_interface_rec.attribute4 = G_NullChar then
          l_revision_rec.attribute4 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute4 :=
            nvl(l_interface_rec.attribute4, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute4 := l_interface_rec.attribute4;
        End if;

        If l_interface_rec.attribute5 = G_NullChar then
          l_revision_rec.attribute5 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute5 :=
            nvl(l_interface_rec.attribute5, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute5 := l_interface_rec.attribute5;
        End if;

        If l_interface_rec.attribute6 = G_NullChar then
          l_revision_rec.attribute6 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute6 :=
            nvl(l_interface_rec.attribute6, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute6 := l_interface_rec.attribute6;
        End if;

        If l_interface_rec.attribute7 = G_NullChar then
          l_revision_rec.attribute7 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute7 :=
            nvl(l_interface_rec.attribute7, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute7 := l_interface_rec.attribute7;
        End if;

        If l_interface_rec.attribute8 = G_NullChar then
          l_revision_rec.attribute8 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute8 :=
            nvl(l_interface_rec.attribute8, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute8 := l_interface_rec.attribute8;
        End if;

        If l_interface_rec.attribute9 = G_NullChar then
          l_revision_rec.attribute9 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute9 :=
            nvl(l_interface_rec.attribute9, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute9 := l_interface_rec.attribute9;
        End if;

        If l_interface_rec.attribute10 = G_NullChar then
          l_revision_rec.attribute10 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute10 :=
            nvl(l_interface_rec.attribute10, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute10 := l_interface_rec.attribute10;
        End if;

        If l_interface_rec.attribute11 = G_NullChar then
          l_revision_rec.attribute11 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute11 :=
            nvl(l_interface_rec.attribute11, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute11 := l_interface_rec.attribute11;
        End if;

        If l_interface_rec.attribute12 = G_NullChar then
          l_revision_rec.attribute12 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute12 :=
            nvl(l_interface_rec.attribute12, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute12 := l_interface_rec.attribute12;
        End if;

        If l_interface_rec.attribute13 = G_NullChar then
          l_revision_rec.attribute13 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute13 :=
            nvl(l_interface_rec.attribute13, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute13 := l_interface_rec.attribute13;
        End if;

        If l_interface_rec.attribute14 = G_NullChar then
          l_revision_rec.attribute14 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute14 :=
            nvl(l_interface_rec.attribute14, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute14 := l_interface_rec.attribute14;
        End if;

        If l_interface_rec.attribute15 = G_NullChar then
          l_revision_rec.attribute15 := null;
        Elsif l_interface_rec.transaction_type = G_Update then
          l_revision_rec.attribute15 :=
            nvl(l_interface_rec.attribute15, Fnd_Api.G_Miss_Char);
        Else
          l_revision_rec.attribute15 := l_interface_rec.attribute15;
        End if;

        If l_interface_rec.transaction_type = G_Insert then

	  Bom_RoutingRevision_Pvt.CreateRtgRevision(
	    p_api_version           =>      1.0,
            p_init_msg_list         =>      FND_API.G_TRUE,
            p_commit                =>      FND_API.G_FALSE,
            p_validation_level      =>      FND_API.G_VALID_LEVEL_FULL,
            x_return_status         =>      l_return_status,
            x_msg_count             =>      l_msg_count,
            x_msg_data              =>      l_msg_data,
            p_RtgRevision_rec       =>      l_revision_rec,
            x_RtgRevision_rec       =>      l_revision_rec
          );

        Elsif l_interface_rec.transaction_type = G_Update then

 	  Bom_RoutingRevision_Pvt.UpdateRtgRevision(
            p_api_version           =>      1.0,
            p_init_msg_list         =>      FND_API.G_TRUE,
            p_commit                =>      FND_API.G_FALSE,
            p_validation_level      =>      FND_API.G_VALID_LEVEL_FULL,
            x_return_status         =>      l_return_status,
            x_msg_count             =>      l_msg_count,
            x_msg_data              =>      l_msg_data,
            p_RtgRevision_rec       =>      l_revision_rec,
	    x_RtgRevision_rec       =>      l_revision_rec
	  );

        Elsif l_interface_rec.transaction_type = G_Delete then

 	  Bom_RoutingRevision_Pvt.DeleteRtgRevision(
            p_api_version           =>      1.0,
            p_init_msg_list         =>      FND_API.G_TRUE,
            p_commit                =>      FND_API.G_FALSE,
            p_validation_level      =>      FND_API.G_VALID_LEVEL_FULL,
            x_return_status         =>      l_return_status,
            x_msg_count             =>      l_msg_count,
            x_msg_data              =>      l_msg_data,
            p_RtgRevision_rec       =>      l_revision_rec,
	    x_RtgRevision_rec       =>      l_revision_rec
	  );
        End if; -- insert, update and delete

        If l_return_status = Fnd_Api.G_RET_STS_SUCCESS then
	  If g_DeleteRows then
            Delete from mtl_rtg_item_revs_interface
	    Where rowid = l_interface_rec.rowid;
	  Else
	    Update mtl_rtg_item_revs_interface
	    Set process_flag = 7,
	        transaction_id = mtl_system_items_interface_s.nextval,
		request_id = nvl(request_id,g_RequestId),
		program_id = nvl(program_id,g_ProgramId),
	program_application_id = nvl(program_application_id,g_ApplicationId),
		program_update_date = nvl(program_update_date,sysdate),
		created_by = nvl(created_by,g_UserId),
		last_updated_by = nvl(last_updated_by,g_UserId),
		creation_date = nvl(creation_date,sysdate),
		last_update_date = nvl(last_update_date,sysdate),
		last_update_login = nvl(last_update_login,g_LoginId)
	    Where rowid = l_interface_rec.rowid;
          End if;
        Elsif l_return_status = Fnd_Api.G_RET_STS_ERROR then
          If l_phase = 2 then
            If l_msg_count > 1 then
    	      l_msg_data := FND_MSG_PUB.Get;
            End if;
            Fnd_Message.Parse_Encoded(
              ENCODED_MESSAGE => l_msg_data,
              APP_SHORT_NAME  => l_msg_app,
              MESSAGE_NAME    => l_msg_name);
            For l_transaction_rec in l_Transaction_csr loop
  	      l_ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => g_OrgId,
                        user_id => g_UserId,
                        login_id => g_LoginId,
                        prog_appid => g_ApplicationId,
                        prog_id => g_ProgramId,
                        req_id => g_RequestId,
                        trans_id => l_transaction_rec.transaction_id,
                        error_text => l_msg_data,
                        tbl_name => 'MTL_RTG_ITEM_REVS_INTERFACE',
                        msg_name => l_msg_name,
                        err_text => l_msg_data);
              If l_ret_code <> 0 then
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
              end if;
	      Update mtl_rtg_item_revs_interface
	      Set process_flag = 3,
	        transaction_id = l_transaction_rec.transaction_id
	      Where rowid = l_interface_rec.rowid;
            End loop; -- log error
          End if; -- final phase
        Elsif l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR then
          Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        End if; -- process return status
      End; -- nested block

      If g_Commit then
	If mod(l_interface_csr%rowcount, g_CommitRows) = 0 then
          COMMIT WORK;
        End if;
      End if; -- periodic commits
    End loop; -- scan interface table
    If g_Commit then
       COMMIT WORK;
    End if; -- commit remaining rows
    -- rescan table in case updating new revisions
    l_phase :=  l_phase + 1;
  End loop; -- phase
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
END ImportRevision;

PROCEDURE ImportRouting(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER          := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       IN OUT NOCOPY     VARCHAR2,
  x_msg_count           IN OUT NOCOPY     NUMBER,
  x_msg_data            IN OUT NOCOPY     VARCHAR2,
  p_organization_id     IN      NUMBER,
  p_all_organizations   IN      VARCHAR2        := FND_API.G_TRUE,
  p_commit_rows         IN      NUMBER          := 500,
  p_delete_rows         IN      VARCHAR2        := FND_API.G_FALSE
)IS
l_api_name		CONSTANT VARCHAR2(30)	:= 'ImportRouting';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_return_status         VARCHAR2(1);
cursor 			l_parameter_cursor is
  			  Select organization_code
  			  From mtl_parameters
  			  Where organization_id = p_organization_id;
BEGIN
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
  G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  g_CommitRows := p_commit_rows;
  g_Commit := Fnd_Api.to_boolean(p_commit);
  g_DeleteRows := Fnd_Api.to_boolean(p_delete_rows);
  g_OrgId := p_organization_id;
  For l_parameter_rec in l_parameter_cursor loop
    g_OrgCode := l_parameter_rec.organization_code;
  End loop;
  If p_all_organizations = FND_API.G_FALSE then
    g_AllOrgs := g_no;
  Else
    g_AllOrgs := g_yes;
  End if;

  -- who columns
  g_UserId := nvl(Fnd_Global.USER_ID, -1);
  g_LoginId := Fnd_Global.LOGIN_ID;
  g_RequestId := Fnd_Global.CONC_REQUEST_ID;
  g_ProgramId := Fnd_Global.CONC_PROGRAM_ID;
  g_ApplicationId := Fnd_Global.PROG_APPL_ID;

  ImportHeader(x_return_status => l_return_status);
  If l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  End if;
  ImportOperation(x_return_status => l_return_status);
  If l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  End if;
  ImportResource(x_return_status => l_return_status);
  If l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  End if;
  ImportRevision(x_return_status => l_return_status);
  If l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  End if;

  -- End of API body.
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count => x_msg_count,
    p_data => x_msg_data
  );
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
END ImportRouting;
END BOM_RoutingInterface_PUB;

/
