--------------------------------------------------------
--  DDL for Package EAM_MAT_REQ_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_MAT_REQ_DEFAULT_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVMRDS.pls 115.2 2003/06/11 06:16:11 agaurav ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMPMRDS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_MAT_REQ_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/


        PROCEDURE Attribute_Defaulting
        (  p_eam_mat_req_rec         IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_eam_mat_req_rec         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
         );

        PROCEDURE Populate_Null_Columns
        (  p_eam_mat_req_rec         IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , p_old_eam_mat_req_rec     IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
         , x_eam_mat_req_rec         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
        );


        PROCEDURE GetMaterials_In_Op1
        (   p_eam_mat_req_tbl     IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
          , p_organization_id         IN  NUMBER
          , p_wip_entity_id           IN  NUMBER
          , x_eam_mat_req_tbl      OUT  NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
        );


		PROCEDURE Change_OpSeqNum1
	    (   p_eam_mat_req_rec     IN  EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
		  , p_operation_seq_num   IN   NUMBER
	      , p_department_id          IN NUMBER
		  , x_eam_mat_req_rec      OUT  NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_rec_type
        );


END EAM_MAT_REQ_DEFAULT_PVT;

 

/
