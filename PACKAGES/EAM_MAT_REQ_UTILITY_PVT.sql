--------------------------------------------------------
--  DDL for Package EAM_MAT_REQ_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_MAT_REQ_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVMRUS.pls 115.2 2003/06/11 06:20:41 agaurav ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVMRUS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_MAT_REQ_UTILITY_PVT
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
        , p_inventory_item_id  IN  NUMBER
        , x_eam_mat_req_rec    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
        , x_Return_status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Insert_Row
        ( p_eam_mat_req_rec    IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
        , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_Status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Update_Row
        ( p_eam_mat_req_rec    IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
        , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_Status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Delete_Row
        ( p_eam_mat_req_rec    IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
        , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_Status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Perform_Writes
        ( p_eam_mat_req_rec    IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
        , x_mesg_token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_status      OUT NOCOPY VARCHAR2
        );

		FUNCTION NUM_OF_ROW
        ( p_wip_entity_id NUMBER
	    , p_organization_id NUMBER
	    , p_operation_seq_num NUMBER
	    ) RETURN BOOLEAN ;


END EAM_MAT_REQ_UTILITY_PVT;

 

/
