--------------------------------------------------------
--  DDL for Package EAM_EXPLODE_ACTIVITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_EXPLODE_ACTIVITY_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVEXAS.pls 115.3 2004/01/06 08:54:48 samjain ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVEXAS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_EXPLODE_ACTIVITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  12-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/


      PROCEDURE EXPLODE_ACTIVITY
         ( p_validation_level        IN  NUMBER
         , p_eam_wo_rec              IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , p_eam_op_tbl              IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , p_eam_op_network_tbl      IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , p_eam_res_tbl             IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , p_eam_res_inst_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , p_eam_sub_res_tbl         IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , p_eam_res_usage_tbl       IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , p_eam_mat_req_tbl         IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_wo_rec              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl              OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl             OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_res_usage_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
         );

--Bug#3342391 : Modified the function definition to pass 2 new parameters and default it to null
--    for backward compatibility.The parameters contain the operation_sequence_id and operations_sequence_number
--    and common_routing_sequence_id
      PROCEDURE COPY_ATTACHMENT
         ( p_organization_id         IN  NUMBER
         , p_asset_activity_id       IN  NUMBER
         , p_wip_entity_id           IN  NUMBER
         , p_bill_sequence_id        IN  NUMBER
         , x_error_message           OUT NOCOPY VARCHAR2
         , x_return_status           OUT NOCOPY VARCHAR2
         , p_common_routing_sequence_id IN NUMBER := NULL
         , p_operation_sequence_id  IN NUMBER := NULL
         , p_operation_sequence_num IN NUMBER := NULL
         );

END EAM_EXPLODE_ACTIVITY_PVT;

 

/
