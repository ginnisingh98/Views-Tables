--------------------------------------------------------
--  DDL for Package EAM_PROCESS_WO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PROCESS_WO_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWOPS.pls 120.2.12010000.2 2011/10/25 11:30:36 vboddapa ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWOPS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_PROCESS_WO_PVT
--
--  NOTES
--
--  HISTORY
--
--  12-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/
    G_OPR_SYNC          CONSTANT    NUMBER := 0;
    G_OPR_CREATE        CONSTANT    NUMBER := 1;
    G_OPR_UPDATE        CONSTANT    NUMBER := 2;
    G_OPR_DELETE        CONSTANT    NUMBER := 3;
    G_OPR_COMPLETE      CONSTANT    NUMBER := 4;
    G_OPR_UNCOMPLETE    CONSTANT    NUMBER := 5;
    G_RECORD_FOUND      CONSTANT    VARCHAR2(1)  := 'S';
    G_RECORD_NOT_FOUND  CONSTANT    VARCHAR2(1)  := 'F';

    Debug_File      UTL_FILE.FILE_TYPE;


PROCEDURE RESOURCE_USAGES
        (  p_validation_level        IN  NUMBER
        ,  p_wip_entity_id           IN  NUMBER := NULL
        ,  p_organization_id         IN  NUMBER := NULL
        ,  p_operation_seq_num       IN  NUMBER := NULL
	,  p_resource_seq_num        IN  NUMBER := NULL
        ,  p_eam_res_usage_tbl       IN EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
	,  x_bottomup_scheduled      IN OUT NOCOPY NUMBER
        ,  x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
        ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status           OUT NOCOPY VARCHAR2
        );


PROCEDURE SUB_RESOURCES
        (  p_validation_level        IN  NUMBER
        ,  p_wip_entity_id           IN  NUMBER := NULL
        ,  p_organization_id         IN  NUMBER := NULL
        ,  p_operation_seq_num       IN  NUMBER := NULL
        ,  p_eam_sub_res_tbl         IN EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
        ,  p_eam_res_usage_tbl       IN EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
	,  x_bottomup_scheduled      IN OUT NOCOPY NUMBER
        ,  x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
        ,  x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
        ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status           OUT NOCOPY VARCHAR2
        );


PROCEDURE RESOURCE_INSTANCES
        (  p_validation_level        IN  NUMBER
        ,  p_wip_entity_id           IN  NUMBER := NULL
        ,  p_organization_id         IN  NUMBER := NULL
        ,  p_operation_seq_num       IN  NUMBER := NULL
        ,  p_resource_seq_num        IN  NUMBER := NULL
        ,  p_eam_res_inst_tbl        IN EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        ,  x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status           OUT NOCOPY VARCHAR2
	,  x_schedule_wo              IN OUT NOCOPY NUMBER
	,  x_bottomup_scheduled      IN OUT NOCOPY NUMBER
        );


PROCEDURE MATERIAL_REQUIREMENTS
        (  p_validation_level        IN  NUMBER
        ,  p_wip_entity_id           IN  NUMBER := NULL
        ,  p_organization_id         IN  NUMBER := NULL
        ,  p_operation_seq_num       IN  NUMBER := NULL
        ,  p_department_id           IN  NUMBER := NULL
        ,  p_eam_mat_req_tbl         IN EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
	,  x_material_shortage       IN OUT NOCOPY NUMBER
        ,  x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
        ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status           OUT NOCOPY VARCHAR2
        );

PROCEDURE OPERATION_RESOURCES
        (  p_validation_level        IN  NUMBER
        ,  p_wip_entity_id           IN  NUMBER := NULL
        ,  p_organization_id         IN  NUMBER := NULL
        ,  p_operation_seq_num       IN  NUMBER := NULL
        ,  p_eam_res_tbl             IN EAM_PROCESS_WO_PUB.eam_res_tbl_type
        ,  p_eam_res_inst_tbl        IN EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        ,  p_eam_res_usage_tbl       IN EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
        ,  x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
        ,  x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        ,  x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
	,  x_schedule_wo              IN OUT NOCOPY NUMBER
	,  x_bottomup_scheduled      IN OUT NOCOPY NUMBER
        ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status           OUT NOCOPY VARCHAR2
        );


PROCEDURE OPERATION_NETWORKS
        (  p_validation_level        IN  NUMBER
        ,  p_wip_entity_id           IN  NUMBER := NULL
        ,  p_organization_id         IN  NUMBER := NULL
        ,  p_eam_op_network_tbl      IN EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
        ,  x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
	,  x_schedule_wo              IN OUT NOCOPY NUMBER
	,  x_bottomup_scheduled      IN OUT NOCOPY NUMBER
        ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status           OUT NOCOPY VARCHAR2
        );

PROCEDURE WO_OPERATIONS
        (  p_validation_level        IN  NUMBER
        ,  p_wip_entity_id           IN  NUMBER := NULL
        ,  p_organization_id         IN  NUMBER := NULL
        ,  p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
        ,  p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
        ,  p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
        ,  p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        ,  p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
        ,  p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
        ,  p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
        ,  p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
        ,  x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
        ,  x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
        ,  x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
        ,  x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        ,  x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
        ,  x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
        ,  x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
        ,  x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
	,  x_schedule_wo              IN OUT NOCOPY NUMBER
	,  x_bottomup_scheduled      IN OUT NOCOPY NUMBER
	,  x_material_shortage       IN OUT NOCOPY NUMBER
        ,  x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ,  x_return_status           OUT NOCOPY VARCHAR2
        );

      PROCEDURE WORK_ORDER
         ( p_validation_level        IN  NUMBER
         , p_eam_wo_rec              IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
	 , p_wip_entity_id           IN  NUMBER
         , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
	 , x_schedule_wo             IN OUT NOCOPY NUMBER
	 , x_bottomup_scheduled      IN OUT NOCOPY NUMBER
 	 , x_material_shortage       IN OUT NOCOPY NUMBER
         , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
         );

       PROCEDURE PROCESS_WO
         ( p_api_version_number      IN  NUMBER := 1.0
         , p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_eam_wo_rec              IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         );

      PROCEDURE Validate_Transaction_Type
        ( p_transaction_type         IN  NUMBER
        , p_entity_name              IN  VARCHAR2
        , p_entity_id                IN  VARCHAR2
        , x_valid_transaction        OUT NOCOPY BOOLEAN
        , x_Mesg_Token_Tbl           OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        );

	 PROCEDURE COMP_UNCOMP_WORKORDER
	(
	   p_eam_wo_comp_rec             IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
	 , p_eam_wo_quality_tbl          IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
	 , p_eam_meter_reading_tbl       IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
	 , p_eam_counter_prop_tbl        IN  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
	 , p_eam_wo_comp_rebuild_tbl     IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
	 , p_eam_wo_comp_mr_read_tbl     IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
	 , x_eam_wo_comp_rec             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
	 , x_eam_wo_quality_tbl          OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
	 , x_eam_meter_reading_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
	 , x_eam_counter_prop_tbl        OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
	 , x_eam_wo_comp_rebuild_tbl     OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
	 , x_eam_wo_comp_mr_read_tbl     OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
	 , x_return_status               OUT NOCOPY VARCHAR2
	 , x_msg_count                   OUT NOCOPY NUMBER
	);

	PROCEDURE COMP_UNCOMP_OPERATION
	(
	  p_eam_op_compl_tbl	    IN EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	, p_eam_wo_quality_tbl      IN EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
	, x_eam_op_comp_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
	, x_eam_wo_quality_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
	, x_return_status           OUT NOCOPY VARCHAR2
	, x_msg_count               OUT NOCOPY NUMBER
	);

	PROCEDURE SERVICE_WORKREQUEST_ASSO
	(
	  p_eam_request_tbl	    IN EAM_PROCESS_WO_PUB.eam_request_tbl_type
	, x_eam_request_tbl	    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_request_tbl_type
	, x_return_status           OUT NOCOPY VARCHAR2
	, x_msg_count               OUT NOCOPY NUMBER
	);


      PROCEDURE Set_Debug
        (p_debug_flag                IN  VARCHAR2
         );


      FUNCTION Get_Debug RETURN VARCHAR2;

     --Fix for 3360801.the following procedure will update the records returned by the api with the correct dates

      PROCEDURE UPDATE_DATES
        (x_eam_wo_rec IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type,
	 x_eam_op_tbl IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type,
	 x_eam_res_tbl IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type,
	 x_eam_res_inst_tbl IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
        );

	PROCEDURE LOG_WORK_ORDER_HEADER
        (
         p_eam_wo_rec              IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
        );

END EAM_PROCESS_WO_PVT;

/
