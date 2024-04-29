--------------------------------------------------------
--  DDL for Package Body EAM_PROCESS_WO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PROCESS_WO_PUB" AS
/* $Header: EAMPWOPB.pls 120.21.12010000.20 2012/05/30 07:05:41 vboddapa ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMPWOPB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_PROCESS_WO_PUB
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/
g_pkg_name    CONSTANT VARCHAR2(30):= 'EAM_PROCESS_WO_PUB';

         PROCEDURE DELETE_RELATIONSHIP
         ( p_api_version                   IN NUMBER
         , p_init_msg_list                 IN VARCHAR2 := FND_API.G_TRUE
         , p_commit                        IN VARCHAR2 := FND_API.G_FALSE
         , p_validation_level              IN NUMBER   := FND_API.G_VALID_LEVEL_FULL

         , p_parent_object_id              IN NUMBER
         , p_parent_object_type_id         IN NUMBER
         , p_child_object_id               IN NUMBER
         , p_child_object_type_id          IN NUMBER
         , p_new_parent_object_id          IN NUMBER
         , p_new_parent_object_type_id     IN NUMBER

         , x_return_status                 OUT NOCOPY  VARCHAR2
         , x_msg_count                     OUT NOCOPY  NUMBER
         , x_msg_data                      OUT NOCOPY  VARCHAR2
         ) IS
         BEGIN
           null;
         END DELETE_RELATIONSHIP;

	PROCEDURE PROCESS_MASTER_CHILD_WO
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_eam_wo_relations_tbl    IN  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type
         , p_eam_wo_tbl              IN  EAM_PROCESS_WO_PUB.eam_wo_tbl_type
         , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
	 , p_eam_wo_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type
         , p_eam_wo_quality_tbl      IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
         , p_eam_meter_reading_tbl   IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
 	 , p_eam_counter_prop_tbl    IN  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
         , p_eam_wo_comp_rebuild_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
         , p_eam_wo_comp_mr_read_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
         , p_eam_op_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	 , p_eam_request_tbl         IN  EAM_PROCESS_WO_PUB.eam_request_tbl_type
         , x_eam_wo_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_tbl_type
         , x_eam_wo_relations_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_wo_comp_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type
         , x_eam_wo_quality_tbl      OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
         , x_eam_meter_reading_tbl   OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
  	 , x_eam_counter_prop_tbl    OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
         , x_eam_wo_comp_rebuild_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
         , x_eam_wo_comp_mr_read_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
         , x_eam_op_comp_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	 , x_eam_request_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_request_tbl_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_commit                  IN  VARCHAR2 := 'N'
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'EAM_WO_DEBUG.log'
         , p_debug_file_mode         IN  VARCHAR2 := 'w'
         )IS

        G_EXC_SEV_QUIT_OBJECT   EXCEPTION;
        G_EXC_UNEXP_SKIP_OBJECT EXCEPTION;
        l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_other_message         VARCHAR2(50);
        l_other_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
        l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
        l_err_text              VARCHAR2(2000);
        l_return_status         VARCHAR2(1) := null;
        l_eam_return_status     VARCHAR2(1) := null;
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(1000);
        l_debug                 VARCHAR2(1) := p_debug;
        l_output_dir            VARCHAR2(512) := p_output_dir;
        l_debug_filename        VARCHAR2(512) := p_debug_filename;
        l_debug_file_mode       VARCHAR2(512) := p_debug_file_mode;

        l_message_text  VARCHAR2(1000);
        l_entity_index      NUMBER;
        l_entity_id         VARCHAR2(100);
        l_message_type      VARCHAR2(100);

        l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_wo_tbl            EAM_PROCESS_WO_PUB.eam_wo_tbl_type := p_eam_wo_tbl;
        l_eam_wo_relations_tbl  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type := p_eam_wo_relations_tbl;
        l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type := p_eam_op_tbl;
        l_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type := p_eam_op_network_tbl;
        l_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type := p_eam_res_tbl;
        l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type := p_eam_res_inst_tbl;
        l_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type := p_eam_sub_res_tbl;
        l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type := p_eam_res_usage_tbl;
        l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type := p_eam_mat_req_tbl;
        l_eam_di_tbl		EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type := p_eam_direct_items_tbl;

	l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type := p_eam_wo_comp_tbl;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type := p_eam_wo_quality_tbl;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type := p_eam_meter_reading_tbl;
	l_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type := p_eam_counter_prop_tbl;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type := p_eam_wo_comp_rebuild_tbl;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type := p_eam_wo_comp_mr_read_tbl;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type := p_eam_op_comp_tbl;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type := p_eam_request_tbl;

        l_eam_wo_rec_head         EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_tbl_head         EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_eam_op_network_tbl_head EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl_head        EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_eam_res_inst_tbl_head   EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_eam_sub_res_tbl_head    EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_eam_res_usage_tbl_head  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_eam_mat_req_tbl_head    EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_eam_di_tbl_head         EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

	l_eam_wo_comp_rec_head		EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_eam_wo_comp_tbl_head		EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_eam_wo_quality_tbl_head	EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl_head	EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_wo_comp_rebuild_tbl_head	EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_counter_prop_tbl_head	EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_eam_wo_comp_mr_read_tbl_head	EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl_head		EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl_head		EAM_PROCESS_WO_PUB.eam_request_tbl_type;

        l_out_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_out_eam_wo_tbl            EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
        l_out_eam_wo_relations_tbl  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
        l_out_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_out_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_out_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_out_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_out_eam_di_tbl            EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
        l_out_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.mesg_token_tbl_type;

	l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;

        l_out_eam_wo_rec_main            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_out_eam_wo_tbl_main            EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
        l_out_eam_wo_rel_tbl_main        EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
        l_out_eam_op_tbl_main            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_out_eam_op_network_tbl_main    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_out_eam_res_tbl_main           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl_main      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_sub_res_tbl_main       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_out_eam_res_usage_tbl_main     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_out_eam_mat_req_tbl_main       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_out_eam_di_tbl_main            EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
        l_out_mesg_token_tbl_main        EAM_ERROR_MESSAGE_PVT.mesg_token_tbl_type;

	l_out_eam_wo_comp_rec_main	EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_out_eam_wo_comp_tbl_main	EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_out_eam_wo_quality_tbl_main	EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_ou_eam_meter_reading_tbl_m	EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_counter_prop_tbl_m    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_ou_eam_wo_comp_rebuild_tbl_m	EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_ou_eam_wo_comp_mr_read_tbl_m	EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl_main	EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl_main	EAM_PROCESS_WO_PUB.eam_request_tbl_type;

        l_debug_flag            VARCHAR2(1) := p_debug;

        l_batch_id              NUMBER :=null;
        l_header_id             NUMBER :=null;
        l_header_id_tbl         EAM_PROCESS_WO_PUB.header_id_tbl_type;

	l_wo_relationship_exc_tbl EAM_PROCESS_WO_PUB.wo_relationship_exc_tbl_type;

	--Added for bug#4563210
	l_temp_wip_entity_id	NUMBER;
	l_wo_name		VARCHAR2(240);



--	l_test_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;


        BEGIN


	--
        -- Initialize the message list if the user has set the Init Message List parameter
        --
        IF p_init_msg_list
        THEN
            EAM_ERROR_MESSAGE_PVT.Initialize;
        END IF;



        SAVEPOINT EAM_PR_MASTER_CHILD_WO;


        if p_eam_wo_tbl.count <> 0 then
          l_eam_wo_rec := p_eam_wo_tbl(p_eam_wo_tbl.first);
        end if;


        -- Set the global variable for debug.
        EAM_PROCESS_WO_PVT.Set_Debug(l_debug_flag);

        IF l_debug_flag = 'Y'
        THEN

            IF trim(p_output_dir) IS NULL OR trim(p_output_dir) = ''
            THEN

            -- If debug is Y then out dir must be specified

                l_out_mesg_token_tbl := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_text       => 'Debug is set to Y so an output directory' || ' must be specified. Debug will be turned' || ' off since no directory is specified'
                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                , x_Mesg_Token_Tbl     => l_out_mesg_token_tbl
                , p_Token_Tbl          => l_token_tbl
                 );
                l_mesg_token_tbl := l_out_mesg_token_tbl;

                l_out_eam_wo_rec            := l_eam_wo_rec;
                l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
                l_out_eam_di_tbl            := l_eam_di_tbl;

		l_out_eam_wo_comp_rec         := l_eam_wo_comp_rec;
		l_out_eam_wo_quality_tbl      := l_eam_wo_quality_tbl;
		l_out_eam_meter_reading_tbl   := l_eam_meter_reading_tbl;
		l_out_eam_counter_prop_tbl    := l_eam_counter_prop_tbl;
		l_out_eam_wo_comp_rebuild_tbl := l_eam_wo_comp_rebuild_tbl;
		l_out_eam_wo_comp_mr_read_tbl := l_eam_wo_comp_mr_read_tbl;
		l_out_eam_op_comp_tbl         := l_eam_op_comp_tbl;
		l_out_eam_request_tbl         := l_eam_request_tbl;

                EAM_ERROR_MESSAGE_PVT.Log_Error
                (  p_eam_wo_rec             => l_eam_wo_rec
                ,  p_eam_op_tbl             => l_eam_op_tbl
                ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
                ,  p_eam_res_tbl            => l_eam_res_tbl
                ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
                ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
                ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
                ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
                ,  p_eam_direct_items_tbl        => l_eam_di_tbl
                ,  p_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_BO_LEVEL
                ,  x_eam_wo_rec             => l_out_eam_wo_rec
                ,  x_eam_op_tbl             => l_out_eam_op_tbl
                ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
                ,  x_eam_res_tbl            => l_out_eam_res_tbl
                ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
                ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
                ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
                ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
                ,  x_eam_direct_items_tbl        => l_out_eam_di_tbl
                 );

                l_eam_wo_rec            := l_out_eam_wo_rec;
                l_eam_op_tbl            := l_out_eam_op_tbl;
                l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
                l_eam_res_tbl           := l_out_eam_res_tbl;
                l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
                l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
                l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
                l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
                l_eam_di_tbl            := l_out_eam_di_tbl;

		l_eam_wo_comp_rec         :=  l_out_eam_wo_comp_rec;
		l_eam_wo_quality_tbl      :=  l_out_eam_wo_quality_tbl;
		l_eam_meter_reading_tbl   :=  l_out_eam_meter_reading_tbl;
		l_eam_counter_prop_tbl    :=  l_out_eam_counter_prop_tbl;
		l_eam_wo_comp_rebuild_tbl :=  l_out_eam_wo_comp_rebuild_tbl;
		l_eam_wo_comp_mr_read_tbl :=  l_out_eam_wo_comp_mr_read_tbl;
		l_eam_op_comp_tbl         :=  l_out_eam_op_comp_tbl;
		l_eam_request_tbl         :=  l_out_eam_request_tbl;


                l_debug_flag := 'N';

            END IF;

            IF trim(p_debug_filename) IS NULL OR trim(p_debug_filename) = ''
            THEN

                l_out_mesg_token_tbl := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_text       => 'Debug is set to Y so an output filename' || ' must be specified. Debug will be turned' || ' off since no filename is specified'
                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                , x_Mesg_Token_Tbl     => l_out_mesg_token_tbl
                , p_Token_Tbl          => l_token_tbl
                 );
                l_mesg_token_tbl := l_out_mesg_token_tbl;

                l_out_eam_wo_rec            := l_eam_wo_rec;
                l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
                l_out_eam_di_tbl            := l_eam_di_tbl;

		l_out_eam_wo_comp_rec         := l_eam_wo_comp_rec;
		l_out_eam_wo_quality_tbl      := l_eam_wo_quality_tbl;
		l_out_eam_meter_reading_tbl   := l_eam_meter_reading_tbl;
		l_out_eam_counter_prop_tbl    := l_eam_counter_prop_tbl;
		l_out_eam_wo_comp_rebuild_tbl := l_eam_wo_comp_rebuild_tbl;
		l_out_eam_wo_comp_mr_read_tbl := l_eam_wo_comp_mr_read_tbl;
		l_out_eam_op_comp_tbl         := l_eam_op_comp_tbl;
		l_out_eam_request_tbl         := l_eam_request_tbl;

                EAM_ERROR_MESSAGE_PVT.Log_Error
                (  p_eam_wo_rec             => l_eam_wo_rec
                ,  p_eam_op_tbl             => l_eam_op_tbl
                ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
                ,  p_eam_res_tbl            => l_eam_res_tbl
                ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
                ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
                ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
                ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
                ,  p_eam_direct_items_tbl   => l_eam_di_tbl
                ,  p_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_BO_LEVEL
                ,  x_eam_wo_rec             => l_out_eam_wo_rec
                ,  x_eam_op_tbl             => l_out_eam_op_tbl
                ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
                ,  x_eam_res_tbl            => l_out_eam_res_tbl
                ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
                ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
                ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
                ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
                ,  x_eam_direct_items_tbl   => l_out_eam_di_tbl
                 );

                l_eam_wo_rec            := l_out_eam_wo_rec;
                l_eam_op_tbl            := l_out_eam_op_tbl;
                l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
                l_eam_res_tbl           := l_out_eam_res_tbl;
                l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
                l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
                l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
                l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
                l_eam_di_tbl            := l_out_eam_di_tbl;

		l_eam_wo_comp_rec         :=  l_out_eam_wo_comp_rec;
		l_eam_wo_quality_tbl      :=  l_out_eam_wo_quality_tbl;
		l_eam_meter_reading_tbl   :=  l_out_eam_meter_reading_tbl;
		l_eam_counter_prop_tbl    :=  l_out_eam_counter_prop_tbl;
		l_eam_wo_comp_rebuild_tbl :=  l_out_eam_wo_comp_rebuild_tbl;
		l_eam_wo_comp_mr_read_tbl :=  l_out_eam_wo_comp_mr_read_tbl;
		l_eam_op_comp_tbl         :=  l_out_eam_op_comp_tbl;
		l_eam_request_tbl         :=  l_out_eam_request_tbl;

                l_debug_flag := 'N';

            END IF;

            EAM_PROCESS_WO_PVT.Set_Debug(l_debug_flag);

            IF l_debug_flag = 'Y'
            THEN
                l_out_mesg_token_tbl        := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Open_Debug_Session
                (  p_debug_filename     => p_debug_filename
                ,  p_output_dir         => p_output_dir
                ,  p_debug_file_mode    => l_debug_file_mode
                ,  x_return_status      => l_return_status
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  x_mesg_token_tbl     => l_out_mesg_token_tbl
                 );
                l_mesg_token_tbl        := l_out_mesg_token_tbl;

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                    EAM_PROCESS_WO_PVT.Set_Debug('N');
                END IF;
            END IF;

        END IF;




        l_return_status     := FND_API.G_RET_STS_SUCCESS;
        l_eam_return_status := FND_API.G_RET_STS_SUCCESS;
        x_return_status     := FND_API.G_RET_STS_SUCCESS;

        l_eam_wo_tbl.delete;
        l_eam_wo_relations_tbl.delete;
        l_eam_op_tbl.delete;
        l_eam_op_network_tbl.delete;
        l_eam_res_tbl.delete;
        l_eam_res_inst_tbl.delete;
        l_eam_sub_res_tbl.delete;
        l_eam_mat_req_tbl.delete;
        l_eam_di_tbl.delete;
        l_eam_res_usage_tbl.delete;
	l_eam_wo_comp_tbl.delete;
	l_eam_wo_quality_tbl.delete;
	l_eam_meter_reading_tbl.delete;
	l_eam_counter_prop_tbl.delete;
	l_eam_wo_comp_rebuild_tbl.delete;
	l_eam_wo_comp_mr_read_tbl.delete;
	l_eam_op_comp_tbl.delete;
	l_eam_request_tbl.delete;

        l_eam_wo_tbl            := p_eam_wo_tbl;
        l_eam_wo_relations_tbl  := p_eam_wo_relations_tbl;
        l_eam_op_tbl            := p_eam_op_tbl;
        l_eam_op_network_tbl    := p_eam_op_network_tbl;
        l_eam_res_tbl           := p_eam_res_tbl;
        l_eam_res_inst_tbl      := p_eam_res_inst_tbl;
        l_eam_sub_res_tbl       := p_eam_sub_res_tbl;
        l_eam_mat_req_tbl       := p_eam_mat_req_tbl;
        l_eam_di_tbl            := p_eam_direct_items_tbl;
	l_eam_res_usage_tbl     := p_eam_res_usage_tbl;
	l_eam_wo_comp_tbl	:= p_eam_wo_comp_tbl;
	l_eam_wo_quality_tbl	:= p_eam_wo_quality_tbl;
	l_eam_meter_reading_tbl := p_eam_meter_reading_tbl;
	l_eam_counter_prop_tbl  := p_eam_counter_prop_tbl;
	l_eam_wo_comp_rebuild_tbl := p_eam_wo_comp_rebuild_tbl;
	l_eam_wo_comp_mr_read_tbl := p_eam_wo_comp_mr_read_tbl;
	l_eam_op_comp_tbl	:= p_eam_op_comp_tbl;
	l_eam_request_tbl	:= p_eam_request_tbl;

        l_out_eam_wo_tbl.delete;
        l_out_eam_wo_relations_tbl.delete;
        l_out_eam_op_tbl.delete;
        l_out_eam_op_network_tbl.delete;
        l_out_eam_res_tbl.delete;
        l_out_eam_res_inst_tbl.delete;
        l_out_eam_sub_res_tbl.delete;
        l_out_eam_mat_req_tbl.delete;
        l_out_eam_di_tbl.delete;
	l_out_eam_res_usage_tbl.delete;
	l_out_eam_wo_comp_tbl.delete;
	l_out_eam_wo_quality_tbl.delete;
	l_out_eam_meter_reading_tbl.delete;
	l_out_eam_counter_prop_tbl.delete;
	l_out_eam_wo_comp_rebuild_tbl.delete;
	l_out_eam_wo_comp_mr_read_tbl.delete;
	l_out_eam_op_comp_tbl.delete;
	l_out_eam_request_tbl.delete;

	l_out_eam_wo_tbl            := p_eam_wo_tbl;
        l_out_eam_wo_relations_tbl  := p_eam_wo_relations_tbl;
        l_out_eam_op_tbl            := p_eam_op_tbl;
        l_out_eam_op_network_tbl    := p_eam_op_network_tbl;
        l_out_eam_res_tbl           := p_eam_res_tbl;
        l_out_eam_res_inst_tbl      := p_eam_res_inst_tbl;
        l_out_eam_sub_res_tbl       := p_eam_sub_res_tbl;
	l_out_eam_res_usage_tbl     := p_eam_res_usage_tbl;
        l_out_eam_mat_req_tbl       := p_eam_mat_req_tbl;
        l_out_eam_di_tbl            := p_eam_direct_items_tbl;
	l_out_eam_wo_comp_tbl	    := p_eam_wo_comp_tbl;
	l_out_eam_wo_quality_tbl    := p_eam_wo_quality_tbl;
	l_out_eam_meter_reading_tbl := p_eam_meter_reading_tbl;
	l_out_eam_counter_prop_tbl  := p_eam_counter_prop_tbl;
	l_out_eam_wo_comp_rebuild_tbl := p_eam_wo_comp_rebuild_tbl;
	l_out_eam_wo_comp_mr_read_tbl := p_eam_wo_comp_mr_read_tbl;
	l_out_eam_op_comp_tbl	      := p_eam_op_comp_tbl;
	l_out_eam_request_tbl	      := p_eam_request_tbl;

        l_out_eam_wo_tbl_main.delete;
        l_out_eam_wo_rel_tbl_main.delete;
        l_out_eam_op_tbl_main.delete;
        l_out_eam_op_network_tbl_main.delete;
        l_out_eam_res_tbl_main.delete;
        l_out_eam_res_inst_tbl_main.delete;
        l_out_eam_sub_res_tbl_main.delete;
        l_out_eam_mat_req_tbl_main.delete;
        l_out_eam_di_tbl_main.delete;
	l_out_eam_res_usage_tbl_main.delete;
	l_out_eam_wo_comp_tbl_main.delete;
	l_out_eam_wo_quality_tbl_main.delete;
	l_ou_eam_meter_reading_tbl_m.delete;
	l_out_eam_counter_prop_tbl_m.delete;
	l_ou_eam_wo_comp_rebuild_tbl_m.delete;
	l_ou_eam_wo_comp_mr_read_tbl_m.delete;
	l_out_eam_op_comp_tbl_main.delete;
	l_out_eam_request_tbl_main.delete;
	l_out_eam_counter_prop_tbl_m.delete;

        l_out_eam_wo_tbl_main            := p_eam_wo_tbl;
        l_out_eam_wo_rel_tbl_main        := p_eam_wo_relations_tbl;
        l_out_eam_op_tbl_main            := p_eam_op_tbl;
        l_out_eam_op_network_tbl_main    := p_eam_op_network_tbl;
        l_out_eam_res_tbl_main           := p_eam_res_tbl;
        l_out_eam_res_inst_tbl_main      := p_eam_res_inst_tbl;
        l_out_eam_sub_res_tbl_main       := p_eam_sub_res_tbl;
	l_out_eam_res_usage_tbl_main     := p_eam_res_usage_tbl;
        l_out_eam_mat_req_tbl_main       := p_eam_mat_req_tbl;
        l_out_eam_di_tbl_main            := p_eam_direct_items_tbl;
	l_out_eam_wo_comp_tbl_main	 := p_eam_wo_comp_tbl;
	l_out_eam_wo_quality_tbl_main	 := p_eam_wo_quality_tbl;
 	l_ou_eam_meter_reading_tbl_m	 := p_eam_meter_reading_tbl;
        l_out_eam_counter_prop_tbl       := p_eam_counter_prop_tbl;
	l_ou_eam_wo_comp_rebuild_tbl_m	 := p_eam_wo_comp_rebuild_tbl;
	l_ou_eam_wo_comp_mr_read_tbl_m	 := p_eam_wo_comp_mr_read_tbl;
	l_out_eam_op_comp_tbl_main	 := p_eam_op_comp_tbl;
	l_out_eam_request_tbl_main	 := p_eam_request_tbl;

        x_eam_wo_tbl.delete;
        x_eam_wo_relations_tbl.delete;
        x_eam_op_tbl.delete;
        x_eam_op_network_tbl.delete;
        x_eam_res_tbl.delete;
        x_eam_res_inst_tbl.delete;
        x_eam_sub_res_tbl.delete;
        x_eam_mat_req_tbl.delete;
        x_eam_direct_items_tbl.delete;
	x_eam_res_usage_tbl.delete;
	x_eam_wo_comp_tbl.delete;
	x_eam_wo_quality_tbl.delete;
	x_eam_meter_reading_tbl.delete;
	x_eam_counter_prop_tbl.delete;
	x_eam_wo_comp_rebuild_tbl.delete;
	x_eam_wo_comp_mr_read_tbl.delete;
	x_eam_op_comp_tbl.delete;

        x_eam_wo_tbl              := p_eam_wo_tbl;
        x_eam_wo_relations_tbl    := p_eam_wo_relations_tbl;
        x_eam_op_tbl              := p_eam_op_tbl;
        x_eam_op_network_tbl      := p_eam_op_network_tbl;
        x_eam_res_tbl             := p_eam_res_tbl;
        x_eam_res_inst_tbl        := p_eam_res_inst_tbl;
        x_eam_sub_res_tbl         := p_eam_sub_res_tbl;
	x_eam_res_usage_tbl       := p_eam_res_usage_tbl;
        x_eam_mat_req_tbl         := p_eam_mat_req_tbl;
        x_eam_direct_items_tbl    := p_eam_direct_items_tbl;
	x_eam_res_usage_tbl	  := p_eam_res_usage_tbl;
	x_eam_wo_comp_tbl	  := p_eam_wo_comp_tbl;
	x_eam_wo_quality_tbl      := p_eam_wo_quality_tbl;
	x_eam_meter_reading_tbl   := p_eam_meter_reading_tbl;
	x_eam_counter_prop_tbl    := p_eam_counter_prop_tbl;
	x_eam_wo_comp_rebuild_tbl := p_eam_wo_comp_rebuild_tbl;
	x_eam_wo_comp_mr_read_tbl := p_eam_wo_comp_mr_read_tbl;
	x_eam_op_comp_tbl         := p_eam_op_comp_tbl;

  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN
      EAM_ERROR_MESSAGE_PVT.Write_Debug('') ;
      EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO : Start============================================================================') ;
  END IF ;

  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO : Calling CHECK_BO_NETWORK ...') ; END IF ;


        CHECK_BO_NETWORK
        ( p_eam_wo_tbl              => l_eam_wo_tbl
        , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
        , p_eam_op_tbl              => l_eam_op_tbl
        , p_eam_op_network_tbl      => l_eam_op_network_tbl
        , p_eam_res_tbl             => l_eam_res_tbl
        , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
        , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
        , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
        , p_eam_direct_items_tbl    => l_eam_di_tbl
	, p_eam_res_usage_tbl	    => l_eam_res_usage_tbl
	, p_eam_wo_comp_tbl         => l_eam_wo_comp_tbl
        , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
        , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
        , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
        , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
        , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
        , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
	, p_eam_request_tbl         => l_eam_request_tbl
        , x_eam_wo_tbl              => l_out_eam_wo_tbl
        , x_eam_wo_relations_tbl    => l_out_eam_wo_relations_tbl
        , x_eam_op_tbl              => l_out_eam_op_tbl
        , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
        , x_eam_res_tbl             => l_out_eam_res_tbl
        , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
        , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
        , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
        , x_eam_direct_items_tbl    => l_out_eam_di_tbl
	, x_eam_res_usage_tbl	    => l_out_eam_res_usage_tbl
	, x_eam_wo_comp_tbl         => l_out_eam_wo_comp_tbl
        , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
        , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
        , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
        , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
        , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
        , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
	, x_eam_request_tbl         => l_out_eam_request_tbl
        , x_batch_id                => l_batch_id
        , x_header_id_tbl           => l_header_id_tbl
        , x_return_status           => l_return_status
        );


        l_eam_wo_tbl           := l_out_eam_wo_tbl;
        l_eam_wo_relations_tbl := l_out_eam_wo_relations_tbl;
        l_eam_op_tbl           := l_out_eam_op_tbl;
        l_eam_op_network_tbl   := l_out_eam_op_network_tbl;
        l_eam_res_tbl          := l_out_eam_res_tbl;
        l_eam_res_inst_tbl     := l_out_eam_res_inst_tbl;
        l_eam_sub_res_tbl      := l_out_eam_sub_res_tbl;
	l_eam_res_usage_tbl    := l_out_eam_res_usage_tbl;
        l_eam_mat_req_tbl      := l_out_eam_mat_req_tbl;
        l_eam_di_tbl           := l_out_eam_di_tbl;
	l_eam_wo_comp_tbl         := l_out_eam_wo_comp_tbl;
	l_eam_wo_quality_tbl      := l_out_eam_wo_quality_tbl;
	l_eam_meter_reading_tbl   := l_out_eam_meter_reading_tbl;
	l_eam_counter_prop_tbl	  := l_out_eam_counter_prop_tbl;
	l_eam_wo_comp_rebuild_tbl := l_out_eam_wo_comp_rebuild_tbl;
	l_eam_wo_comp_mr_read_tbl := l_out_eam_wo_comp_mr_read_tbl;
	l_eam_op_comp_tbl         := l_out_eam_op_comp_tbl;
	l_eam_request_tbl         := l_out_eam_request_tbl;

        l_out_eam_wo_tbl.delete;
        l_out_eam_wo_relations_tbl.delete;
        l_out_eam_op_tbl.delete;
        l_out_eam_op_network_tbl.delete;
        l_out_eam_res_tbl.delete;
        l_out_eam_res_inst_tbl.delete;
        l_out_eam_sub_res_tbl.delete;
	l_out_eam_res_usage_tbl.delete;
        l_out_eam_mat_req_tbl.delete;
        l_out_eam_di_tbl.delete;
	l_out_eam_wo_comp_tbl.delete;
	l_out_eam_wo_quality_tbl.delete;
	l_out_eam_meter_reading_tbl.delete;
	l_out_eam_counter_prop_tbl.delete;
	l_out_eam_wo_comp_rebuild_tbl.delete;
	l_out_eam_wo_comp_mr_read_tbl.delete;
	l_out_eam_op_comp_tbl.delete;
	l_out_eam_request_tbl.delete;


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO : CHECK_BO_NETWORK completed with status ='||l_return_status) ; END IF ;

        if nvl(l_return_status,FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS then

                l_out_mesg_token_tbl  := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                (  p_message_name  => 'EAM_WN_BO_NET_ERR'
                , p_token_tbl     => l_token_tbl
                , p_mesg_token_tbl     => l_mesg_token_tbl
                , x_mesg_token_tbl     => l_out_mesg_token_tbl
                );
                l_mesg_token_tbl      := l_out_mesg_token_tbl;

                l_out_eam_wo_rec            := l_eam_wo_rec;
                l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
                l_out_eam_di_tbl            := l_eam_di_tbl;

		l_out_eam_wo_comp_rec         := l_eam_wo_comp_rec;
		l_out_eam_wo_quality_tbl      := l_eam_wo_quality_tbl;
		l_out_eam_meter_reading_tbl   := l_eam_meter_reading_tbl;
		l_out_eam_counter_prop_tbl    := l_eam_counter_prop_tbl;
		l_out_eam_wo_comp_rebuild_tbl := l_eam_wo_comp_rebuild_tbl;
		l_out_eam_wo_comp_mr_read_tbl := l_eam_wo_comp_mr_read_tbl;
		l_out_eam_op_comp_tbl         := l_eam_op_comp_tbl;
		l_out_eam_request_tbl         := l_eam_request_tbl;

                EAM_ERROR_MESSAGE_PVT.Log_Error
                (  p_eam_wo_rec             => l_eam_wo_rec
                ,  p_eam_op_tbl             => l_eam_op_tbl
                ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
                ,  p_eam_res_tbl            => l_eam_res_tbl
                ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
                ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
                ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
                ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
                ,  p_eam_direct_items_tbl   => l_eam_di_tbl
                ,  p_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_BO_LEVEL
                ,  x_eam_wo_rec             => l_out_eam_wo_rec
                ,  x_eam_op_tbl             => l_out_eam_op_tbl
                ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
                ,  x_eam_res_tbl            => l_out_eam_res_tbl
                ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
                ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
                ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
                ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
                ,  x_eam_direct_items_tbl   => l_out_eam_di_tbl
                 );

                l_eam_wo_rec            := l_out_eam_wo_rec;
                l_eam_op_tbl            := l_out_eam_op_tbl;
                l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
                l_eam_res_tbl           := l_out_eam_res_tbl;
                l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
                l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
                l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
                l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
                l_eam_di_tbl            := l_out_eam_di_tbl;

		l_eam_wo_comp_rec         :=  l_out_eam_wo_comp_rec;
		l_eam_wo_quality_tbl      :=  l_out_eam_wo_quality_tbl;
		l_eam_meter_reading_tbl   :=  l_out_eam_meter_reading_tbl;
		l_eam_counter_prop_tbl    :=  l_out_eam_counter_prop_tbl;
		l_eam_wo_comp_rebuild_tbl :=  l_out_eam_wo_comp_rebuild_tbl;
		l_eam_wo_comp_mr_read_tbl :=  l_out_eam_wo_comp_mr_read_tbl;
		l_eam_op_comp_tbl         :=  l_out_eam_op_comp_tbl;
		l_eam_request_tbl         :=  l_out_eam_request_tbl;

                IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y'
                THEN
                   EAM_ERROR_MESSAGE_PVT.Dump_Message_List;
                   EAM_ERROR_MESSAGE_PVT.Close_Debug_Session;
                END IF;


                l_eam_return_status := FND_API.G_RET_STS_ERROR;
                x_return_status     := FND_API.G_RET_STS_ERROR;
                x_msg_count := EAM_ERROR_MESSAGE_PVT.Get_Message_Count;
                return;
        end if;


        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y'
        THEN
            EAM_ERROR_MESSAGE_PVT.Dump_Message_List;
            EAM_ERROR_MESSAGE_PVT.Close_Debug_Session;
        END IF;



        -- Start Processing each of the work orders

        if l_header_id_tbl.count > 0 then



          for i in l_header_id_tbl.first..l_header_id_tbl.last loop

            l_header_id := l_header_id_tbl(i).header_id;

            l_eam_wo_rec_head.transaction_type := null;
            if l_eam_wo_tbl.count > 0 then
            for j in l_eam_wo_tbl.first..l_eam_wo_tbl.last loop
              if l_eam_wo_tbl(j).header_id = l_header_id then
                l_eam_wo_rec_head := l_eam_wo_tbl(j);
              end if;
            end loop;

          end if;

          if l_eam_op_tbl.count > 0 then
            l_eam_op_tbl_head.delete;
            for j in l_eam_op_tbl.first..l_eam_op_tbl.last loop
              if l_eam_op_tbl(j).header_id = l_header_id then
                l_eam_op_tbl_head(l_eam_op_tbl_head.count+1) := l_eam_op_tbl(j);
              end if;
            end loop;
          end if;

          if l_eam_op_network_tbl.count > 0 then
            l_eam_op_network_tbl_head.delete;
            for j in l_eam_op_network_tbl.first..l_eam_op_network_tbl.last loop
              if l_eam_op_network_tbl(j).header_id = l_header_id then
                l_eam_op_network_tbl_head(l_eam_op_network_tbl_head.count+1) := l_eam_op_network_tbl(j);
              end if;
            end loop;
          end if;

          if l_eam_res_tbl.count > 0 then
            l_eam_res_tbl_head.delete;
            for j in l_eam_res_tbl.first..l_eam_res_tbl.last loop
              if l_eam_res_tbl(j).header_id = l_header_id then
                l_eam_res_tbl_head(l_eam_res_tbl_head.count+1) := l_eam_res_tbl(j);
              end if;
            end loop;
          end if;

          if l_eam_res_inst_tbl.count > 0 then
            l_eam_res_inst_tbl_head.delete;
            for j in l_eam_res_inst_tbl.first..l_eam_res_inst_tbl.last loop
              if l_eam_res_inst_tbl(j).header_id = l_header_id then
                l_eam_res_inst_tbl_head(l_eam_res_inst_tbl_head.count+1) := l_eam_res_inst_tbl(j);
              end if;
            end loop;
          end if;

          if l_eam_sub_res_tbl.count > 0 then
            l_eam_sub_res_tbl_head.delete;
            for j in l_eam_sub_res_tbl.first..l_eam_sub_res_tbl.last loop
              if l_eam_sub_res_tbl(j).header_id = l_header_id then
                l_eam_sub_res_tbl_head(l_eam_sub_res_tbl_head.count+1) := l_eam_sub_res_tbl(j);
              end if;
            end loop;
          end if;

          if l_eam_mat_req_tbl.count > 0 then
            l_eam_mat_req_tbl_head.delete;
            for j in l_eam_mat_req_tbl.first..l_eam_mat_req_tbl.last loop
              if l_eam_mat_req_tbl(j).header_id = l_header_id then
                l_eam_mat_req_tbl_head(l_eam_mat_req_tbl_head.count+1) := l_eam_mat_req_tbl(j);
              end if;
            end loop;
          end if;

          if l_eam_di_tbl.count > 0 then
            l_eam_di_tbl_head.delete;
            for j in l_eam_di_tbl.first..l_eam_di_tbl.last loop
              if l_eam_di_tbl(j).header_id = l_header_id then
                l_eam_di_tbl_head(l_eam_di_tbl_head.count+1) := l_eam_di_tbl(j);
              end if;
            end loop;
          end if;

	if l_eam_res_usage_tbl.count > 0 then
            l_eam_res_usage_tbl_head.delete;
            for j in l_eam_res_usage_tbl.first..l_eam_res_usage_tbl.last loop
              if l_eam_res_usage_tbl(j).header_id = l_header_id then
                l_eam_res_usage_tbl_head(l_eam_res_usage_tbl_head.count+1) := l_eam_res_usage_tbl(j);
              end if;
            end loop;
          end if;

	 l_eam_wo_comp_rec_head.transaction_type := null;
            if l_eam_wo_comp_tbl.count > 0 then
            for j in l_eam_wo_comp_tbl.first..l_eam_wo_comp_tbl.last loop
              if l_eam_wo_comp_tbl(j).header_id = l_header_id then
                l_eam_wo_comp_rec_head := l_eam_wo_comp_tbl(j);
              end if;
            end loop;

          end if;

/*	 if l_eam_wo_comp_tbl.count > 0 then
            l_eam_wo_comp_tbl_head.delete;
            for j in l_eam_wo_comp_tbl.first..l_eam_wo_comp_tbl.last loop
              if l_eam_wo_comp_tbl(j).header_id = l_header_id then
                l_eam_wo_comp_tbl_head(l_eam_wo_comp_tbl_head.count+1) := l_eam_wo_comp_tbl(j);
              end if;
            end loop;
          end if;
*/


	 if l_eam_wo_quality_tbl.count > 0 then
            l_eam_wo_quality_tbl_head.delete;
            for j in l_eam_wo_quality_tbl.first..l_eam_wo_quality_tbl.last loop
              if l_eam_wo_quality_tbl(j).header_id = l_header_id then
                l_eam_wo_quality_tbl_head(l_eam_wo_quality_tbl_head.count+1) := l_eam_wo_quality_tbl(j);
              end if;
            end loop;
          end if;

	  if l_eam_meter_reading_tbl.count > 0 then
            l_eam_meter_reading_tbl_head.delete;
            for j in l_eam_meter_reading_tbl.first..l_eam_meter_reading_tbl.last loop
              if l_eam_meter_reading_tbl(j).header_id = l_header_id then
                l_eam_meter_reading_tbl_head(l_eam_meter_reading_tbl_head.count+1) := l_eam_meter_reading_tbl(j);
              end if;
            end loop;
          end if;

	  if l_eam_counter_prop_tbl.count > 0 then
            l_eam_counter_prop_tbl_head.delete;
            for j in l_eam_counter_prop_tbl.first..l_eam_counter_prop_tbl.last loop
              if l_eam_counter_prop_tbl(j).header_id = l_header_id then
                l_eam_counter_prop_tbl_head(l_eam_counter_prop_tbl_head.count+1) := l_eam_counter_prop_tbl(j);
              end if;
            end loop;
          end if;

	  if l_eam_wo_comp_rebuild_tbl.count > 0 then
            l_eam_wo_comp_rebuild_tbl_head.delete;
            for j in l_eam_wo_comp_rebuild_tbl.first..l_eam_wo_comp_rebuild_tbl.last loop
              if l_eam_wo_comp_rebuild_tbl(j).header_id = l_header_id then
                l_eam_wo_comp_rebuild_tbl_head(l_eam_wo_comp_rebuild_tbl_head.count+1) := l_eam_wo_comp_rebuild_tbl(j);
              end if;
            end loop;
          end if;

	   if l_eam_wo_comp_mr_read_tbl.count > 0 then
            l_eam_wo_comp_mr_read_tbl_head.delete;
            for j in l_eam_wo_comp_mr_read_tbl.first..l_eam_wo_comp_mr_read_tbl.last loop
              if l_eam_wo_comp_mr_read_tbl(j).header_id = l_header_id then
                l_eam_wo_comp_mr_read_tbl_head(l_eam_wo_comp_mr_read_tbl_head.count+1) := l_eam_wo_comp_mr_read_tbl(j);
              end if;
            end loop;
          end if;

	   if l_eam_op_comp_tbl.count > 0 then
            l_eam_op_comp_tbl_head.delete;
            for j in l_eam_op_comp_tbl.first..l_eam_op_comp_tbl.last loop
              if l_eam_op_comp_tbl(j).header_id = l_header_id then
                l_eam_op_comp_tbl_head(l_eam_op_comp_tbl_head.count+1) := l_eam_op_comp_tbl(j);
              end if;
            end loop;
          end if;

	   if l_eam_request_tbl.count > 0 then
            l_eam_request_tbl_head.delete;

            for j in l_eam_request_tbl.first..l_eam_request_tbl.last loop
	    	if l_eam_request_tbl(j).header_id = l_header_id then
	      	    l_eam_request_tbl_head(l_eam_request_tbl_head.count+1) := l_eam_request_tbl(j);
		end if;
            end loop;
          end if;

          SAVEPOINT Single_WO_Process;


          -- Insert a dummy message into the message stack before each work order
          -- is processed. If the WO got processed without errors, then this dummy message
          -- is deleted. Else it stays there and serves as a seperator between
          -- the messages generated by different work orders.
          l_mesg_token_tbl.delete;
          l_token_tbl.delete;

          l_token_tbl(1).token_name  := 'Header Id';
          l_token_tbl(1).token_value :=  l_eam_wo_rec_head.header_id;

          l_out_mesg_token_tbl  := l_mesg_token_tbl;
          EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                (  p_message_name  => 'EAM_WN_GEN_WARNING'
                , p_token_tbl     => l_token_tbl
                , p_mesg_token_tbl     => l_mesg_token_tbl
                , x_mesg_token_tbl     => l_out_mesg_token_tbl
                );
          l_mesg_token_tbl      := l_out_mesg_token_tbl;


          EAM_ERROR_MESSAGE_PVT.Translate_And_Insert_Messages
          (  p_mesg_token_tbl     => l_mesg_token_tbl
           , p_error_level        => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
           , p_entity_index       => l_eam_wo_rec_head.row_id
           , p_application_id     => 'EAM'
           );



           PROCESS_WO
           (  p_bo_identifier           => 'EAM'
            , p_api_version_number      => 1.0
            , p_init_msg_list           => FALSE
            , p_commit                  => 'N'
            , p_eam_wo_rec              => l_eam_wo_rec_head
            , p_eam_op_tbl              => l_eam_op_tbl_head
            , p_eam_op_network_tbl      => l_eam_op_network_tbl_head
            , p_eam_res_tbl             => l_eam_res_tbl_head
            , p_eam_res_inst_tbl        => l_eam_res_inst_tbl_head
            , p_eam_sub_res_tbl         => l_eam_sub_res_tbl_head
            , p_eam_res_usage_tbl       => l_eam_res_usage_tbl_head
            , p_eam_mat_req_tbl         => l_eam_mat_req_tbl_head
            , p_eam_direct_items_tbl    => l_eam_di_tbl
  	    , p_eam_wo_comp_rec         => l_eam_wo_comp_rec_head
	    , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl_head
	    , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl_head
	    , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl_head
	    , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl_head
	    , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl_head
  	    , p_eam_op_comp_tbl         => l_eam_op_comp_tbl_head
	    , p_eam_request_tbl         => l_eam_request_tbl_head
            , x_eam_wo_rec              => l_out_eam_wo_rec
            , x_eam_op_tbl              => l_out_eam_op_tbl
            , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
            , x_eam_res_tbl             => l_out_eam_res_tbl
            , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
            , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
            , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
            , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
            , x_eam_direct_items_tbl    => l_out_eam_di_tbl
	    , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
	    , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
	    , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
	    , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
	    , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
	    , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
	    , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
	    , x_eam_request_tbl         => l_out_eam_request_tbl
            , x_return_status           => l_return_status
            , x_msg_count               => l_msg_count
            , p_debug                   => l_debug_flag
            , p_output_dir              => l_output_dir
            , p_debug_filename          => l_debug_filename
            , p_debug_file_mode         => 'a'
           );

	--added for bug 4563210
	if l_eam_wo_rec_head.transaction_type = EAM_PROCESS_WO_PUB.G_OPR_CREATE
                 and l_return_status = 'S' then
                         l_eam_wo_list(l_eam_wo_list.count + 1) := l_out_eam_wo_rec.wip_entity_name;
        end if;

--   IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Size of the list of newly created work orders:'||l_eam_wo_list.count) ; END IF ;

           if l_out_eam_wo_rec.transaction_type is not null then
             l_eam_wo_tbl(l_out_eam_wo_rec.row_id) := l_out_eam_wo_rec;
           end if;

           if l_out_eam_op_tbl.count <> 0 then
             for j in l_out_eam_op_tbl.first..l_out_eam_op_tbl.last loop
               if l_out_eam_op_tbl(j).row_id is null then
                 l_out_eam_op_tbl(j).row_id := l_eam_op_tbl.count+1;
               end if;
               l_eam_op_tbl(l_out_eam_op_tbl(j).row_id) := l_out_eam_op_tbl(j);
             end loop;
           end if;

         if l_out_eam_op_network_tbl.count <> 0 then
           for j in l_out_eam_op_network_tbl.first..l_out_eam_op_network_tbl.last loop
             if l_out_eam_op_network_tbl(j).row_id is null then
               l_out_eam_op_network_tbl(j).row_id := l_eam_op_network_tbl.count+1;
             end if;
             l_eam_op_network_tbl(l_out_eam_op_network_tbl(j).row_id) := l_out_eam_op_network_tbl(j);
           end loop;
         end if;

         if l_out_eam_res_tbl.count <> 0 then
           for j in l_out_eam_res_tbl.first..l_out_eam_res_tbl.last loop
             if l_out_eam_res_tbl(j).row_id is null then
               l_out_eam_res_tbl(j).row_id := l_eam_res_tbl.count+1;
             end if;
             l_eam_res_tbl(l_out_eam_res_tbl(j).row_id) := l_out_eam_res_tbl(j);
           end loop;
         end if;

         if l_out_eam_res_inst_tbl.count <> 0 then
           for j in l_out_eam_res_inst_tbl.first..l_out_eam_res_inst_tbl.last loop
             if l_out_eam_res_inst_tbl(j).row_id is null then
               l_out_eam_res_inst_tbl(j).row_id := l_eam_res_inst_tbl.count+1;
             end if;
             l_eam_res_inst_tbl(l_out_eam_res_inst_tbl(j).row_id) := l_out_eam_res_inst_tbl(j);
           end loop;
         end if;

         if l_out_eam_sub_res_tbl.count <> 0 then
           for j in l_out_eam_sub_res_tbl.first..l_out_eam_sub_res_tbl.last loop
             if l_out_eam_sub_res_tbl(j).row_id is null then
               l_out_eam_sub_res_tbl(j).row_id := l_eam_sub_res_tbl.count+1;
             end if;
             l_eam_sub_res_tbl(l_out_eam_sub_res_tbl(j).row_id) := l_out_eam_sub_res_tbl(j);
           end loop;
         end if;

         if l_out_eam_mat_req_tbl.count <> 0 then
           for j in l_out_eam_mat_req_tbl.first..l_out_eam_mat_req_tbl.last loop
             if l_out_eam_mat_req_tbl(j).row_id is null then
               l_out_eam_mat_req_tbl(j).row_id := l_eam_mat_req_tbl.count+1;
             end if;
             l_eam_mat_req_tbl(l_out_eam_mat_req_tbl(j).row_id) := l_out_eam_mat_req_tbl(j);
           end loop;
         end if;

         if l_out_eam_di_tbl.count <> 0 then
           for j in l_out_eam_di_tbl.first..l_out_eam_di_tbl.last loop
             if l_out_eam_di_tbl(j).row_id is null then
               l_out_eam_di_tbl(j).row_id := l_eam_di_tbl.count+1;
             end if;
             l_eam_di_tbl(l_out_eam_di_tbl(j).row_id) := l_out_eam_di_tbl(j);
           end loop;
         end if;

         if l_out_eam_res_usage_tbl.count <> 0 then
           for j in l_out_eam_res_usage_tbl.first..l_out_eam_res_usage_tbl.last loop
             if l_out_eam_res_usage_tbl(j).row_id is null then
               l_out_eam_res_usage_tbl(j).row_id := l_eam_res_usage_tbl.count+1;
             end if;
             l_eam_res_usage_tbl(l_out_eam_res_usage_tbl(j).row_id) := l_out_eam_res_usage_tbl(j);
           end loop;
         end if;


	 if l_out_eam_wo_comp_rec.transaction_type is not null then
             l_eam_wo_comp_tbl(l_out_eam_wo_comp_rec.row_id) := l_out_eam_wo_comp_rec;
         end if;

	  if l_out_eam_wo_quality_tbl.count <> 0 then
           for j in l_out_eam_wo_quality_tbl.first..l_out_eam_wo_quality_tbl.last loop
             if l_out_eam_wo_quality_tbl(j).row_id is null then
               l_out_eam_wo_quality_tbl(j).row_id := l_eam_wo_quality_tbl.count+1;
             end if;
             l_eam_wo_quality_tbl(l_out_eam_wo_quality_tbl(j).row_id) := l_out_eam_wo_quality_tbl(j);
           end loop;
         end if;

	if l_out_eam_meter_reading_tbl.count <> 0 then
           for j in l_out_eam_meter_reading_tbl.first..l_out_eam_meter_reading_tbl.last loop
             if l_out_eam_meter_reading_tbl(j).row_id is null then
               l_out_eam_meter_reading_tbl(j).row_id := l_eam_meter_reading_tbl.count+1;
             end if;
             l_eam_meter_reading_tbl(l_out_eam_meter_reading_tbl(j).row_id) := l_out_eam_meter_reading_tbl(j);
           end loop;
         end if;

	if l_out_eam_counter_prop_tbl.count <> 0 then
           for j in l_out_eam_counter_prop_tbl.first..l_out_eam_counter_prop_tbl.last loop
             if l_out_eam_counter_prop_tbl(j).row_id is null then
               l_out_eam_counter_prop_tbl(j).row_id := l_eam_counter_prop_tbl.count+1;
             end if;
             l_eam_counter_prop_tbl(l_out_eam_counter_prop_tbl(j).row_id) := l_out_eam_counter_prop_tbl(j);
           end loop;
         end if;


	if l_out_eam_wo_comp_rebuild_tbl.count <> 0 then
           for j in l_out_eam_wo_comp_rebuild_tbl.first..l_out_eam_wo_comp_rebuild_tbl.last loop
             if l_out_eam_wo_comp_rebuild_tbl(j).row_id is null then
               l_out_eam_wo_comp_rebuild_tbl(j).row_id := l_eam_wo_comp_rebuild_tbl.count+1;
             end if;
             l_eam_wo_comp_rebuild_tbl(l_out_eam_wo_comp_rebuild_tbl(j).row_id) := l_out_eam_wo_comp_rebuild_tbl(j);
           end loop;
         end if;

	if l_out_eam_wo_comp_mr_read_tbl.count <> 0 then
           for j in l_out_eam_wo_comp_mr_read_tbl.first..l_out_eam_wo_comp_mr_read_tbl.last loop
             if l_out_eam_wo_comp_mr_read_tbl(j).row_id is null then
               l_out_eam_wo_comp_mr_read_tbl(j).row_id := l_eam_wo_comp_mr_read_tbl.count+1;
             end if;
             l_eam_wo_comp_mr_read_tbl(l_out_eam_wo_comp_mr_read_tbl(j).row_id) := l_out_eam_wo_comp_mr_read_tbl(j);
           end loop;
         end if;

	if l_out_eam_op_comp_tbl.count <> 0 then
           for j in l_out_eam_op_comp_tbl.first..l_out_eam_op_comp_tbl.last loop
             if l_out_eam_op_comp_tbl(j).row_id is null then
               l_out_eam_op_comp_tbl(j).row_id := l_eam_op_comp_tbl.count+1;
             end if;
             l_eam_op_comp_tbl(l_out_eam_op_comp_tbl(j).row_id) := l_out_eam_op_comp_tbl(j);
           end loop;
         end if;

	if l_out_eam_request_tbl.count <> 0 then
           for j in l_out_eam_request_tbl.first..l_out_eam_request_tbl.last loop
             if l_out_eam_request_tbl(j).row_id is null then
               l_out_eam_request_tbl(j).row_id := l_eam_request_tbl.count+1;
             end if;
             l_eam_request_tbl(l_out_eam_request_tbl(j).row_id) := l_out_eam_request_tbl(j);
           end loop;
         end if;


         -- IF WO creation/updation failed, then rollback
         -- till start of this current WO process start
         IF nvl(l_return_status,'Q') <> 'S' THEN
           rollback to Single_WO_Process;

          l_eam_return_status := FND_API.G_RET_STS_ERROR;
          x_return_status     := FND_API.G_RET_STS_ERROR;

          -- Also disregard all relations pertaining to this work
          -- order as not valid;
          if l_eam_wo_relations_tbl.count <> 0 then
          for j in l_eam_wo_relations_tbl.first..l_eam_wo_relations_tbl.last loop

            if l_eam_wo_relations_tbl(j).parent_header_id     = l_header_id or
               l_eam_wo_relations_tbl(j).child_header_id      = l_header_id or
               l_eam_wo_relations_tbl(j).top_level_header_id  = l_header_id then
              l_eam_wo_relations_tbl(j).return_status := FND_API.G_RET_STS_ERROR;
            end if;

          end loop;
          end if;

         ELSE

         -- Delete the general warning message from both the fnd and eam message stacks
         fnd_msg_pub.delete_msg(p_msg_index => fnd_msg_pub.Count_Msg);

         EAM_ERROR_MESSAGE_PVT.Delete_Message;

   	     x_msg_count := EAM_ERROR_MESSAGE_PVT.GET_MESSAGE_COUNT();



          -- Populate the wip_entity_id for newly created work orders
          -- into the corresponding records in the relations PL/SQL table

          if l_eam_wo_relations_tbl.count > 0 then
          for j in l_eam_wo_relations_tbl.first..l_eam_wo_relations_tbl.last loop

            if l_eam_wo_relations_tbl(j).parent_header_id = l_header_id then
              l_eam_wo_relations_tbl(j).parent_object_id := l_out_eam_wo_rec.wip_entity_id;
            end if;

            if l_eam_wo_relations_tbl(j).child_header_id = l_header_id then
              l_eam_wo_relations_tbl(j).child_object_id := l_out_eam_wo_rec.wip_entity_id;
            end if;

            if l_eam_wo_relations_tbl(j).top_level_header_id = l_header_id then
              l_eam_wo_relations_tbl(j).top_level_object_id := l_out_eam_wo_rec.wip_entity_id;
            end if;

          end loop;
          end if;

         END IF;


        end loop;
        end if;








        -- Set the global variable for debug.
        EAM_PROCESS_WO_PVT.Set_Debug(l_debug_flag);

        IF l_debug_flag = 'Y'
        THEN

            IF trim(p_output_dir) IS NULL OR trim(p_output_dir) = ''
            THEN

            -- If debug is Y then out dir must be specified

                l_out_mesg_token_tbl := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_text       => 'Debug is set to Y so an output directory' || ' must be specified. Debug will be turned' || ' off since no directory is specified'
                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                , x_Mesg_Token_Tbl     => l_out_mesg_token_tbl
                , p_Token_Tbl          => l_token_tbl
                 );
                l_mesg_token_tbl := l_out_mesg_token_tbl;

                l_out_eam_wo_rec            := l_eam_wo_rec;
                l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
                l_out_eam_di_tbl            := l_eam_di_tbl;

                EAM_ERROR_MESSAGE_PVT.Log_Error
                (  p_eam_wo_rec             => l_eam_wo_rec
                ,  p_eam_op_tbl             => l_eam_op_tbl
                ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
                ,  p_eam_res_tbl            => l_eam_res_tbl
                ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
                ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
                ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
                ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
                ,  p_eam_direct_items_tbl   => l_eam_di_tbl
                ,  p_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_BO_LEVEL
                ,  x_eam_wo_rec             => l_out_eam_wo_rec
                ,  x_eam_op_tbl             => l_out_eam_op_tbl
                ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
                ,  x_eam_res_tbl            => l_out_eam_res_tbl
                ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
                ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
                ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
                ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
                ,  x_eam_direct_items_tbl   => l_out_eam_di_tbl
                 );

                l_eam_wo_rec            := l_out_eam_wo_rec;
                l_eam_op_tbl            := l_out_eam_op_tbl;
                l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
                l_eam_res_tbl           := l_out_eam_res_tbl;
                l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
                l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
                l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
                l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
                l_eam_di_tbl            := l_out_eam_di_tbl;

		l_eam_wo_comp_rec         :=  l_out_eam_wo_comp_rec;
		l_eam_wo_quality_tbl      :=  l_out_eam_wo_quality_tbl;
		l_eam_meter_reading_tbl   :=  l_out_eam_meter_reading_tbl;
		l_eam_counter_prop_tbl    :=  l_out_eam_counter_prop_tbl;
		l_eam_wo_comp_rebuild_tbl :=  l_out_eam_wo_comp_rebuild_tbl;
		l_eam_wo_comp_mr_read_tbl :=  l_out_eam_wo_comp_mr_read_tbl;
		l_eam_op_comp_tbl         :=  l_out_eam_op_comp_tbl;
		l_eam_request_tbl         :=  l_out_eam_request_tbl;

                l_debug_flag := 'N';

            END IF;

            IF trim(p_debug_filename) IS NULL OR trim(p_debug_filename) = ''
            THEN

                l_out_mesg_token_tbl := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_text       => 'Debug is set to Y so an output filename' || ' must be specified. Debug will be turned' || ' off since no filename is specified'
                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                , x_Mesg_Token_Tbl     => l_out_mesg_token_tbl
                , p_Token_Tbl          => l_token_tbl
                 );
                l_mesg_token_tbl := l_out_mesg_token_tbl;

                l_out_eam_wo_rec            := l_eam_wo_rec;
                l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
                l_out_eam_di_tbl            := l_eam_di_tbl;

		l_out_eam_wo_comp_rec         := l_eam_wo_comp_rec;
		l_out_eam_wo_quality_tbl      := l_eam_wo_quality_tbl;
		l_out_eam_meter_reading_tbl   := l_eam_meter_reading_tbl;
		l_out_eam_counter_prop_tbl    := l_eam_counter_prop_tbl;
		l_out_eam_wo_comp_rebuild_tbl := l_eam_wo_comp_rebuild_tbl;
		l_out_eam_wo_comp_mr_read_tbl := l_eam_wo_comp_mr_read_tbl;
		l_out_eam_op_comp_tbl         := l_eam_op_comp_tbl;
		l_out_eam_request_tbl         := l_eam_request_tbl;

                EAM_ERROR_MESSAGE_PVT.Log_Error
                (  p_eam_wo_rec             => l_eam_wo_rec
                ,  p_eam_op_tbl             => l_eam_op_tbl
                ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
                ,  p_eam_res_tbl            => l_eam_res_tbl
                ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
                ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
                ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
                ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
                ,  p_eam_direct_items_tbl   => l_eam_di_tbl
                ,  p_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_BO_LEVEL
                ,  x_eam_wo_rec             => l_out_eam_wo_rec
                ,  x_eam_op_tbl             => l_out_eam_op_tbl
                ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
                ,  x_eam_res_tbl            => l_out_eam_res_tbl
                ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
                ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
                ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
                ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
                ,  x_eam_direct_items_tbl   => l_out_eam_di_tbl
                 );

                l_eam_wo_rec            := l_out_eam_wo_rec;
                l_eam_op_tbl            := l_out_eam_op_tbl;
                l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
                l_eam_res_tbl           := l_out_eam_res_tbl;
                l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
                l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
                l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
                l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
                l_eam_di_tbl            := l_out_eam_di_tbl;

		l_eam_wo_comp_rec         :=  l_out_eam_wo_comp_rec;
		l_eam_wo_quality_tbl      :=  l_out_eam_wo_quality_tbl;
		l_eam_meter_reading_tbl   :=  l_out_eam_meter_reading_tbl;
		l_eam_counter_prop_tbl    :=  l_out_eam_counter_prop_tbl;
		l_eam_wo_comp_rebuild_tbl :=  l_out_eam_wo_comp_rebuild_tbl;
		l_eam_wo_comp_mr_read_tbl :=  l_out_eam_wo_comp_mr_read_tbl;
		l_eam_op_comp_tbl         :=  l_out_eam_op_comp_tbl;
		l_eam_request_tbl         :=  l_out_eam_request_tbl;

                l_debug_flag := 'N';

            END IF;

            EAM_PROCESS_WO_PVT.Set_Debug(l_debug_flag);

            IF l_debug_flag = 'Y'
            THEN
                l_out_mesg_token_tbl        := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Open_Debug_Session
                (  p_debug_filename     => p_debug_filename
                ,  p_output_dir         => p_output_dir
                ,  p_debug_file_mode    => 'a'
                ,  x_return_status      => l_return_status
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  x_mesg_token_tbl     => l_out_mesg_token_tbl
                 );
                l_mesg_token_tbl        := l_out_mesg_token_tbl;

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                    EAM_PROCESS_WO_PVT.Set_Debug('N');
                END IF;
            END IF;

        END IF;


        if p_eam_wo_tbl.count <> 0 then
          l_eam_wo_rec := p_eam_wo_tbl(p_eam_wo_tbl.first);
        end if;



        if l_eam_wo_relations_tbl.count > 0 then
        -- Start processing the relationships
        for i in 1..l_eam_wo_relations_tbl.count loop

          if nvl(l_eam_wo_relations_tbl(i).return_status,'Z') = 'Z'  OR
             l_eam_wo_relations_tbl(i).return_status = '' OR
             l_eam_wo_relations_tbl(i).return_status = ' '  then

          if l_eam_wo_relations_tbl(i).transaction_type =
            EAM_PROCESS_WO_PUB.G_OPR_CREATE then

             /* Added for bug#4563210 - Start */


	     l_temp_wip_entity_id := l_eam_wo_relations_tbl(i).PARENT_OBJECT_ID;

         IF ( EAM_PROCESS_WO_PVT.Get_Debug = 'Y') THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO : Entering the Check_Wo_Dates procedure ... ') ; END IF ;

	     FOR l_temp_index in 1..2 LOOP

	      if (l_eam_wo_relations_tbl(i).parent_relationship_type = 1) then


	          EAM_WO_NETWORK_DEFAULT_PVT.Check_Wo_Dates
	          (
	           p_api_version                   => 1.0,
	           p_init_msg_list                 => FND_API.G_FALSE,
	           p_commit                        => FND_API.G_FALSE,
	           p_validation_level              => FND_API.G_VALID_LEVEL_FULL,
	           p_wip_entity_id                 => l_temp_wip_entity_id,
	           x_return_status                 => l_return_status,
	           x_msg_count                     => l_msg_count,
	           x_msg_data                      => l_msg_data
	           );

            IF ( EAM_PROCESS_WO_PVT.Get_Debug = 'Y' AND l_temp_index = 1 ) THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO : Check_Wo_Dates for parent wo completed with status of '||l_return_status) ;
	   END IF ;
            IF ( EAM_PROCESS_WO_PVT.Get_Debug = 'Y' AND l_temp_index = 2 ) THEN
		EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO : Check_Wo_Dates for child wo completed with status of '||l_return_status) ;
	     END IF ;

        	IF l_return_status = FND_API.G_RET_STS_ERROR OR
		   l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

		   	--Before inserting the error message, insert the confirmation message of work order creation.
				x_return_status     := l_return_status;
				x_msg_count := EAM_ERROR_MESSAGE_PVT.Get_Message_Count;
				l_eam_return_status := FND_API.G_RET_STS_ERROR;

				if l_eam_wo_list.count > 0 then
					for l_new_wo_list in l_eam_wo_list.first..l_eam_wo_list.last loop
						eam_execution_jsp.add_message(p_app_short_name => 'EAM',
								p_msg_name => 'EAM_CREATE_WORKORDER_CONFIRM',
								p_token1 => 'WORKORDER', p_value1 => l_eam_wo_list(l_new_wo_list));
					end loop;
				end if;
				l_eam_wo_list.delete;
				--Insert the error message.
				select wip_entity_name into l_wo_name
				from wip_entities
				where wip_entity_id = l_temp_wip_entity_id;

				eam_execution_jsp.add_message(p_app_short_name => 'EAM',
					      	p_msg_name => 'EAM_WO_CHK_DATES_ERR',
						p_token1 => 'WORKORDER', p_value1 => l_wo_name);

				x_msg_count := EAM_ERROR_MESSAGE_PVT.Get_Message_Count;
				l_eam_return_status := FND_API.G_RET_STS_ERROR;
		end if;
             end if;
              l_temp_wip_entity_id := l_eam_wo_relations_tbl(i).CHILD_OBJECT_ID;
             END LOOP;
	    /* Added for bug#4563210 - End */

            if l_eam_wo_relations_tbl(i).parent_relationship_type in (1,3,4) then

             SAVEPOINT Add_WO_To_Network_Start;

         IF ( EAM_PROCESS_WO_PVT.Get_Debug = 'Y') THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO : Entering the Add_WO_To_Network procedure ... ') ; END IF ;

              EAM_WO_NETWORK_DEFAULT_PVT.Add_WO_To_Network(
                p_api_version                   => 1.0,
                p_init_msg_list                 => FND_API.G_FALSE,
                p_commit                        => FND_API.G_FALSE,
                p_validation_level              => FND_API.G_VALID_LEVEL_FULL,

                p_child_object_id               => l_eam_wo_relations_tbl(i).child_object_id,
                p_child_object_type_id          => l_eam_wo_relations_tbl(i).child_object_type_id,
                p_parent_object_id              => l_eam_wo_relations_tbl(i).parent_object_id,
                p_parent_object_type_id         => l_eam_wo_relations_tbl(i).parent_object_type_id,
                p_adjust_parent                 => l_eam_wo_relations_tbl(i).adjust_parent,
                p_relationship_type             => l_eam_wo_relations_tbl(i).parent_relationship_type,

                x_return_status                 => l_return_status,
                x_msg_count                     => l_msg_count,
                x_msg_data                      => l_msg_data,
                x_mesg_token_tbl                => l_mesg_token_tbl
               );

               l_eam_wo_relations_tbl(i).return_status := l_return_status;

               if l_return_status <> 'S' then

                 l_eam_return_status := FND_API.G_RET_STS_ERROR;
                 x_return_status     := FND_API.G_RET_STS_ERROR;

                 rollback to Add_Wo_To_Network_Start;

                l_out_eam_wo_rec            := l_eam_wo_rec;
                l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
                l_out_eam_di_tbl            := l_eam_di_tbl;

		l_out_eam_wo_comp_rec         := l_eam_wo_comp_rec;
		l_out_eam_wo_quality_tbl      := l_eam_wo_quality_tbl;
		l_out_eam_meter_reading_tbl   := l_eam_meter_reading_tbl;
		l_out_eam_counter_prop_tbl    := l_eam_counter_prop_tbl;
		l_out_eam_wo_comp_rebuild_tbl := l_eam_wo_comp_rebuild_tbl;
		l_out_eam_wo_comp_mr_read_tbl := l_eam_wo_comp_mr_read_tbl;
		l_out_eam_op_comp_tbl         := l_eam_op_comp_tbl;
		l_out_eam_request_tbl         := l_eam_request_tbl;

    EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl   => l_eam_di_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_out_eam_di_tbl
       );

                l_eam_wo_rec            := l_out_eam_wo_rec;
                l_eam_op_tbl            := l_out_eam_op_tbl;
                l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
                l_eam_res_tbl           := l_out_eam_res_tbl;
                l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
                l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
                l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
                l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
                l_eam_di_tbl            := l_out_eam_di_tbl;

		l_eam_wo_comp_rec         :=  l_out_eam_wo_comp_rec;
		l_eam_wo_quality_tbl      :=  l_out_eam_wo_quality_tbl;
		l_eam_meter_reading_tbl   :=  l_out_eam_meter_reading_tbl;
		l_eam_counter_prop_tbl    :=  l_out_eam_counter_prop_tbl;
		l_eam_wo_comp_rebuild_tbl :=  l_out_eam_wo_comp_rebuild_tbl;
		l_eam_wo_comp_mr_read_tbl :=  l_out_eam_wo_comp_mr_read_tbl;
		l_eam_op_comp_tbl         :=  l_out_eam_op_comp_tbl;
		l_eam_request_tbl         :=  l_out_eam_request_tbl;


               end if;


            elsif l_eam_wo_relations_tbl(i).parent_relationship_type = 2 then

              SAVEPOINT Add_Dependency_Start;
         IF ( EAM_PROCESS_WO_PVT.Get_Debug = 'Y') THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO : Entering the Add_Dependency procedure ... ') ; END IF ;

              EAM_WO_NETWORK_DEFAULT_PVT.Add_Dependency
              (
                p_api_version                   => 1.0,
                p_init_msg_list                 => FND_API.G_FALSE,
                p_commit                        => FND_API.G_FALSE,
                p_validation_level              => FND_API.G_VALID_LEVEL_FULL,

                p_prior_object_id               => l_eam_wo_relations_tbl(i).parent_object_id,
                p_prior_object_type_id          => l_eam_wo_relations_tbl(i).parent_object_type_id,
                p_next_object_id                => l_eam_wo_relations_tbl(i).child_object_id,
                p_next_object_type_id           => l_eam_wo_relations_tbl(i).child_object_type_id,

                x_return_status                 => l_return_status,
                x_msg_count                     => l_msg_count,
                x_msg_data                      => l_msg_data,
                x_mesg_token_tbl                => l_mesg_token_tbl
               );

               l_eam_wo_relations_tbl(i).return_status := l_return_status;

               if l_return_status <> 'S' then

                 l_eam_return_status := FND_API.G_RET_STS_ERROR;
                 x_return_status     := FND_API.G_RET_STS_ERROR;


                 rollback to Add_Dependency_Start;

                l_out_eam_wo_rec            := l_eam_wo_rec;
                l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
                l_out_eam_di_tbl            := l_eam_di_tbl;

		l_out_eam_wo_comp_rec         := l_eam_wo_comp_rec;
		l_out_eam_wo_quality_tbl      := l_eam_wo_quality_tbl;
		l_out_eam_meter_reading_tbl   := l_eam_meter_reading_tbl;
		l_out_eam_counter_prop_tbl    := l_eam_counter_prop_tbl;
		l_out_eam_wo_comp_rebuild_tbl := l_eam_wo_comp_rebuild_tbl;
		l_out_eam_wo_comp_mr_read_tbl := l_eam_wo_comp_mr_read_tbl;
		l_out_eam_op_comp_tbl         := l_eam_op_comp_tbl;
		l_out_eam_request_tbl         := l_eam_request_tbl;

    EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl   => l_eam_di_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_out_eam_di_tbl
       );

                l_eam_wo_rec            := l_out_eam_wo_rec;
                l_eam_op_tbl            := l_out_eam_op_tbl;
                l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
                l_eam_res_tbl           := l_out_eam_res_tbl;
                l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
                l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
                l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
                l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
                l_eam_di_tbl            := l_out_eam_di_tbl;

		l_eam_wo_comp_rec         :=  l_out_eam_wo_comp_rec;
		l_eam_wo_quality_tbl      :=  l_out_eam_wo_quality_tbl;
		l_eam_meter_reading_tbl   :=  l_out_eam_meter_reading_tbl;
		l_eam_counter_prop_tbl    :=  l_out_eam_counter_prop_tbl;
		l_eam_wo_comp_rebuild_tbl :=  l_out_eam_wo_comp_rebuild_tbl;
		l_eam_wo_comp_mr_read_tbl :=  l_out_eam_wo_comp_mr_read_tbl;
		l_eam_op_comp_tbl         :=  l_out_eam_op_comp_tbl;
		l_eam_request_tbl         :=  l_out_eam_request_tbl;

               end if;

            end if;

          elsif l_eam_wo_relations_tbl(i).transaction_type =
            EAM_PROCESS_WO_PUB.G_OPR_DELETE then

            if l_eam_wo_relations_tbl(i).parent_relationship_type in (1,3,4) then

              SAVEPOINT Delink_Relation_Start;

         IF ( EAM_PROCESS_WO_PVT.Get_Debug = 'Y') THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO : Entering the Delink_Child_From_parent procedure ... ') ; END IF ;

              EAM_WO_NETWORK_DEFAULT_PVT.Delink_Child_From_Parent
              (
                p_api_version                   => 1.0,
                p_init_msg_list                 => FND_API.G_FALSE,
                p_commit                        => FND_API.G_FALSE,
                p_validation_level              => FND_API.G_VALID_LEVEL_FULL,

                p_child_object_id               => l_eam_wo_relations_tbl(i).child_object_id,
                p_child_object_type_id          => l_eam_wo_relations_tbl(i).child_object_type_id,
                p_parent_object_id              => l_eam_wo_relations_tbl(i).parent_object_id,
                p_parent_object_type_id         => l_eam_wo_relations_tbl(i).parent_object_type_id,
                p_relationship_type             => l_eam_wo_relations_tbl(i).parent_relationship_type,

                x_return_status                 => l_return_status,
                x_msg_count                     => l_msg_count,
                x_msg_data                      => l_msg_data ,
                x_mesg_token_tbl                => l_mesg_token_tbl
              );

               l_eam_wo_relations_tbl(i).return_status := l_return_status;



               if l_return_status <> 'S' then

                 l_eam_return_status := FND_API.G_RET_STS_ERROR;
                 x_return_status     := FND_API.G_RET_STS_ERROR;


                 rollback to Delink_Relation_Start;

                l_out_eam_wo_rec            := l_eam_wo_rec;
                l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
                l_out_eam_di_tbl            := l_eam_di_tbl;

		l_out_eam_wo_comp_rec         := l_eam_wo_comp_rec;
		l_out_eam_wo_quality_tbl      := l_eam_wo_quality_tbl;
		l_out_eam_meter_reading_tbl   := l_eam_meter_reading_tbl;
		l_out_eam_counter_prop_tbl    := l_eam_counter_prop_tbl;
		l_out_eam_wo_comp_rebuild_tbl := l_eam_wo_comp_rebuild_tbl;
		l_out_eam_wo_comp_mr_read_tbl := l_eam_wo_comp_mr_read_tbl;
		l_out_eam_op_comp_tbl         := l_eam_op_comp_tbl;
		l_out_eam_request_tbl         := l_eam_request_tbl;

    EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl   => l_eam_di_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_out_eam_di_tbl
       );

                l_eam_wo_rec            := l_out_eam_wo_rec;
                l_eam_op_tbl            := l_out_eam_op_tbl;
                l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
                l_eam_res_tbl           := l_out_eam_res_tbl;
                l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
                l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
                l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
                l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
                l_eam_di_tbl            := l_out_eam_di_tbl;

		l_eam_wo_comp_rec         :=  l_out_eam_wo_comp_rec;
		l_eam_wo_quality_tbl      :=  l_out_eam_wo_quality_tbl;
		l_eam_meter_reading_tbl   :=  l_out_eam_meter_reading_tbl;
		l_eam_counter_prop_tbl    :=  l_out_eam_counter_prop_tbl;
		l_eam_wo_comp_rebuild_tbl :=  l_out_eam_wo_comp_rebuild_tbl;
		l_eam_wo_comp_mr_read_tbl :=  l_out_eam_wo_comp_mr_read_tbl;
		l_eam_op_comp_tbl         :=  l_out_eam_op_comp_tbl;
		l_eam_request_tbl         :=  l_out_eam_request_tbl;

               end if;


            elsif l_eam_wo_relations_tbl(i).parent_relationship_type = 2 then

              SAVEPOINT Delete_Dependency_Start;
         IF ( EAM_PROCESS_WO_PVT.Get_Debug = 'Y') THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO : Entering the Delete_Dependency procedure ... ') ; END IF ;

              EAM_WO_NETWORK_DEFAULT_PVT.Delete_Dependency
              (
                p_api_version                   => 1.0,
                p_init_msg_list                 => FND_API.G_FALSE,
                p_commit                        => FND_API.G_FALSE,
                p_validation_level              => FND_API.G_VALID_LEVEL_FULL,

                p_prior_object_id               => l_eam_wo_relations_tbl(i).parent_object_id,
                p_prior_object_type_id          => l_eam_wo_relations_tbl(i).parent_object_type_id,
                p_next_object_id                => l_eam_wo_relations_tbl(i).child_object_id,
                p_next_object_type_id           => l_eam_wo_relations_tbl(i).child_object_type_id,

                x_return_status                 => l_return_status,
                x_msg_count                     => l_msg_count,
                x_msg_data                      => l_msg_data,
                x_mesg_token_tbl                => l_mesg_token_tbl
              );

               l_eam_wo_relations_tbl(i).return_status := l_return_status;



               if l_return_status <> 'S' then

                 l_eam_return_status := FND_API.G_RET_STS_ERROR;
                 x_return_status     := FND_API.G_RET_STS_ERROR;


                 rollback to Delete_Dependency_Start;


                l_out_eam_wo_rec            := l_eam_wo_rec;
                l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
                l_out_eam_di_tbl            := l_eam_di_tbl;

		l_out_eam_wo_comp_rec         := l_eam_wo_comp_rec;
		l_out_eam_wo_quality_tbl      := l_eam_wo_quality_tbl;
		l_out_eam_meter_reading_tbl   := l_eam_meter_reading_tbl;
		l_out_eam_counter_prop_tbl    := l_eam_counter_prop_tbl;
		l_out_eam_wo_comp_rebuild_tbl := l_eam_wo_comp_rebuild_tbl;
		l_out_eam_wo_comp_mr_read_tbl := l_eam_wo_comp_mr_read_tbl;
		l_out_eam_op_comp_tbl         := l_eam_op_comp_tbl;
		l_out_eam_request_tbl         := l_eam_request_tbl;

    EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl   => l_eam_di_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_out_eam_di_tbl
       );

                l_eam_wo_rec            := l_out_eam_wo_rec;
                l_eam_op_tbl            := l_out_eam_op_tbl;
                l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
                l_eam_res_tbl           := l_out_eam_res_tbl;
                l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
                l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
                l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
                l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
                l_eam_di_tbl            := l_out_eam_di_tbl;

		l_eam_wo_comp_rec         :=  l_out_eam_wo_comp_rec;
		l_eam_wo_quality_tbl      :=  l_out_eam_wo_quality_tbl;
		l_eam_meter_reading_tbl   :=  l_out_eam_meter_reading_tbl;
		l_eam_counter_prop_tbl    :=  l_out_eam_counter_prop_tbl;
		l_eam_wo_comp_rebuild_tbl :=  l_out_eam_wo_comp_rebuild_tbl;
		l_eam_wo_comp_mr_read_tbl :=  l_out_eam_wo_comp_mr_read_tbl;
		l_eam_op_comp_tbl         :=  l_out_eam_op_comp_tbl;
		l_eam_request_tbl         :=  l_out_eam_request_tbl;

               end if;


            end if;

          end if;

          end if;

        end loop;
        end if;


        -- If there were any work orders processed, then
        -- Call Validate Structure. If it returns error, then rollback everything

        IF l_eam_wo_tbl.count <> 0  and l_eam_wo_tbl(l_eam_wo_tbl.first).validate_structure = 'Y' then -- added for bug# 3544860

         IF ( EAM_PROCESS_WO_PVT.Get_Debug = 'Y') THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO : Entering the Validate_Structure procedure ... ') ; END IF ;

    EAM_WO_NETWORK_VALIDATE_PVT.Validate_Structure
        (
        p_api_version                   => 1.0,
        p_init_msg_list                 => FND_API.G_FALSE,
        p_commit                        => FND_API.G_FALSE,
        p_validation_level              => FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                => l_eam_wo_tbl(l_eam_wo_tbl.first).wip_entity_id,
        p_work_object_type_id           => 1,
        p_exception_logging             => 'Y',

    	p_validate_status	        => 'N',
	p_output_errors			=> 'N',

        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data,
	x_wo_relationship_exc_tbl	=> l_wo_relationship_exc_tbl
        );


    IF l_return_status = FND_API.G_RET_STS_ERROR OR
       l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

	x_return_status     := l_return_status; -- added for bug# 3544860

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_MAIN_VALIDATE_STRUCT'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

                l_out_eam_wo_rec            := l_eam_wo_rec;
                l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
                l_out_eam_di_tbl            := l_eam_di_tbl;

		l_out_eam_wo_comp_rec         := l_eam_wo_comp_rec;
		l_out_eam_wo_quality_tbl      := l_eam_wo_quality_tbl;
		l_out_eam_meter_reading_tbl   := l_eam_meter_reading_tbl;
		l_out_eam_counter_prop_tbl    := l_eam_counter_prop_tbl;
		l_out_eam_wo_comp_rebuild_tbl := l_eam_wo_comp_rebuild_tbl;
		l_out_eam_wo_comp_mr_read_tbl := l_eam_wo_comp_mr_read_tbl;
		l_out_eam_op_comp_tbl         := l_eam_op_comp_tbl;
		l_out_eam_request_tbl         := l_eam_request_tbl;


    EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl   => l_eam_di_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_out_eam_di_tbl
       );

                l_eam_wo_rec            := l_out_eam_wo_rec;
                l_eam_op_tbl            := l_out_eam_op_tbl;
                l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
                l_eam_res_tbl           := l_out_eam_res_tbl;
                l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
                l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
                l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
                l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
                l_eam_di_tbl            := l_out_eam_di_tbl;

		l_eam_wo_comp_rec         :=  l_out_eam_wo_comp_rec;
		l_eam_wo_quality_tbl      :=  l_out_eam_wo_quality_tbl;
		l_eam_meter_reading_tbl   :=  l_out_eam_meter_reading_tbl;
		l_eam_counter_prop_tbl    :=  l_out_eam_counter_prop_tbl;
		l_eam_wo_comp_rebuild_tbl :=  l_out_eam_wo_comp_rebuild_tbl;
		l_eam_wo_comp_mr_read_tbl :=  l_out_eam_wo_comp_mr_read_tbl;
		l_eam_op_comp_tbl         :=  l_out_eam_op_comp_tbl;
		l_eam_request_tbl         :=  l_out_eam_request_tbl;

      ROLLBACK TO EAM_PR_MASTER_CHILD_WO;

    END IF;

        END IF;
	-- end of fix for bug# 3544860

        x_eam_wo_tbl.delete;
        x_eam_wo_relations_tbl.delete;
        x_eam_op_tbl.delete;
        x_eam_op_network_tbl.delete;
        x_eam_res_tbl.delete;
        x_eam_res_inst_tbl.delete;
        x_eam_sub_res_tbl.delete;
        x_eam_mat_req_tbl.delete;
        x_eam_direct_items_tbl.delete;
	x_eam_res_usage_tbl.delete;

	 x_eam_res_usage_tbl.delete;
	 x_eam_wo_comp_tbl.delete;
	 x_eam_wo_quality_tbl.delete;
	 x_eam_meter_reading_tbl.delete;
	 x_eam_counter_prop_tbl.delete;
	 x_eam_wo_comp_rebuild_tbl.delete;
	 x_eam_wo_comp_mr_read_tbl.delete;
	 x_eam_op_comp_tbl.delete;
	 x_eam_request_tbl.delete;

	x_eam_wo_tbl              := l_eam_wo_tbl;
        x_eam_wo_relations_tbl    := l_eam_wo_relations_tbl;
        x_eam_op_tbl              := l_eam_op_tbl;
        x_eam_op_network_tbl      := l_eam_op_network_tbl;
        x_eam_res_tbl             := l_eam_res_tbl;
        x_eam_res_inst_tbl        := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl         := l_eam_sub_res_tbl;
        x_eam_mat_req_tbl         := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl    := l_eam_di_tbl;

	 x_eam_res_usage_tbl		:= l_eam_res_usage_tbl;
	 x_eam_wo_comp_tbl		:= l_eam_wo_comp_tbl;
	 x_eam_wo_quality_tbl		:= l_eam_wo_quality_tbl;
	 x_eam_meter_reading_tbl	:= l_eam_meter_reading_tbl;
	 x_eam_counter_prop_tbl		:= l_eam_counter_prop_tbl;
	 x_eam_wo_comp_rebuild_tbl	:= l_eam_wo_comp_rebuild_tbl;
	 x_eam_wo_comp_mr_read_tbl	:= l_eam_wo_comp_mr_read_tbl;
	 x_eam_op_comp_tbl		:= l_eam_op_comp_tbl;
	 x_eam_request_tbl		:= l_eam_request_tbl;

        if nvl(l_eam_return_status,FND_API.G_RET_STS_ERROR) <> FND_API.G_RET_STS_SUCCESS then
          x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

        x_msg_count := EAM_ERROR_MESSAGE_PVT.Get_Message_Count;

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y'
        THEN
            EAM_ERROR_MESSAGE_PVT.Dump_Message_List;
            EAM_ERROR_MESSAGE_PVT.Close_Debug_Session;
        END IF;

        -- Standard check of p_commit.
        IF p_commit = 'Y' THEN
                COMMIT WORK;
        END IF;

        EXCEPTION

          WHEN OTHERS THEN

        x_msg_count := EAM_ERROR_MESSAGE_PVT.Get_Message_Count;

      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
        (  p_message_name  => 'EAM_WN_UNKNOWN_ERROR'
         , p_token_tbl     => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl := l_out_mesg_token_tbl;

                l_out_eam_wo_rec            := l_eam_wo_rec;
                l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
                l_out_eam_di_tbl            := l_eam_di_tbl;

		l_out_eam_wo_comp_rec         := l_eam_wo_comp_rec;
		l_out_eam_wo_quality_tbl      := l_eam_wo_quality_tbl;
		l_out_eam_meter_reading_tbl   := l_eam_meter_reading_tbl;
		l_out_eam_counter_prop_tbl    := l_eam_counter_prop_tbl;
		l_out_eam_wo_comp_rebuild_tbl := l_eam_wo_comp_rebuild_tbl;
		l_out_eam_wo_comp_mr_read_tbl := l_eam_wo_comp_mr_read_tbl;
		l_out_eam_op_comp_tbl         := l_eam_op_comp_tbl;
		l_out_eam_request_tbl         := l_eam_request_tbl;


               EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl   => l_eam_di_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => FND_API.G_RET_STS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_RECORD
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_other_token_tbl
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_out_eam_di_tbl
       );

                l_eam_wo_rec            := l_out_eam_wo_rec;
                l_eam_op_tbl            := l_out_eam_op_tbl;
                l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
                l_eam_res_tbl           := l_out_eam_res_tbl;
                l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
                l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
                l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
                l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
                l_eam_di_tbl            := l_out_eam_di_tbl;

		l_eam_wo_comp_rec         :=  l_out_eam_wo_comp_rec;
		l_eam_wo_quality_tbl      :=  l_out_eam_wo_quality_tbl;
		l_eam_meter_reading_tbl   :=  l_out_eam_meter_reading_tbl;
		l_eam_counter_prop_tbl    :=  l_out_eam_counter_prop_tbl;
		l_eam_wo_comp_rebuild_tbl :=  l_out_eam_wo_comp_rebuild_tbl;
		l_eam_wo_comp_mr_read_tbl :=  l_out_eam_wo_comp_mr_read_tbl;
		l_eam_op_comp_tbl         :=  l_out_eam_op_comp_tbl;
		l_eam_request_tbl         :=  l_out_eam_request_tbl;

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y'
        THEN
            EAM_ERROR_MESSAGE_PVT.Dump_Message_List;
            EAM_ERROR_MESSAGE_PVT.Close_Debug_Session;
        END IF;


     END PROCESS_MASTER_CHILD_WO;










        -- This procedure loops through all the input records and finds
        -- out the list of headers that the user has passed

        PROCEDURE CHECK_BO_NETWORK
        ( p_eam_wo_tbl              IN  EAM_PROCESS_WO_PUB.eam_wo_tbl_type
        , p_eam_wo_relations_tbl    IN  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type
        , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
        , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
        , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
        , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
        , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
        , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
        , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
	, p_eam_wo_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type
        , p_eam_wo_quality_tbl      IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
        , p_eam_meter_reading_tbl   IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
        , p_eam_counter_prop_tbl    IN  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
        , p_eam_wo_comp_rebuild_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
        , p_eam_wo_comp_mr_read_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
        , p_eam_op_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	, p_eam_request_tbl         IN  EAM_PROCESS_WO_PUB.eam_request_tbl_type
        , x_eam_wo_tbl              OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_tbl_type
        , x_eam_wo_relations_tbl    OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type
        , x_eam_op_tbl              OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_op_tbl_type
        , x_eam_op_network_tbl      OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
        , x_eam_res_tbl             OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_res_tbl_type
        , x_eam_res_inst_tbl        OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        , x_eam_sub_res_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
        , x_eam_mat_req_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
        , x_eam_direct_items_tbl    OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
        , x_eam_res_usage_tbl       OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
	, x_eam_wo_comp_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type
        , x_eam_wo_quality_tbl      OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
        , x_eam_meter_reading_tbl   OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
        , x_eam_counter_prop_tbl    OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
        , x_eam_wo_comp_rebuild_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
        , x_eam_wo_comp_mr_read_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
        , x_eam_op_comp_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	, x_eam_request_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_request_tbl_type
        , x_batch_id                OUT NOCOPY NUMBER
        , x_header_id_tbl           OUT NOCOPY EAM_PROCESS_WO_PUB.header_id_tbl_type
        , x_return_status           OUT NOCOPY VARCHAR2
        ) IS
          l_batch_id                NUMBER;
          l_header_id_tbl           EAM_PROCESS_WO_PUB.header_id_tbl_type;
          l_count                   NUMBER;
          l_header_id               NUMBER;
          l_found                   VARCHAR2(1) := FND_API.G_FALSE;
          l_return_status           VARCHAR2(1);

          l_eam_wo_tbl              EAM_PROCESS_WO_PUB.eam_wo_tbl_type
                                    := p_eam_wo_tbl;
          l_eam_wo_relations_tbl    EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type
                                    := p_eam_wo_relations_tbl;
          l_eam_op_tbl              EAM_PROCESS_WO_PUB.eam_op_tbl_type
                                    := p_eam_op_tbl;
          l_eam_op_network_tbl      EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
                                    := p_eam_op_network_tbl;
          l_eam_res_tbl             EAM_PROCESS_WO_PUB.eam_res_tbl_type
                                    := p_eam_res_tbl;
          l_eam_res_inst_tbl        EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
                                    := p_eam_res_inst_tbl;
          l_eam_sub_res_tbl         EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
                                    := p_eam_sub_res_tbl;
          l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
                                   := p_eam_res_usage_tbl;
          l_eam_mat_req_tbl         EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
                                    := p_eam_mat_req_tbl;
          l_eam_direct_items_tbl    EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
                                    := p_eam_direct_items_tbl;

	l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type
					:= p_eam_wo_comp_tbl;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
					:= p_eam_wo_quality_tbl;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
					:= p_eam_meter_reading_tbl;
	l_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
					:= p_eam_counter_prop_tbl;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
					:= p_eam_wo_comp_rebuild_tbl;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
					:= p_eam_wo_comp_mr_read_tbl;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
					:= p_eam_op_comp_tbl;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type
					:= p_eam_request_tbl;

        BEGIN

          l_return_status := FND_API.G_RET_STS_SUCCESS;

          l_batch_id := null;

          if l_eam_wo_tbl.count > 0 then
          FOR i in l_eam_wo_tbl.first..l_eam_wo_tbl.last LOOP
            IF l_eam_wo_tbl(i).batch_id is null or l_eam_wo_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_wo_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_wo_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_wo_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_wo_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;


          if l_eam_op_tbl.count > 0 then
          FOR i in l_eam_op_tbl.first..l_eam_op_tbl.last LOOP
            IF l_eam_op_tbl(i).batch_id is null or l_eam_op_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_op_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_op_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_op_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_op_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;


          if l_eam_op_network_tbl.count > 0 then
          FOR i in l_eam_op_network_tbl.first..l_eam_op_network_tbl.last LOOP
            IF l_eam_op_network_tbl(i).batch_id is null or l_eam_op_network_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_op_network_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_op_network_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_op_network_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_op_network_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;

          if l_eam_res_tbl.count > 0 then
          FOR i in l_eam_res_tbl.first..l_eam_res_tbl.last LOOP
            IF l_eam_res_tbl(i).batch_id is null or l_eam_res_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_res_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_res_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_res_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_res_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;

	  if l_eam_res_inst_tbl.count > 0 then
          FOR i in l_eam_res_inst_tbl.first..l_eam_res_inst_tbl.last LOOP
            IF l_eam_res_inst_tbl(i).batch_id is null or l_eam_res_inst_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_res_inst_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_res_inst_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_res_inst_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_res_inst_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;

          if l_eam_sub_res_tbl.count > 0 then
          FOR i in l_eam_sub_res_tbl.first..l_eam_sub_res_tbl.last LOOP
            IF l_eam_sub_res_tbl(i).batch_id is null or l_eam_sub_res_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_sub_res_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_sub_res_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_sub_res_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_sub_res_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;

	 if l_eam_res_usage_tbl.count > 0 then
          FOR i in l_eam_res_usage_tbl.first..l_eam_res_usage_tbl.last LOOP
            IF l_eam_res_usage_tbl(i).batch_id is null or l_eam_res_usage_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_res_usage_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_res_usage_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_res_usage_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_res_usage_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;

          if l_eam_mat_req_tbl.count > 0 then
          FOR i in l_eam_mat_req_tbl.first..l_eam_mat_req_tbl.last LOOP
            IF l_eam_mat_req_tbl(i).batch_id is null or l_eam_mat_req_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_mat_req_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_mat_req_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_mat_req_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_mat_req_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;

          if l_eam_direct_items_tbl.count > 0 then
          FOR i in l_eam_direct_items_tbl.first..l_eam_direct_items_tbl.last LOOP
            IF l_eam_direct_items_tbl(i).batch_id is null or l_eam_direct_items_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_direct_items_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_direct_items_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_direct_items_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_direct_items_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;

	if l_eam_wo_comp_tbl.count > 0 then

          FOR i in l_eam_wo_comp_tbl.first..l_eam_wo_comp_tbl.last LOOP
            IF l_eam_wo_comp_tbl(i).batch_id is null or l_eam_wo_comp_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_wo_comp_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_wo_comp_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_wo_comp_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_wo_comp_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;

	if l_eam_wo_quality_tbl.count > 0 then
          FOR i in l_eam_wo_quality_tbl.first..l_eam_wo_quality_tbl.last LOOP
            IF l_eam_wo_quality_tbl(i).batch_id is null or l_eam_wo_quality_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_wo_quality_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_wo_quality_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_wo_quality_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_wo_quality_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;

	  if l_eam_meter_reading_tbl.count > 0 then
          FOR i in l_eam_meter_reading_tbl.first..l_eam_meter_reading_tbl.last LOOP
            IF l_eam_meter_reading_tbl(i).batch_id is null or l_eam_meter_reading_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_meter_reading_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_meter_reading_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_meter_reading_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_meter_reading_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;

	 if l_eam_counter_prop_tbl.count > 0 then
          FOR i in l_eam_counter_prop_tbl.first..l_eam_counter_prop_tbl.last LOOP
            IF l_eam_counter_prop_tbl(i).batch_id is null or l_eam_counter_prop_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_counter_prop_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_counter_prop_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_counter_prop_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_counter_prop_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;

	   if l_eam_wo_comp_rebuild_tbl.count > 0 then
          FOR i in l_eam_wo_comp_rebuild_tbl.first..l_eam_wo_comp_rebuild_tbl.last LOOP
            IF l_eam_wo_comp_rebuild_tbl(i).batch_id is null or l_eam_wo_comp_rebuild_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_wo_comp_rebuild_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_wo_comp_rebuild_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_wo_comp_rebuild_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_wo_comp_rebuild_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;

	    if l_eam_wo_comp_mr_read_tbl.count > 0 then
          FOR i in l_eam_wo_comp_mr_read_tbl.first..l_eam_wo_comp_mr_read_tbl.last LOOP
            IF l_eam_wo_comp_mr_read_tbl(i).batch_id is null or l_eam_wo_comp_mr_read_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_wo_comp_mr_read_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_wo_comp_mr_read_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_wo_comp_mr_read_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_wo_comp_mr_read_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;

	    if l_eam_op_comp_tbl.count > 0 then
          FOR i in l_eam_op_comp_tbl.first..l_eam_op_comp_tbl.last LOOP
            IF l_eam_op_comp_tbl(i).batch_id is null or l_eam_op_comp_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_op_comp_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_op_comp_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_op_comp_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_op_comp_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;

	     if l_eam_request_tbl.count > 0 then
          FOR i in l_eam_request_tbl.first..l_eam_request_tbl.last LOOP
            IF l_eam_request_tbl(i).batch_id is null or l_eam_request_tbl(i).header_id is null then
              l_return_status := FND_API.G_RET_STS_ERROR;
              return;
            END IF;
            l_eam_request_tbl(i).row_id := i;
            IF l_batch_id = null THEN
              l_batch_id := l_eam_request_tbl(i).batch_id;
            ELSIF l_batch_id <> l_eam_request_tbl(i).batch_id THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            l_header_id := l_eam_request_tbl(i).header_id;
            l_found := FND_API.G_FALSE;
            if l_header_id_tbl.count > 0 then
            for j in l_header_id_tbl.first..l_header_id_tbl.last loop
              if l_header_id = l_header_id_tbl(j).header_id then
                l_found := FND_API.G_TRUE;
              end if;
            end loop;
            end if;
            if l_found = FND_API.G_FALSE then
              l_header_id_tbl(l_header_id_tbl.count+1).header_id := l_header_id;
            end if;
          END LOOP;
          end if;


         -- If return status is not success, then set all records as unprocessed
         if l_return_status <> FND_API.G_RET_STS_SUCCESS then

           for i in l_eam_wo_tbl.first..l_eam_wo_tbl.last loop
             if l_eam_wo_tbl(i).transaction_type is not null then
               l_eam_wo_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_wo_relations_tbl.first..l_eam_wo_relations_tbl.last loop
             if l_eam_wo_relations_tbl(i).transaction_type is not null then
               l_eam_wo_relations_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_op_tbl.first..l_eam_op_tbl.last loop
             if l_eam_op_tbl(i).transaction_type is not null then
               l_eam_op_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_op_network_tbl.first..l_eam_op_tbl.last loop
             if l_eam_op_network_tbl(i).transaction_type is not null then
               l_eam_op_network_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_res_tbl.first..l_eam_res_tbl.last loop
             if l_eam_res_tbl(i).transaction_type is not null then
               l_eam_res_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_res_inst_tbl.first..l_eam_res_inst_tbl.last loop
             if l_eam_res_inst_tbl(i).transaction_type is not null then
               l_eam_res_inst_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_sub_res_tbl.first..l_eam_sub_res_tbl.last loop
             if l_eam_sub_res_tbl(i).transaction_type is not null then
               l_eam_sub_res_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;


           for i in l_eam_res_usage_tbl.first..l_eam_res_usage_tbl.last loop
             if l_eam_res_usage_tbl(i).transaction_type is not null then
               l_eam_res_usage_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_mat_req_tbl.first..l_eam_mat_req_tbl.last loop
             if l_eam_mat_req_tbl(i).transaction_type is not null then
               l_eam_mat_req_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_direct_items_tbl.first..l_eam_direct_items_tbl.last loop
             if l_eam_direct_items_tbl(i).transaction_type is not null then
               l_eam_direct_items_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;

	  for i in l_eam_wo_comp_tbl.first..l_eam_wo_comp_tbl.last loop
             if l_eam_wo_comp_tbl(i).transaction_type is not null then
               l_eam_wo_comp_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

	 for i in l_eam_wo_quality_tbl.first..l_eam_wo_quality_tbl.last loop
             if l_eam_wo_quality_tbl(i).transaction_type is not null then
               l_eam_wo_quality_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

	 for i in l_eam_meter_reading_tbl.first..l_eam_meter_reading_tbl.last loop
             if l_eam_meter_reading_tbl(i).transaction_type is not null then
               l_eam_meter_reading_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

	 for i in l_eam_counter_prop_tbl.first..l_eam_counter_prop_tbl.last loop
             if l_eam_counter_prop_tbl(i).transaction_type is not null then
               l_eam_counter_prop_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

	 for i in l_eam_wo_comp_rebuild_tbl.first..l_eam_wo_comp_rebuild_tbl.last loop
             if l_eam_wo_comp_rebuild_tbl(i).transaction_type is not null then
               l_eam_wo_comp_rebuild_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

	 for i in l_eam_wo_comp_mr_read_tbl.first..l_eam_wo_comp_mr_read_tbl.last loop
             if l_eam_wo_comp_mr_read_tbl(i).transaction_type is not null then
               l_eam_wo_comp_mr_read_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

	 for i in l_eam_op_comp_tbl.first..l_eam_op_comp_tbl.last loop
             if l_eam_op_comp_tbl(i).transaction_type is not null then
               l_eam_op_comp_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

	 for i in l_eam_request_tbl.first..l_eam_request_tbl.last loop
             if l_eam_request_tbl(i).transaction_type is not null then
               l_eam_request_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           end loop;

         end if;

         x_eam_wo_tbl              := l_eam_wo_tbl;
         x_eam_wo_relations_tbl    := l_eam_wo_relations_tbl;
         x_eam_op_tbl              := l_eam_op_tbl;
         x_eam_op_network_tbl      := l_eam_op_network_tbl;
         x_eam_res_tbl             := l_eam_res_tbl;
         x_eam_res_inst_tbl        := l_eam_res_inst_tbl;
         x_eam_sub_res_tbl         := l_eam_sub_res_tbl;
	 x_eam_res_usage_tbl	   := l_eam_res_usage_tbl;
         x_eam_res_usage_tbl       := l_eam_res_usage_tbl;
         x_eam_mat_req_tbl         := l_eam_mat_req_tbl;
         x_eam_direct_items_tbl    := l_eam_direct_items_tbl;

	x_eam_wo_comp_tbl		:= l_eam_wo_comp_tbl        ;
	x_eam_wo_quality_tbl     	:= l_eam_wo_quality_tbl     ;
	x_eam_meter_reading_tbl  	:= l_eam_meter_reading_tbl  ;
	x_eam_counter_prop_tbl   	:= l_eam_counter_prop_tbl   ;
	x_eam_wo_comp_rebuild_tbl	:= l_eam_wo_comp_rebuild_tbl;
	x_eam_wo_comp_mr_read_tbl	:= l_eam_wo_comp_mr_read_tbl;
	x_eam_op_comp_tbl        	:= l_eam_op_comp_tbl        ;
	x_eam_request_tbl        	:= l_eam_request_tbl     ;

          x_batch_id      := l_batch_id;
          x_header_id_tbl := l_header_id_tbl;
          x_return_status := l_return_status;
          return;

         EXCEPTION

           WHEN OTHERS THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
         -- set all records as unprocessed

           for i in l_eam_wo_tbl.first..l_eam_wo_tbl.last loop
             if l_eam_wo_tbl(i).transaction_type is not null then
               l_eam_wo_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_wo_relations_tbl.first..l_eam_wo_relations_tbl.last loop
             if l_eam_wo_relations_tbl(i).transaction_type is not null then
               l_eam_wo_relations_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_op_tbl.first..l_eam_op_tbl.last loop
             if l_eam_op_tbl(i).transaction_type is not null then
               l_eam_op_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_op_network_tbl.first..l_eam_op_tbl.last loop
             if l_eam_op_network_tbl(i).transaction_type is not null then
               l_eam_op_network_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_res_tbl.first..l_eam_res_tbl.last loop
             if l_eam_res_tbl(i).transaction_type is not null then
               l_eam_res_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_res_inst_tbl.first..l_eam_res_inst_tbl.last loop
             if l_eam_res_inst_tbl(i).transaction_type is not null then
               l_eam_res_inst_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_sub_res_tbl.first..l_eam_sub_res_tbl.last loop
             if l_eam_sub_res_tbl(i).transaction_type is not null then
               l_eam_sub_res_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_mat_req_tbl.first..l_eam_mat_req_tbl.last loop
             if l_eam_mat_req_tbl(i).transaction_type is not null then
               l_eam_mat_req_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_direct_items_tbl.first..l_eam_direct_items_tbl.last loop
             if l_eam_direct_items_tbl(i).transaction_type is not null then
               l_eam_direct_items_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_res_usage_tbl.first..l_eam_res_usage_tbl.last loop
             if l_eam_res_usage_tbl(i).transaction_type is not null then
               l_eam_res_usage_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_wo_comp_tbl.first..l_eam_wo_comp_tbl.last loop
             if l_eam_wo_comp_tbl(i).transaction_type is not null then
               l_eam_wo_comp_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_wo_quality_tbl.first..l_eam_wo_quality_tbl.last loop
             if l_eam_wo_quality_tbl(i).transaction_type is not null then
               l_eam_wo_quality_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

	   for i in l_eam_meter_reading_tbl.first..l_eam_meter_reading_tbl.last loop
             if l_eam_meter_reading_tbl(i).transaction_type is not null then
               l_eam_meter_reading_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

	   for i in l_eam_counter_prop_tbl.first..l_eam_counter_prop_tbl.last loop
             if l_eam_counter_prop_tbl(i).transaction_type is not null then
               l_eam_counter_prop_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_wo_comp_rebuild_tbl.first..l_eam_wo_comp_rebuild_tbl.last loop
             if l_eam_wo_comp_rebuild_tbl(i).transaction_type is not null then
               l_eam_wo_comp_rebuild_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_wo_comp_mr_read_tbl.first..l_eam_wo_comp_mr_read_tbl.last loop
             if l_eam_wo_comp_mr_read_tbl(i).transaction_type is not null then
               l_eam_wo_comp_mr_read_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_op_comp_tbl.first..l_eam_op_comp_tbl.last loop
             if l_eam_op_comp_tbl(i).transaction_type is not null then
               l_eam_op_comp_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;

           for i in l_eam_request_tbl.first..l_eam_request_tbl.last loop
             if l_eam_request_tbl(i).transaction_type is not null then
               l_eam_request_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
             end if;
           end loop;


        END CHECK_BO_NETWORK;




    /********************************************************************
    * Procedure: Process_WO
    * Parameters IN:
    *         EAM Work Order column record
    *         Operation column table
    *         Operation Networks column Table
    *         Resource column Table
    *         Substitute Resource column table
    *         Material Requirements column table
    *         Direct Items column table
    * Parameters OUT:
    *         EAM Work Order column record
    *         Operation column table
    *         Operation Networks column Table
    *         Resource column Table
    *         Substitute Resource column table
    *         Material Requirements column table
    *         Direct Items column table
    * Purpose:
    *         This procedure is the driving procedure of the EAM
    *         business Obect. It will verify the integrity of the
    *         business object and will call the private API which
    *         further drive the business object to perform business
    *         logic validations.
    *********************************************************************/

      PROCEDURE PROCESS_WO
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_commit                  IN  VARCHAR2 := 'N'
         , p_eam_wo_rec              IN EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , p_eam_op_tbl              IN EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_res_usage_tbl       IN EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , p_eam_mat_req_tbl         IN EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl    IN EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , p_eam_wo_comp_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
         , p_eam_wo_quality_tbl      IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
         , p_eam_meter_reading_tbl   IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
	 , p_eam_counter_prop_tbl    IN  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
         , p_eam_wo_comp_rebuild_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
         , p_eam_wo_comp_mr_read_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
         , p_eam_op_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	 , p_eam_request_tbl         IN  EAM_PROCESS_WO_PUB.eam_request_tbl_type
         , x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
 	 , x_eam_wo_comp_rec         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
         , x_eam_wo_quality_tbl      OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
         , x_eam_meter_reading_tbl   OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
 	 , x_eam_counter_prop_tbl    OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
         , x_eam_wo_comp_rebuild_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
         , x_eam_wo_comp_mr_read_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
         , x_eam_op_comp_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	 , x_eam_request_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_request_tbl_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'EAM_WO_DEBUG.log'
         , p_debug_file_mode         IN  VARCHAR2 := 'w'
         ) IS

        G_EXC_SEV_QUIT_OBJECT   EXCEPTION;
        G_EXC_UNEXP_SKIP_OBJECT EXCEPTION;
        l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_other_message         VARCHAR2(50);
        l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
        l_err_text              VARCHAR2(2000);
        l_return_status         VARCHAR2(1);
        l_debug_file_mode       VARCHAR2(1) := p_debug_file_mode;

        l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_eam_direct_items_tbl       EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

	l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
 	l_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;

        l_out_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_out_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_out_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_out_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_out_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_out_eam_direct_items_tbl       EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
        l_out_mesg_token_tbl        EAM_ERROR_MESSAGE_PVT.mesg_token_tbl_type;

	l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
 	l_out_eam_counter_prop_tbl        EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;

        l_debug_flag            VARCHAR2(1) := p_debug;
	l_msg_count		NUMBER;
        l_msg_data              VARCHAR2(4000); /* Failure Entry Project */



		l_test_eam_wo_rec EAM_PROCESS_WO_PUB.eam_wo_rec_type;

BEGIN

        l_eam_wo_rec            := p_eam_wo_rec;
        l_eam_op_tbl            := p_eam_op_tbl;
        l_eam_op_network_tbl    := p_eam_op_network_tbl;
        l_eam_res_tbl           := p_eam_res_tbl;
        l_eam_res_inst_tbl      := p_eam_res_inst_tbl;
        l_eam_sub_res_tbl       := p_eam_sub_res_tbl;
        l_eam_res_usage_tbl     := p_eam_res_usage_tbl;
        l_eam_mat_req_tbl       := p_eam_mat_req_tbl;
        l_eam_direct_items_tbl  := p_eam_direct_items_tbl;

	l_eam_wo_comp_rec         := p_eam_wo_comp_rec;
	l_eam_wo_quality_tbl      := p_eam_wo_quality_tbl;
	l_eam_meter_reading_tbl   := p_eam_meter_reading_tbl;
	l_eam_counter_prop_tbl    := p_eam_counter_prop_tbl;
	l_eam_wo_comp_rebuild_tbl := p_eam_wo_comp_rebuild_tbl;
	l_eam_wo_comp_mr_read_tbl := p_eam_wo_comp_mr_read_tbl;
	l_eam_op_comp_tbl         := p_eam_op_comp_tbl;
	l_eam_request_tbl     	  := p_eam_request_tbl;


        --
        -- Set Business Object Idenfier in the System Information record.
        --
        EAM_ERROR_MESSAGE_PVT.Set_Bo_Identifier
                    (p_bo_identifier    =>  p_bo_identifier);

        --
        -- Initialize the message list if the user has set the Init Message List parameter
        --
        IF p_init_msg_list
        THEN
            EAM_ERROR_MESSAGE_PVT.Initialize;
        END IF;

	-- Set the global variable for debug.
        EAM_PROCESS_WO_PVT.Set_Debug(l_debug_flag);

        IF l_debug_flag = 'Y'
        THEN

            IF trim(p_output_dir) IS NULL OR trim(p_output_dir) = ''
            THEN

            -- If debug is Y then out dir must be specified

                l_out_mesg_token_tbl := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_text       => 'Debug is set to Y so an output directory' || ' must be specified. Debug will be turned' || ' off since no directory is specified'
                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                , x_Mesg_Token_Tbl     => l_out_mesg_token_tbl
                , p_Token_Tbl          => l_token_tbl
                 );
                l_mesg_token_tbl := l_out_mesg_token_tbl;

                l_out_eam_wo_rec            := l_eam_wo_rec;
                l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
                l_out_eam_direct_items_tbl  := l_eam_direct_items_tbl;
		l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;

		l_out_eam_wo_comp_rec          := l_eam_wo_comp_rec;
		l_out_eam_wo_quality_tbl       := l_eam_wo_quality_tbl;
		l_out_eam_meter_reading_tbl    := l_eam_meter_reading_tbl;
		l_out_eam_wo_comp_rebuild_tbl  := l_eam_wo_comp_rebuild_tbl;
		l_out_eam_counter_prop_tbl     := l_eam_counter_prop_tbl;
		l_out_eam_wo_comp_mr_read_tbl  := l_eam_wo_comp_mr_read_tbl;
		l_out_eam_op_comp_tbl          := l_eam_op_comp_tbl;
		l_out_eam_request_tbl          := l_eam_request_tbl;

                EAM_ERROR_MESSAGE_PVT.Log_Error
                (  p_eam_wo_rec             => l_eam_wo_rec
                ,  p_eam_op_tbl             => l_eam_op_tbl
                ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
                ,  p_eam_res_tbl            => l_eam_res_tbl
                ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
                ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
                ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
                ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
                ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
                ,  p_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_BO_LEVEL
                ,  x_eam_wo_rec             => l_out_eam_wo_rec
                ,  x_eam_op_tbl             => l_out_eam_op_tbl
                ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
                ,  x_eam_res_tbl            => l_out_eam_res_tbl
                ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
                ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
                ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
                ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
                ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
                 );

                l_eam_wo_rec            := l_out_eam_wo_rec;
                l_eam_op_tbl            := l_out_eam_op_tbl;
                l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
                l_eam_res_tbl           := l_out_eam_res_tbl;
                l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
                l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
                l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
                l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
                l_eam_direct_items_tbl  := l_out_eam_direct_items_tbl;

		l_eam_wo_comp_rec         := l_out_eam_wo_comp_rec        ;
		l_eam_wo_quality_tbl      := l_out_eam_wo_quality_tbl     ;
		l_eam_meter_reading_tbl   := l_out_eam_meter_reading_tbl  ;
		l_eam_wo_comp_rebuild_tbl := l_out_eam_wo_comp_rebuild_tbl;
		l_eam_counter_prop_tbl    := l_out_eam_counter_prop_tbl   ;
		l_eam_wo_comp_mr_read_tbl := l_out_eam_wo_comp_mr_read_tbl;
		l_eam_op_comp_tbl         := l_out_eam_op_comp_tbl        ;
		l_eam_request_tbl         := l_out_eam_request_tbl        ;

                l_debug_flag := 'N';

            END IF;

            IF trim(p_debug_filename) IS NULL OR trim(p_debug_filename) = ''
            THEN

                l_out_mesg_token_tbl := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                ( p_Message_text       => 'Debug is set to Y so an output filename' || ' must be specified. Debug will be turned' || ' off since no filename is specified'
                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                , x_Mesg_Token_Tbl     => l_out_mesg_token_tbl
                , p_Token_Tbl          => l_token_tbl
                 );
                l_mesg_token_tbl := l_out_mesg_token_tbl;

                l_out_eam_wo_rec            := l_eam_wo_rec;
                l_out_eam_op_tbl            := l_eam_op_tbl;
                l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
                l_out_eam_res_tbl           := l_eam_res_tbl;
                l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
                l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
                l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
                l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
                l_out_eam_direct_items_tbl  := l_eam_direct_items_tbl;

		l_out_eam_wo_comp_rec          := l_eam_wo_comp_rec;
		l_out_eam_wo_quality_tbl       := l_eam_wo_quality_tbl;
		l_out_eam_meter_reading_tbl    := l_eam_meter_reading_tbl;
		l_out_eam_wo_comp_rebuild_tbl  := l_eam_wo_comp_rebuild_tbl;
		l_out_eam_counter_prop_tbl     := l_eam_counter_prop_tbl;
		l_out_eam_wo_comp_mr_read_tbl  := l_eam_wo_comp_mr_read_tbl;
		l_out_eam_op_comp_tbl          := l_eam_op_comp_tbl;
		l_out_eam_request_tbl          := l_eam_request_tbl;

                EAM_ERROR_MESSAGE_PVT.Log_Error
                (  p_eam_wo_rec             => l_eam_wo_rec
                ,  p_eam_op_tbl             => l_eam_op_tbl
                ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
                ,  p_eam_res_tbl            => l_eam_res_tbl
                ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
                ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
                ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
                ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
                ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
                ,  p_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
                ,  p_error_status           => 'W'
                ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_BO_LEVEL
                ,  x_eam_wo_rec             => l_out_eam_wo_rec
                ,  x_eam_op_tbl             => l_out_eam_op_tbl
                ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
                ,  x_eam_res_tbl            => l_out_eam_res_tbl
                ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
                ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
                ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
                ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
                ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
                 );

                l_eam_wo_rec            := l_out_eam_wo_rec;
                l_eam_op_tbl            := l_out_eam_op_tbl;
                l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
                l_eam_res_tbl           := l_out_eam_res_tbl;
                l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
                l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
                l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
                l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
                l_eam_direct_items_tbl  := l_out_eam_direct_items_tbl;

		l_eam_wo_comp_rec         := l_out_eam_wo_comp_rec        ;
		l_eam_wo_quality_tbl      := l_out_eam_wo_quality_tbl     ;
		l_eam_meter_reading_tbl   := l_out_eam_meter_reading_tbl  ;
		l_eam_wo_comp_rebuild_tbl := l_out_eam_wo_comp_rebuild_tbl;
		l_eam_counter_prop_tbl    := l_out_eam_counter_prop_tbl   ;
		l_eam_wo_comp_mr_read_tbl := l_out_eam_wo_comp_mr_read_tbl;
		l_eam_op_comp_tbl         := l_out_eam_op_comp_tbl        ;
		l_eam_request_tbl         := l_out_eam_request_tbl        ;

		l_debug_flag := 'N';

            END IF;

            EAM_PROCESS_WO_PVT.Set_Debug(l_debug_flag);

            IF l_debug_flag = 'Y'
            THEN
                l_out_mesg_token_tbl        := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Open_Debug_Session
                (  p_debug_filename     => p_debug_filename
                ,  p_output_dir         => p_output_dir
                ,  p_debug_file_mode    => l_debug_file_mode
                ,  x_return_status      => l_return_status
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  x_mesg_token_tbl     => l_out_mesg_token_tbl
                 );
                l_mesg_token_tbl        := l_out_mesg_token_tbl;

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                    EAM_PROCESS_WO_PVT.Set_Debug('N');
                END IF;
            END IF;

        END IF;

IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN
    EAM_ERROR_MESSAGE_PVT.write_debug('==================================================Work Order==============================================================');
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Start ==============================================================');
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Workorder: ' || p_eam_wo_rec.wip_entity_name||'  Wip Entity Id : '||p_eam_wo_rec.wip_entity_id);
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Transaction Type : '||p_eam_wo_rec.TRANSACTION_TYPE||' (1:Create / 2:Update / 3:Delete / 4:Complete / 5:UnComplete)');
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : System Status Id : '||p_eam_wo_rec.STATUS_TYPE||' User Defined Status Id : '||p_eam_wo_rec.USER_DEFINED_STATUS_ID);
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Scheduled Start date : '||to_char(p_eam_wo_rec.SCHEDULED_START_DATE,'DD-MON-YY HH:MI:SS'));
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Scheduled Completion Date : '||to_char(p_eam_wo_rec.SCHEDULED_COMPLETION_DATE,'DD-MON-YY HH:MI:SS'));
    EAM_ERROR_MESSAGE_PVT.write_debug('');
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Num of operations: ' || p_eam_op_tbl.COUNT);
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Num of resources: ' || p_eam_res_tbl.COUNT);
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Num of materials: ' || p_eam_mat_req_tbl.COUNT);
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Num of direct items: ' || p_eam_direct_items_tbl.COUNT);
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Num of sub resources: ' || p_eam_sub_res_tbl.COUNT);
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Num of resource inst: ' || p_eam_res_inst_tbl.COUNT);
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Num of op networks: ' || p_eam_op_network_tbl.COUNT);

    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Workorder Completion Rec WipEntityId: ' || l_eam_wo_comp_rec.wip_entity_id);
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Num of qua records: ' || p_eam_wo_quality_tbl.COUNT);
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Num of meter rdg recs: ' || p_eam_meter_reading_tbl.COUNT);
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Num of counter prop recs: ' || p_eam_counter_prop_tbl.COUNT);
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Num of completion rebld recs: ' || p_eam_wo_comp_rebuild_tbl.COUNT);
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Num of completion meter rdg recs: ' || p_eam_wo_comp_mr_read_tbl.COUNT);
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Num of op completion recs: ' || p_eam_op_comp_tbl.COUNT);
    EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : Num of work request recs: ' || p_eam_request_tbl.COUNT);
END IF;


        --
        -- Verify if all the entity record(s) belong to the same business object
        --
IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS__WO : Calling Check_BO_Record procedure, BO record validation'); END IF;

       CHECK_BO_RECORD
         ( p_eam_wo_rec                    =>  l_eam_wo_rec
         , p_eam_op_tbl                    =>  l_eam_op_tbl
         , p_eam_op_network_tbl            =>  l_eam_op_network_tbl
         , p_eam_res_tbl                   =>  l_eam_res_tbl
         , p_eam_res_inst_tbl              =>  l_eam_res_inst_tbl
         , p_eam_sub_res_tbl               =>  l_eam_sub_res_tbl
         , p_eam_res_usage_tbl             =>  l_eam_res_usage_tbl
         , p_eam_mat_req_tbl               =>  l_eam_mat_req_tbl
         , p_eam_direct_items_tbl          =>  l_eam_direct_items_tbl
 	 , p_eam_wo_comp_rec		   =>  l_eam_wo_comp_rec
	 , p_eam_wo_quality_tbl		   =>  l_eam_wo_quality_tbl
	 , p_eam_meter_reading_tbl	   =>  l_eam_meter_reading_tbl
	 , p_eam_counter_prop_tbl	   =>  l_eam_counter_prop_tbl
	 , p_eam_wo_comp_rebuild_tbl	   =>  l_eam_wo_comp_rebuild_tbl
	 , p_eam_wo_comp_mr_read_tbl	   =>  l_eam_wo_comp_mr_read_tbl
	 , p_eam_op_comp_tbl		   =>  l_eam_op_comp_tbl
	 , p_eam_request_tbl		   =>  l_eam_request_tbl
         , x_return_status                 =>  l_return_status
       );



        IF l_return_status <> 'S' THEN
            RAISE G_EXC_SEV_QUIT_OBJECT;
        END IF;
IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS__WO : BO record validation Successful'); END IF;

        --
        -- Call the Private API for performing further business rules validation
        --

IF (p_eam_wo_rec.transaction_type IS NOT NULL)
   OR (p_eam_op_tbl.COUNT > 0) OR (p_eam_op_network_tbl.COUNT >0)
   OR (p_eam_res_tbl.COUNT >0) OR (p_eam_res_inst_tbl.COUNT >0) OR (p_eam_sub_res_tbl.COUNT >0)
   OR (p_eam_mat_req_tbl.COUNT >0) OR (p_eam_direct_items_tbl.COUNT >0) OR (p_eam_res_usage_tbl.COUNT>0)
THEN

IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS__WO : Calling the EAM_PROCESS_WO_PVT.PROCESS_WO procedure'); END IF;

EAM_PROCESS_WO_PVT.PROCESS_WO
        (  p_api_version_number            =>  p_api_version_number
         , x_return_status                 =>  x_return_status
         , x_msg_count                     =>  x_msg_count
         , p_eam_wo_rec                    =>  p_eam_wo_rec
         , p_eam_op_tbl                    =>  p_eam_op_tbl
         , p_eam_op_network_tbl            =>  p_eam_op_network_tbl
         , p_eam_res_tbl                   =>  p_eam_res_tbl
         , p_eam_res_inst_tbl              =>  p_eam_res_inst_tbl
         , p_eam_sub_res_tbl               =>  p_eam_sub_res_tbl
         , p_eam_res_usage_tbl             =>  p_eam_res_usage_tbl
         , p_eam_mat_req_tbl               =>  p_eam_mat_req_tbl
         , p_eam_direct_items_tbl          =>  p_eam_direct_items_tbl
         , x_eam_wo_rec                    =>  x_eam_wo_rec
         , x_eam_op_tbl                    =>  x_eam_op_tbl
         , x_eam_op_network_tbl            =>  x_eam_op_network_tbl
         , x_eam_res_tbl                   =>  x_eam_res_tbl
         , x_eam_res_inst_tbl              =>  x_eam_res_inst_tbl
         , x_eam_sub_res_tbl               =>  x_eam_sub_res_tbl
         , x_eam_res_usage_tbl             =>  x_eam_res_usage_tbl
         , x_eam_mat_req_tbl               =>  x_eam_mat_req_tbl
         , x_eam_direct_items_tbl          =>  x_eam_direct_items_tbl
         );

        l_return_status := x_return_status;
        IF l_return_status <> 'S'
        THEN

        l_eam_wo_rec            := x_eam_wo_rec;
        l_eam_op_tbl            := x_eam_op_tbl;
        l_eam_op_network_tbl    := x_eam_op_network_tbl;
        l_eam_res_tbl           := x_eam_res_tbl;
        l_eam_res_inst_tbl      := x_eam_res_inst_tbl;
        l_eam_sub_res_tbl       := x_eam_sub_res_tbl;
        l_eam_res_usage_tbl     := x_eam_res_usage_tbl;
        l_eam_mat_req_tbl       := x_eam_mat_req_tbl;
        l_eam_direct_items_tbl  := x_eam_direct_items_tbl;

        -- Call Error Handler

        l_token_tbl(1).token_name := 'WIP_ENTITY_NAME';
        l_token_tbl(1).token_value := p_eam_wo_rec.wip_entity_name;
        l_token_tbl(2).token_name := 'ORGANIZATION_ID';
        l_token_tbl(2).token_value := p_eam_wo_rec.organization_id;

        l_out_eam_wo_rec            := l_eam_wo_rec;
        l_out_eam_op_tbl            := l_eam_op_tbl;
        l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
        l_out_eam_res_tbl           := l_eam_res_tbl;
        l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
        l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
        l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
        l_out_eam_direct_items_tbl  := l_eam_direct_items_tbl;

        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_ALL
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_BO_LEVEL
        ,  p_other_message          => l_other_message
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_token_tbl        => l_token_tbl
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );

        l_eam_wo_rec            := l_out_eam_wo_rec;
        l_eam_op_tbl            := l_out_eam_op_tbl;
        l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
        l_eam_res_tbl           := l_out_eam_res_tbl;
        l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
        l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
        l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
        l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
        l_eam_direct_items_tbl  := l_out_eam_direct_items_tbl;

        x_eam_wo_rec            := l_eam_wo_rec;
        x_eam_op_tbl            := l_eam_op_tbl;
        x_eam_op_network_tbl    := l_eam_op_network_tbl;
        x_eam_res_tbl           := l_eam_res_tbl;
        x_eam_res_inst_tbl      := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl       := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl       := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl  := l_eam_direct_items_tbl;
           END IF;

--removed code for failure entry and shifted it to EAMVWOPB.pls


        x_return_status := l_return_status;

  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.PROCESS_WO : End===============================================================') ;   END IF ;

        x_msg_count := EAM_ERROR_MESSAGE_PVT.Get_Message_Count;

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y'
        THEN
            EAM_ERROR_MESSAGE_PVT.Dump_Message_List;
	    IF p_eam_request_tbl.COUNT = 0 THEN
	            EAM_ERROR_MESSAGE_PVT.Close_Debug_Session;
	    END IF;
        END IF;


        -- Standard check of p_commit.
        IF p_commit = 'Y' THEN
                COMMIT WORK;
        END IF;


	IF p_eam_request_tbl.COUNT > 0 THEN
		FOR mm in p_eam_request_tbl.FIRST..p_eam_request_tbl.LAST LOOP
			IF p_eam_request_tbl(mm).wip_entity_id IS NULL THEN
				l_eam_request_tbl(mm).wip_entity_id := x_eam_wo_rec.wip_entity_id;
			END IF;
		END LOOP;
	END IF;

END IF;

	IF (p_eam_wo_comp_rec.transaction_type is not null) THEN


		EAM_PROCESS_WO_PVT.COMP_UNCOMP_WORKORDER
		(
		  p_eam_wo_comp_rec            => p_eam_wo_comp_rec
		, p_eam_wo_quality_tbl         => p_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl      => p_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl    => p_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl    => p_eam_wo_comp_mr_read_tbl
		, x_eam_wo_comp_rec            => x_eam_wo_comp_rec
		, x_eam_wo_quality_tbl         => x_eam_wo_quality_tbl
		, x_eam_meter_reading_tbl      => x_eam_meter_reading_tbl
		, x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		, x_eam_wo_comp_rebuild_tbl    => x_eam_wo_comp_rebuild_tbl
		, x_eam_wo_comp_mr_read_tbl    => x_eam_wo_comp_mr_read_tbl
		, x_return_status              => l_return_status
		, x_msg_count                  => l_msg_count
		);

	        x_return_status := l_return_status;
		x_msg_count := l_msg_count;

		 IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y'
	        THEN
		    EAM_ERROR_MESSAGE_PVT.Dump_Message_List;
	            EAM_ERROR_MESSAGE_PVT.Close_Debug_Session;
	        END IF;


	END IF;

	IF p_eam_op_comp_tbl.COUNT > 0 THEN

		EAM_PROCESS_WO_PVT.COMP_UNCOMP_OPERATION
		(
		  p_eam_op_compl_tbl	    => p_eam_op_comp_tbl
		, p_eam_wo_quality_tbl      => p_eam_wo_quality_tbl
		, x_eam_op_comp_tbl         => x_eam_op_comp_tbl
		, x_eam_wo_quality_tbl      => x_eam_wo_quality_tbl
		, x_return_status           => l_return_status
		, x_msg_count               => l_msg_count
		);

	        x_return_status := l_return_status;
		x_msg_count := l_msg_count;

		 IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y'
	        THEN
		    EAM_ERROR_MESSAGE_PVT.Dump_Message_List;
	            EAM_ERROR_MESSAGE_PVT.Close_Debug_Session;
	        END IF;


	END IF;


	IF p_eam_request_tbl.COUNT > 0 THEN

		EAM_PROCESS_WO_PVT.SERVICE_WORKREQUEST_ASSO
		(
		  p_eam_request_tbl	    => l_eam_request_tbl
		, x_eam_request_tbl         => x_eam_request_tbl
		, x_return_status           => l_return_status
		, x_msg_count               => l_msg_count
		);

	        x_return_status := l_return_status;
		x_msg_count := l_msg_count;

		 IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y'
	        THEN
		    EAM_ERROR_MESSAGE_PVT.Dump_Message_List;
	            EAM_ERROR_MESSAGE_PVT.Close_Debug_Session;
	        END IF;


	END IF;

    EXCEPTION
    WHEN G_EXC_SEV_QUIT_OBJECT THEN

        -- baroy
        -- This exception is raised only by the CHECK_BO_RECORD
        -- procedure. In that procedure, the error message has already
        -- been logged. There is no need to do it again.



        x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
        x_msg_count     := EAM_ERROR_MESSAGE_PVT.Get_Message_Count;

        x_eam_wo_rec            := l_eam_wo_rec;
        x_eam_op_tbl            := l_eam_op_tbl;
        x_eam_op_network_tbl    := l_eam_op_network_tbl;
        x_eam_res_tbl           := l_eam_res_tbl;
        x_eam_res_inst_tbl      := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl       := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl       := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl  := l_eam_direct_items_tbl;

	x_eam_wo_comp_rec         := l_eam_wo_comp_rec;
	x_eam_wo_quality_tbl      := l_eam_wo_quality_tbl;
	x_eam_meter_reading_tbl   := l_eam_meter_reading_tbl;
	x_eam_counter_prop_tbl    := l_eam_counter_prop_tbl;
	x_eam_wo_comp_rebuild_tbl := l_eam_wo_comp_rebuild_tbl;
	x_eam_wo_comp_mr_read_tbl := l_eam_wo_comp_mr_read_tbl;
	x_eam_op_comp_tbl         := l_eam_op_comp_tbl;
	x_eam_request_tbl     	  := l_eam_request_tbl;

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y'
        THEN
            EAM_ERROR_MESSAGE_PVT.Dump_Message_List;
            EAM_ERROR_MESSAGE_PVT.Close_Debug_Session;
        END IF;


    WHEN G_EXC_UNEXP_SKIP_OBJECT THEN

    -- Call Error Handler

        l_out_eam_wo_rec            := l_eam_wo_rec;
        l_out_eam_op_tbl            := l_eam_op_tbl;
        l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
        l_out_eam_res_tbl           := l_eam_res_tbl;
        l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
        l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
        l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
        l_out_eam_direct_items_tbl  := l_eam_direct_items_tbl;

	l_out_eam_wo_comp_rec          := l_eam_wo_comp_rec;
	l_out_eam_wo_quality_tbl       := l_eam_wo_quality_tbl;
	l_out_eam_meter_reading_tbl    := l_eam_meter_reading_tbl;
	l_out_eam_wo_comp_rebuild_tbl  := l_eam_wo_comp_rebuild_tbl;
	l_out_eam_counter_prop_tbl     := l_eam_counter_prop_tbl;
	l_out_eam_wo_comp_mr_read_tbl  := l_eam_wo_comp_mr_read_tbl;
	l_out_eam_op_comp_tbl          := l_eam_op_comp_tbl;
	l_out_eam_request_tbl          := l_eam_request_tbl;

        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_BO_LEVEL
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_NOT_PICKED
        ,  p_other_message          => l_other_message
        ,  p_other_token_tbl        => l_token_tbl
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );

        l_eam_wo_rec            := l_out_eam_wo_rec;
        l_eam_op_tbl            := l_out_eam_op_tbl;
        l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
        l_eam_res_tbl           := l_out_eam_res_tbl;
        l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
        l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
        l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
        l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
        l_eam_direct_items_tbl  := l_out_eam_direct_items_tbl;

	l_eam_wo_comp_rec         := l_out_eam_wo_comp_rec        ;
	l_eam_wo_quality_tbl      := l_out_eam_wo_quality_tbl     ;
	l_eam_meter_reading_tbl   := l_out_eam_meter_reading_tbl  ;
	l_eam_wo_comp_rebuild_tbl := l_out_eam_wo_comp_rebuild_tbl;
	l_eam_counter_prop_tbl    := l_out_eam_counter_prop_tbl   ;
	l_eam_wo_comp_mr_read_tbl := l_out_eam_wo_comp_mr_read_tbl;
	l_eam_op_comp_tbl         := l_out_eam_op_comp_tbl        ;
	l_eam_request_tbl         := l_out_eam_request_tbl        ;

        x_eam_wo_rec            := l_eam_wo_rec;
        x_eam_op_tbl            := l_eam_op_tbl;
        x_eam_op_network_tbl    := l_eam_op_network_tbl;
        x_eam_res_tbl           := l_eam_res_tbl;
        x_eam_res_inst_tbl      := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl       := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl       := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl  := l_eam_direct_items_tbl;

	x_eam_wo_comp_rec         := l_eam_wo_comp_rec;
	x_eam_wo_quality_tbl      := l_eam_wo_quality_tbl;
	x_eam_meter_reading_tbl   := l_eam_meter_reading_tbl;
	x_eam_counter_prop_tbl    := l_eam_counter_prop_tbl;
	x_eam_wo_comp_rebuild_tbl := l_eam_wo_comp_rebuild_tbl;
	x_eam_wo_comp_mr_read_tbl := l_eam_wo_comp_mr_read_tbl;
	x_eam_op_comp_tbl         := l_eam_op_comp_tbl;
	x_eam_request_tbl     	  := l_eam_request_tbl;

        x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED;
        x_msg_count     := EAM_ERROR_MESSAGE_PVT.Get_Message_Count;

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y'
        THEN
            EAM_ERROR_MESSAGE_PVT.Dump_Message_List;
            EAM_ERROR_MESSAGE_PVT.Close_Debug_Session;
        END IF;


    WHEN OTHERS THEN

        -- Call Error Handler

      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
        (  p_message_name  => 'EAM_PR_WO_UNKNOWN_ERROR'
         , p_token_tbl     => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl := l_out_mesg_token_tbl;

      l_other_message := 'EAM_PR_WO_CSEV_SKIP';

        l_out_eam_wo_rec            := l_eam_wo_rec;
        l_out_eam_op_tbl            := l_eam_op_tbl;
        l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
        l_out_eam_res_tbl           := l_eam_res_tbl;
        l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
        l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
        l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
        l_out_eam_direct_items_tbl  := l_eam_direct_items_tbl;

	l_out_eam_wo_comp_rec          := l_eam_wo_comp_rec;
	l_out_eam_wo_quality_tbl       := l_eam_wo_quality_tbl;
	l_out_eam_meter_reading_tbl    := l_eam_meter_reading_tbl;
	l_out_eam_wo_comp_rebuild_tbl  := l_eam_wo_comp_rebuild_tbl;
	l_out_eam_counter_prop_tbl     := l_eam_counter_prop_tbl;
	l_out_eam_wo_comp_mr_read_tbl  := l_eam_wo_comp_mr_read_tbl;
	l_out_eam_op_comp_tbl          := l_eam_op_comp_tbl;
	l_out_eam_request_tbl          := l_eam_request_tbl;

        EAM_ERROR_MESSAGE_PVT.Log_Error
        (  p_eam_wo_rec             => l_eam_wo_rec
        ,  p_eam_op_tbl             => l_eam_op_tbl
        ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
        ,  p_eam_res_tbl            => l_eam_res_tbl
        ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
        ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
        ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
        ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
        ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
        ,  p_mesg_token_tbl         => l_mesg_token_tbl
        ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED
        ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_BO_LEVEL
        ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
        ,  p_other_message          => l_other_message
        ,  x_eam_wo_rec             => l_out_eam_wo_rec
        ,  x_eam_op_tbl             => l_out_eam_op_tbl
        ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
        ,  x_eam_res_tbl            => l_out_eam_res_tbl
        ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
        ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
        ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
        ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
        ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
        );

        l_eam_wo_rec            := l_out_eam_wo_rec;
        l_eam_op_tbl            := l_out_eam_op_tbl;
        l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
        l_eam_res_tbl           := l_out_eam_res_tbl;
        l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
        l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
        l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
        l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
        l_eam_direct_items_tbl  := l_out_eam_direct_items_tbl;

	l_eam_wo_comp_rec         := l_out_eam_wo_comp_rec        ;
	l_eam_wo_quality_tbl      := l_out_eam_wo_quality_tbl     ;
	l_eam_meter_reading_tbl   := l_out_eam_meter_reading_tbl  ;
	l_eam_wo_comp_rebuild_tbl := l_out_eam_wo_comp_rebuild_tbl;
	l_eam_counter_prop_tbl    := l_out_eam_counter_prop_tbl   ;
	l_eam_wo_comp_mr_read_tbl := l_out_eam_wo_comp_mr_read_tbl;
	l_eam_op_comp_tbl         := l_out_eam_op_comp_tbl        ;
	l_eam_request_tbl         := l_out_eam_request_tbl        ;

        x_eam_wo_rec            := l_eam_wo_rec;
        x_eam_op_tbl            := l_eam_op_tbl;
        x_eam_op_network_tbl    := l_eam_op_network_tbl;
        x_eam_res_tbl           := l_eam_res_tbl;
        x_eam_res_inst_tbl      := l_eam_res_inst_tbl;
        x_eam_sub_res_tbl       := l_eam_sub_res_tbl;
        x_eam_res_usage_tbl     := l_eam_res_usage_tbl;
        x_eam_mat_req_tbl       := l_eam_mat_req_tbl;
        x_eam_direct_items_tbl  := l_eam_direct_items_tbl;

	x_eam_wo_comp_rec         := l_eam_wo_comp_rec;
	x_eam_wo_quality_tbl      := l_eam_wo_quality_tbl;
	x_eam_meter_reading_tbl   := l_eam_meter_reading_tbl;
	x_eam_counter_prop_tbl    := l_eam_counter_prop_tbl;
	x_eam_wo_comp_rebuild_tbl := l_eam_wo_comp_rebuild_tbl;
	x_eam_wo_comp_mr_read_tbl := l_eam_wo_comp_mr_read_tbl;
	x_eam_op_comp_tbl         := l_eam_op_comp_tbl;
	x_eam_request_tbl     	  := l_eam_request_tbl;

        x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_UNEXPECTED;
        x_msg_count     := EAM_ERROR_MESSAGE_PVT.Get_Message_Count;

        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y'
        THEN
            EAM_ERROR_MESSAGE_PVT.Dump_Message_List;
            EAM_ERROR_MESSAGE_PVT.Close_Debug_Session;
        END IF;


END PROCESS_WO;


/*
*  Overloaded procedure for safety permit
*
*/

PROCEDURE PROCESS_WO
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_commit                  IN  VARCHAR2 := 'N'
         , p_eam_wo_rec              IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
          , p_eam_wo_comp_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
         , p_eam_wo_quality_tbl      IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
         , p_eam_meter_reading_tbl   IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
          , p_eam_counter_prop_tbl    IN  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
         , p_eam_wo_comp_rebuild_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
         , p_eam_wo_comp_mr_read_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
         , p_eam_op_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
         , p_eam_request_tbl         IN  EAM_PROCESS_WO_PUB.eam_request_tbl_type
         , p_eam_permit_tbl          IN  EAM_PROCESS_PERMIT_PUB.eam_wp_tbl_type -- new param for safety permit
         , p_eam_permit_wo_assoc_tbl IN EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type -- new param for safety permit
         , x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
        , x_eam_wo_comp_rec         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
         , x_eam_wo_quality_tbl      OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
         , x_eam_meter_reading_tbl   OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
        , x_eam_counter_prop_tbl    OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
         , x_eam_wo_comp_rebuild_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
         , x_eam_wo_comp_mr_read_tbl OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
         , x_eam_op_comp_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
         , x_eam_request_tbl         OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_request_tbl_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'EAM_WO_DEBUG.log'
         , p_debug_file_mode         IN  VARCHAR2 := 'w'
         ) IS

         l_return_status VARCHAR2(1);
         l_permit_wo_association_tbl EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type;
         lx_permit_wo_association_tbl EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type;
         l_work_permit_header_rec    EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type;
         lx_work_permit_header_rec   EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type;
         l_permit_wo_association_rec EAM_PROCESS_PERMIT_PUB.eam_wp_association_rec_type;
         l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type ;

         l_wip_entity_id  NUMBER;



BEGIN

PROCESS_WO
        (  p_bo_identifier                 =>  p_bo_identifier
         , p_api_version_number            =>  p_api_version_number
         , p_commit                        =>  p_commit
         , p_init_msg_list                 =>  p_init_msg_list
         , p_eam_wo_rec                    =>  p_eam_wo_rec
         , p_eam_op_tbl                    =>  p_eam_op_tbl
         , p_eam_op_network_tbl            =>  p_eam_op_network_tbl
         , p_eam_res_tbl                   =>  p_eam_res_tbl
         , p_eam_res_inst_tbl              =>  p_eam_res_inst_tbl
         , p_eam_sub_res_tbl               =>  p_eam_sub_res_tbl
         , p_eam_res_usage_tbl             =>  p_eam_res_usage_tbl
         , p_eam_mat_req_tbl               =>  p_eam_mat_req_tbl
         , p_eam_direct_items_tbl          =>  p_eam_direct_items_tbl
         , p_eam_wo_comp_rec               =>  p_eam_wo_comp_rec
         , p_eam_wo_quality_tbl            =>  p_eam_wo_quality_tbl
         , p_eam_meter_reading_tbl         =>  p_eam_meter_reading_tbl
         , p_eam_counter_prop_tbl          =>  p_eam_counter_prop_tbl
         , p_eam_wo_comp_rebuild_tbl       =>  p_eam_wo_comp_rebuild_tbl
         , p_eam_wo_comp_mr_read_tbl       =>  p_eam_wo_comp_mr_read_tbl
         , p_eam_op_comp_tbl               =>  p_eam_op_comp_tbl
         , p_eam_request_tbl               =>  p_eam_request_tbl
         , x_eam_wo_rec                    =>  x_eam_wo_rec
         , x_eam_op_tbl                    =>  x_eam_op_tbl
         , x_eam_op_network_tbl            =>  x_eam_op_network_tbl
         , x_eam_res_tbl                   =>  x_eam_res_tbl
         , x_eam_res_inst_tbl              =>  x_eam_res_inst_tbl
         , x_eam_sub_res_tbl               =>  x_eam_sub_res_tbl
         , x_eam_res_usage_tbl             =>  x_eam_res_usage_tbl
         , x_eam_mat_req_tbl               =>  x_eam_mat_req_tbl
         , x_eam_direct_items_tbl          =>  x_eam_direct_items_tbl
         , x_eam_wo_comp_rec               =>  x_eam_wo_comp_rec
         , x_eam_wo_quality_tbl            =>  x_eam_wo_quality_tbl
         , x_eam_meter_reading_tbl         =>  x_eam_meter_reading_tbl
         , x_eam_counter_prop_tbl          =>  x_eam_counter_prop_tbl
         , x_eam_wo_comp_rebuild_tbl       =>  x_eam_wo_comp_rebuild_tbl
         , x_eam_wo_comp_mr_read_tbl       =>  x_eam_wo_comp_mr_read_tbl
         , x_eam_op_comp_tbl               =>  x_eam_op_comp_tbl
         , x_eam_request_tbl               =>  x_eam_request_tbl
         , x_return_status                 =>  l_return_status
         , x_msg_count                     =>  x_msg_count
         , p_debug                         =>  p_debug
         , p_output_dir                    =>  p_output_dir
         , p_debug_filename                =>  p_debug_filename
         , p_debug_file_mode               =>  p_debug_file_mode
         );


         x_return_status := l_return_status ;

  /*Call the permit APIs only if work order creation was successful*/

        IF ((l_return_status = 'S') or (l_return_status is null)) THEN

        -- In case of update workorder x_eam_wo_rec.wip_entity_id might be null
        -- if there are no association records dummy record will be passed which contains wip_entity_id
            IF x_eam_wo_rec.wip_entity_id is not null THEN
              l_wip_entity_id :=x_eam_wo_rec.wip_entity_id;
            ELSIF p_eam_permit_wo_assoc_tbl.COUNT > 0 THEN
              l_wip_entity_id :=p_eam_permit_wo_assoc_tbl(1).TARGET_REF_ID;
            END IF;


            -- Process new permit records

            IF p_eam_permit_tbl.COUNT > 0 THEN
                    FOR i in p_eam_permit_tbl.FIRST..p_eam_permit_tbl.LAST LOOP

                      l_work_permit_header_rec := p_eam_permit_tbl(i);
                       IF l_work_permit_header_rec.transaction_type=EAM_PROCESS_WO_PVT.G_OPR_CREATE THEN
                          --build association record using permit header record

                          l_permit_wo_association_rec.HEADER_ID               :=1;
                          l_permit_wo_association_rec.BATCH_ID                :=l_wip_entity_id;
                          l_permit_wo_association_rec.ROW_ID                  :=i;
                          l_permit_wo_association_rec.SAFETY_ASSOCIATION_ID   := null;
                          l_permit_wo_association_rec.SOURCE_ID               :=null;
                          l_permit_wo_association_rec.TARGET_REF_ID           := l_wip_entity_id;
                          l_permit_wo_association_rec.ASSOCIATION_TYPE        :=3;
                          l_permit_wo_association_rec.TRANSACTION_TYPE        :=EAM_PROCESS_WO_PVT.G_OPR_CREATE;
                          l_permit_wo_association_rec.ATTRIBUTE_CATEGORY      :=l_work_permit_header_rec.ATTRIBUTE_CATEGORY;
                          l_permit_wo_association_rec.ATTRIBUTE1              :=l_work_permit_header_rec.ATTRIBUTE1;
                          l_permit_wo_association_rec.ATTRIBUTE2              :=l_work_permit_header_rec.ATTRIBUTE2;
                          l_permit_wo_association_rec.ATTRIBUTE3              :=l_work_permit_header_rec.ATTRIBUTE3;
                          l_permit_wo_association_rec.ATTRIBUTE4              :=l_work_permit_header_rec.ATTRIBUTE4;
                          l_permit_wo_association_rec.ATTRIBUTE5              :=l_work_permit_header_rec.ATTRIBUTE5;
                          l_permit_wo_association_rec.ATTRIBUTE6              :=l_work_permit_header_rec.ATTRIBUTE6;
                          l_permit_wo_association_rec.ATTRIBUTE7              :=l_work_permit_header_rec.ATTRIBUTE7;
                          l_permit_wo_association_rec.ATTRIBUTE8              :=l_work_permit_header_rec.ATTRIBUTE8;
                          l_permit_wo_association_rec.ATTRIBUTE9              :=l_work_permit_header_rec.ATTRIBUTE9;
                          l_permit_wo_association_rec.ATTRIBUTE10             :=l_work_permit_header_rec.ATTRIBUTE10;
                          l_permit_wo_association_rec.ATTRIBUTE11             :=l_work_permit_header_rec.ATTRIBUTE11;
                          l_permit_wo_association_rec.ATTRIBUTE12             :=l_work_permit_header_rec.ATTRIBUTE12;
                          l_permit_wo_association_rec.ATTRIBUTE13             :=l_work_permit_header_rec.ATTRIBUTE13;
                          l_permit_wo_association_rec.ATTRIBUTE14             :=l_work_permit_header_rec.ATTRIBUTE14;
                          l_permit_wo_association_rec.ATTRIBUTE15             :=l_work_permit_header_rec.ATTRIBUTE15;
                          l_permit_wo_association_rec.ATTRIBUTE16              :=l_work_permit_header_rec.ATTRIBUTE16;
                          l_permit_wo_association_rec.ATTRIBUTE17             :=l_work_permit_header_rec.ATTRIBUTE17;
                          l_permit_wo_association_rec.ATTRIBUTE18             :=l_work_permit_header_rec.ATTRIBUTE18;
                          l_permit_wo_association_rec.ATTRIBUTE19             :=l_work_permit_header_rec.ATTRIBUTE19;
                          l_permit_wo_association_rec.ATTRIBUTE20             :=l_work_permit_header_rec.ATTRIBUTE20;
                          l_permit_wo_association_rec.ATTRIBUTE21             :=l_work_permit_header_rec.ATTRIBUTE21;
                          l_permit_wo_association_rec.ATTRIBUTE22             :=l_work_permit_header_rec.ATTRIBUTE22;
                          l_permit_wo_association_rec.ATTRIBUTE23             :=l_work_permit_header_rec.ATTRIBUTE23;
                          l_permit_wo_association_rec.ATTRIBUTE24             :=l_work_permit_header_rec.ATTRIBUTE24;
                          l_permit_wo_association_rec.ATTRIBUTE25             :=l_work_permit_header_rec.ATTRIBUTE25;
                          l_permit_wo_association_rec.ATTRIBUTE26             :=l_work_permit_header_rec.ATTRIBUTE26;
                          l_permit_wo_association_rec.ATTRIBUTE27             :=l_work_permit_header_rec.ATTRIBUTE27;
                          l_permit_wo_association_rec.ATTRIBUTE28             :=l_work_permit_header_rec.ATTRIBUTE28;
                          l_permit_wo_association_rec.ATTRIBUTE29             :=l_work_permit_header_rec.ATTRIBUTE29;
                          l_permit_wo_association_rec.ATTRIBUTE30             :=l_work_permit_header_rec.ATTRIBUTE30;

                          l_permit_wo_association_tbl(1) :=  l_permit_wo_association_rec;
                        END IF; -- End if transaction_type

                       EAM_PROCESS_PERMIT_PVT.PROCESS_WORK_PERMIT(
                            p_bo_identifier              => p_bo_identifier
                          , p_api_version_number      	 => p_api_version_number
                          , p_init_msg_list           	 => TRUE
                          , p_commit                  	 => p_commit
                          , p_work_permit_header_rec  	 => l_work_permit_header_rec
                          , p_permit_wo_association_tbl  => l_permit_wo_association_tbl
                          , x_work_permit_header_rec  	 => lx_work_permit_header_rec
                          , x_return_status           	 => l_return_status
                          , x_msg_count               	 => x_msg_count
                          , p_debug                      => p_debug
                          , p_output_dir             	   => p_output_dir
                          , p_debug_filename          	 => p_debug_filename
                          , p_debug_file_mode        	   => p_debug_file_mode
                          );
                    END LOOP; --PERMIT LOOP
            END IF;

             --check for work order/permit association for existing permit

            IF p_eam_permit_wo_assoc_tbl.COUNT > 0 THEN
                  FOR j in p_eam_permit_wo_assoc_tbl.FIRST..p_eam_permit_wo_assoc_tbl.LAST LOOP

                        IF ( p_eam_permit_wo_assoc_tbl(j).SOURCE_ID IS NOT NULL) THEN
                            l_permit_wo_association_tbl(1) :=p_eam_permit_wo_assoc_tbl(j);
                            l_permit_wo_association_tbl(1).TARGET_REF_ID :=l_wip_entity_id;
                             EAM_PROCESS_PERMIT_PVT.PERMIT_WORK_ORDER_ASSOCIATION
                                   ( p_validation_level           => EAM_PROCESS_WO_PVT.G_OPR_UPDATE
                                     , p_organization_id	           => p_eam_wo_rec.organization_id
                                     , p_permit_wo_association_tbl  => l_permit_wo_association_tbl
                                     , p_work_permit_id             => l_permit_wo_association_tbl(1).SOURCE_ID
                                     , x_permit_wo_association_tbl  => lx_permit_wo_association_tbl
                                     , x_mesg_token_tbl             => l_out_Mesg_Token_Tbl
                                     , x_return_status              => l_return_status
                                    );


                        END IF;
                    END LOOP; --ASSOCIATION LOOP
                END IF;

        END IF;
        x_return_status :=l_return_status;


END PROCESS_WO;


 PROCEDURE EXPLODE_ACTIVITY
       (  p_api_version             IN  NUMBER   := 1.0
        , p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
        , p_commit                  IN  VARCHAR2 := fnd_api.g_false
        , p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
        , p_organization_id         IN  NUMBER
        , p_asset_activity_id       IN  NUMBER
        , p_wip_entity_id           IN  NUMBER
        , p_start_date              IN  DATE
        , p_completion_date         IN  DATE
        , p_rev_datetime            IN  DATE     := SYSDATE
        , p_entity_type             IN  NUMBER   := 6
        , x_return_status           OUT NOCOPY VARCHAR2
        , x_msg_count               OUT NOCOPY NUMBER
        , x_msg_data                OUT NOCOPY VARCHAR2
        )
        IS

        l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_eam_direct_items_tbl       EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

        x_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        x_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        x_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        x_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        x_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        x_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        x_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        x_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        x_eam_direct_items_tbl       EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

        BEGIN

        l_eam_wo_rec.WIP_ENTITY_ID                := p_wip_entity_id;
        l_eam_wo_rec.ORGANIZATION_ID              := p_organization_id;
        l_eam_wo_rec.ASSET_ACTIVITY_ID            := p_asset_activity_id;
        l_eam_wo_rec.REQUESTED_START_DATE         := p_start_date;
        l_eam_wo_rec.DUE_DATE                     := p_completion_date;
        l_eam_wo_rec.BOM_REVISION_DATE            := p_rev_datetime;
        l_eam_wo_rec.ROUTING_REVISION_DATE        := p_rev_datetime;
        l_eam_wo_rec.SOURCE_LINE_ID               := null;
        l_eam_wo_rec.SOURCE_CODE                  := 'EZ_WO';
        l_eam_wo_rec.RETURN_STATUS                := null;
        l_eam_wo_rec.TRANSACTION_TYPE             := 2;


        EAM_PROCESS_WO_PVT.PROCESS_WO
        ( p_api_version_number            =>  p_api_version
        , x_return_status                 =>  x_return_status
        , x_msg_count                     =>  x_msg_count
        , p_eam_wo_rec                    =>  l_eam_wo_rec
        , p_eam_op_tbl                    =>  l_eam_op_tbl
        , p_eam_op_network_tbl            =>  l_eam_op_network_tbl
        , p_eam_res_tbl                   =>  l_eam_res_tbl
        , p_eam_res_inst_tbl              =>  l_eam_res_inst_tbl
        , p_eam_sub_res_tbl               =>  l_eam_sub_res_tbl
        , p_eam_res_usage_tbl             =>  l_eam_res_usage_tbl
        , p_eam_mat_req_tbl               =>  l_eam_mat_req_tbl
        , p_eam_direct_items_tbl               =>  l_eam_direct_items_tbl
        , x_eam_wo_rec                    =>  x_eam_wo_rec
        , x_eam_op_tbl                    =>  x_eam_op_tbl
        , x_eam_op_network_tbl            =>  x_eam_op_network_tbl
        , x_eam_res_tbl                   =>  x_eam_res_tbl
        , x_eam_res_inst_tbl              =>  x_eam_res_inst_tbl
        , x_eam_sub_res_tbl               =>  x_eam_sub_res_tbl
        , x_eam_res_usage_tbl             =>  x_eam_res_usage_tbl
        , x_eam_mat_req_tbl               =>  x_eam_mat_req_tbl
        , x_eam_direct_items_tbl               =>  x_eam_direct_items_tbl
        );

END EXPLODE_ACTIVITY;







PROCEDURE CHECK_BO_RECORD
        ( p_eam_wo_rec              IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
        , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
        , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
        , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
        , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
        , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
        , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
        , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
	, p_eam_wo_comp_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
        , p_eam_wo_quality_tbl      IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
        , p_eam_meter_reading_tbl   IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
	, p_eam_counter_prop_tbl    IN  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
        , p_eam_wo_comp_rebuild_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
        , p_eam_wo_comp_mr_read_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
        , p_eam_op_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	, p_eam_request_tbl         IN  EAM_PROCESS_WO_PUB.eam_request_tbl_type
        , x_return_status           OUT NOCOPY VARCHAR2
        )
        IS

        -- baroy
        l_wip_entity_id   NUMBER       := NULL;
        l_organization_id NUMBER       := NULL;
        l_other_message   VARCHAR2(50) := NULL;
        l_mesg_token_tbl  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

        l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

	l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
        l_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type ;

        l_out_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_out_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_out_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_out_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_out_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_out_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

	l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
        l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type ;

        -- baroy

        BEGIN

IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.CHECK_BO_RECORD : Start==================='); END IF;

           l_eam_wo_rec            := p_eam_wo_rec;
           l_eam_op_tbl            := p_eam_op_tbl;
           l_eam_op_network_tbl    := p_eam_op_network_tbl;
           l_eam_res_tbl           := p_eam_res_tbl;
           l_eam_res_inst_tbl      := p_eam_res_inst_tbl;
           l_eam_sub_res_tbl       := p_eam_sub_res_tbl;
           l_eam_res_usage_tbl     := p_eam_res_usage_tbl;
           l_eam_mat_req_tbl       := p_eam_mat_req_tbl;
           l_eam_direct_items_tbl  := p_eam_direct_items_tbl;

	   l_eam_wo_comp_rec		:= p_eam_wo_comp_rec;
  	   l_eam_wo_quality_tbl		:= p_eam_wo_quality_tbl;
	   l_eam_meter_reading_tbl	:= p_eam_meter_reading_tbl;
	   l_eam_counter_prop_tbl	:= p_eam_counter_prop_tbl;
	   l_eam_wo_comp_rebuild_tbl	:= p_eam_wo_comp_rebuild_tbl;
	   l_eam_wo_comp_mr_read_tbl	:= p_eam_wo_comp_mr_read_tbl;
	   l_eam_op_comp_tbl		:= p_eam_op_comp_tbl;
	   l_eam_request_tbl		:= p_eam_request_tbl;

           -- baroy - If Parent record is null, then find the first non-null weid and orgid
           --         from the child tables


           IF p_eam_wo_rec.transaction_type is null and (p_eam_wo_comp_rec.transaction_type is null and p_eam_request_tbl.COUNT >0 )then

             FOR J in 1 .. 1 LOOP

               FOR I IN 1..p_eam_op_tbl.COUNT LOOP
                 -- If there is an entity with error, then flag it and exit.
                 IF p_eam_op_tbl(I).transaction_type is not null and
                    (p_eam_op_tbl(I).wip_entity_id is null or
                     p_eam_op_tbl(I).organization_id is null) then
                   l_other_message := 'EAM_WO_OP_REC_INVALID';
                   EXIT;
                 END IF;
                 IF p_eam_op_tbl(I).wip_entity_id is not null AND
                    p_eam_op_tbl(I).organization_Id is not null
                 THEN
                    l_wip_entity_id   := p_eam_op_tbl(I).wip_entity_id;
                    l_organization_id := p_eam_op_tbl(I).organization_id;
                    EXIT;
                 END IF;
               END LOOP;
               IF l_wip_entity_id is not null or
                  l_other_message is not null then exit; end if;

               FOR I IN 1..p_eam_op_network_tbl.COUNT LOOP
                 -- If there is an entity with error, then flag it and exit.
                 IF p_eam_op_network_tbl(I).transaction_type is not null and
                    (p_eam_op_network_tbl(I).wip_entity_id is null or
                     p_eam_op_network_tbl(I).organization_id is null) then
                   l_other_message := 'EAM_WO_OPN_REC_INVALID';
                   EXIT;
                 END IF;
                 IF p_eam_op_network_tbl(I).wip_entity_id is not null AND
                    p_eam_op_network_tbl(I).organization_id is not null
                 THEN
                    l_wip_entity_id   := p_eam_op_network_tbl(I).wip_entity_id;
                    l_organization_id := p_eam_op_network_tbl(I).organization_id;
                    EXIT;
                 END IF;
               END LOOP;
               IF l_wip_entity_id is not null or
                  l_other_message is not null then exit; end if;

               FOR I IN 1..p_eam_res_tbl.COUNT LOOP
                 -- If there is an entity with error, then flag it and exit.
                 IF p_eam_res_tbl(I).transaction_type is not null and
                    (p_eam_res_tbl(I).wip_entity_id is null or
                     p_eam_res_tbl(I).organization_id is null) then
                   l_other_message := 'EAM_WO_RES_REC_INVALID';
                   EXIT;
                 END IF;
                 IF p_eam_res_tbl(I).wip_entity_id is not null AND
                    p_eam_res_tbl(I).organization_id is not null
                 THEN
                    l_wip_entity_id   := p_eam_res_tbl(I).wip_entity_id;
                    l_organization_id := p_eam_res_tbl(I).organization_id;
                    EXIT;
                 END IF;
               END LOOP;
               IF l_wip_entity_id is not null or
                  l_other_message is not null then exit; end if;

               FOR I IN 1..p_eam_res_inst_tbl.COUNT LOOP
                 -- If there is an entity with error, then flag it and exit.
                 IF p_eam_res_inst_tbl(I).transaction_type is not null and
                    (p_eam_res_inst_tbl(I).wip_entity_id is null or
                     p_eam_res_inst_tbl(I).organization_id is null) then
                   l_other_message := 'EAM_WO_RESI_REC_INVALID';
                   EXIT;
                 END IF;
                 IF p_eam_res_inst_tbl(I).wip_entity_id is not null AND
                    p_eam_res_inst_tbl(I).organization_id is not null
                 THEN
                    l_wip_entity_id   := p_eam_res_inst_tbl(I).wip_entity_id;
                    l_organization_id := p_eam_res_inst_tbl(I).organization_id;
                    EXIT;
                 END IF;
               END LOOP;
               IF l_wip_entity_id is not null or
                  l_other_message is not null then exit; end if;

               FOR I IN 1..p_eam_sub_res_tbl.COUNT LOOP
                 -- If there is an entity with error, then flag it and exit.
                 IF p_eam_sub_res_tbl(I).transaction_type is not null and
                    (p_eam_sub_res_tbl(I).wip_entity_id is null or
                     p_eam_sub_res_tbl(I).organization_id is null) then
                   l_other_message := 'EAM_WO_SURES_REC_INVALID';
                   EXIT;
                 END IF;
                 IF p_eam_sub_res_tbl(I).wip_entity_id is not null AND
                    p_eam_sub_res_tbl(I).organization_id is not null
                 THEN
                    l_wip_entity_id   := p_eam_sub_res_tbl(I).wip_entity_id;
                    l_organization_id := p_eam_sub_res_tbl(I).organization_id;
                    EXIT;
                 END IF;
               END LOOP;
               IF l_wip_entity_id is not null or
                  l_other_message is not null then exit; end if;

               FOR I IN 1..p_eam_res_usage_tbl.COUNT LOOP
                 -- If there is an entity with error, then flag it and exit.
                 IF p_eam_res_usage_tbl(I).transaction_type is not null and
                    (p_eam_res_usage_tbl(I).wip_entity_id is null or
                     p_eam_res_usage_tbl(I).organization_id is null) then
                   l_other_message := 'EAM_WO_RESU_REC_INVALID';
                   EXIT;
                 END IF;
                 IF p_eam_res_usage_tbl(I).wip_entity_id is not null AND
                    p_eam_res_usage_tbl(I).organization_id is not null
                 THEN
                    l_wip_entity_id   := p_eam_res_usage_tbl(I).wip_entity_id;
                    l_organization_id := p_eam_res_usage_tbl(I).organization_id;
                    EXIT;
                 END IF;
               END LOOP;
               IF l_wip_entity_id is not null or
                  l_other_message is not null then exit; end if;

               FOR I IN 1..p_eam_direct_items_tbl.COUNT LOOP
                 -- If there is an entity with error, then flag it and exit.
                 IF p_eam_direct_items_tbl(I).transaction_type is not null and
                    (p_eam_direct_items_tbl(I).wip_entity_id is null or
                     p_eam_direct_items_tbl(I).organization_id is null) then
                   l_other_message := 'EAM_WO_DI_REC_INVALID';
                   EXIT;
                 END IF;
                 IF p_eam_direct_items_tbl(I).wip_entity_id is not null AND
                    p_eam_direct_items_tbl(I).organization_id is not null
                 THEN
                    l_wip_entity_id   := p_eam_direct_items_tbl(I).wip_entity_id;
                    l_organization_id := p_eam_direct_items_tbl(I).organization_id;
                    EXIT;
                 END IF;
               END LOOP;
               IF l_wip_entity_id is not null or
                  l_other_message is not null then exit; end if;

               FOR I IN 1..p_eam_mat_req_tbl.COUNT LOOP
                 -- If there is an entity with error, then flag it and exit.
                 IF p_eam_mat_req_tbl(I).transaction_type is not null and
                    (p_eam_mat_req_tbl(I).wip_entity_id is null or
                     p_eam_mat_req_tbl(I).organization_id is null) then
                   l_other_message := 'EAM_WO_MAT_REC_INVALID';
                   EXIT;
                 END IF;
                 IF p_eam_mat_req_tbl(I).wip_entity_id is not null AND
                    p_eam_mat_req_tbl(I).organization_id is not null
                 THEN
                    l_wip_entity_id   := p_eam_mat_req_tbl(I).wip_entity_id;
                    l_organization_id := p_eam_mat_req_tbl(I).organization_id;
                    EXIT;
                 END IF;
               END LOOP;

             END LOOP;

             -- If there is no weid even in the child tables, or if one of the
             -- entities had error in them, then return false
             IF (l_wip_entity_id is null or l_other_message is not null) --AND
                 --p_eam_wo_comp_rec.transaction_type IS NULL AND
                 --p_eam_op_comp_tbl.COUNT = 0 AND
                 --p_eam_request_tbl.COUNT = 0)
             then

             x_return_status := 'E';

               l_out_eam_wo_rec            := l_eam_wo_rec;
               l_out_eam_op_tbl            := l_eam_op_tbl;
               l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
               l_out_eam_res_tbl           := l_eam_res_tbl;
               l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
               l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
               l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
               l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
               l_out_eam_direct_items_tbl  := l_eam_direct_items_tbl;

               -- Log the error
               EAM_ERROR_MESSAGE_PVT.Log_Error
                 (  p_eam_wo_rec             => l_eam_wo_rec
                 ,  p_eam_op_tbl             => l_eam_op_tbl
                 ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
                 ,  p_eam_res_tbl            => l_eam_res_tbl
                 ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
                 ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
                 ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
                 ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
                 ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
                 ,  p_mesg_token_tbl         => l_mesg_token_tbl
                 ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
                 ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_ALL
                 ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_BO_LEVEL
                 ,  p_other_message          => l_other_message
                 ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
                 ,  p_other_token_tbl        => l_token_tbl
                 ,  x_eam_wo_rec             => l_out_eam_wo_rec
                 ,  x_eam_op_tbl             => l_out_eam_op_tbl
                 ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
                 ,  x_eam_res_tbl            => l_out_eam_res_tbl
                 ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
                 ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
                 ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
                 ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
                 ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
               );

               l_eam_wo_rec            := l_out_eam_wo_rec;
               l_eam_op_tbl            := l_out_eam_op_tbl;
               l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
               l_eam_res_tbl           := l_out_eam_res_tbl;
               l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
               l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
               l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
               l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
               l_eam_direct_items_tbl  := l_out_eam_direct_items_tbl;

             END IF;

             RETURN;

           ELSE

             l_wip_entity_id   := p_eam_wo_rec.wip_entity_id;
             l_organization_id := p_eam_wo_rec.organization_id;
           END IF;
           -- end - baroy

IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.CHECK_BO_RECORD : Validating OP record'); END IF;

           FOR I IN 1..p_eam_op_tbl.COUNT LOOP
               IF p_eam_op_tbl(I).wip_entity_id is not null AND (
                  p_eam_op_tbl(I).wip_entity_id <> l_wip_entity_id OR
                  p_eam_op_tbl(I).organization_id <> l_organization_id)
               THEN
                  x_return_status := 'E';
                  l_other_message := 'EAM_WO_BO_REC_INVALID';
               END IF;
           END LOOP;

IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.CHECK_BO_RECORD : Validating OPN record'); END IF;

           FOR I IN 1..p_eam_op_network_tbl.COUNT LOOP
               IF p_eam_op_network_tbl(I).wip_entity_id is not null AND (
                  p_eam_op_network_tbl(I).wip_entity_id <> l_wip_entity_id OR
                  p_eam_op_network_tbl(I).organization_id <> l_organization_id)
               THEN
                  x_return_status := 'E';
                  l_other_message := 'EAM_WO_BO_REC_INVALID';
               END IF;
           END LOOP;

IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.CHECK_BO_RECORD : Validating RES record'); END IF;

           FOR I IN 1..p_eam_res_tbl.COUNT LOOP

               IF p_eam_res_tbl(I).wip_entity_id is not null AND (
                  p_eam_res_tbl(I).wip_entity_id <> l_wip_entity_id OR
                  p_eam_res_tbl(I).organization_id <> l_organization_id)
               THEN
	          x_return_status := 'E';
                  l_other_message := 'EAM_WO_BO_REC_INVALID';
               END IF;
           END LOOP;

IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.CHECK_BO_RECORD : Validating RES_INST record'); END IF;

           FOR I IN 1..p_eam_res_inst_tbl.COUNT LOOP
               IF p_eam_res_inst_tbl(I).wip_entity_id is not null AND (
                  p_eam_res_inst_tbl(I).wip_entity_id <> l_wip_entity_id OR
                  p_eam_res_inst_tbl(I).organization_id <> l_organization_id)
               THEN
                  x_return_status := 'E';
                  l_other_message := 'EAM_WO_BO_REC_INVALID';
               END IF;
           END LOOP;

IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.CHECK_BO_RECORD : Validating SUB_RES record'); END IF;

           FOR I IN 1..p_eam_sub_res_tbl.COUNT LOOP
               IF p_eam_sub_res_tbl(I).wip_entity_id is not null AND (
                  p_eam_sub_res_tbl(I).wip_entity_id <> l_wip_entity_id OR
                  p_eam_sub_res_tbl(I).organization_id <> l_organization_id)
               THEN
                  x_return_status := 'E';
                  l_other_message := 'EAM_WO_BO_REC_INVALID';
               END IF;
           END LOOP;

IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.CHECK_BO_RECORD : Validating RES_USAGE record'); END IF;

           FOR I IN 1..p_eam_res_usage_tbl.COUNT LOOP
               IF p_eam_res_usage_tbl(I).wip_entity_id is not null AND (
                  p_eam_res_usage_tbl(I).wip_entity_id <> l_wip_entity_id OR
                  p_eam_res_usage_tbl(I).organization_id <> l_organization_id)
               THEN
                  x_return_status := 'E';
                  l_other_message := 'EAM_WO_BO_REC_INVALID';
               END IF;
           END LOOP;

IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.CHECK_BO_RECORD : Validating MAT_REQ record'); END IF;

           FOR I IN 1..p_eam_mat_req_tbl.COUNT LOOP
               IF p_eam_mat_req_tbl(I).wip_entity_id is not null AND (
                  p_eam_mat_req_tbl(I).wip_entity_id <> l_wip_entity_id OR
                  p_eam_mat_req_tbl(I).organization_id <> l_organization_id)
               THEN
                  x_return_status := 'E';
                  l_other_message := 'EAM_WO_BO_REC_INVALID';
               END IF;
           END LOOP;

IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.CHECK_BO_RECORD : Validating DI record'); END IF;

           FOR I IN 1..p_eam_direct_items_tbl.COUNT LOOP
               IF p_eam_direct_items_tbl(I).wip_entity_id is not null AND (
                  p_eam_direct_items_tbl(I).wip_entity_id <> l_wip_entity_id OR
                  p_eam_direct_items_tbl(I).organization_id <> l_organization_id)
               THEN
                  x_return_status := 'E';
                  l_other_message := 'EAM_WO_BO_REC_INVALID';
               END IF;
           END LOOP;

           IF x_return_status = 'E' THEN
             -- Log the error

             l_out_eam_wo_rec            := l_eam_wo_rec;
             l_out_eam_op_tbl            := l_eam_op_tbl;
             l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
             l_out_eam_res_tbl           := l_eam_res_tbl;
             l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
             l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
             l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
             l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
             l_out_eam_direct_items_tbl  := l_eam_direct_items_tbl;

             EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_wo_rec             => l_eam_wo_rec
               ,  p_eam_op_tbl             => l_eam_op_tbl
               ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  p_eam_res_tbl            => l_eam_res_tbl
               ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
               ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_ALL
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_BO_LEVEL
               ,  p_other_message          => l_other_message
               ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
               ,  p_other_token_tbl        => l_token_tbl
               ,  x_eam_wo_rec             => l_out_eam_wo_rec
               ,  x_eam_op_tbl             => l_out_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_out_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
             );

             l_eam_wo_rec            := l_out_eam_wo_rec;
             l_eam_op_tbl            := l_out_eam_op_tbl;
             l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
             l_eam_res_tbl           := l_out_eam_res_tbl;
             l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
             l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
             l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
             l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
             l_eam_direct_items_tbl  := l_out_eam_direct_items_tbl;

             RETURN;
           END IF;

     -- Add check for work order completion reocrds.Need to add for operation
     -- comlpetions and work/service request records

     IF p_eam_wo_comp_rec.transaction_type IS NOT NULL THEN




	  l_wip_entity_id   := p_eam_wo_comp_rec.wip_entity_id;
          l_organization_id := p_eam_wo_comp_rec.organization_id;

	   l_eam_wo_quality_tbl		:= p_eam_wo_quality_tbl;
	   l_eam_meter_reading_tbl	:= p_eam_meter_reading_tbl;
	   l_eam_wo_comp_rebuild_tbl	:= p_eam_wo_comp_rebuild_tbl;
	   l_eam_wo_comp_mr_read_tbl	:= p_eam_wo_comp_mr_read_tbl;


	  IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.CHECK_BO_RECORD : Validating Quality record'); END IF;

           FOR I IN 1..l_eam_wo_quality_tbl.COUNT LOOP
               IF p_eam_wo_quality_tbl(I).wip_entity_id is not null AND (
                  p_eam_wo_quality_tbl(I).wip_entity_id <> l_wip_entity_id OR
                  p_eam_wo_quality_tbl(I).organization_id <> l_organization_id)
               THEN
                  x_return_status := 'E';
                  l_other_message := 'EAM_WO_BO_REC_INVALID';
               END IF;
           END LOOP;

   	  IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.CHECK_BO_RECORD : Validating Meter record'); END IF;

           FOR I IN 1..l_eam_meter_reading_tbl.COUNT LOOP
               IF p_eam_meter_reading_tbl(I).wip_entity_id is not null AND (
                  p_eam_meter_reading_tbl(I).wip_entity_id <> l_wip_entity_id
                  )
               THEN
                  x_return_status := 'E';
                  l_other_message := 'EAM_WO_BO_REC_INVALID';
               END IF;
           END LOOP;

	   IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.CHECK_BO_RECORD : Validating Counter Properties record'); END IF;

           FOR I IN 1..l_eam_counter_prop_tbl.COUNT LOOP
               IF p_eam_counter_prop_tbl(I).wip_entity_id is not null AND (
                  p_eam_counter_prop_tbl(I).wip_entity_id <> l_wip_entity_id
                  )
               THEN
                  x_return_status := 'E';
                  l_other_message := 'EAM_WO_BO_REC_INVALID';
               END IF;
           END LOOP;


	   IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.CHECK_BO_RECORD : Validating Meter Completion record'); END IF;

           FOR I IN 1..l_eam_wo_comp_rebuild_tbl.COUNT LOOP
               IF p_eam_wo_comp_rebuild_tbl(I).wip_entity_id is not null AND (
                  p_eam_wo_comp_rebuild_tbl(I).wip_entity_id <> l_wip_entity_id OR
                  p_eam_wo_comp_rebuild_tbl(I).organization_id <> l_organization_id)
               THEN
                  x_return_status := 'E';
                  l_other_message := 'EAM_WO_BO_REC_INVALID';
               END IF;
           END LOOP;

	    IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.CHECK_BO_RECORD : Validating Rebuild Completion record'); END IF;

           FOR I IN 1..l_eam_wo_comp_mr_read_tbl.COUNT LOOP
               IF p_eam_wo_comp_mr_read_tbl(I).wip_entity_id is not null AND (
                  p_eam_wo_comp_mr_read_tbl(I).wip_entity_id <> l_wip_entity_id OR
                  p_eam_wo_comp_mr_read_tbl(I).organization_id <> l_organization_id)
               THEN
                  x_return_status := 'E';
                  l_other_message := 'EAM_WO_BO_REC_INVALID';
               END IF;
           END LOOP;

	IF x_return_status = 'E' THEN
	 -- Log the error

             /* l_out_eam_wo_rec            := l_eam_wo_rec;
             l_out_eam_op_tbl            := l_eam_op_tbl;
             l_out_eam_op_network_tbl    := l_eam_op_network_tbl;
             l_out_eam_res_tbl           := l_eam_res_tbl;
             l_out_eam_res_inst_tbl      := l_eam_res_inst_tbl;
             l_out_eam_sub_res_tbl       := l_eam_sub_res_tbl;
             l_out_eam_res_usage_tbl     := l_eam_res_usage_tbl;
             l_out_eam_mat_req_tbl       := l_eam_mat_req_tbl;
             l_out_eam_direct_items_tbl  := l_eam_direct_items_tbl;

             EAM_ERROR_MESSAGE_PVT.Log_Error
               (  p_eam_wo_rec             => l_eam_wo_rec
               ,  p_eam_op_tbl             => l_eam_op_tbl
               ,  p_eam_op_network_tbl     => l_eam_op_network_tbl
               ,  p_eam_res_tbl            => l_eam_res_tbl
               ,  p_eam_res_inst_tbl       => l_eam_res_inst_tbl
               ,  p_eam_sub_res_tbl        => l_eam_sub_res_tbl
               ,  p_eam_res_usage_tbl      => l_eam_res_usage_tbl
               ,  p_eam_mat_req_tbl        => l_eam_mat_req_tbl
               ,  p_eam_direct_items_tbl   => l_eam_direct_items_tbl
               ,  p_mesg_token_tbl         => l_mesg_token_tbl
               ,  p_error_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
               ,  p_error_scope            => EAM_ERROR_MESSAGE_PVT.G_SCOPE_ALL
               ,  p_error_level            => EAM_ERROR_MESSAGE_PVT.G_BO_LEVEL
               ,  p_other_message          => l_other_message
               ,  p_other_status           => EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR
               ,  p_other_token_tbl        => l_token_tbl
               ,  x_eam_wo_rec             => l_out_eam_wo_rec
               ,  x_eam_op_tbl             => l_out_eam_op_tbl
               ,  x_eam_op_network_tbl     => l_out_eam_op_network_tbl
               ,  x_eam_res_tbl            => l_out_eam_res_tbl
               ,  x_eam_res_inst_tbl       => l_out_eam_res_inst_tbl
               ,  x_eam_sub_res_tbl        => l_out_eam_sub_res_tbl
               ,  x_eam_res_usage_tbl      => l_out_eam_res_usage_tbl
               ,  x_eam_mat_req_tbl        => l_out_eam_mat_req_tbl
               ,  x_eam_direct_items_tbl   => l_out_eam_direct_items_tbl
             );

             l_eam_wo_rec            := l_out_eam_wo_rec;
             l_eam_op_tbl            := l_out_eam_op_tbl;
             l_eam_op_network_tbl    := l_out_eam_op_network_tbl;
             l_eam_res_tbl           := l_out_eam_res_tbl;
             l_eam_res_inst_tbl      := l_out_eam_res_inst_tbl;
             l_eam_sub_res_tbl       := l_out_eam_sub_res_tbl;
             l_eam_res_usage_tbl     := l_out_eam_res_usage_tbl;
             l_eam_mat_req_tbl       := l_out_eam_mat_req_tbl;
             l_eam_direct_items_tbl  := l_out_eam_direct_items_tbl; */

             RETURN;
      END IF;
    END IF;  -- End of check for work order completion record


           x_return_status := 'S';
IF EAM_PROCESS_WO_PVT.get_debug = 'Y' then EAM_ERROR_MESSAGE_PVT.write_debug(to_char(sysdate,'DD-MON-YY HH:MI:SS')||' EAM_PROCESS_WO_PUB.CHECK_BO_RECORD : End === Status : '||x_return_status||' ==================='); END IF;
           RETURN;

END CHECK_BO_RECORD;




 PROCEDURE COPY_WORKORDER
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
         , p_commit                  IN  VARCHAR2 := fnd_api.g_false
         , p_wip_entity_id           IN  NUMBER
         , p_organization_id         IN  NUMBER
         , x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         ) IS

	l_eam_wo_rec               EAM_PROCESS_WO_PUB.eam_wo_rec_type;
	l_eam_op_tbl               EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_eam_op_network_tbl       EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_eam_res_tbl              EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_eam_sub_res_tbl	   EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_eam_res_inst_tbl         EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_eam_res_usage_tbl        EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_eam_mat_req_tbl          EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_eam_di_tbl		   EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_eam_wo_comp_rec               EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_eam_wo_quality_tbl            EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl         EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_counter_prop_tbl		EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_eam_wo_comp_rebuild_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl       EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl               EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl               EAM_PROCESS_WO_PUB.eam_request_tbl_type;

	l_out_eam_wo_rec		EAM_PROCESS_WO_PUB.eam_wo_rec_type;
	l_out_eam_op_tbl		EAM_PROCESS_WO_PUB.eam_op_tbl_type;
	l_out_eam_op_network_tbl	EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
	l_out_eam_res_tbl		EAM_PROCESS_WO_PUB.eam_res_tbl_type;
	l_out_eam_res_inst_tbl		EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
	l_out_eam_sub_res_tbl		EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
	l_out_eam_res_usage_tbl		EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
	l_out_eam_mat_req_tbl		EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
	l_out_eam_di_tbl		EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
	l_out_eam_wo_comp_rec           EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_counter_prop_tbl	EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;

	l_return_status			VARCHAR2(1);
	l_msg_count			NUMBER;
	l_output_dir			VARCHAR2(512);
	l_op_count			NUMBER;
	l_eam_op_rec               EAM_PROCESS_WO_PUB.eam_op_rec_type;
	l_eam_op_network_rec       EAM_PROCESS_WO_PUB.eam_op_network_rec_type;
	l_eam_res_rec              EAM_PROCESS_WO_PUB.eam_res_rec_type;
	l_eam_res_inst_rec	   EAM_PROCESS_WO_PUB.eam_res_inst_rec_type;
	l_eam_res_usage_rec        EAM_PROCESS_WO_PUB.eam_res_usage_rec_type;
	l_eam_mat_req_rec          EAM_PROCESS_WO_PUB.eam_mat_req_rec_type;
	l_eam_di_rec		   EAM_PROCESS_WO_PUB.eam_direct_items_rec_type;

	TYPE wkorder_op_tbl_type            is TABLE OF number INDEX BY BINARY_INTEGER;
	TYPE wkorder_op_netwrk_tbl_type     is TABLE OF number INDEX BY BINARY_INTEGER;

	l_wkorder_op_tbl	     wkorder_op_tbl_type;
	l_wkorder_op_netwrk_tbl	     wkorder_op_netwrk_tbl_type;

	l_op_index		NUMBER;
	l_op_res_index		NUMBER;
	l_op_res_inst_index	NUMBER;
	l_op_network_index	NUMBER;
	l_op_material_index	NUMBER;
	l_op_direct_item_index	NUMBER;

	l_old_activity_id	NUMBER;

	CURSOR l_operations is
	select
		wip_entity_id		,
		organization_id		,
		operation_seq_num 	,
		standard_operation_id	,
		department_id         	,
		operation_sequence_id 	,
		description           	,
		minimum_transfer_quantity	,
		count_point_type      ,
		backflush_flag        ,
		shutdown_type         ,
		first_unit_start_date             ,
		last_unit_completion_date        ,
		attribute_category    ,
		attribute1            ,
		attribute2            ,
		attribute3            ,
		attribute4            ,
		attribute5            ,
		attribute6            ,
		attribute7            ,
		attribute8            ,
		attribute9            ,
		attribute10           ,
		attribute11           ,
		attribute12           ,
		attribute13           ,
		attribute14           ,
		attribute15           ,
		long_description
	from wip_operations
	where wip_entity_id = p_wip_entity_id;

	CURSOR l_op_resources is
	select
		wor.wip_entity_id		    ,
		wor.organization_id		    ,
		wor.operation_seq_num               ,
		wor.resource_seq_num                ,
		wor.resource_id                     ,
		wor.uom_code                        ,
		wor.basis_type                      ,
		wor.usage_rate_or_amount            ,
		wor.activity_id                     ,
		wor.scheduled_flag                  ,
		wor.firm_flag			    ,
		wor.assigned_units                  ,
		wor.maximum_assigned_units          ,
		wor.autocharge_type                 ,
		wor.standard_rate_flag              ,
		wor.applied_resource_units          ,
		wor.applied_resource_value          ,
		wor.start_date                      ,
		wor.completion_date                 ,
		wor.schedule_seq_num                ,
		wor.substitute_group_num            ,
		wor.replacement_group_num           ,
		wor.attribute_category              ,
		wor.attribute1                      ,
		wor.attribute2                      ,
		wor.attribute3                      ,
		wor.attribute4                      ,
		wor.attribute5                      ,
		wor.attribute6                      ,
		wor.attribute7                      ,
		wor.attribute8                      ,
		wor.attribute9                      ,
		wor.attribute10                     ,
		wor.attribute11                     ,
		wor.attribute12                     ,
		wor.attribute13                     ,
		wor.attribute14                     ,
		wor.attribute15                     ,
		wor.department_id
	 from   wip_operations wo,
	        wip_operation_resources wor
	 where wo.wip_entity_id = p_wip_entity_id
	   and wor.wip_entity_id = p_wip_entity_id
	   and wo.operation_seq_num = wor.operation_seq_num;

	 CURSOR l_resource_instances is
	 select
		wori.wip_entity_id       	,
		wori.organization_id     	,
		wori.operation_seq_num   	,
		wori.resource_seq_num    	,
		wori.instance_id         	,
		wori.serial_number      	,
		wori.start_date       		,
		wori.completion_date     	,
		wori.batch_id
	 from  wip_op_resource_instances wori,
	       wip_operation_resources wor
	 where wor.wip_entity_id = p_wip_entity_id
	   and wori.wip_entity_id = p_wip_entity_id
	   and wori.operation_seq_num = wor.operation_seq_num
	   and wori.resource_seq_num = wor.resource_seq_num;

	CURSOR l_op_network IS
		SELECT
			wip_entity_id		 ,
			organization_id		 ,
			prior_operation          ,
			next_operation		 ,
			attribute_category       ,
			attribute1               ,
			attribute2               ,
			attribute3               ,
			attribute4               ,
			attribute5               ,
			attribute6               ,
			attribute7               ,
			attribute8               ,
			attribute9               ,
			attribute10              ,
			attribute11              ,
			attribute12              ,
			attribute13              ,
			attribute14              ,
			attribute15
		FROM
			wip_operation_networks
	       WHERE    wip_entity_id = p_wip_entity_id;

		 CURSOR l_op_material IS
			SELECT
			wip_entity_id              ,
			organization_id            ,
			operation_seq_num          ,
			inventory_item_id          ,
			quantity_per_assembly      ,
			department_id              ,
			wip_supply_type            ,
			date_required              ,
			required_quantity          ,
			released_quantity          ,
			quantity_issued            ,
			supply_subinventory        ,
			supply_locator_id          ,
			mrp_net_flag               ,
			mps_required_quantity      ,
			mps_date_required          ,
			component_sequence_id      ,
			comments                   ,
			attribute_category         ,
			attribute1                 ,
			attribute2                 ,
			attribute3                 ,
			attribute4                 ,
			attribute5                 ,
			attribute6                 ,
			attribute7                 ,
			attribute8                 ,
			attribute9                 ,
			attribute10                ,
			attribute11                ,
			attribute12                ,
			attribute13                ,
			attribute14                ,
			attribute15                ,
			auto_request_material      ,
			suggested_vendor_name      ,
			vendor_id                  ,
			unit_price
		  FROM  wip_requirement_operations wro
		  WHERE wro.wip_entity_id = p_wip_entity_id
		    AND wro.organization_id = p_organization_id;

		    CURSOR l_op_direct_item IS
			SELECT
			description                    ,
			purchasing_category_id         ,
			direct_item_sequence_id        ,
			operation_seq_num              ,
			department_id                  ,
			wip_entity_id                  ,
			organization_id                ,
			suggested_vendor_name	       ,
			suggested_vendor_id            ,
			suggested_vendor_site	       ,
			suggested_vendor_site_id       ,
			suggested_vendor_contact       ,
			suggested_vendor_contact_id    ,
			suggested_vendor_phone         ,
			suggested_vendor_item_num      ,
			unit_price                     ,
			auto_request_material	       ,
			required_quantity              ,
			uom                            ,
			need_by_date                   ,
			attribute_category             ,
			attribute1                     ,
			attribute2                     ,
			attribute3                     ,
			attribute4                     ,
			attribute5                     ,
			attribute6                     ,
			attribute7                     ,
			attribute8                     ,
			attribute9                     ,
			attribute10                    ,
			attribute11		       ,
			attribute12                    ,
			attribute13                    ,
			attribute14                    ,
			attribute15
		FROM    wip_eam_direct_items wedi
                WHERE   wedi.wip_entity_id = p_wip_entity_id
                AND     wedi.organization_id = p_organization_id;

	 BEGIN

	l_op_index		:=1;
	l_op_res_index		:=1;
	l_op_res_inst_index	:=1;
	l_op_network_index	:=1;
	l_op_material_index	:=1;
	l_op_direct_item_index	:=1;

 -- Get Work Order Header information
	EAM_WO_UTILITY_PVT.Query_Row(
		p_wip_entity_id     => p_wip_entity_id ,
		p_organization_id   => p_organization_id,
		x_eam_wo_rec        => l_eam_wo_rec,
		x_Return_status     => l_Return_status
	);

	l_eam_wo_rec.header_id			:= 1;
	l_eam_wo_rec.batch_id			:= 1;
	l_eam_wo_rec.wip_entity_name		:= null;
	l_eam_wo_rec.wip_entity_id		:= null;


	l_old_activity_id			:= l_eam_wo_rec.asset_activity_id;
	l_eam_wo_rec.asset_activity_id		:= null;
	l_eam_wo_rec.transaction_type		:= EAM_PROCESS_WO_PVT.G_OPR_CREATE;
	l_eam_wo_rec.return_status		:= null;

	l_eam_wo_rec.date_released		:= null;
	l_eam_wo_rec.cycle_id			:= null;
	l_eam_wo_rec.seq_id			:= null;
	l_eam_wo_rec.pm_schedule_id		:= null;
	l_eam_wo_rec.parent_wip_entity_id	:= null;
	l_eam_wo_rec.pending_flag               := null;
	l_eam_wo_rec.status_type                := 17;  --draft
	l_eam_wo_rec.user_defined_status_id     := 17;  --draft

	FOR opRec IN l_operations LOOP

		l_eam_op_rec.header_id		:= 1;
		l_eam_op_rec.batch_id		:= 1;
		l_eam_op_rec.wip_entity_id	:= null;
		l_eam_op_rec.transaction_type	:= EAM_PROCESS_WO_PVT.G_OPR_CREATE;
		l_eam_op_rec.return_status	:= null;

		l_eam_op_rec.organization_id          := opRec.organization_id;
		l_eam_op_rec.operation_seq_num        := opRec.operation_seq_num;
		l_eam_op_rec.department_id            := opRec.department_id;
		l_eam_op_rec.operation_sequence_id    := opRec.operation_sequence_id;
		l_eam_op_rec.description              := opRec.description;
		l_eam_op_rec.minimum_transfer_quantity:= opRec.minimum_transfer_quantity;
		l_eam_op_rec.count_point_type         := opRec.count_point_type;
		l_eam_op_rec.backflush_flag           := opRec.backflush_flag;
		l_eam_op_rec.shutdown_type            := opRec.shutdown_type;
		l_eam_op_rec.start_date               := opRec.first_unit_start_date;
		l_eam_op_rec.completion_date          := opRec.last_unit_completion_date;
		l_eam_op_rec.attribute_category       := opRec.attribute_category;
		l_eam_op_rec.attribute1               := opRec.attribute1;
		l_eam_op_rec.attribute2               := opRec.attribute2;
		l_eam_op_rec.attribute3               := opRec.attribute3;
		l_eam_op_rec.attribute4               := opRec.attribute4;
		l_eam_op_rec.attribute5               := opRec.attribute5;
		l_eam_op_rec.attribute6               := opRec.attribute6;
		l_eam_op_rec.attribute7               := opRec.attribute7;
		l_eam_op_rec.attribute8               := opRec.attribute8;
		l_eam_op_rec.attribute9               := opRec.attribute9;
		l_eam_op_rec.attribute10              := opRec.attribute10;
		l_eam_op_rec.attribute11              := opRec.attribute11;
		l_eam_op_rec.attribute12              := opRec.attribute12;
		l_eam_op_rec.attribute13              := opRec.attribute13;
		l_eam_op_rec.attribute14              := opRec.attribute14;
		l_eam_op_rec.attribute15              := opRec.attribute15;
		l_eam_op_rec.long_description         := opRec.long_description;

		l_eam_op_tbl(l_op_index) := l_eam_op_rec;

		l_op_index := l_op_index +1;
	END LOOP;

	FOR opRes IN l_op_resources LOOP
		l_eam_res_rec.header_id		:= 1;
		l_eam_res_rec.batch_id		:= 1;
		l_eam_res_rec.wip_entity_id	:= null;
		l_eam_res_rec.transaction_type	:= EAM_PROCESS_WO_PVT.G_OPR_CREATE;
		l_eam_res_rec.return_status	:= null;

		l_eam_res_rec.organization_id             := opRes.organization_id        ;
		l_eam_res_rec.operation_seq_num           := opRes.operation_seq_num      ;
		l_eam_res_rec.resource_seq_num            := opRes.resource_seq_num       ;
		l_eam_res_rec.resource_id                 := opRes.resource_id            ;
		l_eam_res_rec.uom_code                    := opRes.uom_code               ;
		l_eam_res_rec.basis_type                  := opRes.basis_type             ;
		l_eam_res_rec.usage_rate_or_amount        := opRes.usage_rate_or_amount   ;
		l_eam_res_rec.activity_id                 := opRes.activity_id            ;
		l_eam_res_rec.scheduled_flag              := opRes.scheduled_flag         ;
		l_eam_res_rec.firm_flag			  := opRes.firm_flag		  ;
		l_eam_res_rec.assigned_units              := opRes.assigned_units         ;
		l_eam_res_rec.maximum_assigned_units      := opRes.maximum_assigned_units ;
		l_eam_res_rec.autocharge_type             := opRes.autocharge_type        ;
		l_eam_res_rec.standard_rate_flag          := opRes.standard_rate_flag     ;
		l_eam_res_rec.start_date                  := opRes.start_date             ;
		l_eam_res_rec.completion_date             := opRes.completion_date        ;
		l_eam_res_rec.schedule_seq_num            := opRes.schedule_seq_num       ;
		l_eam_res_rec.substitute_group_num        := opRes.substitute_group_num   ;
		l_eam_res_rec.replacement_group_num       := opRes.replacement_group_num  ;
		l_eam_res_rec.attribute_category          := opRes.attribute_category     ;
		l_eam_res_rec.attribute1                  := opRes.attribute1             ;
		l_eam_res_rec.attribute2                  := opRes.attribute2             ;
		l_eam_res_rec.attribute3                  := opRes.attribute3             ;
		l_eam_res_rec.attribute4                  := opRes.attribute4             ;
		l_eam_res_rec.attribute5                  := opRes.attribute5             ;
		l_eam_res_rec.attribute6                  := opRes.attribute6             ;
		l_eam_res_rec.attribute7                  := opRes.attribute7             ;
		l_eam_res_rec.attribute8                  := opRes.attribute8             ;
		l_eam_res_rec.attribute9                  := opRes.attribute9             ;
		l_eam_res_rec.attribute10                 := opRes.attribute10            ;
		l_eam_res_rec.attribute11                 := opRes.attribute11            ;
		l_eam_res_rec.attribute12                 := opRes.attribute12            ;
		l_eam_res_rec.attribute13                 := opRes.attribute13            ;
		l_eam_res_rec.attribute14                 := opRes.attribute14            ;
		l_eam_res_rec.attribute15                 := opRes.attribute15            ;
		l_eam_res_rec.department_id               := opRes.department_id          ;

		l_eam_res_tbl(l_op_res_index) := l_eam_res_rec;

		l_op_res_index := l_op_res_index +1;

	END LOOP;

	FOR opResInst IN l_resource_instances LOOP

		l_eam_res_inst_rec.header_id		:= 1;
		l_eam_res_inst_rec.batch_id		:= 1;
		l_eam_res_inst_rec.wip_entity_id	:= null;
		l_eam_res_inst_rec.transaction_type	:= EAM_PROCESS_WO_PVT.G_OPR_CREATE;
		l_eam_res_inst_rec.return_status	:= null;

		l_eam_res_inst_rec.organization_id     := opResInst.organization_id    ;
		l_eam_res_inst_rec.operation_seq_num   := opResInst.operation_seq_num  ;
		l_eam_res_inst_rec.resource_seq_num    := opResInst.resource_seq_num   ;
		l_eam_res_inst_rec.instance_id         := opResInst.instance_id        ;
		l_eam_res_inst_rec.serial_number       := opResInst.serial_number      ;
		l_eam_res_inst_rec.start_date          := opResInst.start_date         ;
		l_eam_res_inst_rec.completion_date     := opResInst.completion_date    ;
		l_eam_res_inst_rec.top_level_batch_id  := opResInst.batch_id ;

		l_eam_res_inst_tbl(l_op_res_inst_index) := l_eam_res_inst_rec;

		l_op_res_inst_index := l_op_res_inst_index +1;
	END LOOP;


 	FOR opNetwork IN l_op_network LOOP

		l_eam_op_network_rec.header_id := 1;
		l_eam_op_network_rec.batch_id := 1;
		l_eam_op_network_rec.wip_entity_id := null;
		l_eam_op_network_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
		l_eam_op_network_rec.return_status	:= null;

		l_eam_op_network_rec.organization_id     := opNetwork.organization_id     ;
		l_eam_op_network_rec.prior_operation     := opNetwork.prior_operation     ;
		l_eam_op_network_rec.next_operation      := opNetwork.next_operation      ;
		l_eam_op_network_rec.attribute_category  := opNetwork.attribute_category  ;
		l_eam_op_network_rec.attribute1          := opNetwork.attribute1          ;
		l_eam_op_network_rec.attribute2          := opNetwork.attribute2          ;
		l_eam_op_network_rec.attribute3          := opNetwork.attribute3          ;
		l_eam_op_network_rec.attribute4          := opNetwork.attribute4          ;
		l_eam_op_network_rec.attribute5          := opNetwork.attribute5          ;
		l_eam_op_network_rec.attribute6          := opNetwork.attribute6          ;
		l_eam_op_network_rec.attribute7          := opNetwork.attribute7          ;
		l_eam_op_network_rec.attribute8          := opNetwork.attribute8          ;
		l_eam_op_network_rec.attribute9          := opNetwork.attribute9          ;
		l_eam_op_network_rec.attribute10         := opNetwork.attribute10         ;
		l_eam_op_network_rec.attribute11         := opNetwork.attribute11         ;
		l_eam_op_network_rec.attribute12         := opNetwork.attribute12         ;
		l_eam_op_network_rec.attribute13         := opNetwork.attribute13         ;
		l_eam_op_network_rec.attribute14         := opNetwork.attribute14         ;
		l_eam_op_network_rec.attribute15         := opNetwork.attribute15         ;

		l_eam_op_network_tbl(l_op_network_index) := l_eam_op_network_rec;

		l_op_network_index := l_op_network_index +1;

	END LOOP;

 	FOR opMaterial IN l_op_material LOOP

		l_eam_mat_req_rec.header_id := 1;
		l_eam_mat_req_rec.batch_id := 1;
		l_eam_mat_req_rec.wip_entity_id := null;
		l_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
		l_eam_mat_req_rec.return_status	:= null;

		l_eam_mat_req_rec.organization_id          := opMaterial.organization_id        ;
		l_eam_mat_req_rec.operation_seq_num        := opMaterial.operation_seq_num      ;
		l_eam_mat_req_rec.inventory_item_id        := opMaterial.inventory_item_id      ;
		l_eam_mat_req_rec.quantity_per_assembly    := opMaterial.quantity_per_assembly  ;
		l_eam_mat_req_rec.department_id            := opMaterial.department_id          ;
		l_eam_mat_req_rec.wip_supply_type          := opMaterial.wip_supply_type        ;
		l_eam_mat_req_rec.date_required            := opMaterial.date_required          ;
		l_eam_mat_req_rec.required_quantity        := opMaterial.required_quantity      ;
		l_eam_mat_req_rec.supply_subinventory      := opMaterial.supply_subinventory    ;
		l_eam_mat_req_rec.supply_locator_id        := opMaterial.supply_locator_id      ;
		l_eam_mat_req_rec.mrp_net_flag             := opMaterial.mrp_net_flag           ;
		l_eam_mat_req_rec.component_sequence_id    := opMaterial.component_sequence_id  ;
		l_eam_mat_req_rec.comments                 := opMaterial.comments               ;
		l_eam_mat_req_rec.attribute_category       := opMaterial.attribute_category     ;
		l_eam_mat_req_rec.attribute1               := opMaterial.attribute1             ;
		l_eam_mat_req_rec.attribute2               := opMaterial.attribute2             ;
		l_eam_mat_req_rec.attribute3               := opMaterial.attribute3             ;
		l_eam_mat_req_rec.attribute4               := opMaterial.attribute4             ;
		l_eam_mat_req_rec.attribute5               := opMaterial.attribute5             ;
		l_eam_mat_req_rec.attribute6               := opMaterial.attribute6             ;
		l_eam_mat_req_rec.attribute7               := opMaterial.attribute7             ;
		l_eam_mat_req_rec.attribute8               := opMaterial.attribute8             ;
		l_eam_mat_req_rec.attribute9               := opMaterial.attribute9             ;
		l_eam_mat_req_rec.attribute10              := opMaterial.attribute10            ;
		l_eam_mat_req_rec.attribute11              := opMaterial.attribute11            ;
		l_eam_mat_req_rec.attribute12              := opMaterial.attribute12            ;
		l_eam_mat_req_rec.attribute13              := opMaterial.attribute13            ;
		l_eam_mat_req_rec.attribute14              := opMaterial.attribute14            ;
		l_eam_mat_req_rec.attribute15              := opMaterial.attribute15            ;
		l_eam_mat_req_rec.auto_request_material    := opMaterial.auto_request_material  ;
		l_eam_mat_req_rec.suggested_vendor_name    := opMaterial.suggested_vendor_name  ;
		l_eam_mat_req_rec.vendor_id                := opMaterial.vendor_id              ;
		l_eam_mat_req_rec.unit_price               := opMaterial.unit_price             ;

		l_eam_mat_req_tbl(l_op_material_index) := l_eam_mat_req_rec;

		l_op_material_index := l_op_material_index +1;
	END LOOP;

	FOR opDirectItem IN l_op_direct_item LOOP

		l_eam_di_rec.header_id := 1;
		l_eam_di_rec.batch_id := 1;
		l_eam_di_rec.wip_entity_id := null;
		l_eam_di_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
		l_eam_di_rec.return_status	:= null;

		l_eam_di_rec.description                  := opDirectItem.description                  ;
		l_eam_di_rec.purchasing_category_id       := opDirectItem.purchasing_category_id       ;
		l_eam_di_rec.operation_seq_num            := opDirectItem.operation_seq_num            ;
		l_eam_di_rec.department_id                := opDirectItem.department_id                ;
		l_eam_di_rec.organization_id              := opDirectItem.organization_id              ;
		l_eam_di_rec.suggested_vendor_name	  := opDirectItem.suggested_vendor_name	  ;
		l_eam_di_rec.suggested_vendor_id          := opDirectItem.suggested_vendor_id          ;
		l_eam_di_rec.suggested_vendor_site	  := opDirectItem.suggested_vendor_site	  ;
		l_eam_di_rec.suggested_vendor_site_id     := opDirectItem.suggested_vendor_site_id     ;
		l_eam_di_rec.suggested_vendor_contact     := opDirectItem.suggested_vendor_contact     ;
		l_eam_di_rec.suggested_vendor_contact_id  := opDirectItem.suggested_vendor_contact_id  ;
		l_eam_di_rec.suggested_vendor_phone       := opDirectItem.suggested_vendor_phone       ;
		l_eam_di_rec.suggested_vendor_item_num    := opDirectItem.suggested_vendor_item_num    ;
		l_eam_di_rec.unit_price                   := opDirectItem.unit_price                   ;
		l_eam_di_rec.auto_request_material	  := opDirectItem.auto_request_material	  ;
		l_eam_di_rec.required_quantity            := opDirectItem.required_quantity            ;
		l_eam_di_rec.uom                          := opDirectItem.uom                          ;
		l_eam_di_rec.need_by_date                 := opDirectItem.need_by_date                 ;
		l_eam_di_rec.attribute_category           := opDirectItem.attribute_category           ;
		l_eam_di_rec.attribute1                   := opDirectItem.attribute1                   ;
		l_eam_di_rec.attribute2                   := opDirectItem.attribute2                   ;
		l_eam_di_rec.attribute3                   := opDirectItem.attribute3                   ;
		l_eam_di_rec.attribute4                   := opDirectItem.attribute4                   ;
		l_eam_di_rec.attribute5                   := opDirectItem.attribute5                   ;
		l_eam_di_rec.attribute6                   := opDirectItem.attribute6                   ;
		l_eam_di_rec.attribute7                   := opDirectItem.attribute7                   ;
		l_eam_di_rec.attribute8                   := opDirectItem.attribute8                   ;
		l_eam_di_rec.attribute9                   := opDirectItem.attribute9                   ;
		l_eam_di_rec.attribute10                  := opDirectItem.attribute10                  ;
		l_eam_di_rec.attribute11                  := opDirectItem.attribute11                  ;
		l_eam_di_rec.attribute12                  := opDirectItem.attribute12                  ;
		l_eam_di_rec.attribute13                  := opDirectItem.attribute13                  ;
		l_eam_di_rec.attribute14                  := opDirectItem.attribute14                  ;
		l_eam_di_rec.attribute15                  := opDirectItem.attribute15                  ;

		l_eam_di_tbl(l_op_direct_item_index) := l_eam_di_rec;

		l_op_direct_item_index := l_op_direct_item_index +1;
	END LOOP;

      EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

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
                                   , p_eam_wo_comp_rec         => l_eam_wo_comp_rec
                                   , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
                                   , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
		 	           , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
                                   , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
                                   , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
                                   , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
                                   , p_eam_request_tbl         => l_eam_request_tbl
                                   , x_eam_wo_rec              => l_out_eam_wo_rec
                                   , x_eam_op_tbl              => l_out_eam_op_tbl
                                   , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
                                   , x_eam_res_tbl             => l_out_eam_res_tbl
                                   , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
                                   , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
                                   , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
                                   , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
                                   , x_eam_direct_items_tbl    => l_out_eam_di_tbl
                                   , x_eam_wo_comp_rec         => l_out_eam_wo_comp_rec
                                   , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
                                   , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
			           , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
                                   , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
                                   , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
                                   , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
                                   , x_eam_request_tbl         => l_out_eam_request_tbl
                                   , x_return_status           => x_return_status
                                   , x_msg_count               => x_msg_count
                                   , p_debug                   =>  NVL(fnd_profile.value('EAM_DEBUG'), 'N')
                                   , p_debug_filename          => 'CopyWorkOrder.log'
                                   , p_output_dir              => l_output_dir
                                   , p_debug_file_mode         => 'w'
                               );

	update wip_discrete_jobs
	   set primary_item_id = l_old_activity_id
	 where wip_entity_id = l_out_eam_wo_rec.wip_entity_id;

       	update wip_entities
	   set primary_item_id = l_old_activity_id
	 where wip_entity_id = l_out_eam_wo_rec.wip_entity_id; /*added for bug 9974953*/

	 update wip_operations wo
	    set STANDARD_OPERATION_ID = ( select STANDARD_OPERATION_ID from wip_operations wo1
					   where wo.OPERATION_SEQ_NUM = wo1.OPERATION_SEQ_NUM
					   and wo1.wip_entity_id = p_wip_entity_id
					   )
	    where wip_entity_id = l_out_eam_wo_rec.wip_entity_id;

	l_out_eam_wo_rec.asset_activity_id := l_old_activity_id;

	x_eam_wo_rec		:=	l_out_eam_wo_rec;
	x_eam_op_tbl            :=	l_out_eam_op_tbl;
	x_eam_op_network_tbl    :=	l_out_eam_op_network_tbl;
	x_eam_res_tbl           :=	l_out_eam_res_tbl;
	x_eam_res_inst_tbl      :=	l_out_eam_res_inst_tbl;
	x_eam_res_usage_tbl     :=	l_out_eam_res_usage_tbl;
	x_eam_mat_req_tbl       :=	l_out_eam_mat_req_tbl;
	x_eam_direct_items_tbl  :=	l_out_eam_di_tbl;

	 END COPY_WORKORDER;





	     /********************************************************************
    * Procedure: Process_WO
    * Parameters IN:
    *         EAM Work Order column record
    *         Operation column table
    *         Operation Networks column Table
    *         Resource column Table
    *         Substitute Resource column table
    *         Material Requirements column table
    *         Direct Items column table
    * Parameters OUT:
    *         EAM Work Order column record
    *         Operation column table
    *         Operation Networks column Table
    *         Resource column Table
    *         Substitute Resource column table
    *         Material Requirements column table
    *         Direct Items column table
    * Purpose:
    *         This procedure is the driving procedure of the EAM
    *         business Obect. It will verify the integrity of the
    *         business object and will call the private API which
    *         further drive the business object to perform business
    *         logic validations.
    *********************************************************************/

      PROCEDURE PROCESS_WO
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_commit                  IN  VARCHAR2 := 'N'
         , p_eam_wo_rec              IN EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , p_eam_op_tbl              IN EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_res_usage_tbl       IN EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , p_eam_mat_req_tbl         IN EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl    IN EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'EAM_WO_DEBUG.log'
         , p_debug_file_mode         IN  VARCHAR2 := 'w'
         )
	 IS


	l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
 	l_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;

   	l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
 	l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;

BEGIN
	EAM_PROCESS_WO_PUB.PROCESS_WO(
		  p_bo_identifier		=> p_bo_identifier
		, p_api_version_number		=> p_api_version_number
		, p_init_msg_list		=> p_init_msg_list
		, p_commit			=> p_commit
		, p_eam_wo_rec			=> p_eam_wo_rec
		, p_eam_op_tbl			=> p_eam_op_tbl
		, p_eam_op_network_tbl		=> p_eam_op_network_tbl
		, p_eam_res_tbl			=> p_eam_res_tbl
		, p_eam_res_inst_tbl		=> p_eam_res_inst_tbl
		, p_eam_sub_res_tbl		=> p_eam_sub_res_tbl
		, p_eam_res_usage_tbl		=> p_eam_res_usage_tbl
		, p_eam_mat_req_tbl		=> p_eam_mat_req_tbl
		, p_eam_direct_items_tbl	=> p_eam_direct_items_tbl
		, p_eam_wo_comp_rec		=> l_eam_wo_comp_rec
		, p_eam_wo_quality_tbl		=> l_eam_wo_quality_tbl
		, p_eam_meter_reading_tbl	=> l_eam_meter_reading_tbl
		, p_eam_counter_prop_tbl	=> l_eam_counter_prop_tbl
		, p_eam_wo_comp_rebuild_tbl	=> l_eam_wo_comp_rebuild_tbl
		, p_eam_wo_comp_mr_read_tbl	=> l_eam_wo_comp_mr_read_tbl
		, p_eam_op_comp_tbl		=> l_eam_op_comp_tbl
		, p_eam_request_tbl		=> l_eam_request_tbl
		, x_eam_wo_rec			=> x_eam_wo_rec
		, x_eam_op_tbl			=> x_eam_op_tbl
		, x_eam_op_network_tbl		=> x_eam_op_network_tbl
		, x_eam_res_tbl			=> x_eam_res_tbl
		, x_eam_res_inst_tbl		=> x_eam_res_inst_tbl
		, x_eam_sub_res_tbl		=> x_eam_sub_res_tbl
		, x_eam_res_usage_tbl		=> x_eam_res_usage_tbl
		, x_eam_mat_req_tbl		=> x_eam_mat_req_tbl
		, x_eam_direct_items_tbl	=> x_eam_direct_items_tbl
		, x_eam_wo_comp_rec		=> l_out_eam_wo_comp_rec
		, x_eam_wo_quality_tbl		=> l_out_eam_wo_quality_tbl
		, x_eam_meter_reading_tbl	=> l_out_eam_meter_reading_tbl
		, x_eam_counter_prop_tbl	=> l_out_eam_counter_prop_tbl
		, x_eam_wo_comp_rebuild_tbl	=> l_out_eam_wo_comp_rebuild_tbl
		, x_eam_wo_comp_mr_read_tbl	=> l_out_eam_wo_comp_mr_read_tbl
		, x_eam_op_comp_tbl		=> l_out_eam_op_comp_tbl
		, x_eam_request_tbl		=> l_out_eam_request_tbl
		, x_return_status		=> x_return_status
		, x_msg_count			=> x_msg_count
		, p_debug			=> p_debug
		, p_output_dir			=> p_output_dir
		, p_debug_filename		=> p_debug_filename
		, p_debug_file_mode		=> p_debug_file_mode

	);


END PROCESS_WO;





PROCEDURE PROCESS_MASTER_CHILD_WO
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_eam_wo_relations_tbl    IN  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type
         , p_eam_wo_tbl              IN  EAM_PROCESS_WO_PUB.eam_wo_tbl_type
         , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_eam_wo_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_tbl_type
         , x_eam_wo_relations_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_commit                  IN  VARCHAR2 := 'N'
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'EAM_WO_DEBUG.log'
         , p_debug_file_mode         IN  VARCHAR2 := 'w'
         ) IS

        l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;

	l_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;

        l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;

	l_out_eam_wo_comp_rec         EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
	l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
	l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
	l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;

BEGIN
	 EAM_PROCESS_WO_PUB.PROCESS_MASTER_CHILD_WO
	(   p_bo_identifier			=> p_bo_identifier
	  , p_api_version_number		=> p_api_version_number
	  , p_init_msg_list			=> p_init_msg_list
	  , p_eam_wo_relations_tbl		=> p_eam_wo_relations_tbl
	  , p_eam_wo_tbl			=> p_eam_wo_tbl
	  , p_eam_op_tbl			=> p_eam_op_tbl
	  , p_eam_op_network_tbl		=> p_eam_op_network_tbl
	  , p_eam_res_tbl			=> p_eam_res_tbl
	  , p_eam_res_inst_tbl			=> p_eam_res_inst_tbl
	  , p_eam_sub_res_tbl			=> p_eam_sub_res_tbl
	  , p_eam_mat_req_tbl			=> p_eam_mat_req_tbl
	  , p_eam_direct_items_tbl		=> p_eam_direct_items_tbl
	  , p_eam_res_usage_tbl			=> l_eam_res_usage_tbl
	  , p_eam_wo_comp_tbl			=> l_eam_wo_comp_tbl
	  , p_eam_wo_quality_tbl      		=> l_eam_wo_quality_tbl
	  , p_eam_meter_reading_tbl   		=> l_eam_meter_reading_tbl
	  , p_eam_counter_prop_tbl    		=> l_eam_counter_prop_tbl
	  , p_eam_wo_comp_rebuild_tbl 		=> l_eam_wo_comp_rebuild_tbl
	  , p_eam_wo_comp_mr_read_tbl 		=> l_eam_wo_comp_mr_read_tbl
	  , p_eam_op_comp_tbl         		=> l_eam_op_comp_tbl
	  , p_eam_request_tbl         		=> l_eam_request_tbl
	  , x_eam_wo_tbl              		=> x_eam_wo_tbl
	  , x_eam_wo_relations_tbl    		=> x_eam_wo_relations_tbl
	  , x_eam_op_tbl              		=> x_eam_op_tbl
	  , x_eam_op_network_tbl      		=> x_eam_op_network_tbl
	  , x_eam_res_tbl             		=> x_eam_res_tbl
	  , x_eam_res_inst_tbl			=> x_eam_res_inst_tbl
	  , x_eam_sub_res_tbl         		=> x_eam_sub_res_tbl
	  , x_eam_mat_req_tbl         		=> x_eam_mat_req_tbl
	  , x_eam_direct_items_tbl    		=> x_eam_direct_items_tbl
	  , x_eam_res_usage_tbl       		=> l_out_eam_res_usage_tbl
	  , x_eam_wo_comp_tbl         		=> l_out_eam_wo_comp_tbl
	  , x_eam_wo_quality_tbl      		=> l_out_eam_wo_quality_tbl
	  , x_eam_meter_reading_tbl   		=> l_out_eam_meter_reading_tbl
	  , x_eam_counter_prop_tbl    		=> l_out_eam_counter_prop_tbl
	  , x_eam_wo_comp_rebuild_tbl 		=> l_out_eam_wo_comp_rebuild_tbl
	  , x_eam_wo_comp_mr_read_tbl 		=> l_out_eam_wo_comp_mr_read_tbl
	  , x_eam_op_comp_tbl         		=> l_out_eam_op_comp_tbl
	  , x_eam_request_tbl         		=> l_out_eam_request_tbl
	  , x_return_status			=> x_return_status
	  , x_msg_count               		=> x_msg_count
	  , p_commit                  		=> p_commit
	  , p_debug                   		=> p_debug
	  , p_output_dir              		=> p_output_dir
	  , p_debug_filename          		=> p_debug_filename
	  , p_debug_file_mode         		=> p_debug_file_mode
	);


END PROCESS_MASTER_CHILD_WO;


/* This procedure is used to make an entry in wip_eam_direct_items
when a Purchase Requisition/Purchase Order is created  for description direct items in
Purchasing using forms.This procedure is called from purchasing code.
Bug 8450377
*/

PROCEDURE UPDATE_WO_ADD_DES_DIR_ITEM
        (  p_wip_entity_id                IN  NUMBER
         , p_operation_seq_num            IN  NUMBER
         , p_inventory_item_id            IN  NUMBER
         , p_description                  IN  VARCHAR2
         , p_organization_id              IN  NUMBER
         , p_purchasing_category_id       IN  NUMBER
         , p_suggested_vendor_name        IN  VARCHAR2 := NULL
         , p_suggested_vendor_id          IN  NUMBER   := NULL
         , p_suggested_vendor_site        IN  VARCHAR2 := NULL
         , p_suggested_vendor_site_id     IN  NUMBER   := NULL
         , p_suggested_vendor_contact     IN  VARCHAR2 := NULL
         , p_suggested_vendor_contact_id  IN  NUMBER   := NULL
         , p_suggested_vendor_phone       IN  VARCHAR2 := NULL
         , p_suggested_vendor_item_num    IN  VARCHAR2 := NULL
         , p_required_quantity            IN  NUMBER
         , p_unit_price                   IN  NUMBER
         , p_uom                          IN  VARCHAR2
         , p_need_by_date                 IN  DATE
         , p_amount                       IN  NUMBER
         , p_order_type_lookup_code       IN  VARCHAR2
         , x_direct_item_sequence_id      IN OUT NOCOPY NUMBER
         , x_return_status                OUT NOCOPY VARCHAR2
         ) IS

         l_direct_item_sequence_id NUMBER := NULL;
         l_department_id NUMBER := NULL;
         l_uom_code VARCHAR2(100);
         l_count NUMBER;
BEGIN

 -- For non-stock direct items no need to populate wip_resource_seq_num.So returning null
  IF p_inventory_item_id is not null then
    x_direct_item_sequence_id := null;
    x_return_status := 'S';
    return;
  END IF;

--If x_direct_item_sequence_id is not null,then requisition is being updated.In that case we same value should be returned
  --if it exists against the given work order and operation

  if x_direct_item_sequence_id is not null then
      select sum(count) into l_count from
      (
        select count(*) as count
        from wip_eam_direct_items wed
        where wed.wip_entity_id = p_wip_entity_id and
              wed.operation_seq_num = p_operation_seq_num and
              wed.direct_item_sequence_id = x_direct_item_sequence_id and
              wed.organization_id = p_organization_id

        union all

        SELECT count(*) as count
        FROM
          po_requisition_lines_all pr,
          wip_entities we
        WHERE
              pr.destination_organization_id = p_organization_id
        AND pr.item_id is null
        AND pr.wip_resource_seq_num = x_direct_item_sequence_id
        AND pr.destination_type_code = 'SHOP FLOOR'
        AND pr.wip_entity_id = we.wip_entity_id
        AND pr.wip_operation_seq_num = p_operation_seq_num
        AND pr.wip_entity_id = p_wip_entity_id
        AND we.entity_type in (6,7)

        union all
        SELECT count(*) as count
        FROM
          po_distributions_all pd,
          po_lines_all pl,
          wip_entities we
        WHERE
              pd.destination_organization_id = p_organization_id
        AND pd.po_line_id = pl.po_line_id(+)
        AND pl.item_id is null
        AND pd.wip_resource_seq_num = x_direct_item_sequence_id
        AND pd.destination_type_code = 'SHOP FLOOR'
        AND pd.wip_entity_id = we.wip_entity_id
        AND pd.wip_operation_seq_num = p_operation_seq_num
        AND pd.wip_entity_id = p_wip_entity_id
        AND we.entity_type in (6,7)
      ) ;

      if(l_count > 0) then
           x_return_status := 'S';
           return ;
      end if;
  end if;

  select count(*) into l_count from wip_eam_direct_items wed where
                        wed.wip_entity_id = p_wip_entity_id and
                        wed.operation_seq_num = p_operation_seq_num and
                        wed.description = p_description and
			wed.organization_id = p_organization_id;

  --Entry is already there. return the direct item sequence id.
  if l_count > 0 then
    select max(direct_item_sequence_id) into x_direct_item_sequence_id
                        from wip_eam_direct_items wed where
                        wed.wip_entity_id = p_wip_entity_id and
                        wed.operation_seq_num = p_operation_seq_num and
                        wed.description = p_description and
			wed.organization_id = p_organization_id;
    x_return_status := 'S';
    return;
  end if;

  select wip_eam_di_seq_id_s.nextval into l_direct_item_sequence_id from dual;

  IF (p_operation_seq_num is not null AND
   p_wip_entity_id is not null     AND
   p_organization_id is not null)
  THEN
  SELECT department_id INTO l_department_id
  FROM wip_operations
  WHERE wip_entity_id = p_wip_entity_id AND
        operation_seq_num = p_operation_seq_num AND
        organization_id = p_organization_id;
  END IF;

  IF(p_uom IS NOT null) THEN -- 9727518
  select distinct uom_code into l_uom_code from mtl_uom_conversions muc where muc.unit_of_measure = p_uom;
  END IF;

  INSERT INTO WIP_EAM_DIRECT_ITEMS
         (
           DESCRIPTION
         , PURCHASING_CATEGORY_ID
         , DIRECT_ITEM_SEQUENCE_ID
         , OPERATION_SEQ_NUM
         , DEPARTMENT_ID
         , WIP_ENTITY_ID
         , ORGANIZATION_ID
         , SUGGESTED_VENDOR_NAME
         , SUGGESTED_VENDOR_ID
         , SUGGESTED_VENDOR_SITE
         , SUGGESTED_VENDOR_SITE_ID
         , SUGGESTED_VENDOR_CONTACT
         , SUGGESTED_VENDOR_CONTACT_ID
         , SUGGESTED_VENDOR_PHONE
         , SUGGESTED_VENDOR_ITEM_NUM
         , UNIT_PRICE
         , AUTO_REQUEST_MATERIAL
         , REQUIRED_QUANTITY
         , UOM
         , NEED_BY_DATE
         , last_update_date
         , last_updated_by
         , creation_date
         , created_by
         , last_update_login
         , AMOUNT
         , ORDER_TYPE_LOOKUP_CODE)

         VALUES
         (
           p_description
         , p_purchasing_category_id
         , l_direct_item_sequence_id
         , p_operation_seq_num
         , l_department_id
         , p_wip_entity_id
         , p_organization_id
         , p_suggested_vendor_name
         , p_suggested_vendor_id
         , p_suggested_vendor_site
         , p_suggested_vendor_site_id
         , p_suggested_vendor_contact
         , p_suggested_vendor_contact_id
         , p_suggested_vendor_phone
         , p_suggested_vendor_item_num
         , p_unit_price
         , 'Y'
         , p_required_quantity
         , l_uom_code
         , p_need_by_date
         , SYSDATE
         , FND_GLOBAL.user_id
         , SYSDATE
         , FND_GLOBAL.user_id
         , FND_GLOBAL.login_id
         , p_amount
         , p_order_type_lookup_code);

         x_direct_item_sequence_id := l_direct_item_sequence_id;
         x_return_status := 'S';

      EXCEPTION
        WHEN OTHERS THEN
          x_return_status := 'E';

    END UPDATE_WO_ADD_DES_DIR_ITEM;

END EAM_PROCESS_WO_PUB;

/
