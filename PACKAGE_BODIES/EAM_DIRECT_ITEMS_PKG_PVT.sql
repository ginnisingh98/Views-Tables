--------------------------------------------------------
--  DDL for Package Body EAM_DIRECT_ITEMS_PKG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_DIRECT_ITEMS_PKG_PVT" AS
/* $Header: EAMVDIPB.pls 120.2 2006/03/24 03:05:41 gbadoni noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVDIPB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_DIRECT_ITEMS_PKG_PVT
--
--  NOTES
--
--  HISTORY
--
--  01-OCT-2003    6/3/2004Basanth Roy     Initial Creation
***************************************************************************/

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_DIRECT_ITEMS_PKG_PVT';





        /********************************************************************
        * Procedure     : Insert_Row
        * Parameters IN : Direct Items column record
        * Parameters OUT NOCOPY: Return Status
        * Purpose       : Procedure will perfrom an insert into the
        *                 wip_eam_direct_items table.
        *********************************************************************/

        PROCEDURE Insert_Row
        ( X_DESCRIPTION                   IN VARCHAR2        ,
          X_DIRECT_ITEM_TYPE              IN NUMBER          ,
          X_PURCHASING_CATEGORY_ID        IN NUMBER          ,
          X_DIRECT_ITEM_SEQUENCE_ID       IN OUT NOCOPY NUMBER,		-- Fix for Bug 3745360
          X_INVENTORY_ITEM_ID             IN NUMBER          ,
          X_OPERATION_SEQ_NUM             IN NUMBER          ,
          X_DEPARTMENT_ID                 IN NUMBER          ,
          X_WIP_ENTITY_ID                 IN NUMBER          ,
          X_ORGANIZATION_ID               IN NUMBER          ,
          X_SUGGESTED_VENDOR_NAME         IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_ID           IN NUMBER          ,
          X_SUGGESTED_VENDOR_SITE         IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_SITE_ID      IN NUMBER          ,
          X_SUGGESTED_VENDOR_CONTACT      IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_CONTACT_ID   IN NUMBER          ,
          X_SUGGESTED_VENDOR_PHONE        IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_ITEM_NUM     IN VARCHAR2        ,
          X_UNIT_PRICE                    IN NUMBER          ,
          X_AUTO_REQUEST_MATERIAL         IN VARCHAR2        ,
          X_REQUIRED_QUANTITY             IN NUMBER          ,
          X_UOM                           IN VARCHAR2        ,
          X_NEED_BY_DATE                  IN DATE            ,
          X_ATTRIBUTE_CATEGORY            IN VARCHAR2        ,
          X_ATTRIBUTE1                    IN VARCHAR2        ,
          X_ATTRIBUTE2                    IN VARCHAR2        ,
          X_ATTRIBUTE3                    IN VARCHAR2        ,
          X_ATTRIBUTE4                    IN VARCHAR2        ,
          X_ATTRIBUTE5                    IN VARCHAR2        ,
          X_ATTRIBUTE6                    IN VARCHAR2        ,
          X_ATTRIBUTE7                    IN VARCHAR2        ,
          X_ATTRIBUTE8                    IN VARCHAR2        ,
          X_ATTRIBUTE9                    IN VARCHAR2        ,
          X_ATTRIBUTE10                   IN VARCHAR2        ,
          X_ATTRIBUTE11                   IN VARCHAR2        ,
          X_ATTRIBUTE12                   IN VARCHAR2        ,
          X_ATTRIBUTE13                   IN VARCHAR2        ,
          X_ATTRIBUTE14                   IN VARCHAR2        ,
          X_ATTRIBUTE15                   IN VARCHAR2        ,
          X_PROGRAM_APPLICATION_ID        IN NUMBER          ,
          X_PROGRAM_ID                    IN NUMBER          ,
          X_PROGRAM_UPDATE_DATE           IN DATE            ,
          X_REQUEST_ID                    IN NUMBER          ,
          x_return_Status                 OUT NOCOPY VARCHAR2,
          x_material_shortage_flag        OUT NOCOPY VARCHAR2,
          x_material_shortage_check_date  OUT NOCOPY DATE
         )
        IS
          l_eam_direct_items_rec EAM_PROCESS_WO_PUB.eam_direct_items_rec_type;
          l_eam_direct_items_tbl EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
          l_eam_mat_req_rec EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
          l_eam_mat_req_tbl EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
           l_output_dir VARCHAR2(512);

          l_eam_wo_rec              EAM_PROCESS_WO_PUB.eam_wo_rec_type;
          l_eam_op_tbl              EAM_PROCESS_WO_PUB.eam_op_tbl_type;
          l_eam_op_network_tbl      EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
          l_eam_res_tbl             EAM_PROCESS_WO_PUB.eam_res_tbl_type;
          l_eam_res_inst_tbl        EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
          l_eam_sub_res_tbl         EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
          l_eam_res_usage_tbl       EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	  l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	  l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	  l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	  l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	  l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	  l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	  l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
          l_eam_counter_prop_tbl	  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

	  l_out_eam_wo_rec              EAM_PROCESS_WO_PUB.eam_wo_rec_type;
          l_out_eam_op_tbl              EAM_PROCESS_WO_PUB.eam_op_tbl_type;
          l_out_eam_op_network_tbl      EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
          l_out_eam_res_tbl             EAM_PROCESS_WO_PUB.eam_res_tbl_type;
          l_out_eam_res_inst_tbl        EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
          l_out_eam_sub_res_tbl         EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
          l_out_eam_res_usage_tbl       EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
          l_out_eam_mat_req_tbl         EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
          l_out_eam_direct_items_tbl    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	  l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	  l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	  l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	  l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	  l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	  l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	  l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	  l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

	  l_return_status               VARCHAR2(10);
          l_msg_count                   NUMBER;

        BEGIN

        l_eam_direct_items_tbl.delete;
        l_eam_mat_req_tbl.delete;

        if X_DIRECT_ITEM_TYPE = 1 then -- description based

          l_eam_direct_items_rec.DESCRIPTION := X_DESCRIPTION;
          l_eam_direct_items_rec.PURCHASING_CATEGORY_ID := X_PURCHASING_CATEGORY_ID;
          l_eam_direct_items_rec.Direct_Item_Sequence_Id := X_Direct_Item_Sequence_Id;
          l_eam_direct_items_rec.Operation_Seq_Num := X_Operation_Seq_Num;
          l_eam_direct_items_rec.Department_id := X_Department_id;
          l_eam_direct_items_rec.Wip_entity_id := X_Wip_entity_id;
          l_eam_direct_items_rec.Organization_id := X_Organization_id;
          l_eam_direct_items_rec.Suggested_Vendor_Name := X_Suggested_Vendor_Name;
          l_eam_direct_items_rec.Suggested_Vendor_Id := X_Suggested_Vendor_Id;
          l_eam_direct_items_rec.Suggested_Vendor_Site := X_Suggested_Vendor_Site;
          l_eam_direct_items_rec.Suggested_Vendor_Site_Id := X_Suggested_Vendor_Site_Id;
          l_eam_direct_items_rec.Suggested_Vendor_Contact := X_Suggested_Vendor_Contact;
          l_eam_direct_items_rec.Suggested_Vendor_Contact_Id := X_Suggested_Vendor_Contact_Id;
          l_eam_direct_items_rec.Suggested_Vendor_Phone := X_Suggested_Vendor_Phone;
          l_eam_direct_items_rec.Suggested_Vendor_Item_Num := X_Suggested_Vendor_Item_Num;
          l_eam_direct_items_rec.Unit_Price := X_Unit_Price;
          l_eam_direct_items_rec.Auto_request_Material := X_Auto_request_Material;
          l_eam_direct_items_rec.Required_Quantity := X_Required_Quantity;
          l_eam_direct_items_rec.UOM := X_UOM;
          l_eam_direct_items_rec.Need_By_Date := X_Need_By_Date;
          l_eam_direct_items_rec.ATTRIBUTE_CATEGORY := X_ATTRIBUTE_CATEGORY;
          l_eam_direct_items_rec.ATTRIBUTE1 := X_ATTRIBUTE1;
          l_eam_direct_items_rec.ATTRIBUTE2 := X_ATTRIBUTE2;
          l_eam_direct_items_rec.ATTRIBUTE3 := X_ATTRIBUTE3;
          l_eam_direct_items_rec.ATTRIBUTE4 := X_ATTRIBUTE4;
          l_eam_direct_items_rec.ATTRIBUTE5 := X_ATTRIBUTE5;
          l_eam_direct_items_rec.ATTRIBUTE6 := X_ATTRIBUTE6;
          l_eam_direct_items_rec.ATTRIBUTE7 := X_ATTRIBUTE7;
          l_eam_direct_items_rec.ATTRIBUTE8 := X_ATTRIBUTE8;
          l_eam_direct_items_rec.ATTRIBUTE9 := X_ATTRIBUTE9;
          l_eam_direct_items_rec.ATTRIBUTE10 := X_ATTRIBUTE10;
          l_eam_direct_items_rec.ATTRIBUTE11 := X_ATTRIBUTE11;
          l_eam_direct_items_rec.ATTRIBUTE12 := X_ATTRIBUTE12;
          l_eam_direct_items_rec.ATTRIBUTE13 := X_ATTRIBUTE13;
          l_eam_direct_items_rec.ATTRIBUTE14 := X_ATTRIBUTE14;
          l_eam_direct_items_rec.ATTRIBUTE15 := X_ATTRIBUTE15;
          l_eam_direct_items_rec.PROGRAM_APPLICATION_ID     := null;
          l_eam_direct_items_rec.PROGRAM_ID                 := null;
          l_eam_direct_items_rec.PROGRAM_UPDATE_DATE        := sysdate;
          l_eam_direct_items_rec.REQUEST_ID                 := null;
          l_eam_direct_items_rec.RETURN_STATUS              := null;
          l_eam_direct_items_rec.TRANSACTION_TYPE           := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
          l_eam_direct_items_rec.HEADER_ID                  := 1;
          l_eam_direct_items_rec.BATCH_ID                   := 1;
          l_eam_direct_items_rec.ROW_ID                     := null;

          l_eam_direct_items_tbl(1) := l_eam_direct_items_rec;

        elsif X_DIRECT_ITEM_TYPE = 2 then -- non-stockable inventory item

          l_eam_mat_req_rec.Operation_Seq_Num := X_Operation_Seq_Num;
          l_eam_mat_req_rec.Department_id := X_Department_id;
          l_eam_mat_req_rec.Wip_entity_id := X_Wip_entity_id;
          l_eam_mat_req_rec.Organization_id := X_Organization_id;
	  l_eam_mat_req_rec.Suggested_Vendor_Name := X_Suggested_Vendor_Name;   	-- Fix for Bug 3665818
          l_eam_mat_req_rec.Vendor_Id := X_Suggested_Vendor_Id;				-- Fix for Bug 3665818
          l_eam_mat_req_rec.inventory_item_id := X_INVENTORY_ITEM_ID;
          l_eam_mat_req_rec.Unit_Price := X_Unit_Price;
          l_eam_mat_req_rec.Auto_request_Material := X_Auto_request_Material;
          l_eam_mat_req_rec.Required_Quantity := X_Required_Quantity;
          l_eam_mat_req_rec.Date_Required := X_Need_By_Date;
          l_eam_mat_req_rec.ATTRIBUTE_CATEGORY := X_ATTRIBUTE_CATEGORY;
          l_eam_mat_req_rec.ATTRIBUTE1 := X_ATTRIBUTE1;
          l_eam_mat_req_rec.ATTRIBUTE2 := X_ATTRIBUTE2;
          l_eam_mat_req_rec.ATTRIBUTE3 := X_ATTRIBUTE3;
          l_eam_mat_req_rec.ATTRIBUTE4 := X_ATTRIBUTE4;
          l_eam_mat_req_rec.ATTRIBUTE5 := X_ATTRIBUTE5;
          l_eam_mat_req_rec.ATTRIBUTE6 := X_ATTRIBUTE6;
          l_eam_mat_req_rec.ATTRIBUTE7 := X_ATTRIBUTE7;
          l_eam_mat_req_rec.ATTRIBUTE8 := X_ATTRIBUTE8;
          l_eam_mat_req_rec.ATTRIBUTE9 := X_ATTRIBUTE9;
          l_eam_mat_req_rec.ATTRIBUTE10 := X_ATTRIBUTE10;
          l_eam_mat_req_rec.ATTRIBUTE11 := X_ATTRIBUTE11;
          l_eam_mat_req_rec.ATTRIBUTE12 := X_ATTRIBUTE12;
          l_eam_mat_req_rec.ATTRIBUTE13 := X_ATTRIBUTE13;
          l_eam_mat_req_rec.ATTRIBUTE14 := X_ATTRIBUTE14;
          l_eam_mat_req_rec.ATTRIBUTE15 := X_ATTRIBUTE15;
          l_eam_mat_req_rec.PROGRAM_APPLICATION_ID     := null;
          l_eam_mat_req_rec.PROGRAM_ID                 := null;
          l_eam_mat_req_rec.PROGRAM_UPDATE_DATE        := sysdate;
          l_eam_mat_req_rec.REQUEST_ID                 := null;
          l_eam_mat_req_rec.RETURN_STATUS              := null;
          l_eam_mat_req_rec.TRANSACTION_TYPE           := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
          l_eam_mat_req_rec.HEADER_ID                  := 1;
          l_eam_mat_req_rec.BATCH_ID                   := 1;
          l_eam_mat_req_rec.ROW_ID                     := null;

          l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;

        end if;

EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

        EAM_PROCESS_WO_PUB.PROCESS_WO
        (  p_bo_identifier           => 'EAM'
         , p_api_version_number      => 1.0
         , p_init_msg_list           => FALSE
         , p_commit                  => 'N'
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
         , x_return_status           => l_return_status
         , x_msg_count               => l_msg_count
         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_output_dir              => l_output_dir
         , p_debug_filename          => 'diitemins.log'
         , p_debug_file_mode         => 'w'
         );

         x_return_status := l_return_status;
	 x_material_shortage_flag := l_out_eam_wo_rec.material_shortage_flag;
         x_material_shortage_check_date := l_out_eam_wo_rec.material_shortage_check_date;

	 BEGIN			-- Fix for Bug 3745360 Begin
		 IF x_direct_item_type = 1 THEN
			 x_direct_item_sequence_id := l_out_eam_direct_items_tbl(1).direct_item_sequence_id;
	         END IF;
	EXCEPTION
		WHEN no_data_found THEN
			null;
	END;			-- Fix for Bug 3745360 End
        END Insert_Row;




        /********************************************************************
        * Procedure     : Update_Row
        * Parameters IN : Direct Items column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Update on the
        *                 wip_eam_direct_items
        *********************************************************************/

        PROCEDURE Update_Row
        ( X_DESCRIPTION                   IN VARCHAR2        ,
          X_DIRECT_ITEM_TYPE              IN NUMBER          ,
          X_PURCHASING_CATEGORY_ID        IN NUMBER          ,
          X_DIRECT_ITEM_SEQUENCE_ID       IN NUMBER          ,
          X_INVENTORY_ITEM_ID             IN NUMBER          ,
          X_OPERATION_SEQ_NUM             IN NUMBER          ,
          X_DEPARTMENT_ID                 IN NUMBER          ,
          X_WIP_ENTITY_ID                 IN NUMBER          ,
          X_ORGANIZATION_ID               IN NUMBER          ,
          X_SUGGESTED_VENDOR_NAME         IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_ID           IN NUMBER          ,
          X_SUGGESTED_VENDOR_SITE         IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_SITE_ID      IN NUMBER          ,
          X_SUGGESTED_VENDOR_CONTACT      IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_CONTACT_ID   IN NUMBER          ,
          X_SUGGESTED_VENDOR_PHONE        IN VARCHAR2        ,
          X_SUGGESTED_VENDOR_ITEM_NUM     IN VARCHAR2        ,
          X_UNIT_PRICE                    IN NUMBER          ,
          X_AUTO_REQUEST_MATERIAL         IN VARCHAR2        ,
          X_REQUIRED_QUANTITY             IN NUMBER          ,
          X_UOM                           IN VARCHAR2        ,
          X_NEED_BY_DATE                  IN DATE            ,
          X_ATTRIBUTE_CATEGORY            IN VARCHAR2        ,
          X_ATTRIBUTE1                    IN VARCHAR2        ,
          X_ATTRIBUTE2                    IN VARCHAR2        ,
          X_ATTRIBUTE3                    IN VARCHAR2        ,
          X_ATTRIBUTE4                    IN VARCHAR2        ,
          X_ATTRIBUTE5                    IN VARCHAR2        ,
          X_ATTRIBUTE6                    IN VARCHAR2        ,
          X_ATTRIBUTE7                    IN VARCHAR2        ,
          X_ATTRIBUTE8                    IN VARCHAR2        ,
          X_ATTRIBUTE9                    IN VARCHAR2        ,
          X_ATTRIBUTE10                   IN VARCHAR2        ,
          X_ATTRIBUTE11                   IN VARCHAR2        ,
          X_ATTRIBUTE12                   IN VARCHAR2        ,
          X_ATTRIBUTE13                   IN VARCHAR2        ,
          X_ATTRIBUTE14                   IN VARCHAR2        ,
          X_ATTRIBUTE15                   IN VARCHAR2        ,
          X_PROGRAM_APPLICATION_ID        IN NUMBER          ,
          X_PROGRAM_ID                    IN NUMBER          ,
          X_PROGRAM_UPDATE_DATE           IN DATE            ,
          X_REQUEST_ID                    IN NUMBER          ,
          X_RETURN_STATUS                 OUT NOCOPY VARCHAR2,
          X_MATERIAL_SHORTAGE_FLAG        OUT NOCOPY VARCHAR2,
          X_MATERIAL_SHORTAGE_CHECK_DATe  OUT NOCOPY DATE
         )
        IS

          l_eam_direct_items_rec EAM_PROCESS_WO_PUB.eam_direct_items_rec_type;
          l_eam_direct_items_tbl EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
          l_eam_mat_req_rec EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
          l_eam_mat_req_tbl EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;

          l_eam_wo_rec              EAM_PROCESS_WO_PUB.eam_wo_rec_type;
          l_eam_op_tbl              EAM_PROCESS_WO_PUB.eam_op_tbl_type;
          l_eam_op_network_tbl      EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
          l_eam_res_tbl             EAM_PROCESS_WO_PUB.eam_res_tbl_type;
          l_eam_res_inst_tbl        EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
          l_eam_sub_res_tbl         EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
          l_eam_res_usage_tbl       EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	  l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	  l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	  l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	  l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	  l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	  l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	  l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	  l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

          l_out_eam_wo_rec              EAM_PROCESS_WO_PUB.eam_wo_rec_type;
          l_out_eam_op_tbl              EAM_PROCESS_WO_PUB.eam_op_tbl_type;
          l_out_eam_op_network_tbl      EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
          l_out_eam_res_tbl             EAM_PROCESS_WO_PUB.eam_res_tbl_type;
          l_out_eam_res_inst_tbl        EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
          l_out_eam_sub_res_tbl         EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
          l_out_eam_res_usage_tbl       EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
          l_out_eam_mat_req_tbl         EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
          l_out_eam_direct_items_tbl    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	  l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	  l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	  l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	  l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	  l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	  l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	  l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	  l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

          l_return_status               VARCHAR2(10);
          l_msg_count                   NUMBER;
	   l_output_dir VARCHAR2(512);

        BEGIN

        if X_DIRECT_ITEM_TYPE = 1 then

          l_eam_direct_items_rec.DESCRIPTION := X_DESCRIPTION;
          l_eam_direct_items_rec.PURCHASING_CATEGORY_ID := X_PURCHASING_CATEGORY_ID;
          l_eam_direct_items_rec.Direct_Item_Sequence_Id := X_Direct_Item_Sequence_Id;
          l_eam_direct_items_rec.Operation_Seq_Num := X_Operation_Seq_Num;
          l_eam_direct_items_rec.Department_id := X_Department_id;
          l_eam_direct_items_rec.Wip_entity_id := X_Wip_entity_id;
          l_eam_direct_items_rec.Organization_id := X_Organization_id;
          l_eam_direct_items_rec.Suggested_Vendor_Name := X_Suggested_Vendor_Name;
          l_eam_direct_items_rec.Suggested_Vendor_Id := X_Suggested_Vendor_Id;
          l_eam_direct_items_rec.Suggested_Vendor_Site := X_Suggested_Vendor_Site;
          l_eam_direct_items_rec.Suggested_Vendor_Site_Id := X_Suggested_Vendor_Site_Id;
          l_eam_direct_items_rec.Suggested_Vendor_Contact := X_Suggested_Vendor_Contact;
          l_eam_direct_items_rec.Suggested_Vendor_Contact_Id := X_Suggested_Vendor_Contact_Id;
          l_eam_direct_items_rec.Suggested_Vendor_Phone := X_Suggested_Vendor_Phone;
          l_eam_direct_items_rec.Suggested_Vendor_Item_Num := X_Suggested_Vendor_Item_Num;
          l_eam_direct_items_rec.Unit_Price := X_Unit_Price;
          l_eam_direct_items_rec.Auto_request_Material := X_Auto_request_Material;
          l_eam_direct_items_rec.Required_Quantity := X_Required_Quantity;
          l_eam_direct_items_rec.UOM := X_UOM;
          l_eam_direct_items_rec.Need_By_Date := X_Need_By_Date;
          l_eam_direct_items_rec.ATTRIBUTE_CATEGORY := X_ATTRIBUTE_CATEGORY;
          l_eam_direct_items_rec.ATTRIBUTE1 := X_ATTRIBUTE1;
          l_eam_direct_items_rec.ATTRIBUTE2 := X_ATTRIBUTE2;
          l_eam_direct_items_rec.ATTRIBUTE3 := X_ATTRIBUTE3;
          l_eam_direct_items_rec.ATTRIBUTE4 := X_ATTRIBUTE4;
          l_eam_direct_items_rec.ATTRIBUTE5 := X_ATTRIBUTE5;
          l_eam_direct_items_rec.ATTRIBUTE6 := X_ATTRIBUTE6;
          l_eam_direct_items_rec.ATTRIBUTE7 := X_ATTRIBUTE7;
          l_eam_direct_items_rec.ATTRIBUTE8 := X_ATTRIBUTE8;
          l_eam_direct_items_rec.ATTRIBUTE9 := X_ATTRIBUTE9;
          l_eam_direct_items_rec.ATTRIBUTE10 := X_ATTRIBUTE10;
          l_eam_direct_items_rec.ATTRIBUTE11 := X_ATTRIBUTE11;
          l_eam_direct_items_rec.ATTRIBUTE12 := X_ATTRIBUTE12;
          l_eam_direct_items_rec.ATTRIBUTE13 := X_ATTRIBUTE13;
          l_eam_direct_items_rec.ATTRIBUTE14 := X_ATTRIBUTE14;
          l_eam_direct_items_rec.ATTRIBUTE15 := X_ATTRIBUTE15;
          l_eam_direct_items_rec.PROGRAM_APPLICATION_ID     := null;
          l_eam_direct_items_rec.PROGRAM_ID                 := null;
          l_eam_direct_items_rec.PROGRAM_UPDATE_DATE        := sysdate;
          l_eam_direct_items_rec.REQUEST_ID                 := null;
          l_eam_direct_items_rec.RETURN_STATUS              := null;
          l_eam_direct_items_rec.TRANSACTION_TYPE           := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
          l_eam_direct_items_rec.HEADER_ID                  := 1;
          l_eam_direct_items_rec.BATCH_ID                   := 1;
          l_eam_direct_items_rec.ROW_ID                     := null;

          l_eam_direct_items_tbl(1) := l_eam_direct_items_rec;

        elsif X_DIRECT_ITEM_TYPE = 2 then

          l_eam_mat_req_rec.Operation_Seq_Num := X_Operation_Seq_Num;
          l_eam_mat_req_rec.Department_id := X_Department_id;
          l_eam_mat_req_rec.Wip_entity_id := X_Wip_entity_id;
          l_eam_mat_req_rec.Organization_id := X_Organization_id;
	  l_eam_mat_req_rec.Suggested_Vendor_Name := X_Suggested_Vendor_Name;   	-- Fix for Bug 3665818
          l_eam_mat_req_rec.Vendor_Id := X_Suggested_Vendor_Id;				-- Fix for Bug 3665818
	  l_eam_mat_req_rec.inventory_item_id := X_Inventory_Item_id;
          l_eam_mat_req_rec.Unit_Price := X_Unit_Price;
          l_eam_mat_req_rec.Auto_request_Material := X_Auto_request_Material;
          l_eam_mat_req_rec.Required_Quantity := X_Required_Quantity;
          l_eam_mat_req_rec.Date_Required := X_Need_By_Date;
          l_eam_mat_req_rec.ATTRIBUTE_CATEGORY := X_ATTRIBUTE_CATEGORY;
          l_eam_mat_req_rec.ATTRIBUTE1 := X_ATTRIBUTE1;
          l_eam_mat_req_rec.ATTRIBUTE2 := X_ATTRIBUTE2;
          l_eam_mat_req_rec.ATTRIBUTE3 := X_ATTRIBUTE3;
          l_eam_mat_req_rec.ATTRIBUTE4 := X_ATTRIBUTE4;
          l_eam_mat_req_rec.ATTRIBUTE5 := X_ATTRIBUTE5;
          l_eam_mat_req_rec.ATTRIBUTE6 := X_ATTRIBUTE6;
          l_eam_mat_req_rec.ATTRIBUTE7 := X_ATTRIBUTE7;
          l_eam_mat_req_rec.ATTRIBUTE8 := X_ATTRIBUTE8;
          l_eam_mat_req_rec.ATTRIBUTE9 := X_ATTRIBUTE9;
          l_eam_mat_req_rec.ATTRIBUTE10 := X_ATTRIBUTE10;
          l_eam_mat_req_rec.ATTRIBUTE11 := X_ATTRIBUTE11;
          l_eam_mat_req_rec.ATTRIBUTE12 := X_ATTRIBUTE12;
          l_eam_mat_req_rec.ATTRIBUTE13 := X_ATTRIBUTE13;
          l_eam_mat_req_rec.ATTRIBUTE14 := X_ATTRIBUTE14;
          l_eam_mat_req_rec.ATTRIBUTE15 := X_ATTRIBUTE15;
          l_eam_mat_req_rec.PROGRAM_APPLICATION_ID     := null;
          l_eam_mat_req_rec.PROGRAM_ID                 := null;
          l_eam_mat_req_rec.PROGRAM_UPDATE_DATE        := sysdate;
          l_eam_mat_req_rec.REQUEST_ID                 := null;
          l_eam_mat_req_rec.RETURN_STATUS              := null;
          l_eam_mat_req_rec.TRANSACTION_TYPE           := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
          l_eam_mat_req_rec.HEADER_ID                  := 1;
          l_eam_mat_req_rec.BATCH_ID                   := 1;
          l_eam_mat_req_rec.ROW_ID                     := null;

          l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;

        end if;

EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

        EAM_PROCESS_WO_PUB.PROCESS_WO
        (  p_bo_identifier           => 'EAM'
         , p_api_version_number      => 1.0
         , p_init_msg_list           => FALSE
         , p_commit                  => 'N'
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
         , x_return_status           => l_return_status
         , x_msg_count               => l_msg_count
         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_output_dir              => l_output_dir
         , p_debug_filename          => 'diitemupd.log'
         , p_debug_file_mode         => 'w'
         );

         x_return_status := l_return_status;
	 x_material_shortage_flag := l_out_eam_wo_rec.material_shortage_flag;
         x_material_shortage_check_date := l_out_eam_wo_rec.material_shortage_check_date;

        END Update_Row;



        /********************************************************************
        * Procedure     : Delete_Row
        * Parameters IN : Direct Items column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Delete on the
        *                 wip_eam_direct_items
        *********************************************************************/

        PROCEDURE Delete_Row
        ( X_DIRECT_ITEM_TYPE                IN NUMBER,
          X_DIRECT_ITEM_SEQUENCE_ID         IN NUMBER,
          X_INVENTORY_ITEM_ID               IN NUMBER,
          X_OPERATION_SEQ_NUM               IN NUMBER,
          X_WIP_ENTITY_ID                   IN NUMBER,
          X_ORGANIZATION_ID                 IN NUMBER,
          x_return_Status                   OUT NOCOPY VARCHAR2,
          x_material_shortage_flag          OUT NOCOPY VARCHAR2,
          x_material_shortage_check_date    OUT NOCOPY DATE
         )
        IS
          l_eam_direct_items_rec EAM_PROCESS_WO_PUB.eam_direct_items_rec_type;
          l_eam_direct_items_tbl EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
          l_eam_mat_req_rec EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
          l_eam_mat_req_tbl EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;

          l_eam_wo_rec              EAM_PROCESS_WO_PUB.eam_wo_rec_type;
          l_eam_op_tbl              EAM_PROCESS_WO_PUB.eam_op_tbl_type;
          l_eam_op_network_tbl      EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
          l_eam_res_tbl             EAM_PROCESS_WO_PUB.eam_res_tbl_type;
          l_eam_res_inst_tbl        EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
          l_eam_sub_res_tbl         EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
          l_eam_res_usage_tbl       EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	  l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	  l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	  l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	  l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	  l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	  l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	  l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	  l_eam_counter_prop_tbl          EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

          l_out_eam_wo_rec              EAM_PROCESS_WO_PUB.eam_wo_rec_type;
          l_out_eam_op_tbl              EAM_PROCESS_WO_PUB.eam_op_tbl_type;
          l_out_eam_op_network_tbl      EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
          l_out_eam_res_tbl             EAM_PROCESS_WO_PUB.eam_res_tbl_type;
          l_out_eam_res_inst_tbl        EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
          l_out_eam_sub_res_tbl         EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
          l_out_eam_res_usage_tbl       EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
          l_out_eam_mat_req_tbl         EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
          l_out_eam_direct_items_tbl    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	  l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	  l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	  l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	  l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	  l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	  l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	  l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
	  l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

          l_return_status               VARCHAR2(10);
          l_msg_count                   NUMBER;
	   l_output_dir VARCHAR2(512);

        BEGIN

        l_eam_direct_items_tbl.delete;
        l_eam_mat_req_tbl.delete;

EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

        if X_DIRECT_ITEM_TYPE = 1 then

          l_eam_direct_items_rec.Direct_Item_Sequence_Id := X_Direct_Item_Sequence_Id;
          l_eam_direct_items_rec.Operation_Seq_Num := X_Operation_Seq_Num;
          l_eam_direct_items_rec.Wip_entity_id := X_Wip_entity_id;
          l_eam_direct_items_rec.Organization_id := X_Organization_id;
          l_eam_direct_items_rec.RETURN_STATUS              := null;
          l_eam_direct_items_rec.TRANSACTION_TYPE           := EAM_PROCESS_WO_PVT.G_OPR_DELETE;
          l_eam_direct_items_rec.HEADER_ID                  := 1;
          l_eam_direct_items_rec.BATCH_ID                   := 1;
          l_eam_direct_items_rec.ROW_ID                     := null;

          l_eam_direct_items_tbl(1) := l_eam_direct_items_rec;

        elsif X_DIRECT_ITEM_TYPE = 2 then

          l_eam_mat_req_rec.Operation_Seq_Num := X_Operation_Seq_Num;
          l_eam_mat_req_rec.Wip_entity_id := X_Wip_entity_id;
          l_eam_mat_req_rec.Organization_id := X_Organization_id;
          l_eam_mat_req_rec.inventory_item_id := X_Inventory_item_id;
          l_eam_mat_req_rec.RETURN_STATUS              := null;
          l_eam_mat_req_rec.TRANSACTION_TYPE           := EAM_PROCESS_WO_PVT.G_OPR_DELETE;
          l_eam_mat_req_rec.HEADER_ID                  := 1;
          l_eam_mat_req_rec.BATCH_ID                   := 1;
          l_eam_mat_req_rec.ROW_ID                     := null;

          l_eam_mat_req_tbl(1) := l_eam_mat_req_rec;

        end if;

        EAM_PROCESS_WO_PUB.PROCESS_WO
        (  p_bo_identifier           => 'EAM'
         , p_api_version_number      => 1.0
         , p_init_msg_list           => FALSE
         , p_commit                  => 'N'
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
         , x_return_status           => l_return_status
         , x_msg_count               => l_msg_count
         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_output_dir              =>  l_output_dir
         , p_debug_filename          => 'diitemdel.log'
         , p_debug_file_mode         => 'w'
         );

         x_return_status := l_return_status;
	 x_material_shortage_flag := l_out_eam_wo_rec.material_shortage_flag;
         x_material_shortage_check_date := l_out_eam_wo_rec.material_shortage_check_date;

        END Delete_Row;

--Fix for 3352406.Added the following procedure to show the messages from the api
        /********************************************************************
        * Procedure     : show_mesg
        * Purpose       : Procedure will concatenate all the messages
	                  from the workorder api and return 1 string
        *********************************************************************/
	PROCEDURE show_mesg IS
		 l_msg_count NUMBER;
		 mesg varchar2(2000);
		  i NUMBER;
		  msg_index number;
		 temp varchar2(500);
	BEGIN
	   mesg := '';

	   l_msg_count := fnd_msg_pub.count_msg;
	IF(l_msg_count>0) THEN

	 msg_index := l_msg_count;

	 for i in 1..l_msg_count loop
		 fnd_msg_pub.get(p_msg_index => FND_MSG_PUB.G_NEXT,
                    p_encoded   => 'F',
                    p_data      => temp,
                    p_msg_index_out => msg_index);
		msg_index := msg_index-1;
		mesg := mesg || '    ' ||  to_char(i) || ' . '||temp ;
	end loop;
		fnd_message.set_name('EAM','EAM_WO_API_MESG');

		fnd_message.set_token(token => 'MESG',
			  	  value =>mesg,
			  	  translate =>FALSE);
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

     END show_mesg;

END EAM_DIRECT_ITEMS_PKG_PVT;

/
