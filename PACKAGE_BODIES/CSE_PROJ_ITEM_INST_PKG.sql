--------------------------------------------------------
--  DDL for Package Body CSE_PROJ_ITEM_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_PROJ_ITEM_INST_PKG" AS
-- $Header: CSEITINB.pls 115.40 2003/09/22 16:05:45 stutika ship $

l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('CSE_DEBUG_OPTION'),'N');
PROCEDURE Decode_Message(
   P_Msg_Header             IN         XNP_MESSAGE.Msg_Header_Rec_Type,
   P_Msg_Text               IN         VARCHAR2,
   X_Proj_Item_Inst_Attr_Rec    OUT NOCOPY Proj_Item_Inst_Attr_Rec_Type,
   X_Return_Status          OUT NOCOPY VARCHAR2,
   X_Error_Message          OUT NOCOPY VARCHAR2) IS

   l_Api_Name            CONSTANT  VARCHAR2(30) := 'CSE_PROJ_ITEM_INST_PKG';
   l_Item_Id                NUMBER;
   l_Revision               VARCHAR2(3);
   l_Lot_Number             VARCHAR2(30);
   l_Serial_Number          VARCHAR2(30);
   l_Quantity               NUMBER;
   l_Netwk_Locn_id          NUMBER;
   l_party_site_id          NUMBER;
   l_Work_Order_Number      VARCHAR2(30);
   l_Project_Id             NUMBER;
   l_Task_Id                NUMBER;
   l_Transaction_Date       DATE;
   l_Transaction_Date_Str   VARCHAR2(30);
   l_Transacted_By          NUMBER;

BEGIN

   X_Return_Status  := FND_API.G_RET_STS_SUCCESS;
   X_Error_Message  := Null;

   Xnp_Xml_Utils.Decode(P_Msg_Text,'ITEM_ID',l_Item_Id);
   Xnp_Xml_Utils.Decode(P_Msg_Text,'REVISION',l_Revision);
   Xnp_Xml_Utils.Decode(P_Msg_Text,'LOT_NUMBER',l_Lot_Number);
   Xnp_Xml_Utils.Decode(P_Msg_Text,'SERIAL_NUMBER',l_Serial_Number);
   Xnp_Xml_Utils.Decode(P_Msg_Text,'QUANTITY',l_Quantity);
   Xnp_Xml_Utils.Decode(P_Msg_Text,'NETWORK_LOC_ID',l_Netwk_Locn_id);
   Xnp_Xml_Utils.Decode(P_Msg_Text,'PARTY_SITE_ID',l_party_site_id);
   Xnp_Xml_Utils.Decode(P_Msg_Text,'WORK_ORDER_NUMBER',l_Work_Order_Number);
   Xnp_Xml_Utils.Decode(P_Msg_Text,'PROJECT_ID',l_Project_Id);
   Xnp_Xml_Utils.Decode(P_Msg_Text,'TASK_ID',l_Task_Id);
   Xnp_Xml_Utils.Decode(P_Msg_Text,'TRANSACTION_DATE',l_Transaction_Date_Str);
   Xnp_Xml_Utils.Decode(P_Msg_Text,'TRANSACTED_BY',l_Transacted_By);

   X_Proj_Item_Inst_Attr_Rec.Item_Id               := l_Item_Id;
   X_Proj_Item_Inst_Attr_Rec.Revision              := l_Revision;
   X_Proj_Item_Inst_Attr_Rec.Lot_Number            := l_Lot_Number;
   X_Proj_Item_Inst_Attr_Rec.Serial_Number         := l_Serial_Number;
   X_Proj_Item_Inst_Attr_Rec.Quantity              := l_Quantity;
   X_Proj_Item_Inst_Attr_Rec.Network_Location_id   := l_Netwk_Locn_id;
   X_Proj_Item_Inst_Attr_Rec.Party_site_id         := l_party_site_id;
   X_Proj_Item_Inst_Attr_Rec.Work_Order_Number     := l_Work_Order_Number;
   X_Proj_Item_Inst_Attr_Rec.Project_Id            := l_Project_Id;
   X_Proj_Item_Inst_Attr_Rec.Task_Id               := l_Task_Id;
   X_Proj_Item_Inst_Attr_Rec.Transaction_Date      := TO_DATE(l_Transaction_Date_Str, 'YYYY/MM/DD HH24:MI:SS');
   X_Proj_Item_Inst_Attr_Rec.Transacted_By         := l_Transacted_By;
   X_Proj_Item_Inst_Attr_Rec.Message_id            := P_Msg_Header.Message_Id;

EXCEPTION

 WHEN OTHERS THEN
  fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
  fnd_message.set_token('ERR_MSG',l_Api_Name||'='|| SQLERRM);
  x_error_message := fnd_message.get;
  x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Decode_Message;

PROCEDURE Update_Ib_Repository(
   P_Proj_Item_Inst_Attr_Rec   IN  Proj_Item_Inst_Attr_Rec_Type,
   X_Return_Status          OUT NOCOPY VARCHAR2,
   X_Error_Message          OUT NOCOPY VARCHAR2) IS

   l_Api_Name            CONSTANT  VARCHAR2(30) := 'CSE_PROJ_ITEM_INST_PKG';
   l_api_version                   NUMBER		 DEFAULT    1.0;
   l_Commit                        VARCHAR2(1)	 DEFAULT 	FND_API.G_FALSE;
   l_Init_Msg_List         	       VARCHAR2(1)	 DEFAULT    FND_API.G_TRUE;
   l_Create_Dest_Inst_Flag         VARCHAR2(1)   DEFAULT    FND_API.G_FALSE;
   l_Instance_Header_Tbl_Out       csi_datastructures_pub.instance_header_tbl;
   l_Instance_Rec	               csi_datastructures_pub.Instance_Rec;
   l_Dest_Instance_Rec             csi_datastructures_pub.Instance_Rec;
   l_Instance_Query_Rec            csi_datastructures_pub.Instance_Query_Rec;
   l_txn_rec                       csi_datastructures_pub.transaction_rec;
   L_upd_txn_rec                   csi_datastructures_pub.transaction_rec;
   l_Active_Instance_Only          VARCHAR2(1) DEFAULT FND_API.G_FALSE;
   l_ext_attrib_values_tbl         csi_datastructures_pub.extend_attrib_values_tbl;
   l_Party_Query_Rec               csi_datastructures_pub.party_query_rec;
   l_party_tbl                     csi_datastructures_pub.party_tbl;
   l_account_tbl                   csi_datastructures_pub.party_account_tbl;
   l_pricing_attrib_tbl            csi_datastructures_pub.pricing_attribs_tbl;
   l_org_assignments_tbl           csi_datastructures_pub.organization_units_tbl;
   l_asset_assignment_tbl          csi_datastructures_pub.instance_asset_tbl;
   l_Instance_Id_Lst               csi_datastructures_pub.Id_Tbl;
   l_msg_index                     NUMBER;
   i                               PLS_INTEGER;
   l_S_object_version_number       NUMBER :=1;
   l_D_object_version_number       NUMBER :=1;
   l_object_version_number         NUMBER :=1;
   l_Msg_Count             	       NUMBER;
   l_Msg_Data              	       VARCHAR2(2000);
   l_Account_Query_Rec             csi_datastructures_pub.party_account_query_rec;
   l_Validation_Level              NUMBER   := fnd_api.g_valid_level_full;
   l_Transaction_Id                NUMBER;
   l_Resolve_Id_Columns            VARCHAR2(1)   DEFAULT    FND_API.G_FALSE;
   l_Return_Status                 VARCHAR2(1);
   l_Error_Message                 VARCHAR2(2000);
   l_Hz_Location_Id                NUMBER;
   l_Location_Type_Code            VARCHAR2(30) ;
   l_Transaction_Type_Id           NUMBER;
   l_App_Short_Name      CONSTANT  VARCHAR2(10):='CSE';
   l_Source_Quantity               NUMBER;
   l_Source_Instance_Id            NUMBER;
   l_s_mfg_serial_number_flag      VARCHAR2(1);
   l_Instance_Status               VARCHAR2(30);
   l_S_Inv_Master_Organization_Id  NUMBER;
   l_Inv_Organization_Id           NUMBER;
   l_Source_Unit_Of_Measure        VARCHAR2(3);
   l_s_last_vld_organization_id    NUMBER;
   l_Txn_Status                    VARCHAR2(20);
   l_sysdate                       DATE:=sysdate;
   l_Source_Transaction_Id         NUMBER;
   l_file                          VARCHAR2(500);
   l_exp_status_id                 NUMBER;
   l_s_status_id                   NUMBER;
   l_depreciable                   VARCHAR2(1);
   l_Transaction_Status_Code       VARCHAR2(30);
   l_s_project_id                  NUMBER;
   l_s_task_id                     NUMBER;
   t_transaction_id                NUMBER := -1;
   CURSOR inst_status_cur IS
   SELECT instance_status_id
   FROM csi_instance_statuses
   WHERE upper(name) ='EXPIRED';
   Update_Ib_Exp                   EXCEPTION;

BEGIN
   X_Return_Status         := FND_API.G_RET_STS_SUCCESS;
   X_Error_Message         := Null;
 -- l_Network_Location_Code := P_Proj_Item_Inst_Attr_Rec.Network_Location_Code;
    If P_Proj_Item_Inst_Attr_Rec.Network_Location_id is not null then
      l_hz_location_id    :=P_Proj_Item_Inst_Attr_Rec.Network_Location_id ;
      l_location_type_code:='HZ_LOCATIONS';
    elsif  P_Proj_Item_Inst_Attr_Rec.party_site_id is not null  then
      l_hz_location_id :=P_Proj_Item_Inst_Attr_Rec.party_site_id ;
      l_location_type_code:='HZ_PARTY_SITES';
    end if;

  l_Transaction_Type_Id   := CSE_UTIL_PKG.Get_Txn_Type_ID
                             ('PROJECT_ITEM_INSTALLED',
                              l_App_Short_Name);

-- If the option is set turn on the debug log.

IF (l_debug = 'Y') THEN
 cse_debug_pub.g_dir  := nvl(FND_PROFILE.VALUE('CSE_DEBUG_LOG_DIRECTORY'), '/tmp');
 cse_debug_pub.g_file := NULL;
 l_file := cse_debug_pub.set_debug_file('cse' || to_char(l_sysdate, 'DD-MON-YYYY') || '.log');
 cse_debug_pub.debug_on;
END IF;

 IF (l_debug = 'Y') THEN
    CSE_DEBUG_PUB.ADD('**** PROJECT ITEM INSTALLED TRANSACTION ******');
    CSE_DEBUG_PUB.ADD('-----------------------------------------------');
 END IF;
  --Step 1, Get Hz Location id

  -- CSE_DEBUG_PUB.ADD('Calling  get_hz_location');

 --  CSE_UTIL_PKG.Get_Hz_Location(
--   P_Network_Location_Code  => l_Network_Location_Code,
--   X_Hz_Location_Id         => l_Hz_Location_Id,
 --  X_Return_Status          => l_Return_Status,
 -- X_Error_Message          => l_Error_Message);

 --  IF NOT(l_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
--     RAISE Update_Ib_Exp;
--   END IF;

--check whether the the item is depreciable
 IF (l_debug = 'Y') THEN
    CSE_DEBUG_PUB.ADD('before cse_util_pkg.check_depreciable');
 END IF;
       cse_util_pkg.check_depreciable(
       p_inventory_item_id => P_Proj_Item_Inst_Attr_Rec.Item_Id,
       p_depreciable       =>l_depreciable);
  IF l_depreciable='Y' THEN
  IF (l_debug = 'Y') THEN
     CSE_DEBUG_PUB.ADD('item is depreciable');
  END IF;
   l_Transaction_Status_Code :=CSE_DATASTRUCTURES_PUB.G_PENDING;
  ELSE
   IF (l_debug = 'Y') THEN
      CSE_DEBUG_PUB.ADD('item is not depreciable');
   END IF;
  l_Transaction_Status_Code :=CSE_DATASTRUCTURES_PUB.G_COMPLETE;
  END IF;

   --Step 2, Query for the existence of the source record

   IF (l_debug = 'Y') THEN
      CSE_DEBUG_PUB.ADD('Initailizing Query Record for the source item instance - step2');
   END IF;

   l_Instance_Query_Rec  := CSE_UTIL_PKG.Init_Instance_Query_Rec;
   l_Instance_Query_Rec.Inventory_Item_Id := P_Proj_Item_Inst_Attr_Rec.Item_Id;
   l_Instance_Query_Rec.Inventory_Revision:= P_Proj_Item_Inst_Attr_Rec.Revision;
   l_Instance_Query_Rec.Lot_Number := P_Proj_Item_Inst_Attr_Rec.Lot_Number;
   l_Instance_Query_Rec.Serial_Number:= P_Proj_Item_Inst_Attr_Rec.Serial_Number;
   l_Instance_Query_Rec.Pa_Project_Id:= P_Proj_Item_Inst_Attr_Rec.project_id;
   l_Instance_Query_Rec.Pa_Project_Task_Id:= P_Proj_Item_Inst_Attr_Rec.Task_Id;
   l_Instance_Query_Rec.Instance_Usage_Code:= CSE_DATASTRUCTURES_PUB.G_IN_PROCESS;

   IF (l_debug = 'Y') THEN
      CSE_DEBUG_PUB.ADD(l_Api_Name||' Before CSI_Item_Instance_Pub.Get_Item_Instance');
   END IF;

   CSI_Item_Instance_Pub.Get_Item_Instances(
      p_api_version		=>l_api_version,
      p_commit 		        =>l_Commit,
      p_init_msg_list       	=>l_Init_Msg_List,
      p_validation_level        =>l_Validation_Level,
      p_instance_Query_rec      =>l_Instance_Query_Rec,
      p_party_query_rec         =>l_Party_Query_Rec,
      p_account_query_rec       =>l_account_query_rec,
      p_active_instance_only 	=>l_Active_Instance_Only,
      x_Instance_Header_Tbl     =>l_Instance_Header_Tbl_Out,
      p_transaction_id          =>l_transaction_id,
      p_resolve_id_columns      =>l_resolve_id_columns,
      x_return_status       	=>l_Return_Status,
      x_msg_count            	=>l_Msg_Count,
      x_msg_data             	=>l_Msg_Data );


  -- get the error message from the stack if there is any error

   IF NOT (l_Return_Status = FND_API.G_Ret_Sts_Success)  THEN
	l_msg_index := 1;
    l_Error_Message:=l_msg_data;
    WHILE l_msg_count > 0 LOOP
	  l_Error_Message := FND_MSG_PUB.GET(l_msg_index,FND_API.G_FALSE);
	  l_msg_index := l_msg_index + 1;
      	  l_Msg_Count := l_Msg_Count - 1;
    END LOOP;
     RAISE Update_Ib_Exp;
   END IF;

  --raise exception if the source record is not found

  IF(l_Instance_Header_Tbl_Out.COUNT=0) THEN
      fnd_message.set_name('CSE','CSE_SRC_RECORD_NOTFOUND');
      fnd_message.set_token('ITEM',P_Proj_Item_Inst_Attr_Rec.Item_Id);
      l_error_message := fnd_message.get;
      l_Return_Status := FND_API.G_RET_STS_ERROR;
      RAISE Update_Ib_Exp;
   END IF;

   -- check if there exist multiple source instances

   IF(l_Instance_Header_Tbl_Out.COUNT>1) THEN
      fnd_message.set_name('CSE','CSE_SRC_MULTIPLE_ITM_INSTANCES');
      fnd_message.set_token('ITEM',P_Proj_Item_Inst_Attr_Rec.Item_Id);
      l_error_message := fnd_message.get;
      l_Return_Status := FND_API.G_RET_STS_ERROR;
      RAISE Update_Ib_Exp;
   END IF;

   -- continue if there exist only one source item instance

    IF(l_Instance_Header_Tbl_Out.COUNT=1) THEN
      i  :=l_Instance_Header_Tbl_Out.FIRST;
      l_Source_Quantity :=l_Instance_Header_Tbl_Out(i).Quantity;
      l_source_unit_of_measure  :=l_Instance_Header_Tbl_Out(i).Unit_Of_Measure;
      l_Source_Instance_id      :=l_Instance_Header_Tbl_Out(i).Instance_Id;
      l_S_Inv_Master_Organization_Id:=l_Instance_Header_Tbl_Out(i).Inv_Master_Organization_Id;
      l_Inv_Organization_Id :=l_Instance_Header_Tbl_Out(i).Inv_Organization_Id;
      l_S_object_version_number:=l_Instance_Header_Tbl_Out(i).object_version_number;
      l_s_mfg_serial_number_flag :=l_Instance_Header_Tbl_Out(i).mfg_serial_number_flag;
      l_s_status_id :=l_Instance_Header_Tbl_Out(i).instance_status_id;
      l_s_last_vld_organization_id :=l_Instance_Header_Tbl_Out(i).vld_organization_id;
      l_s_project_id :=l_Instance_Header_Tbl_Out(i).pa_project_id;
      l_s_task_id    :=l_Instance_Header_Tbl_Out(i).pa_project_task_id;


   -- Step 3,Check if the txn_qty is more than source item instance qty

   IF(P_Proj_Item_Inst_Attr_Rec.Quantity >
      l_Instance_Header_Tbl_Out(i).Quantity)  THEN
      fnd_message.set_name('CSE','CSE_SRC_ITEM_QUANTITY');
      fnd_message.set_token('ITEM',P_Proj_Item_Inst_Attr_Rec.Item_Id);
      l_error_message := fnd_message.get;
      l_Return_Status := FND_API.G_RET_STS_ERROR;
      RAISE Update_Ib_Exp;
   END IF;


   --Step 4,If the Item is serialized,

    IF(P_Proj_Item_Inst_Attr_Rec.Serial_Number IS NOT NULL) THEN


       IF (l_debug = 'Y') THEN
          CSE_DEBUG_PUB.ADD('Initailizing instance Record for update of serialized item inst- step4');
       END IF;

       l_Instance_Rec := CSE_UTIL_PKG.Init_Instance_Update_Rec;
       l_Instance_Rec.Instance_Id := l_Source_Instance_Id;
       l_Instance_Rec.Instance_Usage_Code := CSE_DATASTRUCTURES_PUB.G_INSTALLED;
       l_Instance_Rec.Install_Location_Type_Code:=l_Location_Type_Code;
       l_Instance_Rec.Install_Location_Id   :=l_Hz_Location_Id;
       l_Instance_Rec.Location_Type_Code    :=l_Location_Type_Code;
       l_Instance_Rec.Location_Id           :=l_Hz_Location_Id;
       l_Instance_Rec.pa_project_id         :=null;
       l_Instance_Rec.pa_project_task_id    :=null;
       l_Instance_Rec.last_pa_project_id    :=l_s_project_id;
       l_Instance_Rec.last_pa_task_id       :=l_s_task_id;
       l_Instance_Rec.object_version_number :=l_S_object_version_number;
       l_Txn_Rec  := CSE_UTIL_PKG.Init_Txn_Rec;
       l_Txn_Rec.Transaction_Date  := l_sysdate;
       l_Txn_Rec.Source_transaction_date :=P_Proj_Item_Inst_Attr_Rec.Transaction_Date;
       l_Txn_Rec.Transaction_Type_Id :=l_Transaction_Type_Id;
       l_Txn_Rec.Source_Group_Ref:= P_Proj_Item_Inst_Attr_Rec.Work_Order_Number;
       l_Txn_Rec.Transaction_Quantity := P_Proj_Item_Inst_Attr_Rec.Quantity;
       l_Txn_Rec.Transacted_By := P_Proj_Item_Inst_Attr_Rec.Transacted_By;
       l_Txn_Rec.Transaction_Status_Code    := l_Transaction_Status_Code;
       l_Txn_Rec.Message_Id := P_Proj_Item_Inst_Attr_Rec.Message_Id;
       l_Txn_Rec.Object_Version_Number := l_S_object_version_number;
       l_txn_rec.transaction_action_code :=  NULL;
       IF NOT t_transaction_id = -1 THEN
         l_txn_rec.transaction_id := t_transaction_id;
       END IF;


       IF (l_debug = 'Y') THEN
          CSE_DEBUG_PUB.ADD('Before update of serialized item instanace');
       END IF;


       CSI_Item_Instance_Pub.Update_Item_Instance(
      		p_api_version=>	l_api_version,
      		p_commit => l_Commit,
                p_validation_level=> l_Validation_Level,
      		p_init_msg_list =>l_Init_Msg_List,
      		p_instance_rec  => l_Instance_Rec,
                p_ext_attrib_values_tbl  => l_ext_attrib_values_tbl,
                p_party_tbl => l_party_tbl,
                p_account_tbl=> l_account_tbl,
                p_pricing_attrib_tbl => l_pricing_attrib_tbl,
                p_org_assignments_tbl=> l_org_assignments_tbl,
      		p_txn_rec    =>	l_Txn_Rec,
                p_asset_assignment_tbl   => l_asset_assignment_tbl,
		x_instance_id_lst =>l_instance_id_lst,
      		x_return_status =>l_Return_Status,
      		x_msg_count     =>l_Msg_Count,
      		x_msg_data      =>l_Msg_Data );


  -- get the error message from the stack if there is any error

  IF NOT (l_Return_Status = FND_API.G_Ret_Sts_Success) THEN
	l_msg_index := 1;
    	l_Error_Message:=l_msg_data;
    WHILE l_msg_count > 0 LOOP
	l_Error_Message := FND_MSG_PUB.GET(l_msg_index,FND_API.G_FALSE);
	l_msg_index := l_msg_index + 1;
        l_Msg_Count := l_Msg_Count - 1;
    END LOOP;
     RAISE Update_Ib_Exp;
  ELSIF l_Return_Status = FND_API.G_Ret_Sts_Success THEN
        IF t_transaction_id =-1 THEN
           t_transaction_id := l_txn_rec.transaction_id;
        END IF;
  END IF;
 END IF;

-- Step 5  ,if the item is non serialized

 IF(P_Proj_Item_Inst_Attr_Rec.Serial_Number IS  NULL) THEN

--Step 5.1 ,Check for the existence of the destination record

   IF (l_debug = 'Y') THEN
      CSE_DEBUG_PUB.ADD('Initailizing Query Record for the destination instance - step5.1');
   END IF;

   l_Instance_Query_Rec := CSE_UTIL_PKG.Init_Instance_Query_Rec;
   l_Instance_Query_Rec.Inventory_Item_Id := P_Proj_Item_Inst_Attr_Rec.Item_Id;
   l_Instance_Query_Rec.Inventory_Revision:= P_Proj_Item_Inst_Attr_Rec.Revision;
   l_Instance_Query_Rec.Lot_Number := P_Proj_Item_Inst_Attr_Rec.Lot_Number;
   l_Instance_Query_Rec.Serial_Number:= P_Proj_Item_Inst_Attr_Rec.Serial_Number;
   l_Instance_Query_Rec.last_Pa_Project_Id:= P_Proj_Item_Inst_Attr_Rec.project_id;
   l_Instance_Query_Rec.last_pa_Task_Id := P_Proj_Item_Inst_Attr_Rec.Task_Id;
   l_Instance_Query_Rec.Location_Id := l_Hz_Location_Id;
   l_Instance_Query_Rec.Location_Type_Code:= l_Location_Type_Code;
   l_Instance_Query_Rec.Instance_Usage_Code:=CSE_DATASTRUCTURES_PUB.G_INSTALLED;

   l_Active_Instance_Only := FND_API.G_FALSE;

   IF (l_debug = 'Y') THEN
      CSE_DEBUG_PUB.ADD('Before querying for the existence of destination record');
   END IF;

   CSI_Item_Instance_Pub.Get_Item_Instances(
      p_api_version		=>  l_api_version,
      p_commit 		        =>  l_Commit,
      p_init_msg_list       	=>  l_Init_Msg_List,
      p_validation_level        =>  l_Validation_Level,
      p_instance_Query_rec      =>  l_Instance_Query_Rec,
      p_party_query_rec         =>  l_Party_Query_Rec,
      p_account_query_rec       =>  l_account_query_rec,
      p_active_instance_only 	=>  l_Active_Instance_Only,
      p_transaction_id          =>  l_transaction_id,
      p_resolve_id_columns      =>  l_resolve_id_columns,
      x_Instance_Header_Tbl     =>  l_Instance_Header_Tbl_Out,
      x_return_status       	=>  l_Return_Status,
      x_msg_count            	=>  l_Msg_Count,
      x_msg_data             	=>  l_Msg_Data );

   -- get the error message from the stack if there is any error

   IF NOT (l_Return_Status = FND_API.G_Ret_Sts_Success)  THEN
	l_msg_index := 1;
        l_Error_Message:=l_msg_data;
    WHILE l_msg_count > 0 LOOP
	  l_Error_Message := FND_MSG_PUB.GET(l_msg_index,FND_API.G_FALSE);
	  l_msg_index := l_msg_index + 1;
          l_Msg_Count := l_Msg_Count - 1;
    END LOOP;
     RAISE Update_Ib_Exp;
   END IF;

 -- update source instance quantity

      IF (l_debug = 'Y') THEN
         CSE_DEBUG_PUB.ADD('Initailizing instance Record for update of source qty - step5.3');
      END IF;

       l_Instance_Rec  := CSE_UTIL_PKG.Init_Instance_Update_Rec;
       l_Instance_Rec.Instance_Id := l_Source_instance_id;
       l_Instance_Rec.Quantity    := (l_Source_Quantity -
                                      P_Proj_Item_Inst_Attr_Rec.Quantity);
       l_Instance_Rec.Active_End_Date :=Null;
       l_Instance_Rec.Object_version_number :=l_S_object_version_number;
       l_Party_tbl.delete;
       l_Txn_Rec := CSE_UTIL_PKG.Init_Txn_Rec;
       l_Txn_Rec.Transaction_Date := l_sysdate;
       l_Txn_Rec.Transaction_Type_Id  := l_Transaction_Type_Id;
       l_Txn_Rec.Source_Transaction_Date := P_Proj_Item_Inst_Attr_Rec.Transaction_Date;
       l_Txn_Rec.Source_Group_Ref:= P_Proj_Item_Inst_Attr_Rec.Work_Order_Number;
       l_Txn_Rec.Transaction_Quantity := P_Proj_Item_Inst_Attr_Rec.Quantity;
       l_Txn_Rec.Transacted_By := P_Proj_Item_Inst_Attr_Rec.Transacted_By;
       l_Txn_Rec.Transaction_Status_Code    := l_Transaction_Status_Code;
       l_Txn_Rec.Transaction_Action_Code    := Null;
       l_Txn_Rec.Message_Id := P_Proj_Item_Inst_Attr_Rec.Message_Id;
       IF NOT t_transaction_id = -1 THEN
          l_txn_rec.transaction_id := t_transaction_id;
       END IF;

       IF (l_debug = 'Y') THEN
          CSE_DEBUG_PUB.ADD('Before update of source instanace qty - step 5.3');
       END IF;

       CSI_Item_Instance_Pub.Update_Item_Instance(
      		p_api_version	         => l_api_version,
      		p_commit 		 => l_Commit,
                p_validation_level       => l_Validation_Level,
      		p_init_msg_list          => l_Init_Msg_List,
      		p_instance_rec           => l_Instance_Rec,
                p_ext_attrib_values_tbl  => l_ext_attrib_values_tbl,
                p_party_tbl              => l_party_tbl,
                p_account_tbl            => l_account_tbl,
                p_pricing_attrib_tbl     => l_pricing_attrib_tbl,
                p_org_assignments_tbl    => l_org_assignments_tbl,
      		p_txn_rec                => l_Txn_Rec,
                p_asset_assignment_tbl   => l_asset_assignment_tbl,
		x_instance_id_lst	 => l_instance_id_lst,
      		x_return_status       	 => l_Return_Status,
      		x_msg_count            	 => l_Msg_Count,
                x_Msg_data               => l_Msg_Data);


   -- get the error message from the stack if there is any error

   IF NOT(l_Return_Status = FND_API.G_Ret_Sts_Success) THEN
	l_msg_index := 1;
        l_Error_Message:=l_Msg_Data;
    WHILE l_msg_count > 0 LOOP
	  l_Error_Message := FND_MSG_PUB.GET(l_msg_index,FND_API.G_FALSE);
	  l_msg_index := l_msg_index + 1;
          l_Msg_Count := l_Msg_Count - 1;
    END LOOP;
     RAISE Update_Ib_Exp;
   ELSIF (l_Return_Status = FND_API.G_Ret_Sts_Success) THEN
       IF t_transaction_Id = -1 THEN
          t_transaction_id := l_txn_rec.transaction_id;
       END IF;
   END IF;
    l_upd_txn_rec                  := l_txn_rec;

IF(l_Instance_Header_Tbl_Out.COUNT>0) THEN

   cse_util_pkg.get_destination_instance(
     P_Dest_Instance_tbl  => l_Instance_Header_Tbl_Out,
     X_Instance_Rec       => l_Dest_Instance_Rec,
     X_Return_Status      => l_Return_Status,
     X_Error_Message      => l_Error_Message);


  IF NOT(l_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
   RAISE Update_Ib_Exp;
  END IF;


-- If destination item instance is found

  IF l_Dest_Instance_Rec.Instance_id IS NOT NULL THEN
  l_D_object_version_number:=l_Dest_Instance_Rec.object_version_number;


   IF (l_debug = 'Y') THEN
      CSE_DEBUG_PUB.ADD('Initailizing instance Record for update Of dest inst - step5.1');
   END IF;

    l_Instance_Rec := CSE_UTIL_PKG.Init_Instance_Update_Rec;
    l_Instance_Rec.Instance_Id  := l_Dest_Instance_Rec.Instance_Id;
    l_Instance_Rec.Quantity  := (P_Proj_Item_Inst_Attr_Rec.Quantity +
                                            l_Dest_Instance_Rec.Quantity );
    l_Instance_Rec.Active_End_Date      := Null;
    l_Instance_Rec.Object_version_Number:=l_D_Object_Version_Number;

-- check if destination instance is expired ,if expired then set the status same as source.

    FOR inst_status_cur_rec in inst_status_cur
    LOOP
     IF (inst_status_cur_rec.instance_status_id=l_Dest_Instance_Rec.Instance_status_id)
      THEN
        l_Instance_Rec.instance_status_id :=l_s_status_id;
      END IF;
    END LOOP;
    l_Txn_Rec  :=CSE_UTIL_PKG.Init_Txn_Rec;
    l_Txn_Rec.Transaction_Date  :=l_sysdate;
    l_Txn_Rec.Source_Transaction_Date :=P_Proj_Item_Inst_Attr_Rec.Transaction_Date;
    l_Txn_Rec.Transaction_Type_Id  :=L_Transaction_Type_Id;
    l_Txn_Rec.Source_Group_Ref :=P_Proj_Item_Inst_Attr_Rec.Work_Order_Number;
    l_Txn_Rec.source_dist_ref_id2  :=l_upd_txn_rec.transaction_id;
    IF (l_debug = 'Y') THEN
       CSE_DEBUG_PUB.ADD('source txn id-'||l_upd_txn_rec.transaction_id);
    END IF;
    l_Txn_Rec.Transaction_Quantity :=P_Proj_Item_Inst_Attr_Rec.Quantity;
    l_Txn_Rec.Transacted_By :=P_Proj_Item_Inst_Attr_Rec.Transacted_By;
    l_Txn_Rec.Transaction_Status_Code   :=l_Transaction_Status_Code;
    l_Txn_Rec.Message_Id  :=P_Proj_Item_Inst_Attr_Rec.Message_Id;
    l_Txn_Rec.Object_Version_Number  :=l_D_Object_version_number;
    l_txn_rec.transaction_action_code :=NULL;
    IF NOT t_transaction_id =-1 THEN
       l_txn_rec.transaction_id := t_transaction_id;
    END IF;

   IF (l_debug = 'Y') THEN
      CSE_DEBUG_PUB.ADD('Before update of destination instanace');
   END IF;

       CSI_Item_Instance_Pub.Update_Item_Instance(
      		p_api_version	         =>l_api_version,
      		p_commit 		 =>l_Commit,
                p_validation_level       =>l_Validation_Level,
      		p_init_msg_list          =>l_Init_Msg_List,
      		p_instance_rec           =>l_Instance_Rec,
                p_ext_attrib_values_tbl  =>l_ext_attrib_values_tbl,
                p_party_tbl              =>l_party_tbl,
                p_account_tbl            =>l_account_tbl,
                p_pricing_attrib_tbl     =>l_pricing_attrib_tbl,
                p_org_assignments_tbl    =>l_org_assignments_tbl,
      		p_txn_rec                =>l_Txn_Rec,
                p_asset_assignment_tbl   =>l_asset_assignment_tbl,
		x_instance_id_lst	 =>l_instance_id_lst,
      		x_return_status       	 =>l_Return_Status,
      		x_msg_count            	 =>l_Msg_Count,
      		x_msg_data             	 =>l_Msg_Data );

   -- get the error message from the stack if there is any error

     --l_Dest_transaction_id            := l_txn_rec.transaction_id;
     --l_upd_txn_rec.source_dist_ref_id2:= l_dest_transaction_id;

  IF NOT(l_Return_Status = FND_API.G_Ret_Sts_Success) THEN
	l_msg_index := 1;
        l_Error_Message:=l_Msg_Data;
    WHILE l_msg_count > 0 LOOP
	  l_Error_Message := FND_MSG_PUB.GET(l_msg_index,FND_API.G_FALSE);
	  l_msg_index := l_msg_index + 1;
          l_Msg_Count := l_Msg_Count - 1;
  	 END LOOP;
     RAISE Update_Ib_Exp;
  ELSIF (l_Return_Status = FND_API.G_Ret_Sts_Success) THEN
       IF t_transaction_id =-1 THEN
          t_transaction_id := l_txn_rec.transaction_id;
       END IF;
  END IF;

  ELSIF l_Dest_Instance_Rec.Instance_Id IS  NULL THEN
  l_Create_Dest_Inst_Flag :=FND_API.G_TRUE;
  END IF;

 ELSIF (l_Instance_Header_Tbl_Out.COUNT=0) THEN
   l_Create_Dest_Inst_Flag :=FND_API.G_TRUE;
 END IF;

--create destination item instance ,if the dest item instance is not found

IF (l_Create_Dest_Inst_Flag = FND_API.G_TRUE ) THEN

IF (l_debug = 'Y') THEN
   CSE_DEBUG_PUB.ADD('Initailizing instance Record for the creation Of dest inst - step5.1');
END IF;

       l_Instance_Rec  := CSE_UTIL_PKG.Init_Instance_Create_Rec;
       l_Instance_Rec.Inventory_Item_id := P_Proj_Item_Inst_Attr_Rec.Item_id;
       l_Instance_Rec.Inventory_Revision := P_Proj_Item_Inst_Attr_Rec.Revision;
       l_Instance_Rec.Inv_Master_Organization_Id := l_s_Inv_Master_Organization_Id;
       l_Instance_Rec.vld_organization_id := l_s_last_vld_organization_id;
       l_Instance_Rec.object_version_number :=l_object_version_number;
       l_Instance_Rec.Serial_Number := P_Proj_Item_Inst_Attr_Rec.Serial_Number;
       l_Instance_Rec.Mfg_Serial_Number_Flag := l_s_mfg_serial_number_flag ;
       l_Instance_Rec.Customer_View_Flag := 'N';
       l_Instance_Rec.Merchant_View_Flag := 'Y';
       l_Instance_Rec.Lot_Number := P_Proj_Item_Inst_Attr_Rec.Lot_Number;
       l_Instance_Rec.Quantity := P_Proj_Item_Inst_Attr_Rec.Quantity;
       l_Instance_Rec.Unit_Of_measure := l_Source_Unit_Of_Measure;
       l_Instance_Rec.Instance_Usage_Code := CSE_DATASTRUCTURES_PUB.G_INSTALLED;
       l_Instance_Rec.instance_status_id  := l_s_status_id ;
       l_Instance_Rec.Install_Location_Type_Code := l_Location_Type_Code;
       l_Instance_Rec.Install_Location_Id := l_Hz_Location_Id;
       l_Instance_Rec.Location_Type_Code := l_Location_Type_Code;
       l_Instance_Rec.Location_Id := l_Hz_Location_Id;
       l_Instance_Rec.Last_Pa_Project_Id :=P_Proj_Item_Inst_Attr_Rec.Project_Id;
       l_Instance_Rec.Last_Pa_Task_Id := P_Proj_Item_Inst_Attr_Rec.Task_Id;
       l_ext_attrib_values_tbl := CSE_UTIL_PKG.Init_ext_attrib_values_tbl;
       l_party_tbl:= CSE_UTIL_PKG.Init_party_tbl;
       l_account_tbl := CSE_UTIL_PKG.Init_account_tbl;
       l_pricing_attrib_tbl := CSE_UTIL_PKG.Init_pricing_attribs_tbl;
       l_org_assignments_tbl:= CSE_UTIL_PKG.Init_org_assignments_tbl;
       l_asset_assignment_tbl := CSE_UTIL_PKG.Init_asset_assignment_tbl;
       l_Txn_Rec := CSE_UTIL_PKG.Init_Txn_Rec;
       l_Txn_Rec.Transaction_Date := l_sysdate;
       l_Txn_Rec.Source_Transaction_Date := P_Proj_Item_Inst_Attr_Rec.Transaction_Date;
       l_Txn_Rec.Transaction_Type_Id := l_transaction_type_id;
       l_Txn_Rec.Source_Group_Ref:= P_Proj_Item_Inst_Attr_Rec.Work_Order_Number;
       --l_Txn_Rec.source_dist_ref_id2:=l_upd_txn_rec.transaction_id;
        IF (l_debug = 'Y') THEN
           CSE_DEBUG_PUB.ADD('source txn id-'||l_upd_txn_rec.transaction_id);
        END IF;
       l_Txn_Rec.Transaction_Quantity := P_Proj_Item_Inst_Attr_Rec.Quantity;
       l_Txn_Rec.Transacted_By := P_Proj_Item_Inst_Attr_Rec.Transacted_By;
       l_Txn_Rec.Transaction_Status_Code := l_Transaction_Status_Code;
       l_Txn_Rec.Message_Id := P_Proj_Item_Inst_Attr_Rec.Message_Id;
       IF NOT t_transaction_id =-1 THEN
          l_txn_rec.transaction_id := t_transaction_id;
       END IF;

       IF (l_debug = 'Y') THEN
          CSE_DEBUG_PUB.ADD('Before creation of destination instanace');
       END IF;

       CSI_Item_Instance_Pub.Create_Item_Instance(
      		p_api_version	         =>l_api_version,
      		p_commit 		 =>l_Commit,
                p_validation_level       =>l_Validation_Level,
      		p_init_msg_list          =>l_Init_Msg_List,
      		p_instance_rec           =>l_Instance_Rec,
                p_ext_attrib_values_tbl  =>l_ext_attrib_values_tbl,
                p_party_tbl              =>l_party_tbl,
                p_account_tbl            =>l_account_tbl,
                p_pricing_attrib_tbl     =>l_pricing_attrib_tbl,
                p_org_assignments_tbl    =>l_org_assignments_tbl,
      		p_txn_rec                =>l_Txn_Rec,
                p_asset_assignment_tbl   =>l_asset_assignment_tbl,
		x_return_status       	 =>l_Return_Status,
      		x_msg_count            	 =>l_Msg_Count,
      		x_msg_data             	 =>l_Msg_Data );

   -- get the error message from the stack if there is any error

  IF NOT(l_Return_Status = FND_API.G_Ret_Sts_Success) THEN
	l_msg_index := 1;
    	l_Error_Message:=l_Msg_Data;
    WHILE l_msg_count > 0 LOOP
	  l_Error_Message := FND_MSG_PUB.GET(l_msg_index,FND_API.G_FALSE);
	  l_msg_index := l_msg_index + 1;
          l_Msg_Count := l_Msg_Count - 1;
    END LOOP;
    RAISE Update_Ib_Exp;
  ELSIF (l_Return_Status = FND_API.G_Ret_Sts_Success) THEN
        IF t_transaction_id =-1 THEN
           t_transaction_id := l_txn_rec.transaction_id;
        END IF;
  END IF;

-- Update the source transaction to populate the
-- source_dist_ref_id2 with the destination transaction id.

  --l_Dest_transaction_id            := l_txn_rec.transaction_id;
  --l_upd_txn_rec.source_dist_ref_id2:= l_dest_transaction_id;

  END IF;
   IF (l_debug = 'Y') THEN
      CSE_DEBUG_PUB.ADD('dest txn id-'||l_upd_txn_rec.source_dist_ref_id2);
   END IF;
  -- update the source transaction with destination transaction_id
 IF (l_debug = 'Y') THEN
   CSE_DEBUG_PUB.ADD('Before calling csi_transactions_pvt.update_transactions');
 END IF;
     csi_transactions_pvt.update_transactions(
        P_api_version      => l_api_version,
        P_Init_Msg_List    => l_Init_Msg_List,
        P_Commit           => l_Commit,
        p_validation_level => l_validation_level,
        P_transaction_rec  => l_upd_txn_rec,
        X_Return_Status    => l_Return_Status,
        X_Msg_Count        => l_Msg_Count,
        X_Msg_Data         => l_Msg_Data);

  IF (l_debug = 'Y') THEN
     CSE_DEBUG_PUB.ADD('after calling csi_transactions_pvt.update_transactions');
  END IF;

  IF NOT(l_Return_Status = FND_API.G_Ret_Sts_Success) THEN
	l_msg_index := 1;
    	l_Error_Message:=l_Msg_Data;
    WHILE l_msg_count > 0 LOOP
        l_Error_Message := FND_MSG_PUB.GET(l_msg_index,FND_API.G_FALSE);
        l_msg_index := l_msg_index + 1;
        l_Msg_Count := l_Msg_Count - 1;
    END LOOP;
    RAISE Update_Ib_Exp;
  ELSIF (l_Return_Status = FND_API.G_Ret_Sts_Success) THEN
    IF NOT t_transaction_id =-1 THEN
       l_txn_rec.transaction_id := t_transaction_id;
    END IF;
  END IF;
 END IF;
END IF;
IF (l_debug = 'Y') THEN
   CSE_DEBUG_PUB.ADD('**** END OF PROJECT ITEM INSTALLED TRANSACTION ******');
   CSE_DEBUG_PUB.ADD('                                                      ');
END IF;
EXCEPTION
 WHEN Update_Ib_Exp THEN
  X_Return_Status := l_Return_Status;
  x_Error_Message := l_Error_Message;

 WHEN OTHERS THEN
  fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
  fnd_message.set_token('ERR_MSG',l_Api_Name||'='|| SQLERRM);
  x_error_message := fnd_message.get;
  x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
 END Update_Ib_Repository;
PROCEDURE Update_eib_instances(
   P_proj_item_inst_Attr_tbl  IN  proj_item_inst_Attr_tbl_Type,
   X_Return_Status        OUT NOCOPY VARCHAR2,
   X_Error_Message        OUT NOCOPY VARCHAR2) IS

BEGIN
 IF NOT p_proj_item_inst_attr_tbl.COUNT = 0 THEN

 FOR i IN p_proj_item_inst_attr_tbl.FIRST .. p_proj_item_inst_attr_tbl.LAST
 LOOP
   IF p_proj_item_inst_attr_tbl.EXISTS(i) THEN
      update_ib_repository( p_proj_item_inst_attr_tbl(i),
                            x_return_status,
                            x_error_message);
   END IF;

 END LOOP;
 END IF; -- tbl.count IF
 EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
  fnd_message.set_token('ERR_MSG','CSE_PROJ_ITEM_INST_PKG.UPDATE_EIB_INSTANCES'||'='|| SQLERRM);
  x_error_message := fnd_message.get;
  x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END update_eib_instances;

END CSE_PROJ_ITEM_INST_PKG;

/
