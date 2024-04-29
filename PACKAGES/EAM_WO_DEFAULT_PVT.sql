--------------------------------------------------------
--  DDL for Package EAM_WO_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WO_DEFAULT_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWODS.pls 120.2 2005/08/25 00:08:54 mmaduska noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWODS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WO_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/


        PROCEDURE Attribute_Defaulting
        (  p_eam_wo_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
	 , p_old_eam_wo_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_wo_rec         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_mesg_token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Conditional_Defaulting
        (  p_eam_wo_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_wo_rec         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_mesg_token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Populate_Null_Columns
        (  p_eam_wo_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , p_old_eam_wo_rec     IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_wo_rec         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
        );

        -- get wip_entity_id
        FUNCTION get_wip_entity_id
        RETURN NUMBER;

        -- get wip_entity_name_prefix
        FUNCTION get_wip_entity_name_prefix
        (  p_organization_id IN  NUMBER
        )
        RETURN VARCHAR2;

        -- get wip_entity_name
         FUNCTION get_wip_entity_name(p_org_id NUMBER,p_plan_maintenance IN VARCHAR2)
        RETURN VARCHAR2;

END EAM_WO_DEFAULT_PVT;

 

/
