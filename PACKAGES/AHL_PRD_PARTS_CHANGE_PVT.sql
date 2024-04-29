--------------------------------------------------------
--  DDL for Package AHL_PRD_PARTS_CHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_PARTS_CHANGE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVPPCS.pls 120.2 2008/02/01 03:30:15 sikumar ship $ */
--
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: This package will do parts change processing
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Sangita Gupta 08/23/02
-- ---------   ------  ------------------------------------------


   Type Ahl_Parts_Rec_Type is Record (
                 Workorder_Id NUMBER
                 ,Operation_Sequence_Num NUMBER
                 ,workorder_operation_id NUMBER
                 ,Unit_Config_Header_Id NUMBER
                ,Unit_Config_Name  VARCHAR2(80)
                ,Unit_config_obj_ver_num Number --UC_HEADER_OBJ_VER_NUM
                 ,Mc_Relationship_Id NUMBER
                 ,Installed_Instance_Id   NUMBER
                ,Installed_Instance_Num   varchar2(30)
                ,Installed_Quantity NUMBER
                ,Installation_date  DATE
                ,Parent_Installed_Instance_Id   NUMBER
                ,Parent_Installed_Instance_Num   varchar2(30)
                ,Removed_Instance_Id  NUMBER
                ,Removed_Instance_Num  varchar2(30)--see in csi_item_instances
                ,Removed_Quantity NUMBER
                ,Removal_Code Varchar2(30)
                ,Removal_Meaning Varchar2(80)
                ,Removal_Reason_Id  Number
                ,Removal_Reason_Name varchar2(30)
                ,Removal_Date   Date
                --,Condition_Id  Number
                --,Condition Varchar2(80)
                --,Locator_id  NUMBER
                --,Locator_code varchar2(240)
                --,Subinventory_code   VarChar2(10)
                --,Severity_id Number
                --,Severity_name Varchar2(30)
                ,Csi_II_Relationship_Id   NUMBER
                ,CSI_II_OBJECT_VERSION_NUM NUMBER --Rel_Object_Version_Num
                --,Target_Visit_Num  NUMBER
                --,Target_Visit_Id NUMBER
                --,Problem_Code  varchar2(30)
                --,Problem_Meaning VARCHAR2(80)
                ,Operation_Type VARCHAR2(1)
                --,Summary VarChar2(80)
                --,estimated_duration number
                ,Installed_Instance_Obj_Ver_Num NUMBER
                ,Removed_INSTANCE_OBJ_VER_NUM   Number -- not sureif reqd
                ,Last_update_date   DATE
                ,Last_Update_by NUMBER
                ,Creation_date  DATE
                ,Created_by NUMBER
                ,Last_update_login  NUMBER
                --,collection_id      NUMBER
                --,NonRoutine_WO_ID   NUMBER
                --, Material_txn_id     Number
                ,Part_Change_Txn_Id  NUMBER
                ,path_position_id    NUMBER

);

Type Ahl_Parts_tbl_type is Table of Ahl_Parts_Rec_Type
        index by Binary_Integer;

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Process_part
--  Type        : Private
--  Function    : Manages Parts change operations such as install, swap and return.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Process_Parts Parameters :
--
--    p_x_parts_rec_tbl                   IN OUT   Ahl_Parts_rec_Type  Required
 --   Unit_Config_Header_Id      Optional- Decides whether a part is UC or IB config.
--    Unit_Config_Header_Name    Optional - Decides whether a part is UC or IB config.
--    Target_Visit_Number       Optional. Needed when an SR is created.
--    Target_Visit_Id           Optional. Either number or ID should be sent for an SR creation.
--    Problem_Code              Required when returning an unserviceable item. If problem meaning exists then derived.
--    Problem_Meaning           Required when returning an unserviceable item.
--    Removed_Instance_Number   Required when returning a part.
--    Removed_Instance_Id       Derivable. Either number or ID should be sent if returning a part.
--    MC_Relationship_id        Required when removing, installing or swapping a UC part.(Same as position)
--    Removal_Code              Required when removing a part.
--    Removal_Reason_Id            Required when removing a part.
--    Condition                 Required when returning.
--    Parent_Installed_Instance_Id   Required when performing an installation
--    Installed_Instance_Id   Required when performing an installation
--    Relationship_Id           Required when performing an installation
--    Operation_Sequence_Num        Required
--    Ahl_Wo_Id                 Required
--    Rel_Object_Version_Number  Required for swap or return
--    Locator                   Required if Subinventory is selected
--    Subinventory            Optional
--    Operation_Type          C - for Create, S - for Swap and D - for delete.
--    Summary                  Required if creating an SR
--   Installed_Instance_Obj_Ver_Num Required if installing a part
--    SWAPPED_INSTANCE_OBJ_VER_NUM		Required only for swapping. This is the object version number of the replaced item.
--    UC_HEADER_OBJ_VER_NUM		Required.  This is the object version number of the UC header record. This is neded for UC status updates.
-- Csi_II_Relationship_Id   Required for part return. Must be null for install.
--    Last_update_date          Required (SYSDATE)
--    Last_Update_by            Required
--     Creation_date            Required
--    Created_by                Required
--      Last_update_login       Required

--      NonRoutine_WO_ID        Out parameter from SR
--
--      Material_Txn_id              Out parameter from Material Transaction.
--    Part_Change_Txn_Id        Generated

--
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

   Procedure process_part (
  P_API_Version        In  Number Default  1.0,
  P_Init_Msg_List      In  Varchar2 Default Fnd_API.G_False,
  P_Commit             In  Varchar2 Default Fnd_API.G_False,
  P_Validation_Level   In  Number   Default Fnd_API.G_Valid_Level_Full,
  p_module_type        In  VarChar2  Default NULL,
  p_default            In  Varchar2  Default FND_API.G_TRUE,
  p_x_parts_rec_tbl    In  Out nocopy Ahl_Parts_tbl_type,
  X_Error_Code         Out NOCOPY Varchar2,
  X_Return_Status      Out NOCOPY Varchar2,
  X_Msg_Count          Out NOCOPY Number,
  X_Msg_Data           Out NOCOPY Varchar2,
  x_warning_msg_tbl    OUT NOCOPY ahl_uc_validation_pub.error_tbl_type );

 -- Obtain Config header id given the item_instance_id
 -- Fix for bug# 5564026. Added workorder_id.
 -- Er# 5660658: Added p_validation_mode parameter. This takes 2 values
 -- PARTS_CHG and UPDATE_UC.
 procedure get_unit_config_information(
 p_item_instance_id In number,
 p_workorder_id     In  Number,
 p_validation_mode  In  varchar2 := 'PARTS_CHG',
 x_unit_config_id   Out NOCOPY number,
 x_unit_config_name Out NOCOPY Varchar2,
 --x_unit_config_obj_version_num Out NOCOPY number,
 x_return_status    Out NOCOPY Varchar2);




-- Update Material Return txn if item returned using Material Transactions.
PROCEDURE Update_Material_Return (p_return_mtl_txn_id  IN NUMBER,
                                  p_workorder_id       IN NUMBER,
                                  p_Item_Instance_Id   IN  NUMBER,
                                  x_return_status  OUT NOCOPY VARCHAR2);


-- Added for ER 5854712.
-- Procedure will return removed instance to Visit-Workorder locator.
PROCEDURE ReturnTo_Workorder_Locator( p_init_msg_list   IN            VARCHAR2 := FND_API.G_FALSE,
                                      p_commit          IN            VARCHAR2 := FND_API.G_FALSE,
                                      p_part_change_id  IN            NUMBER,
                                      p_disposition_id  IN            NUMBER,
                                      x_return_status      OUT NOCOPY VARCHAR2,
                                      x_msg_data           OUT NOCOPY VARCHAR2,
                                      x_msg_count          OUT NOCOPY NUMBER,
                                      x_ahl_mtltxn_rec     OUT NOCOPY AHL_PRD_MTLTXN_PVT.Ahl_Mtltxn_Rec_Type);

TYPE move_item_instance_rec_type IS RECORD(
  instance_id            Number,
  instance_number        Varchar2(30),
  quantity               Number,
  from_workorder_id      Number,
  from_workorder_number  Varchar2(80),
  to_workorder_id        Number,
  to_workorder_number    Varchar2(80)
  );

TYPE move_item_instance_tbl_type is Table of move_item_instance_rec_type
        index by Binary_Integer;

-- Procedure to move item instances between work orders.
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
  X_Msg_Data               Out NOCOPY Varchar2);

FUNCTION Get_UnitConfig_ID(p_workorder_id IN NUMBER) RETURN NUMBER;


end;---- Package Specification AHL_PRD_PARTS_CHANGE_PVT

/
