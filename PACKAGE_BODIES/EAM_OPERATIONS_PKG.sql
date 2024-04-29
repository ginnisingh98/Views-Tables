--------------------------------------------------------
--  DDL for Package Body EAM_OPERATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_OPERATIONS_PKG" as
/* $Header: EAMOPTHB.pls 120.1 2006/03/14 20:44:59 pkathoti noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Operation_Seq_Num              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Repetitive_Schedule_Id         NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Operation_Sequence_Id          NUMBER,
                       X_Standard_Operation_Id          NUMBER,
                       X_Department_Id                  NUMBER,
		       X_Shutdown_Type			VARCHAR2,
		       X_Operation_Completed		VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Scheduled_Quantity             NUMBER,
                       X_Quantity_In_Queue              NUMBER,
                       X_Quantity_Running               NUMBER,
                       X_Quantity_Waiting_To_Move       NUMBER,
                       X_Quantity_Rejected              NUMBER,
                       X_Quantity_Scrapped              NUMBER,
                       X_Quantity_Completed             NUMBER,
                       X_First_Unit_Start_Date          DATE,
                       X_First_Unit_Completion_Date     DATE,
                       X_Last_Unit_Start_Date           DATE,
                       X_Last_Unit_Completion_Date      DATE,
                       X_Previous_Operation_Seq_Num     NUMBER,
                       X_Next_Operation_Seq_Num         NUMBER,
                       X_Count_Point_Type               NUMBER,
                       X_Backflush_Flag                 NUMBER,
                       X_Minimum_Transfer_Quantity      NUMBER,
                       X_Date_Last_Moved                DATE,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
		       X_X_Pos				NUMBER,
		       X_Y_Pos				NUMBER,
  		       X_LONG_DESCRIPTION               VARCHAR2,
		       X_L_EAM_OP_REC	OUT NOCOPY	EAM_PROCESS_WO_PUB.eam_op_rec_type,
		       X_WO_Start_Date OUT NOCOPY DATE,
		       X_WO_Completion_Date OUT NOCOPY DATE
) IS
     x_user_id		number	:= FND_GLOBAL.USER_ID;
     x_login_id		number	:= FND_GLOBAL.LOGIN_ID;
     x_request_id       number  := FND_GLOBAL.CONC_REQUEST_ID;
     x_appl_id          number  := FND_GLOBAL.PROG_APPL_ID;
     x_program_id       number  := FND_GLOBAL.CONC_PROGRAM_ID;
     x_standard_op	boolean	:= (X_Standard_Operation_Id is NOT NULL);

     l_return_status    VARCHAR2(1);
     l_msg_count        NUMBER;
     l_msg_data         VARCHAR2(1000);
     l_error_message    VARCHAR2(1000);
     l_output_dir	VARCHAR2(255);

     l_eam_op_rec	EAM_PROCESS_WO_PUB.eam_op_rec_type;

    l_eam_wo_rec		EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_eam_op_tbl                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_eam_op_network_tbl    	EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_eam_res_tbl               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_eam_res_inst_tbl          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl       	EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl         EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl      	EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_eam_di_tbl         	EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_out_eam_wo_rec		EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_out_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_out_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_out_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_out_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_out_eam_di_tbl         	EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    BEGIN

    l_return_status         := FND_API.G_RET_STS_SUCCESS;


     /* get output directory path from database */
     EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

     l_eam_op_rec.HEADER_ID                     := 1;
     l_eam_op_rec.BATCH_ID                      := 1;
     l_eam_op_rec.WIP_ENTITY_ID                 := X_Wip_Entity_Id;
     l_eam_op_rec.ORGANIZATION_ID               := X_Organization_Id;
     l_eam_op_rec.OPERATION_SEQ_NUM             := X_Operation_Seq_Num;
     l_eam_op_rec.STANDARD_OPERATION_ID         := X_Standard_Operation_Id;
     l_eam_op_rec.DEPARTMENT_ID                 := X_Department_Id;
     l_eam_op_rec.OPERATION_SEQUENCE_ID         := X_Operation_Sequence_Id;
     l_eam_op_rec.DESCRIPTION                   := X_Description;
     l_eam_op_rec.MINIMUM_TRANSFER_QUANTITY     := X_Minimum_Transfer_Quantity;
     l_eam_op_rec.COUNT_POINT_TYPE              := X_Count_Point_Type;
     l_eam_op_rec.BACKFLUSH_FLAG                := X_Backflush_Flag;
     l_eam_op_rec.SHUTDOWN_TYPE                 := X_Shutdown_Type;
     l_eam_op_rec.START_DATE                    := X_First_Unit_Start_Date;
     l_eam_op_rec.COMPLETION_DATE               := X_Last_Unit_Completion_Date;
     l_eam_op_rec.ATTRIBUTE_CATEGORY            := X_Attribute_Category;
     l_eam_op_rec.ATTRIBUTE1                    := X_Attribute1;
     l_eam_op_rec.ATTRIBUTE2                    := X_Attribute2;
     l_eam_op_rec.ATTRIBUTE3                    := X_Attribute3;
     l_eam_op_rec.ATTRIBUTE4                    := X_Attribute4;
     l_eam_op_rec.ATTRIBUTE5                    := X_Attribute5;
     l_eam_op_rec.ATTRIBUTE6                    := X_Attribute6;
     l_eam_op_rec.ATTRIBUTE7                    := X_Attribute7;
     l_eam_op_rec.ATTRIBUTE8                    := X_Attribute8;
     l_eam_op_rec.ATTRIBUTE9                    := X_Attribute9;
     l_eam_op_rec.ATTRIBUTE10                   := X_Attribute10;
     l_eam_op_rec.ATTRIBUTE11                   := X_Attribute11;
     l_eam_op_rec.ATTRIBUTE12                   := X_Attribute12;
     l_eam_op_rec.ATTRIBUTE13                   := X_Attribute13;
     l_eam_op_rec.ATTRIBUTE14                   := X_Attribute14;
     l_eam_op_rec.ATTRIBUTE15                   := X_Attribute15;
     l_eam_op_rec.LONG_DESCRIPTION              := X_LONG_DESCRIPTION;
     l_eam_op_rec.TRANSACTION_TYPE              := EAM_PROCESS_WO_PUB.G_OPR_CREATE;
     --Added for bug#4318049
     l_eam_op_rec.X_POS                         := X_x_pos;
     l_eam_op_rec.Y_POS                         := X_y_pos;


     l_eam_op_tbl(1) := l_eam_op_rec;

    /* Call Work Order API to perform the operations */

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
         , p_commit                  => 'N'
         , x_return_status           => l_return_status
         , x_msg_count               => l_msg_count
         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_debug_filename          => 'EAMOPTHB.log'
	 , p_debug_file_mode	     => 'W'
         , p_output_dir              => l_output_dir
         );

	IF (l_return_status = 'S') THEN
		X_L_EAM_OP_REC := l_out_eam_op_tbl(1);
		IF(l_out_eam_wo_rec.scheduled_start_date IS NOT NULL)THEN
		     X_WO_Start_Date := l_out_eam_wo_rec.scheduled_start_date;
		    X_WO_Completion_Date := l_out_eam_wo_rec.scheduled_completion_date;
		END IF;

	ELSE
		EAM_WORKORDER_UTIL_PKG.show_mesg;
        END IF;

  END Insert_Row;


  PROCEDURE Update_Row(X_Rowid                   	VARCHAR2,
                       X_Wip_Entity_Id                  NUMBER,
                       X_Operation_Seq_Num              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Operation_Sequence_Id          NUMBER,
                       X_Standard_Operation_Id          NUMBER,
                       X_Department_Id                  NUMBER,
		       X_Shutdown_Type			VARCHAR2,
		       X_Operation_Completed		VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_First_Unit_Start_Date          DATE,
                       X_First_Unit_Completion_Date     DATE,
                       X_Last_Unit_Start_Date           DATE,
                       X_Last_Unit_Completion_Date      DATE,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
		       X_X_Pos				NUMBER,
		       X_Y_Pos				NUMBER,
		       X_Long_Description               VARCHAR2,
       		       X_L_EAM_OP_REC	   OUT NOCOPY	EAM_PROCESS_WO_PUB.eam_op_rec_type,
		       X_WO_Start_Date OUT NOCOPY DATE,
		       X_WO_Completion_Date OUT NOCOPY DATE

		       ) IS

     l_return_status    VARCHAR2(1);
     l_msg_count        NUMBER;
     l_msg_data         VARCHAR2(1000);
     l_error_message    VARCHAR2(1000);
     l_output_dir	VARCHAR2(255);
     l_start_date	DATE;
     l_end_date		DATE;

     l_eam_op_rec	EAM_PROCESS_WO_PUB.eam_op_rec_type;

    l_eam_wo_rec		EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_eam_op_tbl                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_eam_op_network_tbl    	EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_eam_res_tbl               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_eam_res_inst_tbl          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl       	EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl         EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl      	EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_eam_di_tbl         	EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_out_eam_wo_rec		EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_out_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_out_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_out_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_out_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_out_eam_di_tbl         	EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    BEGIN

    l_return_status         := FND_API.G_RET_STS_SUCCESS;


     /* get output directory path from database */
     EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

     l_eam_op_rec.HEADER_ID                     := 1;
     l_eam_op_rec.BATCH_ID                      := 1;
     l_eam_op_rec.WIP_ENTITY_ID                 := X_Wip_Entity_Id;
     l_eam_op_rec.ORGANIZATION_ID               := X_Organization_Id;
     l_eam_op_rec.OPERATION_SEQ_NUM             := X_Operation_Seq_Num;
     l_eam_op_rec.STANDARD_OPERATION_ID         := X_Standard_Operation_Id;
     l_eam_op_rec.DEPARTMENT_ID                 := X_Department_Id;
     l_eam_op_rec.OPERATION_SEQUENCE_ID         := X_Operation_Sequence_Id;
     l_eam_op_rec.DESCRIPTION                   := X_Description;
     l_eam_op_rec.SHUTDOWN_TYPE                 := X_Shutdown_Type;
     l_eam_op_rec.START_DATE                    := X_First_Unit_Start_Date;
     l_eam_op_rec.COMPLETION_DATE               := X_Last_Unit_Completion_Date;
     l_eam_op_rec.ATTRIBUTE_CATEGORY            := X_Attribute_Category;
     l_eam_op_rec.ATTRIBUTE1                    := X_Attribute1;
     l_eam_op_rec.ATTRIBUTE2                    := X_Attribute2;
     l_eam_op_rec.ATTRIBUTE3                    := X_Attribute3;
     l_eam_op_rec.ATTRIBUTE4                    := X_Attribute4;
     l_eam_op_rec.ATTRIBUTE5                    := X_Attribute5;
     l_eam_op_rec.ATTRIBUTE6                    := X_Attribute6;
     l_eam_op_rec.ATTRIBUTE7                    := X_Attribute7;
     l_eam_op_rec.ATTRIBUTE8                    := X_Attribute8;
     l_eam_op_rec.ATTRIBUTE9                    := X_Attribute9;
     l_eam_op_rec.ATTRIBUTE10                   := X_Attribute10;
     l_eam_op_rec.ATTRIBUTE11                   := X_Attribute11;
     l_eam_op_rec.ATTRIBUTE12                   := X_Attribute12;
     l_eam_op_rec.ATTRIBUTE13                   := X_Attribute13;
     l_eam_op_rec.ATTRIBUTE14                   := X_Attribute14;
     l_eam_op_rec.ATTRIBUTE15                   := X_Attribute15;
     l_eam_op_rec.LONG_DESCRIPTION              := X_LONG_DESCRIPTION;
     l_eam_op_rec.TRANSACTION_TYPE              := EAM_PROCESS_WO_PUB.G_OPR_UPDATE;
     --Added for bug#4615678
     l_eam_op_rec.X_POS                         := X_x_pos;
     l_eam_op_rec.Y_POS                         := X_y_pos;


     l_eam_op_tbl(1) := l_eam_op_rec;

    /* Call Work Order API to perform the operations */

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
         , p_commit                  => 'N'
         , x_return_status           => l_return_status
         , x_msg_count               => l_msg_count
         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_debug_filename          => 'EAMOPTHB.log'
	 , p_debug_file_mode	     => 'W'
         , p_output_dir              => l_output_dir
         );


	IF (l_return_status = 'S') THEN
		X_L_EAM_OP_REC := l_out_eam_op_tbl(1);
		IF(l_out_eam_wo_rec.scheduled_start_date IS NOT NULL)THEN
		     X_WO_Start_Date := l_out_eam_wo_rec.scheduled_start_date;
		    X_WO_Completion_Date := l_out_eam_wo_rec.scheduled_completion_date;
		END IF;

	ELSE
		EAM_WORKORDER_UTIL_PKG.show_mesg;
        END IF;

  END Update_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Wip_Entity_Id                    NUMBER,
                     X_Operation_Seq_Num                NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Operation_Sequence_Id            NUMBER,
                     X_Standard_Operation_Id            NUMBER,
                     X_Department_Id                    NUMBER,
		     X_Shutdown_Type			VARCHAR2,
		     X_Operation_Completed		VARCHAR2,
                     X_Description                      VARCHAR2,
                     X_First_Unit_Start_Date            DATE,
                     X_First_Unit_Completion_Date       DATE,
                     X_Last_Unit_Start_Date             DATE,
                     X_Last_Unit_Completion_Date        DATE,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
		     X_X_Pos				NUMBER,
		     X_Y_Pos				NUMBER,
	 	     X_Long_Description			VARCHAR2) IS
    CURSOR C IS
        SELECT *
        FROM   WIP_OPERATIONS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Wip_Entity_Id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      fnd_message.raise_error;
      app_exception.raise_exception;
    end if;
    CLOSE C;


    if         (Recinfo.wip_entity_id = X_Wip_Entity_Id)
           AND (Recinfo.operation_seq_num = X_Operation_Seq_Num)
           AND (Recinfo.organization_id = X_Organization_Id)
           AND (nvl(Recinfo.operation_sequence_id, 1) =
                nvl(X_Operation_Sequence_Id, 1))
           AND (nvl(Recinfo.standard_operation_id, 1) =
	        nvl(X_Standard_Operation_Id, 1))
           AND (Recinfo.department_id = X_Department_Id)
           AND (nvl(Recinfo.shutdown_type, 'xxx') =
	        nvl(X_Shutdown_Type,'xxx'))
           AND (Recinfo.operation_completed = X_Operation_Completed or
	        Recinfo.operation_completed is null)
           AND (nvl(Recinfo.description, 'xxx') =
	        nvl(X_Description,'xxx'))
           AND (Recinfo.first_unit_start_date = X_First_Unit_Start_Date)
           AND (Recinfo.first_unit_completion_date = X_First_Unit_Completion_Date)
           AND (Recinfo.last_unit_start_date = X_Last_Unit_Start_Date)
           AND (Recinfo.last_unit_completion_date = X_Last_Unit_Completion_Date)
    then
          if (  (nvl(Recinfo.attribute_category, 'xxx') =
		 nvl(X_Attribute_Category, 'xxx'))
           AND  (nvl(Recinfo.attribute1, 'xxx') =
		 nvl(X_Attribute1, 'xxx'))
           AND  (nvl(Recinfo.attribute2, 'xxx') =
		 nvl(X_Attribute2, 'xxx'))
           AND  (nvl(Recinfo.attribute3, 'xxx') =
		 nvl(X_Attribute3, 'xxx'))
           AND  (nvl(Recinfo.attribute4, 'xxx') =
		 nvl(X_Attribute4, 'xxx'))
           AND  (nvl(Recinfo.attribute5, 'xxx') =
		 nvl(X_Attribute5, 'xxx'))
           AND  (nvl(Recinfo.attribute6, 'xxx') =
		 nvl(X_Attribute6, 'xxx'))
           AND  (nvl(Recinfo.attribute7, 'xxx') =
		 nvl(X_Attribute7, 'xxx'))
           AND  (nvl(Recinfo.attribute8, 'xxx') =
		 nvl(X_Attribute8, 'xxx'))
           AND  (nvl(Recinfo.attribute9, 'xxx') =
		 nvl(X_Attribute9, 'xxx'))
           AND  (nvl(Recinfo.attribute10, 'xxx') =
		 nvl(X_Attribute10, 'xxx'))
           AND  (nvl(Recinfo.attribute11, 'xxx') =
		 nvl(X_Attribute11, 'xxx'))
           AND  (nvl(Recinfo.attribute12, 'xxx') =
		 nvl(X_Attribute12, 'xxx'))
           AND  (nvl(Recinfo.attribute13, 'xxx') =
		 nvl(X_Attribute13, 'xxx'))
           AND  (nvl(Recinfo.attribute14, 'xxx') =
		 nvl(X_Attribute14, 'xxx'))
           AND  (nvl(Recinfo.attribute15, 'xxx') =
		 nvl(X_Attribute15, 'xxx'))
/*           AND  (nvl(Recinfo.long_description, 'xxx') =
		 nvl(X_Long_Description, 'xxx'))*/
           )
      then
        return;
      else
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        fnd_message.raise_error;
        app_exception.raise_exception;
      end if;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      fnd_message.raise_error;
      app_exception.raise_exception;
    end if;
  END Lock_Row;


  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
		       X_WO_Start_Date OUT NOCOPY DATE,
		       X_WO_Completion_Date OUT NOCOPY DATE) IS

     l_return_status    VARCHAR2(1);
      l_msg_count        NUMBER;
     l_msg_data         VARCHAR2(1000);
     l_error_message    VARCHAR2(1000);
     l_output_dir	VARCHAR2(255);
     l_start_date	DATE;
     l_end_date		DATE;
     l_wip_entity_id	NUMBER;
     l_organization_id	NUMBER;
     l_operation_seq_num NUMBER;

     l_eam_op_rec	EAM_PROCESS_WO_PUB.eam_op_rec_type;

    l_eam_wo_rec		EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_eam_op_tbl                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_eam_op_network_tbl    	EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_eam_res_tbl               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_eam_res_inst_tbl          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl       	EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl         EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl      	EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_eam_di_tbl         	EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_out_eam_wo_rec		EAM_PROCESS_WO_PUB.eam_wo_rec_type;
    l_out_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_out_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_out_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_out_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_out_eam_di_tbl         	EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
    l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    BEGIN

    l_return_status         := FND_API.G_RET_STS_SUCCESS;


     /* get output directory path from database */
     EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

	select wip_entity_id,
		organization_id,
		operation_seq_num
	into	l_wip_entity_id,
		l_organization_id,
		l_operation_seq_num
	from
		wip_operations
	where	rowid=X_Rowid;

     l_eam_op_rec.HEADER_ID                     := 1;
     l_eam_op_rec.BATCH_ID                      := 1;
     l_eam_op_rec.WIP_ENTITY_ID                 := l_wip_entity_id;
     l_eam_op_rec.ORGANIZATION_ID               := l_organization_id;
     l_eam_op_rec.OPERATION_SEQ_NUM             := l_operation_seq_num;
     l_eam_op_rec.TRANSACTION_TYPE              := EAM_PROCESS_WO_PUB.G_OPR_DELETE;

     l_eam_op_tbl(1) := l_eam_op_rec;

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
         , p_commit                  => 'N'
         , x_return_status           => l_return_status
         , x_msg_count               => l_msg_count
         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_debug_filename          => 'EAMOPTHB.log'
	 , p_debug_file_mode	     => 'W'
         , p_output_dir              => l_output_dir
         );

	IF (l_return_status <> 'S') THEN
		EAM_WORKORDER_UTIL_PKG.show_mesg;
	ELSE
                IF(l_out_eam_wo_rec.scheduled_start_date IS NOT NULL)THEN
		    X_WO_Start_Date := l_out_eam_wo_rec.scheduled_start_date;
		    X_WO_Completion_Date := l_out_eam_wo_rec.scheduled_completion_date;
		END IF;

        END IF;

   EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RAISE NO_DATA_FOUND;
   END Delete_Row;


END EAM_OPERATIONS_PKG;

/
