--------------------------------------------------------
--  DDL for Package EAM_SUB_RESOURCE_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_SUB_RESOURCE_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVSRUS.pls 115.1 2002/11/24 23:46:17 baroy noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVSRUS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_SUB_RESOURCE_UTILITY_PVT
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
        , x_eam_sub_res_rec    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_rec_type
        , x_Return_status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Insert_Row
        ( p_eam_sub_res_rec    IN  EAM_PROCESS_WO_PUB.eam_sub_res_rec_type
        , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_Status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Update_Row
        ( p_eam_sub_res_rec    IN  EAM_PROCESS_WO_PUB.eam_sub_res_rec_type
        , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_Status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Delete_Row
        ( p_eam_sub_res_rec    IN  EAM_PROCESS_WO_PUB.eam_sub_res_rec_type
        , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_Status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Perform_Writes
        ( p_eam_sub_res_rec    IN  EAM_PROCESS_WO_PUB.eam_sub_res_rec_type
        , x_mesg_token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_status      OUT NOCOPY VARCHAR2
        );

END EAM_SUB_RESOURCE_UTILITY_PVT;

 

/
