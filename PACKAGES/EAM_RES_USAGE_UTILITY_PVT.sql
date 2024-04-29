--------------------------------------------------------
--  DDL for Package EAM_RES_USAGE_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_RES_USAGE_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVRUUS.pls 120.1 2005/10/06 02:00:54 mmaduska noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVRUUS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_RES_USAGE_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  12-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

        PROCEDURE Add_Usage
        ( p_eam_res_usage_rec  IN  EAM_PROCESS_WO_PUB.eam_res_usage_rec_type
        , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_Status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Delete_Usage
        ( p_wip_entity_id      IN NUMBER
        , p_organization_id    IN NUMBER
        , p_operation_seq_num  IN NUMBER
        , p_resource_seq_num   IN NUMBER
        , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_Status      OUT NOCOPY VARCHAR2
         );


        FUNCTION NUM_OF_ROW
        ( p_eam_res_usage_tbl  IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
        , p_wip_entity_id      IN NUMBER
        , p_organization_id    IN NUMBER
        , p_operation_seq_num  IN NUMBER
        , p_resource_seq_num   IN NUMBER
        ) RETURN BOOLEAN;


END EAM_RES_USAGE_UTILITY_PVT;

 

/
