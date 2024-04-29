--------------------------------------------------------
--  DDL for Package EAM_RES_INST_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_RES_INST_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVRIUS.pls 115.2 2003/10/22 21:08:59 baroy ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVRIUS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_RES_INST_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  12-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

        PROCEDURE Query_Row
        ( p_wip_entity_id      IN  NUMBER
        , p_organization_id    IN  NUMBER
        , p_operation_seq_num  IN  NUMBER
        , p_resource_seq_num   IN  NUMBER
        , p_instance_id        IN  NUMBER
        , p_serial_number      IN  VARCHAR2
        , x_eam_res_inst_rec   OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
        , x_Return_status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Insert_Row
        ( p_eam_res_inst_rec   IN  EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
        , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_Status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Update_Row
        ( p_eam_res_inst_rec   IN  EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
        , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_Status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Delete_Row
        ( p_eam_res_inst_rec   IN  EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
        , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_Status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Perform_Writes
        ( p_eam_res_inst_rec   IN  EAM_PROCESS_WO_PUB.eam_res_inst_rec_type
        , x_mesg_token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_status      OUT NOCOPY VARCHAR2
        );

END EAM_RES_INST_UTILITY_PVT;

 

/
