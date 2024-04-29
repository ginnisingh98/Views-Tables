--------------------------------------------------------
--  DDL for Package Body AHL_PRD_PARTS_CHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_PARTS_CHANGE_PVT" AS
/* $Header: AHLVPPCB.pls 120.12 2008/07/01 01:33:59 sikumar ship $ */


 G_DEBUG varchar2(1) := AHL_DEBUG_PUB.is_log_enabled;
 G_PKG_NAME  CONSTANT VARCHAR2(30) := 'AHL_PRD_PARTS_CHANGE_PVT';
 G_CSI_LOCATION_TYPE_CODE CONSTANT VARCHAR2(30) := 'CSI_INST_LOCATION_SOURCE_CODE';

-----------------------------------
--   Declare Local Procedures    --
-----------------------------------
-- Default and validate the parameters

PROCEDURE validate_part_record (
  p_x_parts_rec    In Out Nocopy  Ahl_Parts_Rec_type,
  p_module_type    In             Varchar2,
  X_Return_Status  Out Nocopy     Varchar2);

-- Convert value to ids
PROCEDURE convert_value_to_id(
  p_x_parts_rec    In Out Nocopy Ahl_Parts_Rec_type,
  X_Return_Status  Out Nocopy    Varchar2);

PROCEDURE create_csi_transaction_rec(
  p_x_csi_transaction_rec In Out Nocopy CSI_DATASTRUCTURES_PUB.transaction_rec,
  x_return_status         Out Nocopy    Varchar2);

--For UC processing
PROCEDURE Process_UC(
  p_x_parts_rec   In Out Nocopy Ahl_Parts_Rec_type,
  p_module_type   In            varchar2,
  p_x_csi_transaction_rec In Out Nocopy CSI_DATASTRUCTURES_PUB.transaction_rec,
  x_return_status Out Nocopy    Varchar2,
  x_path_position_id Out NOCOPY Number,
  x_warning_msg_tbl OUT NOCOPY ahl_uc_validation_pub.error_tbl_type);

 --For IB processing
PROCEDURE Process_IB(
  p_x_csi_transaction_rec In Out Nocopy CSI_DATASTRUCTURES_PUB.transaction_rec,
  p_x_parts_rec           In Out Nocopy Ahl_Parts_Rec_type,
  x_return_status         Out Nocopy  Varchar2);

--For status update of a removed item after UC or IB processing
PROCEDURE update_item_location(
  p_x_parts_rec           In Out Nocopy ahl_parts_rec_type,
  p_x_csi_transaction_rec In Out Nocopy CSI_DATASTRUCTURES_PUB.transaction_rec,
  x_return_status         Out Nocopy   Varchar2);

--For Material transaction api
PROCEDURE process_material_txn(
  p_x_parts_rec   In Out Nocopy ahl_parts_rec_type,
  p_module_type   In            varchar2,
  x_return_status Out Nocopy    varchar2
                    );

-- Service request processing
/*
PROCEDURE process_SR(
  p_x_parts_rec_tbl In Out Nocopy Ahl_parts_tbl_type,
  p_module_type     In            Varchar2,
  x_return_status   Out Nocopy    Varchar2
                   );

*/

-- Get Material Issue transaction, is exists, when installing an item.
PROCEDURE Get_Issue_Mtl_Txn (p_workorder_id IN NUMBER,
                             p_Item_Instance_Id  IN  NUMBER,
                             x_issue_mtl_txn_id  OUT NOCOPY NUMBER);


/*
-- Update Material Return txn if item returned using Material Transactions.
PROCEDURE Update_Material_Return (p_return_mtl_txn_id  IN NUMBER,
                                  p_workorder_id       IN NUMBER,
                                  p_Item_Instance_Id   IN  NUMBER,
                                  x_return_status  OUT NOCOPY VARCHAR2);

*/
/*Validate and get the instance to be moved with ids*/
PROCEDURE get_dest_instance_rec(
   p_module_type            In  Varchar2  Default NULL,
   p_move_item_instance_rec IN move_item_instance_rec_type,
   x_instance_rec Out NOCOPY csi_datastructures_pub.instance_rec,
   x_serialized Out NOCOPY Varchar2,
   x_Return_Status          Out NOCOPY Varchar2
);
/*Change the location of item instance from one wip job to another */
PROCEDURE update_csi_item_instance(
   p_instance_rec          IN       csi_datastructures_pub.instance_rec,
   p_x_csi_transaction_rec In Out Nocopy CSI_DATASTRUCTURES_PUB.transaction_rec,
   X_Return_Status         Out NOCOPY Varchar2
);
/*Change the location of item instance(non serialized) from one wip job to another
  Does splitting if needed */
PROCEDURE move_nonser_instance(
   p_source_instance_id IN NUMBER,
   p_move_quantity      IN NUMBER,
   p_dest_wip_job_id    IN NUMBER,
   p_x_csi_transaction_rec In Out Nocopy CSI_DATASTRUCTURES_PUB.transaction_rec,
   X_Return_Status          Out NOCOPY Varchar2
);
/*Create a new instance if needed if a non-serialized item is split
  and if it does not exist at destination wip job*/
PROCEDURE create_similar_instance(
   p_source_instance_id IN NUMBER,
   p_dest_quantity      IN NUMBER,
   p_dest_wip_job_id    IN NUMBER,
   p_x_csi_transaction_rec In Out Nocopy CSI_DATASTRUCTURES_PUB.transaction_rec,
   x_dest_instance_id   OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2
);
--------------------------------------
-- End Local Procedures Declaration --
--------------------------------------


Procedure process_part (
  P_API_Version        In            Number:= 1.0,
  P_Init_Msg_List      In            Varchar2:= Fnd_API.G_False,
  P_Commit             In            Varchar2:= Fnd_API.G_False,
  P_Validation_Level   In            Number:= Fnd_API.G_Valid_Level_Full,
  p_module_type        In            VarChar2 := NULL,
  p_default            In            Varchar2 := FND_API.G_TRUE,
  p_x_parts_rec_tbl    In Out NOCOPY Ahl_Parts_tbl_type,
  X_Error_Code         Out NOCOPY    Varchar2,
  X_Return_Status      Out NOCOPY    Varchar2,
  X_Msg_Count          Out NOCOPY    Number,
  X_Msg_Data           Out NOCOPY    Varchar2,
  x_warning_msg_tbl OUT NOCOPY ahl_uc_validation_pub.error_tbl_type )
IS
--
  l_api_name          CONSTANT 	VARCHAR2(30) := 'Process_Part_Change';
  l_api_version       CONSTANT 	NUMBER   	 := 1.0;
  l_msg_count number;
  l_row_id number;
  l_ahl_mtltxn_id number;
  l_csi_transaction_rec  CSI_DATASTRUCTURES_PUB.transaction_rec;
  l_path_position_id     NUMBER;

  -- Added for Post 11.5.10 Enh.
  l_Issue_Mtl_Txn_id     NUMBER;
  l_part_change_type     VARCHAR2(1);
  l_part_change_qty NUMBER;



--
Begin

  -- Standard start of API savepoint
  Savepoint perform_part_changes_pvt;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.Initialize;
  END IF;

 -- Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Enable Debug.
 IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.enable_debug;
 END IF;

 -- Add debug mesg.
 IF G_DEBUG = 'Y' THEN
    AHL_DEBUG_PUB.debug('Begin private API:' ||  G_PKG_NAME || '.' || l_api_name);
 END IF;

 --Loop through the table record
 IF ( p_x_parts_rec_tbl.COUNT > 0) THEN
    FOR i IN p_x_parts_rec_tbl.FIRST..p_x_parts_rec_tbl.LAST LOOP
      IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('Input parameter dump for record:'|| i);
          AHL_DEBUG_PUB.debug('Input Workorder_Id:' || p_x_parts_rec_tbl(i).Workorder_Id);
          AHL_DEBUG_PUB.debug('Input Operation_Sequence_Num:'|| p_x_parts_rec_tbl(i).Operation_Sequence_Num );
          AHL_DEBUG_PUB.debug('Input workorder_operation_id:'|| p_x_parts_rec_tbl(i).workorder_operation_id);
          AHL_DEBUG_PUB.debug('Input Unit_Config_Header_Id:'|| p_x_parts_rec_tbl(i).Unit_Config_Header_Id);
          AHL_DEBUG_PUB.debug('Input Unit_Config_Name:'|| p_x_parts_rec_tbl(i).Unit_Config_Name);
          AHL_DEBUG_PUB.debug('Input Unit_config_obj_ver_num:' || p_x_parts_rec_tbl(i).Unit_config_obj_ver_num);
          AHL_DEBUG_PUB.debug('Input Mc_Relationship_Id:' || p_x_parts_rec_tbl(i).Mc_Relationship_Id);
          AHL_DEBUG_PUB.debug('Input Installed_Instance_Id:' || p_x_parts_rec_tbl(i).Installed_Instance_Id);
          AHL_DEBUG_PUB.debug('Input Installed_Instance_Num:' || p_x_parts_rec_tbl(i).Installed_Instance_Num);
          AHL_DEBUG_PUB.debug('Input Installation_date:' || p_x_parts_rec_tbl(i).Installation_date);
          AHL_DEBUG_PUB.debug('Input Parent_Installed_Instance_Id:' || p_x_parts_rec_tbl(i).Parent_Installed_Instance_Id);
          AHL_DEBUG_PUB.debug('Input Parent_Installed_Instance_Num:' || p_x_parts_rec_tbl(i).Parent_Installed_Instance_Num);
          AHL_DEBUG_PUB.debug('Input Removed_Instance_Id:' || p_x_parts_rec_tbl(i).Removed_Instance_Id);
          AHL_DEBUG_PUB.debug('Input Removed_Instance_Num:' || p_x_parts_rec_tbl(i).Removed_Instance_Num);
          AHL_DEBUG_PUB.debug('Input Removal_Code:' || p_x_parts_rec_tbl(i).Removal_Code);
          AHL_DEBUG_PUB.debug('Input Removal_Meaning:'|| p_x_parts_rec_tbl(i).Removal_Meaning);
          AHL_DEBUG_PUB.debug('Input Removal_Reason_Id:'|| p_x_parts_rec_tbl(i).Removal_Reason_Id);
          AHL_DEBUG_PUB.debug('Input Removal_Reason_Name:' || p_x_parts_rec_tbl(i).Removal_Reason_Name);
          AHL_DEBUG_PUB.debug('Input Removal_Date:' || p_x_parts_rec_tbl(i).Removal_Date);
          --AHL_DEBUG_PUB.debug('Input Condition_Id:' || p_x_parts_rec_tbl(i).Condition_Id);
          --AHL_DEBUG_PUB.debug('Input Locator_id:'|| p_x_parts_rec_tbl(i).Locator_id);
          --AHL_DEBUG_PUB.debug('Input Locator_code:'|| p_x_parts_rec_tbl(i).Locator_code);
          --AHL_DEBUG_PUB.debug('Input Subinventory_code:'|| p_x_parts_rec_tbl(i).Subinventory_code);
          --AHL_DEBUG_PUB.debug('Input Severity_id:' || p_x_parts_rec_tbl(i).Severity_id);
          AHL_DEBUG_PUB.debug('Input Csi_II_Relationship_Id:' || p_x_parts_rec_tbl(i).Csi_II_Relationship_Id);
          AHL_DEBUG_PUB.debug('Input CSI_II_OBJECT_VERSION_NUM:' || p_x_parts_rec_tbl(i).CSI_II_OBJECT_VERSION_NUM);
          --AHL_DEBUG_PUB.debug('Input Target_Visit_Num:'|| p_x_parts_rec_tbl(i).Target_Visit_Num);
          --AHL_DEBUG_PUB.debug('Input Target_Visit_Id:' || p_x_parts_rec_tbl(i).Target_Visit_Id);
          --AHL_DEBUG_PUB.debug('Input Problem_Code:' || p_x_parts_rec_tbl(i).Problem_Code);
          --AHL_DEBUG_PUB.debug('Input Problem_Meaning:'|| p_x_parts_rec_tbl(i).Problem_Meaning);
          AHL_DEBUG_PUB.debug('Input Operation_Type:' || p_x_parts_rec_tbl(i).Operation_Type);
          --AHL_DEBUG_PUB.debug('Input Summary:'|| p_x_parts_rec_tbl(i).Summary);
          --AHL_DEBUG_PUB.debug('Input estimated_duration:'|| p_x_parts_rec_tbl(i).estimated_duration);
          AHL_DEBUG_PUB.debug('Input Installed_Instance_Obj_Ver_Num:'|| p_x_parts_rec_tbl(i).Installed_Instance_Obj_Ver_Num);
          AHL_DEBUG_PUB.debug('Input Removed_INSTANCE_OBJ_VER_NUM:'|| p_x_parts_rec_tbl(i).Removed_INSTANCE_OBJ_VER_NUM);

      END IF;

      -- Set ids to null if the caller is jsp else go the id way
      IF (p_module_type ='JSP' ) THEN
         --p_x_parts_rec_tbl(i).removed_instance_id := null;
         p_x_parts_rec_tbl(i).installed_instance_id := null;
         --p_x_parts_rec_tbl(i).locator_id := null;
         --p_x_parts_rec_tbl(i).condition_id := null;
         p_x_parts_rec_tbl(i).removal_reason_id := null;
         p_x_parts_rec_tbl(i).removal_code := null;
         --p_x_parts_rec_tbl(i).problem_code:= null;

      END IF;

      -- convert value to ids first
      IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('Calling convert_value_to_id');
      END IF;
      Convert_value_to_id(p_x_parts_rec =>    p_x_parts_rec_tbl(i),
                          X_Return_Status => x_return_status);

      -- Check Error Message stack.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

      -- dbms_output.put_line('After convert_value_to_id');
      IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('After convert_value_to_id');
        -- Perform Validation Checks
        AHL_DEBUG_PUB.debug('Calling perform validations ');
      END IF;

      Validate_part_record(
                         p_x_parts_rec => p_x_parts_rec_tbl(i),
                         p_module_type => p_module_type,
                         X_Return_Status => X_Return_Status);

      -- Check Error Message stack.
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count > 0 THEN
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

      ------**************Get csi_transaction_rec.
      Create_csi_transaction_rec(l_csi_transaction_rec,x_return_status);
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Check if config_header_id was provided. If not check if unit_config_name exists.
      -- If yes then perform UC processing else do IB processing

      -- *********************** UC Processing ********************************
      IF (p_x_parts_rec_tbl(i).Unit_Config_Header_Id is not null) then
          -- dbms_output.put_line('Callung UC config');
          IF G_DEBUG = 'Y' THEN
             AHL_DEBUG_PUB.debug('Callung UC config');
          END IF;

          Process_UC(
                   p_x_parts_rec => p_x_parts_rec_tbl(i),
                   p_module_type => p_module_type,
                   p_x_csi_transaction_rec => l_csi_transaction_rec,
                   x_return_status => x_return_status,
                   x_path_position_id => l_path_position_id,
		   x_warning_msg_tbl => x_warning_msg_tbl);
          IF G_DEBUG = 'Y' THEN
             AHL_DEBUG_PUB.debug('x_return_status after uc config '|| x_return_status);

          END IF;


      -- *********************** IB Processing ********************************
      ELSE
          IF G_DEBUG = 'Y' THEN
             AHL_DEBUG_PUB.debug('IB Processing');
          END IF;
          -- dbms_output.put_line('IB processing');

          Process_IB(
                   p_x_csi_transaction_rec => l_csi_transaction_rec,
                   p_x_parts_rec => p_x_parts_rec_tbl(i),
                   x_return_status => x_return_status);

      END IF; -- if l_uc_processing

      -- error checking after UC or IB processing
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      ---*********** Update item location to WIP if operation is remove or swap***********---

      /*IF ( p_x_parts_rec_tbl(i).Unit_Config_Header_Id is null AND p_x_parts_rec_tbl(i).operation_type='D' or p_x_parts_rec_tbl(i).operation_type='M') then

         update_item_location(
                            p_x_parts_rec => p_x_parts_rec_tbl(i),
                            p_x_csi_transaction_rec => l_csi_transaction_rec,
                            x_return_status => x_return_status);
         IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;



         ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

      END IF;*/

      /* P11.5.10 Enhancement: Material Transaction Functionality is removed from Parts Change.
       Per ER#:
      ---****** Call Material Transaction if inventory is not null and part is returned. ******--

      IF ( (p_x_parts_rec_tbl(i).operation_type='D' or p_x_parts_rec_tbl(i).operation_type='M')
          AND ( p_x_parts_rec_tbl(i).SubInventory_code is not null)) THEN

          IF G_DEBUG = 'Y' THEN
             AHL_DEBUG_PUB.debug('inside material txn call');
          END IF;
          --Call material transaction api
          Process_material_txn(
                             p_x_parts_rec => p_x_parts_rec_tbl(i),
                             p_module_type => p_module_type,
                             x_return_status => x_return_status);

          IF (x_return_status = FND_API.G_RET_STS_ERROR) then
             RAISE FND_API.G_EXC_ERROR;
          ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;
      */

      ---******Insert into ahl_part_changes table ******---
      -- Null out removal date and installation dates.
      IF (p_x_parts_rec_tbl(i).operation_type='D' ) THEN
         p_x_parts_rec_tbl(i).installation_date := NULL;
         l_part_change_type := 'R';  -- Remove.
         l_part_change_qty := NVL(p_x_parts_rec_tbl(i).removed_quantity,1);
         p_x_parts_rec_tbl(i).Installed_Instance_Id := NULL;
      END IF;

      IF (p_x_parts_rec_tbl(i).operation_type='C' ) THEN
         p_x_parts_rec_tbl(i).removal_date := NULL;
         l_part_change_type := 'I'; -- Install

         -- Find out the Issue Material Txn for this instance.
         Get_Issue_Mtl_Txn ( p_x_parts_rec_tbl(i).workorder_id,
                             p_x_parts_rec_tbl(i).Installed_Instance_Id,
                             l_Issue_Mtl_Txn_id);
         l_part_change_qty := NVL(p_x_parts_rec_tbl(i).installed_quantity,1);
         p_x_parts_rec_tbl(i).Removed_Instance_Id := NULL;

      END IF;

      IF (p_x_parts_rec_tbl(i).operation_type='M' ) THEN
         l_part_change_type := 'S'; -- Swap.

         -- Find out the Issue Material Txn for this instance.
         Get_Issue_Mtl_Txn ( p_x_parts_rec_tbl(i).workorder_id,
                             p_x_parts_rec_tbl(i).Installed_Instance_Id,
                             l_Issue_Mtl_Txn_id);
         l_part_change_qty := NVL(p_x_parts_rec_tbl(i).installed_quantity,1);

      END IF;

      -- set path position ID -- out parameter.
      p_x_parts_rec_tbl(i).path_position_id := l_path_position_id;

      -- insert into ahl_part_chnages if everything is ok.
      AHL_PART_CHANGES_PKG.insert_row(
            X_ROWID => l_row_id,
            X_PART_CHANGE_ID => p_x_parts_rec_tbl(i).part_change_txn_id,
            X_UNIT_CONFIG_HEADER_ID =>p_x_parts_rec_tbl(i).unit_config_header_id,
            X_REMOVED_INSTANCE_ID => p_x_parts_rec_tbl(i).removed_instance_id,
            --X_MC_RELATIONSHIP_ID => p_x_parts_rec_tbl(i).mc_relationship_id,
            X_MC_RELATIONSHIP_ID => l_path_position_id,
            X_REMOVAL_CODE =>  p_x_parts_rec_tbl(i).removal_code,
            --X_STATUS_ID =>  p_x_parts_rec_tbl(i).Condition_id,
            X_REMOVAL_REASON_ID =>  p_x_parts_rec_tbl(i).removal_reason_id,
            X_INSTALLED_INSTANCE_ID => p_x_parts_rec_tbl(i).installed_instance_id,
            X_WORKORDER_OPERATION_ID => p_x_parts_rec_tbl(i).workorder_operation_id,
            X_OBJECT_VERSION_NUMBER => 1,
            --X_COLLECTION_ID => p_x_parts_rec_tbl(i).collection_id,
            --X_WORKORDER_MTL_TXN_ID =>   p_x_parts_rec_tbl(i).material_txn_id,
            --X_NON_ROUTINE_WORKORDER_ID => null,
            X_REMOVAL_DATE => p_x_parts_rec_tbl(i).removal_date,
            X_INSTALLATION_DATE => p_x_parts_rec_tbl(i).Installation_Date,
            X_ISSUE_MTL_TXN_ID => l_issue_mtl_txn_id,
            X_RETURN_MTL_TXN_ID => null,
            X_PART_CHANGE_TYPE => l_part_change_type,
            X_CREATION_DATE => sysdate,
            X_CREATED_BY =>  fnd_global.user_id,
            X_LAST_UPDATE_DATE => sysdate,
            X_LAST_UPDATED_BY  => fnd_global.user_id,
            X_LAST_UPDATE_LOGIN  => fnd_global.login_id,
            X_ATTRIBUTE_CATEGORY =>null,
            X_ATTRIBUTE1 => null,
            X_ATTRIBUTE2 =>null,
            X_ATTRIBUTE3 =>null,
            X_ATTRIBUTE4 =>null,
            X_ATTRIBUTE5 =>null,
            X_ATTRIBUTE6 =>null,
            X_ATTRIBUTE7 =>null,
            X_ATTRIBUTE8 =>null,
            X_ATTRIBUTE9 =>null,
            X_ATTRIBUTE10 =>null,
            X_ATTRIBUTE11 =>null,
            X_ATTRIBUTE12 =>null,
            X_ATTRIBUTE13 =>null,
            X_ATTRIBUTE14 =>null,
            X_ATTRIBUTE15 =>null,
            X_QUANTITY => l_part_change_qty);

    END LOOP;

  END IF;

  /* Disposition API creates Service Request. Hence this is no longer needed. */
  /* ER#
  -- Create Service Request for the Parts records if operation type = D or M andbased on condition.

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug('Calling SR');
  END IF;
  --Call sr api
  Process_SR(
           p_x_parts_rec_tbl => p_x_parts_rec_tbl,
           p_module_type => p_module_type,
           x_return_status   => x_return_status);

  IF (x_return_status = FND_API.G_RET_STS_ERROR) then
     RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  */

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

    -- Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug('Completed Processing. Checking for errors', '');
  END IF;

  -- Standard call to get message count and if count is 1, get message
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

  -- Disable debug (if enabled)
  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.disable_debug;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to perform_part_changes_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
-- Disable debug
    IF G_DEBUG = 'Y' THEN
       AHL_DEBUG_PUB.disable_debug;
    END IF;


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to perform_part_changes_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
   -- Disable debug
    IF G_DEBUG = 'Y' THEN
       AHL_DEBUG_PUB.disable_debug;
    END IF;
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to perform_part_changes_pvt;
    --IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'AHL_PRD_PARTS_CHANGE_PVT',
                               p_procedure_name => 'process_parts',
                               p_error_text     => SQLERRM);
    --END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

    -- Disable debug
    IF G_DEBUG = 'Y' THEN
       AHL_DEBUG_PUB.disable_debug;
    END IF;

End Process_Part;
---------------------------------

Procedure Validate_Part_Record (
                              p_x_parts_rec    In  Out Nocopy Ahl_Parts_Rec_type,
                              p_module_type    In             Varchar2,
                              X_Return_Status  Out NOCOPY     Varchar2)
IS
--
  l_junk varchar2(100):= null;
  l_org_id NUMBER;
  l_inventory_status number;
  l_plan_id number;
  l_wip_entity_id number;

  l_rm_inventory_item_id  NUMBER;
  l_rm_inst_number        csi_item_instances.instance_number%TYPE;

  --To check if the unit config header is valid or not.
  CURSOR ahl_uc_header_csr(p_uc_header_id number) IS
    select 'x'
    from ahl_unit_config_headers
    where unit_config_header_id = p_uc_header_id
        and trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

  --To check that the operation sequence exists for the work order.
  CURSOR ahl_wo_Oper_csr (p_wo_id in number, p_op_seq_num in number) IS
    select workorder_operation_id
    from ahl_workorder_operations
    where workorder_id= p_wo_id
        and operation_sequence_num = p_op_seq_num;

  -- Get workorder details.
  -- and get organization id
  CURSOR ahl_job_csr(p_wo_id in number) IS
    select job_status_code, organization_id , wip_entity_id
    --from ahl_workorders_v
    from ahl_workorder_tasks_v
    where workorder_id = p_wo_id;

  /*
  --To check if user sends a target visit, then check should be made that the visit is open.
  CURSOR ahl_visit_csr(p_visit_id in NUmber) IS
    select status_code
    from ahl_visits_vl
    where visit_id = p_visit_id;

  -- to get locator_id from locator code
  CURSOR ahl_locator_csr (p_locator_code in varchar2, p_org_id in number) is
    select inventory_location_id
    from mtl_item_locations_kfv
    where concatenated_segments = p_locator_code
        and organization_id =p_org_id;

  */

  -- to validate installed item instance
  CURSOR ahl_location_type_csr(l_item_instance_id in number) IS
    -- Fix for bug# 6993283
    --select location_type_code
    select cii.wip_job_id,
    (select wip_entity_name
      from wip_entities
      where wip_entity_id = cii.wip_job_id) wip_job_name
    from csi_item_instances cii
    where cii.instance_id= l_item_instance_id
        --and location_type_code  NOT IN ('PO','IN-TRANSIT','PROJECT','INVENTORY')
        and cii.location_type_code = 'WIP'
        and trunc(sysdate) < trunc(nvl(cii.active_end_date, sysdate+1))
        and cii.quantity > 0;

  -- to validate removal item instance.
  CURSOR ahl_item_instance_csr(p_item_instance_id in number) IS
    select inventory_item_id, instance_number
    from csi_item_instances
    where instance_id= p_item_instance_id
       and trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

  -- To validate if instance's item defined in job's org.
  CURSOR mtl_system_kfv_csr(p_inventory_item_id IN NUMBER,
                            p_org_id            IN NUMBER) IS
    Select 'x'
    From mtl_system_items_b
    where inventory_item_id = p_inventory_item_id
      and organization_id = p_org_id
      and enabled_flag = 'Y';

--
  l_msg_data varchar2(2000);
  l_msg_count number;

  l_return_status VARCHAR2(1);

  CURSOR get_instance_attrib_csr(p_instance_id NUMBER) IS
    SELECT inventory_item_id,
           inv_master_organization_id,
           lot_number,
           quantity,
           unit_of_measure,
           inventory_revision,
           serial_number
      FROM csi_item_instances
     WHERE instance_id = p_instance_id;

 l_config_instance_rec get_instance_attrib_csr%ROWTYPE;
 l_new_instance_rec get_instance_attrib_csr%ROWTYPE;
--

 -- Fix for bug# 6993283
 l_inst_job_id           NUMBER;
 l_wip_job_name          WIP_ENTITIES.wip_entity_name%TYPE;

BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;



  --********Test that the workorder_id is not null -----
  IF ( p_x_parts_rec.workorder_id is null or p_x_parts_rec.workorder_id =FND_API.G_MISS_NUM) then

    FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_WO_ID_MISSIN');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --rroy
  -- ACL Changes
  l_return_status := AHL_PRD_UTIL_PKG.Is_Unit_Locked(p_workorder_id => p_x_parts_rec.workorder_id,
                    p_ue_id => NULL,
                    p_visit_id => NULL,
                    p_item_instance_id => NULL);
  IF l_return_status = FND_API.G_TRUE THEN
        FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_PRTCHG_UNTLCKD');
  	FND_MSG_PUB.ADD;
  	RAISE FND_API.G_EXC_ERROR;
  END IF;

  --rroy
-- ACL Changes

  --******** Test that operation type is not null -----
  IF ( p_x_parts_rec.operation_type is null ) then
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_OP_TYPE_MISSIN');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --*********** Operation Seq ********** -----
  IF (p_x_parts_rec.operation_sequence_num is null ) then
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_INVALID_OPERATION');
    FND_MESSAGE.Set_Token('OPSEQ', p_x_parts_rec.operation_sequence_num);
    --FND_MESSAGE.Set_Token('WOID', p_x_parts_rec.workorder_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --*********** Check that the operation sequence exists for the work order. ---
  OPEN ahl_wo_oper_csr(p_x_parts_rec.workorder_id,p_x_parts_rec.operation_sequence_num );

  FETCH ahl_wo_oper_csr INTO p_x_parts_rec.workorder_operation_id;
  IF (ahl_wo_oper_csr%NOTFOUND) THEN
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_INVALID_OPERATION');
    FND_MESSAGE.Set_Token('OPSEQ', p_x_parts_rec.operation_sequence_num);

    --FND_MESSAGE.Set_Token('WOID', p_x_parts_rec.workorder_id);
    FND_MSG_PUB.ADD;
    CLOSE ahl_wo_oper_csr;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE ahl_wo_oper_csr;

  -- Validate that the job is not closed.
  OPEN ahl_job_csr(p_x_parts_rec.workorder_id );
  FETCH ahl_job_csr INTO l_junk, l_org_id, l_wip_entity_id;
  IF ( ahl_job_csr%NOTFOUND) THEN
    CLOSE ahl_job_csr;
    FND_MESSAGE.set_name('AHL', 'AHL_PRD_WO_INVALID');
    FND_MESSAGE.set_token('WOID', p_x_parts_rec.workorder_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE ahl_job_csr;

  IF (l_junk <> '3' and l_junk <> '19') THEN
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_JOB_CLOSED');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- To test pending transactions in WIP interface.
  /*IF (AHL_WIP_JOB_PVT.wip_massload_pending(l_wip_entity_id)) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;*/

  --Check if the UC header id is valid.
  IF (p_x_parts_rec.Unit_Config_Header_Id is not null) then
    OPEN ahl_uc_header_csr(p_x_parts_rec.Unit_Config_Header_Id );

    FETCH ahl_uc_header_csr INTO l_junk;
    IF ( ahl_uc_header_csr%NOTFOUND) THEN
      CLOSE ahl_uc_header_csr;
      FND_MESSAGE.set_name('AHL', 'AHL_PRD_UC_HEADER_INVALID');
      FND_MESSAGE.set_token('UCID', p_x_parts_rec.unit_config_header_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  --********* Position *************--
  --Check that the position is not null for a UC part
  IF (p_x_parts_rec.mc_relationship_id is null
      and p_x_parts_rec.Unit_Config_Header_Id is not null
      and p_x_parts_rec.operation_type <> 'D')
  THEN
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_NULL_POSN');
    FND_MSG_PUB.ADD;
  END IF;

  --*********Instance number **************--
  -- It is mandatory.This should not be expired.
  IF ( p_x_parts_rec.operation_type='D' and
       p_x_parts_rec.removed_instance_id is null )
  THEN
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_RMV_ITEM_MISSING');
    FND_MSG_PUB.ADD;
  END IF;

  IF ( p_x_parts_rec.operation_type='M' and
       p_x_parts_rec.removed_instance_id is null )
  THEN
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_RMV_ITEM_MISSING');
    FND_MSG_PUB.ADD;
  END IF;

  IF ( ( p_x_parts_rec.operation_type='C' or p_x_parts_rec.operation_type='M') and
       (p_x_parts_rec.installed_instance_id is null) )
  THEN
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_INSTALL_ITEM_MISSIN');
    FND_MSG_PUB.ADD;
  END IF;

  IF ( (p_x_parts_rec.operation_type='C') and
       (p_x_parts_rec.parent_installed_instance_id is null ))
  THEN
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_PARENT_ITEM_MISSING');
    FND_MSG_PUB.ADD;
  END IF;

  --** validate item instance***--
  -- Check whether teh part being installed is valid or not.
  IF (p_x_parts_rec.operation_type ='C' or p_x_parts_rec.operation_type='M') THEN

    OPEN ahl_location_type_csr(p_x_parts_Rec.Installed_Instance_Id);
    /* replaced validation to fix bug# 6993283
    FETCH ahl_location_type_csr into l_junk;
    CLOSE ahl_location_type_csr;
    IF l_junk is null then
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_INST_STATUS_INVALID');
       FND_MSG_PUB.ADD;
       --RAISE FND_API.G_EXC_ERROR;
    END IF;
    */
    FETCH ahl_location_type_csr into l_inst_job_id, l_wip_job_name;
    IF (ahl_location_type_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_ITEM_NOT_ISSUED');
       FND_MSG_PUB.ADD;
    ELSE
      -- added to fix bug# 6993283
      -- validate job ID.
      IF (l_inst_job_id <> l_wip_entity_id) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PRD_INST_JOB_INVALID');
        FND_MESSAGE.Set_Token('WO_NAME',l_wip_job_name);
        FND_MSG_PUB.ADD;
      END IF;
    END IF;
    CLOSE ahl_location_type_csr;
  END IF;

  -- Check if the removed instance is defined in the job's organization.
  IF (p_x_parts_rec.operation_type = 'D' or p_x_parts_rec.operation_type = 'M') THEN
    OPEN ahl_item_instance_csr(p_x_parts_rec.removed_instance_id);
    FETCH ahl_item_instance_csr INTO l_rm_inventory_item_id, l_rm_inst_number;
    IF ahl_item_instance_csr%NOTFOUND THEN
      FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_RMV_ITEM_INVALID');
      FND_MSG_PUB.ADD;
    ELSE
      -- Validate that the item exists in the job's org.
      OPEN mtl_system_kfv_csr(l_rm_inventory_item_id, l_org_id);
      FETCH mtl_system_kfv_csr INTO l_junk;
      IF (mtl_system_kfv_csr%NOTFOUND) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_RMV_ORG_INVALID');
        FND_MESSAGE.Set_Token('INST_ID', l_rm_inst_number);
        FND_MSG_PUB.ADD;
      END IF;
      CLOSE mtl_system_kfv_csr;

    END IF;
    CLOSE ahl_item_instance_csr;
  END IF;


  --******** 	Reason Lov ***--
  --  should not be null for part removal. Validate if the reason code sent exists in the table

  --mtl_transaction_reasons.
  IF ( p_x_parts_rec.removal_reason_id is null
       and (p_x_parts_rec.operation_type='M' or p_x_parts_rec.operation_type='D')
      )
  THEN
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_REASON_CODE_MISSING');
    FND_MSG_PUB.ADD;
  END IF;

  ---*****Validate reason****************
  IF (p_x_parts_rec.removal_reason_id is not null ) THEN
     AHL_PRD_UTIL_PKG.validate_reason(
                                    p_reason_id  => p_x_parts_rec.removal_reason_id,
                                    x_return_status => x_return_status,
                                    x_msg_data => l_msg_data);
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

  END IF;


  /* Condition is stored as part of Disposition. Per ER#  */
  /*
  --*****Condition **********--- Condition should not be null when removing a part.
  IF (p_x_parts_rec.condition_Id is null
      and ( p_x_parts_rec.operation_type='M' or p_x_parts_rec.operation_type='D')
      )
  THEN
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_CONDN_MISSING');
    FND_MSG_PUB.ADD;
  END IF;

  --********* Validate Condition ***************__
  IF (p_x_parts_rec.condition_id is not null ) THEN
    AHL_PRD_UTIL_PKG.validate_condition(
                                      p_condition_id => p_x_parts_rec.condition_id ,
                                      x_return_status => x_return_status,
                                      x_msg_data => l_msg_data );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  */

  --**** Removal Code- This is mandatory in case of part removal.
  IF (p_x_parts_rec.operation_type='D'
             OR p_x_parts_rec.operation_type='M') THEN
    IF (p_x_parts_rec.removal_code is null) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_REMOVAL_CODE_MISSIN');
      FND_MSG_PUB.ADD;
    ELSIF NOT(AHL_UTIL_MC_PKG.Validate_Lookup_Code('AHL_REMOVAL_CODE',p_x_parts_rec.removal_code)) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_PRD_REMOVAL_CODE_INVALID');
      FND_MESSAGE.Set_Token('CODE', p_x_parts_rec.removal_code);
      FND_MSG_PUB.ADD;
    END IF;
  END IF;

  /* SR is now created by Disposition API. ER#
  --********** Perform mrb/unservicebale  i.e. SR creation validations
  IF ((p_x_parts_rec.operation_type='D' or p_x_parts_rec.operation_type='M') AND
       ((fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE') is not null
          and p_x_parts_rec.Condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE'))
        OR
         (fnd_profile.value('AHL_MTL_MAT_STATUS_MRB') is not null and
          p_x_parts_rec.Condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_MRB'))))
  THEN
    --*******	Problem Code- This should not be null in case of part removal.
    --    if p_x_parts_rec.problem_code is null then
    --       FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_PROBLEM_CODE_MISSIN');
    --       FND_MSG_PUB.ADD;
    --    end if;

    --******* Target Visit ***********
    -- Error out if target visit id is null for unserviceable/mrb type part removal.

    IF p_x_parts_rec.target_visit_id is null  THEN
      -- dbms_output.put_line('Target visit is null for unserviceable mrb');
      FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_VISIT_INVALID');
      FND_MSG_PUB.ADD;
    END IF;

    --If user sends a target visit, then check should be made that the visit is open.

    IF (p_x_parts_rec.target_visit_id is not null ) THEN
      OPEN ahl_visit_csr(p_x_parts_rec.target_visit_id );
      FETCH ahl_visit_csr INTO l_junk;
      CLOSE ahl_visit_csr;
      IF l_junk = 'CLOSED' THEN
         FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_VISIT_INVALID');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    --  dbms_output.put_line('target viist id is valid');
  END IF;--end sr validation

  */

  /* Collection Id is now stored in AHL_PRD_DISPOSITIONS_B table */
  /*
  --************* QA plan *************--
  -- Collection_id should not be null if subinventory status is MRB and a QA plan is attached to the item.

  IF (p_x_parts_rec.subinventory_code is not null ) THEN
     -- Status_id of the part must match the subinventory status in the case of return.

     IF ( p_x_parts_rec.operation_type='D' OR
          p_x_parts_rec.operation_type='M') THEN

       AHL_PRD_UTIL_PKG.VALIDATE_MATERIAL_STATUS(p_Organization_Id => l_org_id ,
		  				 p_Subinventory_Code  => p_x_parts_rec.subinventory_code,
       						 p_Condition_id => p_x_parts_rec.condition_id,
                                                 x_return_status => x_return_status);

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- The following procedure call will decide if a qa plan is atatched.
       AHL_QA_RESULTS_PVT.get_qa_plan(
                                      p_api_version   => '1.0',
                                      p_init_msg_list => FND_API.G_False,
                                      p_commit => FND_API.G_FALSE,
                                      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                      p_default => FND_API.G_FALSE,
                                      --p_module_type => p_module_type,
                                      p_organization_id => l_org_id,
                                      p_transaction_number => 2004,
                                      p_col_trigger_value => fnd_profile.value('AHL_MRB_DISP_PLAN_TYPE'),
                                      x_return_status => x_return_status,
                                      x_msg_count => l_msg_count,
                                      x_msg_data => l_msg_data,
                                      x_plan_id  => l_plan_id);

       IF (fnd_profile.value('AHL_MTL_MAT_STATUS_MRB') is not null and
           p_x_parts_rec.condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_MRB')
           and l_plan_id is not null
           and p_x_parts_rec.collection_id is null)
       THEN
         FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_COLLECT_ID_MISSIN');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

     END IF; -- operation type.
  END IF; -- sub-inventory null.

  */

  /* Material Transaction is not allowed from Parts Change. */
  /* ER#
  --************* Locator Code ***************--
  -- get ID if code is provided.
  IF ( p_x_parts_Rec.locator_code is not null AND p_x_parts_rec.subinventory_code is null) THEN

    --OPEN ahl_locator_csr(p_x_parts_rec.locator_code, l_org_id);
    --FETCH ahl_locator_csr INTO p_x_parts_rec.locator_id;
    --IF (ahl_locator_csr%NOTFOUND) then
      FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_SUBINV_MANDATORY');
      FND_MSG_PUB.ADD;
    --END IF;
    --CLOSE ahl_locator_csr;
  END IF;

  -- Validate ID.
  IF (p_x_parts_rec.locator_id is not null ) THEN
    AHL_PRD_UTIL_PKG.validate_locators(
                                     p_locator_id => p_x_parts_rec.locator_id,
                                     p_org_id => l_org_id,
                                     p_subinventory_code => p_x_parts_rec.subinventory_code,
                                     X_Return_Status => x_return_status,
                                     x_msg_data  => l_msg_data);
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  */

  --***********Removal Date *************--
  IF (p_x_parts_rec.Removal_date is null or p_x_parts_rec.Removal_date = FND_API.G_MISS_DATE) THEN

    p_x_parts_rec.Removal_date := sysdate;
  ELSIF (trunc(p_x_parts_rec.Removal_date) > trunc(sysdate)) THEN
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_REMOVAL_DATE_INVALID');
    FND_MESSAGE.Set_Token('DATE',p_x_parts_rec.Removal_date);
    FND_MSG_PUB.ADD;
  END IF;



  --***********Default Installation Date is null *************--
  IF (p_x_parts_rec.Installation_Date is null OR p_x_parts_rec.Installation_Date = FND_API.G_MISS_DATE) THEN

    p_x_parts_rec.Installation_Date := sysdate;
  END IF;

   IF ( p_x_parts_rec.operation_type='D'
     AND p_x_parts_rec.removed_instance_id IS NOT NULL)THEN
     OPEN get_instance_attrib_csr(p_x_parts_rec.removed_instance_id);
     FETCH get_instance_attrib_csr INTO  l_config_instance_rec;
     CLOSE get_instance_attrib_csr;
     IF(NVL(p_x_parts_rec.removed_quantity,1) <= 0 OR NVL(p_x_parts_rec.removed_quantity,1) > l_config_instance_rec.quantity)THEN
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_INRMV_QTY');
       FND_MSG_PUB.ADD;
     END IF;
  END IF;

  IF ( p_x_parts_rec.operation_type='C')THEN

       OPEN get_instance_attrib_csr(p_x_parts_rec.installed_instance_id);
       FETCH get_instance_attrib_csr INTO  l_new_instance_rec;
       CLOSE get_instance_attrib_csr;

       IF(NVL(p_x_parts_rec.installed_quantity,1) <= 0 OR NVL(p_x_parts_rec.installed_quantity,1) > l_new_instance_rec.quantity)THEN
         FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_ININST_QTY');
         FND_MSG_PUB.ADD;
       END IF;

       IF p_x_parts_rec.removed_instance_id IS NOT NULL THEN
         OPEN get_instance_attrib_csr(p_x_parts_rec.removed_instance_id);
         FETCH get_instance_attrib_csr INTO  l_config_instance_rec;
         CLOSE get_instance_attrib_csr;

         IF(l_config_instance_rec.inventory_item_id <> l_new_instance_rec.inventory_item_id
            OR l_config_instance_rec.inv_master_organization_id <> l_new_instance_rec.inv_master_organization_id
            OR NVL(l_config_instance_rec.lot_number,'x') <> NVL(l_new_instance_rec.lot_number,'x')
            OR NVL(l_config_instance_rec.unit_of_measure,'x')  <> NVL(l_new_instance_rec.unit_of_measure,'x')
            OR NVL(l_config_instance_rec.inventory_revision,'x')  <> NVL(l_new_instance_rec.inventory_revision,'x')
            OR l_config_instance_rec.serial_number IS NOT NULL
            OR l_new_instance_rec.serial_number IS NOT NULL)THEN
            FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_INV_MRG');
            FND_MSG_PUB.ADD;

          END IF;
       END IF;

  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
WHEN NO_DATA_FOUND THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  -- dbms_output.put_line('No data found');


END Validate_Part_Record; -- validate_part_record
--------------------------------------

Procedure convert_value_to_id(
                            p_x_parts_rec    In  Out Nocopy Ahl_Parts_Rec_type,
                            X_Return_Status  Out NOCOPY     Varchar2)
IS

  --to get header id if header name is provided
  CURSOR ahl_header_id_csr (p_uc_name in varchar2) IS
    select unit_config_header_id
    from ahl_unit_config_headers
    where name = p_uc_name;

  --to get instance_id if instance_number is provided
  CURSOR ahl_instance_id_csr (p_instance_num in varchar2) IS
    select instance_id
    from csi_item_instances
    where instance_number= p_instance_num;

  /*
  --to get condition_id if condition meaning is provided
  CURSOR ahl_condition_csr ( p_condition in varchar2) is
    select status_id
    from mtl_material_statuses
    where status_code = p_condition;
  */

  --to get reason id if reason name is provided
  CURSOR ahl_reason_csr (p_reason_name in varchar2) IS
    select reason_id
    from mtl_transaction_reasons
    where reason_name = p_Reason_Name;

  --To get removal reason code if menaing is provided
  CURSOR ahl_removal_lookup_csr(p_meaning in varchar2) IS
    select lookup_code
    from fnd_lookup_values_vl
    where meaning = p_meaning
      and lookup_type= 'AHL_REMOVAL_CODE';

  /*
  --to get problem code if problem meaning is provided
  CURSOR ahl_problem_lookup_csr(p_meaning in varchar2) IS
    select lookup_code
    from fnd_lookup_values_vl
    where meaning = p_meaning
      and lookup_type= 'REQUEST_PROBLEM_CODE';

  -- To get target visit id if number is provided
  CURSOR ahl_target_visit_csr (p_visit_number in Number) IS
    select visit_id from ahl_visits_vl
    where visit_number = p_visit_number;
  */

--
BEGIN

  -- Get header_id if header name is provided
  IF (p_x_parts_Rec.unit_config_name is not null
      and p_x_parts_Rec.unit_config_header_id is null ) THEN
    OPEN ahl_header_id_csr(p_x_parts_rec.Unit_Config_Name);
    FETCH ahl_header_id_csr INTO p_x_parts_rec.Unit_Config_Header_Id;
    IF (ahl_header_id_csr%NOTFOUND) THEN
      CLOSE ahl_header_id_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_UC_NAME_MISSING');
      FND_MESSAGE.Set_Token('NAME',p_x_parts_rec.unit_config_name);
      FND_MSG_PUB.ADD;
    ELSE
      CLOSE ahl_header_id_csr;
    END IF;   END IF;

  -- Get Instance Id if instance number is provided
  IF (p_x_parts_rec.removed_instance_num is not null
      and  p_x_parts_rec.removed_instance_id is null ) THEN
    OPEN ahl_instance_id_csr(p_x_parts_rec.removed_instance_num);
    FETCH ahl_instance_id_csr INTO p_x_parts_rec.removed_instance_id;
    IF (ahl_instance_id_csr%NOTFOUND) THEN
      CLOSE ahl_instance_id_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_PRD_RMV_INST_INVALID');
      FND_MESSAGE.Set_Token('INST',p_x_parts_rec.removed_instance_num);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE ahl_instance_id_csr;
   END IF;

  IF (p_x_parts_rec.installed_instance_num is not null
      and p_x_parts_rec.installed_instance_id is null) THEN
    -- dbms_output.put_line('inside ahl_header_id_csr installed');
    OPEN ahl_instance_id_csr(p_x_parts_rec.installed_instance_num);
    FETCH ahl_instance_id_csr INTO p_x_parts_rec.installed_instance_id;
    IF (ahl_instance_id_csr%NOTFOUND) THEN
      CLOSE ahl_instance_id_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_PRD_INSTAL_INST_INVALID');
      FND_MESSAGE.Set_Token('INST',p_x_parts_rec.installed_instance_num);
      FND_MSG_PUB.ADD;
    ELSE
      CLOSE ahl_instance_id_csr;
    END IF;
  END IF;

  --Parent installed instance number
  IF (p_x_parts_rec.parent_installed_instance_num is not null
      and p_x_parts_rec.parent_installed_instance_id is null) THEN

    OPEN ahl_instance_id_csr(p_x_parts_rec.parent_installed_instance_num);
    FETCH ahl_instance_id_csr INTO p_x_parts_rec.parent_installed_instance_id;
    IF (ahl_instance_id_csr%NOTFOUND) THEN
      CLOSE ahl_instance_id_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_PINSTAL_INVALID');
      FND_MESSAGE.Set_Token('INST',p_x_parts_rec.parent_installed_instance_num);
      FND_MSG_PUB.ADD;
    ELSE
      CLOSE ahl_instance_id_csr;
    END IF;
  END IF;

  /* Condition is stored in AHL_PRD_DISPOSITIONS_B
  -- Get condition id if condition meaning is provided
  IF (p_x_parts_Rec.Condition is not null
        and p_x_parts_Rec.Condition_id is null) THEN
    -- dbms_output.put_line('inside ahl_condition_csr');
    OPEN ahl_condition_csr(p_x_parts_rec.condition);
    FETCH ahl_condition_csr INTO p_x_parts_rec.condition_id;
    IF (ahl_condition_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_PRD_COND_INVALID');
      FND_MESSAGE.Set_Token('CODE',p_x_parts_rec.condition);
      FND_MSG_PUB.ADD;
    END IF;
    CLOSE ahl_condition_csr;
  END IF;
  */

  -- Get reason id if reasonname is provided
  IF ( p_x_parts_Rec.Removal_Reason_Name is not null
        and p_x_parts_Rec.Removal_Reason_Id is null) THEN
    OPEN ahl_reason_csr(p_x_parts_rec.removal_reason_name);
    FETCH ahl_reason_csr INTO p_x_parts_rec.removal_reason_id;
    IF (ahl_reason_csr%NOTFOUND) THEN
      CLOSE ahl_reason_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_PRD_REASON_INVALID');
      FND_MSG_PUB.ADD;
    ELSE
      CLOSE ahl_reason_csr;
    END IF;
  END IF;

  --Get reason_code if reason_meaning is provided
  IF (p_x_parts_rec.removal_meaning is not null
      AND p_x_parts_rec.removal_code is null) THEN
    OPEN ahl_removal_lookup_csr(p_x_parts_rec.removal_meaning);
    FETCH ahl_removal_lookup_csr INTO p_x_parts_rec.removal_code;
    IF (ahl_removal_lookup_csr%NOTFOUND) THEN
       CLOSE ahl_removal_lookup_csr;
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_REMOVAL_CODE_INVALID');
       FND_MESSAGE.Set_Token('CODE',p_x_parts_rec.removal_meaning);
       FND_MSG_PUB.ADD;
    ELSE
       CLOSE ahl_removal_lookup_csr;
    END IF;
  END IF;


 /* SR is created by Disposition API.
  -- To get target visit id if number is provided
  IF (p_x_parts_rec.target_visit_num is not null
        AND p_x_parts_rec.target_visit_id is null) THEN
    OPEN ahl_target_visit_csr(p_x_parts_rec.target_visit_num);
    FETCH ahl_target_visit_csr INTO p_x_parts_rec.target_visit_id;
    IF (ahl_target_visit_csr%NOTFOUND) THEN
      CLOSE ahl_target_visit_csr;
      FND_MESSAGE.Set_Name('AHL','AHL_TARGET_VISIT_INVALID');
      FND_MESSAGE.Set_Token('CODE',p_x_parts_rec.target_visit_num);
      FND_MSG_PUB.ADD;
    ELSE
      CLOSE ahl_target_visit_csr;
    END IF;
  END IF;

  --Get problem_code if problem_meaning is provided
  IF (p_x_parts_rec.problem_meaning is not null
      AND p_x_parts_rec.problem_code is null) THEN
    OPEN ahl_problem_lookup_csr(p_x_parts_rec.problem_meaning);
    FETCH ahl_problem_lookup_csr INTO p_x_parts_rec.problem_code;
    IF (ahl_problem_lookup_csr%NOTFOUND) THEN
              CLOSE ahl_problem_lookup_csr;
                FND_MESSAGE.Set_Name('AHL','AHL_PROBLEM_CODE_INVALID');
                FND_MESSAGE.Set_Token('CODE',p_x_parts_rec.problem_meaning);
                FND_MSG_PUB.ADD;
             else
               CLOSE ahl_problem_lookup_csr;
            end if;
  end if;
  */

end;--procedure
-------------------------------------



-- Added workorder_id to fix bug# 5564026.
-- Er# 5660658: Added p_validation_mode parameter. This takes 2 values
-- PARTS_CHG and UPDATE_UC. UC status validation should be done only for Parts
-- Change.
Procedure get_unit_config_information(
                                    p_item_instance_id In  Number,
                                    p_workorder_id     In  Number,
                                    p_validation_mode  In  varchar2 := 'PARTS_CHG',
                                    x_unit_config_id   Out NOCOPY Number,
                                    x_unit_config_name Out NOCOPY Varchar2,
                                    x_return_status    Out NOCOPY Varchar2)
IS
--
  l_name  ahl_unit_config_headers.name%TYPE;
  l_location_type_code varchar2(30);
  l_location_meaning   fnd_lookups.meaning%TYPE;
--
  CURSOR ahl_uc_name_csr(p_uc_name in varchar2) IS
    select unit_config_header_id, unit_config_status_code,active_uc_status_code
    from ahl_unit_config_headers
    where name = p_uc_name
      and trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1));

  CURSOR ahl_location_type_csr(p_item_instance_id   In number,
                               p_csi_location_type  In Varchar2) IS
    select location_type_code, f.meaning
    from csi_item_instances csi, csi_lookups f
    where csi.location_type_code = f.lookup_code



        and f.lookup_type = p_csi_location_type
        and  instance_id= p_item_instance_id
    	and  TRUNC(SYSDATE) < TRUNC(NVL(active_end_date, SYSDATE+1));

  -- get instance for the work order.
  CURSOR get_vst_instance_csr (p_workorder_id IN NUMBER) IS

  SELECT
         NVL(VST.ITEM_INSTANCE_ID, VTS.INSTANCE_ID)
  FROM
        AHL_WORKORDERS AWOS,
        AHL_VISITS_B VST,
        AHL_VISIT_TASKS_B VTS
  WHERE
        AWOS.VISIT_TASK_ID = VTS.VISIT_TASK_ID   AND
        VST.VISIT_ID = VTS.VISIT_ID  AND
        WORKORDER_ID = p_workorder_id;

  l_unit_config_status_code   ahl_unit_config_headers.unit_config_status_code%TYPE;
  l_active_uc_status_code     ahl_unit_config_headers.active_uc_status_code%TYPE;

  l_item_instance_id NUMBER;
  l_uc_header_id     NUMBER;

--
BEGIN

  -- Initialize API return status to success
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_item_instance_id := p_item_instance_id;

  IF p_workorder_id IS NOT NULL
  THEN
     OPEN get_vst_instance_csr(p_workorder_id);
     FETCH get_vst_instance_csr INTO l_item_instance_id;
     CLOSE get_vst_instance_csr;
  END IF;

  l_name := AHL_UMP_UTIL_PKG.get_unitName (l_item_instance_id );
  x_unit_config_name:= l_name;

  IF (l_name is not null ) THEN
      OPEN ahl_uc_name_csr(l_name);
      FETCH ahl_uc_name_csr INTO x_unit_config_id, l_unit_config_status_code,
                                 l_active_uc_status_code;
      IF (ahl_uc_name_csr%NOTFOUND) THEN
         x_unit_config_name := NULL;
         x_unit_config_id := NULL;
      ELSE
        IF (l_unit_config_status_code = 'DRAFT') THEN
          FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_UC_DRAFT');
          FND_MSG_PUB.ADD;
          CLOSE ahl_uc_name_csr;
          RAISE FND_API.G_EXC_ERROR;
        ELSIF ((p_validation_mode = 'PARTS_CHG') AND (l_active_uc_status_code <> 'APPROVED')) THEN
          FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_UC_UNAPPROVED');
          FND_MSG_PUB.ADD;
          CLOSE ahl_uc_name_csr;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      CLOSE ahl_uc_name_csr;
  END IF;

  -- Test whether the item instance is valid. If it is in inventory then return an error.
  OPEN ahl_location_type_csr(l_item_instance_id, G_CSI_LOCATION_TYPE_CODE);
  FETCH ahl_location_type_csr INTO l_location_type_code, l_location_meaning;
  IF (ahl_location_type_csr%NOTFOUND) THEN
     CLOSE ahl_location_type_csr;
     FND_MESSAGE.Set_Name('AHL', 'AHL_PRD_PC_INST_EXPIRED');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  ELSE
    IF (l_location_type_code IN ('PO','IN-TRANSIT','PROJECT','INVENTORY')) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_PRD_INST_STATUS_INVALID');
      FND_MESSAGE.Set_Token('STATUS',l_location_meaning);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END; -- procedure get_unit_config_information
------------------------------------------

Procedure create_csi_transaction_rec(
                                   p_x_csi_transaction_rec in out nocopy CSI_DATASTRUCTURES_PUB.transaction_rec,

                                   X_Return_Status  Out NOCOPY     Varchar2)
IS

  l_transaction_type_id number;
  l_return_val boolean;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- csi transaction record.
  p_x_csi_transaction_rec.source_transaction_date := sysdate;

  -- get transaction_type_id .
  AHL_Util_UC_Pkg.GetCSI_Transaction_ID('UC_UPDATE',l_transaction_type_id, l_return_val);

  IF NOT(l_return_val) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- use the transaction id from the header record.
  p_x_csi_transaction_rec.transaction_type_id := l_transaction_type_id;

END create_csi_transaction_rec;
----------------------------------

Procedure Process_UC(
                   p_x_parts_rec   in out nocopy Ahl_Parts_Rec_type,
                   p_module_type   in            Varchar2,
                   p_x_csi_transaction_rec In Out Nocopy CSI_DATASTRUCTURES_PUB.transaction_rec,
                   X_Return_Status  Out NOCOPY     Varchar2,
                   x_path_position_id Out NOCOPY   Number,
                   x_warning_msg_tbl OUT NOCOPY ahl_uc_validation_pub.error_tbl_type)
IS
  l_msg_count number;
  l_msg_data varchar2(2000);

  CURSOR check_inst_nonserial(p_instance_id IN NUMBER) IS
    SELECT 'X'
    FROM mtl_system_items_b mtl, csi_item_instances csi
    WHERE csi.instance_id = p_instance_id
    AND csi.inventory_item_id = mtl.inventory_item_id
    AND NVL(csi.inv_organization_id, csi.inv_master_organization_id) = mtl.organization_id
    AND mtl.serial_number_control_code = 1;

  l_junk VARCHAR2(1);
  l_serialized VARCHAR2(1);
  l_move_item_instance_tbl move_item_instance_tbl_type;

  CURSOR get_curr_quantity_csr(p_instance_id IN NUMBER) IS
  SELECT QUANTITY from csi_item_instances
  WHERE INSTANCE_ID = p_instance_id;

  l_curr_config_qty NUMBER;
  l_curr_job_qty NUMBER;
  l_dest_instance_id NUMBER;
  l_remaining_qty NUMBER;

  l_instance_rec csi_datastructures_pub.instance_rec;

  CURSOR csi_item_instance_csr(p_instance_id IN NUMBER) IS
  select instance_number,object_Version_number
  from csi_item_instances CII
  where CII.instance_id = p_instance_id;

  CURSOR get_wip_job_csr(p_workorder_id IN NUMBER) IS
  select wip_entity_id from ahl_workorders
  where workorder_id = p_workorder_id;
  l_wip_job_id NUMBER;

  CURSOR removal_instance_id(p_instance_id IN NUMBER, p_wip_job_id IN NUMBER) IS
  SELECT C1.instance_id FROM CSI_ITEM_INSTANCES C1, CSI_ITEM_INSTANCES C2
  WHERE C1.INV_MASTER_ORGANIZATION_ID= C2.INV_MASTER_ORGANIZATION_ID
  AND C1.INVENTORY_ITEM_ID = C2.INVENTORY_ITEM_ID
  AND NVL(C1.INVENTORY_REVISION,'x') = NVL(C2.INVENTORY_REVISION,'x')
  AND NVL(C1.LOT_NUMBER,'x') = NVL(C2.LOT_NUMBER,'x')
  AND C1.WIP_JOB_ID= p_wip_job_id
  AND C1.unit_of_measure = C2.unit_of_measure
  AND C2.instance_id = p_instance_id
  AND C1.quantity > 0
  AND C1.ACTIVE_START_DATE <= SYSDATE
  AND ((C1.ACTIVE_END_DATE IS NULL) OR (C1.ACTIVE_END_DATE > SYSDATE));

  l_final_removed_inst_id NUMBER;

BEGIN

  -- Initialize.
  x_path_position_id := p_x_parts_rec.mc_relationship_id;

  OPEN get_wip_job_csr(p_x_parts_rec.workorder_id);
  FETCH get_wip_job_csr INTO l_wip_job_id;
  CLOSE get_wip_job_csr;

  IF ( p_x_parts_rec.operation_type ='D') then
     IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('Before making a call to AHL_UC_INSTANCE_PVT.remove_instance.');
     END IF;

     -- find the path_position_id for the removed instance.

     AHL_MC_PATH_POSITION_PVT.Map_Instance_To_Pos_ID (
          p_api_version => 1.0,
          x_return_status => x_return_status,
          x_msg_count     => l_msg_count,
          x_msg_data      => l_msg_data,
          p_csi_item_instance_id => p_x_parts_rec.removed_instance_id,
          x_path_position_id  => x_path_position_id);


     IF (x_return_status = FND_API.G_RET_STS_ERROR) then
        RAISE FND_API.G_EXC_ERROR;
     ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     l_serialized := FND_API.G_FALSE;
     OPEN check_inst_nonserial(p_x_parts_rec.Removed_Instance_Id);
     FETCH check_inst_nonserial INTO l_junk;
     IF(check_inst_nonserial%NOTFOUND)THEN
        l_serialized := FND_API.G_TRUE;
     END IF;
     CLOSE check_inst_nonserial;

     IF( l_serialized = FND_API.G_FALSE) THEN
       OPEN get_curr_quantity_csr(p_x_parts_rec.Removed_Instance_Id);
       FETCH get_curr_quantity_csr INTO l_curr_config_qty;
       CLOSE get_curr_quantity_csr;
     END IF;
       --Call remove_instance
     IF( l_serialized = FND_API.G_TRUE OR p_x_parts_rec.Removed_Quantity = l_curr_config_qty)THEN
       AHL_UC_INSTANCE_PVT.remove_instance(
         p_api_version           =>  1.0,
         p_init_msg_list         =>  FND_API.G_TRUE,
         p_commit                =>  FND_API.G_FALSE,
         p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
         x_return_status         =>  x_return_status,
         x_msg_count             =>  l_msg_count,
         x_msg_data              =>  l_msg_data,
         p_uc_header_id          =>  p_x_parts_rec.unit_config_header_id,
         p_instance_id           =>  p_x_parts_rec.Removed_Instance_Id,
         p_csi_ii_ovn            =>  p_x_parts_rec.CSI_II_OBJECT_VERSION_NUM,
         p_prod_user_flag        =>  'Y');


        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        update_item_location(
                            p_x_parts_rec => p_x_parts_rec,
                            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
                            x_return_status => x_return_status);
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        l_move_item_instance_tbl(1).instance_id := p_x_parts_rec.Removed_Instance_Id;
        l_move_item_instance_tbl(1).quantity := p_x_parts_rec.Removed_Quantity;
        l_move_item_instance_tbl(1).to_workorder_id := p_x_parts_rec.workorder_id;

        move_instance_location(
              P_API_Version =>  1.0,
              P_Init_Msg_List => Fnd_API.G_False,
              P_Commit   => Fnd_API.G_False,
              P_Validation_Level  => Fnd_API.G_Valid_Level_Full,
              p_module_type => 'API',
              p_default     => FND_API.G_TRUE,
              p_move_item_instance_tbl => l_move_item_instance_tbl,
              x_return_status         =>  x_return_status,
              x_msg_count             =>  l_msg_count,
              x_msg_data              =>  l_msg_data);
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF( l_serialized = FND_API.G_FALSE)THEN
          OPEN removal_instance_id(p_x_parts_rec.Removed_Instance_Id, l_wip_job_id);
          FETCH removal_instance_id INTO l_final_removed_inst_id;
          IF(removal_instance_id%FOUND)THEN
           p_x_parts_rec.Removed_Instance_Id := l_final_removed_inst_id;
          END IF;
          CLOSE removal_instance_id;
        END IF;
        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('1 final p_x_parts_rec.Removed_Instance_Id ' || p_x_parts_rec.Removed_Instance_Id);
          AHL_DEBUG_PUB.debug('l_final_removed_inst_id ' || l_final_removed_inst_id);
        END IF;

     ELSE -- non-serialized incomplete removal

        AHL_UC_INSTANCE_PVT.remove_instance(
         p_api_version           =>  1.0,
         p_init_msg_list         =>  FND_API.G_TRUE,
         p_commit                =>  FND_API.G_FALSE,
         p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
         x_return_status         =>  x_return_status,
         x_msg_count             =>  l_msg_count,
         x_msg_data              =>  l_msg_data,
         p_uc_header_id          =>  p_x_parts_rec.unit_config_header_id,
         p_instance_id           =>  p_x_parts_rec.Removed_Instance_Id,
         p_csi_ii_ovn            =>  p_x_parts_rec.CSI_II_OBJECT_VERSION_NUM,
         p_prod_user_flag        =>  'Y');


        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        update_item_location(
                            p_x_parts_rec => p_x_parts_rec,
                            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
                            x_return_status => x_return_status);

        l_remaining_qty := l_curr_config_qty - p_x_parts_rec.Removed_Quantity;
        -- update configuration instance with net quantity
        l_instance_rec.instance_id := p_x_parts_rec.Removed_Instance_Id;
        l_instance_rec.quantity := l_remaining_qty;
        OPEN csi_item_instance_csr(p_x_parts_rec.Removed_Instance_Id);
        FETCH csi_item_instance_csr INTO p_x_parts_rec.Removed_Instance_Num
                                         ,l_instance_rec.object_version_number;
        CLOSE csi_item_instance_csr;

        update_csi_item_instance(
            p_instance_rec        => l_instance_rec,
            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
            x_return_status      =>  x_return_status
        );

        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        --create same instance with removed qty
        create_similar_instance(
          p_source_instance_id => p_x_parts_rec.Removed_Instance_Id,
          p_dest_quantity      => p_x_parts_rec.Removed_Quantity,
          p_dest_wip_job_id    => l_wip_job_id,
          p_x_csi_transaction_rec => p_x_csi_transaction_rec,
          x_dest_instance_id   => l_dest_instance_id,
          x_return_status      =>  x_return_status
        );
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --Call install_existing_instance
       AHL_UC_INSTANCE_PVT.install_existing_instance(
        p_api_version           =>  1.0,
        p_init_msg_list         =>  FND_API.G_TRUE,
        p_commit                =>  FND_API.G_FALSE,
        p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
        x_return_status         =>  x_return_status,
        x_msg_count             =>  l_msg_count,
        x_msg_data              =>  l_msg_data,
        p_uc_header_id          =>  p_x_parts_rec.unit_config_header_id,
        p_parent_instance_id    =>  p_x_parts_rec.Parent_Installed_Instance_Id,
        p_instance_id           =>  p_x_parts_rec.Removed_Instance_Id,
        p_instance_number       =>  p_x_parts_rec.Removed_Instance_Num,
        p_relationship_id       =>  p_x_parts_rec.mc_relationship_id,
        p_csi_ii_ovn            =>  NULL,
        p_prod_user_flag        =>  'Y',
        x_warning_msg_tbl       =>  x_warning_msg_tbl);

       IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('After making a call to AHL_UC_INSTANCE_PVT.install_existing_instance.');
       END IF;

       IF (x_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

        p_x_parts_rec.Removed_Instance_Id := l_dest_instance_id;
         IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('update_item_location :: ' ||l_dest_instance_id);
       END IF;
        /*update_item_location(
                            p_x_parts_rec => p_x_parts_rec,
                            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
                            x_return_status => x_return_status);
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
           RAISE FND_API.G_EXC_ERROR;
        END IF;*/

        l_move_item_instance_tbl(1).instance_id := p_x_parts_rec.Removed_Instance_Id;
        l_move_item_instance_tbl(1).quantity := p_x_parts_rec.Removed_Quantity;
        l_move_item_instance_tbl(1).to_workorder_id := p_x_parts_rec.workorder_id;
        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('moving it');
       END IF;
        move_instance_location(
              P_API_Version =>  1.0,
              P_Init_Msg_List => Fnd_API.G_False,
              P_Commit   => Fnd_API.G_False,
              P_Validation_Level  => Fnd_API.G_Valid_Level_Full,
              p_module_type => 'API',
              p_default     => FND_API.G_TRUE,
              p_move_item_instance_tbl => l_move_item_instance_tbl,
              x_return_status         =>  x_return_status,
              x_msg_count             =>  l_msg_count,
              x_msg_data              =>  l_msg_data);
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        OPEN removal_instance_id(p_x_parts_rec.Removed_Instance_Id, l_wip_job_id);
        FETCH removal_instance_id INTO l_final_removed_inst_id;
        IF(removal_instance_id%FOUND)THEN
           p_x_parts_rec.Removed_Instance_Id := l_final_removed_inst_id;
        END IF;
        CLOSE removal_instance_id;
        --p_x_parts_rec.Removed_Instance_Id := 274689;
        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('2 final p_x_parts_rec.Removed_Instance_Id ' || p_x_parts_rec.Removed_Instance_Id);
          AHL_DEBUG_PUB.debug('l_final_removed_inst_id ' || l_final_removed_inst_id);
        END IF;

     END IF;

  ELSIF ( p_x_parts_rec.operation_type ='C') then

     IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('Before making a call to AHL_UC_INSTANCE_PVT.install_existing_instance.');
     END IF;

     l_serialized := FND_API.G_FALSE;
     OPEN check_inst_nonserial(p_x_parts_rec.Installed_Instance_Id);
     FETCH check_inst_nonserial INTO l_junk;
     IF(check_inst_nonserial%NOTFOUND)THEN
        l_serialized := FND_API.G_TRUE;
     END IF;
     CLOSE check_inst_nonserial;

     l_curr_config_qty := 0;
     IF( l_serialized = FND_API.G_FALSE AND p_x_parts_rec.Removed_Instance_Id IS NOT NULL) THEN
       OPEN get_curr_quantity_csr(p_x_parts_rec.Removed_Instance_Id);
       FETCH get_curr_quantity_csr INTO l_curr_config_qty;
       CLOSE get_curr_quantity_csr;
     END IF;

     IF( l_serialized = FND_API.G_FALSE AND p_x_parts_rec.Installed_Instance_Id IS NOT NULL) THEN
       OPEN get_curr_quantity_csr(p_x_parts_rec.Installed_Instance_Id);
       FETCH get_curr_quantity_csr INTO l_curr_job_qty;
       CLOSE get_curr_quantity_csr;
     END IF;

     IF( l_serialized = FND_API.G_FALSE
         AND l_curr_job_qty <> p_x_parts_rec.Installed_Quantity AND l_curr_config_qty = 0)THEN
         -- create new instance with remaining qty
         l_remaining_qty := l_curr_job_qty - p_x_parts_rec.Installed_Quantity;
         create_similar_instance(
          p_source_instance_id => p_x_parts_rec.Installed_Instance_Id,
          p_dest_quantity      => l_remaining_qty,
          p_dest_wip_job_id    => l_wip_job_id,
          p_x_csi_transaction_rec => p_x_csi_transaction_rec,
          x_dest_instance_id   => l_dest_instance_id,
          x_return_status      =>  x_return_status
        );
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- update installed instance qty to equal to installed qty
        l_instance_rec.instance_id := p_x_parts_rec.Installed_Instance_Id;
        l_instance_rec.quantity := p_x_parts_rec.Installed_Quantity;

        OPEN csi_item_instance_csr(p_x_parts_rec.Installed_Instance_Id);
        FETCH csi_item_instance_csr INTO p_x_parts_rec.Installed_Instance_Num
                                         ,l_instance_rec.object_version_number;
        CLOSE csi_item_instance_csr;
        update_csi_item_instance(
            p_instance_rec        => l_instance_rec,
            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
            x_return_status      =>  x_return_status
        );
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     END IF;


     IF( l_serialized = FND_API.G_TRUE OR l_curr_config_qty = 0) THEN
       --Call install_existing_instance
       AHL_UC_INSTANCE_PVT.install_existing_instance(
        p_api_version           =>  1.0,
        p_init_msg_list         =>  FND_API.G_TRUE,
        p_commit                =>  FND_API.G_FALSE,
        p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
        x_return_status         =>  x_return_status,
        x_msg_count             =>  l_msg_count,
        x_msg_data              =>  l_msg_data,
        p_uc_header_id          =>  p_x_parts_rec.unit_config_header_id,
        p_parent_instance_id    =>  p_x_parts_rec.Parent_Installed_Instance_Id,
        p_instance_id           =>  p_x_parts_rec.Installed_Instance_Id,
        p_instance_number       =>  p_x_parts_rec.Installed_Instance_Num,
        p_relationship_id       =>  p_x_parts_rec.mc_relationship_id,
        p_csi_ii_ovn            =>  p_x_parts_rec.CSI_II_OBJECT_VERSION_NUM,
        p_prod_user_flag        =>  'Y',
        x_warning_msg_tbl       =>  x_warning_msg_tbl);

        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('After making a call to AHL_UC_INSTANCE_PVT.install_existing_instance.');
       END IF;
    ELSIF( l_serialized = FND_API.G_FALSE AND l_curr_config_qty <> 0) THEN
        AHL_UC_INSTANCE_PVT.remove_instance(
         p_api_version           =>  1.0,
         p_init_msg_list         =>  FND_API.G_TRUE,
         p_commit                =>  FND_API.G_FALSE,
         p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
         x_return_status         =>  x_return_status,
         x_msg_count             =>  l_msg_count,
         x_msg_data              =>  l_msg_data,
         p_uc_header_id          =>  p_x_parts_rec.unit_config_header_id,
         p_instance_id           =>  p_x_parts_rec.Removed_Instance_Id,
         p_csi_ii_ovn            =>  p_x_parts_rec.CSI_II_OBJECT_VERSION_NUM,
         p_prod_user_flag        =>  'Y');


        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        update_item_location(
                            p_x_parts_rec => p_x_parts_rec,
                            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
                            x_return_status => x_return_status);

        l_move_item_instance_tbl(1).instance_id := p_x_parts_rec.Removed_Instance_Id;
        l_move_item_instance_tbl(1).quantity := l_curr_config_qty;
        l_move_item_instance_tbl(1).to_workorder_id := p_x_parts_rec.workorder_id;
        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('moving it');
        END IF;
        move_instance_location(
              P_API_Version =>  1.0,
              P_Init_Msg_List => Fnd_API.G_False,
              P_Commit   => Fnd_API.G_False,
              P_Validation_Level  => Fnd_API.G_Valid_Level_Full,
              p_module_type => 'API',
              p_default     => FND_API.G_TRUE,
              p_move_item_instance_tbl => l_move_item_instance_tbl,
              x_return_status         =>  x_return_status,
              x_msg_count             =>  l_msg_count,
              x_msg_data              =>  l_msg_data);
         IF (x_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
         ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         -- create new instance with net qty on job
         l_remaining_qty := l_curr_job_qty - p_x_parts_rec.Installed_Quantity;

         OPEN removal_instance_id(p_x_parts_rec.Removed_Instance_Id, l_wip_job_id);
         FETCH removal_instance_id INTO l_final_removed_inst_id;
         IF(removal_instance_id%FOUND)THEN
           p_x_parts_rec.Removed_Instance_Id := l_final_removed_inst_id;
         END IF;
         CLOSE removal_instance_id;

         IF(l_remaining_qty > 0)THEN

           create_similar_instance(
            p_source_instance_id => p_x_parts_rec.Removed_Instance_Id,
            p_dest_quantity      => l_remaining_qty,
            p_dest_wip_job_id    => l_wip_job_id,
            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
            x_dest_instance_id   => l_dest_instance_id,
            x_return_status      =>  x_return_status
          );
          IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
          ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
        -- now install the previously removed instance back
        p_x_parts_rec.Installed_Instance_Id := p_x_parts_rec.Removed_Instance_Id;
        -- update installed instance qty to equal to net Config qty
        l_instance_rec.instance_id := p_x_parts_rec.Installed_Instance_Id;
        l_instance_rec.quantity := p_x_parts_rec.Installed_Quantity + l_curr_config_qty;

        OPEN csi_item_instance_csr(p_x_parts_rec.Installed_Instance_Id);
        FETCH csi_item_instance_csr INTO p_x_parts_rec.Installed_Instance_Num
                                         ,l_instance_rec.object_version_number;
        CLOSE csi_item_instance_csr;
        update_csi_item_instance(
            p_instance_rec        => l_instance_rec,
            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
            x_return_status      =>  x_return_status
        );
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- install the instance back
       AHL_UC_INSTANCE_PVT.install_existing_instance(
        p_api_version           =>  1.0,
        p_init_msg_list         =>  FND_API.G_TRUE,
        p_commit                =>  FND_API.G_FALSE,
        p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
        x_return_status         =>  x_return_status,
        x_msg_count             =>  l_msg_count,
        x_msg_data              =>  l_msg_data,
        p_uc_header_id          =>  p_x_parts_rec.unit_config_header_id,
        p_parent_instance_id    =>  p_x_parts_rec.Parent_Installed_Instance_Id,
        p_instance_id           =>  p_x_parts_rec.Installed_Instance_Id,
        p_instance_number       =>  p_x_parts_rec.Installed_Instance_Num,
        p_relationship_id       =>  p_x_parts_rec.mc_relationship_id,
        p_csi_ii_ovn            =>  p_x_parts_rec.CSI_II_OBJECT_VERSION_NUM,
        p_prod_user_flag        =>  'Y',
        x_warning_msg_tbl       =>  x_warning_msg_tbl);

        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('After making a call to AHL_UC_INSTANCE_PVT.install_existing_instance.');
       END IF;
    END IF;

  ELSIF (p_x_parts_rec.operation_type ='M') then

     IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('Before making a call to AHL_UC_INSTANCE_PVT.swap_instance.');
     END IF;
    --Call swap_instance
    AHL_UC_INSTANCE_PVT.swap_instance(
        p_api_version           =>  1.0,
        p_init_msg_list         =>  FND_API.G_TRUE,
        p_commit                =>  FND_API.G_FALSE,
        p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
        x_return_status         =>  x_return_status,
        x_msg_count             =>  l_msg_count,
        x_msg_data              =>  l_msg_data,
        p_uc_header_id          =>  p_x_parts_rec.unit_config_header_id,
        p_parent_instance_id    =>  p_x_parts_rec.Parent_Installed_Instance_Id,
        p_old_instance_id       =>  p_x_parts_rec.Removed_Instance_Id,
        p_new_instance_id       =>  p_x_parts_rec.Installed_Instance_Id,
        p_new_instance_number   =>  p_x_parts_rec.Installed_Instance_Num,
        p_relationship_id       =>  p_x_parts_rec.mc_relationship_id,
        p_csi_ii_ovn            =>  p_x_parts_rec.CSI_II_OBJECT_VERSION_NUM,
        p_prod_user_flag        =>  'Y',
        x_warning_msg_tbl       =>  x_warning_msg_tbl);

     IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('After making a call to AHL_UC_INSTANCE_PVT.swap_instance.');
     END IF;

     IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
     ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     update_item_location(
                            p_x_parts_rec => p_x_parts_rec,
                            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
                            x_return_status => x_return_status);

     IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
     ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     l_move_item_instance_tbl(1).instance_id := p_x_parts_rec.Removed_Instance_Id;
     l_move_item_instance_tbl(1).quantity := 1;
     l_move_item_instance_tbl(1).to_workorder_id := p_x_parts_rec.workorder_id;
     -- move removed item to work order's locator
     move_instance_location(
              P_API_Version =>  1.0,
              P_Init_Msg_List => Fnd_API.G_False,
              P_Commit   => Fnd_API.G_False,
              P_Validation_Level  => Fnd_API.G_Valid_Level_Full,
              p_module_type => 'API',
              p_default     => FND_API.G_TRUE,
              p_move_item_instance_tbl => l_move_item_instance_tbl,
              x_return_status         =>  x_return_status,
              x_msg_count             =>  l_msg_count,
              x_msg_data              =>  l_msg_data);
     IF (x_return_status = FND_API.G_RET_STS_ERROR) then
       RAISE FND_API.G_EXC_ERROR;
     ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  END IF;

  -- Get path position ID for Create and Swap operations.
  IF (p_x_parts_rec.operation_type ='C' OR p_x_parts_rec.operation_type = 'M') then

     -- find the path_position_id for the installed instance.
     AHL_MC_PATH_POSITION_PVT.Map_Instance_To_Pos_ID (
          p_api_version => 1.0,
          x_return_status => x_return_status,
          x_msg_count     => l_msg_count,
          x_msg_data      => l_msg_data,
          p_csi_item_instance_id => p_x_parts_rec.Installed_instance_id,
          x_path_position_id  => x_path_position_id);

     IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('p_x_parts_rec.Installed_Instance_Id ' ||p_x_parts_rec.Installed_Instance_Id);
        AHL_DEBUG_PUB.debug('After Install/swap AHL_UC_INSTANCE_PVT' || x_path_position_id);
     END IF;

     IF (x_return_status = FND_API.G_RET_STS_ERROR) then
        RAISE FND_API.G_EXC_ERROR;
     ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  END IF;


END Process_UC;


Procedure Process_IB(
                   p_x_csi_transaction_rec in out nocopy CSI_DATASTRUCTURES_PUB.transaction_rec,
                   p_x_parts_rec in out nocopy Ahl_Parts_Rec_type,
                   X_Return_Status  Out NOCOPY     Varchar2)
IS
--
  l_csi_relationship_tbl    CSI_DATASTRUCTURES_PUB.ii_relationship_tbl;
  l_csi_transaction_rec     CSI_DATASTRUCTURES_PUB.transaction_rec;

  l_csi_relationship_rec    CSI_DATASTRUCTURES_PUB.ii_relationship_rec;
  l_instance_id_lst         CSI_DATASTRUCTURES_PUB.id_tbl;
  l_unit_config_header_name varchar2(80):= null;
  l_msg_count number;
  l_msg_data varchar2(2000);

  -- Parameters to call Update_Item_Instance.
  l_instance_rec             csi_datastructures_pub.instance_rec;
  l_extend_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
  l_party_tbl                csi_datastructures_pub.party_tbl;
  l_account_tbl              csi_datastructures_pub.party_account_tbl;

  l_pricing_attrib_tbl       csi_datastructures_pub.pricing_attribs_tbl;
  l_org_assignments_tbl      csi_datastructures_pub.organization_units_tbl;
  l_asset_assignment_tbl     csi_datastructures_pub.instance_asset_tbl;

  CURSOR check_inst_nonserial(p_instance_id IN NUMBER) IS
    SELECT 'X'
    FROM mtl_system_items_b mtl, csi_item_instances csi
    WHERE csi.instance_id = p_instance_id
    AND csi.inventory_item_id = mtl.inventory_item_id
    AND NVL(csi.inv_organization_id, csi.inv_master_organization_id) = mtl.organization_id
    AND mtl.serial_number_control_code = 1;

  l_junk VARCHAR2(1);
  l_serialized VARCHAR2(1);
  l_move_item_instance_tbl move_item_instance_tbl_type;

  CURSOR get_curr_quantity_csr(p_instance_id IN NUMBER) IS
  SELECT QUANTITY from csi_item_instances
  WHERE INSTANCE_ID = p_instance_id;

  l_curr_config_qty NUMBER;
  l_curr_job_qty NUMBER;
  l_dest_instance_id NUMBER;
  l_remaining_qty NUMBER;



  CURSOR csi_item_instance_csr(p_instance_id IN NUMBER) IS
  select instance_number,object_Version_number
  from csi_item_instances CII
  where CII.instance_id = p_instance_id;

  CURSOR get_wip_job_csr(p_workorder_id IN NUMBER) IS
  select wip_entity_id from ahl_workorders
  where workorder_id = p_workorder_id;
  l_wip_job_id NUMBER;

  CURSOR removal_instance_id(p_instance_id IN NUMBER, p_wip_job_id IN NUMBER) IS
  SELECT C1.instance_id FROM CSI_ITEM_INSTANCES C1, CSI_ITEM_INSTANCES C2
  WHERE C1.INV_MASTER_ORGANIZATION_ID= C2.INV_MASTER_ORGANIZATION_ID
  AND C1.INVENTORY_ITEM_ID = C2.INVENTORY_ITEM_ID
  AND NVL(C1.INVENTORY_REVISION,'x') = NVL(C2.INVENTORY_REVISION,'x')
  AND NVL(C1.LOT_NUMBER,'x') = NVL(C2.LOT_NUMBER,'x')
  AND C1.WIP_JOB_ID= p_wip_job_id
  AND C1.unit_of_measure = C2.unit_of_measure
  AND C2.instance_id = p_instance_id
  AND C1.quantity > 0
  AND C1.ACTIVE_START_DATE <= SYSDATE
  AND ((C1.ACTIVE_END_DATE IS NULL) OR (C1.ACTIVE_END_DATE > SYSDATE));

  l_final_removed_inst_id NUMBER;


BEGIN

  OPEN get_wip_job_csr(p_x_parts_rec.workorder_id);
  FETCH get_wip_job_csr INTO l_wip_job_id;
  CLOSE get_wip_job_csr;

  -- If operation type = M or C then update installation date.
  IF (p_x_parts_rec.operation_type = 'M' )--OR p_x_parts_rec.operation_type = 'C')
  THEN

       l_instance_rec.INSTANCE_ID := p_x_parts_rec.Installed_instance_id;

       l_instance_rec.Install_Date := p_x_parts_rec.Installation_Date;
       l_instance_rec.OBJECT_VERSION_NUMBER  := p_x_parts_rec.Installed_instance_obj_ver_num;

       CSI_ITEM_INSTANCE_PUB. update_item_instance (
                                             p_api_version =>1.0
                                            ,p_commit => fnd_api.g_false
                                            ,p_init_msg_list => fnd_api.g_false
                                            ,p_validation_level  => fnd_api.g_valid_level_full
                                            ,p_instance_rec => l_instance_rec
                                            ,p_ext_attrib_values_tbl=>l_extend_attrib_values_tbl
                                            ,p_party_tbl    =>l_party_tbl
                                            ,p_account_tbl => l_account_tbl
                                            ,p_pricing_attrib_tbl => l_pricing_attrib_tbl
                                            ,p_org_assignments_tbl   => l_org_assignments_tbl
                                            ,p_asset_assignment_tbl  => l_asset_assignment_tbl
                                            ,p_txn_rec  => p_x_csi_transaction_rec
                                            ,x_instance_id_lst  => l_instance_id_lst
                                            ,x_return_status => x_return_status
                                            ,x_msg_count => l_msg_count
                                            ,x_msg_data  => l_msg_data );
  END IF;

  -- Build csi relationship rec.
  l_csi_relationship_rec.relationship_type_code := 'COMPONENT-OF';
  l_csi_relationship_rec.object_id :=  p_x_parts_rec.Parent_Installed_Instance_Id;
  l_csi_relationship_rec.subject_id := p_x_parts_rec.Installed_Instance_Id;
  l_csi_relationship_rec.relationship_id := p_x_parts_rec.csi_ii_relationship_id;
  l_csi_relationship_rec.object_version_number := p_x_parts_rec.CSI_II_Object_Version_Num;

  l_csi_relationship_tbl(1) := l_csi_relationship_rec;

  --Installing
  IF (p_x_parts_rec.operation_type = 'C' ) then

     IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('IB Processing- Create');
     END IF;

     l_serialized := FND_API.G_FALSE;
     OPEN check_inst_nonserial(p_x_parts_rec.Installed_Instance_Id);
     FETCH check_inst_nonserial INTO l_junk;
     IF(check_inst_nonserial%NOTFOUND)THEN
        l_serialized := FND_API.G_TRUE;
     END IF;
     CLOSE check_inst_nonserial;

     IF( l_serialized = FND_API.G_FALSE AND p_x_parts_rec.Installed_Instance_Id IS NOT NULL) THEN
       OPEN get_curr_quantity_csr(p_x_parts_rec.Installed_Instance_Id);
       FETCH get_curr_quantity_csr INTO l_curr_job_qty;
       CLOSE get_curr_quantity_csr;
     END IF;

     IF( l_serialized = FND_API.G_FALSE
         AND l_curr_job_qty <> p_x_parts_rec.Installed_Quantity)THEN
         -- create new instance with remaining qty
         l_remaining_qty := l_curr_job_qty - p_x_parts_rec.Installed_Quantity;
         create_similar_instance(
          p_source_instance_id => p_x_parts_rec.Installed_Instance_Id,
          p_dest_quantity      => l_remaining_qty,
          p_dest_wip_job_id    => l_wip_job_id,
          p_x_csi_transaction_rec => p_x_csi_transaction_rec,
          x_dest_instance_id   => l_dest_instance_id,
          x_return_status      =>  x_return_status
        );
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('Sunil 1 p_x_parts_rec.Installed_Instance_Id :  ' || p_x_parts_rec.Installed_Instance_Id);
          AHL_DEBUG_PUB.debug('Sunil  p_x_parts_rec.Installed_Quantity ' || p_x_parts_rec.Installed_Quantity);
        END IF;
        -- update installed instance qty to equal to installed qty
        l_instance_rec.instance_id := p_x_parts_rec.Installed_Instance_Id;
        l_instance_rec.quantity := p_x_parts_rec.Installed_Quantity;
        l_instance_rec.Install_Date := p_x_parts_rec.Installation_Date;

        OPEN csi_item_instance_csr(p_x_parts_rec.Installed_Instance_Id);
        FETCH csi_item_instance_csr INTO p_x_parts_rec.Installed_Instance_Num
                                         ,l_instance_rec.object_version_number;
        CLOSE csi_item_instance_csr;
        update_csi_item_instance(
            p_instance_rec        => l_instance_rec,
            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
            x_return_status      =>  x_return_status
        );
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_instance_rec.instance_id := NULL;
        l_instance_rec.quantity := NULL;
        l_instance_rec.Install_Date := NULL;
        l_instance_rec.object_version_number := NULL;

        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('Sunil : Updated installed instance qty to :  ' || p_x_parts_rec.Installed_Quantity);

        END IF;
     END IF;

     IF( l_serialized = FND_API.G_TRUE OR p_x_parts_rec.Removed_Instance_Id IS NULL)THEN
       csi_ii_relationships_pub.create_relationship(
                                                p_api_version => 1.0
                                                ,p_relationship_tbl => l_csi_relationship_tbl
                                                ,p_txn_rec => p_x_csi_transaction_rec
                                                ,x_return_status => x_return_status
                                                ,x_msg_count => l_msg_count
                                                ,x_msg_data  => l_msg_data);
     ELSIF ( l_serialized = FND_API.G_FALSE AND p_x_parts_rec.Removed_Instance_Id IS NOT NULL)THEN

        -- update qty for wo to 0
        l_instance_rec.instance_id := p_x_parts_rec.Installed_Instance_Id;
        l_instance_rec.quantity := 0 ;
        --l_instance_rec.ACTIVE_END_DATE := SYSDATE;

        OPEN csi_item_instance_csr(p_x_parts_rec.Installed_Instance_Id);
        FETCH csi_item_instance_csr INTO p_x_parts_rec.Installed_Instance_Num
                                         ,l_instance_rec.object_version_number;
        CLOSE csi_item_instance_csr;
        update_csi_item_instance(
            p_instance_rec        => l_instance_rec,
            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
            x_return_status      =>  x_return_status
        );


        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_instance_rec.instance_id := NULL;
        l_instance_rec.quantity := NULL;
        l_instance_rec.ACTIVE_END_DATE := NULL;
        l_instance_rec.object_version_number := NULL;


        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('Sunil : Updated fake installed instance qty to :  0 ');
        END IF;

        OPEN get_curr_quantity_csr(p_x_parts_rec.Removed_Instance_Id);
        FETCH get_curr_quantity_csr INTO l_curr_config_qty;
        CLOSE get_curr_quantity_csr;
        -- up config qty
        p_x_parts_rec.Installed_Instance_Id := p_x_parts_rec.Removed_Instance_Id;
        l_instance_rec.instance_id := p_x_parts_rec.Installed_Instance_Id;
        l_instance_rec.quantity := l_curr_config_qty + p_x_parts_rec.Installed_Quantity;
        l_instance_rec.Install_Date := p_x_parts_rec.Installation_Date;


        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('Sunil2 : p_x_parts_rec.Removed_Instance_Id  : ' || p_x_parts_rec.Removed_Instance_Id);
          AHL_DEBUG_PUB.debug('Sunil2 : net config qty  : ' || l_instance_rec.quantity);
        END IF;

        OPEN csi_item_instance_csr(p_x_parts_rec.Installed_Instance_Id);
        FETCH csi_item_instance_csr INTO p_x_parts_rec.Installed_Instance_Num
                                         ,l_instance_rec.object_version_number;
        CLOSE csi_item_instance_csr;
        update_csi_item_instance(
            p_instance_rec        => l_instance_rec,
            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
            x_return_status      =>  x_return_status
        );

        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('Sunil : Updated qty on config to  : ' || l_instance_rec.quantity);
        END IF;

        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_instance_rec.instance_id := NULL;
        l_instance_rec.quantity := NULL;
        l_instance_rec.Install_Date := NULL;
        l_instance_rec.object_version_number := NULL;

        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('Sunil : completed partial install : ');
        END IF;


      END IF;

  -- Removing a part
  ELSIF (p_x_parts_rec.operation_type = 'D' ) then
     -- dbms_output.put_line('IB processing- remove');
     IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('IB Processing- Remove');
     END IF;
     --Test that the part removed is ib config indeed
     l_unit_config_header_name:= AHL_UMP_UTIL_PKG.get_UnitName(p_x_parts_rec.removed_instance_id);


     IF (l_unit_config_header_name is not null ) then
         FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_RMV_PRT_INVALID');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     l_serialized := FND_API.G_FALSE;
     OPEN check_inst_nonserial(p_x_parts_rec.Removed_Instance_Id);
     FETCH check_inst_nonserial INTO l_junk;
     IF(check_inst_nonserial%NOTFOUND)THEN
        l_serialized := FND_API.G_TRUE;
     END IF;
     CLOSE check_inst_nonserial;

     IF( l_serialized = FND_API.G_FALSE) THEN
       OPEN get_curr_quantity_csr(p_x_parts_rec.Removed_Instance_Id);
       FETCH get_curr_quantity_csr INTO l_curr_config_qty;
       CLOSE get_curr_quantity_csr;
     END IF;

     IF( l_serialized = FND_API.G_TRUE OR p_x_parts_rec.Removed_Quantity = l_curr_config_qty)THEN

        csi_ii_relationships_pub.expire_relationship(
                                                p_api_version => 1.0
                                                ,p_relationship_rec => l_csi_relationship_rec
                                                ,p_txn_rec => p_x_csi_transaction_rec
                                                ,x_instance_id_lst=> l_instance_id_lst-- csi_datastructures_pub.id_tbl,
                                                ,x_return_status => x_return_status
                                                ,x_msg_count => l_msg_count
                                                ,x_msg_data  => l_msg_data );
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        update_item_location(
                            p_x_parts_rec => p_x_parts_rec,
                            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
                            x_return_status => x_return_status);
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        l_move_item_instance_tbl(1).instance_id := p_x_parts_rec.Removed_Instance_Id;
        l_move_item_instance_tbl(1).quantity := p_x_parts_rec.Removed_Quantity;
        l_move_item_instance_tbl(1).to_workorder_id := p_x_parts_rec.workorder_id;

        move_instance_location(
              P_API_Version =>  1.0,
              P_Init_Msg_List => Fnd_API.G_False,
              P_Commit   => Fnd_API.G_False,
              P_Validation_Level  => Fnd_API.G_Valid_Level_Full,
              p_module_type => 'API',
              p_default     => FND_API.G_TRUE,
              p_move_item_instance_tbl => l_move_item_instance_tbl,
              x_return_status         =>  x_return_status,
              x_msg_count             =>  l_msg_count,
              x_msg_data              =>  l_msg_data);
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF( l_serialized = FND_API.G_FALSE)THEN
          OPEN removal_instance_id(p_x_parts_rec.Removed_Instance_Id, l_wip_job_id);
          FETCH removal_instance_id INTO l_final_removed_inst_id;
          IF(removal_instance_id%FOUND)THEN
             p_x_parts_rec.Removed_Instance_Id := l_final_removed_inst_id;
          END IF;
          CLOSE removal_instance_id;
        END IF;
        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('1 final p_x_parts_rec.Removed_Instance_Id ' || p_x_parts_rec.Removed_Instance_Id);
          AHL_DEBUG_PUB.debug('l_final_removed_inst_id ' || l_final_removed_inst_id);
        END IF;
    ELSE -- non-serialized incomplete removal

        csi_ii_relationships_pub.expire_relationship(
                                                p_api_version => 1.0
                                                ,p_relationship_rec => l_csi_relationship_rec
                                                ,p_txn_rec => p_x_csi_transaction_rec
                                                ,x_instance_id_lst=> l_instance_id_lst-- csi_datastructures_pub.id_tbl,
                                                ,x_return_status => x_return_status
                                                ,x_msg_count => l_msg_count
                                                ,x_msg_data  => l_msg_data );
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        update_item_location(
                            p_x_parts_rec => p_x_parts_rec,
                            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
                            x_return_status => x_return_status);

        l_remaining_qty := l_curr_config_qty - p_x_parts_rec.Removed_Quantity;
        -- update configuration instance with net quantity
        l_instance_rec.instance_id := p_x_parts_rec.Removed_Instance_Id;
        l_instance_rec.quantity := l_remaining_qty;
        OPEN csi_item_instance_csr(p_x_parts_rec.Removed_Instance_Id);
        FETCH csi_item_instance_csr INTO p_x_parts_rec.Removed_Instance_Num
                                         ,l_instance_rec.object_version_number;
        CLOSE csi_item_instance_csr;

        update_csi_item_instance(
            p_instance_rec        => l_instance_rec,
            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
            x_return_status      =>  x_return_status
        );

        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        l_instance_rec.instance_id := NULL;
        l_instance_rec.quantity := NULL;
        l_instance_rec.object_version_number := NULL;
        --create same instance with removed qty
        create_similar_instance(
          p_source_instance_id => p_x_parts_rec.Removed_Instance_Id,
          p_dest_quantity      => p_x_parts_rec.Removed_Quantity,
          p_dest_wip_job_id    => l_wip_job_id,
          p_x_csi_transaction_rec => p_x_csi_transaction_rec,
          x_dest_instance_id   => l_dest_instance_id,
          x_return_status      =>  x_return_status
        );
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        l_csi_relationship_rec.relationship_type_code := 'COMPONENT-OF';
        l_csi_relationship_rec.object_id :=  p_x_parts_rec.Parent_Installed_Instance_Id;
        l_csi_relationship_rec.subject_id := p_x_parts_rec.Removed_Instance_Id;
        l_csi_relationship_rec.relationship_id := NULL;
        l_csi_relationship_rec.object_version_number := NULL;

        l_csi_relationship_tbl(1) := l_csi_relationship_rec;

        csi_ii_relationships_pub.create_relationship(
                                                p_api_version => 1.0
                                                ,p_relationship_tbl => l_csi_relationship_tbl
                                                ,p_txn_rec => p_x_csi_transaction_rec
                                                ,x_return_status => x_return_status
                                                ,x_msg_count => l_msg_count
                                                ,x_msg_data  => l_msg_data);

       IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('After making a call to csi_ii_relationships_pub.create_relationship.');
       END IF;

       IF (x_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

        p_x_parts_rec.Removed_Instance_Id := l_dest_instance_id;
         IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('update_item_location :: ' ||l_dest_instance_id);
       END IF;
        /*update_item_location(
                            p_x_parts_rec => p_x_parts_rec,
                            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
                            x_return_status => x_return_status);
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
           RAISE FND_API.G_EXC_ERROR;
        END IF;*/

        l_move_item_instance_tbl(1).instance_id := p_x_parts_rec.Removed_Instance_Id;
        l_move_item_instance_tbl(1).quantity := p_x_parts_rec.Removed_Quantity;
        l_move_item_instance_tbl(1).to_workorder_id := p_x_parts_rec.workorder_id;
        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('moving it');
       END IF;
        move_instance_location(
              P_API_Version =>  1.0,
              P_Init_Msg_List => Fnd_API.G_False,
              P_Commit   => Fnd_API.G_False,
              P_Validation_Level  => Fnd_API.G_Valid_Level_Full,
              p_module_type => 'API',
              p_default     => FND_API.G_TRUE,
              p_move_item_instance_tbl => l_move_item_instance_tbl,
              x_return_status         =>  x_return_status,
              x_msg_count             =>  l_msg_count,
              x_msg_data              =>  l_msg_data);
        IF (x_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        OPEN removal_instance_id(p_x_parts_rec.Removed_Instance_Id, l_wip_job_id);
        FETCH removal_instance_id INTO l_final_removed_inst_id;
        IF(removal_instance_id%FOUND)THEN
           p_x_parts_rec.Removed_Instance_Id := l_final_removed_inst_id;
        END IF;
        CLOSE removal_instance_id;
        --p_x_parts_rec.Removed_Instance_Id := 274689;
        IF G_DEBUG = 'Y' THEN
          AHL_DEBUG_PUB.debug('2 final p_x_parts_rec.Removed_Instance_Id ' || p_x_parts_rec.Removed_Instance_Id);
          AHL_DEBUG_PUB.debug('l_final_removed_inst_id ' || l_final_removed_inst_id);
        END IF;

     END IF;

  --Swapping a part
  ELSIF (p_x_parts_rec.operation_type = 'M' ) then
     --Test that the part removed is ib config indeed
     l_unit_config_header_name:= AHL_UMP_UTIL_PKG.get_UnitName(p_x_parts_rec.removed_instance_id);

     IF (l_unit_config_header_name is not null ) then
         FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_RMV_PRT_INVALID');
         FND_MSG_PUB.ADD;
         --RAISE FND_API.G_EXC_ERROR;
     end if;
     IF G_DEBUG = 'Y' THEN
        AHL_DEBUG_PUB.debug('IB Processing- Swap');
     END IF;
     csi_ii_relationships_pub.update_relationship(
                                                p_api_version => 1.0
                                                ,p_relationship_tbl => l_csi_relationship_tbl

                                                ,p_txn_rec => p_x_csi_transaction_rec

                                                ,x_return_status => x_return_status

                                                ,x_msg_count => l_msg_count
                                                ,x_msg_data  => l_msg_data);
    l_move_item_instance_tbl(1).instance_id := p_x_parts_rec.Removed_Instance_Id;
    l_move_item_instance_tbl(1).quantity := p_x_parts_rec.Removed_Quantity;
    l_move_item_instance_tbl(1).to_workorder_id := p_x_parts_rec.workorder_id;
    IF G_DEBUG = 'Y' THEN
       AHL_DEBUG_PUB.debug('moving it');
    END IF;

    update_item_location(
                            p_x_parts_rec => p_x_parts_rec,
                            p_x_csi_transaction_rec => p_x_csi_transaction_rec,
                            x_return_status => x_return_status);

     IF (x_return_status = FND_API.G_RET_STS_ERROR) then
            RAISE FND_API.G_EXC_ERROR;
     ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    move_instance_location(
              P_API_Version =>  1.0,
              P_Init_Msg_List => Fnd_API.G_False,
              P_Commit   => Fnd_API.G_False,
              P_Validation_Level  => Fnd_API.G_Valid_Level_Full,
              p_module_type => 'API',
              p_default     => FND_API.G_TRUE,
              p_move_item_instance_tbl => l_move_item_instance_tbl,
              x_return_status         =>  x_return_status,
              x_msg_count             =>  l_msg_count,
              x_msg_data              =>  l_msg_data);
    IF (x_return_status = FND_API.G_RET_STS_ERROR) then
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  end if;

END Process_IB;

Procedure Update_item_location(p_x_parts_rec IN out nocopy  ahl_parts_rec_type,
 p_x_csi_transaction_rec IN out nocopy  CSI_DATASTRUCTURES_PUB.transaction_rec,

                               X_Return_Status  Out NOCOPY     Varchar2)
IS
--
  l_wip_entity_type          number;
  l_wip_entity_id            number;
  l_instance_rec             csi_datastructures_pub.instance_rec;
  l_extend_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
  l_party_tbl                csi_datastructures_pub.party_tbl;
  l_account_tbl              csi_datastructures_pub.party_account_tbl;
  l_pricing_attrib_tbl       csi_datastructures_pub.pricing_attribs_tbl;
  l_org_assignments_tbl      csi_datastructures_pub.organization_units_tbl;
  l_asset_assignment_tbl     csi_datastructures_pub.instance_asset_tbl;
  l_instance_id_lst          csi_datastructures_pub.id_tbl;
  l_msg_count                number;
  l_msg_data                 varchar2(2000);

  -- For wip_entity_id for the workorder
  CURSOR ahl_wip_entity_csr(p_wo_id in Number) IS
    Select AHL.wip_entity_id, WIP.entity_type
    --FROM ahl_workorders_v AHL, wip_entities WIP
    FROM ahl_search_workorders_v AHL, wip_entities WIP
    WHERE AHL.workorder_id = p_wo_id
       and WIP.wip_entity_id = AHL.wip_entity_id;

  --For the updated object_version number from csi_item_isntances
  CURSOR ahl_obj_ver_csr(p_instance_id in Number) IS
     select object_Version_number
     from csi_item_instances
     where instance_id = p_instance_id;

  --to populate csi_transaction record
  CURSOR ahl_wip_location_csr IS
     select wip_location_id
     from csi_install_parameters ;

BEGIN

  -- get wip_entity_id, wip_entity_type for the workorder
  -- dbms_output.put_line('Calling update_removed item- ahl_wp_entity_csr');
  OPEN ahl_wip_entity_csr(p_x_parts_rec.workorder_id);
  FETCH ahl_wip_entity_csr INTO l_wip_entity_id,l_wip_entity_type;
  IF (ahl_wip_entity_csr%NOTFOUND) THEN
     CLOSE ahl_wip_entity_csr;
     FND_MESSAGE.Set_Name('AHL','AHL_PRD_WIP_ENTITY_MISSING');
     FND_MESSAGE.Set_Token('WOID',p_x_parts_rec.workorder_id);
     FND_MSG_PUB.ADD;
  else
     CLOSE ahl_wip_entity_csr;
  END IF;

  --get the updated object_version number from csi_item_isntances
  OPEN ahl_obj_ver_csr(p_x_parts_rec.removed_instance_id);
  FETCH ahl_obj_ver_csr INTO p_x_parts_rec.removed_instance_obj_ver_num;
  IF (ahl_obj_ver_csr%NOTFOUND) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_PRD_REMOVED_INSTANCE_INVALID');
      FND_MESSAGE.Set_Token('INST',p_x_parts_rec.removed_instance_id);
      FND_MSG_PUB.ADD;
      CLOSE ahl_obj_ver_csr;
  else
      CLOSE ahl_obj_ver_csr;

  END IF;

  -- populate l_instance_rec
  l_instance_rec.INSTANCE_ID := p_x_parts_rec.removed_instance_id;
  l_instance_rec.LOCATION_TYPE_CODE  := 'WIP';
  l_instance_rec.WIP_JOB_ID  := l_wip_entity_id;
  l_instance_rec.OBJECT_VERSION_NUMBER    := p_x_parts_rec.removed_instance_obj_ver_num;
  l_instance_rec.instance_usage_code := 'IN_WIP';


  --get location id
  OPEN  ahl_wip_location_csr();
  FETCH  ahl_wip_location_csr INTO l_instance_rec.LOCATION_ID ;
  CLOSE ahl_wip_location_csr;

  CSI_ITEM_INSTANCE_PUB. update_item_instance (
                                            p_api_version =>1.0
                                            ,p_commit => fnd_api.g_false
                                            ,p_init_msg_list => fnd_api.g_false
                                            ,p_validation_level  => fnd_api.g_valid_level_full
                                            ,p_instance_rec => l_instance_rec
                                            ,p_ext_attrib_values_tbl=>l_extend_attrib_values_tbl
                                            ,p_party_tbl    =>l_party_tbl
                                            ,p_account_tbl => l_account_tbl
                                            ,p_pricing_attrib_tbl => l_pricing_attrib_tbl
                                            ,p_org_assignments_tbl   => l_org_assignments_tbl
                                            ,p_asset_assignment_tbl  => l_asset_assignment_tbl
                                            ,p_txn_rec  => p_x_csi_transaction_rec
                                            ,x_instance_id_lst  => l_instance_id_lst
                                            ,x_return_status => x_return_status
                                            ,x_msg_count => l_msg_count
                                            ,x_msg_data  => l_msg_data );

   END Update_item_location;

--
 Procedure Process_material_txn(
                             p_x_parts_rec in out nocopy Ahl_parts_rec_type,
                             p_module_type in            Varchar2,
                             X_Return_Status  Out NOCOPY     Varchar2)
 IS
--
  l_mtl_txn_tbl        AHL_PRD_MTLTXN_PVT.Ahl_Mtltxn_Tbl_Type;
  x_ahl_mtl_txn_id_tbl AHL_PRD_MTLTXN_PVT.Ahl_Mtl_Txn_Id_tbl;
  l_inventory_item_id  number;
  l_organization_id    number;
  L_revision           varchar2(3);
  l_quantity           number;
  l_uom                varchar2(3);
  --L_wip_entity_id    number;
  l_serial_number      varchar2(30);
  l_lot_number         mtl_lot_numbers.lot_number%TYPE;
  l_msg_count          number;
  l_msg_data           varchar2(2000);

--
  -- For MTL api
  CURSOR ahl_mtl_txn_param_csr (p_wo_id in number, p_instance_id number) is
      SELECT CSI.INVENTORY_ITEM_ID, AHL.organization_id
        , CSI.inventory_revision revision, CSI.quantity, CSI.unit_of_measure,
        CSI.serial_number, CSI.lot_number
      --FROM ahl_workorders_v AHL, csi_item_instances CSI
      FROM ahl_workorder_tasks_v AHL, csi_item_instances CSI
      Where CSI.instance_id = p_instance_id
         --and csi.inv_organization_id = ahl.organization_id
         And AHL.workorder_id = p_wo_id;
BEGIN
  -- dbms_output.put_line('inside material transaction');
  --Derive parameters to be passed to the API.
  OPEN ahl_mtl_txn_param_csr(p_x_parts_rec.workorder_id, p_x_parts_rec.removed_instance_id);

  FETCH ahl_mtl_txn_param_csr INTO l_inventory_item_id, l_organization_id,
                                   L_revision, l_quantity, l_uom,
                                   l_serial_number, l_lot_number;
  IF (ahl_mtl_txn_param_csr%NOTFOUND) THEN
    CLOSE ahl_mtl_txn_param_csr;
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_INST_DATA_MISSING');
    FND_MESSAGE.Set_Token('WOID',p_x_parts_rec.workorder_id);
    FND_MSG_PUB.ADD;
  ELSE
    CLOSE ahl_mtl_txn_param_csr;
  END IF;

  --Get wip_entity_type
  l_mtl_txn_tbl(1).Workorder_id	:= p_x_parts_rec. workorder_id;
  -- dbms_output.put_line('workorder '||l_mtl_txn_tbl(1).Workorder_id);

  l_mtl_txn_tbl(1).Operation_Seq_Num := p_x_parts_rec.Operation_Sequence_Num;
  -- dbms_output.put_line('Operation_Seq_Num '||l_mtl_txn_tbl(1).Operation_Seq_Num);


  l_mtl_txn_tbl(1).INVENTORY_ITEM_ID	:= L_inventory_item_id;
  -- dbms_output.put_line('INVENTORY_ITEM_ID '||l_mtl_txn_tbl(1).INVENTORY_ITEM_ID);

                     l_mtl_txn_tbl(1).REVISION :=	L_revision;
                      -- dbms_output.put_line('REVISION '||l_mtl_txn_tbl(1).REVISION);
                     l_mtl_txn_tbl(1).ORGANIZATION_ID:=	L_organization_id;
                         -- dbms_output.put_line('ORGANIZATION_ID '||l_mtl_txn_tbl(1).ORGANIZATION_ID);
                     --l_mtl_txn_tbl(1).CONDITION	:= p_x_parts_rec.condition_id;
                      -- dbms_output.put_line('CONDITION '||l_mtl_txn_tbl(1).CONDITION);

                     --l_mtl_txn_tbl(1).SUBINVENTORY_NAME	:= p_x_parts_rec.subinventory_code;

                       -- dbms_output.put_line('SUBINVENTORY_NAME '||l_mtl_txn_tbl(1).SUBINVENTORY_NAME);

                     --l_mtl_txn_tbl(1).LOCATOR_ID :=p_x_parts_rec.locator_id;
                       -- dbms_output.put_line('LOCATOR_ID '||l_mtl_txn_tbl(1).LOCATOR_ID);

                     --l_mtl_txn_tbl(1).LOCATOR_segments :=p_x_parts_rec.locator_code;
                     -- dbms_output.put_line('LOCATOR_SEGMENTS '||l_mtl_txn_tbl(1).LOCATOR_SEGMENTS);

                     l_mtl_txn_tbl(1).QUANTITY	:= L_quantity;
                       -- dbms_output.put_line('QUANTITY '||l_mtl_txn_tbl(1).QUANTITY);

                     l_mtl_txn_tbl(1).UOM	:= L_uom;
                         -- dbms_output.put_line('UOM '||l_mtl_txn_tbl(1).UOM);
                     l_mtl_txn_tbl(1).TRANSACTION_TYPE_ID:= WIP_CONSTANTS.RETCOMP_TYPE;
                        -- dbms_output.put_line('TRANSACTION_TYPE_ID '||l_mtl_txn_tbl(1).TRANSACTION_TYPE_ID);

                     l_mtl_txn_tbl(1).TRANSACTION_REFERENCE	:= null;
                     l_mtl_txn_tbl(1).SERIAL_NUMBER	:= L_serial_number;
                            -- dbms_output.put_line('SERIAL_NUMBER '||l_mtl_txn_tbl(1).SERIAL_NUMBER);

                     l_mtl_txn_tbl(1).LOT_NUMBER :=	L_lot_number;
                       -- dbms_output.put_line('LOT_NUMBER '||l_mtl_txn_tbl(1).LOT_NUMBER);


                     --l_mtl_txn_tbl(1).PROBLEM_CODE:=	p_x_parts_rec.problem_code;
                       -- dbms_output.put_line('PROBLEM_CODE '||l_mtl_txn_tbl(1).PROBLEM_CODE);

                    -- l_mtl_txn_tbl(1).TARGET_VISIT_ID:= p_x_parts_rec.target_visit_id;
                      -- dbms_output.put_line('TARGET_VISIT_ID '||l_mtl_txn_tbl(1).TARGET_VISIT_ID);

                     --l_mtl_txn_tbl(1).SR_SUMMARY :=	p_x_parts_rec.summary;
                     -- dbms_output.put_line('SR_SUMMARY '||l_mtl_txn_tbl(1).SR_SUMMARY);

                     --l_mtl_txn_tbl(1).Qa_Collection_Id := p_x_parts_rec.collection_id;
		     l_mtl_txn_tbl(1).Reason_Id := p_x_parts_rec.removal_reason_id;

                        AHL_PRD_MTLTXN_PVT.PERFORM_MTL_TXN
		                              (p_api_version => 1.0,
  		                               p_module_type => null,--sending null because I am calling it internally
                                               p_create_sr => 'N',
                                               p_x_ahl_mtltxn_tbl=> l_mtl_txn_tbl,
  		                               x_return_status => x_return_status,
  		                               x_msg_count=> l_msg_count,
  		                               x_msg_data => l_msg_data );

                       --IF (x_return_status =  FND_API.G_RET_STS_SUCCESS) then
                       --     p_x_parts_rec.Material_txn_id :=  l_mtl_txn_tbl(1). Ahl_mtltxn_Id;
                       --END IF;
   END Process_material_txn;

/*
-- Service request processing
Procedure Process_SR(
                   p_x_parts_rec_tbl In Out Nocopy Ahl_parts_tbl_type,
                   p_module_type     In            Varchar2,
                   X_Return_Status  Out NOCOPY     Varchar2)
IS
  l_sr_task_tbl AHL_PRD_NONROUTINE_PVT.sr_task_tbl_type;
  l_msg_count number;
  l_msg_data varchar2(2000);

BEGIN

  -- Loop through the table record and form table list to call SR API.
  IF ( p_x_parts_rec_tbl.COUNT > 0) THEN
    FOR i IN p_x_parts_rec_tbl.FIRST..p_x_parts_rec_tbl.LAST LOOP

      ---********* Call SR if part condition is unserviceable *********** ------
      IF ((p_x_parts_rec_tbl(i).operation_type='D' or p_x_parts_rec_tbl(i).operation_type='M') AND
         ((fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE') is not null AND
           p_x_parts_rec_tbl(i).Condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_UNSERVICABLE'))
        OR ( fnd_profile.value('AHL_MTL_MAT_STATUS_MRB') is not null and
             p_x_parts_rec_tbl(i).Condition_id = fnd_profile.value('AHL_MTL_MAT_STATUS_MRB'))))
      THEN
        --Summary is mandatory for SR API
        IF (p_x_parts_rec_tbl(i).summary is null) then
             Fnd_Message.SET_NAME('AHL','AHL_PRD_NRJ_SUMMARY_REQ');
             FND_MSG_PUB.ADD;
        END IF;

        -- Populate sr_task_tbl
            l_sr_task_tbl(i).Request_date:= sysdate;
            l_sr_task_tbl(i).Summary := p_x_parts_rec_tbl(i).summary;
            -- dbms_output.put_line('SR- summary '|| p_x_parts_rec_tbl(i).summary);

            l_sr_task_tbl(i).Instance_id:=	p_x_Parts_rec_tbl(i).removed_instance_id;
              -- dbms_output.put_line('SR- Instance_id '|| p_x_Parts_rec_tbl(i).removed_instance_id);

            l_sr_task_tbl(i).Instance_number:=	p_x_Parts_rec_tbl(i).removed_instance_num;
            -- dbms_output.put_line('SR- Instance_num '|| p_x_Parts_rec_tbl(i).removed_instance_num);


            l_sr_task_tbl(i).Problem_code := p_x_parts_rec_tbl(i).problem_code;
            -- dbms_output.put_line('SR- Problem_code '|| p_x_Parts_rec_tbl(i).Problem_code);

            l_sr_task_tbl(i).Problem_meaning := p_x_Parts_rec_tbl(i).problem_meaning;
            -- dbms_output.put_line('SR- Problem_meaning '|| p_x_Parts_rec_tbl(i).Problem_meaning);


            l_sr_task_tbl(i).Visit_id:=	p_x_Parts_rec_tbl(i).Target_Visit_Id;
            -- dbms_output.put_line('SR- Visit_id '|| p_x_Parts_rec_tbl(i).target_Visit_id);


            l_sr_task_tbl(i).Visit_Number := p_x_parts_rec_tbl(i).Target_Visit_Num ;
            -- dbms_output.put_line('SR- Visit_Number '|| p_x_Parts_rec_tbl(i).Target_Visit_Num);
            l_sr_task_tbl(i).Originating_wo_id:= p_x_Parts_rec_tbl(i).workorder_id;
            -- dbms_output.put_line('SR- Originating_wo_id '|| p_x_Parts_rec_tbl(i).workorder_id);

            l_sr_task_tbl(i).Operation_type	:= 'CREATE' ;

            l_sr_task_tbl(i).Severity_id := p_x_Parts_rec_tbl(i).severity_id;
            -- dbms_output.put_line('SR- Severity_id '|| p_x_Parts_rec_tbl(i).Severity_id);


            l_sr_task_tbl(i).Severity_name := p_x_Parts_rec_tbl(i).severity_name;

            -- dbms_output.put_line('SR- Severity_name '|| p_x_Parts_rec_tbl(i).Severity_name);
            l_sr_task_tbl(i).duration := p_x_Parts_rec_tbl(i).estimated_duration;

            -- dbms_output.put_line('SR- duration '|| p_x_Parts_rec_tbl(i).estimated_duration);
           l_sr_task_tbl(i).source_program_code := 'AHL_NONROUTINE';

      END IF; -- part condition.
    END LOOP;
  END IF;

  --Calling Service Request API--
  AHL_PRD_NONROUTINE_PVT.process_nonroutine_job (
                                               p_api_version => 1.0,
                                               p_commit =>  Fnd_Api.g_false,
                                               p_module_type => p_module_type,
                                               x_return_status => x_return_status,
                                               x_msg_count => l_msg_count,
                                               x_msg_data => l_msg_data,
                                               p_x_sr_task_tbl => l_sr_task_tbl);


  -- dbms_output.put_line('Sangita-x_return_status after SR'|| x_return_status);


  IF G_DEBUG = 'Y' THEN
     AHL_DEBUG_PUB.debug('Sangita-x_return_status after SR'|| x_return_status);
  END IF;


  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) then

    IF ( l_sr_task_tbl.COUNT > 0) THEN
      FOR i IN l_sr_task_tbl.FIRST..l_sr_task_tbl.LAST LOOP

        -- dbms_output.put_line('l_sr_task_tbl(1).incident_id='|| l_sr_task_tbl(1).incident_id);
        p_x_parts_rec_tbl(i).nonroutine_wo_id := l_sr_task_tbl(i).Nonroutine_wo_id;

        --- ********* UPDATE AHL_PARTS_CHANGE TABLE AFTER EVERYTHING IS SUCCESFUL ---------

        IF ( p_x_parts_rec_tbl(i).nonroutine_wo_id is not null ) then
          -- dbms_output.put_line('inside update part changes call');
          IF G_DEBUG = 'Y' THEN
             AHL_DEBUG_PUB.debug('inside update part changes call');
          END IF;

          AHL_PART_CHANGES_PKG.update_row(
            X_PART_CHANGE_ID => p_x_parts_rec_tbl(i).part_change_txn_id,
            X_UNIT_CONFIG_HEADER_ID=>p_x_parts_rec_tbl(i).unit_config_header_id,
            X_REMOVED_INSTANCE_ID => p_x_parts_rec_tbl(i).removed_instance_id,
            X_MC_RELATIONSHIP_ID => p_x_parts_rec_tbl(i).mc_relationship_id,
            X_REMOVAL_CODE =>  p_x_parts_rec_tbl(i).removal_code,
            X_STATUS_ID =>  p_x_parts_rec_tbl(i).Condition_id,
            X_REMOVAL_REASON_ID =>  p_x_parts_rec_tbl(i).removal_reason_id,
            X_INSTALLED_INSTANCE_ID => p_x_parts_rec_tbl(i).installed_instance_id,
            X_WORKORDER_OPERATION_ID => p_x_parts_rec_tbl(i).workorder_operation_id,
            X_OBJECT_VERSION_NUMBER => 2,
            X_COLLECTION_ID => p_x_parts_rec_tbl(i).collection_id,
            X_WORKORDER_MTL_TXN_ID =>   p_x_parts_rec_tbl(i).material_txn_id,
            X_NON_ROUTINE_WORKORDER_ID => p_x_parts_rec_tbl(i).nonroutine_wo_id,
            X_REMOVAL_DATE => p_x_parts_rec_tbl(i).removal_date,
            X_INSTALLATION_DATE => p_x_parts_rec_tbl(i).INSTALLATION_DATE,
            X_LAST_UPDATE_DATE => sysdate,
            X_LAST_UPDATED_BY  => fnd_global.user_id,
            X_LAST_UPDATE_LOGIN  => fnd_global.login_id,
            X_ATTRIBUTE_CATEGORY => null,
            X_ATTRIBUTE1 => null,
            X_ATTRIBUTE2 => null,
            X_ATTRIBUTE3 => null,
            X_ATTRIBUTE4 => null,
            X_ATTRIBUTE5 => null,
            X_ATTRIBUTE6 => null,
            X_ATTRIBUTE7 => null,
            X_ATTRIBUTE8 => null,
            X_ATTRIBUTE9 => null,
            X_ATTRIBUTE10 => null,
            X_ATTRIBUTE11 => null,
            X_ATTRIBUTE12 => null,
            X_ATTRIBUTE13 => null,
            X_ATTRIBUTE14 => null,
            X_ATTRIBUTE15 => null
          );

        END IF; -- nonroutine wo exists.
      END LOOP;
    END IF;
  END IF;

END Process_SR;
*/

-- Get Material Issue transaction, if exists, when installing an item.
PROCEDURE Get_Issue_Mtl_Txn (p_workorder_id  IN NUMBER,
                             p_Item_Instance_Id  IN  NUMBER,
                             x_issue_mtl_txn_id  OUT NOCOPY NUMBER)
IS
  -- To get latest material issue txn for the item instance.
  CURSOR ahl_mtl_txn_csr (p_Item_Instance_Id IN NUMBER,
                          p_workorder_id     IN NUMBER) IS
    SELECT workorder_mtl_txn_id
    FROM ahl_workorder_mtl_txns mt, ahl_workorder_operations woo
    WHERE mt.WORKORDER_OPERATION_ID = woo.WORKORDER_OPERATION_ID
      AND TRANSACTION_TYPE_ID = 35  -- issues.
      AND woo.workorder_id = p_workorder_id
    ORDER by mt.TRANSACTION_DATE DESC, mt.LAST_UPDATE_DATE DESC;


BEGIN
  -- get the latest material issue record.
  OPEN ahl_mtl_txn_csr(p_Item_Instance_Id, p_workorder_id);
  FETCH ahl_mtl_txn_csr INTO x_issue_mtl_txn_id;
  IF (ahl_mtl_txn_csr%NOTFOUND) THEN
    x_issue_mtl_txn_id := NULL;
  END IF;
  CLOSE ahl_mtl_txn_csr;

END Get_Issue_Mtl_Txn;

-- Update Material Return txn if item returned using Material Transactions.
PROCEDURE Update_Material_Return (p_return_mtl_txn_id  IN NUMBER,
                                  p_workorder_id       IN NUMBER,
                                  p_Item_Instance_Id   IN  NUMBER,
                                  x_return_status  OUT NOCOPY VARCHAR2)
IS
  -- To get latest removal or swap parts change txn.
  CURSOR ahl_part_chg_csr (p_Item_Instance_Id IN NUMBER,
                           p_workorder_id     IN NUMBER) IS
    SELECT pc.part_change_id, pc.object_version_number
    FROM ahl_part_changes pc, ahl_workorder_operations woo
    WHERE pc.WORKORDER_OPERATION_ID = woo.WORKORDER_OPERATION_ID
      AND pc.removed_instance_id = p_item_instance_id
      AND woo.workorder_id = p_workorder_id
      AND pc.return_mtl_txn_id IS NULL
    ORDER by pc.LAST_UPDATE_DATE DESC
    FOR UPDATE OF return_mtl_txn_id;

  l_part_change_id   NUMBER;
  l_object_version_number NUMBER;
  l_found            BOOLEAN;

BEGIN

  l_found := FALSE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- get the latest material issue record.
  OPEN ahl_part_chg_csr(p_Item_Instance_Id, p_workorder_id);
  FETCH ahl_part_chg_csr INTO l_part_change_id, l_object_version_number;
  IF (ahl_part_chg_csr%FOUND) THEN
    l_found := TRUE;
  END IF;

  IF (l_found) THEN
    UPDATE ahl_part_changes
    SET return_mtl_txn_id = p_return_mtl_txn_id,
        object_version_number = l_object_version_number + 1
    WHERE CURRENT OF ahl_part_chg_csr;
  END IF;

  CLOSE ahl_part_chg_csr;

END Update_Material_Return;

-- Added for ER 5854712 - locator for servicable parts.
-- Procedure will return removed instance to Visit-Workorder locator.
PROCEDURE ReturnTo_Workorder_Locator( p_init_msg_list   IN            VARCHAR2 := FND_API.G_FALSE,
                                      p_commit          IN            VARCHAR2 := FND_API.G_FALSE,
                                      p_part_change_id  IN            NUMBER,
                                      p_disposition_id  IN            NUMBER,
                                      x_return_status      OUT NOCOPY VARCHAR2,
                                      x_msg_data           OUT NOCOPY VARCHAR2,
                                      x_msg_count          OUT NOCOPY NUMBER,
                                      x_ahl_mtltxn_rec     OUT NOCOPY AHL_PRD_MTLTXN_PVT.Ahl_Mtltxn_Rec_Type)
IS
  -- FND Logging Constants
  l_debug_level     NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_debug_proc      NUMBER := FND_LOG.LEVEL_PROCEDURE;
  l_debug_stmt      NUMBER := FND_LOG.LEVEL_STATEMENT;
  l_debug_uexp      NUMBER := FND_LOG.LEVEL_UNEXPECTED;

  l_debug_module    VARCHAR2(80) := 'ahl.plsql.AHL_PRD_PARTS_CHANGE_PVT.ReturnTo_Workorder_Locator';

  CURSOR ahl_disp_csr (p_disposition_id IN NUMBER,
                       p_part_change_id IN NUMBER) IS
    SELECT disp.WORKORDER_ID, disp.INSTANCE_ID, disp.CONDITION_ID,
           DISP.QUANTITY, DISP.UOM, disp.WO_OPERATION_ID, disp.item_revision revision,
           disp.serial_number, disp.lot_number,
           csi.inventory_item_id, vst.organization_id, vst.inv_locator_id,
           loc.subinventory_code, awo.operation_sequence_num
    FROM ahl_prd_dispositions_b disp, csi_item_instances csi,
         ahl_workorders wo, ahl_visits_b vst,
         mtl_item_locations_kfv loc, ahl_workorder_operations awo
    WHERE disp.instance_id = csi.instance_id
      AND disp.part_change_id = p_part_change_id
      AND disp.workorder_id = wo.workorder_id
      AND wo.visit_id = vst.visit_id
      AND vst.inv_locator_id = loc.inventory_location_id(+)
      AND vst.organization_id = loc.organization_id(+)
      AND awo.workorder_operation_id = disp.WO_OPERATION_ID;

  CURSOR get_employee_id(p_user_id IN NUMBER) IS
    SELECT employee_id
    from FND_USER
    WHERE user_id = p_user_id;


  l_mtl_txn_tbl        AHL_PRD_MTLTXN_PVT.Ahl_Mtltxn_Tbl_Type;
  l_disp_Mtl_Txn_Tbl   AHL_PRD_DISP_MTL_TXN_PVT.Disp_Mtl_Txn_Tbl_Type;

  l_disposition_rec    ahl_disp_csr%ROWTYPE;
  l_employee_id        number;

  l_msg_count          number;
  l_msg_count1         number;

BEGIN

  -- log debug message.
  IF (l_debug_proc >= l_debug_level) THEN
     fnd_log.string(l_debug_proc,l_debug_module,
                   'At Start of procedure AHL_PRD_PARTS_CHANGE_PVT.ReturnTo_Workorder_Locator');
  END IF;

  -- Standard start of API savepoint
  Savepoint ReturnTo_Workorder_Locator_pvt;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- log debug message.
  IF (l_debug_stmt >= l_debug_level) THEN
      fnd_log.string(l_debug_stmt,l_debug_module,
               'Input disposition_id:' || p_disposition_id);
      fnd_log.string(l_debug_stmt,l_debug_module,
               'Input Parts_Change_id:' || p_part_change_id);
  END IF;

  -- get count of existing messages.
  l_msg_count := FND_MSG_PUB.Count_Msg;

  -- get disposition details.
  OPEN ahl_disp_csr(p_disposition_id, p_part_change_id);
  FETCH ahl_disp_csr INTO l_disposition_rec;
  IF (ahl_disp_csr%NOTFOUND) THEN
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_PC_DISP_INVALID');
    FND_MESSAGE.Set_Token('DISP_ID',p_disposition_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE ahl_disp_csr;

  -- If visit header does not have locator information then return.
  IF (l_disposition_rec.inv_locator_id IS NULL) THEN
    RETURN;
  END IF;

  -- Form material txn record structure.

  l_mtl_txn_tbl(1).Workorder_id	:= l_disposition_rec.workorder_id;
  -- dbms_output.put_line('workorder '||l_mtl_txn_tbl(1).Workorder_id);

  l_mtl_txn_tbl(1).workorder_operation_id := l_disposition_rec.wo_operation_id;
  -- dbms_output.put_line('workorder_operation_id '||l_mtl_txn_tbl(1).workorder_operation_id);

  l_mtl_txn_tbl(1).operation_seq_num := l_disposition_rec.operation_sequence_num;

  l_mtl_txn_tbl(1).INVENTORY_ITEM_ID := l_disposition_rec.inventory_item_id;
  -- dbms_output.put_line('INVENTORY_ITEM_ID '||l_mtl_txn_tbl(1).INVENTORY_ITEM_ID);

  l_mtl_txn_tbl(1).REVISION := l_disposition_rec.revision;
  -- dbms_output.put_line('REVISION '||l_mtl_txn_tbl(1).REVISION);

  l_mtl_txn_tbl(1).ORGANIZATION_ID:= l_disposition_rec.organization_id;
  -- dbms_output.put_line('ORGANIZATION_ID '||l_mtl_txn_tbl(1).ORGANIZATION_ID);

  l_mtl_txn_tbl(1).CONDITION := l_disposition_rec.condition_id;
  -- dbms_output.put_line('CONDITION '||l_mtl_txn_tbl(1).CONDITION);

  l_mtl_txn_tbl(1).SUBINVENTORY_NAME := l_disposition_rec.subinventory_code;
  -- dbms_output.put_line('SUBINVENTORY_NAME '||l_mtl_txn_tbl(1).SUBINVENTORY_NAME);

  l_mtl_txn_tbl(1).MOVE_TO_PROJECT_FLAG := 'Y';
  -- dbms_output.put_line('MOVE_TO_PROJECT_FLAG '||l_mtl_txn_tbl(1).MOVE_TO_PROJECT_FLAG);

  l_mtl_txn_tbl(1).QUANTITY := l_disposition_rec.quantity;
  -- dbms_output.put_line('QUANTITY '||l_mtl_txn_tbl(1).QUANTITY);

  l_mtl_txn_tbl(1).UOM	:= l_disposition_rec.uom;
  -- dbms_output.put_line('UOM '||l_mtl_txn_tbl(1).UOM);

  l_mtl_txn_tbl(1).TRANSACTION_TYPE_ID:= WIP_CONSTANTS.RETCOMP_TYPE;
  -- dbms_output.put_line('TRANSACTION_TYPE_ID '||l_mtl_txn_tbl(1).TRANSACTION_TYPE_ID);

  l_mtl_txn_tbl(1).TRANSACTION_REFERENCE := null;

  l_mtl_txn_tbl(1).SERIAL_NUMBER := l_disposition_rec.serial_number;
  -- dbms_output.put_line('SERIAL_NUMBER '||l_mtl_txn_tbl(1).SERIAL_NUMBER);

  l_mtl_txn_tbl(1).LOT_NUMBER := l_disposition_rec.lot_number;
  -- dbms_output.put_line('LOT_NUMBER '||l_mtl_txn_tbl(1).LOT_NUMBER);

  l_mtl_txn_tbl(1).disposition_id := p_disposition_id;
  -- dbms_output.put_line('LOT_NUMBER '||l_mtl_txn_tbl(1).LOT_NUMBER);

  -- populate receipient.
  OPEN get_employee_id(FND_GLOBAL.USER_ID);
  FETCH get_employee_id INTO l_employee_id;
  CLOSE get_employee_id;

  l_mtl_txn_tbl(1).recepient_id := l_employee_id;

  AHL_PRD_MTLTXN_PVT.PERFORM_MTL_TXN (p_api_version => 1.0,
  		                      p_module_type => null,
                                      p_create_sr => 'N', -- servicable return txn.
                                      p_x_ahl_mtltxn_tbl=> l_mtl_txn_tbl,
                                      x_return_status => x_return_status,
                                      x_msg_count=> x_msg_count,
  	                              x_msg_data => x_msg_data );

  IF (l_debug_stmt >= l_debug_level)
  THEN
        fnd_log.string
        (
            l_debug_stmt,
            l_debug_module,
            'After call to AHL_PRD_MTLTXN_PVT.PERFORM_MTL_TXN. Return status:' || x_return_status
        );
        fnd_log.string
        (
            l_debug_stmt,
            l_debug_module,
            'After call to AHL_PRD_MTLTXN_PVT.PERFORM_MTL_TXN. Error count:' || x_msg_count
        );
  END IF;

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- get count of message after calling Material txn api.
  x_msg_count := FND_MSG_PUB.Count_Msg;

  -- if return status success.. remove info messages from WIP/INV.
  FOR i IN l_msg_count+1..x_msg_count LOOP
     FND_MSG_PUB.Delete_Msg(i);
  END LOOP;

  -- log debug message.
  IF (l_debug_proc >= l_debug_level) THEN
     fnd_log.string(l_debug_proc,l_debug_module,
                   '');
  END IF;

  FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                             p_data  => x_msg_data,
                             p_encoded => fnd_api.g_false);

  -- Call disposition api to associate material txn.
  l_disp_Mtl_Txn_Tbl(1).wo_mtl_txn_id  := l_mtl_txn_tbl(1).Ahl_MtlTxn_Id;
  l_disp_Mtl_Txn_Tbl(1).disposition_id := l_mtl_txn_tbl(1).disposition_id;
  l_disp_Mtl_Txn_Tbl(1).quantity       := l_mtl_txn_tbl(1).Quantity;
  l_disp_Mtl_Txn_Tbl(1).uom            := l_mtl_txn_tbl(1).uom;

  AHL_PRD_DISP_MTL_TXN_PVT.Process_Disp_Mtl_Txn (
                p_api_version         => 1.0,
                p_init_msg_list       => FND_API.G_FALSE,
                p_commit              => FND_API.G_FALSE,
                p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data,
                p_module              => 'JSP',
                p_x_disp_mtl_txn_tbl  => l_disp_Mtl_Txn_Tbl);

  IF (l_debug_stmt >= l_debug_level)
  THEN
        fnd_log.string
        (
            l_debug_stmt,
            l_debug_module,
            'After call to AHL_PRD_DISP_MTL_TXN_PVT.Process_Disp_Mtl_Txn. Return status:' || x_return_status
        );
        fnd_log.string
        (
            l_debug_stmt,
            l_debug_module,
            'After call to AHL_PRD_DISP_MTL_TXN_PVT.Process_Disp_Mtl_Txn. Error count:' || x_msg_count
        );
  END IF;

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- log debug message.
  IF (l_debug_proc >= l_debug_level) THEN
     fnd_log.string(l_debug_proc,l_debug_module,
                   'At End of procedure AHL_PRD_PARTS_CHANGE_PVT.ReturnTo_Workorder_Locator');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to ReturnTo_Workorder_Locator_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
   -- Disable debug
   IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.disable_debug;
   END IF;


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to ReturnTo_Workorder_Locator_pvt;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
   -- Disable debug
   IF G_DEBUG = 'Y' THEN
      AHL_DEBUG_PUB.disable_debug;
   END IF;

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to ReturnTo_Workorder_Locator_pvt;
    --IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'AHL_PRD_PARTS_CHANGE_PVT',
                               p_procedure_name => 'process_parts',
                               p_error_text     => SQLERRM);
    --END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

    -- Disable debug
    IF G_DEBUG = 'Y' THEN
       AHL_DEBUG_PUB.disable_debug;
    END IF;

END ReturnTo_Workorder_Locator;


PROCEDURE move_instance_location(
  P_API_Version            In  Number Default  1.0,
  P_Init_Msg_List          In  Varchar2 Default Fnd_API.G_False,
  P_Commit                 In  Varchar2 Default Fnd_API.G_False,
  P_Validation_Level       In  Number   Default Fnd_API.G_Valid_Level_Full,
  p_module_type            In  Varchar2  Default NULL,
  p_default                In  Varchar2  Default FND_API.G_TRUE,
  p_move_item_instance_tbl In AHL_PRD_PARTS_CHANGE_PVT.move_item_instance_tbl_type,
  X_Return_Status          Out NOCOPY Varchar2,
  X_Msg_Count              Out NOCOPY Number,
  X_Msg_Data               Out NOCOPY Varchar2) IS

  l_api_name          CONSTANT 	VARCHAR2(30) := 'move_instance_location';
  l_api_version       CONSTANT 	NUMBER   	 := 1.0;

  l_instance_rec             csi_datastructures_pub.instance_rec;
  l_csi_transaction_rec  CSI_DATASTRUCTURES_PUB.transaction_rec;
  l_serialized VARCHAR2(1);





BEGIN
  -- Standard start of API savepoint
  SAVEPOINT MOVE_INSTANCE_LOCATION;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name ||'.begin',
			'At the start of PLSQL procedure'
		);
  END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ------**************Get csi_transaction_rec.
  Create_csi_transaction_rec(l_csi_transaction_rec,x_return_status);
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.'  || l_api_name,
			'Created CSI Transaction'
		);
  END IF;

  --get location id
  /*OPEN  ahl_wip_location_csr();
  FETCH  ahl_wip_location_csr INTO l_location_id ;
  CLOSE ahl_wip_location_csr;*/

  FOR i IN p_move_item_instance_tbl.FIRST..p_move_item_instance_tbl.LAST LOOP
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.'  || l_api_name,
			'p_move_item_instance_tbl(i).instance_id : ' || p_move_item_instance_tbl(i).instance_id
		);
    END IF;
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.'  || l_api_name,
			'p_move_item_instance_tbl(i).quantity : ' || p_move_item_instance_tbl(i).quantity
		);
    END IF;
    get_dest_instance_rec(
        p_module_type => p_module_type,
        p_move_item_instance_rec => p_move_item_instance_tbl(i),
        x_instance_rec =>  l_instance_rec,
        x_serialized  => l_serialized,
        x_Return_Status  => X_Return_Status
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'get_dest_instance_rec returned error'
		);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*l_instance_rec.location_id := l_location_id;
    l_instance_rec.LOCATION_TYPE_CODE  := 'WIP';
    l_instance_rec.instance_usage_code := 'IN_WIP';*/

    IF FND_API.To_Boolean(l_serialized) THEN
      update_csi_item_instance(
        p_instance_rec        => l_instance_rec,
        p_x_csi_transaction_rec => l_csi_transaction_rec,
        x_Return_Status  => X_Return_Status
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'serialized move: update_csi_item_instance returned error'
		);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE


      move_nonser_instance(
        p_source_instance_id => l_instance_rec.instance_id,
        p_move_quantity      => l_instance_rec.quantity,
        p_dest_wip_job_id    => l_instance_rec.wip_job_id,
        p_x_csi_transaction_rec => l_csi_transaction_rec,
        x_Return_Status  => X_Return_Status
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'non serialized move: move_nonser_instance returned error'
		);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END LOOP;

   -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;



  -- Standard call to get message count and if count is 1, get message
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name ||'.end',
			'At the end of PLSQL procedure'
		);
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to MOVE_INSTANCE_LOCATION;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);


 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to MOVE_INSTANCE_LOCATION;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);

 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to MOVE_INSTANCE_LOCATION;
    --IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'AHL_PRD_PARTS_CHANGE_PVT',
                               p_procedure_name => 'move_instance_location',
                               p_error_text     => SQLERRM);
    --END IF;
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

END move_instance_location;

PROCEDURE get_dest_instance_rec(
   p_module_type            IN VARCHAR2  Default NULL,
   p_move_item_instance_rec IN move_item_instance_rec_type,
   x_instance_rec Out NOCOPY csi_datastructures_pub.instance_rec,
   x_serialized Out NOCOPY Varchar2,
   x_Return_Status          Out NOCOPY Varchar2
) IS
  l_api_name          CONSTANT 	VARCHAR2(30) := 'get_dest_instance_rec';
  -- For wip_entity_id for the workorder
  CURSOR wip_entity_woid_csr(p_wo_id IN NUMBER) IS
  Select AHL.wip_entity_id,job_status_code
  FROM ahl_search_workorders_v AHL
  WHERE AHL.workorder_id = p_wo_id;

  CURSOR wip_entity_wonum_csr(p_wo_number IN VARCHAR2) IS
  Select AHL.wip_entity_id,job_status_code
  FROM ahl_search_workorders_v AHL
  WHERE AHL.JOB_NUMBER = p_wo_number;

  --For the updated object_version number from csi_item_isntances
  CURSOR csi_item_instance_id_csr(p_instance_id IN NUMBER) IS
     select instance_id,object_Version_number,serial_number,quantity,wip_job_id
     from csi_item_instances CII
     where CII.instance_id = p_instance_id
     AND CII.ACTIVE_START_DATE <= SYSDATE
     AND ((CII.ACTIVE_END_DATE IS NULL) OR (CII.ACTIVE_END_DATE > SYSDATE))
     AND NOT EXISTS (SELECT 'x' FROM CSI_II_RELATIONSHIPS CIR
     WHERE CIR.SUBJECT_ID = CII.INSTANCE_ID
     AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
     AND ((CIR.ACTIVE_START_DATE IS NULL) OR (CIR.ACTIVE_START_DATE <= SYSDATE))
     AND ((CIR.ACTIVE_END_DATE IS NULL) OR (CIR.ACTIVE_END_DATE > SYSDATE)));

  CURSOR csi_item_instance_num_csr(p_instance_number IN VARCHAR2) IS
     select instance_id, object_Version_number,serial_number,quantity,wip_job_id
     from csi_item_instances CII
     where CII.instance_number = p_instance_number
     AND CII.ACTIVE_START_DATE <= SYSDATE
     AND ((CII.ACTIVE_END_DATE IS NULL) OR (CII.ACTIVE_END_DATE > SYSDATE))
     AND NOT EXISTS (SELECT 'x' FROM CSI_II_RELATIONSHIPS CIR
     WHERE CIR.SUBJECT_ID = CII.INSTANCE_ID
     AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
     AND ((CIR.ACTIVE_START_DATE IS NULL) OR (CIR.ACTIVE_START_DATE <= SYSDATE))
     AND ((CIR.ACTIVE_END_DATE IS NULL) OR (CIR.ACTIVE_END_DATE > SYSDATE)));

  l_instance_rec             csi_datastructures_pub.instance_rec;
  l_from_wip_entity_id NUMBER;
  l_curr_wip_entity_id NUMBER;
  l_to_wip_entity_id NUMBER;
  l_serial_number VARCHAR2(30);
  l_current_quantity NUMBER;
  l_status_code VARCHAR2(30);
  l_check_qnt_flag BOOLEAN;


  CURSOR check_inst_nonserial(p_instance_id IN NUMBER) IS
    SELECT 'X'
    FROM mtl_system_items_b mtl, csi_item_instances csi
    WHERE csi.instance_id = p_instance_id
    AND csi.inventory_item_id = mtl.inventory_item_id
    AND NVL(csi.inv_organization_id, csi.inv_master_organization_id) = mtl.organization_id
    AND mtl.serial_number_control_code = 1;

  l_junk VARCHAR2(1);

  CURSOR check_org_csr(p_from_wip_entity NUMBER,p_to_wip_entity NUMBER)IS
  SELECT 'x' FROM ahl_workorders A,ahl_workorders B WHERE
  A.wip_entity_id = p_from_wip_entity
  AND B.wip_entity_id = p_to_wip_entity
  AND A.visit_id = B.visit_id;


BEGIN
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name ||'.begin',
			'At the start of PLSQL procedure'
		);
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(p_module_type = 'JSP' AND p_move_item_instance_rec.from_workorder_number IS NOT NULL) THEN
     OPEN wip_entity_wonum_csr(p_move_item_instance_rec.from_workorder_number);
     FETCH wip_entity_wonum_csr INTO l_from_wip_entity_id,l_status_code;
     IF (wip_entity_wonum_csr%NOTFOUND OR l_status_code IN ('1','5','7','12','17','22')) THEN
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'wip_entity_not_found for from_workorder_number'
		);
       END IF;
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_WO_NUM_MISSING');
       FND_MESSAGE.Set_Token('WONUM',p_move_item_instance_rec.from_workorder_number);
       FND_MSG_PUB.ADD;
     END IF;
     CLOSE wip_entity_wonum_csr;
  ELSIF p_move_item_instance_rec.from_workorder_id IS NOT NULL THEN
     OPEN wip_entity_woid_csr(p_move_item_instance_rec.from_workorder_id);
     FETCH wip_entity_woid_csr INTO l_from_wip_entity_id,l_status_code;
     IF (wip_entity_woid_csr%NOTFOUND OR l_status_code IN ('1','5','7','12','17','22')) THEN
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'wip_entity_not_found for from_workorder_id'
		);
       END IF;
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_WO_ID_MISSING');
       FND_MESSAGE.Set_Token('WOID',p_move_item_instance_rec.from_workorder_id);
       FND_MSG_PUB.ADD;
     END IF;
     CLOSE wip_entity_woid_csr;
  END IF;
  --dbms_output.put_line('point1');

  IF(p_module_type = 'JSP' AND p_move_item_instance_rec.to_workorder_number IS NOT NULL) THEN
     OPEN wip_entity_wonum_csr(p_move_item_instance_rec.to_workorder_number);
     FETCH wip_entity_wonum_csr INTO l_to_wip_entity_id, l_status_code;
     IF (wip_entity_wonum_csr%NOTFOUND OR l_status_code IN ('1','4','5','6','7','12','17','21','22')) THEN
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'wip_entity_not_found for to_workorder_number'
		);
       END IF;
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_WO_NUM_MISSING');
       FND_MESSAGE.Set_Token('WONUM',p_move_item_instance_rec.to_workorder_number);
       FND_MSG_PUB.ADD;
     END IF;
     CLOSE wip_entity_wonum_csr;
  ELSE
     OPEN wip_entity_woid_csr(p_move_item_instance_rec.to_workorder_id);
     FETCH wip_entity_woid_csr INTO l_to_wip_entity_id, l_status_code;
     IF (wip_entity_woid_csr%NOTFOUND OR l_status_code IN ('1','4','5','6','7','12','17','21','22')) THEN
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'wip_entity_not_found for to_workorder_id'
		);
       END IF;
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_WO_ID_MISSING');
       FND_MESSAGE.Set_Token('WOID',p_move_item_instance_rec.to_workorder_id);
       FND_MSG_PUB.ADD;
     END IF;
     CLOSE wip_entity_woid_csr;
  END IF;

  IF(l_from_wip_entity_id IS NOT NULL) THEN
   OPEN check_org_csr(l_from_wip_entity_id,l_to_wip_entity_id);
   FETCH check_org_csr INTO l_junk;
   IF(check_org_csr%NOTFOUND)THEN
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_WO_NUM_MISSING');
    FND_MESSAGE.Set_Token('WONUM',p_move_item_instance_rec.to_workorder_number);
    FND_MSG_PUB.ADD;
   END IF;
   CLOSE check_org_csr;
  END IF;

  l_check_qnt_flag := true; --amsriniv. Introducing this flag to check if quantity /serial checks are required.
  --dbms_output.put_line('point2');
  IF((p_module_type = 'JSP' AND p_move_item_instance_rec.instance_number IS NOT NULL) OR
     p_move_item_instance_rec.instance_id IS NULL) THEN
     --get the updated object_version number from csi_item_isntances
     --dbms_output.put_line('point2 : ' || p_move_item_instance_rec.instance_number);
     --l_check_qnt_flag := true; --amsriniv. Introducing this flag to check if quantity /serial checks are required.
     OPEN csi_item_instance_num_csr(p_move_item_instance_rec.instance_number);
     FETCH csi_item_instance_num_csr INTO l_instance_rec.instance_id,
                                          l_instance_rec.OBJECT_VERSION_NUMBER,
                                          l_serial_number,
                                          l_current_quantity,
                                          l_curr_wip_entity_id;

     IF (csi_item_instance_num_csr%NOTFOUND) THEN
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'removed instance_num not found ' || p_move_item_instance_rec.instance_number
		);
       END IF;
       l_check_qnt_flag := FALSE; --amsriniv
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_REM_INSTNUM_INV');
       FND_MESSAGE.Set_Token('INST',p_move_item_instance_rec.instance_number);
       FND_MSG_PUB.ADD;
     END IF;
     CLOSE csi_item_instance_num_csr;
  ELSE
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name ||'.begin',
			'p_move_item_instance_rec.instance_id : ' || p_move_item_instance_rec.instance_id
		);
      END IF;
     --get the updated object_version number from csi_item_isntances
     OPEN csi_item_instance_id_csr(p_move_item_instance_rec.instance_id);
     FETCH csi_item_instance_id_csr INTO l_instance_rec.instance_id,
                                          l_instance_rec.OBJECT_VERSION_NUMBER,
                                          l_serial_number,
                                          l_current_quantity,
                                          l_curr_wip_entity_id;
     IF (csi_item_instance_id_csr%NOTFOUND) THEN
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'removed instance_id not found ' || p_move_item_instance_rec.instance_id
		);
       END IF;
       l_check_qnt_flag := FALSE; --amsriniv
       FND_MESSAGE.Set_Name('AHL','AHL_PRD_REM_INSTID_INV');
       FND_MESSAGE.Set_Token('INST',p_move_item_instance_rec.instance_id);--amsriniv
       FND_MSG_PUB.ADD;
     END IF;
     CLOSE csi_item_instance_id_csr;
  END IF;


  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
     fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'checking whether item is serialized'
		);
  END IF;

  --Validate quantity / serial item only if valid instance exists.
  x_serialized := FND_API.G_FALSE;
  IF (l_check_qnt_flag) THEN
	  OPEN check_inst_nonserial(l_instance_rec.instance_id);
	  FETCH check_inst_nonserial INTO l_junk;
	  IF(check_inst_nonserial%NOTFOUND)THEN
	    x_serialized := FND_API.G_TRUE;
	  END IF;
	  CLOSE check_inst_nonserial;

	  IF FND_API.To_Boolean(x_serialized) THEN
	     IF(NVL(p_move_item_instance_rec.quantity,1) <> 1)THEN
	       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
			fnd_log.string
			(
				fnd_log.level_error,
				'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
				'invalid qty for serialized item  ' || p_move_item_instance_rec.quantity
			);
	       END IF;
	       FND_MESSAGE.Set_Name('AHL','AHL_PRD_INV_SER_QTY');
	       FND_MESSAGE.Set_Token('QTY',to_char(p_move_item_instance_rec.quantity));
	       FND_MSG_PUB.ADD;
	     END IF;
	  ELSE
	     IF ((NVL(p_move_item_instance_rec.quantity,1) < 0) OR
		  (NVL(p_move_item_instance_rec.quantity,1) > l_current_quantity))THEN
	       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
			fnd_log.string
			(
				fnd_log.level_error,
				'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
				'invalid qty for non serialized item  ' || p_move_item_instance_rec.quantity
			);
	       END IF;
	       FND_MESSAGE.Set_Name('AHL','AHL_PRD_INV_NONSER_QTY');
	       FND_MESSAGE.Set_Token('QTY',to_char(p_move_item_instance_rec.quantity));
	       FND_MSG_PUB.ADD;
	     END IF;
	  END IF;
  END IF;

  IF(l_curr_wip_entity_id <> l_from_wip_entity_id) THEN
    IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'item not in from wip_entity_id location   ' || l_from_wip_entity_id
		);
    END IF;
    FND_MESSAGE.Set_Name('AHL','AHL_PRD_INV_CURR_LOC');
    FND_MESSAGE.Set_Token('INST',l_instance_rec.instance_id);
    FND_MSG_PUB.ADD;
  END IF;
  --Standard check to count messages
  IF Fnd_Msg_Pub.count_msg > 0  THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

  l_instance_rec.wip_job_id := l_to_wip_entity_id;
  l_instance_rec.quantity := NVL(p_move_item_instance_rec.quantity,1);
  x_instance_rec := l_instance_rec;


  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
     fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'x_instance_rec.instance_id   ' || x_instance_rec.instance_id
		);
	fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'x_instance_rec.wip_job_id   ' || x_instance_rec.wip_job_id
		);
	fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'x_instance_rec.quantity   ' || x_instance_rec.quantity
		);
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name ||'.end',
			'At the end of PLSQL procedure'
		);
  END IF;


END get_dest_instance_rec;

PROCEDURE update_csi_item_instance(
   p_instance_rec        IN csi_datastructures_pub.instance_rec,
   p_x_csi_transaction_rec In Out Nocopy CSI_DATASTRUCTURES_PUB.transaction_rec,
   X_Return_Status          Out NOCOPY Varchar2
) IS
  l_api_name          CONSTANT 	VARCHAR2(30) := 'update_csi_item_instance';
  l_extend_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
  l_party_tbl                csi_datastructures_pub.party_tbl;
  l_account_tbl              csi_datastructures_pub.party_account_tbl;
  l_pricing_attrib_tbl       csi_datastructures_pub.pricing_attribs_tbl;
  l_org_assignments_tbl      csi_datastructures_pub.organization_units_tbl;
  l_asset_assignment_tbl     csi_datastructures_pub.instance_asset_tbl;
  l_instance_id_lst          csi_datastructures_pub.id_tbl;
  l_msg_count                number;
  l_msg_data                 varchar2(2000);

  --to populate csi_transaction record
  /*CURSOR ahl_wip_location_csr IS
     select wip_location_id
     from csi_install_parameters ;*/

  l_instance_rec  csi_datastructures_pub.instance_rec;
  --to find an expired instance if there
  /*CURSOR dest_instance_csr(p_source_instance_id IN NUMBER ) IS
 SELECT 'x'
 FROM CSI_ITEM_INSTANCES CI1, CSI_ITEM_INSTANCES CI2
 WHERE CI1.INV_MASTER_ORGANIZATION_ID= CI2.INV_MASTER_ORGANIZATION_ID
 AND CI1.INVENTORY_ITEM_ID = CI2.INVENTORY_ITEM_ID
 AND NVL(CI1.INVENTORY_REVISION,'x') = NVL(CI2.INVENTORY_REVISION,'x')
 AND NVL(CI1.LOT_NUMBER,'x') = NVL(CI2.LOT_NUMBER,'x')
 AND NVL(CI1.SERIAL_NUMBER,'x') = NVL(CI2.SERIAL_NUMBER,'x')
 AND CI1.WIP_JOB_ID= CI2.WIP_JOB_ID
 AND CI1.instance_id <> p_source_instance_id
 AND CI2.instance_id = p_source_instance_id
 AND CI1.LOCATION_TYPE_CODE='WIP'
 AND CI1.INSTANCE_USAGE_CODE = 'IN_WIP'
 AND CI1.unit_of_measure = CI2.unit_of_measure
 AND CI1.ACTIVE_START_DATE <= SYSDATE
 AND (CI1.ACTIVE_END_DATE IS NULL OR  CI1.ACTIVE_END_DATE < SYSDATE)
 AND NOT EXISTS (SELECT 'x' FROM CSI_II_RELATIONSHIPS CIR
 WHERE CIR.SUBJECT_ID = CI1.INSTANCE_ID
 AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
 AND ((CIR.ACTIVE_START_DATE IS NULL) OR (CIR.ACTIVE_START_DATE <= SYSDATE))
 AND ((CIR.ACTIVE_END_DATE IS NULL) OR (CIR.ACTIVE_END_DATE > SYSDATE)) );

 l_junk VARCHAR2(1);*/


BEGIN
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name ||'.begin',
			'At the start of PLSQL procedure'
		);
   END IF;

   -- populate l_instance_rec
  l_instance_rec := p_instance_rec;
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name ||'.begin',
			'l_instance_rec.instance_id : ' || l_instance_rec.instance_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name ||'.begin',
			'l_instance_rec.quantity : ' || l_instance_rec.quantity
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name ||'.begin',
			'l_instance_rec.active_end_date : ' || to_char(l_instance_rec.active_end_date)
		);
  END IF;
  IF(l_instance_rec.quantity = 0 )THEN
     /*OPEN dest_instance_csr(l_instance_rec.instance_id);
     FETCH dest_instance_csr INTO l_junk;
     IF(dest_instance_csr%FOUND)THEN
       --l_instance_rec.instance_usage_code := NULL;
       --l_instance_rec.active_end_date := SYSDATE;
       l_instance_rec.instance_usage_code := 'UNUSABLE';
     END IF;
     CLOSE dest_instance_csr;*/
     l_instance_rec.active_end_date := SYSDATE;
     l_instance_rec.instance_usage_code := 'UNUSABLE';

  END IF;



  --get location id
  /*OPEN  ahl_wip_location_csr();
  FETCH  ahl_wip_location_csr INTO l_instance_rec.LOCATION_ID ;
  CLOSE ahl_wip_location_csr;*/


   CSI_ITEM_INSTANCE_PUB. update_item_instance (
                                            p_api_version =>1.0
                                            ,p_commit => fnd_api.g_false
                                            ,p_init_msg_list => fnd_api.g_false
                                            ,p_validation_level  => fnd_api.g_valid_level_full
                                            ,p_instance_rec => l_instance_rec
                                            ,p_ext_attrib_values_tbl=>l_extend_attrib_values_tbl
                                            ,p_party_tbl    =>l_party_tbl
                                            ,p_account_tbl => l_account_tbl
                                            ,p_pricing_attrib_tbl => l_pricing_attrib_tbl
                                            ,p_org_assignments_tbl   => l_org_assignments_tbl
                                            ,p_asset_assignment_tbl  => l_asset_assignment_tbl
                                            ,p_txn_rec  => p_x_csi_transaction_rec
                                            ,x_instance_id_lst  => l_instance_id_lst
                                            ,x_return_status => x_return_status
                                            ,x_msg_count => l_msg_count
                                            ,x_msg_data  => l_msg_data );
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name ||'.end',
			'At the end of PLSQL procedure'
		);
  END IF;
END update_csi_item_instance;

PROCEDURE move_nonser_instance(
   p_source_instance_id IN NUMBER,
   p_move_quantity      IN NUMBER,
   p_dest_wip_job_id    IN NUMBER,
   p_x_csi_transaction_rec In Out Nocopy CSI_DATASTRUCTURES_PUB.transaction_rec,
   X_Return_Status          Out NOCOPY Varchar2
) IS
  l_api_name          CONSTANT 	VARCHAR2(30) := 'move_nonser_instance';

  l_instance_rec            csi_datastructures_pub.instance_rec;
  l_extend_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
  l_party_tbl                csi_datastructures_pub.party_tbl;
  l_account_tbl              csi_datastructures_pub.party_account_tbl;
  l_pricing_attrib_tbl       csi_datastructures_pub.pricing_attribs_tbl;
  l_org_assignments_tbl      csi_datastructures_pub.organization_units_tbl;
  l_asset_assignment_tbl     csi_datastructures_pub.instance_asset_tbl;
  l_instance_id_lst          csi_datastructures_pub.id_tbl;
  l_msg_count                number;
  l_msg_data                 varchar2(2000);


  CURSOR get_instance_attrib_csr(p_instance_id NUMBER) IS
    SELECT instance_id,
           instance_number,
           inventory_item_id,
           inv_master_organization_id,
           lot_number,
           quantity,
           unit_of_measure,
           install_date,
           inventory_revision,
           object_version_number,
           wip_job_id,
           location_id
      FROM csi_item_instances
     WHERE instance_id = p_instance_id;

 l_source_inst_rec get_instance_attrib_csr%ROWTYPE;



 CURSOR dest_instance_csr(p_inventory_item_id IN NUMBER,
           p_inv_master_org_id IN NUMBER,p_wip_job_id IN NUMBER,
           --p_location_id IN NUMBER,
           p_unit_of_measure IN VARCHAR2,
           p_source_instance_id IN NUMBER ) IS
 SELECT instance_id,
           instance_number,
           inventory_item_id,
           inv_master_organization_id,
           lot_number,
           quantity,
           unit_of_measure,
           install_date,
           inventory_revision,
           object_version_number,
           wip_job_id,
           location_id FROM CSI_ITEM_INSTANCES CII
 WHERE INV_MASTER_ORGANIZATION_ID= p_inv_master_org_id
 AND INVENTORY_ITEM_ID = p_inventory_item_id
 AND WIP_JOB_ID= p_wip_job_id
 AND instance_id <> p_source_instance_id
 AND LOCATION_TYPE_CODE='WIP'
 AND INSTANCE_USAGE_CODE='IN_WIP'
 --AND LOCATION_ID= p_location_id
 AND unit_of_measure = p_unit_of_measure
 AND ACTIVE_START_DATE <= SYSDATE
 AND ((ACTIVE_END_DATE IS NULL) OR (ACTIVE_END_DATE > SYSDATE))
 AND NOT EXISTS (SELECT 'x' FROM CSI_II_RELATIONSHIPS CIR
 WHERE CIR.SUBJECT_ID = CII.INSTANCE_ID
 AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
 AND ((CIR.ACTIVE_START_DATE IS NULL) OR (CIR.ACTIVE_START_DATE <= SYSDATE))
 AND ((CIR.ACTIVE_END_DATE IS NULL) OR (CIR.ACTIVE_END_DATE > SYSDATE)) );

 l_item_found_in_dest_wo BOOLEAN;
 l_dest_instance_rec dest_instance_csr%ROWTYPE ;
 l_dest_instance_id NUMBER;

 CURSOR dest_inactive_instance_csr(p_source_instance_id IN NUMBER,p_wip_job_id IN NUMBER ) IS
 SELECT 'x'
 FROM CSI_ITEM_INSTANCES CI1, CSI_ITEM_INSTANCES CI2
 WHERE CI1.INV_MASTER_ORGANIZATION_ID= CI2.INV_MASTER_ORGANIZATION_ID
 AND CI1.INVENTORY_ITEM_ID = CI2.INVENTORY_ITEM_ID
 AND NVL(CI1.INVENTORY_REVISION,'x') = NVL(CI2.INVENTORY_REVISION,'x')
 AND NVL(CI1.LOT_NUMBER,'x') = NVL(CI2.LOT_NUMBER,'x')
 AND CI1.WIP_JOB_ID= p_wip_job_id
 AND CI1.instance_id <> p_source_instance_id
 AND CI2.instance_id = p_source_instance_id
 AND CI1.LOCATION_TYPE_CODE='WIP'
 --AND CI1.INSTANCE_USAGE_CODE IS NOT NULL
 AND NVL(CI1.INSTANCE_USAGE_CODE,'x') <> 'UNUSABLE'
 --AND CI1.quantity = 0
 AND CI1.unit_of_measure = CI2.unit_of_measure
 AND CI1.ACTIVE_START_DATE <= SYSDATE
 AND CI1.ACTIVE_END_DATE IS NOT NULL AND  CI1.ACTIVE_END_DATE < SYSDATE
 AND NOT EXISTS (SELECT 'x' FROM CSI_II_RELATIONSHIPS CIR
 WHERE CIR.SUBJECT_ID = CI1.INSTANCE_ID
 AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
 AND ((CIR.ACTIVE_START_DATE IS NULL) OR (CIR.ACTIVE_START_DATE <= SYSDATE))
 AND ((CIR.ACTIVE_END_DATE IS NULL) OR (CIR.ACTIVE_END_DATE > SYSDATE)) );

 l_inactive_item_found BOOLEAN;
 l_junk VARCHAR2(1);

 CURSOR is_open_job_instance_csr(p_instance_id IN NUMBER) IS
 SELECT 'x' from ahl_visit_tasks_b VST, ahl_workorders WO where
 VST.instance_id = p_instance_id
 AND VST.visit_task_id = WO.visit_task_id
 AND VST.visit_id = WO.visit_id
 AND WO.status_code NOT IN ('4','5','7','12','17','22');

 l_open_wip_job_source BOOLEAN;
 l_open_wip_job_dest BOOLEAN;


BEGIN
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name ||'.begin',
			'At the start of PLSQL procedure'
		);
  END IF;

  OPEN get_instance_attrib_csr(p_source_instance_id);
  FETCH get_instance_attrib_csr INTO l_source_inst_rec;
  CLOSE get_instance_attrib_csr;

  OPEN is_open_job_instance_csr(p_source_instance_id);
  FETCH is_open_job_instance_csr INTO l_junk;
  IF(is_open_job_instance_csr%NOTFOUND)THEN
    l_open_wip_job_source := FALSE;
  ELSE
    l_open_wip_job_source := TRUE;
  END IF;
  CLOSE is_open_job_instance_csr;


  l_item_found_in_dest_wo := FALSE;

  FOR dest_instance_rec IN dest_instance_csr(l_source_inst_rec.inventory_item_id,
                                             l_source_inst_rec.inv_master_organization_id,
                                             p_dest_wip_job_id,
                                             --l_source_inst_rec.location_id,
                                             l_source_inst_rec.unit_of_measure,
                                             p_source_instance_id
                                             )LOOP
    IF( NVL(dest_instance_rec.lot_number,'X') = NVL(l_source_inst_rec.lot_number,'X') AND
        NVL(dest_instance_rec.inventory_revision,'X') = NVL(l_source_inst_rec.inventory_revision,'X')) THEN
        l_item_found_in_dest_wo := TRUE;
        l_dest_instance_rec := dest_instance_rec;

        OPEN is_open_job_instance_csr(l_dest_instance_rec.instance_id);
        FETCH is_open_job_instance_csr INTO l_junk;
        IF(is_open_job_instance_csr%NOTFOUND)THEN
           l_open_wip_job_dest := FALSE;
        ELSE
           l_open_wip_job_dest := TRUE;
        END IF;
        CLOSE is_open_job_instance_csr;
    END IF;
  END LOOP;

  IF(l_item_found_in_dest_wo AND l_source_inst_rec.quantity <> p_move_quantity) THEN
    -- item in destination and not a full move. Should be OK as nothing gets expired
    -- add to dest instance quantity
    l_instance_rec.instance_id := l_dest_instance_rec.instance_id;
    l_instance_rec.quantity := l_dest_instance_rec.quantity + p_move_quantity;
    l_instance_rec.object_version_number := l_dest_instance_rec.object_version_number;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'Item Found in destination'
		);
	  fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'l_dest_instance_rec.instance_id   ' || l_dest_instance_rec.instance_id
		);
    END IF;
    --l_instance_rec.wip_job_id := l_dest_instance_rec.wip_job_id;
    update_csi_item_instance(
        p_instance_rec        => l_instance_rec,
        p_x_csi_transaction_rec => p_x_csi_transaction_rec,
        x_Return_Status  => X_Return_Status
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'Item in destination: dest Non Serialized update_csi_item_instance returned error '
		);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- reduce quantity and/or expire source insance
    l_instance_rec.instance_id := l_source_inst_rec.instance_id;
    l_instance_rec.quantity := l_source_inst_rec.quantity - p_move_quantity;
    l_instance_rec.object_version_number := l_source_inst_rec.object_version_number;

    update_csi_item_instance(
        p_instance_rec        => l_instance_rec,
        p_x_csi_transaction_rec => p_x_csi_transaction_rec,
        x_Return_Status  => X_Return_Status
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'Item in destination: source Non Serialized update_csi_item_instance returned error '
		);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSIF(l_item_found_in_dest_wo AND l_source_inst_rec.quantity = p_move_quantity) THEN
    -- item in destination and is a full move. Make sure that item with open job do not get expired
    -- add to dest instance quantity


    l_instance_rec.instance_id := l_dest_instance_rec.instance_id;
    IF( NOT l_open_wip_job_source) THEN
      l_instance_rec.quantity := l_dest_instance_rec.quantity + p_move_quantity;
    ELSIF (NOT l_open_wip_job_dest) THEN
      l_instance_rec.quantity := 0;
    ELSE
      l_instance_rec.quantity := l_dest_instance_rec.quantity + p_move_quantity;
    END IF;
    l_instance_rec.object_version_number := l_dest_instance_rec.object_version_number;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'Item Found in destination'
		);
	  fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'l_dest_instance_rec.instance_id   ' || l_dest_instance_rec.instance_id
		);
    END IF;
    --l_instance_rec.wip_job_id := l_dest_instance_rec.wip_job_id;
    update_csi_item_instance(
        p_instance_rec        => l_instance_rec,
        p_x_csi_transaction_rec => p_x_csi_transaction_rec,
        x_Return_Status  => X_Return_Status
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'Item in destination: dest Non Serialized update_csi_item_instance returned error '
		);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- reduce quantity and/or expire source insance
    l_instance_rec.instance_id := l_source_inst_rec.instance_id;
    IF( NOT l_open_wip_job_source) THEN
      l_instance_rec.quantity := l_source_inst_rec.quantity - p_move_quantity;
    ELSIF (NOT l_open_wip_job_dest) THEN
      l_instance_rec.quantity := l_source_inst_rec.quantity + l_dest_instance_rec.quantity;
      l_instance_rec.wip_job_id := p_dest_wip_job_id; --now change the location
    ELSE
      l_instance_rec.quantity := l_source_inst_rec.quantity - p_move_quantity;
    END IF;
    l_instance_rec.object_version_number := l_source_inst_rec.object_version_number;

    update_csi_item_instance(
        p_instance_rec        => l_instance_rec,
        p_x_csi_transaction_rec => p_x_csi_transaction_rec,
        x_Return_Status  => X_Return_Status
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'Item in destination: source Non Serialized update_csi_item_instance returned error '
		);
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE -- no item in destination
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'Active Item Not Found in destination'
		);
	  fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'l_source_inst_rec.instance_id   ' || l_source_inst_rec.instance_id
		);
      fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'l_source_inst_rec.quantity   ' || l_source_inst_rec.quantity
		);
      fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'p_dest_wip_job_id   ' || p_dest_wip_job_id
		);
     fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'p_move_quantity   ' || p_move_quantity
		);
    END IF;
    l_inactive_item_found := TRUE;
    OPEN dest_inactive_instance_csr(p_source_instance_id,p_dest_wip_job_id);
    FETCH dest_inactive_instance_csr INTO l_junk;
    IF(dest_inactive_instance_csr%NOTFOUND)THEN
      l_inactive_item_found := FALSE;
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		  fnd_log.string
		  (
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'No inactive item either in destination '
		  );
      END IF;
    END IF;
    CLOSE dest_inactive_instance_csr;
    -- check if full quantity is being moved, if yes, just change location of source
    IF(l_source_inst_rec.quantity = p_move_quantity AND NOT(l_inactive_item_found))THEN
       l_instance_rec.instance_id := l_source_inst_rec.instance_id;
       l_instance_rec.wip_job_id := p_dest_wip_job_id;
       l_instance_rec.object_version_number := l_source_inst_rec.object_version_number;
       update_csi_item_instance(
          p_instance_rec        => l_instance_rec,
          p_x_csi_transaction_rec => p_x_csi_transaction_rec,
          x_Return_Status  => X_Return_Status
       );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		  fnd_log.string
		  (
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'Item NOT in destination: Full Move update_csi_item_instance returned error '
		  );
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSE -- else create instance at dest with move qty and reduce source qty
         -- or reuse an expired instance create_similar_instance API does that
       create_similar_instance(
          p_source_instance_id => l_source_inst_rec.instance_id,
          p_dest_quantity      => p_move_quantity,
          p_dest_wip_job_id    => p_dest_wip_job_id,
          p_x_csi_transaction_rec => p_x_csi_transaction_rec,
          x_dest_instance_id   => l_dest_instance_id,
          x_return_status      => X_Return_Status
       );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		  fnd_log.string
		  (
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'Item NOT in destination: Partial Move create_similar_instance returned error '
		  );
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- reduce quantity and/or expire source insance
       l_instance_rec.instance_id := l_source_inst_rec.instance_id;
       l_instance_rec.quantity := l_source_inst_rec.quantity - p_move_quantity;
       l_instance_rec.object_version_number := l_source_inst_rec.object_version_number;
       update_csi_item_instance(
         p_instance_rec        => l_instance_rec,
         p_x_csi_transaction_rec => p_x_csi_transaction_rec,
         x_Return_Status  => X_Return_Status
       );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		  fnd_log.string
		  (
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'Item NOT in destination: Partial Move/Update Source qty update_csi_item_instance returned error '
		  );
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name ||'.end',
			'At the end of PLSQL procedure'
		);
  END IF;
END move_nonser_instance;


PROCEDURE create_similar_instance(
   p_source_instance_id IN NUMBER,
   p_dest_quantity      IN NUMBER,
   p_dest_wip_job_id    IN NUMBER,
   p_x_csi_transaction_rec In Out Nocopy CSI_DATASTRUCTURES_PUB.transaction_rec,
   x_dest_instance_id   OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2
) IS
  l_api_name          CONSTANT 	VARCHAR2(30) := 'create_similar_instance';
  l_source_instance_rec csi_datastructures_pub.instance_rec;
  l_dest_instance_rec csi_datastructures_pub.instance_rec;
  l_new_instance_tbl csi_datastructures_pub.instance_tbl;

  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);

  CURSOR get_instance_attrib_csr(p_instance_id NUMBER) IS
    SELECT instance_id,
           object_version_number,
           INVENTORY_REVISION,
           LOT_NUMBER,
           LOCATION_ID,
           INSTANCE_STATUS_ID
      FROM csi_item_instances
     WHERE instance_id = p_instance_id;

 CURSOR dest_instance_csr(p_wip_job_id IN NUMBER,
           p_source_instance_id IN NUMBER ) IS
 SELECT CI1.instance_id
 FROM CSI_ITEM_INSTANCES CI1, CSI_ITEM_INSTANCES CI2
 WHERE CI1.INV_MASTER_ORGANIZATION_ID= CI2.INV_MASTER_ORGANIZATION_ID
 AND CI1.INVENTORY_ITEM_ID = CI2.INVENTORY_ITEM_ID
 AND NVL(CI1.INVENTORY_REVISION,'x') = NVL(CI2.INVENTORY_REVISION,'x')
 AND NVL(CI1.LOT_NUMBER,'x') = NVL(CI2.LOT_NUMBER,'x')
 AND CI1.WIP_JOB_ID= p_wip_job_id
 AND CI1.instance_id <> CI2.instance_id
 AND CI2.instance_id = p_source_instance_id
 AND CI1.LOCATION_TYPE_CODE='WIP'
 AND CI1.INSTANCE_USAGE_CODE = 'IN_WIP'
 --AND CI1.quantity = 0
 AND CI1.unit_of_measure = CI2.unit_of_measure
 AND CI1.ACTIVE_START_DATE <= SYSDATE
 AND CI1.ACTIVE_END_DATE IS NOT NULL AND  CI1.ACTIVE_END_DATE < SYSDATE
 AND NOT EXISTS (SELECT 'x' FROM CSI_II_RELATIONSHIPS CIR
 WHERE CIR.SUBJECT_ID = CI1.INSTANCE_ID
 AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
 AND ((CIR.ACTIVE_START_DATE IS NULL) OR (CIR.ACTIVE_START_DATE <= SYSDATE))
 AND ((CIR.ACTIVE_END_DATE IS NULL) OR (CIR.ACTIVE_END_DATE > SYSDATE)) );

 CURSOR dest_instance_csr1(p_wip_job_id IN NUMBER,
           p_source_instance_id IN NUMBER ) IS
 SELECT CI1.instance_id
 FROM CSI_ITEM_INSTANCES CI1, CSI_ITEM_INSTANCES CI2
 WHERE CI1.INV_MASTER_ORGANIZATION_ID= CI2.INV_MASTER_ORGANIZATION_ID
 AND CI1.INVENTORY_ITEM_ID = CI2.INVENTORY_ITEM_ID
 AND NVL(CI1.INVENTORY_REVISION,'x') = NVL(CI2.INVENTORY_REVISION,'x')
 AND NVL(CI1.LOT_NUMBER,'x') = NVL(CI2.LOT_NUMBER,'x')
 AND CI1.WIP_JOB_ID= p_wip_job_id
 AND CI1.instance_id <> CI2.instance_id
 AND CI2.instance_id = p_source_instance_id
 AND CI1.LOCATION_TYPE_CODE='WIP'
 AND NVL(CI1.INSTANCE_USAGE_CODE,'x') <> 'UNUSABLE'
 --AND CI1.quantity = 0
 AND CI1.unit_of_measure = CI2.unit_of_measure
 AND CI1.ACTIVE_START_DATE <= SYSDATE
 AND CI1.ACTIVE_END_DATE IS NOT NULL AND  CI1.ACTIVE_END_DATE < SYSDATE
 AND NOT EXISTS (SELECT 'x' FROM CSI_II_RELATIONSHIPS CIR
 WHERE CIR.SUBJECT_ID = CI1.INSTANCE_ID
 AND CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
 AND ((CIR.ACTIVE_START_DATE IS NULL) OR (CIR.ACTIVE_START_DATE <= SYSDATE))
 AND ((CIR.ACTIVE_END_DATE IS NULL) OR (CIR.ACTIVE_END_DATE > SYSDATE)) );

 l_copy_instance BOOLEAN;

BEGIN
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name ||'.begin',
			'At the start of PLSQL procedure'
		);
   END IF;

   l_copy_instance := TRUE;
   OPEN dest_instance_csr(p_dest_wip_job_id,p_source_instance_id );
   FETCH dest_instance_csr INTO l_dest_instance_rec.instance_id;
   IF(dest_instance_csr%FOUND)THEN
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
       (
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'Expired instance found'
       );
      END IF;
     l_copy_instance := FALSE;
   END IF;
   CLOSE dest_instance_csr;

   IF(l_copy_instance)THEN
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
       (
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'Searching for a dummy one'
       );
      END IF;
     OPEN dest_instance_csr1(p_dest_wip_job_id,p_source_instance_id );
     FETCH dest_instance_csr1 INTO l_dest_instance_rec.instance_id;
     IF(dest_instance_csr1%FOUND)THEN
       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
       (
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'Dummy instance found '
       );
      END IF;
      l_copy_instance := FALSE;
     END IF;
     CLOSE dest_instance_csr1;
   END IF;

   IF(l_copy_instance)THEN
     OPEN get_instance_attrib_csr(p_source_instance_id);
     FETCH get_instance_attrib_csr INTO l_source_instance_rec.instance_id,
                                      l_source_instance_rec.object_version_number,
                                      l_source_instance_rec.INVENTORY_REVISION,
                                      l_source_instance_rec.LOT_NUMBER,
                                      l_source_instance_rec.LOCATION_ID,
                                      l_source_instance_rec.INSTANCE_STATUS_ID;
     CLOSE get_instance_attrib_csr;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'l_source_instance_rec.instance_id ' || l_source_instance_rec.instance_id
		);
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'l_source_instance_rec.object_version_number ' || l_source_instance_rec.object_version_number
		);
	    fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'p_dest_quantity   ' || p_dest_quantity
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'p_dest_wip_job_id    ' || p_dest_wip_job_id
		);
      END IF;

     CSI_ITEM_INSTANCE_PUB.copy_item_instance
     (
      p_api_version            => 1.0
     ,p_commit                 => fnd_api.g_false
     ,p_init_msg_list          => fnd_api.g_true
     ,p_validation_level       => fnd_api.g_valid_level_full
     ,p_source_instance_rec    => l_source_instance_rec
     ,p_copy_ext_attribs       => fnd_api.g_true
     ,p_copy_org_assignments   => fnd_api.g_true
     ,p_copy_parties           => fnd_api.g_true
     ,p_copy_party_contacts    => fnd_api.g_true
     ,p_copy_accounts          => fnd_api.g_true
     ,p_copy_asset_assignments => fnd_api.g_true
     ,p_copy_pricing_attribs   => fnd_api.g_true
     ,p_copy_inst_children     => fnd_api.g_true
     ,p_txn_rec                => p_x_csi_transaction_rec
     ,x_new_instance_tbl       => l_new_instance_tbl
     ,x_return_status          => x_return_status
     ,x_msg_count              => l_msg_count
     ,x_msg_data               => l_msg_data
     );

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		  fnd_log.string
		  (
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'CSI_ITEM_INSTANCE_PUB.copy_item_instance returned error '
		  );
      END IF;
      RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'Instance copied successfully'
		);
	    fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'l_new_instance_tbl(1).instance_id : ' ||l_new_instance_tbl(1).instance_id
		);

     END IF;
     l_dest_instance_rec.instance_id := l_new_instance_tbl(1).instance_id;
   ELSE
     l_dest_instance_rec.active_end_date := NULL;
     l_dest_instance_rec.instance_usage_code := 'IN_WIP';

   END IF;

   OPEN get_instance_attrib_csr(l_dest_instance_rec.instance_id);
   FETCH get_instance_attrib_csr INTO l_dest_instance_rec.instance_id,
                                      l_dest_instance_rec.object_version_number,
                                      l_dest_instance_rec.INVENTORY_REVISION,
                                      l_dest_instance_rec.LOT_NUMBER,
                                      l_dest_instance_rec.LOCATION_ID,
                                      l_dest_instance_rec.INSTANCE_STATUS_ID;
   CLOSE get_instance_attrib_csr;

   -- if opening an expired instance
   IF(NOT l_copy_instance) THEN
     l_dest_instance_rec.INSTANCE_STATUS_ID := 510; -- as good as created
   END IF;

   l_dest_instance_rec.quantity := p_dest_quantity;
   l_dest_instance_rec.wip_job_id := p_dest_wip_job_id;


   update_csi_item_instance
   (
     p_instance_rec        => l_dest_instance_rec,
     p_x_csi_transaction_rec => p_x_csi_transaction_rec,
     x_Return_Status  => X_Return_Status
   );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		  fnd_log.string
		  (
			fnd_log.level_error,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name,
			'Updating copied instance loc: update_csi_item_instance returned error '
		  );
     END IF;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   x_dest_instance_id := l_dest_instance_rec.instance_id;


   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name ||'.begin',
			'At the end of PLSQL procedure'
		);
  END IF;

END create_similar_instance;

-- Function to get unit on visit or visit task.
FUNCTION Get_UnitConfig_ID(p_workorder_id IN NUMBER)
RETURN NUMBER IS

CURSOR get_vst_instance_csr (p_workorder_id IN NUMBER) IS

  SELECT
         NVL(VST.ITEM_INSTANCE_ID, VTS.INSTANCE_ID)
  FROM
        AHL_WORKORDERS AWOS,
        AHL_VISITS_B VST,
        AHL_VISIT_TASKS_B VTS
  WHERE
        AWOS.VISIT_TASK_ID = VTS.VISIT_TASK_ID   AND
        VST.VISIT_ID = VTS.VISIT_ID  AND
        WORKORDER_ID = p_workorder_id;

-- declare local variables here
l_item_instance_id NUMBER;
l_uc_header_id     NUMBER;

BEGIN
  IF p_workorder_id IS NULL
  THEN
     RETURN -1;
  END IF;

  OPEN get_vst_instance_csr(p_workorder_id);
  FETCH get_vst_instance_csr INTO l_item_instance_id;
  CLOSE get_vst_instance_csr;

  l_uc_header_id := AHL_UTIL_UC_PKG.get_uc_header_id(l_item_instance_id);

  RETURN l_uc_header_id;

END Get_UnitConfig_ID;

END; -- Package Body AHL_PRD_PART_CHANGE

/
